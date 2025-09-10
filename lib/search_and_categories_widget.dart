import 'package:flutter/material.dart';

class SearchAndCategoriesWidget extends StatelessWidget {
  const SearchAndCategoriesWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Column(
        children: [
          // Search Bar
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.2),
                  spreadRadius: 1,
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: Colors.blue),
                const SizedBox(width: 8.0),
                const Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Search...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.black54),
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
          const SizedBox(height: 16.0),
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