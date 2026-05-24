/// Fase zoals door de AI op de foto herkend.
enum PlantAiPhase {
  seedling,
  growing,
  flowering,
  fruiting,
  almostRipe,
  ripe,
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
    required this.harvestWindowLabel,
    required this.confidencePercent,
    required this.advice,
    this.warnings = const [],
  });

  final DateTime scannedAt;
  final PlantAiPhase phase;
  final String phaseLabel;
  final int? daysUntilHarvest;
  final String harvestWindowLabel;
  final int confidencePercent;
  final String advice;
  final List<String> warnings;

  Map<String, dynamic> toJson() => {
        'scannedAt': scannedAt.toIso8601String(),
        'phase': phase.name,
        'phaseLabel': phaseLabel,
        'daysUntilHarvest': daysUntilHarvest,
        'harvestWindowLabel': harvestWindowLabel,
        'confidencePercent': confidencePercent,
        'advice': advice,
        'warnings': warnings,
      };

  factory PlantAiAnalysis.fromJson(Map<String, dynamic> json) {
    final phaseRaw = json['phase'] as String?;
    final phase = PlantAiPhase.values.byName(phaseRaw ?? 'growing');
    return PlantAiAnalysis(
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      phase: phase,
      phaseLabel: json['phaseLabel'] as String? ?? phase.label,
      daysUntilHarvest: json['daysUntilHarvest'] as int?,
      harvestWindowLabel: json['harvestWindowLabel'] as String? ?? '',
      confidencePercent: (json['confidencePercent'] as num?)?.toInt() ?? 70,
      advice: json['advice'] as String? ?? '',
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }
}
