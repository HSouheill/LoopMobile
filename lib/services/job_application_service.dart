import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/job_application.dart';
import 'auth_service.dart';

class JobApplicationService {
  static final String baseUrl = '${Environment.apiUrl}jobs';

  // Get job applications for the authenticated user's jobs
  static Future<JobApplicationsResponse> getMyJobApplications({
    int page = 1,
    int limit = 20,
    String? status,
    String? sort,
  }) async {
    try {
      final queryParams = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
        if (sort != null) 'sort': sort,
        if (status != null) 'status': status,
      };

      final uri = Uri.parse('$baseUrl/applications/my').replace(queryParameters: queryParams);
      final response = await http.get(
        uri,
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return JobApplicationsResponse.fromJson(data);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to load applications: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching job applications: $e');
    }
  }


  // Update application status (accept/reject)
  static Future<void> updateApplicationStatus({
    required String applicationId,
    required String status, // 'accepted' or 'rejected'
  }) async {
    try {
      final url = Uri.parse('$baseUrl/applications/$applicationId/status');
      final response = await http.put(
        url,
        headers: {
          ...AuthService.getAuthHeaders(),
          'Content-Type': 'application/json',
        },
        body: json.encode({'status': status}),
      );

      if (response.statusCode != 200) {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to update status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating application status: $e');
    }
  }
}

