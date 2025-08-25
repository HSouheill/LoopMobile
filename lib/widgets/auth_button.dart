import 'package:flutter/material.dart';

class AuthButton extends StatelessWidget {
  final String label;
  final IconData? leadingIcon;
  final VoidCallback onPressed;
  final bool filled;

  const AuthButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.leadingIcon,
    this.filled = false,
  });

  @override
  Widget build(BuildContext context) {
    final child = Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (leadingIcon != null) ...[
          Icon(leadingIcon),
          const SizedBox(width: 8),
        ],
        Text(label),
      ],
    );

    return SizedBox(
      width: double.infinity,
      height: 50,
      child: filled
          ? ElevatedButton(onPressed: onPressed, child: child)
          : OutlinedButton(onPressed: onPressed, child: child),
    );
  }
}