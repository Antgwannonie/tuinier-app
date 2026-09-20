import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class MushroomFruitingAssets {
  static const hero = 'assets/images/mushroom_fruiting/fruiting_hero.png';
  static const pinheads = 'assets/images/mushroom_fruiting/fruiting_pinheads.png';
  static const tip = 'assets/images/mushroom_fruiting/fruiting_tip.png';
}

class MushroomFruitingIllustration extends StatelessWidget {
  const MushroomFruitingIllustration({
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
                Icons.spa_outlined,
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
