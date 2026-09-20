import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class MushroomGrowthAssets {
  static const hero = 'assets/images/mushroom_growth/growth_hero.png';
  static const monitoring =
      'assets/images/mushroom_growth/growth_monitoring.png';
}

class MushroomGrowthIllustration extends StatelessWidget {
  const MushroomGrowthIllustration({
    super.key,
    required this.assetPath,
    this.aspectRatio = 4 / 3,
    this.compact = false,
  });

  final String assetPath;
  final double aspectRatio;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(compact ? 10 : 12),
      child: ColoredBox(
        color: compact ? const Color(0xFFF8FAF7) : const Color(PlantDetailDesign.card),
        child: AspectRatio(
          aspectRatio: aspectRatio,
          child: Image.asset(
            assetPath,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => Center(
              child: Icon(
                Icons.trending_up_rounded,
                size: compact ? 22 : 32,
                color: const Color(PlantDetailDesign.primaryGreen)
                    .withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
