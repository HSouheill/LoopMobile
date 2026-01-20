import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '/services/listing_service.dart' hide ListingCategory;
import 'listings_category.dart'; // import enum with localization support
import '../../widgets/listing_widgets/featured_listings_widget.dart' as flw; // reuse shared card UI

class CategoryListingsPage extends StatefulWidget {
  final ListingCategory category;

  const CategoryListingsPage({super.key, required this.category});

  @override
  State<CategoryListingsPage> createState() => _CategoryListingsPageState();
}

class _CategoryListingsPageState extends State<CategoryListingsPage> {
  int page = 1;
  final int limit = 10;
  bool isLoading = false;
  String? error;
  List<PropertyListing> listings = [];
  ListingMeta? meta;
  String selectedSort = 'featured_first'; // Default: featured first

  @override
  void initState() {
    super.initState();
    _fetchPage();
  }

  Future<void> _fetchPage({int pageToFetch = 1}) async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      ListingsResponse resp;

      if (widget.category == ListingCategory.featured) {
        // featured: use isFeatured param
        resp = await ListingService.getAllListings(
          page: pageToFetch,
          limit: limit,
          isFeatured: true,
          sort: selectedSort,
        );
      } else if (widget.category == ListingCategory.newListings) {
        resp = await ListingService.getAllListings(
          page: pageToFetch,
          limit: limit,
          sort: selectedSort,
        );
      } else {
        // types (apartment / chalet / commercial)
        resp = await ListingService.getAllListings(
          page: pageToFetch,
          limit: limit,
          type: widget.category.apiType,
          sort: selectedSort,
        );
      }

      if (!mounted) return;
      setState(() {
        listings = resp.listings;
        meta = resp.meta;
        page = resp.meta.page;
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

  void _goToPage(int newPage) {
    if (newPage < 1) return;
    if (meta != null && newPage > meta!.pages) return;
    _fetchPage(pageToFetch: newPage);
  }

  Future<void> _onRefresh() async {
    await _fetchPage(pageToFetch: 1);
  }

  String _getSortLabel(String sort, AppLocalizations? l10n) {
    switch (sort) {
      case 'featured_first':
        return 'Featured';
      case 'date_desc':
        return l10n?.newestFirst ?? 'Newest';
      case 'date_asc':
        return l10n?.oldestFirst ?? 'Oldest';
      case 'price_asc':
        return 'Price ↑';
      case 'price_desc':
        return 'Price ↓';
      default:
        return 'Featured';
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = widget.category.getLocalizedDisplayName(l10n);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Column(
        children: [
          // Compact sorting button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                PopupMenuButton<String>(
                  icon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.sort,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _getSortLabel(selectedSort, l10n),
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(width: 2),
                      Icon(
                        Icons.arrow_drop_down,
                        size: 18,
                        color: Colors.grey[700],
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    PopupMenuItem<String>(
                      value: 'date_desc',
                      child: Row(
                        children: [
                          if (selectedSort == 'date_desc')
                            const Icon(Icons.check, size: 18, color: Colors.blue)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(l10n?.newestFirst ?? 'Newest First'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'date_asc',
                      child: Row(
                        children: [
                          if (selectedSort == 'date_asc')
                            const Icon(Icons.check, size: 18, color: Colors.blue)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(l10n?.oldestFirst ?? 'Oldest First'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'price_asc',
                      child: Row(
                        children: [
                          if (selectedSort == 'price_asc')
                            const Icon(Icons.check, size: 18, color: Colors.blue)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(l10n?.priceLowToHigh ?? 'Price: Low to High'),
                        ],
                      ),
                    ),
                    PopupMenuItem<String>(
                      value: 'price_desc',
                      child: Row(
                        children: [
                          if (selectedSort == 'price_desc')
                            const Icon(Icons.check, size: 18, color: Colors.blue)
                          else
                            const SizedBox(width: 18),
                          const SizedBox(width: 8),
                          Text(l10n?.priceHighToLow ?? 'Price: High to Low'),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (String value) {
                    if (value != selectedSort) {
                      setState(() {
                        selectedSort = value;
                      });
                      // Reset to page 1 and fetch with new sort
                      _fetchPage(pageToFetch: 1);
                    }
                  },
                ),
              ],
            ),
          ),
          // Main content
          Expanded(
            child: isLoading && listings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        l10n?.failedToLoadListingsCategory(title, error ?? '') ?? 'Failed to load $title: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: listings.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: [
                              const SizedBox(height: 80),
                              Center(child: Text(l10n?.noListingsFound ?? 'No listings found')),
                            ],
                          )
                        : GridView.builder(
                            padding: const EdgeInsets.all(12),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.58, // Lower ratio = taller cards to fit content
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 12,
                            ),
                            itemCount: listings.length,
                            itemBuilder: (context, index) {
                              final listing = listings[index];
                              return flw.PropertyListingCard(listing: listing);
                            },
                          ),
                  ),
                  // Pagination controls
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton(
                          onPressed: (meta == null || page <= 1) ? null : () => _goToPage(page - 1),
                          child: Text(l10n?.previous ?? 'Previous'),
                        ),
                        Text(l10n?.pageOf(meta?.page ?? page, meta?.pages ?? 0) ?? 'Page ${meta?.page ?? page} of ${meta?.pages ?? '?'}'),
                        ElevatedButton(
                          onPressed: (meta == null || (meta!.pages != 0 && page >= meta!.pages)) ? null : () => _goToPage(page + 1),
                          child: Text(l10n?.next ?? 'Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
