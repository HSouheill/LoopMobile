import 'dart:async';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  bool _hasNavigated = false;
  Timer? _navigationTimer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    
    // Create animation controller - duration will be set when animation loads
    _animationController = AnimationController(vsync: this);
    
    // Navigate after animation completes or after a maximum duration
    _navigationTimer = Timer(const Duration(seconds: 15), () {
      _navigateToMain();
    });
  }

  void _navigateToMain() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _animationController.stop();
    _navigationTimer?.cancel();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _navigationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1929), // Dark navy background
      body: SafeArea(
  child: Align(
    alignment: const Alignment(0, -0.2), // ⬆️ raise animation
    child: Lottie.asset(
      'assets/animation.json',
      controller: _animationController,
      fit: BoxFit.contain, // 👈 IMPORTANT
      repeat: false,
      onLoaded: (composition) {
        _animationController.duration = composition.duration;
        _animationController.forward();

        _animationController.addStatusListener((status) {
          if (status == AnimationStatus.completed) {
            if (mounted && !_hasNavigated) {
              _navigateToMain();
            }
          }
        });
      },
      errorBuilder: (context, error, stackTrace) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.error_outline, color: Colors.white70, size: 48),
            SizedBox(height: 16),
            Text(
              'Animation loading...',
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ],
        );
      },
    ),
  ),
),
    );
  }
}
