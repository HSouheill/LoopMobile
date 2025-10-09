import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../../widgets/profile_widgets/dynamic_gradient_button.dart';
import '../../../services/service_service.dart';

class AddService extends StatefulWidget {
  const AddService({super.key});

  @override
  State<AddService> createState() => _AddServiceState();
}

class _AddServiceState extends State<AddService> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _portfolioLinkController = TextEditingController();
  
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isFeatured = false;
  String _selectedType = 'individual';
  File? _selectedImage;

  @override
  void dispose() {
    _titleController.dispose();
    _subtitleController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _portfolioLinkController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
      });
    }
  }

  Future<void> _createService() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        final serviceData = {
          'title': _titleController.text.trim(),
          'subtitle': _subtitleController.text.trim(),
          'location': _locationController.text.trim(),
          'email': _emailController.text.trim(),
          'portfolioLink': _portfolioLinkController.text.trim(),
          'isFeatured': _isFeatured,
          'type': _selectedType,
        };

        // Add image URL if image is selected (you might need to upload to a service first)
        if (_selectedImage != null) {
          // For now, we'll use a placeholder. In production, upload to your image service
          serviceData['image'] = 'https://example.com/images/service.jpg';
        }

        final result = await ServiceService.createService(serviceData);
        
        if (result['success']) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Service created successfully!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        } else {
          if (mounted) {
            // Show user-friendly error message
            String errorMessage = result['error'] ?? 'Failed to create service. Please try again.';
            
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(errorMessage),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Dismiss',
                  textColor: Colors.white,
                  onPressed: () {
                    ScaffoldMessenger.of(context).hideCurrentSnackBar();
                  },
                ),
              ),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('An unexpected error occurred. Please try again.'),
              backgroundColor: Colors.red,
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: false,
          flexibleSpace: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/serverProviderBackground.png"),
                    fit: BoxFit.cover,
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
                        size: 14,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Service Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _selectedImage != null
                          ? FileImage(_selectedImage!)
                          : const AssetImage("assets/defaultProfileImage.png") as ImageProvider,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          decoration: const BoxDecoration(
                            color: Color(0xFF0048FF),
                            shape: BoxShape.circle,
                          ),
                          padding: const EdgeInsets.all(8),
                          child: const Icon(
                            Icons.add_a_photo_outlined,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Service Title *',
                  hintText: 'Enter service title',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Title is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Subtitle Field
              TextFormField(
                controller: _subtitleController,
                decoration: const InputDecoration(
                  labelText: 'Service Description',
                  hintText: 'Enter service description',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),

              // Location Field
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'Enter service location',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
              ),
              const SizedBox(height: 16),

              // Email Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Contact Email',
                  hintText: 'Enter contact email',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email),
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    if (!RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Portfolio Link Field
              TextFormField(
                controller: _portfolioLinkController,
                decoration: const InputDecoration(
                  labelText: 'Portfolio Link',
                  hintText: 'Enter portfolio URL',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                keyboardType: TextInputType.url,
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    try {
                      Uri.parse(value);
                    } catch (e) {
                      return 'Please enter a valid URL';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Service Type
              DropdownButtonFormField<String>(
                value: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Service Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'individual', child: Text('Individual')),
                  DropdownMenuItem(value: 'company', child: Text('Company')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedType = value!;
                  });
                },
              ),
              const SizedBox(height: 16),

              // Featured Service Checkbox
              CheckboxListTile(
                title: const Text('Featured Service'),
                subtitle: const Text('Make this service stand out'),
                value: _isFeatured,
                onChanged: (value) {
                  setState(() {
                    _isFeatured = value ?? false;
                  });
                },
                controlAffinity: ListTileControlAffinity.leading,
              ),
              const SizedBox(height: 30),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: DynamicGradientButton(
                  buttonText: _isLoading ? 'Creating...' : 'Add Service',
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textSize: 16.0,
                  onTap: _isLoading ? null : _createService,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
