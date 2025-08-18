import 'package:flutter/material.dart';

class UnderConstructionPage extends StatelessWidget {
  final String pageName;
  const UnderConstructionPage({super.key, required this.pageName});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$pageName Page is under construction 🚧',
        style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        textAlign: TextAlign.center,
      ),
    );
  }
}
