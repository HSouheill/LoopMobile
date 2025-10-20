// lib/services/favorite_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

class FavoriteService {
  static final String baseUrl = '${Environment.apiUrl}favorites';

  /// Toggle favorite status - add if not favorited, remove if already favorited
  static Future<Map<String, dynamic>> toggleFavorite({
    required String favoritedObjectId,
    required String table,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/toggle');
      final response = await http.post(
        url,
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'favoritedObjectId': favoritedObjectId,
          'table': table,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Favorite status updated',
          'isFavorited': data['isFavorited'] ?? false,
          'action': data['action'] ?? 'toggled',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update favorite status',
          'isFavorited': false,
        };
      }
    } catch (e) {
      print('Toggle favorite error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'isFavorited': false,
      };
    }
  }

  /// Add a new favorite
  static Future<Map<String, dynamic>> addFavorite({
    required String favoritedObjectId,
    required String table,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/add');
      final response = await http.post(
        url,
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'favoritedObjectId': favoritedObjectId,
          'table': table,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'] ?? 'Item added to favorites',
          'isFavorited': true,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to add to favorites',
          'isFavorited': false,
        };
      }
    } catch (e) {
      print('Add favorite error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'isFavorited': false,
      };
    }
  }

  /// Remove a favorite
  static Future<Map<String, dynamic>> removeFavorite({
    required String favoritedObjectId,
    required String table,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/remove');
      final response = await http.post(
        url,
        headers: AuthService.getAuthHeaders(),
        body: jsonEncode({
          'favoritedObjectId': favoritedObjectId,
          'table': table,
        }),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Item removed from favorites',
          'isFavorited': false,
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to remove from favorites',
          'isFavorited': true,
        };
      }
    } catch (e) {
      print('Remove favorite error: $e');
      return {
        'success': false,
        'message': 'Network error occurred',
        'isFavorited': true,
      };
    }
  }

  /// Check if a specific object is favorited by the authenticated user
  static Future<Map<String, dynamic>> checkFavorite({
    required String favoritedObjectId,
    required String table,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/check');
      final response = await http.get(
        Uri.parse('$url?favoritedObjectId=$favoritedObjectId&table=$table'),
        headers: AuthService.getAuthHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'isFavorited': data['isFavorited'] ?? false,
        };
      } else {
        return {
          'success': false,
          'isFavorited': false,
          'message': data['message'] ?? 'Failed to check favorite status',
        };
      }
    } catch (e) {
      print('Check favorite error: $e');
      return {
        'success': false,
        'isFavorited': false,
        'message': 'Network error occurred',
      };
    }
  }

  /// Get all favorites by the authenticated user
  static Future<Map<String, dynamic>> getUserFavorites() async {
    try {
      final url = Uri.parse('$baseUrl/my-favorites');
      final response = await http.get(
        url,
        headers: AuthService.getAuthHeaders(),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'favorites': data['favorites'] ?? [],
        };
      } else {
        return {
          'success': false,
          'favorites': [],
          'message': data['message'] ?? 'Failed to load favorites',
        };
      }
    } catch (e) {
      print('Get user favorites error: $e');
      return {
        'success': false,
        'favorites': [],
        'message': 'Network error occurred',
      };
    }
  }
}
