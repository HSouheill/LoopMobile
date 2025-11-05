import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

class AgentInfoService {
  static Future<Map<String, dynamic>?> getAgentInfo() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('No authentication token found');
      }

      final response = await http.get(
        Uri.parse('${Environment.apiUrl}agents-routes/agent-info'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }
}
