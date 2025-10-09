import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

class SocialLinksService {
  static Future<Map<String, dynamic>?> addSocialLink(String name, String link) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      // Basic URL validation
      if (!link.startsWith('http://') && !link.startsWith('https://')) {
        throw Exception('URL must start with http:// or https://');
      }

      final response = await http.post(
        Uri.parse('${Environment.apiUrl}agents-routes/social-links'),
        headers: AuthService.getAuthHeaders(),
        body: json.encode({
          'name': name,
          'link': link,
        }),
      );
      
      // Check if response body is empty or contains HTML
      if (response.body.isEmpty) {
        throw Exception('Server returned empty response');
      }
      
      if (response.body.trim().startsWith('<')) {
        throw Exception('Server returned HTML instead of JSON. This might indicate a server error or wrong endpoint. Response: ${response.body.substring(0, 100)}...');
      }

      if (response.statusCode == 201) {
        try {
          final data = json.decode(response.body);
          return data;
        } catch (jsonError) {
          throw Exception('Server returned invalid JSON response: ${response.body}');
        }
      } else {
        // Handle non-JSON error responses
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to add social link');
        } catch (jsonError) {
          // If response is not JSON, show the raw response
          throw Exception('Server error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (e.toString().contains('unexpected character')) {
        throw Exception('Server returned invalid response. Please check your connection and try again.');
      }
      if (e.toString().contains('Connection refused') || e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      }
      rethrow;
    }
  }

  static Future<Map<String, dynamic>?> deleteSocialLink(String linkId) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.delete(
        Uri.parse('${Environment.apiUrl}agents-routes/social-links/$linkId'),
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        // Handle non-JSON error responses
        try {
          final errorData = json.decode(response.body);
          throw Exception(errorData['message'] ?? 'Failed to delete social link');
        } catch (jsonError) {
          // If response is not JSON, show the raw response
          throw Exception('Server error: ${response.statusCode} - ${response.body}');
        }
      }
    } catch (e) {
      if (e.toString().contains('unexpected character')) {
        throw Exception('Server returned invalid response. Please check your connection and try again.');
      }
      if (e.toString().contains('Connection refused') || e.toString().contains('Failed host lookup')) {
        throw Exception('Cannot connect to server. Please check your internet connection.');
      }
      rethrow;
    }
  }
}
