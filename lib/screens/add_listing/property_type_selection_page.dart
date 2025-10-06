import 'package:flutter/material.dart';

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
  ];

  final List<Map<String, String>> rentalPeriods = [
    {'value': 'daily', 'label': 'Daily'},
    {'value': 'monthly', 'label': 'Monthly'},
    {'value': 'yearly', 'label': 'Yearly'},
  ];

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
        title: const Text(
          'List Your Property',
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
                          'For Rent',
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
                          'For Sale',
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
                const Text(
                  'Listing Type',
                  style: TextStyle(
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
                  hint: const Text(
                    'Select Type',
                    style: TextStyle(
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
                        type['label']!,
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
              const Text(
                'Rental Period',
                style: TextStyle(
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
                        period['label']!,
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
                      child: const Text(
                        'Clear',
                        style: TextStyle(
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
                      child: const Text(
                        'Next',
                        style: TextStyle(
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
