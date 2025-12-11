// lib/services/news_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';

class NewsItem {
  final String id;
  final String body;
  final DateTime createdAt;
  final DateTime updatedAt;

  NewsItem({
    required this.id,
    required this.body,
    required this.createdAt,
    required this.updatedAt,
  });

  factory NewsItem.fromJson(Map<String, dynamic> json) {
    return NewsItem(
      id: json['_id'] ?? '',
      body: json['body'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
    );
  }
}

class NewsResponse {
  final String message;
  final List<NewsItem> data;
  final Map<String, dynamic> pagination;
  final Map<String, dynamic> filter;

  NewsResponse({
    required this.message,
    required this.data,
    required this.pagination,
    required this.filter,
  });

  factory NewsResponse.fromJson(Map<String, dynamic> json) {
    return NewsResponse(
      message: json['message'] ?? '',
      data: (json['data'] as List<dynamic>?)
              ?.map((item) => NewsItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      pagination: json['pagination'] as Map<String, dynamic>? ?? {},
      filter: json['filter'] as Map<String, dynamic>? ?? {},
    );
  }
}

class NewsService {
  static final String baseUrl = '${Environment.apiUrl}news';

  static Future<NewsResponse> getNews() async {
    try {
      final url = Uri.parse('$baseUrl/get');
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return NewsResponse.fromJson(data);
      } else {
        throw Exception('Failed to load news: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching news: $e');
    }
  }
}

