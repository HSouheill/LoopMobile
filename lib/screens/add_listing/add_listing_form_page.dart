import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/listing_create_service.dart';

class AddListingFormPage extends StatefulWidget {
  const AddListingFormPage({super.key});

  @override
  State<AddListingFormPage> createState() => _AddListingFormPageState();
}

class _AddListingFormPageState extends State<AddListingFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _cityController = TextEditingController();
  final _bedroomsController = TextEditingController();
  final _bathroomsController = TextEditingController();
  final _sizeController = TextEditingController();
  final _floorController = TextEditingController();
  final _buildingAgeController = TextEditingController();

  String? selectedCondition = 'good';
  String? selectedPapers = 'title_deed';
  List<XFile> _selectedImages = [];
  bool _isLoading = false;

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> conditions = [
    {'value': 'new', 'label': 'New'},
    {'value': 'excellent', 'label': 'Excellent'},
    {'value': 'good', 'label': 'Good'},
    {'value': 'needs_renovation', 'label': 'Needs Renovation'},
    {'value': 'old', 'label': 'Old'},
  ];

  final List<Map<String, String>> papers = [
    {'value': 'title_deed', 'label': 'Title Deed'},
    {'value': 'rental_contract', 'label': 'Rental Contract'},
    {'value': 'under_construction', 'label': 'Under Construction'},
    {'value': 'other', 'label': 'Other'},
  ];

  // Amenities
  Map<String, bool> amenities = {
    'furnished': false,
    'terrace': false,
    'privatePool': false,
    'storageRoom': false,
    'sharedPool': false,
    'sharedGym': false,
    'security': false,
    'seaView': false,
    'garden': false,
    'mountainView': false,
    'elevator': false,
    'parking': false,
    'centralAC': false,
    'heating': false,
    'solarSystem': false,
    'electricity24_7': false,
    'maidRoom': false,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    _cityController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    _sizeController.dispose();
    _floorController.dispose();
    _buildingAgeController.dispose();
    super.dispose();
  }

  Future<void> _pickImages() async {
    try {
      final List<XFile> images = await _picker.pickMultiImage();
      setState(() {
        _selectedImages.addAll(images);
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking images: $e')),
      );
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String listingFor = args?['listingFor'] ?? 'rent';
      final String? rentalPeriod = args?['rentalPeriod'];
      final double priceValue = double.tryParse(_priceController.text) ?? 0;
      
      // Determine payment frequency
      String paymentFrequency = 'sale';
      if (listingFor == 'rent') {
        paymentFrequency = rentalPeriod ?? 'monthly'; // Default to monthly if not specified
      }
      
      final listingData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': args?['propertyType'],
        'listingFor': listingFor,
        'price': priceValue,
        'paymentFrequency': paymentFrequency,
        'location': {
          'city': _cityController.text.trim(),
        },
        'bedrooms': int.tryParse(_bedroomsController.text) ?? 0,
        'bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
        'size': double.tryParse(_sizeController.text) ?? 0,
        'floor': _floorController.text.trim(),
        'condition': selectedCondition,
        'buildingAge': int.tryParse(_buildingAgeController.text) ?? 0,
        'papers': selectedPapers,
        'amenities': amenities,
        'images': _selectedImages.map((image) => image.path).toList(),
        'isPublished': false,
        'status': 'pending',
        'currency': 'USD',
      };

      final success = await ListingCreateService.createListing(listingData);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Listing created successfully!')),
        );
        Navigator.popUntil(context, (route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to create listing. Please try again.')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String listingFor = args?['listingFor'] ?? 'rent';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Add Property Details',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Basic Information
              _buildSectionTitle('Basic Information'),
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _titleController,
                label: 'Property Title',
                hint: 'Enter property title',
                validator: (value) => value?.isEmpty == true ? 'Title is required' : null,
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _descriptionController,
                label: 'Description',
                hint: 'Describe your property',
                maxLines: 3,
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _cityController,
                label: 'City',
                hint: 'Enter city',
                validator: (value) => value?.isEmpty == true ? 'City is required' : null,
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _priceController,
                label: listingFor == 'rent' ? 'Rental Price' : 'Sale Price',
                hint: 'Enter price',
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty == true ? 'Price is required' : null,
              ),
              
              const SizedBox(height: 30),
              
              // Property Details
              _buildSectionTitle('Property Details'),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _bedroomsController,
                      label: 'Bedrooms',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: _bathroomsController,
                      label: 'Bathrooms',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _sizeController,
                      label: 'Size (sq ft)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: _floorController,
                      label: 'Floor',
                      hint: 'Ground',
                    ),
                  ),
                ],
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _buildingAgeController,
                label: 'Building Age (years)',
                hint: '0',
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 15),
              
              // Condition Dropdown
              _buildDropdown(
                value: selectedCondition,
                label: 'Condition',
                items: conditions,
                onChanged: (value) => setState(() => selectedCondition = value),
              ),
              
              const SizedBox(height: 15),
              
              // Papers Dropdown
              _buildDropdown(
                value: selectedPapers,
                label: 'Papers',
                items: papers,
                onChanged: (value) => setState(() => selectedPapers = value),
              ),
              
              const SizedBox(height: 30),
              
              // Images
              _buildSectionTitle('Property Images'),
              const SizedBox(height: 15),
              
              GestureDetector(
                onTap: _pickImages,
                child: Container(
                  width: double.infinity,
                  height: 120,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey[300]!, width: 2, style: BorderStyle.solid),
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey[50],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to add images',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              if (_selectedImages.isNotEmpty) ...[
                const SizedBox(height: 15),
                SizedBox(
                  height: 100,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _selectedImages.length,
                    itemBuilder: (context, index) {
                      return Container(
                        margin: const EdgeInsets.only(right: 8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(_selectedImages[index].path),
                            width: 100,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
              
              const SizedBox(height: 30),
              
              // Amenities
              _buildSectionTitle('Amenities'),
              const SizedBox(height: 15),
              
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: amenities.keys.map((key) {
                  return FilterChip(
                    label: Text(_getAmenityLabel(key)),
                    selected: amenities[key]!,
                    onSelected: (selected) {
                      setState(() {
                        amenities[key] = selected;
                      });
                    },
                    selectedColor: const Color(0xFF3B82F6).withOpacity(0.2),
                    checkmarkColor: const Color(0xFF3B82F6),
                  );
                }).toList(),
              ),
              
              const SizedBox(height: 40),
              
              // Create Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitListing,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3B82F6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'Create Listing',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
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
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdown({
    required String? value,
    required String label,
    required List<Map<String, String>> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8),
            color: Colors.grey[50],
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Select $label'),
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item['value'],
                  child: Text(item['label']!),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  String _getAmenityLabel(String key) {
    switch (key) {
      case 'furnished': return 'Furnished';
      case 'terrace': return 'Terrace';
      case 'privatePool': return 'Private Pool';
      case 'storageRoom': return 'Storage Room';
      case 'sharedPool': return 'Shared Pool';
      case 'sharedGym': return 'Shared Gym';
      case 'security': return 'Security';
      case 'seaView': return 'Sea View';
      case 'garden': return 'Garden';
      case 'mountainView': return 'Mountain View';
      case 'elevator': return 'Elevator';
      case 'parking': return 'Parking';
      case 'centralAC': return 'Central AC';
      case 'heating': return 'Heating';
      case 'solarSystem': return 'Solar System';
      case 'electricity24_7': return '24/7 Electricity';
      case 'maidRoom': return 'Maid Room';
      default: return key;
    }
  }
}
