// lib/screens/inactive_listings/widgets/inactive_listing_card_list.dart
import 'package:flutter/material.dart';

class InactiveListingCardList extends StatelessWidget {
  final List<Map<String, dynamic>> items;
  final Axis scrollDirection; // new: allows vertical or horizontal

  const InactiveListingCardList({
    super.key,
    required this.items,
    this.scrollDirection = Axis.horizontal, // default horizontal
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
                  onActivate: () {
                    print("${item['description']} Activated!");
                  },
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
                  onActivate: () {
                    print("${item['description']} Activated!");
                  },
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
  final VoidCallback? onActivate; // Optional action button

  const InactiveListingCard({
    super.key,
    required this.daysLeft,
    required this.backgroundImage,
    required this.description,
    required this.price,
    required this.layoutType,
    this.location,
    this.owner,
    this.onActivate,
  });

  @override
  Widget build(BuildContext context) {
    if (layoutType == 'B') {
      // 👉 Option B layout (Detailed)
      return Center(
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
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: Image.network(
                  backgroundImage,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stack) =>
                      Container(height: 180, color: Colors.grey[300]),
                ),
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
                              "$price / Month",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),

                        // Owner Row
                        if (owner != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.person,
                                  size: 14, color: Color(0xFF0ACC00)),
                              const SizedBox(width: 4),
                              Text(
                                owner!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0048FF),
                                    fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),

                        // Location Row
                        if (location != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: Color(0xFF858585)),
                              const SizedBox(width: 4),
                              Text(
                                location!,
                                style: const TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF0048FF),
                                    fontWeight: FontWeight.w400),
                              ),
                            ],
                          ),
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
                        child: const Text(
                          'Activate Listing',
                          style: TextStyle(
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
      );
    }

    // 👉 Option A layout (Compact)
    return SizedBox(
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
                image: DecorationImage(
                  image: NetworkImage(backgroundImage),
                  fit: BoxFit.cover,
                  colorFilter: ColorFilter.mode(
                    Colors.black.withOpacity(0.1),
                    BlendMode.darken,
                  ),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 2,
                    blurRadius: 7,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.topLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 3.0, left: 52.5),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 15,
                          vertical: 3.5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: const Color.fromRGBO(0, 72, 255, 0.34),
                            width: 0.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 1,
                              blurRadius: 3,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          "$daysLeft Days Left", // 👈 formatted here
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w400,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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
              "\$$price / Month", // 👈 formatted here
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
                child: const Text(
                  'Activate Listing',
                  style: TextStyle(
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
    );
  }
}
