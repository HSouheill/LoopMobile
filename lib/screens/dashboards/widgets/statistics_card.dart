import 'package:flutter/material.dart';

class StatCard extends StatelessWidget {
  final String title;
  final String value;

  const StatCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      padding: const EdgeInsets.symmetric(vertical: 9),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: const RadialGradient(
          center: Alignment(1.018, 1.3934),
          radius: 2.4344,
          colors: [
            Color(0xFF82A6FF),
            Color(0xFF487CFF),
            Color(0xFF0048FF),
            Color(0xFF0048FF),
          ],
          stops: [0.0, 0.3221, 0.5212, 0.2],
        ),
      ),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// 🔹 Wrapper widget to generate multiple StatCards
class StatCardList extends StatelessWidget {
  final List<Map<String, String>> items;

  const StatCardList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: items.map((item) {
        return StatCard(
          title: item['title'] ?? '',
          value: item['value'] ?? '',
        );
      }).toList(),
    );
  }
}
