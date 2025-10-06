import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../environment.dart';
import 'auth_service.dart';

class ListingCreateService {
  // Create a new listing with image upload
  static Future<bool> createListing(
    Map<String, dynamic> listingData,
    List<XFile>? images,
  ) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}listings/create');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      
      // Add text fields
      // Handle nested objects by converting them to JSON strings
      listingData.forEach((key, value) {
        if (key == 'images') {
          // Skip images field as we'll handle it separately
          return;
        } else if (value is Map || value is List) {
          // Convert complex types to JSON
          request.fields[key] = jsonEncode(value);
        } else {
          // Add simple types directly
          request.fields[key] = value.toString();
        }
      });
      
      // Add image files
      if (images != null && images.isNotEmpty) {
        for (var image in images) {
          final bytes = await image.readAsBytes();
          final multipartFile = http.MultipartFile.fromBytes(
            'images', // Field name expected by backend
            bytes,
            filename: image.name,
          );
          request.files.add(multipartFile);
        }
      }
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        print('Listing created successfully');
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
