import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../environment.dart';
import 'auth_service.dart';

class ListingCreateService {
  // Create a new listing with image and video upload
  static Future<bool> createListing(
    Map<String, dynamic> listingData,
    List<XFile>? images,
    XFile? video,
  ) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}listings/create');
      
      // Create multipart request
      final request = http.MultipartRequest('POST', url);
      
      // Add authorization header
      request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      
      // Add text fields with proper handling for nested objects
      listingData.forEach((key, value) {
        if (key == 'images') {
          // Skip images field as we'll handle it separately
          return;
        } else if (key == 'location' && value is Map) {
          // Flatten location object into separate fields
          final location = value as Map<String, dynamic>;
          location.forEach((locKey, locValue) {
            if (locValue != null) {
              request.fields['location[$locKey]'] = locValue.toString();
            }
          });
        } else if (key == 'amenities' && value is Map) {
          // Send amenities as bracketed fields so backend gets proper object
          final amenities = value as Map<String, dynamic>;
          amenities.forEach((amenityKey, amenityValue) {
            if (amenityValue != null) {
              final strVal = (amenityValue is bool)
                  ? (amenityValue ? 'true' : 'false')
                  : amenityValue.toString();
              request.fields['amenities[$amenityKey]'] = strVal;
            }
          });
        } else if (value is Map || value is List) {
          // Convert other complex types to JSON
          request.fields[key] = jsonEncode(value);
        } else if (value != null) {
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
      
      // Add video file (optional)
      if (video != null) {
        final videoBytes = await video.readAsBytes();
        final videoMultipartFile = http.MultipartFile.fromBytes(
          'video', // Field name expected by backend
          videoBytes,
          filename: video.name,
        );
        request.files.add(videoMultipartFile);
      }
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        // Update hasListing to true locally since backend updates it
        if (AuthService.currentUser != null && !AuthService.currentUser!.hasListing) {
          final updatedUser = AuthService.currentUser!.copyWith(hasListing: true);
          await AuthService.updateCurrentUser(updatedUser);
        }
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }
}