import 'package:flutter/material.dart';

import 'tuinier_colors.dart';

/// Gedeelde decoraties, kaarten, schaduwen, gradients.
abstract final class TuinierDecorations {
  static List<BoxShadow> get cardShadow => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.05),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get cardShadowMedium => [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get scanButtonShadow => [
        BoxShadow(
          color: TuinierColors.primary.withValues(alpha: 0.25),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];

  static BoxDecoration card({
    Color color = TuinierColors.card,
    double radius = 20,
    bool shadow = true,
    bool bordered = true,
    Border? border,
  }) {
    return BoxDecoration(
      color: color,
      borderRadius: BorderRadius.circular(radius),
      border: border ??
          (bordered
              ? Border.all(color: TuinierColors.border.withValues(alpha: 0.6))
              : null),
      boxShadow: shadow ? cardShadow : null,
    );
  }

  static BoxDecoration aiCoachGradient({double radius = 24}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TuinierColors.primary, TuinierColors.gradientLight],
      ),
    );
  }

  static BoxDecoration scanHeroGradient({double radius = 20}) {
    return BoxDecoration(
      borderRadius: BorderRadius.circular(radius),
      gradient: const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [TuinierColors.headerDark, TuinierColors.primary],
      ),
    );
  }

  static BoxDecoration appBarBorder() {
    return const BoxDecoration(
      color: TuinierColors.card,
      border: Border(
        bottom: BorderSide(color: TuinierColors.border, width: 1),
      ),
    );
  }

  /// Buitenste sectiekaart, lichtgrijs (#F2F2F2).
  static const sectionCardFill = Color(0xFFF2F2F2);

  static BoxDecoration sectionCard({
    double radius = 20,
  }) {
    return BoxDecoration(
      color: sectionCardFill,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFE5E5E5)),
      boxShadow: cardShadow,
    );
  }

  /// Witte binnenkaart voor lijstitems.
  static BoxDecoration innerListCard({double radius = 16}) {
    return BoxDecoration(
      color: TuinierColors.card,
      borderRadius: BorderRadius.circular(radius),
      border: Border.all(color: const Color(0xFFEBEBEB)),
    );
  }

  static BoxDecoration bottomNavBorder() {
    return const BoxDecoration(
      color: TuinierColors.card,
      border: Border(
        top: BorderSide(color: TuinierColors.border, width: 1),
      ),
    );
  }
}
