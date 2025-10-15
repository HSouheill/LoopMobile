import 'package:flutter/material.dart';
import '../services/listing_service.dart';
import 'listing_image_widget.dart';
import 'amenities_widget.dart';

class ListingDetailsModal extends StatelessWidget {
  final PropertyListing listing;
  final VoidCallback? onClose;

  const ListingDetailsModal({
    super.key,
    required this.listing,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SingleChildScrollView(
          controller: scrollController,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Listing image
                ListingImageWidget(
                  imageUrl: listing.imageUrl,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  borderRadius: BorderRadius.circular(12),
                  placeholderIcon: Icons.home,
                  placeholderIconSize: 50,
                ),
                const SizedBox(height: 20),
                
                // Title and price
                Text(
                  listing.title,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  listing.price,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0048FF),
                  ),
                ),
                const SizedBox(height: 20),
                
                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text(
                      listing.location,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                
                // Description
                if (listing.description != null) ...[
                  const Text(
                    'Description',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    listing.description!,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Property details
                if (_hasPropertyDetails()) ...[
                  const Text(
                    'Property Details',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: _buildPropertyDetailChips(),
                  ),
                  const SizedBox(height: 20),
                ],
                
                // Amenities
                AmenitiesWidget(
                  amenities: listing.amenityList,
                  title: 'Amenities',
                  padding: const EdgeInsets.only(bottom: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _hasPropertyDetails() {
    return listing.bedrooms != null || 
           listing.bathrooms != null || 
           listing.size != null ||
           listing.type != null ||
           listing.floor != null ||
           listing.condition != null ||
           listing.buildingAge != null ||
           listing.papers != null ||
           listing.listingFor != null ||
           listing.status != null;
  }

  List<Widget> _buildPropertyDetailChips() {
    List<Widget> chips = [];
    
    if (listing.type != null) {
      chips.add(_buildDetailChip('Type: ${listing.type}'));
    }
    if (listing.bedrooms != null) {
      chips.add(_buildDetailChip('${listing.bedrooms} Bedrooms'));
    }
    if (listing.bathrooms != null) {
      chips.add(_buildDetailChip('${listing.bathrooms} Bathrooms'));
    }
    if (listing.size != null) {
      chips.add(_buildDetailChip('${listing.size} sq ft'));
    }
    if (listing.floor != null) {
      chips.add(_buildDetailChip('Floor: ${listing.floor}'));
    }
    if (listing.condition != null) {
      chips.add(_buildDetailChip('Condition: ${listing.condition}'));
    }
    if (listing.buildingAge != null) {
      chips.add(_buildDetailChip('Age: ${listing.buildingAge} years'));
    }
    if (listing.papers != null) {
      chips.add(_buildDetailChip('Papers: ${listing.papers}'));
    }
    if (listing.listingFor != null) {
      chips.add(_buildDetailChip('For: ${listing.listingFor}'));
    }
    if (listing.status != null) {
      chips.add(_buildDetailChip('Status: ${listing.status}'));
    }
    
    return chips;
  }

  Widget _buildDetailChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0048FF).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFF0048FF)),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: Color(0xFF0048FF),
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// Helper function to show the modal
void showListingDetailsModal(BuildContext context, PropertyListing listing) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => ListingDetailsModal(listing: listing),
  );
}
