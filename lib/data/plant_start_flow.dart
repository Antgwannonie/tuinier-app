import '../models/garden_plant_profile.dart';
import '../models/plant_grow_approach.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import 'garden_countdown.dart';
import 'plant_season_activation.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';
import 'planting_season_status.dart';

PlantStartMethod? plantStartMethodFromTask(GardenTaskType type) {
  return switch (type) {
    GardenTaskType.preSow => PlantStartMethod.preSowIndoors,
    GardenTaskType.sowOutdoors => PlantStartMethod.sowOutdoors,
    GardenTaskType.plantOutdoors => PlantStartMethod.plantOutdoors,
    GardenTaskType.harvest => null,
  };
}

GardenTaskType? gardenTaskTypeFromPlantStartMethod(PlantStartMethod method) {
  return switch (method) {
    PlantStartMethod.preSowIndoors => GardenTaskType.preSow,
    PlantStartMethod.sowOutdoors => GardenTaskType.sowOutdoors,
    PlantStartMethod.plantOutdoors => GardenTaskType.plantOutdoors,
  };
}

String moestuinPlantingMethodLabel(GardenTaskType type) {
  return plantStartMethodFromTask(type)?.cardLabel ?? type.shortLabel;
}

/// Methodes die voor dit gewas in de kalender voorkomen.
List<PlantStartMethod> availablePlantStartMethods(Vegetable vegetable) {
  const plantingTypes = {
    GardenTaskType.preSow,
    GardenTaskType.sowOutdoors,
    GardenTaskType.plantOutdoors,
  };
  final out = <PlantStartMethod>{};
  for (final activity in calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  )) {
    if (!plantingTypes.contains(activity.type)) continue;
    final method = plantStartMethodFromTask(activity.type);
    if (method != null) out.add(method);
  }
  final ordered = <PlantStartMethod>[
    PlantStartMethod.preSowIndoors,
    PlantStartMethod.sowOutdoors,
    PlantStartMethod.plantOutdoors,
  ];
  return [for (final m in ordered) if (out.contains(m)) m];
}

PlantStartMethod? suggestedPlantStartMethod({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final status = plantingSeasonStatusFor(
    vegetable.id,
    reference: reference,
    vegetable: vegetable,
  );
  if (status.taskType != null &&
      (status.phase == PlantingSeasonPhase.activeNow ||
          status.phase == PlantingSeasonPhase.daysLeft)) {
    return plantStartMethodFromTask(status.taskType!);
  }
  final methods = availablePlantStartMethods(vegetable);
  return methods.isNotEmpty ? methods.first : null;
}

bool profileAwaitingOutdoorPlanting(GardenPlantProfile profile) =>
    profile.isPlanted &&
    profile.awaitingOutdoorPlanting &&
    profile.isMoestuinActive;

PlantGrowApproach? _growApproachForProfile(GardenPlantProfile profile) {
  if (profile.plantGrowApproach != null) return profile.plantGrowApproach;
  return switch (profile.plantStartMethod) {
    PlantStartMethod.preSowIndoors || PlantStartMethod.sowOutdoors =>
      PlantGrowApproach.seed,
    PlantStartMethod.plantOutdoors => PlantGrowApproach.seedling,
    null => null,
  };
}

VegetableGardenStatus? outdoorPlantingStatus(
  String vegetableId, [
  DateTime? reference,
]) {
  return gardenStatusForTask(
    vegetableId,
    GardenTaskType.plantOutdoors,
    reference,
  );
}

bool isOutdoorPlantingDueNow({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final status = outdoorPlantingStatus(vegetable.id, reference);
  return status?.isActiveNow == true;
}

int? daysUntilOutdoorPlanting({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final status = outdoorPlantingStatus(vegetable.id, reference);
  if (status == null) return null;
  if (status.isActiveNow) return 0;
  if (status.daysUntil > 0) return status.daysUntil;
  return null;
}

bool needsMoestuinPlantingButton({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  DateTime? reference,
}) {
  if (profile == null || !profile.isMoestuinActive) return false;
  if (profileAwaitingOutdoorPlanting(profile)) {
    return isOutdoorPlantingDueNow(
      vegetable: vegetable,
      reference: reference,
    );
  }
  if (profile.isPlanted) return false;
  if (isMoestuinOffSeasonWaiting(
    profile: profile,
    vegetable: vegetable,
    reference: reference,
  )) {
    return false;
  }
  return isPlantingSeasonActiveNow(
    vegetable: vegetable,
    growApproach: _growApproachForProfile(profile),
    plantStartMethod: profile.plantStartMethod,
    reference: reference,
  );
}

const outdoorPlantingActionLabel = 'Buiten planten';

int? outdoorPlantingDaysLeftInWindow({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final status = outdoorPlantingStatus(vegetable.id, reference);
  if (status == null || !status.isActiveNow) return null;
  final today = DateTime(
    (reference ?? DateTime.now()).year,
    (reference ?? DateTime.now()).month,
    (reference ?? DateTime.now()).day,
  );
  final left = status.periodEnd.difference(today).inDays;
  return left >= 0 ? left : null;
}

String moestuinOutdoorPlantingActiveActionLabel({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final left = outdoorPlantingDaysLeftInWindow(
    vegetable: vegetable,
    reference: reference,
  );
  if (left != null && left > 0) {
    return left == 1
        ? 'Nog 1 dag buiten planten'
        : 'Nog $left dagen buiten planten';
  }
  return 'Nu buiten planten';
}

DateTime? outdoorPlantingReminderAt({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final status = outdoorPlantingStatus(vegetable.id, reference);
  if (status == null) return null;
  final base = status.isActiveNow
      ? (reference ?? DateTime.now())
      : status.periodStart;
  return DateTime(base.year, base.month, base.day, 9, 15);
}

const _initialPlantTaskTypes = [
  GardenTaskType.preSow,
  GardenTaskType.sowOutdoors,
];

/// Aftelling buiten planten alleen na binnen voorgezaaid.
bool shouldIncludeOutdoorPlantingInCountdown(GardenPlantProfile? profile) {
  return profile != null && profileAwaitingOutdoorPlanting(profile);
}

bool _hasPlantingActivity(Vegetable vegetable, GardenTaskType type) {
  return calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  ).any((a) => a.type == type);
}

/// Kalendertypes voor aftelling op nog niet gestarte planten (stap 1: zaaien).
List<GardenTaskType> unplantedCountdownTaskTypes({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
}) {
  if (shouldIncludeOutdoorPlantingInCountdown(profile)) {
    return const [GardenTaskType.plantOutdoors];
  }
  return [
    for (final type in _initialPlantTaskTypes)
      if (_hasPlantingActivity(vegetable, type)) type,
  ];
}

/// Label voor stap 1: binnen voorzaaien of buiten zaaien.
String moestuinInitialPlantingActionLabel({
  required Vegetable vegetable,
}) {
  final methods = availablePlantStartMethods(vegetable);
  if (methods.contains(PlantStartMethod.preSowIndoors)) {
    return PlantStartMethod.preSowIndoors.cardLabel;
  }
  if (methods.contains(PlantStartMethod.sowOutdoors)) {
    return PlantStartMethod.sowOutdoors.cardLabel;
  }
  return PlantStartMethod.preSowIndoors.cardLabel;
}

/// Dagen tot het volgende voorzaai-/buiten-zaai-venster.
int? daysUntilNextUnplantedPlantSeason(
  String vegetableId, {
  DateTime? reference,
  Vegetable? vegetable,
}) {
  return daysUntilNextInitialPlantSeason(
    vegetableId,
    reference: reference,
    vegetable: vegetable,
  );
}
