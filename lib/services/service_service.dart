// Enhanced services/service_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/service_provider.dart';

class ServiceService {
  static final String baseUrl = '${Environment.apiUrl}agents-routes';
  
  static Future<ServiceProvidersResponse> getFeaturedServiceProviders({int limit = 3}) async {
    try {
      final url = Uri.parse('$baseUrl/get-all-service-providers?isFeatured=true&withServices=true&limit=$limit&sort=date_desc');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceProvidersResponse.fromJson(data);
      } else {
        throw Exception('Failed to load featured service providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching featured service providers: $e');
    }
  }
  
  static Future<ServiceProvidersResponse> getTopRatedServiceProviders({int limit = 3}) async {
    try {
      final url = Uri.parse('$baseUrl/get-all-service-providers?withServices=true&limit=$limit&sort=rating_desc');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceProvidersResponse.fromJson(data);
      } else {
        throw Exception('Failed to load top rated service providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching top rated service providers: $e');
    }
  }
  
  static Future<ServiceProvidersResponse> getServiceProvidersByType({
    required String providerType,
    int limit = 3,
    String sort = 'date_desc',
  }) async {
    try {
      final url = Uri.parse('$baseUrl/get-all-service-providers?providerType=$providerType&withServices=true&limit=$limit&sort=$sort');
      final response = await http.get(url);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceProvidersResponse.fromJson(data);
      } else {
        throw Exception('Failed to load $providerType service providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching $providerType service providers: $e');
    }
  }
  
  static Future<ServiceProvidersResponse> getAllServiceProviders({
    int page = 1,
    int limit = 10,
    bool? isFeatured,
    String? providerType,
    String? city,
    String? sort = 'date_desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'withServices': 'true',
        if (sort != null) 'sort': sort,
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
        if (providerType != null) 'providerType': providerType,
        if (city != null) 'city': city,
      };
      
      final uri = Uri.parse('$baseUrl/get-all-service-providers').replace(queryParameters: queryParams);
      final response = await http.get(uri);
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceProvidersResponse.fromJson(data);
      } else {
        throw Exception('Failed to load service providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching service providers: $e');
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
  
  String? get providerType {
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
