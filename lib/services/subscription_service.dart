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
        Uri.parse('${Environment.apiUrl}subscriptions/my-subscription'),
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

  /// Get the plans available to the authenticated user's role.
  /// Uses /plans/me which is scoped by role and excludes the starter plan.
  static Future<List<dynamic>?> getAllPlans() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.apiUrl}plans/me'),
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

      final url = '${Environment.apiUrl}subscriptions/subscribe';
      print('Subscribing to plan at: $url');
      print('Plan ID: $planId');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({'planId': planId}),
      );

      print('Subscribe response status: ${response.statusCode}');
      print('Subscribe response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data;
        } catch (e) {
          print('Error parsing success response: $e');
          throw Exception('Server returned invalid JSON response');
        }
      } else if (response.statusCode == 409) {
        // Already has active subscription
        try {
          final data = json.decode(response.body);
          throw Exception(data['message'] ?? 'Already subscribed to a plan');
        } catch (e) {
          throw Exception('Already subscribed to a plan');
        }
      } else {
        print('Error subscribing to plan: ${response.statusCode}');
        try {
          final data = json.decode(response.body);
          throw Exception(data['message'] ?? 'Failed to subscribe to plan');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): Could not subscribe to plan');
        }
      }
    } catch (e) {
      print('Error in subscribeToPlan: $e');
      rethrow;
    }
  }

  /// Recharge the service-provider 30-day plan (+30 days).
  static Future<Map<String, dynamic>?> rechargeServicePlan() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.post(
        Uri.parse('${Environment.apiUrl}subscriptions/recharge-service'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        try {
          final data = json.decode(response.body);
          throw Exception(data['message'] ?? 'Failed to recharge service plan');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): Could not recharge');
        }
      }
    } catch (e) {
      print('Error in rechargeServicePlan: $e');
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

      final url = '${Environment.apiUrl}subscriptions/unsubscribe';
      print('Unsubscribing at: $url');

      final response = await http.post(
        Uri.parse(url),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Unsubscribe response status: ${response.statusCode}');
      print('Unsubscribe response body: ${response.body}');

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body);
          return data;
        } catch (e) {
          print('Error parsing success response: $e');
          throw Exception('Server returned invalid JSON response');
        }
      } else if (response.statusCode == 404) {
        throw Exception('No active subscription found');
      } else {
        print('Error unsubscribing: ${response.statusCode}');
        try {
          final data = json.decode(response.body);
          throw Exception(data['message'] ?? 'Failed to unsubscribe');
        } catch (e) {
          throw Exception('Server error (${response.statusCode}): Could not unsubscribe');
        }
      }
    } catch (e) {
      print('Error in unsubscribe: $e');
      rethrow;
    }
  }
}
