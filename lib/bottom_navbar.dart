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
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 103, 155, 218),
            Color.fromARGB(255, 27, 55, 147),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent,
        elevation: 0,
        showSelectedLabels: false,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color.fromARGB(255, 27, 55, 147),
        unselectedItemColor: Colors.white,
        items: [
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.people, 0),
            label: "Agents",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.apartment, 1),
            label: "Listings",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.home, 2),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.design_services, 3),
            label: "Services",
          ),
          BottomNavigationBarItem(
            icon: _buildIcon(Icons.chat, 4),
            label: "Chat",
          ),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData iconData, int index) {
    if (index == currentIndex) {
      return Container(
        // margin: const EdgeInsets.only(left: 0, top: 12, right: 0, bottom: 0),
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
        child: Icon(
          iconData,
          color: const Color.fromARGB(255, 27, 55, 147),
        ),
      );
    } else {
      return Icon(iconData);
    }
  }
}
