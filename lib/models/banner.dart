// lib/models/banner.dart
import '../environment.dart';

class Banner {
  final String id;
  final int bannerNumber;
  final List<String> images;
  final DateTime createdAt;
  final DateTime updatedAt;

  Banner({
    required this.id,
    required this.bannerNumber,
    required this.images,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Banner.fromJson(Map<String, dynamic> json) {
    return Banner(
      id: json['_id'] ?? '',
      bannerNumber: json['bannerNumber'] ?? 0,
      images: (json['images'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }

  // Get full image URLs
  List<String> get imageUrls {
    return images.map((image) {
      if (image.startsWith('http://') || image.startsWith('https://')) {
        return image;
      }
      return '${Environment.apiUrl}assets/$image';
    }).toList();
  }
}

