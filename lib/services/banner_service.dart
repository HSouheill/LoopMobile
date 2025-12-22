// lib/services/banner_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/banner.dart';

class BannerService {
  static final String baseUrl = '${Environment.apiUrl}banners';

  // Banner numbers for different screens
  static const int homeScreen = 1;
  static const int agentsScreen = 2;
  static const int servicesScreen = 3;
  static const int jobsScreen = 4;

  /// Fetch banner by banner number
  /// Returns null if banner not found
  static Future<Banner?> getBanner(int bannerNumber) async {
    try {
      final url = Uri.parse('$baseUrl/get/$bannerNumber');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        
        // Check if banner exists
        if (data['banner'] != null) {
          return Banner.fromJson(data['banner']);
        }
        
        // Banner not found
        return null;
      } else if (response.statusCode == 404) {
        // Banner not found
        return null;
      } else {
        throw Exception('Failed to load banner: ${response.statusCode}');
      }
    } catch (e) {
      // Return null on error (banner not found or network error)
      return null;
    }
  }
}

