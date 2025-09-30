// File: lib/services/auth_service.dart

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../environment.dart';

// Updated User class with profileImage field
class User {
  final String id;
  final String name;
  final String fullName;
  final String email;
  final String? location;
  final String? city;
  final String role;
  final bool active;
  final String? profileImage; // Add this field

  User({
    required this.id,
    required this.name,
    required this.fullName,
    required this.email,
    this.location,
    this.city,
    required this.role,
    required this.active,
    this.profileImage, // Add this parameter
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? json['id'] ?? '',
      name: json['name'] ?? json['firstName'] ?? '',
      fullName: json['fullName'] ?? json['firstName'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      location: json['location'],
      city: json['city'],
      role: json['role'] ?? 'user',
      active: json['active'] ?? true,
      profileImage: json['profileImage'], // Add this line
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'fullName': fullName,
      'email': email,
      'location': location,
      'city': city,
      'role': role,
      'active': active,
      'profileImage': profileImage, // Add this line
    };
  }

  // Method to create a copy with updated profile image
  User copyWith({
    String? id,
    String? name,
    String? fullName,
    String? email,
    String? location,
    String? city,
    String? role,
    bool? active,
    String? profileImage,
  }) {
    return User(
      id: id ?? this.id,
      name: name ?? this.name,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      location: location ?? this.location,
      city: city ?? this.city,
      role: role ?? this.role,
      active: active ?? this.active,
      profileImage: profileImage ?? this.profileImage,
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
        final errorData = jsonDecode(response.body);
        print('SignIn error: ${errorData['message']}');
        return false;
      }
    } catch (e) {
      print('SignIn exception: $e');
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
      print('Error loading auth data: $e');
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
}
