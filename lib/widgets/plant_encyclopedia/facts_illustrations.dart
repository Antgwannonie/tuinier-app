import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class FactsAssets {
  static const hero = 'assets/images/mushroom_facts/facts_hero.png';
  static const top1Fungus = 'assets/images/mushroom_facts/facts_top1_fungus.png';
  static const top2Mycelium = 'assets/images/mushroom_facts/facts_top2_mycelium.png';
  static const top3Nature = 'assets/images/mushroom_facts/facts_top3_nature.png';
  static const top4Nutrition = 'assets/images/mushroom_facts/facts_top4_nutrition.png';
  static const top5History = 'assets/images/mushroom_facts/facts_top5_history.png';
  static const top6Variety = 'assets/images/mushroom_facts/facts_top6_variety.png';
  static const cultivation = 'assets/images/mushroom_facts/facts_cultivation.png';
  static const spotlightKingOyster =
      'assets/images/mushroom_facts/facts_spotlight_king_oyster.png';
}

class FactsIllustration extends StatelessWidget {
  const FactsIllustration({
    super.key,
    required this.assetPath,
    this.aspectRatio = 4 / 3,
    this.compact = false,
    this.borderRadius = 12,
  });

  final String assetPath;
  final double aspectRatio;
  final bool compact;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final image = Image.asset(
      assetPath,
      fit: BoxFit.cover,
      filterQuality: FilterQuality.medium,
      errorBuilder: (_, __, ___) => _Placeholder(compact: compact),
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
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
        Icons.lightbulb_outline_rounded,
        size: compact ? 22 : 32,
        color: const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.5),
      ),
    );
  }
}
