import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_sowing_guide.dart';

const _sowingIllustrationAssets = {
  PlantSowingIllustration.indoorTray: 'assets/images/sowing/sowing_indoor_tray.png',
  PlantSowingIllustration.outdoorSoil:
      'assets/images/sowing/sowing_outdoor_soil.png',
  PlantSowingIllustration.seedDepth: 'assets/images/sowing/sowing_seed_depth.png',
  PlantSowingIllustration.germinationTimeline:
      'assets/images/sowing/sowing_germination.png',
  PlantSowingIllustration.temperatureRange:
      'assets/images/sowing/sowing_temperature.png',
  PlantSowingIllustration.lightGermination: 'assets/images/sowing/sowing_light.png',
  PlantSowingIllustration.waterGermination: 'assets/images/sowing/sowing_water.png',
  PlantSowingIllustration.prickOut: 'assets/images/sowing/sowing_prick_out.png',
  PlantSowingIllustration.potUp: 'assets/images/sowing/sowing_pot_up.png',
};

/// Vaste beeldverhouding voor alle zaai-illustraties (zelfde als de PNG's).
abstract final class SowingIllustrationFormat {
  static const aspectRatio = 4 / 3;
}

class SowingIllustration extends StatelessWidget {
  const SowingIllustration({
    super.key,
    required this.kind,
  });

  final PlantSowingIllustration kind;

  @override
  Widget build(BuildContext context) {
    final asset = _sowingIllustrationAssets[kind];
    if (asset == null) return const SizedBox.shrink();

    return AspectRatio(
      aspectRatio: SowingIllustrationFormat.aspectRatio,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: ColoredBox(
          color: const Color(PlantDetailDesign.card),
          child: Image.asset(
            asset,
            width: double.infinity,
            height: double.infinity,
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
