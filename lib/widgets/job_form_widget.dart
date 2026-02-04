import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import '../services/job_service.dart';
import '../services/image_upload_service.dart';
import '../screens/search/city_selection_page.dart';

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
  final _skillsController = TextEditingController();

  String _selectedJobType = 'Full-time';
  String _selectedAttendance = 'On site';
  int _minExperience = 0;
  int _maxExperience = 1;
  bool _isFeatured = false;
  bool _isLoading = false;
  File? _selectedImage;

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
    
    _skillsController.text = job.skills.join(', ');
    _selectedJobType = job.jobType;
    _selectedAttendance = job.attendance;
    
    // Safely parse experience range values
    _minExperience = _parseIntValue(job.experienceRange['min'], 0);
    _maxExperience = _parseIntValue(job.experienceRange['max'], 1);
    
    _isFeatured = job.isFeatured;
    
    // For existing jobs, we don't pre-select an image file
    _selectedImage = null;
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

  Future<void> _pickImage({ImageSource source = ImageSource.gallery}) async {
    try {
      final File? imageFile = await ImageUploadService.pickImage(source: source);
      if (imageFile != null) {
        setState(() {
          _selectedImage = imageFile;
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

  void _removeImage() {
    setState(() {
      _selectedImage = null;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _workingHoursController.dispose();
    _descriptionController.dispose();
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
        // Update existing job - don't include imageUrl when editing
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
          // Don't include imageUrl when editing existing jobs
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
          imageFile: _selectedImage,
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
        backgroundColor: const Color.fromARGB(255, 69, 100, 201),
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
              _buildLocationSelector(),
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

              // Image picker - only show for new jobs, not when editing
              if (widget.existingJob == null) ...[
                _buildImagePicker(),
                const SizedBox(height: 16),
              ],

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
                activeColor: const Color.fromARGB(255, 69, 100, 201),
              ),
              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 69, 100, 201),
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
              borderSide: const BorderSide(color: Color.fromARGB(255, 69, 100, 201)),
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

  Widget _buildLocationSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final selectedCity = await Navigator.push<String?>(
              context,
              MaterialPageRoute(
                builder: (context) => CitySelectionPage(
                  selectedCity: _locationController.text.isNotEmpty ? _locationController.text : null,
                ),
              ),
            );
            if (selectedCity != null) {
              setState(() {
                _locationController.text = selectedCity;
              });
            } else if (selectedCity == null && _locationController.text.isNotEmpty) {
              setState(() {
                _locationController.text = '';
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _locationController.text.isEmpty
                    ? const Color(0xFFE0E0E0)
                    : const Color.fromARGB(255, 69, 100, 201),
                width: _locationController.text.isEmpty ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _locationController.text.isNotEmpty
                        ? _locationController.text
                        : 'Select job location',
                    style: TextStyle(
                      fontSize: 16,
                      color: _locationController.text.isNotEmpty
                          ? Colors.black87
                          : Colors.grey[600],
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: Colors.grey[600],
                ),
              ],
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
              borderSide: const BorderSide(color: Color.fromARGB(255, 69, 100, 201)),
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
              borderSide: const BorderSide(color: Color.fromARGB(255, 69, 100, 201)),
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

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Job Image (optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E1E1E),
          ),
        ),
        const SizedBox(height: 8),
        
        if (_selectedImage != null) ...[
          // Show selected image
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.file(
                _selectedImage!,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _pickImage(source: ImageSource.gallery),
                  icon: const Icon(Icons.photo_library),
                  label: const Text('Change Image'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 69, 100, 201),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _removeImage,
                  icon: const Icon(Icons.delete),
                  label: const Text('Remove'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ] else ...[
          // Show image picker buttons
          Container(
            width: double.infinity,
            height: 200,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(0xFFE0E0E0),
                style: BorderStyle.solid,
                width: 2,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.add_photo_alternate,
                  size: 48,
                  color: Color(0xFF9E9E9E),
                ),
                const SizedBox(height: 8),
                const Text(
                  'No image selected',
                  style: TextStyle(
                    color: Color(0xFF9E9E9E),
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(source: ImageSource.gallery),
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Gallery'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 69, 100, 201),
                        foregroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () => _pickImage(source: ImageSource.camera),
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Camera'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 69, 100, 201),
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
