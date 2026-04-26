import 'package:flutter/material.dart';

import '../models/planet_data.dart';
import '../widgets/animated_sprite_planet.dart';

import '../models/planet_quiz_question.dart';
import '../services/apollo_quiz_service.dart';

import 'dart:math';

class PlanetInfoPopup extends StatefulWidget {
  final PlanetData planet;

  const PlanetInfoPopup({
    super.key,
    required this.planet,
  });

  @override
  State<PlanetInfoPopup> createState() => _PlanetInfoPopupState();
}

class _PlanetInfoPopupState extends State<PlanetInfoPopup> {
  bool isFavorite = false;

  final List<PlanetData> comparePlanets = const [
    PlanetData(
      name: 'Mercury',
      subtitle: 'The swift planet',
      description: 'Mercury is the closest planet to the Sun.',
      diameter: '4,879 km',
      mass: '3.30 × 10²³ kg',
      dayLength: '1407.6 h',
    ),
    PlanetData(
      name: 'Venus',
      subtitle: 'Earth’s hot twin',
      description: 'Venus is the hottest planet.',
      diameter: '12,104 km',
      mass: '4.87 × 10²⁴ kg',
      dayLength: '5832 h',
    ),
    PlanetData(
      name: 'Earth',
      subtitle: 'The living planet',
      description: 'Earth is the only known planet with life.',
      diameter: '12,742 km',
      mass: '5.97 × 10²⁴ kg',
      dayLength: '24 h',
    ),
    PlanetData(
      name: 'Mars',
      subtitle: 'The red planet',
      description: 'Mars is a cold desert world.',
      diameter: '6,779 km',
      mass: '6.42 × 10²³ kg',
      dayLength: '24.6 h',
    ),
  ];

  Future<void> _openQuiz() async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const _QuizLoadingDialog(),
    );

    final quiz = await ApolloQuizService.generateQuiz(widget.planet);

    if (!mounted) return;

    Navigator.pop(context);

    if (quiz == null) {
      showDialog(
        context: context,
        builder: (_) => const _QuizErrorDialog(),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => _AIPlanetQuizDialog(
        planet: widget.planet,
        quiz: quiz,
      ),
    );
  }

  void _openCompare() {
    showDialog(
      context: context,
      builder: (_) => _CompareDialog(
        currentPlanet: widget.planet,
        planets: comparePlanets,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final planet = widget.planet;

    return SafeArea(
      child: Material(
        color: Colors.transparent,
        child: Center(
          child: Container(
            margin: const EdgeInsets.all(18),
            constraints: const BoxConstraints(maxWidth: 520),
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(32),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF111827),
                  Color(0xFF07111F),
                  Color(0xFF050814),
                ],
              ),
              border: Border.all(color: Colors.white12),
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _PopupTopBar(
                    isFavorite: isFavorite,
                    onFavoriteTap: () {
                      setState(() {
                        isFavorite = !isFavorite;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _PlanetPopupIntro(planet: planet)),
                      const SizedBox(width: 18),
                      SizedBox.square(
                        dimension: 150,
                        child: planet.hasSprite
                            ? AnimatedSpritePlanet(
                          assetPath: planet.assetPath!,
                          frameCount: planet.frameCount,
                          columns: planet.columns,
                          rows: planet.rows,
                          animate: true,
                        )
                            : const SizedBox(),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  _StatsBar(planet: planet),
                  const SizedBox(height: 24),
                  _PopupSection(
                    title: 'Key features',
                    children: [
                      _InfoRow(
                        icon: Icons.public,
                        title: 'Solar System role',
                        text:
                        '${planet.name} has its own structure, motion, and environmental conditions.',
                      ),
                      const _InfoRow(
                        icon: Icons.auto_awesome,
                        title: 'Unique structure',
                        text:
                        'Every planet has different materials, temperatures, atmosphere, and rotation behavior.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _PopupSection(
                    title: 'Interactive learning',
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCard(
                              title: 'Quick quiz',
                              icon: Icons.quiz_rounded,
                              color: const Color(0xFF9B5CFF),
                              onTap: _openQuiz,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionCard(
                              title: 'Compare',
                              icon: Icons.balance_rounded,
                              color: const Color(0xFF56C7FF),
                              onTap: _openCompare,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PopupTopBar extends StatelessWidget {
  final bool isFavorite;
  final VoidCallback onFavoriteTap;

  const _PopupTopBar({
    required this.isFavorite,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _RoundButton(
          icon: Icons.arrow_back_ios_new_rounded,
          onTap: () => Navigator.pop(context),
        ),
        const Spacer(),
        _RoundButton(
          icon: isFavorite
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isFavorite ? const Color(0xFFFF5C8A) : Colors.white,
          onTap: onFavoriteTap,
        ),
      ],
    );
  }
}

class _PlanetPopupIntro extends StatelessWidget {
  final PlanetData planet;

  const _PlanetPopupIntro({required this.planet});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.centerLeft,
          child: Text(
            planet.name,
            maxLines: 1,
            style: const TextStyle(
              fontFamily: 'JockeyOne',
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          planet.subtitle,
          style: const TextStyle(
            color: Color(0xFFFFC857),
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        Text(
          planet.description,
          style: TextStyle(
            color: Colors.white.withOpacity(0.78),
            height: 1.45,
            fontSize: 16,
          ),
        ),
      ],
    );
  }
}

class _StatsBar extends StatelessWidget {
  final PlanetData planet;

  const _StatsBar({required this.planet});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.055),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              icon: Icons.straighten,
              label: 'Diameter',
              value: planet.diameter,
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.monitor_weight_outlined,
              label: 'Mass',
              value: planet.mass,
            ),
          ),
          Expanded(
            child: _StatItem(
              icon: Icons.schedule,
              label: 'Day',
              value: planet.dayLength,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFFFFC857), size: 22),
        const SizedBox(height: 8),
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.65))),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            maxLines: 1,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _PlanetQuizDialog extends StatefulWidget {
  final PlanetData planet;

  const _PlanetQuizDialog({required this.planet});

  @override
  State<_PlanetQuizDialog> createState() => _PlanetQuizDialogState();
}

class _PlanetQuizDialogState extends State<_PlanetQuizDialog> {
  String? selected;

  @override
  Widget build(BuildContext context) {
    final correct = widget.planet.diameter;

    final answers = [
      correct,
      '12,742 km',
      '49,244 km',
      '139,820 km',
    ].toSet().toList();

    return AlertDialog(
      backgroundColor: const Color(0xFF101827),
      title: Text(
        'Quick quiz: ${widget.planet.name}',
        style: const TextStyle(color: Colors.white),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'What is this planet’s diameter?',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          ...answers.map(
                (answer) => RadioListTile<String>(
              value: answer,
              groupValue: selected,
              activeColor: const Color(0xFFFFC857),
              title: Text(answer, style: const TextStyle(color: Colors.white)),
              onChanged: (value) => setState(() => selected = value),
            ),
          ),
          if (selected != null)
            Text(
              selected == correct ? 'Correct!' : 'Not quite. Try again.',
              style: TextStyle(
                color: selected == correct
                    ? const Color(0xFF7CFF9B)
                    : const Color(0xFFFF7070),
                fontWeight: FontWeight.bold,
              ),
            ),
        ],
      ),
    );
  }
}

class _CompareDialog extends StatefulWidget {
  final PlanetData currentPlanet;
  final List<PlanetData> planets;

  const _CompareDialog({
    required this.currentPlanet,
    required this.planets,
  });

  @override
  State<_CompareDialog> createState() => _CompareDialogState();
}

class _CompareDialogState extends State<_CompareDialog> {
  PlanetData? selectedPlanet;

  double _number(String value) {
    var cleaned = value
        .replaceAll(',', '')
        .replaceAll('km', '')
        .replaceAll('h', '')
        .replaceAll('kg', '')
        .replaceAll(' ', '')
        .trim();

    cleaned = cleaned
        .replaceAll('²⁰', '20')
        .replaceAll('²¹', '21')
        .replaceAll('²²', '22')
        .replaceAll('²³', '23')
        .replaceAll('²⁴', '24')
        .replaceAll('²⁵', '25')
        .replaceAll('²⁶', '26')
        .replaceAll('²⁷', '27')
        .replaceAll('²⁸', '28');

    if (cleaned.contains('×10')) {
      final parts = cleaned.split('×10');

      if (parts.length == 2) {
        final base = double.tryParse(parts[0]) ?? 0;
        final exponent = int.tryParse(parts[1]) ?? 0;

        return base * pow(10, exponent);
      }
    }

    return double.tryParse(cleaned) ?? 0;
  }

  String _ratio(String a, String b) {
    final n1 = _number(a);
    final n2 = _number(b);
    if (n1 <= 0 || n2 <= 0) return '—';

    final ratio = n1 > n2 ? n1 / n2 : n2 / n1;
    return '${ratio.toStringAsFixed(ratio > 10 ? 1 : 2)}×';
  }

  @override
  Widget build(BuildContext context) {
    selectedPlanet ??= widget.planets.firstWhere(
          (p) => p.name != widget.currentPlanet.name,
      orElse: () => widget.planets.first,
    );

    final other = selectedPlanet!;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 560),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(34),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF101B31),
              Color(0xFF08101F),
              Color(0xFF040712),
            ],
          ),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF56C7FF).withOpacity(0.18),
              blurRadius: 45,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.balance_rounded,
                    color: Color(0xFF56C7FF),
                    size: 34,
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'Planet Battle',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: _PlanetBattleCard(
                      planet: widget.currentPlanet,
                      color: const Color(0xFFFFC857),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white.withOpacity(0.07),
                        border: Border.all(color: Colors.white12),
                      ),
                      child: const Text(
                        'VS',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: _PlanetBattleCard(
                      planet: other,
                      color: const Color(0xFF56C7FF),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.055),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white10),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<PlanetData>(
                    value: selectedPlanet,
                    dropdownColor: const Color(0xFF101827),
                    iconEnabledColor: const Color(0xFF56C7FF),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    items: widget.planets
                        .where((p) => p.name != widget.currentPlanet.name)
                        .map(
                          (planet) => DropdownMenuItem(
                        value: planet,
                        child: Text('Compare with ${planet.name}'),
                      ),
                    )
                        .toList(),
                    onChanged: (planet) {
                      if (planet == null) return;
                      setState(() => selectedPlanet = planet);
                    },
                  ),
                ),
              ),

              const SizedBox(height: 20),

              _BattleStatRow(
                icon: Icons.straighten,
                title: 'Diameter clash',
                left: widget.currentPlanet.diameter,
                right: other.diameter,
                center: _ratio(widget.currentPlanet.diameter, other.diameter),
              ),
              _BattleStatRow(
                icon: Icons.monitor_weight_outlined,
                title: 'Mass duel',
                left: widget.currentPlanet.mass,
                right: other.mass,
                center: _ratio(widget.currentPlanet.mass, other.mass),
              ),
              _BattleStatRow(
                icon: Icons.schedule,
                title: 'Day length race',
                left: widget.currentPlanet.dayLength,
                right: other.dayLength,
                center: _ratio(widget.currentPlanet.dayLength, other.dayLength),
              ),

              const SizedBox(height: 18),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF56C7FF).withOpacity(0.12),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: const Color(0xFF56C7FF).withOpacity(0.35),
                  ),
                ),
                child: Text(
                  _verdict(widget.currentPlanet, other),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.84),
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _verdict(PlanetData a, PlanetData b) {
    final diameterA = _number(a.diameter);
    final diameterB = _number(b.diameter);
    final dayA = _number(a.dayLength);
    final dayB = _number(b.dayLength);

    final bigger = diameterA > diameterB ? a.name : b.name;
    final faster = dayA < dayB ? a.name : b.name;

    return 'Apollo verdict: $bigger dominates in size, while $faster spins faster. '
        '${a.name} vs ${b.name} is basically cosmic heavyweight stats versus orbital personality.';
  }
}

class _PlanetBattleCard extends StatelessWidget {
  final PlanetData planet;
  final Color color;

  const _PlanetBattleCard({
    required this.planet,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 116,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color.withOpacity(0.11),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: color.withOpacity(0.38)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              planet.name,
              maxLines: 1,
              style: TextStyle(
                color: color,
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            planet.subtitle,
            maxLines: 2,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white.withOpacity(0.66),
              fontSize: 12,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _BattleStatRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String left;
  final String center;
  final String right;

  const _BattleStatRow({
    required this.icon,
    required this.title,
    required this.left,
    required this.center,
    required this.right,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(icon, color: const Color(0xFFFFC857), size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Text(
                  left,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFC857).withOpacity(0.13),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: const Color(0xFFFFC857).withOpacity(0.35),
                  ),
                ),
                child: Text(
                  center,
                  style: const TextStyle(
                    color: Color(0xFFFFC857),
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  right,
                  textAlign: TextAlign.right,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _PopupSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _PopupSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.045),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.white, fontSize: 21)),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String text;

  const _InfoRow({
    required this.icon,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: const Color(0xFFFFC857)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      subtitle: Text(text, style: const TextStyle(color: Colors.white70)),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(22),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.13),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: color.withOpacity(0.35)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 34),
            const SizedBox(height: 10),
            Text(title, style: TextStyle(color: color)),
          ],
        ),
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RoundButton({
    required this.icon,
    this.color = Colors.white,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.08),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.white10),
        ),
        child: Icon(icon, color: color),
      ),
    );
  }
}

class _QuizLoadingDialog extends StatelessWidget {
  const _QuizLoadingDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF151F33),
              Color(0xFF08101F),
            ],
          ),
          border: Border.all(color: Colors.white12),
        ),
        child: Row(
          children: [
            const CircularProgressIndicator(color: Color(0xFFFFC857)),
            const SizedBox(width: 18),
            Expanded(
              child: Text(
                'Apollo is building your quiz...',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuizErrorDialog extends StatelessWidget {
  const _QuizErrorDialog();

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          color: const Color(0xFF101827),
          border: Border.all(color: Colors.white12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.warning_rounded, color: Color(0xFFFFC857), size: 42),
            const SizedBox(height: 14),
            const Text(
              'Quiz failed',
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Apollo could not generate a quiz right now.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            const SizedBox(height: 18),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AIPlanetQuizDialog extends StatefulWidget {
  final PlanetData planet;
  final PlanetQuizQuestion quiz;

  const _AIPlanetQuizDialog({
    required this.planet,
    required this.quiz,
  });

  @override
  State<_AIPlanetQuizDialog> createState() => _AIPlanetQuizDialogState();
}

class _AIPlanetQuizDialogState extends State<_AIPlanetQuizDialog> {
  int? selectedIndex;

  @override
  Widget build(BuildContext context) {
    final answered = selectedIndex != null;
    final correct = selectedIndex == widget.quiz.correctIndex;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(18),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        padding: const EdgeInsets.all(22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(30),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF151F33),
              Color(0xFF0B1224),
              Color(0xFF050814),
            ],
          ),
          border: Border.all(color: Colors.white12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.45),
              blurRadius: 34,
              spreadRadius: 4,
            ),
          ],
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: const Color(0xFF9B5CFF).withOpacity(0.16),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: const Color(0xFF9B5CFF).withOpacity(0.35),
                      ),
                    ),
                    child: const Icon(
                      Icons.quiz_rounded,
                      color: Color(0xFFBFA2FF),
                      size: 30,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${widget.planet.name} Quiz',
                            maxLines: 1,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        Text(
                          'Generated by Apollo',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.55),
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close_rounded, color: Colors.white70),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.055),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: Colors.white10),
                ),
                child: Text(
                  widget.quiz.question,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              ...List.generate(widget.quiz.answers.length, (index) {
                final isSelected = selectedIndex == index;
                final isCorrect = widget.quiz.correctIndex == index;

                Color borderColor = Colors.white12;
                Color backgroundColor = Colors.white.withOpacity(0.045);
                Color iconColor = Colors.white54;
                IconData icon = Icons.circle_outlined;

                if (answered && isCorrect) {
                  borderColor = const Color(0xFF7CFF9B);
                  backgroundColor = const Color(0xFF7CFF9B).withOpacity(0.12);
                  iconColor = const Color(0xFF7CFF9B);
                  icon = Icons.check_circle_rounded;
                } else if (answered && isSelected && !isCorrect) {
                  borderColor = const Color(0xFFFF7070);
                  backgroundColor = const Color(0xFFFF7070).withOpacity(0.12);
                  iconColor = const Color(0xFFFF7070);
                  icon = Icons.cancel_rounded;
                } else if (!answered && isSelected) {
                  borderColor = const Color(0xFFFFC857);
                  backgroundColor = const Color(0xFFFFC857).withOpacity(0.12);
                  iconColor = const Color(0xFFFFC857);
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
                    onTap: answered
                        ? null
                        : () {
                      setState(() {
                        selectedIndex = index;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: borderColor),
                      ),
                      child: Row(
                        children: [
                          Icon(icon, color: iconColor, size: 24),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              widget.quiz.answers[index],
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                height: 1.25,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),

              if (answered) ...[
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: (correct
                        ? const Color(0xFF7CFF9B)
                        : const Color(0xFFFF7070))
                        .withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: correct
                          ? const Color(0xFF7CFF9B)
                          : const Color(0xFFFF7070),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        correct ? 'Correct!' : 'Not quite.',
                        style: TextStyle(
                          color: correct
                              ? const Color(0xFF7CFF9B)
                              : const Color(0xFFFF7070),
                          fontWeight: FontWeight.w900,
                          fontSize: 18,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.quiz.explanation,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.78),
                          height: 1.4,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}