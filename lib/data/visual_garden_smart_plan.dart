import 'dart:math' as math;

import '../models/vegetable.dart';
import '../models/visual_garden_plan.dart';
import 'moestuin_companion_plants.dart';
import 'plant_planner_spacing.dart';
import 'plant_search_filters.dart';
import 'planting_season_status.dart';
import 'vegetable_repository.dart';
import 'visual_garden_companion_match.dart';
import 'visual_garden_geometry.dart';

class SmartPlanPlacement {
  const SmartPlanPlacement({
    required this.plant,
    required this.xCm,
    required this.yCm,
    required this.spacingCm,
  });

  final Vegetable plant;
  final double xCm;
  final double yCm;
  final double spacingCm;
}

class SmartGardenPlanResult {
  const SmartGardenPlanResult({
    required this.placements,
    required this.successionPlants,
  });

  final List<SmartPlanPlacement> placements;
  final List<Vegetable> successionPlants;
}

/// Regelgebaseerd “slim tuinplan”: selecteert passende planten en plaatst ze
/// in de bak (bestaande placements blijven staan).
SmartGardenPlanResult buildSmartGardenPlan({
  required VisualGardenBed bed,
  required VegetableRepository repository,
  DateTime? now,
  int maxSpecies = 8,
  int maxNewPlacements = 40,
}) {
  final today = now ?? DateTime.now();
  final existingIds = bed.placements.map((p) => p.plantId).toSet();

  final candidates = repository.all
      .where((v) => !kMushroomPlantIds.contains(v.id))
      .toList();

  final scored = <({Vegetable v, double score})>[];
  for (final v in candidates) {
    final score = _scorePlant(
      v: v,
      bed: bed,
      repository: repository,
      neighborIds: existingIds,
      today: today,
    );
    if (score <= 0) continue;
    scored.add((v: v, score: score));
  }
  scored.sort((a, b) => b.score.compareTo(a.score));

  final chosen = <Vegetable>[];
  final chosenIds = <String>{...existingIds};

  for (final item in scored) {
    if (chosen.length >= 2) break;
    if (!kMoestuinCompanionPlantIds.contains(item.v.id)) continue;
    if (chosenIds.contains(item.v.id)) continue;
    if (isBadCompanionOf(
      candidate: item.v,
      repository: repository,
      neighborPlantIds: chosenIds,
    )) {
      continue;
    }
    chosen.add(item.v);
    chosenIds.add(item.v.id);
  }

  for (final item in scored) {
    if (chosen.length >= maxSpecies) break;
    if (chosenIds.contains(item.v.id)) continue;
    if (isBadCompanionOf(
      candidate: item.v,
      repository: repository,
      neighborPlantIds: chosenIds,
    )) {
      continue;
    }
    final sameFamily =
        chosen.where((c) => c.family == item.v.family).length;
    if (sameFamily >= 2) continue;
    chosen.add(item.v);
    chosenIds.add(item.v.id);
  }

  if (chosen.isEmpty && scored.isNotEmpty) {
    chosen.add(scored.first.v);
  }

  final newPlacements = <SmartPlanPlacement>[];
  var working = List<PlantPlacement>.from(bed.placements);

  for (final plant in chosen) {
    if (newPlacements.length >= maxNewPlacements) break;
    final spacing = plannerSpacingCmForVegetable(plant);
    final bedNow = bed.copyWith(placements: working);
    final slots = _findSlots(
      bed: bedNow,
      spacingCm: spacing,
      plantId: plant.id,
      maxCount: _targetCountFor(plant, bed),
    );
    for (final slot in slots) {
      if (newPlacements.length >= maxNewPlacements) break;
      final id =
          'smart_${plant.id}_${DateTime.now().microsecondsSinceEpoch}_${newPlacements.length}';
      working = [
        ...working,
        PlantPlacement(
          id: id,
          plantId: plant.id,
          xCm: slot.$1,
          yCm: slot.$2,
          spacingCm: spacing,
        ),
      ];
      newPlacements.add(
        SmartPlanPlacement(
          plant: plant,
          xCm: slot.$1,
          yCm: slot.$2,
          spacingCm: spacing,
        ),
      );
    }
  }

  return SmartGardenPlanResult(
    placements: newPlacements,
    successionPlants: _successionPlants(
      repository: repository,
      primary: chosen,
      today: today,
    ),
  );
}

double _scorePlant({
  required Vegetable v,
  required VisualGardenBed bed,
  required VegetableRepository repository,
  required Set<String> neighborIds,
  required DateTime today,
}) {
  if (isBadCompanionOf(
    candidate: v,
    repository: repository,
    neighborPlantIds: neighborIds,
  )) {
    return -100;
  }

  final spacing = plannerSpacingCmForVegetable(v);
  final capacity = estimateMaxPlantsGrid(bed: bed, spacingCm: spacing);
  if (capacity < 1) return -50;

  var score = 10.0;

  if (kMoestuinCompanionPlantIds.contains(v.id)) {
    score += 18;
  }

  if (neighborIds.isNotEmpty &&
      isGoodCompanionOf(
        candidate: v,
        repository: repository,
        anchorPlantIds: neighborIds,
      )) {
    score += 22;
  }

  final season = plantingSeasonStatusFor(
    v.id,
    reference: today,
    vegetable: v,
  );
  switch (season.phase) {
    case PlantingSeasonPhase.activeNow:
      score += 20;
    case PlantingSeasonPhase.daysLeft:
      score += 14;
    case PlantingSeasonPhase.startsSoon:
      score += 6;
    case PlantingSeasonPhase.seasonEnded:
      score -= 8;
    case PlantingSeasonPhase.noCalendar:
      score += 2;
  }

  final months = sowingMonthsForPlant(v);
  if (months.contains(today.month)) {
    score += 12;
  }

  if (bed.areaM2 < 1.2 && spacing <= 30) score += 6;
  if (bed.areaM2 >= 1.2 && spacing >= 35) score += 4;

  return score;
}

int _targetCountFor(Vegetable plant, VisualGardenBed bed) {
  final spacing = plannerSpacingCmForVegetable(plant);
  final maxGrid = estimateMaxPlantsGrid(bed: bed, spacingCm: spacing);
  if (kMoestuinCompanionPlantIds.contains(plant.id)) {
    return math.min(3, math.max(1, maxGrid ~/ 4));
  }
  return math.min(6, math.max(1, maxGrid ~/ 3));
}

List<(double, double)> _findSlots({
  required VisualGardenBed bed,
  required double spacingCm,
  required String plantId,
  required int maxCount,
}) {
  final found = <(double, double)>[];
  if (maxCount <= 0 || spacingCm <= 0) return found;

  final minX = bed.verticesCm.map((v) => v.dx).reduce(math.min);
  final maxX = bed.verticesCm.map((v) => v.dx).reduce(math.max);
  final minY = bed.verticesCm.map((v) => v.dy).reduce(math.min);
  final maxY = bed.verticesCm.map((v) => v.dy).reduce(math.max);

  final step = spacingCm;
  final startX = minX + spacingCm / 2;
  final startY = minY + spacingCm / 2;

  final temp = List<PlantPlacement>.from(bed.placements);

  for (var y = startY; y <= maxY - spacingCm / 2 + 0.01; y += step) {
    for (var x = startX; x <= maxX - spacingCm / 2 + 0.01; x += step) {
      if (found.length >= maxCount) return found;
      final probeBed = bed.copyWith(placements: temp);
      final ok = checkPlacement(
        bed: probeBed,
        xCm: x,
        yCm: y,
        spacingCm: spacingCm,
        ignorePlacementId: null,
        spacingFor: (_, fallback) => fallback,
      );
      if (!ok.isValid) continue;
      found.add((x, y));
      temp.add(
        PlantPlacement(
          id: 'tmp_${plantId}_${found.length}',
          plantId: plantId,
          xCm: x,
          yCm: y,
          spacingCm: spacingCm,
        ),
      );
    }
  }
  return found;
}

List<Vegetable> _successionPlants({
  required VegetableRepository repository,
  required List<Vegetable> primary,
  required DateTime today,
  int limit = 8,
}) {
  final primaryFamilies = primary.map((p) => p.family).toSet();
  final primaryIds = primary.map((p) => p.id).toSet();
  final laterMonth = today.month >= 11 ? 3 : (today.month + 2);

  final out = <Vegetable>[];
  for (final v in repository.all) {
    if (out.length >= limit) break;
    if (primaryIds.contains(v.id)) continue;
    if (kMushroomPlantIds.contains(v.id)) continue;
    if (primaryFamilies.contains(v.family)) continue;
    final months = sowingMonthsForPlant(v);
    if (months.isNotEmpty && !months.contains(laterMonth)) continue;
    if (isBadCompanionOf(
      candidate: v,
      repository: repository,
      neighborPlantIds: primaryIds,
    )) {
      continue;
    }
    out.add(v);
  }

  if (out.length < 4) {
    for (final v in repository.all) {
      if (out.length >= limit) break;
      if (primaryIds.contains(v.id) || out.any((o) => o.id == v.id)) {
        continue;
      }
      if (kMushroomPlantIds.contains(v.id)) continue;
      if (primaryFamilies.contains(v.family)) continue;
      out.add(v);
    }
  }
  return out;
}
