// lib/screens/inactive_listings/widgets/inactive_listing_card_list.dart
import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../../widgets/listing_image_widget.dart';

class InactiveListingCardList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Axis scrollDirection; // new: allows vertical or horizontal
  final Function(String)? onItemTap; // new: callback for item taps

  const InactiveListingCardList({
    super.key,
    required this.items,
    this.scrollDirection = Axis.horizontal, // default horizontal
    this.onItemTap,
  });

  @override
  Widget build(BuildContext context) {
    // Use Column if vertical, Row if horizontal
    final isVertical = scrollDirection == Axis.vertical;

    return SingleChildScrollView(
      scrollDirection: scrollDirection,
      child: isVertical
          ? Column(
              children: items.map((item) {
                return InactiveListingCard(
                  daysLeft: item['daysLeft'] ?? '',
                  backgroundImage: item['backgroundImage'] ?? '',
                  description: item['description'] ?? '',
                  price: item['price'] ?? '',
                  layoutType: item['layoutType'] ?? 'A',
                  location: item['location'],
                  owner: item['owner'],
                  type: item['type'],
                  bedrooms: item['bedrooms'],
                  bathrooms: item['bathrooms'],
                  size: item['size'],
                  condition: item['condition'],
                  buildingAge: item['buildingAge'],
                  papers: item['papers'],
                  listingFor: item['listingFor'],
                  currency: item['currency'],
                  status: item['status'],
                  viewsCount: item['viewsCount'],
                  favoritesCount: item['favoritesCount'],
                  onActivate: () {
                    // Listing activated
                  },
                  onTap: onItemTap != null ? () => onItemTap!(item['description'] ?? '') : null,
                );
              }).toList(),
            )
          : Row(
              children: items.map((item) {
                return InactiveListingCard(
                  daysLeft: item['daysLeft'] ?? '',
                  backgroundImage: item['backgroundImage'] ?? '',
                  description: item['description'] ?? '',
                  price: item['price'] ?? '',
                  layoutType: item['layoutType'] ?? 'A',
                  location: item['location'],
                  owner: item['owner'],
                  type: item['type'],
                  bedrooms: item['bedrooms'],
                  bathrooms: item['bathrooms'],
                  size: item['size'],
                  condition: item['condition'],
                  buildingAge: item['buildingAge'],
                  papers: item['papers'],
                  listingFor: item['listingFor'],
                  currency: item['currency'],
                  status: item['status'],
                  viewsCount: item['viewsCount'],
                  favoritesCount: item['favoritesCount'],
                  onActivate: () {
                    // Listing activated
                  },
                  onTap: onItemTap != null ? () => onItemTap!(item['description'] ?? '') : null,
                );
              }).toList(),
            ),
    );
  }
}

class InactiveListingCard extends StatelessWidget {
  final String daysLeft;
  final String backgroundImage;
  final String description;
  final String price;
  final String layoutType; // "A" or "B"
  final String? location; // Optional for layout B
  final String? owner; // Optional for layout B
  final String? type;
  final String? bedrooms;
  final String? bathrooms;
  final String? size;
  final String? condition;
  final String? buildingAge;
  final String? papers;
  final String? listingFor;
  final String? currency;
  final String? status;
  final String? viewsCount;
  final String? favoritesCount;
  final VoidCallback? onActivate; // Optional action button
  final VoidCallback? onTap; // Optional card tap callback

  const InactiveListingCard({
    super.key,
    required this.daysLeft,
    required this.backgroundImage,
    required this.description,
    required this.price,
    required this.layoutType,
    this.location,
    this.owner,
    this.type,
    this.bedrooms,
    this.bathrooms,
    this.size,
    this.condition,
    this.buildingAge,
    this.papers,
    this.listingFor,
    this.currency,
    this.status,
    this.viewsCount,
    this.favoritesCount,
    this.onActivate,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    if (layoutType == 'B') {
      // 👉 Option B layout (Detailed)
      return Center(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
          width: MediaQuery.of(context).size.width * 0.90,
          margin:
              const EdgeInsets.symmetric(vertical: 8), // only vertical spacing
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 7,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          padding: const EdgeInsets.all(12), // padding for inner content
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image with rounded corners
              ListingImageWidget(
                imageUrl: backgroundImage,
                height: 180,
                width: double.infinity,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(6),
                placeholderIcon: Icons.home,
                placeholderIconSize: 50,
                placeholderColor: Colors.grey[400] ?? Colors.grey,
              ),
              const SizedBox(height: 2),

              // Row with two columns
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Left column: description, price, owner, location
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Description aligned with price and icons
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 3), // adjust to match icon width + spacing
                          child: Text(
                            description,
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w400),
                          ),
                        ),
                        const SizedBox(height: 2),

                        // Price Row
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            const Icon(Icons.attach_money,
                                size: 16, color: Color(0xFF1E1E1E)),
                            const SizedBox(width: 2),
                            Text(
                              "$price ${AppLocalizations.of(context)?.perMonth ?? '/ Month'}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                      ],
                    ),
                  ),

                  // Right column: vertically centered button
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      OutlinedButton(
                        onPressed: onActivate,
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 6),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          side: const BorderSide(
                            color: Color(0xFF0048FF),
                            width: 1,
                          ),
                        ),
                        child: Text(
                          AppLocalizations.of(context)?.activateListing ?? 'Activate Listing',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Color(0xFF1E1E1E),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        ),
      );
    }

    // 👉 Option A layout (Compact)
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.6,
        child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 9.0, vertical: 10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image + Days Left badge
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Stack(
                  children: [
                    ListingImageWidget(
                      imageUrl: backgroundImage,
                      height: 160,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      placeholderIcon: Icons.home,
                      placeholderIconSize: 40,
                      placeholderColor: Colors.grey[500] ?? Colors.grey,
                    ),
                    // Dark overlay
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 5),

            // Description
            Text(
              description,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Color(0xFF1E1E1E),
              ),
            ),

            // Price
            Text(
              "\$$price ${AppLocalizations.of(context)?.perMonth ?? '/ Month'}", // 👈 formatted here
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1E1E1E),
              ),
            ),

            const SizedBox(height: 7),

            // Activate Button
            Center(
              child: OutlinedButton(
                onPressed: onActivate,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(50.0),
                  ),
                  side: const BorderSide(
                    color: Color(0xFF0048FF),
                    width: 1,
                  ),
                ),
                child: Text(
                  AppLocalizations.of(context)?.activateListing ?? 'Activate Listing',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }
}
