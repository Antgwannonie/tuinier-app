import '../models/garden_plant_profile.dart';
import '../models/plant_grow_approach.dart';
import '../models/vegetable.dart';
import 'plant_pending_planting.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';
import 'planting_season_status.dart';

/// Eén actief zaai-/plantvenster voor weergave (wizard stap 2).
class ActivePlantingSeasonLine {
  const ActivePlantingSeasonLine({
    required this.type,
    required this.title,
    required this.statusLine,
  });

  final GardenTaskType type;
  final String title;
  final String statusLine;

  String get shortTitle => switch (type) {
        GardenTaskType.preSow => 'Voorzaai',
        GardenTaskType.sowOutdoors => 'Buiten zaaien',
        GardenTaskType.plantOutdoors => 'Buiten planten',
        GardenTaskType.harvest => 'Oogsten',
      };
}

bool isPlantingSeasonPhaseOpen(PlantingSeasonPhase phase) =>
    phase == PlantingSeasonPhase.activeNow ||
    phase == PlantingSeasonPhase.daysLeft;

String plantingSeasonTypeTitle(GardenTaskType type) => switch (type) {
      GardenTaskType.preSow => 'Voorzaai-seizoen (binnen)',
      GardenTaskType.sowOutdoors => 'Buiten zaai-seizoen',
      GardenTaskType.plantOutdoors => 'Buiten plant-seizoen',
      GardenTaskType.harvest => 'Oogstseizoen',
    };

bool vegetableSupportsPlantingTaskType(
  Vegetable vegetable,
  GardenTaskType type,
) {
  return plantingActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  ).any((activity) => activity.type == type);
}

PlantingSeasonStatus plantingSeasonStatusForTask(
  Vegetable vegetable,
  GardenTaskType type, {
  DateTime? reference,
}) {
  return plantingSeasonStatusForTaskTypes(
    vegetable.id,
    types: {type},
    reference: reference,
    vegetable: vegetable,
  );
}

String _statusLineFor(PlantingSeasonStatus status) {
  switch (status.phase) {
    case PlantingSeasonPhase.activeNow:
      return 'Nu actief';
    case PlantingSeasonPhase.daysLeft:
      final d = status.days ?? 0;
      if (d <= 0) return 'Nu actief';
      return d == 1
          ? 'Nu actief · nog 1 dag in dit venster'
          : 'Nu actief · nog $d dagen in dit venster';
    default:
      return status.label.trim();
  }
}

/// Alle zaai-/plantvensters die vandaag open zijn (voor wizard stap 2).
List<ActivePlantingSeasonLine> activePlantingSeasonLinesFor({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  const order = [
    GardenTaskType.preSow,
    GardenTaskType.sowOutdoors,
    GardenTaskType.plantOutdoors,
  ];

  final lines = <ActivePlantingSeasonLine>[];
  for (final type in order) {
    if (!vegetableSupportsPlantingTaskType(vegetable, type)) continue;
    final status = plantingSeasonStatusForTask(
      vegetable,
      type,
      reference: reference,
    );
    if (!isPlantingSeasonPhaseOpen(status.phase)) continue;
    lines.add(
      ActivePlantingSeasonLine(
        type: type,
        title: plantingSeasonTypeTitle(type),
        statusLine: _statusLineFor(status),
      ),
    );
  }
  return lines;
}

bool isOutdoorPlantSeasonActive(
  Vegetable vegetable, {
  DateTime? reference,
}) {
  if (!vegetableSupportsPlantingTaskType(
    vegetable,
    GardenTaskType.plantOutdoors,
  )) {
    return false;
  }
  final status = plantingSeasonStatusForTask(
    vegetable,
    GardenTaskType.plantOutdoors,
    reference: reference,
  );
  return isPlantingSeasonPhaseOpen(status.phase);
}

bool isPreSowSeasonActive(
  Vegetable vegetable, {
  DateTime? reference,
}) {
  if (!vegetableSupportsPlantingTaskType(vegetable, GardenTaskType.preSow)) {
    return false;
  }
  final status = plantingSeasonStatusForTask(
    vegetable,
    GardenTaskType.preSow,
    reference: reference,
  );
  return isPlantingSeasonPhaseOpen(status.phase);
}

/// Buiten of balkon: kou/frost kan de plant schaden.
bool isColdExposedPlantingLocation(GardenLocation location) =>
    location == GardenLocation.outdoor ||
    location == GardenLocation.balcony;

/// Waarschuwing bij planttaken: zaailing/volwassen plant buiten buiten het plantseizoen.
String? earlyOutdoorPlantingTaskWarning({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  DateTime? reference,
}) {
  final approach = resolvePlantGrowApproach(profile);
  if (approach != PlantGrowApproach.seedling &&
      approach != PlantGrowApproach.adult) {
    return null;
  }
  if (!isColdExposedPlantingLocation(profile.location)) return null;
  if (isOutdoorPlantSeasonActive(vegetable, reference: reference)) return null;

  if (isPreSowSeasonActive(vegetable, reference: reference)) {
    return 'Het is nu voorzaai-seizoen, maar het buiten-plantseizoen is nog niet begonnen. '
        'Een zaailing of volwassen plant buiten zetten kan te vroeg zijn door kou en vorst. '
        'Je mag het wel doen — let extra op koude nachten.';
  }

  return 'Je plant buiten of op het balkon terwijl het buiten-plantseizoen nog niet '
      '(meer) actief is. Dat kan de plant stress geven. Binnen of in de kas is veiliger.';
}
