import 'package:flutter/material.dart';
import '../screens/services/job_detail_page.dart';
import '../services/job_service.dart';

// The main widget that holds the title and the horizontal list of jobs
class FeaturedJobsWidget extends StatelessWidget {
  final String title;
  final List<Job> jobs;

  const FeaturedJobsWidget({
    super.key,
    required this.title,
    required this.jobs,
  });

  @override
  Widget build(BuildContext context) {
    // Make height responsive if you want; for simplicity use a value that fits content
    final double listHeight = 320;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: listHeight,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: jobs.length,
              itemBuilder: (context, index) {
                return JobCard(job: jobs[index], cardHeight: listHeight);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// Widget for a single job card
class JobCard extends StatelessWidget {
  final Job job;
  final double cardHeight;

  const JobCard({
    super.key,
    required this.job,
    required this.cardHeight,
  });

  @override
  Widget build(BuildContext context) {
    // Use the incoming cardHeight so the card can fill the vertical space and layout children with Expanded
    return GestureDetector(
      onTap: () async {
        try {
          // Fetch job detail and navigate
          final jobDetail = await JobService.getJobDetail(job.id);
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
        constraints: BoxConstraints(
          // ensure the card fills the available vertical space (prevents overflow)
          maxHeight: cardHeight,
        ),
        // No border and transparent background
        decoration: const BoxDecoration(
          color: Colors.transparent,
        ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job image with overlay
          SizedBox(
            height: 160, // slightly reduced so details have room
            width: double.infinity,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(0),
                    topRight: Radius.circular(0),
                  ),
                  child: Image.network(
                    job.imageUrl,
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
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      job.jobType,
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: CircleAvatar(
                    backgroundColor: Colors.white.withOpacity(0.8),
                    radius: 16,
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.blue,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Job details — use Expanded so it adapts to available space and won't overflow
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    job.title,
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
                          job.companyName,
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
                          job.location,
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
                  const Spacer(),
                  Row(
                    children: [
                      Icon(
                        Icons.search,
                        size: 16,
                        color: Colors.blue.shade700,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        job.jobType,
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
