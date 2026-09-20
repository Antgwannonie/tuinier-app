import '../models/add_plant_wizard_models.dart';
import '../models/garden_plant_profile.dart';
import '../models/tuin_space.dart';
import '../models/visual_garden_plan.dart';
import 'garden_profile_store.dart';
import 'my_garden_store.dart';
import 'plant_season_activation.dart';
import 'planting_season_status.dart';
import 'store_update_batch.dart';
import 'vegetable_repository.dart';

class VisualBedApplyResult {
  const VisualBedApplyResult({
    required this.spaceId,
    required this.spaceName,
    required this.addedCount,
    required this.plannedInactiveCount,
    required this.keptExistingCount,
    this.addToAgenda = false,
    this.agendaPlantIds = const [],
  });

  final String spaceId;
  final String spaceName;
  final int addedCount;
  final int plannedInactiveCount;
  final int keptExistingCount;
  final bool addToAgenda;
  final List<String> agendaPlantIds;
}

GardenLocation gardenLocationFromTuinPlace(TuinSpacePlace place) {
  return switch (place) {
    TuinSpacePlace.outdoor => GardenLocation.outdoor,
    TuinSpacePlace.balcony => GardenLocation.balcony,
    TuinSpacePlace.greenhouse => GardenLocation.greenhouse,
    TuinSpacePlace.indoor => GardenLocation.windowsill,
  };
}

/// Maakt een nieuwe moestuin met de baknaam en plant de bakplanten erin.
///
/// Planten worden gepland vanaf zaad voor hun zaai-/plantperiode. Buiten het
/// seizoen staan ze niet-actief tot het nieuwe seizoen begint. Al groeiende
/// planten behouden hun bestaande profiel.
Future<VisualBedApplyResult?> applyVisualBedToNewMoestuin({
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required VisualGardenBed bed,
  required String spaceName,
  TuinSpacePlace place = TuinSpacePlace.outdoor,
  bool addToAgenda = false,
}) async {
  final plantIds = bed.placements.map((p) => p.plantId).toSet().toList()
    ..sort();
  if (plantIds.isEmpty) return null;

  final name = spaceName.trim().isEmpty ? bed.name : spaceName.trim();
  final location = gardenLocationFromTuinPlace(place);
  final today = DateTime.now();

  late final String spaceId;
  var addedCount = 0;
  var plannedInactiveCount = 0;
  var keptExistingCount = 0;

  await runStoreBatch(() async {
    spaceId = await gardenStore.createSpace(name: name, place: place);

    for (final id in plantIds) {
      final vegetable = repository.byId(id);
      if (vegetable == null) continue;

      final alreadyInSpace = gardenStore.contains(id);
      if (!alreadyInSpace) {
        await gardenStore.add(id);
        addedCount++;
      }

      final existing = profileStore.profileFor(id);
      if (existing != null && existing.isPlanted) {
        keptExistingCount++;
        continue;
      }

      final plantedAt = plannedSeasonStartDate(
        id,
        types: plantingTaskTypesForGrowApproach(PlantGrowApproach.seed),
        reference: today,
        vegetable: vegetable,
      );

      await profileStore.beginFreshPlantInGarden(
        id,
        plantedAt: plantedAt,
        location: location,
        sunLevel: SunLevel.medium,
        isPlanted: false,
        plantGrowApproach: PlantGrowApproach.seed,
      );

      if (shouldMarkInactiveUntilPlantingSeason(
        vegetable: vegetable,
        isPlanted: false,
        growApproach: PlantGrowApproach.seed,
        reference: today,
      )) {
        final profile = profileStore.profileFor(id);
        if (profile != null) {
          await profileStore.saveProfile(
            applyOffSeasonInactiveState(profile),
          );
          plannedInactiveCount++;
        }
      }
    }
  });

  return VisualBedApplyResult(
    spaceId: spaceId,
    spaceName: gardenStore.activeSpace?.name ?? name,
    addedCount: addedCount,
    plannedInactiveCount: plannedInactiveCount,
    keptExistingCount: keptExistingCount,
    addToAgenda: addToAgenda,
    agendaPlantIds: addToAgenda ? plantIds : const [],
  );
}
