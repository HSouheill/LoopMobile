import 'package:flutter/material.dart';
import '../../services/listing_service.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../../widgets/listing_widgets/listing_card.dart';
import 'advanced_filters_page.dart';

class SearchResultsPage extends StatefulWidget {
  final String? initialQuery;
  final String? initialCategory;
  final Map<String, dynamic>? initialFilters;

  const SearchResultsPage({
    super.key,
    this.initialQuery,
    this.initialCategory,
    this.initialFilters,
  });

  @override
  State<SearchResultsPage> createState() => _SearchResultsPageState();
}

class _SearchResultsPageState extends State<SearchResultsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<PropertyListing> _listings = [];
  bool _isLoading = false;
  String _currentQuery = '';
  String? _currentCategory;
  Map<String, dynamic> _currentFilters = {};
  int _currentPage = 1;
  bool _hasMoreData = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _currentQuery = widget.initialQuery ?? '';
    _currentCategory = widget.initialCategory;
    _currentFilters = widget.initialFilters ?? {};
    _searchController.text = _currentQuery;
    _scrollController.addListener(_onScroll);
    _performSearch();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoading &&
        _hasMoreData) {
      _loadMoreResults();
    }
  }

  Future<void> _performSearch({bool resetPage = true}) async {
    if (resetPage) {
      _currentPage = 1;
      _listings.clear();
    }

    setState(() {
      _isLoading = true;
    });


    try {
      ListingsResponse response;
      
      // If we have a category but no query, use getAllListings with type filter
      if (_currentCategory != null && _currentQuery.isEmpty) {
        response = await ListingService.getAllListings(
          page: _currentPage,
          limit: 20,
          type: _currentCategory,
          sort: 'date_desc',
        );
      } else {
        response = await ListingService.searchListings(
          query: _currentQuery,
          category: _currentCategory,
          page: _currentPage,
          filters: _currentFilters,
        );
      }

      setState(() {
        if (resetPage) {
          _listings = response.listings;
        } else {
          _listings.addAll(response.listings);
        }
        _hasMoreData = _currentPage < response.meta.pages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n?.errorLoadingListings(e.toString()) ?? 'Error searching: $e')),
        );
      }
    }
  }

  Future<void> _loadMoreResults() async {
    if (_isLoading || !_hasMoreData) return;
    
    _currentPage++;
    await _performSearch(resetPage: false);
  }

  void _onSearchSubmitted() {
    _currentQuery = _searchController.text.trim();
    _performSearch();
  }

  void _openAdvancedFilters() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedFiltersPage(
          initialQuery: _currentQuery,
          initialFilters: _currentFilters,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _currentQuery = result['query'] ?? '';
        _currentFilters = result['filters'] ?? {};
        _searchController.text = _currentQuery;
      });
      _performSearch();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.listings ?? 'Search Results'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _openAdvancedFilters,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _onSearchSubmitted(),
                    decoration: InputDecoration(
                      hintText: l10n?.search ?? 'Search properties...',
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),
                ElevatedButton(
                  onPressed: _onSearchSubmitted,
                  child: Text(l10n?.search ?? 'Search'),
                ),
              ],
            ),
          ),
          
          // Results
          Expanded(
            child: _isLoading && _listings.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : _listings.isEmpty
                    ? Center(
                        child: Text(
                          l10n?.noListingsFound ?? 'No results found',
                          style: const TextStyle(fontSize: 16.0),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _performSearch(),
                        child: ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          itemCount: _listings.length + (_isLoading ? 1 : 0),
                          itemBuilder: (context, index) {
                            if (index == _listings.length) {
                              return const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                            
                            final listing = _listings[index];
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: ListingCard(listing: listing),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
