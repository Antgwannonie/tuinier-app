import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class ColonizationAssets {
  static const hero = 'assets/images/mushroom_colonization/colonization_hero.png';
  static const healthyMycelium =
      'assets/images/mushroom_colonization/colonization_healthy_mycelium.png';
  static const fullBlock =
      'assets/images/mushroom_colonization/colonization_full_block.png';
  static const rack =
      'assets/images/mushroom_colonization/colonization_rack.png';
}

class ColonizationIllustration extends StatelessWidget {
  const ColonizationIllustration({
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
      fit: BoxFit.cover,
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
        width: compact ? 52 : 72,
        height: compact ? 52 : 72,
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
        Icons.grass_outlined,
        size: compact ? 22 : 32,
        color: const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.5),
      ),
    );
  }
}
