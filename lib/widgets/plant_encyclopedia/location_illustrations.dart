import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_location_guide.dart';
import 'sowing_illustrations.dart';

const _locationAssets = {
  PlantLocationIllustration.sunHours:
      'assets/images/location/location_sun_hours.png',
  PlantLocationIllustration.spaceDimensions:
      'assets/images/location/location_space_dimensions.png',
  PlantLocationIllustration.plantSpacing:
      'assets/images/transplant/transplant_plant_spacing.png',
  PlantLocationIllustration.rowSpacing:
      'assets/images/transplant/transplant_row_spacing.png',
  PlantLocationIllustration.wind:
      'assets/images/location/location_wind.png',
  PlantLocationIllustration.temperature:
      'assets/images/location/location_temperature.png',
  PlantLocationIllustration.frost:
      'assets/images/location/location_frost.png',
  PlantLocationIllustration.humidity:
      'assets/images/location/location_humidity.png',
  PlantLocationIllustration.greenhouseOutdoor:
      'assets/images/location/location_greenhouse_outdoor.png',
  PlantLocationIllustration.indoorGrowing:
      'assets/images/location/location_indoor_growing.png',
  PlantLocationIllustration.openGround:
      'assets/images/location/location_open_ground.png',
  PlantLocationIllustration.pot: 'assets/images/location/location_pot.png',
  PlantLocationIllustration.raisedBed:
      'assets/images/location/location_raised_bed.png',
  PlantLocationIllustration.balcony:
      'assets/images/location/location_balcony.png',
  PlantLocationIllustration.greenhouse:
      'assets/images/location/location_greenhouse.png',
  PlantLocationIllustration.indoor:
      'assets/images/location/location_indoor.png',
};

class LocationIllustration extends StatelessWidget {
  const LocationIllustration({
    super.key,
    required this.kind,
    this.size = LocationIllustrationSize.normal,
  });

  final PlantLocationIllustration kind;
  final LocationIllustrationSize size;

  double get _height {
    switch (size) {
      case LocationIllustrationSize.small:
        return 56;
      case LocationIllustrationSize.inline:
        return 72;
      case LocationIllustrationSize.compact:
        return 92;
      case LocationIllustrationSize.large:
        return 140;
      case LocationIllustrationSize.normal:
        return 0;
    }
  }

  double? get _width {
    if (size == LocationIllustrationSize.inline) return 110;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final asset = _locationAssets[kind];
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

    if (size == LocationIllustrationSize.normal) {
      return AspectRatio(
        aspectRatio: SowingIllustrationFormat.aspectRatio,
        child: image,
      );
    }

    return SizedBox(
      height: _height,
      width: _width ?? double.infinity,
      child: image,
    );
  }
}

String locationSunLevelAsset(LocationSunLevel level) {
  switch (level) {
    case LocationSunLevel.fullSun:
      return 'assets/images/location/location_sun_full.png';
    case LocationSunLevel.partialShade:
      return 'assets/images/location/location_sun_partial.png';
    case LocationSunLevel.lightShade:
      return 'assets/images/location/location_sun_light_shade.png';
    case LocationSunLevel.shade:
      return 'assets/images/location/location_sun_shade.png';
  }
}

IconData locationSunLevelIcon(LocationSunLevel level) {
  switch (level) {
    case LocationSunLevel.fullSun:
      return Icons.wb_sunny_rounded;
    case LocationSunLevel.partialShade:
      return Icons.wb_cloudy_rounded;
    case LocationSunLevel.lightShade:
      return Icons.cloud_outlined;
    case LocationSunLevel.shade:
      return Icons.cloud_queue_rounded;
  }
}

Color locationSunLevelColor(LocationSunLevel level, {bool highlighted = false}) {
  if (highlighted) return const Color(PlantDetailDesign.primaryGreen);
  switch (level) {
    case LocationSunLevel.fullSun:
      return const Color(0xFFF59E0B);
    case LocationSunLevel.partialShade:
      return const Color(0xFF94A3B8);
    case LocationSunLevel.lightShade:
      return const Color(0xFF9CA3AF);
    case LocationSunLevel.shade:
      return const Color(0xFF6B7280);
  }
}

IconData locationMarkerIcon(LocationSuitabilityMarker marker) {
  switch (marker) {
    case LocationSuitabilityMarker.check:
      return Icons.check_rounded;
    case LocationSuitabilityMarker.warning:
      return Icons.priority_high_rounded;
    case LocationSuitabilityMarker.cross:
      return Icons.close_rounded;
  }
}

Color locationMarkerColor(LocationSuitabilityMarker marker) {
  switch (marker) {
    case LocationSuitabilityMarker.check:
      return const Color(PlantDetailDesign.primaryGreen);
    case LocationSuitabilityMarker.warning:
      return const Color(PlantDetailDesign.warning);
    case LocationSuitabilityMarker.cross:
      return const Color(0xFFEF4444);
  }
}
