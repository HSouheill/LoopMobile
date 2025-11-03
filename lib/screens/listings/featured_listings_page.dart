// screens/listings/featured_listings_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../services/listing_service.dart';
import '../../widgets/listing_widgets/featured_listings_widget.dart';

class FeaturedListingsPage extends StatefulWidget {
  const FeaturedListingsPage({super.key});

  @override
  State<FeaturedListingsPage> createState() => _FeaturedListingsPageState();
}

class _FeaturedListingsPageState extends State<FeaturedListingsPage> {
  List<PropertyListing> listings = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  int totalListings = 0;
  final int itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadFeaturedListings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _loadFeaturedListings({int page = 1, bool append = false}) async {
    try {
      if (!append) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      final response = await ListingService.getAllListings(
        page: page,
        limit: itemsPerPage,
        isFeatured: true,
        sort: 'date_desc',
      );

      setState(() {
        if (append) {
          listings.addAll(response.listings);
        } else {
          listings = response.listings;
        }
        currentPage = response.meta.page;
        totalPages = response.meta.pages;
        totalListings = response.meta.total;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
        isLoading = false;
      });
    }
  }

  Future<void> _refreshListings() async {
    await _loadFeaturedListings(page: 1);
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _loadNextPage() {
    if (currentPage < totalPages && !isLoading) {
      _loadFeaturedListings(page: currentPage + 1, append: true);
    }
  }

  void _loadPreviousPage() {
    if (currentPage > 1 && !isLoading) {
      _loadFeaturedListings(page: currentPage - 1);
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.featuredListings ?? 'Featured Listings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshListings,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshListings,
        child: Column(
          children: [
            // Header with count
            if (!isLoading && listings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      l10n?.showingFeaturedListings(listings.length, totalListings) ?? 'Showing ${listings.length} of $totalListings featured listings',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Text(
                      l10n?.pageOf(currentPage, totalPages) ?? 'Page $currentPage of $totalPages',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            
            // Content
            Expanded(
              child: _buildContent(),
            ),
            
            // Pagination controls
            if (!isLoading && listings.isNotEmpty && totalPages > 1)
              _buildPaginationControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    final l10n = AppLocalizations.of(context);
    if (isLoading && listings.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null && listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              l10n?.failedToLoadFeaturedListings ?? 'Failed to load featured listings',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _refreshListings,
              child: Text(l10n?.retry ?? 'Retry'),
            ),
          ],
        ),
      );
    }

    if (listings.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.home_outlined, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              l10n?.noFeaturedListingsFound ?? 'No featured listings found',
              style: const TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(12),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.58, // Lower ratio = taller cards to fit content
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: listings.length + (isLoading ? 2 : 0), // Add loading placeholders
      itemBuilder: (context, index) {
        if (index >= listings.length) {
          // Show loading placeholder
          return _buildLoadingCard();
        }
        
        final listing = listings[index];
        return PropertyListingCard(listing: listing);
      },
    );
  }

  Widget _buildLoadingCard() {
    return Card(
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Previous button
          ElevatedButton.icon(
            onPressed: currentPage > 1 ? _loadPreviousPage : null,
            icon: const Icon(Icons.chevron_left),
            label: Text(AppLocalizations.of(context)?.previous ?? 'Previous'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage > 1 ? null : Colors.grey[300],
            ),
          ),
          
          // Page indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey[300]!),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              AppLocalizations.of(context)?.pageCurrentOfTotal(currentPage, totalPages) ?? '$currentPage / $totalPages',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          
          // Next button
          ElevatedButton.icon(
            onPressed: currentPage < totalPages ? _loadNextPage : null,
            icon: const Icon(Icons.chevron_right),
            label: Text(AppLocalizations.of(context)?.next ?? 'Next'),
            style: ElevatedButton.styleFrom(
              backgroundColor: currentPage < totalPages ? null : Colors.grey[300],
            ),
          ),
        ],
      ),
    );
  }
}