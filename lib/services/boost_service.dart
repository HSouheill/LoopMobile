import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

/// Client for the boost-wallet API (/api/boosts).
///
/// Users buy boost-day packages and spend days (1–30) to feature their own
/// profile / listings / jobs. v1 purchases credit the wallet instantly with no
/// payment (backend returns free:true).
class BoostService {
  static Map<String, String> get _headers {
    final token = AuthService.token;
    if (token == null) throw Exception('No authentication token found');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Current wallet: { balanceDays, recentTransactions }.
  static Future<Map<String, dynamic>?> getWallet() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiUrl}boosts/wallet'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print('Error fetching boost wallet: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error in getWallet: $e');
      return null;
    }
  }

  /// Active packages the user can buy (list of maps).
  static Future<List<dynamic>?> getPackages() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiUrl}boosts/packages'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        return data['packages'] as List<dynamic>?;
      }
      print('Error fetching boost packages: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error in getPackages: $e');
      return null;
    }
  }

  /// Buy a package. v1: credits the wallet immediately (no payment).
  /// Returns the parsed response ({ message, free, balanceDays }).
  static Future<Map<String, dynamic>> purchase(String packageId) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}boosts/purchase'),
      headers: _headers,
      body: json.encode({'packageId': packageId}),
    );
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to purchase boost package');
  }

  /// Spend [days] (1–30) to feature an owned target.
  /// [targetType] is one of: 'user', 'listing', 'job'.
  /// Returns { balanceDays, targetType, targetId, featuredUntil }.
  static Future<Map<String, dynamic>> spend({
    required String targetType,
    required String targetId,
    required int days,
  }) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}boosts/spend'),
      headers: _headers,
      body: json.encode({
        'targetType': targetType,
        'targetId': targetId,
        'days': days,
      }),
    );
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to apply boost');
  }
}
