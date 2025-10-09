// Enhanced services/service_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/service_provider.dart';
import '../models/my_service.dart';
import 'auth_service.dart';

class ServiceService {
  static final String baseUrl = '${Environment.apiUrl}agents-routes';
  
  static Future<ServiceProvidersResponse> getFeaturedServiceProviders({int limit = 3}) async {
    try {
      final url = Uri.parse('$baseUrl/get-all-service-providers?isFeatured=true&withServices=true&limit=$limit&sort=date_desc');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
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
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
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
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
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
      final response = await http.get(
        uri,
        headers: AuthService.getAuthHeaders(),
      );
      
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

  static Future<ServiceProviderWithReviews> getServiceProviderWithReviews(String serviceProviderId) async {
    try {
      // First try to get all service providers and find the specific one
      final url = Uri.parse('$baseUrl/get-all-service-providers?withReviews=true&withServices=true&limit=100&page=1');
     
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['users'] != null && data['users'].isNotEmpty) {
          
          // Find the specific service provider by ID
          try {
            final serviceProviderData = data['users'].firstWhere(
              (provider) => provider['_id'] == serviceProviderId,
            );
        
            return ServiceProviderWithReviews.fromJson(serviceProviderData);
          } catch (e) {
          
            // If service provider not found in the list, try a direct API call
            return await _getServiceProviderDirectly(serviceProviderId);
          }
        } else {
          throw Exception('No service providers found in response');
        }
      } else {
     
        throw Exception('Failed to load service provider: ${response.statusCode}');
      }
    } catch (e) {
    
      // If the general call fails, try direct approach
      try {
        return await _getServiceProviderDirectly(serviceProviderId);
      } catch (directError) {
        throw Exception('Error fetching service provider: $e');
      }
    }
  }

  static Future<ServiceProviderWithReviews> _getServiceProviderDirectly(String serviceProviderId) async {
    try {
      // Try direct service provider endpoint if it exists
      final url = Uri.parse('${Environment.apiUrl}users/$serviceProviderId?withReviews=true&withServices=true');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['users'] != null && data['users'].isNotEmpty) {
          return ServiceProviderWithReviews.fromJson(data['users'][0]);
        } else if (data['_id'] != null) {
          // If it's a single service provider object
          return ServiceProviderWithReviews.fromJson(data);
        } else {
          throw Exception('No service provider data found');
        }
      } else {
        throw Exception('Failed to load service provider directly: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching service provider directly: $e');
    }
  }

  // Get my services with pagination
  static Future<MyServicesResponse> getMyServices({
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      
      final uri = Uri.parse('$baseUrl/my-services').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MyServicesResponse.fromJson(data);
      } else {
        throw Exception('Failed to load my services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching my services: $e');
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
