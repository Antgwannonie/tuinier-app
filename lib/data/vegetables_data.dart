import '../models/vegetable.dart';
import 'extra_reference_vegetables.dart';
import 'my_garden_plants.dart';
import 'new_atlas_vegetables.dart';

/// Jouw moestuinplan eerst; daarna overige referentiegroenten (geen dubbele ids).
const List<Vegetable> kVegetablesSeed = [
  ...kMyGardenPlants,
  ...kExtraReferenceVegetables,
  ...kNewAtlasVegetables,
];
