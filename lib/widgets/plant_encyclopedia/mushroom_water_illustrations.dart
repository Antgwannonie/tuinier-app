import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';

abstract final class MushroomWaterAssets {
  static const hero = 'assets/images/mushroom_water/water_hero.png';
  static const substrateMoisture =
      'assets/images/mushroom_water/water_substrate_moisture.png';
  static const signalDry = 'assets/images/mushroom_water/water_signal_dry.png';
  static const signalWet = 'assets/images/mushroom_water/water_signal_wet.png';
  static const hygrometer = 'assets/images/mushroom_water/water_hygrometer.png';
}

class MushroomWaterIllustration extends StatelessWidget {
  const MushroomWaterIllustration({
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
                Icons.water_drop_outlined,
                size: compact ? 22 : 32,
                color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
