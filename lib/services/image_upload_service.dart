import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../environment.dart';
import 'auth_service.dart';

class ImageUploadService {
  static final String baseUrl = '${Environment.apiUrl}upload';
  
  /// Upload an image file to the server and get the URL
  static Future<String?> uploadImage(File imageFile) async {
    try {
      final uri = Uri.parse(baseUrl);
      final request = http.MultipartRequest('POST', uri);
      
      // Add authentication headers
      final authHeaders = AuthService.getAuthHeaders();
      request.headers.addAll(authHeaders);
      
      // Add the image file
      request.files.add(
        await http.MultipartFile.fromPath(
          'image', // This should match the field name expected by multer
          imageFile.path,
        ),
      );
      
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = json.decode(response.body);
        // Return the filename or URL from the response
        if (data['filename'] != null) {
          return data['filename'];
        } else if (data['url'] != null) {
          return data['url'];
        } else if (data['imageUrl'] != null) {
          return data['imageUrl'];
        }
      }
      
      throw Exception('Failed to upload image: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error uploading image: $e');
    }
  }
  
  /// Pick an image from gallery or camera
  static Future<File?> pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      
      if (image != null) {
        return File(image.path);
      }
      return null;
    } catch (e) {
      throw Exception('Error picking image: $e');
    }
  }
}
