import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';
import 'device_uuid_service.dart';

class ReportService {
  static const String _baseUrl = '${Environment.apiUrl}reports/';

  // Submit a report for a listing
  static Future<Map<String, dynamic>> reportListing({
    required String listingId,
    required String reason,
    String? extraDetails,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);
      
      // Get the device UUID (same for all reports from this device)
      final reportUuid = await DeviceUuidService.getDeviceUuid();
      
      // Check if user is authenticated
      final isAuthenticated = AuthService.isLoggedIn;
      
      final body = {
        'reportedObjectId': listingId,
        'reason': reason,
        'extraDetails': extraDetails ?? '',
        'tableName': 'listing',
        'reportUuid': reportUuid,
        'quickFlag': !isAuthenticated, // true if not authenticated, false if authenticated
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
          'message': data['message'] ?? 'Report submitted successfully',
          'report': data['report'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit report',
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

  // Get available report reasons
  static List<String> getReportReasons() {
    return [
      'spam',
      'inappropriate_content',
      'harassment',
      'fake_information',
      'scam',
      'violence',
      'hate_speech',
      'copyright_violation',
      'other',
    ];
  }

  // Submit a report for a user/agent
  static Future<Map<String, dynamic>> reportUser({
    required String userId,
    required String reason,
    String? extraDetails,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);
      
      // Get the device UUID (same for all reports from this device)
      final reportUuid = await DeviceUuidService.getDeviceUuid();
      
      // Check if user is authenticated
      final isAuthenticated = AuthService.isLoggedIn;
      
      final body = {
        'reportedObjectId': userId,
        'reason': reason,
        'extraDetails': extraDetails ?? '',
        'tableName': 'user',
        'reportUuid': reportUuid,
        'quickFlag': !isAuthenticated, // true if not authenticated, false if authenticated
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
          'message': data['message'] ?? 'Report submitted successfully',
          'report': data['report'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit report',
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

  // Submit a report for a review
  static Future<Map<String, dynamic>> reportReview({
    required String reviewId,
    required String reason,
    String? extraDetails,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);
      
      // Get the device UUID (same for all reports from this device)
      final reportUuid = await DeviceUuidService.getDeviceUuid();
      
      // Check if user is authenticated
      final isAuthenticated = AuthService.isLoggedIn;
      
      final body = {
        'reportedObjectId': reviewId,
        'reason': reason,
        'extraDetails': extraDetails ?? '',
        'tableName': 'review',
        'reportUuid': reportUuid,
        'quickFlag': !isAuthenticated, // true if not authenticated, false if authenticated
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
          'message': data['message'] ?? 'Report submitted successfully',
          'report': data['report'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit report',
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

  // Submit a report for a job
  static Future<Map<String, dynamic>> reportJob({
    required String jobId,
    required String reason,
    String? extraDetails,
  }) async {
    try {
      final url = Uri.parse(_baseUrl);
      
      // Get the device UUID (same for all reports from this device)
      final reportUuid = await DeviceUuidService.getDeviceUuid();
      
      // Check if user is authenticated
      final isAuthenticated = AuthService.isLoggedIn;
      
      final body = {
        'reportedObjectId': jobId,
        'reason': reason,
        'extraDetails': extraDetails ?? '',
        'tableName': 'job',
        'reportUuid': reportUuid,
        'quickFlag': !isAuthenticated, // true if not authenticated, false if authenticated
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
          'message': data['message'] ?? 'Report submitted successfully',
          'report': data['report'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to submit report',
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

  // Get human-readable reason labels
  static Map<String, String> getReasonLabels() {
    return {
      'spam': 'Spam',
      'inappropriate_content': 'Inappropriate Content',
      'harassment': 'Harassment',
      'fake_information': 'Fake Information',
      'scam': 'Scam',
      'violence': 'Violence',
      'hate_speech': 'Hate Speech',
      'copyright_violation': 'Copyright Violation',
      'other': 'Other',
    };
  }
}
