import 'package:flutter/material.dart';
import '../../../../widgets/country_picker_button.dart';

class RealEstateSignupPage2 extends StatefulWidget {
  const RealEstateSignupPage2({super.key});

  @override
  State<RealEstateSignupPage2> createState() => _RealEstateSignupPage2State();
}

class _RealEstateSignupPage2State extends State<RealEstateSignupPage2> {
  final _formKey = GlobalKey<FormState>();
  final _phoneCtrl = TextEditingController();
  String _selectedCountry = '';
  String _selectedDistrict = '';
  String _selectedCity = '';
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
    _phoneCtrl.dispose();
    super.dispose();
  }

  void _next() {
    if (_formKey.currentState!.validate()) {
      Navigator.pushNamed(context, '/realEstateSignup3', arguments: {
        'firstName': _firstName,
        'lastName': _lastName,
        'email': _email,
        'password': _password,
        'phone': '$_selectedCountryCode${_phoneCtrl.text.trim()}',
        'country': _selectedCountry,
        'governance': 'Central Government',
        'district': _selectedDistrict,
        'city': _selectedCity,
      });
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
                'assets/login_page.jpg',
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
                        const Text(
                          'Sign Up',
                          style: TextStyle(
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
                                      if (v == null || v.isEmpty) return 'Required';
                                      if (v.length < 8) return 'Invalid phone';
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          
                          // Select Country
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCountry.isEmpty ? null : _selectedCountry,
                              decoration: InputDecoration(
                                hintText: 'Select Country',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.public, color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                              ),
                              items: ['Lebanon', 'United States', 'United Kingdom', 'France', 'Germany', 'Canada'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCountry = newValue ?? '';
                                });
                              },
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          // Select District
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedDistrict.isEmpty ? null : _selectedDistrict,
                              decoration: InputDecoration(
                                hintText: 'Select District',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.location_city, color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                              ),
                              items: ['Beirut', 'Mount Lebanon', 'North Lebanon', 'South Lebanon', 'Bekaa', 'Nabatieh'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedDistrict = newValue ?? '';
                                });
                              },
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
                          ),
                          const SizedBox(height: 16),
                          
                          
                          // Select City
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[50],
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.grey[200]!),
                            ),
                            child: DropdownButtonFormField<String>(
                              value: _selectedCity.isEmpty ? null : _selectedCity,
                              decoration: InputDecoration(
                                hintText: 'Select City',
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                prefixIcon: Icon(Icons.location_city, color: Colors.grey[400]),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                                suffixIcon: Icon(Icons.arrow_drop_down, color: Colors.grey[400]),
                              ),
                              items: ['Beirut', 'Tripoli', 'Sidon', 'Tyre', 'Zahle', 'Jounieh'].map((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  _selectedCity = newValue ?? '';
                                });
                              },
                              validator: (v) => (v == null || v.isEmpty) ? 'Required' : null,
                            ),
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
                              child: const Text(
                                'Next',
                                style: TextStyle(
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
                              const Text(
                                "Already have an account? ",
                                style: TextStyle(color: Colors.grey),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushNamed(context, '/loginLanding'),
                                child: const Text(
                                  'Log in',
                                  style: TextStyle(
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
