import 'dart:convert';
import 'package:http/http.dart' as http;
import '../environment.dart';
import 'auth_service.dart';

class ListingCreateService {
  // Create a new listing
  static Future<bool> createListing(Map<String, dynamic> listingData) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}listings/create');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer ${AuthService.token}',
        },
        body: jsonEncode(listingData),
      );

      if (response.statusCode == 201) {
        return true;
      } else {
        print('Failed to create listing: ${response.statusCode}');
        print('Response: ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error creating listing: $e');
      return false;
    }
  }
}
