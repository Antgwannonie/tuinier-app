import 'package:flutter/material.dart';

import 'tuinier_colors.dart';

/// Kleuren voor plant-sheets en moestuin-kaarten (mockup-groen).
class PlantSetupPalette {
  const PlantSetupPalette({
    required this.badgeBackground,
    required this.badgeForeground,
    required this.cardBackground,
    required this.cardBorder,
    required this.sectionLabel,
    required this.dateIconBackground,
    required this.dateIconForeground,
    required this.chipSelectedBackground,
    required this.chipSelectedForeground,
    required this.chipIdleBackground,
    required this.chipIdleForeground,
    required this.activeIcon,
    required this.confirmButton,
    required this.confirmButtonForeground,
  });

  final Color badgeBackground;
  final Color badgeForeground;
  final Color cardBackground;
  final Color cardBorder;
  final Color sectionLabel;
  final Color dateIconBackground;
  final Color dateIconForeground;
  final Color chipSelectedBackground;
  final Color chipSelectedForeground;
  final Color chipIdleBackground;
  final Color chipIdleForeground;
  final Color activeIcon;
  final Color confirmButton;
  final Color confirmButtonForeground;

  factory PlantSetupPalette.of(BuildContext context) {
    return const PlantSetupPalette(
      badgeBackground: TuinierColors.lightGreen,
      badgeForeground: TuinierColors.card,
      cardBackground: TuinierColors.card,
      cardBorder: TuinierColors.border,
      sectionLabel: TuinierColors.primary,
      dateIconBackground: TuinierColors.scanHover,
      dateIconForeground: TuinierColors.headerDark,
      chipSelectedBackground: TuinierColors.primary,
      chipSelectedForeground: TuinierColors.card,
      chipIdleBackground: TuinierColors.background,
      chipIdleForeground: TuinierColors.textSecondary,
      activeIcon: TuinierColors.lightGreen,
      confirmButton: TuinierColors.primary,
      confirmButtonForeground: TuinierColors.card,
    );
  }
}
