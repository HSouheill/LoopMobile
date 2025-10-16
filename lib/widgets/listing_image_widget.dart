import 'package:flutter/material.dart';

class ListingImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final IconData placeholderIcon;
  final double placeholderIconSize;
  final Color placeholderColor;

  const ListingImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.placeholderIcon = Icons.home,
    this.placeholderIconSize = 50,
    this.placeholderColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return Container(
          width: width,
          height: height,
          color: Colors.grey[200],
          child: Center(
            child: CircularProgressIndicator(
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                  : null,
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).primaryColor,
              ),
            ),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: Colors.grey[200],
        child: Icon(
          placeholderIcon,
          size: placeholderIconSize,
          color: placeholderColor,
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: imageWidget,
      );
    }

    return imageWidget;
  }
}
