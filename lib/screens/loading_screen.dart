import 'dart:math';
import 'package:flutter/material.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _backgroundController;
  late final AnimationController _progressController;

  @override
  void initState() {
    super.initState();

    _backgroundController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _progressController.forward();

    _progressController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/main');
      }
    });
  }

  @override
  void dispose() {
    _backgroundController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _backgroundController,
          _progressController,
        ]),
        builder: (_, __) {
          return Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.35,
                colors: [
                  Color(0xFF4B2A78),
                  Color(0xFF1A1238),
                  Color(0xFF09051A),
                ],
              ),
            ),
            child: Stack(
              children: [
                ...List.generate(45, (i) {
                  final t = (_backgroundController.value + i * 0.037) % 1.0;
                  final x = (sin(i * 91.7) * 0.5 + 0.5) * size.width;
                  final y = (t * size.height * 1.15) - 80;

                  return Positioned(
                    left: x,
                    top: y,
                    child: Opacity(
                      opacity: 0.25 + sin(t * pi) * 0.55,
                      child: Container(
                        width: 2 + (i % 3).toDouble(),
                        height: 2 + (i % 3).toDouble(),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.white.withOpacity(0.7),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }),

                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.scale(
                        scale:
                        1 + sin(_backgroundController.value * pi * 2) * 0.04,
                        child: Container(
                          width: 118,
                          height: 118,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const RadialGradient(
                              colors: [
                                Color(0xFFFFE8A7),
                                Color(0xFFFFC62D),
                                Color(0xFFFF8A00),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFFFFC62D).withOpacity(0.45),
                                blurRadius: 42,
                                spreadRadius: 8,
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 34),

                      const Text(
                        'Unilearn',
                        style: TextStyle(
                          fontFamily: 'JockeyOne',
                          fontSize: 46,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      Text(
                        'Loading your universe...',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.white.withOpacity(0.65),
                          letterSpacing: 0.8,
                        ),
                      ),

                      const SizedBox(height: 34),

                      SizedBox(
                        width: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            minHeight: 5,
                            value: _progressController.value,
                            backgroundColor: Colors.white.withOpacity(0.12),
                            color: const Color(0xFFFFC62D),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}