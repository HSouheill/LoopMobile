import 'package:flutter/material.dart';
import '../widgets/auth_button.dart';

class LoginLandingPage extends StatelessWidget {
  const LoginLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Transparent app bar to match your design
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image (full screen)
          Positioned.fill(
            child: Image.asset(
              'assets/images/city_bg.jpg', // swap to your asset path or network image
              fit: BoxFit.cover,
            ),
          ),
          // Bottom sheet style container
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
                  // Primary login button
                  AuthButton(
                    label: 'Log in with Email Address',
                    leadingIcon: Icons.mail_outline,
                    onPressed: () => Navigator.pushNamed(context, '/loginEmail'),
                    // style hint: primary
                    filled: true,
                  ),
                  const SizedBox(height: 12),
                  // Google
                  AuthButton(
                    label: 'Log In With Google',
                    leadingIcon: Icons.g_mobiledata,
                    onPressed: () {
                      // TODO: add google sign-in
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Google Sign-in (stub)')));
                    },
                    filled: false,
                  ),
                  const SizedBox(height: 12),
                  // Apple
                  AuthButton(
                    label: 'Log In With Apple',
                    leadingIcon: Icons.apple,
                    onPressed: () {
                      // TODO: add apple sign-in
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Apple Sign-in (stub)')));
                    },
                    filled: false,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      GestureDetector(
                        onTap: () {
                          // TODO: navigate to sign up
                        },
                        child: const Text(
                          'Sign up',
                          style: TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
                        ),
                      ),
                    ],
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