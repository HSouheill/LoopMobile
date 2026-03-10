import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import '../../../../widgets/country_picker_button.dart';

class UserSignupPage2 extends StatefulWidget {
  const UserSignupPage2({super.key});

  @override
  State<UserSignupPage2> createState() => _UserSignupPage2State();
}

class _UserSignupPage2State extends State<UserSignupPage2> {
  final _formKey = GlobalKey<FormState>();
  final _dateOfBirthCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  String _selectedGender = '';
  String _selectedCountryCode = '+961';
  String _selectedCountryFlag = '🇱🇧';

  @override
  void initState() {
    super.initState();
    // Get data from previous page
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        // Store the data for final submission
        _firstName = args['firstName'] ?? '';
        _lastName = args['lastName'] ?? '';
        _email = args['email'] ?? '';
        _password = args['password'] ?? '';
      }
    });
  }

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';

  @override
  void dispose() {
    _dateOfBirthCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, '/userSignup3', arguments: {
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'password': _password,
        'dateOfBirth': _dateOfBirthCtrl.text.trim(),
        'gender': _selectedGender,
        'phone': '$_selectedCountryCode${_phoneCtrl.text.trim()}',
      });
    }
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
                errorBuilder: (context, error, stackTrace) {
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
                        Text(
                          l10n.signUp,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Form
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Date of Birth and Gender
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: TextFormField(
                                    controller: _dateOfBirthCtrl,
                                    decoration: InputDecoration(
                                      hintText: l10n.dateOfBirth,
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[400]),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    readOnly: true,
                                    onTap: () async {
                                      final date = await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now().subtract(const Duration(days: 6570)), // 18 years ago
                                        firstDate: DateTime(1900),
                                        lastDate: DateTime.now(),
                                      );
                                      if (date != null) {
                                        _dateOfBirthCtrl.text = '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
                                      }
                                    },
                                    validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: DropdownButtonFormField<String>(
                                    value: _selectedGender.isEmpty ? null : _selectedGender,
                                    decoration: InputDecoration(
                                      hintText: l10n.gender,
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      prefixIcon: Icon(Icons.person_outline, color: Colors.grey[400]),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    items: [
                                      {'label': l10n.male, 'value': 'Male'},
                                      {'label': l10n.female, 'value': 'Female'},
                                      {'label': l10n.other, 'value': 'Other'}
                                    ].map((item) {
                                      return DropdownMenuItem<String>(
                                        value: item['value'],
                                        child: Text(item['label']!),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        _selectedGender = newValue ?? '';
                                      });
                                    },
                                    validator: (v) => (v == null || v.isEmpty) ? l10n.required : null,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Phone Number
                          Row(
                            children: [
                              CountryPickerButton(
                                selectedCode: _selectedCountryCode,
                                selectedFlag: _selectedCountryFlag,
                                onChanged: (country) {
                                  setState(() {
                                    _selectedCountryCode = country['code']!;
                                    _selectedCountryFlag = country['flag']!;
                                  });
                                },
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.grey[50],
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.grey[200]!),
                                  ),
                                  child: TextFormField(
                                    controller: _phoneCtrl,
                                    decoration: InputDecoration(
                                      hintText: '00 123 456',
                                      hintStyle: TextStyle(color: Colors.grey[400]),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                    ),
                                    keyboardType: TextInputType.phone,
                                    validator: (v) {
                                      if (v == null || v.isEmpty) return l10n.required;
                                      if (v.length < 8) return l10n.invalidPhone;
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          
                          // Next button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _next,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                l10n.next,
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),
                          
                          // Already have an account link
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                l10n.alreadyHaveAnAccount,
                                style: const TextStyle(color: Colors.grey),
                              ),
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
