import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

/// Client for the refresh-wallet API (/api/refreshes).
///
/// Users buy refresh packages and spend 1 refresh to bump one of their own
/// listings back to the top of the newest-first queue (its creation date is
/// reset to now). A listing can be refreshed as many times as the user has
/// refreshes — there is no per-listing cap.
///
/// v1 purchases credit the wallet instantly with no payment (backend returns
/// free: true).
class RefreshService {
  static Map<String, String> get _headers {
    final token = AuthService.token;
    if (token == null) throw Exception('No authentication token found');
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  /// Current wallet: { balance, recentTransactions }.
  static Future<Map<String, dynamic>?> getWallet() async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiUrl}refreshes/wallet'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print('Error fetching refresh wallet: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error in getWallet: $e');
      return null;
    }
  }

  /// Active packages the user can buy, paginated.
  /// Returns { packages: [...], pagination: { page, limit, total, pages } }.
  static Future<Map<String, dynamic>?> getPackages({int page = 1, int limit = 5}) async {
    try {
      final response = await http.get(
        Uri.parse('${Environment.apiUrl}refreshes/packages?page=$page&limit=$limit'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body) as Map<String, dynamic>;
      }
      print('Error fetching refresh packages: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error in getPackages: $e');
      return null;
    }
  }

  /// Buy a package. v1: credits the wallet immediately (no payment).
  /// Returns the parsed response ({ message, free, balance }).
  static Future<Map<String, dynamic>> purchase(String packageId) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}refreshes/purchase'),
      headers: _headers,
      body: json.encode({'packageId': packageId}),
    );
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200 || response.statusCode == 201) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to purchase refresh package');
  }

  /// Spend 1 refresh to bump an owned listing to the top of the queue.
  /// Returns { balance, listingId, refreshedAt }.
  static Future<Map<String, dynamic>> spend(String listingId) async {
    final response = await http.post(
      Uri.parse('${Environment.apiUrl}refreshes/spend'),
      headers: _headers,
      body: json.encode({'listingId': listingId}),
    );
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return data;
    }
    throw Exception(data['message'] ?? 'Failed to refresh listing');
  }
}
