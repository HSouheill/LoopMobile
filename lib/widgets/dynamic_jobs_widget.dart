import 'package:flutter/material.dart';
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
  String get title {
    if (widget.customTitle != null) return widget.customTitle!;

    switch (widget.category) {
      case JobCategory.featured:
        return 'Featured Jobs';
      case JobCategory.forYou:
        return 'For You';
      case JobCategory.recent:
        return 'Recent Jobs';
    }
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
        setState(() {
          error = 'Failed to load jobs: $e';
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
                child: const Text('See all'),
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
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          else if (jobs.isEmpty)
            const SizedBox(
              height: 320,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.work_outline, color: Colors.grey, size: 48),
                    SizedBox(height: 16),
                    Text(
                      'No jobs found',
                      style: TextStyle(color: Colors.grey, fontSize: 16),
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
      print('Error checking favorite status: $e');
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
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Failed to load job details: $e'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.only(right: 16.0),
        constraints: const BoxConstraints(
          maxHeight: 320,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Job image with overlay
            SizedBox(
              height: 160,
              width: double.infinity,
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(0),
                    ),
                    child: Image.network(
                      widget.job.imageUrl,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const SizedBox(
                          height: 160,
                          child: Center(child: CircularProgressIndicator()),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 160,
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
                ],
              ),
            ),

            // Job details
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 0.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.job.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blue.shade100,
                          radius: 12,
                          child: const Icon(Icons.work_outline,
                              size: 14, color: Colors.blue),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            widget.job.companyName,
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            widget.job.location,
                            style: TextStyle(
                              color: Colors.blue.shade700,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(
                          Icons.search,
                          size: 16,
                          color: Colors.blue.shade700,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          widget.job.jobType,
                          style: TextStyle(
                            color: Colors.blue.shade700,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
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
