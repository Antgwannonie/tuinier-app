import 'package:flutter/material.dart';

import '../../data/plant_care_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';

const _careAssets = {
  PlantCareIllustration.dailyMagnify:
      'assets/images/care/care_daily_magnify.png',
  PlantCareIllustration.weeklyClipboard:
      'assets/images/care/care_weekly_clipboard.png',
  PlantCareIllustration.maintenanceShears:
      'assets/images/care/care_maintenance_shears.png',
  PlantCareIllustration.pruningShears:
      'assets/images/care/care_pruning_shears.png',
  PlantCareIllustration.topping: 'assets/images/care/care_topping.png',
  PlantCareIllustration.suckering: 'assets/images/care/care_suckering.png',
  PlantCareIllustration.tying: 'assets/images/care/care_tying.png',
  PlantCareIllustration.supportTrellis:
      'assets/images/care/care_support_trellis.png',
  PlantCareIllustration.mulch: 'assets/images/care/care_mulch.png',
  PlantCareIllustration.weed: 'assets/images/care/care_weed.png',
  PlantCareIllustration.heatShade: 'assets/images/care/care_heat_shade.png',
  PlantCareIllustration.coldCover: 'assets/images/care/care_cold_cover.png',
  PlantCareIllustration.frostCover: 'assets/images/care/care_frost_cover.png',
  PlantCareIllustration.windFence: 'assets/images/care/care_wind_fence.png',
  PlantCareIllustration.rainCloud: 'assets/images/care/care_rain_cloud.png',
  PlantCareIllustration.animalSnail:
      'assets/images/care/care_animal_snail.png',
  PlantCareIllustration.animalBird: 'assets/images/care/care_animal_bird.png',
  PlantCareIllustration.animalRabbit:
      'assets/images/care/care_animal_rabbit.png',
  PlantCareIllustration.animalMouse:
      'assets/images/care/care_animal_mouse.png',
  PlantCareIllustration.healthyPlant:
      'assets/images/care/care_healthy_plant.png',
  PlantCareIllustration.warningLeaf:
      'assets/images/care/care_warning_leaf.png',
  PlantCareIllustration.seasonSpring:
      'assets/images/care/care_season_spring.png',
  PlantCareIllustration.seasonSummer:
      'assets/images/care/care_season_summer.png',
  PlantCareIllustration.seasonAutumn:
      'assets/images/care/care_season_autumn.png',
  PlantCareIllustration.seasonWinter:
      'assets/images/care/care_season_winter.png',
  PlantCareIllustration.winterWrap: 'assets/images/care/care_winter_wrap.png',
  PlantCareIllustration.potPlant: 'assets/images/care/care_pot.png',
  PlantCareIllustration.greenhouse: 'assets/images/care/care_greenhouse.png',
};

class CareIllustration extends StatelessWidget {
  const CareIllustration({
    super.key,
    required this.kind,
    this.size = CareIllustrationSize.compact,
  });

  final PlantCareIllustration kind;
  final CareIllustrationSize size;

  double get _height {
    return switch (size) {
      CareIllustrationSize.icon => 72,
      CareIllustrationSize.compact => 100,
      CareIllustrationSize.normal => 140,
    };
  }

  @override
  Widget build(BuildContext context) {
    final asset = _careAssets[kind];
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
