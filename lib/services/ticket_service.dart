import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';
import 'device_uuid_service.dart';

class TicketService {
  static const String _baseUrl = '${Environment.apiUrl}tickets/';
  static const String _logisticBaseUrl = '${Environment.apiUrl}logistic-tickets/';

  // Create a support ticket
  static Future<Map<String, dynamic>> createTicket({
    required String email,
    required String phoneNumber,
    required String content,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);
      
      // Get the device UUID
      final deviceUuid = await DeviceUuidService.getDeviceUuid();
      
      // Check if user is authenticated
      final isAuthenticated = AuthService.isLoggedIn;
      
      final body = {
        'email': email,
        'phoneNumber': phoneNumber,
        'deviceUuid': deviceUuid,
        'content': content,
        'isGuest': !isAuthenticated, // true if not authenticated, false if authenticated
      };

      // Prepare headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Add authorization header if user is authenticated
      if (isAuthenticated && AuthService.token != null) {
        headers['Authorization'] = 'Bearer ${AuthService.token}';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Ticket created successfully',
          'ticket': data['ticket'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create ticket',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred: ${e.toString()}',
      };
    }
  }

  // Create a support ticket for authenticated users (auto-fills email and phone)
  static Future<Map<String, dynamic>> createTicketForAuthenticatedUser({
    required String content,
  }) async {
    try {
      if (!AuthService.isLoggedIn || AuthService.currentUser == null) {
        return {
          'success': false,
          'message': 'User must be authenticated to use this method',
        };
      }

      final user = AuthService.currentUser!;

      return await createTicket(
        email: user.email,
        phoneNumber: user.phone ?? '',
        content: content,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred: ${e.toString()}',
      };
    }
  }

  // Create a logistic ticket
  static Future<Map<String, dynamic>> createLogisticTicket({
    required String email,
    required String phoneNumber,
    required String content,
  }) async {
    try {
      final url = Uri.parse(_logisticBaseUrl);

      // Get the device UUID
      final deviceUuid = await DeviceUuidService.getDeviceUuid();

      // Check if user is authenticated
      final isAuthenticated = AuthService.isLoggedIn;

      final body = {
        'email': email,
        'phoneNumber': phoneNumber,
        'deviceUuid': deviceUuid,
        'content': content,
        'isGuest': !isAuthenticated, // true if not authenticated, false if authenticated
      };

      // Prepare headers
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Add authorization header if user is authenticated
      if (isAuthenticated && AuthService.token != null) {
        headers['Authorization'] = 'Bearer ${AuthService.token}';
      }

      final response = await http.post(
        url,
        headers: headers,
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Logistic ticket created successfully',
          'ticket': data['ticket'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to create logistic ticket',
          'errors': data['errors'],
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred: ${e.toString()}',
      };
    }
  }

  // Create a logistic ticket for authenticated users (auto-fills email and phone)
  static Future<Map<String, dynamic>> createLogisticTicketForAuthenticatedUser({
    required String content,
  }) async {
    try {
      if (!AuthService.isLoggedIn || AuthService.currentUser == null) {
        return {
          'success': false,
          'message': 'User must be authenticated to use this method',
        };
      }

      final user = AuthService.currentUser!;

      return await createLogisticTicket(
        email: user.email,
        phoneNumber: user.phone ?? '',
        content: content,
      );
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred: ${e.toString()}',
      };
    }
  }
}
