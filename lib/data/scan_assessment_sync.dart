import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import 'crop_growth_phase_guide.dart';
import 'home_action_completion.dart';
import 'moestuin_task_catalog.dart';

/// Synchroniseert scanAssessments naar recommendedActions en dedupliceert.
PlantAiInsightReport syncScanAssessments(
  PlantAiInsightReport insight, {
  PlantAiPhase? phase,
}) {
  if (insight.scanAssessments.isEmpty) return insight;

  final carePhase = resolveCropCarePhase(
    phase: phase,
    growthPhaseDetail: insight.growthPhaseDetail,
  );
  final deduped = _dedupeAssessments(insight.scanAssessments)
      .where((a) => _assessmentAllowedForPhase(a, carePhase))
      .toList();
  final tasks = deduped
      .where((a) => a.kind == ScanAssessmentKind.task)
      .where((a) => a.title.trim().isNotEmpty)
      .toList();

  final recommended = tasks
      .map(
        (a) => AiRecommendedAction(
          title: a.title,
          description: a.description,
          reasonSummary: a.visibleOnPhoto
              ? 'Zichtbaar op je scanfoto'
              : 'Actie nodig voor ${a.title.toLowerCase()}',
          steps: a.steps,
          priority: _priorityFromAssessment(a),
        ),
      )
      .toList();

  return PlantAiInsightReport(
    summary: insight.summary,
    healthScore: insight.healthScore,
    growthScore: insight.growthScore,
    harvestChancePercent: insight.harvestChancePercent,
    harvestChanceNote: insight.harvestChanceNote,
    riskLevel: insight.riskLevel,
    priority: insight.priority,
    pests: insight.pests,
    diseases: insight.diseases,
    waterStatus: insight.waterStatus,
    waterSymptoms: insight.waterSymptoms,
    waterAdvice: insight.waterAdvice,
    nutrients: insight.nutrients,
    growthPhaseDetail: insight.growthPhaseDetail,
    harvestReady: insight.harvestReady,
    moreHarvestExpectedThisSeason: insight.moreHarvestExpectedThisSeason,
    seasonHarvestComplete: insight.seasonHarvestComplete,
    harvestAlternativeTips: insight.harvestAlternativeTips,
    plantLikelyDead: insight.plantLikelyDead,
    deadPlantCheckSteps: insight.deadPlantCheckSteps,
    ripenessNote: insight.ripenessNote,
    floweringStatus: insight.floweringStatus,
    floweringNote: insight.floweringNote,
    growthScheduleStatus: insight.growthScheduleStatus,
    growthScheduleWeeksDelta: insight.growthScheduleWeeksDelta,
    growthScheduleNote: insight.growthScheduleNote,
    adjustedHarvestLabel: insight.adjustedHarvestLabel,
    pruningAdvice: insight.pruningAdvice,
    weedsDetected: insight.weedsDetected,
    weedsNote: insight.weedsNote,
    sunlightLevel: insight.sunlightLevel,
    sunlightAdvice: insight.sunlightAdvice,
    problems: insight.problems,
    recommendedActions: recommended.isNotEmpty ? recommended : insight.recommendedActions,
    coachTasks: insight.coachTasks,
    moduleConfidence: insight.moduleConfidence,
    scanComparisonBullets: insight.scanComparisonBullets,
    leafAnalysisNote: insight.leafAnalysisNote,
    strengths: insight.strengths,
    attentionPoints: insight.attentionPoints,
    environmentNote: insight.environmentNote,
    weekFocus: insight.weekFocus,
    outlookBullets: insight.outlookBullets,
    coachWeekPlan: insight.coachWeekPlan,
    didYouKnow: insight.didYouKnow,
    fruitSizeVsMarket: insight.fruitSizeVsMarket,
    visualObservations: insight.visualObservations,
    scanAssessments: deduped,
  );
}

bool _assessmentAllowedForPhase(
  PlantScanAssessment assessment,
  CropCarePhase phase,
) {
  if (assessment.kind == ScanAssessmentKind.positive) return true;
  if (assessment.taskId.trim().isEmpty) return true;
  return isTaskIdAllowedForPhase(assessment.taskId, phase);
}

List<PlantScanAssessment> _dedupeAssessments(List<PlantScanAssessment> raw) {
  final byId = <String, PlantScanAssessment>{};
  for (final a in raw) {
    if (a.taskId.trim().isEmpty || a.title.trim().isEmpty) continue;
    final existing = byId[a.taskId];
    if (existing == null) {
      byId[a.taskId] = a;
      continue;
    }
    // task wint altijd van let_op; positive verliest van beide.
    final winner = _pickPreferred(existing, a);
    byId[a.taskId] = winner;
  }
  return byId.values.toList();
}

PlantScanAssessment _pickPreferred(
  PlantScanAssessment a,
  PlantScanAssessment b,
) {
  int rank(ScanAssessmentKind k) => switch (k) {
        ScanAssessmentKind.task => 3,
        ScanAssessmentKind.letOp => 2,
        ScanAssessmentKind.positive => 1,
      };
  if (rank(a.kind) >= rank(b.kind)) return a;
  return b;
}

AiPriority _priorityFromAssessment(PlantScanAssessment a) {
  if (!a.visibleOnPhoto) return AiPriority.medium;
  final score = a.scorePercent;
  if (score != null && score < 45) return AiPriority.high;
  return AiPriority.medium;
}

/// Onderwerp-sleutels uit assessments voor deduplicatie met waarschuwingen.
Set<String> assessmentTopicKeys(PlantAiInsightReport? insight) {
  if (insight == null || insight.scanAssessments.isEmpty) return const {};
  final keys = <String>{};
  for (final a in insight.scanAssessments) {
    if (a.kind == ScanAssessmentKind.positive) continue;
    final fromId = semanticTopicKeyForTaskId(a.taskId);
    if (fromId != null) keys.add(fromId);
    final fromTitle = semanticTopicKeyForAction('${a.title} ${a.description}');
    if (fromTitle != null) keys.add(fromTitle);
  }
  return keys;
}

/// Gemiddelde score van positieve assessments (0–100).
int? averagePositiveAssessmentScore(PlantAiInsightReport? insight) {
  if (insight == null) return null;
  final scores = insight.scanAssessments
      .where((a) => a.kind == ScanAssessmentKind.positive)
      .map((a) => a.scorePercent)
      .whereType<int>()
      .map((s) => s.clamp(0, 100))
      .toList();
  if (scores.isEmpty) return null;
  return (scores.reduce((a, b) => a + b) / scores.length).round();
}

List<PlantScanAssessment> letOpAssessments(PlantAiInsightReport? insight) {
  if (insight == null) return const [];
  final taskIds = insight.scanAssessments
      .where((a) => a.kind == ScanAssessmentKind.task)
      .map((a) => a.taskId)
      .toSet();
  return insight.scanAssessments
      .where((a) => a.kind == ScanAssessmentKind.letOp)
      .where((a) => !taskIds.contains(a.taskId))
      .toList();
}
