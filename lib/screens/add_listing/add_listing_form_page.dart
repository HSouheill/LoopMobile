import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loopflutter/l10n/app_localizations.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../services/listing_create_service.dart';
import '../../services/listing_service.dart';
import '../../utils/verification_guard.dart';
import '../search/city_selection_page.dart';

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

  String? selectedCondition = 'ready';
  String? selectedPapers = 'title_deed';
  String? selectedFurnishing = 'unfurnished';
  List<XFile> _selectedImages = [];
  XFile? _selectedVideo;
  bool _isLoading = false;
  bool _isEditMode = false;
  PropertyListing? _editingListing;
  bool _initialized = false;

  final ImagePicker _picker = ImagePicker();

  final List<Map<String, String>> conditions = [
    {'value': 'under_construction', 'label': 'Under Construction'},
    {'value': 'ready', 'label': 'Ready'},
    {'value': 'needs_renovation', 'label': 'Needs Renovation'},
  ];

  final List<Map<String, String>> papers = [
    {'value': 'title_deed', 'label': 'Title Deed'},
    {'value': 'under_construction', 'label': 'Under Construction'},
    {'value': 'other', 'label': 'Other'},
  ];

  final List<Map<String, String>> furnishingOptions = [
    {'value': 'unfurnished', 'label': 'Unfurnished'},
    {'value': 'semi_furnished', 'label': 'Semi-Furnished'},
    {'value': 'fully_furnished', 'label': 'Fully Furnished'},
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
    'accessible': false,
    'atticLoft': false,
    'builtInKitchenAppliances': false,
    'builtInWardrobes': false,
    'concierge': false,
    'coveredParking': false,
    'fireplace': false,
    'petsAllowed': false,
    'playroom': false,
    'privateGarden': false,
    'privateGym': false,
    'privateJacuzzi': false,
    'sharedSpa': false,
    'studyRoom': false,
    'balcony': false,
    'walkInCloset': false,
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initializeEditMode();
  }

  void _initializeEditMode() {
    if (_initialized) return;
    
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['editMode'] == true && args['listing'] != null) {
      _isEditMode = true;
      _editingListing = args['listing'] as PropertyListing;
      _populateFields();
    }
    _initialized = true;
  }

  void _populateFields() {
    if (_editingListing != null) {
      setState(() {
        _titleController.text = _editingListing!.title;
        _descriptionController.text = _editingListing!.description ?? '';
        _cityController.text = _editingListing!.location;
        
        // Extract price value from formatted price string (convert to integer)
        if (_editingListing!.priceValue != null) {
          _priceController.text = _editingListing!.priceValue!.toInt().toString();
        }
        
        if (_editingListing!.bedrooms != null) {
          _bedroomsController.text = _editingListing!.bedrooms.toString();
        }
        
        if (_editingListing!.bathrooms != null) {
          _bathroomsController.text = _editingListing!.bathrooms.toString();
        }
        
        if (_editingListing!.size != null) {
          _sizeController.text = _editingListing!.size.toString();
        }
        
        if (_editingListing!.floor != null) {
          _floorController.text = _editingListing!.floor.toString();
        }
        
        if (_editingListing!.buildingAge != null) {
          _buildingAgeController.text = _editingListing!.buildingAge.toString();
        }
        
        if (_editingListing!.condition != null) {
          selectedCondition = _editingListing!.condition;
        }
        
        if (_editingListing!.papers != null) {
          selectedPapers = _editingListing!.papers;
        }
        
        if (_editingListing!.furnishing != null) {
          selectedFurnishing = _editingListing!.furnishing;
        }
        
        // Set amenities
        if (_editingListing!.amenityList != null) {
          for (String amenity in _editingListing!.amenityList!) {
            if (amenities.containsKey(amenity)) {
              amenities[amenity] = true;
            }
          }
        }
      });
    }
  }

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
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.errorPickingImages("$e") ?? 'Error picking images: $e')),
      );
    }
  }

  Future<void> _pickVideo() async {
    try {
      final XFile? video = await _picker.pickVideo(source: ImageSource.gallery);
      if (video != null) {
        setState(() {
          _selectedVideo = video;
        });
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.errorPickingImages("$e") ?? 'Error picking video: $e')),
      );
    }
  }

  Future<void> _submitListing() async {
    if (!_formKey.currentState!.validate()) return;

    // Read route args before any async gap (needs a live BuildContext).
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

    // Only admin-approved accounts can create/edit listings (backend enforces
    // this too). Show a clear message instead of a generic failure.
    if (!await VerificationGuard.ensureCanManageContent(context)) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final String listingFor = args?['listingFor'] ?? (_editingListing?.listingFor ?? 'rent');
      final String? rentalPeriod = args?['rentalPeriod'];
      final bool isDailyRentChalet = _isDailyRentChalet(args);
      final int priceValue = int.tryParse(_priceController.text) ?? 0;
      
      // Determine payment frequency - only for rent, must be one of: 'daily', 'monthly', 'yearly'
      String? paymentFrequency;
      if (listingFor == 'rent') {
        // Validate and set paymentFrequency from rentalPeriod
        final validFrequencies = ['daily', 'monthly', 'yearly'];
        if (rentalPeriod != null && validFrequencies.contains(rentalPeriod)) {
          paymentFrequency = rentalPeriod;
        } else if (_editingListing?.paymentFrequency != null && validFrequencies.contains(_editingListing!.paymentFrequency)) {
          // For edit mode, use existing paymentFrequency if available
          paymentFrequency = _editingListing!.paymentFrequency;
        } else {
          // Default to monthly if not specified
          paymentFrequency = 'monthly';
        }
      }
      
      final listingData = {
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'type': args?['propertyType'] ?? _editingListing?.type,
        'listingFor': listingFor,
        'price': priceValue,
        if (paymentFrequency != null) 'paymentFrequency': paymentFrequency,
        'location': {
          'city': _cityController.text.trim(),
        },
        'bedrooms': int.tryParse(_bedroomsController.text) ?? 0,
        'bathrooms': int.tryParse(_bathroomsController.text) ?? 0,
        'size': double.tryParse(_sizeController.text) ?? 0,
        'buildingAge': int.tryParse(_buildingAgeController.text) ?? 0,
        // Floor / Condition / Papers / Furnishing don't apply to daily-rent Chalet
        if (!isDailyRentChalet) ...{
          'floor': _floorController.text.trim(),
          'condition': selectedCondition,
          'papers': selectedPapers,
          if (selectedFurnishing != null) 'furnishing': selectedFurnishing,
        },
        'amenities': amenities,
        'isPublished': false,
        'status': _editingListing?.status ?? 'pending',
        'currency': 'USD',
      };

      bool success;
      if (_isEditMode && _editingListing != null) {
        // Edit existing listing
        success = await ListingService.editListing(_editingListing!.id, listingData);
        
        if (success) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.listingUpdatedSuccessfully ?? 'Listing updated successfully!')),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.failedToUpdateListing ?? 'Failed to update listing. Please try again.')),
          );
        }
      } else {
        // Create new listing
        success = await ListingCreateService.createListing(
          listingData,
          _selectedImages,
          _selectedVideo,
        );
        
        if (success) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.listingCreatedSuccessfully ?? 'Listing created successfully!')),
          );
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n?.failedToCreateListing ?? 'Failed to create listing. Please try again.')),
          );
        }
      }
    } catch (e) {
      final l10n = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n?.genericError("$e") ?? 'Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Daily-rent Chalet hides Floor / Condition / Papers / Furnishing.
  bool _isDailyRentChalet(Map<String, dynamic>? args) {
    final type = args?['propertyType'] ?? _editingListing?.type;
    final period = args?['rentalPeriod'] ?? _editingListing?.paymentFrequency;
    return type == 'chalet' && period == 'daily';
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String listingFor = args?['listingFor'] ?? 'rent';
    final bool isDailyRentChalet = _isDailyRentChalet(args);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditMode
              ? (AppLocalizations.of(context)?.editPropertyDetails ?? 'Edit Property Details')
              : (AppLocalizations.of(context)?.addPropertyDetails ?? 'Add Property Details'),
          style: const TextStyle(
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
              _buildSectionTitle(AppLocalizations.of(context)?.basicInformation ?? 'Basic Information'),
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _titleController,
                label: AppLocalizations.of(context)?.propertyTitle ?? 'Property Title',
                hint: AppLocalizations.of(context)?.enterPropertyTitle ?? 'Enter property title',
                validator: (value) => value?.isEmpty == true ? (AppLocalizations.of(context)?.titleIsRequired ?? 'Title is required') : null,
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _descriptionController,
                label: AppLocalizations.of(context)?.description ?? 'Description',
                hint: AppLocalizations.of(context)?.describeYourProperty ?? 'Describe your property',
                maxLines: 3,
              ),
              
              const SizedBox(height: 15),
              
              _buildCitySelector(context),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _priceController,
                label: listingFor == 'rent'
                    ? (AppLocalizations.of(context)?.rentalPrice ?? 'Rental Price')
                    : (AppLocalizations.of(context)?.salePrice ?? 'Sale Price'),
                hint: AppLocalizations.of(context)?.enterPrice ?? 'Enter price',
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) => value?.isEmpty == true ? (AppLocalizations.of(context)?.priceIsRequired ?? 'Price is required') : null,
              ),
              
              const SizedBox(height: 30),
              
              // Property Details
              _buildSectionTitle(AppLocalizations.of(context)?.propertyDetails ?? 'Property Details'),
              const SizedBox(height: 15),
              
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _bedroomsController,
                      label: AppLocalizations.of(context)?.bedrooms ?? 'Bedrooms',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: _buildTextField(
                      controller: _bathroomsController,
                      label: AppLocalizations.of(context)?.bathrooms ?? 'Bathrooms',
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
                      label: AppLocalizations.of(context)?.sizeSqFt ?? 'Size (sq ft)',
                      hint: '0',
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  // Floor hidden for daily-rent Chalet
                  if (!isDailyRentChalet) ...[
                    const SizedBox(width: 15),
                    Expanded(
                      child: _buildTextField(
                        controller: _floorController,
                        label: AppLocalizations.of(context)?.floor ?? 'Floor',
                        hint: AppLocalizations.of(context)?.ground ?? 'Ground',
                      ),
                    ),
                  ],
                ],
              ),
              
              const SizedBox(height: 15),
              
              _buildTextField(
                controller: _buildingAgeController,
                label: AppLocalizations.of(context)?.buildingAgeYears ?? 'Building Age (years)',
                hint: '0',
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 15),
              
              // Condition / Papers / Furnishing hidden for daily-rent Chalet
              if (!isDailyRentChalet) ...[
                // Condition Dropdown
                _buildDropdown(
                  value: selectedCondition,
                  label: AppLocalizations.of(context)?.condition ?? 'Condition',
                  items: conditions
                      .map((e) => {
                            'value': e['value']!,
                            'label': _localizeConditionLabel(context, e['value']!)
                          })
                      .toList(),
                  onChanged: (value) => setState(() => selectedCondition = value),
                ),

                const SizedBox(height: 15),

                // Papers Dropdown
                _buildDropdown(
                  value: selectedPapers,
                  label: AppLocalizations.of(context)?.papers ?? 'Papers',
                  items: papers
                      .map((e) => {
                            'value': e['value']!,
                            'label': _localizePapersLabel(context, e['value']!)
                          })
                      .toList(),
                  onChanged: (value) => setState(() => selectedPapers = value),
                ),

                const SizedBox(height: 15),

                // Furnishing Dropdown
                _buildDropdown(
                  value: selectedFurnishing,
                  label: 'Furnishing',
                  items: furnishingOptions
                      .map((e) => {
                            'value': e['value']!,
                            'label': _localizeFurnishingLabel(context, e['value']!)
                          })
                      .toList(),
                  onChanged: (value) => setState(() => selectedFurnishing = value),
                ),

                const SizedBox(height: 15),
              ],

              const SizedBox(height: 15),
              
              // Images - Only show for new listings, hide for edit mode
              if (!_isEditMode) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle(AppLocalizations.of(context)?.propertyImages ?? 'Property Images'),
                    if (_selectedImages.isNotEmpty)
                      Text(
                        AppLocalizations.of(context)?.imagesCounter(_selectedImages.length) ?? '${_selectedImages.length}/10 images',
                        style: TextStyle(
                          fontSize: 14,
                          color: _selectedImages.length >= 10 ? Colors.red : Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                
                GestureDetector(
                  onTap: _selectedImages.length >= 10 ? null : _pickImages,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedImages.length >= 10 ? Colors.grey[400]! : Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedImages.length >= 10 ? Colors.grey[200] : Colors.grey[50],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedImages.length >= 10 ? Icons.check_circle : Icons.add_photo_alternate,
                          size: 40,
                          color: _selectedImages.length >= 10 ? Colors.green : Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedImages.length >= 10
                              ? (AppLocalizations.of(context)?.maxImagesReached ?? 'Maximum images reached (10/10)')
                              : (AppLocalizations.of(context)?.tapToAddImages ?? 'Tap to add images'),
                          style: TextStyle(
                            color: _selectedImages.length >= 10 ? Colors.green[700] : Colors.grey[600],
                            fontSize: 16,
                            fontWeight: _selectedImages.length >= 10 ? FontWeight.w600 : FontWeight.normal,
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
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  File(_selectedImages[index].path),
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _selectedImages.removeAt(index);
                                    });
                                  },
                                  child: Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
                
                const SizedBox(height: 30),
                
                // Video Upload Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildSectionTitle('Property Video (Optional)'),
                    if (_selectedVideo != null)
                      Text(
                        'Video selected',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.green[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 15),
                
                GestureDetector(
                  onTap: _pickVideo,
                  child: Container(
                    width: double.infinity,
                    height: 120,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedVideo != null ? Colors.green[400]! : Colors.grey[300]!,
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                      borderRadius: BorderRadius.circular(8),
                      color: _selectedVideo != null ? Colors.green[50] : Colors.grey[50],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          _selectedVideo != null ? Icons.check_circle : Icons.videocam,
                          size: 40,
                          color: _selectedVideo != null ? Colors.green : Colors.grey[400],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _selectedVideo != null
                              ? 'Video selected. Tap to change'
                              : 'Tap to add video (optional)',
                          style: TextStyle(
                            color: _selectedVideo != null ? Colors.green[700] : Colors.grey[600],
                            fontSize: 16,
                            fontWeight: _selectedVideo != null ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                if (_selectedVideo != null) ...[
                  const SizedBox(height: 15),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[50],
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.video_file, color: Colors.grey[700]),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _selectedVideo!.name,
                            style: TextStyle(
                              color: Colors.grey[700],
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedVideo = null;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              
              const SizedBox(height: 30),
              
              // Amenities
              _buildSectionTitle(AppLocalizations.of(context)?.amenities ?? 'Amenities'),
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
                      : Text(
                          _isEditMode
                              ? (AppLocalizations.of(context)?.updateListing ?? 'Update Listing')
                              : (AppLocalizations.of(context)?.createListing ?? 'Create Listing'),
                          style: const TextStyle(
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
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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

  Widget _buildCitySelector(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n?.city ?? 'City',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () async {
            final selectedCity = await Navigator.push<String?>(
              context,
              MaterialPageRoute(
                builder: (context) => CitySelectionPage(
                  selectedCity: _cityController.text.isNotEmpty ? _cityController.text : null,
                ),
              ),
            );
            if (selectedCity != null) {
              setState(() {
                _cityController.text = selectedCity;
              });
            } else if (selectedCity == null && _cityController.text.isNotEmpty) {
              // User selected "All" - clear the city
              setState(() {
                _cityController.text = '';
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(
                color: _cityController.text.isEmpty ? Colors.grey[300]! : const Color(0xFF3B82F6),
                width: _cityController.text.isEmpty ? 1 : 2,
              ),
              borderRadius: BorderRadius.circular(8),
              color: Colors.grey[50],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _cityController.text.isNotEmpty
                        ? _cityController.text
                        : (l10n?.enterCity ?? 'Select city'),
                    style: TextStyle(
                      fontSize: 16,
                      color: _cityController.text.isNotEmpty ? Colors.black87 : Colors.grey[600],
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
    final l10n = AppLocalizations.of(context);
    switch (key) {
      case 'furnished': return l10n?.amenityFurnished ?? 'Furnished';
      case 'terrace': return l10n?.amenityTerrace ?? 'Terrace';
      case 'privatePool': return l10n?.amenityPrivatePool ?? 'Private Pool';
      case 'storageRoom': return l10n?.amenityStorageRoom ?? 'Storage Room';
      case 'sharedPool': return l10n?.amenitySharedPool ?? 'Shared Pool';
      case 'sharedGym': return l10n?.amenitySharedGym ?? 'Shared Gym';
      case 'security': return l10n?.amenitySecurity ?? 'Security';
      case 'seaView': return l10n?.amenitySeaView ?? 'Sea View';
      case 'garden': return l10n?.amenityGarden ?? 'Garden';
      case 'mountainView': return l10n?.amenityMountainView ?? 'Mountain View';
      case 'elevator': return l10n?.amenityElevator ?? 'Elevator';
      case 'parking': return l10n?.amenityParking ?? 'Parking';
      case 'centralAC': return l10n?.amenityCentralAC ?? 'Central AC';
      case 'heating': return l10n?.amenityHeating ?? 'Heating';
      case 'solarSystem': return l10n?.amenitySolarSystem ?? 'Solar System';
      case 'electricity24_7': return l10n?.amenityElectricity247 ?? '24/7 Electricity';
      case 'maidRoom': return l10n?.amenityMaidRoom ?? 'Maid Room';
      case 'accessible': return 'Accessible';
      case 'atticLoft': return 'Attic/Loft';
      case 'builtInKitchenAppliances': return 'Built-in Kitchen Appliances';
      case 'builtInWardrobes': return 'Built-in Wardrobes';
      case 'concierge': return 'Concierge';
      case 'coveredParking': return 'Covered Parking';
      case 'fireplace': return 'Fireplace';
      case 'petsAllowed': return 'Pets Allowed';
      case 'playroom': return 'Playroom';
      case 'privateGarden': return 'Private Garden';
      case 'privateGym': return 'Private Gym';
      case 'privateJacuzzi': return 'Private Jacuzzi';
      case 'sharedSpa': return 'Shared Spa';
      case 'studyRoom': return 'Study Room';
      case 'balcony': return 'Balcony';
      case 'walkInCloset': return 'Walk-in Closet';
      default: return key;
    }
  }

  String _localizeConditionLabel(BuildContext context, String value) {
    switch (value) {
      case 'under_construction':
        return 'Under Construction';
      case 'ready':
        return 'Ready';
      case 'needs_renovation':
        return 'Needs Renovation';
      default:
        return value;
    }
  }

  String _localizePapersLabel(BuildContext context, String value) {
    final l10n = AppLocalizations.of(context);
    switch (value) {
      case 'title_deed':
        return l10n?.papersTitleDeed ?? 'Title Deed';
      case 'rental_contract':
        return l10n?.papersRentalContract ?? 'Rental Contract';
      case 'under_construction':
        return l10n?.papersUnderConstruction ?? 'Under Construction';
      case 'other':
        return l10n?.papersOther ?? 'Other';
      default:
        return value;
    }
  }

  String _localizeFurnishingLabel(BuildContext context, String value) {
    switch (value) {
      case 'unfurnished':
        return 'Unfurnished';
      case 'semi_furnished':
        return 'Semi-Furnished';
      case 'fully_furnished':
        return 'Fully Furnished';
      default:
        return value;
    }
  }
}
