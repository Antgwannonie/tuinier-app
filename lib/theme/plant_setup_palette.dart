import 'package:flutter/material.dart';

/// Kleuren alleen voor de plant-toevoegen / geplant-sheets (experimenteerbaar).
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
    final dark = Theme.of(context).brightness == Brightness.dark;
    if (dark) {
      return const PlantSetupPalette(
        badgeBackground: Color(0xFF8B6914),
        badgeForeground: Color(0xFFFFF8E7),
        cardBackground: Color(0xFF2A3328),
        cardBorder: Color(0xFF4A5C47),
        sectionLabel: Color(0xFFB8C9AE),
        dateIconBackground: Color(0xFF3D5A40),
        dateIconForeground: Color(0xFFE8F5E6),
        chipSelectedBackground: Color(0xFF5A7A52),
        chipSelectedForeground: Color(0xFFF5FAF3),
        chipIdleBackground: Color(0xFF353F34),
        chipIdleForeground: Color(0xFF9EAE98),
        activeIcon: Color(0xFF9CCC65),
        confirmButton: Color(0xFF6B8E4E),
        confirmButtonForeground: Color(0xFF1B2418),
      );
    }
    return const PlantSetupPalette(
      badgeBackground: Color(0xFFC67B4E),
      badgeForeground: Color(0xFFFFF8F0),
      cardBackground: Color(0xFFF0F5EC),
      cardBorder: Color(0xFFB8C9AE),
      sectionLabel: Color(0xFF3D5A40),
      dateIconBackground: Color(0xFFC5E1C5),
      dateIconForeground: Color(0xFF1B4332),
      chipSelectedBackground: Color(0xFF3D6B4F),
      chipSelectedForeground: Color(0xFFF5FAF3),
      chipIdleBackground: Color(0xFFE2E8DE),
      chipIdleForeground: Color(0xFF5C6B58),
      activeIcon: Color(0xFF2F5233),
      confirmButton: Color(0xFF3D6B4F),
      confirmButtonForeground: Color(0xFFF5FAF3),
    );
  }
}
