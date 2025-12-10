import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';

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
  
  // Amenities - using same structure as add_listing_form_page.dart
  Map<String, bool> amenities = {
    'furnished': false,
    'terrace': false,
    'privatePool': false,
    'storageRoom': false,
    'sharedPool': false,
    'sharedGym': false,
    'security': false,
    'seaView': false,
    'garden': false,
    'mountainView': false,
    'elevator': false,
    'parking': false,
    'centralAC': false,
    'heating': false,
    'solarSystem': false,
    'electricity24_7': false,
    'maidRoom': false,
  };

  final List<String> _propertyTypes = [
    'apartment',
    'chalet',
    'studio',
    'commercial',
    'villa',
    'land',
  ];
  
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
      
      // Initialize amenities from initial filters
      if (widget.initialFilters!['amenities'] != null) {
        final amenityList = widget.initialFilters!['amenities'];
        if (amenityList is String) {
          // Parse comma-separated string
          final amenityArray = amenityList.split(',').map((a) => a.trim().toLowerCase()).toList();
          for (String key in amenities.keys) {
            if (amenityArray.contains(key.toLowerCase())) {
              amenities[key] = true;
            }
          }
        } else if (amenityList is List) {
          // Parse list
          for (String key in amenities.keys) {
            if (amenityList.any((a) => a.toString().toLowerCase() == key.toLowerCase())) {
              amenities[key] = true;
            }
          }
        }
      }
      
      // Keep backward compatibility with old format
      if (widget.initialFilters!['parking'] == true) amenities['parking'] = true;
      if (widget.initialFilters!['elevator'] == true) amenities['elevator'] = true;
      if (widget.initialFilters!['pool'] == true) amenities['sharedPool'] = true;
      if (widget.initialFilters!['garden'] == true) amenities['garden'] = true;
      if (widget.initialFilters!['security'] == true) amenities['security'] = true;
      if (widget.initialFilters!['furnished'] == true) amenities['furnished'] = true;
    } else {
      // Set default values to null (Any) when no initial filters
      _selectedType = null;
      _selectedListingFor = 'rent'; // Default to rent
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
      _selectedListingFor = 'rent'; // Default to rent
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
      
      // Reset all amenities to false
      for (String key in amenities.keys) {
        amenities[key] = false;
      }
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
    
    // Collect selected amenities
    final selectedAmenities = <String>[];
    amenities.forEach((key, value) {
      if (value == true) {
        selectedAmenities.add(key);
      }
    });
    
    // Send amenities as comma-separated string matching backend API
    if (selectedAmenities.isNotEmpty) {
      filters['amenities'] = selectedAmenities.join(',');
    }

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
              // TextFormField(
              //   controller: _searchController,
              //   decoration: const InputDecoration(
              //     labelText: 'Search',
              //     hintText: 'Enter search terms...',
              //     border: OutlineInputBorder(),
              //   ),
              // ),
              // const SizedBox(height: 24.0),

              // Listing For
              _buildSectionTitle('Listing For'),
              Row(
                children: [
                  Expanded(
                    child: _buildListingForButton('sale', 'Sale'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildListingForButton('rent', 'Rent'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Property Type
              _buildSectionTitle('Property Type'),
              Wrap(
                spacing: 8.0,
                runSpacing: 8.0,
                children: [
                  // Any option
                  _buildPropertyTypeButton(
                    context,
                    type: null,
                    label: 'Any',
                    icon: Icons.home,
                  ),
                  // Property type buttons
                  ..._propertyTypes.map((type) {
                    return _buildPropertyTypeButton(
                      context,
                      type: type,
                      label: _getPropertyTypeLabel(context, type),
                      icon: _getPropertyTypeIcon(type),
                    );
                  }).toList(),
                ],
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

              // Amenities - using FilterChips like add_listing_form_page.dart
              _buildSectionTitle('Amenities'),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: amenities.keys.map((key) {
                  return FilterChip(
                    label: Text(_getAmenityLabel(key)),
                    selected: amenities[key]!,
                    onSelected: (selected) {
                      setState(() {
                        amenities[key] = selected;
                      });
                    },
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF3B82F6),
                  );
                }).toList(),
              ),
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

  String _getAmenityLabel(String key) {
    switch (key) {
      case 'furnished': return 'Furnished';
      case 'terrace': return 'Terrace';
      case 'privatePool': return 'Private Pool';
      case 'storageRoom': return 'Storage Room';
      case 'sharedPool': return 'Shared Pool';
      case 'sharedGym': return 'Shared Gym';
      case 'security': return 'Security';
      case 'seaView': return 'Sea View';
      case 'garden': return 'Garden';
      case 'mountainView': return 'Mountain View';
      case 'elevator': return 'Elevator';
      case 'parking': return 'Parking';
      case 'centralAC': return 'Central AC';
      case 'heating': return 'Heating';
      case 'solarSystem': return 'Solar System';
      case 'electricity24_7': return '24/7 Electricity';
      case 'maidRoom': return 'Maid Room';
      default: return key;
    }
  }

  IconData _getPropertyTypeIcon(String type) {
    switch (type) {
      case 'apartment':
        return Icons.apartment;
      case 'chalet':
        return Icons.house_siding;
      case 'studio':
        return Icons.home_work;
      case 'commercial':
        return Icons.business;
      case 'villa':
        return Icons.villa;
      case 'land':
        return Icons.landscape;
      default:
        return Icons.home;
    }
  }

  String _getPropertyTypeLabel(BuildContext context, String type) {
    final l10n = AppLocalizations.of(context);
    switch (type) {
      case 'apartment':
        return l10n?.propertyTypeApartment ?? 'Apartment';
      case 'chalet':
        return l10n?.propertyTypeChalet ?? 'Chalet';
      case 'studio':
        return l10n?.propertyTypeStudio ?? 'Studio';
      case 'commercial':
        return l10n?.propertyTypeCommercial ?? 'Commercial';
      case 'villa':
        return l10n?.propertyTypeVilla ?? 'Villa';
      case 'land':
        return l10n?.propertyTypeLand ?? 'Land';
      default:
        return type;
    }
  }

  Widget _buildPropertyTypeButton(
    BuildContext context, {
    required String? type,
    required String label,
    required IconData icon,
  }) {
    final isSelected = _selectedType == type;
    // Flip colors: blue by default, gray when selected
    final gradientColors = isSelected
        ? [
            Colors.grey[300]!,
            Colors.grey[400]!,
          ]
        : [
            const Color.fromARGB(255, 103, 155, 218),
            const Color.fromARGB(255, 69, 100, 201),
          ];
    final iconColor = Colors.white;
    final textColor = isSelected ? Colors.grey[700]! : Colors.black87;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedType = type;
        });
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: gradientColors,
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListingForButton(String value, String label) {
    final isSelected = _selectedListingFor == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedListingFor = value;
          // Clear payment frequency when switching to sale (not applicable)
          if (value == 'sale') {
            _selectedPaymentFrequency = null;
          }
        });
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isSelected
                ? [
                    const Color.fromARGB(255, 103, 155, 218),
                    const Color.fromARGB(255, 69, 100, 201),
                  ]
                : [
                    Colors.grey[300]!,
                    Colors.grey[400]!,
                  ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(8.0),
          border: isSelected
              ? Border.all(
                  color: const Color.fromARGB(255, 69, 100, 201),
                  width: 2.0,
                )
              : Border.all(
                  color: Colors.grey[300]!,
                  width: 1.0,
                ),
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.grey[700]!,
          ),
        ),
      ),
    );
  }
}
