import 'package:flutter/material.dart';
import '../../widgets/job_search_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/dynamic_jobs_widget.dart';
import '../../services/banner_service.dart';

class JobsPage extends StatefulWidget {
  const JobsPage({super.key});

  @override
  State<JobsPage> createState() => _JobsPageState();
}

class _JobsPageState extends State<JobsPage> {
  List<String> _bannerImages = [];
  bool _isLoadingBanner = true;

  @override
  void initState() {
    super.initState();
    _fetchBanner();
  }

  Future<void> _fetchBanner() async {
    try {
      final banner = await BannerService.getBanner(BannerService.jobsScreen);
      if (mounted) {
        setState(() {
          _bannerImages = banner?.imageUrls ?? [];
          _isLoadingBanner = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _bannerImages = [];
          _isLoadingBanner = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
            _isLoadingBanner
                ? const SizedBox(
                    height: 200,
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _bannerImages.isNotEmpty
                    ? ImageSliderWidget(imageUrls: _bannerImages)
                    : const SizedBox(height: 0), // Temporary space when no banner
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
