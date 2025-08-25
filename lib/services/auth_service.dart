class AuthService {
  // Stub sign in method. Replace with your real auth logic (Firebase, REST API, etc.)
  static Future<bool> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    // Example trivial check
    return email.isNotEmpty && password.length >= 6;
  }
}