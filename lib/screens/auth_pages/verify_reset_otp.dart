import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../services/auth_service.dart';

class VerifyResetOtpPage extends StatefulWidget {
  const VerifyResetOtpPage({super.key});

  @override
  State<VerifyResetOtpPage> createState() => _VerifyResetOtpPageState();
}

class _VerifyResetOtpPageState extends State<VerifyResetOtpPage> {
  final List<TextEditingController> _controllers =
      List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(6, (index) => FocusNode());
  String _otp = '      ';
  bool _loading = false;
  bool _resending = false;

  // These will be set from route arguments
  String? _email;
  String? _phone;
  bool _isPhone = true;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < _focusNodes.length; i++) {
      _focusNodes[i].addListener(() {
        if (_focusNodes[i].hasFocus) {
          _controllers[i].selection = TextSelection.fromPosition(
            TextPosition(offset: _controllers[i].text.length),
          );
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null) {
      _email = args['email'];
      _phone = args['phone'];
      _isPhone = args['isPhone'] ?? (_phone != null);
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _onDigitChanged(String value, int index) {
    setState(() {
      if (value.length == 1) {
        _otp = _otp.substring(0, index) + value + _otp.substring(index + 1);
        if (index < 5) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      } else if (value.isEmpty) {
        _otp = _otp.substring(0, index) + ' ' + _otp.substring(index + 1);
        if (index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    });
  }

  bool _isOtpComplete() {
    return _otp.replaceAll(' ', '').length == 6;
  }

  Future<void> _verifyOtp() async {
    if (!_isOtpComplete()) return;

    setState(() => _loading = true);

    final result = await AuthService.verifyResetOtp(
      email: _email,
      phone: _phone,
      otp: _otp.trim(),
    );

    setState(() => _loading = false);

    if (!mounted) return;

    if (result['success'] == true) {
      final pendingId = result['pendingId'];
      Navigator.pushReplacementNamed(
        context,
        '/resetPassword',
        arguments: {'pendingId': pendingId},
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Verification failed')),
      );
    }
  }

  Future<void> _resendOtp() async {
    setState(() => _resending = true);

    await AuthService.forgotPassword(
      email: _email,
      phone: _phone,
    );

    setState(() => _resending = false);
  }

  String get _displayContact {
    if (_isPhone && _phone != null) {
      return _phone!;
    } else if (_email != null) {
      return _email!;
    }
    return '';
  }

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
                color: Colors.black.withOpacity(0.5),
                colorBlendMode: BlendMode.darken,
              ),
            ),
          ),

          // Bottom sheet style container
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    blurRadius: 10,
                    color: Colors.black12,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Back button and title
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: const Icon(Icons.arrow_back, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          l10n.verifyOtpTitle,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Description
                    Text(
                      l10n.enter6DigitCode(_displayContact),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Warning message about verifying contact info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Colors.orange.shade700,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Please make sure your ${_isPhone ? 'phone number' : 'email'} is correct before entering the OTP code.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange.shade900,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // OTP Input Fields
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) {
                        return Container(
                          width: 45,
                          height: 55,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: _controllers[index].text.isNotEmpty
                                  ? const Color(0xFF0048FF)
                                  : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                            color: _controllers[index].text.isNotEmpty
                                ? const Color(0xFF0048FF).withOpacity(0.05)
                                : Colors.grey.shade50,
                          ),
                          child: TextField(
                            controller: _controllers[index],
                            focusNode: _focusNodes[index],
                            textAlign: TextAlign.center,
                            keyboardType: TextInputType.number,
                            maxLength: 1,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E1E1E),
                            ),
                            decoration: const InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              contentPadding: EdgeInsets.zero,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(1),
                            ],
                            onChanged: (value) => _onDigitChanged(value, index),
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 24),

                    // Resend Code Button
                    Center(
                      child: TextButton(
                        onPressed: _resending ? null : _resendOtp,
                        child: _resending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : Text(
                                l10n.resendCode,
                                style: const TextStyle(
                                  color: Color(0xFF0048FF),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed:
                            _isOtpComplete() && !_loading ? _verifyOtp : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor:
                                      AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                l10n.verify,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Back to login
                    Center(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.popUntil(
                            context,
                            (route) =>
                                route.settings.name == '/loginEmail' ||
                                route.settings.name == '/loginLanding' ||
                                route.isFirst,
                          );
                        },
                        child: Text(
                          l10n.backToLogin,
                          style: const TextStyle(
                            color: Colors.blue,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
