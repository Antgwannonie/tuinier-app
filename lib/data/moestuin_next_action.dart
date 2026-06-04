import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'garden_countdown.dart';
import 'garden_plant_schedule.dart';
import 'home_task_timing.dart';
import 'planting_calendar.dart';

/// Of deze plant nu een urgente kaartactie of actieve maandtaak heeft.
bool plantNeedsMoestuinAction({
  required bool hasHomeAction,
  required HomeTaskEntry? taskEntry,
  required bool awaitingPlant,
  required bool awaitingFirstScan,
}) {
  if (awaitingPlant) return true;
  if (awaitingFirstScan) return true;
  if (hasHomeAction) return true;
  return taskEntry?.timing.isActiveNow ?? false;
}

/// Korte plantnaam voor aftelteksten (Pruimenboom → Pruimen).
String cropShortName(String nameNl) {
  var s = nameNl.trim();
  final lower = s.toLowerCase();
  if (lower.endsWith('boom')) {
    s = s.substring(0, s.length - 4).trim();
  }
  return s;
}

String _seasonLabelForTask(GardenTaskType type) {
  switch (type) {
    case GardenTaskType.harvest:
      return 'oogstseizoen';
    case GardenTaskType.plantOutdoors:
      return 'plantseizoen';
    case GardenTaskType.sowOutdoors:
      return 'zaaiseizoen';
    case GardenTaskType.preSow:
      return 'voorzaaiseizoen';
  }
}

/// Afteltekst wanneer er (voorlopig) geen actie meer nodig is — kort met reden.
String? nextMoestuinActionCountdown({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final crop = cropShortName(vegetable.nameNl);

  if (profile != null && awaitingFirstPhotoScan(profile)) {
    return 'Eerste foto: nu';
  }

  int? scanDays;
  final due = profile?.nextScanDue;
  if (due != null) {
    final d = DateTime(due.year, due.month, due.day).difference(today).inDays;
    if (d > 0) scanDays = d;
  }

  final status = gardenStatusFor(vegetable.id, ref);
  final calendarDays = status != null &&
          !status.isActiveNow &&
          status.daysUntil > 0
      ? status.daysUntil
      : null;

  if (scanDays == null && calendarDays == null) return null;

  if (scanDays != null &&
      (calendarDays == null || scanDays <= calendarDays)) {
    if (scanDays == 1) return 'Nieuwe scan over 1 dag';
    return 'Nieuwe scan over $scanDays dagen';
  }

  final days = status!.daysUntil;
  final season = _seasonLabelForTask(status.activity.type);
  if (days == 1) return '$crop $season over 1 dag';
  return '$crop $season over $days dagen';
}
