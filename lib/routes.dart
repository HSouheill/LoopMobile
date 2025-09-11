import 'package:flutter/widgets.dart';
import 'screens/auth_pages/login_landing.dart';
import 'screens/auth_pages/login_email.dart';
import 'screens/auth_pages/pre_login_page.dart';
import 'screens/auth_pages/forgot_password.dart'; // Import the new forgot password page
import 'screens/dashboards/dashboard.dart';
import 'screens/profile/profile.dart';

Map<String, WidgetBuilder> appRoutes() {
  return {
    '/loginLanding': (_) => const LoginLandingPage(),
    '/loginEmail': (_) => const LoginEmailPage(),
    '/preLogin': (context) => const PreLoginPage(),
    '/forgotPassword': (_) => const ForgotPasswordPage(), // Add the new route
    '/dashboard': (context) => const DashboardPage(),
    '/profile': (context) => const ProfileScreen(),
  };
}