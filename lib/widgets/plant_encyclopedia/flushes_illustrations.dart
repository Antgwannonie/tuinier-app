import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class FlushesAssets {
  static const hero = 'assets/images/mushroom_flushes/flushes_hero.png';
  static const cycleHarvest =
      'assets/images/mushroom_flushes/flushes_cycle_harvest.png';
  static const cyclePinheads =
      'assets/images/mushroom_flushes/flushes_cycle_pinheads.png';
  static const cycleNext = 'assets/images/mushroom_flushes/flushes_cycle_next.png';
  static const problemDry = 'assets/images/mushroom_flushes/flushes_problem_dry.png';
  static const problemWet = 'assets/images/mushroom_flushes/flushes_problem_wet.png';
  static const problemMold =
      'assets/images/mushroom_flushes/flushes_problem_mold.png';
  static const problemSlow =
      'assets/images/mushroom_flushes/flushes_problem_slow.png';
  static const problemFewPins =
      'assets/images/mushroom_flushes/flushes_problem_few_pins.png';
  static const feeding = 'assets/images/mushroom_flushes/flushes_feeding.png';
}

class FlushesIllustration extends StatelessWidget {
  const FlushesIllustration({
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
                Icons.autorenew_rounded,
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
