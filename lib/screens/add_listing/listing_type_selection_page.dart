import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class ListingTypeSelectionPage extends StatefulWidget {
  const ListingTypeSelectionPage({super.key});

  @override
  State<ListingTypeSelectionPage> createState() => _ListingTypeSelectionPageState();
}

class _ListingTypeSelectionPageState extends State<ListingTypeSelectionPage> {
  String? selectedType;

  final List<Map<String, String>> listingTypes = [
    {'value': 'owner', 'label': 'Property Owner'},
    {'value': 'agent', 'label': 'Real Estate Agent'},
  ];

  @override
  Widget build(BuildContext context) {
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
          AppLocalizations.of(context)?.beforeYouList ?? 'Before You List',
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
            Text(
              AppLocalizations.of(context)?.beforeYouListSubtitle ?? "Let us know if you're the owner of the property or an agent listing on someone's behalf.",
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 30),
            Text(
              AppLocalizations.of(context)?.iAm ?? 'I am..',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
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
                  value: selectedType,
                  hint: Text(
                    AppLocalizations.of(context)?.select ?? 'Select',
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
                  items: listingTypes.map((type) {
                    return DropdownMenuItem<String>(
                      value: type['value'],
                      child: Text(
                        _localizeListingType(context, type['value']!),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedType = newValue;
                    });
                  },
                ),
              ),
            ),
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
                        AppLocalizations.of(context)?.back ?? 'Back',
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
                      onPressed: selectedType != null
                          ? () {
                              Navigator.pushNamed(
                                context,
                                '/property-type-selection',
                                arguments: {'listingType': selectedType},
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

String _localizeListingType(BuildContext context, String value) {
  final l10n = AppLocalizations.of(context);
  switch (value) {
    case 'owner':
      return l10n?.propertyOwner ?? 'Property Owner';
    case 'agent':
      return l10n?.realEstateAgent ?? 'Real Estate Agent';
    default:
      return value;
  }
}
