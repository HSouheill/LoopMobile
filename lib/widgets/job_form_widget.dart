import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/job_service.dart';

class JobFormWidget extends StatefulWidget {
  final Job? existingJob;
  final VoidCallback? onSuccess;

  const JobFormWidget({
    super.key,
    this.existingJob,
    this.onSuccess,
  });

  @override
  State<JobFormWidget> createState() => _JobFormWidgetState();
}

class _JobFormWidgetState extends State<JobFormWidget> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _workingHoursController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _imageUrlController = TextEditingController();
  final _skillsController = TextEditingController();

  String _selectedJobType = 'Full-time';
  String _selectedAttendance = 'On site';
  int _minExperience = 0;
  int _maxExperience = 1;
  bool _isFeatured = false;
  bool _isLoading = false;

  final List<String> _jobTypes = [
    'Full-time',
    'Part-time',
    'Contract',
    'Internship',
    'Freelance'
  ];

  final List<String> _attendanceTypes = [
    'On site',
    'Online',
    'Hybrid',
    'Remote'
  ];

  @override
  void initState() {
    super.initState();
    if (widget.existingJob != null) {
      _populateForm();
    }
  }

  void _populateForm() {
    final job = widget.existingJob!;
    _titleController.text = job.title;
    _locationController.text = job.location;
    _workingHoursController.text = job.workingHours;
    _descriptionController.text = job.description;
    _imageUrlController.text = job.imageUrl;
    _skillsController.text = job.skills.join(', ');
    _selectedJobType = job.jobType;
    _selectedAttendance = job.attendance;
    
    // Safely parse experience range values
    _minExperience = _parseIntValue(job.experienceRange['min'], 0);
    _maxExperience = _parseIntValue(job.experienceRange['max'], 1);
    
    _isFeatured = job.isFeatured;
  }

  int _parseIntValue(dynamic value, int defaultValue) {
    if (value is int) {
      return value;
    }
    if (value != null) {
      return int.tryParse(value.toString()) ?? defaultValue;
    }
    return defaultValue;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _workingHoursController.dispose();
    _descriptionController.dispose();
    _imageUrlController.dispose();
    _skillsController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    // Validate experience range
    if (_maxExperience < _minExperience) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Maximum experience must be greater than or equal to minimum experience'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final skills = _skillsController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .where((s) => s.length <= 100) // Backend constraint: maxlength 100
          .toList();

      if (widget.existingJob != null) {
        // Update existing job
        await JobService.updateJob(
          jobId: widget.existingJob!.id,
          title: _titleController.text.trim(),
          location: _locationController.text.trim(),
          jobType: _selectedJobType,
          experienceRange: {
            'min': _minExperience,
            'max': _maxExperience,
          },
          workingHours: _workingHoursController.text.trim(),
          attendance: _selectedAttendance,
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : null,
          skills: skills.isNotEmpty ? skills : null,
          isFeatured: _isFeatured,
        );
      } else {
        // Create new job
        await JobService.createJob(
          title: _titleController.text.trim(),
          location: _locationController.text.trim(),
          jobType: _selectedJobType,
          experienceRange: {
            'min': _minExperience,
            'max': _maxExperience,
          },
          workingHours: _workingHoursController.text.trim(),
          attendance: _selectedAttendance,
          description: _descriptionController.text.trim(),
          imageUrl: _imageUrlController.text.trim().isNotEmpty
              ? _imageUrlController.text.trim()
              : null,
          skills: skills.isNotEmpty ? skills : null,
          isFeatured: _isFeatured,
        );
      }

      // Success - show success message and navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.existingJob != null
                ? 'Job updated successfully!'
                : 'Job created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        
        if (widget.onSuccess != null) {
          widget.onSuccess!();
        }
        
        Navigator.of(context).pop();
      }
    } catch (e) {
      // Error - show error message but don't navigate back
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingJob != null ? 'Edit Job' : 'Create New Job'),
        backgroundColor: const Color(0xFF0048FF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              _buildTextField(
                controller: _titleController,
                label: 'Job Title',
                hint: 'Enter job title',
                maxLength: 200,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Job title is required';
                  }
                  if (value.trim().length > 200) {
                    return 'Job title must be 200 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Location
              _buildTextField(
                controller: _locationController,
                label: 'Location',
                hint: 'Enter job location',
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Location is required';
                  }
                  if (value.trim().length > 100) {
                    return 'Location must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Job Type
              _buildDropdown(
                label: 'Job Type',
                value: _selectedJobType,
                items: _jobTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedJobType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Attendance
              _buildDropdown(
                label: 'Attendance',
                value: _selectedAttendance,
                items: _attendanceTypes,
                onChanged: (value) {
                  setState(() {
                    _selectedAttendance = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Experience Range
              Row(
                children: [
                  Expanded(
                    child: _buildNumberField(
                      label: 'Min Experience (years)',
                      value: _minExperience,
                      onChanged: (value) {
                        setState(() {
                          _minExperience = value;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildNumberField(
                      label: 'Max Experience (years)',
                      value: _maxExperience,
                      onChanged: (value) {
                        setState(() {
                          _maxExperience = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Working Hours
              _buildTextField(
                controller: _workingHoursController,
                label: 'Working Hours',
                hint: 'e.g., 9AM-5PM',
                maxLength: 100,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Working hours is required';
                  }
                  if (value.trim().length > 100) {
                    return 'Working hours must be 100 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Description
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Enter job description',
                maxLines: 4,
                maxLength: 2000,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Description is required';
                  }
                  if (value.trim().length > 2000) {
                    return 'Description must be 2000 characters or less';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Skills
              _buildTextField(
                controller: _skillsController,
                label: 'Skills (comma-separated)',
                hint: 'e.g., JavaScript, React, Node.js',
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final skills = value.split(',').map((s) => s.trim()).where((s) => s.isNotEmpty);
                    for (final skill in skills) {
                      if (skill.length > 100) {
                        return 'Each skill must be 100 characters or less';
                      }
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Image URL
              _buildTextField(
                controller: _imageUrlController,
                label: 'Image URL (optional)',
                hint: 'Enter image URL',
              ),
              const SizedBox(height: 16),

              // Featured checkbox
              CheckboxListTile(
                title: const Text('Featured Job'),
                subtitle: const Text('Make this job stand out'),
                value: _isFeatured,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value ?? false;
                  });
                },
                activeColor: const Color(0xFF0048FF),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0048FF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          widget.existingJob != null ? 'Update Job' : 'Create Job',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          maxLength: maxLength,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0048FF)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0048FF)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNumberField({
    required String label,
    required int value,
    required ValueChanged<int> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          initialValue: value.toString(),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(2), // Max 2 digits (0-50)
          ],
          onChanged: (value) {
            final intValue = int.tryParse(value) ?? 0;
            // Ensure value is within backend constraints (0-50)
            final clampedValue = intValue.clamp(0, 50);
            onChanged(clampedValue);
          },
          decoration: InputDecoration(
            hintText: '0',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF0048FF)),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }
}
