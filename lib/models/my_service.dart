import '../environment.dart';

class MyService {
  final String id;
  final String title;
  final String subtitle;
  final String location;
  final String image;
  final String email;
  final String portfolioLink;
  final bool isFeatured;
  final String type;
  final String owner;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String slug;
  final String userId;
  final double averageRating;
  final int reviewCount;
  final bool locked;

  MyService({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.image,
    required this.email,
    required this.portfolioLink,
    required this.isFeatured,
    required this.type,
    required this.owner,
    required this.createdAt,
    required this.updatedAt,
    required this.slug,
    required this.userId,
    required this.averageRating,
    required this.reviewCount,
    this.locked = false,
  });

  factory MyService.fromJson(Map<String, dynamic> json) {
    return MyService(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Service',
      subtitle: json['subtitle']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Unknown Location',
      image: json['image']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      portfolioLink: json['portfolioLink']?.toString() ?? '',
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 'true',
      type: json['type']?.toString() ?? 'individual',
      owner: json['owner']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      slug: json['slug']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
      locked: json['locked'] == true || json['locked'] == 'true',
    );
  }

  // Get the full image URL with proper handling
  String get imageUrl {
    if (image.isEmpty) {
      return 'https://via.placeholder.com/300x200?text=No+Image';
    }
    
    // If it's already a full URL, return as is
    if (image.startsWith('http://') || image.startsWith('https://')) {
      return image;
    }
    
    // Build full URL with environment base URL
    return '${Environment.apiUrl}assets/$image';
  }
}

class MyServicesResponse {
  final List<MyService> services;
  final MyServicesMeta meta;

  MyServicesResponse({
    required this.services,
    required this.meta,
  });

  factory MyServicesResponse.fromJson(Map<String, dynamic> json) {
    return MyServicesResponse(
      services: (json['services'] as List<dynamic>? ?? [])
          .map((service) => MyService.fromJson(service))
          .toList(),
      meta: MyServicesMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class MyServicesMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  MyServicesMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory MyServicesMeta.fromJson(Map<String, dynamic> json) {
    return MyServicesMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }
}
