import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'garden_plant_schedule.dart';
import 'plant_age_warnings.dart';
import 'planting_calendar.dart';

/// Beoordeling plantdatum t.o.v. de moestijnkalender (NL/BE).
class PlantingTimingAssessment {
  const PlantingTimingAssessment({
    required this.status,
    this.warningLines = const [],
    this.infoLines = const [],
    this.plantWindowLabel,
    this.harvestWindowLabel,
    this.alternativeLabel,
    this.positiveLines = const [],
  });

  final PlantingTimingStatus status;
  final List<String> warningLines;
  final List<String> infoLines;
  final String? plantWindowLabel;
  final String? harvestWindowLabel;
  final String? alternativeLabel;
  final List<String> positiveLines;

  bool get hasWarnings => warningLines.isNotEmpty;
  bool get hasPositive => positiveLines.isNotEmpty;
  bool get showOnInfoTab =>
      hasWarnings ||
      hasPositive ||
      infoLines.isNotEmpty ||
      plantWindowLabel != null;
}

/// Scan zegt dat oogst dit seizoen nog kan — geen seizoenswaarschuwing-icoon.
bool aiReassuresHarvestThisSeason(GardenPlantProfile? profile) {
  if (profile == null || profile.lastAnalysis == null) return false;
  final ai = profile.lastAnalysis!;
  if (ai.hasCropMismatch) return false;
  return ai.harvestStillPossibleThisSeason == true;
}

List<String> harvestReassuranceLines(GardenPlantProfile profile) {
  final ai = profile.lastAnalysis!;
  final lines = <String>[];
  final note = ai.seasonTimingWarning?.trim();
  if (note != null && note.isNotEmpty) {
    lines.add(note);
  } else {
    lines.add(
      'Volgens je laatste scan lijkt oogst dit seizoen nog haalbaar.',
    );
  }
  if (ai.harvestWindowLabel.trim().isNotEmpty) {
    lines.add('Geschat venster: ${ai.harvestWindowLabel}');
  }
  return lines;
}

enum PlantingTimingStatus {
  onTime,
  slightlyLate,
  tooLate,
  beforeSeason,
  noCalendar,
  unknownDate,
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

bool _isPlantingType(GardenTaskType type) {
  return type == GardenTaskType.preSow ||
      type == GardenTaskType.sowOutdoors ||
      type == GardenTaskType.plantOutdoors;
}

DateTime _periodEnd(int year, int month) =>
    DateTime(year, month, daysInMonth(year, month));

DateTime _periodStart(int year, VegetableMonthActivity activity, int month) {
  final day = activityCalendarDay(activity).clamp(1, daysInMonth(year, month));
  return DateTime(year, month, day);
}

String _monthName(int month) => kMonthNamesNl[month];

String _formatMonthRange(Set<int> months) {
  if (months.isEmpty) return '—';
  final sorted = months.toList()..sort();
  final parts = <String>[];
  var start = sorted.first;
  var prev = sorted.first;

  void flush(int end) {
    if (start == end) {
      parts.add(_monthName(start));
    } else {
      parts.add('${_monthName(start)}–${_monthName(end)}');
    }
  }

  for (var i = 1; i < sorted.length; i++) {
    final m = sorted[i];
    if (m == prev + 1) {
      prev = m;
    } else {
      flush(prev);
      start = m;
      prev = m;
    }
  }
  flush(prev);
  return parts.join(', ');
}

Set<int> _monthsForType(String vegetableId, GardenTaskType type) {
  final months = <int>{};
  for (final a in kPlantingCalendar) {
    if (a.vegetableId != vegetableId || a.type != type) continue;
    months.addAll(a.months);
  }
  return months;
}

Set<int> _allPlantingMonths(String vegetableId) {
  final months = <int>{};
  for (final a in kPlantingCalendar) {
    if (a.vegetableId != vegetableId) continue;
    if (!_isPlantingType(a.type)) continue;
    months.addAll(a.months);
  }
  return months;
}

Set<int> _allHarvestMonths(String vegetableId) {
  return _monthsForType(vegetableId, GardenTaskType.harvest);
}

bool _isDateInPlantingWindow(DateTime date, String vegetableId) {
  final d = _dateOnly(date);
  for (final a in kPlantingCalendar) {
    if (a.vegetableId != vegetableId) continue;
    if (!_isPlantingType(a.type)) continue;
    for (final month in a.months) {
      for (final year in [d.year - 1, d.year, d.year + 1]) {
        final start = _periodStart(year, a, month);
        final end = _periodEnd(year, month);
        if (!d.isBefore(start) && !d.isAfter(end)) return true;
      }
    }
  }
  return false;
}

DateTime? _nextPlantingStartAfter(DateTime date, String vegetableId) {
  final d = _dateOnly(date);
  DateTime? best;
  for (final a in kPlantingCalendar) {
    if (a.vegetableId != vegetableId) continue;
    if (!_isPlantingType(a.type)) continue;
    for (final month in a.months) {
      for (final year in [d.year, d.year + 1]) {
        final start = _periodStart(year, a, month);
        if (!start.isAfter(d)) continue;
        if (best == null || start.isBefore(best)) best = start;
      }
    }
  }
  return best;
}

DateTime? _lastPlantingEndBefore(DateTime date, String vegetableId) {
  final d = _dateOnly(date);
  DateTime? best;
  for (final a in kPlantingCalendar) {
    if (a.vegetableId != vegetableId) continue;
    if (!_isPlantingType(a.type)) continue;
    for (final month in a.months) {
      for (final year in [d.year - 1, d.year, d.year + 1]) {
        final end = _periodEnd(year, month);
        if (end.isBefore(d) && (best == null || end.isAfter(best))) {
          best = end;
        }
      }
    }
  }
  return best;
}

DateTime? _lastPlantingEndBeforeInYear(DateTime date, String vegetableId) {
  final d = _dateOnly(date);
  DateTime? best;
  for (final a in kPlantingCalendar) {
    if (a.vegetableId != vegetableId) continue;
    if (!_isPlantingType(a.type)) continue;
    for (final month in a.months) {
      final end = _periodEnd(d.year, month);
      if (end.isBefore(d) && (best == null || end.isAfter(best))) {
        best = end;
      }
    }
  }
  return best;
}

bool isTropicalOrIndoorCrop(String vegetableId) {
  const ids = {
    'mango',
    'avocado',
    'shiitake',
    'oesterzwam',
    'kastanjechampignon',
  };
  return ids.contains(vegetableId);
}

String? _alternativeAdvice({
  required Vegetable vegetable,
  required GardenLocation location,
  required DateTime referenceDate,
  String? nextWindowLabel,
}) {
  final inProtected = location == GardenLocation.greenhouse ||
      location == GardenLocation.windowsill;

  if (isTropicalOrIndoorCrop(vegetable.id)) {
    if (inProtected) {
      return 'Houd ${vegetable.nameNl} binnen of in kas op min. 18–22 °C met veel licht. '
          'Buiten in ons klimaat is oogst meestal niet haalbaar.';
    }
    return 'Zet de plant binnen of in een verwarmde kas (min. 18–22 °C, veel licht). '
        'Alleen dan is kans op groei of vruchtvorming realistisch.';
  }

  if (inProtected) {
    return 'In kas of op een lichte vensterbank (min. ca. 12–16 °C ’s nachts, '
        'overdag zoveel mogelijk licht) kan uitloop of vruchtzetting soms nog lukken, '
        'maar verwacht een korter seizoen dan bij planten op tijd.';
  }

  final next = nextWindowLabel ?? 'het volgende plantmoment in de kalender';
  return 'Buiten is de kans op een normale oogst nu klein. Alternatief: voorzaaien of '
      'uitplanten in kas of op vensterbank (warm en licht), of wacht tot $next.';
}

/// Kalenderlabels voor AI-prompt en UI.
({String? plant, String? harvest}) calendarLabelsFor(String vegetableId) {
  final plantMonths = _allPlantingMonths(vegetableId);
  final harvestMonths = _allHarvestMonths(vegetableId);
  return (
    plant: plantMonths.isEmpty
        ? null
        : 'Zaaien / planten: ${_formatMonthRange(plantMonths)}',
    harvest: harvestMonths.isEmpty
        ? null
        : 'Oogsten: ${_formatMonthRange(harvestMonths)}',
  );
}

List<String> _aiSeasonSupplementLines(GardenPlantProfile profile) {
  final ai = profile.lastAnalysis;
  if (ai == null) {
    return const [
      'Tip: maak een plantscan — aan de hand van de grootte op de foto '
          'schattent we of oogst dit seizoen nog haalbaar is.',
    ];
  }

  final lines = <String>[];
  if (ai.seasonTimingWarning != null && ai.seasonTimingWarning!.isNotEmpty) {
    lines.add(ai.seasonTimingWarning!);
  }

  final possible = ai.harvestStillPossibleThisSeason;
  if (possible == true) {
    return const [];
  } else if (possible == false) {
    lines.add(
      'Scan: voor deze grootte en het seizoen is normale oogst onwaarschijnlijk — '
      'mogelijk laat bloeier of weinig/geen vruchten.',
    );
  }

  return lines;
}

/// Weergave op detailscherm en in meldingen (inclusief AI na scan).
PlantingTimingAssessment seasonDisplayFor({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  DateTime? reference,
}) {
  final base = assessPlantingTiming(
    vegetable: vegetable,
    profile: profile,
    reference: reference,
  );

  if (profile.plantingDateUnknown) {
    final photoInfo = photoAgeInfoForUnknownDate(profile);
    if (photoInfo.isEmpty) return base;
    return PlantingTimingAssessment(
      status: base.status,
      warningLines: base.warningLines,
      infoLines: [...base.infoLines, ...photoInfo],
      plantWindowLabel: base.plantWindowLabel,
      harvestWindowLabel: base.harvestWindowLabel,
    );
  }

  if (!profile.isPlanted) return base;

  if (aiReassuresHarvestThisSeason(profile)) {
    return PlantingTimingAssessment(
      status: PlantingTimingStatus.onTime,
      warningLines: const [],
      infoLines: [
        if (base.plantWindowLabel != null) base.plantWindowLabel!,
        if (base.harvestWindowLabel != null) base.harvestWindowLabel!,
      ],
      positiveLines: harvestReassuranceLines(profile),
      plantWindowLabel: base.plantWindowLabel,
      harvestWindowLabel: base.harvestWindowLabel,
    );
  }

  final dateWarn = datePhotoWarningsFor(profile);
  final seasonExtra = _aiSeasonSupplementLines(profile);
  final warnings = [...base.warningLines, ...dateWarn, ...seasonExtra];

  if (warnings.isEmpty && !base.hasWarnings) return base;

  return PlantingTimingAssessment(
    status: base.status,
    warningLines: warnings,
    infoLines: base.infoLines,
    plantWindowLabel: base.plantWindowLabel,
    harvestWindowLabel: base.harvestWindowLabel,
    alternativeLabel: base.alternativeLabel,
  );
}

PlantingTimingAssessment assessPlantingTiming({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  DateTime? reference,
}) {
  final labels = calendarLabelsFor(vegetable.id);
  final plantLabel = labels.plant;
  final harvestLabel = labels.harvest;

  if (profile.plantingDateUnknown) {
    return PlantingTimingAssessment(
      status: PlantingTimingStatus.unknownDate,
      infoLines: [
        'Zaaidatum onbekend — we beoordelen groei vooral via je plantscans.',
        profilePlantedDateLabel(profile),
        ...photoAgeInfoForUnknownDate(profile),
        if (plantLabel != null) 'Richtlijn $plantLabel',
        if (harvestLabel != null) 'Richtlijn $harvestLabel',
      ],
      plantWindowLabel: plantLabel,
      harvestWindowLabel: harvestLabel,
    );
  }

  final plantMonths = _allPlantingMonths(vegetable.id);
  final harvestMonths = _allHarvestMonths(vegetable.id);

  if (plantMonths.isEmpty) {
    return PlantingTimingAssessment(
      status: PlantingTimingStatus.noCalendar,
      infoLines: [
        'Geen kalenderdata voor dit gewas — gebruik de teeltteksten als richtlijn.',
        if (vegetable.sowingOutdoors.isNotEmpty)
          'Zaaien buiten: ${vegetable.sowingOutdoors}',
        if (vegetable.harvest.isNotEmpty) 'Oogst: ${vegetable.harvest}',
      ],
      plantWindowLabel: plantLabel,
      harvestWindowLabel: harvestLabel,
    );
  }

  final ref = _dateOnly(reference ?? profile.plantedAt);
  final inWindow = _isDateInPlantingWindow(ref, vegetable.id);

  if (inWindow) {
    return PlantingTimingAssessment(
      status: PlantingTimingStatus.onTime,
      infoLines: [
        'Je plantdatum (${ref.day}-${ref.month}-${ref.year}) valt binnen een '
            'geschikt plantmoment voor ${vegetable.nameNl}.',
      ],
      plantWindowLabel: plantLabel,
      harvestWindowLabel: harvestLabel,
    );
  }

  final lastEnd = _lastPlantingEndBefore(ref, vegetable.id);
  final lastEndThisYear = _lastPlantingEndBeforeInYear(ref, vegetable.id);
  final nextStart = _nextPlantingStartAfter(ref, vegetable.id);
  final nextLabel = nextStart != null
      ? '${nextStart.day}-${nextStart.month}-${nextStart.year}'
      : null;

  final daysAfterWindow = lastEnd != null ? ref.difference(lastEnd).inDays : 0;

  if (lastEndThisYear == null && nextStart != null && nextStart.isAfter(ref)) {
    return PlantingTimingAssessment(
      status: PlantingTimingStatus.beforeSeason,
      warningLines: [
        'Je bent (${ref.day}-${ref.month}) nog vóór het eerste plantseizoen van '
            '${vegetable.nameNl} in de kalender.',
        if (nextLabel != null) 'Eerste geschikte periode vanaf: $nextLabel.',
      ],
      plantWindowLabel: plantLabel,
      harvestWindowLabel: harvestLabel,
      alternativeLabel: _alternativeAdvice(
        vegetable: vegetable,
        location: profile.location,
        referenceDate: ref,
        nextWindowLabel: plantLabel,
      ),
    );
  }

  final isOutdoor = profile.location == GardenLocation.outdoor ||
      profile.location == GardenLocation.balcony;
  final tooLate = daysAfterWindow > 21;
  final slightlyLate = daysAfterWindow > 0 && daysAfterWindow <= 21;

  final warnings = <String>[];
  if (tooLate) {
    warnings.add(
      isOutdoor
          ? 'Grote kans op geen of zeer beperkte oogst buiten: je bent te laat met '
              'planten/zaaien (${ref.day}-${ref.month}) voor dit seizoen.'
          : 'Je plantdatum valt buiten het kalenderseizoen; oogst kan uitblijven of '
              'sterk verminderd zijn.',
    );
  } else if (slightlyLate) {
    warnings.add(
      'Je zit net na het plantseizoen — verminderde kans op oogst, vooral buiten.',
    );
  }

  if (plantLabel != null) {
    warnings.add('Juiste plantperiode: $plantLabel.');
  }
  if (harvestLabel != null) {
    warnings.add('Verwachte oogstperiode: $harvestLabel.');
  }

  return PlantingTimingAssessment(
    status: tooLate
        ? PlantingTimingStatus.tooLate
        : slightlyLate
            ? PlantingTimingStatus.slightlyLate
            : PlantingTimingStatus.tooLate,
    warningLines: warnings,
    plantWindowLabel: plantLabel,
    harvestWindowLabel: harvestLabel,
    alternativeLabel: _alternativeAdvice(
      vegetable: vegetable,
      location: profile.location,
      referenceDate: ref,
      nextWindowLabel: nextLabel ?? plantLabel,
    ),
  );
}
