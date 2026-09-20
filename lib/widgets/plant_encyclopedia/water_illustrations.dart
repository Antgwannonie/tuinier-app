import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_water_guide.dart';
import 'sowing_illustrations.dart';

const _waterAssets = {
  PlantWaterIllustration.wateringCan:
      'assets/images/water/water_watering_can.png',
  PlantWaterIllustration.germinationSpray:
      'assets/images/water/water_germination_spray.png',
  PlantWaterIllustration.growthStages:
      'assets/images/water/water_growth_stages.png',
  PlantWaterIllustration.floweringStages:
      'assets/images/water/water_flowering_stages.png',
  PlantWaterIllustration.fruitingStages:
      'assets/images/water/water_fruiting_stages.png',
  PlantWaterIllustration.tooLittleWater:
      'assets/images/water/water_too_little.png',
  PlantWaterIllustration.tooMuchWater:
      'assets/images/water/water_too_much.png',
  PlantWaterIllustration.waterQuality:
      'assets/images/water/water_quality_barrel.png',
  PlantWaterIllustration.potWatering:
      'assets/images/water/water_pot.png',
  PlantWaterIllustration.greenhouseWater:
      'assets/images/water/water_greenhouse.png',
};

class WaterIllustration extends StatelessWidget {
  const WaterIllustration({
    super.key,
    required this.kind,
    this.size = WaterIllustrationSize.normal,
  });

  final PlantWaterIllustration kind;
  final WaterIllustrationSize size;

  double get _height {
    switch (size) {
      case WaterIllustrationSize.inline:
        return 72;
      case WaterIllustrationSize.compact:
        return 92;
      case WaterIllustrationSize.normal:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _waterAssets[kind];
    if (asset == null) return const SizedBox.shrink();

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: ColoredBox(
        color: const Color(PlantDetailDesign.card),
        child: Image.asset(
          asset,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.image_not_supported_outlined, size: 28),
          ),
        ),
      ),
    );

    if (size == WaterIllustrationSize.normal) {
      return AspectRatio(
        aspectRatio: SowingIllustrationFormat.aspectRatio,
        child: image,
      );
    }

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: image,
    );
  }
}
