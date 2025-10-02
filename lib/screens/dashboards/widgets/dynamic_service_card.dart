import 'package:flutter/material.dart';
import '../../../widgets/profile_widgets/dynamic_gradient_button.dart';

class DynamicServiceCard extends StatefulWidget {
  final String leftText;
  final String imageUrl;

  const DynamicServiceCard({
    super.key,
    required this.leftText,
    required this.imageUrl,
  });

  @override
  State<DynamicServiceCard> createState() => _DynamicServiceCardState();
}

class _DynamicServiceCardState extends State<DynamicServiceCard> {
  bool boostPressed = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25.0, vertical: 12),
      child: Column(
        children: [
          // First row: left text + views/saves
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.leftText,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Row(
                children: const [
                  Icon(Icons.remove_red_eye, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("42 views", style: TextStyle(fontSize: 12)),
                  SizedBox(width: 12),
                  Icon(Icons.save_alt, size: 14, color: Colors.grey),
                  SizedBox(width: 4),
                  Text("42 saves", style: TextStyle(fontSize: 12)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Second row: image + button columns or Boost replacement
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image on the left
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  widget.imageUrl,
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 80,
                      height: 80,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image, color: Colors.white),
                    );
                  },
                ),
              ),
              const SizedBox(width: 12),

              // Middle & right columns or Cancel/Promote buttons
              Expanded(
                child: boostPressed
                    ? Row(
                        children: [
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: DynamicGradientButton(
                                buttonText: 'Cancel',
                                onTap: () {
                                  setState(() {
                                    boostPressed = false;
                                  });
                                },
                                padding:
                                    const EdgeInsets.symmetric(vertical: 6),
                                useGradient: false,
                                backgroundColor: const Color(0xFFF9FBFF),
                                borderColor: const Color(0xFFEA4435),
                                borderWidth: 1.0,
                                textColor: const Color(0xFFEA4435),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: SizedBox(
                              width: double.infinity,
                              child: DynamicGradientButton(
                                buttonText: 'Promote',
                                onTap: () {},
                                padding:
                                    const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Sold',
                                    onTap: () {},
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    useGradient: false,
                                    backgroundColor: const Color(0xFFF9FBFF),
                                    borderColor: const Color(0xFF0048FF),
                                    borderWidth: 1.0,
                                    textColor: const Color(0xFF1E1E1E),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Delete',
                                    onTap: () {},
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 6),
                                    useGradient: false,
                                    backgroundColor: const Color(0xFFF9FBFF),
                                    borderColor: const Color(0xFFEA4435),
                                    borderWidth: 1.0,
                                    textColor: const Color(0xFFEA4435),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              children: [
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Boost',
                                    onTap: () {
                                      setState(() {
                                        boostPressed = true;
                                      });
                                    },
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                SizedBox(
                                  width: double.infinity,
                                  child: DynamicGradientButton(
                                    buttonText: 'Edit',
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, '/edit-my-service');
                                    },
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 8),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// Wrapper widget to generate multiple cards
class DynamicServiceCardList extends StatelessWidget {
  final List<Map<String, String>> items;

  const DynamicServiceCardList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items
          .map((item) => DynamicServiceCard(
                leftText: item['leftText'] ?? '',
                imageUrl: item['imageUrl'] ?? '',
              ))
          .toList(),
    );
  }
}
