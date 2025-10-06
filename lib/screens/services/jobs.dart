import 'package:flutter/material.dart';
import '../../widgets/search_only_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/featured_jobs_widget.dart'; // Import your existing widget

class JobsPage extends StatelessWidget {
  const JobsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> sliderImages = [
      'https://images.unsplash.com/photo-1486312338219-ce68e2c6b9f0?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1497032205916-ac775f0649ae?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
      'https://images.unsplash.com/photo-1560472354-b33ff0c44a43?ixlib=rb-4.0.3&auto=format&fit=crop&w=1000&q=80',
    ];

    // Featured Jobs data
    final List<Job> featuredJobs = [
      Job(
        title: 'Senior Software Engineer',
        companyName: 'TechVision Solutions',
        location: 'Beirut, Lebanon',
        jobType: 'Full-time',
        imageUrl:
            'https://images.pexels.com/photos/3184360/pexels-photo-3184360.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'Digital Marketing Manager',
        companyName: 'Creative Media Hub',
        location: 'Jounieh, Mount Lebanon',
        jobType: 'Full-time',
        imageUrl:
            'https://images.pexels.com/photos/3184292/pexels-photo-3184292.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'UI/UX Designer',
        companyName: 'Design Studio Pro',
        location: 'Hazmieh, Mount Lebanon',
        jobType: 'Contract',
        imageUrl:
            'https://images.pexels.com/photos/3184465/pexels-photo-3184465.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'Data Analyst',
        companyName: 'Analytics Corp',
        location: 'Antelias, Mount Lebanon',
        jobType: 'Full-time',
        imageUrl:
            'https://images.pexels.com/photos/3184639/pexels-photo-3184639.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
    ];

    // Top Rated Jobs data
    final List<Job> topRatedJobs = [
      Job(
        title: 'Project Manager',
        companyName: 'Elite Consulting Group',
        location: 'Beirut, Lebanon',
        jobType: 'Full-time',
        imageUrl:
            'https://images.pexels.com/photos/3184287/pexels-photo-3184287.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'Sales Representative',
        companyName: 'Global Trading Co.',
        location: 'Dbayeh, Mount Lebanon',
        jobType: 'Full-time',
        imageUrl:
            'https://images.pexels.com/photos/3184418/pexels-photo-3184418.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'Content Writer',
        companyName: 'WordCraft Agency',
        location: 'Sin El Fil, Mount Lebanon',
        jobType: 'Part-time',
        imageUrl:
            'https://images.pexels.com/photos/3184454/pexels-photo-3184454.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'Financial Advisor',
        companyName: 'Premier Finance',
        location: 'Kaslik, Mount Lebanon',
        jobType: 'Full-time',
        imageUrl:
            'https://images.pexels.com/photos/3184298/pexels-photo-3184298.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
    ];

    // For You Jobs data (personalized recommendations)
    final List<Job> forYouJobs = [
      Job(
        title: 'Mobile App Developer',
        companyName: 'AppTech Innovations',
        location: 'Beirut, Lebanon',
        jobType: 'Remote',
        imageUrl:
            'https://images.pexels.com/photos/3184317/pexels-photo-3184317.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'Graphic Designer',
        companyName: 'Visual Arts Studio',
        location: 'Jounieh, Mount Lebanon',
        jobType: 'Contract',
        imageUrl:
            'https://images.pexels.com/photos/3184432/pexels-photo-3184432.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'Customer Service Rep',
        companyName: 'Service Excellence Ltd',
        location: 'Hazmieh, Mount Lebanon',
        jobType: 'Part-time',
        imageUrl:
            'https://images.pexels.com/photos/3184357/pexels-photo-3184357.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
      Job(
        title: 'Social Media Specialist',
        companyName: 'Digital Reach Agency',
        location: 'Dbayeh, Mount Lebanon',
        jobType: 'Full-time',
        imageUrl:
            'https://images.pexels.com/photos/3184394/pexels-photo-3184394.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500',
      ),
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
            const SearchOnlyWidget(),
            const SizedBox(height: 10),
            ImageSliderWidget(imageUrls: sliderImages),
            const SizedBox(height: 20),

            // Featured Jobs
            FeaturedJobsWidget(
              title: 'Featured Jobs',
              jobs: featuredJobs,
            ),
            const SizedBox(height: 20),

            // Top Rated Jobs
            FeaturedJobsWidget(
              title: 'Top Rated',
              jobs: topRatedJobs,
            ),
            const SizedBox(height: 20),

            // For You Jobs (Personalized recommendations)
            FeaturedJobsWidget(
              title: 'For You',
              jobs: forYouJobs,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
