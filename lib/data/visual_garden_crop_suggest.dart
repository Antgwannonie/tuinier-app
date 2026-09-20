import 'dart:math' as math;

import '../models/vegetable.dart';
import '../models/visual_garden_plan.dart';
import 'crop_lifecycle_metadata.dart';
import 'plant_planner_spacing.dart';
import 'plant_search_filters.dart';
import 'vegetable_overview_data.dart';
import 'vegetable_repository.dart';
import 'visual_garden_companion_match.dart';
import 'visual_garden_geometry.dart';

/// Suggestie voor een opvolgteelt, met korte uitleg.
class NextCropSuggestion {
  const NextCropSuggestion({
    required this.plant,
    required this.score,
    required this.reason,
    required this.spacingCm,
  });

  final Vegetable plant;
  final int score;
  final String reason;
  final double spacingCm;
}

/// Bepaalt wanneer de bak vrijkomt na oogst van planten in [plan].
DateTime bedAvailableAfterPlan({
  required VisualCropPlan plan,
  required VegetableRepository repository,
}) {
  final year = plan.endDateOnly.year;
  int? lastHarvestMonth;

  for (final id in plan.plantIds) {
    final v = repository.byId(id);
    if (v == null) continue;
    final month = _lastHarvestMonthFor(v);
    if (month == null) continue;
    lastHarvestMonth = lastHarvestMonth == null
        ? month
        : math.max(lastHarvestMonth, month);
  }

  if (lastHarvestMonth == null) return plan.endDateOnly;
  return DateTime(year, lastHarvestMonth, 1);
}

/// Grootste plantzone (cm) uit het vorige teeltplan — opvolgers mogen dit
/// niet overschrijden (zelfde of kleiner).
double maxPlantSpacingCmFromPlan({
  required VisualCropPlan plan,
  required VegetableRepository repository,
}) {
  var maxSpacing = 0.0;
  for (final p in plan.placements) {
    final v = repository.byId(p.plantId);
    final spacing = v != null
        ? plannerSpacingCmForVegetable(v)
        : plannerSpacingCmFor(p.plantId, fallbackCm: p.spacingCm);
    maxSpacing = math.max(maxSpacing, spacing);
  }
  if (maxSpacing <= 0) return 80;
  return maxSpacing;
}

int? _lastHarvestMonthFor(Vegetable v) {
  final facts = vegetableOverviewFactsFor(v.id);
  final months = (facts != null && facts.harvestMonths.isNotEmpty)
      ? facts.harvestMonths
      : harvestMonthsFor(v);
  if (months.isEmpty) return null;

  final sorted = months.toList()..sort();
  final wrapsWinter =
      sorted.any((m) => m >= 10) && sorted.any((m) => m <= 3);
  if (wrapsWinter) {
    final late = sorted.where((m) => m >= 8).toList();
    if (late.isNotEmpty) return late.last;
  }
  return sorted.last;
}

/// Laatste oogstmaand van een plant (1–12), of null als onbekend.
int? lastHarvestMonthForVegetable(Vegetable v) => _lastHarvestMonthFor(v);

/// Unieke planten uit een teeltplan met hun (geschatte) oogstmaand.
class PreviousCropHarvestSlot {
  const PreviousCropHarvestSlot({
    required this.plant,
    required this.harvestMonth,
    required this.spacingCm,
  });

  final Vegetable plant;
  final int harvestMonth;
  final double spacingCm;
}

List<PreviousCropHarvestSlot> previousCropHarvestSlots({
  required VisualCropPlan plan,
  required VegetableRepository repository,
}) {
  final byId = <String, PreviousCropHarvestSlot>{};
  for (final p in plan.placements) {
    if (byId.containsKey(p.plantId)) continue;
    final v = repository.byId(p.plantId);
    if (v == null) continue;
    final month = _lastHarvestMonthFor(v);
    if (month == null) continue;
    byId[p.plantId] = PreviousCropHarvestSlot(
      plant: v,
      harvestMonth: month,
      spacingCm: plannerSpacingCmForVegetable(v),
    );
  }
  final list = byId.values.toList()
    ..sort((a, b) => a.harvestMonth.compareTo(b.harvestMonth));
  return list;
}

Set<int> _sowOrPlantMonthsFor(Vegetable v) {
  final months = <int>{}
    ..addAll(sowingMonthsForPlant(v))
    ..addAll(plantingMonthsFor(v));
  final facts = vegetableOverviewFactsFor(v.id);
  if (facts != null) {
    months.addAll(facts.sowMonths);
    months.addAll(facts.plantMonths);
  }
  return months;
}

String _monthNl(int month) {
  const names = <String>[
    '',
    'januari',
    'februari',
    'maart',
    'april',
    'mei',
    'juni',
    'juli',
    'augustus',
    'september',
    'oktober',
    'november',
    'december',
  ];
  if (month < 1 || month > 12) return '';
  return names[month];
}

/// Suggesties voor een volgende teelt na [previous].
///
/// Filtert op zaai-/plantperiode én plantafmeting: alleen planten die even
/// groot of kleiner zijn dan de grootste plant in teeltplan 1.
List<NextCropSuggestion> suggestNextCropPlants({
  required VisualCropPlan previous,
  required VegetableRepository repository,
  DateTime? availableFrom,
  double? maxSpacingCm,
  int limit = 12,
}) {
  final from = availableFrom ??
      bedAvailableAfterPlan(plan: previous, repository: repository);
  final month = from.month;
  final nextMonth = (month % 12) + 1;
  final spacingCap = maxSpacingCm ??
      maxPlantSpacingCmFromPlan(plan: previous, repository: repository);
  final prevFamilies = <String>{};
  final prevIds = previous.plantIds;
  final prevNames = <String>[];

  for (final id in prevIds) {
    final v = repository.byId(id);
    if (v == null) continue;
    prevFamilies.add(v.family);
    prevNames.add(v.nameNl);
  }

  final afterLabel = prevNames.isEmpty
      ? previous.name
      : (prevNames.length == 1
          ? prevNames.first
          : '${prevNames.first} e.a.');

  final scored = <NextCropSuggestion>[];
  for (final v in repository.all) {
    if (kMushroomPlantIds.contains(v.id)) continue;
    if (prevIds.contains(v.id)) continue;
    if (prevFamilies.contains(v.family)) continue;

    final spacing = plannerSpacingCmForVegetable(v);
    // Zelfde bak: alleen planten die evenveel of minder ruimte vragen.
    if (spacing > spacingCap + 0.5) continue;

    if (isBadCompanionOf(
      candidate: v,
      repository: repository,
      neighborPlantIds: prevIds,
    )) {
      continue;
    }

    final months = _sowOrPlantMonthsFor(v);
    final inWindow = months.contains(month);
    final inNext = months.contains(nextMonth);
    if (!inWindow && !inNext && months.isNotEmpty) {
      final goodCompanion = isGoodCompanionOf(
        candidate: v,
        repository: repository,
        anchorPlantIds: prevIds,
      );
      if (!goodCompanion) continue;
    }

    var score = 5;
    String reason;
    if (inWindow) {
      score += 28;
      reason =
          'Zaaien/planten in ${_monthNl(month)} — past na $afterLabel';
    } else if (inNext) {
      score += 16;
      reason =
          'Zaaien/planten in ${_monthNl(nextMonth)} — kort na $afterLabel';
    } else {
      reason = 'Past als opvolger na $afterLabel';
    }

    if ((spacingCap - spacing).abs() <= 5) {
      score += 8;
      reason = '$reason · vergelijkbare ruimte (${spacing.round()} cm)';
    } else {
      reason = '$reason · past in bak (${spacing.round()} cm)';
    }

    if (isGoodCompanionOf(
      candidate: v,
      repository: repository,
      anchorPlantIds: prevIds,
    )) {
      score += 12;
      reason = '$reason · goede buurplant';
    }

    scored.add(
      NextCropSuggestion(
        plant: v,
        score: score,
        reason: reason,
        spacingCm: spacing,
      ),
    );
  }

  scored.sort((a, b) => b.score.compareTo(a.score));
  return scored.take(limit).toList();
}

/// Plaatst voorgestelde planten in dezelfde bak (lege teelt) voor preview.
List<PlantPlacement> previewPlacementsForNextCrop({
  required VisualGardenBed bed,
  required List<Vegetable> plants,
  int maxPlacements = 12,
}) {
  final found = <PlantPlacement>[];
  if (plants.isEmpty) return found;

  final emptyBed = bed.copyWith(placements: const []);
  var working = <PlantPlacement>[];

  for (final plant in plants) {
    if (found.length >= maxPlacements) break;
    final spacing = plannerSpacingCmForVegetable(plant);
    final slots = _findSlots(
      bed: emptyBed.copyWith(placements: working),
      spacingCm: spacing,
      plantId: plant.id,
      maxCount: 1,
    );
    if (slots.isEmpty) continue;
    final (x, y) = slots.first;
    final placement = PlantPlacement(
      id: 'preview_${plant.id}_${found.length}',
      plantId: plant.id,
      xCm: x,
      yCm: y,
      spacingCm: spacing,
    );
    working = [...working, placement];
    found.add(placement);
  }
  return found;
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
