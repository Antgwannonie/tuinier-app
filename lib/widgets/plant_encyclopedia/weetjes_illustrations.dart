import 'package:flutter/material.dart';

import '../../data/plant_weetjes_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';

const _weetjesIllustrationAssets = {
  PlantWeetjesIllustration.origin:
      'assets/images/weetjes/weetjes_origin.png',
  PlantWeetjesIllustration.history:
      'assets/images/weetjes/weetjes_history.png',
  PlantWeetjesIllustration.family:
      'assets/images/weetjes/weetjes_family.png',
  PlantWeetjesIllustration.edibleParts:
      'assets/images/weetjes/weetjes_edible_parts.png',
  PlantWeetjesIllustration.funFact:
      'assets/images/weetjes/weetjes_fun_fact.png',
  PlantWeetjesIllustration.healthShield:
      'assets/images/weetjes/weetjes_health_shield.png',
  PlantWeetjesIllustration.healthMuscle:
      'assets/images/weetjes/weetjes_health_muscle.png',
  PlantWeetjesIllustration.healthHeart:
      'assets/images/weetjes/weetjes_health_heart.png',
  PlantWeetjesIllustration.healthDrop:
      'assets/images/weetjes/weetjes_health_drop.png',
  PlantWeetjesIllustration.kitchenSalad:
      'assets/images/weetjes/weetjes_kitchen_salad.png',
  PlantWeetjesIllustration.kitchenSoup:
      'assets/images/weetjes/weetjes_kitchen_soup.png',
  PlantWeetjesIllustration.kitchenSmoothie:
      'assets/images/weetjes/weetjes_kitchen_smoothie.png',
  PlantWeetjesIllustration.kitchenTea:
      'assets/images/weetjes/weetjes_kitchen_tea.png',
  PlantWeetjesIllustration.varietyCherry:
      'assets/images/weetjes/weetjes_variety_cherry.png',
  PlantWeetjesIllustration.varietyPlum:
      'assets/images/weetjes/weetjes_variety_plum.png',
  PlantWeetjesIllustration.varietyBeefsteak:
      'assets/images/weetjes/weetjes_variety_beefsteak.png',
  PlantWeetjesIllustration.varietyYellow:
      'assets/images/weetjes/weetjes_variety_yellow.png',
  PlantWeetjesIllustration.varietyBlack:
      'assets/images/weetjes/weetjes_variety_black.png',
  PlantWeetjesIllustration.wildlifeBee:
      'assets/images/weetjes/weetjes_wildlife_bee.png',
  PlantWeetjesIllustration.wildlifeButterfly:
      'assets/images/weetjes/weetjes_wildlife_butterfly.png',
  PlantWeetjesIllustration.wildlifeLadybug:
      'assets/images/weetjes/weetjes_wildlife_ladybug.png',
  PlantWeetjesIllustration.wildlifeBumblebee:
      'assets/images/weetjes/weetjes_wildlife_bumblebee.png',
  PlantWeetjesIllustration.medalGold:
      'assets/images/weetjes/weetjes_medal_gold.png',
  PlantWeetjesIllustration.medalSilver:
      'assets/images/weetjes/weetjes_medal_silver.png',
  PlantWeetjesIllustration.medalBronze:
      'assets/images/weetjes/weetjes_medal_bronze.png',
  PlantWeetjesIllustration.appInsect:
      'assets/images/weetjes/weetjes_app_insect.png',
  PlantWeetjesIllustration.appDecor:
      'assets/images/weetjes/weetjes_app_decor.png',
  PlantWeetjesIllustration.appCosmetic:
      'assets/images/weetjes/weetjes_app_cosmetic.png',
  PlantWeetjesIllustration.appTea:
      'assets/images/weetjes/weetjes_kitchen_tea.png',
  PlantWeetjesIllustration.appDye:
      'assets/images/weetjes/weetjes_app_dye.png',
};

abstract final class WeetjesIllustrationFormat {
  static const heroAspectRatio = 16 / 9;
  static const iconSize = 64.0;
}

class WeetjesHeroIllustration extends StatelessWidget {
  const WeetjesHeroIllustration({
    super.key,
    required this.kind,
  });

  final PlantWeetjesIllustration kind;

  @override
  Widget build(BuildContext context) {
    final asset = _weetjesIllustrationAssets[kind];
    if (asset == null) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: WeetjesIllustrationFormat.heroAspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: const Color(0xFFFAFAFA),
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => const Center(
              child: Icon(Icons.image_not_supported_outlined, size: 32),
            ),
          ),
        ),
      ),
    );
  }
}

class WeetjesIconIllustration extends StatelessWidget {
  const WeetjesIconIllustration({
    super.key,
    required this.kind,
    this.size = WeetjesIllustrationFormat.iconSize,
  });

  final PlantWeetjesIllustration kind;
  final double size;

  @override
  Widget build(BuildContext context) {
    final asset = _weetjesIllustrationAssets[kind];
    if (asset == null) return SizedBox(width: size, height: size);

    return SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: ColoredBox(
          color: const Color(0xFFFAFAFA),
          child: Image.asset(
            asset,
            fit: BoxFit.cover,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Icon(
              Icons.eco_outlined,
              size: size * 0.45,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
        ),
      ),
    );
  }
}
