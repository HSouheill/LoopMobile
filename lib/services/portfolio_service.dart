import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path/path.dart' as path;
import 'dart:convert';
import '../environment.dart';
import 'auth_service.dart';

class PortfolioService {
  static const String _baseUrl = Environment.apiUrl;

  /// Upload a portfolio PDF file
  static Future<Map<String, dynamic>> uploadPortfolioPDF(File pdfFile) async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${_baseUrl}agents-routes/portfolio-pdf'),
      );

      // Add authorization header
      request.headers['Authorization'] = 'Bearer $token';

      // Add the PDF file
      request.files.add(
        await http.MultipartFile.fromPath(
          'pdf',
          pdfFile.path,
          filename: path.basename(pdfFile.path),
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final responseData = json.decode(responseBody);
        return {
          'success': true,
          'message': responseData['message'],
          'user': responseData['user'],
        };
      } else {
        final errorData = json.decode(responseBody);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to upload portfolio PDF',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error uploading portfolio PDF: ${e.toString()}',
      };
    }
  }

  /// Delete the portfolio PDF
  static Future<Map<String, dynamic>> deletePortfolioPDF() async {
    try {
      final token = AuthService.token;
      if (token == null) {
        throw Exception('Authentication token not found');
      }

      final response = await http.delete(
        Uri.parse('${_baseUrl}agents-routes/portfolio-pdf'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      final responseBody = json.decode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': responseBody['message'],
          'user': responseBody['user'],
        };
      } else {
        return {
          'success': false,
          'message': responseBody['message'] ?? 'Failed to delete portfolio PDF',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Error deleting portfolio PDF: ${e.toString()}',
      };
    }
  }

  /// Get the portfolio PDF URL
  static String? getPortfolioUrl(String? portfolioLink) {
    if (portfolioLink == null || portfolioLink.isEmpty) {
      return null;
    }
    return '${_baseUrl}assets/$portfolioLink';
  }
}
