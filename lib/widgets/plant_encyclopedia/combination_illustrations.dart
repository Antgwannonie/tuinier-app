import 'package:flutter/material.dart';

import '../../data/plant_combination_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';

const _comboAssets = {
  PlantCombinationIllustration.goodNeighbors:
      'assets/images/combination/combo_good_neighbors.png',
  PlantCombinationIllustration.badNeighbors:
      'assets/images/combination/combo_bad_neighbors.png',
  PlantCombinationIllustration.plantFamily:
      'assets/images/combination/combo_plant_family.png',
  PlantCombinationIllustration.cropRotation:
      'assets/images/combination/combo_crop_rotation.png',
  PlantCombinationIllustration.predecessors:
      'assets/images/combination/combo_predecessors.png',
  PlantCombinationIllustration.successors:
      'assets/images/combination/combo_successors.png',
  PlantCombinationIllustration.companions:
      'assets/images/combination/combo_companions.png',
  PlantCombinationIllustration.pestPlants:
      'assets/images/combination/combo_pest_plants.png',
  PlantCombinationIllustration.soilImprovers:
      'assets/images/combination/combo_soil_improvers.png',
  PlantCombinationIllustration.nitrogenFixers:
      'assets/images/combination/combo_nitrogen_fixers.png',
  PlantCombinationIllustration.greenManure:
      'assets/images/combination/combo_green_manure.png',
  PlantCombinationIllustration.spaceSaving:
      'assets/images/combination/combo_space_saving.png',
  PlantCombinationIllustration.benefits:
      'assets/images/combination/combo_benefits.png',
  PlantCombinationIllustration.mistakes:
      'assets/images/combination/combo_mistakes.png',
};

enum CombinationIllustrationSize {
  large,
  compact,
  icon,
}

class CombinationIllustration extends StatelessWidget {
  const CombinationIllustration({
    super.key,
    required this.kind,
    this.size = CombinationIllustrationSize.large,
  });

  final PlantCombinationIllustration kind;
  final CombinationIllustrationSize size;

  double get _height {
    return switch (size) {
      CombinationIllustrationSize.icon => 72,
      CombinationIllustrationSize.compact => 100,
      CombinationIllustrationSize.large => 140,
    };
  }

  @override
  Widget build(BuildContext context) {
    final asset = _comboAssets[kind];
    if (asset == null) return SizedBox(height: _height);

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: const Color(PlantDetailDesign.card),
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.medium,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}
