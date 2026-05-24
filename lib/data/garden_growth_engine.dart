import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'garden_plant_schedule.dart';
import 'garden_scan_prefs_store.dart';

enum GrowthScheduleStatus {
  onTrack,
  slightlyBehind,
  delayed,
  unknown,
}

extension GrowthScheduleStatusLabel on GrowthScheduleStatus {
  String get label {
    switch (this) {
      case GrowthScheduleStatus.onTrack:
        return 'Op schema';
      case GrowthScheduleStatus.slightlyBehind:
        return 'Loopt iets achter';
      case GrowthScheduleStatus.delayed:
        return 'Groei vertraagd';
      case GrowthScheduleStatus.unknown:
        return 'Nog geen scan';
    }
  }

  String get emoji {
    switch (this) {
      case GrowthScheduleStatus.onTrack:
        return '🟢';
      case GrowthScheduleStatus.slightlyBehind:
        return '🟠';
      case GrowthScheduleStatus.delayed:
        return '🔴';
      case GrowthScheduleStatus.unknown:
        return '📷';
    }
  }
}

/// Persoonlijke groeiprognose op basis van de laatste AI-foto.
class PlantGrowthInsight {
  const PlantGrowthInsight({
    required this.profile,
    required this.phaseLabel,
    this.daysUntilHarvest,
    required this.harvestWindowLabel,
    required this.confidencePercent,
    required this.healthPercent,
    required this.scheduleStatus,
    required this.summaryLine,
    required this.needsScan,
    this.lastScanAt,
    this.advice,
  });

  final GardenPlantProfile profile;
  final String? phaseLabel;
  final int? daysUntilHarvest;
  final String harvestWindowLabel;
  final int confidencePercent;
  final int healthPercent;
  final GrowthScheduleStatus scheduleStatus;
  final String summaryLine;
  final bool needsScan;
  final DateTime? lastScanAt;
  final String? advice;

  /// Compatibel met oudere UI die `daysUntilNext` gebruikte.
  int? get daysUntilNext => daysUntilHarvest;
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

PlantGrowthInsight? growthInsightFor(
  Vegetable vegetable,
  GardenPlantProfile? profile, [
  DateTime? reference,
  int daysUntilFirstPhoto = GardenScanPrefsStore.defaultDaysUntilFirstPhoto,
]) {
  if (profile == null) return null;

  final analysis = profile.lastAnalysis;
  if (analysis == null) {
    final firstDue = profile.isPlanted
        ? firstPhotoDueDate(
            profile,
            daysUntilFirstPhoto: daysUntilFirstPhoto,
          )
        : null;
    final summary = !profile.isPlanted
        ? 'Vink “geplant” aan zodra het in de grond staat'
        : firstDue != null && DateTime.now().isBefore(firstDue)
            ? 'Eerste foto rond ${firstDue.day}-${firstDue.month}'
            : 'Maak een foto in Plant scan voor een schatting';
    return PlantGrowthInsight(
      profile: profile,
      phaseLabel: null,
      daysUntilHarvest: null,
      harvestWindowLabel: vegetable.harvest,
      confidencePercent: 0,
      healthPercent: 70,
      scheduleStatus: GrowthScheduleStatus.unknown,
      summaryLine: summary,
      needsScan: profile.isPlanted,
    );
  }

  final today = _dateOnly(reference ?? DateTime.now());
  final days = analysis.daysUntilHarvest;
  final scheduleStatus = _scheduleFromAnalysis(analysis, profile, today);

  String summaryLine;
  if (analysis.phase == PlantAiPhase.ripe) {
    summaryLine = 'Klaar om te oogsten';
  } else if (days != null && days <= 0) {
    summaryLine = 'Oogst mogelijk — controleer op de foto';
  } else if (days != null) {
    summaryLine = 'Fase: ${analysis.phaseLabel} · oogst over ±$days dagen';
  } else {
    summaryLine = 'Fase: ${analysis.phaseLabel}';
  }

  final health = switch (scheduleStatus) {
    GrowthScheduleStatus.onTrack => 92,
    GrowthScheduleStatus.slightlyBehind => 72,
    GrowthScheduleStatus.delayed => 55,
    GrowthScheduleStatus.unknown => 70,
  };

  final harvestLabel = profile.predictedHarvestAt != null
      ? '± ${profile.predictedHarvestAt!.day}-${profile.predictedHarvestAt!.month}-${profile.predictedHarvestAt!.year}'
      : analysis.harvestWindowLabel;

  return PlantGrowthInsight(
    profile: profile,
    phaseLabel: analysis.phaseLabel,
    daysUntilHarvest: days,
    harvestWindowLabel: harvestLabel,
    confidencePercent: analysis.confidencePercent,
    healthPercent: health,
    scheduleStatus: scheduleStatus,
    summaryLine: summaryLine,
    needsScan: false,
    lastScanAt: analysis.scannedAt,
    advice: analysis.advice,
  );
}

GrowthScheduleStatus _scheduleFromAnalysis(
  PlantAiAnalysis analysis,
  GardenPlantProfile profile,
  DateTime today,
) {
  if (analysis.phase == PlantAiPhase.ripe) {
    return GrowthScheduleStatus.onTrack;
  }

  final days = analysis.daysUntilHarvest;
  if (days == null) {
    return GrowthScheduleStatus.onTrack;
  }

  final planted = _dateOnly(profile.plantedAt);
  final ageDays = today.difference(planted).inDays;
  if (ageDays > 120 && days > 21) {
    return GrowthScheduleStatus.delayed;
  }
  if (days > 28) {
    return GrowthScheduleStatus.slightlyBehind;
  }
  return GrowthScheduleStatus.onTrack;
}

int compareGrowthInsight(PlantGrowthInsight? a, PlantGrowthInsight? b) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  if (a.needsScan != b.needsScan) {
    return a.needsScan ? 1 : -1;
  }
  final statusOrder = a.scheduleStatus.index.compareTo(b.scheduleStatus.index);
  if (statusOrder != 0) return statusOrder;
  final da = a.daysUntilHarvest ?? 999;
  final db = b.daysUntilHarvest ?? 999;
  return da.compareTo(db);
}
