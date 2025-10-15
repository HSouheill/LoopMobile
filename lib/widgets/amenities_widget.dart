import 'package:flutter/material.dart';

class AmenitiesWidget extends StatelessWidget {
  final List<String>? amenities;
  final String? title;
  final EdgeInsets? padding;

  const AmenitiesWidget({
    super.key,
    this.amenities,
    this.title,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    if (amenities == null || amenities!.isEmpty) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: padding ?? EdgeInsets.zero,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title!,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: amenities!.map((amenity) => 
              _buildAmenityChip(amenity)
            ).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAmenityChip(String amenity) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFF4CAF50).withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4CAF50)),
      ),
      child: Text(
        _formatAmenityName(amenity),
        style: const TextStyle(
          color: Color(0xFF4CAF50),
          fontWeight: FontWeight.w500,
          fontSize: 12,
        ),
      ),
    );
  }

  String _formatAmenityName(String amenity) {
    String formatted = amenity.replaceAllMapped(
      RegExp(r'([A-Z])'),
      (match) => ' ${match.group(1)}',
    );
    
    // Capitalize first letter and handle special cases
    formatted = formatted.trim();
    if (formatted.isNotEmpty) {
      formatted = formatted[0].toUpperCase() + formatted.substring(1);
    }
    
    // Handle special cases
    formatted = formatted.replaceAll('24 7', '24/7');
    formatted = formatted.replaceAll('A C', 'AC');
    
    return formatted;
  }
}
