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

          // Featured Listings (dynamic, fetches from backend)
          const DynamicListingsWidget(category: ListingCategory.featured),

          const SizedBox(height: 100),
        ],
      ),
    );
  }
}
