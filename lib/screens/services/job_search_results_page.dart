import 'package:flutter/material.dart';
import '../../services/job_service.dart';
import '../../widgets/dynamic_jobs_widget.dart';

class JobSearchResultsPage extends StatefulWidget {
  final String searchQuery;

  const JobSearchResultsPage({
    super.key,
    required this.searchQuery,
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

  @override
  void initState() {
    super.initState();
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

      final response = await JobService.searchJobs(
        query: widget.searchQuery,
        page: currentPage,
        limit: 20,
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Search: ${widget.searchQuery}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
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
                        'Failed to load search results: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: jobs.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(child: Text('No jobs found')),
                            ],
                          )
                        : GridView.builder(
                            controller: _scrollController,
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.84,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: jobs.length + (isLoadingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == jobs.length) {
                                return const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                );
                              }
                              final job = jobs[index];
                              return JobCard(job: job);
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
