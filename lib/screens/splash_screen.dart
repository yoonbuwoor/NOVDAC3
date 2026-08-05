import 'dart:async';

import 'package:flutter/material.dart';

import '../core/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key, required this.child});

  final Widget child;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;
  bool _showApp = false;
  Timer? _splashTimer;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..forward();
    _scale = CurvedAnimation(parent: _controller, curve: Curves.easeOutBack);
    _splashTimer = Timer(const Duration(milliseconds: 1650), () {
      if (mounted) setState(() => _showApp = true);
    });
  }

  @override
  void dispose() {
    _splashTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 650),
      child: _showApp
          ? widget.child
          : Scaffold(
              key: const ValueKey('splash'),
              backgroundColor: navy,
              body: Stack(
                fit: StackFit.expand,
                children: [
                  const _RadarBackground(),
                  Center(
                    child: ScaleTransition(
                      scale: _scale,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 240,
                            height: 190,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(34),
                              boxShadow: [
                                BoxShadow(
                                  color: cyan.withOpacity(.25),
                                  blurRadius: 34,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Image.asset(
                              'assets/images/logo_full.webp',
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 14),
                          const Text(
                            'DRONE • PHOTOGRAMMÉTRIE • SIG • IA',
                            style: TextStyle(
                              color: cyan,
                              fontSize: 11,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Positioned(
                    left: 0,
                    right: 0,
                    bottom: 48,
                    child: Column(
                      children: [
                        SizedBox(
                          width: 120,
                          child: LinearProgressIndicator(
                            minHeight: 3,
                            borderRadius: BorderRadius.all(Radius.circular(99)),
                            backgroundColor: Colors.white12,
                          ),
                        ),
                        SizedBox(height: 13),
                        Text(
                          'DroneAtlas Academy • Novateur221',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _RadarBackground extends StatelessWidget {
  const _RadarBackground();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(painter: _RadarPainter());
  }
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cyan.withOpacity(.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    final center = Offset(size.width * .5, size.height * .48);
    for (double radius = 80; radius < size.longestSide; radius += 80) {
      canvas.drawCircle(center, radius, paint);
    }
    for (var i = 0; i < 12; i++) {
      final angle = i * 3.1415926535 / 6;
      canvas.drawLine(
        center,
        center + Offset.fromDirection(angle, size.longestSide),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
