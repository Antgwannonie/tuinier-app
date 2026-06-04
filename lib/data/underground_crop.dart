import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';

/// Gewassen waar de oogst onder de grond zit — niet zichtbaar op een gewone plantfoto.
const Set<String> kUndergroundCropIds = {
  'wortel',
  'mini_wortel',
  'rode_biet',
  'biet',
  'pastinaak',
  'schorseneer',
  'meiraap',
  'radijs',
  'zwarte_radijs',
  'aardappel',
  'zoete_aardappel',
  'ui',
  'bosui',
  'ui_bloei',
  'knoflook',
  'sjalot',
  'knolselerij',
  'knolvenkel',
  'knolraap',
  'knolselderij',
  'yacon',
  'aardpeer',
  'pastinaak_winter',
};

bool isUndergroundCrop(Vegetable vegetable) {
  if (kUndergroundCropIds.contains(vegetable.id)) return true;
  final id = vegetable.id.toLowerCase();
  if (id.contains('wortel') ||
      id.contains('aardappel') ||
      id.contains('knol') ||
      id.startsWith('ui') ||
      id.contains('_ui')) {
    return true;
  }
  final family = vegetable.family.toLowerCase();
  return family.contains('wortel') ||
      family.contains('ui') ||
      family.contains('knol');
}

/// Oogst bevestigd via proefoogst-scan (AI zag het geoogste deel).
bool isUndergroundHarvestConfirmed(
  GardenPlantProfile profile,
  Vegetable vegetable,
) {
  if (!isUndergroundCrop(vegetable)) return false;
  final a = profile.lastAnalysis;
  if (a == null || !a.isHarvestProbeScan) return false;
  if (a.insight?.harvestReady == true) return true;
  return a.phase == PlantAiPhase.ripe;
}

/// Oogst mogelijk op basis van bovengrondse groei — nog geen bevestiging.
bool isUndergroundHarvestPossible(
  GardenPlantProfile profile,
  Vegetable vegetable,
) {
  if (!isUndergroundCrop(vegetable)) return false;
  if (isUndergroundHarvestConfirmed(profile, vegetable)) return true;
  final a = profile.lastAnalysis;
  if (a == null || !a.matchesSelectedCrop) return false;
  final note = a.undergroundHarvestNote?.trim();
  if (note != null && note.isNotEmpty) return true;
  final days = a.daysUntilHarvest;
  if (days != null && days <= 21) return true;
  if (a.phase == PlantAiPhase.almostRipe || a.phase == PlantAiPhase.fruiting) {
    return true;
  }
  return false;
}

String undergroundHarvestHint(GardenPlantProfile profile) {
  final a = profile.lastAnalysis;
  if (a == null) return '';
  if (a.undergroundHarvestNote != null &&
      a.undergroundHarvestNote!.trim().isNotEmpty) {
    return a.undergroundHarvestNote!.trim();
  }
  if (a.insight?.ripenessNote != null &&
      a.insight!.ripenessNote!.trim().isNotEmpty) {
    return a.insight!.ripenessNote!.trim();
  }
  return a.harvestWindowLabel;
}
