/// Risiconiveau uit AI-plantanalyse.
enum AiRiskLevel {
  low,
  medium,
  high,
}

extension AiRiskLevelLabel on AiRiskLevel {
  String get labelNl {
    switch (this) {
      case AiRiskLevel.low:
        return 'Laag';
      case AiRiskLevel.medium:
        return 'Gemiddeld';
      case AiRiskLevel.high:
        return 'Hoog';
    }
  }

  /// Oude typo in prompts — gebruik [labelNl].
  String get labelNL => labelNl;
}

AiRiskLevel? parseAiRiskLevel(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'low':
    case 'laag':
      return AiRiskLevel.low;
    case 'medium':
    case 'gemiddeld':
      return AiRiskLevel.medium;
    case 'high':
    case 'hoog':
      return AiRiskLevel.high;
    default:
      return null;
  }
}

/// Prioriteit voor aanbevolen acties.
enum AiPriority {
  low,
  medium,
  high,
  urgent,
}

extension AiPriorityLabel on AiPriority {
  String get labelNl {
    switch (this) {
      case AiPriority.low:
        return 'Laag';
      case AiPriority.medium:
        return 'Gemiddeld';
      case AiPriority.high:
        return 'Hoog';
      case AiPriority.urgent:
        return 'Urgent';
    }
  }
}

AiPriority? parseAiPriority(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'low':
    case 'laag':
      return AiPriority.low;
    case 'medium':
    case 'gemiddeld':
      return AiPriority.medium;
    case 'high':
    case 'hoog':
      return AiPriority.high;
    case 'urgent':
      return AiPriority.urgent;
    default:
      return null;
  }
}

enum AiWaterStatus {
  ok,
  tooDry,
  tooWet,
  wilting,
}

extension AiWaterStatusLabel on AiWaterStatus {
  String get labelNl {
    switch (this) {
      case AiWaterStatus.ok:
        return 'Vocht lijkt in orde';
      case AiWaterStatus.tooDry:
        return 'Te droog';
      case AiWaterStatus.tooWet:
        return 'Te nat';
      case AiWaterStatus.wilting:
        return 'Verwelking zichtbaar';
    }
  }
}

AiWaterStatus? parseAiWaterStatus(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'ok':
    case 'goed':
      return AiWaterStatus.ok;
    case 'too_dry':
    case 'dry':
    case 'droog':
      return AiWaterStatus.tooDry;
    case 'too_wet':
    case 'wet':
    case 'nat':
      return AiWaterStatus.tooWet;
    case 'wilting':
    case 'verwelkt':
      return AiWaterStatus.wilting;
    default:
      return null;
  }
}

enum AiFloweringStatus {
  none,
  buds,
  blooming,
  faded,
}

extension AiFloweringStatusLabel on AiFloweringStatus {
  String get labelNl {
    switch (this) {
      case AiFloweringStatus.none:
        return 'Geen bloei zichtbaar';
      case AiFloweringStatus.buds:
        return 'Bloemknoppen';
      case AiFloweringStatus.blooming:
        return 'In bloei';
      case AiFloweringStatus.faded:
        return 'Uitgebloeid';
    }
  }
}

AiFloweringStatus? parseAiFloweringStatus(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'none':
    case 'geen':
      return AiFloweringStatus.none;
    case 'buds':
    case 'knoppen':
      return AiFloweringStatus.buds;
    case 'blooming':
    case 'bloei':
      return AiFloweringStatus.blooming;
    case 'faded':
    case 'uitgebloeid':
      return AiFloweringStatus.faded;
    default:
      return null;
  }
}

enum AiGrowthScheduleStatus {
  ahead,
  onTrack,
  behind,
  unknown,
}

extension AiGrowthScheduleStatusLabel on AiGrowthScheduleStatus {
  String get labelNl {
    switch (this) {
      case AiGrowthScheduleStatus.ahead:
        return 'Loopt voor op gemiddeld';
      case AiGrowthScheduleStatus.onTrack:
        return 'Op schema';
      case AiGrowthScheduleStatus.behind:
        return 'Loopt achter op gemiddeld';
      case AiGrowthScheduleStatus.unknown:
        return 'Nog onduidelijk';
    }
  }
}

AiGrowthScheduleStatus? parseAiGrowthScheduleStatus(String? raw) {
  switch (raw?.toLowerCase()) {
    case 'ahead':
    case 'voor':
      return AiGrowthScheduleStatus.ahead;
    case 'on_track':
    case 'ontrack':
    case 'schema':
      return AiGrowthScheduleStatus.onTrack;
    case 'behind':
    case 'achter':
      return AiGrowthScheduleStatus.behind;
  }
  return AiGrowthScheduleStatus.unknown;
}

/// Plaag of ziekte met betrouwbaarheid.
class AiIssueFinding {
  const AiIssueFinding({
    required this.id,
    required this.labelNl,
    required this.confidencePercent,
    this.detected = false,
    this.symptoms,
    this.action,
  });

  final String id;
  final String labelNl;
  final int confidencePercent;
  final bool detected;
  final String? symptoms;
  final String? action;

  Map<String, dynamic> toJson() => {
        'id': id,
        'labelNl': labelNl,
        'confidencePercent': confidencePercent,
        'detected': detected,
        if (symptoms != null) 'symptoms': symptoms,
        if (action != null) 'action': action,
      };

  factory AiIssueFinding.fromJson(Map<String, dynamic> json) {
    return AiIssueFinding(
      id: json['id'] as String? ?? 'onbekend',
      labelNl: json['labelNl'] as String? ?? json['label'] as String? ?? '—',
      confidencePercent:
          ((json['confidencePercent'] as num?)?.toInt() ?? 0).clamp(0, 100),
      detected: json['detected'] as bool? ?? false,
      symptoms: json['symptoms'] as String?,
      action: json['action'] as String?,
    );
  }
}

class AiNutrientIssue {
  const AiNutrientIssue({
    required this.id,
    required this.labelNl,
    this.detected = false,
    this.confidencePercent = 0,
    this.symptoms,
    this.explanation,
  });

  final String id;
  final String labelNl;
  final bool detected;
  final int confidencePercent;
  final String? symptoms;
  final String? explanation;

  Map<String, dynamic> toJson() => {
        'id': id,
        'labelNl': labelNl,
        'detected': detected,
        'confidencePercent': confidencePercent,
        if (symptoms != null) 'symptoms': symptoms,
        if (explanation != null) 'explanation': explanation,
      };

  factory AiNutrientIssue.fromJson(Map<String, dynamic> json) {
    return AiNutrientIssue(
      id: json['id'] as String? ?? 'onbekend',
      labelNl: json['labelNl'] as String? ?? json['label'] as String? ?? '—',
      detected: json['detected'] as bool? ?? false,
      confidencePercent:
          ((json['confidencePercent'] as num?)?.toInt() ?? 0).clamp(0, 100),
      symptoms: json['symptoms'] as String?,
      explanation: json['explanation'] as String?,
    );
  }
}

class AiRecommendedAction {
  const AiRecommendedAction({
    required this.title,
    this.description,
    this.reasonSummary,
    this.linkedObservationTitle,
    this.steps = const [],
    this.priority = AiPriority.medium,
  });

  final String title;
  final String? description;
  final String? reasonSummary;
  final String? linkedObservationTitle;
  final List<String> steps;
  final AiPriority priority;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (description != null) 'description': description,
        if (reasonSummary != null) 'reasonSummary': reasonSummary,
        if (linkedObservationTitle != null)
          'linkedObservationTitle': linkedObservationTitle,
        if (steps.isNotEmpty) 'steps': steps,
        'priority': priority.name,
      };

  factory AiRecommendedAction.fromJson(Map<String, dynamic> json) {
    return AiRecommendedAction(
      title: json['title'] as String? ?? '',
      description: json['description'] as String?,
      reasonSummary: json['reasonSummary'] as String?,
      linkedObservationTitle: json['linkedObservationTitle'] as String?,
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList(),
      priority:
          parseAiPriority(json['priority'] as String?) ?? AiPriority.medium,
    );
  }
}

/// Eén zichtbare bevinding op de scanfoto (AI Observaties-kaart).
class AiVisualObservation {
  const AiVisualObservation({
    required this.title,
    required this.description,
    required this.scorePercent,
    this.kind,
  });

  final String title;
  final String description;
  final int scorePercent;
  /// leaf|flower|fruit|pest|water|disease|damage|growth|other
  final String? kind;

  Map<String, dynamic> toJson() => {
        'title': title,
        'description': description,
        'scorePercent': scorePercent,
        if (kind != null) 'kind': kind,
      };

  factory AiVisualObservation.fromJson(Map<String, dynamic> json) {
    return AiVisualObservation(
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      scorePercent:
          ((json['scorePercent'] as num?)?.toInt() ?? 70).clamp(0, 100),
      kind: json['kind'] as String?,
    );
  }
}

/// Taakvoorstel voor tuincoach (kalender/herinnering).
class AiCoachTaskSuggestion {
  const AiCoachTaskSuggestion({
    required this.title,
    this.body,
    this.dueInDays = 0,
    this.kind = 'check',
  });

  final String title;
  final String? body;
  final int dueInDays;
  final String kind;

  Map<String, dynamic> toJson() => {
        'title': title,
        if (body != null) 'body': body,
        'dueInDays': dueInDays,
        'kind': kind,
      };

  factory AiCoachTaskSuggestion.fromJson(Map<String, dynamic> json) {
    return AiCoachTaskSuggestion(
      title: json['title'] as String? ?? '',
      body: json['body'] as String?,
      dueInDays: 0,
      kind: json['kind'] as String? ?? 'check',
    );
  }
}

/// Soort checklist-beoordeling per scan.
enum ScanAssessmentKind {
  task,
  letOp,
  positive;

  static ScanAssessmentKind? parse(String? raw) {
    if (raw == null) return null;
    final n = raw.trim().toLowerCase().replaceAll('-', '_');
    return switch (n) {
      'task' || 'taak' => ScanAssessmentKind.task,
      'let_op' || 'letop' || 'info' => ScanAssessmentKind.letOp,
      'positive' || 'positief' => ScanAssessmentKind.positive,
      _ => null,
    };
  }
}

/// Checklist-beoordeling: taak, let-op info, of positieve bevinding.
class PlantScanAssessment {
  const PlantScanAssessment({
    required this.taskId,
    required this.kind,
    required this.title,
    required this.description,
    this.scorePercent,
    this.steps = const [],
    this.visibleOnPhoto = false,
  });

  final String taskId;
  final ScanAssessmentKind kind;
  final String title;
  final String description;
  final int? scorePercent;
  final List<String> steps;
  final bool visibleOnPhoto;

  Map<String, dynamic> toJson() => {
        'taskId': taskId,
        'kind': kind == ScanAssessmentKind.letOp ? 'let_op' : kind.name,
        'title': title,
        'description': description,
        if (scorePercent != null) 'scorePercent': scorePercent,
        if (steps.isNotEmpty) 'steps': steps,
        'visibleOnPhoto': visibleOnPhoto,
      };

  factory PlantScanAssessment.fromJson(Map<String, dynamic> json) {
    final kindRaw = json['kind'] as String?;
    return PlantScanAssessment(
      taskId: json['taskId'] as String? ?? '',
      kind: ScanAssessmentKind.parse(kindRaw) ?? ScanAssessmentKind.task,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      scorePercent: (json['scorePercent'] as num?)?.toInt()?.clamp(0, 100),
      steps: (json['steps'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .where((s) => s.trim().isNotEmpty)
          .toList(),
      visibleOnPhoto: json['visibleOnPhoto'] as bool? ?? false,
    );
  }
}

/// Uitgebreid AI-rapport (plaag, ziekte, water, voeding, coach).
class PlantAiInsightReport {
  const PlantAiInsightReport({
    required this.summary,
    required this.healthScore,
    required this.growthScore,
    this.harvestChancePercent,
    this.harvestChanceNote,
    this.riskLevel = AiRiskLevel.low,
    this.priority = AiPriority.low,
    this.pests = const [],
    this.diseases = const [],
    this.waterStatus,
    this.waterSymptoms,
    this.waterAdvice,
    this.nutrients = const [],
    this.growthPhaseDetail,
    this.harvestReady,
    this.moreHarvestExpectedThisSeason,
    this.seasonHarvestComplete,
    this.harvestAlternativeTips = const [],
    this.plantLikelyDead,
    this.deadPlantCheckSteps = const [],
    this.ripenessNote,
    this.floweringStatus,
    this.floweringNote,
    this.growthScheduleStatus,
    this.growthScheduleWeeksDelta,
    this.growthScheduleNote,
    this.adjustedHarvestLabel,
    this.pruningAdvice,
    this.weedsDetected,
    this.weedsNote,
    this.sunlightLevel,
    this.sunlightAdvice,
    this.problems = const [],
    this.recommendedActions = const [],
    this.coachTasks = const [],
    this.moduleConfidence,
    this.scanComparisonBullets = const [],
    this.leafAnalysisNote,
    this.strengths = const [],
    this.attentionPoints = const [],
    this.environmentNote,
    this.weekFocus,
    this.outlookBullets = const [],
    this.coachWeekPlan = const [],
    this.didYouKnow,
    this.fruitSizeVsMarket,
    this.visualObservations = const [],
    this.scanAssessments = const [],
  });

  final String summary;
  final int healthScore;
  final int growthScore;
  /// AI-inschatting: kans (0-100) dat oogst nog haalbaar is op basis van de foto.
  final int? harvestChancePercent;
  /// Korte uitleg waarom (zichtbare koppen/vruchten, volwassenheid, gezondheid).
  final String? harvestChanceNote;
  final AiRiskLevel riskLevel;
  final AiPriority priority;
  final List<AiIssueFinding> pests;
  final List<AiIssueFinding> diseases;
  final AiWaterStatus? waterStatus;
  final String? waterSymptoms;
  final String? waterAdvice;
  final List<AiNutrientIssue> nutrients;
  final String? growthPhaseDetail;
  final bool? harvestReady;
  final bool? moreHarvestExpectedThisSeason;
  final bool? seasonHarvestComplete;
  final List<String> harvestAlternativeTips;
  final bool? plantLikelyDead;
  final List<String> deadPlantCheckSteps;
  final String? ripenessNote;
  final AiFloweringStatus? floweringStatus;
  final String? floweringNote;
  final AiGrowthScheduleStatus? growthScheduleStatus;
  final int? growthScheduleWeeksDelta;
  final String? growthScheduleNote;
  final String? adjustedHarvestLabel;
  final String? pruningAdvice;
  final bool? weedsDetected;
  final String? weedsNote;
  final String? sunlightLevel;
  final String? sunlightAdvice;
  final List<String> problems;
  final List<AiRecommendedAction> recommendedActions;
  final List<AiCoachTaskSuggestion> coachTasks;
  final Map<String, int>? moduleConfidence;
  final List<String> scanComparisonBullets;
  final String? leafAnalysisNote;
  final List<String> strengths;
  final List<String> attentionPoints;
  final String? environmentNote;
  final String? weekFocus;
  final List<String> outlookBullets;
  final List<String> coachWeekPlan;
  final String? didYouKnow;
  final String? fruitSizeVsMarket;
  final List<AiVisualObservation> visualObservations;
  final List<PlantScanAssessment> scanAssessments;

  bool get hasUrgentFindings =>
      riskLevel == AiRiskLevel.high ||
      priority == AiPriority.high ||
      priority == AiPriority.urgent;

  List<AiIssueFinding> get confirmedPests =>
      pests.where((p) => p.detected && p.confidencePercent >= 55).toList();

  List<AiIssueFinding> get confirmedDiseases =>
      diseases.where((d) => d.detected && d.confidencePercent >= 55).toList();

  List<AiNutrientIssue> get confirmedNutrients =>
      nutrients.where((n) => n.detected && n.confidencePercent >= 55).toList();

  Map<String, dynamic> toJson() => {
        'summary': summary,
        'healthScore': healthScore,
        'growthScore': growthScore,
        if (harvestChancePercent != null)
          'harvestChancePercent': harvestChancePercent,
        if (harvestChanceNote != null) 'harvestChanceNote': harvestChanceNote,
        'riskLevel': riskLevel.name,
        'priority': priority.name,
        'pests': pests.map((e) => e.toJson()).toList(),
        'diseases': diseases.map((e) => e.toJson()).toList(),
        if (waterStatus != null) 'waterStatus': waterStatus!.name,
        if (waterSymptoms != null) 'waterSymptoms': waterSymptoms,
        if (waterAdvice != null) 'waterAdvice': waterAdvice,
        'nutrients': nutrients.map((e) => e.toJson()).toList(),
        if (growthPhaseDetail != null) 'growthPhaseDetail': growthPhaseDetail,
        if (harvestReady != null) 'harvestReady': harvestReady,
        if (moreHarvestExpectedThisSeason != null)
          'moreHarvestExpectedThisSeason': moreHarvestExpectedThisSeason,
        if (seasonHarvestComplete != null)
          'seasonHarvestComplete': seasonHarvestComplete,
        if (harvestAlternativeTips.isNotEmpty)
          'harvestAlternativeTips': harvestAlternativeTips,
        if (plantLikelyDead != null) 'plantLikelyDead': plantLikelyDead,
        if (deadPlantCheckSteps.isNotEmpty)
          'deadPlantCheckSteps': deadPlantCheckSteps,
        if (ripenessNote != null) 'ripenessNote': ripenessNote,
        if (floweringStatus != null) 'floweringStatus': floweringStatus!.name,
        if (floweringNote != null) 'floweringNote': floweringNote,
        if (growthScheduleStatus != null)
          'growthScheduleStatus': growthScheduleStatus!.name,
        if (growthScheduleWeeksDelta != null)
          'growthScheduleWeeksDelta': growthScheduleWeeksDelta,
        if (growthScheduleNote != null)
          'growthScheduleNote': growthScheduleNote,
        if (adjustedHarvestLabel != null)
          'adjustedHarvestLabel': adjustedHarvestLabel,
        if (pruningAdvice != null) 'pruningAdvice': pruningAdvice,
        if (weedsDetected != null) 'weedsDetected': weedsDetected,
        if (weedsNote != null) 'weedsNote': weedsNote,
        if (sunlightLevel != null) 'sunlightLevel': sunlightLevel,
        if (sunlightAdvice != null) 'sunlightAdvice': sunlightAdvice,
        'problems': problems,
        'recommendedActions':
            recommendedActions.map((e) => e.toJson()).toList(),
        'coachTasks': coachTasks.map((e) => e.toJson()).toList(),
        if (moduleConfidence != null && moduleConfidence!.isNotEmpty)
          'moduleConfidence': moduleConfidence,
        if (scanComparisonBullets.isNotEmpty)
          'scanComparisonBullets': scanComparisonBullets,
        if (leafAnalysisNote != null) 'leafAnalysisNote': leafAnalysisNote,
        if (strengths.isNotEmpty) 'strengths': strengths,
        if (attentionPoints.isNotEmpty) 'attentionPoints': attentionPoints,
        if (environmentNote != null) 'environmentNote': environmentNote,
        if (weekFocus != null) 'weekFocus': weekFocus,
        if (outlookBullets.isNotEmpty) 'outlookBullets': outlookBullets,
        if (coachWeekPlan.isNotEmpty) 'coachWeekPlan': coachWeekPlan,
        if (didYouKnow != null) 'didYouKnow': didYouKnow,
        if (fruitSizeVsMarket != null) 'fruitSizeVsMarket': fruitSizeVsMarket,
        if (visualObservations.isNotEmpty)
          'visualObservations':
              visualObservations.map((e) => e.toJson()).toList(),
        if (scanAssessments.isNotEmpty)
          'scanAssessments': scanAssessments.map((e) => e.toJson()).toList(),
      };

  factory PlantAiInsightReport.fromJson(Map<String, dynamic> json) {
    List<AiIssueFinding> parseIssues(String key) {
      final raw = json[key] as List<dynamic>?;
      if (raw == null) return const [];
      return raw
          .whereType<Map<String, dynamic>>()
          .map(AiIssueFinding.fromJson)
          .toList();
    }

    return PlantAiInsightReport(
      summary: json['summary'] as String? ?? '',
      healthScore: ((json['healthScore'] as num?)?.toInt() ?? 70).clamp(0, 100),
      growthScore: ((json['growthScore'] as num?)?.toInt() ?? 70).clamp(0, 100),
      harvestChancePercent:
          (json['harvestChancePercent'] as num?)?.toInt()?.clamp(0, 100),
      harvestChanceNote: json['harvestChanceNote'] as String?,
      riskLevel:
          parseAiRiskLevel(json['riskLevel'] as String?) ?? AiRiskLevel.low,
      priority:
          parseAiPriority(json['priority'] as String?) ?? AiPriority.low,
      pests: parseIssues('pests'),
      diseases: parseIssues('diseases'),
      waterStatus: parseAiWaterStatus(json['waterStatus'] as String?),
      waterSymptoms: json['waterSymptoms'] as String?,
      waterAdvice: json['waterAdvice'] as String?,
      nutrients: (json['nutrients'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiNutrientIssue.fromJson)
              .toList() ??
          const [],
      growthPhaseDetail: json['growthPhaseDetail'] as String?,
      harvestReady: json['harvestReady'] as bool?,
      moreHarvestExpectedThisSeason:
          json['moreHarvestExpectedThisSeason'] as bool?,
      seasonHarvestComplete: json['seasonHarvestComplete'] as bool?,
      harvestAlternativeTips: (json['harvestAlternativeTips'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      plantLikelyDead: json['plantLikelyDead'] as bool?,
      deadPlantCheckSteps: (json['deadPlantCheckSteps'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      ripenessNote: json['ripenessNote'] as String?,
      floweringStatus:
          parseAiFloweringStatus(json['floweringStatus'] as String?),
      floweringNote: json['floweringNote'] as String?,
      growthScheduleStatus: parseAiGrowthScheduleStatus(
        json['growthScheduleStatus'] as String?,
      ),
      growthScheduleWeeksDelta:
          (json['growthScheduleWeeksDelta'] as num?)?.toInt(),
      growthScheduleNote: json['growthScheduleNote'] as String?,
      adjustedHarvestLabel: json['adjustedHarvestLabel'] as String?,
      pruningAdvice: json['pruningAdvice'] as String?,
      weedsDetected: json['weedsDetected'] as bool?,
      weedsNote: json['weedsNote'] as String?,
      sunlightLevel: json['sunlightLevel'] as String?,
      sunlightAdvice: json['sunlightAdvice'] as String?,
      problems: (json['problems'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      recommendedActions: (json['recommendedActions'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiRecommendedAction.fromJson)
              .toList() ??
          const [],
      coachTasks: (json['coachTasks'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiCoachTaskSuggestion.fromJson)
              .toList() ??
          const [],
      moduleConfidence: _parseModuleConfidence(json['moduleConfidence']),
      scanComparisonBullets: (json['scanComparisonBullets'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      leafAnalysisNote: json['leafAnalysisNote'] as String?,
      strengths: (json['strengths'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      attentionPoints: (json['attentionPoints'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      environmentNote: json['environmentNote'] as String?,
      weekFocus: json['weekFocus'] as String?,
      outlookBullets: (json['outlookBullets'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      coachWeekPlan: (json['coachWeekPlan'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      didYouKnow: json['didYouKnow'] as String?,
      fruitSizeVsMarket: json['fruitSizeVsMarket'] as String?,
      visualObservations: (json['visualObservations'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(AiVisualObservation.fromJson)
              .where((o) => o.title.trim().isNotEmpty)
              .toList() ??
          const [],
      scanAssessments: (json['scanAssessments'] as List<dynamic>?)
              ?.whereType<Map<String, dynamic>>()
              .map(PlantScanAssessment.fromJson)
              .where((a) => a.taskId.trim().isNotEmpty && a.title.trim().isNotEmpty)
              .toList() ??
          const [],
    );
  }
}

Map<String, int>? _parseModuleConfidence(dynamic raw) {
  if (raw is! Map) return null;
  final out = <String, int>{};
  for (final entry in raw.entries) {
    final v = entry.value;
    if (v is num) out[entry.key.toString()] = v.toInt().clamp(0, 100);
  }
  return out.isEmpty ? null : out;
}
