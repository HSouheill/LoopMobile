import 'package:flutter/material.dart';
import '../../widgets/search_and_categories_widget.dart';
import '../../widgets/listing_widgets/dynamic_listings_widget.dart';
import 'listings_category.dart'; // import enum with localization support

class ListingsPage extends StatefulWidget {
  const ListingsPage({super.key});

  @override
  State<ListingsPage> createState() => _ListingsPageState();
}

class _ListingsPageState extends State<ListingsPage> {
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
              const SizedBox(height: 24),
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
        ),
      ],
    );
  }
}
