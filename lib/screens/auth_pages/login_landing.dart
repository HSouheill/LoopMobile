import 'package:flutter/material.dart';
import '../../widgets/auth_button.dart';
import 'package:loopflutter/l10n/app_localizations.dart';

class LoginLandingPage extends StatelessWidget {
  const LoginLandingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
         children: [
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity, // This makes the box stretch to full width
              child: Image.asset(
                'assets/BackgroundLogo.png',
                fit: BoxFit.cover, // Ensures the image covers the full width without distortion
              ),
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
                    label: l10n.logInWithEmailAddress,
                    leadingIcon: Icons.mail_outline,
                    onPressed: () => Navigator.pushNamed(context, '/loginEmail'),
                    filled: true,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.dontHaveAnAccount),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/signupOptions'),
                        child: Text(
                          l10n.signUpButton,
                          style: const TextStyle(color: Colors.blue, decoration: TextDecoration.underline),
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