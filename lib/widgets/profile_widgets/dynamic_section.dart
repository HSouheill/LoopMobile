import 'package:flutter/material.dart';

class DynamicSection extends StatefulWidget {
  final String title;
  final List<Map<String, String>> rows;

  const DynamicSection({
    super.key,
    required this.title,
    required this.rows,
  });

  @override
  State<DynamicSection> createState() => _DynamicSectionState();
}

class _DynamicSectionState extends State<DynamicSection> {
  late List<bool> switchStates;

  @override
  void initState() {
    super.initState();
    switchStates = List.generate(widget.rows.length, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Color(0xFF1E1E1E),
            ),
          ),
        ),
        Column(
          children: widget.rows.asMap().entries.map((entry) {
            final index = entry.key;
            final row = entry.value;

            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child: Row(
                children: [
                  SizedBox(
                    width: 40,
                    height: 10,
                    child: Transform.scale(
                      scale: 0.7,
                      child: Switch(
                        value: switchStates[index],
                        onChanged: (value) {
                          setState(() {
                            switchStates[index] = value;
                          });
                        },
                        activeTrackColor: const Color(0xFF0048FF),
                        inactiveTrackColor: const Color(0xFFADADAD),
                        activeColor: const Color(0xFFFFFFFF),
                        inactiveThumbColor: const Color(0xFFFFFFFF),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    row["text"] ?? "",
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w400,
                      color: Color(0xFF1E1E1E),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
