import 'dart:math' as math;

import '../models/vegetable.dart';
import 'vegetable_overview_data.dart';

/// Haalt de kleinste maat in cm uit een overzicht-string zoals `80–120 cm`.
double? parseMinSpacingCmFromText(String? text) {
  if (text == null) return null;
  final trimmed = text.trim();
  if (trimmed.isEmpty) return null;

  final matches = RegExp(r'(\d+(?:[.,]\d+)?)').allMatches(trimmed);
  if (matches.isEmpty) return null;

  double? min;
  for (final match in matches) {
    final raw = match.group(1);
    if (raw == null) continue;
    final value = double.tryParse(raw.replaceAll(',', '.'));
    if (value == null || value <= 0) continue;
    min = min == null ? value : math.min(min, value);
  }
  return min;
}

/// Plantzone voor de visuele planner.
///
/// Gebruikt het minimum uit overzicht-veld **Breedte** (`width`),
/// anders [fallbackCm] (catalogus `spacingCm`).
double plannerSpacingCmFor(
  String plantId, {
  required double fallbackCm,
}) {
  final facts = vegetableOverviewFactsFor(plantId);
  final fromOverview = parseMinSpacingCmFromText(facts?.width);
  if (fromOverview != null) return fromOverview;
  if (fallbackCm > 0) return fallbackCm;
  return 25;
}

double plannerSpacingCmForVegetable(Vegetable plant) {
  return plannerSpacingCmFor(
    plant.id,
    fallbackCm: plant.spacingCm.toDouble(),
  );
}
