import '../models/add_plant_wizard_models.dart';
import '../models/plant_grow_approach.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import 'planting_calendar.dart';
import 'planting_season_context.dart';
import 'planting_season_status.dart';
import 'wizard_season_plan.dart';

/// Keuze op wizard-stap 5 (seizoen).
enum WizardSeasonDecision {
  proceedNow,
  waitForSeason,
}

/// Seizoensbeoordeling na aanpak + locatie + zon.
class WizardSeasonAssessment {
  const WizardSeasonAssessment({
    required this.isIdealTiming,
    required this.showWarning,
    required this.headline,
    required this.explanation,
    required this.alternativeTip,
    this.proceedTipDaysLabel,
    required this.idealSeasonLabel,
    this.daysUntilIdealSeason,
    this.daysHighlight,
    required this.intendedTaskType,
  });

  final bool isIdealTiming;
  final bool showWarning;
  final String headline;
  final String explanation;
  final String alternativeTip;

  /// Dagen tot de actie die de gebruiker koos (bijv. buiten zaaien).
  final String? proceedTipDaysLabel;
  final String idealSeasonLabel;
  final int? daysUntilIdealSeason;

  /// Korte regel met timing, apart vet in de UI.
  final String? daysHighlight;
  final GardenTaskType intendedTaskType;
}

bool isWizardLocationColdExposed(WizardGrowLocation location) =>
    location == WizardGrowLocation.outdoor ||
    location == WizardGrowLocation.balcony;

/// Welk kalendervenster hoort bij de keuzes van de gebruiker.
GardenTaskType intendedWizardTaskType({
  required PlantGrowApproach approach,
  required WizardGrowLocation location,
}) {
  if (approach == PlantGrowApproach.seed) {
    if (!isWizardLocationColdExposed(location)) {
      return GardenTaskType.preSow;
    }
    return GardenTaskType.sowOutdoors;
  }
  return GardenTaskType.plantOutdoors;
}

PlantStartMethod plantStartMethodForWizard({
  required PlantGrowApproach approach,
  required WizardGrowLocation location,
  required List<PlantStartMethod> available,
}) {
  if (approach == PlantGrowApproach.seed) {
    if (!isWizardLocationColdExposed(location) &&
        available.contains(PlantStartMethod.preSowIndoors)) {
      return PlantStartMethod.preSowIndoors;
    }
    if (available.contains(PlantStartMethod.sowOutdoors)) {
      return PlantStartMethod.sowOutdoors;
    }
    return available.contains(PlantStartMethod.preSowIndoors)
        ? PlantStartMethod.preSowIndoors
        : PlantStartMethod.sowOutdoors;
  }
  return available.contains(PlantStartMethod.plantOutdoors)
      ? PlantStartMethod.plantOutdoors
      : PlantStartMethod.plantOutdoors;
}

String _taskTypeLabel(GardenTaskType type) => switch (type) {
      GardenTaskType.preSow => 'voorzaai-seizoen (binnen)',
      GardenTaskType.sowOutdoors => 'buiten zaai-seizoen',
      GardenTaskType.plantOutdoors => 'buiten plant-seizoen',
      GardenTaskType.harvest => 'oogstseizoen',
    };

String _actionLabel(PlantGrowApproach approach, WizardGrowLocation location) {
  if (approach == PlantGrowApproach.seed) {
    return isWizardLocationColdExposed(location) ? 'buiten zaaien' : 'voorzaaien';
  }
  return approach == PlantGrowApproach.seedling ? 'zaailing planten' : 'planten';
}

String _outdoorSeasonStatePhrase(PlantingSeasonPhase phase) {
  return switch (phase) {
    PlantingSeasonPhase.seasonEnded => 'is al afgelopen',
    PlantingSeasonPhase.startsSoon => 'is nog niet begonnen',
    _ => 'is nog niet begonnen',
  };
}

String? _daysHighlightLabel(int? days, PlantingSeasonPhase phase) {
  if (days == null) return null;
  if (phase == PlantingSeasonPhase.seasonEnded) {
    if (days == 0) return 'Volgend seizoen kan nu beginnen';
    if (days == 1) return 'Volgend seizoen begint over 1 dag';
    return 'Volgend seizoen begint over $days dagen';
  }
  if (days == 0) return 'Het seizoen kan nu beginnen';
  if (days == 1) return 'Het seizoen begint over 1 dag';
  return 'Het seizoen begint over $days dagen';
}

PlantingSeasonPhase _daysLabelPhase(
  PlantingSeasonPhase statusPhase,
  int? daysUntil,
) {
  if (daysUntil == null) return statusPhase;
  if (statusPhase == PlantingSeasonPhase.noCalendar ||
      statusPhase == PlantingSeasonPhase.seasonEnded) {
    return PlantingSeasonPhase.seasonEnded;
  }
  return statusPhase;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

int? _daysUntilIdealSeason(
  Vegetable vegetable,
  GardenTaskType taskType, {
  DateTime? reference,
}) {
  final today = _dateOnly(reference ?? DateTime.now());
  final status = plantingSeasonStatusForTask(
    vegetable,
    taskType,
    reference: reference,
  );

  switch (status.phase) {
    case PlantingSeasonPhase.startsSoon:
      return status.days;
    case PlantingSeasonPhase.activeNow:
    case PlantingSeasonPhase.daysLeft:
      return 0;
    case PlantingSeasonPhase.seasonEnded:
    case PlantingSeasonPhase.noCalendar:
      break;
  }

  final upcoming = plantingWindowRangesFor(
    vegetable.id,
    yearFrom: today.year - 1,
    yearTo: today.year + 2,
    types: {taskType},
    vegetable: vegetable,
  ).where((w) => w.start.isAfter(today)).toList()
    ..sort((a, b) => a.start.compareTo(b.start));

  if (upcoming.isNotEmpty) {
    return upcoming.first.start.difference(today).inDays;
  }

  final initialDays = daysUntilNextInitialPlantSeason(
    vegetable.id,
    reference: reference,
    vegetable: vegetable,
  );
  if (initialDays != null) return initialDays;

  return daysUntilNextPlantingSeason(
    vegetable.id,
    reference: reference,
    vegetable: vegetable,
  );
}

String? _daysUntilActionLabel(int? days, String prefix) {
  if (days == null) return null;
  if (days == 0) return '$prefix nu';
  if (days == 1) return '$prefix over 1 dag';
  return '$prefix over $days dagen';
}

String _proceedTipDaysPrefix(
  PlantGrowApproach approach,
  WizardGrowLocation location,
) {
  if (approach == PlantGrowApproach.seed &&
      isWizardLocationColdExposed(location)) {
    return 'Buiten zaaien kan';
  }
  if (approach == PlantGrowApproach.seedling) {
    return 'Buiten planten van je zaailing kan';
  }
  return 'Buiten planten kan';
}

WizardSeasonAssessment buildWizardSeasonAssessment({
  required Vegetable vegetable,
  required PlantGrowApproach approach,
  required WizardGrowLocation location,
  DateTime? reference,
}) {
  final intended = intendedWizardTaskType(
    approach: approach,
    location: location,
  );
  final status = plantingSeasonStatusForTask(
    vegetable,
    intended,
    reference: reference,
  );
  final ideal = isPlantingSeasonPhaseOpen(status.phase);
  final cold = isWizardLocationColdExposed(location);
  final action = _actionLabel(approach, location);
  final seasonLabel = _taskTypeLabel(intended);
  final name = vegetable.nameNl;
  final daysUntil = _daysUntilIdealSeason(vegetable, intended, reference: reference);
  final daysHighlight = _daysHighlightLabel(
    daysUntil,
    _daysLabelPhase(status.phase, daysUntil),
  );
  final seasonState = _outdoorSeasonStatePhrase(status.phase);

  if (ideal) {
    final left = status.phase == PlantingSeasonPhase.daysLeft ? status.days : null;
    final leftLine = left != null && left > 0
        ? (left == 1
            ? ' Het venster sluit over 1 dag.'
            : ' Het venster sluit over $left dagen.')
        : '';
    return WizardSeasonAssessment(
      isIdealTiming: true,
      showWarning: false,
      headline: 'Goed moment om te starten',
      explanation:
          'Voor $name past jouw keuze ($action) bij het huidige $seasonLabel.$leftLine',
      alternativeTip: 'Je kunt de plant direct toevoegen en aan de slag.',
      idealSeasonLabel: seasonLabel,
      daysUntilIdealSeason: null,
      intendedTaskType: intended,
    );
  }

  if (!cold) {
    return WizardSeasonAssessment(
      isIdealTiming: true,
      showWarning: false,
      headline: 'Binnen of in de kas is dat prima',
      explanation:
          'Het $seasonLabel loopt buiten nog niet of is voorbij, maar jij start '
          '${approach == PlantGrowApproach.seed ? 'binnen' : 'beschut'}. '
          'Kou buiten is dan geen probleem voor je start.',
      alternativeTip:
          'Later kun je alsnog buiten planten wanneer het buiten-plantseizoen begint.',
      idealSeasonLabel: seasonLabel,
      daysUntilIdealSeason: daysUntil,
      daysHighlight: daysHighlight,
      intendedTaskType: intended,
    );
  }

  String explanation;
  String alternative;
  String? proceedTipDaysLabel;

  final proceedDaysPrefix = _proceedTipDaysPrefix(approach, location);

  if (approach == PlantGrowApproach.seed) {
    if (isPreSowSeasonActive(vegetable, reference: reference) &&
        intended == GardenTaskType.sowOutdoors) {
      final daysUntilOutdoorSow = _daysUntilIdealSeason(
        vegetable,
        GardenTaskType.sowOutdoors,
        reference: reference,
      );
      proceedTipDaysLabel =
          _daysUntilActionLabel(daysUntilOutdoorSow, proceedDaysPrefix);
      explanation =
          'Het is nu voorzaai-seizoen binnen voor $name, maar je wilt buiten zaaien. '
          'Buiten is de kans op goede kieming nu kleiner door kou, natte grond en nachtvorst.';
      alternative =
          'Start nu binnen met voorzaaien op de vensterbank of in de kas. '
          'Zo krijgt je plant een warme start tot het buiten zaai-seizoen begint.';
    } else {
      proceedTipDaysLabel =
          _daysUntilActionLabel(daysUntil, proceedDaysPrefix);
      explanation =
          'Je wilt $action voor $name, maar het $seasonLabel $seasonState. '
          'Buiten starten heeft een lagere slagingskans.';
      alternative =
          'Start beschut binnen of in de kas als je toch wilt beginnen, '
          'of wacht tot het $seasonLabel weer open is.';
    }
  } else {
    if (isPreSowSeasonActive(vegetable, reference: reference)) {
      final daysUntilOutdoorPlant = _daysUntilIdealSeason(
        vegetable,
        GardenTaskType.plantOutdoors,
        reference: reference,
      );
      proceedTipDaysLabel =
          _daysUntilActionLabel(daysUntilOutdoorPlant, proceedDaysPrefix);
      explanation =
          'Het is voorzaai-tijd voor $name, maar het buiten-plantseizoen $seasonState. '
          'Een ${approach == PlantGrowApproach.seedling ? 'zaailing' : 'volwassen plant'} '
          'nu buiten zetten kan te vroeg zijn door kou.';
      alternative =
          'Zet de plant eerst binnen of in de kas. Zo blijft ze beschut '
          'tot het buiten-plantseizoen begint.';
    } else {
      proceedTipDaysLabel =
          _daysUntilActionLabel(daysUntil, proceedDaysPrefix);
      explanation =
          'Je wilt $action buiten, maar het $seasonLabel $seasonState. '
          'De plant kan stress krijgen of niet goed aanslaan.';
      alternative =
          'Start beschut binnen of in de kas als je toch wilt beginnen, '
          'of wacht tot het $seasonLabel weer open is.';
    }
  }

  return WizardSeasonAssessment(
    isIdealTiming: false,
    showWarning: true,
    headline: 'Niet het juiste seizoen',
    explanation: explanation,
    alternativeTip: alternative,
    proceedTipDaysLabel: proceedTipDaysLabel,
    idealSeasonLabel: seasonLabel,
    daysUntilIdealSeason: daysUntil,
    daysHighlight: daysHighlight,
    intendedTaskType: intended,
  );
}

WizardSeasonPlan seasonPlanForWizardWait({
  required Vegetable vegetable,
  required PlantGrowApproach approach,
}) {
  return buildWizardSeasonPlan(
    vegetable: vegetable,
    approach: approach,
    waitsForSeason: true,
  );
}
