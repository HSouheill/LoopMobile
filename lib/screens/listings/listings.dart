import 'package:flutter/material.dart';
import '../../widgets/search_and_categories_widget.dart';
import '../../widgets/listing_widgets/dynamic_listings_widget.dart';
import '../../services/listing_service.dart';

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Search Bar Component
          const SearchAndCategoriesWidget(),

          // Featured Listings (dynamic, fetches from backend)
          const DynamicListingsWidget(category: ListingCategory.featured),

          // New Listings
          const DynamicListingsWidget(category: ListingCategory.newListings),

          // Apartments
          const DynamicListingsWidget(category: ListingCategory.apartments),

          // Chalets
          const DynamicListingsWidget(category: ListingCategory.chalets),

          // Commercial Buildings
          const DynamicListingsWidget(category: ListingCategory.commercial),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
