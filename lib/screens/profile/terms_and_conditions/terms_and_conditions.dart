import 'package:flutter/material.dart';
import 'privacy_policy.dart';

class TermsAndConditionsPage extends StatefulWidget {
  const TermsAndConditionsPage({super.key});

  @override
  State<TermsAndConditionsPage> createState() => _TermsAndConditionsPageState();
}

class _TermsAndConditionsPageState extends State<TermsAndConditionsPage> {
  bool isTermsActive = true;

  final List<Map<String, String>> termsSections = const [
    {
      'title': '1. License to use',
      'description':
          'You are granted a limited license to access and use this app for personal purposes only.',
    },
    {
      'title': '2. User Responsibilities',
      'description':
          'You agree not to misuse the app and comply with all applicable laws and regulations.',
    },
    {
      'title': '3. Intellectual Property',
      'description':
          'All content in this app is owned by us or our licensors and protected by law.',
    },
  ];

  double getTextWidth(String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.width;
  }

  @override
  Widget build(BuildContext context) {
    final TextStyle activeStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Color(0xFF0ACC00),
    );

    final TextStyle inactiveStyle = const TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    );

    return Scaffold(
      body: Column(
        children: [
          // AppBar with toggle
          SafeArea(
            child: Column(
              children: [
                // Back + Title
                Row(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        width: 30,
                        height: 30,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: const Color(0xFF0048FF),
                            width: 1,
                          ),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(
                            Icons.arrow_back_rounded,
                            color: Color(0xFF0048FF),
                            size: 22,
                          ),
                          onPressed: () {
                            Navigator.pop(context);
                          },
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Center(
                        child: Text(
                          "Terms and Conditions",
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E1E1E),
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 50), // balance spacing
                  ],
                ),

                const SizedBox(height: 16),
                // Tabs Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Terms Tab
                    GestureDetector(
                      onTap: () {
                        setState(() => isTermsActive = true);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Terms & Conditions",
                            style: (isTermsActive ? activeStyle : inactiveStyle)
                                .copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 1,
                            width: getTextWidth(
                              "Terms & Conditions",
                              isTermsActive ? activeStyle : inactiveStyle,
                            ),
                            color: isTermsActive
                                ? const Color(0xFF0ACC00)
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 32),
                    // Privacy Tab
                    GestureDetector(
                      onTap: () {
                        setState(() => isTermsActive = false);
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            "Privacy Policy",
                            style:
                                (!isTermsActive ? activeStyle : inactiveStyle)
                                    .copyWith(fontSize: 14),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            height: 1,
                            width: getTextWidth(
                              "Privacy Policy",
                              !isTermsActive ? activeStyle : inactiveStyle,
                            ),
                            color: !isTermsActive
                                ? const Color(0xFF0ACC00)
                                : Colors.transparent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Body (scrollable area)
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: isTermsActive
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: termsSections
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
                    )
                  : const PrivacyPolicyPage(), // scrollable inside Expanded
            ),
          ),
        ],
      ),
    );
  }
}
