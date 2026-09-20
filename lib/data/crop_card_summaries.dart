import '../models/vegetable.dart';
import 'plant_crop_profiles.dart';

String _name(Vegetable v) => v.nameNl.split('(').first.trim();

String _first(List<String> items, String fallback) =>
    items.isNotEmpty ? items.first : fallback;

/// Unieke, korte samenvatting onder een groente-/kruid-/fruit-kop (kaarttekst).
/// De rest van de uitleg staat in Meer info.
String cropCardSummaryFor({
  required String tab,
  required String title,
  required Vegetable vegetable,
  CropProfile? profile,
}) {
  final p = profile ?? cropProfileFor(vegetable.id);
  final name = _name(vegetable);
  final t = title.trim().toLowerCase();
  final tabKey = tab.trim().toLowerCase();

  switch (tabKey) {
    case 'sowing':
    case 'zaaien':
      return _sowing(t, name, p, vegetable);
    case 'transplant':
    case 'uitplanten':
      return _transplant(t, name, p, vegetable);
    case 'location':
    case 'standplaats':
      return _location(t, name, p);
    case 'water':
      return _water(t, name, p, vegetable);
    case 'nutrition':
    case 'voeding':
      return _nutrition(t, name, p);
    case 'growth':
    case 'groei':
      return _growth(t, name, p);
    case 'bloom':
    case 'bloei':
      return _bloom(t, name, p);
    case 'harvest':
    case 'oogst':
      return _harvest(t, name, p);
    case 'care':
    case 'verzorging':
      return _care(t, name, p);
    case 'problems':
    case 'problemen':
      return _problems(t, name, p, vegetable);
    case 'combination':
    case 'combinaties':
      return _combination(t, name, p);
    case 'weetjes':
      return _weetjes(t, name, p);
    default:
      return p.specialNotes.isNotEmpty
          ? p.specialNotes
          : 'Belangrijkste tip voor $name: juist water, standplaats en timing in NL.';
  }
}

String _shortHint(String text, String fallback, {int max = 110}) {
  final t = text.trim();
  if (t.isEmpty) return fallback;
  if (t.length <= max) return t;
  final cut = t.substring(0, max);
  final lastSpace = cut.lastIndexOf(' ');
  return '${(lastSpace > 40 ? cut.substring(0, lastSpace) : cut).trimRight()}…';
}

String _sowing(String t, String name, CropProfile p, Vegetable v) {
  if (t.contains('binnen')) {
    return _shortHint(
      v.sowingIndoors,
      p.frostSensitive
          ? 'Voorzaai $name binnen voor een voorsprong; uitplanten na ijsheiligen.'
          : 'Voorzaai $name binnen indien je vroeger wilt oogsten.',
    );
  }
  if (t.contains('buiten')) {
    return _shortHint(
      v.sowingOutdoors,
      'Zaai $name buiten als de grond warm genoeg is en nachtvorst voorbij is.',
    );
  }
  if (t.contains('zaaidiepte') || t == 'diepte') {
    return 'Zaai $name niet te diep — te diep remt kieming, te ondiep droogt uit.';
  }
  if (t.contains('kiemduur')) {
    return 'Kiemduur van $name hangt af van warmte: koeler weer = trager.';
  }
  if (t.contains('kiemtemp') || t.contains('temperatuur')) {
    return 'Ideaal rond ${p.tempIdeal}; te koud = trage of geen kieming.';
  }
  if (t.contains('licht')) {
    return 'Zet $name-zaailingen licht; te donker = lange, slappe planten.';
  }
  if (t.contains('water')) {
    return 'Houd zaaigrond van $name licht vochtig, nooit sopnat (schimmelrisico).';
  }
  if (t.contains('verspenen')) {
    return 'Verspeen $name na 2–4 echte blaadjes voor stevige groei.';
  }
  if (t.contains('oppotten')) {
    return 'Verpot $name zodra wortels de pot vullen; anders remt groei.';
  }
  if (t.contains('afharden')) {
    return p.frostSensitive
        ? 'Hard $name 7–14 dagen af; pas vast buiten na ijsheiligen.'
        : 'Hard $name geleidelijk af zodat koude nachten geen klap geven.';
  }
  return 'Zaai $name op tijd en houd gelijkmatig vochtig tot kieming.';
}

String _transplant(String t, String name, CropProfile p, Vegetable v) {
  if (t.contains('periode') || t.contains('uitplantperiode')) {
    return _shortHint(
      v.transplant,
      p.frostSensitive
          ? 'Plant $name uit na ijsheiligen (± half mei) bij warme grond.'
          : 'Plant $name uit zodra de grond bewerkbaar is en vorst voorbij.',
    );
  }
  if (t.contains('voorwaarde')) {
    return p.frostSensitive
        ? 'Geen nachtvorst, bodem warm genoeg, stevige zaailing — $name is vorstgevoelig.'
        : 'Losse grond, voldoende licht; $name verdraagt koel weer beter.';
  }
  if (t.contains('afharden')) {
    return 'Laat $name 5–10 dagen wennen: eerst halfschaduw, daarna meer zon.';
  }
  if (t.contains('plantafstand') && !t.contains('rij')) {
    return 'Geef $name genoeg ruimte voor lucht — minder schimmel in vochtig NL-weer.';
  }
  if (t.contains('rijafstand')) {
    return 'Rijen ruim genoeg voor pad, licht en snelle droging na regen.';
  }
  if (t.contains('plantdiepte') || (t.contains('diepte') && !t.contains('zaai'))) {
    return p.key == CropProfileKey.tomaat
        ? 'Plant $name iets dieper dan in de pot: stengelwortels geven extra stevigheid.'
        : 'Plant $name op dezelfde diepte als in de pot; te diep remt aanslaan.';
  }
  if (t.contains('locatie') || t.contains('plek')) {
    return '$name: ${p.sunHoursIdeal} zon · water ${p.waterNeed.toLowerCase()}.';
  }
  if (t.contains('bodem')) {
    return p.soilType;
  }
  if (t.contains('water')) {
    return 'Geef $name na uitplanten goed water; daarna ${p.waterHow}';
  }
  if (t.contains('steun') || t.contains('ondersteun')) {
    return p.supportNeeded.toLowerCase().contains('ja') ||
            p.supportNeeded.toLowerCase().contains('vaak')
        ? p.supportHow
        : 'Steun bij $name alleen nodig bij klim- of hoge gewassen.';
  }
  if (t.contains('bescherm')) {
    return p.frostSensitive
        ? 'Bescherm jonge $name met vliesdoek bij late kou.'
        : 'Bescherm $name tegen wind, felle zon en slakken vlak na uitplant.';
  }
  if (t.contains('aanslaan') || t.contains('eerste groei')) {
    return '$name slaat in 1–2 weken aan bij gelijkmatig vocht.';
  }
  if (t.contains('oogst')) {
    return p.daysToFruitHint.isNotEmpty
        ? p.daysToFruitHint
        : 'Eerste oogst hangt af van ras en seizoen — zie oogsttab.';
  }
  if (t.contains('fout')) {
    return 'Vaak mis bij $name: te vroeg uitplanten, droogte of te diep planten.';
  }
  return 'Plant $name stevig uit, geef water en bescherm de eerste dagen.';
}

String _location(String t, String name, CropProfile p) {
  if (t.contains('ideale') || t.contains('standplaats')) {
    return '$name wil ${p.sunHoursIdeal} zon — sleutel tot goede groei in NL.';
  }
  if (t.contains('zonuren')) {
    return 'Mik op ${p.sunHoursIdeal}; onder ${p.sunHoursMin} blijft $name mager.';
  }
  if (t.contains('locatie') || t.contains('geschikt')) {
    return p.kasPreferred
        ? '$name doet het vaak beter in kas of beschutte warme plek.'
        : '$name past in volle grond, bak of pot op een lichte plek.';
  }
  if (t.contains('ruimte') || t.contains('benodigde')) {
    return 'Geef $name ruimte zodat bladeren snel drogen na regen.';
  }
  if (t.contains('plantafstand')) {
    return 'Voldoende afstand voorkomt schimmel bij $name in vochtig weer.';
  }
  if (t.contains('rijafstand')) {
    return 'Rijen ruim genoeg voor licht, pad en luchtcirculatie.';
  }
  if (t.contains('wind')) {
    return 'Windgevoeligheid $name: ${p.windSensitivity}. ${p.supportHow}';
  }
  if (t.contains('temperatuur')) {
    return 'Ideaal ${p.tempIdeal} (min ${p.tempMin}, max ${p.tempMax}).';
  }
  if (t.contains('vorst')) {
    return p.frostSensitive
        ? '$name is vorstgevoelig — wacht op milde nachten / ijsheiligen.'
        : '$name verdraagt kou beter; jonge groei kan nog vorstschade tonen.';
  }
  if (t.contains('luchtvochtig')) {
    return 'Luchtvochtigheid: ${p.humidityLevel}. Goede lucht = minder schimmel.';
  }
  if (t.contains('kas')) {
    return p.kasPreferred
        ? 'Kas helpt $name in NL; ventileer tegen schimmel.'
        : '$name kan buiten; kas alleen voor vroege voorsprong.';
  }
  if (t.contains('binnen')) {
    return p.indoorSuitable
        ? '$name kan (tijdelijk) binnen met veel licht.'
        : 'Binnen vooral voor opkweek; $name wil buiten licht voor oogst.';
  }
  return '$name: ${p.sunHoursIdeal} zon, temp rond ${p.tempIdeal}.';
}

String _water(String t, String name, CropProfile p, Vegetable v) {
  if (t.contains('behoefte')) {
    return '$name: ${p.waterNeed.toLowerCase()} waterbehoefte — check de bovenlaag vóór je giet.';
  }
  if (t.contains('water geven') || t == 'water geven') {
    return p.waterHow;
  }
  if (t.contains('kieming')) {
    return p.waterGermination;
  }
  if (t.contains('groei') && !t.contains('probleem')) {
    return p.waterGrowth;
  }
  if (t.contains('bloei')) {
    return p.waterBloom;
  }
  if (t.contains('vrucht') ||
      t.contains('bladgroei') ||
      t.contains('wortel') ||
      t.contains('bol') ||
      t.contains('peul') ||
      t.contains('kolf') ||
      t.contains('volle groei') ||
      t.contains('na de bloei') ||
      t.contains('oogstperiode')) {
    return cropLateStageWaterHow(v.id);
  }
  if (t.contains('droogte')) {
    return 'Droogtegevoeligheid $name: ${p.droughtSensitive}. ${p.tooLittleSigns}';
  }
  if (t.contains('natte') || t.contains('nat ')) {
    return 'Natte-grond risico: ${p.wetSensitive}. ${p.tooMuchSigns}';
  }
  if (t.contains('te weinig')) {
    return p.tooLittleSigns;
  }
  if (t.contains('te veel')) {
    return p.tooMuchSigns;
  }
  if (t.contains('kwaliteit')) {
    return 'Regenwater of lauw kraanwater is prima voor $name.';
  }
  if (t.contains('pot')) {
    return p.potCare.isNotEmpty
        ? p.potCare
        : 'In pot droogt $name sneller — check vaker in de zomer.';
  }
  if (t.contains('kas')) {
    return p.greenhouseCare.isNotEmpty
        ? p.greenhouseCare
        : 'In de kas: water én ventileren, anders schimmel bij $name.';
  }
  if (t.contains('tip')) {
    return 'Mulch en ochtendgift houden $name stabiel vochtig in NL-zomers.';
  }
  return '${p.waterNeed}: ${p.waterHow}';
}

String _nutrition(String t, String name, CropProfile p) {
  if (t.contains('voedingsbehoefte') || t == 'voedingsbehoefte') {
    return p.fertiliserAdvice;
  }
  if (t.contains('bodem')) {
    return p.soilType;
  }
  if (t.contains('ph')) {
    return 'Houd pH rond ${p.phRange} zodat $name voeding kan opnemen.';
  }
  if (t.contains('compost')) {
    return p.compostAdvice;
  }
  if (t.contains('beste mest') || t.contains('mest voor')) {
    return p.fertiliserAdvice;
  }
  if (t.contains('voedingsstoffen') || t.contains('belangrijkste')) {
    return p.mainNutrients;
  }
  if (t.contains('bij planten')) {
    return p.feedAtPlant;
  }
  if (t.contains('tijdens groei')) {
    return p.feedDuringGrowth;
  }
  if (t.contains('tijdens bloei') || (t.contains('bloei') && t.contains('bemest'))) {
    return p.feedBloom;
  }
  if (t.contains('vrucht') ||
      t.contains('bladgroei') ||
      t.contains('wortel') ||
      t.contains('bol') ||
      t.contains('peul') ||
      t.contains('na de bloei') ||
      t.contains('oogstperiode') ||
      t.contains('volle groei')) {
    return p.feedFruit;
  }
  if (t.contains('tekort')) {
    return p.deficiencySigns;
  }
  if (t.contains('overbemesting') || t.contains('teveel')) {
    return p.overfeedSigns;
  }
  if (t.contains('schema') || t.contains('tip')) {
    return 'Schema $name: ${p.feedAtPlant} Daarna ${p.feedDuringGrowth}';
  }
  return p.fertiliserAdvice;
}

String _growth(String t, String name, CropProfile p) {
  if (t.contains('fase') || t.contains('groeifase')) {
    return '$name groeit ${p.growthSpeed.toLowerCase()}: ${p.growthHabit}';
  }
  if (t.contains('duur') || t.contains('tijd tot')) {
    return p.daysToFruitHint.isNotEmpty
        ? p.daysToFruitHint
        : 'Tijd tot oogst hangt af van ras en NL-weer.';
  }
  if (t.contains('hoogte') || t.contains('breedte') || t.contains('habit')) {
    return p.growthHabit;
  }
  if (t.contains('groeiwijze') || t.contains('snelheid')) {
    return 'Groeisnelheid $name: ${p.growthSpeed}. ${p.growthHabit}';
  }
  if (t.contains('steun') || t.contains('opbinden') || t.contains('ondersteun')) {
    return p.supportHow;
  }
  if (t.contains('toppen')) {
    return p.pinchTop;
  }
  if (t.contains('dieven')) {
    return p.removeSuckers;
  }
  if (t.contains('uitdunnen')) {
    return p.thinSeedlings;
  }
  if (t.contains('stimuleren')) {
    return 'Stimuleer $name met zon (${p.sunHoursIdeal}), water en tijdige verzorging.';
  }
  if (t.contains('probleem') || t.contains('stress')) {
    return p.growthProblems;
  }
  if (t.contains('gezond')) {
    return p.healthySigns;
  }
  if (t.contains('tip') || t.contains('seizoen')) {
    return p.seasonCare.isNotEmpty ? p.seasonCare : p.healthySigns;
  }
  return '${p.growthSpeed} groei — ${p.growthHabit}';
}

String _bloom(String t, String name, CropProfile p) {
  if (t.contains('bloeiperiode') || t == 'periode') {
    return p.bloomPeriodHint;
  }
  if (t.contains('eerste')) {
    return 'Eerste bloei van $name: ${p.bloomPeriodHint}';
  }
  if (t.contains('vrucht') || t.contains('bloei en oogst')) {
    return p.daysToFruitHint;
  }
  if (t.contains('zelfbestuiv')) {
    return p.selfPollinating
        ? 'Eén $name is meestal genoeg; insecten helpen nog steeds.'
        : 'Voor goede bestuiving heeft $name insecten of een tweede plant nodig.';
  }
  if (t.contains('manlijk') || t.contains('vrouwel') || t.contains('bloemen')) {
    return p.hasSeparateSexFlowers
        ? '$name heeft aparte mannelijke en vrouwelijke bloemen — bestuiving telt.'
        : 'Bloemen van $name zijn meestal compleet; insecten helpen bij zetting.';
  }
  if (t.contains('bestuiv') || t.contains('bijen')) {
    return p.pollinators;
  }
  if (t.contains('stimuleren')) {
    return p.bloomStimulate;
  }
  if (t.contains('verwijderen') || t.contains('uitgebloeid')) {
    return p.removeFlowersAdvice;
  }
  if (t.contains('hand') || t.contains('zelf je')) {
    return p.handPollinate;
  }
  if (t.contains('gezond')) {
    return p.bloomHealthy;
  }
  if (t.contains('probleem')) {
    return p.bloomProblems;
  }
  if (t.contains('eetbaar')) {
    return p.flowersEdible;
  }
  return '${p.bloomPeriodHint} — ${p.pollinators}';
}

String _harvest(String t, String name, CropProfile p) {
  if (t.contains('oogstperiode') || t.contains('wanneer')) {
    return p.daysToFruitHint.isNotEmpty
        ? p.daysToFruitHint
        : 'Oogst $name wanneer ${p.ripenessSigns}';
  }
  if (t.contains('tijd tot')) {
    return p.daysToFruitHint;
  }
  if (t.contains('frequentie')) {
    return p.harvestFrequency;
  }
  if (t.contains('rijp') || t.contains('herkennen')) {
    return p.ripenessSigns;
  }
  if (t.contains('hoe oogst') || t.contains('methode')) {
    return p.harvestHow;
  }
  if (t.contains('opbrengst') || t.contains('per plant') || t.contains('m²')) {
    return p.yieldHint;
  }
  if (t.contains('stimuleren') || t.contains('doorgroeien')) {
    return 'Regelmatig oogsten houdt $name langer productief.';
  }
  if (t.contains('bewaar')) {
    return p.storeHow;
  }
  if (t.contains('invries') || t.contains('vries')) {
    return p.freezeHow;
  }
  if (t.contains('drogen')) {
    return p.dryHow;
  }
  if (t.contains('zaad')) {
    return p.saveSeeds;
  }
  if (t.contains('probleem')) {
    return p.harvestProblems;
  }
  if (t.contains('eetbaar') || t.contains('delen')) {
    return 'Eetbaar: ${p.edibleParts}.';
  }
  if (t.contains('perfect') || t.contains('teken')) {
    return p.ripenessSigns;
  }
  return p.harvestHow;
}

String _care(String t, String name, CropProfile p) {
  if (t.contains('dagelijk')) {
    return p.dailyCheck;
  }
  if (t.contains('wekelijk')) {
    return p.weeklyCheck;
  }
  if (t.contains('onderhoud')) {
    return 'Houd $name schoon: oude bladeren weg, onkruid weg, lucht houden.';
  }
  if (t.contains('snoeien') || t.contains('snoei')) {
    return p.prune;
  }
  if (t.contains('toppen')) {
    return p.pinchTop;
  }
  if (t.contains('dieven')) {
    return p.removeSuckers;
  }
  if (t.contains('opbinden') || t.contains('ondersteun') || t.contains('steun')) {
    return p.supportHow;
  }
  if (t.contains('mulch')) {
    return p.mulch;
  }
  if (t.contains('onkruid')) {
    return p.weed;
  }
  if (t.contains('hitte')) {
    return p.protectHeat;
  }
  if (t.contains('kou') || t.contains('vorst')) {
    return p.protectCold;
  }
  if (t.contains('wind') || t.contains('regen') || t.contains('bescherm') || t.contains('dieren')) {
    return 'Bescherm $name tegen extreem weer; ${p.protectCold}';
  }
  if (t.contains('gezond') || t.contains('waarschuwing')) {
    return '${p.healthySigns} Let op: ${p.stressSigns}';
  }
  if (t.contains('seizoen')) {
    return p.seasonCare;
  }
  if (t.contains('winter')) {
    return p.winterCare;
  }
  if (t.contains('pot')) {
    return p.potCare;
  }
  if (t.contains('kas')) {
    return p.greenhouseCare;
  }
  return p.dailyCheck;
}

String _problems(String t, String name, CropProfile p, Vegetable v) {
  if (t.contains('symptoom') || t.contains('herkennen')) {
    return p.problemSymptoms;
  }
  if (t.contains('insect') || t.contains('plaag')) {
    return 'Let op ${_first(p.commonPests, 'bladluis')} bij $name.';
  }
  if (t.contains('schimmel') || t.contains('ziekte')) {
    return 'Risico: ${_first(p.commonDiseases, 'schimmel')} — lucht en droog blad helpen.';
  }
  if (t.contains('voeding')) {
    return p.deficiencySigns;
  }
  if (t.contains('water')) {
    return 'Te weinig: ${p.tooLittleSigns} Te veel: ${p.tooMuchSigns}';
  }
  if (t.contains('weer')) {
    return p.frostSensitive
        ? 'Vorst, hitte en natte weken zijn de grootste stress voor $name.'
        : 'NL-weer: natte periodes en hittegolven kunnen $name stressen.';
  }
  if (t.contains('bestuiv')) {
    return cropFruitsForHarvest(v.id)
        ? 'Slechte zetting? Check warmte, droogte en bestuivers bij $name.'
        : 'Bestuiving is bij dit gewas minder kritisch voor de oogst.';
  }
  if (t.contains('groei')) {
    return p.growthProblems;
  }
  if (t.contains('pot') || t.contains('kas')) {
    return 'In pot/kas: vaker waterproblemen en schimmel — drainage en ventilatie.';
  }
  if (t.contains('dier')) {
    return 'Slakken, vogels of konijnen kunnen $name beschadigen — bescherm tijdig.';
  }
  return p.problemSymptoms;
}

String _combination(String t, String name, CropProfile p) {
  if (t.contains('goede') && t.contains('buren')) {
    return '$name past goed bij ${_first(p.goodNeighbors, 'passende buren')}.';
  }
  if (t.contains('slechte')) {
    return p.badNeighbors.isNotEmpty
        ? 'Vermijd naast $name: ${p.badNeighbors.first}.'
        : 'Geen harde tegenindicaties — let op schaduw en concurrentie.';
  }
  if (t.contains('familie') || t.contains('plantfamilie')) {
    return 'Familie: ${p.plantFamilyHint}. Wissel families om ziekten te beperken.';
  }
  if (t.contains('wisselteelt')) {
    return 'Wisselteelt: ${p.rotationYears}.';
  }
  if (t.contains('voorganger')) {
    return p.predecessors.isNotEmpty
        ? 'Goede voorgangers: ${p.predecessors.take(2).join(', ')}.'
        : 'Na groenbemester of licht gewas heeft $name een goede start.';
  }
  if (t.contains('opvolger')) {
    return p.successors.isNotEmpty
        ? 'Goede opvolgers: ${p.successors.take(2).join(', ')}.'
        : 'Na $name volgt vaak een ander gewas uit een andere familie.';
  }
  if (t.contains('gezelschap') || t.contains('combinatievoordeel') || t.contains('voordeel')) {
    return p.comboBenefits.isNotEmpty
        ? p.comboBenefits
        : '$name combineert goed voor groei, plagen en biodiversiteit.';
  }
  if (t.contains('plaag') || t.contains('tegen')) {
    return p.pestPlants.isNotEmpty
        ? 'Tegen plagen: ${p.pestPlants.take(2).join(', ')}.'
        : 'Geurende buren helpen plagen rond $name te verstoren.';
  }
  if (t.contains('bodem') || t.contains('stikstof') || t.contains('groenbemest')) {
    return p.soilImprovers.isNotEmpty
        ? 'Bodemhelpers: ${p.soilImprovers.take(2).join(', ')}.'
        : 'Groenbemesters en klaver verbeteren de bodem rond $name.';
  }
  if (t.contains('ruimte') || t.contains('fout')) {
    return p.comboMistakes.isNotEmpty
        ? p.comboMistakes
        : 'Plant $name niet te dicht — anders meer schimmel en concurrentie.';
  }
  return '$name + ${_first(p.goodNeighbors, 'goede buren')} = sterkere moestuin.';
}

String _weetjes(String t, String name, CropProfile p) {
  if (t.contains('oorsprong')) {
    return _shortHint(
      p.origin,
      '$name komt uit een gematigd tot warm klimaat; in NL goed te telen met timing.',
      max: 100,
    );
  }
  if (t.contains('historie') || t.contains('geschiedenis')) {
    return '$name heeft een lange teeltgeschiedenis — zie Meer info voor details.';
  }
  if (t.contains('naam') || t.contains('betekenis')) {
    return _shortHint(
      p.nameMeaning,
      'De naam van $name zegt iets over herkomst of eigenschappen.',
      max: 100,
    );
  }
  if (t.contains('plantenfamilie')) {
    return '$name hoort bij ${p.plantFamilyHint} — belangrijk voor wisselteelt.';
  }
  if (t.contains('familie')) {
    return 'Familie: ${p.plantFamilyHint}.';
  }
  if (t.contains('nuttig') || t.contains('dieren') || t.contains('bijen')) {
    return 'Bijen, hommels en lieveheersbeestjes helpen $name in de moestuin.';
  }
  if (t.contains('wereld') || t.contains('productie')) {
    return '$name wordt wereldwijd geteeld; in NL vooral in moestuin en kas.';
  }
  if (t.contains('bijzonder')) {
    return _shortHint(
      p.specialNotes.isNotEmpty ? p.specialNotes : p.funFact,
      'Opvallende kenmerken van $name staan in Meer info.',
      max: 100,
    );
  }
  if (t.contains('wist') || t.contains('feit')) {
    return _shortHint(
      p.funFact,
      'Leuk weetje over $name — tik voor de volledige tip.',
      max: 100,
    );
  }
  if (t.contains('eetbaar') || t.contains('delen')) {
    return 'Eetbaar: ${p.edibleParts}.';
  }
  if (t.contains('gezondheid')) {
    return _shortHint(
      p.healthBenefits,
      'Verse $name uit eigen tuin is voedzaam — zie Meer info.',
      max: 100,
    );
  }
  if (t.contains('keuken') || t.contains('gebruik')) {
    return _shortHint(
      p.kitchenUse,
      '$name past in veel bereidingen — zie Meer info.',
      max: 100,
    );
  }
  if (t.contains('ras') || t.contains('populair')) {
    return 'Kies een ras van $name dat past bij het NL-klimaat en jouw teeltwijze.';
  }
  if (t.contains('verrassend') || t.contains('toepassing')) {
    return _shortHint(
      p.funFact.isNotEmpty ? p.funFact : p.kitchenUse,
      'Meer dan alleen eten — zie verrassende toepassingen.',
      max: 100,
    );
  }
  return _shortHint(
    p.funFact.isNotEmpty ? p.funFact : p.specialNotes,
    'Weetje over $name — tik voor meer.',
    max: 100,
  );
}
