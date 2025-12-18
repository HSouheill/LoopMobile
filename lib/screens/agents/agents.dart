// Updated agents_page.dart
import 'package:flutter/material.dart';
import '../../widgets/search_only_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/dynamic_agents_widget.dart';
import '../../services/banner_service.dart';

class AgentsPage extends StatefulWidget {
  const AgentsPage({super.key});

  @override
  State<AgentsPage> createState() => _AgentsPageState();
}

class _AgentsPageState extends State<AgentsPage> {
  List<String> _bannerImages = [];
  bool _isLoadingBanner = true;

  @override
  void initState() {
    super.initState();
    _fetchBanner();
  }

  Future<void> _fetchBanner() async {
    try {
      final banner = await BannerService.getBanner(BannerService.agentsScreen);
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search bar component
          const SearchOnlyWidget(),
          const SizedBox(height: 10),
          
          // Image slider
          _isLoadingBanner
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _bannerImages.isNotEmpty
                  ? ImageSliderWidget(imageUrls: _bannerImages)
                  : const SizedBox(height: 0), // Temporary space when no banner
          const SizedBox(height: 10),
          
          // Featured companies section
          const DynamicAgentsWidget(
            category: AgentCategory.featuredCompanies,
          ),
          
          // Top companies section
          const DynamicAgentsWidget(
            category: AgentCategory.topCompanies,
          ),
          
          // Featured agents section (individuals only)
          const DynamicAgentsWidget(
            category: AgentCategory.featured,
          ),
          
          // Top rated agents section (individuals only)
          const DynamicAgentsWidget(
            category: AgentCategory.topRated,
          ),

          const SizedBox(height: 110),
        ],
      ),
    );
  }
}