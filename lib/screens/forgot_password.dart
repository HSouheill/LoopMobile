import 'package:flutter/material.dart';
// import '../services/auth_service.dart'; // Commented out as this is a new page and auth service functions may differ.

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  // A GlobalKey to hold the state of the form, used for validation.
  final _formKey = GlobalKey<FormState>();
  // A controller for the input field (email or phone number).
  final _inputCtrl = TextEditingController();
  // A boolean to control the loading state of the button.
  bool _loading = false;
  // A boolean to toggle between phone number and email input.
  bool _isPhoneSelected = true;

  @override
  void dispose() {
    // Dispose the controller to free up resources.
    _inputCtrl.dispose();
    super.dispose();
  }

  // This function simulates the password reset logic.
  Future<void> _submit() async {
    // Validate the form before proceeding.
    if (!_formKey.currentState!.validate()) return;
    
    // Set loading state to true to show the progress indicator.
    setState(() => _loading = true);

    // Simulate an asynchronous API call for password reset.
    // In a real app, you would call a function from an authentication service here,
    // like AuthService.resetPassword(input).
    await Future.delayed(const Duration(seconds: 2));

    setState(() => _loading = false);

    // Check if the simulated operation was successful.
    final ok = _inputCtrl.text.isNotEmpty; // A simple check to simulate success.
    
    // Show a snackbar message based on the result.
    if (ok) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reset link/code sent successfully!')));
      // Optionally navigate back to the login page after success.
      // Navigator.of(context).pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to send reset link/code. Please check your input.')));
    }
  }

  @override
  Widget build(BuildContext context) {
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
                'assets/Background.png',
                fit: BoxFit.cover,
                // Add a color filter for a darker overlay to make the text on top more readable.
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
                  BoxShadow(blurRadius: 10, color: Colors.black12, offset: Offset(0, -4)),
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
                        const Text(
                          'Forgot Password',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    // Descriptive text
                    Text(
                      _isPhoneSelected ? 
                      'Enter your phone number below. We\'ll send a verification code to proceed with resetting your password' :
                      'Enter your email address below. We\'ll send a password reset link to proceed with resetting your password',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Input field (Email or Phone)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: _isPhoneSelected ? 
                              // Phone number input with country code picker
                              Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                    child: Row(
                                      children: const [
                                        // Flag placeholder
                                        CircleAvatar(
                                          radius: 12,
                                          backgroundColor: Colors.grey,
                                          child: Icon(Icons.flag, size: 16, color: Colors.white),
                                        ),
                                        SizedBox(width: 8),
                                        Text('+961', style: TextStyle(color: Colors.black)),
                                        Icon(Icons.arrow_drop_down, color: Colors.black),
                                      ],
                                    ),
                                  ),
                                  // Divider
                                  Container(
                                    width: 1,
                                    height: 30,
                                    color: Colors.grey[200],
                                  ),
                                  Expanded(
                                    child: TextFormField(
                                      controller: _inputCtrl,
                                      decoration: InputDecoration(
                                        hintText: '00 123 456',
                                        hintStyle: TextStyle(color: Colors.grey[400]),
                                        border: InputBorder.none,
                                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                      ),
                                      keyboardType: TextInputType.phone,
                                      validator: (v) {
                                        if (v == null || v.isEmpty) return 'Please enter your phone number';
                                        return null;
                                      },
                                    ),
                                  ),
                                ],
                              ) :
                              // Email input
                              TextFormField(
                                controller: _inputCtrl,
                                decoration: InputDecoration(
                                  hintText: 'Enter Email Address',
                                  hintStyle: TextStyle(color: Colors.grey[400]),
                                  prefixIcon: Icon(Icons.mail_outline, color: Colors.grey[400]),
                                  border: InputBorder.none,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Please enter your email';
                                  if (!v.contains('@') || !v.contains('.')) return 'Enter a valid email';
                                  return null;
                                },
                              ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Next button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _loading ? null : _submit,
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
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Next',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Links at the bottom
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              GestureDetector(
                                onTap: () => Navigator.pop(context),
                                child: const Text(
                                  'Back to Login',
                                  style: TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 32),
                              GestureDetector(
                                // Toggles the input type between phone and email
                                onTap: () {
                                  setState(() {
                                    _isPhoneSelected = !_isPhoneSelected;
                                    // Clear the input field when toggling to avoid validation issues.
                                    _inputCtrl.clear();
                                  });
                                },
                                child: Text(
                                  _isPhoneSelected ? 'Verify By Email' : 'Verify By Phone',
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    decoration: TextDecoration.underline,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
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
