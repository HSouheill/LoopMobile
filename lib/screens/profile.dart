// File: lib/screens/profile.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/auth_service.dart';
import '../environment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUpdatingImage = false;
  bool _didUpdateProfile = false; // Add this line
  
Future<void> _pickAndUploadImage() async {
  try {
    // Show image source selection dialog
    final ImageSource? source = await _showImageSourceDialog();
    if (source == null) return;

    // Pick image from selected source
    final XFile? image = await _picker.pickImage(
      source: source,
      maxWidth: 1000,
      maxHeight: 1000,
      imageQuality: 80,
    );

    if (image == null) return;

    setState(() {
      _isUpdatingImage = true;
    });

    // Create multipart request to upload image to your backend endpoint
    final uri = Uri.parse('${Environment.apiUrl}upload');
    final request = http.MultipartRequest('POST', uri);
    
    // Add the image file (your backend expects 'image' field name)
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    // Send upload request
    final response = await request.send();
    final responseBody = await response.stream.bytesToString();
    final responseData = jsonDecode(responseBody);

    if (response.statusCode == 200) {
      // Get the user ID from the AuthService
      final userId = AuthService.currentUser?.id;

      if (userId == null) {
        throw Exception('User ID not found. Please log in again.');
      }

      // Update profile image via the backend endpoint, passing the user ID
      await _updateProfileImage(responseData['filename'], userId);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile image updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );

        // Update the UI to show the new image immediately
        setState(() {
          _didUpdateProfile = true; // Set the flag to true
          // This will rebuild the profile screen with the updated image
        });
      }
    } else {
      throw Exception(responseData['message'] ?? 'Failed to upload image');
    }
  } catch (e) {
    print('Error uploading image: $e');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating profile image: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  } finally {
    if (mounted) {
      setState(() {
        _isUpdatingImage = false;
      });
    }
  }
}

Future<void> _updateProfileImage(String filename, String userId) async {
  try {
    final url = Uri.parse('${Environment.apiUrl}users/update-profile-image');
    final response = await http.post(
      url,
      headers: AuthService.getAuthHeaders(),
      body: jsonEncode({
        'filename': filename,
        'userId': userId, // Pass the user ID to the backend
      }),
    );

    if (response.statusCode == 200) {
      // Update the current user data
      final currentUser = AuthService.currentUser;
      if (currentUser != null) {
        final updatedUser = currentUser.copyWith(profileImage: filename);
        await AuthService.updateCurrentUser(updatedUser);
      }
    } else {
      final errorData = jsonDecode(response.body);
      throw Exception(errorData['message'] ?? 'Failed to update profile image');
    }
  } catch (e) {
    print('Error updating profile image: $e');
    rethrow;
  }
}

  Future<ImageSource?> _showImageSourceDialog() async {
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Image Source'),
          content: const Text('Choose where to get your profile image from:'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 18),
                  SizedBox(width: 4),
                  Text('Camera'),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, size: 18),
                  SizedBox(width: 4),
                  Text('Gallery'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await AuthService.signOut();
                if (mounted) {
                  // Navigate back to main screen and refresh
                  Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                }
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    
    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('No user data available'),
        ),
      );
    }

// Added this to update header on profile update
  return PopScope<bool>(
    canPop: false, // Prevent the default back action
    onPopInvokedWithResult: (bool didPop, bool? result) {
      // If the pop didn't already happen (canPop=false), manually pop with our result.
      if (!didPop) {
        Navigator.pop(context, _didUpdateProfile);
      }
    },
    child: Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            
            // Profile Image Section
            Center(
              child: Stack(
                children: [
                  GestureDetector(
                    onTap: _isUpdatingImage ? null : _pickAndUploadImage,
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey.shade300, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: _isUpdatingImage
                          ? const Center(child: CircularProgressIndicator())
                          : CircleAvatar(
                              radius: 58,
                              backgroundImage: user.profileImage != null
                                  ? NetworkImage('${Environment.apiUrl}assets/${user.profileImage}')
                                  : const NetworkImage('https://i.pravatar.cc/150?img=3') as ImageProvider,
                              backgroundColor: Colors.grey[200],
                            ),
                    ),
                  ),
                  
                  // Camera icon overlay
                  if (!_isUpdatingImage)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.camera_alt,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            if (!_isUpdatingImage)
              Text(
                'Tap to change photo',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 14,
                ),
              ),
            
            const SizedBox(height: 30),
            
            // User Information Cards
            _buildInfoCard('Full Name', user.fullName, Icons.person),
            _buildInfoCard('Email', user.email, Icons.email),
            if (user.location != null && user.location!.isNotEmpty)
              _buildInfoCard('Location', user.location!, Icons.location_on),
            if (user.city != null && user.city!.isNotEmpty)
              _buildInfoCard('City', user.city!, Icons.location_city),
            _buildInfoCard('Role', user.role.toUpperCase(), Icons.badge),
            
            const SizedBox(height: 40),
            
            // Settings Section
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Colors.grey),
                    title: const Text('Settings'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      Navigator.pushNamed(context, '/settings');
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.help_outline, color: Colors.grey),
                    title: const Text('Help & Support'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to help page
                    },
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.info_outline, color: Colors.grey),
                    title: const Text('About'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // Navigate to about page
                    },
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 30),
            
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _showLogoutDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 2,
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
      ),
    );
  }

  Widget _buildInfoCard(String label, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600, size: 22),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}