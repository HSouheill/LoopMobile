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

            return Container(
              padding: const EdgeInsets.symmetric(vertical: 0.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 70, // keeps the track wide
                    child: Transform.translate(
                      offset: const Offset(-12, 0), // shift left
                      child: Transform.scale(
                        scaleX: 0.8,
                        scaleY: 0.6,
                        child: SwitchTheme(
                          data: SwitchThemeData(
                            trackOutlineColor:
                                MaterialStateProperty.all(Colors.transparent),
                          ),
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
                          ),
                        ),
                      ),
                    ),
                  ),
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
