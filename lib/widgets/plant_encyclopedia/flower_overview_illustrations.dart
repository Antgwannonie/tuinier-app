import 'package:flutter/material.dart';

/// Watercolor sectiekoppen en hergebruikte iconen voor bloemen-overzicht.
abstract final class FlowerOverviewAssets {
  static const whyPlant = 'assets/images/flower_overview/flower_why_plant.png';
  static const natureValue =
      'assets/images/flower_overview/flower_nature_value.png';
  static const traits = 'assets/images/flower_overview/flower_traits.png';
  static const weather = 'assets/images/flower_overview/flower_weather.png';
  static const suitable = 'assets/images/flower_overview/flower_suitable.png';
  static const features = 'assets/images/flower_overview/flower_features.png';
  static const tip = 'assets/images/flower_overview/flower_tip.png';

  static const bee = 'assets/images/bloom/bloom_pollinator_bee.png';
  static const butterfly = 'assets/images/bloom/bloom_pollinator_butterfly.png';
  static const bumblebee =
      'assets/images/bloom/bloom_pollinator_bumblebee.png';
  static const hoverfly = 'assets/images/combination/combo_pollinators.png';

  static const pestControl =
      'assets/images/combination/combo_pest_plants.png';
  static const pollination = 'assets/images/combination/combo_pollinators.png';
  static const soilHealth =
      'assets/images/combination/combo_soil_improvers.png';
  static const biodiversity =
      'assets/images/combination/combo_benefits.png';

  static const border = 'assets/images/location/location_open_ground.png';
  static const pot = 'assets/images/location/location_pot.png';
  static const cutGarden = 'assets/images/harvest/harvest_basket.png';
  static const butterflyGarden = 'assets/images/bloom/bloom_pollinator_butterfly.png';
  static const beeGarden = 'assets/images/bloom/bloom_pollinator_bee.png';
  static const natureGarden = 'assets/images/combination/combo_benefits.png';
  static const frost = 'assets/images/location/location_frost.png';
  static const sun = 'assets/images/location/location_sun_full.png';
  static const drought = 'assets/images/care/care_heat_shade.png';
}

class FlowerOverviewIcon extends StatelessWidget {
  const FlowerOverviewIcon({
    super.key,
    required this.asset,
    this.size = 28,
    this.fallbackIcon = Icons.local_florist_outlined,
  });

  final String asset;
  final double size;
  final IconData fallbackIcon;

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      asset,
      width: size,
      height: size,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => Icon(
        fallbackIcon,
        size: size * 0.85,
        color: const Color(0xFF7B1FA2),
      ),
    );
  }
}
