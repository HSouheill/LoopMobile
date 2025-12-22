// lib/widgets/banner_placeholder_widget.dart
import 'package:flutter/material.dart';

class BannerPlaceholderWidget extends StatelessWidget {
  final double height;

  const BannerPlaceholderWidget({
    super.key,
    this.height = 200.0,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: Colors.grey[200], // Light gray
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Center(
          child: Icon(
            Icons.home,
            size: 48,
            color: Colors.grey[500],
          ),
        ),
      ),
    );
  }
}

