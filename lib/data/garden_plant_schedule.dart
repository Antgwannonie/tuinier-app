import '../models/garden_plant_profile.dart';
import '../models/garden_personal_event.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'crop_harvest_kind.dart';
import 'crop_lifecycle_metadata.dart';
import 'underground_crop.dart';
import 'garden_profile_store.dart';
import 'garden_scan_prefs_store.dart';
import 'my_garden_store.dart';
import 'plant_scan_history.dart';
import 'plant_scan_persist_policy.dart';
import 'plant_scan_photo_store.dart';
import 'home_action_completion.dart';
import 'plant_lifecycle.dart';
import 'planting_calendar.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Resterende dagen tot AI-oogst; telt elke kalenderdag af sinds de scan.
int? remainingHarvestDays(
  GardenPlantProfile profile, {
  DateTime? reference,
}) {
  if (!hasPostPlantAiScan(profile)) return null;
  final today = _dateOnly(reference ?? DateTime.now());
  final predicted = profile.predictedHarvestAt;
  if (predicted != null) {
    final left = _dateOnly(predicted).difference(today).inDays;
    return left > 0 ? left : null;
  }
  final analysis = profile.lastAnalysis;
  if (analysis == null) return null;
  final atScan = analysis.daysUntilHarvest;
  if (atScan == null || atScan <= 0) return null;
  final elapsed = today.difference(_dateOnly(analysis.scannedAt)).inDays;
  final left = atScan - elapsed;
  return left > 0 ? left : null;
}

/// AI-oogsttelling is verlopen (vandaag of eerder), zonder dat de fase «rijp» hoeft te zijn.
bool isHarvestDueBySchedule(
  GardenPlantProfile profile, {
  DateTime? reference,
}) {
  if (!hasPostPlantAiScan(profile)) return false;
  final today = _dateOnly(reference ?? DateTime.now());
  final predicted = profile.predictedHarvestAt;
  if (predicted != null) {
    return !_dateOnly(predicted).isAfter(today);
  }
  final analysis = profile.lastAnalysis;
  if (analysis == null) return false;
  final atScan = analysis.daysUntilHarvest;
  if (atScan == null) return false;
  final elapsed = today.difference(_dateOnly(analysis.scannedAt)).inDays;
  return atScan - elapsed <= 0;
}

/// Korte waarde voor moestuin-kaart «Oogst over …» (dagen of AI-venster).
String? moestuinHarvestCountdownValue(
  GardenPlantProfile profile, {
  DateTime? reference,
}) {
  final days = remainingHarvestDays(profile, reference: reference);
  if (days != null && days > 0) {
    return days == 1 ? '1 dag' : '$days dagen';
  }
  return shortHarvestWindowLabel(profile.lastAnalysis?.harvestWindowLabel ?? '');
}

/// Verkort het AI-oogstvenster voor compacte UI; null = geen bruikbare AI-tekst.
String? shortHarvestWindowLabel(String raw) {
  var label = raw.trim();
  if (label.isEmpty || label == '—' || label == '-') return null;

  final lower = label.toLowerCase();

  if (RegExp(r'enkele\s+jaren?').hasMatch(lower)) return 'Enkele jaren';
  if (RegExp(r'meerdere\s+jaren?').hasMatch(lower)) return 'Meerdere jaren';

  final yearRange = RegExp(
    r'over\s+(\d+)\s*(?:tot|–|-)\s*(\d+)\s*jaar',
  ).firstMatch(lower);
  if (yearRange != null) {
    return '${yearRange.group(1)}–${yearRange.group(2)} jaar';
  }

  final yearOver = RegExp(r'over\s+(\d+)\s*jaar').firstMatch(lower);
  if (yearOver != null) {
    final n = int.tryParse(yearOver.group(1)!);
    if (n == 1) return '1 jaar';
    if (n != null) return '$n jaar';
  }

  if (RegExp(r'\bjaren\b').hasMatch(lower)) return 'Jaren';
  if (RegExp(r'\d+\s*jaar').hasMatch(lower) && lower.contains('oogst')) {
    final m = RegExp(r'(\d+)\s*jaar').firstMatch(lower);
    if (m != null) {
      final n = int.tryParse(m.group(1)!);
      if (n == 1) return '1 jaar';
      if (n != null) return '$n jaar';
    }
    return 'Jaren';
  }

  final weekMatch = RegExp(r'over\s+(\d+)\s*weken?').firstMatch(lower);
  if (weekMatch != null) {
    final n = int.tryParse(weekMatch.group(1)!);
    if (n == 1) return '1 week';
    if (n != null) return '$n weken';
  }

  final monthMatch = RegExp(r'over\s+(\d+)\s*maanden?').firstMatch(lower);
  if (monthMatch != null) {
    final n = int.tryParse(monthMatch.group(1)!);
    if (n == 1) return '1 maand';
    if (n != null) return '$n maanden';
  }

  if (lower.contains('volgend seizoen') || lower.contains('volgende seizoen')) {
    return 'Volgend seizoen';
  }
  if (lower.contains('niet dit seizoen') ||
      lower.contains('niet voor dit') ||
      lower.contains('niet dit jaar')) {
    return 'Niet dit seizoen';
  }
  if (lower.contains('binnenkort')) return 'Binnenkort';

  if (label.length <= 14) return _capitalizeHarvestLabel(label);

  final first = label.split(RegExp(r'[.;,]')).first.trim();
  if (first.length <= 14) return _capitalizeHarvestLabel(first);
  return '${first.substring(0, 11)}…';
}

String _capitalizeHarvestLabel(String label) {
  if (label.isEmpty) return label;
  return label[0].toUpperCase() + label.substring(1);
}

/// Minstens één scan op of na de huidige zaai-/plantdatum.
bool hasPostPlantAiScan(GardenPlantProfile profile) {
  if (!profile.isPlanted) return false;
  final analysis = profile.lastAnalysis;
  if (analysis == null) return false;
  // Bestaande plant met onbekende plantdatum: eerste scan geldt meteen.
  if (profile.plantingDateUnknown) return true;
  final planted = _dateOnly(profile.plantedAt);
  final scanned = _dateOnly(analysis.scannedAt);
  return !scanned.isBefore(planted);
}

/// Of de AI al een oogstschatting gaf die we direct mogen gebruiken.
bool _aiHasHarvestEstimate(PlantAiAnalysis analysis) {
  if (analysis.daysUntilHarvest != null) return true;
  if (analysis.phase == PlantAiPhase.ripe ||
      analysis.phase == PlantAiPhase.almostRipe) {
    return true;
  }
  if (analysis.insight?.harvestReady == true) return true;
  final label = analysis.harvestWindowLabel.trim();
  return label.isNotEmpty && label != '—' && label != '-';
}

/// Oogstacties alleen na een geldige AI-scan van déze teelt (niet kalender/oud seizoen).
bool canUseAiHarvestAssessment(
  GardenPlantProfile profile, {
  Vegetable? vegetable,
}) {
  if (!profile.isPlanted || !profile.isMoestuinActive) return false;
  if (!hasPostPlantAiScan(profile)) return false;
  final analysis = profile.lastAnalysis!;
  if (!analysis.matchesSelectedCrop || analysis.hasCropMismatch) return false;

  // Onbekende plantdatum of AI met oogstinfo: niet wachten op X dagen na toevoegen.
  if (profile.plantingDateUnknown || _aiHasHarvestEstimate(analysis)) {
    return true;
  }
  if (profile.predictedHarvestAt != null) return true;

  final today = _dateOnly(DateTime.now());
  final planted = _dateOnly(profile.plantedAt);
  final daysSincePlant = today.difference(planted).inDays;
  final minDays = vegetable != null && isPerennialCrop(vegetable) ? 120 : 21;
  if (daysSincePlant < minDays) return false;

  return true;
}

/// Motivatie voor eerste scan (bel, info-panelen, scan-banner).
const String kFirstScanMotivationMessage =
    'Doe je eerste scan om jouw plant vanaf dag één bij te houden.';

/// Korte regel op plantkaart en status-chip.
const String kFirstScanShortLabel = 'Maak je eerste scan';

/// Actieknop op plantkaart, groene badge en scan-tegel.
const String kFirstScanCardLabel = 'Eerste scan';

/// Profiel na nieuwe AI-scan bijwerken.
GardenPlantProfile applyAiScanToProfile(
  GardenPlantProfile profile,
  PlantAiAnalysis analysis, {
  required int weeklyScanIntervalDays,
  required Vegetable vegetable,
  String? imageFingerprint,
  String? newScanPhotoPath,
  bool forcePersist = false,
}) {
  if (!forcePersist && !shouldPersistAiScan(analysis)) {
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

  final coachingActive = profile.isMoestuinActive;

  updated = updated.copyWith(
    lastAnalysis: analysis,
    predictedHarvestAt: harvestAt,
    nextScanDue: coachingActive
        ? _dateOnly(analysis.scannedAt)
            .add(Duration(days: weeklyScanIntervalDays))
        : profile.nextScanDue,
    lastScanImageFingerprint: imageFingerprint,
    plantHealthAcknowledged: coachingActive
        ? analysis.warnings.isEmpty
        : profile.plantHealthAcknowledged,
    warningsDismissedFromBell:
        coachingActive ? false : profile.warningsDismissedFromBell,
  );

  if (!coachingActive) {
    return updated;
  }

  updated = applyPlantLifecycleAfterScan(
    profile: updated,
    analysis: analysis,
    vegetable: vegetable,
    reference: analysis.scannedAt,
  );

  return completeScanHomeActionsOnProfile(updated, analysis);
}

/// Na een opgeslagen scan verdwijnen scan-acties op Home.
GardenPlantProfile completeScanHomeActionsOnProfile(
  GardenPlantProfile profile,
  PlantAiAnalysis analysis,
) {
  final scanMs = analysis.scannedAt.millisecondsSinceEpoch;
  final completed = Map<String, int>.from(profile.completedHomeActions);

  void mark(String kindName, String topic, String activeLabel) {
    completed[homeActionDismissKey(
      kindName: kindName,
      topic: topic,
      activeLabel: activeLabel,
    )] = scanMs;
  }

  mark('firstScan', 'Eerste scan', kFirstScanShortLabel);
  mark('weeklyScan', 'Scan', 'Wekelijkse foto');

  return profile.copyWith(completedHomeActions: completed);
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

/// Geplant maar nog geen geldige eerste scan na toevoegen/planten.
bool awaitingFirstPhotoScan(GardenPlantProfile profile) {
  if (!profile.isMoestuinActive) return false;
  return profile.isPlanted && !hasPostPlantAiScan(profile);
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

/// Wanneer de eerste plant-scan · kort en duidelijk.
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
  if (!profile.isMoestuinActive) return false;
  if (!profile.isPlanted || profile.lastAnalysis == null) return false;
  final due = profile.nextScanDue;
  if (due == null) return true;
  return !_dateOnly(DateTime.now()).isBefore(_dateOnly(due));
}

/// Strenger dan [isReadyToHarvest]: alleen voor Home-acties (AI moet oogst bevestigen).
bool isHomeHarvestActionDue(
  GardenPlantProfile profile, {
  Vegetable? vegetable,
}) {
  if (vegetable != null && isOrnamentalOnlyMoestuinCrop(vegetable)) {
    return false;
  }
  if (!canUseAiHarvestAssessment(profile, vegetable: vegetable)) return false;
  final a = profile.lastAnalysis!;
  if (vegetable != null && isUndergroundCrop(vegetable)) {
    return isUndergroundHarvestConfirmed(profile, vegetable);
  }
  if (a.insight?.harvestReady == true) return true;
  if (a.phase == PlantAiPhase.ripe) return true;
  return false;
}

bool isReadyToHarvest(
  GardenPlantProfile profile, {
  Vegetable? vegetable,
}) {
  if (vegetable != null && isOrnamentalOnlyMoestuinCrop(vegetable)) {
    return false;
  }
  if (!canUseAiHarvestAssessment(profile, vegetable: vegetable)) return false;
  final a = profile.lastAnalysis!;
  if (vegetable != null && isUndergroundCrop(vegetable)) {
    return isUndergroundHarvestConfirmed(profile, vegetable);
  }
  if (a.phase == PlantAiPhase.ripe) return true;
  if (a.insight?.harvestReady == true) return true;
  return isHarvestDueBySchedule(profile);
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
          title: '$name · ${act.type.label}',
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
        title: '$name · eerste foto',
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
          title: '$name · voortgangsfoto',
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
          title: '$name · oogst',
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
