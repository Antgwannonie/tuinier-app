import 'plant_ai_analysis.dart';

/// Waar de plant staat — beïnvloedt groeisnelheid.
enum GardenLocation {
  outdoor,
  greenhouse,
  windowsill,
  balcony,
}

extension GardenLocationLabel on GardenLocation {
  String get label {
    switch (this) {
      case GardenLocation.outdoor:
        return 'Buiten';
      case GardenLocation.greenhouse:
        return 'Kas / tunnel';
      case GardenLocation.windowsill:
        return 'Vensterbank';
      case GardenLocation.balcony:
        return 'Balkon';
    }
  }
}

/// Zon op de plek van de plant.
enum SunLevel {
  low,
  medium,
  high,
}

extension SunLevelLabel on SunLevel {
  String get label {
    switch (this) {
      case SunLevel.low:
        return 'Weinig zon';
      case SunLevel.medium:
        return 'Gemiddeld';
      case SunLevel.high:
        return 'Veel zon';
    }
  }
}

/// Persoonlijk profiel per gewas in Mijn moestuin.
class GardenPlantProfile {
  const GardenPlantProfile({
    required this.vegetableId,
    required this.plantedAt,
    this.location = GardenLocation.outdoor,
    this.sunLevel = SunLevel.medium,
    this.isPlanted = false,
    this.lastAnalysis,
    this.scanHistory = const [],
    this.predictedHarvestAt,
    this.nextScanDue,
  });

  final String vegetableId;
  final DateTime plantedAt;
  final GardenLocation location;
  final SunLevel sunLevel;

  /// Gebruiker heeft bevestigd dat het gewas in de grond staat.
  final bool isPlanted;
  final PlantAiAnalysis? lastAnalysis;
  final List<PlantAiAnalysis> scanHistory;
  final DateTime? predictedHarvestAt;
  final DateTime? nextScanDue;

  GardenPlantProfile copyWith({
    DateTime? plantedAt,
    GardenLocation? location,
    SunLevel? sunLevel,
    bool? isPlanted,
    PlantAiAnalysis? lastAnalysis,
    bool clearAnalysis = false,
    List<PlantAiAnalysis>? scanHistory,
    DateTime? predictedHarvestAt,
    DateTime? nextScanDue,
    bool clearHarvest = false,
    bool clearNextScan = false,
  }) {
    return GardenPlantProfile(
      vegetableId: vegetableId,
      plantedAt: plantedAt ?? this.plantedAt,
      location: location ?? this.location,
      sunLevel: sunLevel ?? this.sunLevel,
      isPlanted: isPlanted ?? this.isPlanted,
      lastAnalysis:
          clearAnalysis ? null : (lastAnalysis ?? this.lastAnalysis),
      scanHistory: scanHistory ?? this.scanHistory,
      predictedHarvestAt:
          clearHarvest ? null : (predictedHarvestAt ?? this.predictedHarvestAt),
      nextScanDue: clearNextScan ? null : (nextScanDue ?? this.nextScanDue),
    );
  }

  factory GardenPlantProfile.defaults(String vegetableId, [DateTime? planted]) {
    return GardenPlantProfile(
      vegetableId: vegetableId,
      plantedAt: planted ?? DateTime.now(),
      isPlanted: false,
    );
  }

  Map<String, dynamic> toJson() => {
        'vegetableId': vegetableId,
        'plantedAt': plantedAt.toIso8601String(),
        'location': location.name,
        'sunLevel': sunLevel.name,
        'isPlanted': isPlanted,
        if (lastAnalysis != null) 'lastAnalysis': lastAnalysis!.toJson(),
        'scanHistory': scanHistory.map((e) => e.toJson()).toList(),
        if (predictedHarvestAt != null)
          'predictedHarvestAt': predictedHarvestAt!.toIso8601String(),
        if (nextScanDue != null) 'nextScanDue': nextScanDue!.toIso8601String(),
      };

  factory GardenPlantProfile.fromJson(Map<String, dynamic> json) {
    PlantAiAnalysis? analysis;
    final rawAnalysis = json['lastAnalysis'];
    if (rawAnalysis is Map<String, dynamic>) {
      analysis = PlantAiAnalysis.fromJson(rawAnalysis);
    }

    final rawHistory = json['scanHistory'] as List<dynamic>? ?? [];
    final history = rawHistory
        .whereType<Map<String, dynamic>>()
        .map(PlantAiAnalysis.fromJson)
        .toList();

    DateTime? harvestAt;
    final rawHarvest = json['predictedHarvestAt'] as String?;
    if (rawHarvest != null) harvestAt = DateTime.parse(rawHarvest);

    DateTime? nextScan;
    final rawNext = json['nextScanDue'] as String?;
    if (rawNext != null) nextScan = DateTime.parse(rawNext);

    final isPlanted = json['isPlanted'] as bool? ??
        (analysis != null || history.isNotEmpty || rawHarvest != null);

    return GardenPlantProfile(
      vegetableId: json['vegetableId'] as String,
      plantedAt: DateTime.parse(json['plantedAt'] as String),
      location: GardenLocation.values.byName(json['location'] as String),
      sunLevel: SunLevel.values.byName(json['sunLevel'] as String),
      isPlanted: isPlanted,
      lastAnalysis: analysis,
      scanHistory: history,
      predictedHarvestAt: harvestAt,
      nextScanDue: nextScan,
    );
  }
}
