import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

/// A selectable service-provider category from the backend catalog.
class CategoryOption {
  final String slug;
  final String label;
  final String emoji;

  const CategoryOption({
    required this.slug,
    required this.label,
    this.emoji = '',
  });

  /// Label with the emoji prefix, matching what the backend denormalizes onto
  /// the user (used for display in pickers).
  String get displayLabel =>
      emoji.isNotEmpty ? '$emoji $label' : label;

  factory CategoryOption.fromJson(Map<String, dynamic> json) {
    return CategoryOption(
      slug: json['slug']?.toString() ?? '',
      label: json['label']?.toString() ?? '',
      emoji: json['emoji']?.toString() ?? '',
    );
  }
}

class CategoryPage {
  final List<CategoryOption> categories;
  final int page;
  final int pages;
  final int total;

  const CategoryPage({
    required this.categories,
    required this.page,
    required this.pages,
    required this.total,
  });
}

class CategoryService {
  static final String baseUrl = '${Environment.apiUrl}agents-routes';

  /// Paginated, searchable list of selectable (active) categories.
  static Future<CategoryPage> fetchServiceCategories({
    String? query,
    int page = 1,
    int limit = 20,
  }) async {
    final queryParams = <String, String>{
      'page': page.toString(),
      'limit': limit.toString(),
      if (query != null && query.trim().isNotEmpty) 'q': query.trim(),
    };

    final uri = Uri.parse('$baseUrl/service-categories')
        .replace(queryParameters: queryParams);
    final response = await http.get(uri, headers: AuthService.getAuthHeaders());

    if (response.statusCode == 200) {
      final data = json.decode(response.body) as Map<String, dynamic>;
      final list = (data['categories'] as List<dynamic>? ?? [])
          .map((c) => CategoryOption.fromJson(c as Map<String, dynamic>))
          .toList();
      final meta = (data['meta'] as Map<String, dynamic>? ?? {});
      return CategoryPage(
        categories: list,
        page: (meta['page'] ?? page) as int,
        pages: (meta['pages'] ?? 1) as int,
        total: (meta['total'] ?? list.length) as int,
      );
    }
    throw Exception('Failed to load categories: ${response.statusCode}');
  }

  /// Update the authenticated service provider's own category.
  /// Pass either [categoryKey] (a base/approved slug) or [customCategory] text.
  static Future<Map<String, dynamic>> updateMyCategory({
    String? categoryKey,
    String? customCategory,
  }) async {
    final uri = Uri.parse('$baseUrl/my-category');
    final body = <String, dynamic>{
      if (categoryKey != null) 'categoryKey': categoryKey,
      if (customCategory != null) 'customCategory': customCategory,
    };

    final response = await http.put(
      uri,
      headers: AuthService.getAuthHeaders(),
      body: json.encode(body),
    );

    final data = json.decode(response.body) as Map<String, dynamic>;
    if (response.statusCode == 200) {
      return {'success': true, 'data': data};
    }
    return {
      'success': false,
      'error': data['message'] ?? 'Failed to update category',
      'statusCode': response.statusCode,
    };
  }
}
