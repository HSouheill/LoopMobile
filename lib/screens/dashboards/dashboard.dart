// File: lib/screens/dashboard.dart

import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;

    // Route to appropriate dashboard based on user role
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (user != null) {
        String route;
        switch (user.role) {
          case 'agent-individual':
            route = '/agent-individual-dashboard';
            break;
          case 'agent-company':
            route = '/agent-company-dashboard';
            break;
          case 'service-provider-individual':
            route = '/service-provider-individual-dashboard';
            break;
          case 'service-provider-company':
            route = '/service-provider-company-dashboard';
            break;
          default:
            // For 'user' role, stay on this page
            return;
        }
        Navigator.pushReplacementNamed(context, route);
      }
    });

    // Return a minimal scaffold with just a loading indicator
    // The routing logic above will handle navigation to the appropriate dashboard
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

}