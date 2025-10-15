import 'package:flutter/material.dart';
import 'package:loopflutter/widgets/profile_widgets/dynamic_gradient_button.dart';
import 'package:loopflutter/services/agent_service.dart';
import 'package:loopflutter/utils/phone_validator.dart';
import 'package:loopflutter/utils/password_validator.dart';

class EditAgentScreen extends StatefulWidget {
  final Map<String, dynamic> agent;
  
  const EditAgentScreen({super.key, required this.agent});

  @override
  State<EditAgentScreen> createState() => _EditAgentScreenState();
}

class _EditAgentScreenState extends State<EditAgentScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();
  
  // Form controllers
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _countryController = TextEditingController();
  final _governanceController = TextEditingController();
  final _districtController = TextEditingController();
  final _cityController = TextEditingController();
  final _portfolioLinkController = TextEditingController();
  
  // Form state
  String? _selectedGender;
  DateTime? _selectedDOB;
  String? _selectedRole;
  bool _isLoading = false;
  String? _errorMessage;
  
  // Social links
  List<Map<String, String>> _socialLinks = [];
  
  // Gender options
  final List<String> _genderOptions = ['male', 'female'];
  
  // Role options
  final List<String> _roleOptions = ['user', 'agent-individual', 'agent-company'];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
    _initializeForm();
  }

  void _initializeForm() {
    // Initialize form fields with agent data
    _firstNameController.text = widget.agent['firstName'] ?? '';
    _lastNameController.text = widget.agent['lastName'] ?? '';
    _emailController.text = widget.agent['email'] ?? '';
    _phoneController.text = widget.agent['phone'] ?? '';
    _descriptionController.text = widget.agent['description'] ?? '';
    _countryController.text = widget.agent['country'] ?? '';
    _governanceController.text = widget.agent['governance'] ?? '';
    _districtController.text = widget.agent['district'] ?? '';
    _cityController.text = widget.agent['city'] ?? '';
    _portfolioLinkController.text = widget.agent['portfolioLink'] ?? '';
    
    _selectedGender = widget.agent['gender'];
    _selectedRole = widget.agent['role'];
    
    // Initialize DOB
    if (widget.agent['DOB'] != null) {
      try {
        _selectedDOB = DateTime.parse(widget.agent['DOB']);
      } catch (e) {
        print('Error parsing DOB: $e');
      }
    }
    
    // Initialize social links
    if (widget.agent['socialLinks'] != null && widget.agent['socialLinks'] is List) {
      _socialLinks = List<Map<String, String>>.from(
        widget.agent['socialLinks'].map((link) => Map<String, String>.from(link))
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _descriptionController.dispose();
    _countryController.dispose();
    _governanceController.dispose();
    _districtController.dispose();
    _cityController.dispose();
    _portfolioLinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      body: Stack(
        children: [
          Container(
            height: 75,
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(1.018, 1.3934),
                radius: 1.0,
                colors: [
                  Color(0xFF82A6FF),
                  Color(0xFF487CFF),
                  Color(0xFF3770FF),
                  Color(0xFF0048FF),
                ],
                stops: [0.0, 0.3221, 0.7212, 1.0],
              ),
            ),
          ),

          Positioned(
            top: 20,
            left: 16,
            child: SizedBox(
              width: 30,
              height: 30,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: const Color(0xFF0048FF),
                    width: 1,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                ),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Color(0xFF0048FF),
                    size: 16,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
          ),

          Positioned(
            top: 25,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "Edit Agent",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 95, left: 16, right: 16),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline, color: Colors.red.shade600, size: 20),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(color: Colors.red.shade600),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Required Fields Section
                    _buildSectionTitle('Required Information'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _firstNameController,
                      label: 'First Name',
                      hint: 'Enter first name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'First name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _lastNameController,
                      label: 'Last Name',
                      hint: 'Enter last name',
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Last name is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      hint: 'Enter email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _phoneController,
                      label: 'Phone',
                      hint: 'Enter phone number',
                      icon: Icons.phone_outlined,
                      keyboardType: TextInputType.phone,
                      validator: (value) {
                        return PhoneValidator.validatePhoneNumber(value ?? '');
                      },
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _passwordController,
                      label: 'Password (leave blank to keep current)',
                      hint: 'Enter new password',
                      icon: Icons.lock_outline,
                      obscureText: true,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          return PasswordValidator.validatePassword(value);
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Role Dropdown
                    _buildRoleDropdown(),
                    const SizedBox(height: 24),

                    // Optional Fields Section
                    _buildSectionTitle('More Information'),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _descriptionController,
                      label: 'Description',
                      hint: 'Enter description',
                      icon: Icons.description_outlined,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Date of Birth
                    _buildDateField(),
                    const SizedBox(height: 16),

                    // Gender Dropdown
                    _buildGenderDropdown(),
                    const SizedBox(height: 16),

                    // Location Fields
                    _buildTextField(
                      controller: _countryController,
                      label: 'Country',
                      hint: 'Enter country',
                      icon: Icons.public_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _governanceController,
                      label: 'Governance/State',
                      hint: 'Enter governance or state',
                      icon: Icons.location_city_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _districtController,
                      label: 'District',
                      hint: 'Enter district',
                      icon: Icons.location_on_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _cityController,
                      label: 'City',
                      hint: 'Enter city',
                      icon: Icons.location_city_outlined,
                    ),
                    const SizedBox(height: 16),

                    _buildTextField(
                      controller: _portfolioLinkController,
                      label: 'Portfolio Link',
                      hint: 'Enter portfolio URL',
                      icon: Icons.link_outlined,
                      keyboardType: TextInputType.url,
                      validator: (value) {
                        if (value != null && value.isNotEmpty) {
                          try {
                            Uri.parse(value);
                          } catch (e) {
                            return 'Invalid URL format';
                          }
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Social Links Section
                    _buildSocialLinksSection(),
                    const SizedBox(height: 24),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Color(0xFF1D1D1D),
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1D1D1D),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          maxLines: maxLines,
          validator: validator,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: const Color(0xFF0048FF), size: 20),
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF9AA3AF)),
            enabledBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF), width: 1.2),
            ),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF), width: 1.4),
            ),
            border: const UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF)),
            ),
            contentPadding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildRoleDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Role',
          style: TextStyle(
            color: Color(0xFF1D1D1D),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedRole,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.work_outline, color: Color(0xFF0048FF), size: 20),
            hintText: 'Select role',
            hintStyle: TextStyle(color: Color(0xFF9AA3AF)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF), width: 1.2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF), width: 1.4),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          items: _roleOptions.map((String role) {
            return DropdownMenuItem<String>(
              value: role,
              child: Text(role == 'user' ? 'USER' : role.replaceAll('-', ' ').toUpperCase()),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedRole = newValue;
            });
          },
        ),
      ],
    );
  }

  Widget _buildDateField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Date of Birth',
          style: TextStyle(
            color: Color(0xFF1D1D1D),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: _selectDate,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFF0048FF), width: 1.2),
              ),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today_outlined, color: Color(0xFF0048FF), size: 20),
                const SizedBox(width: 12),
                Text(
                  _selectedDOB != null
                      ? '${_selectedDOB!.day}/${_selectedDOB!.month}/${_selectedDOB!.year}'
                      : 'Select date of birth',
                  style: TextStyle(
                    color: _selectedDOB != null ? const Color(0xFF1D1D1D) : const Color(0xFF9AA3AF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Gender',
          style: TextStyle(
            color: Color(0xFF1D1D1D),
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          decoration: const InputDecoration(
            prefixIcon: Icon(Icons.person_outline, color: Color(0xFF0048FF), size: 20),
            hintText: 'Select gender',
            hintStyle: TextStyle(color: Color(0xFF9AA3AF)),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF), width: 1.2),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF), width: 1.4),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: Color(0xFF0048FF)),
            ),
            contentPadding: EdgeInsets.symmetric(vertical: 14),
          ),
          items: _genderOptions.map((String gender) {
            return DropdownMenuItem<String>(
              value: gender,
              child: Text(gender.toUpperCase()),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedGender = newValue;
            });
          },
        ),
      ],
    );
  }


  Widget _buildSocialLinksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Text(
              'Social Links',
              style: TextStyle(
                color: Color(0xFF1D1D1D),
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            TextButton.icon(
              onPressed: _addSocialLink,
              icon: const Icon(Icons.add, color: Color(0xFF0048FF), size: 16),
              label: const Text(
                'Add Link',
                style: TextStyle(color: Color(0xFF0048FF)),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._socialLinks.asMap().entries.map((entry) {
          int index = entry.key;
          Map<String, String> link = entry.value;
          return _buildSocialLinkRow(index, link);
        }).toList(),
      ],
    );
  }

  Widget _buildSocialLinkRow(int index, Map<String, String> link) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0048FF), width: 1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: TextFormField(
              initialValue: link['name'] ?? '',
              decoration: const InputDecoration(
                labelText: 'Platform',
                hintText: 'e.g., LinkedIn, Twitter',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                _socialLinks[index]['name'] = value;
              },
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: TextFormField(
              initialValue: link['link'] ?? '',
              decoration: const InputDecoration(
                labelText: 'URL',
                hintText: 'https://...',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onChanged: (value) {
                _socialLinks[index]['link'] = value;
              },
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => _removeSocialLink(index),
            icon: const Icon(Icons.delete_outline, color: Colors.red),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: const Color(0xFF0048FF), width: 1.5),
            ),
            child: TextButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: TextButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                foregroundColor: const Color(0xFF1E1E1E),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ),
        const SizedBox(width: 30),
        Expanded(
          child: DynamicGradientButton(
            buttonText: _isLoading ? 'Updating...' : 'Update Agent',
            onTap: _isLoading ? null : _submitForm,
            padding: const EdgeInsets.symmetric(horizontal: 17, vertical: 7),
            textSize: 18,
          ),
        ),
      ],
    );
  }

  // Helper methods for form functionality
  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDOB ?? DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDOB) {
      setState(() {
        _selectedDOB = picked;
      });
    }
  }

  void _addSocialLink() {
    setState(() {
      _socialLinks.add({'name': '', 'link': ''});
    });
  }

  void _removeSocialLink(int index) {
    setState(() {
      _socialLinks.removeAt(index);
    });
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Filter out empty social links
      final validSocialLinks = _socialLinks
          .where((link) => link['name']?.isNotEmpty == true && link['link']?.isNotEmpty == true)
          .map((link) => {'name': link['name']!, 'link': link['link']!})
          .toList();

      await AgentService.editAgent(
        agentId: widget.agent['_id'],
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
        phone: _phoneController.text.trim(),
        password: _passwordController.text.trim().isNotEmpty ? _passwordController.text : null,
        role: _selectedRole,
        description: _descriptionController.text.trim().isNotEmpty ? _descriptionController.text.trim() : null,
        DOB: _selectedDOB?.toIso8601String(),
        gender: _selectedGender,
        country: _countryController.text.trim().isNotEmpty ? _countryController.text.trim() : null,
        governance: _governanceController.text.trim().isNotEmpty ? _governanceController.text.trim() : null,
        district: _districtController.text.trim().isNotEmpty ? _districtController.text.trim() : null,
        city: _cityController.text.trim().isNotEmpty ? _cityController.text.trim() : null,
        portfolioLink: _portfolioLinkController.text.trim().isNotEmpty ? _portfolioLinkController.text.trim() : null,
        socialLinks: validSocialLinks.isNotEmpty ? validSocialLinks : null,
      );

      if (mounted) {
        Navigator.pop(context, true); // Return true to indicate success
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Agent updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}
