import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import 'city_selection_page.dart';

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
  int? _bedrooms;
  int? _bathrooms;
  double? _minSize;
  double? _maxSize;
  String? _selectedCondition;
  String? _selectedFurnishing;
  String? _selectedPaymentFrequency;
  String? _selectedOwnership;
  String? _selectedFloor;
  
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
    'accessible': false,
    'atticLoft': false,
    'builtInKitchenAppliances': false,
    'builtInWardrobes': false,
    'concierge': false,
    'coveredParking': false,
    'fireplace': false,
    'petsAllowed': false,
    'playroom': false,
    'privateGarden': false,
    'privateGym': false,
    'privateJacuzzi': false,
    'sharedSpa': false,
    'studyRoom': false,
    'balcony': false,
    'walkInCloset': false,
  };

  final List<String> _propertyTypes = [
    'apartment',
    'chalet',
    'studio',
    'commercial',
    'villa',
    'land',
    'industrial',
    'room',
    'building',
    'international',
  ];
  
  final List<String> _paymentFrequencyOptions = ['daily', 'monthly', 'yearly'];

  final List<String> _conditionOptions = [
    'under_construction',
    'ready',
    'needs_renovation',
  ];

  final List<String> _furnishingOptions = [
    'unfurnished',
    'semi_furnished',
    'fully_furnished',
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
      // Use minBedrooms/maxBedrooms for backward compatibility, prefer min if both exist
      _bedrooms = widget.initialFilters!['minBedrooms'] ?? widget.initialFilters!['maxBedrooms'];
      _bathrooms = widget.initialFilters!['minBathrooms'] ?? widget.initialFilters!['maxBathrooms'];
      _minSize = widget.initialFilters!['minSize']?.toDouble();
      _maxSize = widget.initialFilters!['maxSize']?.toDouble();
      _selectedCondition = widget.initialFilters!['condition'];
      _selectedFurnishing = widget.initialFilters!['furnishing'];
      _selectedPaymentFrequency = widget.initialFilters!['paymentFrequency'];
      _selectedOwnership = widget.initialFilters!['ownership'];
      _selectedFloor = widget.initialFilters!['floor'];
      
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
      // Set default values to null (All) when no initial filters
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
      _bedrooms = null;
      _bathrooms = null;
      _minSize = null;
      _maxSize = null;
      _selectedCondition = null;
      _selectedFurnishing = null;
      _selectedPaymentFrequency = null;
      _selectedOwnership = null;
      _selectedFloor = null;
      
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
    // Set both min and max to the same value for bedrooms and bathrooms
    if (_bedrooms != null) {
      filters['minBedrooms'] = _bedrooms;
      filters['maxBedrooms'] = _bedrooms;
    }
    if (_bathrooms != null) {
      filters['minBathrooms'] = _bathrooms;
      filters['maxBathrooms'] = _bathrooms;
    }
    if (_minSize != null) filters['minSize'] = _minSize;
    if (_maxSize != null) filters['maxSize'] = _maxSize;
    if (_selectedCondition != null) filters['condition'] = _selectedCondition;
    if (_selectedFurnishing != null && _selectedFurnishing!.isNotEmpty) {
      // Ensure furnishing is one of the valid values: "unfurnished", "semi_furnished", "fully_furnished"
      final furnishingValue = _selectedFurnishing!.toLowerCase().trim();
      if (_furnishingOptions.contains(furnishingValue)) {
        filters['furnishing'] = furnishingValue;
      }
    }
    if (_selectedPaymentFrequency != null && _selectedPaymentFrequency!.isNotEmpty) {
      filters['paymentFrequency'] = _selectedPaymentFrequency!.toLowerCase().trim();
    }
    if (_selectedOwnership != null && _selectedOwnership!.isNotEmpty) {
      filters['ownership'] = _selectedOwnership;
    }
    if (_selectedFloor != null && _selectedFloor!.isNotEmpty) {
      filters['floor'] = _selectedFloor;
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
                  // All option
                  _buildPropertyTypeButton(
                    context,
                    type: null,
                    label: 'All',
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
                      child: Text('All'),
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
              GestureDetector(
                onTap: () async {
                  final selectedCity = await Navigator.push<String?>(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CitySelectionPage(
                        selectedCity: _selectedCity,
                      ),
                    ),
                  );
                  if (selectedCity != _selectedCity) {
                    setState(() {
                      _selectedCity = selectedCity;
                    });
                  }
                },
                child: InputDecorator(
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Select city',
                    suffixIcon: Icon(Icons.arrow_drop_down),
                  ),
                  child: Text(
                    _selectedCity ?? 'All',
                    style: TextStyle(
                      fontSize: 16.0,
                      color: _selectedCity != null
                          ? Colors.black87
                          : Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16.0),

              // Ownership
              _buildSectionTitle('Ownership'),
              DropdownButtonFormField<String>(
                value: _selectedOwnership,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select ownership',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'user',
                    child: Text('Owner'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'agent-individual',
                    child: Text('Agent'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'agent-company',
                    child: Text('Company'),
                  ),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedOwnership = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Price Range
              _buildSectionTitle('Price'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _minPrice?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Min',
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
                        labelText: 'Max',
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

              // Bedrooms & Bathrooms
              _buildSectionTitle('Bedrooms & Bathrooms'),
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _bedrooms,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Bedrooms',
                        labelText: 'Bedrooms',
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...List.generate(15, (index) => index + 1).map((count) {
                          return DropdownMenuItem<int>(
                            value: count,
                            child: Text('$count'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _bedrooms = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: DropdownButtonFormField<int>(
                      value: _bathrooms,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Bathrooms',
                        labelText: 'Bathrooms',
                      ),
                      items: [
                        const DropdownMenuItem<int>(
                          value: null,
                          child: Text('All'),
                        ),
                        ...List.generate(15, (index) => index + 1).map((count) {
                          return DropdownMenuItem<int>(
                            value: count,
                            child: Text('$count'),
                          );
                        }).toList(),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _bathrooms = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Size Range
              _buildSectionTitle('Size (m²)'),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      initialValue: _minSize?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Min Size',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _minSize = double.tryParse(value);
                      },
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: TextFormField(
                      initialValue: _maxSize?.toString(),
                      decoration: const InputDecoration(
                        labelText: 'Max Size',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        _maxSize = double.tryParse(value);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Floor
              _buildSectionTitle('Floor'),
              DropdownButtonFormField<String>(
                value: _selectedFloor,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select floor',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All'),
                  ),
                  ...List.generate(16, (index) {
                    final floorValue = index - 5; // -5 to 10
                    final displayValue = floorValue == 10 ? '10+' : floorValue.toString();
                    final backendValue = floorValue == 10 ? '10+' : floorValue.toString();
                    return DropdownMenuItem<String>(
                      value: backendValue,
                      child: Text(displayValue),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFloor = value;
                  });
                },
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
                    child: Text('All'),
                  ),
                  ..._conditionOptions.map((condition) {
                    return DropdownMenuItem(
                      value: condition,
                      child: Text(_formatConditionLabel(condition)),
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

              // Furnishing
              _buildSectionTitle('Furnishing'),
              DropdownButtonFormField<String>(
                value: _selectedFurnishing,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('All'),
                  ),
                  ..._furnishingOptions.map((furnishing) {
                    return DropdownMenuItem(
                      value: furnishing,
                      child: Text(_formatFurnishingLabel(furnishing)),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedFurnishing = value;
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
                    child: Text('All'),
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
                    child: GestureDetector(
                      onTap: _clearAllFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 103, 155, 218),
                              const Color.fromARGB(255, 69, 100, 201),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        child: const Text(
                          'Clear All',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: GestureDetector(
                      onTap: _applyFilters,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color.fromARGB(255, 103, 155, 218),
                              const Color.fromARGB(255, 69, 100, 201),
                            ],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(16.0),
                          border: Border.all(
                            color: Colors.grey[300]!,
                            width: 1.0,
                          ),
                        ),
                        child: const Text(
                          'Search',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
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

  String _formatConditionLabel(String condition) {
    switch (condition) {
      case 'under_construction':
        return 'Under Construction';
      case 'ready':
        return 'Ready';
      case 'needs_renovation':
        return 'Needs Renovation';
      default:
        return condition.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
    }
  }

  String _formatFurnishingLabel(String furnishing) {
    switch (furnishing) {
      case 'unfurnished':
        return 'Unfurnished';
      case 'semi_furnished':
        return 'Semi-Furnished';
      case 'fully_furnished':
        return 'Fully Furnished';
      default:
        return furnishing.replaceAll('_', ' ').split(' ').map((word) {
          if (word.isEmpty) return word;
          return word[0].toUpperCase() + word.substring(1).toLowerCase();
        }).join(' ');
    }
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
      case 'accessible': return 'Accessible';
      case 'atticLoft': return 'Attic/Loft';
      case 'builtInKitchenAppliances': return 'Built-in Kitchen Appliances';
      case 'builtInWardrobes': return 'Built-in Wardrobes';
      case 'concierge': return 'Concierge';
      case 'coveredParking': return 'Covered Parking';
      case 'fireplace': return 'Fireplace';
      case 'petsAllowed': return 'Pets Allowed';
      case 'playroom': return 'Playroom';
      case 'privateGarden': return 'Private Garden';
      case 'privateGym': return 'Private Gym';
      case 'privateJacuzzi': return 'Private Jacuzzi';
      case 'sharedSpa': return 'Shared Spa';
      case 'studyRoom': return 'Study Room';
      case 'balcony': return 'Balcony';
      case 'walkInCloset': return 'Walk-in Closet';
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
      case 'industrial':
        return Icons.factory;
      case 'room':
        return Icons.meeting_room;
      case 'building':
        return Icons.business_center;
      case 'international':
        return Icons.public;
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
      case 'industrial':
        return l10n?.propertyTypeIndustrial ?? 'Industrial';
      case 'room':
        return l10n?.propertyTypeRoom ?? 'Room';
      case 'building':
        return l10n?.propertyTypeBuilding ?? 'Building';
      case 'international':
        return l10n?.propertyTypeInternational ?? 'International';
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
    // Keep same gradient colors for both selected and unselected
    final gradientColors = [
      const Color.fromARGB(255, 103, 155, 218),
      const Color.fromARGB(255, 69, 100, 201),
    ];
    final iconColor = Colors.white;
    final textColor = isSelected ? Colors.blue[700]! : Colors.black87;
    final fontWeight = isSelected ? FontWeight.bold : FontWeight.normal;

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
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color.fromARGB(153, 120, 120, 120),
                        spreadRadius: 2,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Icon(icon, color: iconColor, size: 30),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: TextStyle(
              fontSize: 12.0,
              color: textColor,
              fontWeight: fontWeight,
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
            colors: [
              const Color.fromARGB(255, 103, 155, 218),
              const Color.fromARGB(255, 69, 100, 201),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16.0),
          border: Border.all(
            color: Colors.grey[300]!,
            width: 1.0,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(138, 116, 116, 116),
                    spreadRadius: 2,
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? Colors.white : Colors.white,
          ),
        ),
      ),
    );
  }
}
