import '../models/add_plant_wizard_models.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import 'planting_season_status.dart';
import 'planting_timing_advice.dart';

/// Waarschuwing + extra tips bij start buiten het aanbevolen seizoen.
class WizardOffSeasonGuidance {
  const WizardOffSeasonGuidance({
    required this.body,
    required this.extraTips,
  });

  final String body;
  final List<String> extraTips;
}

/// 4–6 concrete eerste stappen voor de wizard-overzichtspagina.
class WizardFirstSteps {
  const WizardFirstSteps({
    required this.steps,
    this.offSeason,
  });

  final List<String> steps;
  final WizardOffSeasonGuidance? offSeason;
}

WizardFirstSteps buildWizardFirstSteps({
  required Vegetable vegetable,
  required PlantAddIntent intent,
  required WizardGrowLocation location,
  required WizardSunHours sunHours,
  required PlantingTimingAssessment timing,
  required PlantingSeasonStatus season,
  PlantGrowApproach? growApproach,
  PlantStartMethod? plantStartMethod,
  PlantWizardCurrentPhase? currentPhase,
  PlantAiAnalysis? scanAnalysis,
  bool existingScanCompleted = false,
}) {
  final offSeason = _offSeasonGuidance(
    intent: intent,
    timing: timing,
    season: season,
  );

  final steps = switch (intent) {
    PlantAddIntent.alreadyHave => _existingPlantSteps(
        vegetable: vegetable,
        scan: scanAnalysis,
        scanCompleted: existingScanCompleted,
        currentPhase: currentPhase,
        sunHours: sunHours,
      ),
    PlantAddIntent.planForSeason => _planForSeasonSteps(
        vegetable: vegetable,
        location: location,
        sunHours: sunHours,
        growApproach: growApproach,
      ),
    PlantAddIntent.startNow => _startNowSteps(
        vegetable: vegetable,
        approach: growApproach ?? PlantGrowApproach.seed,
        method: plantStartMethod ?? PlantStartMethod.sowOutdoors,
        location: location,
        sunHours: sunHours,
      ),
  };

  return WizardFirstSteps(
    steps: _limitSteps(steps),
    offSeason: offSeason,
  );
}

WizardOffSeasonGuidance? _offSeasonGuidance({
  required PlantAddIntent intent,
  required PlantingTimingAssessment timing,
  required PlantingSeasonStatus season,
}) {
  if (intent != PlantAddIntent.startNow) return null;

  final offSeason = timing.status == PlantingTimingStatus.tooLate ||
      timing.status == PlantingTimingStatus.beforeSeason ||
      season.phase == PlantingSeasonPhase.seasonEnded;

  if (!offSeason) return null;

  return const WizardOffSeasonGuidance(
    body:
        'Je bent buiten het aanbevolen seizoen gestart. De plant kan langzamer '
        'groeien of minder opbrengst geven.',
    extraTips: [
      'Bescherm tegen kou of extreme hitte.',
      'Overweeg een kas of beschutte plek.',
      'Controleer de plant vaker op stress.',
      'Verwacht mogelijk een latere oogst.',
    ],
  );
}

List<String> _startNowSteps({
  required Vegetable vegetable,
  required PlantGrowApproach approach,
  required PlantStartMethod method,
  required WizardGrowLocation location,
  required WizardSunHours sunHours,
}) {
  return switch (approach) {
    PlantGrowApproach.seed => _seedSteps(
        vegetable: vegetable,
        method: method,
        location: location,
        sunHours: sunHours,
      ),
    PlantGrowApproach.seedling => _seedlingSteps(
        vegetable: vegetable,
        location: location,
        sunHours: sunHours,
      ),
    PlantGrowApproach.adult => _adultPlantSteps(
        vegetable: vegetable,
        location: location,
        sunHours: sunHours,
      ),
  };
}

bool _isIndoorSowing({
  required PlantStartMethod method,
  required WizardGrowLocation location,
}) {
  if (method == PlantStartMethod.preSowIndoors) return true;
  return location == WizardGrowLocation.indoor ||
      location == WizardGrowLocation.growLight;
}

List<String> _seedSteps({
  required Vegetable vegetable,
  required PlantStartMethod method,
  required WizardGrowLocation location,
  required WizardSunHours sunHours,
}) {
  final name = vegetable.nameNl;
  final spacing = vegetable.spacingCm;

  if (_isIndoorSowing(method: method, location: location)) {
    final steps = <String>[
      'Vul een zaaibakje of klein potje met zaaigrond voor $name.',
      'Zaai de zaden op de juiste diepte (zie verpakking of zaadbuidel).',
      'Geef voorzichtig water met een plantenspuit.',
      'Zet het bakje warm weg (${_warmSpotHint(location)}).',
      _lightStep(sunHours, indoor: true),
      'Controleer dagelijks op kieming.',
    ];
    return steps;
  }

  final steps = <String>[
    'Maak de grond los op je ${_locationLabel(location)}.',
    'Verwijder onkruid en stenen uit het zaaibed.',
    if (spacing > 0)
      'Zaai $name op ongeveer $spacing cm afstand.'
    else
      'Zaai $name op de juiste afstand volgens het zaad.',
    'Bedek de zaden met een dun laagje aarde.',
    'Geef direct water zodat de grond goed vochtig is.',
    'Houd de grond licht vochtig tot de zaden ontkiemen.',
  ];
  if (sunHours == WizardSunHours.little) {
    steps.add('Kies een plek met meer zon zodra de zaailingen opkomen.');
  }
  return steps;
}

List<String> _seedlingSteps({
  required Vegetable vegetable,
  required WizardGrowLocation location,
  required WizardSunHours sunHours,
}) {
  final name = vegetable.nameNl;
  final steps = <String>[
    'Graaf een plantgat op je ${_locationLabel(location)}.',
    'Plaats de zaailing op dezelfde diepte als in het potje.',
    'Vul aan met aarde en druk zacht aan.',
    'Geef direct water zodat de wortels goed aansluiten.',
    if (location == WizardGrowLocation.outdoor ||
        location == WizardGrowLocation.balcony)
      'Bescherm de eerste dagen tegen harde wind of felle middagzon.'
    else
      'Zet de plant op een lichte plek (${_locationLabel(location)}).',
    'Controleer op slakken en vraatschade rond $name.',
  ];
  if (sunHours == WizardSunHours.little) {
    steps.add('Let op voldoende licht; ${name} heeft zon nodig om door te groeien.');
  }
  return steps;
}

List<String> _adultPlantSteps({
  required Vegetable vegetable,
  required WizardGrowLocation location,
  required WizardSunHours sunHours,
}) {
  final name = vegetable.nameNl;
  final steps = <String>[
    'Controleer of je ${_locationLabel(location)} past bij $name (${vegetable.sunRequirement.toLowerCase()}).',
    'Graaf een ruim plantgat op de gekozen plek.',
    if (vegetable.soilAndFood.trim().isNotEmpty)
      'Meng eventueel compost of voeding door de grond.'
    else
      'Meng eventueel compost door de grond.',
    'Plaats de plant rechtop en vul aan met aarde.',
    'Geef direct een flinke scheut water.',
    'Controleer de eerste week dagelijks of $name goed aanslaat.',
  ];
  if (sunHours == WizardSunHours.little &&
      vegetable.sunRequirement.toLowerCase().contains('veel')) {
    steps.add('Overweeg een zonnigere plek als de plant slap blijft hangen.');
  }
  return steps;
}

List<String> _existingPlantSteps({
  required Vegetable vegetable,
  required PlantAiAnalysis? scan,
  required bool scanCompleted,
  PlantWizardCurrentPhase? currentPhase,
  required WizardSunHours sunHours,
}) {
  final name = vegetable.nameNl;
  final steps = <String>[
    'Controleer de gezondheid van het blad van je $name.',
    'Steek je vinger in de grond: de bodem mag licht vochtig zijn.',
    'Verwijder eventueel onkruid rondom de plant.',
    'Kijk onder de bladeren op plagen en ziektes.',
  ];

  final phase = scan?.phaseLabel.trim();
  if (phase != null && phase.isNotEmpty) {
    steps.add(
      'Je scan toont fase «$phase»: houd dit in de gaten bij je verzorging.',
    );
  } else if (currentPhase != null) {
    steps.add(
      'Je plant zit in fase ${currentPhase.title}: pas je verzorging daarop aan.',
    );
  }

  final coachTasks = scan?.insight?.coachTasks ?? const [];
  for (final task in coachTasks) {
    final title = task.title.trim();
    if (title.isNotEmpty) {
      steps.add(title);
    }
  }

  if (scanCompleted) {
    steps.add('Bekijk de actuele taken voor $name in je moestuin.');
  } else {
    steps.add('Maak een eerste AI-scan om fase en gezondheid vast te leggen.');
  }

  if (sunHours == WizardSunHours.little) {
    steps.add('Let op voldoende licht; ${vegetable.sunRequirement.toLowerCase()}.');
  }

  return steps;
}

List<String> _planForSeasonSteps({
  required Vegetable vegetable,
  required WizardGrowLocation location,
  required WizardSunHours sunHours,
  PlantGrowApproach? growApproach,
}) {
  final name = vegetable.nameNl;
  final approach = growApproach ?? PlantGrowApproach.seed;
  final material = switch (approach) {
    PlantGrowApproach.seed => 'zaden',
    PlantGrowApproach.seedling => 'een zaailing of jong plantje',
    PlantGrowApproach.adult => 'een volwassen plant',
  };

  return [
    'Je plant $name staat klaar tot het seizoen begint.',
    'Controleer wanneer het zaai- of plantseizoen voor $name start.',
    'Schaf alvast $material en potgrond of compost aan.',
    'Kies alvast een plek: ${_locationLabel(location)} met ${vegetable.sunRequirement.toLowerCase()}.',
    if (sunHours != WizardSunHours.unknown)
      'Je gaf ${_sunSummary(sunHours)} aan: controleer of dat past bij $name.',
    'Wacht op de seizoensmelding in de app en start dan met je eerste stappen.',
  ];
}

String _locationLabel(WizardGrowLocation location) => switch (location) {
      WizardGrowLocation.outdoor => 'buitenplek',
      WizardGrowLocation.greenhouse => 'kas of tunnel',
      WizardGrowLocation.shed => 'schuur of beschutte plek',
      WizardGrowLocation.balcony => 'balkon',
      WizardGrowLocation.indoor => 'vensterbank of binnenplek',
      WizardGrowLocation.growLight => 'plek met groeilamp',
    };

String _warmSpotHint(WizardGrowLocation location) => switch (location) {
      WizardGrowLocation.greenhouse => 'bijv. in de kas',
      WizardGrowLocation.indoor => 'bijv. boven de verwarming of vensterbank',
      WizardGrowLocation.growLight => 'onder je groeilamp',
      _ => 'bijv. boven 18 °C',
    };

String _lightStep(WizardSunHours sunHours, {required bool indoor}) {
  if (sunHours == WizardSunHours.enough || sunHours == WizardSunHours.normal) {
    return 'Zorg voor voldoende licht zodra de zaden ontkiemen.';
  }
  if (sunHours == WizardSunHours.little || sunHours == WizardSunHours.average) {
    return indoor
        ? 'Zet kiemende zaden op de lichtste plek of gebruik een groeilamp.'
        : 'Zorg voor voldoende licht zodra de zaden ontkiemen.';
  }
  return 'Zorg voor voldoende licht zodra de zaden ontkiemen.';
}

String _sunSummary(WizardSunHours sunHours) => switch (sunHours) {
      WizardSunHours.little => 'weinig zon',
      WizardSunHours.average => 'gemiddeld zonlicht',
      WizardSunHours.normal => 'voldoende zon',
      WizardSunHours.enough => 'veel zon',
      WizardSunHours.unknown => 'onbekende zon',
    };

List<String> _limitSteps(List<String> steps) {
  final out = <String>[];
  for (final raw in steps) {
    final s = raw.trim();
    if (s.isEmpty || out.contains(s)) continue;
    out.add(s);
    if (out.length >= 6) break;
  }
  return out;
}
