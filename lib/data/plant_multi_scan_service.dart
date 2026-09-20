import 'dart:typed_data';

import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'plant_count_scan.dart';
import 'plant_photo_ai_service.dart';

/// Resultaat van een multi-plant scansessie.
class MultiPlantScanResult {
  const MultiPlantScanResult({
    required this.analysis,
    required this.bestPhotoIndex,
  });

  final PlantAiAnalysis analysis;
  final int bestPhotoIndex;
}

/// Analyseert meerdere plantfoto's en kiest de beste voor history + moestuin-kaart.
Future<MultiPlantScanResult> runMultiPlantScan({
  required PlantPhotoAiService service,
  required List<Uint8List> photos,
  required List<ScanPhotoSlot> slots,
  required int plantCount,
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required String mimeType,
  String? plantWindowLabel,
  String? harvestWindowLabel,
  required bool outsidePlantingSeason,
  int? daysSinceStatedPlantDate,
  bool isHarvestProbePhoto = false,
}) async {
  if (photos.isEmpty) {
    throw PlantPhotoAiException('Geen foto\'s om te analyseren.');
  }

  final analyses = <PlantAiAnalysis>[];
  for (var i = 0; i < photos.length; i++) {
    final result = await service.analyze(
      imageBytes: photos[i],
      mimeType: mimeType,
      vegetable: vegetable,
      plantedAt: profile.plantedAt,
      plantingDateUnknown: profile.plantingDateUnknown,
      locationLabel: profile.location.label,
      sunLabel: profile.sunLevel.label,
      outsidePlantingSeason: outsidePlantingSeason,
      plantWindowLabel: plantWindowLabel,
      harvestWindowLabel: harvestWindowLabel,
      daysSinceStatedPlantDate: daysSinceStatedPlantDate,
      previousAnalysis: profile.lastAnalysis,
      previousImageFingerprint: profile.lastScanImageFingerprint,
      isFirstScan: profile.lastAnalysis == null,
      isHarvestProbePhoto: isHarvestProbePhoto,
    );
    analyses.add(result);
  }

  final bestIndex = _pickBestPhotoIndex(analyses, slots);
  final merged = _mergeMultiPlantAnalysis(
    analyses: analyses,
    slots: slots,
    plantCount: plantCount,
    bestIndex: bestIndex,
  );

  return MultiPlantScanResult(
    analysis: merged,
    bestPhotoIndex: bestIndex,
  );
}

int _pickBestPhotoIndex(List<PlantAiAnalysis> analyses, List<ScanPhotoSlot> slots) {
  var bestIndex = 0;
  var bestScore = -0x7fffffff;
  for (var i = 0; i < analyses.length; i++) {
    final slot = i < slots.length ? slots[i] : const ScanPhotoSlot(
      label: '',
      kind: ScanPhotoSlotKind.neutral,
    );
    final score = _scoreAnalysis(analyses[i], slot);
    if (score > bestScore) {
      bestScore = score;
      bestIndex = i;
    }
  }
  return bestIndex;
}

int _scoreAnalysis(PlantAiAnalysis analysis, ScanPhotoSlot slot) {
  if (!analysis.matchesSelectedCrop) return -100000;
  var score = analysis.confidencePercent;
  switch (slot.kind) {
    case ScanPhotoSlotKind.best:
      score += 30;
      break;
    case ScanPhotoSlotKind.worst:
      score -= 25;
      break;
    case ScanPhotoSlotKind.neutral:
      break;
  }
  score -= analysis.warnings.length * 10;
  switch (analysis.healthTrend) {
    case PlantHealthTrend.improved:
      score += 12;
      break;
    case PlantHealthTrend.stable:
      score += 4;
      break;
    case PlantHealthTrend.worse:
      score -= 15;
      break;
    case PlantHealthTrend.unknown:
      break;
  }
  switch (analysis.phase) {
    case PlantAiPhase.fruiting:
    case PlantAiPhase.flowering:
    case PlantAiPhase.growing:
      score += 8;
      break;
    case PlantAiPhase.almostRipe:
    case PlantAiPhase.ripe:
      score += 12;
      break;
    case PlantAiPhase.seedling:
      break;
    case null:
      break;
  }
  return score;
}

PlantAiAnalysis _mergeMultiPlantAnalysis({
  required List<PlantAiAnalysis> analyses,
  required List<ScanPhotoSlot> slots,
  required int plantCount,
  required int bestIndex,
}) {
  final best = analyses[bestIndex];
  final extraWarnings = <String>{};
  final issueNotes = <String>[];

  for (var i = 0; i < analyses.length; i++) {
    if (i == bestIndex) continue;
    final a = analyses[i];
    if (!a.matchesSelectedCrop) continue;
    final slot = i < slots.length ? slots[i] : null;
    for (final w in a.warnings) {
      if (w.trim().isNotEmpty) extraWarnings.add(w.trim());
    }
    if (a.warnings.isNotEmpty && slot != null) {
      issueNotes.add('${slot.label}: ${a.warnings.first}');
    } else if (slot?.kind == ScanPhotoSlotKind.worst &&
        a.healthTrend == PlantHealthTrend.worse) {
      issueNotes.add('${slot!.label} ziet er zwakker uit.');
    }
  }

  final mergedWarnings = [
    ...best.warnings,
    ...extraWarnings.where((w) => !best.warnings.contains(w)),
  ];

  final contextLine = plantCount > 5
      ? 'Steekproef van 5 planten (2 zwakste, 3 mooiste) uit jouw $plantCount ${plantCount == 1 ? 'plant' : 'planten'}.'
      : plantCount > 1
          ? 'Scan van $plantCount planten; de mooiste is opgeslagen op je plantkaart.'
          : null;

  final issueLine = issueNotes.isNotEmpty
      ? ' Ook gezien: ${issueNotes.take(2).join(' ')}'
      : '';

  final advice = [
    best.advice.trim(),
    if (contextLine != null) contextLine,
    if (issueLine.isNotEmpty) issueLine.trim(),
  ].where((s) => s.isNotEmpty).join(' ');

  return best.copyWith(
    advice: advice,
    warnings: mergedWarnings,
  );
}
