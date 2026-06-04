import '../models/plant_ai_analysis.dart';

/// Minimale betrouwbaarheid om een scan in de geschiedenis te bewaren.
const int kMinScanConfidenceToPersist = 55;

/// Of deze AI-scan het profiel en de scanhistorie mag bijwerken.
bool shouldPersistAiScan(PlantAiAnalysis analysis) {
  if (!analysis.matchesSelectedCrop || analysis.hasCropMismatch) {
    return false;
  }
  if (_phaseIndicatesWrongCrop(analysis.phaseLabel)) {
    return false;
  }
  if (isUnrecognizedPlantLabel(analysis.detectedPlantLabel)) {
    return false;
  }
  if (analysis.confidencePercent < kMinScanConfidenceToPersist) {
    return false;
  }
  if (_adviceIndicatesRescanOnly(analysis)) {
    return false;
  }
  return true;
}

/// Korte NL-uitleg waarom de scan niet is opgeslagen (null = wel opgeslagen).
String? scanNotPersistedMessage(PlantAiAnalysis analysis) {
  if (!analysis.matchesSelectedCrop || analysis.hasCropMismatch) {
    final detail = analysis.cropMismatchWarning?.trim();
    if (detail != null && detail.isNotEmpty) {
      return 'Scan niet opgeslagen: $detail';
    }
    return 'Scan niet opgeslagen: dit lijkt niet het juiste gewas op de foto. '
        'Kies de juiste plant en scan opnieuw.';
  }
  if (_phaseIndicatesWrongCrop(analysis.phaseLabel)) {
    return 'Scan niet opgeslagen: verkeerd gewas op de foto.';
  }
  if (isUnrecognizedPlantLabel(analysis.detectedPlantLabel)) {
    return 'Scan niet opgeslagen: de plant kon niet betrouwbaar worden herkend. '
        'Maak een scherpere foto of kies het juiste gewas.';
  }
  if (analysis.confidencePercent < kMinScanConfidenceToPersist) {
    return 'Scan niet opgeslagen: betrouwbaarheid te laag '
        '(${analysis.confidencePercent}%). Probeer een duidelijkere foto.';
  }
  if (_adviceIndicatesRescanOnly(analysis)) {
    return 'Scan niet opgeslagen: geen bruikbaar resultaat. Scan opnieuw met '
        'een duidelijke foto van je plant.';
  }
  return null;
}

bool _phaseIndicatesWrongCrop(String phaseLabel) {
  final p = phaseLabel.toLowerCase();
  return p.contains('verkeerd gewas');
}

/// Eerste scan van zaadbed/grond telt niet als "onbekend".
bool isUnrecognizedPlantLabel(String? label) {
  final l = label?.toLowerCase().trim() ?? '';
  if (l.isEmpty) return false;

  const allowed = [
    'zaadbed',
    'grond',
    'plantplek',
    'mulch',
    'aarde',
    'potgrond',
    'zaai',
  ];
  if (allowed.any((a) => l.contains(a))) return false;

  const blocked = [
    'onbekend',
    'unknown',
    'niet herken',
    'niet te herken',
    'geen plant',
    'onduidelijk',
    'unclear',
    'niet identificeer',
  ];
  return blocked.any((b) => l.contains(b));
}

bool _adviceIndicatesRescanOnly(PlantAiAnalysis analysis) {
  final advice = analysis.advice.toLowerCase();
  final summary = analysis.insight?.summary.toLowerCase() ?? '';
  final combined = '$advice $summary';
  if (combined.trim().isEmpty) return true;

  const rescanOnly = [
    'scan opnieuw',
    'kies het juiste gewas',
    'kies de juiste plant',
    'geen bruikbaar',
    'niet te beoordelen',
  ];
  final wantsRescan = rescanOnly.any((p) => combined.contains(p));
  if (!wantsRescan) return false;

  final hasUsefulInsight = analysis.insight != null &&
      (analysis.insight!.healthScore >= 40 ||
          analysis.insight!.confirmedPests.isNotEmpty ||
          analysis.insight!.confirmedDiseases.isNotEmpty ||
          analysis.insight!.problems.isNotEmpty);

  return !hasUsefulInsight &&
      analysis.daysUntilHarvest == null &&
      analysis.phase == PlantAiPhase.growing &&
      analysis.confidencePercent < 65;
}
