import 'package:flutter/material.dart';

import '../../data/plant_bloom_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';

const _bloomAssets = {
  PlantBloomIllustration.periodFlower:
      'assets/images/bloom/bloom_period_flower.png',
  PlantBloomIllustration.firstBloom:
      'assets/images/bloom/bloom_first_plant.png',
  PlantBloomIllustration.fruitTiming:
      'assets/images/bloom/bloom_fruit_timing.png',
  PlantBloomIllustration.pollinationSelf:
      'assets/images/bloom/bloom_pollination_self.png',
  PlantBloomIllustration.pollinationCross:
      'assets/images/bloom/bloom_pollination_cross.png',
  PlantBloomIllustration.pollinationManual:
      'assets/images/bloom/bloom_pollination_manual.png',
  PlantBloomIllustration.pollinatorBee:
      'assets/images/bloom/bloom_pollinator_bee.png',
  PlantBloomIllustration.pollinatorBumblebee:
      'assets/images/bloom/bloom_pollinator_bumblebee.png',
  PlantBloomIllustration.pollinatorButterfly:
      'assets/images/bloom/bloom_pollinator_butterfly.png',
  PlantBloomIllustration.stimulateSun:
      'assets/images/bloom/bloom_stimulate_sun.png',
  PlantBloomIllustration.stimulateWater:
      'assets/images/bloom/bloom_stimulate_water.png',
  PlantBloomIllustration.stimulatePotassium:
      'assets/images/bloom/bloom_stimulate_potassium.png',
  PlantBloomIllustration.deadheadShears:
      'assets/images/bloom/bloom_deadhead_shears.png',
  PlantBloomIllustration.manualPollination:
      'assets/images/bloom/bloom_manual_brush.png',
  PlantBloomIllustration.problemDrop:
      'assets/images/bloom/bloom_problem_drop.png',
  PlantBloomIllustration.problemNoBloom:
      'assets/images/bloom/bloom_problem_no_bloom.png',
  PlantBloomIllustration.problemFewFlowers:
      'assets/images/bloom/bloom_problem_few.png',
  PlantBloomIllustration.healthyBloom:
      'assets/images/bloom/bloom_healthy.png',
  PlantBloomIllustration.edibleFlowers:
      'assets/images/bloom/bloom_edible_flowers.png',
  PlantBloomIllustration.edibleFruitsOnly:
      'assets/images/bloom/bloom_edible_fruits.png',
  PlantBloomIllustration.edibleNot:
      'assets/images/bloom/bloom_edible_not.png',
  // Hergebruik bestaande bloom-beelden tot er speciale assets zijn.
  PlantBloomIllustration.flowerMale:
      'assets/images/bloom/bloom_pollination_manual.png',
  PlantBloomIllustration.flowerFemale:
      'assets/images/bloom/bloom_fruit_timing.png',
};

class BloomIllustration extends StatelessWidget {
  const BloomIllustration({
    super.key,
    required this.kind,
    this.size = BloomIllustrationSize.normal,
  });

  final PlantBloomIllustration kind;
  final BloomIllustrationSize size;

  double get _height {
    return switch (size) {
      BloomIllustrationSize.icon => 72,
      BloomIllustrationSize.compact => 100,
      BloomIllustrationSize.normal => 140,
    };
  }

  IconData? get _fallbackIcon {
    return switch (kind) {
      PlantBloomIllustration.flowerMale => Icons.spa_outlined,
      PlantBloomIllustration.flowerFemale => Icons.local_florist_outlined,
      _ => null,
    };
  }

  Color get _fallbackTint {
    return switch (kind) {
      PlantBloomIllustration.flowerMale => const Color(0xFFFEF3C7),
      PlantBloomIllustration.flowerFemale => const Color(0xFFFDF2F8),
      _ => const Color(PlantDetailDesign.card),
    };
  }

  @override
  Widget build(BuildContext context) {
    final asset = _bloomAssets[kind];
    final fallback = _fallbackIcon;

    return SizedBox(
      height: _height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: asset == null ? _fallbackTint : const Color(PlantDetailDesign.card),
          child: asset == null
              ? Center(
                  child: Icon(
                    fallback ?? Icons.image_not_supported_outlined,
                    size: size == BloomIllustrationSize.icon ? 28 : 40,
                    color: kind == PlantBloomIllustration.flowerFemale
                        ? const Color(0xFFDB2777)
                        : const Color(0xFFD97706),
                  ),
                )
              : Image.asset(
                  asset,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                  filterQuality: FilterQuality.medium,
                  errorBuilder: (context, error, stackTrace) {
                    if (fallback != null) {
                      return ColoredBox(
                        color: _fallbackTint,
                        child: Center(
                          child: Icon(
                            fallback,
                            size: size == BloomIllustrationSize.icon ? 28 : 40,
                            color: kind == PlantBloomIllustration.flowerFemale
                                ? const Color(0xFFDB2777)
                                : const Color(0xFFD97706),
                          ),
                        ),
                      );
                    }
                    return const Center(
                      child: Icon(Icons.image_not_supported_outlined, size: 32),
                    );
                  },
                ),
        ),
      ),
    );
  }
}
