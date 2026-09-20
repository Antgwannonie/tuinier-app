import '../models/add_plant_wizard_models.dart';
import '../models/vegetable.dart';
import 'planting_calendar.dart';
import 'planting_season_status.dart';

/// Seizoensplan voor stap 4 wanneer de gebruiker «voor het juiste seizoen» kiest.
class WizardSeasonPlan {
  const WizardSeasonPlan({
    required this.status,
    required this.advice,
    required this.startDate,
    required this.windowLabel,
    required this.sowWindowLabel,
    required this.actionLabel,
    required this.hasCalendar,
    required this.approach,
    required this.daysUntilAction,
    this.waitsForSeason = true,
  });

  final PlantingSeasonStatus status;
  final PlantingSeasonAdvice advice;
  final DateTime startDate;
  final String windowLabel;
  final String sowWindowLabel;
  final String actionLabel;
  final bool hasCalendar;
  final PlantGrowApproach approach;

  /// Dagen tot je kunt zaaien/planten (0 = nu mogelijk).
  final int? daysUntilAction;

  /// Of de plant op niet-actief komt tot het seizoen begint.
  final bool waitsForSeason;

  static const pageSubtitle =
      'Je hoeft geen datum te kiezen. Wij kijken wanneer het voor dit gewas het beste moment is en geven je dan een seintje.';

  String get _actionVerb =>
      approach == PlantGrowApproach.seed ? 'zaaien' : 'planten';

  String get friendlyStatusHeadline {
    final days = daysUntilAction;

    if (days == 0) {
      if (status.phase == PlantingSeasonPhase.daysLeft &&
          status.days != null &&
          status.days! > 0) {
        final left = status.days!;
        return left == 1
            ? 'Nog 1 dag om te $_actionVerb'
            : 'Nog $left dagen om te $_actionVerb';
      }
      return 'Je kunt nu $_actionVerb';
    }

    if (days != null && days > 0) {
      if (days == 1) return 'Morgen kun je $_actionVerb';
      return 'Over $days dagen kun je $_actionVerb';
    }

    return approach == PlantGrowApproach.seed
        ? 'Zaaiperiode volgt uit je gewas'
        : 'Plantperiode volgt uit je gewas';
  }

  String get friendlyContextLine {
    final days = daysUntilAction;

    if (days != null && days > 0) {
      if (waitsForSeason) {
        return 'Je plant komt op niet-actief in je moestuin tot het seizoen begint. '
            'Je krijgt een melding zodra je kunt starten met taken.';
      }
      return 'Je start direct met kweken. Ook buiten het aanbevolen seizoen '
          'ontvang je passend AI-advies.';
    }

    if (!hasCalendar) {
      return sowWindowLabel.isNotEmpty
          ? 'Richtlijn voor dit gewas: $sowWindowLabel.'
          : 'We gebruiken algemene zaai- en planttips voor dit gewas.';
    }
    return switch (status.phase) {
      PlantingSeasonPhase.activeNow || PlantingSeasonPhase.daysLeft =>
        'Het seizoen loopt nu. Zaai of plant binnen de periode hieronder.',
      PlantingSeasonPhase.startsSoon =>
        'Het seizoen begint binnenkort. Je kunt dan starten met zaaien of planten.',
      PlantingSeasonPhase.seasonEnded =>
        'We plannen alvast voor het volgende seizoen en houden je op de hoogte.',
      PlantingSeasonPhase.noCalendar =>
        'We gebruiken algemene zaai- en planttips voor dit gewas.',
    };
  }

  String get reminderText {
    final today = DateTime.now();
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final now = DateTime(today.year, today.month, today.day);

    if (status.phase == PlantingSeasonPhase.activeNow ||
        status.phase == PlantingSeasonPhase.daysLeft) {
      return 'Je krijgt een melding zodra er iets voor je klaarstaat in Taken.';
    }
    final days = daysUntilAction;
    if (days != null && days > 0) {
      if (waitsForSeason) {
        return 'Je plant komt op niet-actief in je moestuin. Zodra het seizoen '
            'begint krijg je een melding en worden taken actief.';
      }
      return 'Je kunt nu starten met taken. De AI helpt je met advies voor dit moment.';
    }
    if (!start.isAfter(now)) {
      return 'Je krijgt een melding zodra je kunt starten.';
    }
    return 'We verwachten rond ${_formatDateNl(start)} dat je kunt beginnen. Je hoeft zelf niets in te plannen.';
  }

  List<String> get locationTips {
    final tips = <String>[];
    for (final raw in advice.detailLines) {
      final tip = _friendlyAdviceLine(raw);
      if (tip != null && !tips.contains(tip)) tips.add(tip);
    }
    return tips.take(2).toList();
  }

  String get overviewDateLabel {
    if (!hasCalendar) {
      return sowWindowLabel.isNotEmpty
          ? 'Gepland voor $sowWindowLabel'
          : 'Gepland voor het seizoen';
    }
    if (status.phase == PlantingSeasonPhase.activeNow ||
        status.phase == PlantingSeasonPhase.daysLeft) {
      return 'Start in $windowLabel';
    }
    return 'Gepland voor $windowLabel';
  }
}

WizardSeasonPlan buildWizardSeasonPlan({
  required Vegetable vegetable,
  required PlantGrowApproach approach,
  DateTime? reference,
  bool waitsForSeason = true,
}) {
  final today = reference ?? DateTime.now();
  final taskTypes = _resolvedTaskTypes(
    vegetable: vegetable,
    approach: approach,
    reference: today,
  );
  final status = plantingSeasonStatusForTaskTypes(
    vegetable.id,
    types: taskTypes,
    reference: today,
    vegetable: vegetable,
  );
  final advice = plantingSeasonAdviceFor(vegetable, reference: today);
  final window = nextRelevantPlantingWindow(
    vegetable.id,
    types: taskTypes,
    reference: today,
    vegetable: vegetable,
  );
  final sowWindow = nextRelevantPlantingWindow(
    vegetable.id,
    types: const {
      GardenTaskType.preSow,
      GardenTaskType.sowOutdoors,
    },
    reference: today,
    vegetable: vegetable,
  );
  final startDate = plannedSeasonStartDate(
    vegetable.id,
    types: taskTypes,
    reference: today,
    vegetable: vegetable,
  );

  final windowLabel = window != null
      ? formatWizardPlantingWindow(window.start, window.end)
      : _fallbackWindowLabel(vegetable, approach);
  final sowWindowLabel = sowWindow != null
      ? formatWizardPlantingWindow(sowWindow.start, sowWindow.end)
      : _fallbackSowWindowLabel(vegetable);

  final hasSowCalendar = sowWindow != null ||
      plantingSeasonStatusForTaskTypes(
        vegetable.id,
        types: const {
          GardenTaskType.preSow,
          GardenTaskType.sowOutdoors,
        },
        reference: today,
        vegetable: vegetable,
      ).phase !=
          PlantingSeasonPhase.noCalendar;

  final daysUntilAction = _resolveDaysUntilAction(
    status: status,
    vegetable: vegetable,
    taskTypes: taskTypes,
    startDate: startDate,
    reference: today,
  );

  return WizardSeasonPlan(
    status: status,
    advice: advice,
    startDate: startDate,
    windowLabel: windowLabel,
    sowWindowLabel: sowWindowLabel,
    actionLabel: _actionLabelForApproach(approach),
    hasCalendar: status.phase != PlantingSeasonPhase.noCalendar ||
        hasSowCalendar ||
        daysUntilAction != null,
    approach: approach,
    daysUntilAction: daysUntilAction,
    waitsForSeason: waitsForSeason,
  );
}

int? _resolveDaysUntilAction({
  required PlantingSeasonStatus status,
  required Vegetable vegetable,
  required Set<GardenTaskType> taskTypes,
  required DateTime startDate,
  required DateTime reference,
}) {
  final today = DateTime(reference.year, reference.month, reference.day);

  switch (status.phase) {
    case PlantingSeasonPhase.activeNow:
    case PlantingSeasonPhase.daysLeft:
      return 0;
    case PlantingSeasonPhase.startsSoon:
      return status.days ?? _daysFromDate(startDate, today);
    case PlantingSeasonPhase.seasonEnded:
      final next = nextRelevantPlantingWindow(
        vegetable.id,
        types: taskTypes,
        reference: today,
        vegetable: vegetable,
      );
      if (next != null && next.start.isAfter(today)) {
        return next.start.difference(today).inDays;
      }
      return daysUntilNextPlantingSeason(
        vegetable.id,
        reference: today,
        vegetable: vegetable,
      );
    case PlantingSeasonPhase.noCalendar:
      final fromStart = _daysFromDate(startDate, today);
      if (fromStart != null) return fromStart;
      return daysUntilNextPlantingSeason(
        vegetable.id,
        reference: today,
        vegetable: vegetable,
      );
  }
}

int? _daysFromDate(DateTime date, DateTime today) {
  final target = DateTime(date.year, date.month, date.day);
  if (!target.isAfter(today)) return 0;
  return target.difference(today).inDays;
}

Set<GardenTaskType> _resolvedTaskTypes({
  required Vegetable vegetable,
  required PlantGrowApproach approach,
  required DateTime reference,
}) {
  final primary = _taskTypesForApproach(approach);
  final windows = plantingWindowRangesFor(
    vegetable.id,
    yearFrom: reference.year - 1,
    yearTo: reference.year + 2,
    types: primary,
    vegetable: vegetable,
  );
  if (windows.isNotEmpty) return primary;

  if (approach == PlantGrowApproach.seed) {
    return const {
      GardenTaskType.preSow,
      GardenTaskType.sowOutdoors,
    };
  }

  return const {
    GardenTaskType.preSow,
    GardenTaskType.sowOutdoors,
    GardenTaskType.plantOutdoors,
  };
}

String? _friendlyAdviceLine(String raw) {
  var line = raw.trim();
  if (line.isEmpty) return null;

  if (line.startsWith('Binnen of kas:')) {
    line = 'In huis of kas: ${line.substring(14).trim()}';
  } else if (line.startsWith('Daarna buiten:')) {
    line = 'Later buiten: ${line.substring(14).trim()}';
  } else if (line.startsWith('Buiten:')) {
    line = 'Buiten in de tuin: ${line.substring(7).trim()}';
  }

  line = line.replaceAll(' · ', '. ').replaceAll('·', ',');
  if (line.endsWith('.')) line = line.substring(0, line.length - 1);

  return _lowerFirst(line);
}

String _lowerFirst(String s) {
  if (s.isEmpty) return s;
  return s[0].toLowerCase() + s.substring(1);
}

String formatWizardPlantingWindow(DateTime start, DateTime end) {
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
    return '${months[start.month]} tot ${months[end.month]} ${start.year}';
  }
  return '${months[start.month]} ${start.year} tot ${months[end.month]} ${end.year}';
}

Set<GardenTaskType> _taskTypesForApproach(PlantGrowApproach approach) {
  return switch (approach) {
    PlantGrowApproach.seed => {
        GardenTaskType.preSow,
        GardenTaskType.sowOutdoors,
      },
    PlantGrowApproach.seedling || PlantGrowApproach.adult => {
        GardenTaskType.plantOutdoors,
      },
  };
}

String _actionLabelForApproach(PlantGrowApproach approach) {
  return switch (approach) {
    PlantGrowApproach.seed => 'Zaaien',
    PlantGrowApproach.seedling => 'Zaailing planten',
    PlantGrowApproach.adult => 'Plant uitplanten',
  };
}

String _fallbackWindowLabel(Vegetable vegetable, PlantGrowApproach approach) {
  final outdoors = vegetable.sowingOutdoors.trim();
  final indoors = vegetable.sowingIndoors.trim();
  return switch (approach) {
    PlantGrowApproach.seed when indoors.isNotEmpty => indoors,
    PlantGrowApproach.seed when outdoors.isNotEmpty => outdoors,
    PlantGrowApproach.seedling || PlantGrowApproach.adult when outdoors.isNotEmpty =>
      outdoors,
    _ => _fallbackSowWindowLabel(vegetable),
  };
}

String _fallbackSowWindowLabel(Vegetable vegetable) {
  final harvest = vegetable.harvest.trim();
  if (harvest.isNotEmpty && harvest != 'Juni–oktober; zie teeltinfo.') {
    return _harvestToSowHint(harvest);
  }
  final outdoors = vegetable.sowingOutdoors.trim();
  if (outdoors.isNotEmpty && outdoors != 'Zie kalender in de app.') {
    return outdoors;
  }
  return 'maart tot september';
}

String _harvestToSowHint(String harvest) {
  final cleaned = harvest
      .replaceAll('–', ' tot ')
      .replaceAll('-', ' tot ')
      .replaceAll('; zie teeltinfo.', '')
      .trim();
  if (cleaned.toLowerCase().startsWith('oogst')) return cleaned;
  return 'zaaien vóór oogst in $cleaned';
}

String _formatDateNl(DateTime d) {
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
  return '${d.day} ${months[d.month]} ${d.year}';
}
