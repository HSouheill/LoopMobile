import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class UnderConstructionPage extends StatelessWidget {
  final String pageName;
  const UnderConstructionPage({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    // Get the localized strings for the current language
    final localizations = AppLocalizations.of(context)!;

    return Center(
      child: Text(
        // Use the localized string and pass the pageName as a variable
        localizations.underConstructionPage(pageName),
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
