import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/agent_service.dart';
import '../../services/listing_service.dart';
import '../../widgets/listing_widgets/featured_listings_widget.dart';

class AgentListingsPage extends StatefulWidget {
  final String agentId;
  final String agentName;

  const AgentListingsPage({
    super.key,
    required this.agentId,
    required this.agentName,
  });

  @override
  State<AgentListingsPage> createState() => _AgentListingsPageState();
}

class _AgentListingsPageState extends State<AgentListingsPage> {
  List<PropertyListing> listings = [];
  bool isLoading = true;
  String? error;
  int currentPage = 1;
  int totalPages = 1;
  int totalListings = 0;
  final int itemsPerPage = 10;
  final ScrollController _scrollController = ScrollController();
  
  // Filter state
  bool _showFilters = false;
  String? _selectedListingFor;
  String? _selectedCity;
  String? _selectedType;
  String? _selectedSort = 'date_desc';
  final TextEditingController _minPriceController = TextEditingController();
  final TextEditingController _maxPriceController = TextEditingController();
  final TextEditingController _minBedroomsController = TextEditingController();
  final TextEditingController _maxBedroomsController = TextEditingController();
  final TextEditingController _minBathroomsController = TextEditingController();
  final TextEditingController _maxBathroomsController = TextEditingController();
  final TextEditingController _minSizeController = TextEditingController();
  final TextEditingController _maxSizeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadAgentListings();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _minPriceController.dispose();
    _maxPriceController.dispose();
    _minBedroomsController.dispose();
    _maxBedroomsController.dispose();
    _minBathroomsController.dispose();
    _maxBathroomsController.dispose();
    _minSizeController.dispose();
    _maxSizeController.dispose();
    super.dispose();
  }

  Future<void> _loadAgentListings({int page = 1, bool append = false}) async {
    try {
      if (!append) {
        setState(() {
          isLoading = true;
          error = null;
        });
      }

      // Parse filter values
      double? minPrice = _minPriceController.text.isNotEmpty 
          ? double.tryParse(_minPriceController.text) : null;
      double? maxPrice = _maxPriceController.text.isNotEmpty 
          ? double.tryParse(_maxPriceController.text) : null;
      int? minBedrooms = _minBedroomsController.text.isNotEmpty 
          ? int.tryParse(_minBedroomsController.text) : null;
      int? maxBedrooms = _maxBedroomsController.text.isNotEmpty 
          ? int.tryParse(_maxBedroomsController.text) : null;
      int? minBathrooms = _minBathroomsController.text.isNotEmpty 
          ? int.tryParse(_minBathroomsController.text) : null;
      int? maxBathrooms = _maxBathroomsController.text.isNotEmpty 
          ? int.tryParse(_maxBathroomsController.text) : null;
      double? minSize = _minSizeController.text.isNotEmpty 
          ? double.tryParse(_minSizeController.text) : null;
      double? maxSize = _maxSizeController.text.isNotEmpty 
          ? double.tryParse(_maxSizeController.text) : null;

      final response = await AgentService.getAgentListings(
        agentId: widget.agentId,
        page: page,
        limit: itemsPerPage,
        sort: _selectedSort,
        listingFor: _selectedListingFor,
        city: _selectedCity,
        type: _selectedType,
        minPrice: minPrice,
        maxPrice: maxPrice,
        minBedrooms: minBedrooms,
        maxBedrooms: maxBedrooms,
        minBathrooms: minBathrooms,
        maxBathrooms: maxBathrooms,
        minSize: minSize,
        maxSize: maxSize,
      );

      // Parse the response
      final listingsData = response['listings'] as List<dynamic>;
      final meta = response['meta'] as Map<String, dynamic>;
      
      final listingsList = listingsData
          .map((json) => PropertyListing.fromJson(json))
          .toList();

      setState(() {
        if (append) {
          listings.addAll(listingsList);
        } else {
          listings = listingsList;
        }
        currentPage = meta['page'] as int;
        totalPages = meta['pages'] as int;
        totalListings = meta['total'] as int;
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
    await _loadAgentListings(page: 1);
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
      _loadAgentListings(page: currentPage + 1, append: true);
    }
  }

  void _loadPreviousPage() {
    if (currentPage > 1 && !isLoading) {
      _loadAgentListings(page: currentPage - 1);
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
        title: Text(l10n?.agentListingsTitle(widget.agentName) ?? '${widget.agentName}\'s Listings'),
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
            // Filter section
            _buildFilterSection(l10n),
            
            // Header with count and sort
            if (!isLoading && listings.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Showing ${listings.length} of $totalListings listings',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    Row(
                      children: [
                        _buildSortDropdown(l10n),
                        const SizedBox(width: 8),
                        Text(
                          l10n?.pageOf(currentPage, totalPages) ?? 'Page $currentPage of $totalPages',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
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
              'Failed to load listings',
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
              l10n?.noListingsAvailable ?? 'No listings available',
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
        childAspectRatio: 0.58,
        crossAxisSpacing: 10,
        mainAxisSpacing: 12,
      ),
      itemCount: listings.length + (isLoading ? 2 : 0),
      itemBuilder: (context, index) {
        if (index >= listings.length) {
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
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).padding.bottom),
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

  Widget _buildFilterSection(AppLocalizations? l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Filter header
          InkWell(
            onTap: () {
              setState(() {
                _showFilters = !_showFilters;
              });
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.filter_list, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Filters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_hasActiveFilters())
                        Container(
                          margin: const EdgeInsets.only(left: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: Colors.blue,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            _getActiveFilterCount().toString(),
                            style: const TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ),
                    ],
                  ),
                  Row(
                    children: [
                      if (_hasActiveFilters())
                        TextButton.icon(
                          onPressed: () {
                            _clearAllFilters();
                            _loadAgentListings(page: 1);
                          },
                          icon: const Icon(Icons.clear, size: 16),
                          label: Text(l10n?.clear ?? 'Clear'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                        ),
                      Icon(
                        _showFilters ? Icons.expand_less : Icons.expand_more,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Filter content
          if (_showFilters)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Quick filters row
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _buildFilterChip(
                        label: l10n?.forRent ?? 'Rent',
                        selected: _selectedListingFor == 'rent',
                        onSelected: (selected) {
                          setState(() {
                            _selectedListingFor = selected ? 'rent' : null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: l10n?.forSale ?? 'Sale',
                        selected: _selectedListingFor == 'sale',
                        onSelected: (selected) {
                          setState(() {
                            _selectedListingFor = selected ? 'sale' : null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: l10n?.propertyTypeApartment ?? 'Apartment',
                        selected: _selectedType == 'apartment',
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? 'apartment' : null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: l10n?.propertyTypeChalet ?? 'Chalet',
                        selected: _selectedType == 'chalet',
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? 'chalet' : null;
                          });
                        },
                      ),
                      _buildFilterChip(
                        label: 'Commercial',
                        selected: _selectedType == 'commercial',
                        onSelected: (selected) {
                          setState(() {
                            _selectedType = selected ? 'commercial' : null;
                          });
                        },
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Price range
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Min Price',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money, size: 20),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxPriceController,
                          decoration: const InputDecoration(
                            labelText: 'Max Price',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.attach_money, size: 20),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Bedrooms & Bathrooms
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minBedroomsController,
                          decoration: const InputDecoration(
                            labelText: 'Min Bedrooms',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bed, size: 20),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxBedroomsController,
                          decoration: const InputDecoration(
                            labelText: 'Max Bedrooms',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bed, size: 20),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Bathrooms
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minBathroomsController,
                          decoration: const InputDecoration(
                            labelText: 'Min Bathrooms',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bathroom, size: 20),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxBathroomsController,
                          decoration: const InputDecoration(
                            labelText: 'Max Bathrooms',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.bathroom, size: 20),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Size range
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _minSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Min Size (m²)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.square_foot, size: 20),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _maxSizeController,
                          decoration: const InputDecoration(
                            labelText: 'Max Size (m²)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.square_foot, size: 20),
                            isDense: true,
                          ),
                          keyboardType: TextInputType.number,
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // City field
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _selectedCity = value.isEmpty ? null : value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'City',
                      border: const OutlineInputBorder(),
                      prefixIcon: const Icon(Icons.location_city, size: 20),
                      isDense: true,
                      hintText: _selectedCity ?? '',
                    ),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Apply button
                  ElevatedButton.icon(
                    onPressed: () {
                      _loadAgentListings(page: 1);
                    },
                    icon: const Icon(Icons.search),
                    label: const Text('Apply Filters'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool selected,
    required Function(bool) onSelected,
  }) {
    return FilterChip(
      label: Text(label),
      selected: selected,
      onSelected: onSelected,
      selectedColor: Theme.of(context).primaryColor.withOpacity(0.2),
      checkmarkColor: Theme.of(context).primaryColor,
    );
  }

  Widget _buildSortDropdown(AppLocalizations? l10n) {
    return PopupMenuButton<String>(
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
            _getSortLabel(_selectedSort ?? 'date_desc', l10n),
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
              if (_selectedSort == 'date_desc')
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
              if (_selectedSort == 'date_asc')
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
              if (_selectedSort == 'price_asc')
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
              if (_selectedSort == 'price_desc')
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
        if (value != _selectedSort) {
          setState(() {
            _selectedSort = value;
          });
          _loadAgentListings(page: 1);
        }
      },
    );
  }

  String _getSortLabel(String sort, AppLocalizations? l10n) {
    switch (sort) {
      case 'date_desc':
        return l10n?.newestFirst ?? 'Newest';
      case 'date_asc':
        return l10n?.oldestFirst ?? 'Oldest';
      case 'price_asc':
        return 'Price ↑';
      case 'price_desc':
        return 'Price ↓';
      default:
        return l10n?.newestFirst ?? 'Newest';
    }
  }

  bool _hasActiveFilters() {
    return _selectedListingFor != null ||
        _selectedCity != null ||
        _selectedType != null ||
        _minPriceController.text.isNotEmpty ||
        _maxPriceController.text.isNotEmpty ||
        _minBedroomsController.text.isNotEmpty ||
        _maxBedroomsController.text.isNotEmpty ||
        _minBathroomsController.text.isNotEmpty ||
        _maxBathroomsController.text.isNotEmpty ||
        _minSizeController.text.isNotEmpty ||
        _maxSizeController.text.isNotEmpty;
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (_selectedListingFor != null) count++;
    if (_selectedCity != null) count++;
    if (_selectedType != null) count++;
    if (_minPriceController.text.isNotEmpty || _maxPriceController.text.isNotEmpty) count++;
    if (_minBedroomsController.text.isNotEmpty || _maxBedroomsController.text.isNotEmpty) count++;
    if (_minBathroomsController.text.isNotEmpty || _maxBathroomsController.text.isNotEmpty) count++;
    if (_minSizeController.text.isNotEmpty || _maxSizeController.text.isNotEmpty) count++;
    return count;
  }

  void _clearAllFilters() {
    setState(() {
      _selectedListingFor = null;
      _selectedCity = null;
      _selectedType = null;
      _selectedSort = 'date_desc';
      _minPriceController.clear();
      _maxPriceController.clear();
      _minBedroomsController.clear();
      _maxBedroomsController.clear();
      _minBathroomsController.clear();
      _maxBathroomsController.clear();
      _minSizeController.clear();
      _maxSizeController.clear();
    });
  }
}

