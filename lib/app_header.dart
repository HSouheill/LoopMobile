import 'package:flutter/material.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String? subtitle; // optional button/text under name
  final String location;
  final VoidCallback? onSubtitleTap;

  const AppHeader({
    super.key,
    required this.name,
    this.subtitle,
    required this.location,
    this.onSubtitleTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          // Profile picture
          CircleAvatar(
            radius: 22,
            backgroundImage: NetworkImage(
              'https://i.pravatar.cc/150?img=3', // placeholder
            ),
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 12),
          // Name + optional subtitle
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black,
                ),
              ),
              if (subtitle != null)
                GestureDetector(
                  onTap: onSubtitleTap,
                  child: Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
            ],
          ),
          const Spacer(),
          // Location icon + text
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.black87),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(width: 16),
          // Notification icon with badge
          Stack(
            children: [
              IconButton(
                icon: const Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: () {},
              ),
              Positioned(
                right: 6,
                top: 6,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 8,
                    minHeight: 8,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: 8),
          // Globe/dropdown icon
          IconButton(
            icon: const Icon(Icons.language, color: Colors.black87),
            onPressed: () {},
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}
