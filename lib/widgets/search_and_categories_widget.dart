import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../screens/search/search_results_page.dart';
import '../screens/search/advanced_filters_page.dart';

class SearchAndCategoriesWidget extends StatefulWidget {
  const SearchAndCategoriesWidget({super.key});

  @override
  State<SearchAndCategoriesWidget> createState() => _SearchAndCategoriesWidgetState();
}

class _SearchAndCategoriesWidgetState extends State<SearchAndCategoriesWidget> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _performSearch() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            initialQuery: query,
          ),
        ),
      );
    } else {
      // If no query, show a message or do nothing
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a search term'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _openAdvancedFilters() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (context) => AdvancedFiltersPage(
          initialQuery: _searchController.text.trim(),
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SearchResultsPage(
            initialQuery: result['query'],
            initialFilters: result['filters'],
          ),
        ),
      );
    }
  }

  void _navigateToCategory(String category) {
    // Automatically trigger search with the selected category filter
    // even if search bar is empty
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          initialCategory: category,
          // Pass empty query to trigger category-only search
          initialQuery: '',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Search Bar (transparent, no borders, hint color matches icon)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.transparent, // transparent background
              borderRadius: BorderRadius.circular(30.0),
              // removed boxShadow to eliminate borders/shadow
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Color.fromARGB(255, 38, 118, 216)),
                const SizedBox(width: 8.0),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context);
                      return TextField(
                        controller: _searchController,
                        cursorColor: Color.fromARGB(255, 69, 100, 201),
                        onSubmitted: (_) => _performSearch(),
                        decoration: InputDecoration(
                          hintText: l10n?.search ?? 'Search...',
                          // remove all borders
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          // keep background transparent
                          filled: true,
                          fillColor: Colors.transparent,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
                          // placeholder color same as icon
                          hintStyle: const TextStyle(color: Color.fromARGB(255, 38, 118, 216)),
                        ),
                      );
                    }
                  ),
                ),
                IconButton(
                  icon: const Icon(
                    Icons.tune,
                    color: Color.fromARGB(255, 38, 118, 216),
                    size: 30,
                  ),
                  iconSize: 30,
                  onPressed: _openAdvancedFilters,
                ),
              ],
            ),
          ),
          const SizedBox(height: 4.0),
          // Horizontal separator line
          Container(
            height: 1.0,
            color: Colors.green,
            margin: const EdgeInsets.symmetric(horizontal: 0.0),
          ),
          const SizedBox(height: 16.0),
          // Categories - Horizontally scrollable
          SizedBox(
            height: 85.0,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 4.0),
              children: [
                _buildCategoryIcon(
                    context, Icons.house_siding, 'chalet', 'chalet'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.cottage, 'villa', 'villa'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.apartment, 'apartment', 'apartment'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.landscape, 'land', 'land'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.business, 'commercial', 'commercial'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.roofing, 'studio', 'studio'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.factory, 'industrial', 'industrial'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.bed, 'room', 'room'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.domain, 'building', 'building'),
                const SizedBox(width: 16.0),
                _buildCategoryIcon(
                    context, Icons.public, 'international', 'international'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(
      BuildContext context, IconData icon, String category, String filterValue) {
    String label = _getPropertyTypeLabel(context, category);
    
    return GestureDetector(
      onTap: () => _navigateToCategory(filterValue),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  Color.fromARGB(255, 103, 155, 218),
                  Color.fromARGB(255, 69, 100, 201),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 8.0),
          Text(
            label,
            style: const TextStyle(fontSize: 12.0, color: Colors.black87),
          ),
        ],
      ),
    );
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
}

// Sticky header delegate for SearchAndCategoriesWidget
class StickySearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  final Widget child;

  StickySearchHeaderDelegate({required this.child});

  @override
  double get minExtent => 170.0; // Approximate height of the widget

  @override
  double get maxExtent => 170.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white, // Background color to prevent content showing through
      child: child,
    );
  }

  @override
  bool shouldRebuild(StickySearchHeaderDelegate oldDelegate) {
    return child != oldDelegate.child;
  }
}