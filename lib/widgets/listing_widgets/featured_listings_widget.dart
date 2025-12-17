// widgets/featured_listings_widget.dart
import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/listing_service.dart';
import '../../services/favorite_service.dart';
import '../../screens/listings/single_listing_page.dart';

class FeaturedListingsWidget extends StatefulWidget {
  final String title;
  final VoidCallback? onSeeAll;
  final bool isMainPage;

  const FeaturedListingsWidget({
    super.key,
    required this.title,
    this.onSeeAll,
    this.isMainPage = true,
  });

  @override
  State<FeaturedListingsWidget> createState() => _FeaturedListingsWidgetState();
}

class _FeaturedListingsWidgetState extends State<FeaturedListingsWidget> {
  List<PropertyListing> listings = [];
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadFeaturedListings();
  }

  Future<void> _loadFeaturedListings() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      final response = await ListingService.getFeaturedListings(
        limit: widget.isMainPage ? 3 : 10,
      );
      
      setState(() {
        listings = response.listings;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.isMainPage)
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context);
                    return TextButton(
                      onPressed: widget.onSeeAll,
                      child: Text(l10n?.seeAll ?? 'See all'),
                    );
                  }
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
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return Text(
                        l10n?.failedToLoadFeaturedListings ?? 'Failed to load listings',
                        style: Theme.of(context).textTheme.titleMedium,
                      );
                    }
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error!,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return ElevatedButton(
                        onPressed: _loadFeaturedListings,
                        child: Text(l10n?.retry ?? 'Retry'),
                      );
                    }
                  ),
                ],
              ),
            ),
          )
        else if (listings.isEmpty)
          Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context);
              return SizedBox(
                height: 330,
                child: Center(
                  child: Text(l10n?.noFeaturedListingsFound ?? 'No featured listings found'),
                ),
              );
            }
          )
        else
          SizedBox(
            height: 330,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: listings.length,
              itemBuilder: (context, index) {
                final listing = listings[index];
                return PropertyListingCard(listing: listing);
              },
            ),
          ),
      ],
    );
  }
}

class PropertyListingCard extends StatefulWidget {
  final PropertyListing listing;

  const PropertyListingCard({
    super.key,
    required this.listing,
  });

  @override
  State<PropertyListingCard> createState() => _PropertyListingCardState();
}

class _PropertyListingCardState extends State<PropertyListingCard> {
  bool _isFavorited = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkFavoriteStatus();
  }

  Future<void> _checkFavoriteStatus() async {
    try {
      final result = await FavoriteService.checkFavorite(
        favoritedObjectId: widget.listing.id,
        table: 'listing',
      );
      
      if (mounted) {
        setState(() {
          _isFavorited = result['isFavorited'] ?? false;
        });
      }
    } catch (e) {
      // Error checking favorite status
    }
  }

  Future<void> _toggleFavorite() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await FavoriteService.toggleFavorite(
        favoritedObjectId: widget.listing.id,
        table: 'listing',
      );

      if (mounted) {
        setState(() {
          _isFavorited = result['isFavorited'] ?? false;
          _isLoading = false;
        });

        // Show user feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Favorite status updated'),
            duration: const Duration(seconds: 2),
            backgroundColor: result['success'] == true 
                ? Colors.green 
                : Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            duration: const Duration(seconds: 2),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatTimeAgo(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SingleListingPage(listing: widget.listing),
          ),
        );
      },
      child: Container(
        width: 250,
        margin: const EdgeInsets.symmetric(horizontal: 4.0),
        child: Card(
          color: Colors.transparent,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(
              color: Colors.grey.withOpacity(0.2),
              width: 1.0,
            ),
          ),
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
                      widget.listing.imageUrl,
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
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.8),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _isFavorited ? Icons.favorite : Icons.favorite_border,
                                color: _isFavorited ? Colors.red : Colors.black,
                                size: 20,
                              ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 10,
                    right: 10,
                    child: GestureDetector(
                      onTap: () {
                        // Share functionality - prevent navigation
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 69, 100, 201),
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: const Icon(
                          Icons.share,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                      Text(
                        widget.listing.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        widget.listing.price,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.green,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.person, size: 16, color: Colors.grey),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.listing.agentName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          const Icon(Icons.location_on, size: 16, color: Colors.blue),
                          const SizedBox(width: 5),
                          Expanded(
                            child: Text(
                              widget.listing.location,
                              style: const TextStyle(
                                color: Colors.blue,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      // Time ago display below location
                      if (widget.listing.createdAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          _formatTimeAgo(widget.listing.createdAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}