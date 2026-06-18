import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/review.dart';
import 'auth_service.dart';

class AgentService {
  static final String baseUrl = '${Environment.apiUrl}agents-routes';
  
  static Future<AgentWithListingsAndReviews> getAgentWithReviewsAndListings(String agentId) async {
    try {
      // Fetch the single agent directly by id. The backend returns the agent
      // with their latest 3 active+published listings and latest 3 reviews
      // (and favorite status), so we don't need to over-fetch the whole agent
      // list and filter client-side.
      final url = Uri.parse(
          '$baseUrl/get-agent-by-id/$agentId?withReviews=true&withListings=true');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode != 200) {
        throw Exception('Failed to load agent: ${response.statusCode}');
      }

      // The body should be JSON. Behind the prod nginx proxy a misconfig (or an
      // error page) can return HTML, which would make json.decode throw with a
      // confusing FormatException — guard against that with a clear message.
      dynamic data;
      try {
        data = json.decode(response.body);
      } on FormatException {
        throw Exception(
            'Server returned a non-JSON response while loading the agent.');
      }

      // Endpoint shape: { user: {...} }. Fall back to a bare object just in case.
      final raw = (data is Map && data['user'] != null) ? data['user'] : data;
      if (raw is! Map<String, dynamic> || raw['_id'] == null) {
        throw Exception('No agent data found in response');
      }
      return AgentWithListingsAndReviews.fromJson(raw);
    } catch (e) {
      throw Exception('Error fetching agent: $e');
    }
  }

  // Get agent by ID using the new endpoint
  static Future<Map<String, dynamic>> getAgentById(String agentId) async {
    try {
      final url = Uri.parse('$baseUrl/get-agent-by-id/$agentId?withReviews=true&withListings=true');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load agent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agent by ID: $e');
    }
  }

  // Get agent listings with pagination
  static Future<Map<String, dynamic>> getAgentListings({
    required String agentId,
    int page = 1,
    int limit = 10,
    String? sort,
    String? listingFor,
    String? city,
    String? type,
    double? minPrice,
    double? maxPrice,
    int? minBedrooms,
    int? maxBedrooms,
    int? minBathrooms,
    int? maxBathrooms,
    double? minSize,
    double? maxSize,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (sort != null) 'sort': sort,
        if (listingFor != null) 'listingFor': listingFor,
        if (city != null) 'city': city,
        if (type != null) 'type': type,
        if (minPrice != null) 'minPrice': minPrice.toString(),
        if (maxPrice != null) 'maxPrice': maxPrice.toString(),
        if (minBedrooms != null) 'minBedrooms': minBedrooms.toString(),
        if (maxBedrooms != null) 'maxBedrooms': maxBedrooms.toString(),
        if (minBathrooms != null) 'minBathrooms': minBathrooms.toString(),
        if (maxBathrooms != null) 'maxBathrooms': maxBathrooms.toString(),
        if (minSize != null) 'minSize': minSize.toString(),
        if (maxSize != null) 'maxSize': maxSize.toString(),
      };
      
      final url = Uri.parse('$baseUrl/agent-listings/$agentId').replace(queryParameters: queryParams);
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load agent listings: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agent listings: $e');
    }
  }

  // New method to fetch my agents
  static Future<Map<String, dynamic>> getMyAgents({int page = 1, int limit = 20}) async {
    try {
      final url = Uri.parse('$baseUrl/my-agents?page=$page&limit=$limit');
      
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to load my agents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching my agents: $e');
    }
  }

  // Add new agent method
  static Future<Map<String, dynamic>> addAgent({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String? companyName,
    String? description,
    String? DOB,
    String? gender,
    String? profileImage,
    String? country,
    String? governance,
    String? district,
    String? city,
    bool? isFeatured,
    String? portfolioLink,
    List<Map<String, String>>? socialLinks,
  }) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}agents-routes/add-agent');
      
      final body = {
        'firstName': firstName,
        'lastName': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        if (companyName != null) 'companyName': companyName,
        if (description != null) 'description': description,
        if (DOB != null) 'DOB': DOB,
        if (gender != null) 'gender': gender,
        if (profileImage != null) 'profileImage': profileImage,
        if (country != null) 'country': country,
        if (governance != null) 'governance': governance,
        if (district != null) 'district': district,
        if (city != null) 'city': city,
        if (isFeatured != null) 'isFeatured': isFeatured,
        if (portfolioLink != null) 'portfolioLink': portfolioLink,
        if (socialLinks != null) 'socialLinks': socialLinks,
      };
      
      final response = await http.post(
        url,
        headers: AuthService.getAuthHeaders(),
        body: json.encode(body),
      );
      
      if (response.statusCode == 201) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to add agent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error adding agent: $e');
    }
  }

  // Search agents using the backend search API
  static Future<Map<String, dynamic>> searchAgents({
    required String query,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/search-agents').replace(queryParameters: {
        'q': query,
        'page': page.toString(),
        'limit': limit.toString(),
        'sort': 'featured_first',
      });

      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        throw Exception('Failed to search agents: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching agents: $e');
    }
  }

  // Edit agent method
  static Future<Map<String, dynamic>> editAgent({
    required String agentId,
    String? firstName,
    String? lastName,
    String? email,
    String? phone,
    String? password,
    String? role,
    String? companyName,
    String? description,
    String? DOB,
    String? gender,
    String? profileImage,
    String? country,
    String? governance,
    String? district,
    String? city,
    bool? isFeatured,
    String? portfolioLink,
    List<Map<String, String>>? socialLinks,
  }) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}agents-routes/edit-agent/$agentId');
      
      final body = <String, dynamic>{};
      
      // Only include fields that are provided (not null)
      if (firstName != null) body['firstName'] = firstName;
      if (lastName != null) body['lastName'] = lastName;
      if (email != null) body['email'] = email;
      if (phone != null) body['phone'] = phone;
      if (password != null) body['password'] = password;
      if (role != null) body['role'] = role;
      if (companyName != null) body['companyName'] = companyName;
      if (description != null) body['description'] = description;
      if (DOB != null) body['DOB'] = DOB;
      if (gender != null) body['gender'] = gender;
      if (profileImage != null) body['profileImage'] = profileImage;
      if (country != null) body['country'] = country;
      if (governance != null) body['governance'] = governance;
      if (district != null) body['district'] = district;
      if (city != null) body['city'] = city;
      if (isFeatured != null) body['isFeatured'] = isFeatured;
      if (portfolioLink != null) body['portfolioLink'] = portfolioLink;
      if (socialLinks != null) body['socialLinks'] = socialLinks;
      
      final response = await http.put(
        url,
        headers: AuthService.getAuthHeaders(),
        body: json.encode(body),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to edit agent: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error editing agent: $e');
    }
  }
}
