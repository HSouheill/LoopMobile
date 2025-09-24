// lib/services/agent_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../widgets/recommended_agents_widget.dart'; // Updated import path
import '../environment.dart';

class AgentService {
  // Base URL from your Environment file
  static const String baseUrl = Environment.apiUrl;
  
  // Fetch agents with optional filtering and sorting
  static Future<List<Agent>> getAgents([Map<String, String>? queryParams]) async {
    try {
      // Build query string
      String queryString = '';
      if (queryParams != null && queryParams.isNotEmpty) {
        queryString = '?' + queryParams.entries
            .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
            .join('&');
      }
      
      final url = Uri.parse('${baseUrl}agents-routes/get-all-agents$queryString');
      
      // Debug print the URL being called
      print('DEBUG: Calling URL: $url');
      
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers like authentication if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      // Debug print the response
      print('DEBUG: Response status: ${response.statusCode}');
      print('DEBUG: Response body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Debug print the parsed data structure
        print('DEBUG: Parsed data keys: ${data.keys}');
        
        // Try multiple possible data structures
        List<dynamic> agentsJson = [];
        if (data.containsKey('users')) {
          agentsJson = data['users'] as List<dynamic>;
        } else if (data.containsKey('agents')) {
          agentsJson = data['agents'] as List<dynamic>;
        } else if (data.containsKey('data')) {
          agentsJson = data['data'] as List<dynamic>;
        } else if (data.containsKey('result')) {
          agentsJson = data['result'] as List<dynamic>;
        } else {
          // If none of the expected keys exist, print available keys
          print('DEBUG: Available keys in response: ${data.keys}');
          throw Exception('Unexpected response structure. Available keys: ${data.keys}');
        }
        
        print('DEBUG: Found ${agentsJson.length} agents in response');
        
        // Convert to Agent objects
        final agents = agentsJson.map((json) {
          try {
            return Agent.fromJson(json);
          } catch (e) {
            print('DEBUG: Error parsing agent: $json, Error: $e');
            rethrow;
          }
        }).toList();
        
        print('DEBUG: Successfully parsed ${agents.length} agents');
        return agents;
        
      } else {
        throw Exception('Failed to load agents: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('DEBUG: Exception in getAgents: $e');
      throw Exception('Network error: $e');
    }
  }

  // Get featured agents
  static Future<List<Agent>> getFeaturedAgents({String sort = 'featured', int? limit}) async {
    final params = <String, String>{'isFeatured': 'true', 'sort': sort};
    if (limit != null) {
      params['limit'] = limit.toString();
    }
    return getAgents(params);
  }

  // Get top rated agents
  static Future<List<Agent>> getTopRatedAgents({String sort = 'featured'}) async {
    return getAgents({'sort': sort, 'minRating': '4.5'});
  }

  // Get personalized agents
  static Future<List<Agent>> getPersonalizedAgents({String sort = 'featured'}) async {
    return getAgents({'sort': sort, 'personalized': 'true'});
  }

  // Get newest agents
  static Future<List<Agent>> getNewestAgents() async {
    return getAgents({'sort': 'newest'});
  }
}