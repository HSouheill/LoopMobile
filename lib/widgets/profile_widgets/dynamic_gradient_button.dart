import 'package:flutter/material.dart';

class DynamicGradientButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double borderWidth;
  final Color textColor;
  final bool useGradient;
  final double? textSize; // ✅ Add this - make it nullable

  const DynamicGradientButton({
    Key? key,
    required this.buttonText,
    this.onTap,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth = 2.0,
    this.textColor = Colors.white,
    this.useGradient = true,
    this.textSize, // ✅ Add this optional parameter
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ??
            const EdgeInsets.symmetric(horizontal: 13.0, vertical: 7.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(50.0),
          color: useGradient ? null : backgroundColor ?? Colors.blue,
          gradient: useGradient
              ? const RadialGradient(
                  center: Alignment(1.0, 1.4),
                  radius: 1.5,
                  colors: [
                    Color(0xFF82A6FF),
                    Color(0xFF487CFF),
                    Color(0xFF3770FF),
                    Color(0xFF0048FF),
                  ],
                  stops: [0.0, 0.3221, 0.7212, 1.0],
                )
              : null,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
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
          style: TextStyle(
            color: textColor,
            fontSize: textSize ?? 11.0, // ✅ Use custom size or default to 11.0
            fontWeight: FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
