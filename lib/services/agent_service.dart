import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/review.dart';
import 'auth_service.dart';

class AgentService {
  static final String baseUrl = '${Environment.apiUrl}agents-routes';
  
  static Future<AgentWithListingsAndReviews> getAgentWithReviewsAndListings(String agentId) async {
    try {
      // First try to get all agents and find the specific one
      final url = Uri.parse('$baseUrl/get-all-agents?withReviews=true&withListings=true&limit=100&page=1');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        if (data['users'] != null && data['users'].isNotEmpty) {
          // Find the specific agent by ID
          try {
            final agentData = data['users'].firstWhere(
              (agent) => agent['_id'] == agentId,
            );
            return AgentWithListingsAndReviews.fromJson(agentData);
          } catch (e) {
            // If agent not found in the list, try a direct API call
            return await _getAgentDirectly(agentId);
          }
        } else {
          throw Exception('No agents found in response');
        }
      } else {
        throw Exception('Failed to load agent: ${response.statusCode}');
      }
    } catch (e) {
      // If the general call fails, try direct approach
      try {
        return await _getAgentDirectly(agentId);
      } catch (directError) {
        throw Exception('Error fetching agent: $e');
      }
    }
  }

  static Future<AgentWithListingsAndReviews> _getAgentDirectly(String agentId) async {
    try {
      // Try direct agent endpoint if it exists
      final url = Uri.parse('${Environment.apiUrl}users/$agentId?withReviews=true&withListings=true');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['users'] != null && data['users'].isNotEmpty) {
          return AgentWithListingsAndReviews.fromJson(data['users'][0]);
        } else if (data['_id'] != null) {
          // If it's a single agent object
          return AgentWithListingsAndReviews.fromJson(data);
        } else {
          throw Exception('No agent data found');
        }
      } else {
        throw Exception('Failed to load agent directly: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching agent directly: $e');
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
