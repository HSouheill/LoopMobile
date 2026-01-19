import 'package:flutter/material.dart';
import '../../widgets/search_and_categories_widget.dart';
import '../../widgets/listing_widgets/dynamic_listings_widget.dart';
import '../../widgets/image_slider_widget.dart';
import '../../widgets/banner_placeholder_widget.dart';
import '../../services/banner_service.dart';
import 'listings_category.dart'; // import enum with localization support

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  List<String> _bannerImages = [];
  bool _isLoadingBanner = true;

  @override
  void initState() {
    super.initState();
    _fetchBanner();
  }

  Future<void> _fetchBanner() async {
    try {
      final banner = await BannerService.getBanner(5); // Using bannerNumber 5
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
    return CustomScrollView(
      slivers: [
        // Search and categories widget (scrolls with page)
        const SliverToBoxAdapter(
          child: SearchAndCategoriesWidget(),
        ),
        // Rest of the content
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              // Banner
              _isLoadingBanner
                  ? const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    )
                  : _bannerImages.isNotEmpty
                      ? ImageSliderWidget(imageUrls: _bannerImages)
                      : const BannerPlaceholderWidget(),
              const SizedBox(height: 24),
              // Featured Listings (dynamic, fetches from backend)
              const DynamicListingsWidget(category: ListingCategory.featured),

              // Chalets
              const DynamicListingsWidget(category: ListingCategory.chalets),

              // Villas
              const DynamicListingsWidget(category: ListingCategory.villas),

              // Apartments
              const DynamicListingsWidget(category: ListingCategory.apartments),

              // Land
              const DynamicListingsWidget(category: ListingCategory.land),

              // Commercial Buildings
              const DynamicListingsWidget(category: ListingCategory.commercial),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}
