import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../widgets/dynamic_jobs_widget.dart';
import 'job_advanced_filters_page.dart';

class JobSearchResultsPage extends StatefulWidget {
  final String searchQuery;
  final Map<String, dynamic>? initialFilters;

  const JobSearchResultsPage({
    super.key,
    required this.searchQuery,
    this.initialFilters,
  });

  @override
  State<JobSearchResultsPage> createState() => _JobSearchResultsPageState();
}

class _JobSearchResultsPageState extends State<JobSearchResultsPage> {
  List<Job> jobs = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  bool hasMoreData = true;
  bool isLoadingMore = false;
  final ScrollController _scrollController = ScrollController();
  Map<String, dynamic>? _currentFilters;
  late String _currentSearchQuery;

  @override
  void initState() {
    super.initState();
    _currentSearchQuery = widget.searchQuery;
    _currentFilters = widget.initialFilters;
    _loadSearchResults();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      if (!isLoadingMore && hasMoreData) {
        _loadMoreResults();
      }
    }
  }

  Future<void> _loadSearchResults({bool isRefresh = false}) async {
    try {
      setState(() {
        if (isRefresh) {
          currentPage = 1;
          hasMoreData = true;
        }
        isLoading = true;
        error = null;
      });

      // Parse filters for API call
      String? location;
      String? jobType;
      int? minExperience;
      int? maxExperience;
      String? attendance;
      String? skills;
      DateTime? createdFrom;
      DateTime? createdTo;
      bool? isFeatured;
      String sort = 'score';

      if (_currentFilters != null) {
        location = _currentFilters!['location']?.toString();
        jobType = _currentFilters!['jobType']?.toString();
        if (_currentFilters!['minExperience'] != null) {
          minExperience = int.tryParse(_currentFilters!['minExperience'].toString());
        }
        if (_currentFilters!['maxExperience'] != null) {
          maxExperience = int.tryParse(_currentFilters!['maxExperience'].toString());
        }
        attendance = _currentFilters!['attendance']?.toString();
        skills = _currentFilters!['skills']?.toString();
        if (_currentFilters!['createdFrom'] != null) {
          createdFrom = DateTime.tryParse(_currentFilters!['createdFrom'].toString());
        }
        if (_currentFilters!['createdTo'] != null) {
          createdTo = DateTime.tryParse(_currentFilters!['createdTo'].toString());
        }
        if (_currentFilters!['isFeatured'] != null) {
          isFeatured = _currentFilters!['isFeatured'] == true || 
                      _currentFilters!['isFeatured'] == 'true';
        }
        if (_currentFilters!['sort'] != null) {
          sort = _currentFilters!['sort'].toString();
        }
      }

      final response = await JobService.searchJobs(
        query: _currentSearchQuery,
        page: currentPage,
        limit: 20,
        location: location,
        jobType: jobType,
        minExperience: minExperience,
        maxExperience: maxExperience,
        attendance: attendance,
        skills: skills,
        createdFrom: createdFrom,
        createdTo: createdTo,
        isFeatured: isFeatured,
        sort: sort,
      );

      setState(() {
        if (isRefresh) {
          jobs = response.jobs;
        } else {
          jobs.addAll(response.jobs);
        }
        hasMoreData = response.meta.page < response.meta.pages;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _loadMoreResults() async {
    if (isLoadingMore || !hasMoreData) return;

    setState(() {
      isLoadingMore = true;
    });

    currentPage++;
    await _loadSearchResults();

    setState(() {
      isLoadingMore = false;
    });
  }

  Future<void> _onRefresh() async {
    await _loadSearchResults(isRefresh: true);
  }

  void _openAdvancedFilters() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => JobAdvancedFiltersPage(
          initialQuery: _currentSearchQuery,
          initialFilters: _currentFilters,
        ),
      ),
    );

    if (result != null && mounted) {
      setState(() {
        _currentSearchQuery = result['query'] ?? '';
        _currentFilters = result['filters'];
        currentPage = 1;
        hasMoreData = true;
      });
      _loadSearchResults(isRefresh: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: $_currentSearchQuery'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openAdvancedFilters,
            tooltip: 'Filter',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadSearchResults(isRefresh: true),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        (l10n?.failedToLoadJobs ?? 'Failed to load jobs') + (error != null ? ': $error' : ''),
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: jobs.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              SizedBox(height: 80),
                              Center(child: Text(l10n?.noJobsFound ?? 'No jobs found')),
                            ],
                          )
                        : SingleChildScrollView(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Wrap(
                                  spacing: 16,
                                  runSpacing: 16,
                                  children: jobs.map((job) {
                                    return SizedBox(
                                      width: (MediaQuery.of(context).size.width - 48) / 2,
                                      child: JobCard(
                                        job: job,
                                        width: null,
                                        margin: EdgeInsets.zero,
                                      ),
                                    );
                                  }).toList(),
                                ),
                                if (isLoadingMore)
                                  const Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: Center(child: CircularProgressIndicator()),
                                  ),
                              ],
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
