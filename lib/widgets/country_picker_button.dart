import 'package:flutter/material.dart';

const List<Map<String, String>> kCountries = [
  {'code': '+961', 'flag': '🇱🇧', 'name': 'Lebanon'},
  {'code': '+971', 'flag': '🇦🇪', 'name': 'UAE'},
  {'code': '+966', 'flag': '🇸🇦', 'name': 'Saudi Arabia'},
  {'code': '+965', 'flag': '🇰🇼', 'name': 'Kuwait'},
  {'code': '+974', 'flag': '🇶🇦', 'name': 'Qatar'},
  {'code': '+973', 'flag': '🇧🇭', 'name': 'Bahrain'},
  {'code': '+968', 'flag': '🇴🇲', 'name': 'Oman'},
  {'code': '+962', 'flag': '🇯🇴', 'name': 'Jordan'},
  {'code': '+963', 'flag': '🇸🇾', 'name': 'Syria'},
  {'code': '+964', 'flag': '🇮🇶', 'name': 'Iraq'},
  {'code': '+20', 'flag': '🇪🇬', 'name': 'Egypt'},
  {'code': '+212', 'flag': '🇲🇦', 'name': 'Morocco'},
  {'code': '+216', 'flag': '🇹🇳', 'name': 'Tunisia'},
  {'code': '+213', 'flag': '🇩🇿', 'name': 'Algeria'},
  {'code': '+249', 'flag': '🇸🇩', 'name': 'Sudan'},
  {'code': '+218', 'flag': '🇱🇾', 'name': 'Libya'},
  {'code': '+967', 'flag': '🇾🇪', 'name': 'Yemen'},
  {'code': '+970', 'flag': '🇵🇸', 'name': 'Palestine'},
  {'code': '+1', 'flag': '🇺🇸', 'name': 'United States'},
  {'code': '+44', 'flag': '🇬🇧', 'name': 'United Kingdom'},
  {'code': '+33', 'flag': '🇫🇷', 'name': 'France'},
  {'code': '+49', 'flag': '🇩🇪', 'name': 'Germany'},
  {'code': '+39', 'flag': '🇮🇹', 'name': 'Italy'},
  {'code': '+34', 'flag': '🇪🇸', 'name': 'Spain'},
  {'code': '+31', 'flag': '🇳🇱', 'name': 'Netherlands'},
  {'code': '+32', 'flag': '🇧🇪', 'name': 'Belgium'},
  {'code': '+41', 'flag': '🇨🇭', 'name': 'Switzerland'},
  {'code': '+46', 'flag': '🇸🇪', 'name': 'Sweden'},
  {'code': '+47', 'flag': '🇳🇴', 'name': 'Norway'},
  {'code': '+45', 'flag': '🇩🇰', 'name': 'Denmark'},
  {'code': '+358', 'flag': '🇫🇮', 'name': 'Finland'},
  {'code': '+48', 'flag': '🇵🇱', 'name': 'Poland'},
  {'code': '+90', 'flag': '🇹🇷', 'name': 'Turkey'},
  {'code': '+7', 'flag': '🇷🇺', 'name': 'Russia'},
  {'code': '+380', 'flag': '🇺🇦', 'name': 'Ukraine'},
  {'code': '+30', 'flag': '🇬🇷', 'name': 'Greece'},
  {'code': '+351', 'flag': '🇵🇹', 'name': 'Portugal'},
  {'code': '+91', 'flag': '🇮🇳', 'name': 'India'},
  {'code': '+92', 'flag': '🇵🇰', 'name': 'Pakistan'},
  {'code': '+880', 'flag': '🇧🇩', 'name': 'Bangladesh'},
  {'code': '+94', 'flag': '🇱🇰', 'name': 'Sri Lanka'},
  {'code': '+977', 'flag': '🇳🇵', 'name': 'Nepal'},
  {'code': '+86', 'flag': '🇨🇳', 'name': 'China'},
  {'code': '+81', 'flag': '🇯🇵', 'name': 'Japan'},
  {'code': '+82', 'flag': '🇰🇷', 'name': 'South Korea'},
  {'code': '+60', 'flag': '🇲🇾', 'name': 'Malaysia'},
  {'code': '+65', 'flag': '🇸🇬', 'name': 'Singapore'},
  {'code': '+63', 'flag': '🇵🇭', 'name': 'Philippines'},
  {'code': '+62', 'flag': '🇮🇩', 'name': 'Indonesia'},
  {'code': '+66', 'flag': '🇹🇭', 'name': 'Thailand'},
  {'code': '+84', 'flag': '🇻🇳', 'name': 'Vietnam'},
  {'code': '+61', 'flag': '🇦🇺', 'name': 'Australia'},
  {'code': '+64', 'flag': '🇳🇿', 'name': 'New Zealand'},
  {'code': '+55', 'flag': '🇧🇷', 'name': 'Brazil'},
  {'code': '+52', 'flag': '🇲🇽', 'name': 'Mexico'},
  {'code': '+54', 'flag': '🇦🇷', 'name': 'Argentina'},
  {'code': '+57', 'flag': '🇨🇴', 'name': 'Colombia'},
  {'code': '+56', 'flag': '🇨🇱', 'name': 'Chile'},
  {'code': '+27', 'flag': '🇿🇦', 'name': 'South Africa'},
  {'code': '+234', 'flag': '🇳🇬', 'name': 'Nigeria'},
  {'code': '+254', 'flag': '🇰🇪', 'name': 'Kenya'},
  {'code': '+233', 'flag': '🇬🇭', 'name': 'Ghana'},
  {'code': '+251', 'flag': '🇪🇹', 'name': 'Ethiopia'},
];

class CountryPickerButton extends StatelessWidget {
  final String selectedCode;
  final String selectedFlag;
  final ValueChanged<Map<String, String>> onChanged;

  const CountryPickerButton({
    super.key,
    required this.selectedCode,
    required this.selectedFlag,
    required this.onChanged,
  });

  void _open(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        children: kCountries.map((country) {
          final isSelected = country['code'] == selectedCode;
          return ListTile(
            leading: Text(country['flag']!, style: const TextStyle(fontSize: 24)),
            title: Text(country['name']!),
            trailing: Text(country['code']!, style: const TextStyle(color: Colors.grey)),
            selected: isSelected,
            selectedColor: const Color.fromARGB(255, 69, 100, 201),
            onTap: () {
              onChanged(country);
              Navigator.pop(context);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _open(context),
      child: Container(
        height: 56,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(selectedFlag, style: const TextStyle(fontSize: 20)),
            const SizedBox(width: 4),
            Text(selectedCode, style: const TextStyle(fontSize: 14)),
            const Icon(Icons.arrow_drop_down, size: 20, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}
