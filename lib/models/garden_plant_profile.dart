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
    this.lastScanImageFingerprint,
    this.lastScanPhotoPath,
    this.scanPhotoPaths = const [],
    this.plantHealthAcknowledged = false,
    this.plantingDateUnknown = false,
    this.warningsDismissedFromBell = false,
    this.harvestedPercent = 0,
    this.archivedAt,
    this.moestuinBatchId,
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

  /// Vingerafdruk van de laatste scanfoto (zelfde foto herkennen).
  final String? lastScanImageFingerprint;

  /// Laatste opgeslagen scanfoto (lokaal pad).
  final String? lastScanPhotoPath;

  /// Paden van opgeslagen scans, zelfde volgorde als [scanHistory].
  final List<String> scanPhotoPaths;

  /// Gebruiker heeft actie ondernomen op AI-waarschuwingen (verbergt melding).
  final bool plantHealthAcknowledged;

  /// Zaai-/plantdatum is onbekend; geen kalenderwaarschuwing op ingevulde datum.
  final bool plantingDateUnknown;

  /// Verborgen in meldingen-bel; op plantdetail blijft zichtbaar tot afgehandeld.
  final bool warningsDismissedFromBell;

  /// Oogstvoortgang voor dit gewas (0..100).
  final int harvestedPercent;

  /// Gezet wanneer het gewas uit de actieve moestuin gaat (history).
  final DateTime? archivedAt;

  /// Zelfde id voor alle planten bij «Maak nieuwe moestuin» (herstel in één keer).
  final String? moestuinBatchId;

  bool get isArchived => archivedAt != null;

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
    String? lastScanImageFingerprint,
    bool clearScanFingerprint = false,
    String? lastScanPhotoPath,
    bool clearLastScanPhoto = false,
    List<String>? scanPhotoPaths,
    bool? plantHealthAcknowledged,
    bool? plantingDateUnknown,
    bool? warningsDismissedFromBell,
    int? harvestedPercent,
    DateTime? archivedAt,
    bool clearArchivedAt = false,
    String? moestuinBatchId,
    bool clearMoestuinBatchId = false,
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
      lastScanImageFingerprint: clearScanFingerprint
          ? null
          : (lastScanImageFingerprint ?? this.lastScanImageFingerprint),
      lastScanPhotoPath: clearLastScanPhoto
          ? null
          : (lastScanPhotoPath ?? this.lastScanPhotoPath),
      scanPhotoPaths: scanPhotoPaths ?? this.scanPhotoPaths,
      plantHealthAcknowledged:
          plantHealthAcknowledged ?? this.plantHealthAcknowledged,
      plantingDateUnknown:
          plantingDateUnknown ?? this.plantingDateUnknown,
      warningsDismissedFromBell:
          warningsDismissedFromBell ?? this.warningsDismissedFromBell,
      harvestedPercent: harvestedPercent ?? this.harvestedPercent,
      archivedAt: clearArchivedAt ? null : (archivedAt ?? this.archivedAt),
      moestuinBatchId: clearMoestuinBatchId
          ? null
          : (moestuinBatchId ?? this.moestuinBatchId),
    );
  }

  factory GardenPlantProfile.defaults(String vegetableId, [DateTime? planted]) {
    return GardenPlantProfile(
      vegetableId: vegetableId,
      plantedAt: planted ?? DateTime.now(),
      isPlanted: false,
    );
  }

  /// Kopie voor opnieuw starten in Mijn moestuin; history-profiel blijft ongewijzigd.
  GardenPlantProfile freshSeasonCopy() {
    return GardenPlantProfile(
      vegetableId: vegetableId,
      plantedAt: DateTime.now(),
      location: location,
      sunLevel: sunLevel,
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
        if (lastScanImageFingerprint != null)
          'lastScanImageFingerprint': lastScanImageFingerprint,
        if (lastScanPhotoPath != null) 'lastScanPhotoPath': lastScanPhotoPath,
        'scanPhotoPaths': scanPhotoPaths,
        'plantHealthAcknowledged': plantHealthAcknowledged,
        'plantingDateUnknown': plantingDateUnknown,
        'warningsDismissedFromBell': warningsDismissedFromBell,
        'harvestedPercent': harvestedPercent,
        if (archivedAt != null) 'archivedAt': archivedAt!.toIso8601String(),
        if (moestuinBatchId != null) 'moestuinBatchId': moestuinBatchId,
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
      lastScanImageFingerprint:
          json['lastScanImageFingerprint'] as String?,
      lastScanPhotoPath: json['lastScanPhotoPath'] as String?,
      scanPhotoPaths: (json['scanPhotoPaths'] as List<dynamic>? ?? [])
          .map((e) => e as String)
          .toList(),
      plantHealthAcknowledged:
          json['plantHealthAcknowledged'] as bool? ?? false,
      plantingDateUnknown: json['plantingDateUnknown'] as bool? ?? false,
      warningsDismissedFromBell:
          json['warningsDismissedFromBell'] as bool? ?? false,
      harvestedPercent: ((json['harvestedPercent'] as num?) ?? 0)
          .round()
          .clamp(0, 100)
          .toInt(),
      archivedAt: json['archivedAt'] != null
          ? DateTime.parse(json['archivedAt'] as String)
          : null,
      moestuinBatchId: json['moestuinBatchId'] as String?,
    );
  }
}
