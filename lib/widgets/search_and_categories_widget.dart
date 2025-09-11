import 'package:flutter/material.dart';

class SearchAndCategoriesWidget extends StatelessWidget {
  const SearchAndCategoriesWidget({super.key});

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
                const Icon(Icons.search, color: Colors.blue),
                const SizedBox(width: 8.0),
                Expanded(
                  child: TextField(
                    cursorColor: Colors.blue,
                    decoration: const InputDecoration(
                      hintText: 'Search...',
                      // remove all borders
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      // keep background transparent
                      filled: true,
                      fillColor: Colors.transparent,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 12.0),
                      // placeholder color same as icon
                      hintStyle: TextStyle(color: Colors.blue),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune, color: Colors.black87),
                  onPressed: () {
                    // Handle filter button press
                  },
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
                  Icons.house_siding, 'Chalets', Colors.blue, Colors.white),
              _buildCategoryIcon(
                  Icons.villa, 'Villas', Colors.blue, Colors.white),
              _buildCategoryIcon(
                  Icons.apartment, 'Apartments', Colors.blue, Colors.white),
              _buildCategoryIcon(
                  Icons.landscape, 'Land', Colors.blue, Colors.white),
              _buildCategoryIcon(
                  Icons.business, 'Commercial', Colors.blue, Colors.white),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryIcon(
      IconData icon, String label, Color backgroundColor, Color iconColor) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12.0),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: backgroundColor,
          ),
          child: Icon(icon, color: iconColor, size: 30),
        ),
        const SizedBox(height: 8.0),
        Text(
          label,
          style: const TextStyle(fontSize: 12.0, color: Colors.black87),
        ),
      ],
    );
  }
}
