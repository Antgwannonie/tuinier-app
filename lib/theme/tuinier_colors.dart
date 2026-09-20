import 'package:flutter/material.dart';

/// Moestuin app design system: kleuren.
abstract final class TuinierColors {
  // Primair
  static const primary = Color(0xFF2E7D32);
  static const lightGreen = Color(0xFF81C784);
  static const headerDark = Color(0xFF1B5E20);
  static const gradientLight = Color(0xFF66BB6A);

  // Oppervlakken
  static const background = Color(0xFFF6F8F3);
  static const scanPageBackground = Color(0xFFF8F9F7);
  static const coachTipBackground = Color(0xFFF4FAF4);
  static const card = Color(0xFFFFFFFF);
  static const border = Color(0xFFE5E7EB);
  static const searchBar = Color(0xFFF3F4F6);

  // Tekst
  static const textPrimary = Color(0xFF1F2937);
  static const textSecondary = Color(0xFF6B7280);
  static const iconPrimary = Color(0xFF374151);
  static const iconMuted = Color(0xFF9CA3AF);

  // Status
  static const success = Color(0xFF22C55E);
  static const warning = Color(0xFFF59E0B);
  static const error = Color(0xFFEF4444);
  static const info = Color(0xFF3B82F6);

  // Groeifase badges
  static const phaseSeedling = Color(0xFFA7F3D0);
  static const phaseGrowing = Color(0xFFBBF7D0);
  static const phaseFlowering = Color(0xFFFDE68A);
  static const phaseFruiting = Color(0xFFFDBA74);
  static const phaseHarvest = Color(0xFF86EFAC);

  // Hover / accent
  static const scanHover = Color(0xFFF0FDF4);

  // Aliassen (bestaande code)
  static const white = card;
  static const primaryDarkGreen = primary;
  static const heroGreen = headerDark;
  static const midGreen = lightGreen;
  static const accentGreen = gradientLight;
  static const bgTintGreen = background;
  static const cardTintGreen = Color(0xFFF0FDF4);
  static const alertRed = error;
  static const alertOrange = warning;
  static const warningGold = warning;
  static const waterBlue = info;
  static const healthyGreen = success;

  static const lightSeed = primary;
  static const lightPrimary = primary;
  static const lightOnPrimary = card;
  static const lightPrimaryContainer = scanHover;
  static const lightOnPrimaryContainer = headerDark;

  static const lightSecondary = lightGreen;
  static const lightOnSecondary = card;
  static const lightSecondaryContainer = background;
  static const lightOnSecondaryContainer = headerDark;

  static const lightSurface = background;
  static const lightOnSurface = textPrimary;
  static const lightSurfaceVariant = background;
  static const lightOnSurfaceVariant = textSecondary;

  static const lightOutline = border;
  static const lightOutlineVariant = border;

  static const lightHeroGreen = headerDark;
  static const lightAccentGreen = gradientLight;
  static const lightCardFill = card;

  // Donker, zelfde als light (app draait altijd light).
  static const darkSeed = primary;
  static const darkPrimary = primary;
  static const darkOnPrimary = card;
  static const darkPrimaryContainer = scanHover;
  static const darkOnPrimaryContainer = headerDark;
  static const darkSecondary = lightGreen;
  static const darkOnSecondary = card;
  static const darkSecondaryContainer = background;
  static const darkOnSecondaryContainer = headerDark;
  static const darkSurface = background;
  static const darkOnSurface = textPrimary;
  static const darkSurfaceVariant = card;
  static const darkOnSurfaceVariant = textSecondary;
  static const darkOutline = border;
  static const darkOutlineVariant = border;

  /// Scorekleur tuingezondheid (90–100 groen, 70–89 oranje, 0–69 rood).
  static Color healthScoreColor(int score) {
    if (score >= 90) return success;
    if (score >= 70) return warning;
    return error;
  }

  /// Gezondheidsbadge op plantkaart (90–100 groen, 70–89 oranje, 0–69 rood).
  static Color plantHealthColor(int percent) => healthScoreColor(percent);

  /// Groeifase → badge-achtergrond.
  static Color phaseBadgeBackground(String phaseLabel) {
    final p = phaseLabel.toLowerCase();
    if (p.contains('zaad') || p.contains('zaail')) return phaseSeedling;
    if (p.contains('bloei')) return phaseFlowering;
    if (p.contains('vrucht')) return phaseFruiting;
    if (p.contains('oogst')) return phaseHarvest;
    if (p.contains('groei')) return phaseGrowing;
    return phaseGrowing;
  }

  static ColorScheme colorScheme(Brightness brightness) {
    return const ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: card,
      primaryContainer: scanHover,
      onPrimaryContainer: headerDark,
      secondary: lightGreen,
      onSecondary: card,
      secondaryContainer: background,
      onSecondaryContainer: headerDark,
      tertiary: info,
      onTertiary: card,
      tertiaryContainer: Color(0xFFDBEAFE),
      onTertiaryContainer: Color(0xFF1E40AF),
      error: error,
      onError: card,
      errorContainer: Color(0xFFFEE2E2),
      onErrorContainer: Color(0xFF991B1B),
      surface: background,
      onSurface: textPrimary,
      surfaceContainerHighest: card,
      surfaceContainerHigh: card,
      surfaceContainer: card,
      surfaceContainerLow: card,
      surfaceContainerLowest: card,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border,
      shadow: Colors.black,
      scrim: Colors.black,
      inverseSurface: textPrimary,
      onInverseSurface: card,
      inversePrimary: lightGreen,
    );
  }
}
