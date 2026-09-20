import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'garden_plant_schedule.dart';

/// Gewassen waar de oogst onder de grond zit, niet zichtbaar op een gewone plantfoto.
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
  'gember',
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

/// Oogst mogelijk op basis van bovengrondse groei, nog geen bevestiging.
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
  if (a.insight?.harvestReady == true) return true;
  if (a.phase == PlantAiPhase.ripe) return true;
  if (a.phase == PlantAiPhase.almostRipe) {
    final remaining = remainingHarvestDays(profile);
    return remaining == null || remaining <= 7;
  }
  final remaining = remainingHarvestDays(profile);
  if (remaining != null && remaining <= 7) return true;
  return isHarvestDueBySchedule(profile);
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

/// AI denkt dat oogst mogelijk is (bovengronds + tijd sinds zaai/plant).
bool isUndergroundAiHarvestSignal(
  GardenPlantProfile profile,
  Vegetable vegetable,
) {
  if (!isUndergroundCrop(vegetable)) return false;
  return isUndergroundHarvestPossible(profile, vegetable);
}

/// Herkenningsgids voor rijpheid, wanneer de AI twijfelt.
String undergroundRipenessGuideFor(Vegetable vegetable) {
  final id = vegetable.id;
  if (id.contains('wortel') || id == 'pastinaak' || id == 'schorseneer') {
    return 'Trek één wortel uit de grond en kijk naar de kleur en dikte.\n\n'
        '• Rijp: stevige wortel, goede kleur (oranje bij wortel, wit bij '
        'pastinaak), niet dun of haarachtig.\n'
        '• Te vroeg: heel dun, vaak nog felgroen loof dat niet verkleurt.\n'
        '• Te laat: barst open, houtachtig of bloeistengel verschijnt.\n\n'
        'Combineer dit met de teelttijd op je plantkaart en het '
        'oogstseizoen in de kalender.';
  }
  if (id.contains('biet') || id == 'rode_biet') {
    return 'Trek één biet voorzichtig uit de grond.\n\n'
        '• Rijp: knol van gewenste grootte, glad en stevig; blad nog '
        'gezond maar mag iets verkleuren.\n'
        '• Te vroeg: kleine knol, blad nog heel jong en felgroen.\n'
        '• Te laat: knol barst, wordt houtachtig of gaat door naar zaad.\n\n'
        'De AI ziet alleen het loof, controleer altijd zelf onder de grond.';
  }
  if (id.contains('aardappel')) {
    return 'Graaf bij één plant voorzichtig een aardappel op.\n\n'
        '• Rijp: schil stevig, geen groene vlekken; loof begint geel te '
        'worden of af te sterven (late oogst).\n'
        '• Te vroeg: dunne schil die makkelijk schuurt af; kleine knollen.\n\n'
        'Bij vroege oogst: controleer meerdere planten, niet alles rijpt '
        'tegelijk.';
  }
  if (id.contains('ui') ||
      id.contains('knoflook') ||
      id.contains('sjalot')) {
    return 'Trek één bol of knoflookteentje uit de grond.\n\n'
        '• Rijp: bol/knoflook goed gevormd; loof geel en slap (ui) of '
        'bruin en droog (knoflook).\n'
        '• Te vroeg: bol nog klein, loof nog groen en stevig.\n\n'
        'Laat geoogste uien/knoflook drogen voor opslag.';
  }
  if (id.contains('radijs')) {
    return 'Trek één radijs uit de grond.\n\n'
        '• Rijp: knol rond en stevig, niet houtachtig of gaat door naar bloei.\n'
        '• Te vroeg: heel klein; te laat: barst open of bloeit.\n\n'
        'Radijs groeit snel, controleer regelmatig zodra het loof volwassen '
        'lijkt.';
  }
  return 'Trek één plant voorzichtig uit de grond en beoordeel de knol, '
      'wortel of bol onder de grond.\n\n'
      '• Rijp: goede grootte en kleur voor dit gewas, stevig en niet '
      'houtachtig.\n'
      '• Te vroeg: nog klein of dun, laat staan en scan later opnieuw.\n'
      '• Te laat: barst, bloeit of wordt taai.\n\n'
      'De AI ziet alleen het loof boven de grond. Combineer je eigen '
      'controle met de teelttijd en het oogstseizoen.';
}
