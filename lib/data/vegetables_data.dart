import '../models/vegetable.dart';
import 'expanded_fruit_and_plants.dart';
import 'extra_reference_vegetables.dart';
import 'my_garden_plants.dart';
import 'new_atlas_vegetables.dart';
import 'moestuin_companion_plants.dart';
import 'new_garden_varieties.dart';
import 'nl_common_plants_bulk.dart';
import 'vegetable_id_migrations.dart';

List<Vegetable> _buildVegetableCatalog() {
  final raw = <Vegetable>[
    ...kMyGardenPlants,
    ...kExtraReferenceVegetables,
    ...kNewAtlasVegetables,
    ...kExpandedFruitAndPlants,
    ...kNlCommonPlantsBulk,
    ...kNewGardenVarieties,
    ...kMoestuinCompanionPlants,
  ];
  return raw
      .where((v) => !kVegetableIdMigrations.containsKey(v.id))
      .toList(growable: false);
}

/// Jouw moestuinplan eerst; daarna overige referentiegroenten (geen dubbele ids).
final List<Vegetable> kVegetablesSeed = _buildVegetableCatalog();
