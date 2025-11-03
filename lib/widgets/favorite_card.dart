import 'package:flutter/material.dart';
import '../models/favorite.dart';
import '../environment.dart';

class FavoriteCard extends StatelessWidget {
  final Favorite favorite;
  final VoidCallback? onTap;
  final VoidCallback? onRemove;

  const FavoriteCard({
    super.key,
    required this.favorite,
    this.onTap,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final details = favorite.objectDetails;
    final imageUrl = _getImageUrl(details.displayImage);
    
    return Card(
      margin: EdgeInsets.zero,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image section
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
              child: Container(
                height: 120,
                width: double.infinity,
                color: Colors.grey[200],
                child: _buildImage(imageUrl, details.itemType),
              ),
            ),
            // Content section
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Title and type
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          details.displayTitle,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getTypeColor(details.itemType),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          details.itemType,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  // Description
                  if (details.displayDescription.isNotEmpty)
                    Text(
                      details.displayDescription,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  const SizedBox(height: 8),
                  // Price or location
                  Row(
                    children: [
                      if (details.price != null) ...[
                        Text(
                          '\$${details.price!.toStringAsFixed(0)}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 8),
                      ],
                      if (details.displayLocation.isNotEmpty)
                        Expanded(
                          child: Text(
                            details.displayLocation,
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Remove button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed: onRemove,
                        icon: const Icon(
                          Icons.favorite,
                          color: Colors.red,
                          size: 20,
                        ),
                        tooltip: 'Remove from favorites',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getImageUrl(String? image) {
    if (image == null || image.isEmpty) return '';
    
    // If it's already a full URL, return as is
    if (image.startsWith('http')) {
      return image;
    }
    
    // Skip invalid image names
    if (image == 'url' || image == 'null' || image == 'undefined') {
      return '';
    }
    
    // Otherwise, construct the URL with backend URL + /assets + /image
    return '${Environment.apiUrl}assets/$image';
  }

  Widget _buildImage(String imageUrl, String itemType) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder(itemType);
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) {
        // Log the error for debugging but don't show it to user
        print('Image load error for $imageUrl: $error');
        return _buildPlaceholder(itemType);
      },
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Center(
          child: CircularProgressIndicator(
            value: loadingProgress.expectedTotalBytes != null
                ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                : null,
          ),
        );
      },
      // Add cache width and height for better performance
      cacheWidth: 200,
      cacheHeight: 150,
    );
  }

  Widget _buildPlaceholder(String itemType) {
    IconData iconData;
    Color iconColor;

    switch (itemType.toLowerCase()) {
      case 'user':
        iconData = Icons.person;
        iconColor = Colors.blue;
        break;
      case 'listing':
        iconData = Icons.home;
        iconColor = Colors.green;
        break;
      case 'job':
        iconData = Icons.work;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.favorite;
        iconColor = Colors.grey;
    }

    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          iconData,
          size: 48,
          color: iconColor.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Color _getTypeColor(String itemType) {
    switch (itemType.toLowerCase()) {
      case 'user':
        return Colors.blue;
      case 'listing':
        return Colors.green;
      case 'job':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}
