import '../models/add_plant_wizard_models.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import 'plant_season_activation.dart';
import 'plant_start_flow.dart';
import 'planting_season_status.dart';
import 'planting_timing_advice.dart';
import 'crop_bloom_countdown.dart';
import 'moestuin_card_metrics.dart';
import 'wizard_first_steps.dart';

/// Eén factor die de slagingskans verhoogt of verlaagt.
class WizardScoreFactor {
  const WizardScoreFactor({
    required this.title,
    required this.explanation,
    this.impactPoints,
  });

  final String title;
  final String explanation;

  /// Positief of negatief puntenverschil t.o.v. 100%.
  final int? impactPoints;

  /// Korte regel voor in het overzicht.
  String get displayLine {
    final line = explanation.trim();
    return line.isNotEmpty ? line : title;
  }
}

/// Extra uitleg bij «ik heb deze plant al» — seizoen + scan-begeleiding.
class ExistingPlantAnalysisContext {
  const ExistingPlantAnalysisContext({
    required this.isPlantingSeasonNow,
    required this.seasonStatusLabel,
    required this.seasonDetail,
    required this.scanGuidance,
    required this.fruitRecoveryNote,
  });

  final bool isPlantingSeasonNow;
  final String seasonStatusLabel;
  final String seasonDetail;
  final String scanGuidance;
  final String fruitRecoveryNote;
}

/// AI-stijl analyse na stap 6 van de toevoeg-wizard.
class PlantWizardAnalysis {
  const PlantWizardAnalysis({
    required this.successPercent,
    required this.successHeadline,
    required this.successDetail,
    required this.successAndCareDetail,
    required this.successScoreIntro,
    required this.successScoreFactors,
    required this.growthTips,
    required this.harvestWindow,
    required this.harvestDetail,
    required this.daysUntilHarvest,
    required this.recommendations,
    required this.canStartNow,
    required this.seasonHeadline,
    required this.seasonBody,
    required this.timing,
    required this.firstSteps,
    this.existingPlantContext,
  });

  final int successPercent;
  final String successHeadline;
  final String successDetail;

  /// Slagingskans + belangrijkste verzorgingstips in één tekstblok.
  final String successAndCareDetail;

  /// Waarom 100% niet realistisch is en wat jouw % betekent.
  final String successScoreIntro;
  final List<WizardScoreFactor> successScoreFactors;

  /// Gebruiksvriendelijke groeitips, los van de score-uitleg.
  final List<String> growthTips;

  final String harvestWindow;

  /// Oogstperiode in maanden (bijv. «juni – augustus»).
  final String harvestDetail;

  /// Dagen vanaf vandaag tot eerste geschatte oogstkans (`null` = niet te schatten).
  final int? daysUntilHarvest;
  final List<String> recommendations;
  final bool canStartNow;
  final String seasonHeadline;
  final String seasonBody;
  final PlantingTimingAssessment timing;
  final WizardFirstSteps firstSteps;
  final ExistingPlantAnalysisContext? existingPlantContext;
}

const kWizardPopularPlantIds = [
  'tomaat',
  'komkommer',
  'rode_paprika',
  'courgette',
  'aubergine',
];

PlantWizardAnalysis buildPlantWizardAnalysis({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required WizardGrowLocation location,
  required WizardSunHours sunHours,
  required PlantAddIntent intent,
  PlantGrowApproach? growApproach,
  PlantWizardCurrentPhase? currentPhase,
  DateTime? reference,
  bool existingScanCompleted = false,
  PlantAiAnalysis? scanAnalysis,
}) {
  final ref = reference ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final isExisting = intent == PlantAddIntent.alreadyHave;
  final waitsForSeason = intent.waitsForSeason;
  final timing = assessPlantingTiming(vegetable: vegetable, profile: profile);
  final season = plantingSeasonStatusFor(
    vegetable.id,
    reference: isExisting ? ref : profile.plantedAt,
    vegetable: vegetable,
  );
  final scoreFactors = <WizardScoreFactor>[];
  final methods = availablePlantStartMethods(vegetable);
  final approach = growApproach ?? PlantGrowApproach.seed;
  final method = isExisting
      ? PlantStartMethod.plantOutdoors
      : plantStartMethodForApproach(
          approach: approach,
          available: methods,
          suggested: suggestedPlantStartMethod(
            vegetable: vegetable,
            reference: profile.plantedAt,
          ),
        );

  var score = 72;
  switch (timing.status) {
    case PlantingTimingStatus.onTime:
      score += 18;
      scoreFactors.add(const WizardScoreFactor(
        title: 'Goede timing',
        explanation: 'Je start op een goed moment.',
        impactPoints: 18,
      ));
    case PlantingTimingStatus.slightlyLate:
      score += 6;
      scoreFactors.add(const WizardScoreFactor(
        title: 'Iets later',
        explanation: 'Iets later dan ideaal, maar nog oké.',
        impactPoints: 6,
      ));
    case PlantingTimingStatus.beforeSeason:
      score -= 4;
      scoreFactors.add(const WizardScoreFactor(
        title: 'Vroeg',
        explanation: 'Nog vroeg in het seizoen.',
        impactPoints: -4,
      ));
    case PlantingTimingStatus.tooLate:
      score -= 22;
      scoreFactors.add(const WizardScoreFactor(
        title: 'Te laat',
        explanation: 'Buiten het zaai- of plantvenster.',
        impactPoints: -22,
      ));
    case PlantingTimingStatus.unknownDate:
      if (isExisting && profile.plantingDateUnknown) {
        scoreFactors.add(const WizardScoreFactor(
          title: 'Scan',
          explanation: 'We volgen je plant via scan.',
        ));
      } else {
        score -= 6;
        scoreFactors.add(const WizardScoreFactor(
          title: 'Datum',
          explanation: 'Startdatum is nog onzeker.',
          impactPoints: -6,
        ));
      }
    case PlantingTimingStatus.noCalendar:
      score += 4;
      scoreFactors.add(const WizardScoreFactor(
        title: 'Kalender',
        explanation: 'Geen vaste kalender voor dit gewas.',
        impactPoints: 4,
      ));
  }

  if (season.phase == PlantingSeasonPhase.activeNow ||
      season.phase == PlantingSeasonPhase.daysLeft) {
    score += 10;
    scoreFactors.add(WizardScoreFactor(
      title: 'Seizoen',
      explanation: season.label.isNotEmpty
          ? season.label
          : 'Nu een goed moment om te starten.',
      impactPoints: 10,
    ));
  } else if (season.phase == PlantingSeasonPhase.startsSoon) {
    score += 4;
    scoreFactors.add(WizardScoreFactor(
      title: 'Binnenkort',
      explanation: season.days != null
          ? 'Seizoen begint over ${season.days} dagen.'
          : 'Seizoen begint binnenkort.',
      impactPoints: 4,
    ));
  } else if (season.phase == PlantingSeasonPhase.seasonEnded && !isExisting) {
    score -= 18;
    scoreFactors.add(const WizardScoreFactor(
      title: 'Seizoen voorbij',
      explanation: 'Het plantseizoen is voorbij.',
      impactPoints: -18,
    ));
  }

  final sunNeed = vegetable.sunRequirement.toLowerCase();
  if (sunHours == WizardSunHours.unknown) {
    score -= 4;
    scoreFactors.add(const WizardScoreFactor(
      title: 'Zon',
      explanation: 'Zon op je plek is nog niet ingevuld.',
      impactPoints: -4,
    ));
  } else if (sunNeed.contains('veel') && !sunHours.isAdequateForHighSunPlants) {
    score -= 10;
    scoreFactors.add(WizardScoreFactor(
      title: 'Weinig zon',
      explanation: '${vegetable.nameNl} heeft meer zon nodig op deze plek.',
      impactPoints: -10,
    ));
  } else if (sunNeed.contains('weinig') && sunHours.isStrongSun) {
    score -= 6;
    scoreFactors.add(const WizardScoreFactor(
      title: 'Veel zon',
      explanation: 'Deze plek is erg zonnig voor dit gewas.',
      impactPoints: -6,
    ));
  } else {
    score += 6;
    scoreFactors.add(WizardScoreFactor(
      title: 'Plek',
      explanation: 'Plek en zon passen goed bij ${vegetable.nameNl}.',
      impactPoints: 6,
    ));
  }

  if (!isExisting) {
    if (approach == PlantGrowApproach.seed &&
        !methods.contains(PlantStartMethod.sowOutdoors) &&
        !methods.contains(PlantStartMethod.preSowIndoors)) {
      score -= 14;
      scoreFactors.add(const WizardScoreFactor(
        title: 'Zaaien',
        explanation: 'Zaaien past niet zo goed bij dit gewas.',
        impactPoints: -14,
      ));
    }
    if (approach != PlantGrowApproach.seed &&
        !methods.contains(PlantStartMethod.plantOutdoors)) {
      score -= 10;
      scoreFactors.add(const WizardScoreFactor(
        title: 'Planten',
        explanation: 'Een plantje past beter dan een volwassen plant.',
        impactPoints: -10,
      ));
    }
    if (method == PlantStartMethod.preSowIndoors &&
        location == WizardGrowLocation.outdoor) {
      score -= 8;
      scoreFactors.add(const WizardScoreFactor(
        title: 'Voorzaaien',
        explanation: 'Voorzaaien werkt het best binnen.',
        impactPoints: -8,
      ));
    }
    if (waitsForSeason) {
      score = score.clamp(55, 92);
    }
  } else if (currentPhase != null) {
    final phaseDelta = switch (currentPhase) {
      PlantWizardCurrentPhase.ripe => 10,
      PlantWizardCurrentPhase.almostRipe => 8,
      PlantWizardCurrentPhase.fruiting => 6,
      PlantWizardCurrentPhase.flowering => 4,
      PlantWizardCurrentPhase.growing => 2,
      PlantWizardCurrentPhase.seedling => 0,
    };
    score += phaseDelta;
    if (phaseDelta > 0) {
      scoreFactors.add(WizardScoreFactor(
        title: 'Fase',
        explanation: 'Je plant staat in fase ${currentPhase.title}.',
        impactPoints: phaseDelta,
      ));
    }
  }

  if (isExisting && existingScanCompleted && scanAnalysis?.insight != null) {
    final scanResult = _existingPlantScanSuccessResult(
      scan: scanAnalysis!,
      vegetable: vegetable,
    );
    score = scanResult.percent;
    scoreFactors.add(scanResult.factor);
  } else if (isExisting && scanAnalysis != null) {
    final scanAdjust = _scanScoreAdjustment(
      scan: scanAnalysis,
      vegetable: vegetable,
    );
    score += scanAdjust.delta;
    if (scanAdjust.factor != null) {
      scoreFactors.add(scanAdjust.factor!);
    }
  }

  final hopelessHarvest = isExisting &&
      existingScanCompleted &&
      scanAnalysis?.insight != null &&
      _scanIndicatesNoHarvest(scanAnalysis!.insight!);
  score = score.clamp(hopelessHarvest ? 5 : 35, 95);
  final compactScoreFactors = _topWizardScoreFactors(scoreFactors);

  final harvestWindow = timing.harvestWindowLabel?.trim().isNotEmpty == true
      ? timing.harvestWindowLabel!.trim()
      : vegetable.harvest.trim().isNotEmpty
          ? vegetable.harvest.trim()
          : 'Volgt na start';

  final harvestOutlook = _buildHarvestMonthsOutlook(harvestWindow: harvestWindow);

  final growthTips = _buildGrowthTips(
    vegetable: vegetable,
    sunHours: sunHours,
    sunNeed: sunNeed,
    isExisting: isExisting,
    currentPhase: currentPhase,
    method: method,
    approach: approach,
    timing: timing,
    location: location,
    existingScanCompleted: existingScanCompleted,
  );

  final recommendations = growthTips;

  final plantingSeasonNow = season.phase == PlantingSeasonPhase.activeNow ||
      season.phase == PlantingSeasonPhase.daysLeft;

  final canStartNow = isExisting
      ? true
      : isPlantingSeasonActiveNow(
          vegetable: vegetable,
          growApproach: approach,
          plantStartMethod: method,
          reference: ref,
        );

  final seasonHeadline = isExisting
      ? (existingScanCompleted ? 'AI-groeicontrole' : 'Plant al aanwezig')
      : canStartNow
          ? (waitsForSeason
              ? 'Goed moment om te plannen'
              : 'Ja, je kunt nu beginnen!')
          : (waitsForSeason
              ? 'Komt op niet-actief in je moestuin'
              : intent == PlantAddIntent.startNow
                  ? 'Je start nu met AI-begeleiding'
                  : (season.phase == PlantingSeasonPhase.startsSoon
                      ? 'Bijna het juiste seizoen'
                      : 'Nog niet het ideale moment'));

  final seasonBody = isExisting
      ? (existingScanCompleted
          ? 'De AI vergelijkt je plant met wat normaal is in dit seizoen en stelt passende taken voor.'
          : 'Na je scan bepaalt de AI of je plant op schema loopt voor dit seizoen.')
      : canStartNow
          ? (waitsForSeason
              ? 'We zetten deze plant klaar in je moestuin. Zodra het seizoen begint kun je starten met taken.'
              : 'Dit is het juiste seizoen om te starten. De omstandigheden zijn gunstig voor een goede start en gezonde groei.')
          : (waitsForSeason
              ? wizardOffSeasonInactiveNote(
                  vegetable: vegetable,
                  growApproach: approach,
                  reference: ref,
                )
              : intent == PlantAddIntent.startNow
                  ? 'Ook buiten het aanbevolen seizoen krijg je passend AI-advies om verantwoord te starten.'
                  : (timing.infoLines.isNotEmpty
                      ? timing.infoLines.first
                      : season.label.isNotEmpty
                          ? season.label
                          : 'Kies een latere startdatum of plan het gewas voor het volgende venster.'));

  final successHeadline = isExisting
      ? (score >= 80
          ? 'Goed vastgelegd'
          : score >= 60
              ? 'Redelijk beeld'
              : score >= 35
                  ? 'Scan toont zorgen'
                  : 'Oogst niet meer haalbaar')
      : score >= 80
          ? 'Goed bezig!'
          : score >= 65
              ? 'Redelijk plan'
              : 'Let op de timing';

  final successDetail = isExisting
      ? (scanAnalysis?.insight != null && score < 65
          ? _compactText(
              _existingPlantScanDetail(scanAnalysis!.insight!),
              maxLen: 140,
            )
          : profile.plantingDateUnknown
              ? 'We volgen je plant via scan.'
              : 'Met je keuzes kunnen we je beter helpen.')
      : score >= 80
          ? 'De omstandigheden zien er goed uit.'
          : score >= 65
              ? 'Met kleine aanpassingen kan het alsnog lukken.'
              : 'Kijk nog even naar timing, methode en plek.';

  final successScoreIntro = 'Dit komt door je keuzes hieronder.';

  final successAndCareDetail = '$successHeadline. $successDetail';

  final existingPlantContext = isExisting
      ? ExistingPlantAnalysisContext(
          isPlantingSeasonNow: plantingSeasonNow,
          seasonStatusLabel: _existingPlantScheduleLabel(
            vegetable: vegetable,
            scanAnalysis: scanAnalysis,
          ),
          seasonDetail: _existingPlantScheduleDetail(
            vegetable: vegetable,
            scanAnalysis: scanAnalysis,
            plantingSeasonNow: plantingSeasonNow,
            season: season,
          ),
          scanGuidance:
              'De AI gebruikt je scan om te bepalen of ${vegetable.nameNl} op schema loopt voor dit seizoen en welke taken nu passen.',
          fruitRecoveryNote: score < 35
              ? 'Volgens je scan is oogst dit seizoen niet meer realistisch. Je kunt de plant nog vastleggen om je tuin bij te houden.'
              : score < 70
              ? 'Lijkt oogst onzeker? De AI geeft je dan concrete stappen, zoals extra voeding, snoeien, verplaatsen of beschermen, om alsnog te oogsten.'
              : 'Staat je plant er goed voor? De AI helpt je de oogst op het juiste moment te pakken. Ziet het er minder goed uit, dan krijg je tips om alsnog vruchten te kweken.',
        )
      : null;

  final firstSteps = buildWizardFirstSteps(
    vegetable: vegetable,
    intent: intent,
    location: location,
    sunHours: sunHours,
    timing: timing,
    season: season,
    growApproach: growApproach,
    plantStartMethod: method,
    currentPhase: currentPhase,
    scanAnalysis: scanAnalysis,
    existingScanCompleted: existingScanCompleted,
  );

  return PlantWizardAnalysis(
    successPercent: score,
    successHeadline: successHeadline,
    successDetail: successDetail,
    successAndCareDetail: successAndCareDetail,
    successScoreIntro: successScoreIntro,
    successScoreFactors: compactScoreFactors,
    growthTips: _dedupeStrings(growthTips).take(5).toList(),
    harvestWindow: harvestWindow,
    harvestDetail: harvestOutlook.detail,
    daysUntilHarvest: harvestOutlook.daysFromToday,
    recommendations: _dedupeStrings(recommendations).take(5).toList(),
    canStartNow: canStartNow,
    seasonHeadline: seasonHeadline,
    seasonBody: seasonBody,
    timing: timing,
    firstSteps: firstSteps,
    existingPlantContext: existingPlantContext,
  );
}

class _HarvestOutlook {
  const _HarvestOutlook({
    required this.daysFromToday,
    required this.detail,
  });

  final int? daysFromToday;
  final String detail;
}

_HarvestOutlook _buildHarvestMonthsOutlook({required String harvestWindow}) {
  final window = harvestWindow.trim();
  return _HarvestOutlook(
    daysFromToday: null,
    detail: window.isNotEmpty && window != 'Volgt na start' ? window : '',
  );
}

List<String> _buildGrowthTips({
  required Vegetable vegetable,
  required WizardSunHours sunHours,
  required String sunNeed,
  required bool isExisting,
  PlantWizardCurrentPhase? currentPhase,
  required PlantStartMethod method,
  required PlantGrowApproach approach,
  required PlantingTimingAssessment timing,
  required WizardGrowLocation location,
  bool existingScanCompleted = false,
}) {
  final tips = <String>[];

  if (isExisting) {
    if (existingScanCompleted) {
      tips.add(
        'Je eerste scan is gedaan. Na toevoegen staat deze in je scanhistorie.',
      );
    } else {
      tips.add(
        'Maak je eerste scan in de vorige stap. De AI bepaalt dan je groeifase.',
      );
    }
    if (currentPhase != null) {
      tips.add(
        switch (currentPhase) {
          PlantWizardCurrentPhase.ripe ||
          PlantWizardCurrentPhase.almostRipe =>
            'Je gaf aan dat de plant bijna klaar is. Scan om te zien wanneer je het beste kunt oogsten.',
          PlantWizardCurrentPhase.seedling =>
            'Jonge plant: houd de grond licht vochtig en bescherm tegen kou tot hij sterker is.',
          PlantWizardCurrentPhase.fruiting =>
            'Vruchten vormen zich. Geef regelmatig water en let op tekenen van ziekte.',
          _ =>
            'Scan elke paar weken zodat de AI je fase en volgende taken kan bijsturen.',
        },
      );
    }
  } else {
    if (timing.positiveLines.isNotEmpty) {
      tips.add(timing.positiveLines.first);
    }
    if (method == PlantStartMethod.preSowIndoors) {
      tips.add(
        'Voorzaaien: zet zaad binnen op een lichte plek en plant uit zodra het warm genoeg is.',
      );
    } else if (approach == PlantGrowApproach.seedling) {
      tips.add(
        'Laat zaailingen eerst wennen aan buitenlucht (harden off) voordat je ze definitief plant.',
      );
    }
  }

  final water = vegetable.water.trim();
  if (water.isNotEmpty) {
    tips.add('Water geven: ${_compactText(water, maxLen: 110)}');
  }

  if (sunHours != WizardSunHours.unknown) {
    if (sunNeed.contains('veel') && !sunHours.isAdequateForHighSunPlants) {
      tips.add(
        'Standplaats: kies een plek met minstens 8 uur directe zon per dag. Nu gaf je «${sunHours.summaryLabel}» aan.',
      );
    } else if (sunNeed.contains('half') || sunNeed.contains('weinig')) {
      tips.add(
        'Standplaats: halfschaduw of ochtendzon past beter bij ${vegetable.nameNl}.',
      );
    } else {
      tips.add(
        'Standplaats: ${vegetable.sunRequirement.trim().isNotEmpty ? vegetable.sunRequirement.trim() : 'jouw gekozen plek past goed'}.',
      );
    }
  }

  if (vegetable.spacingCm > 0) {
    tips.add(
      'Afstand: houd ongeveer ${vegetable.spacingCm} cm tussen planten zodat lucht en wortels ruimte hebben.',
    );
  }

  final soil = vegetable.soilAndFood.trim();
  if (soil.isNotEmpty) {
    tips.add('Voeding & grond: ${_firstUsefulSentence(soil)}');
  }

  final care = vegetable.care.trim();
  if (care.isNotEmpty) {
    tips.add('Verzorging: ${_firstUsefulSentence(care)}');
  }

  final issues = vegetable.commonIssues.trim();
  if (issues.isNotEmpty) {
    tips.add('Let op: ${_firstUsefulSentence(issues)}');
  }

  if (tips.isEmpty) {
    tips.add('Geef regelmatig water en controleer je plant wekelijks op blad en groei.');
  }

  return tips;
}

String _resolvedSunLabel(WizardSunHours sunHours) => sunHours.summaryLabel;

String _firstUsefulSentence(String text) {
  final t = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t.isEmpty) return t;

  final semi = t.indexOf(';');
  if (semi > 0 && semi < 120) {
    return t.substring(0, semi).trim();
  }

  final dot = t.indexOf('. ');
  if (dot > 0 && dot < 140) {
    return t.substring(0, dot + 1).trim();
  }

  return _compactText(t, maxLen: 120);
}

String _compactText(String text, {required int maxLen}) {
  final t = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t.length <= maxLen) return t;
  return '${t.substring(0, maxLen - 1).trim()}…';
}

List<WizardScoreFactor> _topWizardScoreFactors(List<WizardScoreFactor> factors) {
  final sorted = [...factors]
    ..sort(
      (a, b) => (b.impactPoints ?? 0).abs().compareTo((a.impactPoints ?? 0).abs()),
    );
  return sorted.take(3).toList();
}

List<String> _dedupeStrings(List<String> items) {
  final seen = <String>{};
  final out = <String>[];
  for (final item in items) {
    final key = item.trim().toLowerCase();
    if (key.isEmpty || seen.contains(key)) continue;
    seen.add(key);
    out.add(item.trim());
  }
  return out;
}

class _ScanScoreAdjustment {
  const _ScanScoreAdjustment({required this.delta, this.factor});

  final int delta;
  final WizardScoreFactor? factor;
}

class _ExistingPlantScanSuccessResult {
  const _ExistingPlantScanSuccessResult({
    required this.percent,
    required this.factor,
  });

  final int percent;
  final WizardScoreFactor factor;
}

bool _scanIndicatesNoHarvest(PlantAiInsightReport insight) {
  final harvest = insight.harvestChancePercent;
  if (harvest != null && harvest <= 24) return true;

  final blob = [
    insight.summary,
    insight.harvestChanceNote ?? '',
    ...insight.problems,
    ...insight.attentionPoints,
    for (final a in insight.scanAssessments) '${a.title} ${a.description}',
  ].join(' ').toLowerCase();

  const markers = [
    'niet meer oogstbaar',
    'niet oogstbaar',
    'geen oogst meer',
    'niet meer haalbaar',
    'vrijwel geen oogst',
    'vrijwel niet meer haalbaar',
    'geen haalbare oogst',
    'rot in de krop',
    'rot in krop',
    'krop rot',
    'krop is rot',
    'verrot',
    'niet meer te redden',
    'geen oogst meer mogelijk',
  ];
  return markers.any(blob.contains);
}

String _existingPlantScanDetail(PlantAiInsightReport insight) {
  final note = insight.harvestChanceNote?.trim();
  if (note != null && note.isNotEmpty) return note;
  return insight.summary.trim();
}

_ExistingPlantScanSuccessResult _existingPlantScanSuccessResult({
  required PlantAiAnalysis scan,
  required Vegetable vegetable,
}) {
  final insight = scan.insight!;
  final health = moestuinPlantHealthPercent(
    analysis: scan,
    vegetable: vegetable,
  );
  final harvest = insight.harvestChancePercent;
  final noHarvest = _scanIndicatesNoHarvest(insight);
  final parts = <String>[];

  var score = harvest ?? health;
  if (harvest != null) {
    parts.add('oogstkans op foto: $harvest%');
    final healthNudge = ((health - 70) * 0.12).round().clamp(-8, 8);
    if (healthNudge != 0) {
      score += healthNudge;
      parts.add('gezondheid op foto: $health%');
    }
  } else {
    parts.add('gezondheid op foto: $health%');
  }

  if (insight.confirmedDiseases.isNotEmpty) {
    score -= 10;
    parts.add('ziekte zichtbaar op de foto');
  }
  if (insight.confirmedPests.isNotEmpty) {
    score -= 5;
    parts.add('plagen zichtbaar op de foto');
  }
  if (insight.riskLevel == AiRiskLevel.high) {
    score -= 8;
    parts.add('hoog risico op de scan');
  }
  if (insight.priority == AiPriority.urgent) {
    score -= 5;
    parts.add('hoge urgentie op de scan');
  }

  if (noHarvest) {
    if (harvest != null) {
      score = score.clamp(5, harvest + 5);
    } else {
      score = score.clamp(5, 28);
    }
    parts.add('oogst niet meer haalbaar volgens scan');
  } else if (harvest != null && harvest <= 44) {
    score = score.clamp(15, harvest + 12);
  } else {
    score = score.clamp(20, 95);
  }

  return _ExistingPlantScanSuccessResult(
    percent: score,
    factor: WizardScoreFactor(
      title: 'AI-scan',
      explanation: parts.isEmpty
          ? 'Slagingskans gebaseerd op je scanfoto.'
          : parts.join('; '),
      impactPoints: null,
    ),
  );
}

_ScanScoreAdjustment _scanScoreAdjustment({
  required PlantAiAnalysis scan,
  required Vegetable vegetable,
}) {
  final insight = scan.insight;
  if (insight == null) return const _ScanScoreAdjustment(delta: 0);

  final health = moestuinPlantHealthPercent(
    analysis: scan,
    vegetable: vegetable,
  );

  var delta = 0;
  final parts = <String>[];

  final healthDelta = ((health - 75) * 0.35).round();
  if (healthDelta != 0) {
    delta += healthDelta;
    parts.add(
      health >= 75
          ? 'plant ziet er gezond uit op de scan ($health%)'
          : 'plant ziet er minder gezond uit op de scan ($health%)',
    );
  }

  final harvest = insight.harvestChancePercent;
  if (harvest != null && !cropUsesBloomCountdown(vegetable)) {
    final harvestDelta = ((harvest - 65) * 0.22).round();
    if (harvestDelta.abs() >= 2) {
      delta += harvestDelta;
      parts.add('oogstkans op foto: $harvest%');
    }
  } else if (harvest != null && cropUsesBloomCountdown(vegetable)) {
    final bloomDelta = ((harvest - 65) * 0.15).round();
    if (bloomDelta.abs() >= 2) {
      delta += bloomDelta;
      parts.add('bloeikans op foto: $harvest%');
    }
  }

  if (insight.confirmedPests.isNotEmpty) {
    delta -= 6;
    parts.add('plagen zichtbaar op de foto');
  }
  if (insight.confirmedDiseases.isNotEmpty) {
    delta -= 8;
    parts.add('ziekte zichtbaar op de foto');
  }
  if (insight.riskLevel == AiRiskLevel.high ||
      insight.priority == AiPriority.urgent) {
    delta -= 5;
    parts.add('hoge urgentie op de scan');
  }

  final openTasks = insight.scanAssessments
      .where((a) => a.kind == ScanAssessmentKind.task)
      .length;
  if (openTasks >= 4) {
    delta -= 4;
    parts.add('meerdere acties nodig volgens scan');
  }

  delta = delta.clamp(-28, 14);

  if (delta == 0 && parts.isEmpty) {
    return const _ScanScoreAdjustment(
      delta: 0,
      factor: WizardScoreFactor(
        title: 'AI-scan',
        explanation: 'Plant ziet er op de foto redelijk uit.',
        impactPoints: 0,
      ),
    );
  }

  return _ScanScoreAdjustment(
    delta: delta,
    factor: WizardScoreFactor(
      title: 'AI-scan',
      explanation: parts.join('; '),
      impactPoints: delta,
    ),
  );
}

String _existingPlantScheduleLabel({
  required Vegetable vegetable,
  required PlantAiAnalysis? scanAnalysis,
}) {
  final status = scanAnalysis?.insight?.growthScheduleStatus;
  if (status != null && status != AiGrowthScheduleStatus.unknown) {
    return switch (status) {
      AiGrowthScheduleStatus.onTrack => '${vegetable.nameNl}: op schema',
      AiGrowthScheduleStatus.ahead => '${vegetable.nameNl}: loopt voor',
      AiGrowthScheduleStatus.behind => '${vegetable.nameNl}: loopt achter',
      AiGrowthScheduleStatus.unknown => 'Seizoenscontrole via AI',
    };
  }
  return 'Seizoenscontrole via AI';
}

String _existingPlantScheduleDetail({
  required Vegetable vegetable,
  required PlantAiAnalysis? scanAnalysis,
  required bool plantingSeasonNow,
  required PlantingSeasonStatus season,
}) {
  final note = scanAnalysis?.insight?.growthScheduleNote?.trim();
  if (note != null && note.isNotEmpty) return note;

  final summary = scanAnalysis?.insight?.summary.trim();
  if (summary != null && summary.isNotEmpty) return summary;

  final status = scanAnalysis?.insight?.growthScheduleStatus;
  if (status != null && status != AiGrowthScheduleStatus.unknown) {
    return status.labelNl;
  }

  if (plantingSeasonNow) {
    return 'Je plant staat al in de grond. De AI vergelijkt de groei met wat '
        'normaal is in dit seizoen.';
  }

  return 'De klassieke zaai- of plantkalender is nu niet actief, maar je plant '
      'kan al groeien. De AI bepaalt via scans of ${vegetable.nameNl} goed op '
      'schema loopt.';
}
