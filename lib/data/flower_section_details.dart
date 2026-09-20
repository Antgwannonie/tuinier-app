import '../models/vegetable.dart';
import 'flower_guide_profiles.dart';
import 'plant_guide_detail.dart';

/// Bouwt uitgebreide detailteksten per bloemen-kop, op basis van flower-profiel.
List<PlantGuideDetailBlock> flowerSectionDetailsFor({
  required String tab,
  required String title,
  required Vegetable vegetable,
  FlowerGuideProfile? profile,
}) {
  final p = profile ?? flowerGuideProfileFor(vegetable.id);
  final name = vegetable.nameNl.split('(').first.trim();
  final t = title.trim().toLowerCase();
  final gap = (p.note != null && p.note!.trim().isNotEmpty) ? p.note : p.tip;

  List<PlantGuideDetailBlock> d({
    required String why,
    required String how,
    required String tip,
    String? meaning,
    String? extra,
  }) =>
      guideDetailBlocks(
        meaning: _enrichMeaning(meaning, name, title),
        why: _enrichWhy(why, name, p, tab),
        how: _enrichHow(how, name, p, tab, title),
        tip: _enrichTip(tip, name, p),
        extra: _enrichExtra(extra ?? gap, name, p),
      );

  switch (tab) {
    case 'sowing':
      return _sowingDetails(t, name, p, vegetable, d);
    case 'transplant':
      return _transplantDetails(t, name, p, vegetable, d);
    case 'location':
      return _locationDetails(t, name, p, vegetable, d);
    case 'water':
      return _waterDetails(t, name, p, vegetable, d);
    case 'nutrition':
      return _nutritionDetails(t, name, p, vegetable, d);
    case 'growth':
      return _growthDetails(t, name, p, vegetable, d);
    case 'bloom':
      return _bloomDetails(t, name, p, vegetable, d);
    case 'harvest':
      return _harvestDetails(t, name, p, vegetable, d);
    case 'care':
      return _careDetails(t, name, p, vegetable, d);
    case 'combination':
      return _combinationDetails(t, name, p, vegetable, d);
    case 'problems':
      return _problemsDetails(t, name, p, vegetable, d);
    case 'weetjes':
      return _weetjesDetails(t, name, p, vegetable, d);
    default:
      return d(
        meaning: 'Informatie over “$title” voor $name.',
        why: 'Deze kop helpt je $name beter te verzorgen als moestuinbloem.',
        how: p.tip,
        tip: 'Combineer standplaats, water en bloeiverzorging.',
      );
  }
}

/// Detecteert tab via titelkeywords als die niet expliciet bekend is.
List<PlantGuideDetailBlock> flowerDetailForSection(String title, Vegetable v) {
  final t = title.trim().toLowerCase();
  final tab = _tabFromTitle(t);
  return flowerSectionDetailsFor(
    tab: tab,
    title: title,
    vegetable: v,
  );
}

String _tabFromTitle(String t) {
  if (t.contains('zaai') ||
      t.contains('kiem') ||
      t.contains('verspenen') ||
      t.contains('afhard')) {
    return 'sowing';
  }
  if (t.contains('uitplant') ||
      t.contains('plantafstand') ||
      t.contains('rijafstand') ||
      t.contains('plantdiepte') ||
      t.contains('aanslaan') ||
      t.contains('bescherming na') ||
      t.contains('bodemvoorbereiding')) {
    return 'transplant';
  }
  if (t.contains('standplaats') ||
      t.contains('halfschaduw') ||
      (t.contains('kas') && !t.contains('probleem')) ||
      (t.contains('zon') && !t.contains('bloei') && !t.contains('te weinig'))) {
    return 'location';
  }
  if (t.contains('water') || t.contains('droogte') || t.contains('natte')) {
    return 'water';
  }
  if (t.contains('voeding') ||
      t.contains('bodem') ||
      t.contains('compost') ||
      t.contains('mest') ||
      t.contains('ph')) {
    return 'nutrition';
  }
  if (t.contains('groei') ||
      t.contains('hoogte') ||
      t.contains('habitus') ||
      t.contains('levensduur')) {
    return 'growth';
  }
  if (t.contains('bloei') ||
      t.contains('geur') ||
      t.contains('herbloei') ||
      t.contains('bestuiv') ||
      t.contains('mannelijk') ||
      t.contains('vrouwelijk')) {
    return 'bloom';
  }
  if (t.contains('zaad') ||
      t.contains('oogst') ||
      t.contains('drogen') ||
      t.contains('bewaren') ||
      t.contains('zelfzaai')) {
    return 'harvest';
  }
  if (t.contains('verzorg') ||
      t.contains('snoei') ||
      t.contains('mulch') ||
      t.contains('opbind') ||
      t.contains('ondersteun') ||
      t.contains('winter') ||
      t.contains('uitgebloeid')) {
    return 'care';
  }
  if (t.contains('buur') ||
      t.contains('combin') ||
      t.contains('gezelschap') ||
      t.contains('wisselteelt') ||
      t.contains('stikstof') ||
      t.contains('groenbemest')) {
    return 'combination';
  }
  if (t.contains('plaag') ||
      t.contains('ziekte') ||
      t.contains('probleem') ||
      t.contains('symptoom') ||
      t.contains('insect') ||
      t.contains('schimmel')) {
    return 'problems';
  }
  if (t.contains('oorsprong') ||
      t.contains('histor') ||
      t.contains('symbol') ||
      t.contains('weetje') ||
      t.contains('bijzonder') ||
      t.contains('naam') ||
      t.contains('familie')) {
    return 'weetjes';
  }
  return 'care';
}

typedef _D = List<PlantGuideDetailBlock> Function({
  required String why,
  required String how,
  required String tip,
  String? meaning,
  String? extra,
});

String _join(List<String> items) =>
    items.isEmpty ? '—' : items.join(', ');

String _months(Set<int> months) {
  if (months.isEmpty) return 'Niet van toepassing / ter plaatse';
  const names = {
    1: 'jan',
    2: 'feb',
    3: 'mrt',
    4: 'apr',
    5: 'mei',
    6: 'jun',
    7: 'jul',
    8: 'aug',
    9: 'sep',
    10: 'okt',
    11: 'nov',
    12: 'dec',
  };
  final sorted = months.toList()..sort();
  return sorted.map((m) => names[m] ?? '$m').join(', ');
}

List<PlantGuideDetailBlock> _sowingDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('zaaidiepte') || t.contains('diepte')) {
    return d(
      meaning:
          'Zaaidiepte is hoe diep het zaad van $name in de grond of zaaigrond komt. '
          'Dat bepaalt of het genoeg licht, vocht en zuurstof krijgt om te kiemen.',
      why:
          'Te diep zaaien remt lichtkiemers en kost energie vóór het zaadje bovenkomt. '
          'Te ondiep zaaien laat donkerkiemers uitdrogen of wegspoelen bij regen. '
          'Voor $name is de juiste diepte daarom het verschil tussen snelle opkomst en mislukking.',
      how:
          'Zaai $name op ${p.sowDepth}. ${p.sowLight}. '
          'Vul een bak of zaaibed met luchtige zaaigrond, maak een geultje of druk het zaad licht aan, '
          'bedek precies volgens het type (licht- of donkerkiemer) en geef daarna voorzichtig water '
          'tot de bovenlaag vochtig is — niet sopnat.',
      tip:
          'Druk na het zaaien licht aan zodat het zaad contact maakt met vochtige grond. '
          'Houd daarna gelijkmatig vochtig tot opkomst (${p.kiemduur}) bij ongeveer ${p.kiemtemp}.',
    );
  }
  if (t.contains('licht') && t.contains('kiem')) {
    return d(
      meaning:
          'Dit vertelt of $name licht of juist donker nodig heeft om te kiemen. '
          'Lichtkiemers mogen niet (of nauwelijks) bedekt worden; donkerkiemers wel.',
      why:
          '${p.sowLight}: verkeerd bedekken is een klassieke mislukking. '
          'Zonder de juiste lichtconditie blijft het zaad liggen of schimmelt het weg.',
      how: p.sowLight.toLowerCase().contains('licht')
          ? 'Zaai $name oppervlakkig op vochtige zaaigrond. Bedek hooguit met een flinterdun laagje zand '
              'of helemaal niet. Zet de bak op een lichte, warme plek (${p.kiemtemp}) en houd de grond '
              'vochtig met een plantenspuit tot de zaailingen zichtbaar zijn (${p.kiemduur}).'
          : 'Bedek $name met grond tot ${p.sowDepth}. Druk licht aan, geef water van onderaf of voorzichtig '
              'van boven, en zet weg bij ${p.kiemtemp} tot opkomst (${p.kiemduur}).',
      tip:
          'Controleer dagelijks: de bovenlaag mag niet kurkdroog worden, maar ook niet plassen. '
          'Temperatuur rond ${p.kiemtemp} houdt de kieming stabiel.',
    );
  }
  if (t.contains('kiemduur')) {
    return d(
      meaning:
          'Kiemduur is de tijd die $name gemiddeld nodig heeft van zaaien tot de eerste zaailingen zichtbaar zijn.',
      why:
          'Met deze richtlijn weet je wanneer je moet wachten, bijsturen of opnieuw zaaien. '
          'In een koel NL-voorjaar duurt kieming vaak langer dan op de verpakking staat.',
      how:
          'Reken op ongeveer ${p.kiemduur} bij een stabiele temperatuur van ${p.kiemtemp}. '
          'Zaai in frisse zaaigrond, houd licht vochtig, en open de bak kort voor frisse lucht als er '
          'condens op het deksel staat. Zie je na die periode nog niets: check temperatuur en vocht, '
          'en zaai eventueel opnieuw in plaats van te vroeg te graven.',
      tip:
          'Koeler weer verlengt de kiemduur; een warmtematje of vensterbank op het zuiden helpt binnen. '
          'Buiten: zaai in ${_months(p.sowOutdoorMonths)} wanneer de grond is opgewarmd.',
    );
  }
  if (t.contains('kiemtemp') || t.contains('temperatuur')) {
    return d(
      meaning:
          'De kiemtemperatuur is de bodem- of luchttemperatuur waarbij $name het betrouwbaarst opkomt.',
      why:
          'Te koud betekent trage of geen opkomst. Te warm én nat geeft schimmel (omvalziekte). '
          'Voor het korte Nederlandse seizoen is een stabiele temperatuur cruciaal.',
      how:
          'Mik op ${p.kiemtemp}. Binnen kun je voorzaaien in ${_months(p.sowIndoorMonths)}: '
          'zet de bak op een warme, lichte plek of gebruik een kweekmat. Meet liever de temperatuur '
          'bij de potgrond dan alleen de kamerlucht. Zodra zaailingen opkomen, iets koeler zetten '
          'voorkomt slappe, lange planten.',
      tip:
          'Buiten zaaien in ${_months(p.sowOutdoorMonths)}. Wacht bij vorstgevoelige $name tot na '
          'de IJsheiligen (± half mei) of bescherm met vliesdoek.',
    );
  }
  if (t.contains('binnen')) {
    return d(
      meaning:
          'Voorzaaien betekent dat je $name eerst binnenshuis of in een kas opkweekt vóór je buiten uitplant.',
      why:
          'Dat geeft voorsprong in het korte NL-seizoen, vooral bij vorstgevoelige soorten. '
          'Je wint weken bloei en voorkomt dat late kou zaailingen doodt.',
      how:
          'Zaai binnen in ${_months(p.sowIndoorMonths)} op diepte ${p.sowDepth} (${p.sowLight}). '
          'Gebruik zaaigrond, houd ${p.kiemtemp} aan, en geef licht vocht tot opkomst (${p.kiemduur}). '
          'Verspeen na 2–4 echte blaadjes en hard 1–2 weken af vóór uitplanten in '
          '${_months(p.transplantMonths)}.',
      tip:
          'Zet zaailingen op de lichtste plek die je hebt. Draai de bak regelmatig zodat ze niet '
          'scheef naar het raam groeien.',
    );
  }
  if (t.contains('buiten')) {
    return d(
      meaning:
          'Direct buiten zaaien betekent dat het zaad van $name meteen in de volle grond of bak buiten komt.',
      why:
          'Sommige bloemen houden niet van verplanten. Buiten zaaien spaart werk en geeft vaak '
          'sterkere, natuurlijkere planten — mits de grond warm genoeg is.',
      how:
          'Zaai buiten in ${_months(p.sowOutdoorMonths)} op ${p.sowDepth}. Maak het bed los, '
          'verwijder onkruid, zaai dun, bedek volgens type (${p.sowLight}) en geef voorzichtig water. '
          'Dun later uit tot ongeveer ${p.plantSpacing} zodat planten lucht krijgen.',
      tip: p.tip.isNotEmpty
          ? p.tip
          : 'Markeer de rij: jonge $name is makkelijk te verwarren met onkruid in de eerste weken.',
    );
  }
  if (t.contains('verspenen') || t.contains('oppot')) {
    return d(
      meaning: 'Jonge $name meer ruimte geven.',
      why: 'Dichte zaailingen concurreren en worden slap.',
      how: 'Verspeen na 2–4 echte blaadjes; plantafstand later ${p.plantSpacing}.',
      tip: 'Hanteer voorzichtig; vermijd beschadigde wortelhals.',
    );
  }
  if (t.contains('water') && !t.contains('diepte')) {
    return d(
      meaning: 'Vocht tijdens kieming van $name.',
      why: 'Zaden mogen niet uitdrogen, maar stilstaand water geeft omvalziekte.',
      how: 'Houd zaaigrond licht vochtig tot opkomst (${p.kiemduur}). '
          'Benevel of geef van onderaf; nooit plassen laten staan.',
      tip: p.frostSensitive
          ? 'Bij voorzaai binnen: na IJsheiligen (~11–15 mei) pas buiten.'
          : 'Kiemtemperatuur: ${p.kiemtemp}.',
    );
  }
  if (t.contains('afhard')) {
    return d(
      meaning: 'Wennen van $name aan buitenlucht.',
      why: 'Plots buiten zetten geeft verbranding of groeistilstand.',
      how: '1–2 weken opbouwen: eerst paar uur halfschaduw, daarna langer en meer zon.',
      tip: p.frostSensitive
          ? 'Vorstgevoelig — wacht tot na IJsheiligen (~11–15 mei).'
          : 'Meestal minder kritiek; gewoon geleidelijk opbouwen.',
    );
  }
  if (t.contains('fout') || t.contains('mistake')) {
    return d(
      meaning: 'Veelgemaakte zaaifouten bij $name.',
      why: _join(p.mistakes),
      how: 'Volg diepte (${p.sowDepth}), licht (${p.sowLight}) en temperatuur (${p.kiemtemp}).',
      tip: p.tip,
    );
  }
  return d(
    meaning: 'Zaaiadvies voor $name.',
    why: 'Goede start bepaalt bloei later in het seizoen.',
    how:
        'Binnen ${_months(p.sowIndoorMonths)}; buiten ${_months(p.sowOutdoorMonths)}. '
        'Diepte ${p.sowDepth} (${p.sowLight}).',
    tip: 'Kiemduur ${p.kiemduur} bij ${p.kiemtemp}.',
  );
}

List<PlantGuideDetailBlock> _transplantDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('uitplantperiode') || (t.contains('periode') && t.contains('uitplant'))) {
    return d(
      meaning: 'Wanneer je $name naar buiten plant.',
      why: p.frostSensitive
          ? 'Vorstgevoelig — plant pas na IJsheiligen (~11–15 mei).'
          : 'Bij mild weer; bodemtemp > 10 °C voor goed wortelcontact.',
      how: 'Uitplantmaanden: ${_months(p.transplantMonths)}.',
      tip: p.tip,
    );
  }
  if (t.contains('uitplantvoorwaarden') || t.contains('voorwaarden')) {
    return d(
      meaning: 'Condities voor uitplanten van $name.',
      why: p.frostSensitive
          ? 'Geen nachtvorst; na IJsheiligen (~11–15 mei) is veilig.'
          : 'Mild weer, bodemtemp > 10 °C.',
      how: 'Plant met 4–6 echte blaadjes. Afstand: ${p.plantSpacing}.',
      tip: 'Afharden: 1–2 weken voor uitplant starten.',
    );
  }
  if (t.contains('bescherming')) {
    return d(
      meaning: 'Bescherming na uitplanten van $name.',
      why: p.frostSensitive
          ? 'Vorstgevoelig: vliesdoek bij koude nachten.'
          : 'Bescherm vooral tegen slakken en felle middagzon de eerste week.',
      how: "Wind, slakken en late nachtvorst zijn de grootste risico's.",
      tip: p.supportAdvice,
    );
  }
  if (t.contains('bodemvoorbereiding') || t.contains('bodem')) {
    return d(
      meaning: 'Grondvoorbereiding voor uitplant van $name.',
      why: '${p.soilType} — goede structuur bevordert wortelgroei.',
      how: '${p.compostAdvice} Maak grond los, verwijder onkruid en stenen.',
      tip: 'pH-richtlijn: ${p.phRange}.',
    );
  }
  if (t.contains('locatie') || t.contains('plek')) {
    return d(
      meaning: 'Beste plantplek voor $name.',
      why: '${p.sunNeed} (min ${p.sunHoursMin}, ideaal ${p.sunHoursIdeal}).',
      how: '${p.soilType} Pot: ${p.potAdvice}',
      tip: p.droughtResistant
          ? 'Goede drainage is cruciaal; liever te droog dan te nat.'
          : 'Houd gelijkmatig vochtig de eerste weken.',
    );
  }
  if (t.contains('plantafstand')) {
    return d(
      meaning: 'Ruimte tussen planten van $name.',
      why: 'Te dicht = schimmel en concurrentie; te wijd = onkruid.',
      how: 'Plantafstand: ${p.plantSpacing}.',
      tip: 'Rijafstand: ${p.rowSpacing}.',
    );
  }
  if (t.contains('rijafstand')) {
    return d(
      meaning: 'Ruimte tussen rijen $name.',
      why: 'Lucht en bereikbaarheid voor verzorging.',
      how: 'Rijafstand: ${p.rowSpacing}.',
      tip: 'Plantafstand in de rij: ${p.plantSpacing}.',
    );
  }
  if (t.contains('plantdiepte') || t.contains('diepte')) {
    return d(
      meaning: 'Hoe diep je $name uitplant.',
      why: 'Te diep geeft rotting; te hoog drogen wortels uit.',
      how: p.plantingDepth,
      tip: 'Geef na het planten goed aan en mulch licht indien passend.',
    );
  }
  if (t.contains('water')) {
    return d(
      meaning: 'Water direct na uitplanten van $name.',
      why: 'Wortels moeten contact maken met de grond zonder luchtbellen.',
      how: 'Geef ruim water bij de voet; daarna ${p.waterHow}',
      tip: 'Eerste week niet laten uitdrogen, ook bij droogtetolerante soorten.',
    );
  }
  if (t.contains('ondersteun') || t.contains('opbind')) {
    return d(
      meaning: 'Steun bij het uitplanten van $name.',
      why: p.supportAdvice,
      how: 'Zet steun meteen mee, zodat je wortels later niet beschadigt.',
      tip: 'Habitus: ${p.habit}.',
    );
  }
  if (t.contains('aanslaan') || t.contains('eerste groei')) {
    return d(
      meaning: 'Hoe snel $name aanslaat na uitplanten.',
      why: 'Groeisnelheid: ${p.growthSpeed}.',
      how: 'Houd 1–2 weken gelijkmatig vochtig; bescherm tegen felle middagzon indien nodig.',
      tip: p.frostSensitive
          ? 'Bescherm tegen late nachtvorst met vliesdoek.'
          : 'Meestal stevig genoeg bij normale voorjaarskou.',
    );
  }
  if (t.contains('afhard') || t.contains('vroeg') || t.contains('fout')) {
    return d(
      meaning: 'Risico’s bij uitplanten van $name.',
      why: _join(p.mistakes.take(3).toList()),
      how: 'Uitplanten in ${_months(p.transplantMonths)}; afstand ${p.plantSpacing}.',
      tip: p.tip,
    );
  }
  if (t.contains('zon') || t.contains('halfschaduw') || t.contains('pot') || t.contains('volle grond')) {
    return d(
      meaning: 'Waar je $name naartoe plant.',
      why: 'Standplaats: ${p.sunNeed} (${p.sunHoursIdeal} ideaal).',
      how: 'Kies ${p.soilType} Pot: ${p.potAdvice}',
      tip: 'Waterbehoefte na uitplant: ${p.waterNeed}.',
    );
  }
  return d(
    meaning: 'Uitplanten van $name.',
    why: 'Juiste timing en afstand voorkomen stress en schimmel.',
    how:
        'Maanden: ${_months(p.transplantMonths)}. Afstand ${p.plantSpacing}, '
        'diepte: ${p.plantingDepth}.',
    tip: p.supportAdvice,
  );
}

List<PlantGuideDetailBlock> _locationDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  // --- Ideale standplaats ---
  if (t.contains('ideale standplaats') || t == 'standplaats') {
    return d(
      meaning:
          'De ideale standplaats combineert licht, beschutting en bodem zodat $name rijkelijk bloeit.',
      why:
          'Te weinig licht geeft slappe stengels en weinig bloei. ${p.sunNeed} met ${p.sunHoursIdeal} zon is ideaal.',
      how:
          'Kies een plek met minstens ${p.sunHoursMin} directe zon. '
          'Bodem: ${p.soilType} Beschut tegen harde wind bij hoge rassen.',
      tip: p.winterHardy
          ? 'Winterhard bij goede drainage; natte klei is riskanter dan vorst.'
          : 'Plant na IJsheiligen (± 15 mei) om late nachtvorst te vermijden.',
    );
  }
  // --- Zonuren per dag ---
  if (t.contains('zonuren') || (t.contains('zon') && t.contains('dag'))) {
    return d(
      meaning:
          'Zonuren bepalen fotosynthese en bloemknopvorming bij $name.',
      why:
          'Onder het minimum (${p.sunHoursMin}) bloeit $name minder en groeit slapper. '
          'Ideaal ${p.sunHoursIdeal}.',
      how:
          'Observeer de plek om 10:00, 13:00 en 16:00. Tel uren directe zon. '
          'Halfschaduw-soorten verdragen minder, maar niet volle schaduw.',
      tip:
          'In NL schijnt de zon in de zomer 14–16 uur (bewolking inbegrepen). '
          'Zuidgevel en open tuin geven het meeste bruikbare licht.',
    );
  }
  // --- Geschikte locaties ---
  if (t.contains('geschikte locatie') || t.contains('locatie')) {
    return d(
      meaning:
          'Niet elke teeltplek past: volume, drainage en licht verschillen sterk.',
      why:
          'Potten drogen sneller maar zijn flexibel. Volle grond geeft de beste bloeiprestatie. '
          'Kas helpt bij vorstgevoelige soorten in het kille NL-voorjaar.',
      how:
          'Volle grond: plant op afstand ${p.plantSpacing}. Pot: ${p.potAdvice} '
          'Balkon: alleen als de bloem compact genoeg is (${p.habit}).',
      tip:
          'Verhoogde bakken combineren drainage met warmte — ideaal voor mediterrane bloemen in NL.',
    );
  }
  // --- Benodigde ruimte ---
  if (t.contains('benodigde ruimte') || t.contains('ruimte')) {
    return d(
      meaning:
          'Ruimte is hoogte, breedte én worteldiepte — niet alleen plantafstand.',
      why:
          'Te dicht planten: schimmeldruk, concurrentie en minder bloei. Habitus: ${p.habit}.',
      how:
          'Plantafstand ${p.plantSpacing}; rijafstand ${p.rowSpacing}. '
          'Hoge rassen kunnen buren beschaduwen.',
      tip: p.supportAdvice,
    );
  }
  // --- Plantafstand ---
  if (t.contains('plantafstand')) {
    return d(
      meaning: 'Afstand tussen bloemen in de rij.',
      why:
          'Voldoende lucht beperkt meeldauw en geeft elke plant licht en voeding. '
          'Te wijd staat onkruid eerder kans.',
      how:
          'Houd ${p.plantSpacing} hart-op-hart. In bakken mag het iets dichter '
          'bij compacte soorten, maar luchtcirculatie blijft belangrijk.',
      tip:
          'Plant in driehoeksverband voor een voller bed met dezelfde afstand.',
    );
  }
  // --- Rijafstand ---
  if (t.contains('rijafstand')) {
    return d(
      meaning: 'Ruimte tussen rijen voor pad, lucht en licht.',
      why:
          'Brede paden maken wieden, deadheading en plukken makkelijker.',
      how: 'Mik op ${p.rowSpacing} tussen rijen.',
      tip:
          'In een pluktuin: brede paden zodat je kunt knippen zonder bloemen te knakken.',
    );
  }
  // --- Windgevoeligheid ---
  if (t.contains('wind')) {
    return d(
      meaning: 'Windgevoeligheid van $name.',
      why:
          'Hoge of topzware bloemen knakken bij harde wind, vooral na regen '
          'wanneer stengels zwaar zijn. Habitus: ${p.habit}.',
      how: p.supportAdvice,
      tip:
          'Plant in groep of achter een haag. Potten: kies een zware pot of zet vast.',
    );
  }
  // --- Temperatuur ---
  if (t.contains('temperatuur') || t.contains('temp')) {
    return d(
      meaning: 'Temperatuurvereisten voor $name in NL-klimaat.',
      why: p.frostSensitive
          ? '$name is vorstgevoelig. Wacht op stabiel weer na IJsheiligen (± 15 mei). '
              'NL heeft regelmatig late nachtvorst tot begin mei.'
          : '$name verdraagt koel weer, maar natte kou remt wortels.',
      how:
          'Gebruik vliesdoek bij aangekondigde nachtvorst. '
          'Bij hitte: schaduwdoek en extra water.',
      tip:
          'Bodemthermometer helpt bij voorjaar-uitplant: mik op 10–12 °C bodemtemp.',
    );
  }
  // --- Vorstgevoeligheid ---
  if (t.contains('vorst') || t.contains('winterhard')) {
    return d(
      meaning:
          'Vorst beschadigt celvocht in blad en stengel; jonge planten zijn het kwetsbaarst.',
      why: p.frostSensitive
          ? '$name is vorstgevoelig. Te vroeg buiten zetten (vóór half mei) geeft uitval. '
              'In NL komt nachtvorst tot begin mei regelmatig voor.'
          : p.winterHardy
              ? '$name is winterhard bij goede drainage. Natte winterklei '
                  'is gevaarlijker dan droge vorst.'
              : '$name verdraagt koel weer maar is niet betrouwbaar winterhard.',
      how: p.winterAdvice,
      tip: p.frostSensitive
          ? 'Vliesdoek bij nachtvorst; liever een week later dan één nacht te vroeg.'
          : 'Goede drainage is belangrijker dan vorstbescherming bij winterharde bloemen.',
    );
  }
  // --- Luchtvochtigheid ---
  if (t.contains('luchtvochtigheid') || t.contains('vochtigheid')) {
    return d(
      meaning:
          'Luchtvochtigheid beïnvloedt verdamping, schimmelrisico en bladcomfort.',
      why: p.droughtResistant
          ? 'Droogtetolerante bloemen als $name doen het beter bij lagere luchtvochtigheid. '
              'Natte lucht + stilstaand = schimmelrisico.'
          : 'Te droog: slapte en spint. Te vochtig + stilstaand: meeldauw. '
              'Gemiddeld is het beste voor $name.',
      how:
          'Buiten: plant op afstand ${p.plantSpacing} voor lucht. '
          'In kas: ventileer overdag.',
      tip:
          'NL-klimaat is van nature relatief vochtig; zorg voor luchtcirculatie bij dicht geplante borders.',
    );
  }
  // --- Kas of Buiten ---
  if (t.contains('kas') && !t.contains('probleem')) {
    return d(
      meaning: 'Kas versus buiten voor $name.',
      why:
          'Kas geeft warmte en bescherming tegen late vorst. Buiten geeft beter licht '
          'en natuurlijke bestuiving door insecten.',
      how:
          'Buiten: de meeste moestuinbloemen doen het prima na IJsheiligen. '
          'Kas: nuttig voor vroege opkweek of kwetsbare soorten.',
      tip:
          'Vorstgevoelig: ${p.frostSensitive ? 'kas of koude bak voor voorsprong' : 'buiten lukt meestal goed'}.',
    );
  }
  // --- Binnen kweken ---
  if (t.contains('binnen')) {
    return d(
      meaning: 'Binnen kweken van $name.',
      why:
          'Binnen mist vaak de lichtintensiteit van buiten. De meeste bloemen '
          'gedijen alleen tijdelijk binnen als opkweek.',
      how:
          'Zuidenraam of kweeklamp 12–16 uur. Goede potgrond en drainage. '
          '${p.potAdvice}',
      tip:
          'Opkweek binnen → afharden (1–2 weken) → buiten is de beste aanpak '
          'voor vorstgevoelige eenjarigen.',
    );
  }
  // --- Lichtbehoefte (catch-all zon/licht) ---
  if (t.contains('zon') || t.contains('licht')) {
    return d(
      meaning: 'Lichtbehoefte van $name.',
      why: 'Te weinig licht = weinig bloei en slappe groei.',
      how: '${p.sunNeed}. Ideaal ${p.sunHoursIdeal}, minimum ${p.sunHoursMin}.',
      tip: v.sunRequirement.isNotEmpty ? v.sunRequirement : p.tip,
    );
  }
  // --- Droogtetolerantie ---
  if (t.contains('droog')) {
    return d(
      meaning: 'Droogtetolerantie van $name.',
      why: p.droughtResistant
          ? 'Relatief droogtetolerant zodra aangeslagen.'
          : 'Niet droogtetolerant; gelijkmatig vochtig houden.',
      how: p.waterHow,
      tip: p.mulchAdvice,
    );
  }
  // --- Pot ---
  if (t.contains('pot')) {
    return d(
      meaning: 'Potteelt van $name.',
      why: 'Potten drogen sneller en beperken wortelruimte.',
      how: p.potAdvice,
      tip: 'Waterbehoefte: ${p.waterNeed}.',
    );
  }
  // --- Bodem/grond ---
  if (t.contains('bodem') || t.contains('grond')) {
    return d(
      meaning: 'Grondsoort voor $name.',
      why: p.soilType,
      how: '${p.compostAdvice} pH: ${p.phRange}.',
      tip: p.fertiliserAdvice,
    );
  }
  return d(
    meaning: 'Standplaats voor $name.',
    why: '${p.sunNeed}; water ${p.waterNeed}.',
    how: '${p.soilType} ${p.winterAdvice}',
    tip: p.tip,
  );
}

List<PlantGuideDetailBlock> _waterDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('waterbehoefte') || t == 'waterbehoefte') {
    return d(
      meaning: 'Hoe dorstig $name is.',
      why:
          'Richtlijn: ${p.waterNeed}. ${p.droughtResistant ? "Droogtetolerant na aanslaan." : "Gelijkmatig vochtig houden."}',
      how: p.waterHow,
      tip: p.droughtResistant
          ? 'Eenmaal aangeslagen verdraagt $name drogere periodes. Laat bovenlaag opdrogen.'
          : 'Laat niet langdurig kurkdroog staan, vooral in pot.',
    );
  }
  if (t.contains('hoe vaak') || t == 'hoe vaak') {
    return d(
      meaning: 'Hoe vaak $name water nodig heeft.',
      why:
          'Behoefte ${p.waterNeed}. Frequentie hangt af van weer, bodem en seizoen.',
      how:
          '${p.waterHow} In droge periodes vaker; in regenachtig NL-weer minder.',
      tip:
          'Steek een vinger 3 cm in de grond: droog = gieten, vochtig = wachten.',
    );
  }
  if (t.contains('hoeveel')) {
    return d(
      meaning: 'Hoeveel water per gietbeurt voor $name.',
      why:
          'Liever diep en minder vaak dan oppervlakkig sproeien.',
      how:
          '${p.waterHow} Pot: giet tot het uit de drainage komt.',
      tip:
          'Mulch houdt vocht langer vast en vermindert gietfrequentie.',
    );
  }
  if (t.contains('beste moment') || t.contains('wanneer')) {
    return d(
      meaning: 'Beste moment van de dag om $name water te geven.',
      why:
          'Ochtend is ideaal: blad droogt snel op, minder schimmelrisico.',
      how:
          'Giet bij de voet, niet over blad/bloemen. Liever voor 10:00.',
      tip:
          'Nooit midden op de dag in volle zon: water op blad geeft verbranding.',
    );
  }
  if (t.contains('water geven') || t == 'water geven') {
    return d(
      meaning: 'Hoe je $name het beste water geeft.',
      why: 'Verkeerd water geven (nat blad, oppervlakkig sproeien) bevordert schimmel.',
      how: p.waterHow,
      tip: 'Liever ’s ochtends bij de voet. ${p.mulchAdvice}',
    );
  }
  if (t.contains('kieming') || t.contains('kiem')) {
    return d(
      meaning: 'Vocht tijdens kieming van $name.',
      why:
          'Zaden mogen niet uitdrogen, maar stilstaand water geeft omvalziekte. '
          'Kiemduur: ${p.kiemduur} bij ${p.kiemtemp}.',
      how: 'Houd zaaigrond licht vochtig tot opkomst. Benevel of geef van onderaf.',
      tip: 'Afdekken met doorzichtig folie houdt vocht vast (ventileer dagelijks).',
    );
  }
  if (t.contains('groei') && !t.contains('zaad')) {
    return d(
      meaning: 'Water in de groeifase van $name.',
      why: 'Jonge planten bouwen wortels en blad; droogte nu remt later bloei.',
      how: 'Geef regelmatig als de bovenlaag droog aanvoelt.',
      tip: 'Dieper wateren stimuleert diepe wortels.',
    );
  }
  if (t.contains('bloei') && !t.contains('zaad') && !t.contains('na de')) {
    return d(
      meaning: 'Water rond de bloei van $name.',
      why:
          'Droogtestress kort de bloeiperiode in of geeft knopval. '
          'Gelijkmatig vocht verlengt de bloei aanzienlijk.',
      how: 'Houd aan ${p.waterNeed}: ${p.waterHow}',
      tip: p.rebloomAdvice,
    );
  }
  if (t.contains('zaadvorming') || t.contains('na de bloei') || t.contains('na bloei')) {
    return d(
      meaning: 'Water na de bloei en tijdens zaadvorming van $name.',
      why:
          'Na de hoofdbloei kun je het water geleidelijk verminderen. '
          'Wil je zaad oogsten, houd dan licht vochtig tot de zaden rijp zijn.',
      how: 'Verminder de frequentie maar laat niet volledig uitdrogen als je zaad wilt.',
      tip: p.seedHarvestAdvice,
    );
  }
  if (t.contains('droogte')) {
    return d(
      meaning: 'Droogtegedrag van $name.',
      why: p.droughtResistant
          ? 'Relatief droogteresistent na aanslaan. Natte voeten zijn erger dan droogte.'
          : 'Niet droogtetolerant. Bij hittegolven extra water + mulch.',
      how: p.droughtResistant
          ? 'Diep maar minder vaak wateren; laat bovenlaag opdrogen.'
          : 'Extra water + mulch bij warm weer. Check pot dagelijks.',
      tip: p.mulchAdvice,
    );
  }
  if (t.contains('natte grond')) {
    return d(
      meaning: 'Gevoeligheid voor natte voeten bij $name.',
      why: 'Wortelrot en schimmel bij langdurig natte grond.',
      how: 'Verbeter drainage. Verhoogde bakken helpen.',
      tip: p.winterAdvice,
    );
  }
  if (t.contains('te weinig') || t.contains('tekenen van te weinig')) {
    return d(
      meaning: 'Signalen van te weinig water bij $name.',
      why: 'Slapte, knopval, broze bladranden en kortere bloei.',
      how: 'Geef diep water bij de voet en controleer de volgende dag.',
      tip: 'Verwar warmte-slapte niet met chronische droogte.',
    );
  }
  if (t.contains('te veel') || t.contains('tekenen van te veel') || t.contains('teveel')) {
    return d(
      meaning: 'Signalen van te veel water bij $name.',
      why: 'Gele bladeren, slappe stengels ondanks natte grond, muffe geur.',
      how: 'Stop met gieten. Laat opdrogen, verbeter drainage.',
      tip: 'Potten: check of gaten open zijn.',
    );
  }
  if (t.contains('nat')) {
    return d(
      meaning: 'Te veel water bij $name.',
      why: 'Wortelrot en schimmel zijn de grootste risico’s, vooral in klei.',
      how: 'Laat opdrogen, verbeter drainage, giet niet in de schotel.',
      tip: p.winterAdvice,
    );
  }
  if (t.contains('waterkwaliteit') || t.contains('kwaliteit')) {
    return d(
      meaning: 'Welk water het beste is voor $name.',
      why: 'Regenwater is zacht en ideaal. Hard kraanwater bevat kalk.',
      how: 'Gebruik bij voorkeur regenwater of lauw, afgestaan water.',
      tip: 'In kas: watertemperatuur dichter bij bodemtemperatuur houden.',
    );
  }
  if (t.contains('pot')) {
    return d(
      meaning: 'Water in pot voor $name.',
      why: 'Potten drogen sneller uit dan volle grond.',
      how: '${p.potAdvice} ${p.waterHow} Giet tot het uit de drainage komt.',
      tip: 'Bij hitte kunnen potten op een dag uitdrogen. Check dagelijks.',
    );
  }
  if (t.contains('kas') && !t.contains('probleem')) {
    return d(
      meaning: 'Water in kas of tunnel voor $name.',
      why: 'In de kas verdampt water sneller overdag maar blijft vochtig bij stilstaande lucht.',
      how: 'Water bij de voet; ventileer na het gieten. Ochtends gieten.',
      tip: 'Overmatige luchtvochtigheid bevordert meeldauw.',
    );
  }
  if (t.contains('fout') || t.contains('veelgemaakte')) {
    return d(
      meaning: 'Veelgemaakte waterfouten bij $name.',
      why: _join(p.mistakes),
      how: p.waterHow,
      tip: p.droughtResistant
          ? 'Droogtetolerante bloemen sterven eerder aan te veel water dan te weinig.'
          : 'Gelijkmatig vochtig is beter dan wisselend dras en droog.',
    );
  }
  return d(
    meaning: 'Wateradvies voor $name.',
    why: 'Behoefte: ${p.waterNeed}.',
    how: p.waterHow,
    tip: v.water.isNotEmpty ? v.water : p.tip,
  );
}

List<PlantGuideDetailBlock> _nutritionDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('voedingsbehoefte') || t == 'voedingsbehoefte') {
    return d(
      meaning: 'Voedingsbehoefte van $name.',
      why:
          '${p.fertiliserAdvice} Bloemen willen meestal minder stikstof dan groenten.',
      how: p.compostAdvice,
      tip: 'Te veel stikstof geeft weelderig blad ten koste van bloemen.',
    );
  }
  if (t.contains('bodemsoort') || t.contains('beste bodem')) {
    return d(
      meaning: 'Welke bodem $name prefereert.',
      why: p.soilType,
      how:
          'pH-richtlijn: ${p.phRange}. ${p.compostAdvice}',
      tip:
          'Mediterrane bloemen houden van arme, doorlatende grond. '
          'Snijbloemen willen rijkere humusgrond.',
    );
  }
  if (t.contains('ph')) {
    return d(
      meaning: 'Zuurgraad van de bodem voor $name.',
      why: 'Buiten ${p.phRange} neemt de plant voeding minder goed op.',
      how:
          'Meet met een pH-set. Pas geleidelijk aan met compost of kalk.',
      tip:
          'Plotse grote kalkgiften vermijden. Compost buffert pH langzaam.',
    );
  }
  if (t.contains('compost')) {
    return d(
      meaning: 'Compost bij $name.',
      why:
          'Compost verbetert structuur en vochtbuffer, maar sommige bloemen '
          '(lavendel, duizendblad) willen het arm.',
      how: p.compostAdvice,
      tip: 'Gebruik rijpe compost; verse mest kan wortels verbranden.',
    );
  }
  if (t.contains('meststof') || (t.contains('mest') && !t.contains('groenbemest'))) {
    return d(
      meaning: 'Bemesting voor $name.',
      why: p.fertiliserAdvice,
      how: p.compostAdvice,
      tip: v.soilAndFood.isNotEmpty ? v.soilAndFood : p.tip,
    );
  }
  if (t.contains('beste mest')) {
    return d(
      meaning: 'Welke mest het beste past bij $name.',
      why: p.fertiliserAdvice,
      how:
          '${p.compostAdvice} '
          'Organische mest is vrijwel altijd veiliger dan kunstmest bij bloemen.',
      tip: 'Wormenmest is mild en geschikt voor de meeste bloemen.',
    );
  }
  if (t.contains('belangrijkste') || t.contains('voedingsstoffen')) {
    return d(
      meaning: 'N-P-K voor $name.',
      why:
          'N (stikstof): blad en groei. P (fosfor): wortels en bloei. '
          'K (kalium): stevigheid, bloeirijkheid en winterhardheid.',
      how:
          'Voor bloemen: liever weinig N en meer P/K dan bij groenten. '
          'Te veel stikstof remt bloem- en knopvorming.',
      tip:
          'Beenmeel of bloedmeel levert P; comfrey-gier of kalimagnesia levert K.',
    );
  }
  if (t.contains('bemesten bij planten') || t.contains('bij planten')) {
    return d(
      meaning: 'Startbemesting bij het planten van $name.',
      why: 'Jonge wortels hebben milde startvoeding, geen zoutpiek.',
      how:
          'Meng compost door het plantgat. ${p.compostAdvice}',
      tip: 'Niet tegen de stengel; meng door de grond.',
    );
  }
  if (t.contains('tijdens groei')) {
    return d(
      meaning: 'Bijmesten in de groeifase van $name.',
      why: 'Actieve groei verbruikt voeding, maar minder dan bij groenten.',
      how:
          'Geef elke 3-4 weken een lichte gift organische mest of vloeibare voeding.',
      tip: p.fertiliserAdvice,
    );
  }
  if (t.contains('tijdens bloei')) {
    return d(
      meaning: 'Voeding rond de bloei van $name.',
      why:
          'Fosfor (P) ondersteunt knopvorming en bloei. '
          'Te veel stikstof remt bloem- en knopvorming juist.',
      how:
          'Kies een mest met meer fosfor (P) tijdens de bloeiperiode. '
          'Comfrey-gier is een goede organische bron.',
      tip: 'Stop met stikstofrijke mest zodra knoppen zichtbaar zijn.',
    );
  }
  if (t.contains('na de bloei') || t.contains('zaad') || t.contains('nazomer')) {
    return d(
      meaning: 'Bemesting na de bloei van $name.',
      why:
          'Na de hoofdbloei kun je licht kalium (K) bijgeven voor stevige '
          'stengels, zaadrijping en winterhardheid bij vaste planten.',
      how:
          'Geef kaliumrijke voeding (kalimagnesia, comfrey-gier). '
          'Verminder mest bij eenjarigen die klaar zijn.',
      tip:
          'Vaste planten: najaarsgift K helpt de winter door. '
          'Eenjarigen: stop mestgift als de bloei voorbij is.',
    );
  }
  if (t.contains('tekort')) {
    return d(
      meaning: 'Voedingstekorten bij $name.',
      why:
          'Vergeling, zwakke bloei of paarse bladranden kunnen wijzen op tekort.',
      how:
          'Check eerst vocht en pH (${p.phRange}), daarna licht bijmesten. '
          'Gele onderste bladeren = vaak N-tekort of ouderdom.',
      tip: p.fertiliserAdvice,
    );
  }
  if (t.contains('overbemesting') || t.contains('te veel')) {
    return d(
      meaning: 'Overbemesting bij $name.',
      why:
          'Weelderig blad, weinig bloemen, zoutschade en verbrande bladranden.',
      how:
          'Stop mest, spoel potgrond licht, geef alleen water tot herstel.',
      tip:
          'Bloemen willen vaak minder mest dan groenten. Liever te weinig dan te veel.',
    );
  }
  if (t.contains('schema') || t.contains('voedingsschema')) {
    return d(
      meaning: 'Eenvoudig voedingsschema voor $name.',
      why: 'Timing voorkomt pieken en tekorten.',
      how:
          '1) Bij planten: compost. 2) Groei: lichte N-gift. '
          '3) Bloei: fosfor (P). 4) Nazomer: kalium (K) voor stevigheid.',
      tip: p.fertiliserAdvice,
    );
  }
  if (t.contains('bodem') || t.contains('grond')) {
    return d(
      meaning: 'Welke grond $name wil.',
      why: p.soilType,
      how: 'pH-richtlijn: ${p.phRange}. ${p.compostAdvice}',
      tip: p.fertiliserAdvice,
    );
  }
  if (t.contains('voeding') || t.contains('behoefte')) {
    return d(
      meaning: 'Voedingsbehoefte van $name.',
      why: p.fertiliserAdvice,
      how: p.compostAdvice,
      tip: 'Te veel stikstof geeft blad ten koste van bloemen.',
    );
  }
  return d(
    meaning: 'Voeding & bodem voor $name.',
    why: p.soilType,
    how: '${p.compostAdvice} ${p.fertiliserAdvice}',
    tip: 'pH ${p.phRange}.',
  );
}

List<PlantGuideDetailBlock> _growthDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('groeiwijze') || t.contains('habitus') || t == 'habit') {
    return d(
      meaning: 'Groeivorm van $name.',
      why: '${p.habit} — bepaalt steun en afstand.',
      how: 'Groeisnelheid: ${p.growthSpeed}. Afstand: ${p.plantSpacing}.',
      tip: p.supportAdvice,
    );
  }
  if (t.contains('hoogte') || t.contains('breedte')) {
    return d(
      meaning: 'Afmetingen van $name.',
      why: 'Habitus: ${p.habit}.',
      how: 'Groeisnelheid: ${p.growthSpeed}. Afstand: ${p.plantSpacing}.',
      tip: p.supportAdvice,
    );
  }
  if (t.contains('snelheid')) {
    return d(
      meaning: 'Hoe snel $name groeit.',
      why: 'Groeisnelheid: ${p.growthSpeed}.',
      how: 'Geef passende standplaats (${p.sunNeed}) en water (${p.waterNeed}).',
      tip: p.tip,
    );
  }
  if (t.contains('levensduur') || t.contains('eenjarig') || t.contains('vast')) {
    return d(
      meaning: 'Levensduur van $name in NL.',
      why: p.winterHardy
          ? 'Kan als vaste plant terugkomen bij juiste stand.'
          : 'Vaak eenjarig of niet betrouwbaar winterhard.',
      how: p.winterAdvice,
      tip: p.note ?? p.tip,
    );
  }
  if (t.contains('ondersteun') || t.contains('opbind')) {
    return d(
      meaning: 'Steun tijdens groei van $name.',
      why: p.supportAdvice,
      how: 'Plaats steun vroeg; habitus ${p.habit}.',
      tip: 'Bij wind: dichter planten in groep of net gebruiken.',
    );
  }
  if (t.contains('snoei')) {
    return d(
      meaning: 'Snoeien voor betere groei van $name.',
      why: p.pruneAdvice,
      how: p.deadheadAdvice,
      tip: p.rebloomAdvice,
    );
  }
  if (t.contains('stimul') || t.contains('terugbloei') || t.contains('herbloei')) {
    return d(
      meaning: 'Groei en herbloei stimuleren bij $name.',
      why: p.rebloomAdvice,
      how: '${p.deadheadAdvice} ${p.fertiliserAdvice}',
      tip: 'Zorg voor ${p.sunNeed} en passend water (${p.waterNeed}).',
    );
  }
  if (t.contains('lente') || t.contains('zomer') || t.contains('herfst') || t.contains('winter')) {
    return d(
      meaning: 'Seizoensgroei van $name.',
      why: 'Bloei: ${p.bloomPeriod} (${p.bloomDuration}).',
      how: t.contains('winter') ? p.winterAdvice : '${p.mulchAdvice} ${p.pruneAdvice}',
      tip: p.tip,
    );
  }
  if (t.contains('jong') || t.contains('fase') || t.contains('volwassen')) {
    return d(
      meaning: 'Groeifase van $name.',
      why: 'Van kiem tot bloei vraagt andere zorg.',
      how:
          'Jonge plant: gelijkmatig vochtig. Groei: afstand ${p.plantSpacing}. '
          'Bloei: ${p.bloomPeriod}.',
      tip: p.growthSpeed,
    );
  }
  return d(
    meaning: 'Groei van $name.',
    why: '${p.habit}; snelheid ${p.growthSpeed}.',
    how: p.supportAdvice,
    tip: p.tip,
  );
}

List<PlantGuideDetailBlock> _bloomDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('periode') || t.contains('bloeiperiode')) {
    return d(
      meaning: 'Wanneer $name bloeit.',
      why: 'Bloeiperiode: ${p.bloomPeriod}.',
      how: 'Duur: ${p.bloomDuration}. Vorm: ${p.flowerForm}.',
      tip: p.rebloomAdvice,
    );
  }
  if (t.contains('duur') || t.contains('bloeiduur')) {
    return d(
      meaning: 'Hoe lang $name blijft bloeien.',
      why: 'Bloeiduur: ${p.bloomDuration}.',
      how: p.deadheadAdvice,
      tip: p.rebloomAdvice,
    );
  }
  if (t.contains('vorm') || t.contains('kleur')) {
    return d(
      meaning: 'Bloemvorm van $name.',
      why: 'Vorm: ${p.flowerForm}.',
      how: 'Geur: ${p.fragrance} (sterkte ${p.scentDots}/3).',
      tip: p.tip,
    );
  }
  if (t.contains('geur')) {
    return d(
      meaning: 'Geur van $name.',
      why: p.fragrance,
      how: 'Geursterkte: ${p.scentDots} van 3.',
      tip: 'Geur komt het best vrij op warme, droge dagen.',
    );
  }
  if (t.contains('uitgebloeid') || t.contains('deadhead') || t.contains('verwijder')) {
    return d(
      meaning: 'Uitgebloeide bloemen van $name.',
      why: 'Voorkomt zaadzetting ten koste van nieuwe knoppen (tenzij je zaad wilt).',
      how: p.deadheadAdvice,
      tip: p.rebloomAdvice,
    );
  }
  if (t.contains('herbloei') || t.contains('stimul')) {
    return d(
      meaning: 'Herbloei bij $name.',
      why: p.rebloomAdvice,
      how: '${p.deadheadAdvice} Licht: ${p.sunNeed}. Water: ${p.waterNeed}.',
      tip: p.fertiliserAdvice,
    );
  }
  if (t.contains('bestuiv') || t.contains('bij') || t.contains('zelfbestuiv')) {
    return d(
      meaning: 'Bestuivers en $name.',
      why: _join(p.benefits),
      how: 'Plant in groepjes; open bloemen (${p.flowerForm}) zijn het toegankelijkst.',
      tip: 'Goede buren: ${_join(p.goodNeighbors)}.',
    );
  }
  if (t.contains('mannelijk') || t.contains('vrouwelijk')) {
    return d(
      meaning: 'Geslachtsexpressie bij $name.',
      why: 'Belangrijk voor bestuiving en zaadzetting.',
      how: 'Vorm: ${p.flowerForm}. Bestuivingsmethode verschilt per type bloem.',
      tip: _join(p.benefits),
    );
  }
  return d(
    meaning: 'Bloei van $name.',
    why: '${p.bloomPeriod} · ${p.bloomDuration}.',
    how: '${p.flowerForm}. ${p.deadheadAdvice}',
    tip: p.fragrance,
  );
}

List<PlantGuideDetailBlock> _harvestDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('wanneer') || t.contains('rijp')) {
    return d(
      meaning: 'Wanneer je zaad of bloesem van $name oogst.',
      why: 'Te vroeg = kiemt niet; te laat = uitval of schimmel.',
      how: p.seedHarvestAdvice,
      tip: 'Oogst op een droge dag, bij voorkeur ’s ochtends na dauwdroging.',
    );
  }
  if (t.contains('verzamel') || t.contains('losmak') || t.contains('zeef')) {
    return d(
      meaning: 'Zaden van $name schoonmaken.',
      why: 'Schoon, droog zaad bewaart beter.',
      how: 'Laat peulen/hoofden nabrijpen, wrijf los, zeeft kaf eruit.',
      tip: p.seedHarvestAdvice,
    );
  }
  if (t.contains('droog')) {
    return d(
      meaning: 'Drogen van oogst van $name.',
      why: 'Restvocht veroorzaakt schimmel in opslag.',
      how: 'Spreid dun uit op papier op een luchtige, schaduwrijke plek.',
      tip: 'Snijbloemen: zet meteen op water; droogbloemen ondersteboven binden.',
    );
  }
  if (t.contains('bewaar') || t.contains('houdbaar')) {
    return d(
      meaning: 'Zaden van $name bewaren.',
      why: 'Koel, droog en donker houdt kiemkracht langer.',
      how: 'Luchtdichte doos/envelop met label (soort + jaar).',
      tip: 'Controleer na een week op vocht; nadragen indien nodig.',
    );
  }
  if (t.contains('zelfzaai')) {
    return d(
      meaning: 'Zelfzaai van $name.',
      why: 'Handig voor volgend seizoen, lastig als je een strak bed wilt.',
      how: 'Laat enkele hoofden staan of knip weg vóór zaadval.',
      tip: p.deadheadAdvice,
    );
  }
  if (t.contains('fout')) {
    return d(
      meaning: 'Fouten bij zaadoogst van $name.',
      why: _join(p.mistakes.take(4).toList()),
      how: p.seedHarvestAdvice,
      tip: p.tip,
    );
  }
  return d(
    meaning: 'Oogst & zaad van $name.',
    why: 'Voor pluk, thee of eigen zaad.',
    how: p.seedHarvestAdvice,
    tip: 'Bloei: ${p.bloomPeriod}.',
  );
}

List<PlantGuideDetailBlock> _careDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('dagelijk')) {
    return d(
      meaning: 'Dagelijkse check bij $name.',
      why: 'Vroeg plagen en droogte zien voorkomt uitval.',
      how: 'Kijk naar slapte, luizen en uitgebloeide bloemen.',
      tip: 'Waterbehoefte: ${p.waterNeed}.',
    );
  }
  if (t.contains('wekelijk')) {
    return d(
      meaning: 'Wekelijkse verzorging van $name.',
      why: 'Onderhoud houdt bloei en gezondheid op peil.',
      how: '${p.deadheadAdvice} ${p.mulchAdvice}',
      tip: p.pruneAdvice,
    );
  }
  if (t.contains('snoei')) {
    return d(
      meaning: 'Snoeien van $name.',
      why: p.pruneAdvice,
      how: p.deadheadAdvice,
      tip: p.winterAdvice,
    );
  }
  if (t.contains('uitgebloeid')) {
    return d(
      meaning: 'Deadheading bij $name.',
      why: 'Stimuleert vaak nieuwe knoppen en voorkomt rot.',
      how: p.deadheadAdvice,
      tip: p.rebloomAdvice,
    );
  }
  if (t.contains('opbind') || t.contains('ondersteun')) {
    return d(
      meaning: 'Steun voor $name.',
      why: p.supportAdvice,
      how: 'Gebruik stokken, ringen of burenplanten; zet steun vroeg.',
      tip: 'Habitus: ${p.habit}.',
    );
  }
  if (t.contains('mulch')) {
    return d(
      meaning: 'Mulchen bij $name.',
      why: 'Vocht vasthouden en onkruid remmen.',
      how: p.mulchAdvice,
      tip: p.droughtResistant
          ? 'Bij droge soorten: liever grind/open bodem dan natte mulch.'
          : 'Organische mulch werkt goed bij gemiddelde waterbehoefte.',
    );
  }
  if (t.contains('winter')) {
    return d(
      meaning: 'Winterzorg voor $name.',
      why: p.winterHardy ? 'Winterhard bij goede stand.' : 'Niet betrouwbaar winterhard.',
      how: p.winterAdvice,
      tip: p.frostSensitive ? 'Jonge planten extra beschermen.' : p.tip,
    );
  }
  if (t.contains('pot')) {
    return d(
      meaning: 'Potverzorging van $name.',
      why: p.potAdvice,
      how: '${p.waterHow} ${p.fertiliserAdvice}',
      tip: 'Verpot bij wortelgebondenheid in het voorjaar.',
    );
  }
  if (t.contains('droogte')) {
    return d(
      meaning: 'Verzorging van $name tijdens droogte.',
      why: p.droughtResistant ? 'Relatief tolerant.' : 'Gevoelig voor uitdrogen.',
      how: 'Diep wateren + ${p.mulchAdvice}',
      tip: p.waterHow,
    );
  }
  if (t.contains('regen') || t.contains('nat')) {
    return d(
      meaning: 'Verzorging van $name bij nat weer.',
      why: 'Schimmelrisico stijgt bij stilstaande lucht en nat blad.',
      how: 'Zorg voor lucht (${p.plantSpacing}), verwijder rotte bloemen.',
      tip: _join(p.diseases),
    );
  }
  if (t.contains('bloei')) {
    return d(
      meaning: 'Verzorging tijdens bloei van $name.',
      why: 'Bloei vraagt stabiel water en lichte voeding.',
      how: '${p.waterHow} ${p.deadheadAdvice}',
      tip: p.rebloomAdvice,
    );
  }
  if (t.contains('kalender') || t.contains('onderhoud')) {
    return d(
      meaning: 'Jaarrond onderhoud van $name.',
      why: 'Bloei ${p.bloomPeriod}; winter: ${p.winterAdvice}',
      how: 'Lente planten/snoei · zomer deadhead/water · herfst zaad/opruimen · winter beschermen.',
      tip: p.tip,
    );
  }
  if (t.contains('fout')) {
    return d(
      meaning: 'Veelgemaakte verzorgingsfouten bij $name.',
      why: _join(p.mistakes),
      how: p.pruneAdvice,
      tip: p.tip,
    );
  }
  return d(
    meaning: 'Verzorging van $name.',
    why: p.note ?? 'Regelmatig onderhoud verlengt bloei en gezondheid.',
    how: '${p.deadheadAdvice} ${p.mulchAdvice}',
    tip: p.tip,
  );
}

List<PlantGuideDetailBlock> _combinationDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('goede buur') || t.contains('goede buren')) {
    return d(
      meaning: 'Goede buren van $name.',
      why: 'Samenwerking in ruimte, geur en insecten.',
      how: _join(p.goodNeighbors),
      tip: _join(p.benefits),
    );
  }
  if (t.contains('slechte buur') || t.contains('slechte buren')) {
    return d(
      meaning: 'Minder goede buren van $name.',
      why: 'Concurrentie, schaduw of familieconflicten.',
      how: _join(p.badNeighbors),
      tip: 'Houd plantafstand ${p.plantSpacing}.',
    );
  }
  if (t.contains('gezelschap') || t.contains('companion')) {
    return d(
      meaning: 'Gezelschapsplanten bij $name.',
      why: _join(p.benefits),
      how: 'Combineer met: ${_join(p.goodNeighbors)}.',
      tip: p.tip,
    );
  }
  if (t.contains('plaag') || t.contains('bestrijd')) {
    return d(
      meaning: '$name en plaagbeheer.',
      why: _join(p.benefits),
      how: 'Plant in de rand of tussen rijen; combineer met ${_join(p.goodNeighbors)}.',
      tip: 'Plagen om op te letten: ${_join(p.pests)}.',
    );
  }
  if (t.contains('bestuiv') || t.contains('bij')) {
    return d(
      meaning: '$name als bestuiversplant.',
      why: 'Bloei ${p.bloomPeriod}; vorm ${p.flowerForm}.',
      how: 'Plant in clusters; laat een deel uitbloeien.',
      tip: _join(p.benefits),
    );
  }
  if (t.contains('bodem') || t.contains('stikstof') || t.contains('groenbemest')) {
    return d(
      meaning: 'Bodemwaarde van $name.',
      why: _join(p.benefits),
      how: p.key == FlowerProfileKey.greenManure
          ? 'Zaai dicht, laat bloeien voor bijen, werk onder vóór rijp zaad.'
          : p.compostAdvice,
      tip: p.fertiliserAdvice,
    );
  }
  if (t.contains('wissel') || t.contains('voorganger') || t.contains('opvolger')) {
    final how = switch (p.key) {
      FlowerProfileKey.mediterranean || FlowerProfileKey.treeBloom =>
        '$name blijft bij voorkeur op een vaste plek; vernieuw alleen bij slechte groei.',
      FlowerProfileKey.greenManure =>
        'Zaai $name na vroege oogst; werk onder vóór rijp zaad en volg met snijbloemen of bladgewas.',
      FlowerProfileKey.herbBloom =>
        'Meerjarige kruiden laten staan; eenjarige bloeiende kruiden licht wisselen van bed.',
      _ =>
        'Wissel eenjarige $name jaarlijks van plek; vermijd te vaak dezelfde familie op dezelfde grond.',
    };
    return d(
      meaning: 'Rotatie en opvolging rond $name.',
      why:
          'Voorkomt ziekteopbouw en houdt de bodem in balans — in NL vooral belangrijk na natte winters.',
      how: how,
      tip: 'Slechte buren: ${_join(p.badNeighbors)}.',
    );
  }
  if (t.contains('familie')) {
    return d(
      meaning: 'Combineren binnen families bij $name.',
      why: p.note ?? 'Houd rekening met familie bij wisselteelt.',
      how: 'Goede buren: ${_join(p.goodNeighbors)}.',
      tip: p.tip,
    );
  }
  if (t.contains('ruimte') || t.contains('besparing')) {
    return d(
      meaning: 'Slim ruimtegebruik rond $name.',
      why: 'Combineer hoog en laag, rijen en onderbeplanting — zo benut je elke vierkante meter.',
      how: 'Zet hoge bloemen achteraan, lage als randbeplanting; vul gaten met bodembedekkers.',
      tip: 'Onderbeplanting remt onkruid en houdt vocht vast.',
    );
  }
  if (t.contains('voordeel') || t.contains('voordelen')) {
    return d(
      meaning: 'Waarom combinaties met $name werken.',
      why: 'Goede buren geven meer bloei, minder plagen, gezondere bodem en meer bestuiving.',
      how: '${_join(p.benefits)}. Buren: ${_join(p.goodNeighbors)}.',
      tip: 'Diversiteit is de sleutel: meng soorten, hoogtes en bloeitijden.',
    );
  }
  if (t.contains('fout') || t.contains('fouten')) {
    return d(
      meaning: 'Veelgemaakte combinatiefouten bij $name.',
      why: _join(p.mistakes),
      how: 'Vermijd: ${_join(p.badNeighbors)}. Houd plantafstand ${p.plantSpacing}.',
      tip: 'Zelfde familie niet jaar na jaar op dezelfde plek.',
    );
  }
  return d(
    meaning: 'Combinaties met $name.',
    why: _join(p.benefits),
    how: 'Goed: ${_join(p.goodNeighbors)}. Minder: ${_join(p.badNeighbors)}.',
    tip: p.tip,
  );
}

List<PlantGuideDetailBlock> _problemsDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('symptoom') || t.contains('herken')) {
    return d(
      meaning: 'Signalen dat $name het moeilijk heeft.',
      why: 'Vroege herkenning voorkomt uitval.',
      how: 'Let op slapte, vlekken, luizen en knopval. Fouten: ${_join(p.mistakes)}.',
      tip: 'Check eerst water en zon (${p.sunNeed}, ${p.waterNeed}).',
    );
  }
  if (t.contains('insect') || t.contains('plaag') || t.contains('luis') || t.contains('slak')) {
    return d(
      meaning: 'Plagen bij $name.',
      why: _join(p.pests),
      how: 'Stimuleer nuttige insecten, verwijder zwaar aangetaste delen, houd luchtig.',
      tip: 'Voordelen van deze bloem: ${_join(p.benefits)}.',
    );
  }
  if (t.contains('schimmel') || t.contains('ziekte') || t.contains('meeldauw') || t.contains('roest')) {
    return d(
      meaning: 'Ziekten bij $name.',
      why: _join(p.diseases),
      how: 'Houd afstand ${p.plantSpacing}, water bij de voet, verwijder ziek blad.',
      tip: 'Vermijd nat blad in de avond.',
    );
  }
  if (t.contains('water')) {
    return d(
      meaning: 'Waterproblemen bij $name.',
      why: 'Behoefte ${p.waterNeed}; droogteresistent: ${p.droughtResistant ? 'ja' : 'nee'}.',
      how: p.waterHow,
      tip: 'Te nat: drainage. Te droog: diep water + mulch.',
    );
  }
  if (t.contains('weer') || t.contains('vorst') || t.contains('hitte') || t.contains('wind')) {
    return d(
      meaning: 'Weerschade bij $name.',
      why: p.frostSensitive
          ? 'Vorstgevoelig in jonge stadia.'
          : 'Relatief stevig tegen milde kou.',
      how: '${p.supportAdvice} ${p.winterAdvice}',
      tip: p.protectHint(),
    );
  }
  if (t.contains('groei')) {
    return d(
      meaning: 'Groeiproblemen bij $name.',
      why: _join(p.mistakes),
      how: 'Check zon (${p.sunNeed}), afstand (${p.plantSpacing}) en voeding.',
      tip: p.fertiliserAdvice,
    );
  }
  if (t.contains('pot')) {
    return d(
      meaning: 'Problemen in pot bij $name.',
      why: 'Uitdroging, te kleine pot of slechte drainage.',
      how: p.potAdvice,
      tip: p.waterHow,
    );
  }
  if (t.contains('voeding') || t.contains('tekort')) {
    return d(
      meaning: 'Voedingsproblemen bij $name.',
      why: p.fertiliserAdvice,
      how: 'Eerst water/pH (${p.phRange}) checken, daarna spaarzaam bijmesten.',
      tip: p.compostAdvice,
    );
  }
  if (t.contains('voorkomen') || t.contains('preventie')) {
    return d(
      meaning: 'Problemen voorkomen bij $name.',
      why: 'Goede standplaats (${p.sunNeed}), juist water (${p.waterNeed}) en luchtcirculatie zijn de basis.',
      how: 'Wissel van plek, houd afstand (${p.plantSpacing}), mulch en verwijder ziek materiaal.',
      tip: 'Controleer wekelijks op vroege signalen; vroeg handelen voorkomt uitval.',
    );
  }
  if (t.contains('eerste hulp') || t.contains('hulp')) {
    return d(
      meaning: 'Eerste hulp bij $name.',
      why: 'Slapte, vergeling of vlekken? Check eerst water en licht, dan plagen.',
      how: 'Geef water bij droogte, verplaats bij te veel zon/schaduw, verwijder ziek blad.',
      tip: p.frostSensitive
          ? 'Bij vorst: afdekken met vliesdoek; bij hitte: schaduw en extra water.'
          : 'Check drainage bij natte periodes; schimmel is vaak het eerste probleem.',
    );
  }
  if (t.contains('natuurlijk') || t.contains('bestrijding') || t.contains('biologisch')) {
    return d(
      meaning: 'Natuurlijke bestrijding bij $name.',
      why: 'Lieveheersbeestjes eten bladluis, gaasvliegen ruimen rupsen op, zweefvliegen helpen mee.',
      how: 'Plant bloemrijke randen, hang insectenhotels en vermijd breed-spectrum bestrijding.',
      tip: 'Goede buren: ${_join(p.goodNeighbors)} — biodiversiteit is de beste plaagwering.',
    );
  }
  return d(
    meaning: 'Problemen bij $name.',
    why: 'Veelvoorkomend: ${_join(p.mistakes.take(3).toList())}.',
    how: 'Plagen: ${_join(p.pests)}. Ziekten: ${_join(p.diseases)}.',
    tip: p.tip,
  );
}

List<PlantGuideDetailBlock> _weetjesDetails(
  String t,
  String name,
  FlowerGuideProfile p,
  Vegetable v,
  _D d,
) {
  if (t.contains('oorsprong')) {
    return d(
      meaning: 'Waar $name vandaan komt.',
      why: p.origin,
      how: p.history,
      tip: p.specialFact,
    );
  }
  if (t.contains('histor')) {
    return d(
      meaning: 'Geschiedenis van $name.',
      why: p.history,
      how: p.useThroughAges,
      tip: p.origin,
    );
  }
  if (t.contains('symbol')) {
    return d(
      meaning: 'Symboliek van $name.',
      why: p.symbolism,
      how: p.specialFact,
      tip: p.history,
    );
  }
  if (t.contains('bijzonder') || t.contains('wist je') || t.contains('weetje')) {
    return d(
      meaning: 'Bijzonder feit over $name.',
      why: p.specialFact,
      how: p.useThroughAges,
      tip: p.tip,
    );
  }
  if (t.contains('gebruik') || t.contains('toepassing') || t.contains('boeket') || t.contains('thee')) {
    return d(
      meaning: 'Gebruik van $name.',
      why: p.useThroughAges,
      how: _join(p.benefits),
      tip: p.seedHarvestAdvice,
    );
  }
  if (t.contains('waarde') || t.contains('moestuin')) {
    return d(
      meaning: 'Waarde van $name in de moestuin.',
      why: _join(p.benefits),
      how: 'Buren: ${_join(p.goodNeighbors)}.',
      tip: p.tip,
    );
  }
  if (t.contains('naam')) {
    return d(
      meaning: 'Naam en betekenis rond $name.',
      why: p.symbolism,
      how: p.origin,
      tip: p.specialFact,
    );
  }
  if (t.contains('familie')) {
    return d(
      meaning: 'Variatie binnen $name.',
      why: p.history,
      how: 'Bloemvorm: ${p.flowerForm}. Geur: ${p.fragrance}.',
      tip: p.specialFact,
    );
  }
  if (t.contains('tuin') && t.contains('gebruik')) {
    return d(
      meaning: '$name in de tuin.',
      why: 'Als border-, rand- of potplant voegt $name kleur en functie toe.',
      how: 'Plant op ${p.sunNeed.toLowerCase()} standplaats; afstand ${p.plantSpacing}.',
      tip: _join(p.benefits),
    );
  }
  if (t.contains('wereldwijd')) {
    return d(
      meaning: '$name wereldwijd.',
      why: p.origin,
      how: p.useThroughAges,
      tip: p.symbolism,
    );
  }
  if (t.contains('verrass')) {
    return d(
      meaning: 'Verrassende toepassingen van $name.',
      why: p.useThroughAges,
      how: _join(p.benefits),
      tip: p.specialFact,
    );
  }
  if (t.contains('populair') || t.contains('ras')) {
    return d(
      meaning: 'Populaire rassen van $name.',
      why: 'Elk ras verschilt in kleur, hoogte en bloeiduur.',
      how: 'Bloemvorm: ${p.flowerForm}. Bloei: ${p.bloomPeriod}.',
      tip: p.tip,
    );
  }
  if (t.contains('kleur')) {
    return d(
      meaning: 'Kleurvarianten van $name.',
      why: 'Afhankelijk van het ras bloeit $name in meerdere kleuren.',
      how: 'Bloemvorm: ${p.flowerForm}. Geur: ${p.fragrance}.',
      tip: p.specialFact,
    );
  }
  return d(
    meaning: 'Weetjes over $name.',
    why: p.specialFact,
    how: '${p.origin} ${p.history}',
    tip: '${p.symbolism} ${p.tip}',
  );
}

extension on FlowerGuideProfile {
  String protectHint() {
    if (frostSensitive) {
      return 'Vliesdoek bij aangekondigde nachtvorst.';
    }
    if (droughtResistant) {
      return 'Bij hitte vooral jong water geven; later spaarzamer.';
    }
    return tip;
  }
}

String _enrichMeaning(String? meaning, String name, String title) {
  final base = (meaning ?? '').trim();
  if (base.length >= 120) return base;
  final core = base.isEmpty
      ? '“$title” beschrijft een belangrijk onderdeel van de teelt van $name.'
      : base;
  return '$core '
      'In deze uitleg zie je wat de term betekent, waarom het telt in het Nederlandse klimaat, '
      'en hoe je het praktisch aanpakt.';
}

String _enrichWhy(
  String why,
  String name,
  FlowerGuideProfile p,
  String tab,
) {
  final base = why.trim();
  if (base.length >= 160) return base;
  final climate = p.frostSensitive
      ? 'In NL speelt late nachtvorst (rond de IJsheiligen) vaak een rol.'
      : 'In NL tellen vooral vochtig weer, wisselende temperaturen en korte zomers.';
  final stand =
      '$name wil ${p.sunNeed.toLowerCase()} en heeft een ${p.waterNeed.toLowerCase()} waterbehoefte.';
  if (base.isEmpty) {
    return '$stand $climate Goed advies voorkomt tegenvallers in bloei en gezondheid.';
  }
  return '$base $stand $climate';
}

String _enrichHow(
  String how,
  String name,
  FlowerGuideProfile p,
  String tab,
  String title,
) {
  final base = how.trim();
  if (base.length >= 180) return base;

  final steps = switch (tab) {
    'sowing' =>
      'Werk zo: 1) gebruik frisse zaaigrond, 2) zaai op ${p.sowDepth} (${p.sowLight}), '
          '3) houd licht vochtig bij ${p.kiemtemp}, 4) wacht op opkomst (${p.kiemduur}), '
          '5) verspeen of dun uit tot ongeveer ${p.plantSpacing}.',
    'transplant' =>
      'Werk zo: 1) hard 7–14 dagen af, 2) plant uit in ${_months(p.transplantMonths)} '
          '(na vorst als de soort gevoelig is), 3) houd ${p.plantSpacing} aan, '
          '4) plant op ${p.plantingDepth}, 5) geef meteen water bij de voet en bescherm de eerste dagen.',
    'water' =>
      'Werk zo: geef $name water volgens “${p.waterNeed}”: ${p.waterHow} '
          'Check met de vinger 2–3 cm diep; geef liever ’s ochtends bij de voet dan over het blad ’s avonds.',
    'nutrition' =>
      'Werk zo: start met ${p.compostAdvice} Kies mest volgens: ${p.fertiliserAdvice} '
          'Houd pH rond ${p.phRange} en vermijd te veel stikstof — dat geeft blad ten koste van bloei.',
    'location' =>
      'Werk zo: zet $name op ${p.sunNeed.toLowerCase()} (${p.sunHoursIdeal} ideaal). '
          'Bodem: ${p.soilType} Afstand: ${p.plantSpacing}.',
    'bloom' =>
      'Werk zo: zorg voor genoeg zon, geef water naar behoefte (${p.waterNeed}), '
          'en volg: ${p.deadheadAdvice.isNotEmpty ? p.deadheadAdvice : p.pruneAdvice}. '
          'Bloei verwacht je vooral ${p.bloomPeriod.toLowerCase()}.',
    'care' =>
      'Werk zo: controleer water (${p.waterNeed}), verwijder uitgebloeide delen '
          '(${p.deadheadAdvice.isNotEmpty ? p.deadheadAdvice : 'knip netjes weg'}) '
          'en snoei volgens: ${p.pruneAdvice.isNotEmpty ? p.pruneAdvice : 'na de bloei of in het voorjaar'}.',
    'harvest' =>
      'Werk zo: ${p.seedHarvestAdvice.isNotEmpty ? p.seedHarvestAdvice : 'oogst droge, rijpe zaden op een droge dag'}. '
          'Droog 5–14 dagen luchtig na, zeef kaf eruit en bewaar koel en droog met oogstjaar erbij.',
    'growth' =>
      'Werk zo: geef $name ruimte (${p.plantSpacing}), voldoende zon en ${p.waterNeed.toLowerCase()} water. '
          'Groeisnelheid: ${p.growthSpeed}. Habitus: ${p.habit}. '
          '${p.supportAdvice.isNotEmpty ? p.supportAdvice : 'Steun alleen bij wind of zware bloemen.'}',
    'problems' =>
      'Werk zo: 1) bekijk blad, knoppen en stengel, 2) check water en standplaats eerst, '
          '3) grijp gericht in (plagen/schimmel/weer). '
          '${p.mistakes.isNotEmpty ? 'Let vooral op: ${_join(p.mistakes.take(2).toList())}.' : ''}',
    'combination' =>
      'Werk zo: plant $name bij '
          '${p.goodNeighbors.isNotEmpty ? _join(p.goodNeighbors.take(3).toList()) : 'passende buren'} '
          '${p.badNeighbors.isNotEmpty ? 'en vermijd ${_join(p.badNeighbors.take(2).toList())}' : ''}. '
          'Houd ${p.plantSpacing} aan voor lucht en minder schimmel.',
    'weetjes' =>
      'Lees de herkomst en eigenschappen van $name en gebruik die kennis bij standplaats, '
          'combinaties en verzorging in jouw tuin.',
    _ =>
      'Werk zo stap voor stap en pas aan op het weer van de week. '
          'Basis voor $name: ${p.sunNeed}, water “${p.waterNeed}”, bloei ${p.bloomPeriod}.',
  };

  if (base.isEmpty) return steps;
  if (base.length < 80) {
    return '$base\n\n$steps';
  }
  return '$base\n\nExtra uitleg: $steps';
}

String _enrichTip(String tip, String name, FlowerGuideProfile p) {
  final base = tip.trim();
  final extras = <String>[
    if (p.frostSensitive)
      'Bescherm jonge $name bij aangekondigde nachtvorst met vliesdoek.',
    if (p.droughtResistant)
      'Bij hitte: liever één keer diep water dan elke dag een scheutje.',
    if (!p.droughtResistant)
      'Mulch helpt vocht vasthouden in droge NL-zomers.',
    'Noteer zaai- en uitplantdatum: dan weet je volgend jaar wat werkte.',
  ];
  final add = extras.take(2).join(' ');
  if (base.isEmpty) return add;
  if (base.length >= 140) return base;
  return '$base $add';
}

String _enrichExtra(String? extra, String name, FlowerGuideProfile p) {
  final base = (extra ?? '').trim();
  if (base.length >= 120) return base;
  final fallback = p.tip.isNotEmpty
      ? p.tip
      : 'Combineer goede standplaats, juist water en tijdige verzorging voor de mooiste bloei van $name.';
  if (base.isEmpty) return fallback;
  return '$base $fallback';
}
