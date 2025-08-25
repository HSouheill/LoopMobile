import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final IconData leadingIcon;
  final VoidCallback onPressed;
  final bool filled;

  const AuthButton({
    super.key,
    required this.label,
    required this.leadingIcon,
    required this.onPressed,
    required this.filled,
  });

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return ElevatedButton.icon(
        icon: Icon(leadingIcon, color: Colors.white),
        label: Text(label, style: const TextStyle(color: Colors.white)),
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } else {
      return OutlinedButton.icon(
        icon: Icon(leadingIcon, color: Colors.blue),
        label: Text(label, style: const TextStyle(color: Colors.blue)),
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.blue),
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    }
  }
}