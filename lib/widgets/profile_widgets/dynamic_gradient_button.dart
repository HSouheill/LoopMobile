// File: lib/screens/dynamic_gradient_button.dart

import 'package:flutter/material.dart';

class DynamicGradientButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding; // Add this line

  const DynamicGradientButton({
    Key? key,
    required this.buttonText,
    this.onTap,
    this.padding, // Add this line
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        // Use the provided padding, or a default value if none is given
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 13.0, vertical: 7.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          gradient: const RadialGradient(
            center: Alignment(1.0, 1.4),
            radius: 1.5,
            colors: [
              Color(0xFF82A6FF),
              Color(0xFF487CFF),
              Color(0xFF3770FF),
              Color(0xFF0048FF),
            ],
            stops: [0.0, 0.3221, 0.7212, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              offset: const Offset(0, 4),
              blurRadius: 5.3,
            ),
          ],
        ),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11.0,
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
