import 'package:flutter/material.dart';
import '/services/listing_service.dart';
import '/services/listing_service.dart' show ListingCategory; // import enum from service
import '../../widgets/featured_listings_widget.dart' as flw; // reuse shared card UI

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
                        : GridView.builder(
                            padding: const EdgeInsets.all(16),
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
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
