import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Tuin-thema: sierlijke koppen (plantachtig), leesbare bodytekst.
ThemeData buildTuinierTheme({required Brightness brightness}) {
  // Warm olijf-/aardetint (was fel Material-groen) — zichtbaar op knoppen, chips, nav.
  final colorScheme = ColorScheme.fromSeed(
    seedColor: brightness == Brightness.light
        ? const Color(0xFF4A6741)
        : const Color(0xFF7CB87A),
    brightness: brightness,
  );

  final base = ThemeData(
    colorScheme: colorScheme,
    useMaterial3: true,
    brightness: brightness,
  );

  final body = GoogleFonts.nunitoSansTextTheme(base.textTheme);
  final heading = GoogleFonts.frauncesTextTheme(body);

  final textTheme = heading.copyWith(
    bodyLarge: body.bodyLarge,
    bodyMedium: body.bodyMedium,
    bodySmall: body.bodySmall,
    labelLarge: body.labelLarge,
    labelMedium: body.labelMedium,
    labelSmall: body.labelSmall,
    displayLarge: _heading(heading.displayLarge, FontWeight.w700),
    displayMedium: _heading(heading.displayMedium, FontWeight.w700),
    displaySmall: _heading(heading.displaySmall, FontWeight.w600),
    headlineLarge: _heading(heading.headlineLarge, FontWeight.w700),
    headlineMedium: _heading(heading.headlineMedium, FontWeight.w700),
    headlineSmall: _heading(heading.headlineSmall, FontWeight.w700),
    titleLarge: _heading(heading.titleLarge, FontWeight.w700),
    titleMedium: _heading(heading.titleMedium, FontWeight.w700),
    titleSmall: _heading(heading.titleSmall, FontWeight.w600),
  );

  return base.copyWith(
    textTheme: textTheme,
    primaryTextTheme: textTheme,
    appBarTheme: AppBarTheme(
      centerTitle: true,
      scrolledUnderElevation: 0,
      titleTextStyle: GoogleFonts.amaticSc(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        color: colorScheme.onSurface,
        letterSpacing: 0.6,
        height: 1.1,
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final selected = states.contains(WidgetState.selected);
        return GoogleFonts.fraunces(
          fontSize: 12,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
          color: selected
              ? colorScheme.onSurface
              : colorScheme.onSurfaceVariant,
        );
      }),
    ),
  );
}

TextStyle? _heading(TextStyle? style, FontWeight weight) {
  return style?.copyWith(fontWeight: weight, letterSpacing: 0.2);
}

/// Sierlijke kop (Fraunces) — sectietitels en maandnaam.
TextStyle? tuinDisplayStyle(
  BuildContext context, {
  TextStyle? base,
  double? fontSize,
  FontWeight fontWeight = FontWeight.w700,
  Color? color,
}) {
  final themed = base ?? Theme.of(context).textTheme.titleMedium;
  return GoogleFonts.fraunces(
    fontSize: fontSize ?? themed?.fontSize,
    fontWeight: fontWeight,
    color: color ?? themed?.color,
    height: themed?.height ?? 1.2,
    letterSpacing: 0.3,
  );
}

/// Extra sierlijk voor korte titels (handgeschreven tuin-label).
TextStyle? tuinAccentDisplayStyle(
  BuildContext context, {
  double fontSize = 26,
  FontWeight fontWeight = FontWeight.w700,
  Color? color,
}) {
  final cs = Theme.of(context).colorScheme;
  return GoogleFonts.amaticSc(
    fontSize: fontSize,
    fontWeight: fontWeight,
    color: color ?? cs.onSurface,
    letterSpacing: 0.5,
    height: 1.05,
  );
}
