// File: lib/screens/profile.dart

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/auth_service.dart';
import '../../environment.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../widgets/profile_widgets/settings_dynamic_section.dart';
import '../../utils/password_validator.dart';
import '../../utils/phone_validator.dart';
import '../../widgets/profile_widgets/otp_verification_dialog.dart';
import '../../widgets/country_picker_button.dart';

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
  late TextEditingController phoneController;
  
  // Password change controllers
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;
  bool _isChangingPassword = false;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  // Edit contact variables
  bool _isEditingContact = false;
  String? _pendingEditId;
  String? _newPhoneNumber;

  // Selected country code for phone input
  String _selectedCountryCode = '+961';
  String _selectedCountryFlag = '🇱🇧';


  // Helper method to extract country code and phone number
  Map<String, String> _extractPhoneParts(String? phoneNumber) {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      return {'countryCode': '+961', 'phoneNumber': '', 'flag': '🇱🇧'};
    }
    
    // Remove any spaces or special characters
    String cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    
    // Build country codes map from kCountries list (longer codes first to avoid prefix conflicts)
    final sortedCountries = List<Map<String, String>>.from(kCountries)
      ..sort((a, b) => b['code']!.length.compareTo(a['code']!.length));
    Map<String, String> countryCodes = {
      for (final c in sortedCountries) c['code']!: c['flag']!
    };
    
    // Try to find matching country code
    for (String code in countryCodes.keys) {
      if (cleanPhone.startsWith(code)) {
        return {
          'countryCode': code,
          'phoneNumber': cleanPhone.substring(code.length),
          'flag': countryCodes[code]!
        };
      }
    }
    
    // Default to Lebanon if no match found
    return {'countryCode': '+961', 'phoneNumber': cleanPhone, 'flag': '🇱🇧'};
  }

  @override
  void initState() {
    super.initState();

    final user = AuthService.currentUser;

    emailController = TextEditingController(
      text: user != null ? user.email : '',
    );
    
    // Extract phone number without country code for the input field
    final phoneParts = _extractPhoneParts(user?.phone);
    phoneController = TextEditingController(
      text: phoneParts['phoneNumber'] ?? '',
    );

    // Initialize selected country from user's phone
    _selectedCountryCode = phoneParts['countryCode'] ?? '+961';
    _selectedCountryFlag = phoneParts['flag'] ?? '🇱🇧';
    
    // Initialize password controllers
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    phoneController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildMenuItems(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return [
      {
        'icon': Icons.headset_mic,
        'text': l10n.helpAndSupport,
        'color': Color.fromARGB(255, 69, 100, 201),
      },
      {
        'icon': Icons.description,
        'text': l10n.termsAndConditions,
        'color': Color.fromARGB(255, 69, 100, 201),
      },
      // {
      //   'icon': Icons.extension,
      //   'text': l10n.referrals,
      //   'color': Color(0xFF0048FF),
      // },
    ];
  }

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
          final l10n = AppLocalizations.of(context)!;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.profileImageUpdatedSuccessfully),
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
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorUpdatingProfileImage(e.toString())),
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
      rethrow;
    }
  }

  Future<ImageSource?> _showImageSourceDialog() async {
    final l10n = AppLocalizations.of(context)!;
    return showDialog<ImageSource>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.selectImageSource),
          content: Text(l10n.chooseImageSource),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.camera),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.camera_alt, size: 18),
                  SizedBox(width: 4),
                  Text(l10n.camera),
                ],
              ),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(ImageSource.gallery),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.photo_library, size: 18),
                  SizedBox(width: 4),
                  Text(l10n.gallery),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _showLogoutDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(l10n.logout),
          content: Text(l10n.areYouSureLogout),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
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
              child: Text(l10n.logout),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAccountDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            l10n.deleteAccount,
            style: const TextStyle(
              color: Colors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.deleteAccountWarning,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.deletingAccountWillRemove,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 8),
              Text(l10n.allPersonalData),
              Text(l10n.allListingsAndServices),
              Text(l10n.allMessagesAndChatHistory),
              Text(l10n.allReviewsAndFavorites),
              Text(l10n.allSubscriptions),
              const SizedBox(height: 12),
              Text(
                l10n.deleteAccountConfirmation,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(l10n.cancel),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _deleteAccount();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: Text(
                l10n.deleteAccount,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteAccount() async {
    try {
      final l10n = AppLocalizations.of(context)!;
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Text(l10n.deletingAccount),
              ],
            ),
          );
        },
      );

      final result = await AuthService.deleteAccount();

      if (mounted) {
        // Close loading dialog
        Navigator.of(context).pop();
        
        if (result['success']) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
          
          // Navigate to login screen
          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
        } else {
          // Show error message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        // Close loading dialog if it's still open
        Navigator.of(context).pop();
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorDeletingAccount(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _changePassword() async {
    final newPassword = newPasswordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    final l10n = AppLocalizations.of(context)!;
    // Validate passwords match
    if (newPassword != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.passwordsDoNotMatch),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Validate password strength
    final passwordError = PasswordValidator.validatePassword(newPassword);
    if (passwordError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(passwordError),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isChangingPassword = true;
    });

    try {
      final result = await AuthService.changePassword(newPassword);
      
      if (mounted) {
        if (result['success']) {
          // Clear password fields
          newPasswordController.clear();
          confirmPasswordController.clear();
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error changing password: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isChangingPassword = false;
        });
      }
    }
  }

  void _showCountryPicker() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return ListView(
          shrinkWrap: true,
          children: kCountries.map((country) {
            final isSelected = country['code'] == _selectedCountryCode;
            return ListTile(
              leading: Text(country['flag']!, style: const TextStyle(fontSize: 24)),
              title: Text(country['name']!),
              trailing: Text(
                country['code']!,
                style: const TextStyle(color: Colors.grey),
              ),
              selected: isSelected,
              selectedColor: const Color.fromARGB(255, 69, 100, 201),
              onTap: () {
                setState(() {
                  _selectedCountryCode = country['code']!;
                  _selectedCountryFlag = country['flag']!;
                });
                Navigator.pop(context);
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _editContact() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final newEmail = emailController.text.trim();
    final newPhone = phoneController.text.trim();
    
    // Validate email if provided
    if (newEmail.isNotEmpty) {
      final emailError = PhoneValidator.validateEmail(newEmail);
      if (emailError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(emailError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    // Validate phone if provided
    if (newPhone.isNotEmpty) {
      final phoneError = PhoneValidator.validatePhoneNumber(newPhone);
      if (phoneError != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(phoneError),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }
    
    // Check if there are any changes
    final currentEmail = currentUser.email.toLowerCase();
    final currentPhone = currentUser.phone ?? '';
    final phoneParts = _extractPhoneParts(currentPhone);
    final currentPhoneNumber = phoneParts['phoneNumber'] ?? '';
    final currentCountryCode = phoneParts['countryCode'] ?? '+961';

    final l10n = AppLocalizations.of(context)!;
    final phoneChanged = newPhone != currentPhoneNumber || _selectedCountryCode != currentCountryCode;
    if (newEmail.toLowerCase() == currentEmail && !phoneChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noChangesDetected),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isEditingContact = true;
    });

    try {
      // Prepare data for API call
      String? emailToSend = newEmail.toLowerCase() != currentEmail ? newEmail : null;
      String? phoneToSend;

      if (phoneChanged && newPhone.isNotEmpty) {
        // Combine selected country code with phone number
        phoneToSend = '$_selectedCountryCode$newPhone';
        _newPhoneNumber = phoneToSend;
      }

      final l10n = AppLocalizations.of(context)!;
      if (emailToSend == null && phoneToSend == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.noChangesDetected),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      // Request OTP
      final result = await AuthService.requestEditContact(
        newEmail: emailToSend,
        newPhone: phoneToSend,
      );

      if (mounted) {
        if (result['success']) {
          _pendingEditId = result['pendingEditId'];
          
          // Show OTP dialog
          _showOtpDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorRequestingOtp(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEditingContact = false;
        });
      }
    }
  }

  void _showOtpDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => OtpVerificationDialog(
        phoneNumber: _newPhoneNumber ?? 'your phone',
        onVerify: _verifyOtp,
        onResend: _resendOtp,
        isLoading: _isEditingContact,
      ),
    );
  }

  Future<void> _verifyOtp(String otp) async {
    if (_pendingEditId == null) return;

    setState(() {
      _isEditingContact = true;
    });

    try {
      final result = await AuthService.verifyEditOtp(
        pendingEditId: _pendingEditId!,
        otp: otp,
      );

      if (mounted) {
        if (result['success']) {
          // Close OTP dialog
          Navigator.of(context).pop();
          
          // Update the UI with new user data
          setState(() {
            _didUpdateProfile = true;
          });

          // Update controllers with new values
          final updatedUser = AuthService.currentUser;
          if (updatedUser != null) {
            emailController.text = updatedUser.email;
            final phoneParts = _extractPhoneParts(updatedUser.phone);
            phoneController.text = phoneParts['phoneNumber'] ?? '';
          }

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorVerifyingOtp(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEditingContact = false;
        });
      }
    }
  }

  Future<void> _resendOtp() async {
    final currentUser = AuthService.currentUser;
    if (currentUser == null) return;

    final newEmail = emailController.text.trim();
    final newPhone = phoneController.text.trim();
    
    setState(() {
      _isEditingContact = true;
    });

    try {
      // Prepare data for API call
      String? emailToSend = newEmail.toLowerCase() != currentUser.email.toLowerCase() ? newEmail : null;
      String? phoneToSend;
      
      if (newPhone.isNotEmpty) {
        phoneToSend = '$_selectedCountryCode$newPhone';
        _newPhoneNumber = phoneToSend;
      }

      final result = await AuthService.requestEditContact(
        newEmail: emailToSend,
        newPhone: phoneToSend,
      );

      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        if (result['success']) {
          _pendingEditId = result['pendingEditId'];
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.otpResentSuccessfully),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.errorRequestingOtp(e.toString())),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isEditingContact = false;
        });
      }
    }
  }

  Future<void> _handleOptionChange(String optionName, bool value) async {
    try {
      final result = await AuthService.updateUserOptions(
        hideSocialLinks: optionName == 'hideSocialLinks' ? value : null,
        hideContactInfo: optionName == 'hideContactInfo' ? value : null,
        newMessagesNotifications: optionName == 'newMessagesNotifications' ? value : null,
        listingApprovalNotifications: optionName == 'listingApprovalNotifications' ? value : null,
        serviceRequestsNotifications: optionName == 'serviceRequestsNotifications' ? value : null,
        promotionsNotifications: optionName == 'promotionsNotifications' ? value : null,
      );

      if (mounted) {
        if (result['success']) {
          // Update the UI to reflect the change
          setState(() {
            _didUpdateProfile = true;
          });
          
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(result['message']),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          throw Exception(result['message']);
        }
      }
    } catch (e) {
      rethrow; // Re-throw to be handled by the DynamicSection widget
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    if (user == null) {
      final l10n = AppLocalizations.of(context)!;
      return Scaffold(
        body: Center(
          child: Text(l10n.noUserDataAvailable),
        ),
      );
    }

  return Scaffold(

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
                          image: AssetImage("assets/profileBackgroundImage.png"),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                        // Back arrow
                         Positioned(
                      top: 40,
                      left: 16,
                      child: GestureDetector(
                        onTap: () {
                          // Return the update flag when navigating back
                          Navigator.of(context).pop(_didUpdateProfile);
                        },
                        child: Container(
                          width: 30,
                          height: 30,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(
                              color: Color.fromARGB(255, 69, 100, 201),
                              width: 1,
                            ),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.arrow_back_rounded,
                              color: Color.fromARGB(255, 69, 100, 201),
                              size: 22,
                            ),
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
                      AppLocalizations.of(context)!.email, emailController, Icons.email_outlined),

                  const SizedBox(height: 20),

                  // Phone input (below Email)
                  Builder(
                    builder: (context) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 25.0, right: 25.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 0.0, vertical: 8.0),
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(
                                color: Color.fromARGB(255, 69, 100, 201), // 👈 divider color
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
                                color: Color.fromARGB(255, 69, 100, 201),
                                size: 20,
                              ),
                              const SizedBox(width: 14.0),

                              // Country Code and Flag (tappable dropdown)
                              GestureDetector(
                                onTap: _showCountryPicker,
                                child: Row(
                                  children: [
                                    Text(
                                      _selectedCountryFlag,
                                      style: const TextStyle(fontSize: 20),
                                    ),
                                    const SizedBox(width: 6.0),
                                    Text(
                                      _selectedCountryCode,
                                      style: const TextStyle(
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
                              ),

                              // Vertical Separator
                              Container(
                                height: 20,
                                width: 1.5,
                                color: Color.fromARGB(255, 69, 100, 201),
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 10.0),
                              ),

                              const SizedBox(width: 20.0),
                              // Phone Number Input Field
                              Expanded(
                                child: Builder(
                                  builder: (context) {
                                    final l10n = AppLocalizations.of(context)!;
                                    return TextField(
                                      controller: phoneController,
                                      decoration: InputDecoration(
                                        hintText: phoneController.text.isEmpty
                                            ? l10n.enterYourPhoneNumber
                                            : l10n.phoneNumberPlaceholder,
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
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return DynamicGradientButton(
                        buttonText: _isEditingContact ? l10n.processing : l10n.editEmailAndNumber,
                        onTap: _isEditingContact ? null : _editContact,
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // new password and rewrite password section
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        children: [
                          BuildNewPassword(
                            Icons.lock_open_outlined,
                            l10n.enterNewPassword,
                            obscureText: _obscureNewPassword,
                            controller: newPasswordController,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                          BuildNewPassword(
                            Icons.lock_outline,
                            l10n.reEnterPassword,
                            obscureText: _obscureConfirmPassword,
                            controller: confirmPasswordController,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ],
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return DynamicGradientButton(
                        buttonText: _isChangingPassword ? l10n.changing : l10n.changePassword,
                        onTap: _isChangingPassword ? null : _changePassword,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.5, vertical: 7.0),
                      );
                    },
                  ),

                  const SizedBox(height: 30),

                  // Horizontal ScrollView containing 5 items with icon and text
                  horizontalScroll(),

                  // Dynamic settings section
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: DynamicSection(
                              title: l10n.notificationSettings,
                              rows: [
                                {"text": l10n.newMessages},
                                {"text": l10n.listingApproval},
                                {"text": l10n.serviceRequests},
                                {"text": l10n.promotions},
                              ],
                              userOptions: user.options,
                              onOptionChanged: _handleOptionChange,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 15),
                            child: DynamicSection(
                              title: l10n.privacySettings,
                              rows: [
                                {"text": l10n.hideSocialLinks},
                                {"text": l10n.hideContactInfo},
                              ],
                              userOptions: user.options,
                              onOptionChanged: _handleOptionChange,
                            ),
                          ),
                        ],
                      );
                    },
                  ),

                  // ! Manage links is missing in figma

                  const SizedBox(height: 20),

                  logOutButton(),

                  deleteAccountButton(() {
                    _showDeleteAccountDialog();
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
                                    : const AssetImage(
                                            'assets/defaultProfileImage.png')
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
                              color: Color.fromARGB(255, 69, 100, 201),
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
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Row(
                mainAxisSize: MainAxisSize.min, // wrap content tightly
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.logout, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    l10n.logout,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
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
          child: Builder(
            builder: (context) {
              final l10n = AppLocalizations.of(context)!;
              return Row(
                mainAxisSize: MainAxisSize.min, // wrap content tightly
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.delete, color: Colors.white),
                  SizedBox(width: 8),
                  Text(
                    l10n.deleteAccount,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  SizedBox horizontalScroll() {
    final menuItems = _buildMenuItems(context);
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
              route = '/referrals';
              break;
            case 3:
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
                      color: Colors.white,
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
              Icon(icon, color: Color.fromARGB(255, 69, 100, 201), size: 22),
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
            color: Color.fromARGB(255, 69, 100, 201),
            thickness: 1.5,
            height: 0,
          ),
        ],
      ),
    );
  }

// New password and rewrite password widget with eye toggle
  Widget BuildNewPassword(
    IconData icon,
    String hintText, {
    bool obscureText = false,
    TextEditingController? controller,
    VoidCallback? onToggleVisibility,
  }) {
    return Padding(
      padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: const Color.fromARGB(255, 69, 100, 201)),
              const SizedBox(width: 35),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: obscureText, // for hidden text (like password)
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: InputBorder.none, // removes underline
                    hintStyle: const TextStyle(color: Colors.grey),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: onToggleVisibility,
                    ),
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
            color: Color.fromARGB(255, 69, 100, 201),
            thickness: 1.5,
            height: 0,
          ),
        ],
      ),
    );
  }
}
