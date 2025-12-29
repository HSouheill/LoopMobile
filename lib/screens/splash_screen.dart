import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late VideoPlayerController _controller;
  bool _hasNavigated = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    // 1. Double check the path matches your pubspec.yaml exactly
    _controller = VideoPlayerController.asset('assets/animation.mp4');

    try {
      await _controller.initialize();
      
      // Ensure the video doesn't loop so we can detect the end
      await _controller.setLooping(false);
      
      setState(() {
        _isInitialized = true;
      });

      // Start playing
      await _controller.play();

      // Add listener to navigate when video reaches the end
      _controller.addListener(() {
        final bool isAtEnd = _controller.value.position >= _controller.value.duration;
        
        // Sometimes position is slightly less than duration at the end
        if (_isInitialized && isAtEnd && !_hasNavigated) {
          _navigateToMain();
        }
      });
    } catch (e) {
      debugPrint("Video Error: $e");
      // If video fails to load, wait 2 seconds then skip to main
      Timer(const Duration(seconds: 2), _navigateToMain);
    }
  }

  void _navigateToMain() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _controller.pause();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1929),
      body: Center(
        child: _isInitialized
            ? SizedBox.expand( // This makes the video fill the screen
                child: FittedBox(
                  fit: BoxFit.cover, // Or BoxFit.contain depending on your preference
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}