import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_transplant_guide.dart';
import 'sowing_illustrations.dart';

const _transplantAssets = {
  PlantTransplantIllustration.conditions:
      'assets/images/transplant/transplant_conditions.png',
  PlantTransplantIllustration.hardening:
      'assets/images/transplant/transplant_hardening.png',
  PlantTransplantIllustration.plantSpacing:
      'assets/images/transplant/transplant_plant_spacing.png',
  PlantTransplantIllustration.rowSpacing:
      'assets/images/transplant/transplant_row_spacing.png',
  PlantTransplantIllustration.plantingDepth:
      'assets/images/transplant/transplant_planting_depth.png',
  PlantTransplantIllustration.bestLocation:
      'assets/images/transplant/transplant_best_location.png',
  PlantTransplantIllustration.soilPrep:
      'assets/images/transplant/transplant_soil_prep.png',
  PlantTransplantIllustration.waterAfter:
      'assets/images/transplant/transplant_water.png',
  PlantTransplantIllustration.support:
      'assets/images/transplant/transplant_support.png',
  PlantTransplantIllustration.protection:
      'assets/images/transplant/transplant_protection.png',
  PlantTransplantIllustration.establish:
      'assets/images/transplant/transplant_establish.png',
  PlantTransplantIllustration.growth:
      'assets/images/transplant/transplant_growth.png',
  PlantTransplantIllustration.mistakes:
      'assets/images/transplant/transplant_mistakes.png',
};

class TransplantIllustration extends StatelessWidget {
  const TransplantIllustration({
    super.key,
    required this.kind,
    this.size = TransplantIllustrationSize.normal,
  });

  final PlantTransplantIllustration kind;
  final TransplantIllustrationSize size;

  double get _height {
    switch (size) {
      case TransplantIllustrationSize.compact:
        return 92;
      case TransplantIllustrationSize.large:
        return 168;
      case TransplantIllustrationSize.normal:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final asset = _transplantAssets[kind];
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

    if (size == TransplantIllustrationSize.normal) {
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

IconData transplantChipIcon(TransplantChipIcon icon) {
  switch (icon) {
    case TransplantChipIcon.sun:
      return Icons.wb_sunny_outlined;
    case TransplantChipIcon.partialSun:
      return Icons.wb_cloudy_outlined;
    case TransplantChipIcon.pot:
      return Icons.yard_outlined;
    case TransplantChipIcon.greenhouse:
      return Icons.house_siding_outlined;
    case TransplantChipIcon.openGround:
      return Icons.grass_outlined;
    case TransplantChipIcon.wind:
      return Icons.air_outlined;
    case TransplantChipIcon.slug:
      return Icons.pest_control_outlined;
    case TransplantChipIcon.frost:
      return Icons.ac_unit_outlined;
    case TransplantChipIcon.strongSun:
      return Icons.light_mode_outlined;
    case TransplantChipIcon.sparkle:
      return Icons.auto_awesome_outlined;
    case TransplantChipIcon.weather:
      return Icons.cloud_queue_outlined;
  }
}
