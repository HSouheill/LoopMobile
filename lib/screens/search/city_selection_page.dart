import 'package:flutter/material.dart';
import '../services/cities_service.dart';

class CitySelectionPage extends StatefulWidget {
  final String? selectedCity;

  const CitySelectionPage({
    super.key,
    this.selectedCity,
  });

  @override
  State<CitySelectionPage> createState() => _CitySelectionPageState();
}

class _CitySelectionPageState extends State<CitySelectionPage> {
  String? _selectedCity;
  bool _isLebanonExpanded = false;
  List<String> _lebanonCities = [];
  final TextEditingController _searchController = TextEditingController();
  List<String> _filteredCities = [];

  @override
  void initState() {
    super.initState();
    _selectedCity = widget.selectedCity;
    _loadLebanonCities();
    _filteredCities = _lebanonCities;
    _searchController.addListener(_filterCities);
    // Expand Lebanon if a city is already selected
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_selectedCity != null && _lebanonCities.contains(_selectedCity)) {
        setState(() {
          _isLebanonExpanded = true;
        });
      }
    });
  }

  void _loadLebanonCities() {
    _lebanonCities = LocationService.getAllCitiesInLebanon();
    _filteredCities = _lebanonCities;
  }

  void _filterCities() {
    final query = _searchController.text.toLowerCase().trim();
    if (query.isEmpty) {
      setState(() {
        _filteredCities = _lebanonCities;
      });
    } else {
      setState(() {
        _filteredCities = _lebanonCities
            .where((city) => city.toLowerCase().contains(query))
            .toList();
      });
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _selectCity(String? city) {
    setState(() {
      _selectedCity = city;
    });
    Navigator.pop(context, city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select City'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Column(
        children: [
          // Search bar for cities (only shown when Lebanon is expanded)
          if (_isLebanonExpanded)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search cities...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  filled: true,
                  fillColor: Colors.grey[100],
                ),
              ),
            ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                // Any option
                _buildCityOption(
                  label: 'All',
                  value: null,
                  icon: Icons.location_on_outlined,
                ),
                const SizedBox(height: 8.0),
                
                // Lebanon option (expandable)
                _buildExpandableLebanonSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCityOption({
    required String label,
    required String? value,
    required IconData icon,
  }) {
    final isSelected = _selectedCity == value;
    
    return GestureDetector(
      onTap: () => _selectCity(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF3B82F6).withOpacity(0.1)
              : Colors.white,
          border: Border.all(
            color: isSelected
                ? const Color(0xFF3B82F6)
                : Colors.grey[300]!,
            width: isSelected ? 2.0 : 1.0,
          ),
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? const Color(0xFF3B82F6)
                  : Colors.grey[600],
            ),
            const SizedBox(width: 12.0),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? const Color(0xFF3B82F6)
                      : Colors.black87,
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: Color(0xFF3B82F6),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpandableLebanonSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Lebanon header (clickable to expand/collapse)
        GestureDetector(
          onTap: () {
            setState(() {
              _isLebanonExpanded = !_isLebanonExpanded;
              if (!_isLebanonExpanded) {
                _searchController.clear();
              }
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: Colors.grey[300]!,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.flag,
                  color: Color(0xFF3B82F6),
                ),
                const SizedBox(width: 12.0),
                const Expanded(
                  child: Text(
                    'Lebanon',
                    style: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Icon(
                  _isLebanonExpanded
                      ? Icons.expand_less
                      : Icons.expand_more,
                  color: Colors.grey[600],
                ),
              ],
            ),
          ),
        ),
        
        // Cities list (shown when expanded)
        if (_isLebanonExpanded) ...[
          const SizedBox(height: 8.0),
          if (_filteredCities.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'No cities found',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.0,
                  ),
                ),
              ),
            )
          else
            ..._filteredCities.map((city) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: _buildCityOption(
                  label: city,
                  value: city,
                  icon: Icons.location_city,
                ),
              );
            }).toList(),
        ],
      ],
    );
  }
}

