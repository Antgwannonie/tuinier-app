import 'package:flutter/material.dart';

/// Gedeelde stijl voor tuin-meldingen (licht geel, geen fel rood).
class GardenWarningStyle {
  static Color dangerBackground(ColorScheme cs) => Color.alphaBlend(
        cs.error.withValues(alpha: 0.14),
        cs.surfaceContainerLow,
      );

  static Color dangerForeground(ColorScheme cs) => cs.onErrorContainer;

  static Color dangerIcon(ColorScheme cs) => cs.error;

  static Color background(ColorScheme cs) => Color.alphaBlend(
        Colors.amber.withValues(alpha: 0.18),
        cs.surfaceContainerLow,
      );

  static Color foreground(ColorScheme cs) =>
      Colors.amber.shade900;

  static Color icon(ColorScheme cs) => Color.lerp(
        Colors.amber.shade700,
        cs.primary,
        0.15,
      )!;

  static Color infoBackground(ColorScheme cs) => Color.alphaBlend(
        Colors.green.withValues(alpha: 0.14),
        cs.surfaceContainerLow,
      );

  static Color infoForeground(ColorScheme cs) => Colors.green.shade900;

  static Color infoIcon(ColorScheme cs) => Colors.green.shade700;

  static Color badgeSolid(ColorScheme cs) => Colors.amber.shade700;

  static Color badgeBackground(ColorScheme cs) => Color.alphaBlend(
        Colors.amber.withValues(alpha: 0.45),
        cs.surfaceContainerHighest,
      );

  /// Grijs accent voor milde scan-informatie.
  static Color neutralBackground(ColorScheme cs) =>
      cs.surfaceContainerHighest.withValues(alpha: 0.9);

  static Color neutralForeground(ColorScheme cs) => cs.onSurfaceVariant;
}
