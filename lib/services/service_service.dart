// Enhanced services/service_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';

class ServiceService {
  static final String baseUrl = '${Environment.apiUrl}agents-routes';
  
  static Future<ServicesResponse> getFeaturedServices({int limit = 3}) async {
    try {
      final url = Uri.parse('$baseUrl/get-all-services?isFeatured=true&limit=$limit&sort=date_desc');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServicesResponse.fromJson(data);
      } else {
        throw Exception('Failed to load featured services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching featured services: $e');
    }
  }
  
  static Future<ServicesResponse> getTopRatedServices({int limit = 3}) async {
    try {
      final url = Uri.parse('$baseUrl/get-all-services?topRated=true&limit=$limit&sort=rating_desc');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServicesResponse.fromJson(data);
      } else {
        throw Exception('Failed to load top rated services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching top rated services: $e');
    }
  }
  
  static Future<ServicesResponse> getServicesByType({
    required String type,
    int limit = 3,
    String sort = 'date_desc',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/get-all-services?type=$type&limit=$limit&sort=$sort');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServicesResponse.fromJson(data);
      } else {
        throw Exception('Failed to load $type services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching $type services: $e');
    }
  }
  
  static Future<ServicesResponse> getAllServices({
    int page = 1,
    int limit = 10,
    bool? isFeatured,
    bool? topRated,
    String? type,
    String? location,
    String? sort = 'date_desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (sort != null) 'sort': sort,
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
        if (topRated != null) 'topRated': topRated.toString(),
        if (type != null) 'type': type,
        if (location != null) 'location': location,
      };
      
      final uri = Uri.parse('$baseUrl/get-all-services').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServicesResponse.fromJson(data);
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching services: $e');
    }
  }
}

enum ServiceCategory {
  featured,
  topRated,
  companies,
  individual,
}

extension ServiceCategoryExtension on ServiceCategory {
  String get displayName {
    switch (this) {
      case ServiceCategory.featured:
        return 'Featured Services';
      case ServiceCategory.topRated:
        return 'Top Rated Services';
      case ServiceCategory.companies:
        return 'Company Services';
      case ServiceCategory.individual:
        return 'Individual Services';
    }
  }
  
  String? get apiType {
    switch (this) {
      case ServiceCategory.featured:
        return null; // Handled by isFeatured parameter
      case ServiceCategory.topRated:
        return null; // Handled by topRated parameter
      case ServiceCategory.companies:
        return 'company';
      case ServiceCategory.individual:
        return 'individual';
    }
  }
  
  String get routeName {
    switch (this) {
      case ServiceCategory.featured:
        return '/featured-services';
      case ServiceCategory.topRated:
        return '/top-rated-services';
      case ServiceCategory.companies:
        return '/company-services';
      case ServiceCategory.individual:
        return '/individual-services';
    }
  }
}

class ServicesResponse {
  final List<Service> services;
  final ServiceMeta meta;
  
  ServicesResponse({
    required this.services,
    required this.meta,
  });
  
  factory ServicesResponse.fromJson(Map<String, dynamic> json) {
    return ServicesResponse(
      services: (json['services'] as List)
          .map((service) => Service.fromJson(service))
          .toList(),
      meta: ServiceMeta.fromJson(json['meta'] ?? {}),
    );
  }
}

class ServiceMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;
  
  ServiceMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
  
  factory ServiceMeta.fromJson(Map<String, dynamic> json) {
    return ServiceMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
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
  final double averageRating;
  final int reviewCount;
  
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
    required this.averageRating,
    required this.reviewCount,
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
      averageRating: (json['averageRating'] ?? 0.0).toDouble(),
      reviewCount: (json['reviewCount'] ?? 0).toInt(),
    );
  }

  // Convert Service to Agent format for compatibility with RecommendedAgentsWidget
  Map<String, dynamic> toAgentJson() {
    return {
      'imageUrl': image,
      'name': title,
      'propertyCount': 0, // Services don't have property count
      'location': location,
      'rating': averageRating,
      'reviewCount': reviewCount,
      'customText': subtitle,
    };
  }
}
