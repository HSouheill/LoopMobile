import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../services/job_service.dart';
import '../services/favorite_service.dart';
import '../screens/services/job_detail_page.dart';
import '../screens/services/category_jobs_page.dart';

// Enum for different job categories/filters
enum JobCategory {
  featured,
  forYou,
  recent,
}

extension JobCategoryExtension on JobCategory {
  String get displayName {
    switch (this) {
      case JobCategory.featured:
        return 'Featured Jobs';
      case JobCategory.forYou:
        return 'For You';
      case JobCategory.recent:
        return 'Recent Jobs';
    }
  }
  
  String getDisplayNameLocalized(AppLocalizations? l10n) {
    if (l10n == null) return displayName;
    switch (this) {
      case JobCategory.featured:
        return l10n.featuredJobs;
      case JobCategory.forYou:
        return l10n.forYouJobs;
      case JobCategory.recent:
        return l10n.recentJobs;
    }
  }
}

class DynamicJobsWidget extends StatefulWidget {
  final JobCategory category;
  final String? customTitle; // Optional custom title override
  final int limit; // Add limit parameter like listings
  final VoidCallback? onSeeAll; // Add onSeeAll callback

  const DynamicJobsWidget({
    super.key,
    required this.category,
    this.customTitle,
    this.limit = 3, // Default to 3 like listings
    this.onSeeAll,
  });

  @override
  State<DynamicJobsWidget> createState() => _DynamicJobsWidgetState();
}

class _DynamicJobsWidgetState extends State<DynamicJobsWidget> {
  List<Job> jobs = [];
  bool isLoading = false;
  String error = '';

  @override
  void initState() {
    super.initState();
    _loadJobs();
  }

  // Get title based on category
  String _getTitle(AppLocalizations? l10n) {
    if (widget.customTitle != null) return widget.customTitle!;
    return widget.category.getDisplayNameLocalized(l10n);
  }

  // Get filter parameters based on category
  Map<String, String> get filterParams {
    final params = <String, String>{'limit': widget.limit.toString()};
    switch (widget.category) {
      case JobCategory.featured:
        params.addAll({'isFeatured': 'true', 'sort': 'date_desc'});
        break;
      case JobCategory.forYou:
        params.addAll({'sort': 'date_desc'});
        break;
      case JobCategory.recent:
        params.addAll({'sort': 'date_desc'});
        break;
    }
    return params;
  }

  Future<void> _loadJobs() async {
    if (!mounted) return;

    setState(() {
      isLoading = true;
      error = '';
    });

    try {
      final response = await JobService.getJobs(
        page: 1,
        limit: widget.limit,
        isFeatured: widget.category == JobCategory.featured ? true : null,
        sort: 'date_desc',
      );
      if (mounted) {
        setState(() {
          jobs = response.jobs;
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          error = l10n?.failedToLoadJobs ?? 'Failed to load jobs: $e';
          isLoading = false;
        });
      }
    }
  }

  void _handleSeeAll() {
    if (widget.onSeeAll != null) {
      widget.onSeeAll!();
      return;
    }
    // Navigate to category jobs page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CategoryJobsPage(category: widget.category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = _getTitle(l10n);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with title and "See all" button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              TextButton(
                onPressed: _handleSeeAll,
                child: Text(l10n?.seeAll ?? 'See all'),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Content area
          if (isLoading)
            const SizedBox(
              height: 320,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (error.isNotEmpty)
            SizedBox(
              height: 320,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline,
                        color: Colors.red.shade400, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      error,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade600),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _loadJobs,
                      child: Text(l10n?.retry ?? 'Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (jobs.isEmpty)
            SizedBox(
              height: 320,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.work_outline, color: Colors.grey, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      l10n?.noJobsFound ?? 'No jobs found',
                      style: const TextStyle(color: Colors.grey, fontSize: 16),
                    ),
                  ],
                ),
              ),
            )
          else
            // Horizontal list of job cards
            SizedBox(
              height: 320,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: jobs.length,
                itemBuilder: (context, index) {
                  return JobCard(job: jobs[index]);
                },
              ),
            ),
        ],
      ),
    );
  }
}

// Widget for a single job card
class JobCard extends StatefulWidget {
  final Job job;

  const JobCard({
    super.key,
    required this.job,
  });

  @override
  State<JobCard> createState() => _JobCardState();
}

class _JobCardState extends State<JobCard> {
  bool _isFavorited = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  // Determine the table based on jobType
  String get _tableType {
    final jobType = widget.job.jobType.toLowerCase();
    // If jobType contains "service" or "provider", use 'user' table, otherwise use 'job' table
    if (jobType.contains('service') || jobType.contains('provider')) {
      return 'user';
    }
    return 'job';
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final result = await FavoriteService.checkFavorite(
        favoritedObjectId: widget.job.id,
        table: _tableType,
      );
      
      if (mounted) {
        setState(() {
          _isFavorited = result['isFavorited'] ?? false;
        });
      }
    } catch (e) {
      // Error checking favorite status
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FavoriteService.toggleFavorite(
        favoritedObjectId: widget.job.id,
        table: _tableType,
      );

      if (mounted) {
        setState(() {
          _isFavorited = result['isFavorited'] ?? false;
          _isLoading = false;
        });

        // Show user feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Favorite status updated'),
            duration: const Duration(seconds: 2),
            backgroundColor: result['success'] == true 
                ? Colors.green 
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        try {
          // Fetch job detail and navigate
          final jobDetail = await JobService.getJobDetail(widget.job.id);
          if (context.mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => JobDetailPage(job: jobDetail),
              ),
            );
          }
        } catch (e) {
          if (context.mounted) {
            final l10n = AppLocalizations.of(context);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(l10n?.failedToLoadJobDetails ?? 'Failed to load job details: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8.0),
        child: Container(
          width: 250,
          margin: const EdgeInsets.only(right: 16.0),
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              color: Colors.grey.shade300,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: IntrinsicHeight(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Job image with overlay - use AspectRatio for responsive sizing
                AspectRatio(
                  aspectRatio: 1.78, // approximately 250:140, works well across devices
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(8),
                          topRight: Radius.circular(8),
                        ),
                        child: Image.network(
                          widget.job.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: Colors.grey[100],
                              child: const Center(child: CircularProgressIndicator()),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[100],
                              child: Center(
                                child: Icon(
                                  Icons.work_outline,
                                  size: 50,
                                  color: Colors.grey[600],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _toggleFavorite,
                          child: CircleAvatar(
                            backgroundColor: Colors.white.withOpacity(0.8),
                            radius: 16,
                            child: _isLoading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  )
                                : Icon(
                                    _isFavorited ? Icons.favorite : Icons.favorite_border,
                                    color: _isFavorited ? Colors.red : Colors.blue,
                                    size: 20,
                                  ),
                          ),
                        ),
                      ),
                      if (widget.job.isFeatured)
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: const Color.fromARGB(255, 244, 208, 3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context);
                                return Text(
                                  l10n?.featuredLabel ?? 'Featured',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                // Job details - content determines height
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.job.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Colors.blue.shade100,
                            radius: 10,
                            child: const Icon(Icons.work_outline,
                                size: 12, color: Colors.blue),
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.job.companyName,
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              widget.job.location,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 13,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 14,
                            color: Colors.blue.shade700,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              widget.job.jobType,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 13,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
