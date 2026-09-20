import '../models/vegetable.dart';
import 'flower_guide_profiles.dart';

String _name(Vegetable v) => v.nameNl.split('(').first.trim();

String _monthsNl(Set<int> months) {
  const labels = {
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
  if (months.isEmpty) return '';
  final sorted = months.toList()..sort();
  if (sorted.length == 1) return labels[sorted.first]!;
  return '${labels[sorted.first]}–${labels[sorted.last]}';
}

String _firstBenefit(FlowerGuideProfile p) =>
    p.benefits.isNotEmpty ? p.benefits.first : 'nuttige insecten';

String _firstNeighbor(FlowerGuideProfile p) =>
    p.goodNeighbors.isNotEmpty ? p.goodNeighbors.first : 'moestuingroenten';

String _firstPest(FlowerGuideProfile p) =>
    p.pests.isNotEmpty ? p.pests.first : 'bladluis';

String _firstDisease(FlowerGuideProfile p) =>
    p.diseases.isNotEmpty ? p.diseases.first : 'schimmel';

String _firstMistake(FlowerGuideProfile p) =>
    p.mistakes.isNotEmpty ? p.mistakes.first : 'te nat of te diep zaaien';

/// Unieke, korte samenvatting onder een bloemen-kop (kaarttekst).
/// Gebruikt profiel + plantnaam zodat elke kop het belangrijkste moment vangt.
String flowerCardSummaryFor({
  required String tab,
  required String title,
  required Vegetable vegetable,
  FlowerGuideProfile? profile,
}) {
  final p = profile ?? flowerGuideProfileFor(vegetable.id);
  final name = _name(vegetable);
  final t = title.trim().toLowerCase();
  final tabKey = tab.trim().toLowerCase();

  switch (tabKey) {
    case 'sowing':
    case 'zaaien':
      return _sowing(t, name, p);
    case 'transplant':
    case 'uitplanten':
      return _transplant(t, name, p);
    case 'location':
    case 'standplaats':
      return _location(t, name, p);
    case 'water':
      return _water(t, name, p);
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
    case 'zaadoogst':
    case 'oogst':
      return _harvest(t, name, p);
    case 'care':
    case 'verzorging':
      return _care(t, name, p);
    case 'problems':
    case 'problemen':
      return _problems(t, name, p);
    case 'combination':
    case 'combinaties':
      return _combination(t, name, p);
    case 'weetjes':
      return _weetjes(t, name, p);
    default:
      return p.tip.isNotEmpty
          ? p.tip
          : 'Belangrijkste tip voor $name: ${p.note ?? 'volg zon, water en timing in NL.'}';
  }
}

String _sowing(String t, String name, FlowerGuideProfile p) {
  final indoor = _monthsNl(p.sowIndoorMonths);
  final outdoor = _monthsNl(p.sowOutdoorMonths);
  if (t.contains('binnen')) {
    return indoor.isEmpty
        ? '$name meestal niet voorzaaien — liever direct buiten.'
        : 'Voorzaai $name binnen in $indoor; na ijsheiligen uitplanten.';
  }
  if (t.contains('buiten')) {
    return outdoor.isEmpty
        ? '$name zaai je vooral binnen of plant je als plantgoed.'
        : 'Direct buiten zaaien in $outdoor, in zaaibed of moestuinrand.';
  }
  if (t.contains('zaaidiepte') || t == 'diepte') {
    return 'Zaai $name op ${p.sowDepth.isNotEmpty ? p.sowDepth : 'juiste diepte'} — te diep remt kieming.';
  }
  if (t.contains('kiemduur')) {
    return '$name kiemt in ${p.kiemduur.isNotEmpty ? p.kiemduur : '1–2 weken'}; wees geduldig bij koel weer.';
  }
  if (t.contains('kiemtemp') || t.contains('kiemtemperatuur')) {
    return 'Ideaal ${p.kiemtemp.isNotEmpty ? p.kiemtemp : '18–22 °C'}; te koud = trage of geen kieming.';
  }
  if (t.contains('licht')) {
    return p.sowLight.isNotEmpty
        ? '$name: ${p.sowLight}.'
        : '$name wil licht tijdens kieming; vermijd donkere, warme hoeken.';
  }
  if (t.contains('water')) {
    return 'Houd $name-zaad licht vochtig, nooit sopnat — schimmel is het grootste risico.';
  }
  if (t.contains('verspenen')) {
    return 'Verspeen $name na 2–4 echte blaadjes zodat zaailingen stevig verder groeien.';
  }
  if (t.contains('oppotten')) {
    return 'Verpot $name zodra wortels de pot vullen; te lang in kleine pot remt bloei.';
  }
  if (t.contains('afharden')) {
    return p.frostSensitive
        ? 'Hard $name 7–14 dagen af; zet pas vast na ijsheiligen buiten.'
        : 'Hard $name geleidelijk af zodat koude nachten geen klap geven.';
  }
  if (t.contains('fout')) {
    return 'Meest voorkomend bij $name: ${_firstMistake(p)}.';
  }
  return 'Zaai $name niet te diep en houd gelijkmatig vochtig tot kieming.';
}

String _transplant(String t, String name, FlowerGuideProfile p) {
  final period = _monthsNl(p.transplantMonths);
  if (t.contains('periode') || t.contains('uitplantperiode')) {
    return period.isEmpty
        ? 'Plant $name uit als de grond warm is en nachtvorst voorbij is.'
        : 'Uitplanten van $name: $period (na ijsheiligen bij vorstgevoelige soorten).';
  }
  if (t.contains('voorwaarde')) {
    return p.frostSensitive
        ? 'Grond ≥10 °C, geen nachtvorst — $name is vorstgevoelig.'
        : 'Losse grond, voldoende licht; $name verdraagt koel weer beter.';
  }
  if (t.contains('afharden')) {
    return 'Laat $name 1–2 weken wennen: eerst halfschaduw, daarna volle zon.';
  }
  if (t.contains('plantafstand') && !t.contains('rij')) {
    return 'Houd ${p.plantSpacing} tussen $name-planten voor lucht en bloei.';
  }
  if (t.contains('rijafstand')) {
    return p.rowSpacing.contains('N.v.t')
        ? 'Rijafstand is bij $name minder strikt — focus op plantafstand.'
        : 'Rijen op ${p.rowSpacing} zodat $name droogt na regen.';
  }
  if (t.contains('plantdiepte') || t.contains('diepte')) {
    return 'Plant $name op ${p.plantingDepth}; te diep kan stengelrot geven.';
  }
  if (t.contains('locatie') || t.contains('plek') || t.contains('beste')) {
    return '$name wil ${p.sunNeed.toLowerCase()} en ${p.waterNeed.toLowerCase()} water.';
  }
  if (t.contains('bodem')) {
    return p.soilType.isNotEmpty
        ? 'Voor $name: ${p.soilType}'
        : 'Losse, doorlatende grond met compost voor $name.';
  }
  if (t.contains('water')) {
    return 'Geef $name na uitplanten goed water; daarna volgens ${p.waterNeed.toLowerCase()} behoefte.';
  }
  if (t.contains('steun') || t.contains('ondersteun')) {
    return p.supportAdvice.isNotEmpty
        ? p.supportAdvice
        : 'Steun $name alleen bij hoge of slappe stelen.';
  }
  if (t.contains('bescherm')) {
    return p.frostSensitive
        ? 'Bescherm jonge $name met vliesdoek bij late kou.'
        : 'Bescherm $name tegen harde wind en slakken vlak na uitplant.';
  }
  if (t.contains('aanslaan') || t.contains('eerste groei')) {
    return '$name slaat in 1–2 weken aan bij gelijkmatig vocht en licht.';
  }
  if (t.contains('oogst') || t.contains('bloei')) {
    return 'Eerste bloei van $name rond ${p.bloomPeriod.isNotEmpty ? p.bloomPeriod.toLowerCase() : 'de zomer'}.';
  }
  if (t.contains('fout')) {
    return 'Vaak mis bij $name: ${_firstMistake(p)}.';
  }
  return 'Plant $name op ${p.sunNeed.toLowerCase()} met ${p.plantSpacing} ruimte.';
}

String _location(String t, String name, FlowerGuideProfile p) {
  if (t.contains('ideale') || t.contains('standplaats')) {
    return '$name: ${p.sunNeed.toLowerCase()} — sleutel tot volle bloei in NL.';
  }
  if (t.contains('zonuren')) {
    return 'Mik op ${p.sunHoursIdeal}; onder ${p.sunHoursMin} blijft $name mager.';
  }
  if (t.contains('locatie') || t.contains('geschikt')) {
    return '$name doet het best in volle grond of grote pot op ${p.sunNeed.toLowerCase()}.';
  }
  if (t.contains('ruimte') || t.contains('benodigde')) {
    return 'Geef $name ruimte (${p.plantSpacing}) zodat bladeren snel drogen na regen.';
  }
  if (t.contains('plantafstand')) {
    return '${p.plantSpacing} tussen $name voorkomt schimmel in vochtig NL-weer.';
  }
  if (t.contains('rijafstand')) {
    return p.rowSpacing;
  }
  if (t.contains('wind')) {
    return p.habit.toLowerCase().contains('hoog') ||
            p.supportAdvice.toLowerCase().contains('steun')
        ? 'Hoge $name beschermen of steunen bij westenwind.'
        : 'Lage $name verdraagt wind meestal goed.';
  }
  if (t.contains('temperatuur')) {
    return p.frostSensitive
        ? '$name houdt van warmte; nachtvorst remt of doodt jonge planten.'
        : '$name verdraagt koel NL-weer beter dan tropische bloemen.';
  }
  if (t.contains('vorst')) {
    return p.winterHardy
        ? '$name is winterhard; jonge groei kan wel vorstschade tonen.'
        : (p.frostSensitive
            ? '$name is niet winterhard — behandel als eenjarige of kuipplant.'
            : '$name verdraagt lichte kou, maar niet strenge vorst.');
  }
  if (t.contains('luchtvochtig')) {
    return 'Goede luchtcirculatie houdt $name gezond in vochtige NL-zomers.';
  }
  if (t.contains('kas')) {
    return p.frostSensitive
        ? 'Kas helpt $name vroeg starten; ventileer tegen schimmel.'
        : '$name kan buiten; kas alleen voor vroege voorsprong.';
  }
  if (t.contains('binnen')) {
    return 'Binnen alleen tijdelijk of als zaailing; $name wil buiten licht voor bloei.';
  }
  return '$name op ${p.sunNeed.toLowerCase()} met ${p.sunHoursIdeal} zon.';
}

String _water(String t, String name, FlowerGuideProfile p) {
  if (t.contains('behoefte')) {
    return '$name: ${p.waterNeed.toLowerCase()} waterbehoefte — check de bovenlaag vóór je giet.';
  }
  if (t.contains('water geven') || t == 'water geven') {
    return p.waterHow.isNotEmpty
        ? p.waterHow
        : 'Geef $name ’s ochtends bij de voet; nat blad ’s avonds = schimmelrisico.';
  }
  if (t.contains('kieming')) {
    return 'Tijdens kieming: $name licht vochtig houden (${p.kiemduur}).';
  }
  if (t.contains('groei') && !t.contains('probleem')) {
    return p.droughtResistant
        ? '$name verdraagt droge periodes; geef diep water als blad slap wordt.'
        : 'Tijdens groei van $name: gelijkmatig vochtig, vooral in warme weken.';
  }
  if (t.contains('bloei') && !t.contains('na')) {
    return 'In de bloei (${p.bloomPeriod}) houdt gelijkmatig vocht $name langer mooi.';
  }
  if (t.contains('na de bloei') || t.contains('zaad')) {
    return 'Na de bloei: water minderen; bij zaadoogst $name licht vochtig houden tot rijp.';
  }
  if (t.contains('droogte')) {
    return p.droughtResistant
        ? '$name is droogtetolerant — ideaal voor warme, droge NL-zomers.'
        : '$name is gevoelig voor droogte; mulch helpt in hittegolven.';
  }
  if (t.contains('natte') || t.contains('nat ')) {
    return 'Te natte grond remt $name en geeft wortelrot — zorg voor drainage.';
  }
  if (t.contains('te weinig')) {
    return 'Slap blad en knopval bij $name wijzen vaak op te weinig water.';
  }
  if (t.contains('te veel')) {
    return 'Gele bladpunten en slapte ondanks natte grond: te veel water bij $name.';
  }
  if (t.contains('kwaliteit')) {
    return 'Regenwater of lauw kraanwater is prima voor $name; vermijd koud stortbad.';
  }
  if (t.contains('pot')) {
    return p.potAdvice.isNotEmpty
        ? p.potAdvice
        : 'In pot droogt $name sneller — check dagelijks in de zomer.';
  }
  if (t.contains('kas')) {
    return 'In de kas: $name water geven én ventileren, anders botrytis.';
  }
  if (t.contains('tip')) {
    return p.tip.isNotEmpty ? p.tip : 'Mulch en ochtendgift houden $name stabiel vochtig.';
  }
  return '${p.waterNeed} water voor $name: ${p.waterHow}';
}

String _nutrition(String t, String name, FlowerGuideProfile p) {
  if (t.contains('voedingsbehoefte') || t == 'voedingsbehoefte') {
    return '$name is geen zware eter — ${p.fertiliserAdvice}';
  }
  if (t.contains('bodem') || t.contains('bodemsoort')) {
    return p.soilType.isNotEmpty
        ? 'Bodem voor $name: ${p.soilType}'
        : 'Losse, doorlatende grond geeft $name de beste start.';
  }
  if (t.contains('ph')) {
    return 'Houd pH rond ${p.phRange} zodat $name voeding kan opnemen.';
  }
  if (t.contains('compost')) {
    return p.compostAdvice.isNotEmpty
        ? p.compostAdvice
        : 'Rijpe compost in het voorjaar is genoeg voor $name.';
  }
  if (t.contains('beste mest') || t.contains('mest voor')) {
    return p.fertiliserAdvice;
  }
  if (t.contains('voedingsstoffen') || t.contains('belangrijkste')) {
    return 'Voor $name: matig stikstof, genoeg fosfor/kalium voor bloei.';
  }
  if (t.contains('bij planten') || t.contains('bij uitplant')) {
    return 'Bij planten van $name: lichte compostgift, geen verse mest tegen wortels.';
  }
  if (t.contains('tijdens groei')) {
    return 'Tijdens groei spaarzaam bijmesten — te veel blad remt bloei van $name.';
  }
  if (t.contains('tijdens bloei') || (t.contains('bloei') && t.contains('bemest'))) {
    return 'Rond bloei (${p.bloomPeriod}) mag $name iets meer fosfor/kalium.';
  }
  if (t.contains('na de bloei')) {
    return 'Na de bloei: licht kalium voor stevigheid; stop zware stikstof bij $name.';
  }
  if (t.contains('tekort')) {
    return 'Bleek blad of weinig bloemen bij $name: eerst water checken, dan licht bijmesten.';
  }
  if (t.contains('overbemesting') || t.contains('teveel')) {
    return 'Overbemesting geeft weelderig blad en weinig bloemen bij $name.';
  }
  if (t.contains('schema') || t.contains('tip')) {
    return 'Schema $name: compost bij start → licht bijmesten tot bloei → daarna minderen.';
  }
  return p.fertiliserAdvice;
}

String _growth(String t, String name, FlowerGuideProfile p) {
  if (t.contains('fase') || t.contains('groeifase')) {
    return '$name groeit ${p.growthSpeed.toLowerCase()} van zaailing naar bloei (${p.bloomPeriod}).';
  }
  if (t.contains('duur') || t.contains('tijd tot')) {
    return 'Van zaai tot bloei hangt af van ras; $name bloeit vooral ${p.bloomPeriod.toLowerCase()}.';
  }
  if (t.contains('hoogte') || t.contains('breedte') || t.contains('habit')) {
    return p.habit.isNotEmpty
        ? '$name: ${p.habit}.'
        : 'Geef $name ruimte (${p.plantSpacing}) om tot volle vorm te komen.';
  }
  if (t.contains('groeiwijze') || t.contains('snelheid')) {
    return '$name groeit ${p.growthSpeed.toLowerCase()}; ${p.habit}.';
  }
  if (t.contains('steun') || t.contains('opbinden')) {
    return p.supportAdvice.isNotEmpty
        ? p.supportAdvice
        : 'Steun $name tijdig bij wind of zware bloemen.';
  }
  if (t.contains('toppen')) {
    return 'Top jonge $name voor bossigere groei, tenzij je één hoge stengel wilt.';
  }
  if (t.contains('uitdunnen')) {
    return 'Dun $name uit tot ${p.plantSpacing} — te dicht = minder bloemen.';
  }
  if (t.contains('stimuleren')) {
    return 'Stimuleer $name met zon (${p.sunHoursIdeal}), water en deadheading.';
  }
  if (t.contains('probleem') || t.contains('stress')) {
    return 'Groeistress bij $name: vaak te weinig zon, te nat, of ${_firstMistake(p)}.';
  }
  if (t.contains('gezond')) {
    return 'Gezonde $name heeft stevige stengel, fris blad en gestage nieuwe knoppen.';
  }
  if (t.contains('tip') || t.contains('seizoen')) {
    return p.tip.isNotEmpty ? p.tip : 'In NL: plant $name op tijd en gun genoeg zon.';
  }
  return '$name: ${p.growthSpeed.toLowerCase()} groei, habitus ${p.habit.toLowerCase()}.';
}

String _bloom(String t, String name, FlowerGuideProfile p) {
  if (t.contains('bloeiperiode') || t == 'periode') {
    return '$name bloeit ${p.bloomPeriod.isNotEmpty ? p.bloomPeriod.toLowerCase() : 'in de zomer'} in het NL-klimaat.';
  }
  if (t.contains('bloeiduur') || t.contains('duur')) {
    return p.bloomDuration.isNotEmpty
        ? 'Bloeiduur $name: ${p.bloomDuration} — knippen verlengt vaak.'
        : 'Bloeiduur hangt af van weer; deadheading helpt $name langer door.';
  }
  if (t.contains('kleur')) {
    return 'Kleur van $name varieert per ras; kies wat past bij je border.';
  }
  if (t.contains('vorm')) {
    return p.flowerForm.isNotEmpty
        ? '$name heeft ${p.flowerForm.toLowerCase()}.'
        : 'Bloemvorm van $name trekt bestuivers aan.';
  }
  if (t.contains('geur') || t.contains('geurend')) {
    return p.fragrance.isNotEmpty
        ? '$name: ${p.fragrance.toLowerCase()}.'
        : 'Geur van $name trekt insecten — of blijft mild.';
  }
  if (t.contains('bestuiv') || t.contains('bijen') || t.contains('insect')) {
    return '$name trekt ${_firstBenefit(p).toLowerCase()} — waardevol in de moestuin.';
  }
  if (t.contains('stimuleren') || t.contains('meer bloemen')) {
    return p.rebloomAdvice.isNotEmpty
        ? p.rebloomAdvice
        : 'Meer bloemen bij $name: zon, deadheading en niet te veel stikstof.';
  }
  if (t.contains('verwijderen') || t.contains('deadhead') || t.contains('uitgebloeid')) {
    return p.deadheadAdvice.isNotEmpty
        ? p.deadheadAdvice
        : 'Verwijder uitgebloeide $name voor netheid en vaak meer knoppen.';
  }
  if (t.contains('zelfbestuiv') || t.contains('manlijk') || t.contains('vrouwel')) {
    return 'Bloemen van $name zijn meestal compleet; insecten helpen bij zaadvorming.';
  }
  if (t.contains('probleem') || t.contains('geen bloei')) {
    return 'Geen bloei bij $name? Check zon (${p.sunHoursIdeal}) en overbemesting.';
  }
  if (t.contains('eetbaar')) {
    return 'Check per soort of bloemen van $name eetbaar zijn; niet alle bloemen zijn dat.';
  }
  if (t.contains('eerste')) {
    return 'Eerste bloei van $name meestal aan het begin van ${p.bloomPeriod.toLowerCase()}.';
  }
  return '$name bloeit ${p.bloomPeriod.toLowerCase()} — ${_firstBenefit(p).toLowerCase()}.';
}

String _harvest(String t, String name, FlowerGuideProfile p) {
  if (t.contains('wanneer') || t.contains('oogsten')) {
    return p.seedHarvestAdvice.isNotEmpty
        ? p.seedHarvestAdvice
        : 'Oogst zaden van $name als zaaddozen droog en bruin zijn.';
  }
  if (t.contains('rijp') || t.contains('herkennen')) {
    return 'Rijp zaad van $name knispert licht en is droog — niet groen plukken.';
  }
  if (t.contains('verzamel') || t.contains('knip') || t.contains('pluk')) {
    return 'Knip of pluk rijpe $name-stengels op een droge dag.';
  }
  if (t.contains('drogen')) {
    return 'Droog $name-zaden 5–14 dagen luchtig binnen, uit de zon.';
  }
  if (t.contains('losmaken') || t.contains('zeven')) {
    return 'Wrijf $name-zaden los en zeef kaf eruit voor schone bewaring.';
  }
  if (t.contains('bewaar') || t.contains('houdbaar')) {
    return 'Bewaar $name-zaden koel en droog; noteer het oogstjaar (1–3 jaar houdbaar).';
  }
  if (t.contains('zelf') || t.contains('uitzaai')) {
    return 'Laat een deel $name uitzaaien, of zaai opnieuw volgens ${p.kiemduur}.';
  }
  if (t.contains('fout')) {
    return 'Vaak mis: te vroeg oogsten — wacht tot $name echt droog is.';
  }
  if (t.contains('tip')) {
    return p.tip.isNotEmpty ? p.tip : 'Oogst $name-zaden bij droog weer voor langere houdbaarheid.';
  }
  return p.seedHarvestAdvice.isNotEmpty
      ? p.seedHarvestAdvice
      : 'Oogst droge zaden van $name in nazomer/herfst.';
}

String _care(String t, String name, FlowerGuideProfile p) {
  if (t.contains('dagelijk')) {
    return 'Check $name dagelijks op water (${p.waterNeed.toLowerCase()}) en slap blad.';
  }
  if (t.contains('wekelijk')) {
    return 'Wekelijks: dode bloemen weg, blad checken, onkruid rond $name weg.';
  }
  if (t.contains('snoeien') || t.contains('snoei')) {
    return p.pruneAdvice.isNotEmpty
        ? p.pruneAdvice
        : 'Snoei $name na de bloei of in het voorjaar voor frisse groei.';
  }
  if (t.contains('uitgebloeid') || t.contains('deadhead')) {
    return p.deadheadAdvice.isNotEmpty
        ? p.deadheadAdvice
        : 'Deadheading houdt $name langer in bloei.';
  }
  if (t.contains('opbinden') || t.contains('ondersteun') || t.contains('steun')) {
    return p.supportAdvice.isNotEmpty
        ? p.supportAdvice
        : 'Steun $name bij wind of zware bloemen.';
  }
  if (t.contains('mulch')) {
    return p.mulchAdvice.isNotEmpty
        ? p.mulchAdvice
        : (p.droughtResistant
            ? 'Lichte mulch of grind bij $name; vermijd natte kraag.'
            : 'Mulch houdt vocht vast rond $name in droge weken.');
  }
  if (t.contains('onkruid')) {
    return 'Houd de voet van $name vrij van onkruid — concurrentie remt bloei.';
  }
  if (t.contains('winter') || t.contains('kou') || t.contains('vorst')) {
    return p.winterAdvice.isNotEmpty
        ? p.winterAdvice
        : (p.winterHardy
            ? '$name is winterhard; ruim alleen dode delen in het voorjaar.'
            : '$name overwintert niet buiten — opruimen na vorst of binnenhalen.');
  }
  if (t.contains('pot')) {
    return p.potAdvice.isNotEmpty
        ? p.potAdvice
        : 'In pot: $name vaker water geven en jaarlijks verversen.';
  }
  if (t.contains('hitte') || t.contains('regen') || t.contains('bescherm')) {
    return 'Bij hitte extra water; bij langdurige regen lucht houden rond $name.';
  }
  if (t.contains('tip')) {
    return p.tip.isNotEmpty ? p.tip : 'Regelmatig knippen en juist water = gezonde $name.';
  }
  if (t.contains('fout')) {
    return 'Veelgemaakte fout bij $name: ${_firstMistake(p)}.';
  }
  return 'Verzorg $name met ${p.waterNeed.toLowerCase()} water, zon en tijdige deadheading.';
}

String _problems(String t, String name, FlowerGuideProfile p) {
  if (t.contains('symptoom') || t.contains('herkennen')) {
    return 'Bij $name eerst blad, knoppen en stengel checken — vroeg ingrijpen loont.';
  }
  if (t.contains('insect') || t.contains('plaag')) {
    return 'Let op ${_firstPest(p)} bij $name; natuurlijke vijanden helpen mee.';
  }
  if (t.contains('schimmel') || t.contains('ziekte')) {
    return 'Risico bij $name: ${_firstDisease(p)} — droge bladeren en lucht zijn preventie.';
  }
  if (t.contains('voeding')) {
    return 'Voedingstekort bij $name lijkt vaak op waterstress; check beide.';
  }
  if (t.contains('water')) {
    return 'Waterproblemen bij $name: te droog = slap; te nat = geel en rot.';
  }
  if (t.contains('weer')) {
    return p.frostSensitive
        ? '$name is vorstgevoelig — let op IJsheiligen, natte winters en hitte.'
        : 'NL-weer: natte winters, hittegolven en storm kunnen $name stressen.';
  }
  if (t.contains('bestuiv')) {
    return 'Weinige insecten? Plant $name in groepjes en vermijd pesticiden.';
  }
  if (t.contains('groei')) {
    return 'Stilstaande groei bij $name: vaak te weinig zon of ${_firstMistake(p)}.';
  }
  if (t.contains('pot')) {
    return p.potAdvice.isNotEmpty
        ? p.potAdvice
        : 'In pot heeft $name sneller watertekort — drainage is essentieel.';
  }
  if (t.contains('voorkomen')) {
    return 'Voorkom problemen: ${p.sunNeed.toLowerCase()}, juist water (${p.waterNeed.toLowerCase()}) en lucht rond $name.';
  }
  if (t.contains('natuurlijk') || t.contains('bestrijd')) {
    return 'Bestrijd plagen bij $name liefst met lieveheersbeestjes en slimme buren — geen gif.';
  }
  if (t.contains('eerste hulp') || t.contains('hulp')) {
    return '$name hangt slap? Check meteen water, licht en de onderkant van het blad.';
  }
  if (t.contains('dier')) {
    return 'Slakken en konijnen kunnen jonge $name kaalvreten — bescherm tijdig.';
  }
  return 'Voorkom problemen bij $name: juiste standplaats, lucht en ${_firstMistake(p)} vermijden.';
}

String _combination(String t, String name, FlowerGuideProfile p) {
  if (t.contains('goede') && t.contains('buren')) {
    return '$name past goed bij ${_firstNeighbor(p)}.';
  }
  if (t.contains('slechte')) {
    return p.badNeighbors.isNotEmpty
        ? 'Vermijd naast $name: ${p.badNeighbors.first}.'
        : 'Geen harde tegenindicaties — let vooral op schaduw en concurrentie.';
  }
  if (t.contains('plantfamilie') || (t.contains('familie') && !t.contains('wisselteelt'))) {
    return 'Familieleden van $name delen plagen — wissel families op het bed.';
  }
  if (t.contains('wisselteelt')) {
    return p.key == FlowerProfileKey.greenManure
        ? 'Neem $name mee in je rotatie als groenbemester tussen oogsten.'
        : 'Eenjarige $name wissel je makkelijk; vaste planten krijgen een vaste plek.';
  }
  if (t.contains('voorganger')) {
    return 'Na groenbemester of licht gewas heeft $name de beste start.';
  }
  if (t.contains('opvolger')) {
    return 'Na $name volgt vaak een licht gewas of nieuwe groenbemester.';
  }
  if (t.contains('gezelschap')) {
    return 'Gezelschapsplanten rond $name: ${_firstNeighbor(p)} en ${_firstBenefit(p).toLowerCase()}.';
  }
  if (t.contains('tegen plagen') || (t.contains('plaag') && t.contains('plant'))) {
    return '$name helpt tegen plagen via ${_firstBenefit(p).toLowerCase()}.';
  }
  if (t.contains('bestuiver')) {
    return 'Plant bestuiversbloemen bij $name voor meer bijen en hommels.';
  }
  if (t.contains('bodemverbeter')) {
    return 'Bodemverbeteraars naast $name houden structuur en voeding op peil.';
  }
  if (t.contains('stikstof')) {
    return 'Stikstofbinders (klaver, lupine) geven gratis voeding naast $name.';
  }
  if (t.contains('groene bemest') || t.contains('groenbemest')) {
    return p.key == FlowerProfileKey.greenManure
        ? '$name zelf is een groene bemester — zaai op lege plekken.'
        : 'Zaai groene bemesters naast of na $name voor bedekte, levende bodem.';
  }
  if (t.contains('ruimte')) {
    return 'Combineer hoog/laag rond $name (${p.plantSpacing}) voor meer op één bed.';
  }
  if (t.contains('combinatievoordeel') || t.contains('voordelen')) {
    return 'Voordeel van $name: ${_firstBenefit(p).toLowerCase()}.';
  }
  if (t.contains('fout')) {
    return 'Vaak mis: $name te dicht planten of ${_firstMistake(p)}.';
  }
  return '$name combineert goed met ${_firstNeighbor(p)} voor ${_firstBenefit(p).toLowerCase()}.';
}

String _weetjes(String t, String name, FlowerGuideProfile p) {
  if (t.contains('oorsprong')) {
    return p.origin.isNotEmpty
        ? p.origin
        : '$name is een cultuurplant die goed past in het gematigde NL-klimaat.';
  }
  if (t.contains('historie') || t.contains('geschiedenis')) {
    return p.history.isNotEmpty
        ? p.history
        : 'Al eeuwen geteeld; in NL vooral als sier- en nutsbloem in de moestuin.';
  }
  if (t.contains('symboliek')) {
    return p.symbolism.isNotEmpty
        ? p.symbolism
        : '$name staat vaak voor vreugde, dankbaarheid of vriendschap.';
  }
  if (t.contains('naam') || t.contains('betekenis')) {
    return 'De naam “$name” verwijst vaak naar vorm, kleur of gebruik.';
  }
  if (t.contains('familie')) {
    return 'Familie bepaalt buren en plagen — plant $name bewust in je wisselteelt.';
  }
  if (t.contains('bijzonder')) {
    return p.specialFact.isNotEmpty
        ? p.specialFact
        : (p.note?.trim().isNotEmpty == true
            ? p.note!
            : '$name valt op door ${_firstBenefit(p).toLowerCase()}.');
  }
  if (t.contains('wist')) {
    return p.specialFact.isNotEmpty
        ? p.specialFact
        : 'Wist je dat $name ${_firstBenefit(p).toLowerCase()}?';
  }
  if (t.contains('eeuwen')) {
    return p.useThroughAges.isNotEmpty
        ? p.useThroughAges
        : '$name werd vroeger en nu gebruikt in tuinen, boeketten en soms de keuken.';
  }
  if (t.contains('boeket')) {
    return p.key == FlowerProfileKey.greenManure
        ? '$name is geen snijbloem — vooral bodem en bijen.'
        : '$name staat mooi op de vaas; oogst ’s ochtends voor langere houdbaarheid.';
  }
  if (t.contains('tuinen') && t.contains('gebruik')) {
    return '$name past in border, rand of pot — kies ${p.sunNeed.toLowerCase()}.';
  }
  if (t.contains('wereldwijd')) {
    return 'Wereldwijd wordt $name gewaardeerd als sier- en nutsbloem; in NL past het gematigde klimaat.';
  }
  if (t.contains('toepassingen') && !t.contains('verrass')) {
    return p.key == FlowerProfileKey.greenManure
        ? '$name: bodemverbeteraar en bijenplant in één.'
        : '$name: insecten, snijbloem en soms keuken — afhankelijk van soort.';
  }
  if (t.contains('waarde') || t.contains('moestuin')) {
    return p.benefits.isNotEmpty
        ? '${p.benefits.take(2).join('; ')}.'
        : 'In de moestuin helpt $name met ${_firstBenefit(p).toLowerCase()}.';
  }
  if (t.contains('verrassend')) {
    return '$name is meer dan decoratie: ${_firstBenefit(p).toLowerCase()}.';
  }
  if (t.contains('ras')) {
    return 'Kies een ras van $name dat past bij NL-weer: kleur, hoogte en bloeiduur verschillen.';
  }
  if (t.contains('kleur')) {
    return 'Kleurvarianten van $name verschillen per ras — kies wat past bij je border.';
  }
  if (t.contains('eetbaar') || t.contains('delen')) {
    return 'Niet alle bloemen zijn eetbaar — check specifiek of $name veilig is om te eten.';
  }
  return p.specialFact.isNotEmpty
      ? p.specialFact
      : (p.tip.isNotEmpty ? p.tip : '$name: ${_firstBenefit(p).toLowerCase()}.');
}
