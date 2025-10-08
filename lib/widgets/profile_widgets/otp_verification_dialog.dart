import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class OtpVerificationDialog extends StatefulWidget {
  final String phoneNumber;
  final Function(String) onVerify;
  final VoidCallback onResend;
  final bool isLoading;

  const OtpVerificationDialog({
    super.key,
    required this.phoneNumber,
    required this.onVerify,
    required this.onResend,
    this.isLoading = false,
  });

  @override
  State<OtpVerificationDialog> createState() => _OtpVerificationDialogState();
}

class _OtpVerificationDialogState extends State<OtpVerificationDialog> {
  final List<TextEditingController> _controllers = List.generate(6, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (index) => FocusNode());
  String _otp = '      '; // Initialize with 6 spaces

  @override
  void initState() {
    super.initState();
    // Set up focus node listeners
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
        // Update the OTP string
        _otp = _otp.substring(0, index) + value + _otp.substring(index + 1);
        
        // Move to next field
        if (index < 5) {
          _focusNodes[index + 1].requestFocus();
        } else {
          _focusNodes[index].unfocus();
        }
      } else if (value.isEmpty) {
        // Clear the current position and move to previous field
        _otp = _otp.substring(0, index) + ' ' + _otp.substring(index + 1);
        if (index > 0) {
          _focusNodes[index - 1].requestFocus();
        }
      }
    });
  }


  bool _isOtpComplete() {
    // Check if all 6 digits are filled (no spaces)
    return _otp.replaceAll(' ', '').length == 6;
  }


  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Stack(
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
            // Header
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0048FF).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Icon(
                    Icons.sms,
                    color: Color(0xFF0048FF),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Verify Phone Number',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E1E1E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Enter the 6-digit code sent to\n${widget.phoneNumber}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // Hidden TextField for capturing full OTP input
            Positioned(
              left: -1000, // Hide it off-screen
              child: TextField(
                autofocus: true,
                keyboardType: TextInputType.number,
                maxLength: 6,
                style: const TextStyle(color: Colors.transparent),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  counterText: '',
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                onChanged: (value) {
                  if (value.length <= 6) {
                    setState(() {
                      // Update all controllers and OTP string
                      for (int i = 0; i < 6; i++) {
                        if (i < value.length) {
                          _controllers[i].text = value[i];
                          _otp = _otp.substring(0, i) + value[i] + _otp.substring(i + 1);
                        } else {
                          _controllers[i].text = '';
                          _otp = _otp.substring(0, i) + ' ' + _otp.substring(i + 1);
                        }
                      }
                    });
                  }
                },
              ),
            ),

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
                    onSubmitted: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _focusNodes[index + 1].requestFocus();
                      }
                    },
                    onTap: () {
                      _controllers[index].selection = TextSelection.fromPosition(
                        TextPosition(offset: _controllers[index].text.length),
                      );
                    },
                  ),
                );
              }),
            ),

            const SizedBox(height: 24),

            // Resend Code Button
            TextButton(
              onPressed: widget.isLoading ? null : widget.onResend,
              child: Text(
                'Resend Code',
                style: TextStyle(
                  color: widget.isLoading ? Colors.grey : const Color(0xFF0048FF),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isOtpComplete() && !widget.isLoading
                    ? () => widget.onVerify(_otp.trim())
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0048FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: widget.isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Cancel Button
            TextButton(
              onPressed: widget.isLoading ? null : () => Navigator.of(context).pop(),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
