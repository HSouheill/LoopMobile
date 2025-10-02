import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import '../models/review.dart';
import 'auth_service.dart';

class ReviewService {
  static const int defaultLimit = 5;

  static Future<ReviewResponse> getReviewsByObject({
    required String objectId,
    required String table,
    int page = 1,
    int limit = defaultLimit,
  }) async {
    try {
      final uri = Uri.parse('${Environment.apiUrl}reviews/by-object').replace(
        queryParameters: {
          'objectId': objectId,
          'table': table,
          'page': page.toString(),
          'limit': limit.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: AuthService.getAuthHeaders(),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return ReviewResponse.fromJson(data);
      } else if (response.statusCode == 401) {
        throw Exception('Session expired. Please log in again.');
      } else {
        final errorData = jsonDecode(response.body);
        throw Exception(errorData['message'] ?? 'Failed to fetch reviews');
      }
    } catch (e) {
      throw Exception('Network error: ${e.toString()}');
    }
  }
}

class ReviewResponse {
  final List<Review> reviews;
  final PaginationInfo pagination;

  ReviewResponse({
    required this.reviews,
    required this.pagination,
  });

  factory ReviewResponse.fromJson(Map<String, dynamic> json) {
    return ReviewResponse(
      reviews: (json['reviews'] as List<dynamic>? ?? [])
          .map((review) => Review.fromJson(review))
          .toList(),
      pagination: PaginationInfo.fromJson(json['pagination'] ?? {}),
    );
  }
}

class PaginationInfo {
  final int currentPage;
  final int totalPages;
  final int totalCount;
  final int limit;
  final bool hasNextPage;
  final bool hasPrevPage;

  PaginationInfo({
    required this.currentPage,
    required this.totalPages,
    required this.totalCount,
    required this.limit,
    required this.hasNextPage,
    required this.hasPrevPage,
  });

  factory PaginationInfo.fromJson(Map<String, dynamic> json) {
    return PaginationInfo(
      currentPage: (json['currentPage'] ?? 1).toInt(),
      totalPages: (json['totalPages'] ?? 1).toInt(),
      totalCount: (json['totalCount'] ?? 0).toInt(),
      limit: (json['limit'] ?? 5).toInt(),
      hasNextPage: json['hasNextPage'] ?? false,
      hasPrevPage: json['hasPrevPage'] ?? false,
    );
  }
}
