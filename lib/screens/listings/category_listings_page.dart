import 'package:flutter/material.dart';
import '/services/listing_service.dart';
import './dynamic_listings_widget.dart'; // for PropertyListingCard & ListingCategory types

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
          sort: 'date_desc',
        );
      } else if (widget.category == ListingCategory.newListings) {
        resp = await ListingService.getAllListings(
          page: pageToFetch,
          limit: limit,
          sort: 'date_desc',
        );
      } else {
        // types (apartment / chalet / commercial)
        resp = await ListingService.getAllListings(
          page: pageToFetch,
          limit: limit,
          type: widget.category.apiType,
          sort: 'date_desc',
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

  @override
  Widget build(BuildContext context) {
    final title = widget.category.displayName;
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: isLoading && listings.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: Column(
                children: [
                  if (error != null)
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        'Failed to load $title: $error',
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  Expanded(
                    child: listings.isEmpty
                        ? ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            children: const [
                              SizedBox(height: 80),
                              Center(child: Text('No listings found')),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.all(12),
                            itemCount: listings.length,
                            itemBuilder: (context, index) {
                              final listing = listings[index];
                              // Reuse the same listing card from dynamic_listings_widget.dart
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12.0),
                                child: SizedBox(
                                  height: 140,
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 3,
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: Image.network(
                                            listing.imageUrl,
                                            height: double.infinity,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder: (context, error, stackTrace) {
                                              return Container(
                                                color: Colors.grey[300],
                                                child: const Center(child: Icon(Icons.broken_image)),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        flex: 5,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              listing.title,
                                              style: Theme.of(context).textTheme.titleMedium,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(listing.price, style: const TextStyle(fontWeight: FontWeight.bold)),
                                            const SizedBox(height: 8),
                                            Row(
                                              children: [
                                                const Icon(Icons.location_on, size: 14, color: Colors.blue),
                                                const SizedBox(width: 6),
                                                Expanded(
                                                  child: Text(
                                                    listing.location,
                                                    maxLines: 1,
                                                    overflow: TextOverflow.ellipsis,
                                                    style: const TextStyle(color: Colors.blue),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              );
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
                          child: const Text('Previous'),
                        ),
                        Text('Page ${meta?.page ?? page} of ${meta?.pages ?? '?'}'),
                        ElevatedButton(
                          onPressed: (meta == null || (meta!.pages != 0 && page >= meta!.pages)) ? null : () => _goToPage(page + 1),
                          child: const Text('Next'),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
