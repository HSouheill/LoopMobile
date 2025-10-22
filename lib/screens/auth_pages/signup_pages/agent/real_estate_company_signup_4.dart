import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../../../../environment.dart';

class RealEstateCompanySignupPage4 extends StatefulWidget {
  const RealEstateCompanySignupPage4({super.key});

  @override
  State<RealEstateCompanySignupPage4> createState() => _RealEstateCompanySignupPage4State();
}

class _RealEstateCompanySignupPage4State extends State<RealEstateCompanySignupPage4> {
  final ImagePicker _picker = ImagePicker();
  File? _frontIdImage;
  File? _backIdImage;
  File? _selfieImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Get data from previous pages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        // Store the data for final submission
        _firstName = args['firstName'] ?? '';
        _lastName = args['lastName'] ?? '';
        _email = args['email'] ?? '';
        _password = args['password'] ?? '';
        _companyName = args['companyName'] ?? '';
        _phone = args['phone'] ?? '';
        _country = args['country'] ?? '';
        _district = args['district'] ?? '';
        _city = args['city'] ?? '';
      }
    });
  }

  String _firstName = '';
  String _lastName = '';
  String _email = '';
  String _password = '';
  String _companyName = '';
  String _phone = '';
  String _country = '';
  String _district = '';
  String _city = '';

  Future<void> _pickImage(ImageSource source, String imageType) async {
    try {
      final XFile? image = await _picker.pickImage(source: source);
      if (image != null) {
        setState(() {
          switch (imageType) {
            case 'frontId':
              _frontIdImage = File(image.path);
              break;
            case 'backId':
              _backIdImage = File(image.path);
              break;
            case 'selfie':
              _selfieImage = File(image.path);
              break;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _completeSignup() async {
    if (_frontIdImage == null || _backIdImage == null || _selfieImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please upload all required images'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${Environment.apiUrl}users/signup'),
      );

      // Add text fields
      request.fields['firstName'] = _firstName;
      request.fields['lastName'] = _lastName;
      request.fields['email'] = _email;
      request.fields['password'] = _password;
      request.fields['role'] = 'agent-company';
      request.fields['phone'] = _phone;
      request.fields['companyName'] = _companyName;
      request.fields['country'] = _country;
      request.fields['governance'] = 'Central Government';
      request.fields['district'] = _district;
      request.fields['city'] = _city;

      // Add image files
      request.files.add(await http.MultipartFile.fromPath('frontId', _frontIdImage!.path));
      request.files.add(await http.MultipartFile.fromPath('backId', _backIdImage!.path));
      request.files.add(await http.MultipartFile.fromPath('selfie', _selfieImage!.path));

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 202) {
        final data = json.decode(responseBody);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('OTP sent to your phone. Please verify to complete signup.'),
              backgroundColor: Colors.green,
            ),
          );
          // Navigate to OTP verification page
          Navigator.pushNamed(context, '/verifyOtp', arguments: {
            'pendingId': data['pendingId'],
            'phone': _phone,
          });
        }
      } else {
        final errorData = json.decode(responseBody);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errorData['message'] ?? 'Signup failed'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Network error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Widget _buildImageUploadCard({
    required String title,
    required String description,
    required File? image,
    required String imageType,
    required IconData icon,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
            children: [
              Icon(icon, color: Colors.blue, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          // Image preview or upload button
          if (image != null)
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  image,
                  fit: BoxFit.cover,
                ),
              ),
            )
          else
            Container(
              width: double.infinity,
              height: 120,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.cloud_upload_outlined, size: 32, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Tap to upload',
                    style: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                ],
              ),
            ),
          
          const SizedBox(height: 12),
          
          // Upload buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.camera, imageType),
                  icon: const Icon(Icons.camera_alt, size: 18),
                  label: const Text('Camera'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[50],
                    foregroundColor: Colors.blue[700],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(ImageSource.gallery, imageType),
                  icon: const Icon(Icons.photo_library, size: 18),
                  label: const Text('Gallery'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[100],
                    foregroundColor: Colors.grey[700],
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
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
                          'Upload Documents',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please upload the required documents to complete your company registration',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Image upload cards
                    _buildImageUploadCard(
                      title: 'Front ID',
                      description: 'Upload the front side of your ID document',
                      image: _frontIdImage,
                      imageType: 'frontId',
                      icon: Icons.credit_card,
                    ),
                    
                    _buildImageUploadCard(
                      title: 'Back ID',
                      description: 'Upload the back side of your ID document',
                      image: _backIdImage,
                      imageType: 'backId',
                      icon: Icons.credit_card,
                    ),
                    
                    _buildImageUploadCard(
                      title: 'Selfie',
                      description: 'Take a selfie holding your ID document',
                      image: _selfieImage,
                      imageType: 'selfie',
                      icon: Icons.person,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Complete Signup button
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _completeSignup,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          elevation: 0,
                        ),
                        child: _isLoading 
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Complete Signup',
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
            ),
          ),
        ],
      ),
    );
  }
}
