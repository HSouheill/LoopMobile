// File: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../environment.dart';

// UserOptions class to handle user preferences
class UserOptions {
  final bool hideSocialLinks;
  final bool hideContactInfo;
  final bool newMessagesNotifications;
  final bool listingApprovalNotifications;
  final bool serviceRequestsNotifications;
  final bool promotionsNotifications;

  UserOptions({
    this.hideSocialLinks = false,
    this.hideContactInfo = false,
    this.newMessagesNotifications = true,
    this.listingApprovalNotifications = true,
    this.serviceRequestsNotifications = true,
    this.promotionsNotifications = true,
  });

  factory UserOptions.fromJson(Map<String, dynamic> json) {
    return UserOptions(
      hideSocialLinks: _parseBool(json['hide_social_links']) ?? false,
      hideContactInfo: _parseBool(json['hide_contact_info']) ?? false,
      newMessagesNotifications: _parseBool(json['new_messages_notifications']) ?? true,
      listingApprovalNotifications: _parseBool(json['listing_approval_notifications']) ?? true,
      serviceRequestsNotifications: _parseBool(json['service_requests_notifications']) ?? true,
      promotionsNotifications: _parseBool(json['promotions_notifications']) ?? true,
    );
  }

  // Helper method to safely parse boolean values
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'hide_social_links': hideSocialLinks,
      'hide_contact_info': hideContactInfo,
      'new_messages_notifications': newMessagesNotifications,
      'listing_approval_notifications': listingApprovalNotifications,
      'service_requests_notifications': serviceRequestsNotifications,
      'promotions_notifications': promotionsNotifications,
    };
  }

  UserOptions copyWith({
    bool? hideSocialLinks,
    bool? hideContactInfo,
    bool? newMessagesNotifications,
    bool? listingApprovalNotifications,
    bool? serviceRequestsNotifications,
    bool? promotionsNotifications,
  }) {
    return UserOptions(
      hideSocialLinks: hideSocialLinks ?? this.hideSocialLinks,
      hideContactInfo: hideContactInfo ?? this.hideContactInfo,
      newMessagesNotifications: newMessagesNotifications ?? this.newMessagesNotifications,
      listingApprovalNotifications: listingApprovalNotifications ?? this.listingApprovalNotifications,
      serviceRequestsNotifications: serviceRequestsNotifications ?? this.serviceRequestsNotifications,
      promotionsNotifications: promotionsNotifications ?? this.promotionsNotifications,
    );
  }
}

// Updated User class with profileImage field and options
class User {
  final String id;
  final String name;
  final String fullName;
  final String email;
  final String? phone;
  final String? location;
  final String? city;
  final String role;
  final bool active;
  final String? profileImage; // Add this field
  final String? portfolioLink; // Add portfolio link field
  final String? companyName; // Add company name field
  final UserOptions? options; // Add options field

  User({
    required this.id,
    required this.name,
    required this.fullName,
    required this.email,
    this.phone,
    this.location,
    this.city,
    required this.role,
    required this.active,
    this.profileImage, // Add this parameter
    this.portfolioLink, // Add portfolio link parameter
    this.companyName, // Add company name parameter
    this.options, // Add options parameter
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Simplified fullName parsing to avoid complex ternary
    String fullName;
    if (json['fullName'] != null) {
      fullName = json['fullName'].toString();
    } else {
      final role = json['role']?.toString() ?? '';
      if (role == 'agent-company' || role == 'service-provider-company') {
        fullName = json['companyName']?.toString() ?? 
                  json['firstName']?.toString() ?? 
                  json['name']?.toString() ?? '';
      } else {
        fullName = json['firstName']?.toString() ?? 
                  json['name']?.toString() ?? '';
      }
    }

    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['firstName'] ?? '',
      fullName: fullName,
      email: json['email'] ?? '',
      phone: json['phone'],
      location: json['location'],
      city: json['city'],
      role: json['role'] ?? 'user',
      active: json['active'] != null ? _parseBool(json['active']) ?? true : true,
      profileImage: json['profileImage'],
      portfolioLink: json['portfolioLink'],
      companyName: json['companyName'],
      options: json['options'] != null ? UserOptions.fromJson(json['options']) : null,
    );
  }

  // Helper method to safely parse boolean values
  static bool? _parseBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'location': location,
      'city': city,
      'role': role,
      'active': active,
      'profileImage': profileImage, // Add this line
      'portfolioLink': portfolioLink, // Add portfolio link
      'companyName': companyName, // Add company name
      'options': options?.toJson(),
    };
  }

  // Method to create a copy with updated profile image
  User copyWith({
    String? id,
    String? name,
    String? fullName,
    String? email,
    String? phone,
    String? location,
    String? city,
    String? role,
    bool? active,
    String? profileImage,
    String? portfolioLink,
    String? companyName,
    UserOptions? options,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      city: city ?? this.city,
      role: role ?? this.role,
      active: active ?? this.active,
      profileImage: profileImage ?? this.profileImage,
      portfolioLink: portfolioLink ?? this.portfolioLink,
      companyName: companyName ?? this.companyName,
      options: options ?? this.options,
    );
  }
}

class AuthService {
  static User? _currentUser;
  static String? _token;

  static User? get currentUser => _currentUser;
  static String? get token => _token;
  static bool get isLoggedIn => _currentUser != null && _token != null;

  // Sign in with email, username, or phone number
  static Future<bool> signIn(String input, String password,
      {bool isPhone = false}) async {
    try {
      Map<String, String> bodyData;

      if (isPhone) {
        // Phone number login
        bodyData = {'phone': input, 'password': password};
      } else {
        // Determine if the input is an email or a username based on the '@' symbol
        final isEmail = input.contains('@');
        bodyData = isEmail
            ? {'email': input.toLowerCase(), 'password': password}
            : {'name': input, 'password': password};
      }

      final url = Uri.parse('${Environment.apiUrl}users/signin');
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(bodyData),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _currentUser = User.fromJson(data['user']);

        // Store in SharedPreferences for persistent login
        await _storeAuthData();

        return true;
      } else {
        // Handle error response from the server
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  // Store authentication data
  static Future<void> _storeAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('auth_token', _token!);
    }
    if (_currentUser != null) {
      await prefs.setString('user_data', jsonEncode(_currentUser!.toJson()));
    }
  }

  // Load authentication data from storage
  static Future<bool> loadAuthData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      final userData = prefs.getString('user_data');

      if (token != null && userData != null) {
        _token = token;
        _currentUser = User.fromJson(jsonDecode(userData));
        return true;
      }
    } catch (e) {
      // Error loading auth data
    }
    return false;
  }

  // Update current user and persist to storage
  static Future<void> updateCurrentUser(User updatedUser) async {
    _currentUser = updatedUser;
    await _storeAuthData();
  }

  // Sign out
  static Future<void> signOut() async {
    _currentUser = null;
    _token = null;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_data');
  }

  // Check if user is authenticated and token is valid
  static Future<bool> checkAuthStatus() async {
    if (!isLoggedIn) {
      return await loadAuthData();
    }
    return true;
  }

  // Get headers for authenticated requests
  static Map<String, String> getAuthHeaders() {
    return {
      'Content-Type': 'application/json',
      if (_token != null) 'Authorization': 'Bearer $_token',
    };
  }

  // Change password for authenticated users
  static Future<Map<String, dynamic>> changePassword(String newPassword) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}users/changePasswordAuthenticated');
      final response = await http.post(
        url,
        headers: getAuthHeaders(),
        body: jsonEncode({
          'newPassword': newPassword,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        return {
          'success': true,
          'message': data['message'] ?? 'Password changed successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to change password',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Request edit contact (email/phone) with OTP
  static Future<Map<String, dynamic>> requestEditContact({
    String? newEmail,
    String? newPhone,
  }) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}users/request-edit-contact');
      final response = await http.post(
        url,
        headers: getAuthHeaders(),
        body: jsonEncode({
          if (newEmail != null) 'newEmail': newEmail,
          if (newPhone != null) 'newPhone': newPhone,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 202) {
        return {
          'success': true,
          'message': data['message'] ?? 'OTP sent successfully',
          'pendingEditId': data['pendingEditId'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to send OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Verify OTP for edit contact
  static Future<Map<String, dynamic>> verifyEditOtp({
    required String pendingEditId,
    required String otp,
  }) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}users/verify-edit-otp');
      final response = await http.post(
        url,
        headers: getAuthHeaders(),
        body: jsonEncode({
          'pendingEditId': pendingEditId,
          'otp': otp,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Update current user with new data
        if (data['user'] != null) {
          _currentUser = User.fromJson(data['user']);
          await _storeAuthData();
        }
        
        // Update token if provided
        if (data['token'] != null) {
          _token = data['token'];
          await _storeAuthData();
        }

        return {
          'success': true,
          'message': data['message'] ?? 'Contact info updated successfully',
          'user': data['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to verify OTP',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Handle signup completion with token and user data
  static Future<bool> completeSignup(String token, Map<String, dynamic> userData) async {
    try {
      _token = token;
      _currentUser = User.fromJson(userData);

      // Store in SharedPreferences for persistent login
      await _storeAuthData();

      return true;
    } catch (e) {
      return false;
    }
  }

  // Update user options
  static Future<Map<String, dynamic>> updateUserOptions({
    bool? hideSocialLinks,
    bool? hideContactInfo,
    bool? newMessagesNotifications,
    bool? listingApprovalNotifications,
    bool? serviceRequestsNotifications,
    bool? promotionsNotifications,
  }) async {
    try {
      final url = Uri.parse('${Environment.apiUrl}users/update-options');
      final response = await http.put(
        url,
        headers: getAuthHeaders(),
        body: jsonEncode({
          if (hideSocialLinks != null) 'hide_social_links': hideSocialLinks,
          if (hideContactInfo != null) 'hide_contact_info': hideContactInfo,
          if (newMessagesNotifications != null) 'new_messages_notifications': newMessagesNotifications,
          if (listingApprovalNotifications != null) 'listing_approval_notifications': listingApprovalNotifications,
          if (serviceRequestsNotifications != null) 'service_requests_notifications': serviceRequestsNotifications,
          if (promotionsNotifications != null) 'promotions_notifications': promotionsNotifications,
        }),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Update current user with new options
        if (_currentUser != null && data['options'] != null) {
          final updatedOptions = UserOptions.fromJson(data['options']);
          final updatedUser = _currentUser!.copyWith(options: updatedOptions);
          _currentUser = updatedUser;
          await _storeAuthData();
        }

        return {
          'success': true,
          'message': data['message'] ?? 'User options updated successfully',
          'options': data['options'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to update user options',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }

  // Delete user account
  static Future<Map<String, dynamic>> deleteAccount() async {
    try {
      final url = Uri.parse('${Environment.apiUrl}users/delete-account');
      final response = await http.delete(
        url,
        headers: getAuthHeaders(),
      );

      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200) {
        // Clear user data after successful deletion
        await signOut();
        
        return {
          'success': true,
          'message': data['message'] ?? 'Account deleted successfully',
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Failed to delete account',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Network error occurred',
      };
    }
  }
}
