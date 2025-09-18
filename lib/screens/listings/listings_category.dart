// enums/listing_category.dart

enum ListingCategory {
  // Enum values with their specific properties
  featured(
    displayName: 'Featured Listings',
    routeName: '/featured-listings', // Example route for "See all"
    apiType: null,
  ),
  newListings(
    displayName: 'New Listings',
    routeName: '/new-listings',
    apiType: null,
  ),
  apartments(
    displayName: 'Apartments',
    routeName: '/apartments',
    apiType: 'apartment', // Used for the API call
  ),
  chalets(
    displayName: 'Chalets',
    routeName: '/chalets',
    apiType: 'chalet',
  ),
  commercial(
    displayName: 'Commercial',
    routeName: '/commercial',
    apiType: 'commercial',
  );

  // Constructor for the enum
  const ListingCategory({
    required this.displayName,
    required this.routeName,
    required this.apiType,
  });

  // Properties of the enum
  final String displayName;
  final String routeName;
  final String? apiType;
}