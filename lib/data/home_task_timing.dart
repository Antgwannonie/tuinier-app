import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'garden_countdown.dart';
import 'garden_plant_schedule.dart';
import 'planting_calendar.dart';

/// Of een taak nu kan (volle kleur) of nog vergrendeld is.
class HomeTaskTiming {
  const HomeTaskTiming({
    required this.isActiveNow,
    this.daysUntil,
    this.usesAi = false,
    this.countdownLabel,
  });

  final bool isActiveNow;
  final int? daysUntil;
  final bool usesAi;
  final String? countdownLabel;

  bool get isLocked => !isActiveNow && daysUntil != null;
}

class HomeTaskEntry {
  const HomeTaskEntry({
    required this.vegetableId,
    required this.activity,
    required this.timing,
  });

  final String vegetableId;
  final VegetableMonthActivity activity;
  final HomeTaskTiming timing;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _isPlantingTask(GardenTaskType type) {
  return type == GardenTaskType.preSow ||
      type == GardenTaskType.sowOutdoors ||
      type == GardenTaskType.plantOutdoors;
}

/// Volgende kalenderdatum voor dit gewas en taaktype (vanaf vandaag).
DateTime? nextCalendarActivityDate(
  String vegetableId,
  GardenTaskType type,
  DateTime from,
) {
  final start = _dateOnly(from);
  DateTime? best;

  for (final a in kPlantingCalendar) {
    if (a.vegetableId != vegetableId || a.type != type) continue;
    for (final m in a.months) {
      for (final year in [start.year, start.year + 1]) {
        final day = activityCalendarDay(a).clamp(1, daysInMonth(year, m));
        final candidate = DateTime(year, m, day);
        if (candidate.isBefore(start)) continue;
        if (best == null || candidate.isBefore(best)) {
          best = candidate;
        }
      }
    }
  }
  return best;
}

VegetableMonthActivity? _activityForMonth(
  String vegetableId,
  GardenTaskType type,
  int month,
) {
  final matches = kPlantingCalendar
      .where((a) => a.vegetableId == vegetableId && a.type == type)
      .toList();
  if (matches.isEmpty) return null;
  for (final a in matches) {
    if (a.months.contains(month)) return a;
  }
  return matches.first;
}

HomeTaskTiming resolveHomeTaskTiming({
  required Vegetable vegetable,
  required GardenTaskType taskType,
  required GardenPlantProfile? profile,
  required bool useAi,
  DateTime? reference,
  bool allowCalendarHarvest = true,
}) {
  final today = _dateOnly(reference ?? DateTime.now());

  if (useAi &&
      profile != null &&
      taskType == GardenTaskType.harvest &&
      profile.lastAnalysis != null) {
    if (canUseAiHarvestAssessment(profile, vegetable: vegetable)) {
      final analysis = profile.lastAnalysis!;
      final days = analysis.daysUntilHarvest;
      if (days != null) {
        final active = days <= 0 || analysis.phase == PlantAiPhase.ripe;
        return HomeTaskTiming(
          isActiveNow: active,
          daysUntil: active ? null : days,
          usesAi: true,
          countdownLabel: active ? null : 'Over $days dagen (AI)',
        );
      }
      final aiWindow = shortHarvestWindowLabel(analysis.harvestWindowLabel);
      if (aiWindow != null) {
        return HomeTaskTiming(
          isActiveNow: false,
          daysUntil: null,
          usesAi: true,
          countdownLabel: aiWindow,
        );
      }
      final harvest = profile.predictedHarvestAt;
      if (harvest != null) {
        final d = _dateOnly(harvest).difference(today).inDays;
        final active = d <= 0;
        return HomeTaskTiming(
          isActiveNow: active,
          daysUntil: active ? null : d,
          usesAi: true,
          countdownLabel: active ? null : 'Over $d dagen (AI)',
        );
      }
    }
  }

  if (profile != null &&
      taskType == GardenTaskType.harvest &&
      profile.isPlanted &&
      useAi &&
      !allowCalendarHarvest) {
    return const HomeTaskTiming(isActiveNow: false);
  }

  final status = gardenStatusForTask(vegetable.id, taskType, reference);
  if (status == null) {
    return const HomeTaskTiming(isActiveNow: false);
  }

  String? label;
  if (!status.isActiveNow) {
    final days = status.daysUntil;
    if (days <= 60) {
      label = 'Over $days dagen';
    } else {
      final start = status.periodStart;
      label = 'Vanaf ${start.day}-${start.month}';
    }
  }

  return HomeTaskTiming(
    isActiveNow: status.isActiveNow,
    daysUntil: status.isActiveNow ? null : status.daysUntil,
    usesAi: false,
    countdownLabel: label,
  );
}

/// Taken voor het gekozen filter, met actief/vergrendeld status.
List<HomeTaskEntry> homeTaskEntriesFor({
  required int month,
  required GardenTaskType taskFilter,
  required Iterable<String> vegetableIds,
  required bool Function(String vegetableId) useAiFor,
  required GardenPlantProfile? Function(String id) profileFor,
  required Vegetable? Function(String id) vegetableById,
  DateTime? reference,
}) {
  final entries = <HomeTaskEntry>[];
  final today = reference ?? DateTime.now();

  for (final id in vegetableIds) {
    final veg = vegetableById(id);
    if (veg == null) continue;

    final hasType = kPlantingCalendar.any(
      (a) => a.vegetableId == id && a.type == taskFilter,
    );
    if (!hasType) continue;

    final profile = profileFor(id);
    if (profile != null && profile.isPlanted && _isPlantingTask(taskFilter)) {
      // Voor reeds geplante gewassen tonen we geen plant/zaai-acties meer.
      continue;
    }
    if (profile != null && !profile.isPlanted && !_isPlantingTask(taskFilter)) {
      // Nog niet geplant: geen oogst-taak op de kaart (voorkomt verkeerd icoon bij zaaien).
      continue;
    }
    final useAi = useAiFor(id) && profile != null;

    final timing = resolveHomeTaskTiming(
      vegetable: veg,
      taskType: taskFilter,
      profile: profile,
      useAi: useAi,
      reference: today,
    );

    final activity = _activityForMonth(id, taskFilter, month);
    if (activity == null) continue;

    final inThisMonth = activity.months.contains(month);
    final aiHarvestVisible = useAi &&
        taskFilter == GardenTaskType.harvest &&
        (profile?.lastAnalysis?.daysUntilHarvest != null ||
            profile?.predictedHarvestAt != null);
    if (!inThisMonth && !timing.isActiveNow && !aiHarvestVisible) continue;

    entries.add(
      HomeTaskEntry(
        vegetableId: id,
        activity: activity,
        timing: timing,
      ),
    );
  }

  entries.sort((a, b) {
    if (a.timing.isActiveNow != b.timing.isActiveNow) {
      return a.timing.isActiveNow ? -1 : 1;
    }
    final da = a.timing.daysUntil ?? 9999;
    final db = b.timing.daysUntil ?? 9999;
    final cmp = da.compareTo(db);
    if (cmp != 0) return cmp;
    return a.vegetableId.compareTo(b.vegetableId);
  });

  return entries;
}

bool _isPreferredHomeTaskEntry(HomeTaskEntry candidate, HomeTaskEntry current) {
  if (candidate.timing.isActiveNow != current.timing.isActiveNow) {
    return candidate.timing.isActiveNow;
  }
  final dc = candidate.timing.daysUntil ?? 9999;
  final dn = current.timing.daysUntil ?? 9999;
  return dc < dn;
}

/// Per plant de meest relevante maandtaak (alle typen), zonder apart filter.
Map<String, HomeTaskEntry> homeTaskEntriesByVegetableForMonth({
  required int month,
  required Iterable<String> vegetableIds,
  required bool Function(String vegetableId) useAiFor,
  required GardenPlantProfile? Function(String id) profileFor,
  required Vegetable? Function(String id) vegetableById,
  DateTime? reference,
}) {
  final byId = <String, HomeTaskEntry>{};
  for (final type in taskTypesForMonth(month)) {
    final entries = homeTaskEntriesFor(
      month: month,
      taskFilter: type,
      vegetableIds: vegetableIds,
      useAiFor: useAiFor,
      profileFor: profileFor,
      vegetableById: vegetableById,
      reference: reference,
    );
    for (final entry in entries) {
      final existing = byId[entry.vegetableId];
      if (existing == null ||
          _isPreferredHomeTaskEntry(entry, existing)) {
        byId[entry.vegetableId] = entry;
      }
    }
  }
  return byId;
}

const _plantingTaskTypes = [
  GardenTaskType.plantOutdoors,
  GardenTaskType.sowOutdoors,
  GardenTaskType.preSow,
];

const _harvestTaskTypes = [GardenTaskType.harvest];

/// Zaai-/plantacties in de moestuin voor de gekozen maand.
List<HomeTaskEntry> homePlantingEntriesForMonth({
  required int month,
  required Iterable<String> vegetableIds,
  required GardenPlantProfile? Function(String id) profileFor,
  required Vegetable? Function(String id) vegetableById,
  DateTime? reference,
}) {
  return _mergeTaskEntriesForTypes(
    month: month,
    types: _plantingTaskTypes,
    vegetableIds: vegetableIds,
    useAiFor: (_) => false,
    profileFor: profileFor,
    vegetableById: vegetableById,
    reference: reference,
  );
}

/// Kalender-oogstacties in de moestuin voor de gekozen maand.
List<HomeTaskEntry> homeHarvestCalendarEntriesForMonth({
  required int month,
  required Iterable<String> vegetableIds,
  required bool Function(String vegetableId) useAiFor,
  required GardenPlantProfile? Function(String id) profileFor,
  required Vegetable? Function(String id) vegetableById,
  DateTime? reference,
}) {
  return _mergeTaskEntriesForTypes(
    month: month,
    types: _harvestTaskTypes,
    vegetableIds: vegetableIds,
    useAiFor: useAiFor,
    profileFor: profileFor,
    vegetableById: vegetableById,
    reference: reference,
  );
}

List<HomeTaskEntry> _mergeTaskEntriesForTypes({
  required int month,
  required List<GardenTaskType> types,
  required Iterable<String> vegetableIds,
  required bool Function(String vegetableId) useAiFor,
  required GardenPlantProfile? Function(String id) profileFor,
  required Vegetable? Function(String id) vegetableById,
  DateTime? reference,
}) {
  final byId = <String, HomeTaskEntry>{};
  for (final type in types) {
    final entries = homeTaskEntriesFor(
      month: month,
      taskFilter: type,
      vegetableIds: vegetableIds,
      useAiFor: useAiFor,
      profileFor: profileFor,
      vegetableById: vegetableById,
      reference: reference,
    );
    for (final entry in entries) {
      final existing = byId[entry.vegetableId];
      if (existing == null || _isPreferredHomeTaskEntry(entry, existing)) {
        byId[entry.vegetableId] = entry;
      }
    }
  }

  final list = byId.values.toList();
  list.sort((a, b) {
    if (a.timing.isActiveNow != b.timing.isActiveNow) {
      return a.timing.isActiveNow ? -1 : 1;
    }
    final da = a.timing.daysUntil ?? 9999;
    final db = b.timing.daysUntil ?? 9999;
    final cmp = da.compareTo(db);
    if (cmp != 0) return cmp;
    return a.vegetableId.compareTo(b.vegetableId);
  });
  return list;
}

/// Korte regel onder plantnaam op home (zaai/plant/oogst).
String homeTaskEntryLabel(HomeTaskEntry entry) {
  if (entry.timing.isActiveNow) {
    return entry.activity.type.label;
  }
  return entry.timing.countdownLabel ?? entry.activity.type.label;
}
