import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.errorLoadingListings(e.toString()) ?? 'Error loading listings: $e')),
      );
    }
  }

  Future<void> _refresh() async {
    await _loadListings(refresh: true);
  }

  void _showListingDetails(PropertyListing listing) {
    showListingDetailsModal(context, listing);
  }

  Future<void> _deleteListing(PropertyListing listing) async {
    final l10n = AppLocalizations.of(context);
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n?.deleteListing ?? 'Delete Listing'),
        content: Text(l10n?.deleteListingConfirm(listing.title) ?? 'Are you sure you want to delete "${listing.title}"? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n?.cancel ?? 'Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text(l10n?.delete ?? 'Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(),
        ),
      );

      try {
        final success = await ListingService.deleteListing(listing.id);
        Navigator.of(context).pop(); // Close loading dialog

        final l10n = AppLocalizations.of(context);
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.listingDeletedSuccessfully ?? 'Listing deleted successfully')),
          );
          // Refresh the listings
          await _refresh();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.failedToDeleteListing ?? 'Failed to delete listing')),
          );
        }
      } catch (e) {
        Navigator.of(context).pop(); // Close loading dialog
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.errorDeletingListing(e.toString()) ?? 'Error deleting listing: $e')),
        );
      }
    }
  }

  void _editListing(PropertyListing listing) {
    // Navigate to edit listing page with the listing data
    Navigator.pushNamed(
      context,
      '/add-listing-form',
      arguments: {
        'editMode': true,
        'listing': listing,
      },
    );
  }



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.myListings ?? 'My Listings'),
        backgroundColor: const Color(0xFF0048FF),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: isLoading && listings.isEmpty
            ? const Center(child: CircularProgressIndicator())
            : listings.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.inbox, size: 64, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          l10n?.noActiveListings ?? 'No active listings found',
                          style: const TextStyle(fontSize: 18, color: Colors.grey),
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
                              SnackBar(content: Text(l10n?.soldFunctionalityNotImplemented ?? 'Sold functionality not implemented yet')),
                            );
                          },
                          onDelete: () => _deleteListing(listing),
                          onBoost: () {
                            // TODO: Implement boost functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n?.boostFunctionalityNotImplemented ?? 'Boost functionality not implemented yet')),
                            );
                          },
                          onEdit: () => _editListing(listing),
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
                                  buttonText: AppLocalizations.of(context)?.cancel ?? 'Cancel',
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
                                  buttonText: AppLocalizations.of(context)?.promoteButton ?? 'Promote',
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
                                    buttonText: AppLocalizations.of(context)?.soldButton ?? 'Sold',
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
                                    buttonText: AppLocalizations.of(context)?.delete ?? 'Delete',
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
                                    buttonText: AppLocalizations.of(context)?.boostButton ?? 'Boost',
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
                                    buttonText: AppLocalizations.of(context)?.editButton ?? 'Edit',
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
