import 'package:flutter/material.dart';
import '../../../widgets/auth_button.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SignupOptionsPage extends StatelessWidget {
  const SignupOptionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Background image
          Align(
            alignment: Alignment.topCenter,
            child: SizedBox(
              width: double.infinity,
              child: Image.asset(
                'assets/BackgroundLogo.png',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  // Fallback if image doesn't exist
                  return Container(
                    height: 200,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Colors.blue.shade100, Colors.white],
                      ),
                    ),
                  );
                },
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

                  // Header with back button and title
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(Icons.arrow_back, size: 24),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        l10n.signUpAs,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // User signup option
                  _buildSignupOption(
                    icon: Icons.person_outline,
                    label: l10n.user,
                    onTap: () {
                      Navigator.pushNamed(context, '/userSignup1');
                    },
                  ),
                  const SizedBox(height: 12),

                  // Real Estate signup option
                  _buildSignupOption(
                    icon: Icons.business_outlined,
                    label: l10n.realEstate,
                    onTap: () {
                      Navigator.pushNamed(context, '/realEstateLanding');
                    },
                    hasBadge: true,
                  ),
                  const SizedBox(height: 12),

                  // Service Provider signup option
                  _buildSignupOption(
                    icon: Icons.home_work_outlined,
                    label: l10n.serviceProvider,
                    onTap: () {
                      Navigator.pushNamed(context, '/serviceProviderLanding');
                    },
                  ),

                  const SizedBox(height: 24),

                  // Already have an account link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(l10n.alreadyHaveAnAccount),
                      GestureDetector(
                        onTap: () => Navigator.pushNamed(context, '/loginLanding'),
                        child: Text(
                          l10n.logIn,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
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

  Widget _buildSignupOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool hasBadge = false,
  }) {
    // Use the shared AuthButton so it matches PreLoginPage styling.
    // Wrap in a SizedBox to keep the same height as the previous options.
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: AuthButton(
            label: label,
            leadingIcon: icon,
            onPressed: onTap,
            filled: false, // matches the 'Sign Up' in PreLoginPage (unfilled)
          ),
        ),

        // Optional badge (keeps the previous hasBadge behavior)
      
      ],
    );
  }
}
