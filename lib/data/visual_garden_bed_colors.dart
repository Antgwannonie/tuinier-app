import 'package:flutter/material.dart';

/// Standaard bakkleuren uit de Moestuinplanner-mockup (houten rand + aarde).
abstract final class VisualGardenBedColors {
  static const Color pageBackground = Color(0xFFFDFCF7);
  static const Color titleGreen = Color(0xFF2D472B);
  static const Color softGreen = Color(0xFFE9F2E6);
  static const Color softGreenButton = Color(0xFFDCE8D6);
  static const Color chipSelectedFill = Color(0xFFF0F5EE);
  static const Color areaChip = Color(0xFFE4F0DC);
  static const Color dimensionLine = Color(0xFF5B8A4C);

  /// Houten rand (mockup).
  static const int defaultBorderArgb = 0xFFB08968;

  /// Donkere aarde binnenin (mockup).
  static const int defaultFillArgb = 0xFF4A3728;

  static const List<VisualBedColorPreset> presets = [
    VisualBedColorPreset(
      id: 'hout_aarde',
      label: 'Hout & aarde',
      borderArgb: defaultBorderArgb,
      fillArgb: defaultFillArgb,
    ),
    VisualBedColorPreset(
      id: 'donker_hout',
      label: 'Donker hout',
      borderArgb: 0xFF6D4C41,
      fillArgb: 0xFF3E2723,
    ),
    VisualBedColorPreset(
      id: 'licht_hout',
      label: 'Licht hout',
      borderArgb: 0xFFD7B899,
      fillArgb: 0xFF5D4037,
    ),
    VisualBedColorPreset(
      id: 'groene_rand',
      label: 'Groene rand',
      borderArgb: 0xFF6B8E6B,
      fillArgb: 0xFF4A3728,
    ),
    VisualBedColorPreset(
      id: 'sage',
      label: 'Sage & aarde',
      borderArgb: 0xFF8FA88A,
      fillArgb: 0xFF3E4A3A,
    ),
  ];

  static VisualBedColorPreset presetByColors(int borderArgb, int fillArgb) {
    for (final p in presets) {
      if (p.borderArgb == borderArgb && p.fillArgb == fillArgb) return p;
    }
    return presets.first;
  }
}

class VisualBedColorPreset {
  const VisualBedColorPreset({
    required this.id,
    required this.label,
    required this.borderArgb,
    required this.fillArgb,
  });

  final String id;
  final String label;
  final int borderArgb;
  final int fillArgb;

  Color get border => Color(borderArgb);
  Color get fill => Color(fillArgb);
}
