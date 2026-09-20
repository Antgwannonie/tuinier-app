import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class MushroomProblemsAssets {
  static const hero = 'assets/images/mushroom_problems/problems_hero.png';
  static const discardTrash =
      'assets/images/mushroom_problems/problems_discard_trash.png';
}

class MushroomProblemsIllustration extends StatelessWidget {
  const MushroomProblemsIllustration({
    super.key,
    required this.assetPath,
    this.aspectRatio = 4 / 3,
    this.compact = false,
    this.circular = false,
  });

  final String assetPath;
  final double aspectRatio;
  final bool compact;
  final bool circular;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => Center(
        child: Icon(
          Icons.warning_amber_rounded,
          size: compact ? 22 : 32,
          color: const Color(0xFFB71C1C).withValues(alpha: 0.5),
        ),
      ),
    );

    if (circular) {
      return ClipOval(
        child: AspectRatio(
          aspectRatio: 1,
          child: ColoredBox(
            color: const Color(0xFFF8FAF7),
            child: image,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
      child: ColoredBox(
        color: compact ? const Color(0xFFF8FAF7) : const Color(PlantDetailDesign.card),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: image,
        ),
      ),
    );
  }
}
