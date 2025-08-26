// File: lib/app_header.dart

import 'package:flutter/material.dart';
import 'main.dart'; // Import main.dart to access MyApp's state
import 'services/auth_service.dart'; // Import AuthService to access user data
import 'environment.dart';

class AppHeader extends StatelessWidget implements PreferredSizeWidget {
  final String name;
  final String? subtitle;
  final String location;
  final VoidCallback? onSubtitleTap;
  final bool isLoggedIn;
  final VoidCallback? onLogout;
  final String? profileImageUrl; // Add a new parameter to pass the image URL

  const AppHeader({
    super.key,
    required this.name,
    this.subtitle,
    required this.location,
    this.onSubtitleTap,
    this.isLoggedIn = false,
    this.onLogout,
    this.profileImageUrl, // Initialize the new parameter
  });

  @override
  Widget build(BuildContext context) {
    // Get the current user from AuthService
    final user = AuthService.currentUser;

    return AppBar(
      automaticallyImplyLeading: false,
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 70,
      title: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundImage: isLoggedIn && user != null && user.profileImage != null
                ? NetworkImage('${Environment.apiUrl}assets/${user.profileImage}')
                : const NetworkImage('https://i.pravatar.cc/150?img=3') as ImageProvider,
            backgroundColor: Colors.grey[200],
          ),
          const SizedBox(width: 12),
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
                _buildSubtitleWidget(),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.location_on_outlined, color: Colors.black87),
              const SizedBox(width: 4),
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
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
          PopupMenuButton<String>(
            icon: const Icon(Icons.language, color: Colors.black87),
            onSelected: (String result) {
              if (result == 'en') {
                MyApp.of(context).setLocale(const Locale('en'));
              } else if (result == 'ar') {
                MyApp.of(context).setLocale(const Locale('ar'));
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem<String>(
                value: 'en',
                child: Text('EN'),
              ),
              const PopupMenuItem<String>(
                value: 'ar',
                child: Text('AR'),
              ),
            ],
          ),
          // Small logout button when logged in
          if (isLoggedIn) ...[
            
            const SizedBox(width: 8),
            PopupMenuButton<String>(
              icon: const Icon(Icons.account_circle_outlined, color: Colors.black87),
              onSelected: (String result) {
                switch (result) {
                  case 'profile':
                    Navigator.pushNamed(context, '/profile');
                    break;
                  case 'settings':
                    Navigator.pushNamed(context, '/settings');
                    break;
                  case 'logout':
                    _showLogoutDialog(context);
                    break;
                }
              },
              itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, size: 18),
                      SizedBox(width: 8),
                      Text('Profile'),
                    ],
                  ),
                ),
                const PopupMenuItem<String>(
                  value: 'settings',
                  child: Row(
                    children: [
                      Icon(Icons.settings_outlined, size: 18),
                      SizedBox(width: 8),
                      Text('Settings'),
                    ],
                  ),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem<String>(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_outlined, size: 18, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Logout', style: TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                onLogout?.call();
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSubtitleWidget() {
    // Show rounded button for "Login", regular underlined text for others
    if (subtitle?.toLowerCase() == 'login') {
      return Container(
        margin: const EdgeInsets.only(top: 2),
        child: ElevatedButton(
          onPressed: onSubtitleTap,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            minimumSize: const Size(0, 0),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
          ),
          child: Text(
            subtitle!,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      );
    } else {
      // Regular underlined text button for other subtitles
      return TextButton(
        onPressed: onSubtitleTap,
        style: TextButton.styleFrom(
          padding: EdgeInsets.zero,
          minimumSize: const Size(0, 0),
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: Colors.blue,
          textStyle: const TextStyle(
            fontSize: 12,
            decoration: TextDecoration.underline,
          ),
        ),
        child: Text(subtitle!),
      );
    }
  }

  @override
  Size get preferredSize => const Size.fromHeight(70);
}