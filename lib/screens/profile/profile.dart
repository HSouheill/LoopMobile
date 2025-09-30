// File: lib/screens/profile.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth_service.dart';
import '../../environment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../widgets/profile_widgets/dynamic_section.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  bool _isUpdatingImage = false;
  bool _didUpdateProfile = false; // Add this line

// user inforamtion icon and input field
  late TextEditingController emailController;

  @override
  void initState() {
    super.initState();

    final user = AuthService.currentUser;

    emailController = TextEditingController(
      text: user != null ? user.email : '',
    );
  }

// List for the 5 items in the horizontal scroll view
  final List<Map<String, dynamic>> menuItems = [
    {
      'icon': Icons.headset_mic,
      'text': 'Help & Support',
      'color': Color(0xFF0048FF),
    },
    {
      'icon': Icons.description,
      'text': 'Terms & Conditions',
      'color': Color(0xFF0048FF),
    },
    {
      'icon': Icons.star,
      'text': 'Favorites',
      'color': Color(0xFF0048FF),
    },
    {
      'icon': Icons.extension,
      'text': 'Referrals',
      'color': Color(0xFF0048FF),
    },
    {
      'icon': Icons.apps,
      'text': 'Dashboard',
      'color': Color(0xFF0048FF),
    },
  ];

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
        throw Exception(
            errorData['message'] ?? 'Failed to update profile image');
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
                  Navigator.of(context)
                      .pushNamedAndRemoveUntil('/', (route) => false);
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
      canPop: false,
      onPopInvokedWithResult: (bool didPop, bool? result) {
        if (!didPop) {
          Navigator.pop(context, _didUpdateProfile);
        }
      },
      child: Scaffold(
        body: SingleChildScrollView(
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Column(
                children: [
                  // AppBar section
                  SizedBox(
                    height: 150,
                    child: Stack(
                      children: [
                        // Background image
                        Container(
                          decoration: const BoxDecoration(
                            image: DecorationImage(
                              image: AssetImage(
                                  "assets/profileBackgroundImage.png"),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        // Back arrow
                        Positioned(
                          top: 30,
                          left: 16,
                          child: SizedBox(
                            width: 25,
                            height: 25,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: Color(0xFF0048FF),
                                  width: 1,
                                ),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.arrow_back_rounded,
                                  color: Color(0xFF0048FF),
                                  size: 16,
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            ),
                          ),
                        ),

                        // Settings icon
                        Positioned(
                          top: 75,
                          right: 16,
                          child: SizedBox(
                            width: 23,
                            height: 23,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Color(0xFF0048FF),
                                borderRadius: BorderRadius.circular(50.0),
                              ),
                              child: IconButton(
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                                icon: const Icon(
                                  Icons.mode_edit_outline_sharp,
                                  color: Colors.white,
                                  size: 14,
                                ),
                                onPressed: () {},
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 35), // space for profile image

                  // User Info and other content
                  // _buildInfoCard('Full Name', user.fullName, Icons.person),
                  // if (user.location != null && user.location!.isNotEmpty)
                  //   _buildInfoCard(
                  //       'Location', user.location!, Icons.location_on),
                  // if (user.city != null && user.city!.isNotEmpty)
                  //   _buildInfoCard('City', user.city!, Icons.location_city),
                  // _buildInfoCard('Role', user.role.toUpperCase(), Icons.badge),

                  // const SizedBox(height: 30),

                  //User Info
                  _buildInfoCard(
                      'Email', emailController, Icons.email_outlined),

                  const SizedBox(height: 20),

                  // Phone input (below Email)
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 0.0, vertical: 8.0),
                      decoration: const BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFF0048FF), // 👈 divider color
                            width: 1.5, // thickness of divider
                          ),
                        ),
                      ),
                      child: Row(
                        mainAxisSize:
                            MainAxisSize.max, // Let the Row fill the Container
                        children: [
                          // Phone Icon
                          const Icon(
                            Icons.phone,
                            color: Color(0xFF2563FF),
                            size: 20,
                          ),
                          const SizedBox(width: 14.0),

                          // Country Code and Flag
                          // This section is now a fixed-width Row
                          Row(
                            children: [
                              Container(
                                width: 20,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                              const SizedBox(width: 6.0),
                              const Text(
                                '+961',
                                style: TextStyle(
                                  color: Color(0XFF1E1E1E),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const Icon(
                                Icons.arrow_drop_down,
                                color: Color(0xFF1E1E1E),
                                size: 20,
                              ),
                            ],
                          ),

                          // Vertical Separator
                          Container(
                            height: 20,
                            width: 1.5,
                            color: Color(0xFF2563FF),
                            margin:
                                const EdgeInsets.symmetric(horizontal: 10.0),
                          ),

                          const SizedBox(width: 20.0),
                          // Phone Number Input Field
                          const Expanded(
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: '00 123 456',
                                hintStyle: TextStyle(color: Colors.grey),
                                border: InputBorder.none,
                                isDense: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                              keyboardType: TextInputType.phone,
                              style: TextStyle(
                                color: Color(0xFF1E1E1E),
                                fontWeight: FontWeight
                                    .w400, // optional: adjust font size
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  DynamicGradientButton(
                    buttonText: 'Edit Email & Number', // Your custom text
                    onTap: () {
                      // This code runs when the button is tapped
                      print('Button tapped!');
                      // You can add navigation, API calls, or other logic here
                    },
                  ),

                  const SizedBox(height: 30),

// new password and rewrite password section
                  Column(
                    children: [
                      BuildNewPassword(
                          Icons.lock_open_outlined, "Enter new password",
                          obscureText: true),
                      BuildNewPassword(Icons.lock_outline, "Re-enter password"),
                    ],
                  ),

                  const SizedBox(height: 20),

                  DynamicGradientButton(
                    buttonText: 'Change Password', // Your custom text
                    onTap: () {
                      // This code runs when the button is tapped
                      print('Button tapped!');
                      // You can add navigation, API calls, or other logic here
                    },
                    padding: const EdgeInsets.symmetric(
                        horizontal: 18.5, vertical: 7.0),
                  ),

                  const SizedBox(height: 30),

                  // Horizontal ScrollView containing 5 items with icon and text
                  horizontalScroll(),

                  // Dynamic settings section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: DynamicSection(
                      title: 'Notification Settings',
                      rows: const [
                        {"text": "New Messages"},
                        {"text": "Listing Approval"},
                        {"text": "Service Requests"},
                        {"text": "Promotions"},
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: DynamicSection(
                      title: 'Privacy Settings',
                      rows: const [
                        {"text": "Hide Social Links"},
                        {"text": "Hide Contact Info"},
                      ],
                    ),
                  ),

                  // ! Manage links is missing in figma

                  const SizedBox(height: 20),

                  logOutButton(),

                  deleteAccountButton(() {
                    // your delete account logic here
                  }),

                  // Logout Button

                  const SizedBox(height: 20),
                ],
              ),

              // Profile Image overlapping the app bar
              Positioned(
                top: 100, // adjust to overlap properly
                left: 16,
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: _isUpdatingImage ? null : _pickAndUploadImage,
                      child: Container(
                        width: 90,
                        height: 90,
                        child: _isUpdatingImage
                            ? const Center(child: CircularProgressIndicator())
                            : CircleAvatar(
                                radius: 58,
                                backgroundImage: user.profileImage != null
                                    ? NetworkImage(
                                        '${Environment.apiUrl}assets/${user.profileImage}')
                                    : const NetworkImage(
                                            'https://i.pravatar.cc/150?img=3')
                                        as ImageProvider,
                                backgroundColor: Colors.grey[200],
                              ),
                      ),
                    ),
                    if (!_isUpdatingImage)
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Color(0xFF0048FF),
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: const Icon(
                                Icons.mode_edit_outline_sharp,
                                color: Colors.white,
                                size: 14,
                              ),
                              onPressed: () {},
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget logOutButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 20), // left padding
      child: Align(
        alignment: Alignment.centerLeft, // align button to the left
        child: ElevatedButton(
          onPressed: _showLogoutDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min, // wrap content tightly
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Logout',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget deleteAccountButton(VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(left: 20.0),
      child: Align(
        alignment: Alignment.centerLeft, // align the button to the left
        child: ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.0),
            ),
            elevation: 2,
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min, // wrap content tightly
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.delete, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Delete Account',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  SizedBox horizontalScroll() {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.only(left: 5),
        itemCount: menuItems.length,
        separatorBuilder: (context, index) => const SizedBox(width: 25),
        itemBuilder: (context, index) {
          final item = menuItems[index];

          // Determine the route based on index
          String route = '';
          switch (index) {
            case 0:
              route = '/help-and-support';
              break;
            case 1:
              route = '/terms-and-conditions';
              break;
            case 2:
              route = '/favorites';
              break;
            case 3:
              route = '/referrals';
              break;
            case 4:
              route = '/profile-dashboard';
              break;
          }

          return InkWell(
            onTap: () {
              if (route.isNotEmpty) {
                Navigator.pushNamed(context, route);
              }
            },
            child: Container(
              width: 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      color: item['color'],
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['icon'],
                      size: 24,
                      color:
                          index == 2 ? const Color(0xFFFFBA00) : Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 32,
                    child: Text(
                      item['text'],
                      style: const TextStyle(
                        fontSize: 11,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

// Email widget
  Widget _buildInfoCard(
      String label, TextEditingController controller, IconData icon) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 0),
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      decoration: BoxDecoration(
        color: Color(0xF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row: icon + input field
          Row(
            children: [
              Icon(icon, color: Color(0xFF0048FF), size: 22),
              const SizedBox(width: 42),
              Expanded(
                child: TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: label,
                    hintStyle: TextStyle(
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF1E1E1E),
                  ),
                ),
              ),
            ],
          ),
          // Divider
          const Divider(
            color: Color(0xFF0048FF),
            thickness: 1.5,
            height: 0,
          ),
        ],
      ),
    );
  }

// New password and rewrite password widget
  Widget BuildNewPassword(IconData icon, String hintText,
      {bool obscureText = false}) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFF0048FF)),
              const SizedBox(width: 35),
              Expanded(
                child: TextField(
                  obscureText: obscureText, // for hidden text (like password)
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none, // removes underline
                    hintStyle: const TextStyle(color: Colors.grey),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
          const Divider(
            color: Color(0xFF0048FF),
            thickness: 1.5,
            height: 0,
          ),
        ],
      ),
    );
  }
}
