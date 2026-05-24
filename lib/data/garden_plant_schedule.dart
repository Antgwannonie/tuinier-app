import '../models/garden_plant_profile.dart';
import '../models/garden_personal_event.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'garden_profile_store.dart';
import 'garden_scan_prefs_store.dart';
import 'my_garden_store.dart';
import 'planting_calendar.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Profiel na nieuwe AI-scan bijwerken.
GardenPlantProfile applyAiScanToProfile(
  GardenPlantProfile profile,
  PlantAiAnalysis analysis, {
  required int weeklyScanIntervalDays,
}) {
  final history = List<PlantAiAnalysis>.from(profile.scanHistory)..add(analysis);
  final trimmed = history.length > 24
      ? history.sublist(history.length - 24)
      : history;

  DateTime? harvestAt;
  final days = analysis.daysUntilHarvest;
  if (days != null) {
    harvestAt = _dateOnly(analysis.scannedAt).add(Duration(days: days));
  } else if (analysis.phase == PlantAiPhase.ripe) {
    harvestAt = _dateOnly(analysis.scannedAt);
  }

  return profile.copyWith(
    lastAnalysis: analysis,
    scanHistory: trimmed,
    predictedHarvestAt: harvestAt,
    nextScanDue: _dateOnly(analysis.scannedAt)
        .add(Duration(days: weeklyScanIntervalDays)),
    isPlanted: true,
  );
}

DateTime firstPhotoDueDate(
  GardenPlantProfile profile, {
  required int daysUntilFirstPhoto,
}) {
  return _dateOnly(profile.plantedAt).add(Duration(days: daysUntilFirstPhoto));
}

bool needsFirstPhoto(
  GardenPlantProfile profile, {
  required int daysUntilFirstPhoto,
}) {
  if (!profile.isPlanted) return false;
  if (profile.lastAnalysis != null) return false;
  final due = firstPhotoDueDate(
    profile,
    daysUntilFirstPhoto: daysUntilFirstPhoto,
  );
  return !_dateOnly(DateTime.now()).isBefore(due);
}

bool needsWeeklyScan(GardenPlantProfile profile) {
  if (!profile.isPlanted || profile.lastAnalysis == null) return false;
  final due = profile.nextScanDue;
  if (due == null) return true;
  return !_dateOnly(DateTime.now()).isBefore(_dateOnly(due));
}

bool isReadyToHarvest(GardenPlantProfile profile) {
  final a = profile.lastAnalysis;
  if (a == null) return false;
  if (a.phase == PlantAiPhase.ripe) return true;
  final days = a.daysUntilHarvest;
  return days != null && days <= 0;
}

List<GardenPersonalEvent> personalEventsForProfile(
  GardenPlantProfile profile,
  Vegetable vegetable, {
  required int daysUntilFirstPhoto,
  required int weeklyScanIntervalDays,
}) {
  final events = <GardenPersonalEvent>[];
  final name = vegetable.nameNl;

  if (!profile.isPlanted) {
    final now = DateTime.now();
    final month = now.month;
    final activities = kPlantingCalendar.where(
      (a) =>
          a.vegetableId == profile.vegetableId &&
          a.months.contains(month) &&
          (a.type == GardenTaskType.plantOutdoors ||
              a.type == GardenTaskType.sowOutdoors ||
              a.type == GardenTaskType.preSow),
    );
    for (final act in activities) {
      final day = activityCalendarDay(act);
      events.add(
        GardenPersonalEvent(
          vegetableId: profile.vegetableId,
          date: DateTime(now.year, month, day),
          type: PersonalEventType.plantReminder,
          title: '$name — ${act.type.label}',
          subtitle: act.hint,
        ),
      );
    }
    return events;
  }

  if (profile.lastAnalysis == null) {
    final due = firstPhotoDueDate(
      profile,
      daysUntilFirstPhoto: daysUntilFirstPhoto,
    );
    events.add(
      GardenPersonalEvent(
        vegetableId: profile.vegetableId,
        date: due,
        type: PersonalEventType.firstPhoto,
        title: '$name — eerste foto',
        subtitle: 'Scan de plant voor persoonlijke planning',
      ),
    );
  } else {
    var scanDue = profile.nextScanDue ??
        _dateOnly(profile.lastAnalysis!.scannedAt)
            .add(Duration(days: weeklyScanIntervalDays));
    for (var i = 0; i < 8; i++) {
      events.add(
        GardenPersonalEvent(
          vegetableId: profile.vegetableId,
          date: scanDue,
          type: PersonalEventType.weeklyScan,
          title: '$name — voortgangsfoto',
          subtitle: 'Houd je moestuin bij met een nieuwe scan',
        ),
      );
      scanDue = scanDue.add(Duration(days: weeklyScanIntervalDays));
    }

    final harvest = profile.predictedHarvestAt;
    if (harvest != null) {
      events.add(
        GardenPersonalEvent(
          vegetableId: profile.vegetableId,
          date: harvest,
          type: PersonalEventType.harvest,
          title: '$name — oogst',
          subtitle: profile.lastAnalysis?.harvestWindowLabel,
        ),
      );
    }
  }

  return events;
}

List<GardenPersonalEvent> allPersonalEvents({
  required GardenProfileStore profileStore,
  required MyGardenStore gardenStore,
  required Vegetable? Function(String id) vegetableById,
  required int daysUntilFirstPhoto,
  required int weeklyScanIntervalDays,
}) {
  final out = <GardenPersonalEvent>[];
  for (final id in gardenStore.ids) {
    final veg = vegetableById(id);
    if (veg == null) continue;
    final profile = profileStore.profileFor(id);
    if (profile == null) continue;
    out.addAll(
      personalEventsForProfile(
        profile,
        veg,
        daysUntilFirstPhoto: daysUntilFirstPhoto,
        weeklyScanIntervalDays: weeklyScanIntervalDays,
      ),
    );
  }
  out.sort((a, b) => a.date.compareTo(b.date));
  return out;
}

List<GardenPersonalEvent> personalEventsOnDay({
  required int year,
  required int month,
  required int day,
  required GardenProfileStore profileStore,
  required MyGardenStore gardenStore,
  required Vegetable? Function(String id) vegetableById,
  required int daysUntilFirstPhoto,
  required int weeklyScanIntervalDays,
}) {
  return allPersonalEvents(
    profileStore: profileStore,
    gardenStore: gardenStore,
    vegetableById: vegetableById,
    daysUntilFirstPhoto: daysUntilFirstPhoto,
    weeklyScanIntervalDays: weeklyScanIntervalDays,
  )
      .where((e) =>
          e.date.year == year && e.date.month == month && e.date.day == day)
      .toList();
}
