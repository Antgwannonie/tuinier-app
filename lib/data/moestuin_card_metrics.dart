import 'package:flutter/material.dart';

import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import 'crop_bloom_countdown.dart';
import 'crop_lifecycle_metadata.dart';
import 'garden_growth_engine.dart';
import 'garden_plant_schedule.dart';
import 'garden_scan_prefs_store.dart';
import 'moestuin_pinned_action.dart';
import 'plant_ai_insight_mapper.dart';
import 'plant_health_warnings.dart';
import 'plant_lifecycle.dart';
import 'plant_pending_planting.dart';
import 'plant_scheduled_actions.dart';
import 'scan_assessment_sync.dart';
import 'plant_season_activation.dart';
import 'plant_start_flow.dart';

enum MoestuinMetricTileMode {
  inactive,
  countdown,
  actionReady,
  needsAttention,
}

/// Weergavegegevens voor de nieuwe moestuin-plantkaart.
class MoestuinCardMetrics {
  const MoestuinCardMetrics({
    required this.healthPercent,
    required this.healthBadgeLabel,
    required this.phaseLabel,
    required this.phaseDetail,
    required this.phaseIcon,
    required this.growthScoreLabel,
    required this.growthScoreColor,
    required this.growthScoreDetail,
    required this.healthDetailLines,
    required this.harvestValue,
    this.harvestDays,
    required this.harvestMode,
    required this.harvestReady,
    required this.scanValue,
    this.scanDays,
    required this.scanMode,
    required this.scanReady,
    required this.openTaskCount,
    required this.tasksValue,
  });

  final int? healthPercent;
  final String healthBadgeLabel;
  final String phaseLabel;
  final String phaseDetail;
  final IconData phaseIcon;
  final String growthScoreLabel;
  final Color growthScoreColor;
  final String growthScoreDetail;
  final List<String> healthDetailLines;
  final String harvestValue;
  final int? harvestDays;
  final MoestuinMetricTileMode harvestMode;
  final bool harvestReady;
  final String scanValue;
  final int? scanDays;
  final MoestuinMetricTileMode scanMode;
  final bool scanReady;
  final int openTaskCount;
  final String tasksValue;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

String _shortPhase(String phaseLabel) {
  final p = phaseLabel.toLowerCase();
  if (p.contains('zaad') || p.contains('zaail')) return 'Zaailing';
  if (p.contains('bloei')) return 'Bloei';
  if (p.contains('vrucht')) return 'Vruchten';
  if (p.contains('oogst') || p.contains('rijp')) return 'Oogstbaar';
  if (p.contains('groei')) return 'Groei';
  if (p.contains('voorgezaaid')) return 'Voorgezaaid';
  if (p.contains('niet gezaaid')) return 'Niet gezaaid';
  if (p.contains('geen scan')) return 'Geen scan';
  return phaseLabel;
}

String _shortGrowthScoreForCard(String label) {
  final l = label.toLowerCase();
  if (l.contains('voor op')) return 'Voor schema';
  if (l.contains('achter op') || l.contains('iets achter')) return 'Loopt achter';
  if (l.contains('vertraagd')) return 'Vertraagd';
  if (l.contains('onduidelijk')) return 'Onbekend';
  if (l.contains('niet gezaaid')) return 'Niet gezaaid';
  if (l.contains('geen scan')) return 'Geen scan';
  return label;
}

IconData _phaseIcon(String phaseLabel) {
  if (phaseLabel.trim().isEmpty) return Icons.grass_outlined;
  final p = phaseLabel.toLowerCase();
  if (p.contains('zaaien')) return Icons.grass_outlined;
  if (p.contains('zaad') || p.contains('zaail')) return Icons.grass_outlined;
  if (p.contains('bloei')) return Icons.local_florist_outlined;
  if (p.contains('vrucht')) return Icons.eco_outlined;
  if (p.contains('oogst') || p.contains('rijp')) {
    return Icons.agriculture_outlined;
  }
  return Icons.trending_up_rounded;
}

String _healthBadgeLabel(int? percent, PlantWarningHighlightLevel level) {
  if (level == PlantWarningHighlightLevel.danger) return 'Zorg nodig';
  if (level == PlantWarningHighlightLevel.warning) return 'Aandacht';
  if (percent == null) return 'Nog geen scan';
  if (percent >= 85) return 'Gezond';
  if (percent >= 65) return 'Aandacht';
  return 'Zorg nodig';
}

/// Badge onder gezondheidsring (moestuin + scanresultaat).
String moestuinPlantHealthBadgeLabel(
  int percent,
  PlantWarningHighlightLevel level,
) =>
    _healthBadgeLabel(percent, level);

PlantWarningHighlightLevel plantWarningHighlightLevelForAnalysis({
  required PlantAiAnalysis analysis,
  GardenPlantProfile? profile,
  Vegetable? vegetable,
}) {
  if (profile != null && vegetable != null) {
    return plantWarningHighlightLevel(
      profile: profile,
      vegetable: vegetable,
    );
  }
  if (warningsFromInsight(analysis.insight).isNotEmpty) {
    return PlantWarningHighlightLevel.danger;
  }
  for (final w in analysis.warnings) {
    if (w.trim().isNotEmpty) {
      return PlantWarningHighlightLevel.warning;
    }
  }
  return PlantWarningHighlightLevel.none;
}

/// Gemiddelde score (0–100) van positieve scan-beoordelingen of AI-observaties.
int? averageVisualObservationScore(PlantAiInsightReport? insight) {
  if (insight == null) return null;
  final positiveAverage = averagePositiveAssessmentScore(insight);
  if (positiveAverage != null) return positiveAverage;
  if (insight.visualObservations.isEmpty) return null;
  final scores = insight.visualObservations
      .map((o) => o.scorePercent.clamp(0, 100))
      .toList();
  if (scores.isEmpty) return null;
  final sum = scores.fold<int>(0, (total, score) => total + score);
  return (sum / scores.length).round().clamp(0, 100);
}

/// Gezondheidsscore op plantkaart — gemiddelde van AI-observatiescores.
int moestuinPlantHealthPercent({
  required PlantAiAnalysis analysis,
  Vegetable? vegetable,
  GardenPlantProfile? profile,
}) {
  final insight = analysis.insight;
  final observationAverage = averageVisualObservationScore(insight);
  if (observationAverage != null) {
    return observationAverage;
  }

  final level = plantWarningHighlightLevelForAnalysis(
    analysis: analysis,
    profile: profile,
    vegetable: vegetable,
  );
  if (insight != null) {
    var score = insight.healthScore.clamp(0, 100);
    if (level == PlantWarningHighlightLevel.danger) {
      score = score.clamp(0, 58);
    } else if (level == PlantWarningHighlightLevel.warning) {
      score = score.clamp(0, 78);
    }
    return score;
  }
  if (level == PlantWarningHighlightLevel.danger) return 58;
  if (level == PlantWarningHighlightLevel.warning) return 78;
  return analysis.confidencePercent.clamp(75, 98);
}

int? _healthPercent(Vegetable vegetable, GardenPlantProfile? profile) {
  if (profile?.lastAnalysis == null) return null;
  return moestuinPlantHealthPercent(
    analysis: profile!.lastAnalysis!,
    vegetable: vegetable,
    profile: profile,
  );
}

List<String> _healthDetailLines({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
  DateTime? reference,
}) {
  if (profile != null &&
      isMoestuinOffSeasonWaiting(
        profile: profile,
        vegetable: vegetable,
        reference: reference,
      )) {
    final days = daysUntilMoestuinPlantingSeason(
      vegetable: vegetable,
      profile: profile,
      reference: reference,
    );
    if (days == null || days <= 0) {
      return const [
        'Het zaai- of plantseizoen is begonnen. Je kunt nu starten met taken.',
      ];
    }
    final timing = days == 1 ? 'over 1 dag' : 'over $days dagen';
    return [
      'Het zaai- of plantseizoen is nog niet begonnen ($timing). '
          'Na je eerste scan volgt gezondheidsadvies.',
    ];
  }
  if (profile?.lastAnalysis == null) {
    return const [
      'Maak een scan om gezondheid, plagen en water te beoordelen.',
    ];
  }
  final insight = profile!.lastAnalysis!.insight;
  final lines = <String>[];
  if (insight?.summary.isNotEmpty == true) {
    lines.add(insight!.summary);
  }
  for (final w in activeAiWarningsFor(profile)) {
    if (!lines.contains(w)) lines.add(w);
  }
  for (final w in activeSeasonWarningsFor(profile: profile, vegetable: vegetable)) {
    if (!lines.contains(w)) lines.add(w);
  }
  if (insight?.waterAdvice?.isNotEmpty == true) {
    lines.add(insight!.waterAdvice!);
  }
  if (insight?.sunlightAdvice?.isNotEmpty == true) {
    lines.add(insight!.sunlightAdvice!);
  }
  if (lines.isEmpty) {
    lines.add('De plant ziet er gezond uit volgens de laatste scan.');
  }
  return lines;
}

Color _growthScoreColor(
  AiGrowthScheduleStatus? aiStatus,
  GrowthScheduleStatus fallback,
) {
  final status = aiStatus;
  if (status != null && status != AiGrowthScheduleStatus.unknown) {
    return switch (status) {
      AiGrowthScheduleStatus.ahead => TuinierColors.success,
      AiGrowthScheduleStatus.onTrack => TuinierColors.success,
      AiGrowthScheduleStatus.behind => TuinierColors.warning,
      AiGrowthScheduleStatus.unknown => TuinierColors.textSecondary,
    };
  }
  return switch (fallback) {
    GrowthScheduleStatus.onTrack => TuinierColors.success,
    GrowthScheduleStatus.slightlyBehind => TuinierColors.warning,
    GrowthScheduleStatus.delayed => TuinierColors.error,
    GrowthScheduleStatus.unknown => TuinierColors.textSecondary,
  };
}

String _growthScoreLabel({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
  required PlantGrowthInsight? insight,
}) {
  if (profile != null &&
      isMoestuinOffSeasonWaiting(profile: profile, vegetable: vegetable)) {
    return 'Nog niet gestart';
  }
  if (profile?.lastAnalysis == null) return '—';
  final aiStatus = profile?.lastAnalysis?.insight?.growthScheduleStatus;
  if (aiStatus != null && aiStatus != AiGrowthScheduleStatus.unknown) {
    return _shortGrowthScoreForCard(aiStatus.labelNl);
  }
  if (insight != null) {
    return _shortGrowthScoreForCard(insight.scheduleStatus.label);
  }
  if (profile == null || !profile.isPlanted) return '—';
  return '—';
}

String _growthScoreDetail({
  required GardenPlantProfile? profile,
  required PlantGrowthInsight? insight,
}) {
  final ai = profile?.lastAnalysis?.insight;
  if (ai?.growthScheduleNote?.isNotEmpty == true) {
    return ai!.growthScheduleNote!;
  }
  if (ai?.growthScheduleStatus == AiGrowthScheduleStatus.behind) {
    return 'De plant loopt achter op schema voor dit seizoen. '
        'Controleer licht, water en voeding.';
  }
  if (ai?.growthScheduleStatus == AiGrowthScheduleStatus.onTrack) {
    return 'De plant groeit op tempo voor een normale oogst dit seizoen.';
  }
  if (insight?.advice?.isNotEmpty == true) return insight!.advice!;
  if (profile?.lastAnalysis == null) {
    return 'Scan de plant om groei en schema te beoordelen.';
  }
  return 'Groei lijkt normaal; scan opnieuw bij twijfel.';
}

/// Groene badge op de plantkaart: eerst de volgende taak, daarna gezondheid.
String _cardGreenBadgeLabel({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  required int? healthPercent,
  required PlantWarningHighlightLevel warningLevel,
  int? month,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();

  if (profile != null && !profile.isMoestuinActive) {
    if (profile.inactiveReason == PlantMoestuinInactiveReason.offSeason ||
        isMoestuinOffSeasonWaiting(
          profile: profile,
          vegetable: vegetable,
          reference: ref,
        )) {
      return pendingPlantingTaskLabel(
        vegetable: vegetable,
        profile: profile,
      );
    }
    return 'Niet actief';
  }

  if (profile == null || !hasPostPlantAiScan(profile)) {
    return moestuinPreScanGreenBadgeLabel(
      vegetable: vegetable,
      profile: profile,
      scanPrefs: scanPrefs,
      month: month,
      reference: ref,
    );
  }

  return _healthBadgeLabel(healthPercent, warningLevel);
}

String _phaseLabel(Vegetable vegetable, GardenPlantProfile? profile) {
  if (profile != null &&
      profile.isPlanted &&
      awaitingFirstPhotoScan(profile)) {
    return kFirstScanCardLabel;
  }
  if (profile != null &&
      !profile.isPlanted &&
      hasPendingPlantingTask(vegetable: vegetable, profile: profile)) {
    return pendingPlantingTaskLabel(
      vegetable: vegetable,
      profile: profile,
    );
  }
  if (profile == null) return '';
  if (!profile.isMoestuinActive &&
      !isMoestuinOffSeasonWaiting(
        profile: profile,
        vegetable: vegetable,
      )) {
    return '';
  }
  final analysis = profile.lastAnalysis;
  if (analysis == null) return '';
  return _shortPhase(analysis.phaseLabel);
}

String _phaseDetail(Vegetable vegetable, GardenPlantProfile? profile) {
  if (profile != null &&
      !profile.isPlanted &&
      hasPendingPlantingTask(vegetable: vegetable, profile: profile)) {
    final steps = buildPlantingTaskFirstSteps(
      vegetable: vegetable,
      profile: profile,
    );
    return steps.steps.join('\n\n');
  }
  if (profile?.lastAnalysis == null) {
    if (profile != null && profile.isPlanted) {
      return 'Maak je eerste scan. Daarna verschijnt hier de groeifase van je plant.';
    }
    return 'De fase wordt zichtbaar na je eerste scan, zodra je plant staat.';
  }
  final analysis = profile!.lastAnalysis!;
  final insight = analysis.insight;
  final parts = <String>[
    if (insight?.growthPhaseDetail?.isNotEmpty == true)
      insight!.growthPhaseDetail!
    else
      'Geschatte fase: ${analysis.phaseLabel}.',
    if (analysis.fruitHarvestNote?.isNotEmpty == true)
      analysis.fruitHarvestNote!,
    if (insight?.floweringNote?.isNotEmpty == true) insight!.floweringNote!,
    if (insight?.ripenessNote?.isNotEmpty == true) insight!.ripenessNote!,
  ];
  return parts.join('\n\n');
}

({
  String value,
  int? days,
  MoestuinMetricTileMode mode,
  bool ready,
}) _harvestMetric({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  DateTime? reference,
}) {
  if (profile == null || !profile.isPlanted || !profile.isMoestuinActive) {
    return (
      value: '—',
      days: null,
      mode: MoestuinMetricTileMode.inactive,
      ready: false,
    );
  }
  if (!canUseAiHarvestAssessment(profile, vegetable: vegetable)) {
    return (
      value: 'Scan nodig',
      days: null,
      mode: MoestuinMetricTileMode.needsAttention,
      ready: false,
    );
  }
  if (isReadyToHarvest(profile, vegetable: vegetable) ||
      isHomeHarvestActionDue(profile, vegetable: vegetable)) {
    return (
      value: cropUsesBloomCountdown(vegetable) ? 'In bloei' : 'Oogsten',
      days: 0,
      mode: MoestuinMetricTileMode.actionReady,
      ready: true,
    );
  }
  if (cropUsesBloomCountdown(vegetable) &&
      profile.lastAnalysis != null &&
      analysisIsInBloom(profile.lastAnalysis!)) {
    return (
      value: 'In bloei',
      days: 0,
      mode: MoestuinMetricTileMode.actionReady,
      ready: true,
    );
  }
  final days = remainingCropCountdownDays(
    profile,
    vegetable: vegetable,
    reference: reference,
  );
  if (days != null && days > 0) {
    return (
      value: days == 1 ? '1 dag' : '$days dagen',
      days: days,
      mode: MoestuinMetricTileMode.countdown,
      ready: false,
    );
  }
  final countdown = shortHarvestWindowLabel(
    profile.lastAnalysis?.harvestWindowLabel ?? '',
  );
  if (countdown != null) {
    return (
      value: countdown,
      days: days,
      mode: MoestuinMetricTileMode.countdown,
      ready: false,
    );
  }
  return (
    value: 'Binnenkort',
    days: 0,
    mode: MoestuinMetricTileMode.countdown,
    ready: false,
  );
}

({
  String value,
  int? days,
  MoestuinMetricTileMode mode,
  bool ready,
}) _scanMetric({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  DateTime? reference,
}) {
  if (profile != null &&
      isMoestuinOffSeasonWaiting(
        profile: profile,
        vegetable: vegetable,
        reference: reference,
      )) {
    final days = daysUntilMoestuinPlantingSeason(
      vegetable: vegetable,
      profile: profile,
      reference: reference,
    );
    if (days != null && days > 0) {
      return (
        value: days == 1 ? '1 dag' : '$days dagen',
        days: days,
        mode: MoestuinMetricTileMode.countdown,
        ready: false,
      );
    }
    return (
      value: 'Nu starten',
      days: 0,
      mode: MoestuinMetricTileMode.countdown,
      ready: false,
    );
  }

  if (profile == null || !profile.isPlanted || !profile.isMoestuinActive) {
    return (
      value: '—',
      days: null,
      mode: MoestuinMetricTileMode.inactive,
      ready: false,
    );
  }

  final today = _dateOnly(reference ?? DateTime.now());

  if (awaitingFirstPhotoScan(profile)) {
    final due = firstPhotoDueDate(
      profile,
      daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
    );
    final days = _dateOnly(due).difference(today).inDays;
    final ready = days <= 0 ||
        needsFirstPhoto(
          profile,
          daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
        );
    return (
      value: kFirstScanCardLabel,
      days: days > 0 ? days : 0,
      mode: ready
          ? MoestuinMetricTileMode.actionReady
          : MoestuinMetricTileMode.countdown,
      ready: ready,
    );
  }

  if (profile.lastAnalysis == null) {
    return (
      value: kFirstScanCardLabel,
      days: 0,
      mode: MoestuinMetricTileMode.actionReady,
      ready: true,
    );
  }

  if (needsWeeklyScan(profile)) {
    return (
      value: 'Scan nu',
      days: 0,
      mode: MoestuinMetricTileMode.actionReady,
      ready: true,
    );
  }

  final due = profile.nextScanDue;
  if (due == null) {
    final scanned = profile.lastAnalysis?.scannedAt;
    if (scanned != null) {
      final next = _dateOnly(scanned)
          .add(Duration(days: scanPrefs.weeklyScanIntervalDays));
      final days = _dateOnly(next).difference(today).inDays;
      if (days > 0) {
        return (
          value: days == 1 ? '1 dag' : '$days dagen',
          days: days,
          mode: MoestuinMetricTileMode.countdown,
          ready: false,
        );
      }
    }
    return (
      value: 'Scan nu',
      days: 0,
      mode: MoestuinMetricTileMode.actionReady,
      ready: true,
    );
  }

  final days = _dateOnly(due).difference(today).inDays;
  if (days <= 0) {
    return (
      value: 'Scan nu',
      days: 0,
      mode: MoestuinMetricTileMode.actionReady,
      ready: true,
    );
  }
  return (
    value: days == 1 ? '1 dag' : '$days dagen',
    days: days,
    mode: MoestuinMetricTileMode.countdown,
    ready: false,
  );
}

MoestuinCardMetrics computeMoestuinCardMetrics({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();
  final actions = moestuinCardActions(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    month: month,
    reference: ref,
  );
  final insight = growthInsightFor(
    vegetable,
    profile,
    ref,
    scanPrefs.daysUntilFirstPhoto,
  );
  final warningLevel = plantWarningHighlightLevel(
    profile: profile,
    vegetable: vegetable,
  );
  final health = _healthPercent(vegetable, profile);
  final offSeasonWaiting = profile != null &&
      isMoestuinOffSeasonWaiting(
        profile: profile,
        vegetable: vegetable,
        reference: ref,
      );
  final phase = _phaseLabel(vegetable, profile);
  final harvest = _harvestMetric(
    vegetable: vegetable,
    profile: profile,
    reference: ref,
  );
  final scan = _scanMetric(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    reference: ref,
  );
  final taskCount =
      actions.where((a) => isPlantTaskScheduledActionKind(a.kind)).length;
  final infoCount =
      actions.where((a) => isPlantInfoScheduledActionKind(a.kind)).length;
  final openItemCount = taskCount + infoCount;
  final tasksValue = openItemCount == 0 && offSeasonWaiting
      ? moestuinOffSeasonCountdownLabel(
          vegetable: vegetable,
          profile: profile,
          reference: ref,
        )
      : taskCount == 0 &&
              profile != null &&
              !profile.isMoestuinActive &&
              profile.inactiveReason == PlantMoestuinInactiveReason.offSeason
          ? moestuinInactiveNextSeasonLabel(
              profile: profile,
              vegetable: vegetable,
              reference: ref,
            )
          : openItemCount == 0
              ? 'Geen items'
              : formatTasksAndInfoCount(
                  taskCount: taskCount,
                  infoCount: infoCount,
                );

  return MoestuinCardMetrics(
    healthPercent: health,
    healthBadgeLabel: _cardGreenBadgeLabel(
      vegetable: vegetable,
      profile: profile,
      scanPrefs: scanPrefs,
      healthPercent: health,
      warningLevel: warningLevel,
      month: month,
      reference: ref,
    ),
    phaseLabel: phase,
    phaseDetail: _phaseDetail(vegetable, profile),
    phaseIcon: _phaseIcon(phase),
    growthScoreLabel: _growthScoreLabel(
      profile: profile,
      vegetable: vegetable,
      insight: insight,
    ),
    growthScoreColor: _growthScoreColor(
      profile?.lastAnalysis?.insight?.growthScheduleStatus,
      insight?.scheduleStatus ?? GrowthScheduleStatus.unknown,
    ),
    growthScoreDetail: _growthScoreDetail(
      profile: profile,
      insight: insight,
    ),
    healthDetailLines: _healthDetailLines(
      profile: profile,
      vegetable: vegetable,
      reference: ref,
    ),
    harvestValue: harvest.value,
    harvestDays: harvest.days,
    harvestMode: harvest.mode,
    harvestReady: harvest.ready,
    scanValue: scan.value,
    scanDays: scan.days,
    scanMode: scan.mode,
    scanReady: scan.ready,
    openTaskCount: openItemCount,
    tasksValue: tasksValue,
  );
}
