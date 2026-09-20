/// Gedeelde teeltprofielen voor Plant Info-tabs (behalve Zaaien/Uitplanten-entries).
/// Groente/kruiden/fruit — niet bloemen of paddenstoelen.

enum CropProfileKey {
  tomaat,
  paprika,
  aubergine,
  komkommer,
  courgette,
  pompoen,
  meloen,
  sla,
  spinazie,
  biet,
  wortel,
  radijs,
  kool,
  ui,
  prei,
  knoflook,
  aardappel,
  zoeteAardappel,
  mais,
  boon,
  erwt,
  kruidZacht,
  meerjarig,
  fruitZaad,
  aardbei,
  okra,
  gember,
  tauge,
  algemeen,
}

class CropProfile {
  const CropProfile({
    required this.key,
    this.note,
    required this.frostSensitive,
    required this.sunHoursIdeal,
    required this.sunHoursMin,
    required this.windSensitivity,
    required this.tempIdeal,
    required this.tempMin,
    required this.tempMax,
    required this.humidityLevel,
    required this.kasPreferred,
    required this.indoorSuitable,
    required this.waterNeed,
    required this.waterHow,
    required this.waterGermination,
    required this.waterGrowth,
    required this.waterBloom,
    required this.waterFruit,
    required this.droughtSensitive,
    required this.wetSensitive,
    required this.tooLittleSigns,
    required this.tooMuchSigns,
    required this.soilType,
    required this.phRange,
    required this.compostAdvice,
    required this.fertiliserAdvice,
    required this.mainNutrients,
    required this.feedAtPlant,
    required this.feedDuringGrowth,
    required this.feedBloom,
    required this.feedFruit,
    required this.deficiencySigns,
    required this.overfeedSigns,
    required this.growthHabit,
    required this.growthSpeed,
    required this.supportNeeded,
    required this.supportHow,
    required this.pinchTop,
    required this.removeSuckers,
    required this.thinSeedlings,
    required this.growthProblems,
    required this.healthySigns,
    required this.stressSigns,
    required this.bloomPeriodHint,
    required this.daysToFruitHint,
    required this.selfPollinating,
    required this.hasSeparateSexFlowers,
    required this.pollinators,
    required this.bloomStimulate,
    required this.removeFlowersAdvice,
    required this.handPollinate,
    required this.bloomHealthy,
    required this.bloomProblems,
    required this.flowersEdible,
    required this.harvestHow,
    required this.harvestFrequency,
    required this.ripenessSigns,
    required this.yieldHint,
    required this.storeHow,
    required this.freezeHow,
    required this.dryHow,
    required this.saveSeeds,
    required this.harvestProblems,
    required this.edibleParts,
    required this.dailyCheck,
    required this.weeklyCheck,
    required this.mulch,
    required this.weed,
    required this.prune,
    required this.protectHeat,
    required this.protectCold,
    required this.potCare,
    required this.greenhouseCare,
    required this.winterCare,
    required this.seasonCare,
    required this.goodNeighbors,
    required this.badNeighbors,
    required this.plantFamilyHint,
    required this.rotationYears,
    required this.predecessors,
    required this.successors,
    required this.companions,
    required this.pestPlants,
    required this.soilImprovers,
    required this.nitrogenFixers,
    required this.comboBenefits,
    required this.comboMistakes,
    required this.commonPests,
    required this.commonDiseases,
    required this.problemSymptoms,
    required this.origin,
    required this.nameMeaning,
    required this.funFact,
    required this.kitchenUse,
    required this.healthBenefits,
    required this.specialNotes,
  });

  final CropProfileKey key;
  final String? note;
  final bool frostSensitive;
  final String sunHoursIdeal;
  final String sunHoursMin;
  final String windSensitivity;
  final String tempIdeal;
  final String tempMin;
  final String tempMax;
  final String humidityLevel;
  final bool kasPreferred;
  final bool indoorSuitable;
  final String waterNeed;
  final String waterHow;
  final String waterGermination;
  final String waterGrowth;
  final String waterBloom;
  final String waterFruit;
  final String droughtSensitive;
  final String wetSensitive;
  final String tooLittleSigns;
  final String tooMuchSigns;
  final String soilType;
  final String phRange;
  final String compostAdvice;
  final String fertiliserAdvice;
  final String mainNutrients;
  final String feedAtPlant;
  final String feedDuringGrowth;
  final String feedBloom;
  final String feedFruit;
  final String deficiencySigns;
  final String overfeedSigns;
  final String growthHabit;
  final String growthSpeed;
  final String supportNeeded;
  final String supportHow;
  final String pinchTop;
  final String removeSuckers;
  final String thinSeedlings;
  final String growthProblems;
  final String healthySigns;
  final String stressSigns;
  final String bloomPeriodHint;
  final String daysToFruitHint;
  final bool selfPollinating;
  final bool hasSeparateSexFlowers;
  final String pollinators;
  final String bloomStimulate;
  final String removeFlowersAdvice;
  final String handPollinate;
  final String bloomHealthy;
  final String bloomProblems;
  final String flowersEdible;
  final String harvestHow;
  final String harvestFrequency;
  final String ripenessSigns;
  final String yieldHint;
  final String storeHow;
  final String freezeHow;
  final String dryHow;
  final String saveSeeds;
  final String harvestProblems;
  final String edibleParts;
  final String dailyCheck;
  final String weeklyCheck;
  final String mulch;
  final String weed;
  final String prune;
  final String protectHeat;
  final String protectCold;
  final String potCare;
  final String greenhouseCare;
  final String winterCare;
  final String seasonCare;
  final List<String> goodNeighbors;
  final List<String> badNeighbors;
  final String plantFamilyHint;
  final String rotationYears;
  final List<String> predecessors;
  final List<String> successors;
  final List<String> companions;
  final List<String> pestPlants;
  final List<String> soilImprovers;
  final List<String> nitrogenFixers;
  final String comboBenefits;
  final String comboMistakes;
  final List<String> commonPests;
  final List<String> commonDiseases;
  final String problemSymptoms;
  final String origin;
  final String nameMeaning;
  final String funFact;
  final String kitchenUse;
  final String healthBenefits;
  final String specialNotes;
}

CropProfileKey cropProfileKeyFor(String vegetableId) {
  final x = vegetableId.toLowerCase();
  if (x.contains('zoete_aardappel')) return CropProfileKey.zoeteAardappel;
  if (x.contains('aardappel')) return CropProfileKey.aardappel;
  if (x.contains('knoflook') || x.contains('sjalot')) {
    return CropProfileKey.knoflook;
  }
  if (x.contains('mais')) return CropProfileKey.mais;
  if (x.contains('tomaat') ||
      x.contains('cherry') ||
      x.contains('cocktail') ||
      x.contains('pruimtomaat') ||
      x.contains('trostomaat') ||
      x.contains('snoeptomaat') ||
      x.contains('balkontomaat')) {
    return CropProfileKey.tomaat;
  }
  if (x.contains('paprika') ||
      x.contains('peper') ||
      x.contains('chili') ||
      x.contains('cayenne') ||
      x.contains('jalapeno') ||
      x.contains('galapeno') ||
      x.contains('habanero') ||
      x.contains('rawit') ||
      x.contains('banana_peper')) {
    return CropProfileKey.paprika;
  }
  // Pepino (Solanum muricatum) is een vruchtgewas, geen paprika.
  if (x.contains('pepino')) return CropProfileKey.fruitZaad;
  if (x.contains('aubergine')) return CropProfileKey.aubergine;
  if (x.contains('komkommer') ||
      x.contains('augurk') ||
      x.contains('cucamelon')) {
    return CropProfileKey.komkommer;
  }
  if (x.contains('courgette') || x.contains('patisson')) {
    return CropProfileKey.courgette;
  }
  if (x.contains('pompoen') ||
      x.contains('hokkaido') ||
      x.contains('butternut')) {
    return CropProfileKey.pompoen;
  }
  if (x.contains('meloen') || x.contains('watermeloen')) {
    return CropProfileKey.meloen;
  }
  if (x.contains('sla') ||
      x.contains('lollo') ||
      x.contains('eikenblad') ||
      x.contains('ijsberg') ||
      x.contains('andijvie') ||
      x.contains('snijbiet') ||
      x.contains('witlof')) {
    return CropProfileKey.sla;
  }
  if (x.contains('spinazie') ||
      x.contains('rucola') ||
      x.contains('tuinkers') ||
      x.contains('postelein') ||
      x.contains('waterkers') ||
      x.contains('veldsla') ||
      x.contains('tuinmelde')) {
    return CropProfileKey.spinazie;
  }
  if (x.contains('biet') || x.contains('chioggia')) return CropProfileKey.biet;
  // Apiaceae: knolvenkel/knolselerij → wortelprofiel; blad/stengel → spinazie-achtig.
  if (x.contains('knolvenkel') || x.contains('knolselerij')) {
    return CropProfileKey.wortel;
  }
  if (x.contains('venkel') ||
      x.contains('selderij') ||
      x.contains('bleekselderij') ||
      x.contains('stengelselderij')) {
    return CropProfileKey.spinazie;
  }
  if (x.contains('wortel') ||
      x.contains('peen') ||
      x.contains('pastinaak') ||
      x.contains('schorseneer') ||
      x.contains('peterseliewortel')) {
    return CropProfileKey.wortel;
  }
  if (x.contains('radijs') || x.contains('rammenas')) {
    return CropProfileKey.radijs;
  }
  if (x.contains('kool') ||
      x.contains('broccoli') ||
      x.contains('bloemkool') ||
      x.contains('boerenkool') ||
      x.contains('spruit') ||
      x.contains('paksoi') ||
      x.contains('chinese') ||
      x.contains('bimi') ||
      x.contains('romanesco') ||
      x.contains('raap') ||
      x.contains('koolrabi') ||
      x.contains('savooi') ||
      x.contains('mizuna') ||
      x.contains('tatsoi') ||
      x.contains('komatsuna') ||
      x.contains('mosterd') ||
      x.contains('knolraap') ||
      x.contains('knolrabi')) {
    return CropProfileKey.kool;
  }
  if (x.contains('prei')) return CropProfileKey.prei;
  if (x == 'ui' ||
      x.endsWith('_ui') ||
      x.startsWith('ui_') ||
      x.contains('bosui') ||
      x.contains('winterui') ||
      x.contains('rode_ui') ||
      x.contains('scheve_ui')) {
    return CropProfileKey.ui;
  }
  if (x.contains('boon') ||
      x.contains('bonen') ||
      x.contains('sperzie') ||
      x.contains('haricot') ||
      x.contains('snijboon') ||
      x.contains('pinda') ||
      x.contains('linzen')) {
    return CropProfileKey.boon;
  }
  if (x.contains('erwt') ||
      x.contains('kapucijner') ||
      x.contains('tuinboon') ||
      x.contains('sugar') ||
      x.contains('peultjes') ||
      x.contains('peul')) {
    return CropProfileKey.erwt;
  }
  if (x.contains('aardbei')) return CropProfileKey.aardbei;
  if (x.contains('gember')) return CropProfileKey.gember;
  if (x.contains('okra')) return CropProfileKey.okra;
  if (x.contains('tauge')) return CropProfileKey.tauge;
  if (x.contains('asperge') ||
      x.contains('artisjok') ||
      x.contains('rabarber') ||
      x.contains('aardpeer') ||
      x.contains('kardoen')) {
    return CropProfileKey.meerjarig;
  }
  // Fruit/bessen: specifieke namen (vermijd false positives zoals tuinkers/pruimtomaat).
  if (x.contains('appel') ||
      (x.contains('peer') && !x.contains('aardpeer')) ||
      x == 'pruim' ||
      x.startsWith('pruim_') ||
      x.contains('mirabel') ||
      x == 'kers' ||
      x.startsWith('kers_') ||
      x.contains('_kers') ||
      x.contains('kriek') ||
      x.contains('perzik') ||
      x.contains('nectarine') ||
      x.contains('abrikoos') ||
      x.contains('vijg') ||
      x.contains('druif') ||
      x.contains('kiwi') ||
      x.contains('framboos') ||
      x.contains('braam') ||
      x.contains('blauwe_bes') ||
      x.contains('blauwebes') ||
      x.contains('bosbes') ||
      x.contains('zwarte_bes') ||
      x.contains('rode_bes') ||
      x.contains('witte_bes') ||
      x.contains('aalbessen') ||
      x.contains('kruisbes') ||
      x.contains('josta') ||
      x.contains('vlier') ||
      x.contains('veenbes') ||
      x.endsWith('_bes') ||
      x.contains('cranberry') ||
      x.contains('duindoorn') ||
      x.contains('mango') ||
      x.contains('avocado') ||
      x.contains('citroen') ||
      x.contains('limoen') ||
      x.contains('mandarijn') ||
      x.contains('walnoot') ||
      x.contains('hazelnoot') ||
      x.contains('kastanje') ||
      x.contains('kaki') ||
      x.contains('physalis') ||
      x.contains('mispel')) {
    return CropProfileKey.fruitZaad;
  }
  if (x.contains('basilicum') ||
      x.contains('peterselie') ||
      x.contains('bieslook') ||
      x.contains('dille') ||
      x.contains('koriander') ||
      x.contains('munt') ||
      x.contains('tijm') ||
      x.contains('oregano') ||
      x.contains('salie') ||
      x.contains('rozemarijn') ||
      x.contains('dragon') ||
      x.contains('estragon') ||
      x.contains('majoraan') ||
      x.contains('kamille') ||
      x.contains('citroenmelisse') ||
      x.contains('citroengras') ||
      x.contains('kervel') ||
      x.contains('bonenkruid') ||
      x.contains('zuring') ||
      x.contains('kerrie') ||
      x.contains('anijs') ||
      x.contains('tuinkruid') ||
      x.contains('_kruid') ||
      x.endsWith('kruid')) {
    return CropProfileKey.kruidZacht;
  }
  return CropProfileKey.algemeen;
}

CropProfile cropProfileFor(String vegetableId) =>
    kCropProfiles[cropProfileKeyFor(vegetableId)] ??
    kCropProfiles[CropProfileKey.algemeen]!;

/// Welk deel van de plant wordt geoogst?
enum CropHarvestCategory { fruit, leaf, root, herb, allium, legume, grain, other }

CropHarvestCategory cropHarvestCategoryFor(String vegetableId) {
  final key = cropProfileKeyFor(vegetableId);
  switch (key) {
    case CropProfileKey.tomaat:
    case CropProfileKey.paprika:
    case CropProfileKey.aubergine:
    case CropProfileKey.komkommer:
    case CropProfileKey.courgette:
    case CropProfileKey.pompoen:
    case CropProfileKey.meloen:
    case CropProfileKey.okra:
    case CropProfileKey.aardbei:
    case CropProfileKey.fruitZaad:
      return CropHarvestCategory.fruit;
    case CropProfileKey.sla:
    case CropProfileKey.spinazie:
      return CropHarvestCategory.leaf;
    case CropProfileKey.wortel:
    case CropProfileKey.radijs:
    case CropProfileKey.biet:
    case CropProfileKey.aardappel:
    case CropProfileKey.zoeteAardappel:
    case CropProfileKey.gember:
      return CropHarvestCategory.root;
    case CropProfileKey.kruidZacht:
      return CropHarvestCategory.herb;
    case CropProfileKey.ui:
    case CropProfileKey.prei:
    case CropProfileKey.knoflook:
      return CropHarvestCategory.allium;
    case CropProfileKey.boon:
    case CropProfileKey.erwt:
      return CropHarvestCategory.legume;
    case CropProfileKey.mais:
      return CropHarvestCategory.grain;
    case CropProfileKey.kool:
    case CropProfileKey.meerjarig:
    case CropProfileKey.tauge:
    case CropProfileKey.algemeen:
      return CropHarvestCategory.other;
  }
}

/// Geeft true als dit gewas vruchten vormt die je oogst.
bool cropFruitsForHarvest(String vegetableId) =>
    cropHarvestCategoryFor(vegetableId) == CropHarvestCategory.fruit;

/// Vorstgevoeligheid met correctie voor tropische/kuipfruit binnen fruitZaad.
bool cropFrostSensitiveFor(String vegetableId) {
  final x = vegetableId.toLowerCase();
  const tropical = [
    'mango',
    'avocado',
    'citroen',
    'limoen',
    'mandarijn',
    'sinaasappel',
    'ananas',
    'banaan',
    'papaya',
    'passie',
    'lychee',
    'guave',
    'pepino',
    'physalis',
    'gember',
    'okra',
    'citroengras',
  ];
  for (final t in tropical) {
    if (x.contains(t)) return true;
  }
  // Vijg/kiwi: matig winterhard, maar bloesem/jonge plant wel vorstgevoelig.
  if (x.contains('vijg') || x.contains('kiwi')) return true;
  return cropProfileFor(vegetableId).frostSensitive;
}

/// Late-fase wateradvies passend bij oogsttype (voorkomt "vrucht"-taal op blad/wortel).
String cropLateStageWaterHow(String vegetableId) {
  final p = cropProfileFor(vegetableId);
  switch (cropHarvestCategoryFor(vegetableId)) {
    case CropHarvestCategory.fruit:
      return p.waterFruit;
    case CropHarvestCategory.leaf:
      return 'Gelijkmatig vochtig houden voor fris, knapperig blad; droge stress geeft bitter of taai blad.';
    case CropHarvestCategory.root:
      return 'Gelijkmatig vochtig voor egale wortelverdikking; grote schommelingen geven gespleten of houtige wortels.';
    case CropHarvestCategory.herb:
      return 'Matig water: iets droger dan bladgroente; natte voet remt aroma en geeft wortelrot.';
    case CropHarvestCategory.allium:
      return 'Gelijkmatig vochtig tijdens bol-/schachtvulling; later iets droger voor betere houdbaarheid.';
    case CropHarvestCategory.legume:
      return 'Voldoende water tijdens bloei en peulvulling; droogte geeft lege of korte peulen.';
    case CropHarvestCategory.grain:
      return 'Voldoende water tijdens kolfvulling; droge stress remt korrelzetting.';
    case CropHarvestCategory.other:
      return 'Gelijkmatig vochtig houden in de oogstperiode; vermijd extreme droge of natte pieken.';
  }
}

/// Late-fase voedingsadvies passend bij oogsttype.
String cropLateStageFeedHow(String vegetableId) {
  final p = cropProfileFor(vegetableId);
  switch (cropHarvestCategoryFor(vegetableId)) {
    case CropHarvestCategory.fruit:
      return p.feedFruit;
    case CropHarvestCategory.leaf:
      return 'Lichte stikstofgift voor bladkwaliteit; stop of minderen vlak voor oogst bij bittergevoelige soorten.';
    case CropHarvestCategory.root:
      return 'Kalium ondersteunt wortelkwaliteit; te veel stikstof geeft veel loof en kleine knollen/wortels.';
    case CropHarvestCategory.herb:
      return 'Spaarzaam bemesten: te veel stikstof geeft weelderig blad met minder aroma.';
    case CropHarvestCategory.allium:
      return 'Kalium voor bolvulling; geen late zware stikstof (zwakke bol, slechte bewaring).';
    case CropHarvestCategory.legume:
      return 'Weinig tot geen stikstof nodig (wortelknolletjes); lichte kalium/fosfor bij peulzetting mag.';
    case CropHarvestCategory.grain:
      return 'Kalium tijdens kolfvulling; te veel late stikstof vertraagt afrijping.';
    case CropHarvestCategory.other:
      return p.feedFruit.contains('vrucht')
          ? 'Kalium voor stevigheid en oogstkwaliteit; niet te veel late stikstof.'
          : p.feedFruit;
  }
}

/// Korte labeltekst voor eetbare delen op basis van oogstcategorie.
Set<String> cropEdiblePartKeysFor(String vegetableId) {
  final p = cropProfileFor(vegetableId);
  final text = p.edibleParts.toLowerCase();
  final parts = <String>{};
  if (text.contains('vrucht') || text.contains('bes') || text.contains('peul')) {
    parts.add('fruit');
  }
  if (text.contains('blad') || text.contains('krop') || text.contains('loof')) {
    parts.add('leaf');
  }
  if (text.contains('wortel') ||
      text.contains('knol') ||
      text.contains('teen') ||
      text.contains('bol')) {
    parts.add('root');
  }
  if (text.contains('bloem') || text.contains('knop') || text.contains('spruit')) {
    parts.add('flower');
  }
  if (text.contains('stengel') ||
      text.contains('schacht') ||
      text.contains('scheut') ||
      text.contains('pijp')) {
    parts.add('shoot');
  }
  if (text.contains('zaad') || text.contains('pit') || text.contains('boon') || text.contains('erwt')) {
    parts.add('seed');
  }
  if (parts.isNotEmpty) return parts;

  switch (cropHarvestCategoryFor(vegetableId)) {
    case CropHarvestCategory.fruit:
      return {'fruit'};
    case CropHarvestCategory.leaf:
    case CropHarvestCategory.herb:
      return {'leaf'};
    case CropHarvestCategory.root:
      return {'root'};
    case CropHarvestCategory.allium:
      return {'root', 'shoot'};
    case CropHarvestCategory.legume:
      return {'fruit', 'seed'};
    case CropHarvestCategory.grain:
      return {'seed', 'fruit'};
    case CropHarvestCategory.other:
      return {'leaf'};
  }
}

/// Late-fase koptekst passend bij het gewastype.
String cropLateStageLabel(String vegetableId) {
  switch (cropHarvestCategoryFor(vegetableId)) {
    case CropHarvestCategory.fruit:
      return 'Tijdens vruchtvorming';
    case CropHarvestCategory.leaf:
      return 'Tijdens volle bladgroei';
    case CropHarvestCategory.root:
      return 'Tijdens wortelverdikking';
    case CropHarvestCategory.herb:
      return 'Tijdens volle groei';
    case CropHarvestCategory.allium:
      return 'Tijdens bolvulling';
    case CropHarvestCategory.legume:
      return 'Tijdens peulvorming';
    case CropHarvestCategory.grain:
      return 'Tijdens kolfvulling';
    case CropHarvestCategory.other:
      return 'Tijdens oogstperiode';
  }
}

/// Kort timeline-chip label.
String cropTimelineChipLabel(String vegetableId) {
  switch (cropHarvestCategoryFor(vegetableId)) {
    case CropHarvestCategory.fruit:
      return 'Vruchtvorming';
    case CropHarvestCategory.leaf:
      return 'Bladgroei';
    case CropHarvestCategory.root:
      return 'Wortelvorming';
    case CropHarvestCategory.herb:
      return 'Volle groei';
    case CropHarvestCategory.allium:
      return 'Bolvulling';
    case CropHarvestCategory.legume:
      return 'Peulvorming';
    case CropHarvestCategory.grain:
      return 'Kolfvulling';
    case CropHarvestCategory.other:
      return 'Oogst';
  }
}

CropProfile _p({
  required CropProfileKey key,
  String? note,
  bool frostSensitive = false,
  String sunHoursIdeal = '6 – 8 uur',
  String sunHoursMin = '4 – 6 uur',
  String windSensitivity = 'Gemiddeld',
  String tempIdeal = '18 – 25 °C',
  String tempMin = '10 °C',
  String tempMax = '32 °C',
  String humidityLevel = 'Gemiddeld',
  bool kasPreferred = false,
  bool indoorSuitable = false,
  String waterNeed = 'Gemiddeld',
  String waterHow =
      'Geef water bij de voet; liever diep en minder vaak dan oppervlakkig sproeien.',
  String waterGermination =
      'Zaaigrond gelijkmatig vochtig houden; niet sopnat (omvalziekte).',
  String waterGrowth = 'Regelmatig water bij droge periodes; bodem licht vochtig.',
  String waterBloom = 'Gelijkmatig vochtig houden; droge stress kan bloemval geven.',
  String waterFruit =
      'Voldoende water voor vruchtvulling; vermijd grote schommelingen.',
  String droughtSensitive = 'Matig',
  String wetSensitive = 'Matig',
  String tooLittleSigns = 'Slap blad, droge bovenlaag, trage groei.',
  String tooMuchSigns = 'Gele bladeren, slapte ondanks natte grond, wortelrot.',
  String soilType = 'Losse, humusrijke, goed doorlatende grond.',
  String phRange = 'pH 6,0 – 7,0',
  String compostAdvice = 'Werk rijpe compost in voor het seizoen.',
  String fertiliserAdvice =
      'Matige organische bemesting; volg het overzicht voeding.',
  String mainNutrients = 'Stikstof (blad), fosfor (wortels/bloei), kalium (weerstand/vrucht).',
  String feedAtPlant = 'Lichte startgift compost of organische mest bij planten.',
  String feedDuringGrowth = 'Bijmest naar behoefte tijdens actieve groei.',
  String feedBloom = 'Iets meer kalium/fosfor rond bloei indien nodig.',
  String feedFruit = 'Kaliumrijk bij vruchtvorming; niet te veel stikstof.',
  String deficiencySigns = 'Vergeling, paarse nerven, zwakke groei of tipburn.',
  String overfeedSigns = 'Weelderig blad, weinig vrucht, zoutschade of bladbrand.',
  String growthHabit = 'Opgaand tot bossig, afhankelijk van ras.',
  String growthSpeed = 'Gemiddeld',
  String supportNeeded = 'Alleen bij klim- of hoge gewassen.',
  String supportHow = 'Stok, kooi of latwerk tijdig zetten.',
  String pinchTop = 'Alleen bij soorten die toppen verdraagt; anders overslaan.',
  String removeSuckers = 'Alleen bij dievenrassen; meestal niet van toepassing.',
  String thinSeedlings = 'Dun uit tot de juiste plantafstand.',
  String growthProblems = 'Kou, droogte, te dicht planten, tekorten.',
  String healthySigns = 'Stevige stengel, fris blad, gestage nieuwe groei.',
  String stressSigns = 'Slapte, vergeling, bladval, stilstand.',
  String bloomPeriodHint = 'Afhankelijk van ras en seizoen; meestal zomer.',
  String daysToFruitHint = 'Zie oogstkalender / eerste oogst in overzicht.',
  bool selfPollinating = true,
  bool hasSeparateSexFlowers = false,
  String pollinators = 'Bijen en hommels helpen bij de meeste bloeiende gewassen.',
  String bloomStimulate = 'Voldoende licht, warmte en geen extreme droogte.',
  String removeFlowersAdvice =
      'Verwijder zieke of uitgebloeide bloemen; bij bladgewassen soms knoppen weg.',
  String handPollinate = 'Meestal niet nodig; in kas soms handbestuiving helpen.',
  String bloomHealthy = 'Frisse bloemen, goede bestuiversactiviteit, geen massale val.',
  String bloomProblems = 'Bloemval door kou, hitte, droogte of te veel stikstof.',
  String flowersEdible = 'Meestal niet eetbaar; uitzonderingen per soort.',
  String harvestHow = 'Oogst met schoon mes of door te plukken volgens soort.',
  String harvestFrequency = 'Volgens rijpheid; vaak meerdere keren per seizoen.',
  String ripenessSigns = 'Kleur, grootte en stevigheid volgens ras.',
  String yieldHint = 'Zie opbrengst in plantenoverzicht.',
  String storeHow = 'Koel, droog en soortafhankelijk bewaren.',
  String freezeHow = 'Blancheren waar nodig, daarna invriezen.',
  String dryHow = 'Dunne plakken of kruiden drogen op luchtige plek.',
  String saveSeeds = 'Alleen van open-bestoven, gezonde planten; droog bewaren.',
  String harvestProblems = 'Te vroeg/te laat oogsten, beschadiging, bewaarrot.',
  String edibleParts = 'Zie soort: blad, vrucht, wortel, bol of stengel.',
  String dailyCheck = 'Kijk naar slapte, plagen en extreme hitte/kou.',
  String weeklyCheck = 'Onkruid, steun, bemesting, ziekten onder blad.',
  String mulch = 'Mulch houdt vocht vast en remt onkruid.',
  String weed = 'Wied regelmatig zonder wortels te beschadigen.',
  String prune = 'Snoei alleen wat de soort vraagt.',
  String protectHeat = 'Schaduwdoek of extra water bij hittegolven.',
  String protectCold = 'Vliesdoek bij nachtvorst.',
  String potCare = 'Potten drogen sneller; check water dagelijks bij warm weer.',
  String greenhouseCare = 'Ventileer tegen schimmel en hitte.',
  String winterCare = 'Eenjarigen opruimen; meerjarigen beschermen naar soort.',
  String seasonCare = 'Pas water, steun en bescherming aan op het seizoen.',
  List<String> goodNeighbors = const ['Sla', 'Kruiden', 'Wortel'],
  List<String> badNeighbors = const ['Te veel van dezelfde familie'],
  String plantFamilyHint = 'Zie plantenfamilie in de app.',
  String rotationYears = '3 – 4 jaar wisselteelt waar mogelijk.',
  List<String> predecessors = const ['Vlinderbloemigen', 'Bladgewassen'],
  List<String> successors = const ['Bladgewassen', 'Groenbemester'],
  List<String> companions = const ['Bieslook', 'Goudsbloem'],
  List<String> pestPlants = const ['Afrikaan', 'Goudsbloem'],
  List<String> soilImprovers = const ['Compost', 'Groenbemester'],
  List<String> nitrogenFixers = const ['Erwten', 'Bonen'],
  String comboBenefits =
      'Goede buren benutten ruimte, remmen plagen en verbeteren bodem.',
  String comboMistakes =
      'Zelfde familie te vaak op één plek; concurrenten te dicht bij elkaar.',
  List<String> commonPests = const ['Bladluis', 'Slakken'],
  List<String> commonDiseases = const ['Schimmel bij vochtig weer'],
  String problemSymptoms =
      'Vergeling, vlekken, gaatjes, slapte of groeistilstand.',
  String origin = 'Wereldwijd gecultiveerd; oorsprong verschilt per soort.',
  String nameMeaning = 'Naamgeving volgt vaak Latijnse of streektaal.',
  String funFact = 'Elk ras heeft eigen smaak, kleur en teeltduur.',
  String kitchenUse = 'Vers, gekookt of verwerkt naar soort.',
  String healthBenefits = 'Bijdrage aan vezels, vitaminen en mineralen.',
  String specialNotes = '',
}) {
  return CropProfile(
    key: key,
    note: note,
    frostSensitive: frostSensitive,
    sunHoursIdeal: sunHoursIdeal,
    sunHoursMin: sunHoursMin,
    windSensitivity: windSensitivity,
    tempIdeal: tempIdeal,
    tempMin: tempMin,
    tempMax: tempMax,
    humidityLevel: humidityLevel,
    kasPreferred: kasPreferred,
    indoorSuitable: indoorSuitable,
    waterNeed: waterNeed,
    waterHow: waterHow,
    waterGermination: waterGermination,
    waterGrowth: waterGrowth,
    waterBloom: waterBloom,
    waterFruit: waterFruit,
    droughtSensitive: droughtSensitive,
    wetSensitive: wetSensitive,
    tooLittleSigns: tooLittleSigns,
    tooMuchSigns: tooMuchSigns,
    soilType: soilType,
    phRange: phRange,
    compostAdvice: compostAdvice,
    fertiliserAdvice: fertiliserAdvice,
    mainNutrients: mainNutrients,
    feedAtPlant: feedAtPlant,
    feedDuringGrowth: feedDuringGrowth,
    feedBloom: feedBloom,
    feedFruit: feedFruit,
    deficiencySigns: deficiencySigns,
    overfeedSigns: overfeedSigns,
    growthHabit: growthHabit,
    growthSpeed: growthSpeed,
    supportNeeded: supportNeeded,
    supportHow: supportHow,
    pinchTop: pinchTop,
    removeSuckers: removeSuckers,
    thinSeedlings: thinSeedlings,
    growthProblems: growthProblems,
    healthySigns: healthySigns,
    stressSigns: stressSigns,
    bloomPeriodHint: bloomPeriodHint,
    daysToFruitHint: daysToFruitHint,
    selfPollinating: selfPollinating,
    hasSeparateSexFlowers: hasSeparateSexFlowers,
    pollinators: pollinators,
    bloomStimulate: bloomStimulate,
    removeFlowersAdvice: removeFlowersAdvice,
    handPollinate: handPollinate,
    bloomHealthy: bloomHealthy,
    bloomProblems: bloomProblems,
    flowersEdible: flowersEdible,
    harvestHow: harvestHow,
    harvestFrequency: harvestFrequency,
    ripenessSigns: ripenessSigns,
    yieldHint: yieldHint,
    storeHow: storeHow,
    freezeHow: freezeHow,
    dryHow: dryHow,
    saveSeeds: saveSeeds,
    harvestProblems: harvestProblems,
    edibleParts: edibleParts,
    dailyCheck: dailyCheck,
    weeklyCheck: weeklyCheck,
    mulch: mulch,
    weed: weed,
    prune: prune,
    protectHeat: protectHeat,
    protectCold: protectCold,
    potCare: potCare,
    greenhouseCare: greenhouseCare,
    winterCare: winterCare,
    seasonCare: seasonCare,
    goodNeighbors: goodNeighbors,
    badNeighbors: badNeighbors,
    plantFamilyHint: plantFamilyHint,
    rotationYears: rotationYears,
    predecessors: predecessors,
    successors: successors,
    companions: companions,
    pestPlants: pestPlants,
    soilImprovers: soilImprovers,
    nitrogenFixers: nitrogenFixers,
    comboBenefits: comboBenefits,
    comboMistakes: comboMistakes,
    commonPests: commonPests,
    commonDiseases: commonDiseases,
    problemSymptoms: problemSymptoms,
    origin: origin,
    nameMeaning: nameMeaning,
    funFact: funFact,
    kitchenUse: kitchenUse,
    healthBenefits: healthBenefits,
    specialNotes: specialNotes,
  );
}

final Map<CropProfileKey, CropProfile> kCropProfiles = {
  CropProfileKey.tomaat: _p(
    key: CropProfileKey.tomaat,
    frostSensitive: true,
    sunHoursIdeal: '8+ uur',
    sunHoursMin: '6 uur',
    windSensitivity: 'Hoog (steun nodig)',
    tempIdeal: '20 – 26 °C',
    tempMin: '12 – 15 °C',
    tempMax: '32 °C',
    humidityLevel: 'Gemiddeld',
    kasPreferred: true,
    waterNeed: 'Gemiddeld tot hoog',
    waterHow:
        'Diep water aan de voet; blad nat houden vermijden (schimmel). Gelijkmatig om neusrot te beperken.',
    waterFruit:
        'Regelmatig en gelijkmatig; grote schommelingen geven barsten of neusrot.',
    droughtSensitive: 'Hoog bij vruchtzetting',
    wetSensitive: 'Hoog (wortelrot/schimmel)',
    soilType: 'Rijke, warme, goed doorlatende grond met compost.',
    phRange: 'pH 6,0 – 6,8',
    mainNutrients: 'Kalium en calcium belangrijk; niet alleen stikstof.',
    feedFruit: 'Kaliumrijk; calcium helpen (neusrot voorkomen via gelijkmatig water).',
    supportNeeded: 'Ja',
    supportHow: 'Stok of tomatenkooi meteen zetten; losjes opbinden.',
    pinchTop: 'Soms toppen laat in seizoen om rijping te forceren.',
    removeSuckers: 'Bij stamtomaat dieven in bladoksels verwijderen.',
    selfPollinating: true,
    bloomStimulate: 'Schud bloemtrossen licht of zorg voor luchtbeweging in kas.',
    handPollinate: 'In kas: trossen licht tikken of met penseel bestuiven.',
    flowersEdible: 'Nee (vrucht is eetbaar).',
    harvestHow: 'Pluk rijpe vruchten met steel; laat eindseizoen nagaan.',
    ripenessSigns: 'Volle kleur, iets veerkrachtig, makkelijk loskomend.',
    edibleParts: 'Vrucht',
    goodNeighbors: const ['Basilicum', 'Goudsbloem', 'Ui', 'Wortel'],
    badNeighbors: const ['Aardappel (ziekte)', 'Venkel'],
    plantFamilyHint: 'Nachtschade (Solanaceae)',
    rotationYears: '3 – 4 jaar geen nachtschade op dezelfde plek',
    commonPests: const ['Bladluis', 'Witte vlieg', 'Rupsen'],
    commonDiseases: const ['Phytophthora', 'Meeldauw', 'Neusrot'],
    origin: 'Midden- en Zuid-Amerika',
    funFact: 'Tomaat is botanisch een bes; culinair een groente.',
    kitchenUse: 'Rauw, saus, soep, drogen, invriezen.',
    healthBenefits: 'Lycopeen, vitamine C.',
  ),
  CropProfileKey.paprika: _p(
    key: CropProfileKey.paprika,
    frostSensitive: true,
    sunHoursIdeal: '8+ uur',
    kasPreferred: true,
    tempIdeal: '21 – 28 °C',
    tempMin: '15 °C',
    waterNeed: 'Gemiddeld',
    wetSensitive: 'Hoog',
    soilType: 'Warm, voedzaam, doorlatend.',
    supportNeeded: 'Ja bij zware vrucht',
    supportHow: 'Kooi of stok; peperplanten kunnen omwaaien.',
    removeSuckers: 'Meestal niet nodig; lichte vormsnoei mogelijk.',
    selfPollinating: true,
    edibleParts: 'Vrucht',
    goodNeighbors: const ['Basilicum', 'Ui', 'Wortel'],
    badNeighbors: const ['Venkel', 'Boon (soms concurrentie)'],
    plantFamilyHint: 'Nachtschade',
    commonPests: const ['Bladluis', 'Spint'],
    commonDiseases: const ['Neusrot', 'Schimmel bij kou/nat'],
    origin: 'Amerika',
    kitchenUse: 'Rauw, roerbak, saus, drogen (peper).',
  ),
  CropProfileKey.aubergine: _p(
    key: CropProfileKey.aubergine,
    frostSensitive: true,
    kasPreferred: true,
    sunHoursIdeal: '8+ uur',
    tempIdeal: '22 – 30 °C',
    tempMin: '16 °C',
    waterNeed: 'Gemiddeld tot hoog',
    supportNeeded: 'Ja',
    supportHow: 'Stok of kooi; vruchten worden zwaar.',
    edibleParts: 'Vrucht',
    plantFamilyHint: 'Nachtschade',
    commonPests: const ['Coloradokever', 'Bladluis'],
    origin: 'Zuid-Azië; oude cultuurplant, via Middeleeuwen naar Europa.',
    kitchenUse: 'Bakken, grillen, stoof; vaak eerst zouten of voor garen.',
    harvestHow:
        'Pluk als de schil glanzend is en nog stevig; niet te hard laten worden.',
    daysToFruitHint: '±70–100 dagen na uitplanten bij voldoende warmte.',
    specialNotes:
        'In NL het beste in kas of tegen warme zuidmuur. Buiten alleen in warme zomers na ijsheiligen; nachten bij voorkeur >12–15 °C. Plant afgehard uit vanaf eind mei/juni.',
  ),
  CropProfileKey.komkommer: _p(
    key: CropProfileKey.komkommer,
    frostSensitive: true,
    sunHoursIdeal: '6 – 8 uur',
    kasPreferred: true,
    humidityLevel: 'Hoog',
    waterNeed: 'Hoog',
    waterHow: 'Regelmatig en riant aan de voet; mulch helpt.',
    droughtSensitive: 'Hoog',
    wetSensitive: 'Matig tot hoog (schimmel)',
    hasSeparateSexFlowers: true,
    selfPollinating: false,
    handPollinate:
        'Mannelijke bloem (slanke steel) → vrouwelijke (mini-vruchtje) met penseel of meeldraad.',
    flowersEdible: 'Jonge bloemen soms eetbaar; meestal niet het doel.',
    supportNeeded: 'Ja (klimrassen)',
    supportHow: 'Latwerk, net of touw meteen plaatsen.',
    edibleParts: 'Vrucht',
    goodNeighbors: const ['Dille', 'Mais', 'Boon'],
    badNeighbors: const ['Aardappel', 'Sterke aromatische kruiden te dicht'],
    plantFamilyHint: 'Komkommerfamilie (Cucurbitaceae)',
    commonPests: const ['Bladluis', 'Spint'],
    commonDiseases: const ['Meeldauw', 'Valse meeldauw'],
    origin: 'Zuid-Azië',
    kitchenUse: 'Rauw, zuur, salade.',
  ),
  CropProfileKey.courgette: _p(
    key: CropProfileKey.courgette,
    frostSensitive: true,
    waterNeed: 'Hoog',
    hasSeparateSexFlowers: true,
    selfPollinating: false,
    handPollinate: 'Bij slecht weer handbestuiven; anders bijen.',
    flowersEdible: 'Ja — bloemen zijn eetbaar (gevuld/gebakken).',
    supportNeeded: 'Nee (meestal)',
    harvestFrequency: 'Om de 1–3 dagen in piek; jong oogsten.',
    ripenessSigns: '15–25 cm (rasafhankelijk); niet te groot laten.',
    edibleParts: 'Vrucht en bloemen',
    plantFamilyHint: 'Cucurbitaceae',
    goodNeighbors: const ['Mais', 'Boon', 'Oost-Indische kers'],
    commonDiseases: const ['Meeldauw'],
  ),
  CropProfileKey.pompoen: _p(
    key: CropProfileKey.pompoen,
    frostSensitive: true,
    waterNeed: 'Hoog',
    sunHoursIdeal: '6 – 8 uur',
    hasSeparateSexFlowers: true,
    selfPollinating: false,
    supportNeeded: 'Nee (rankers geleiden)',
    harvestHow: 'Steelsgewijs afsnijden; narijpen warm/droog.',
    storeHow: 'Koel en droog; winterpompoen weken tot maanden.',
    edibleParts: 'Vrucht (pitten soms ook)',
    plantFamilyHint: 'Cucurbitaceae',
    growthHabit: 'Rankend of bossig; veel ruimte.',
  ),
  CropProfileKey.meloen: _p(
    key: CropProfileKey.meloen,
    frostSensitive: true,
    kasPreferred: true,
    sunHoursIdeal: '8+ uur',
    tempIdeal: '22 – 30 °C',
    tempMin: '16 °C',
    waterNeed: 'Gemiddeld tot hoog',
    waterHow:
        'Regelmatig water in groei; iets minderen tijdens rijping voor zoetere smaak (niet laten verwelken).',
    waterFruit:
        'Gelijkmatig vochtig houden tot vruchten vullen; grote schommelingen geven barsten of zwakke smaak.',
    hasSeparateSexFlowers: true,
    selfPollinating: false,
    handPollinate:
        'In kas: mannelijke bloem → vrouwelijke (met mini-meloentje) met penseel; of hommels/bijen toelaten.',
    edibleParts: 'Vrucht',
    plantFamilyHint: 'Cucurbitaceae',
    supportNeeded: 'Optioneel (latwerk in kas spaart ruimte)',
    supportHow:
        'Touw/latwerk in kas; buiten vaak op de grond met mulch onder vruchten.',
    ripenessSigns:
        'Geur, kleurverandering, steeltje dat makkelijker loslaat (rasafhankelijk).',
    harvestHow: 'Snijd met een stukje steel; laat narijpen indien nodig.',
    daysToFruitHint: '±75–100 dagen na uitplanten in warme kas.',
    origin:
        'Afrika/Azië (soortafhankelijk); zoete meloenen via Middeleeuwen in Europa.',
    kitchenUse: 'Vers, salade, smoothie.',
    specialNotes:
        'In NL betrouwbaar in kas of tunnel. Buiten alleen op warme, beschutte plek in warme zomers; start met voorzaaien en plant niet vóór echte warmte (vaak juni). Watermeloen vraagt nog meer warmte.',
  ),
  CropProfileKey.sla: _p(
    key: CropProfileKey.sla,
    frostSensitive: false,
    sunHoursIdeal: '4 – 6 uur (zomer halfschaduw)',
    sunHoursMin: '3 – 4 uur',
    tempIdeal: '12 – 20 °C',
    tempMax: '25 °C',
    waterNeed: 'Hoog',
    droughtSensitive: 'Hoog',
    waterHow: 'Gelijkmatig vochtig; nooit laten uitdrogen.',
    soilType: 'Luchtig, vochthoudend, matig voedzaam.',
    feedFruit: 'N.v.t. (bladgewas)',
    selfPollinating: true,
    bloomPeriodHint: 'Doorschieten bij hitte/lange dag — oogst vóór bloei.',
    removeFlowersAdvice: 'Bij doorschieten: oogsten of verwijderen.',
    flowersEdible: 'Nee (bitter na doorschieten).',
    harvestHow: 'Hele krop of blad voor blad snijden.',
    harvestFrequency: 'Bladsla: regelmatig; krop: eenmalig/rijp.',
    edibleParts: 'Blad',
    goodNeighbors: const ['Wortel', 'Radijs', 'Ui', 'Aardbei'],
    badNeighbors: const ['Peterselie (soms)', 'Te dicht bij kool (plagen)'],
    plantFamilyHint: 'Composieten (sla) / bladgewassen',
    commonPests: const ['Slakken', 'Bladluis'],
    origin: 'Middellandse Zeegebied',
  ),
  CropProfileKey.spinazie: _p(
    key: CropProfileKey.spinazie,
    sunHoursIdeal: '4 – 6 uur',
    tempIdeal: '10 – 18 °C',
    waterNeed: 'Gemiddeld tot hoog',
    droughtSensitive: 'Hoog',
    edibleParts: 'Blad',
    bloomPeriodHint: 'Schiet door bij warmte/lange dagen.',
    plantFamilyHint: 'Amarantenfamilie / blad',
    goodNeighbors: const ['Aardbei', 'Erwt', 'Kool'],
    commonPests: const ['Bladluis', 'Slakken'],
  ),
  CropProfileKey.biet: _p(
    key: CropProfileKey.biet,
    waterNeed: 'Gemiddeld',
    soilType: 'Los, steenvrij; niet te vers bemest.',
    thinSeedlings: 'Belangrijk: clusters uitdunnen.',
    edibleParts: 'Knol en blad',
    plantFamilyHint: 'Ganzenvoetfamilie',
    goodNeighbors: const ['Ui', 'Kool', 'Sla'],
    harvestHow: 'Trek of spit voorzichtig; blad apart gebruiken.',
  ),
  CropProfileKey.wortel: _p(
    key: CropProfileKey.wortel,
    sunHoursIdeal: '6 uur',
    waterNeed: 'Gemiddeld',
    waterGermination: 'Constant vochtig tot opkomst (kritisch).',
    soilType: 'Diep los, steenvrij, geen verse mest (vertakte wortels).',
    phRange: 'pH 6,0 – 7,0',
    thinSeedlings: 'Essentieel tot juiste afstand.',
    edibleParts: 'Wortel',
    goodNeighbors: const ['Ui', 'Prei', 'Sla', 'Radijs'],
    badNeighbors: const ['Dille (soms)', 'Andere schermbloemigen dichtbij'],
    plantFamilyHint: 'Schermbloemigen (Apiaceae)',
    commonPests: const ['Wortelvlieg'],
    pestPlants: const ['Ui/prei als geurmasker'],
    storeHow: 'Koel in zand of koelkast; loof verwijderen.',
    origin: 'Afghanistan/Perzië-gebied; oranje peen later in Europa geselecteerd.',
    specialNotes:
        'Zaai ter plaatse: penwortels houden niet van verplanten. Alleen diepe modules als je toch wilt voorzaaien. Dun uit; houd kiembed 10–20 dagen vochtig.',
  ),
  CropProfileKey.radijs: _p(
    key: CropProfileKey.radijs,
    sunHoursIdeal: '4 – 6 uur',
    waterNeed: 'Gemiddeld tot hoog',
    droughtSensitive: 'Hoog (houtige knollen)',
    thinSeedlings: 'Ja, anders kleine/houtige knollen.',
    edibleParts: 'Knol (blad soms)',
    harvestFrequency: 'Snel; niet laten doorschieten.',
    plantFamilyHint: 'Kruisbloemigen',
    goodNeighbors: const ['Sla', 'Wortel', 'Erwt'],
    origin: 'Oostelijke Middellandse Zee / Azië.',
    daysToFruitHint: 'Vaak 3–6 weken na zaaien.',
    specialNotes:
        'Zaai ter plaatse in rijen of breedwerpig; uitplanten loont niet bij deze snelle teelt. Gelijkmatig vocht voorkomt houtige knollen.',
  ),
  CropProfileKey.kool: _p(
    key: CropProfileKey.kool,
    sunHoursIdeal: '6 – 8 uur',
    waterNeed: 'Gemiddeld tot hoog',
    soilType: 'Voedzaam, vaak kalkrijk genoeg; vaste structuur.',
    phRange: 'pH 6,5 – 7,5',
    fertiliserAdvice: 'Goede startgift; kool is een eter.',
    edibleParts: 'Krop/spruiten/bloem/blad naar type',
    goodNeighbors: const ['Ui', 'Biet', 'Sla', 'Dille'],
    badNeighbors: const ['Aardbei', 'Tomaat (concurrentie)'],
    plantFamilyHint: 'Kruisbloemigen (Brassicaceae)',
    rotationYears: '3 – 4 jaar geen koolachtigen',
    commonPests: const ['Koolvlieg', 'Rupsen', 'Aardvlo'],
    commonDiseases: const ['Knolvoet'],
    protectCold: 'Veel kolen verdraagt kou; net tegen vogels/rupsen.',
  ),
  CropProfileKey.ui: _p(
    key: CropProfileKey.ui,
    sunHoursIdeal: '6 – 8 uur',
    waterNeed: 'Laag tot gemiddeld',
    wetSensitive: 'Hoog',
    soilType: 'Los, niet vers bemest, onkruidvrij.',
    edibleParts: 'Bol / pijp (bosui)',
    supportNeeded: 'Nee',
    goodNeighbors: const ['Wortel', 'Sla', 'Aardbei'],
    badNeighbors: const ['Boon', 'Erwt'],
    plantFamilyHint: 'Lookfamilie (Amaryllidaceae)',
    commonPests: const ['Uienvlieg'],
    storeHow: 'Drogen en koel/droog bewaren (harde uien).',
  ),
  CropProfileKey.prei: _p(
    key: CropProfileKey.prei,
    waterNeed: 'Gemiddeld tot hoog',
    soilType: 'Diep bewerkt, voedzaam, vochthoudend.',
    growthHabit: 'Diep planten / aanaarden voor witte schacht.',
    edibleParts: 'Schacht en blad',
    plantFamilyHint: 'Lookfamilie',
    goodNeighbors: const ['Wortel', 'Selderij', 'Aardbei'],
    badNeighbors: const ['Boon'],
    commonPests: const ['Preimot', 'Uienvlieg'],
  ),
  CropProfileKey.knoflook: _p(
    key: CropProfileKey.knoflook,
    waterNeed: 'Laag tot gemiddeld',
    wetSensitive: 'Hoog (rot)',
    edibleParts: 'Teen / bol / groen',
    plantFamilyHint: 'Lookfamilie',
    harvestHow:
        'Oogst als het loof voor ±50–70% vergeelt; bol laten drogen (curing) op luchtige plek.',
    storeHow: 'Koel, droog, luchtig; vlecht of net.',
    winterCare:
        'Najaarspoten (okt–nov) of vroeg voorjaar; mulch bij strenge vorstwisseling.',
    origin: 'Centraal-Azië; eeuwenoude cultuurplant.',
    specialNotes:
        'Plant tenen (punt omhoog), geen zaailing. Kies pootknoflook, geen behandelde supermarktknoflook. Sjalot vergelijkbaar: plant bolletjes/tenen.',
  ),
  CropProfileKey.aardappel: _p(
    key: CropProfileKey.aardappel,
    sunHoursIdeal: '6 – 8 uur',
    waterNeed: 'Gemiddeld',
    soilType: 'Los; niet vers met verse stikstofpiek.',
    growthHabit: 'Aanaarden tegen groen worden.',
    edibleParts: 'Knol (groen = giftig)',
    plantFamilyHint: 'Nachtschade',
    rotationYears: '3 – 4 jaar geen nachtschade',
    commonPests: const ['Coloradokever'],
    commonDiseases: const ['Phytophthora'],
    storeHow: 'Donker, koel, droog; niet bij appel (etheen).',
    badNeighbors: const ['Tomaat'],
    origin: 'Andes (Zuid-Amerika).',
    specialNotes:
        'Poot gecertificeerd pootgoed (voorkiemen helpt). Geen zaailing-uitplant. Aanaarden zodra loof groeit. Zoete aardappel is een ander gewas (slips).',
  ),
  CropProfileKey.zoeteAardappel: _p(
    key: CropProfileKey.zoeteAardappel,
    frostSensitive: true,
    kasPreferred: true,
    sunHoursIdeal: '8+ uur',
    sunHoursMin: '6 uur',
    tempIdeal: '22 – 30 °C',
    tempMin: '18 °C (bodem)',
    waterNeed: 'Gemiddeld tot hoog',
    waterHow:
        'Na uitplanten goed aangieten; daarna regelmatig vochtig, vooral in warme droge periodes. Mulch helpt.',
    soilType:
        'Humusrijk, luchtig, goed doorlatend; ruggen of ruime bakken warmen sneller op.',
    edibleParts: 'Knol (jong blad soms eetbaar)',
    plantFamilyHint: 'Windefamilie (Ipomoea batatas)',
    growthHabit: 'Rankend loof; knollen laat in het seizoen.',
    harvestHow:
        'Oogst voorzichtig in sep–okt bij vergeeld loof of vóór vorst. Knollen zijn breekbaar.',
    storeHow:
        'Eerst 5–10 dagen warm/droog curen (ca. 25–30 °C), daarna kamertemperatuur droog bewaren — niet als gewone aardappel koel bewaren.',
    daysToFruitHint: '±120–150 dagen na uitplanten van slips (4–5 maanden).',
    origin: 'Tropisch Amerika.',
    kitchenUse: 'Bakken, puree, soep, friet.',
    specialNotes:
        'Teelt via slips (stekken), niet via pootknollen zoals aardappel. Jan–mrt: biologische knol laten uitlopen in water/grond; scheuten 10–15 cm afnemen, wortelen, na ijsheiligen (half mei–begin juni) uitplanten bij bodem ≥18 °C. Kas/zuidmuur/bak versnelt. Plantafstand ±40–50 cm.',
  ),
  CropProfileKey.mais: _p(
    key: CropProfileKey.mais,
    frostSensitive: true,
    sunHoursIdeal: '8+ uur',
    waterNeed: 'Hoog bij bloei/kolven',
    windSensitivity: 'Hoog',
    growthHabit: 'Blokvormig planten voor bestuiving.',
    selfPollinating: false,
    pollinators: 'Windbestuiving; plant in blokken, niet één rij.',
    edibleParts: 'Kolf',
    plantFamilyHint: 'Grassen',
    goodNeighbors: const ['Boon', 'Courgette (three sisters)'],
  ),
  CropProfileKey.boon: _p(
    key: CropProfileKey.boon,
    frostSensitive: true,
    sunHoursIdeal: '6 – 8 uur',
    waterNeed: 'Gemiddeld',
    wetSensitive: 'Hoog in kou',
    soilType: 'Niet te stikstofrijk; bonen binden stikstof.',
    nitrogenFixers: const ['Bonen zelf'],
    supportNeeded: 'Ja bij stokboon',
    supportHow: 'Stokken/latwerk meteen.',
    edibleParts: 'Peul / boon',
    goodNeighbors: const ['Mais', 'Komkommer', 'Sla'],
    badNeighbors: const ['Ui', 'Prei', 'Knoflook'],
    plantFamilyHint: 'Vlinderbloemigen',
    commonPests: const ['Bladluis', 'Slakken'],
  ),
  CropProfileKey.erwt: _p(
    key: CropProfileKey.erwt,
    frostSensitive: false,
    sunHoursIdeal: '6 uur',
    tempIdeal: '10 – 18 °C',
    waterNeed: 'Gemiddeld',
    supportNeeded: 'Ja',
    supportHow: 'Net, gaas of twijgen vroeg zetten.',
    edibleParts: 'Peul / erwt',
    plantFamilyHint: 'Vlinderbloemigen',
    nitrogenFixers: const ['Erwten zelf'],
    goodNeighbors: const ['Wortel', 'Radijs', 'Sla'],
    badNeighbors: const ['Ui', 'Look'],
    commonPests: const ['Vogels', 'Bladluis'],
  ),
  CropProfileKey.kruidZacht: _p(
    key: CropProfileKey.kruidZacht,
    frostSensitive: true, // basilicum; hardere kruiden minder — note in special
    sunHoursIdeal: '6 uur',
    indoorSuitable: true,
    waterNeed: 'Laag tot gemiddeld',
    wetSensitive: 'Hoog in pot',
    soilType: 'Luchtig, goede drainage (zeker in pot).',
    pinchTop: 'Ja — toppen voor bossige groei (basilicum e.d.).',
    edibleParts: 'Blad / stengel',
    prune: 'Regelmatig oogsten = snoeien.',
    kitchenUse: 'Vers, drogen, olie, thee.',
    specialNotes:
        'Basilicum is vorstgevoelig; tijm/rozemarijn/salie zijn hardere mediterrane kruiden.',
    plantFamilyHint: 'Verschillend per kruid',
    goodNeighbors: const ['Tomaat (basilicum)', 'Kool (dille)'],
  ),
  CropProfileKey.meerjarig: _p(
    key: CropProfileKey.meerjarig,
    frostSensitive: false,
    sunHoursIdeal: '6 – 8 uur',
    sunHoursMin: '4 – 6 uur',
    waterNeed: 'Gemiddeld (eerste jaar hoger)',
    soilType:
        'Diep bewerkt, voedzaam, goed doorlatend. Asperge: lichte/zandige voorkeur. Rabarber: vochthoudend en rijk.',
    winterCare:
        'Asperge: loof pas afknippen als het volledig is afgestorven (najaar). Rabarber: blad afsterven laten; mulch. Artisjok: terugknippen en afdekken met stro/blad (matig winterhard).',
    edibleParts:
        'Naar soort: aspergescheuten, rabarberstelen, artisjokknoppen, aardpeerknollen…',
    plantFamilyHint:
        'Verschillend (asperge, duizendknoopachtigen, composieten…)',
    rotationYears: 'Vaste plek; geen jaarlijkse wisselteelt zoals eenjarigen.',
    prune:
        'Rabarber: bloemstengels weg. Asperge: loof laten staan tot afgestorven. Artisjok: uitgebloeide stengels weg.',
    harvestHow:
        'Asperge: jaar 1–2 niet oogsten; daarna beperkt, later 6–8 weken in voorjaar. Rabarber: stelen trekken (niet snijden), blad niet eten; eerste jaar spaarzaam. Artisjok: knoppen oogsten vóór openbloei.',
    daysToFruitHint:
        'Asperge: eerste echte oogst vaak jaar 3. Rabarber: vanaf jaar 2–3. Artisjok: soms al jaar 1–2 bij plantgoed.',
    origin: 'Europa/Middellandse Zee (soortafhankelijk).',
    specialNotes:
        'Plant bij voorkeur plantgoed/kronen/scheurlingen i.p.v. alleen zaad. Asperge: kronen in geul, diep voorbereid bed, 10–15 jaar productief. Rabarber: neuzen net boven grond, ±1 m ruimte, scheuren na 4–5 jaar. Artisjok: veel ruimte, warm/beschut, winterbescherming in NL.',
  ),
  CropProfileKey.fruitZaad: _p(
    key: CropProfileKey.fruitZaad,
    frostSensitive: false,
    sunHoursIdeal: '6 – 8 uur',
    sunHoursMin: '5 uur',
    waterNeed: 'Gemiddeld (jaar 1–2 hoger)',
    waterHow:
        'Eerste twee seizoenen regelmatig water bij droogte. Mulch rond de voet (niet tegen stam).',
    soilType:
        'Goed doorlatend, humusrijk. Blauwe bes: zure grond (pH ±4,5–5,5). Steenfruit/pitfruit: eerder neutraal.',
    supportNeeded: 'Vaak ja',
    supportHow:
        'Jonge boom: paal + losse band. Druif/braam/framboos: gaas of draden. Kiwi: stevig latwerk.',
    prune:
        'Pitfruit (appel/peer): wintersnoei voor vorm/licht. Steenfruit (pruim/kers): liever kort na oogst of late zomer (minder loodglansrisico). Bessen/framboos: oude takken weg volgens type (zomer-/herfstframboos). Druif: wintersnoei op korte vruchtsporen.',
    edibleParts: 'Vrucht',
    plantFamilyHint:
        'Vaak rozenfamilie (appel, peer, pruim, kers, braam…); uitzonderingen per soort',
    rotationYears: 'Vaste standplaats',
    winterCare:
        'Wildvraatbescherming (koker/gaas). Vorstgevoelige soorten (vijg, sommige kiwi’s) beschermen of in kuip.',
    protectCold:
        'Bloesemvorst bij vroege bloeiers (pruim/kers/abrikoos): vlies bij aangekondigde vorst. Kuipplanten (citroen e.d.) vorstvrij overwinteren.',
    harvestHow:
        'Pluk rijp naar soort; steeltje meenemen waar dat de houdbaarheid helpt.',
    storeHow:
        'Koel; ethyleengevoelige mix vermijden (appel naast aardappel).',
    origin:
        'Wereldwijd; veel Europese fruitsoorten al eeuwen in NL/BE geteeld.',
    funFact:
        'Onderstam bepaalt boomgrootte en groeikracht: kies halfstam/zwakke onderstam voor kleine tuinen.',
    specialNotes:
        'Koop plantgoed (container of naakte wortel) i.p.v. zaaien als je vrucht wilt. Planttijd: naakte wortel nov–mrt (niet bij vorst); container bijna jaarrond bij milde omstandigheden. Enting moet boven de grond blijven. Bestuiving: check of het ras zelfbestuivend is of een bestuiver-ras nodig heeft.',
  ),
  CropProfileKey.aardbei: _p(
    key: CropProfileKey.aardbei,
    sunHoursIdeal: '6 – 8 uur',
    waterNeed: 'Gemiddeld tot hoog',
    soilType: 'Humusrijk, doorlatend; hart vrij houden.',
    mulch: 'Stro/mulch tegen rot en schoon fruit.',
    edibleParts: 'Vrucht',
    harvestFrequency: 'Dagelijks in piek.',
    plantFamilyHint: 'Rozenfamilie',
    goodNeighbors: const ['Prei', 'Sla', 'Bieslook'],
    badNeighbors: const ['Kool'],
    commonPests: const ['Slakken', 'Vogels'],
    commonDiseases: const ['Grauwe schimmel'],
  ),
  CropProfileKey.okra: _p(
    key: CropProfileKey.okra,
    frostSensitive: true,
    kasPreferred: true,
    sunHoursIdeal: '8+ uur',
    tempIdeal: '24 – 32 °C',
    tempMin: '18 °C',
    waterNeed: 'Gemiddeld tot hoog',
    waterHow: 'Warm en gelijkmatig vochtig; niet koud water op koude wortels.',
    soilType: 'Warm, voedzaam, doorlatend.',
    supportNeeded: 'Ja bij langere planten',
    supportHow: 'Lichte stok tegen omwaaien.',
    edibleParts: 'Jonge peulen',
    harvestFrequency: 'Om de 1–2 dagen; peulen jong oogsten (anders taai).',
    ripenessSigns: '5–10 cm (rasafhankelijk), nog makkelijk breekbaar.',
    daysToFruitHint: '±50–70 dagen na uitplanten bij echte warmte.',
    plantFamilyHint: 'Kaasjeskruidfamilie',
    origin: 'Afrika; via handel wereldwijd in warme klimaten.',
    kitchenUse: 'Roerbak, stoof, soep (gumbo); slijmerig bij lang koken.',
    specialNotes:
        'In NL vrijwel alleen zinvol in kas of zeer warme kuip/zuidmuur. Voorzaaien warm, uitplanten pas bij stabiele warmte. Buiten in koele zomers blijft oogst beperkt — dat is klimaat, geen fout van de teler.',
  ),
  CropProfileKey.gember: _p(
    key: CropProfileKey.gember,
    frostSensitive: true,
    kasPreferred: true,
    indoorSuitable: true,
    sunHoursIdeal: 'Lichte halfschaduw tot gefilterd licht',
    tempIdeal: '22 – 28 °C',
    waterNeed: 'Gemiddeld',
    wetSensitive: 'Hoog (rot)',
    waterHow:
        'Licht vochtig houden; nooit koud en sopnat. In rust/winter veel minder water.',
    soilType: 'Luchtige, humusrijke potgrond met drainage.',
    edibleParts: 'Rizoom',
    harvestHow:
        'Na ±8–10 maanden voorzichtig uitgraven; of stukjes oogsten en rest laten staan.',
    daysToFruitHint:
        'Scheuten na weken; bruikbaar rizoom vaak na één groeiseizoen.',
    origin: 'Zuidoost-Azië.',
    kitchenUse: 'Vers, thee, wok, gebak.',
    specialNotes:
        'Geen zaailing: poot stukken biologisch rizoom (ogen/groeipunten) 2–3 cm diep in kuip/kas vanaf voorjaar. Buiten NL alleen in warme zomer; vorstvrij overwinteren. Supermarktrizoom kan geremd zijn — biologisch werkt betrouwbaarder.',
  ),
  CropProfileKey.tauge: _p(
    key: CropProfileKey.tauge,
    frostSensitive: false,
    indoorSuitable: true,
    sunHoursIdeal: 'Donker tijdens kieming',
    waterNeed: 'Spoelen 2–3× daags',
    waterHow:
        'Mungbonen spoelen met schoon water, goed uitlekken; geen stilstaand water.',
    edibleParts: 'Kiem',
    harvestFrequency: 'Na 3–6 dagen',
    harvestHow:
        'Oogst als de kiem de gewenste lengte heeft; spoel en eet vers.',
    daysToFruitHint: '3 – 6 dagen',
    origin: 'Azië (mungboon: Vigna radiata).',
    kitchenUse: 'Rauw in salade, kort wokken, soep.',
    specialNotes:
        'Keukenkiemgroente, geen tuinuitplant. Gebruik kiemzaad/mungbonen zonder coating. Hygiëne belangrijk; bij twijfel weggooien.',
  ),
  CropProfileKey.algemeen: _p(
    key: CropProfileKey.algemeen,
    specialNotes:
        'Algemeen teeltprofiel voor soorten zonder apart groepprofiel. Controleer altijd raslabel en lokale vorstdata.',
  ),
};
