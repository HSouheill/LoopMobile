import 'package:flutter/material.dart';
import '../../services/listing_service.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
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

  List<String> _getSelectedFilterLabels() {
    final List<String> labels = [];
    final l10n = AppLocalizations.of(context);

    // Listing For
    if (_currentFilters['listingFor'] != null && _currentFilters['listingFor'] != 'rent') {
      labels.add(_currentFilters['listingFor'] == 'sale' ? 'Sale' : _currentFilters['listingFor'].toString());
    }

    // Property Type
    if (_currentFilters['type'] != null) {
      final type = _currentFilters['type'].toString();
      String typeLabel = type;
      switch (type) {
        case 'apartment':
          typeLabel = l10n?.propertyTypeApartment ?? 'Apartment';
          break;
        case 'chalet':
          typeLabel = l10n?.propertyTypeChalet ?? 'Chalet';
          break;
        case 'studio':
          typeLabel = l10n?.propertyTypeStudio ?? 'Studio';
          break;
        case 'commercial':
          typeLabel = l10n?.propertyTypeCommercial ?? 'Commercial';
          break;
        case 'villa':
          typeLabel = l10n?.propertyTypeVilla ?? 'Villa';
          break;
        case 'land':
          typeLabel = l10n?.propertyTypeLand ?? 'Land';
          break;
      }
      labels.add(typeLabel);
    }

    // Payment Frequency
    if (_currentFilters['paymentFrequency'] != null) {
      final freq = _currentFilters['paymentFrequency'].toString();
      labels.add(freq.substring(0, 1).toUpperCase() + freq.substring(1));
    }

    // City
    if (_currentFilters['city'] != null && _currentFilters['city'].toString().isNotEmpty) {
      labels.add(_currentFilters['city'].toString());
    }

    // Ownership
    if (_currentFilters['ownership'] != null && _currentFilters['ownership'].toString().isNotEmpty) {
      final ownership = _currentFilters['ownership'].toString();
      String ownershipLabel = ownership;
      if (ownership == 'user') ownershipLabel = 'Owner';
      else if (ownership == 'agent-individual') ownershipLabel = 'Agent';
      else if (ownership == 'agent-company') ownershipLabel = 'Company';
      labels.add(ownershipLabel);
    }

    // Price Range
    if (_currentFilters['minPrice'] != null || _currentFilters['maxPrice'] != null) {
      final minPrice = _currentFilters['minPrice'];
      final maxPrice = _currentFilters['maxPrice'];
      String priceLabel = '';
      if (minPrice != null && maxPrice != null) {
        final min = minPrice is num ? minPrice.toDouble() : double.tryParse(minPrice.toString()) ?? 0;
        final max = maxPrice is num ? maxPrice.toDouble() : double.tryParse(maxPrice.toString()) ?? 0;
        priceLabel = '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)}';
      } else if (minPrice != null) {
        final min = minPrice is num ? minPrice.toDouble() : double.tryParse(minPrice.toString()) ?? 0;
        priceLabel = 'Min: ${min.toStringAsFixed(0)}';
      } else if (maxPrice != null) {
        final max = maxPrice is num ? maxPrice.toDouble() : double.tryParse(maxPrice.toString()) ?? 0;
        priceLabel = 'Max: ${max.toStringAsFixed(0)}';
      }
      labels.add(priceLabel);
    }

    // Bedrooms
    if (_currentFilters['minBedrooms'] != null || _currentFilters['maxBedrooms'] != null) {
      final bedrooms = _currentFilters['minBedrooms'] ?? _currentFilters['maxBedrooms'];
      final bedroomsInt = bedrooms is int ? bedrooms : (bedrooms is num ? bedrooms.toInt() : int.tryParse(bedrooms.toString()) ?? 0);
      labels.add('$bedroomsInt Bedroom${bedroomsInt > 1 ? 's' : ''}');
    }

    // Bathrooms
    if (_currentFilters['minBathrooms'] != null || _currentFilters['maxBathrooms'] != null) {
      final bathrooms = _currentFilters['minBathrooms'] ?? _currentFilters['maxBathrooms'];
      final bathroomsInt = bathrooms is int ? bathrooms : (bathrooms is num ? bathrooms.toInt() : int.tryParse(bathrooms.toString()) ?? 0);
      labels.add('$bathroomsInt Bathroom${bathroomsInt > 1 ? 's' : ''}');
    }

    // Size Range
    if (_currentFilters['minSize'] != null || _currentFilters['maxSize'] != null) {
      final minSize = _currentFilters['minSize'];
      final maxSize = _currentFilters['maxSize'];
      String sizeLabel = '';
      if (minSize != null && maxSize != null) {
        final min = minSize is num ? minSize.toDouble() : double.tryParse(minSize.toString()) ?? 0;
        final max = maxSize is num ? maxSize.toDouble() : double.tryParse(maxSize.toString()) ?? 0;
        sizeLabel = '${min.toStringAsFixed(0)} - ${max.toStringAsFixed(0)} m²';
      } else if (minSize != null) {
        final min = minSize is num ? minSize.toDouble() : double.tryParse(minSize.toString()) ?? 0;
        sizeLabel = 'Min: ${min.toStringAsFixed(0)} m²';
      } else if (maxSize != null) {
        final max = maxSize is num ? maxSize.toDouble() : double.tryParse(maxSize.toString()) ?? 0;
        sizeLabel = 'Max: ${max.toStringAsFixed(0)} m²';
      }
      labels.add(sizeLabel);
    }

    // Floor
    if (_currentFilters['floor'] != null && _currentFilters['floor'].toString().isNotEmpty) {
      labels.add('Floor: ${_currentFilters['floor']}');
    }

    // Condition
    if (_currentFilters['condition'] != null) {
      final condition = _currentFilters['condition'].toString();
      String conditionLabel = condition;
      switch (condition) {
        case 'under_construction':
          conditionLabel = 'Under Construction';
          break;
        case 'ready':
          conditionLabel = 'Ready';
          break;
        case 'needs_renovation':
          conditionLabel = 'Needs Renovation';
          break;
      }
      labels.add(conditionLabel);
    }

    // Furnishing
    if (_currentFilters['furnishing'] != null && _currentFilters['furnishing'].toString().isNotEmpty) {
      final furnishing = _currentFilters['furnishing'].toString();
      String furnishingLabel = furnishing;
      switch (furnishing) {
        case 'unfurnished':
          furnishingLabel = 'Unfurnished';
          break;
        case 'semi_furnished':
          furnishingLabel = 'Semi-Furnished';
          break;
        case 'fully_furnished':
          furnishingLabel = 'Fully Furnished';
          break;
      }
      labels.add(furnishingLabel);
    }

    // Amenities
    if (_currentFilters['amenities'] != null) {
      final amenities = _currentFilters['amenities'];
      List<String> amenityList = [];
      if (amenities is String) {
        amenityList = amenities.split(',').map((a) => a.trim()).toList();
      } else if (amenities is List) {
        amenityList = amenities.map((a) => a.toString()).toList();
      }
      
      // Map amenity keys to labels
      final amenityLabels = {
        'furnished': 'Furnished',
        'terrace': 'Terrace',
        'privatePool': 'Private Pool',
        'storageRoom': 'Storage Room',
        'sharedPool': 'Shared Pool',
        'sharedGym': 'Shared Gym',
        'security': 'Security',
        'seaView': 'Sea View',
        'garden': 'Garden',
        'mountainView': 'Mountain View',
        'elevator': 'Elevator',
        'parking': 'Parking',
        'centralAC': 'Central AC',
        'heating': 'Heating',
        'solarSystem': 'Solar System',
        'electricity24_7': '24/7 Electricity',
        'maidRoom': 'Maid Room',
        'accessible': 'Accessible',
        'atticLoft': 'Attic/Loft',
        'builtInKitchenAppliances': 'Built-in Kitchen Appliances',
        'builtInWardrobes': 'Built-in Wardrobes',
        'concierge': 'Concierge',
        'coveredParking': 'Covered Parking',
        'fireplace': 'Fireplace',
        'petsAllowed': 'Pets Allowed',
        'playroom': 'Playroom',
        'privateGarden': 'Private Garden',
        'privateGym': 'Private Gym',
        'privateJacuzzi': 'Private Jacuzzi',
        'sharedSpa': 'Shared Spa',
        'studyRoom': 'Study Room',
        'balcony': 'Balcony',
        'walkInCloset': 'Walk-in Closet',
      };
      
      for (var amenity in amenityList) {
        final label = amenityLabels[amenity.toLowerCase()] ?? amenity;
        labels.add(label);
      }
    }

    // Sort
    if (_currentFilters['sort'] != null) {
      final sort = _currentFilters['sort'].toString();
      String sortLabel = '';
      switch (sort) {
        case 'score':
          sortLabel = 'Relevance';
          break;
        case 'date_desc':
          sortLabel = 'Newest First';
          break;
        case 'date_asc':
          sortLabel = 'Oldest First';
          break;
        case 'price_asc':
          sortLabel = 'Price: Low to High';
          break;
        case 'price_desc':
          sortLabel = 'Price: High to Low';
          break;
        default:
          sortLabel = sort;
      }
      labels.add(sortLabel);
    }

    return labels;
  }

  Widget _buildSelectedFiltersChips() {
    final selectedFilters = _getSelectedFilterLabels();
    
    if (selectedFilters.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      height: 50.0,
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          bottom: BorderSide(color: Colors.grey[300]!, width: 1),
        ),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        itemCount: selectedFilters.length,
        itemBuilder: (context, index) {
          return Container(
            margin: const EdgeInsets.only(right: 8.0),
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0),
            decoration: BoxDecoration(
              color: const Color(0xFF3B82F6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20.0),
              border: Border.all(
                color: const Color(0xFF3B82F6).withOpacity(0.3),
                width: 1.0,
              ),
            ),
            child: Center(
              child: Text(
                selectedFilters[index],
                style: const TextStyle(
                  fontSize: 12.0,
                  color: Color(0xFF3B82F6),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          );
        },
      ),
    );
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
            icon: const Icon(
              Icons.tune,
              color: Color.fromARGB(255, 69, 100, 201),
              size: 30,
            ),
            iconSize: 30,
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
          
          // Selected Filters Chips (horizontally scrollable)
          _buildSelectedFiltersChips(),
          
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
