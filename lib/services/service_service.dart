// Enhanced services/service_service.dart
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../environment.dart';
import '../models/service_provider.dart';
import '../models/my_service.dart';
import 'auth_service.dart';

class ServiceService {
  static final String baseUrl = '${Environment.apiUrl}agents-routes';
  static final String usersBaseUrl = '${Environment.apiUrl}users';
  
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
      final url = Uri.parse('$baseUrl/get-all-service-providers?withServices=true&limit=$limit&sort=featured_first');
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
    String sort = 'featured_first',
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
    String? sort,
  }) async {
    try {
      // Use featured_first sort unless filtering by isFeatured (all would be featured)
      final effectiveSort = sort ?? (isFeatured == true ? 'date_desc' : 'featured_first');
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        'withServices': 'true',
        'sort': effectiveSort,
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
      // Fetch the single provider directly by id. The backend returns the
      // provider with their latest 3 (non-locked) services and latest 3 reviews
      // (and favorite status), so we don't over-fetch the whole provider list
      // and filter client-side.
      final url = Uri.parse(
          '$baseUrl/get-service-provider-by-id/$serviceProviderId?withReviews=true&withServices=true');

      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        // Endpoint shape: { user: {...} }. Fall back to a bare object just in case.
        final providerData = (data['user'] ?? data) as Map<String, dynamic>;
        if (providerData.isEmpty || providerData['_id'] == null) {
          throw Exception('No service provider data found in response');
        }
        return ServiceProviderWithReviews.fromJson(providerData);
      } else {
        throw Exception('Failed to load service provider: ${response.statusCode}');
      }
    } catch (e) {
      // If the by-id call fails, fall back to the legacy direct approach.
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

  // Get services for a specific agent (service provider) with pagination and filters
  static Future<MyServicesResponse> getServicesByAgentId({
    required String agentId,
    int page = 1,
    int limit = 20,
    String? sort,
    String? type,
    String? location,
    bool? isFeatured,
    String? q,
    DateTime? createdFrom,
    DateTime? createdTo,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (sort != null) 'sort': sort,
        if (type != null) 'type': type,
        if (location != null) 'location': location,
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
        if (q != null && q.isNotEmpty) 'q': q,
        if (createdFrom != null) 'createdFrom': createdFrom.toIso8601String(),
        if (createdTo != null) 'createdTo': createdTo.toIso8601String(),
      };

      final uri = Uri.parse('$baseUrl/agent-services/$agentId')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return MyServicesResponse.fromJson(data);
      } else {
        throw Exception('Failed to load agent services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agent services: $e');
    }
  }

  // Create a new service with optional image upload
  static Future<Map<String, dynamic>> createService(Map<String, dynamic> serviceData, {File? imageFile}) async {
    try {
      final url = Uri.parse('$baseUrl/add-service');
      
      http.Response response;
      
      if (imageFile != null) {
        // Create multipart request for image upload
        var request = http.MultipartRequest('POST', url);
        
        // Add authorization header
        request.headers.addAll({
          'Authorization': 'Bearer ${AuthService.token}',
        });
        
        // Add text fields
        serviceData.forEach((key, value) {
          if (value != null) {
            request.fields[key] = value.toString();
          }
        });
        
        // Add image file with proper content type detection
        String contentType = 'image/jpeg'; // Default
        String extension = imageFile.path.split('.').last.toLowerCase();
        
        switch (extension) {
          case 'png':
            contentType = 'image/png';
            break;
          case 'gif':
            contentType = 'image/gif';
            break;
          case 'webp':
            contentType = 'image/webp';
            break;
          case 'jpg':
          case 'jpeg':
          default:
            contentType = 'image/jpeg';
            break;
        }
        
        var multipartFile = await http.MultipartFile.fromPath(
          'image', // This should match the field name expected by multer
          imageFile.path,
          contentType: MediaType.parse(contentType),
        );
        request.files.add(multipartFile);
        
        // Send the request
        var streamedResponse = await request.send();
        response = await http.Response.fromStream(streamedResponse);
      } else {
        // Regular JSON request without image
        response = await http.post(
          url,
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${AuthService.token}',
          },
          body: jsonEncode(serviceData),
        );
      }

      if (response.statusCode == 201) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        // Try to parse error response and provide user-friendly message
        try {
          final errorData = json.decode(response.body);
          String userMessage = errorData['message'] ?? 'Failed to create service';
          String? errorKey;
          
          // Make error messages more user-friendly
          if (userMessage.contains('Title is required')) {
            userMessage = 'Please enter a service title';
            errorKey = 'pleaseEnterServiceTitle';
          } else if (userMessage.contains('Invalid email format')) {
            userMessage = 'Please enter a valid email address';
            errorKey = 'pleaseEnterValidEmail';
          } else if (userMessage.contains('portfolioLink is not a valid URL')) {
            userMessage = 'Please enter a valid portfolio URL';
            errorKey = 'pleaseEnterValidPortfolioUrl';
          } else if (userMessage.contains('Validation failed')) {
            userMessage = 'Please check your input and try again';
            errorKey = 'pleaseCheckInputAndTryAgain';
          } else {
            errorKey = 'failedToCreateService';
          }
          
          return {
            'success': false,
            'errorKey': errorKey,
            'error': userMessage,
            'statusCode': response.statusCode,
          };
        } catch (parseError) {
          return {
            'success': false,
            'errorKey': 'failedToCreateServiceTryAgain',
            'error': 'Failed to create service. Please try again.',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'errorKey': 'unableToConnectToServer',
        'error': 'Unable to connect to server. Please check your internet connection and try again.',
      };
    }
  }

  // Edit a service (only name and description)
  static Future<Map<String, dynamic>> editService(String serviceId, Map<String, dynamic> serviceData) async {
    try {
      final url = Uri.parse('$baseUrl/services/$serviceId');
      
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode(serviceData),
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        // Try to parse error response and provide user-friendly message
        try {
          final errorData = json.decode(response.body);
          String userMessage = errorData['message'] ?? 'Failed to update service';
          
          return {
            'success': false,
            'error': userMessage,
            'statusCode': response.statusCode,
          };
        } catch (parseError) {
          return {
            'success': false,
            'errorKey': 'failedToUpdateServiceTryAgain',
            'error': 'Failed to update service. Please try again.',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'errorKey': 'unableToConnectToServer',
        'error': 'Unable to connect to server. Please check your internet connection and try again.',
      };
    }
  }

  // Delete a service
  static Future<Map<String, dynamic>> deleteService(String serviceId) async {
    try {
      final url = Uri.parse('$baseUrl/services/$serviceId');
      
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer ${AuthService.token}',
        },
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        return {
          'success': true,
          'data': responseData,
        };
      } else {
        // Try to parse error response and provide user-friendly message
        try {
          final errorData = json.decode(response.body);
          String userMessage = errorData['message'] ?? 'Failed to delete service';
          
          return {
            'success': false,
            'error': userMessage,
            'statusCode': response.statusCode,
          };
        } catch (parseError) {
          return {
            'success': false,
            'errorKey': 'failedToDeleteServiceTryAgain',
            'error': 'Failed to delete service. Please try again.',
            'statusCode': response.statusCode,
          };
        }
      }
    } catch (e) {
      return {
        'success': false,
        'errorKey': 'unableToConnectToServer',
        'error': 'Unable to connect to server. Please check your internet connection and try again.',
      };
 }
  }
  // Search service providers
  static Future<ServiceProvidersResponse> searchServiceProviders({
    required String query,
    int page = 1,
    int limit = 20,
    String? sort,
    String? city,
    String? district,
    String? companyName,
    String? gender,
    int? minAge,
    int? maxAge,
    DateTime? createdFrom,
    DateTime? createdTo,
    bool? isFeatured,
    bool withServices = true,
    bool withReviews = false,
    String? providerType,
    String? role,
    String? categoryKey,
  }) async {
    try {
      // Use featured_first sort unless filtering by isFeatured (all would be featured)
      final effectiveSort = sort ?? (isFeatured == true ? 'date_desc' : 'featured_first');
      final queryParams = <String, String>{
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        'withServices': withServices.toString(),
        'withReviews': withReviews.toString(),
        'sort': effectiveSort,
        if (city != null) 'city': city,
        if (district != null) 'district': district,
        if (companyName != null) 'companyName': companyName,
        if (gender != null) 'gender': gender,
        if (minAge != null) 'minAge': minAge.toString(),
        if (maxAge != null) 'maxAge': maxAge.toString(),
        if (createdFrom != null) 'createdFrom': createdFrom.toIso8601String(),
        if (createdTo != null) 'createdTo': createdTo.toIso8601String(),
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
        if (role != null) 'role': role,
        if (role == null && providerType != null) 'providerType': providerType,
        if (categoryKey != null) 'categoryKey': categoryKey,
      };
      
      final uri = Uri.parse('$baseUrl/search-service-providers').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return ServiceProvidersResponse.fromJson(data);
      } else {
        throw Exception('Failed to search service providers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching service providers: $e');
    }
  }
}

enum ServiceCategory {
  featured,
  topRated,
  companies,
  individual,
  featuredCompanies,
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
      case ServiceCategory.featuredCompanies:
        return 'Featured Companies';
    }
  }
  
  String getDisplayNameLocalized(AppLocalizations? l10n) {
    if (l10n == null) return displayName;
    switch (this) {
      case ServiceCategory.featured:
        return l10n.featuredServices;
      case ServiceCategory.topRated:
        return l10n.topRatedServices;
      case ServiceCategory.companies:
        return l10n.companyServices;
      case ServiceCategory.individual:
        return l10n.individualServices;
      case ServiceCategory.featuredCompanies:
        return l10n.featuredCompanies;
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
      case ServiceCategory.featuredCompanies:
        return 'company';
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
      case ServiceCategory.featuredCompanies:
        return '/featured-company-services';
    }
  }
}
