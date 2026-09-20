import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class InoculationAssets {
  static const hero = 'assets/images/mushroom_inoculation/inoculation_hero.png';
  static const hygieneSpray =
      'assets/images/mushroom_inoculation/inoculation_hygiene_spray.png';
  static const mistakes =
      'assets/images/mushroom_inoculation/inoculation_mistakes.png';
  static const prevention =
      'assets/images/mushroom_inoculation/inoculation_prevention.png';
}

class InoculationIllustration extends StatelessWidget {
  const InoculationIllustration({
    super.key,
    required this.assetPath,
    this.aspectRatio = 4 / 3,
    this.compact = false,
    this.circle = false,
  });

  final String assetPath;
  final double aspectRatio;
  final bool compact;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => _Placeholder(compact: compact, circle: circle),
    );

    Widget child = image;
    if (circle) {
      child = ClipOval(
        child: AspectRatio(aspectRatio: 1, child: image),
      );
    } else {
      child = AspectRatio(
        aspectRatio: aspectRatio,
        child: image,
      );
    }

    if (circle) {
      return SizedBox(
        width: compact ? 52 : 64,
        height: compact ? 52 : 64,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: const Color(0xFFF8FAF7),
            border: Border.all(color: const Color(PlantDetailDesign.border)),
          ),
          child: child,
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
      child: ColoredBox(
        color: compact ? const Color(0xFFF8FAF7) : const Color(PlantDetailDesign.card),
        child: child,
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.compact, required this.circle});

  final bool compact;
  final bool circle;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.science_outlined,
        size: compact ? 22 : 32,
        color: const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.5),
      ),
    );
  }
}
