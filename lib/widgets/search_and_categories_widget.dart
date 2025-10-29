import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
                const Icon(Icons.search, color: Color.fromARGB(255, 69, 100, 201)),
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
                          hintStyle: const TextStyle(color: Color.fromARGB(255, 69, 100, 201)),
                        ),
                      );
                    }
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.black87),
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
          // Categories
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCategoryIcon(
                  Icons.house_siding, 'Chalets', Colors.blue, Colors.white, 'chalet'),
              _buildCategoryIcon(
                  Icons.villa, 'Villas', Colors.blue, Colors.white, 'villa'),
              _buildCategoryIcon(
                  Icons.apartment, 'Apartments', Colors.blue, Colors.white, 'apartment'),
              _buildCategoryIcon(
                  Icons.landscape, 'Land', Colors.blue, Colors.white, 'land'),
              _buildCategoryIcon(
                  Icons.business, 'Commercial', Colors.blue, Colors.white, 'commercial'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(
      IconData icon, String label, Color backgroundColor, Color iconColor, String category) {
    return GestureDetector(
      onTap: () => _navigateToCategory(category),
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
            child: Icon(icon, color: iconColor, size: 30),
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
}
