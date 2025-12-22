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
              ? const LinearGradient(
                  colors: [
                    Color.fromARGB(255, 103, 155, 218),
                    Color.fromARGB(255, 69, 100, 201),
                  ],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                )
              : null,
          border: borderColor != null
              ? Border.all(color: borderColor!, width: borderWidth)
              : null,
          boxShadow: useGradient
              ? [
                  BoxShadow(
                    color: const Color.fromARGB(255, 69, 100, 201).withOpacity(0.3),
                    offset: const Offset(0, 4),
                    blurRadius: 8,
                  ),
                ]
              : borderColor != null
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ]
                  : null,
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
