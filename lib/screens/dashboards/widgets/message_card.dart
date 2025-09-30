import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final String fullName;
  final String message;
  final String date;
  final String? imageUrl;
  final bool isChecked;

  const MessageCard({
    super.key,
    required this.fullName,
    required this.message,
    required this.date,
    this.imageUrl,
    this.isChecked = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 8,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ Profile Image
          CircleAvatar(
            radius: 24,
            backgroundImage: imageUrl != null && imageUrl!.isNotEmpty
                ? NetworkImage(imageUrl!)
                : const AssetImage("assets/defaultProfileImage.png")
                    as ImageProvider,
          ),

          const SizedBox(width: 12),

          // ✅ Middle Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First row (title)
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 4),

                // Second row: check + subtitle
                Row(
                  children: [
                    // Circular check
                    Container(
                      width: 12,
                      height: 12,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(
                            0xFFF5F5F5), // background for both cases
                        border: Border.all(
                          color: isChecked
                              ? const Color(0xFF0048FF) // checked border
                              : const Color(0xFF858585), // unchecked border
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        isChecked
                            ? Icons.done_all
                            : Icons.check, // double check vs single
                        size: 8,
                        color: isChecked
                            ? const Color(0xFF0048FF) // blue when checked
                            : const Color(0xFF858585), // gray when unchecked
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        date,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ Right column (15% width)
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.15,
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.end, // aligns everything to the right
              mainAxisSize: MainAxisSize.min,
              children: [
                // Right-aligned text
                Text(
                  date,
                  textAlign: TextAlign.right,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.grey,
                  ),
                ),
                // Only show this if not checked
                if (!isChecked) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0048FF),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: const Text(
                      "65", // replace with dynamic text
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
