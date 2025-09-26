import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  final List<Map<String, String>> privacySections = const [
    {
      'title': '1. Data Collection',
      'description':
          'We collect information you provide directly and automatically when you use the app.',
    },
    {
      'title': '2. Data Usage',
      'description':
          'Your data is used to improve the app experience and provide personalized content.',
    },
    {
      'title': '3. Data Sharing',
      'description':
          'We do not share your personal information with third parties without your consent.',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: privacySections
          .map(
            (section) => Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    section['title']!,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    section['description']!,
                    style: const TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
