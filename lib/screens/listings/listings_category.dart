// enums/listing_category.dart

import 'package:loopflutter/l10n/app_localizations.dart';

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
  villas(
    displayName: 'Villas',
    routeName: '/villas',
    apiType: 'villa',
  ),
  land(
    displayName: 'Land',
    routeName: '/land',
    apiType: 'land',
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

  // Get localized display name
  String getLocalizedDisplayName(AppLocalizations? l10n) {
    if (l10n == null) return displayName;
    switch (this) {
      case ListingCategory.featured:
        return l10n.featuredListings;
      case ListingCategory.newListings:
        return l10n.newListings;
      case ListingCategory.apartments:
        return l10n.apartments;
      case ListingCategory.chalets:
        return l10n.chalets;
      case ListingCategory.villas:
        return l10n.villas;
      case ListingCategory.land:
        return l10n.land;
      case ListingCategory.commercial:
        return l10n.commercial;
    }
  }
  
  // Backward compatibility: provide extension-like getters
  // These are already properties but ensure compatibility with code expecting extension methods
}