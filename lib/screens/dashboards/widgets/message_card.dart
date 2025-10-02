import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  final String fullName;
  final String message;
  final String date;
  final String? imageUrl;
  final bool isChecked;
  final String? unreadCount; // 👈 added for flexibility

  const MessageCard({
    super.key,
    required this.fullName,
    required this.message,
    required this.date,
    this.imageUrl,
    this.isChecked = false,
    this.unreadCount, // 👈 optional unread messages
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

          // ✅ Middle Column (Name + Message preview)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  message,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // ✅ Right Column (Date + unread bubble if not checked)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                date,
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                ),
              ),
              if (!isChecked && unreadCount != null) ...[
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0048FF),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Text(
                    unreadCount!,
                    style: const TextStyle(
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
        ],
      ),
    );
  }
}

class MessageCardList extends StatelessWidget {
  final List<Map<String, dynamic>> items;

  const MessageCardList({super.key, required this.items});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: items.map((item) {
        return MessageCard(
          fullName: item['fullName'] ?? '',
          message: item['message'] ?? '',
          date: item['date'] ?? '',
          imageUrl: item['imageUrl'] ?? '',
          isChecked: item['isChecked'] ?? false,
          unreadCount: item['unreadCount'],
        );
      }).toList(),
    );
  }
}
