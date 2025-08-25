import 'package:flutter/widgets.dart';
import 'screens/login_landing.dart';
import 'screens/login_email.dart';
import 'screens/pre_login_page.dart';
import 'screens/forgot_password.dart'; // Import the new forgot password page

Map<String, WidgetBuilder> appRoutes() {
  return {
    '/loginLanding': (_) => const LoginLandingPage(),
    '/loginEmail': (_) => const LoginEmailPage(),
    '/preLogin': (context) => const PreLoginPage(),
    '/forgotPassword': (_) => const ForgotPasswordPage(), // Add the new route
  };
}