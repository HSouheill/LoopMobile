// lib/services/agent_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../recommended_agents_widget.dart'; // Updated import path
import '../../environment.dart';

class AgentService {
  // Base URL from your Environment file
  static const String baseUrl = Environment.apiUrl;

  // Fetch agents with optional filtering and sorting
  static Future<List<Agent>> getAgents(
      [Map<String, String>? queryParams]) async {
    try {
      // Build query string
      String queryString = '';
      if (queryParams != null && queryParams.isNotEmpty) {
        queryString = '?' +
            queryParams.entries
                .map((e) =>
                    '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
                .join('&');
      }

      final url =
          Uri.parse('${baseUrl}agents-routes/get-all-agents$queryString');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          // Add any additional headers like authentication if needed
          // 'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);

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
          throw Exception(
              'Unexpected response structure. Available keys: ${data.keys}');
        }

        // Convert to Agent objects
        final agents = agentsJson.map((json) {
          return Agent.fromJson(json);
        }).toList();

        return agents;
      } else {
        throw Exception(
            'Failed to load agents: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }


  // Get featured agents
  static Future<List<Agent>> getFeaturedAgents(
      {String sort = 'featured', int? limit}) async {
    final params = <String, String>{'isFeatured': 'true', 'sort': sort};
    if (limit != null) {
      params['limit'] = limit.toString();
    }
    return getAgents(params);
  }

  // Get top rated agents
  static Future<List<Agent>> getTopRatedAgents(
      {String sort = 'featured'}) async {
    return getAgents({'sort': sort, 'minRating': '4.5'});
  }

  // Get personalized agents
  static Future<List<Agent>> getPersonalizedAgents(
      {String sort = 'featured'}) async {
    return getAgents({'sort': sort, 'personalized': 'true'});
  }

  // Get newest agents
  static Future<List<Agent>> getNewestAgents() async {
    return getAgents({'sort': 'newest'});
  }

  // Get agents with pagination support
  static Future<AgentsResponse> getAllAgents({
    int page = 1,
    int limit = 10,
    bool? isFeatured,
    String? sort = 'featured',
    String? minRating,
    bool? personalized,
    String? agentType,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (sort != null) 'sort': sort,
        if (isFeatured != null) 'isFeatured': isFeatured.toString(),
        if (minRating != null) 'minRating': minRating,
        if (personalized != null) 'personalized': personalized.toString(),
        if (agentType != null) 'agentType': agentType,
      };

      final url = Uri.parse('${baseUrl}agents-routes/get-all-agents').replace(queryParameters: queryParams);

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        
        // Handle different response structures
        List<dynamic> agentsJson = [];
        Map<String, dynamic>? metaData;
        
        if (data.containsKey('users')) {
          agentsJson = data['users'] as List<dynamic>;
          metaData = data['meta'] as Map<String, dynamic>?;
        } else if (data.containsKey('agents')) {
          agentsJson = data['agents'] as List<dynamic>;
          metaData = data['meta'] as Map<String, dynamic>?;
        } else if (data.containsKey('data')) {
          agentsJson = data['data'] as List<dynamic>;
          metaData = data['meta'] as Map<String, dynamic>?;
        } else if (data.containsKey('result')) {
          agentsJson = data['result'] as List<dynamic>;
          metaData = data['meta'] as Map<String, dynamic>?;
        } else {
          throw Exception('Unexpected response structure. Available keys: ${data.keys}');
        }

        final agents = agentsJson.map((json) => Agent.fromJson(json)).toList();
        final meta = metaData != null ? AgentMeta.fromJson(metaData) : AgentMeta(
          total: agents.length,
          page: page,
          limit: limit,
          pages: 1,
        );

        return AgentsResponse(agents: agents, meta: meta);
      } else {
        throw Exception('Failed to load agents: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }
}

// Response classes for pagination
class AgentsResponse {
  final List<Agent> agents;
  final AgentMeta meta;
  
  AgentsResponse({
    required this.agents,
    required this.meta,
  });
}

class AgentMeta {
  final int total;
  final int page;
  final int limit;
  final int pages;
  
  AgentMeta({
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });
  
  factory AgentMeta.fromJson(Map<String, dynamic> json) {
    return AgentMeta(
      total: json['total'] ?? 0,
      page: json['page'] ?? 1,
      limit: json['limit'] ?? 10,
      pages: json['pages'] ?? 1,
    );
  }
}
