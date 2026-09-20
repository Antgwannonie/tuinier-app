import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'tuinier_colors.dart';

/// Moestuin design system, Amatic (labels), Fraunces (koppen), Nunito Sans (body).
ThemeData buildTuinierTheme({required Brightness brightness}) {
  final colorScheme = TuinierColors.colorScheme(brightness);

  final base = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: Brightness.light,
  );

  final body = GoogleFonts.nunitoSansTextTheme(base.textTheme);
  final heading = GoogleFonts.frauncesTextTheme(body);

  final textTheme = heading.copyWith(
    displayLarge: _frauncesHeading(heading.displayLarge, FontWeight.w600),
    displayMedium: _frauncesHeading(heading.displayMedium, FontWeight.w600),
    displaySmall: _frauncesHeading(heading.displaySmall, FontWeight.w600),
    headlineLarge: _frauncesHeading(heading.headlineLarge, FontWeight.w600),
    headlineMedium: _frauncesHeading(heading.headlineMedium, FontWeight.w600),
    headlineSmall: _frauncesHeading(heading.headlineSmall, FontWeight.w600),
    titleLarge: _frauncesHeading(heading.titleLarge, FontWeight.w600, 20),
    titleMedium: _frauncesHeading(heading.titleMedium, FontWeight.w600, 18),
    titleSmall: _frauncesHeading(heading.titleSmall, FontWeight.w600, 16),
    bodyLarge: _nunitoBody(16, FontWeight.w400, TuinierColors.textPrimary, 1.45),
    bodyMedium: _nunitoBody(14, FontWeight.w400, TuinierColors.textPrimary, 1.4),
    bodySmall: _nunitoBody(12, FontWeight.w400, TuinierColors.textSecondary, 1.35),
    labelLarge: _nunitoBody(14, FontWeight.w600, TuinierColors.textPrimary, 1.3),
    labelMedium: _nunitoBody(12, FontWeight.w500, TuinierColors.textSecondary, 1.3),
    labelSmall: _nunitoBody(12, FontWeight.w500, TuinierColors.textSecondary, 1.25),
  );

  return base.copyWith(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: TuinierColors.background,
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    chipTheme: ChipThemeData(
      backgroundColor: TuinierColors.card,
      selectedColor: TuinierColors.primary,
      labelStyle: _nunitoBody(14, FontWeight.w600, TuinierColors.textPrimary, 1.2),
      secondaryLabelStyle: _nunitoBody(14, FontWeight.w600, TuinierColors.card, 1.2),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: TuinierColors.border),
      ),
    ),
    cardTheme: CardThemeData(
      color: TuinierColors.card,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: TuinierColors.border.withValues(alpha: 0.6)),
      ),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: TuinierColors.primary,
        foregroundColor: TuinierColors.card,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: _nunitoBody(16, FontWeight.w600, TuinierColors.card, 1.2),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: TuinierColors.primary,
        backgroundColor: TuinierColors.card,
        side: const BorderSide(color: TuinierColors.primary, width: 1.5),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: _nunitoBody(16, FontWeight.w600, TuinierColors.primary, 1.2),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: TuinierColors.primary,
      foregroundColor: TuinierColors.card,
      elevation: 4,
      shape: CircleBorder(),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: TuinierColors.card,
      indicatorColor: TuinierColors.scanHover,
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return IconThemeData(
          color: selected ? TuinierColors.primary : TuinierColors.iconMuted,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.fraunces(
          fontSize: 11,
          fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          color: selected ? TuinierColors.primary : TuinierColors.iconMuted,
        );
      }),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: TuinierColors.background,
      foregroundColor: TuinierColors.iconPrimary,
      centerTitle: true,
      scrolledUnderElevation: 0,
      elevation: 0,
      toolbarHeight: 60,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: GoogleFonts.amaticSc(
        fontSize: 28,
        fontWeight: FontWeight.w700,
        color: TuinierColors.textPrimary,
        height: 1.05,
      ),
      iconTheme: const IconThemeData(
        color: TuinierColors.iconPrimary,
        size: 24,
      ),
    ),
    dividerTheme: const DividerThemeData(
      color: TuinierColors.border,
      thickness: 1,
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: TuinierColors.primary,
    ),
  );
}

TextStyle _nunitoBody(
  double size,
  FontWeight weight,
  Color color,
  double height,
) {
  return GoogleFonts.nunitoSans(
    fontSize: size,
    fontWeight: weight,
    color: color,
    height: height,
  );
}

TextStyle? _frauncesHeading(TextStyle? style, FontWeight weight, [double? size]) {
  return GoogleFonts.fraunces(
    fontSize: size ?? style?.fontSize,
    fontWeight: weight,
    color: TuinierColors.textPrimary,
    height: style?.height ?? 1.2,
  );
}

/// Sectietitel, Fraunces (organische kop).
TextStyle? tuinDisplayStyle(
  BuildContext context, {
  TextStyle? base,
  double? fontSize,
  FontWeight fontWeight = FontWeight.w600,
  Color? color,
}) {
  return GoogleFonts.fraunces(
    fontSize: fontSize ?? base?.fontSize ?? 20,
    fontWeight: fontWeight,
    color: color ?? TuinierColors.textPrimary,
    height: 1.2,
  );
}

/// Grote score, Fraunces Bold.
TextStyle? tuinScoreStyle(
  BuildContext context, {
  Color? color,
  double fontSize = 32,
}) {
  return GoogleFonts.fraunces(
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
    color: color ?? TuinierColors.textPrimary,
    height: 1.1,
  );
}

/// App-balk & maand, Amatic SC (handgeschreven tuinlabel).
TextStyle? tuinAccentDisplayStyle(
  BuildContext context, {
  double fontSize = 26,
  FontWeight fontWeight = FontWeight.w700,
  Color? color,
}) {
  return GoogleFonts.amaticSc(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? TuinierColors.textPrimary,
    height: 1.05,
  );
}

/// Maandnaam in sierletter (zelfde als accent).
TextStyle? tuinMonthStyle(
  BuildContext context, {
  double fontSize = 22,
  Color? color,
}) {
  return tuinAccentDisplayStyle(
    context,
    fontSize: fontSize,
    color: color,
  );
}
