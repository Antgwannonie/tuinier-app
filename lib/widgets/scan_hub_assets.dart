import 'package:flutter/material.dart';

import '../theme/tuinier_colors.dart';

enum ScanHubIconKind { plant, weed, insect, disease }

/// Afbeeldingen voor de AI Scan-hub (mockup-stijl).
abstract final class ScanHubAssets {
  static const heroBackground = 'assets/images/scan_hub/scan_hero_bg.png';

  static String iconAsset(ScanHubIconKind kind) => switch (kind) {
        ScanHubIconKind.plant =>
          'assets/images/scan_hub/scan_icon_vegetable.png',
        ScanHubIconKind.weed => 'assets/images/scan_hub/scan_icon_herb.png',
        ScanHubIconKind.insect =>
          'assets/images/scan_hub/scan_icon_insect.png',
        ScanHubIconKind.disease =>
          'assets/images/scan_hub/scan_icon_disease.png',
      };
}

class ScanHubCategoryIcon extends StatelessWidget {
  const ScanHubCategoryIcon({
    super.key,
    required this.kind,
    this.size = 52,
    this.flat = false,
  });

  final ScanHubIconKind kind;
  final double size;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Image.asset(
        ScanHubAssets.iconAsset(kind),
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) =>
            _FallbackScanIcon(kind: kind, size: size, flat: flat),
      ),
    );
  }
}

class _FallbackScanIcon extends StatelessWidget {
  const _FallbackScanIcon({
    required this.kind,
    required this.size,
    required this.flat,
  });

  final ScanHubIconKind kind;
  final double size;
  final bool flat;

  @override
  Widget build(BuildContext context) {
    final icon = Icon(
      switch (kind) {
        ScanHubIconKind.plant => Icons.local_florist_rounded,
        ScanHubIconKind.weed => Icons.grass_rounded,
        ScanHubIconKind.insect => Icons.pest_control_rounded,
        ScanHubIconKind.disease => Icons.shield_rounded,
      },
      size: size * (flat ? 0.72 : 0.48),
      color: TuinierColors.primary,
    );

    if (flat) return icon;

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        color: TuinierColors.cardTintGreen,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: icon,
    );
  }
}
