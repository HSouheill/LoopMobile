import 'package:flutter/material.dart';
import '../../services/listing_service.dart';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../widgets/listing_image_widget.dart';
import '../../widgets/listing_details_modal.dart';

class MyListingsPage extends StatefulWidget {
  const MyListingsPage({super.key});

  @override
  State<MyListingsPage> createState() => _MyListingsPageState();
}

class _MyListingsPageState extends State<MyListingsPage> {
  List<PropertyListing> listings = [];
  bool isLoading = true;
  bool hasMore = true;
  int currentPage = 1;
  final int limit = 10;

  @override
  void initState() {
    super.initState();
    _loadListings();
  }

  Future<void> _loadListings({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        listings.clear();
        hasMore = true;
      });
    }

    if (!hasMore && !refresh) return;

    try {
      final response = await ListingService.getMyListings(
        status: 'active',
        page: currentPage,
        limit: limit,
      );

      setState(() {
        if (refresh) {
          listings = response.listings;
        } else {
          listings.addAll(response.listings);
        }
        hasMore = currentPage < response.meta.pages;
        currentPage++;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading listings: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    await _loadListings(refresh: true);
  }

  void _showListingDetails(PropertyListing listing) {
    showListingDetailsModal(context, listing);
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
        backgroundColor: const Color(0xFF0048FF),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading && listings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : listings.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.inbox, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No active listings found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: listings.length + (hasMore ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (index == listings.length) {
                        return const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        );
                      }

                      final listing = listings[index];
                      return GestureDetector(
                        onTap: () => _showListingDetails(listing),
                        child: MyListingCard(
                          listing: listing,
                          onSold: () {
                            // TODO: Implement sold functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Sold functionality not implemented yet')),
                            );
                          },
                          onDelete: () {
                            // TODO: Implement delete functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Delete functionality not implemented yet')),
                            );
                          },
                          onBoost: () {
                            // TODO: Implement boost functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Boost functionality not implemented yet')),
                            );
                          },
                          onEdit: () {
                            // TODO: Navigate to edit page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Edit functionality not implemented yet')),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

class MyListingCard extends StatefulWidget {
  final PropertyListing listing;
  final VoidCallback onSold;
  final VoidCallback onDelete;
  final VoidCallback onBoost;
  final VoidCallback onEdit;

  const MyListingCard({
    super.key,
    required this.listing,
    required this.onSold,
    required this.onDelete,
    required this.onBoost,
    required this.onEdit,
  });

  @override
  State<MyListingCard> createState() => _MyListingCardState();
}

class _MyListingCardState extends State<MyListingCard> {
  bool boostPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
      child: Column(
        children: [
          // First row: title only (removed views/saves)
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  widget.listing.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row: image + buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left
              ListingImageWidget(
                imageUrl: widget.listing.imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                borderRadius: BorderRadius.circular(8),
                placeholderIcon: Icons.home,
                placeholderIconSize: 30,
              ),
              const SizedBox(width: 12),

              // Buttons
              Expanded(
                child: boostPressed
                    ? Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: DynamicGradientButton(
                                buttonText: 'Cancel',
                                onTap: () {
                                  setState(() {
                                    boostPressed = false;
                                  });
                                },
                                padding: const EdgeInsets.symmetric(vertical: 6),
                                useGradient: false,
                                backgroundColor: const Color(0xFFF9FBFF),
                                borderColor: const Color(0xFFEA4435),
                                borderWidth: 1.0,
                                textColor: const Color(0xFFEA4435),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: DynamicGradientButton(
                                buttonText: 'Promote',
                                onTap: widget.onBoost,
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Sold',
                                    onTap: widget.onSold,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    useGradient: false,
                                    backgroundColor: const Color(0xFFF9FBFF),
                                    borderColor: const Color(0xFF0048FF),
                                    borderWidth: 1.0,
                                    textColor: const Color(0xFF1E1E1E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Delete',
                                    onTap: widget.onDelete,
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    useGradient: false,
                                    backgroundColor: const Color(0xFFF9FBFF),
                                    borderColor: const Color(0xFFEA4435),
                                    borderWidth: 1.0,
                                    textColor: const Color(0xFFEA4435),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Boost',
                                    onTap: () {
                                      setState(() {
                                        boostPressed = true;
                                      });
                                    },
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Edit',
                                    onTap: widget.onEdit,
                                    padding: const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
