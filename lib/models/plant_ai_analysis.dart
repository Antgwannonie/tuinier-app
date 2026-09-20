import 'plant_ai_insight_report.dart';

/// Fase zoals door de AI op de foto herkend.
enum PlantAiPhase {
  seedling,
  growing,
  flowering,
  fruiting,
  almostRipe,
  ripe,
}

enum PlantHealthTrend {
  improved,
  stable,
  worse,
  unknown,
}

PlantHealthTrend parsePlantHealthTrend(String? raw) {
  switch (raw) {
    case 'improved':
      return PlantHealthTrend.improved;
    case 'stable':
      return PlantHealthTrend.stable;
    case 'worse':
      return PlantHealthTrend.worse;
    default:
      return PlantHealthTrend.unknown;
  }
}

extension PlantAiPhaseLabel on PlantAiPhase {
  String get label {
    switch (this) {
      case PlantAiPhase.seedling:
        return 'Zaailing / jong';
      case PlantAiPhase.growing:
        return 'In groei';
      case PlantAiPhase.flowering:
        return 'Bloei';
      case PlantAiPhase.fruiting:
        return 'Vruchten / knollen';
      case PlantAiPhase.almostRipe:
        return 'Bijna rijp';
      case PlantAiPhase.ripe:
        return 'Rijp voor oogst';
    }
  }
}

/// Herkent fase-strings uit AI-JSON (NL/EN).
PlantAiPhase? parsePlantAiPhase(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  final key = raw.toLowerCase().replaceAll('-', '_');
  const map = {
    'seedling': PlantAiPhase.seedling,
    'zaailing': PlantAiPhase.seedling,
    'gezaaid': PlantAiPhase.seedling,
    'growing': PlantAiPhase.growing,
    'groei': PlantAiPhase.growing,
    'groeifase': PlantAiPhase.growing,
    'flowering': PlantAiPhase.flowering,
    'bloei': PlantAiPhase.flowering,
    'fruiting': PlantAiPhase.fruiting,
    'vruchtzetting': PlantAiPhase.fruiting,
    'vruchten': PlantAiPhase.fruiting,
    'almost_ripe': PlantAiPhase.almostRipe,
    'bijna_rijp': PlantAiPhase.almostRipe,
    'ripe': PlantAiPhase.ripe,
    'rijp': PlantAiPhase.ripe,
  };
  return map[key];
}

/// Resultaat van een AI-fotoanalyse.
class PlantAiAnalysis {
  const PlantAiAnalysis({
    required this.scannedAt,
    required this.phase,
    required this.phaseLabel,
    this.daysUntilHarvest,
    this.daysUntilBloom,
    required this.harvestWindowLabel,
    required this.confidencePercent,
    required this.advice,
    this.warnings = const [],
    this.matchedPrevious = false,
    this.comparisonNote,
    this.harvestStillPossibleThisSeason,
    this.seasonTimingWarning,
    this.estimatedWeeksGrowing,
    this.plantedDateMatchesPhoto,
    this.datePhotoComparisonNote,
    this.expectedWeeksFromStatedDate,
    this.matchesSelectedCrop = true,
    this.detectedPlantLabel,
    this.cropMismatchWarning,
    this.healthImprovedSincePrevious,
    this.pestLikelyResolvedSincePrevious,
    this.healthComparisonNote,
    this.healthTrend = PlantHealthTrend.unknown,
    this.insight,
    this.isHarvestProbeScan = false,
    this.undergroundHarvestNote,
    this.fruitHarvestNote,
    this.bloomSeasonNote,
  });

  final DateTime scannedAt;
  final PlantAiPhase phase;
  final String phaseLabel;
  final int? daysUntilHarvest;
  /// Moestuinbloemen: geschatte dagen tot (eerste) bloei op basis van de scan.
  final int? daysUntilBloom;
  final String harvestWindowLabel;
  final int confidencePercent;
  final String advice;
  final List<String> warnings;

  /// Of deze scan is afgestemd op de vorige (zelfde fase/foto).
  final bool matchedPrevious;

  /// Korte vergelijking door de AI (optioneel).
  final String? comparisonNote;

  /// Of oogst nog haalbaar lijkt dit seizoen (bij late/buiten-seizoen datum).
  final bool? harvestStillPossibleThisSeason;

  /// Seizoensinschatting op basis van foto + kalender.
  final String? seasonTimingWarning;

  /// Geschatte weken dat de plant al groeit (foto-inschatting).
  final int? estimatedWeeksGrowing;

  /// Of de ingevulde zaai/plantdatum past bij grootte op de foto.
  final bool? plantedDateMatchesPhoto;

  /// Uitleg vergelijking datum ↔ foto (voor meldingen).
  final String? datePhotoComparisonNote;

  /// Verwachte weken groei volgens ingevulde datum t.o.v. scan.
  final int? expectedWeeksFromStatedDate;

  /// Of de foto bij het gekozen gewas in de app hoort.
  final bool matchesSelectedCrop;

  /// Wat de AI op de foto herkent (bijv. "cayennepeper").
  final String? detectedPlantLabel;

  /// Duidelijke melding bij verkeerd gewas gescand.
  final String? cropMismatchWarning;

  /// Gezondheid t.o.v. vorige scan (indien er een vorige scan is).
  final bool? healthImprovedSincePrevious;

  /// Of een eerder zichtbare plaag nu waarschijnlijk verholpen is.
  final bool? pestLikelyResolvedSincePrevious;

  /// Uitleg gezondheid/plaag verandering t.o.v. vorige scan.
  final String? healthComparisonNote;

  /// Trend t.o.v. vorige scan.
  final PlantHealthTrend healthTrend;

  /// Uitgebreid rapport: plaag, ziekte, water, coach, enz.
  final PlantAiInsightReport? insight;

  /// Scan van een uitgetrokken proefplant (ondergronds gewas).
  final bool isHarvestProbeScan;

  /// AI-uitleg over mogelijke oogst zonder zichtbare knol/wortel.
  final String? undergroundHarvestNote;

  /// Bij vruchtgewassen: grootte en rijpheid van zichtbare vruchten op de foto.
  final String? fruitHarvestNote;

  /// Bij moestuinbloemen: bloei op haar hoogte (geen eetbare oogst).
  final String? bloomSeasonNote;

  bool get hasCropMismatch => !matchesSelectedCrop;

  bool get hasInsight => insight != null;

  String get displaySummary {
    final s = insight?.summary.trim();
    if (s != null && s.isNotEmpty) return s;
    return advice.trim();
  }

  int? get healthScore => insight?.healthScore;

  PlantAiAnalysis copyWith({
    DateTime? scannedAt,
    PlantAiPhase? phase,
    String? phaseLabel,
    int? daysUntilHarvest,
    int? daysUntilBloom,
    String? harvestWindowLabel,
    int? confidencePercent,
    String? advice,
    List<String>? warnings,
    bool? matchedPrevious,
    String? comparisonNote,
    bool? harvestStillPossibleThisSeason,
    String? seasonTimingWarning,
    int? estimatedWeeksGrowing,
    bool? plantedDateMatchesPhoto,
    String? datePhotoComparisonNote,
    int? expectedWeeksFromStatedDate,
    bool? matchesSelectedCrop,
    String? detectedPlantLabel,
    String? cropMismatchWarning,
    bool? healthImprovedSincePrevious,
    bool? pestLikelyResolvedSincePrevious,
    String? healthComparisonNote,
    PlantHealthTrend? healthTrend,
    PlantAiInsightReport? insight,
    bool? isHarvestProbeScan,
    String? undergroundHarvestNote,
    String? fruitHarvestNote,
    String? bloomSeasonNote,
  }) {
    return PlantAiAnalysis(
      scannedAt: scannedAt ?? this.scannedAt,
      phase: phase ?? this.phase,
      phaseLabel: phaseLabel ?? this.phaseLabel,
      daysUntilHarvest: daysUntilHarvest ?? this.daysUntilHarvest,
      daysUntilBloom: daysUntilBloom ?? this.daysUntilBloom,
      harvestWindowLabel: harvestWindowLabel ?? this.harvestWindowLabel,
      confidencePercent: confidencePercent ?? this.confidencePercent,
      advice: advice ?? this.advice,
      warnings: warnings ?? this.warnings,
      matchedPrevious: matchedPrevious ?? this.matchedPrevious,
      comparisonNote: comparisonNote ?? this.comparisonNote,
      harvestStillPossibleThisSeason: harvestStillPossibleThisSeason ??
          this.harvestStillPossibleThisSeason,
      seasonTimingWarning: seasonTimingWarning ?? this.seasonTimingWarning,
      estimatedWeeksGrowing:
          estimatedWeeksGrowing ?? this.estimatedWeeksGrowing,
      plantedDateMatchesPhoto:
          plantedDateMatchesPhoto ?? this.plantedDateMatchesPhoto,
      datePhotoComparisonNote:
          datePhotoComparisonNote ?? this.datePhotoComparisonNote,
      expectedWeeksFromStatedDate: expectedWeeksFromStatedDate ??
          this.expectedWeeksFromStatedDate,
      matchesSelectedCrop: matchesSelectedCrop ?? this.matchesSelectedCrop,
      detectedPlantLabel: detectedPlantLabel ?? this.detectedPlantLabel,
      cropMismatchWarning: cropMismatchWarning ?? this.cropMismatchWarning,
      healthImprovedSincePrevious: healthImprovedSincePrevious ??
          this.healthImprovedSincePrevious,
      pestLikelyResolvedSincePrevious: pestLikelyResolvedSincePrevious ??
          this.pestLikelyResolvedSincePrevious,
      healthComparisonNote:
          healthComparisonNote ?? this.healthComparisonNote,
      healthTrend: healthTrend ?? this.healthTrend,
      insight: insight ?? this.insight,
      isHarvestProbeScan: isHarvestProbeScan ?? this.isHarvestProbeScan,
      undergroundHarvestNote:
          undergroundHarvestNote ?? this.undergroundHarvestNote,
      fruitHarvestNote: fruitHarvestNote ?? this.fruitHarvestNote,
      bloomSeasonNote: bloomSeasonNote ?? this.bloomSeasonNote,
    );
  }

  Map<String, dynamic> toJson() => {
        'scannedAt': scannedAt.toIso8601String(),
        'phase': phase.name,
        'phaseLabel': phaseLabel,
        'daysUntilHarvest': daysUntilHarvest,
        if (daysUntilBloom != null) 'daysUntilBloom': daysUntilBloom,
        'harvestWindowLabel': harvestWindowLabel,
        'confidencePercent': confidencePercent,
        'advice': advice,
        'warnings': warnings,
        if (matchedPrevious) 'matchedPrevious': true,
        if (comparisonNote != null) 'comparisonNote': comparisonNote,
        if (harvestStillPossibleThisSeason != null)
          'harvestStillPossibleThisSeason': harvestStillPossibleThisSeason,
        if (seasonTimingWarning != null)
          'seasonTimingWarning': seasonTimingWarning,
        if (estimatedWeeksGrowing != null)
          'estimatedWeeksGrowing': estimatedWeeksGrowing,
        if (plantedDateMatchesPhoto != null)
          'plantedDateMatchesPhoto': plantedDateMatchesPhoto,
        if (datePhotoComparisonNote != null)
          'datePhotoComparisonNote': datePhotoComparisonNote,
        if (expectedWeeksFromStatedDate != null)
          'expectedWeeksFromStatedDate': expectedWeeksFromStatedDate,
        'matchesSelectedCrop': matchesSelectedCrop,
        if (detectedPlantLabel != null) 'detectedPlantLabel': detectedPlantLabel,
        if (cropMismatchWarning != null)
          'cropMismatchWarning': cropMismatchWarning,
        if (healthImprovedSincePrevious != null)
          'healthImprovedSincePrevious': healthImprovedSincePrevious,
        if (pestLikelyResolvedSincePrevious != null)
          'pestLikelyResolvedSincePrevious': pestLikelyResolvedSincePrevious,
        if (healthComparisonNote != null)
          'healthComparisonNote': healthComparisonNote,
        'healthTrend': healthTrend.name,
        if (insight != null) 'insight': insight!.toJson(),
        if (isHarvestProbeScan) 'isHarvestProbeScan': true,
        if (undergroundHarvestNote != null)
          'undergroundHarvestNote': undergroundHarvestNote,
        if (fruitHarvestNote != null) 'fruitHarvestNote': fruitHarvestNote,
        if (bloomSeasonNote != null) 'bloomSeasonNote': bloomSeasonNote,
      };

  factory PlantAiAnalysis.fromJson(Map<String, dynamic> json) {
    final phaseRaw = json['phase'] as String?;
    final phase = PlantAiPhase.values.byName(phaseRaw ?? 'growing');
    return PlantAiAnalysis(
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      phase: phase,
      phaseLabel: json['phaseLabel'] as String? ?? phase.label,
      daysUntilHarvest: json['daysUntilHarvest'] as int?,
      daysUntilBloom: json['daysUntilBloom'] as int?,
      harvestWindowLabel: json['harvestWindowLabel'] as String? ?? '',
      confidencePercent: (json['confidencePercent'] as num?)?.toInt() ?? 70,
      advice: json['advice'] as String? ?? '',
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      matchedPrevious: json['matchedPrevious'] as bool? ?? false,
      comparisonNote: json['comparisonNote'] as String?,
      harvestStillPossibleThisSeason:
          json['harvestStillPossibleThisSeason'] as bool?,
      seasonTimingWarning: json['seasonTimingWarning'] as String?,
      estimatedWeeksGrowing:
          (json['estimatedWeeksGrowing'] as num?)?.toInt(),
      plantedDateMatchesPhoto: json['plantedDateMatchesPhoto'] as bool?,
      datePhotoComparisonNote: json['datePhotoComparisonNote'] as String?,
      expectedWeeksFromStatedDate:
          (json['expectedWeeksFromStatedDate'] as num?)?.toInt(),
      matchesSelectedCrop: json['matchesSelectedCrop'] as bool? ?? true,
      detectedPlantLabel: json['detectedPlantLabel'] as String?,
      cropMismatchWarning: json['cropMismatchWarning'] as String?,
      healthImprovedSincePrevious:
          json['healthImprovedSincePrevious'] as bool?,
      pestLikelyResolvedSincePrevious:
          json['pestLikelyResolvedSincePrevious'] as bool?,
      healthComparisonNote: json['healthComparisonNote'] as String?,
      healthTrend: parsePlantHealthTrend(json['healthTrend'] as String?),
      insight: json['insight'] is Map<String, dynamic>
          ? PlantAiInsightReport.fromJson(
              json['insight'] as Map<String, dynamic>,
            )
          : null,
      isHarvestProbeScan: json['isHarvestProbeScan'] as bool? ?? false,
      undergroundHarvestNote: json['undergroundHarvestNote'] as String?,
      fruitHarvestNote: json['fruitHarvestNote'] as String?,
      bloomSeasonNote: json['bloomSeasonNote'] as String?,
    );
  }
}
