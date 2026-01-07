import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

class SubscriptionService {
  /// Get the authenticated user's current subscription
  static Future<Map<String, dynamic>?> getMySubscription() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.apiUrl}subscription/my-subscription'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        // No active subscription found
        return null;
      } else {
        print('Error fetching subscription: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in getMySubscription: $e');
      return null;
    }
  }

  /// Get all available plans
  static Future<List<dynamic>?> getAllPlans() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.apiUrl}plans/all'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['plans'] as List<dynamic>?;
      } else {
        print('Error fetching plans: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Error in getAllPlans: $e');
      return null;
    }
  }

  /// Subscribe to a plan
  static Future<Map<String, dynamic>?> subscribeToPlan(String planId) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${Environment.apiUrl}subscription/subscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'planId': planId}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 409) {
        // Already has active subscription
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Already subscribed to a plan');
      } else {
        print('Error subscribing to plan: ${response.statusCode}');
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to subscribe to plan');
      }
    } catch (e) {
      print('Error in subscribeToPlan: $e');
      rethrow;
    }
  }

  /// Unsubscribe from current plan
  static Future<Map<String, dynamic>?> unsubscribe() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${Environment.apiUrl}subscription/unsubscribe'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        throw Exception('No active subscription found');
      } else {
        print('Error unsubscribing: ${response.statusCode}');
        final data = json.decode(response.body);
        throw Exception(data['message'] ?? 'Failed to unsubscribe');
      }
    } catch (e) {
      print('Error in unsubscribe: $e');
      rethrow;
    }
  }
}
