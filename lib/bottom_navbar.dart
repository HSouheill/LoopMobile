import 'package:flutter/material.dart';

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
    return Container(
      // 1. Gradient background from left to right with a light blue theme
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 103, 155, 218), // A light blue color
            Color.fromARGB(255, 27, 55, 147), // A slightly lighter blue color
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        // The background color of the bar itself must be transparent
        backgroundColor: Colors.transparent,
        // The elevation should be 0 to avoid a shadow
        elevation: 0,
        // Only unselected labels are visible to make the bar thinner
        showSelectedLabels: false,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed, // ensures all items are the same size
        selectedItemColor: Color.fromARGB(255, 27, 55, 147), // Color of the selected label and icon (not visible)
        unselectedItemColor: Colors.white, // Color of unselected labels and icons
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.search, 0),
            label: "Search",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.notifications, 1),
            label: "Notifications",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, 2),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.person, 3),
            label: "Profile",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.settings, 4),
            label: "Settings",
          ),
        ],
      ),
    );
  }

  // Helper method to build the icon with the circular white background for the selected item
  Widget _buildIcon(IconData iconData, int index) {
    if (index == currentIndex) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: Color.fromARGB(255, 27, 55, 147), // Icon color for the selected item
        ),
      );
    } else {
      // The icon for unselected items
      return Icon(iconData);
    }
  }
}
