import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../widgets/service_search_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/banner_placeholder_widget.dart';
import '../../widgets/dynamic_services_widget.dart';
import '../../services/service_service.dart';
import '../../services/banner_service.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  List<String> _bannerImages = [];
  bool _isLoadingBanner = true;

  @override
  void initState() {
    super.initState();
    _fetchBanner();
  }

  Future<void> _fetchBanner() async {
    try {
      final banner = await BannerService.getBanner(BannerService.servicesScreen);
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
          const ServiceSearchWidget(),
          const SizedBox(height: 10),
          _isLoadingBanner
              ? const SizedBox(
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                )
              : _bannerImages.isNotEmpty
                  ? ImageSliderWidget(imageUrls: _bannerImages)
                  : const BannerPlaceholderWidget(), // Placeholder when no banner
          const SizedBox(height: 20),

          // Explore Jobs Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Center(
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, '/jobs');
                },
                child: Container(
                  width: 250,
                  padding: const EdgeInsets.symmetric(vertical: 12.0),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 103, 155, 218),
                        Color.fromARGB(255, 69, 100, 201),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(50.0),
                    boxShadow: [], // Keeps it consistent with SupportCard (no shadow)
                  ),
                  child: Center(
                    child: Text(
                      AppLocalizations.of(context)?.exploreJobs ?? 'Explore Jobs',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Featured Services
          const DynamicServicesWidget(
            category: ServiceCategory.featured,
            showSeeAll: true,
          ),

          // Company Services
          DynamicServicesWidget(
            category: ServiceCategory.companies,
            title: AppLocalizations.of(context)?.companies ?? 'Companies',
            showSeeAll: true,
          ),

          // Individual Services
          DynamicServicesWidget(
            category: ServiceCategory.individual,
            title: AppLocalizations.of(context)?.individuals ?? 'Individuals',
            showSeeAll: true,
          ),

          // Top Rated Services
          DynamicServicesWidget(
            category: ServiceCategory.topRated,
            title: AppLocalizations.of(context)?.topRated ?? 'Top Rated',
            showSeeAll: true,
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
