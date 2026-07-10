import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 1. Import services
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
    
    // 2. Hide Status Bar and Navigation Bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.asset('assets/animation.mp4');

    try {
      await _controller.initialize();
      await _controller.setLooping(false);
      await _controller.setPlaybackSpeed(6.0); // Set playback speed to 5.0x (2x faster than before)

      setState(() {
        _isInitialized = true;
      });

      await _controller.play();

      _controller.addListener(() {
        final bool isAtEnd = _controller.value.position >= _controller.value.duration;
        if (_isInitialized && isAtEnd && !_hasNavigated) {
          _navigateToMain();
        }
      });
    } catch (e) {
      debugPrint("Video Error: $e");
      Timer(const Duration(milliseconds: 1500), _navigateToMain);
    }
  }

  void _navigateToMain() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _controller.pause();

    // 3. Restore Status Bar and Navigation Bar before leaving
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual, 
      overlays: SystemUiOverlay.values // This brings back top and bottom bars
    );

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
            ? SizedBox.expand(
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: _controller.value.size.width,
                    height: _controller.value.size.height,
                    child: VideoPlayer(_controller),
                  ),
                ),
              )
            : const SizedBox.shrink(), // : const CircularProgressIndicator(color: Colors.white),
      ),
    );
  }
}