import '../models/add_plant_wizard_models.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import '../models/add_plant_setup_result.dart';
import 'crop_lifecycle_metadata.dart';
import 'garden_profile_store.dart';
import 'my_garden_store.dart';
import 'plant_lifecycle.dart';
import 'planting_calendar.dart';
import 'planting_season_status.dart';
import 'vegetable_repository.dart';

Set<GardenTaskType> plantingTaskTypesForGrowApproach(PlantGrowApproach? approach) {
  return switch (approach) {
    PlantGrowApproach.seed => const {
        GardenTaskType.preSow,
        GardenTaskType.sowOutdoors,
      },
    PlantGrowApproach.seedling || PlantGrowApproach.adult => const {
        GardenTaskType.plantOutdoors,
      },
    null => const {
        GardenTaskType.preSow,
        GardenTaskType.sowOutdoors,
        GardenTaskType.plantOutdoors,
      },
  };
}

Set<GardenTaskType> plantingTaskTypesForProfile(GardenPlantProfile profile) {
  return switch (profile.plantStartMethod) {
    PlantStartMethod.plantOutdoors => const {GardenTaskType.plantOutdoors},
    PlantStartMethod.preSowIndoors ||
    PlantStartMethod.sowOutdoors =>
      const {
        GardenTaskType.preSow,
        GardenTaskType.sowOutdoors,
      },
    null => const {
        GardenTaskType.preSow,
        GardenTaskType.sowOutdoors,
        GardenTaskType.plantOutdoors,
      },
  };
}

PlantingSeasonStatus plantingSeasonStatusForGrowApproach({
  required Vegetable vegetable,
  PlantGrowApproach? growApproach,
  PlantStartMethod? plantStartMethod,
  DateTime? reference,
}) {
  final types = growApproach != null
      ? plantingTaskTypesForGrowApproach(growApproach)
      : switch (plantStartMethod) {
          PlantStartMethod.plantOutdoors => const {GardenTaskType.plantOutdoors},
          PlantStartMethod.preSowIndoors ||
          PlantStartMethod.sowOutdoors =>
            const {
              GardenTaskType.preSow,
              GardenTaskType.sowOutdoors,
            },
          null => const {
              GardenTaskType.preSow,
              GardenTaskType.sowOutdoors,
              GardenTaskType.plantOutdoors,
            },
        };

  return plantingSeasonStatusForTaskTypes(
    vegetable.id,
    types: types,
    reference: reference,
    vegetable: vegetable,
  );
}

bool isPlantingSeasonActiveNow({
  required Vegetable vegetable,
  PlantGrowApproach? growApproach,
  PlantStartMethod? plantStartMethod,
  DateTime? reference,
}) {
  final status = plantingSeasonStatusForGrowApproach(
    vegetable: vegetable,
    growApproach: growApproach,
    plantStartMethod: plantStartMethod,
    reference: reference,
  );
  return status.phase == PlantingSeasonPhase.activeNow ||
      status.phase == PlantingSeasonPhase.daysLeft;
}

/// Plant staat in de moestuin maar wacht op het zaai-/plantseizoen.
bool shouldMarkInactiveUntilPlantingSeason({
  required Vegetable vegetable,
  required bool isPlanted,
  PlantGrowApproach? growApproach,
  PlantStartMethod? plantStartMethod,
  DateTime? reference,
}) {
  if (isPlanted) return false;
  return !isPlantingSeasonActiveNow(
    vegetable: vegetable,
    growApproach: growApproach,
    plantStartMethod: plantStartMethod,
    reference: reference,
  );
}

DateTime? nextPlantingSeasonStartDate({
  required Vegetable vegetable,
  PlantGrowApproach? growApproach,
  PlantStartMethod? plantStartMethod,
  DateTime? reference,
}) {
  final today = reference ?? DateTime.now();
  final types = growApproach != null
      ? plantingTaskTypesForGrowApproach(growApproach)
      : plantingTaskTypesForProfile(
          GardenPlantProfile(
            vegetableId: vegetable.id,
            plantedAt: today,
            plantStartMethod: plantStartMethod,
          ),
        );

  final start = plannedSeasonStartDate(
    vegetable.id,
    types: types,
    reference: today,
    vegetable: vegetable,
  );
  final todayOnly = DateTime(today.year, today.month, today.day);
  final startOnly = DateTime(start.year, start.month, start.day);
  if (!startOnly.isAfter(todayOnly) &&
      isPlantingSeasonActiveNow(
        vegetable: vegetable,
        growApproach: growApproach,
        plantStartMethod: plantStartMethod,
        reference: today,
      )) {
    return todayOnly;
  }
  if (startOnly.isBefore(todayOnly)) return null;
  return startOnly;
}

GardenPlantProfile applyOffSeasonInactiveState(GardenPlantProfile profile) {
  if (!profile.isMoestuinActive &&
      profile.inactiveReason == PlantMoestuinInactiveReason.offSeason) {
    return profile;
  }
  return profile.copyWith(
    isMoestuinActive: false,
    inactiveReason: PlantMoestuinInactiveReason.offSeason,
    inactiveSince: DateTime.now(),
    isPlanted: false,
    awaitingOutdoorPlanting: false,
    seasonBeyondCalendar: false,
    awaitingDeathConfirmation: false,
  );
}

String wizardOffSeasonInactiveNote({
  required Vegetable vegetable,
  PlantGrowApproach? growApproach,
  DateTime? reference,
}) {
  final status = plantingSeasonStatusForGrowApproach(
    vegetable: vegetable,
    growApproach: growApproach,
    reference: reference,
  );
  final days = status.days ??
      daysUntilNextPlantingSeason(
        vegetable.id,
        reference: reference,
        vegetable: vegetable,
      );

  final timing = days == null
      ? 'zodra het seizoen begint'
      : days == 0
          ? 'nu'
          : days == 1
              ? 'over 1 dag'
              : 'over $days dagen';

  return 'Deze plant komt in je moestuin op niet-actief te staan tot het '
      'zaai- of plantseizoen begint ($timing). Je krijgt dan een melding en '
      'kunt starten met taken.';
}

String addPlantSuccessMessage({
  required String plantName,
  required AddPlantSetupResult setup,
  required bool added,
  Vegetable? vegetable,
}) {
  if (!added) return '$plantName staat al in je moestuin';
  if (setup.intent.waitsForSeason &&
      vegetable != null &&
      shouldMarkInactiveUntilPlantingSeason(
        vegetable: vegetable,
        isPlanted: setup.isPlanted,
        growApproach: setup.growApproach,
        plantStartMethod: setup.plantStartMethod,
      )) {
    return '$plantName gepland. Staat op niet-actief tot het seizoen begint';
  }
  if (setup.isPlanted) {
    if (setup.initialScan != null) {
      return '$plantName toegevoegd met je eerste scan';
    }
    return '$plantName toegevoegd. Maak je eerste scan via Taken';
  }
  if (setup.intent == PlantAddIntent.startNow) {
    return '$plantName toegevoegd. Je kunt direct starten met taken';
  }
  return '$plantName gepland voor het seizoen';
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Geplande start ligt in de toekomst (wachten op seizoen, niet direct starten).
bool hasFuturePlantingPlan(GardenPlantProfile profile, {DateTime? reference}) {
  final today = _dateOnly(reference ?? DateTime.now());
  final planned = _dateOnly(profile.plantedAt);
  return planned.isAfter(today);
}

/// Plant staat in de moestuin maar wacht op het zaai-/plantseizoen (ook als
/// het profiel nog niet op niet-actief is gezet).
bool isMoestuinOffSeasonWaiting({
  required GardenPlantProfile? profile,
  required Vegetable vegetable,
  DateTime? reference,
}) {
  if (profile == null) return false;
  if (profile.isPlanted) return false;
  if (!profile.isMoestuinActive &&
      profile.inactiveReason == PlantMoestuinInactiveReason.offSeason) {
    return true;
  }
  if (!profile.isMoestuinActive) return false;
  if (!hasFuturePlantingPlan(profile, reference: reference)) return false;
  return shouldMarkInactiveUntilPlantingSeason(
    vegetable: vegetable,
    isPlanted: false,
    growApproach: profile.plantGrowApproach,
    plantStartMethod: profile.plantStartMethod,
    reference: reference,
  );
}

/// Dagen tot het relevante zaai-/plantseizoen begint (`0` = nu open).
int? daysUntilMoestuinPlantingSeason({
  required Vegetable vegetable,
  GardenPlantProfile? profile,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();
  final status = plantingSeasonStatusForGrowApproach(
    vegetable: vegetable,
    plantStartMethod: profile?.plantStartMethod,
    reference: ref,
  );
  return switch (status.phase) {
    PlantingSeasonPhase.startsSoon => status.days,
    PlantingSeasonPhase.activeNow || PlantingSeasonPhase.daysLeft => 0,
    PlantingSeasonPhase.seasonEnded => daysUntilNextPlantingSeason(
        vegetable.id,
        reference: ref,
        vegetable: vegetable,
      ),
    PlantingSeasonPhase.noCalendar => null,
  };
}

/// Korte afteltekst voor het groene statusveld op de moestuin-kaart.
String moestuinOffSeasonCountdownLabel({
  required Vegetable vegetable,
  GardenPlantProfile? profile,
  DateTime? reference,
}) {
  final days = daysUntilMoestuinPlantingSeason(
    vegetable: vegetable,
    profile: profile,
    reference: reference,
  );
  if (days == null) return 'Wacht op seizoen';
  if (days <= 0) return 'Seizoen begint nu';
  if (days == 1) return 'Over 1 dag';
  return 'Over $days dagen';
}

/// Zet wachtende planten op niet-actief en heractiveert ze zodra het seizoen opent.
Future<int> syncMoestuinSeasonActivation({
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  DateTime? reference,
}) async {
  final today = reference ?? DateTime.now();
  var changed = 0;

  for (final id in gardenStore.ids) {
    final profile = profileStore.profileFor(id);
    final vegetable = repository.byId(id);
    if (profile == null || vegetable == null) continue;

    if (!profile.isMoestuinActive) {
      final reactivated = tryReactivatePlantForSeason(
        profile: profile,
        vegetable: vegetable,
        month: today.month,
        reference: today,
      );
      if (reactivated != null) {
        await profileStore.saveProfile(reactivated);
        changed++;
      }
      continue;
    }

    if (profile.isMoestuinActive &&
        !profile.isPlanted &&
        hasFuturePlantingPlan(profile, reference: today) &&
        shouldMarkInactiveUntilPlantingSeason(
          vegetable: vegetable,
          isPlanted: false,
          plantStartMethod: profile.plantStartMethod,
          reference: today,
        )) {
      await profileStore.saveProfile(applyOffSeasonInactiveState(profile));
      changed++;
    }
  }

  return changed;
}
