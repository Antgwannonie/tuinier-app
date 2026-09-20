import 'package:flutter/material.dart';

import '../../data/plant_harvest_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';

const _harvestAssets = {
  PlantHarvestIllustration.periodBasket:
      'assets/images/harvest/harvest_basket.png',
  PlantHarvestIllustration.timeCalendar:
      'assets/images/harvest/harvest_calendar_clock.png',
  PlantHarvestIllustration.ripeTomato:
      'assets/images/harvest/harvest_ripe_tomato.png',
  PlantHarvestIllustration.methodCut:
      'assets/images/harvest/harvest_cut.png',
  PlantHarvestIllustration.methodPick:
      'assets/images/harvest/harvest_pick.png',
  PlantHarvestIllustration.methodTwist:
      'assets/images/harvest/harvest_twist.png',
  PlantHarvestIllustration.frequencyCalendar:
      'assets/images/harvest/harvest_calendar_check.png',
  PlantHarvestIllustration.yieldCrate:
      'assets/images/harvest/harvest_crate.png',
  PlantHarvestIllustration.continueFlower:
      'assets/images/harvest/harvest_flower_continue.png',
  PlantHarvestIllustration.storageFridge:
      'assets/images/harvest/harvest_fridge.png',
  PlantHarvestIllustration.storageCool:
      'assets/images/harvest/harvest_cool_basket.png',
  PlantHarvestIllustration.storagePantry:
      'assets/images/harvest/harvest_pantry.png',
  PlantHarvestIllustration.freezeSnowflake:
      'assets/images/harvest/harvest_freeze.png',
  PlantHarvestIllustration.drySun:
      'assets/images/harvest/harvest_dry_sun.png',
  PlantHarvestIllustration.seedPacket:
      'assets/images/harvest/harvest_seed_packet.png',
  PlantHarvestIllustration.perfectTomato:
      'assets/images/harvest/harvest_perfect_tomato.png',
  PlantHarvestIllustration.edibleFruit:
      'assets/images/harvest/harvest_edible_fruit.png',
  PlantHarvestIllustration.edibleLeaf:
      'assets/images/harvest/harvest_edible_leaf.png',
  PlantHarvestIllustration.edibleFlower:
      'assets/images/harvest/harvest_edible_flower.png',
  PlantHarvestIllustration.edibleRoot:
      'assets/images/harvest/harvest_edible_root.png',
  PlantHarvestIllustration.edibleShoot:
      'assets/images/harvest/harvest_edible_shoot.png',
  PlantHarvestIllustration.edibleSeed:
      'assets/images/harvest/harvest_edible_seed.png',
};

class HarvestIllustration extends StatelessWidget {
  const HarvestIllustration({
    super.key,
    required this.kind,
    this.size = HarvestIllustrationSize.normal,
  });

  final PlantHarvestIllustration kind;
  final HarvestIllustrationSize size;

  double get _height {
    return switch (size) {
      HarvestIllustrationSize.icon => 72,
      HarvestIllustrationSize.compact => 100,
      HarvestIllustrationSize.normal => 140,
    };
  }

  @override
  Widget build(BuildContext context) {
    final asset = _harvestAssets[kind];
    if (asset == null) return const SizedBox.shrink();

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
            alignment: Alignment.center,
            filterQuality: FilterQuality.medium,
            errorBuilder: (context, error, stackTrace) {
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
