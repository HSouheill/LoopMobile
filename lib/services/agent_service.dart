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
      print('DEBUG: Fetching agents from URL: $url');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      print('DEBUG: Response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: Response data keys: ${data.keys.toList()}');
        
        if (data['users'] != null && data['users'].isNotEmpty) {
          print('DEBUG: Found ${data['users'].length} agents');
          // Find the specific agent by ID
          try {
            final agentData = data['users'].firstWhere(
              (agent) => agent['_id'] == agentId,
            );
            print('DEBUG: Found agent with ID: $agentId');
            return AgentWithListingsAndReviews.fromJson(agentData);
          } catch (e) {
            print('DEBUG: Agent not found in list, trying direct approach');
            // If agent not found in the list, try a direct API call
            return await _getAgentDirectly(agentId);
          }
        } else {
          throw Exception('No agents found in response');
        }
      } else {
        print('DEBUG: API call failed with status: ${response.statusCode}');
        print('DEBUG: Response body: ${response.body}');
        throw Exception('Failed to load agent: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error in main call: $e');
      // If the general call fails, try direct approach
      try {
        return await _getAgentDirectly(agentId);
      } catch (directError) {
        print('DEBUG: Direct call also failed: $directError');
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
      print('DEBUG: Fetching my agents from URL: $url');
      
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );
      
      print('DEBUG: My agents response status: ${response.statusCode}');
      
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        print('DEBUG: My agents response data: $data');
        return data;
      } else {
        print('DEBUG: My agents API call failed with status: ${response.statusCode}');
        print('DEBUG: My agents response body: ${response.body}');
        throw Exception('Failed to load my agents: ${response.statusCode}');
      }
    } catch (e) {
      print('DEBUG: Error fetching my agents: $e');
      throw Exception('Error fetching my agents: $e');
    }
  }
}
