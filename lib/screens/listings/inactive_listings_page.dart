import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/listing_service.dart';
import '../dashboards/widgets/inactive_listing_card_list.dart';
import '../../widgets/listing_details_modal.dart';

class InactiveListingsPage extends StatefulWidget {
  const InactiveListingsPage({super.key});

  @override
  State<InactiveListingsPage> createState() => _InactiveListingsPageState();
}

class _InactiveListingsPageState extends State<InactiveListingsPage> {
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
        status: 'pending',
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



  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.inactiveListings ?? 'Inactive Listings'),
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
                          l10n?.noInactiveListings ?? 'No inactive listings found',
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
                        child: InactiveListingCard(
                          daysLeft: _calculateDaysLeft(listing.createdAt),
                          backgroundImage: listing.imageUrl,
                          description: listing.title,
                          price: _extractPrice(listing.price),
                          layoutType: 'B',
                          location: listing.location,
                          owner: listing.agentName,
                          onActivate: () {
                            // TODO: Implement activate functionality
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n?.activateFunctionalityNotImplemented ?? 'Activate functionality not implemented yet')),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  String _calculateDaysLeft(DateTime? createdAt) {
    if (createdAt == null) return '0';
    final now = DateTime.now();
    final difference = now.difference(createdAt).inDays;
    return difference.toString();
  }

  String _extractPrice(String price) {
    // Extract numeric value from price string like "$1,200/Month"
    final regex = RegExp(r'[\d,]+');
    final match = regex.firstMatch(price);
    return match?.group(0)?.replaceAll(',', '') ?? '0';
  }
}
