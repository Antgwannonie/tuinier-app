import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_nutrition_guide.dart';
import 'sowing_illustrations.dart';

const _nutritionAssets = {
  PlantNutritionIllustration.soilSand:
      'assets/images/nutrition/nutrition_soil_sand.png',
  PlantNutritionIllustration.soilLoam:
      'assets/images/nutrition/nutrition_soil_loam.png',
  PlantNutritionIllustration.soilClay:
      'assets/images/nutrition/nutrition_soil_clay.png',
  PlantNutritionIllustration.soilHumus:
      'assets/images/nutrition/nutrition_soil_humus.png',
  PlantNutritionIllustration.compostBin:
      'assets/images/nutrition/nutrition_compost_bin.png',
  PlantNutritionIllustration.fertCompost:
      'assets/images/nutrition/nutrition_fert_compost.png',
  PlantNutritionIllustration.fertWorm:
      'assets/images/nutrition/nutrition_fert_worm.png',
  PlantNutritionIllustration.fertCow:
      'assets/images/nutrition/nutrition_fert_cow.png',
  PlantNutritionIllustration.nitrogenLeaves:
      'assets/images/nutrition/nutrition_nitrogen_leaves.png',
  PlantNutritionIllustration.phosphorusRoots:
      'assets/images/nutrition/nutrition_phosphorus_roots.png',
  PlantNutritionIllustration.potassiumFruits:
      'assets/images/nutrition/nutrition_potassium_fruits.png',
  PlantNutritionIllustration.plantingFeed:
      'assets/images/nutrition/nutrition_planting_feed.png',
  PlantNutritionIllustration.growthFeed:
      'assets/images/nutrition/nutrition_growth_feed.png',
  PlantNutritionIllustration.floweringFeed:
      'assets/images/nutrition/nutrition_flowering_feed.png',
  PlantNutritionIllustration.fruitingFeed:
      'assets/images/nutrition/nutrition_fruiting_feed.png',
  PlantNutritionIllustration.deficiency:
      'assets/images/nutrition/nutrition_deficiency.png',
  PlantNutritionIllustration.overfertilization:
      'assets/images/nutrition/nutrition_overfertilization.png',
  PlantNutritionIllustration.improveCompost:
      'assets/images/nutrition/nutrition_improve_compost.png',
  PlantNutritionIllustration.improveCoverCrop:
      'assets/images/nutrition/nutrition_improve_cover_crop.png',
  PlantNutritionIllustration.improveMulch:
      'assets/images/nutrition/nutrition_improve_mulch.png',
  PlantNutritionIllustration.improveOrganic:
      'assets/images/nutrition/nutrition_improve_organic.png',
  PlantNutritionIllustration.aiSchedule:
      'assets/images/nutrition/nutrition_ai_schedule.png',
};

class NutritionIllustration extends StatelessWidget {
  const NutritionIllustration({
    super.key,
    required this.kind,
    this.size = NutritionIllustrationSize.normal,
  });

  final PlantNutritionIllustration kind;
  final NutritionIllustrationSize size;

  double get _height {
    switch (size) {
      case NutritionIllustrationSize.small:
        return 52;
      case NutritionIllustrationSize.compact:
        return 88;
      case NutritionIllustrationSize.normal:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _nutritionAssets[kind];
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
            child: Icon(Icons.image_not_supported_outlined, size: 24),
          ),
        ),
      ),
    );

    if (size == NutritionIllustrationSize.normal) {
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
