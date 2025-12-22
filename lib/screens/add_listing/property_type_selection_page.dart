import 'package:flutter/material.dart';
import 'package:loopflutter/l10n/app_localizations.dart';

class PropertyTypeSelectionPage extends StatefulWidget {
  const PropertyTypeSelectionPage({super.key});

  @override
  State<PropertyTypeSelectionPage> createState() => _PropertyTypeSelectionPageState();
}

class _PropertyTypeSelectionPageState extends State<PropertyTypeSelectionPage> {
  String? selectedListingFor = 'rent'; // Default to rent
  String? selectedPropertyType;
  String? selectedRentalPeriod;

  final List<Map<String, String>> propertyTypes = [
    {'value': 'apartment', 'label': 'Apartment'},
    {'value': 'chalet', 'label': 'Chalet'},
    {'value': 'studio', 'label': 'Studio'},
    {'value': 'commercial', 'label': 'Commercial'},
    {'value': 'villa', 'label': 'Villa'},
    {'value': 'land', 'label': 'Land'},
    {'value': 'industrial', 'label': 'Industrial'},
    {'value': 'room', 'label': 'Room'},
    {'value': 'building', 'label': 'Building'},
    {'value': 'international', 'label': 'International'},
  ];

  final List<Map<String, String>> rentalPeriods = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final String? preselectedType = args?['preselectedType'];
      // Only pre-select if it's a valid property type (not 'property' which is just a generic term)
      if (preselectedType != null && preselectedType != 'property' && mounted) {
        setState(() {
          selectedPropertyType = preselectedType;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String listingType = args?['listingType'] ?? 'owner';

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
          AppLocalizations.of(context)?.listYourProperty ?? 'List Your Property',
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Property listing type selection (For Rent / For Sale)
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedListingFor = 'rent';
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: selectedListingFor == 'rent' 
                            ? const Color(0xFF3B82F6) 
                            : Colors.white,
                        border: Border.all(
                          color: const Color(0xFF3B82F6), 
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)?.forRent ?? 'For Rent',
                          style: TextStyle(
                            color: selectedListingFor == 'rent' 
                                ? Colors.white 
                                : const Color(0xFF3B82F6),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedListingFor = 'sale';
                      });
                    },
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: selectedListingFor == 'sale' 
                            ? const Color(0xFF3B82F6) 
                            : Colors.white,
                        border: Border.all(
                          color: const Color(0xFF3B82F6), 
                          width: 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          AppLocalizations.of(context)?.forSale ?? 'For Sale',
                          style: TextStyle(
                            color: selectedListingFor == 'sale' 
                                ? Colors.white 
                                : const Color(0xFF3B82F6),
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 30),
            // Property type dropdown
            Row(
              children: [
                const Icon(
                  Icons.description,
                  color: Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)?.listingType ?? 'Listing Type',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF3B82F6), width: 1),
                borderRadius: BorderRadius.circular(8),
                color: Colors.grey[50],
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedPropertyType,
                  hint: Text(
                    AppLocalizations.of(context)?.selectType ?? 'Select Type',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                    ),
                  ),
                  isExpanded: true,
                  icon: const Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey,
                  ),
                  items: propertyTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(
                        _localizePropertyType(context, type['value']!),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedPropertyType = newValue;
                    });
                  },
                ),
              ),
            ),
            const SizedBox(height: 30),
            // Rental period selection (only show for rent)
            if (selectedListingFor == 'rent') ...[
              Text(
                AppLocalizations.of(context)?.rentalPeriod ?? 'Rental Period',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 15),
              ...rentalPeriods.map((period) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Radio<String>(
                        value: period['value']!,
                        groupValue: selectedRentalPeriod,
                        onChanged: (String? value) {
                          setState(() {
                            selectedRentalPeriod = value;
                          });
                        },
                        activeColor: const Color(0xFF3B82F6),
                      ),
                      Text(
                        _localizeRentalPeriod(context, period['value']!),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ],
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF3B82F6), width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(
                        AppLocalizations.of(context)?.clear ?? 'Clear',
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Container(
                    height: 50,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: TextButton(
                      onPressed: selectedPropertyType != null && 
                          (selectedListingFor == 'sale' || selectedRentalPeriod != null)
                          ? () {
                              Navigator.pushNamed(
                                context,
                                '/add-listing-form',
                                arguments: {
                                  'listingType': listingType,
                                  'listingFor': selectedListingFor,
                                  'propertyType': selectedPropertyType,
                                  'rentalPeriod': selectedRentalPeriod,
                                },
                              );
                            }
                          : null,
                      child: Text(
                        AppLocalizations.of(context)?.next ?? 'Next',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

String _localizePropertyType(BuildContext context, String value) {
  final l10n = AppLocalizations.of(context);
  switch (value) {
    case 'apartment':
      return l10n?.propertyTypeApartment ?? 'Apartment';
    case 'chalet':
      return l10n?.propertyTypeChalet ?? 'Chalet';
    case 'studio':
      return l10n?.propertyTypeStudio ?? 'Studio';
    case 'commercial':
      return l10n?.propertyTypeCommercial ?? 'Commercial';
    case 'villa':
      return l10n?.propertyTypeVilla ?? 'Villa';
    case 'land':
      return l10n?.propertyTypeLand ?? 'Land';
    case 'industrial':
      return l10n?.propertyTypeIndustrial ?? 'Industrial';
    case 'room':
      return l10n?.propertyTypeRoom ?? 'Room';
    case 'building':
      return l10n?.propertyTypeBuilding ?? 'Building';
    case 'international':
      return l10n?.propertyTypeInternational ?? 'International';
    default:
      return value;
  }
}

String _localizeRentalPeriod(BuildContext context, String value) {
  final l10n = AppLocalizations.of(context);
  switch (value) {
    case 'daily':
      return l10n?.rentalPeriodDaily ?? 'Daily';
    case 'monthly':
      return l10n?.rentalPeriodMonthly ?? 'Monthly';
    case 'yearly':
      return l10n?.rentalPeriodYearly ?? 'Yearly';
    default:
      return value;
  }
}
