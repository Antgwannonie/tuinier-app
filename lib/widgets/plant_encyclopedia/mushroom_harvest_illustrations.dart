import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class MushroomHarvestAssets {
  static const hero = 'assets/images/mushroom_harvest/harvest_hero.png';
}

class MushroomHarvestIllustration extends StatelessWidget {
  const MushroomHarvestIllustration({
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
    final image = Image.asset(
      assetPath,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => _Placeholder(compact: compact),
    );

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

class _Placeholder extends StatelessWidget {
  const _Placeholder({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.grass_rounded,
        size: compact ? 22 : 32,
        color: const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.5),
      ),
    );
  }
}
