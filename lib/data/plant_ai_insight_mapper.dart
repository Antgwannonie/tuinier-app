import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';

const _pestCatalog = [
  ('bladluis', 'Bladluis'),
  ('witte_vlieg', 'Witte vlieg'),
  ('spint', 'Spint'),
  ('trips', 'Trips'),
  ('rups', 'Rupsen'),
  ('kever', 'Kevers'),
];

const _diseaseCatalog = [
  ('meeldauw', 'Meeldauw'),
  ('valse_meeldauw', 'Valse meeldauw'),
  ('roest', 'Roest'),
  ('bladvlek', 'Bladvlekkenziekte'),
  ('schimmel', 'Schimmelinfectie'),
];

const _nutrientCatalog = [
  ('stikstof', 'Stikstoftekort'),
  ('magnesium', 'Magnesiumtekort'),
  ('kalium', 'Kaliumtekort'),
  ('ijzer', 'IJzertekort'),
];

/// Parseert het geneste `insight`-object uit AI-JSON.
PlantAiInsightReport? parsePlantAiInsight(Map<String, dynamic> json) {
  final raw = json['insight'];
  if (raw is! Map<String, dynamic>) return null;
  try {
    return PlantAiInsightReport.fromJson(raw);
  } catch (_) {
    return null;
  }
}

/// Verwijdert oogst-signalen voor moestuinbloemen (alleen bloei relevant).
PlantAiInsightReport insightForOrnamentalBloom(PlantAiInsightReport insight) {
  final tasks = insight.coachTasks
      .where((t) => t.kind.toLowerCase() != 'harvest')
      .toList();
  return PlantAiInsightReport(
    summary: insight.summary,
    healthScore: insight.healthScore,
    growthScore: insight.growthScore,
    riskLevel: insight.riskLevel,
    priority: insight.priority,
    pests: insight.pests,
    diseases: insight.diseases,
    waterStatus: insight.waterStatus,
    waterSymptoms: insight.waterSymptoms,
    waterAdvice: insight.waterAdvice,
    nutrients: insight.nutrients,
    growthPhaseDetail:
        insight.growthPhaseDetail == 'oogst' ? 'bloei' : insight.growthPhaseDetail,
    harvestReady: false,
    ripenessNote: insight.floweringNote ?? insight.ripenessNote,
    floweringStatus: insight.floweringStatus,
    floweringNote: insight.floweringNote,
    growthScheduleStatus: insight.growthScheduleStatus,
    growthScheduleWeeksDelta: insight.growthScheduleWeeksDelta,
    growthScheduleNote: insight.growthScheduleNote,
    adjustedHarvestLabel: null,
    pruningAdvice: insight.pruningAdvice,
    weedsDetected: insight.weedsDetected,
    weedsNote: insight.weedsNote,
    sunlightLevel: insight.sunlightLevel,
    sunlightAdvice: insight.sunlightAdvice,
    problems: insight.problems,
    recommendedActions: insight.recommendedActions,
    coachTasks: tasks,
  );
}

/// Vult ontbrekende pest/disease/nutrient rijen aan voor consistente UI.
PlantAiInsightReport normalizeInsight(PlantAiInsightReport insight) {
  final pests = _mergeIssues(insight.pests, _pestCatalog);
  final diseases = _mergeIssues(insight.diseases, _diseaseCatalog);
  final nutrients = _mergeNutrients(insight.nutrients);
  return PlantAiInsightReport(
    summary: insight.summary,
    healthScore: insight.healthScore,
    growthScore: insight.growthScore,
    riskLevel: insight.riskLevel,
    priority: insight.priority,
    pests: pests,
    diseases: diseases,
    waterStatus: insight.waterStatus,
    waterSymptoms: insight.waterSymptoms,
    waterAdvice: insight.waterAdvice,
    nutrients: nutrients,
    growthPhaseDetail: insight.growthPhaseDetail,
    harvestReady: insight.harvestReady,
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
    recommendedActions: insight.recommendedActions,
    coachTasks: insight.coachTasks,
  );
}

List<AiIssueFinding> _mergeIssues(
  List<AiIssueFinding> fromAi,
  List<(String, String)> catalog,
) {
  final byId = {for (final p in fromAi) p.id: p};
  return [
    for (final (id, label) in catalog)
      byId[id] ??
          AiIssueFinding(
            id: id,
            labelNl: label,
            confidencePercent: 0,
            detected: false,
          ),
  ];
}

List<AiNutrientIssue> _mergeNutrients(List<AiNutrientIssue> fromAi) {
  final byId = {for (final n in fromAi) n.id: n};
  return [
    for (final (id, label) in _nutrientCatalog)
      byId[id] ??
          AiNutrientIssue(
            id: id,
            labelNl: label,
            detected: false,
            confidencePercent: 0,
          ),
  ];
}

/// Waarschuwingen voor bel/meldingen — combineert insight + legacy warnings.
List<String> warningsFromInsight(PlantAiInsightReport? insight) {
  if (insight == null) return const [];
  final out = <String>[];
  for (final p in insight.confirmedPests) {
    out.add('Plaag: ${p.labelNl} (${p.confidencePercent}%)');
  }
  for (final d in insight.confirmedDiseases) {
    out.add('Ziekte: ${d.labelNl} (${d.confidencePercent}%)');
  }
  for (final n in insight.confirmedNutrients) {
    out.add('Voeding: ${n.labelNl}');
  }
  if (insight.waterStatus != null &&
      insight.waterStatus != AiWaterStatus.ok) {
    out.add('Water: ${insight.waterStatus!.labelNl}');
  }
  if (insight.weedsDetected == true) {
    out.add('Onkruid: ${insight.weedsNote ?? 'ongewenste planten zichtbaar'}');
  }
  for (final problem in insight.problems) {
    final t = problem.trim();
    if (t.isNotEmpty && !out.contains(t)) out.add(t);
  }
  return out;
}

List<String> mergeAnalysisWarnings({
  required List<String> legacyWarnings,
  PlantAiInsightReport? insight,
}) {
  final insightWarnings = warningsFromInsight(insight);
  final out = <String>[];
  for (final w in legacyWarnings) {
    final t = w.trim();
    if (t.isNotEmpty) out.add(t);
  }
  for (final w in insightWarnings) {
    if (!out.contains(w)) out.add(w);
  }
  return out;
}

/// Oogstdagen verschuiven bij achterstand/voorsprong t.o.v. gemiddelde.
int? adjustHarvestDays({
  required int? daysUntilHarvest,
  PlantAiInsightReport? insight,
}) {
  if (daysUntilHarvest == null || insight == null) return daysUntilHarvest;
  final delta = insight.growthScheduleWeeksDelta;
  final status = insight.growthScheduleStatus;
  if (delta == null || status == null) return daysUntilHarvest;
  if (status == AiGrowthScheduleStatus.behind) {
    return (daysUntilHarvest + delta.abs() * 7).clamp(0, 365);
  }
  if (status == AiGrowthScheduleStatus.ahead) {
    return (daysUntilHarvest - delta.abs() * 7).clamp(0, 365);
  }
  return daysUntilHarvest;
}
