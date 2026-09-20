import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'crop_harvest_kind.dart';
import 'garden_plant_schedule.dart';

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Moestuinbloemen: countdown naar bloei i.p.v. oogst.
bool cropUsesBloomCountdown(Vegetable? vegetable) =>
    vegetable != null && isMoestuinBloomCrop(vegetable);

bool analysisIsInBloom(PlantAiAnalysis analysis) =>
    analysis.phase == PlantAiPhase.flowering ||
    analysis.phaseLabel.toLowerCase().contains('bloei');

/// Dagen bij scan: bloei voor moestuinbloemen, anders oogst.
int? cropCountdownDaysAtScan(
  PlantAiAnalysis analysis,
  Vegetable? vegetable,
) {
  if (cropUsesBloomCountdown(vegetable)) {
    if (analysisIsInBloom(analysis)) return 0;
    return analysis.daysUntilBloom ?? analysis.daysUntilHarvest;
  }
  return analysis.daysUntilHarvest;
}

/// Resterende dagen (kalender telt af sinds scan).
int? remainingCropCountdownDays(
  GardenPlantProfile profile, {
  Vegetable? vegetable,
  DateTime? reference,
}) {
  if (!hasPostPlantAiScan(profile)) return null;
  final analysis = profile.lastAnalysis;
  if (analysis == null) return null;

  if (cropUsesBloomCountdown(vegetable)) {
    final today = _dateOnly(reference ?? DateTime.now());
    final atScan = cropCountdownDaysAtScan(analysis, vegetable);
    if (atScan == null || atScan <= 0) return null;
    final elapsed = today.difference(_dateOnly(analysis.scannedAt)).inDays;
    final left = atScan - elapsed;
    return left > 0 ? left : null;
  }

  return remainingHarvestDays(profile, reference: reference);
}

String cropMilestoneScoreLabel(Vegetable? vegetable) =>
    cropUsesBloomCountdown(vegetable) ? 'Bloeikans' : 'Oogstkans';

String cropMilestoneObservationTitle(Vegetable? vegetable) =>
    cropUsesBloomCountdown(vegetable) ? 'Bloei' : 'Oogstkans';

String moestuinMilestoneTileLabel(Vegetable? vegetable) =>
    cropUsesBloomCountdown(vegetable) ? 'Bloei over' : 'Oogst over';

String formatCropCountdownSummaryLine(
  PlantAiAnalysis analysis,
  Vegetable? vegetable,
) {
  if (cropUsesBloomCountdown(vegetable)) {
    if (analysisIsInBloom(analysis)) {
      return 'Nu in bloei.';
    }
    final days = cropCountdownDaysAtScan(analysis, vegetable);
    if (days != null && days > 0) {
      return 'Geschatte bloei over ±$days dagen.';
    }
    if (analysis.bloomSeasonNote?.trim().isNotEmpty == true) {
      return analysis.bloomSeasonNote!.trim();
    }
    if (analysis.harvestWindowLabel.trim().isNotEmpty) {
      return analysis.harvestWindowLabel.trim();
    }
    return '';
  }

  if (analysis.insight?.harvestReady == true ||
      analysis.daysUntilHarvest == 0) {
    return 'Nu oogsten volgens deze scan.';
  }
  if (analysis.daysUntilHarvest != null && analysis.daysUntilHarvest! > 0) {
    return 'Geschatte oogst over ±${analysis.daysUntilHarvest} dagen.';
  }
  if (analysis.harvestWindowLabel.trim().isNotEmpty) {
    return analysis.harvestWindowLabel.trim();
  }
  return '';
}

String formatCropCountdownChangeLine(PlantAiAnalysis current) {
  if (analysisIsInBloom(current) || current.daysUntilBloom != null) {
    if (analysisIsInBloom(current)) return 'Nu in bloei';
    final days = current.daysUntilBloom ?? current.daysUntilHarvest;
    if (days != null && days > 0) {
      return 'Bloei over ±$days dagen';
    }
  }
  if (current.daysUntilHarvest != null) {
    return current.phase == PlantAiPhase.ripe
        ? 'Klaar om te oogsten'
        : 'Oogst over ±${current.daysUntilHarvest} dagen';
  }
  return '';
}
