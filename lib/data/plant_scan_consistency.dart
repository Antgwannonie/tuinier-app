import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';

/// Snelle vingerafdruk — herkent exact dezelfde fotobestanden.
String fingerprintImageBytes(List<int> bytes) {
  var hash = 5381;
  for (final b in bytes) {
    hash = ((hash << 5) + hash) + b;
  }
  return '${bytes.length}:$hash';
}

String _formatScanDate(DateTime d) =>
    '${d.day.toString().padLeft(2, '0')}-${d.month.toString().padLeft(2, '0')}-${d.year}';

/// Prompttekst wanneer er al een eerdere AI-scan is.
String buildPreviousScanPromptSection(PlantAiAnalysis previous) {
  final days = previous.daysUntilHarvest;
  final bloomDays = previous.daysUntilBloom;
  final daysLine = days == null
      ? 'dagen tot oogst: onbekend / al rijp'
      : 'dagen tot oogst: $days';
  final bloomLine = bloomDays == null
      ? ''
      : '\n- Dagen tot bloei: $bloomDays';
  return '''
BELANGRIJK: vergelijk eerst met de VORIGE scan van dezezelfde plant:
- Datum vorige scan: ${_formatScanDate(previous.scannedAt)}
- Fase: ${previous.phase.name} (${previous.phaseLabel})
- $daysLine$bloomLine
- Oogstvenster: ${previous.harvestWindowLabel}
- Vertrouwen: ${previous.confidencePercent}%
- Advies vorige keer: ${previous.advice}
${previous.insight != null ? '''
- Gezondheidsscore vorige keer: ${previous.insight!.healthScore}/100
- Risico vorige keer: ${previous.insight!.riskLevel.labelNl}
- Problemen vorige keer: ${previous.insight!.problems.join('; ')}
''' : ''}

Stap 1: Bekijk de nieuwe foto. Is dit dezelfde plant op dezelfde plek, ZONDER zichtbare groei of faseverschil t.o.v. de vorige scan?
Stap 2a: Als JA (zelfde stadium) → zet "matchesPreviousScan": true. Gebruik dezelfde phase en phaseLabel. Voor daysUntilHarvest: neem de vorige waarde en trek het aantal kalenderdagen af sinds de vorige scan (minimaal 0). Voor daysUntilBloom: idem. Gebruik hetzelfde harvestWindowLabel en hetzelfde advies (max. 1 kleine zin toevoegen als nodig).
Stap 2b: Als NEE (duidelijk andere fase of andere plant) → zet "matchesPreviousScan": false en geef een nieuwe volledige beoordeling.
Wees streng: bij twijfel tussen bijna hetzelfde → matchesPreviousScan true en weinig wijzigen.
Vergelijk ook gezondheid met vorige scan: is er herstel, achteruitgang of gelijk?
Als vorige scan plaagsignalen had, geef aan of die waarschijnlijk verholpen zijn.
''';
}

bool _phasesMatch(PlantAiPhase a, PlantAiPhase b) => a == b;

bool _isLikelySameStage(
  PlantAiAnalysis previous,
  PlantAiAnalysis incoming,
  int daysSincePrevious,
) {
  if (!_phasesMatch(previous.phase, incoming.phase)) return false;
  final prevDays = previous.daysUntilHarvest;
  final incDays = incoming.daysUntilHarvest;
  if (prevDays == null && incDays == null) return true;
  if (prevDays == null || incDays == null) return false;
  final expected = (prevDays - daysSincePrevious).clamp(0, 365);
  return (incDays - expected).abs() <= 4;
}

/// Houdt oogst en tekst stabiel bij dezelfde foto of hetzelfde stadium.
PlantAiAnalysis reconcileWithPreviousScan({
  required PlantAiAnalysis incoming,
  required PlantAiAnalysis? previous,
  required DateTime scannedAt,
  String? previousImageFingerprint,
  required String currentImageFingerprint,
  bool? aiMatchesPrevious,
}) {
  if (previous == null) return incoming;

  final elapsed =
      scannedAt.difference(_dateOnly(previous.scannedAt)).inDays.clamp(0, 365);
  final sameImage = previousImageFingerprint != null &&
      previousImageFingerprint == currentImageFingerprint;
  final aiSame = aiMatchesPrevious == true;
  final likelySame = _isLikelySameStage(previous, incoming, elapsed);

  if (!sameImage && !aiSame && !likelySame) return incoming;
  if (incoming.hasCropMismatch) return incoming;

  final prevDays = previous.daysUntilHarvest;
  int? stabilizedDays;
  if (previous.phase == PlantAiPhase.ripe) {
    stabilizedDays = 0;
  } else if (prevDays != null) {
    stabilizedDays = (prevDays - elapsed).clamp(0, 365);
  } else {
    stabilizedDays = incoming.daysUntilHarvest;
  }

  final prevBloomDays = previous.daysUntilBloom;
  int? stabilizedBloomDays;
  if (previous.phase == PlantAiPhase.flowering) {
    stabilizedBloomDays = 0;
  } else if (prevBloomDays != null) {
    stabilizedBloomDays = (prevBloomDays - elapsed).clamp(0, 365);
  } else {
    stabilizedBloomDays = incoming.daysUntilBloom;
  }

  final keepAdvice = sameImage && elapsed <= 1;
  final advice = keepAdvice
      ? previous.advice
      : incoming.advice.isEmpty
          ? previous.advice
          : incoming.advice;

  final stabilizationInfo = sameImage
      ? 'Zelfde foto als vorige scan; schatting gelijk gehouden.'
      : aiSame
          ? 'Zelfde plant en fase als vorige scan; schatting afgestemd.'
          : 'Vergelijkbaar met vorige scan; kleine verschillen genegeerd.';

  return PlantAiAnalysis(
    scannedAt: scannedAt,
    phase: previous.phase,
    phaseLabel: previous.phaseLabel,
    daysUntilHarvest: stabilizedDays,
    daysUntilBloom: stabilizedBloomDays,
    harvestWindowLabel: previous.harvestWindowLabel,
    confidencePercent: previous.confidencePercent,
    advice: advice,
    warnings: incoming.warnings,
    matchedPrevious: true,
    comparisonNote: incoming.comparisonNote?.trim().isNotEmpty == true
        ? incoming.comparisonNote
        : stabilizationInfo,
    harvestStillPossibleThisSeason: incoming.harvestStillPossibleThisSeason ??
        previous.harvestStillPossibleThisSeason,
    seasonTimingWarning:
        incoming.seasonTimingWarning ?? previous.seasonTimingWarning,
    estimatedWeeksGrowing:
        incoming.estimatedWeeksGrowing ?? previous.estimatedWeeksGrowing,
    plantedDateMatchesPhoto: incoming.plantedDateMatchesPhoto ??
        previous.plantedDateMatchesPhoto,
    datePhotoComparisonNote:
        incoming.datePhotoComparisonNote ?? previous.datePhotoComparisonNote,
    expectedWeeksFromStatedDate: incoming.expectedWeeksFromStatedDate ??
        previous.expectedWeeksFromStatedDate,
    matchesSelectedCrop: incoming.matchesSelectedCrop,
    detectedPlantLabel:
        incoming.detectedPlantLabel ?? previous.detectedPlantLabel,
    cropMismatchWarning:
        incoming.cropMismatchWarning ?? previous.cropMismatchWarning,
    healthImprovedSincePrevious: incoming.healthImprovedSincePrevious,
    pestLikelyResolvedSincePrevious: incoming.pestLikelyResolvedSincePrevious,
    healthComparisonNote:
        incoming.healthComparisonNote ?? previous.healthComparisonNote,
    healthTrend: incoming.healthTrend,
    insight: incoming.insight ?? previous.insight,
  );
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);
