import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
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
  bool isLoadingMore = false;
  bool hasMore = true;
  int currentPage = 1;
  final int limit = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadListings();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  // Load the next page when nearing the bottom.
  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 300 &&
        hasMore &&
        !isLoadingMore &&
        !isLoading) {
      _loadListings();
    }
  }

  Future<void> _loadListings({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        currentPage = 1;
        listings.clear();
        hasMore = true;
      });
    }

    if ((!hasMore && !refresh) || isLoadingMore) return;
    if (!refresh) setState(() => isLoadingMore = true);

    try {
      final response = await ListingService.getMyListings(
        status: 'not-active',
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
        isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
        isLoadingMore = false;
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

  // Unarchive (re-activate) an archived listing. Backend returns 403 if it would
  // exceed the plan limit — we surface that message.
  Future<void> _unarchive(PropertyListing listing) async {
    final result = await ListingService.unarchiveListing(listing.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result.message)),
    );
    if (result.success) {
      await _refresh();
    }
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
                    controller: _scrollController,
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
                          status: listing.status,
                          onActivate: () => _unarchive(listing),
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
