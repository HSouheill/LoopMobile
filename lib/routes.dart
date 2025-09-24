import 'package:flutter/widgets.dart';
import 'screens/auth_pages/login_landing.dart';
import 'screens/auth_pages/login_email.dart';
import 'screens/auth_pages/pre_login_page.dart';
import 'screens/auth_pages/forgot_password.dart'; // Import the new forgot password page
import 'screens/dashboards/dashboard.dart';
import 'screens/profile/profile.dart';
import 'screens/services/jobs.dart';
import 'screens/listings/featured_listings_page.dart';
import 'screens/listings/listings.dart';
import 'screens/profile/help_and_support.dart';
import 'screens/profile/terms_and_conditions/terms_and_conditions.dart';
import 'screens/profile/favorites.dart';
import 'screens/profile/referrals.dart';
import 'screens/profile/profile-dashboard.dart';

Map<String, WidgetBuilder> appRoutes() {
  return {
    '/loginLanding': (_) => const LoginLandingPage(),
    '/loginEmail': (_) => const LoginEmailPage(),
    '/preLogin': (context) => const PreLoginPage(),
    '/forgotPassword': (_) => const ForgotPasswordPage(), // Add the new route
    '/dashboard': (context) => const DashboardPage(),
    '/profile': (context) => const ProfileScreen(),
    '/jobs': (context) => const JobsPage(),
    '/featured-listings': (context) => const FeaturedListingsPage(),
    '/listings': (context) => const ListingsPage(),
    '/help-and-support': (context) => const HelpAndSupportPage(),
    '/terms-and-conditions': (context) => const TermsAndConditionsPage(),
    '/favorites': (context) => const FavoritesPage(),
    '/referrals': (context) => const ReferralsPage(),
    '/profile-dashboard': (context) => const ProfileDashboardPage(),
  };
}
