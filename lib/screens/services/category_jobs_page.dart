import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/job_service.dart';
import '../../widgets/dynamic_jobs_widget.dart'; // For JobCategory enum and JobCard

class CategoryJobsPage extends StatefulWidget {
  final JobCategory category;

  const CategoryJobsPage({super.key, required this.category});

  @override
  State<CategoryJobsPage> createState() => _CategoryJobsPageState();
}

class _CategoryJobsPageState extends State<CategoryJobsPage> {
  int page = 1;
  final int limit = 10;
  bool isLoading = false;
  String? error;
  List<Job> jobs = [];
  JobMeta? meta;

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

  Future<void> _fetchPage({int pageToFetch = 1}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      JobsResponse response;

      switch (widget.category) {
        case JobCategory.featured:
          response = await JobService.getJobs(
            page: pageToFetch,
            limit: limit,
            isFeatured: true,
            sort: 'featured_first',
          );
          break;
        case JobCategory.forYou:
          response = await JobService.getJobs(
            page: pageToFetch,
            limit: limit,
            sort: 'featured_first',
          );
          break;
        case JobCategory.recent:
          response = await JobService.getJobs(
            page: pageToFetch,
            limit: limit,
            sort: 'featured_first',
          );
          break;
      }

      if (!mounted) return;
      setState(() {
        jobs = response.jobs;
        meta = response.meta;
        page = pageToFetch;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _goToPage(int newPage) {
    if (newPage < 1) return;
    if (meta != null && newPage > meta!.pages) return;
    _fetchPage(pageToFetch: newPage);
  }

  Future<void> _onRefresh() async {
    await _fetchPage(pageToFetch: 1);
  }

  String _getTitle(AppLocalizations? l10n) {
    switch (widget.category) {
      case JobCategory.featured:
        return l10n?.featuredJobs ?? 'Featured Jobs';
      case JobCategory.forYou:
        return l10n?.recommendedJobs ?? 'Recommended Jobs';
      case JobCategory.recent:
        return l10n?.recentJobs ?? 'Recent Jobs';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _getTitle(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: isLoading && jobs.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        '${l10n?.failedToLoadJobs ?? 'Failed to load'} $title: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: jobs.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Center(child: Text(l10n?.noJobsFound ?? 'No jobs found')),
                            ],
                          )
                        : SingleChildScrollView(
                            padding: const EdgeInsets.all(16),
                            child: Wrap(
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
                          ),
                  ),
                  // Pagination controls
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: (meta == null || page <= 1) ? null : () => _goToPage(page - 1),
                          child: Text(l10n?.previous ?? 'Previous'),
                        ),
                        Text('${l10n?.page ?? 'Page'} ${meta?.page ?? page} ${l10n?.ofText ?? 'of'} ${meta?.pages ?? '?'}'),
                        ElevatedButton(
                          onPressed: (meta == null || (meta!.pages != 0 && page >= meta!.pages)) ? null : () => _goToPage(page + 1),
                          child: Text(l10n?.next ?? 'Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

}
