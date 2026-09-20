import '../models/vegetable.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';
import 'planting_timing_advice.dart';

enum PlantingSeasonPhase {
  /// Nu in zaai-/plantvenster.
  activeNow,

  /// Nog X dagen in het huidige venster.
  daysLeft,

  /// Eerstvolgend venster begint over X dagen.
  startsSoon,

  /// Geen venster meer dit seizoen (tot volgend jaar).
  seasonEnded,

  /// Geen kalenderdata voor zaai/plant.
  noCalendar,
}

/// Zaai-/plantstatus voor de zoek-atlas.
class PlantingSeasonStatus {
  const PlantingSeasonStatus({
    required this.phase,
    required this.label,
    this.days,
    this.taskType,
  });

  final PlantingSeasonPhase phase;
  final String label;
  final int? days;
  final GardenTaskType? taskType;

  bool get isSeasonEnded => phase == PlantingSeasonPhase.seasonEnded;

  /// Korte regel op Zoeken (werkwoord = type eerstvolgend venster).
  String get searchListLabel {
    final verb = taskType != null ? _verbForType(taskType!) : 'zaaien';
    switch (phase) {
      case PlantingSeasonPhase.activeNow:
        return 'Nu $verb';
      case PlantingSeasonPhase.daysLeft:
        final d = days ?? 0;
        return d == 1 ? 'Nog 1 dag te $verb' : 'Nog $d dagen te $verb';
      case PlantingSeasonPhase.startsSoon:
        final d = days ?? 0;
        return d == 1 ? 'Over 1 dag te $verb' : 'Over $d dagen te $verb';
      case PlantingSeasonPhase.seasonEnded:
        return 'Seizoen voorbij';
      case PlantingSeasonPhase.noCalendar:
        return '';
    }
  }
}

const _plantingTypes = [
  GardenTaskType.preSow,
  GardenTaskType.sowOutdoors,
  GardenTaskType.plantOutdoors,
];

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _periodStart(int year, VegetableMonthActivity activity, int month) {
  final day = activityCalendarDay(activity).clamp(1, daysInMonth(year, month));
  return DateTime(year, month, day);
}

DateTime _periodEnd(int year, int month) =>
    DateTime(year, month, daysInMonth(year, month));

class _PlantWindow {
  const _PlantWindow({
    required this.start,
    required this.end,
    required this.type,
  });

  final DateTime start;
  final DateTime end;
  final GardenTaskType type;
}

/// Groepeert opeenvolgende maanden (bijv. [5,6,7] → één venster, niet drie losse).
List<List<int>> _consecutiveMonthGroups(List<int> months) {
  final sorted = months.toList()..sort();
  if (sorted.isEmpty) return const [];

  final groups = <List<int>>[];
  var current = <int>[sorted.first];

  for (var i = 1; i < sorted.length; i++) {
    if (sorted[i] == sorted[i - 1] + 1) {
      current.add(sorted[i]);
    } else {
      groups.add(current);
      current = <int>[sorted[i]];
    }
  }
  groups.add(current);
  return groups;
}

List<_PlantWindow> _plantingWindowsForYears(
  String vegetableId,
  int yearFrom,
  int yearTo, {
  Vegetable? vegetable,
}) {
  final windows = <_PlantWindow>[];
  final activities = plantingActivitiesForVegetable(
    vegetableId,
    vegetable: vegetable,
  );

  for (final a in activities) {
    if (!_plantingTypes.contains(a.type)) continue;

    for (var y = yearFrom; y <= yearTo; y++) {
      for (final group in _consecutiveMonthGroups(a.months)) {
        final firstMonth = group.first;
        final lastMonth = group.last;
        windows.add(
          _PlantWindow(
            start: _periodStart(y, a, firstMonth),
            end: _periodEnd(y, lastMonth),
            type: a.type,
          ),
        );
      }
    }
  }

  windows.sort((a, b) => a.start.compareTo(b.start));
  return windows;
}

DateTime? _lastPlantingEndInYear(
  String vegetableId,
  int year, {
  Vegetable? vegetable,
}) {
  DateTime? best;
  for (final w in _plantingWindowsForYears(
    vegetableId,
    year,
    year,
    vegetable: vegetable,
  )) {
    if (best == null || w.end.isAfter(best)) best = w.end;
  }
  return best;
}

bool _isBetweenYearSeasons({
  required DateTime today,
  required String vegetableId,
  required DateTime nextStart,
  Vegetable? vegetable,
}) {
  if (nextStart.year <= today.year) return false;
  final lastEnd = _lastPlantingEndInYear(
    vegetableId,
    today.year,
    vegetable: vegetable,
  );
  if (lastEnd == null) return false;
  return !today.isBefore(lastEnd);
}

String _verbForType(GardenTaskType type) {
  switch (type) {
    case GardenTaskType.preSow:
      return 'voorzaaien';
    case GardenTaskType.sowOutdoors:
      return 'zaaien';
    case GardenTaskType.plantOutdoors:
      return 'planten';
    case GardenTaskType.harvest:
      return 'oogsten';
  }
}

int _typePriority(GardenTaskType type) {
  switch (type) {
    case GardenTaskType.plantOutdoors:
      return 0;
    case GardenTaskType.sowOutdoors:
      return 1;
    case GardenTaskType.preSow:
      return 2;
    case GardenTaskType.harvest:
      return 3;
  }
}

int? _daysUntilNextPlantingWindow(
  List<_PlantWindow> windows,
  DateTime today,
) {
  if (windows.isEmpty) return null;

  for (final w in windows) {
    if (!today.isBefore(w.start) && !today.isAfter(w.end)) {
      return 0;
    }
  }

  _PlantWindow? nextWindow;
  for (final w in windows) {
    if (!w.start.isAfter(today)) continue;
    if (nextWindow == null || w.start.isBefore(nextWindow.start)) {
      nextWindow = w;
    }
  }
  if (nextWindow == null) return null;
  return nextWindow.start.difference(today).inDays;
}

/// Dagen tot het eerstvolgende zaai-/plantvenster (0 = venster is nu open).
int? daysUntilNextPlantingSeason(
  String vegetableId, {
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  final windows = _plantingWindowsForYears(
    vegetableId,
    today.year - 1,
    today.year + 1,
    vegetable: vegetable,
  );
  return _daysUntilNextPlantingWindow(windows, today);
}

/// Dagen tot voorzaaien/buiten zaaien — niet buiten planten (transplant).
int? daysUntilNextInitialPlantSeason(
  String vegetableId, {
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  const initialTypes = {
    GardenTaskType.preSow,
    GardenTaskType.sowOutdoors,
  };
  final windows = _plantingWindowsForYears(
    vegetableId,
    today.year - 1,
    today.year + 1,
    vegetable: vegetable,
  ).where((w) => initialTypes.contains(w.type)).toList();
  return _daysUntilNextPlantingWindow(windows, today);
}

/// Zaai-/voorzaai-status voor nog niet gestarte moestuinplanten (stap 1).
PlantingSeasonStatus plantingSeasonStatusForSowStart(
  String vegetableId, {
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  return _statusForTypes(
    vegetableId,
    today,
    const {GardenTaskType.preSow, GardenTaskType.sowOutdoors},
    vegetable: vegetable,
  );
}

/// Resterende dagen in het huidige voorzaai-/buiten-zaai-venster.
int? plantingSowSeasonDaysLeftInWindow(
  String vegetableId, {
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final status = plantingSeasonStatusForSowStart(
    vegetableId,
    reference: reference,
    vegetable: vegetable,
  );
  return switch (status.phase) {
    PlantingSeasonPhase.daysLeft => status.days,
    PlantingSeasonPhase.activeNow => 0,
    _ => null,
  };
}

/// Resterende dagen in het huidige zaai-/plantvenster (`null` = niet in venster).
int? plantingSeasonDaysLeftInWindow(
  String vegetableId, {
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final status = plantingSeasonStatusFor(
    vegetableId,
    reference: reference,
    vegetable: vegetable,
  );
  return switch (status.phase) {
    PlantingSeasonPhase.daysLeft => status.days,
    PlantingSeasonPhase.activeNow => 0,
    _ => null,
  };
}

/// Bepaalt zaai-/plantvenster voor de planten-atlas (zoek-tab).
PlantingSeasonStatus plantingSeasonStatusFor(
  String vegetableId, {
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final base = _plantingSeasonStatusCore(
    vegetableId,
    reference: reference,
    vegetable: vegetable,
  );
  if (vegetable == null || !isTropicalOrIndoorCrop(vegetableId)) {
    return base;
  }
  return _tropicalAtlasStatus(base);
}

PlantingSeasonStatus _plantingSeasonStatusFromWindows(
  List<_PlantWindow> windows,
  String vegetableId,
  DateTime today, {
  Vegetable? vegetable,
}) {
  if (windows.isEmpty) {
    return const PlantingSeasonStatus(
      phase: PlantingSeasonPhase.noCalendar,
      label: '',
    );
  }

  _PlantWindow? activeWindow;
  int? activeDaysLeft;

  for (final w in windows) {
    if (today.isBefore(w.start) || today.isAfter(w.end)) continue;
    final left = w.end.difference(today).inDays;
    if (activeWindow == null) {
      activeWindow = w;
      activeDaysLeft = left;
      continue;
    }
    final betterType =
        _typePriority(w.type) < _typePriority(activeWindow.type);
    final moreTime = left > (activeDaysLeft ?? -1);
    if (betterType || (w.type == activeWindow.type && moreTime)) {
      activeWindow = w;
      activeDaysLeft = left;
    }
  }

  if (activeWindow != null) {
    final type = activeWindow.type;
    final verb = _verbForType(type);
    final left = activeDaysLeft ?? 0;
    if (left <= 0) {
      return PlantingSeasonStatus(
        phase: PlantingSeasonPhase.activeNow,
        label: 'Nu $verb',
        days: 0,
        taskType: type,
      );
    }
    return PlantingSeasonStatus(
      phase: PlantingSeasonPhase.daysLeft,
      label:
          'Nog $left ${left == 1 ? 'dag' : 'dagen'} in zaaiperiode · nog te $verb',
      days: left,
      taskType: type,
    );
  }

  _PlantWindow? nextWindow;
  for (final w in windows) {
    if (!w.start.isAfter(today)) continue;
    if (nextWindow == null || w.start.isBefore(nextWindow.start)) {
      nextWindow = w;
    }
  }

  if (nextWindow != null) {
    final days = nextWindow.start.difference(today).inDays;
    if (_isBetweenYearSeasons(
      today: today,
      vegetableId: vegetableId,
      nextStart: nextWindow.start,
      vegetable: vegetable,
    )) {
      return const PlantingSeasonStatus(
        phase: PlantingSeasonPhase.seasonEnded,
        label: 'Zaaiseizoen voorbij',
      );
    }
    final verb = _verbForType(nextWindow.type);
    return PlantingSeasonStatus(
      phase: PlantingSeasonPhase.startsSoon,
      label: days == 1
          ? 'Over 1 dag te $verb'
          : 'Over $days dagen te $verb',
      days: days,
      taskType: nextWindow.type,
    );
  }

  return const PlantingSeasonStatus(
    phase: PlantingSeasonPhase.seasonEnded,
    label: 'Zaaiseizoen voorbij',
  );
}

PlantingSeasonStatus _plantingSeasonStatusCore(
  String vegetableId, {
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  final windows = _plantingWindowsForYears(
    vegetableId,
    today.year - 1,
    today.year + 1,
    vegetable: vegetable,
  );
  return _plantingSeasonStatusFromWindows(
    windows,
    vegetableId,
    today,
    vegetable: vegetable,
  );
}

PlantingSeasonStatus _statusForTypes(
  String vegetableId,
  DateTime today,
  Set<GardenTaskType> types, {
  Vegetable? vegetable,
}) {
  final windows = _plantingWindowsForYears(
    vegetableId,
    today.year - 1,
    today.year + 1,
    vegetable: vegetable,
  ).where((w) => types.contains(w.type)).toList();
  return _plantingSeasonStatusFromWindows(
    windows,
    vegetableId,
    today,
    vegetable: vegetable,
  );
}

/// Uitgebreid advies voor detailpagina (binnen/kas vs buiten).
class PlantingSeasonAdvice {
  const PlantingSeasonAdvice({
    required this.shortLabel,
    required this.detailLines,
    this.isSeasonEnded = false,
  });

  final String shortLabel;
  final List<String> detailLines;
  final bool isSeasonEnded;

  /// Regels voor accordion (zonder richtlijnen en zonder herhaling van [shortLabel]).
  List<String> get accordionLines {
    return detailLines.where((line) {
      if (line.startsWith('Richtlijn')) return false;
      if (shortLabel.isNotEmpty && line.contains(shortLabel)) return false;
      return line.trim().isNotEmpty;
    }).toList();
  }
}

bool _hasIndoorSowingOption(Vegetable vegetable) {
  final t = vegetable.sowingIndoors.trim().toLowerCase();
  if (t.isEmpty) return false;
  if (t.contains('niet nodig')) return false;
  if (t.contains('meestal niet')) return false;
  return true;
}

bool _calendarHasPreSow(String vegetableId, Vegetable vegetable) {
  return plantingActivitiesForVegetable(vegetableId, vegetable: vegetable)
      .any((a) => a.type == GardenTaskType.preSow);
}

String _statusSentence(PlantingSeasonStatus status, {required String context}) {
  if (status.label.isEmpty) return '';
  switch (status.phase) {
    case PlantingSeasonPhase.activeNow:
      return '$context: ${status.label}.';
    case PlantingSeasonPhase.daysLeft:
    case PlantingSeasonPhase.startsSoon:
    case PlantingSeasonPhase.seasonEnded:
      return '$context: ${status.label}.';
    case PlantingSeasonPhase.noCalendar:
      return '';
  }
}

/// Zaai-/plantadvies met onderscheid binnen/kas en buiten (NL).
PlantingSeasonAdvice plantingSeasonAdviceFor(
  Vegetable vegetable, {
  DateTime? reference,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  final id = vegetable.id;

  final short = plantingSeasonStatusFor(
    id,
    reference: reference,
    vegetable: vegetable,
  );

  if (short.phase == PlantingSeasonPhase.noCalendar) {
    return const PlantingSeasonAdvice(shortLabel: '', detailLines: []);
  }

  final indoorTypes = {GardenTaskType.preSow};
  final outdoorTypes = {GardenTaskType.sowOutdoors, GardenTaskType.plantOutdoors};

  final indoor = _statusForTypes(id, today, indoorTypes, vegetable: vegetable);
  final outdoor =
      _statusForTypes(id, today, outdoorTypes, vegetable: vegetable);

  final lines = <String>[];
  final hasPreSowCal = _calendarHasPreSow(id, vegetable);
  final hasIndoorText = _hasIndoorSowingOption(vegetable);

  final indoorActive = indoor.phase == PlantingSeasonPhase.activeNow ||
      indoor.phase == PlantingSeasonPhase.daysLeft;
  final outdoorActive = outdoor.phase == PlantingSeasonPhase.activeNow ||
      outdoor.phase == PlantingSeasonPhase.daysLeft;
  final outdoorWaiting = outdoor.phase == PlantingSeasonPhase.startsSoon;
  final outdoorEnded = outdoor.phase == PlantingSeasonPhase.seasonEnded;

  if (hasPreSowCal && indoorActive) {
    lines.add(_statusSentence(indoor, context: 'Binnen of kas'));
  } else if (hasPreSowCal &&
      indoor.phase == PlantingSeasonPhase.startsSoon) {
    lines.add(_statusSentence(indoor, context: 'Binnen of kas'));
  }

  if (outdoor.label.isNotEmpty) {
    if (outdoorActive) {
      lines.add(_statusSentence(outdoor, context: 'Buiten'));
    } else if (indoorActive && hasPreSowCal) {
      lines.add(_statusSentence(outdoor, context: 'Daarna buiten'));
    } else {
      lines.add(_statusSentence(outdoor, context: 'Buiten'));
    }
  }

  if (hasIndoorText &&
      !hasPreSowCal &&
      (outdoorWaiting || outdoorEnded) &&
      !indoorActive) {
    lines.add(
      'Binnen of kas: ${vegetable.sowingIndoors}. Buiten is het seizoen '
      '${outdoorEnded ? "voorbij" : "nog niet begonnen"}.',
    );
  }

  if (!hasPreSowCal &&
      outdoorActive &&
      vegetable.sowingOutdoors.trim().isNotEmpty) {
    lines.add('Direct buiten zaaien of planten past nu (geen aparte voorzaai in kalender).');
  }

  if (lines.isEmpty && short.label.isNotEmpty) {
    lines.add(short.label);
  }

  return PlantingSeasonAdvice(
    shortLabel: short.label,
    detailLines: lines,
    isSeasonEnded: short.isSeasonEnded,
  );
}

/// Zaai-/plantvenster voor UI (wizard, detail).
class PlantingWindowRange {
  const PlantingWindowRange({
    required this.start,
    required this.end,
    required this.type,
  });

  final DateTime start;
  final DateTime end;
  final GardenTaskType type;
}

List<PlantingWindowRange> plantingWindowRangesFor(
  String vegetableId, {
  required int yearFrom,
  required int yearTo,
  Set<GardenTaskType>? types,
  Vegetable? vegetable,
}) {
  final raw = _plantingWindowsForYears(
    vegetableId,
    yearFrom,
    yearTo,
    vegetable: vegetable,
  );
  final filtered =
      types == null ? raw : raw.where((w) => types.contains(w.type));
  return [
    for (final w in filtered)
      PlantingWindowRange(start: w.start, end: w.end, type: w.type),
  ];
}

PlantingSeasonStatus plantingSeasonStatusForTaskTypes(
  String vegetableId, {
  required Set<GardenTaskType> types,
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  return _statusForTypes(
    vegetableId,
    today,
    types,
    vegetable: vegetable,
  );
}

PlantingWindowRange? nextRelevantPlantingWindow(
  String vegetableId, {
  required Set<GardenTaskType> types,
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  final windows = plantingWindowRangesFor(
    vegetableId,
    yearFrom: today.year - 1,
    yearTo: today.year + 2,
    types: types,
    vegetable: vegetable,
  );

  for (final w in windows) {
    if (!today.isBefore(w.start) && !today.isAfter(w.end)) return w;
  }

  PlantingWindowRange? next;
  for (final w in windows) {
    if (!w.start.isAfter(today)) continue;
    if (next == null || w.start.isBefore(next.start)) next = w;
  }
  return next ?? (windows.isNotEmpty ? windows.first : null);
}

DateTime plannedSeasonStartDate(
  String vegetableId, {
  required Set<GardenTaskType> types,
  DateTime? reference,
  Vegetable? vegetable,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  final window = nextRelevantPlantingWindow(
    vegetableId,
    types: types,
    reference: today,
    vegetable: vegetable,
  );
  if (window == null) return today;
  if (!today.isBefore(window.start) && !today.isAfter(window.end)) return today;
  if (window.start.isAfter(today)) return window.start;
  return today;
}

String formatPlantingWindowNl(DateTime start, DateTime end) {
  const months = [
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
  if (start.year == end.year && start.month == end.month) {
    return '${months[start.month]} ${start.year}';
  }
  if (start.year == end.year) {
    return '${months[start.month]} – ${months[end.month]} ${start.year}';
  }
  return '${months[start.month]} ${start.year} – ${months[end.month]} ${end.year}';
}

/// Tropisch/kas-gewas: binnen kan eerder dan buiten/kas in de kalender.
PlantingSeasonStatus _tropicalAtlasStatus(PlantingSeasonStatus base) {
  switch (base.phase) {
    case PlantingSeasonPhase.startsSoon:
      if (base.taskType == GardenTaskType.plantOutdoors) {
        final d = base.days;
        if (d == null) {
          return PlantingSeasonStatus(
            phase: PlantingSeasonPhase.activeNow,
            label: 'Nu binnen starten',
            taskType: base.taskType,
          );
        }
        return PlantingSeasonStatus(
          phase: PlantingSeasonPhase.activeNow,
          label:
              'Nu binnen starten · kas/buiten over $d ${d == 1 ? 'dag' : 'dagen'}',
          days: d,
          taskType: base.taskType,
        );
      }
      return base;
    case PlantingSeasonPhase.activeNow:
      if (base.taskType == GardenTaskType.plantOutdoors) {
        return PlantingSeasonStatus(
          phase: base.phase,
          label: 'Nu kas of warm terras',
          days: base.days,
          taskType: base.taskType,
        );
      }
      if (base.taskType == GardenTaskType.preSow ||
          base.taskType == GardenTaskType.sowOutdoors) {
        return PlantingSeasonStatus(
          phase: base.phase,
          label: 'Nu binnen starten',
          days: base.days,
          taskType: base.taskType,
        );
      }
      return base;
    case PlantingSeasonPhase.daysLeft:
      if (base.taskType == GardenTaskType.plantOutdoors) {
        final left = base.days ?? 0;
        return PlantingSeasonStatus(
          phase: base.phase,
          label:
              'Nog $left ${left == 1 ? 'dag' : 'dagen'} kas/terras · binnen altijd',
          days: left,
          taskType: base.taskType,
        );
      }
      if (base.taskType == GardenTaskType.preSow) {
        final left = base.days ?? 0;
        return PlantingSeasonStatus(
          phase: base.phase,
          label:
              'Nog $left ${left == 1 ? 'dag' : 'dagen'} binnen starten',
          days: left,
          taskType: base.taskType,
        );
      }
      return base;
    case PlantingSeasonPhase.seasonEnded:
      return const PlantingSeasonStatus(
        phase: PlantingSeasonPhase.seasonEnded,
        label: 'Buiten/kas voorbij · binnen wel starten',
      );
    case PlantingSeasonPhase.noCalendar:
      return base;
  }
}
