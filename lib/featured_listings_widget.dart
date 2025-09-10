// featured_listings_widget.dart

import 'package:flutter/material.dart';

class PropertyListing {
  final String imageUrl;
  final String title;
  final String price;
  final String agentName;
  final String location;
  final bool isFeatured;

  PropertyListing({
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.agentName,
    required this.location,
    this.isFeatured = false,
  });
}

class FeaturedListingsWidget extends StatelessWidget {
  final List<PropertyListing> listings;
  final String title;

  const FeaturedListingsWidget({
    super.key,
    required this.listings,
    required this.title,
  });

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
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              TextButton(
                onPressed: () {
                  // Handle "See all" tap
                },
                child: const Text('See all'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 330, // Slightly taller to avoid overflow on smaller screens/text scales
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: listings.length,
            itemBuilder: (context, index) {
              final listing = listings[index];
              return _buildListingCard(context, listing);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildListingCard(BuildContext context, PropertyListing listing) {
    return Container(
      width: 250, // Card width
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Card(
        color: Colors.transparent, // Make background transparent
        elevation: 0, // Remove shadow
        shape: null, // Remove border
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
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
                    loadingBuilder: (BuildContext context, Widget child,
                        ImageChunkEvent? loadingProgress) {
                      if (loadingProgress == null) {
                        return child;
                      }
                      return SizedBox(
                        height: 150,
                        child: Center(
                          child: CircularProgressIndicator(
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return const SizedBox(
                        height: 150,
                        child: Center(
                          child: Icon(Icons.error, color: Colors.red),
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
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade600,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: const Icon(
                      Icons.share,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
            ),
          ],
        ),
      ),
    );
  }
}