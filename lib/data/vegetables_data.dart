import '../models/vegetable.dart';
import 'expanded_fruit_and_plants.dart';
import 'extra_reference_vegetables.dart';
import 'my_garden_plants.dart';
import 'new_atlas_vegetables.dart';
import 'moestuin_companion_plants.dart';
import 'nl_common_plants_bulk.dart';

/// Jouw moestuinplan eerst; daarna overige referentiegroenten (geen dubbele ids).
final List<Vegetable> kVegetablesSeed = [
  ...kMyGardenPlants,
  ...kExtraReferenceVegetables,
  ...kNewAtlasVegetables,
  ...kExpandedFruitAndPlants,
  ...kNlCommonPlantsBulk,
  ...kMoestuinCompanionPlants,
];
