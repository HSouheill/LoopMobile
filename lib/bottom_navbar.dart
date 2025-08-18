import 'package:flutter/material.dart';
import 'package:salomon_bottom_bar/salomon_bottom_bar.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SalomonBottomBar(
      currentIndex: currentIndex,
      onTap: onTap,
      items: [
        SalomonBottomBarItem(
          icon: const Icon(Icons.search),
          title: const Text("Search"),
          selectedColor: Colors.pink,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.notifications),
          title: const Text("Notifications"),
          selectedColor: Colors.orange,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.home),
          title: const Text("Home"),
          selectedColor: Colors.purple,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.person),
          title: const Text("Profile"),
          selectedColor: Colors.teal,
        ),
        SalomonBottomBarItem(
          icon: const Icon(Icons.settings),
          title: const Text("Settings"),
          selectedColor: Colors.blueGrey,
        ),
      ],
    );
  }
}
