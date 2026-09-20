import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'crop_harvest_kind.dart';
import 'garden_plant_schedule.dart';
import 'underground_crop.dart';
import 'visible_fruit_crop.dart';

/// Oogst (mogelijk) in beeld, toon uitklapbare oogst-sectie op de plantkaart.
bool isHarvestPossiblyReady(
  GardenPlantProfile profile,
  Vegetable vegetable,
) {
  if (!profile.isPlanted || !profile.isMoestuinActive) return false;
  if (isEdibleMoestuinBloomCrop(vegetable)) {
    return showEdibleBloomHarvestSection(profile, vegetable);
  }
  if (isOrnamentalOnlyMoestuinCrop(vegetable)) {
    return showOrnamentalFinishSection(profile, vegetable);
  }
  if (isUndergroundCrop(vegetable)) {
    return isUndergroundHarvestPossible(profile, vegetable);
  }
  if (!canUseAiHarvestAssessment(profile, vegetable: vegetable)) return false;
  if (isHomeHarvestActionDue(profile, vegetable: vegetable)) return true;
  if (!isReadyToHarvest(profile, vegetable: vegetable)) return false;
  final phase = profile.lastAnalysis?.phase;
  return phase == PlantAiPhase.almostRipe || phase == PlantAiPhase.ripe;
}

/// AI kan op de foto niet zeker zien of oogst rijp is, gebruiker controleert zelf.
bool isAiHarvestVisuallyUncertain(
  GardenPlantProfile profile,
  Vegetable vegetable,
) {
  if (!isHarvestPossiblyReady(profile, vegetable)) return false;
  if (isOrnamentalOnlyMoestuinCrop(vegetable)) return false;

  final a = profile.lastAnalysis;
  if (a == null) return true;

  if (isEdibleMoestuinBloomCrop(vegetable)) {
    return a.insight?.harvestReady != true && a.phase != PlantAiPhase.ripe;
  }

  if (isUndergroundCrop(vegetable)) {
    return !isUndergroundHarvestConfirmed(profile, vegetable);
  }

  if (isVisibleFruitCrop(vegetable)) {
    if (a.insight?.harvestReady == true) return false;
    if (a.phase == PlantAiPhase.ripe) return false;
    if (a.fruitHarvestNote != null && a.fruitHarvestNote!.trim().isNotEmpty) {
      return a.insight?.harvestReady != true;
    }
  }

  if (a.insight?.harvestReady == true) return false;
  if (a.phase == PlantAiPhase.ripe) return false;
  return true;
}

/// Vaste uitleg op de moestuin-kaart wanneer de tuinier zelf moet beoordelen.
String selfCheckHarvestExpandHint() {
  return 'Mogelijk oogstbaar. Controleer zelf of ze rijp zijn.\n\n'
      'Nog niet rijp? Houd de plant actief bij in je moestuin.\n\n'
      'Klaar met oogsten? Rond het seizoen af. Dan stoppen we de plant '
      'voor dit seizoen. Tot volgend seizoen.\n\n'
      'Alles over oogsten en rijpheid vind je bij Oogst-info.';
}
