import 'package:flutter/material.dart';
import '../screens/profile/terms_and_conditions/terms_and_conditions.dart';

class TermsPrivacyAgreement extends StatefulWidget {
  final bool isAgreed;
  final ValueChanged<bool> onChanged;

  const TermsPrivacyAgreement({
    super.key,
    required this.isAgreed,
    required this.onChanged,
  });

  @override
  State<TermsPrivacyAgreement> createState() => _TermsPrivacyAgreementState();
}

class _TermsPrivacyAgreementState extends State<TermsPrivacyAgreement> {
  bool _isAgreed = false;

  @override
  void initState() {
    super.initState();
    _isAgreed = widget.isAgreed;
  }

  @override
  void didUpdateWidget(TermsPrivacyAgreement oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAgreed != oldWidget.isAgreed) {
      _isAgreed = widget.isAgreed;
    }
  }

  void _navigateToTermsAndConditions() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const TermsAndConditionsPage(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Checkbox(
                value: _isAgreed,
                onChanged: (value) {
                  setState(() {
                    _isAgreed = value ?? false;
                  });
                  widget.onChanged(_isAgreed);
                },
                activeColor: Colors.blue,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'I agree to the Terms of Service and Privacy Policy',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: _navigateToTermsAndConditions,
                          child: const Text(
                            'Terms of Service',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Text(
                          ' and ',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                        GestureDetector(
                          onTap: _navigateToTermsAndConditions,
                          child: const Text(
                            'Privacy Policy',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!_isAgreed)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 40),
              child: Text(
                'You must agree to the Terms of Service and Privacy Policy to continue',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.red[600],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
