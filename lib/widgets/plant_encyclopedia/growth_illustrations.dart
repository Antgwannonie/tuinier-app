import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_growth_guide.dart';
import 'sowing_illustrations.dart';

const _growthAssets = {
  PlantGrowthIllustration.phaseGermination:
      'assets/images/growth/growth_phase_germination.png',
  PlantGrowthIllustration.phaseSeedling:
      'assets/images/growth/growth_phase_seedling.png',
  PlantGrowthIllustration.phaseYoung:
      'assets/images/growth/growth_phase_young.png',
  PlantGrowthIllustration.phaseGrowth:
      'assets/images/growth/growth_phase_growth.png',
  PlantGrowthIllustration.phaseBloom:
      'assets/images/growth/growth_phase_bloom.png',
  PlantGrowthIllustration.phaseFruiting:
      'assets/images/growth/growth_phase_fruiting.png',
  PlantGrowthIllustration.phaseHarvest:
      'assets/images/growth/growth_phase_harvest.png',
  PlantGrowthIllustration.growthDuration:
      'assets/images/growth/growth_duration_calendar.png',
  PlantGrowthIllustration.harvestTime:
      'assets/images/growth/growth_harvest_calendar.png',
  PlantGrowthIllustration.heightPlant:
      'assets/images/growth/growth_height.png',
  PlantGrowthIllustration.widthSpread:
      'assets/images/growth/growth_width.png',
  PlantGrowthIllustration.habitCompact:
      'assets/images/growth/growth_habit_compact.png',
  PlantGrowthIllustration.habitBush:
      'assets/images/growth/growth_habit_bush.png',
  PlantGrowthIllustration.habitUpright:
      'assets/images/growth/growth_habit_upright.png',
  PlantGrowthIllustration.habitClimbing:
      'assets/images/growth/growth_habit_climbing.png',
  PlantGrowthIllustration.habitCreeping:
      'assets/images/growth/growth_habit_creeping.png',
  PlantGrowthIllustration.supportStake:
      'assets/images/growth/growth_support_stake.png',
  PlantGrowthIllustration.supportTrellis:
      'assets/images/growth/growth_support_trellis.png',
  PlantGrowthIllustration.supportRope:
      'assets/images/growth/growth_support_rope.png',
  PlantGrowthIllustration.supportNone:
      'assets/images/growth/growth_support_none.png',
  PlantGrowthIllustration.tying:
      'assets/images/growth/growth_tying.png',
  PlantGrowthIllustration.topping:
      'assets/images/growth/growth_topping.png',
  PlantGrowthIllustration.pruningSuckers:
      'assets/images/growth/growth_pruning_suckers.png',
  PlantGrowthIllustration.thinning:
      'assets/images/growth/growth_thinning.png',
  PlantGrowthIllustration.stimulateWater:
      'assets/images/growth/growth_stimulate_water.png',
  PlantGrowthIllustration.stimulateNutrition:
      'assets/images/growth/growth_stimulate_nutrition.png',
  PlantGrowthIllustration.stimulateSun:
      'assets/images/growth/growth_stimulate_sun.png',
  PlantGrowthIllustration.stimulateTemp:
      'assets/images/growth/growth_stimulate_temp.png',
  PlantGrowthIllustration.problems:
      'assets/images/growth/growth_problems.png',
  PlantGrowthIllustration.healthy:
      'assets/images/growth/growth_healthy.png',
  PlantGrowthIllustration.stress:
      'assets/images/growth/growth_stress.png',
  PlantGrowthIllustration.aiAdvice:
      'assets/images/growth/growth_ai_advice.png',
};

class GrowthIllustration extends StatelessWidget {
  const GrowthIllustration({
    super.key,
    required this.kind,
    this.size = GrowthIllustrationSize.normal,
    this.plantFocus = false,
  });

  final PlantGrowthIllustration kind;
  final GrowthIllustrationSize size;
  final bool plantFocus;

  double get _height {
    switch (size) {
      case GrowthIllustrationSize.small:
        return 52;
      case GrowthIllustrationSize.inline:
        return 56;
      case GrowthIllustrationSize.habit:
        return 76;
      case GrowthIllustrationSize.phase:
        return 92;
      case GrowthIllustrationSize.compact:
        return 92;
      case GrowthIllustrationSize.mediumCompact:
        return 112;
      case GrowthIllustrationSize.normal:
        return 0;
    }
  }

  BoxFit get _fit =>
      plantFocus ? BoxFit.cover : BoxFit.contain;

  Alignment get _alignment =>
      plantFocus ? Alignment.bottomCenter : Alignment.center;

  @override
  Widget build(BuildContext context) {
    final asset = _growthAssets[kind];
    if (asset == null) return const SizedBox.shrink();

    final image = ClipRRect(
      borderRadius: BorderRadius.circular(plantFocus ? 8 : 12),
      child: ColoredBox(
        color: const Color(PlantDetailDesign.card),
        child: Image.asset(
          asset,
          fit: _fit,
          alignment: _alignment,
          filterQuality: FilterQuality.medium,
          errorBuilder: (_, __, ___) => const Center(
            child: Icon(Icons.image_not_supported_outlined, size: 24),
          ),
        ),
      ),
    );

    if (size == GrowthIllustrationSize.normal) {
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
