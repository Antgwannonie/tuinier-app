import 'package:flutter/material.dart';

import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../widgets/garden_warning_style.dart';
import 'garden_profile_store.dart';
import 'plant_ai_insight_mapper.dart';
import 'my_garden_store.dart';
import 'plant_age_warnings.dart';
import 'planting_timing_advice.dart';
import 'vegetable_repository.dart';

/// Ernst voor info-knop / meldingen-tab (rood → geel → grijs).
enum PlantWarningHighlightLevel {
  none,
  neutral,
  warning,
  danger,
}

/// Bepaalt de accentkleur van het info-icoon op de plantkaart.
PlantWarningHighlightLevel plantWarningHighlightLevel({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
}) {
  if (activeAiWarningsFor(profile).isNotEmpty) {
    return PlantWarningHighlightLevel.danger;
  }
  if (activeSeasonWarningsFor(profile: profile, vegetable: vegetable)
          .isNotEmpty ||
      activeDatePhotoWarningsFor(profile).isNotEmpty) {
    return PlantWarningHighlightLevel.warning;
  }
  if (lowPriorityScanInfoFor(profile).isNotEmpty) {
    return PlantWarningHighlightLevel.neutral;
  }
  return PlantWarningHighlightLevel.none;
}

/// Of de meldingen-tab inhoud heeft (inclusief scan-informatie).
bool plantHasWarningsTabContent({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
}) {
  return plantWarningHighlightLevel(
            profile: profile,
            vegetable: vegetable,
          ) !=
          PlantWarningHighlightLevel.none ||
      lowPriorityScanInfoFor(profile).isNotEmpty;
}

({Color background, Color foreground}) warningAccentColors(
  ColorScheme cs,
  PlantWarningHighlightLevel level,
) {
  return switch (level) {
    PlantWarningHighlightLevel.danger => (
        background: GardenWarningStyle.dangerBackground(cs),
        foreground: GardenWarningStyle.dangerIcon(cs),
      ),
    PlantWarningHighlightLevel.warning => (
        background: GardenWarningStyle.background(cs),
        foreground: GardenWarningStyle.icon(cs),
      ),
    PlantWarningHighlightLevel.neutral => (
        background: cs.surfaceContainerHighest,
        foreground: cs.onSurfaceVariant,
      ),
    PlantWarningHighlightLevel.none => (
        background: cs.primaryContainer,
        foreground: cs.onPrimaryContainer,
      ),
  };
}

/// AI-scan waarschuwingen (afvinkbaar).
List<String> activeAiWarningsFor(GardenPlantProfile? profile) {
  if (profile == null) return const [];
  if (profile.plantHealthAcknowledged) return const [];
  final ai = profile.lastAnalysis;
  if (ai == null) return const [];
  final out = <String>[];
  if (ai.insight != null) {
    for (final w in warningsFromInsight(ai.insight)) {
      out.add(w);
    }
  }
  for (final raw in ai.warnings) {
    final w = raw.trim();
    if (w.isEmpty) continue;
    if (_isLowPriorityScanInfo(w)) continue;
    if (!out.contains(w)) out.add(w);
  }
  final mismatch = ai.cropMismatchWarning?.trim();
  if (ai.hasCropMismatch &&
      mismatch != null &&
      mismatch.isNotEmpty &&
      !out.contains(mismatch)) {
    out.insert(0, mismatch);
  }
  return out;
}

bool _isLowPriorityScanInfo(String text) {
  final t = text.toLowerCase();
  return t.contains('zelfde foto als vorige scan') ||
      t.contains('zelfde plant en fase als vorige scan') ||
      t.contains('vergelijkbaar met vorige scan');
}

List<String> lowPriorityScanInfoFor(GardenPlantProfile? profile) {
  if (profile == null) return const [];
  final ai = profile.lastAnalysis;
  if (ai == null) return const [];
  final info = <String>[];
  for (final raw in ai.warnings) {
    final w = raw.trim();
    if (w.isEmpty) continue;
    if (_isLowPriorityScanInfo(w)) info.add(w);
  }
  final note = ai.comparisonNote?.trim();
  if (ai.matchedPrevious &&
      note != null &&
      note.isNotEmpty &&
      !info.contains(note)) {
    info.insert(0, note);
  }
  return info;
}

/// Datum vs. foto (AI na scan).
List<String> activeDatePhotoWarningsFor(GardenPlantProfile? profile) =>
    datePhotoWarningsFor(profile);

/// Seizoens-/plantdatum-waarschuwingen (blijven zichtbaar tot datum/locatie past).
List<String> activeSeasonWarningsFor({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
}) {
  if (profile == null || !profile.isPlanted) return const [];
  if (profile.plantingDateUnknown) return const [];
  if (aiReassuresHarvestThisSeason(profile)) return const [];
  return seasonDisplayFor(
    vegetable: vegetable,
    profile: profile,
  ).warningLines;
}

/// Alle meldingen voor overzicht en icoon.
List<String> allActiveWarningsFor({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
}) {
  return [
    ...activeSeasonWarningsFor(profile: profile, vegetable: vegetable),
    ...activeAiWarningsFor(profile),
  ];
}

@Deprecated('Use activeAiWarningsFor')
List<String> activeWarningsFor(GardenPlantProfile? profile) =>
    activeAiWarningsFor(profile);

bool profileHasActiveWarnings(GardenPlantProfile? profile) =>
    activeAiWarningsFor(profile).isNotEmpty;

bool profileHasAnyActiveWarnings({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
}) {
  return allActiveWarningsFor(profile: profile, vegetable: vegetable)
      .isNotEmpty;
}

/// Zichtbaar in meldingen-bel (niet weggeklikt).
bool profileShowsInBell({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
}) {
  if (profile == null || profile.warningsDismissedFromBell) return false;
  return profileHasAnyActiveWarnings(profile: profile, vegetable: vegetable);
}

int countActiveWarningsInGarden({
  required GardenProfileStore profileStore,
  required MyGardenStore gardenStore,
  required VegetableRepository repository,
}) {
  var n = 0;
  for (final id in gardenStore.ids) {
    final p = profileStore.profileFor(id);
    final v = repository.byId(id);
    if (v == null) continue;
    if (profileShowsInBell(profile: p, vegetable: v)) n++;
  }
  return n;
}

List<({GardenPlantProfile profile, Vegetable vegetable})>
    profilesWithActiveWarnings({
  required GardenProfileStore profileStore,
  required MyGardenStore gardenStore,
  required VegetableRepository repository,
}) {
  final out = <({GardenPlantProfile profile, Vegetable vegetable})>[];
  for (final id in gardenStore.ids) {
    final p = profileStore.profileFor(id);
    final v = repository.byId(id);
    if (p == null || v == null) continue;
    if (profileShowsInBell(profile: p, vegetable: v)) {
      out.add((profile: p, vegetable: v));
    }
  }
  return out;
}
