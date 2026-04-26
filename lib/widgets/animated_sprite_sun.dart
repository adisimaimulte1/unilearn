import 'package:flutter/material.dart';
import 'animated_sprite_planet.dart';

class AnimatedSpriteSun extends StatelessWidget {
  const AnimatedSpriteSun({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      clipBehavior: Clip.none,
      children: [
        FractionallySizedBox(
          widthFactor: 0.55,
          heightFactor: 0.55,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFFB703).withOpacity(0.45),
                  blurRadius: 18,
                  spreadRadius: 3,
                ),
                BoxShadow(
                  color: const Color(0xFFFF5C00).withOpacity(0.28),
                  blurRadius: 28,
                  spreadRadius: 5,
                ),
              ],
            ),
          ),
        ),
        ClipOval(
          child: AnimatedSpritePlanet(
            assetPath: 'assets/images/planets/sun.png',
            frameCount: 81,
            columns: 9,
            rows: 9,
          ),
        ),
      ],
    );
  }
}