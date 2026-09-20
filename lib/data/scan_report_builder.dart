import 'package:flutter/material.dart';

import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import 'crop_bloom_countdown.dart';
import 'moestuin_card_metrics.dart';
import 'moestuin_task_catalog.dart';
import 'scan_report_modules.dart';
import 'scan_assessment_sync.dart';
import 'scan_info_plan.dart';
import 'scan_task_plan.dart';
import 'weather_service.dart';

/// Bouwt het volledige scanrapport: vaste kern + optionele kaarten bij relevantie.
ScanReportLayout buildScanReportLayout({
  required PlantAiAnalysis analysis,
  Vegetable? vegetable,
  PlantAiAnalysis? previousAnalysis,
  WeatherForecast? weather,
}) {
  final insight = analysis.insight!;

  final healthPercent = moestuinPlantHealthPercent(
    analysis: analysis,
    vegetable: vegetable,
  );
  final healthLevel = plantWarningHighlightLevelForAnalysis(
    analysis: analysis,
    vegetable: vegetable,
  );
  final harvestPercent = _harvestChanceValue(analysis, insight);
  final scoreCards = [
    ScanStatusTile(
      label: 'Plantgezondheid',
      value: '$healthPercent%',
      status: moestuinPlantHealthBadgeLabel(healthPercent, healthLevel),
      percent: healthPercent,
      icon: Icons.favorite_border,
      iconColor: TuinierColors.plantHealthColor(healthPercent),
      ringColor: TuinierColors.plantHealthColor(healthPercent),
    ),
    ScanStatusTile(
      label: cropMilestoneScoreLabel(vegetable),
      value: '$harvestPercent%',
      status: _harvestChanceLabel(harvestPercent),
      percent: harvestPercent,
      icon: cropUsesBloomCountdown(vegetable)
          ? Icons.local_florist_outlined
          : Icons.shopping_basket_outlined,
      iconColor: const Color(0xFF2E7D32),
      ringColor: observationScoreColor(harvestPercent),
    ),
  ];

  final statusHeadline = _statusHeadline(healthPercent);

  final comparisonBullets = _scanComparisonBullets(analysis, previousAnalysis);
  final progressTitle = previousAnalysis != null
      ? 'Vooruitgang sinds vorige scan'
      : 'Eerste scan van deze plant';
  final progressBody = previousAnalysis != null
      ? (analysis.healthComparisonNote?.trim().isNotEmpty == true
          ? analysis.healthComparisonNote!
          : analysis.comparisonNote?.trim().isNotEmpty == true
              ? analysis.comparisonNote!
              : _defaultProgressBody(analysis, previousAnalysis))
      : 'Maak over een week een nieuwe scan om groei en gezondheid te vergelijken.';

  final tasks = _buildTasks(insight);
  final infoItems = buildScanInfoItems(
    insight: insight,
    vegetable: vegetable,
    phase: analysis.phase,
  );
  final fullAnalysisSections = _buildPhotoVisibleSections(
    analysis: analysis,
    insight: insight,
    vegetable: vegetable,
  );
  final coachObservations = _buildCoachObservations(
    analysis: analysis,
    insight: insight,
    vegetable: vegetable,
  );
  final changeCards = _buildChangeCards(analysis, previousAnalysis);
  final coachTip = _coachTipText(insight, analysis, vegetable);

  return ScanReportLayout(
    summary: insight.summary.trim().isNotEmpty
        ? insight.summary
        : analysis.displaySummary,
    priority: insight.priority,
    statusHeadline: statusHeadline,
    scoreCards: scoreCards,
    progressTitle: progressTitle,
    progressBody: progressBody,
    progressBullets: comparisonBullets,
    tasks: tasks,
    infoItems: infoItems,
    coachObservations: coachObservations,
    changeCards: changeCards,
    coachTip: coachTip,
    fullAnalysisSections: fullAnalysisSections,
  );
}

@Deprecated('Gebruik buildScanReportLayout')
List<DynamicScanSection> buildDynamicScanReport({
  required PlantAiAnalysis analysis,
  Vegetable? vegetable,
  PlantAiAnalysis? previousAnalysis,
  WeatherForecast? weather,
  bool compact = false,
}) {
  final layout = buildScanReportLayout(
    analysis: analysis,
    vegetable: vegetable,
    previousAnalysis: previousAnalysis,
    weather: weather,
  );
  return [
    DynamicScanSection(
      id: ScanReportSectionId.summary,
      title: 'Samenvatting',
      icon: Icons.summarize_outlined,
      body: layout.summary,
      priority: layout.priority,
    ),
    ...layout.fullAnalysisSections,
  ];
}

String _statusHeadline(int healthScore) {
  if (healthScore >= 75) return 'Plant gaat goed!';
  if (healthScore >= 55) return 'Plant heeft aandacht nodig';
  return 'Plant heeft extra zorg nodig';
}

List<ScanCoachObservation> _buildCoachObservations({
  required PlantAiAnalysis analysis,
  required PlantAiInsightReport insight,
  Vegetable? vegetable,
}) {
  final harvestObservation = _buildMandatoryHarvestObservation(
    analysis: analysis,
    insight: insight,
    vegetable: vegetable,
  );

  if (insight.scanAssessments.isNotEmpty) {
    final positive = insight.scanAssessments
        .where((a) => a.kind == ScanAssessmentKind.positive)
        .map(_observationFromAssessment)
        .where((o) => o.title.trim().isNotEmpty)
        .toList();
    final positiveTitles = positive.map((o) => o.title.toLowerCase()).toSet();
    final visibleFindings = insight.scanAssessments
        .where((a) => a.kind == ScanAssessmentKind.task && a.visibleOnPhoto)
        .map(_observationFromVisibleTask)
        .where((o) => o.title.trim().isNotEmpty)
        .where((o) => !positiveTitles.contains(o.title.toLowerCase()))
        .toList();
    return [harvestObservation, ...positive, ...visibleFindings];
  }

  final photoObservations = insight.visualObservations.isNotEmpty
      ? insight.visualObservations
          .where((raw) => !_isDuplicateHarvestObservation(raw))
          .where((raw) => raw.scorePercent >= 75)
          .map(_observationFromAiVisual)
          .where((o) => o.title.trim().isNotEmpty)
          .toList()
      : _observationsFromDetectedSignals(
          analysis: analysis,
          insight: insight,
        ).where((o) => !o.isWarning && o.scorePercent >= 75).toList();

  return [harvestObservation, ...photoObservations];
}

ScanCoachObservation _observationFromAssessment(PlantScanAssessment a) {
  final score = (a.scorePercent ?? 85).clamp(0, 100);
  return ScanCoachObservation(
    title: a.title,
    description: a.description,
    scorePercent: score,
    icon: Icons.eco_outlined,
    iconColor: observationScoreColor(score),
    isWarning: false,
    showScoreRing: true,
  );
}

/// Observatie-kop voor iets zichtbaars op foto dat een taak rechtvaardigt.
ScanCoachObservation _observationFromVisibleTask(PlantScanAssessment a) {
  final score = (a.scorePercent ?? 55).clamp(0, 100);
  final title = _visibleFindingTitle(a);
  final description = a.description.trim().isNotEmpty
      ? a.description.trim()
      : 'Dit is zichtbaar op je scanfoto.';
  return ScanCoachObservation(
    title: title,
    description: description,
    scorePercent: score,
    icon: _iconForTaskId(a.taskId),
    iconColor: observationScoreColor(score),
    isWarning: score < 70,
    showScoreRing: true,
  );
}

String _visibleFindingTitle(PlantScanAssessment a) {
  final catalog = catalogItemForTaskId(a.taskId);
  if (catalog != null) {
    return '${catalog.labelNl} zichtbaar';
  }
  final title = a.title.trim();
  if (title.isEmpty) return 'Op foto gezien';
  final lower = title.toLowerCase();
  if (lower.contains('wieden')) {
    return title.replaceAll(RegExp(r'wieden', caseSensitive: false), 'zichtbaar');
  }
  if (lower.contains('verwijderen')) {
    return title.replaceAll(
      RegExp(r'verwijderen', caseSensitive: false),
      'zichtbaar',
    );
  }
  if (lower.contains('geven') && lower.contains('water')) {
    return 'Droogte zichtbaar';
  }
  if (lower.endsWith('zichtbaar') || lower.contains(' op foto')) {
    return title;
  }
  return '$title op foto';
}

IconData _iconForTaskId(String taskId) {
  final key = semanticTopicKeyForTaskId(taskId);
  return switch (key) {
    'water' => Icons.water_drop_outlined,
    'onkruid' => Icons.grass_outlined,
    'bladluis' || 'witte_vlieg' || 'spint' || 'trips' || 'rups' || 'slak' =>
      Icons.bug_report_outlined,
    'meeldauw' || 'schimmel' => Icons.coronavirus_outlined,
    'snoei' => Icons.content_cut_outlined,
    'voeding' => Icons.compost_outlined,
    'harvest' => Icons.shopping_basket_outlined,
    _ => Icons.visibility_outlined,
  };
}

/// Vaste oogst-/bloei-kop uit het laatste scanresultaat (voor moestuin-kaart).
ScanCoachObservation? buildHarvestMilestoneObservation({
  required PlantAiAnalysis analysis,
  Vegetable? vegetable,
}) {
  final insight = analysis.insight;
  if (insight == null) return null;
  return _buildMandatoryHarvestObservation(
    analysis: analysis,
    insight: insight,
    vegetable: vegetable,
  );
}

String scanHarvestChanceStatusLabel(int percent) => _harvestChanceLabel(percent);

ScanCoachObservation _buildMandatoryHarvestObservation({
  required PlantAiAnalysis analysis,
  required PlantAiInsightReport insight,
  Vegetable? vegetable,
}) {
  final harvestPercent = _harvestChanceValue(analysis, insight);
  final bloomCrop = cropUsesBloomCountdown(vegetable);
  return ScanCoachObservation(
    title: cropMilestoneObservationTitle(vegetable),
    description: _harvestObservationSummary(
      analysis: analysis,
      insight: insight,
      harvestPercent: harvestPercent,
      vegetable: vegetable,
    ),
    scorePercent: harvestPercent,
    icon: bloomCrop
        ? Icons.local_florist_outlined
        : Icons.shopping_basket_outlined,
    iconColor: const Color(0xFF2E7D32),
    isWarning: harvestPercent < 60,
    showScoreRing: false,
  );
}

String _harvestObservationSummary({
  required PlantAiAnalysis analysis,
  required PlantAiInsightReport insight,
  required int harvestPercent,
  Vegetable? vegetable,
}) {
  final parts = <String>[];

  if (insight.harvestChanceNote?.trim().isNotEmpty == true) {
    parts.add(insight.harvestChanceNote!.trim());
  }

  final countdownLine = formatCropCountdownSummaryLine(analysis, vegetable);
  if (countdownLine.isNotEmpty) {
    parts.add(countdownLine);
  }

  for (final note in [
    analysis.bloomSeasonNote,
    analysis.fruitHarvestNote,
    insight.ripenessNote,
    analysis.undergroundHarvestNote,
  ]) {
    if (note?.trim().isNotEmpty == true && !parts.contains(note!.trim())) {
      parts.add(note.trim());
    }
  }

  if (parts.isEmpty) {
    parts.add(
      '${cropMilestoneScoreLabel(vegetable)} '
      '${_harvestChanceLabel(harvestPercent).toLowerCase()} '
      '($harvestPercent%).',
    );
    if (analysis.phaseLabel.trim().isNotEmpty) {
      parts.add('Fase: ${analysis.phaseLabel.trim()}.');
    }
  }

  return parts.join(' ');
}

bool _isDuplicateHarvestObservation(AiVisualObservation raw) {
  final title = raw.title.trim().toLowerCase();
  if (title.contains('oogstkans') ||
      title.contains('oogst kans') ||
      title == 'bloei' ||
      title.contains('bloeikans')) {
    return true;
  }
  return raw.kind?.trim().toLowerCase() == 'harvest';
}

/// Fallback als AI geen visualObservations leverde — alleen expliciet gedetecteerde signalen.
List<ScanCoachObservation> _observationsFromDetectedSignals({
  required PlantAiAnalysis analysis,
  required PlantAiInsightReport insight,
}) {
  final obs = <ScanCoachObservation>[];
  final seen = <String>{};

  void add({
    required String title,
    required String description,
    required int scorePercent,
    required IconData icon,
    Color? iconColor,
  }) {
    final key = title.toLowerCase();
    if (seen.contains(key) || title.trim().isEmpty || description.trim().isEmpty) {
      return;
    }
    seen.add(key);
    final score = scorePercent.clamp(0, 100);
    obs.add(ScanCoachObservation(
      title: title,
      description: description,
      scorePercent: score,
      icon: icon,
      iconColor: iconColor,
      isWarning: score < 60,
    ));
  }

  if (insight.leafAnalysisNote?.trim().isNotEmpty == true) {
    add(
      title: 'Bladeren zichtbaar',
      description: insight.leafAnalysisNote!.trim(),
      scorePercent: insight.healthScore.clamp(60, 95),
      icon: Icons.eco_outlined,
      iconColor: const Color(0xFF2E7D32),
    );
  }

  if (insight.floweringNote?.trim().isNotEmpty == true &&
      insight.floweringStatus != null &&
      insight.floweringStatus != AiFloweringStatus.none) {
    add(
      title: 'Bloei zichtbaar',
      description: insight.floweringNote!.trim(),
      scorePercent: 85,
      icon: Icons.local_florist_outlined,
      iconColor: const Color(0xFFE91E63),
    );
  }

  final fruitNote = [
    if (analysis.fruitHarvestNote?.trim().isNotEmpty == true)
      analysis.fruitHarvestNote!.trim(),
    if (insight.ripenessNote?.trim().isNotEmpty == true)
      insight.ripenessNote!.trim(),
  ].join(' ').trim();
  if (fruitNote.isNotEmpty) {
    add(
      title: insight.harvestReady == true
          ? 'Vruchten oogstbaar'
          : 'Vruchten zichtbaar',
      description: fruitNote,
      scorePercent: insight.harvestReady == true ? 90 : 78,
      icon: Icons.grass_outlined,
      iconColor: const Color(0xFF8D6E63),
    );
  }

  for (final p in insight.confirmedPests) {
    add(
      title: '${p.labelNl} gevonden',
      description: p.symptoms?.trim().isNotEmpty == true
          ? p.symptoms!.trim()
          : p.action?.trim().isNotEmpty == true
              ? p.action!.trim()
              : 'Zichtbaar op de foto',
      scorePercent: (100 - p.confidencePercent).clamp(15, 45),
      icon: Icons.bug_report_outlined,
      iconColor: const Color(0xFFDC2626),
    );
  }

  for (final d in insight.confirmedDiseases) {
    add(
      title: d.labelNl,
      description: d.symptoms?.trim().isNotEmpty == true
          ? d.symptoms!.trim()
          : 'Zichtbaar op de foto',
      scorePercent: (100 - d.confidencePercent).clamp(15, 40),
      icon: Icons.coronavirus_outlined,
      iconColor: const Color(0xFFEA580C),
    );
  }

  if (insight.waterStatus == AiWaterStatus.tooDry ||
      insight.waterStatus == AiWaterStatus.wilting) {
    add(
      title: 'Droogte zichtbaar',
      description: insight.waterSymptoms?.trim().isNotEmpty == true
          ? insight.waterSymptoms!.trim()
          : 'Droogteverschijnselen op de foto',
      scorePercent: 38,
      icon: Icons.water_drop_outlined,
      iconColor: const Color(0xFFEA580C),
    );
  }

  if (insight.waterStatus == AiWaterStatus.tooWet) {
    add(
      title: 'Te natte grond zichtbaar',
      description: insight.waterSymptoms?.trim().isNotEmpty == true
          ? insight.waterSymptoms!.trim()
          : 'Natte grond zichtbaar op de foto',
      scorePercent: 42,
      icon: Icons.water_drop_outlined,
      iconColor: const Color(0xFFEA580C),
    );
  }

  if (insight.weedsDetected == true &&
      insight.weedsNote?.trim().isNotEmpty == true) {
    add(
      title: 'Onkruid zichtbaar',
      description: insight.weedsNote!.trim(),
      scorePercent: 45,
      icon: Icons.grass_outlined,
      iconColor: const Color(0xFFCA8A04),
    );
  }

  if (insight.pruningAdvice?.trim().isNotEmpty == true) {
    add(
      title: 'Snoei nodig',
      description: insight.pruningAdvice!.trim(),
      scorePercent: 55,
      icon: Icons.content_cut_outlined,
      iconColor: const Color(0xFFCA8A04),
    );
  }

  for (final problem in insight.problems.where((x) => x.trim().isNotEmpty)) {
    add(
      title: 'Opvallend op foto',
      description: problem.trim(),
      scorePercent: 50,
      icon: Icons.warning_amber_outlined,
      iconColor: const Color(0xFFCA8A04),
    );
  }

  return obs;
}

ScanCoachObservation _observationFromAiVisual(AiVisualObservation raw) {
  final score = raw.scorePercent.clamp(0, 100);
  return ScanCoachObservation(
    title: raw.title.trim(),
    description: raw.description.trim().isNotEmpty
        ? raw.description.trim()
        : raw.title.trim(),
    scorePercent: score,
    icon: _iconForObservationKind(raw.kind),
    iconColor: score < 60
        ? const Color(0xFFDC2626)
        : const Color(0xFF2E7D32),
    isWarning: score < 60,
  );
}

IconData _iconForObservationKind(String? kind) {
  switch (kind?.toLowerCase()) {
    case 'leaf':
      return Icons.eco_outlined;
    case 'flower':
      return Icons.local_florist_outlined;
    case 'fruit':
      return Icons.grass_outlined;
    case 'pest':
    case 'slug':
      return Icons.bug_report_outlined;
    case 'water':
      return Icons.water_drop_outlined;
    case 'disease':
      return Icons.coronavirus_outlined;
    case 'damage':
      return Icons.healing_outlined;
    case 'growth':
      return Icons.trending_up;
    default:
      return Icons.visibility_outlined;
  }
}

List<ScanChangeCard> _buildChangeCards(
  PlantAiAnalysis analysis,
  PlantAiAnalysis? previous,
) {
  if (previous == null) return const [];

  final cards = <ScanChangeCard>[];
  final prevInsight = previous.insight;
  final insight = analysis.insight;

  String prevHealthLabel() {
    final score = prevInsight?.healthScore ?? 0;
    return _scoreLabel(score);
  }

  switch (analysis.healthTrend) {
    case PlantHealthTrend.improved:
      cards.add(ScanChangeCard(
        category: 'Bladgezondheid',
        status: 'Verbeterd ↑',
        detail: analysis.healthComparisonNote?.trim().isNotEmpty == true
            ? analysis.healthComparisonNote!.trim()
            : 'Minder kleine beschadigingen zichtbaar',
        previousLabel: 'Vorige keer: ${prevHealthLabel()}',
        icon: Icons.eco_outlined,
      ));
      break;
    case PlantHealthTrend.worse:
      cards.add(ScanChangeCard(
        category: 'Bladgezondheid',
        status: 'Achteruit ↓',
        detail: analysis.healthComparisonNote?.trim().isNotEmpty == true
            ? analysis.healthComparisonNote!.trim()
            : 'Meer aandacht nodig dan vorige scan',
        previousLabel: 'Vorige keer: ${prevHealthLabel()}',
        icon: Icons.eco_outlined,
        improved: false,
      ));
      break;
    case PlantHealthTrend.stable:
    case PlantHealthTrend.unknown:
      if (analysis.healthComparisonNote?.trim().isNotEmpty == true) {
        cards.add(ScanChangeCard(
          category: 'Bladgezondheid',
          status: 'Gelijk gebleven',
          detail: analysis.healthComparisonNote!.trim(),
          previousLabel: 'Vorige keer: ${prevHealthLabel()}',
          icon: Icons.eco_outlined,
        ));
      }
  }

  if (analysis.phase != previous.phase) {
    cards.add(ScanChangeCard(
      category: 'Bloei',
      status: 'Meer bloemen ↑',
      detail: '${previous.phaseLabel} → ${analysis.phaseLabel}',
      previousLabel: 'Vorige keer: ${previous.phaseLabel}',
      icon: Icons.local_florist_outlined,
    ));
  } else if (analysis.comparisonNote?.trim().isNotEmpty == true &&
      analysis.comparisonNote!.toLowerCase().contains('bloei')) {
    cards.add(ScanChangeCard(
      category: 'Bloei',
      status: 'Meer bloemen ↑',
      detail: analysis.comparisonNote!.trim(),
      previousLabel: 'Vorige keer: ${previous.phaseLabel}',
      icon: Icons.local_florist_outlined,
    ));
  }

  if ((analysis.phase == PlantAiPhase.fruiting ||
          analysis.fruitHarvestNote?.trim().isNotEmpty == true) &&
      previous.phase.index < analysis.phase.index) {
    cards.add(ScanChangeCard(
      category: 'Vruchten',
      status: 'Eerste vruchten zichtbaar',
      detail: analysis.fruitHarvestNote?.trim().isNotEmpty == true
          ? analysis.fruitHarvestNote!.trim()
          : 'Nieuwe ontwikkeling sinds vorige scan',
      previousLabel: 'Vorige keer: Nog geen vruchten',
      icon: Icons.grass_outlined,
    ));
  }

  if (analysis.comparisonNote?.trim().isNotEmpty == true &&
      !analysis.comparisonNote!.toLowerCase().contains('bloei')) {
    cards.add(ScanChangeCard(
      category: 'Groei',
      status: 'Sterker en hoger',
      detail: analysis.comparisonNote!.trim(),
      previousLabel: 'Vorige keer: ${previous.phaseLabel}',
      icon: Icons.trending_up,
    ));
  } else if (insight != null && insight.growthScore > (prevInsight?.growthScore ?? 0)) {
    cards.add(ScanChangeCard(
      category: 'Groei',
      status: 'Sterker geworden',
      detail: 'Plant oogt voller en krachtiger',
      previousLabel: 'Vorige keer: ${_scoreLabel(prevInsight?.growthScore ?? 60)}',
      icon: Icons.trending_up,
    ));
  }

  final hadPests = prevInsight?.pests.any((p) => p.detected) ?? false;
  final hasPests = insight?.pests.any((p) => p.detected) ?? false;
  if (!hasPests) {
    cards.add(ScanChangeCard(
      category: 'Ziektes & plagen',
      status: 'Geen nieuwe problemen',
      detail: hadPests ? 'Situatie lijkt verbeterd' : 'Alles onder controle',
      previousLabel: 'Vorige keer: ${hadPests ? 'Let op' : 'Goed'}',
      icon: Icons.shield_outlined,
    ));
  }

  final fromAi = analysis.insight?.scanComparisonBullets ?? const [];
  for (final bullet in fromAi.where((s) => s.trim().isNotEmpty).take(3)) {
    if (cards.length >= 5) break;
    final lower = bullet.toLowerCase();
    if (cards.any((c) => bullet.contains(c.category))) continue;
    cards.add(ScanChangeCard(
      category: 'Overig',
      status: lower.contains('verbeter') ? 'Verbeterd ↑' : 'Verandering',
      detail: bullet.trim(),
      previousLabel: 'Vorige scan',
      icon: Icons.compare_arrows,
    ));
  }

  return cards.take(5).toList();
}

String _coachTipText(
  PlantAiInsightReport insight,
  PlantAiAnalysis analysis,
  Vegetable? vegetable,
) {
  final plan = insight.coachWeekPlan.where((s) => s.trim().isNotEmpty).toList();
  if (plan.isNotEmpty) return plan.first.trim();
  for (final t in insight.coachTasks) {
    if (t.body?.trim().isNotEmpty == true) return t.body!.trim();
    if (t.title.trim().isNotEmpty) return t.title.trim();
  }
  if (analysis.advice.trim().isNotEmpty) return analysis.advice.trim();
  return vegetable != null
      ? 'Blijf je ${vegetable.nameNl} regelmatig controleren en geef water als de grond droog aanvoelt.'
      : 'Blijf de plant regelmatig controleren op plagen en geef water als de grond droog aanvoelt.';
}

List<DynamicScanSection> _buildPhotoVisibleSections({
  required PlantAiAnalysis analysis,
  required PlantAiInsightReport insight,
  Vegetable? vegetable,
}) {
  final observations = _buildCoachObservations(
    analysis: analysis,
    insight: insight,
    vegetable: vegetable,
  );
  return observations
      .map(
        (o) => DynamicScanSection(
          id: ScanReportSectionId.summary,
          title: o.title,
          icon: o.icon,
          body: o.description,
          subtitle: '${o.scorePercent}% · ${observationScoreLabel(o.scorePercent)}',
          confidence: o.scorePercent,
          highlight: o.isWarning,
        ),
      )
      .toList();
}

List<ScanTaskItem> _buildTasks(PlantAiInsightReport insight) {
  final fromAssessments = insight.scanAssessments
      .where((a) => a.kind == ScanAssessmentKind.task)
      .map(scanTaskFromAssessment)
      .where((t) => t.title.trim().isNotEmpty)
      .toList();
  if (fromAssessments.isNotEmpty) return fromAssessments;

  final items = <ScanTaskItem>[];
  for (final a in insight.recommendedActions) {
    if (a.title.trim().isEmpty) continue;
    items.add(scanTaskFromRecommendedAction(a));
  }
  if (items.isEmpty) {
    for (final t in insight.coachTasks) {
      if (t.title.trim().isEmpty) continue;
      items.add(scanTaskFromCoachTask(t));
    }
  }
  return items;
}

int _harvestChanceValue(PlantAiAnalysis analysis, PlantAiInsightReport insight) {
  if (insight.harvestChancePercent != null) {
    return insight.harvestChancePercent!.clamp(0, 100);
  }
  // Fallback voor scans vóór AI-oogstkans-veld.
  if (insight.harvestReady == true) return 92;
  if (analysis.daysUntilHarvest != null && analysis.daysUntilHarvest! <= 7) {
    return 80;
  }
  if (analysis.daysUntilHarvest != null) return 65;
  return insight.growthScore >= 70 ? 70 : 50;
}

String _harvestChanceLabel(int percent) {
  if (percent >= 85) return 'Zeer goed';
  if (percent >= 65) return 'Goed';
  if (percent >= 40) return 'Matig';
  return 'Laag';
}

String _defaultProgressBody(
  PlantAiAnalysis analysis,
  PlantAiAnalysis previous,
) {
  if (analysis.matchedPrevious) {
    return 'De plant lijkt vergelijkbaar met je vorige scan.';
  }
  if (analysis.phase != previous.phase) {
    return 'Fase gewijzigd: ${previous.phaseLabel} → ${analysis.phaseLabel}.';
  }
  return 'Er zijn veranderingen zichtbaar sinds je vorige scan.';
}

String _scoreLabel(int score) {
  if (score >= 90) return 'Uitstekend';
  if (score >= 75) return 'Goed';
  if (score >= 60) return 'Redelijk';
  return 'Aandacht nodig';
}

List<String> _scanComparisonBullets(
  PlantAiAnalysis analysis,
  PlantAiAnalysis? previous,
) {
  final fromAi = analysis.insight?.scanComparisonBullets ?? const [];
  if (fromAi.isNotEmpty) {
    return fromAi.where((s) => s.trim().isNotEmpty).toList();
  }
  if (previous == null) return const [];

  final bullets = <String>[];
  if (analysis.healthComparisonNote?.trim().isNotEmpty == true) {
    bullets.add(analysis.healthComparisonNote!.trim());
  }
  if (analysis.comparisonNote?.trim().isNotEmpty == true &&
      !analysis.matchedPrevious) {
    bullets.add(analysis.comparisonNote!.trim());
  }
  switch (analysis.healthTrend) {
    case PlantHealthTrend.improved:
      bullets.add('Gezondheid verbeterd sinds vorige scan.');
      break;
    case PlantHealthTrend.worse:
      bullets.add('Gezondheid achteruit sinds vorige scan.');
      break;
    case PlantHealthTrend.stable:
      bullets.add('Gezondheid gelijk gebleven.');
      break;
    case PlantHealthTrend.unknown:
      break;
  }
  if (analysis.matchedPrevious) {
    bullets.add('Zelfde fase als vorige scan.');
  } else if (analysis.phase != previous.phase) {
    bullets.add('Fase: ${previous.phaseLabel} → ${analysis.phaseLabel}.');
  }
  return bullets;
}
