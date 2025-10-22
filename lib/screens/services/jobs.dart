import 'package:flutter/material.dart';
import '../../widgets/job_search_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/dynamic_jobs_widget.dart';

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> sliderImages = [
      'https://images.unsplash.com/photo-1486312338219-ce68e2c6b9f0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1497032205916-ac775f0649ae?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    ];


    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Jobs',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const JobSearchWidget(),
            const SizedBox(height: 10),
            ImageSliderWidget(imageUrls: sliderImages),
            const SizedBox(height: 20),

            // Featured Jobs
            DynamicJobsWidget(
              category: JobCategory.featured,
              limit: 3,
            ),
            const SizedBox(height: 20),

            // For You Jobs (Personalized recommendations)
            DynamicJobsWidget(
              category: JobCategory.forYou,
              limit: 3,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
