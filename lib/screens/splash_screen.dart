import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
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
  late AnimationController _shineController;
  late AnimationController _fadeController;
  late AnimationController _glowController;
  late Animation<double> _shineAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();
    
    // Fade in animation
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _fadeController,
        curve: Curves.easeIn,
      ),
    );

    // Shine effect animation
    _shineController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    );

    _shineAnimation = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(
        parent: _shineController,
        curve: Curves.easeInOut,
      ),
    );

    // Glow pulse animation
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(
        parent: _glowController,
        curve: Curves.easeInOut,
      ),
    );

    // Start animations
    _fadeController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) {
        _shineController.repeat(period: const Duration(milliseconds: 3000));
        _glowController.repeat(reverse: true);
      }
    });

    // Navigate after 3 seconds
    _navigationTimer = Timer(const Duration(seconds: 7), () {
      _navigateToMain();
    });
  }

  void _navigateToMain() {
    if (_hasNavigated || !mounted) return;
    _hasNavigated = true;

    _shineController.stop();
    _fadeController.stop();
    _glowController.stop();
    _navigationTimer?.cancel();

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const MainScreen()),
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _shineController.dispose();
    _fadeController.dispose();
    _glowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B1929), // Dark navy background
      body: SafeArea(
        child: Center(
          child: AnimatedBuilder(
            animation: Listenable.merge([_fadeAnimation, _shineAnimation, _glowAnimation]),
            builder: (context, child) {
              return Opacity(
                opacity: _fadeAnimation.value,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Modern Skyline
                    _buildDetailedSkyline(),
                    
                    const SizedBox(height: 50),
                    
                    // LOOP Text with Infinity in O
                    _buildLoopLogo(),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildDetailedSkyline() {
    // Specific building heights to create upside-down V
    final buildings = [
      _BuildingSpec(height: 95, width: 32),
      _BuildingSpec(height: 120, width: 35),
      _BuildingSpec(height: 145, width: 38),
      _BuildingSpec(height: 165, width: 40), // Tallest center
      _BuildingSpec(height: 145, width: 38),
      _BuildingSpec(height: 120, width: 35),
      _BuildingSpec(height: 95, width: 32),
    ];



    return Container(
      height: 180,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: buildings.asMap().entries.map((entry) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1.5),
            child: _buildBuilding(entry.value, entry.key),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBuilding(_BuildingSpec spec, int index) {
    return Container(
      width: spec.width,
      height: spec.height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF1A3A5C),
            Color(0xFF2A4F7A),
          ],
        ),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(1),
          topRight: Radius.circular(1),
        ),
      ),
      child: CustomPaint(
        painter: BuildingWindowsPainter(spec.height),
      ),
    );
  }

  Widget _buildLoopLogo() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // L
        _buildLetter('L'),
        const SizedBox(width: 8),
        
        // Infinity symbol (replaces OO)
        Container(
          width: 90,
          height: 50,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              CustomPaint(
                size: Size(90, 50),
                painter: InfinityGlowPainter(_glowAnimation.value),
              ),
              // Main hollow infinity
              CustomPaint(
                size: Size(90, 50),
                painter: InfinityLogoPainter(),
              ),
              // Shine overlay
              ClipPath(
                clipper: InfinityClipper(),
                child: CustomPaint(
                  size: Size(90, 50),
                  painter: ShinePainter(_shineAnimation.value),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        
        // P
        _buildLetter('P'),
      ],
    );
  }

  Widget _buildLetter(String letter) {
    return ShaderMask(
      shaderCallback: (bounds) {
        final shinePos = _shineAnimation.value;
        return LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          stops: [
            (shinePos - 0.3).clamp(0.0, 1.0),
            shinePos.clamp(0.0, 1.0),
            (shinePos + 0.3).clamp(0.0, 1.0),
          ],
          colors: [
            Color(0xFF9BB5D4),
            Color(0xFFFFFFFF),
            Color(0xFF9BB5D4),
          ],
        ).createShader(bounds);
      },
      child: Text(
        letter,
        style: TextStyle(
          fontSize: 56,
          fontWeight: FontWeight.w300,
          color: Colors.white,
          letterSpacing: 2,
          height: 1.0,
        ),
      ),
    );
  }
}

class _BuildingSpec {
  final double height;
  final double width;

  _BuildingSpec({required this.height, required this.width});
}

class BuildingWindowsPainter extends CustomPainter {
  final double buildingHeight;

  BuildingWindowsPainter(this.buildingHeight);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    const windowWidth = 3.5;
    const windowHeight = 4.5;
    const spacingX = 4.0;
    const spacingY = 5.0;
    const padding = 3.0;

    final rows = ((size.height - padding * 2) / (windowHeight + spacingY)).floor();
    final cols = ((size.width - padding * 2) / (windowWidth + spacingX)).floor();

    for (int row = 0; row < rows; row++) {
      for (int col = 0; col < cols; col++) {
        final x = padding + col * (windowWidth + spacingX);
        final y = padding + row * (windowHeight + spacingY);

        // Pattern for lit windows
        final isLit = (row + col) % 3 != 2;
        
        paint.color = isLit 
          ? Color(0xFF4A8DD6).withOpacity(0.9)
          : Color(0xFF1F3A57).withOpacity(0.5);

        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromLTWH(x, y, windowWidth, windowHeight),
            Radius.circular(0.3),
          ),
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class InfinityLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF4A9EE5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final path = _createInfinityPath(size);
    canvas.drawPath(path, paint);
  }

  Path _createInfinityPath(Size size) {
    final path = Path();
    final centerY = size.height / 2;
    final radius = size.height / 2.5;
    final centerLeftX = size.width * 0.28;
    final centerRightX = size.width * 0.72;

    // Create infinity using two circles that overlap
    // Left circle
    path.addOval(Rect.fromCircle(
      center: Offset(centerLeftX, centerY),
      radius: radius,
    ));

    // Right circle  
    path.addOval(Rect.fromCircle(
      center: Offset(centerRightX, centerY),
      radius: radius,
    ));

    return path;
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class InfinityGlowPainter extends CustomPainter {
  final double glowIntensity;

  InfinityGlowPainter(this.glowIntensity);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Color(0xFF2E8FDF).withOpacity(0.3 * glowIntensity)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, 8);

    final path = _createInfinityPath(size);
    canvas.drawPath(path, paint);
  }

  Path _createInfinityPath(Size size) {
    final path = Path();
    final centerY = size.height / 2;
    final radius = size.height / 2.2;
    final centerLeftX = size.width * 0.3;
    final centerRightX = size.width * 0.7;

    path.addOval(Rect.fromCircle(
      center: Offset(centerLeftX, centerY),
      radius: radius,
    ));

    path.addOval(Rect.fromCircle(
      center: Offset(centerRightX, centerY),
      radius: radius,
    ));

    return path;
  }

  @override
  bool shouldRepaint(covariant InfinityGlowPainter oldDelegate) {
    return oldDelegate.glowIntensity != glowIntensity;
  }
}

class InfinityClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final centerY = size.height / 2;
    final radius = size.height / 2.5; // SAME as logo painter
    final centerLeftX = size.width * 0.28;
    final centerRightX = size.width * 0.72;

    final left = Rect.fromCircle(
      center: Offset(centerLeftX, centerY),
      radius: radius + 6, // inflate for stroke + glow
    );

    final right = Rect.fromCircle(
      center: Offset(centerRightX, centerY),
      radius: radius + 6,
    );

    return Path()
      ..addOval(left)
      ..addOval(right);
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}


class ShinePainter extends CustomPainter {
  final double progress;

  ShinePainter(this.progress);

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(0, 0, size.width, size.height);
    
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
        stops: const [0.0, 0.5, 1.0],
        colors: [
          Colors.white.withOpacity(0.0),
          Colors.white.withOpacity(0.5),
          Colors.white.withOpacity(0.0),
        ],
        transform: GradientRotation(0),
      ).createShader(
        Rect.fromLTWH(
          size.width * progress - size.width * 0.5,
          0,
          size.width,
          size.height,
        ),
      );

    canvas.drawRect(rect, paint);
  }

  @override
  bool shouldRepaint(covariant ShinePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}