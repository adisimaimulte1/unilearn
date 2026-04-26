import 'dart:math';

import 'package:flutter/material.dart';

import '../ai/ai_status_dots.dart';
import '../ai/apollo_navigator.dart';
import '../ai/apollo_voice_assistant.dart';
import '../models/planet_data.dart';
import '../widgets/animated_sprite_planet.dart';
import '../widgets/animated_sprite_sun.dart';
import '../widgets/planet_info_popup.dart';

class MainSelectorScreen extends StatefulWidget {
  const MainSelectorScreen({super.key});

  @override
  State<MainSelectorScreen> createState() => _MainSelectorScreenState();
}

class _MainSelectorScreenState extends State<MainSelectorScreen> {
  static const int _initialPage = 495;

  final apolloVoice = ApolloVoiceAssistant();

  final PageController _pageController = PageController(
    viewportFraction: 0.46,
    initialPage: _initialPage,
  );

  double _currentPage = _initialPage.toDouble();

  final planets = const [
    PlanetData(
      name: 'Mercury',
      subtitle: 'The swift planet',
      description: 'Mercury is the closest planet to the Sun and has extreme temperature changes.',
      diameter: '4,879 km',
      mass: '3.30 × 10²³ kg',
      dayLength: '1407.6 h',
      assetPath: 'assets/images/planets/mercury.png',
      frameCount: 100,
      columns: 10,
      rows: 10,
    ),
    PlanetData(
      name: 'Venus',
      subtitle: 'Earth’s hot twin',
      description: 'Venus has a thick atmosphere that traps heat, making it the hottest planet.',
      diameter: '12,104 km',
      mass: '4.87 × 10²⁴ kg',
      dayLength: '5832 h',
      assetPath: 'assets/images/planets/venus.png',
      frameCount: 100,
      columns: 10,
      rows: 10,
    ),
    PlanetData(
      name: 'Earth',
      subtitle: 'The living planet',
      description: 'Earth is the only known planet with life and liquid water.',
      diameter: '12,742 km',
      mass: '5.97 × 10²⁴ kg',
      dayLength: '24 h',
      assetPath: 'assets/images/planets/earth.png',
      frameCount: 100,
      columns: 10,
      rows: 10,
    ),
    PlanetData(
      name: 'Mars',
      subtitle: 'The red planet',
      description: 'Mars is a cold desert world with signs of ancient water.',
      diameter: '6,779 km',
      mass: '6.42 × 10²³ kg',
      dayLength: '24.6 h',
      assetPath: 'assets/images/planets/mars.png',
      frameCount: 100,
      columns: 10,
      rows: 10,
    ),
    PlanetData(
      name: 'Jupiter',
      subtitle: 'King of the planets',
      description: 'Jupiter is the largest planet, famous for the Great Red Spot.',
      diameter: '139,820 km',
      mass: '1.90 × 10²⁷ kg',
      dayLength: '9.9 h',
      assetPath: 'assets/images/planets/jupiter.png',
      frameCount: 100,
      columns: 10,
      rows: 10,
    ),
    PlanetData(
      name: 'Saturn',
      subtitle: 'The ringed giant',
      description: 'Saturn is known for its spectacular rings.',
      diameter: '116,460 km',
      mass: '5.68 × 10²⁶ kg',
      dayLength: '10.7 h',
      assetPath: 'assets/images/planets/saturn.png',
      frameCount: 81,
      columns: 9,
      rows: 9,
    ),
    PlanetData(
      name: 'Uranus',
      subtitle: 'The sideways planet',
      description: 'Uranus rotates on its side, giving it extreme seasons.',
      diameter: '50,724 km',
      mass: '8.68 × 10²⁵ kg',
      dayLength: '17.2 h',
      assetPath: 'assets/images/planets/uranus.png',
      frameCount: 81,
      columns: 9,
      rows: 9,
    ),
    PlanetData(
      name: 'Neptune',
      subtitle: 'The windy ice giant',
      description: 'Neptune has the fastest winds in the Solar System.',
      diameter: '49,244 km',
      mass: '1.02 × 10²⁶ kg',
      dayLength: '16.1 h',
      assetPath: 'assets/images/planets/neptune.png',
      frameCount: 100,
      columns: 10,
      rows: 10,
    ),
    PlanetData(
      name: 'Pluto',
      subtitle: 'The distant dwarf world',
      description: 'Pluto is a dwarf planet with icy mountains.',
      diameter: '2,377 km',
      mass: '1.31 × 10²² kg',
      dayLength: '153.3 h',
      assetPath: 'assets/images/planets/pluto.png',
      frameCount: 100,
      columns: 10,
      rows: 10,
    ),
  ];

  void _openPlanetPopup(PlanetData planet) {
    ApolloNavigator.setActivePlanet(planet);

    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: planet.name,
      barrierColor: Colors.black.withOpacity(0.72),
      transitionDuration: const Duration(milliseconds: 320),
      pageBuilder: (_, __, ___) {
        return PlanetInfoPopup(planet: planet);
      },
      transitionBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: animation,
          child: Transform.scale(
            scale: 0.92 + animation.value * 0.08,
            child: child,
          ),
        );
      },
    ).then((_) {
      ApolloNavigator.clearActivePlanet();
    });
  }

  @override
  void initState() {
    super.initState();

    ApolloNavigator.mainSelectorContext = context;
    ApolloNavigator.registerPlanets(planets);
    ApolloNavigator.updateCurrentPlanet(_realIndex(_initialPage));
    ApolloNavigator.planetPageController = _pageController;
    ApolloNavigator.registerOpenPlanetPopup(_openPlanetPopup);

    ApolloNavigator.registerClosePlanetPopup(() {
      if (!ApolloNavigator.isPlanetPopupOpen) return;

      Navigator.of(context, rootNavigator: true).pop();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      apolloVoice.start();
    });

    _pageController.addListener(() {
      if (!mounted) return;

      setState(() {
        _currentPage = _pageController.page ?? _initialPage.toDouble();
      });

      ApolloNavigator.updateCurrentPlanet(_realIndex(_currentPage.round()));
    });
  }

  @override
  void dispose() {
    if (ApolloNavigator.planetPageController == _pageController) {
      ApolloNavigator.planetPageController = null;
    }

    if (ApolloNavigator.mainSelectorContext == context) {
      ApolloNavigator.mainSelectorContext = null;
    }

    ApolloNavigator.closePlanetPopup = null;
    ApolloNavigator.openPlanetPopup = null;
    _pageController.dispose();
    super.dispose();
  }

  int _realIndex(int index) {
    final length = planets.length;
    return ((index % length) + length) % length;
  }

  double getSunScale() {
    final page = _currentPage;
    final lowerPage = page.floor();
    final upperPage = page.ceil();

    final lowerIndex = _realIndex(lowerPage);
    final upperIndex = _realIndex(upperPage);
    final t = page - lowerPage;

    final lowerCloseness = 1.0 - (lowerIndex / (planets.length - 1));
    final upperCloseness = 1.0 - (upperIndex / (planets.length - 1));
    final closeness = lowerCloseness + (upperCloseness - lowerCloseness) * t;

    return 1.0 + closeness * 2.0;
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sunScale = getSunScale();

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topCenter,
                radius: 1.45,
                colors: [
                  Color(0xFF4B2A78),
                  Color(0xFF1A1238),
                  Color(0xFF09051A),
                ],
              ),
            ),
          ),

          _StarField(size: size),

          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white12),
                ),
                child: const AIStatusDots(),
              ),
            ),
          ),

          Positioned(
            top: 105,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 470,
              child: PageView.builder(
                controller: _pageController,
                itemBuilder: (_, index) {
                  final rawDistance = _currentPage - index;
                  final distance = rawDistance.abs().clamp(0.0, 3.0);
                  final scale = (1 - distance * 0.09).clamp(0.72, 1.0);
                  final opacity = (1 - distance * 0.18).clamp(0.35, 1.0);
                  final yOffset = distance * distance * 38;
                  final xCurve = -rawDistance.sign * distance * distance * 12;
                  final rotation = rawDistance * 0.35;
                  final planet = planets[_realIndex(index)];

                  return Transform.translate(
                    offset: Offset(xCurve, yOffset),
                    child: Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0018)
                        ..rotateY(rotation),
                      child: Transform.scale(
                        scale: scale,
                        child: Opacity(
                          opacity: opacity,
                          child: Center(
                            child: SizedBox.square(
                              dimension: 230,
                              child: _PlanetSelectorItem(
                                planet: planet,
                                isSelected: distance < 0.5,
                                onTap: () => _openPlanetPopup(planet),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Center(
              child: Transform.scale(
                scale: sunScale * 3,
                child: const SizedBox.square(
                  dimension: 105,
                  child: _SunSquare(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanetSelectorItem extends StatelessWidget {
  final PlanetData planet;
  final bool isSelected;
  final VoidCallback onTap;

  const _PlanetSelectorItem({
    required this.planet,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: planet.hasSprite
          ? _PlanetSpriteCard(
        planet: planet,
        isSelected: isSelected,
      )
          : _PlanetFallbackSquare(
        title: planet.name,
        isSelected: isSelected,
      ),
    );
  }
}

class _PlanetSpriteCard extends StatelessWidget {
  final PlanetData planet;
  final bool isSelected;

  const _PlanetSpriteCard({
    required this.planet,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: isSelected ? 1.04 : 0.94,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          color: Colors.white.withOpacity(isSelected ? 0.08 : 0.035),
          border: Border.all(
            color: isSelected
                ? Colors.white.withOpacity(0.9)
                : Colors.white.withOpacity(0.14),
          ),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: const Color(0xFF8DEBFF).withOpacity(0.35),
                blurRadius: 24,
                spreadRadius: 1,
              ),
          ],
        ),
        child: Column(
          children: [
            Expanded(
              child: Center(
                child: SizedBox.square(
                  dimension: isSelected ? 128 : 112,
                  child: AnimatedSpritePlanet(
                    assetPath: planet.assetPath!,
                    frameCount: planet.frameCount,
                    columns: planet.columns,
                    rows: planet.rows,
                    animate: isSelected,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              planet.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'JockeyOne',
                color: Colors.white,
                fontSize: isSelected ? 30 : 24,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlanetFallbackSquare extends StatelessWidget {
  final String title;
  final bool isSelected;

  const _PlanetFallbackSquare({
    required this.title,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 220),
      padding: const EdgeInsets.all(34),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(34),
        gradient: isSelected
            ? const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF8DEBFF),
            Color(0xFF7A5CFF),
          ],
        )
            : LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.14),
            Colors.white.withOpacity(0.045),
          ],
        ),
        border: Border.all(
          color: isSelected
              ? Colors.white.withOpacity(0.85)
              : Colors.white.withOpacity(0.16),
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: const Color(0xFF8DEBFF).withOpacity(0.35),
              blurRadius: 28,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Center(
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: isSelected ? 32 : 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _SunSquare extends StatelessWidget {
  const _SunSquare();

  @override
  Widget build(BuildContext context) {
    return const AnimatedSpriteSun();
  }
}

class _StarField extends StatefulWidget {
  final Size size;

  const _StarField({required this.size});

  @override
  State<_StarField> createState() => _StarFieldState();
}

class _StarFieldState extends State<_StarField>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final List<_StarData> stars;

  @override
  void initState() {
    super.initState();

    final random = Random();

    stars = List.generate(70, (i) {
      final layer = i % 3;

      return _StarData(
        x: random.nextDouble(),
        y: random.nextDouble(),
        size: layer == 0
            ? random.nextDouble() * 1.2 + 0.5
            : layer == 1
            ? random.nextDouble() * 1.7 + 0.8
            : random.nextDouble() * 2.2 + 1.1,
        opacity: random.nextDouble() * 0.55 + 0.2,
        speed: layer == 0
            ? random.nextDouble() * 0.14 + 0.04
            : layer == 1
            ? random.nextDouble() * 0.24 + 0.12
            : random.nextDouble() * 0.38 + 0.22,
        twinkleOffset: random.nextDouble() * pi * 2,
      );
    });

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, __) {
          return Stack(
            children: stars.map((star) {
              final drift = _controller.value * star.speed;

              final x = ((star.x + drift * 0.35) % 1.0) * widget.size.width;
              final y = ((star.y + drift * 0.12) % 1.0) * widget.size.height;

              final twinkle =
                  (sin(_controller.value * pi * 2 + star.twinkleOffset) + 1) /
                      2;

              return Positioned(
                left: x,
                top: y,
                child: Container(
                  width: star.size,
                  height: star.size,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(
                      (star.opacity + twinkle * 0.25).clamp(0.12, 0.85),
                    ),
                    shape: BoxShape.circle,
                  ),
                ),
              );
            }).toList(),
          );
        },
      ),
    );
  }
}

class _StarData {
  final double x;
  final double y;
  final double size;
  final double opacity;
  final double speed;
  final double twinkleOffset;

  const _StarData({
    required this.x,
    required this.y,
    required this.size,
    required this.opacity,
    required this.speed,
    required this.twinkleOffset,
  });
}