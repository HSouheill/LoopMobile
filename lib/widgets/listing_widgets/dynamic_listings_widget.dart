import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '/services/listing_service.dart' hide ListingCategory;
import '../../screens/listings/listings_category.dart'; // import enum with localization support
import '../../screens/listings/category_listings_page.dart';
import 'featured_listings_widget.dart' as flw; // reuse shared card UI

class DynamicListingsWidget extends StatefulWidget {
  final ListingCategory category;
  final int limit;
  final VoidCallback? onSeeAll;

  const DynamicListingsWidget({
    super.key,
    required this.category,
    this.limit = 3,
    this.onSeeAll,
  });

  @override
  State<DynamicListingsWidget> createState() => _DynamicListingsWidgetState();
}

class _DynamicListingsWidgetState extends State<DynamicListingsWidget> {
  List<PropertyListing> listings = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      ListingsResponse response;

      switch (widget.category) {
        case ListingCategory.featured:
          response = await ListingService.getFeaturedListings(limit: widget.limit);
          break;
        case ListingCategory.newListings:
          response = await ListingService.getNewListings(limit: widget.limit);
          break;
        case ListingCategory.apartments:
        case ListingCategory.chalets:
        case ListingCategory.villas:
        case ListingCategory.land:
        case ListingCategory.commercial:
          response = await ListingService.getListingsByType(
            type: widget.category.apiType!,
            limit: widget.limit,
          );
          break;
      }

      if (!mounted) return;
      setState(() {
        listings = response.listings;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  void _handleSeeAll() {
    if (widget.onSeeAll != null) {
      widget.onSeeAll!();
      return;
    }
    // Open paginated page for the selected category
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CategoryListingsPage(category: widget.category),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.category.getLocalizedDisplayName(l10n),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: _handleSeeAll,
                child: Text(l10n?.seeAll ?? 'See all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        if (isLoading)
          const SizedBox(
            height: 330,
            child: Center(child: CircularProgressIndicator()),
          )
        else if (error != null)
          SizedBox(
            height: 330,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.failedToLoadListingsCategory(widget.category.getLocalizedDisplayName(l10n), error ?? '') ?? 'Failed to load ${widget.category.displayName.toLowerCase()}',
                    style: Theme.of(context).textTheme.titleMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      error!,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadListings,
                    child: Text(l10n?.retry ?? 'Retry'),
                  ),
                ],
              ),
            ),
          )
        else if (listings.isEmpty)
          SizedBox(
            height: 330,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.noCategoryListingsFound(widget.category.getLocalizedDisplayName(l10n)) ?? 'No ${widget.category.displayName.toLowerCase()} found',
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          )
        else
          SizedBox(
            height: 330,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return flw.PropertyListingCard(listing: listing);
              },
            ),
          ),
        const SizedBox(height: 20),
      ],
    );
  }
}

class PropertyListingCard extends StatelessWidget {
  final PropertyListing listing;

  const PropertyListingCard({
    super.key,
    required this.listing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16.0),
                    topRight: Radius.circular(16.0),
                  ),
                  child: Image.network(
                    listing.imageUrl,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        height: 150,
                        color: Colors.grey[300],
                        child: const Center(
                          child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                        ),
                      );
                    },
                  ),
                ),
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(4.0),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.favorite_border,
                      color: Colors.black,
                      size: 20,
                    ),
                  ),
                ),
                if (listing.isFeatured)
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context);
                          return Text(
                            l10n?.featuredLabel ?? 'Featured',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          );
                        }
                      ),
                    ),
                  ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    listing.title,
                    style: Theme.of(context).textTheme.titleMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    listing.price,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.person, size: 16, color: Colors.grey),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          listing.agentName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 5),
                  Row(
                    children: [
                      const Icon(Icons.location_on, size: 16, color: Colors.blue),
                      const SizedBox(width: 5),
                      Expanded(
                        child: Text(
                          listing.location,
                          style: const TextStyle(color: Colors.blue),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
