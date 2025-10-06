import 'review.dart';
import '../environment.dart';

class ServiceProvider {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String? companyName;
  final String? userProfileImage;
  final String country;
  final String governance;
  final String district;
  final String city;
  final bool isFeatured;
  final DateTime createdAt;
  final String referralCode;
  final double averageRating;
  final int propertyCount;
  final int reviewCount;
  final List<Service> services;
  final List<Review> reviews;

  ServiceProvider({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.companyName,
    this.userProfileImage,
    required this.country,
    required this.governance,
    required this.district,
    required this.city,
    required this.isFeatured,
    required this.createdAt,
    required this.referralCode,
    required this.averageRating,
    required this.propertyCount,
    required this.reviewCount,
    required this.services,
    this.reviews = const [],
  });

  factory ServiceProvider.fromJson(Map<String, dynamic> json) {
    return ServiceProvider(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      companyName: json['companyName']?.toString(),
      userProfileImage: json['profileImage']?.toString(),
      country: json['country']?.toString() ?? '',
      governance: json['governance']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 'true',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      referralCode: json['referralCode']?.toString() ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      propertyCount: (json['propertyCount'] ?? 0).toInt(),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((service) => Service.fromJson(service))
          .toList(),
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromJson(review))
          .toList(),
    );
  }

  // Get display name (company name for companies, full name for individuals)
  String get displayName {
    if (role == 'service-provider-company' && companyName != null && companyName!.isNotEmpty) {
      return companyName!;
    }
    return '$firstName $lastName';
  }

  // Get location string
  String get location {
    return '$city, $country';
  }

  // Get the latest service for subtitle
  String get latestServiceTitle {
    if (services.isEmpty) return 'No services available';
    return services.first.title;
  }

  // Get subtitle with "others..." if there are more services
  String get subtitle {
    if (services.isEmpty) return 'No services available';
    if (services.length == 1) return services.first.title;
    return '${services.first.title} and ${services.length - 1} others...';
  }

  // Get profile image (using user profileImage first, then first service image as fallback)
  String get profileImage {
    // First priority: user's profileImage
    if (userProfileImage != null && userProfileImage!.isNotEmpty) {
      // If it's already a full URL, return as is
      if (userProfileImage!.startsWith('http://') || userProfileImage!.startsWith('https://')) {
        return userProfileImage!;
      }
      // Build full URL with profileImage
      return '${Environment.apiUrl}assets/$userProfileImage';
    }
    
    // Second priority: first service image
    if (services.isNotEmpty && services.first.image.isNotEmpty) {
      final image = services.first.image;
      // If it's already a full URL, return as is
      if (image.startsWith('http://') || image.startsWith('https://')) {
        return image;
      }
      // Build full URL
      return '${Environment.apiUrl}assets/$image';
    }
    
    return 'https://via.placeholder.com/300x200?text=No+Image';
  }

  // Convert to Agent format for compatibility with existing widgets
  Map<String, dynamic> toAgentJson() {
    return {
      'imageUrl': profileImage,
      'name': displayName,
      'propertyCount': propertyCount,
      'location': location,
      'rating': averageRating,
      'reviewCount': reviewCount,
      'customText': subtitle,
    };
  }
}

class Service {
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

  Service({
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
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['_id']?.toString() ?? '',
      title: json['title']?.toString() ?? 'Untitled Service',
      subtitle: json['subtitle']?.toString() ?? '',
      location: json['location']?.toString() ?? 'Unknown Location',
      image: json['image']?.toString() ?? 'https://via.placeholder.com/300x200?text=No+Image',
      email: json['email']?.toString() ?? '',
      portfolioLink: json['portfolioLink']?.toString() ?? '',
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 'true',
      type: json['type']?.toString() ?? 'individual',
      owner: json['owner']?.toString() ?? '',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: DateTime.tryParse(json['updatedAt']?.toString() ?? '') ?? DateTime.now(),
      slug: json['slug']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
    );
  }
}

class ServiceProvidersResponse {
  final List<ServiceProvider> users;
  final ServiceProviderMeta meta;

  ServiceProvidersResponse({
    required this.users,
    required this.meta,
  });

  factory ServiceProvidersResponse.fromJson(Map<String, dynamic> json) {
    return ServiceProvidersResponse(
      users: (json['users'] as List<dynamic>? ?? [])
          .map((user) => ServiceProvider.fromJson(user))
          .toList(),
      meta: ServiceProviderMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class ServiceProviderMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;

  ServiceProviderMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory ServiceProviderMeta.fromJson(Map<String, dynamic> json) {
    return ServiceProviderMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }
}

class ServiceProviderWithReviews {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String role;
  final String? companyName;
  final String? userProfileImage;
  final String country;
  final String governance;
  final String district;
  final String city;
  final bool isFeatured;
  final DateTime createdAt;
  final String referralCode;
  final double averageRating;
  final int propertyCount;
  final int reviewCount;
  final List<Service> services;
  final List<Review> reviews;

  ServiceProviderWithReviews({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    required this.role,
    this.companyName,
    this.userProfileImage,
    required this.country,
    required this.governance,
    required this.district,
    required this.city,
    required this.isFeatured,
    required this.createdAt,
    required this.referralCode,
    required this.averageRating,
    required this.propertyCount,
    required this.reviewCount,
    required this.services,
    required this.reviews,
  });

  factory ServiceProviderWithReviews.fromJson(Map<String, dynamic> json) {
   
    final reviews = (json['reviews'] as List<dynamic>? ?? [])
        .map((review) => Review.fromJson(review))
        .toList();
     
    return ServiceProviderWithReviews(
      id: json['_id']?.toString() ?? '',
      firstName: json['firstName']?.toString() ?? '',
      lastName: json['lastName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      role: json['role']?.toString() ?? '',
      companyName: json['companyName']?.toString(),
      userProfileImage: json['profileImage']?.toString(),
      country: json['country']?.toString() ?? '',
      governance: json['governance']?.toString() ?? '',
      district: json['district']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      isFeatured: json['isFeatured'] == true || json['isFeatured'] == 'true',
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ?? DateTime.now(),
      referralCode: json['referralCode']?.toString() ?? '',
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      propertyCount: (json['propertyCount'] ?? 0).toInt(),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
      services: (json['services'] as List<dynamic>? ?? [])
          .map((service) => Service.fromJson(service))
          .toList(),
      reviews: reviews,
    );
  }

  // Get display name (company name for companies, full name for individuals)
  String get displayName {
    if (role == 'service-provider-company' && companyName != null && companyName!.isNotEmpty) {
      return companyName!;
    }
    return '$firstName $lastName';
  }

  // Get location string
  String get location {
    return '$city, $country';
  }

  // Get the latest service for subtitle
  String get latestServiceTitle {
    if (services.isEmpty) return 'No services available';
    return services.first.title;
  }

  // Get subtitle with "others..." if there are more services
  String get subtitle {
    if (services.isEmpty) return 'No services available';
    if (services.length == 1) return services.first.title;
    return '${services.first.title} and ${services.length - 1} others...';
  }

  // Get profile image (using user profileImage first, then first service image as fallback)
  String get profileImage {
    // First priority: user's profileImage
    if (userProfileImage != null && userProfileImage!.isNotEmpty) {
      // If it's already a full URL, return as is
      if (userProfileImage!.startsWith('http://') || userProfileImage!.startsWith('https://')) {
        return userProfileImage!;
      }
      // Build full URL with profileImage
      return '${Environment.apiUrl}assets/$userProfileImage';
    }
    
    // Second priority: first service image
    if (services.isNotEmpty && services.first.image.isNotEmpty) {
      final image = services.first.image;
      // If it's already a full URL, return as is
      if (image.startsWith('http://') || image.startsWith('https://')) {
        return image;
      }
      // Build full URL
      return '${Environment.apiUrl}assets/$image';
    }
    
    return 'https://via.placeholder.com/300x200?text=No+Image';
  }
}
