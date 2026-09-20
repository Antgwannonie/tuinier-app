import 'package:flutter/material.dart';

import '../theme/tuinier_colors.dart';

/// Meldingen — design system statuskleuren.
class GardenWarningStyle {
  static Color dangerBackground(ColorScheme cs) => Color.alphaBlend(
        TuinierColors.error.withValues(alpha: 0.1),
        TuinierColors.card,
      );

  static Color dangerForeground(ColorScheme cs) => TuinierColors.error;

  static Color dangerIcon(ColorScheme cs) => TuinierColors.error;

  static Color background(ColorScheme cs) => Color.alphaBlend(
        TuinierColors.warning.withValues(alpha: 0.15),
        TuinierColors.card,
      );

  static Color foreground(ColorScheme cs) => TuinierColors.warning;

  static Color icon(ColorScheme cs) => TuinierColors.warning;

  static Color infoBackground(ColorScheme cs) => Color.alphaBlend(
        TuinierColors.success.withValues(alpha: 0.1),
        TuinierColors.card,
      );

  static Color infoForeground(ColorScheme cs) => TuinierColors.headerDark;

  static Color infoIcon(ColorScheme cs) => TuinierColors.success;

  static Color badgeSolid(ColorScheme cs) => TuinierColors.error;

  static Color badgeBackground(ColorScheme cs) => Color.alphaBlend(
        TuinierColors.warning.withValues(alpha: 0.25),
        TuinierColors.background,
      );

  static Color neutralBackground(ColorScheme cs) => TuinierColors.background;

  static Color neutralForeground(ColorScheme cs) => TuinierColors.textSecondary;
}
