import 'package:flutter/material.dart';

class AdvancedFiltersPage extends StatefulWidget {
  final String initialQuery;
  final Map<String, dynamic>? initialFilters;

  const AdvancedFiltersPage({
    super.key,
    required this.initialQuery,
    this.initialFilters,
  });

  @override
  State<AdvancedFiltersPage> createState() => _AdvancedFiltersPageState();
}

class _AdvancedFiltersPageState extends State<AdvancedFiltersPage> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Filter values
  String? _selectedType;
  String? _selectedListingFor;
  String? _selectedCity;
  String? _selectedSort;
  double? _minPrice;
  double? _maxPrice;
  int? _minBedrooms;
  int? _maxBedrooms;
  int? _minBathrooms;
  int? _maxBathrooms;
  String? _selectedCondition;
  String? _selectedPaymentFrequency;
  bool? _hasParking;
  bool? _hasElevator;
  bool? _hasPool;
  bool? _hasGarden;
  bool? _hasSecurity;
  bool? _isFurnished;

  final List<String> _propertyTypes = [
    'apartment',
    'chalet',
    'studio',
    'commercial',
    'villa',
    'land',
  ];

  final List<String> _listingForOptions = ['sale', 'rent'];
  
  final List<String> _paymentFrequencyOptions = ['daily', 'monthly', 'yearly'];

  final List<String> _conditionOptions = [
    'excellent',
    'good',
    'needs_renovation',
    'new',
    'old',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    
    // Initialize filters from initial values
    if (widget.initialFilters != null) {
      _selectedType = widget.initialFilters!['type'];
      _selectedListingFor = widget.initialFilters!['listingFor'];
      _selectedCity = widget.initialFilters!['city'];
      _selectedSort = widget.initialFilters!['sort'];
      _minPrice = widget.initialFilters!['minPrice']?.toDouble();
      _maxPrice = widget.initialFilters!['maxPrice']?.toDouble();
      _minBedrooms = widget.initialFilters!['minBedrooms'];
      _maxBedrooms = widget.initialFilters!['maxBedrooms'];
      _minBathrooms = widget.initialFilters!['minBathrooms'];
      _maxBathrooms = widget.initialFilters!['maxBathrooms'];
      _selectedCondition = widget.initialFilters!['condition'];
      _selectedPaymentFrequency = widget.initialFilters!['paymentFrequency'];
      _hasParking = widget.initialFilters!['parking'];
      _hasElevator = widget.initialFilters!['elevator'];
      _hasPool = widget.initialFilters!['pool'];
      _hasGarden = widget.initialFilters!['garden'];
      _hasSecurity = widget.initialFilters!['security'];
      _isFurnished = widget.initialFilters!['furnished'];
    } else {
      // Set default values to null (Any) when no initial filters
      _selectedType = null;
      _selectedListingFor = null;
      _selectedCondition = null;
      _selectedSort = null;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedType = null;
      _selectedListingFor = null;
      _selectedCity = null;
      _selectedSort = null;
      _minPrice = null;
      _maxPrice = null;
      _minBedrooms = null;
      _maxBedrooms = null;
      _minBathrooms = null;
      _maxBathrooms = null;
      _selectedCondition = null;
      _selectedPaymentFrequency = null;
      _hasParking = null;
      _hasElevator = null;
      _hasPool = null;
      _hasGarden = null;
      _hasSecurity = null;
      _isFurnished = null;
    });
  }

  void _applyFilters() {
    final filters = <String, dynamic>{};
    
    if (_selectedType != null) filters['type'] = _selectedType;
    if (_selectedListingFor != null) filters['listingFor'] = _selectedListingFor;
    if (_selectedCity != null && _selectedCity!.isNotEmpty) filters['city'] = _selectedCity;
    if (_selectedSort != null) filters['sort'] = _selectedSort;
    if (_minPrice != null) filters['minPrice'] = _minPrice;
    if (_maxPrice != null) filters['maxPrice'] = _maxPrice;
    if (_minBedrooms != null) filters['minBedrooms'] = _minBedrooms;
    if (_maxBedrooms != null) filters['maxBedrooms'] = _maxBedrooms;
    if (_minBathrooms != null) filters['minBathrooms'] = _minBathrooms;
    if (_maxBathrooms != null) filters['maxBathrooms'] = _maxBathrooms;
    if (_selectedCondition != null) filters['condition'] = _selectedCondition;
    if (_selectedPaymentFrequency != null && _selectedPaymentFrequency!.isNotEmpty) {
      filters['paymentFrequency'] = _selectedPaymentFrequency!.toLowerCase().trim();
    }
    if (_hasParking != null) filters['parking'] = _hasParking;
    if (_hasElevator != null) filters['elevator'] = _hasElevator;
    if (_hasPool != null) filters['pool'] = _hasPool;
    if (_hasGarden != null) filters['garden'] = _hasGarden;
    if (_hasSecurity != null) filters['security'] = _hasSecurity;
    if (_isFurnished != null) filters['furnished'] = _isFurnished;

    Navigator.pop(context, {
      'query': _searchController.text.trim(),
      'filters': filters,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Advanced Filters'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          TextButton(
            onPressed: _clearAllFilters,
            child: const Text('Clear All'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search Query
              TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Enter search terms...',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24.0),

              // Property Type
              _buildSectionTitle('Property Type'),
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ..._propertyTypes.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.toUpperCase()),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Listing For
              _buildSectionTitle('Listing For'),
              DropdownButtonFormField<String>(
                value: _selectedListingFor,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ..._listingForOptions.map((option) {
                    return DropdownMenuItem(
                      value: option,
                      child: Text(option.toUpperCase()),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedListingFor = value;
                    // Clear payment frequency when switching to sale or Any (not applicable)
                    if (value == 'sale' || value == null) {
                      _selectedPaymentFrequency = null;
                    }
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Payment Frequency - only show for rent
              if (_selectedListingFor == 'rent') ...[
                _buildSectionTitle('Payment Frequency'),
                DropdownButtonFormField<String>(
                  value: _selectedPaymentFrequency,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select payment frequency',
                  ),
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('Any'),
                    ),
                    ..._paymentFrequencyOptions.map((frequency) {
                      return DropdownMenuItem(
                        value: frequency,
                        child: Text(frequency.substring(0, 1).toUpperCase() + frequency.substring(1)),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedPaymentFrequency = value;
                    });
                  },
                ),
                const SizedBox(height: 16.0),
              ],

              // City
              _buildSectionTitle('City'),
              TextFormField(
                initialValue: _selectedCity,
                decoration: const InputDecoration(
                  hintText: 'Enter city name',
                  border: OutlineInputBorder(),
                ),
                onChanged: (value) {
                  _selectedCity = value.trim().isEmpty ? null : value.trim();
                },
              ),
              const SizedBox(height: 16.0),

              // Price Range
              _buildSectionTitle('Price Range'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _minPrice?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Min Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _minPrice = double.tryParse(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      initialValue: _maxPrice?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Max Price',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _maxPrice = double.tryParse(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Bedrooms
              _buildSectionTitle('Bedrooms'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _minBedrooms?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Min Bedrooms',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _minBedrooms = int.tryParse(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      initialValue: _maxBedrooms?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Max Bedrooms',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _maxBedrooms = int.tryParse(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Bathrooms
              _buildSectionTitle('Bathrooms'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _minBathrooms?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Min Bathrooms',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _minBathrooms = int.tryParse(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      initialValue: _maxBathrooms?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Max Bathrooms',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _maxBathrooms = int.tryParse(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Condition
              _buildSectionTitle('Condition'),
              DropdownButtonFormField<String>(
                value: _selectedCondition,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ..._conditionOptions.map((condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(condition.replaceAll('_', ' ').toUpperCase()),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCondition = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Amenities
              _buildSectionTitle('Amenities'),
              _buildAmenityCheckbox('Parking', _hasParking, (value) {
                setState(() {
                  _hasParking = value;
                });
              }),
              _buildAmenityCheckbox('Elevator', _hasElevator, (value) {
                setState(() {
                  _hasElevator = value;
                });
              }),
              _buildAmenityCheckbox('Pool', _hasPool, (value) {
                setState(() {
                  _hasPool = value;
                });
              }),
              _buildAmenityCheckbox('Garden', _hasGarden, (value) {
                setState(() {
                  _hasGarden = value;
                });
              }),
              _buildAmenityCheckbox('Security', _hasSecurity, (value) {
                setState(() {
                  _hasSecurity = value;
                });
              }),
              _buildAmenityCheckbox('Furnished', _isFurnished, (value) {
                setState(() {
                  _isFurnished = value;
                });
              }),
              const SizedBox(height: 16.0),

              // Sort Options
              _buildSectionTitle('Sort By'),
              DropdownButtonFormField<String>(
                value: _selectedSort,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Any'),
                  ),
                  DropdownMenuItem(value: 'score', child: Text('Relevance')),
                  DropdownMenuItem(value: 'date_desc', child: Text('Newest First')),
                  DropdownMenuItem(value: 'date_asc', child: Text('Oldest First')),
                  DropdownMenuItem(value: 'price_asc', child: Text('Price: Low to High')),
                  DropdownMenuItem(value: 'price_desc', child: Text('Price: High to Low')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedSort = value;
                  });
                },
              ),
              const SizedBox(height: 32.0),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearAllFilters,
                      child: const Text('Clear All'),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      child: const Text('Search'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16.0,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAmenityCheckbox(
    String title,
    bool? value,
    Function(bool?) onChanged,
  ) {
    return CheckboxListTile(
      title: Text(title),
      value: value ?? false,
      onChanged: onChanged,
      controlAffinity: ListTileControlAffinity.leading,
      contentPadding: EdgeInsets.zero,
    );
  }
}
