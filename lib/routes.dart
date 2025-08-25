import 'package:flutter/widgets.dart';
import 'screens/login_landing.dart';
import 'screens/login_email.dart';

Map<String, WidgetBuilder> appRoutes() {
  return {
    '/loginLanding': (_) => const LoginLandingPage(),
    '/loginEmail': (_) => const LoginEmailPage(),
  };
}