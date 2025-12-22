import 'package:flutter/material.dart';
import '../search/city_selection_page.dart';

class ServiceProviderAdvancedFiltersPage extends StatefulWidget {
  final String initialQuery;
  final Map<String, dynamic>? initialFilters;

  const ServiceProviderAdvancedFiltersPage({
    super.key,
    required this.initialQuery,
    this.initialFilters,
  });

  @override
  State<ServiceProviderAdvancedFiltersPage> createState() => _ServiceProviderAdvancedFiltersPageState();
}

class _ServiceProviderAdvancedFiltersPageState extends State<ServiceProviderAdvancedFiltersPage> {
  final TextEditingController _searchController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  
  // Filter values
  String? _selectedProviderType; // 'company' or 'individual'
  String? _selectedCity;
  String? _selectedDistrict;
  String? _selectedSort;
  bool? _isFeatured;

  final List<String> _districts = [
    'Beirut',
    'Mount Lebanon',
    'North Lebanon',
    'South Lebanon',
    'Bekaa',
    'Nabatieh',
  ];

  @override
  void initState() {
    super.initState();
    _searchController.text = widget.initialQuery;
    
    // Initialize filters from initial values
    if (widget.initialFilters != null) {
      // Handle both role and providerType for backward compatibility
      if (widget.initialFilters!['role'] != null) {
        final role = widget.initialFilters!['role'].toString();
        if (role == 'service-provider-company') {
          _selectedProviderType = 'company';
        } else if (role == 'service-provider-individual') {
          _selectedProviderType = 'individual';
        }
      } else if (widget.initialFilters!['providerType'] != null) {
        _selectedProviderType = widget.initialFilters!['providerType'];
      }
      _selectedCity = widget.initialFilters!['city'];
      _selectedDistrict = widget.initialFilters!['district'];
      _selectedSort = widget.initialFilters!['sort'];
      if (widget.initialFilters!['isFeatured'] != null) {
        _isFeatured = widget.initialFilters!['isFeatured'] == true || 
                     widget.initialFilters!['isFeatured'] == 'true';
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _clearAllFilters() {
    setState(() {
      _selectedProviderType = null;
      _selectedCity = null;
      _selectedDistrict = null;
      _selectedSort = null;
      _isFeatured = null;
    });
  }

  void _applyFilters() {
    final query = _searchController.text.trim();

    final filters = <String, dynamic>{};
    
    // Convert providerType to role for backend
    if (_selectedProviderType != null) {
      if (_selectedProviderType == 'company') {
        filters['role'] = 'service-provider-company';
      } else if (_selectedProviderType == 'individual') {
        filters['role'] = 'service-provider-individual';
      }
    }
    if (_selectedCity != null && _selectedCity!.isNotEmpty) filters['city'] = _selectedCity;
    if (_selectedDistrict != null && _selectedDistrict!.isNotEmpty) filters['district'] = _selectedDistrict;
    // Only pass sort if it's explicitly set to oldest (newest is the default)
    if (_selectedSort == 'date_asc') {
      filters['sort'] = _selectedSort;
    }
    if (_isFeatured != null) filters['isFeatured'] = _isFeatured;

    Navigator.pop(context, {
      'query': query,
      'filters': filters,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filter Service Providers'),
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
              _buildSectionTitle('Search Query'),
              TextFormField(
                controller: _searchController,
                decoration: const InputDecoration(
                  labelText: 'Search',
                  hintText: 'Enter search terms...',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: 24.0),

              // Provider Type (Company/Individual) - Main filter
              _buildSectionTitle('Provider Type'),
              Row(
                children: [
                  Expanded(
                    child: _buildProviderTypeButton(null, 'Any', Icons.people_outline),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildProviderTypeButton('individual', 'Individual', Icons.person),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildProviderTypeButton('company', 'Company', Icons.business),
                  ),
                ],
              ),
              const SizedBox(height: 24.0),

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
                    _selectedCity ?? 'Any',
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

              // District
              _buildSectionTitle('District'),
              DropdownButtonFormField<String>(
                value: _selectedDistrict,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Select district',
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: null,
                    child: Text('Any'),
                  ),
                  ..._districts.map((district) {
                    return DropdownMenuItem<String>(
                      value: district,
                      child: Text(district),
                    );
                  }).toList(),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                },
              ),
              const SizedBox(height: 16.0),

              // Featured
              _buildSectionTitle('Featured'),
              Row(
                children: [
                  Expanded(
                    child: _buildBooleanButton(null, 'Any'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildBooleanButton(true, 'Featured'),
                  ),
                  const SizedBox(width: 16.0),
                  Expanded(
                    child: _buildBooleanButton(false, 'Not Featured'),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),

              // Sort Options
              _buildSectionTitle('Sort By'),
              DropdownButtonFormField<String>(
                value: _selectedSort ?? 'date_desc', // Default to newest first
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<String>(
                    value: 'date_desc',
                    child: Text('Newest First'),
                  ),
                  const DropdownMenuItem<String>(
                    value: 'date_asc',
                    child: Text('Oldest First'),
                  ),
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

  Widget _buildProviderTypeButton(String? value, String label, IconData icon) {
    final isSelected = _selectedProviderType == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProviderType = value;
        });
      },
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
            width: isSelected ? 2.0 : 1.0,
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
        child: Column(
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8.0),
            Text(
              label.toUpperCase(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12.0,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBooleanButton(bool? value, String label) {
    final isSelected = _isFeatured == value;

    return GestureDetector(
      onTap: () {
        setState(() {
          _isFeatured = value;
        });
      },
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
            width: isSelected ? 2.0 : 1.0,
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
            fontSize: 14.0,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

