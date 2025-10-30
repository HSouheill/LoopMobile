import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import '../../models/job_detail.dart';
import '../../services/auth_service.dart';
import '../../environment.dart';

class JobApplicationPage extends StatefulWidget {
  final JobDetail job;

  const JobApplicationPage({
    super.key,
    required this.job,
  });

  @override
  State<JobApplicationPage> createState() => _JobApplicationPageState();
}

class _JobApplicationPageState extends State<JobApplicationPage> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _expectedSalaryController = TextEditingController();
  final _experienceController = TextEditingController();
  
  String _selectedCountryCode = '+961';
  bool _isLoading = false;
  bool _isConfirmed = false;
  PlatformFile? _selectedFile;

  final List<String> _countryCodes = ['+961', '+1', '+44', '+33', '+49'];

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _expectedSalaryController.dispose();
    _experienceController.dispose();
    super.dispose();
  }

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx'],
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _selectedFile = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n?.errorPickingFile(e.toString()) ?? 'Error picking file: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _submitApplication() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_isConfirmed) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n?.pleaseConfirmInformationAccurate ?? 'Please confirm that the submitted information is accurate'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Check if user is signed in
    if (!AuthService.isLoggedIn) {
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n?.signInRequired ?? 'Sign In Required'),
            content: Text(l10n?.signInRequiredToApply ?? 'You need to be signed in to apply to jobs. Please sign in and try again.'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(l10n?.ok ?? 'OK'),
              ),
            ],
          ),
        );
      }
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Prepare the request body
      final phone = _selectedCountryCode + _phoneController.text.trim();

      // Create multipart request
      final url = Uri.parse('${Environment.apiUrl}jobs/${widget.job.id}/apply');
      final request = http.MultipartRequest('POST', url);
      
      // Add headers (don't set Content-Type for multipart, http package will handle it)
      if (AuthService.token != null) {
        request.headers['Authorization'] = 'Bearer ${AuthService.token}';
      }
      
      // Add form fields
      request.fields['firstName'] = _firstNameController.text.trim();
      request.fields['lastName'] = _lastNameController.text.trim();
      request.fields['email'] = _emailController.text.trim().toLowerCase();
      request.fields['phone'] = phone;
      request.fields['expectedSalary'] = _expectedSalaryController.text.trim();
      request.fields['experience'] = _experienceController.text.trim();
      
      // Add file if selected
      if (_selectedFile != null && _selectedFile!.path != null) {
        final file = File(_selectedFile!.path!);
        request.files.add(
          await http.MultipartFile.fromPath(
            'portfolio',
            file.path,
            filename: _selectedFile!.name,
          ),
        );
      }
      
      // Send the request
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final data = jsonDecode(response.body);
        
        final l10n = AppLocalizations.of(context);
        if (response.statusCode == 201) {
          // Success
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n?.applicationSubmitted ?? 'Application Submitted'),
              content: Text(l10n?.applicationSubmittedSuccessfully ?? 'Your application has been submitted successfully!'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).pop(); // Go back to job detail page
                  },
                  child: Text(l10n?.ok ?? 'OK'),
                ),
              ],
            ),
          );
        } else if (response.statusCode == 409) {
          // Already applied
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n?.alreadyApplied ?? 'Already Applied'),
              content: Text(data['message'] ?? (l10n?.alreadyAppliedToJob ?? 'You have already applied to this job.')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                  },
                  child: Text(l10n?.ok ?? 'OK'),
                ),
              ],
            ),
          );
        } else {
          // Error
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: Text(l10n?.error ?? 'Error'),
              content: Text(data['message'] ?? (l10n?.failedToSubmitApplication ?? 'Failed to submit application. Please try again.')),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text(l10n?.ok ?? 'OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        final l10n = AppLocalizations.of(context);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n?.error ?? 'Error'),
            content: Text(l10n?.networkError(e.toString()) ?? 'Network error: ${e.toString()}'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text(l10n?.ok ?? 'OK'),
              ),
            ],
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Builder(
          builder: (context) {
            final l10n = AppLocalizations.of(context)!;
            return Text(
              l10n.applicationForm,
              style: const TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            );
          }
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Top Half: Job Details
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Builder(
                    builder: (context) {
                      final l10n = AppLocalizations.of(context)!;
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(
                                Icons.search,
                                color: Color(0xFF1976D2),
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.jobDetails,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _buildJobDetailItem(l10n.experienceRequired, '${widget.job.experienceRange['min'] ?? 0}-${widget.job.experienceRange['max'] ?? 1} years'),
                          _buildJobDetailItem(l10n.skills, widget.job.skills.join(', ')),
                          _buildJobDetailItem(l10n.workingHours, widget.job.workingHours),
                          _buildJobDetailItem(l10n.contractType, widget.job.jobType),
                          _buildJobDetailItem(l10n.jobType, widget.job.attendance),
                          _buildJobDetailItem(l10n.benefits, 'Health Insurance, Paid Leave'),
                        ],
                      );
                    }
                  ),
                ],
              ),
            ),  
            
            // Bottom Half: Application Form
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // First Name and Last Name Row
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _firstNameController,
                                hint: l10n.firstName,
                                icon: Icons.person_outline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _buildTextField(
                                controller: _lastNameController,
                                hint: l10n.lastName,
                                icon: Icons.people_outline,
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return l10n.required;
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                    
                    // Email
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return _buildTextField(
                          controller: _emailController,
                          hint: l10n.enterEmail,
                          icon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.required;
                            }
                            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                              return l10n.invalidEmail;
                            }
                            return null;
                          },
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                    
                    // Phone Number with Country Code
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return TextFormField(
                          controller: _phoneController,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.required;
                            }
                            return null;
                          },
                          style: const TextStyle(fontSize: 14),
                          decoration: InputDecoration(
                            hintText: l10n.phoneNumber,
                        hintStyle: const TextStyle(color: Colors.grey),
                        prefixIcon: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.phone, color: Color(0xFF1976D2), size: 20),
                            const SizedBox(width: 8),
                            Container(
                              width: 80,
                              child: DropdownButton<String>(
                                value: _selectedCountryCode,
                                underline: const SizedBox(),
                                isExpanded: true,
                                style: const TextStyle(fontSize: 14, color: Colors.black),
                                items: _countryCodes.map((String value) {
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value, style: const TextStyle(fontSize: 14)),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    _selectedCountryCode = newValue ?? '+961';
                                  });
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                          ],
                        ),
                        border: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                        enabledBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                        focusedBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
                        ),
                        errorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red),
                        ),
                        focusedErrorBorder: const UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.red, width: 2),
                        ),
                            contentPadding: const EdgeInsets.symmetric(horizontal: 0, vertical: 16),
                          ),
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                    
                    // Expected Salary
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return _buildTextField(
                          controller: _expectedSalaryController,
                          hint: l10n.expectedSalary,
                          icon: Icons.monetization_on_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.required;
                            }
                            return null;
                          },
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                    
                    // Experience
                    Builder(
                      builder: (context) {
                        final l10n = AppLocalizations.of(context)!;
                        return _buildTextField(
                          controller: _experienceController,
                          hint: l10n.experience,
                          icon: Icons.school_outlined,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return l10n.required;
                            }
                            return null;
                          },
                        );
                      }
                    ),
                    const SizedBox(height: 16),
                    
                    // Portfolio Upload
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFF1976D2), width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: InkWell(
                        onTap: _isLoading ? null : _pickFile,
                        borderRadius: BorderRadius.circular(8),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              Icon(
                                Icons.attach_file,
                                color: const Color(0xFF1976D2),
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Builder(
                                      builder: (context) {
                                        final l10n = AppLocalizations.of(context)!;
                                        return Text(
                                          l10n.uploadPortfolioOptional,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                            color: Colors.black87,
                                          ),
                                        );
                                      }
                                    ),
                                    if (_selectedFile != null) ...[
                                      const SizedBox(height: 4),
                                      Text(
                                        _selectedFile!.name,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              if (_selectedFile != null)
                                IconButton(
                                  icon: const Icon(Icons.close, size: 20),
                                  color: Colors.red,
                                  onPressed: _isLoading ? null : () {
                                    setState(() {
                                      _selectedFile = null;
                                    });
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    // Confirmation Checkbox
                    Row(
                      children: [
                        Checkbox(
                          value: _isConfirmed,
                          onChanged: (value) {
                            setState(() {
                              _isConfirmed = value ?? false;
                            });
                          },
                          activeColor: Colors.green,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                        Builder(
                          builder: (context) {
                            final l10n = AppLocalizations.of(context)!;
                            return Expanded(
                              child: Text(
                                l10n.iConfirmInformationAccurate,
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.black87,
                                ),
                              ),
                            );
                          }
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    
                    // Cancel and Apply Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _isLoading ? null : () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              side: const BorderSide(color: Color(0xFF1976D2)),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: Builder(
                              builder: (context) {
                                final l10n = AppLocalizations.of(context)!;
                                return Text(
                                  l10n.cancel,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                );
                              }
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              final l10n = AppLocalizations.of(context)!;
                              return ElevatedButton(
                                onPressed: _isLoading ? null : _submitApplication,
                                style: ElevatedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color(0xFF1976D2),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(25),
                                  ),
                                ),
                                child: _isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                        ),
                                      )
                                    : Text(
                                        l10n.apply,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                              );
                            }
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildJobDetailItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: Color(0xFF1976D2),
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                  color: Colors.black87,
                  fontSize: 14,
                ),
                children: [
                  TextSpan(
                    text: '$label: ',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
      style: const TextStyle(fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey),
        prefixIcon: Icon(icon, color: const Color(0xFF1976D2), size: 20),
        border: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        focusedBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF1976D2), width: 2),
        ),
        errorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red),
        ),
        focusedErrorBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red, width: 2),
        ),
      ),
    );
  }
}

