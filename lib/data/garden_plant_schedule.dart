import '../models/garden_plant_profile.dart';
import '../models/garden_personal_event.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'crop_harvest_kind.dart';
import 'underground_crop.dart';
import 'garden_profile_store.dart';
import 'garden_scan_prefs_store.dart';
import 'my_garden_store.dart';
import 'plant_scan_history.dart';
import 'plant_scan_persist_policy.dart';
import 'plant_scan_photo_store.dart';
import 'planting_calendar.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Motivatie voor eerste scan (bel, info-panelen, scan-banner).
const String kFirstScanMotivationMessage =
    'Doe je eerste scan om jouw plant vanaf dag één bij te houden.';

/// Korte regel op plantkaart en status-chip.
const String kFirstScanShortLabel = 'Maak je eerste scan';

/// Profiel na nieuwe AI-scan bijwerken.
GardenPlantProfile applyAiScanToProfile(
  GardenPlantProfile profile,
  PlantAiAnalysis analysis, {
  required int weeklyScanIntervalDays,
  String? imageFingerprint,
  String? newScanPhotoPath,
}) {
  if (!shouldPersistAiScan(analysis)) {
    return profile;
  }

  final history = List<PlantAiAnalysis>.from(profile.scanHistory);
  final paths = List<String>.from(profile.scanPhotoPaths);

  final sameImage = imageFingerprint != null &&
      imageFingerprint == profile.lastScanImageFingerprint &&
      history.isNotEmpty;

  if (sameImage) {
    history[history.length - 1] = analysis;
    if (newScanPhotoPath != null) {
      if (paths.isNotEmpty) {
        PlantScanPhotoStore.deleteFile(paths.last);
        paths[paths.length - 1] = newScanPhotoPath;
      } else {
        paths.add(newScanPhotoPath);
      }
    }
  } else {
    history.add(analysis);
    if (newScanPhotoPath != null) {
      paths.add(newScanPhotoPath);
    }
  }

  const maxScans = 24;
  if (history.length > maxScans) {
    final drop = history.length - maxScans;
    final removedPaths = paths.take(drop).toList();
    PlantScanPhotoStore.deletePaths(removedPaths);
    history.removeRange(0, drop);
    paths.removeRange(0, drop);
  }

  var updated = profile.copyWith(
    lastAnalysis: analysis,
    scanHistory: history,
    scanPhotoPaths: paths,
    isPlanted: true,
    lastScanImageFingerprint: imageFingerprint,
    lastScanPhotoPath: paths.isNotEmpty ? paths.last : profile.lastScanPhotoPath,
  );
  updated = normalizeProfileScans(updated);

  DateTime? harvestAt;
  final days = analysis.daysUntilHarvest;
  if (days != null) {
    harvestAt = _dateOnly(analysis.scannedAt).add(Duration(days: days));
  } else if (analysis.phase == PlantAiPhase.ripe ||
      analysis.insight?.harvestReady == true) {
    harvestAt = _dateOnly(analysis.scannedAt);
  }

  return updated.copyWith(
    lastAnalysis: analysis,
    predictedHarvestAt: harvestAt,
    nextScanDue: _dateOnly(analysis.scannedAt)
        .add(Duration(days: weeklyScanIntervalDays)),
    lastScanImageFingerprint: imageFingerprint,
    plantHealthAcknowledged: analysis.warnings.isEmpty,
    warningsDismissedFromBell: false,
  );
}

DateTime firstPhotoDueDate(
  GardenPlantProfile profile, {
  required int daysUntilFirstPhoto,
}) {
  return _dateOnly(profile.plantedAt).add(Duration(days: daysUntilFirstPhoto));
}

/// Korte NL-datum, bijv. "8 juni".
String formatDateShortNl(DateTime d) =>
    '${d.day} ${kMonthNamesNl[d.month]}';

/// Chip/label op info-tab: zaaidatum vs. datum in app.
String profilePlantedDateLabel(GardenPlantProfile profile) {
  final date = formatDateShortNl(profile.plantedAt);
  if (profile.plantingDateUnknown) {
    return 'Aan tuin toegevoegd op $date';
  }
  return 'Geplant op $date';
}

/// Geplant maar nog geen enkele scan — actie mag direct op de kaart.
bool awaitingFirstPhotoScan(GardenPlantProfile profile) {
  return profile.isPlanted && profile.lastAnalysis == null;
}

/// Eerste scan op de actielijst (direct na “geplant”, ook zonder zichtbare kiem).
bool needsFirstPhoto(
  GardenPlantProfile profile, {
  required int daysUntilFirstPhoto,
}) {
  return awaitingFirstPhotoScan(profile);
}

/// Extra push/herinnering na [daysUntilFirstPhoto] dagen als er nog geen scan is.
bool firstPhotoNotificationDue(
  GardenPlantProfile profile, {
  required int daysUntilFirstPhoto,
  DateTime? reference,
}) {
  if (!awaitingFirstPhotoScan(profile)) return false;
  final today = _dateOnly(reference ?? DateTime.now());
  final due = firstPhotoDueDate(
    profile,
    daysUntilFirstPhoto: daysUntilFirstPhoto,
  );
  return !today.isBefore(due);
}

/// Wanneer de eerste plant-scan — kort en duidelijk.
String firstPhotoReminderLabel(
  GardenPlantProfile profile, {
  required int daysUntilFirstPhoto,
  DateTime? reference,
}) {
  if (!profile.isPlanted) return 'Eerst “geplant” aangeven';
  if (awaitingFirstPhotoScan(profile)) {
    return kFirstScanMotivationMessage;
  }
  final today = _dateOnly(reference ?? DateTime.now());
  final due = firstPhotoDueDate(
    profile,
    daysUntilFirstPhoto: daysUntilFirstPhoto,
  );
  final days = due.difference(today).inDays;
  if (days <= 0) return 'Eerste foto: vandaag';
  if (days == 1) return 'Eerste foto: morgen';
  if (days <= 14) return 'Eerste foto: over $days d';
  return 'Eerste foto: ${formatDateShortNl(due)}';
}

bool needsWeeklyScan(GardenPlantProfile profile) {
  if (!profile.isPlanted || profile.lastAnalysis == null) return false;
  final due = profile.nextScanDue;
  if (due == null) return true;
  return !_dateOnly(DateTime.now()).isBefore(_dateOnly(due));
}

bool isReadyToHarvest(
  GardenPlantProfile profile, {
  Vegetable? vegetable,
}) {
  if (vegetable != null && isOrnamentalOnlyMoestuinCrop(vegetable)) {
    return false;
  }
  final a = profile.lastAnalysis;
  if (a == null) return false;
  if (vegetable != null && isUndergroundCrop(vegetable)) {
    return isUndergroundHarvestConfirmed(profile, vegetable);
  }
  if (a.phase == PlantAiPhase.ripe) return true;
  if (a.insight?.harvestReady == true) return true;
  final days = a.daysUntilHarvest;
  return days != null && days <= 0;
}

/// Toon oogstblok op plantgeschiedenis (incl. «mogelijk» bij ondergrondse gewassen).
bool showHarvestSection(
  GardenPlantProfile profile, {
  Vegetable? vegetable,
}) {
  if (vegetable != null && isEdibleMoestuinBloomCrop(vegetable)) {
    return showEdibleBloomHarvestSection(profile, vegetable);
  }
  if (vegetable != null && isOrnamentalOnlyMoestuinCrop(vegetable)) {
    return showOrnamentalFinishSection(profile, vegetable);
  }
  if (vegetable != null && isUndergroundCrop(vegetable)) {
    return isUndergroundHarvestPossible(profile, vegetable);
  }
  return isReadyToHarvest(profile, vegetable: vegetable);
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
