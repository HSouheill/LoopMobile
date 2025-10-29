import 'package:flutter/material.dart';
import '../../widgets/auth_button.dart';

class PreLoginPage extends StatelessWidget {
  const PreLoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // The background image is now correctly placed and scaled to fit the entire screen.
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height, // Make the image fill the entire screen height
              child: Image.asset(
                'assets/BackgroundLogo.png',
                fit: BoxFit.cover,
                // The alignment ensures the image is centered, which is good practice.
                alignment: Alignment.center,
              ),
            ),
          ),
          // The bottom sheet style container remains the same.
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(blurRadius: 10, color: Colors.black12, offset: Offset(0, -4)),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 8),
                  // Login button that navigates directly to email login.
                  AuthButton(
                    label: 'Log In',
                    leadingIcon: Icons.login,
                    onPressed: () => Navigator.pushNamed(context, '/loginEmail'),
                    filled: true,
                  ),
                  const SizedBox(height: 12),
                  // Signup button placeholder.
                  AuthButton(
                    label: 'Sign Up',
                    leadingIcon: Icons.person_add_alt,
                    onPressed: () => Navigator.pushNamed(context, '/signupOptions'),
                    filled: false,
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
