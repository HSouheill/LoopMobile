import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../screens/search/search_results_page.dart';

class CategoriesOnlyWidget extends StatelessWidget {
  const CategoriesOnlyWidget({super.key});

  void _navigateToCategory(BuildContext context, String category) {
    // Automatically trigger search with the selected category filter
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SearchResultsPage(
          initialCategory: category,
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
      onTap: () => _navigateToCategory(context, filterValue),
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
