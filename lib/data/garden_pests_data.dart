import '../models/garden_pest.dart';

const List<GardenPest> kGardenPests = [
  GardenPest(
    id: 'bladluis',
    nameNl: 'Bladluis',
    recognition:
        'Kleine groene, zwarte of witte insecten onder bladeren; kleverig honingdauw, krullende bladeren.',
    actionSteps: [
      'Spuit af met een harde waterstraal (ochtend).',
      'Verwijder zwaar aangetaste bladtoppen.',
      'Introduceer lieveheersbeestjes of gebruik biologische zeep/alcoholspuit (test eerst op 1 blad).',
      'Voorkom te veel stikstof, zachte groei trekt bladluis aan.',
      'Herhaal controle na 3–5 dagen.',
    ],
    keywords: ['bladluis', 'luis', 'aphid', 'honingdauw'],
    prevention: ['Mengtuin met bloemen voor nuttige insecten.', 'Niet te dicht planten.'],
    affectedPlants: ['tomaat', 'peper', 'bonen', 'kool', 'pruim', 'ros'],
  ),
  GardenPest(
    id: 'slak',
    nameNl: 'Slakken & naaktslakken',
    recognition:
        'Gaten in bladeren, slimsporen, planten ’s nachts sterk aangetast.',
    actionSteps: [
      'Verzamel slakken bij schemering of vroeg in de ochtend.',
      'Plaats slakkenkorven of bierfuiken (leegmaken en verversen).',
      'Maak een droge barrière (eggshell, schelpenzand rond plant).',
      'Geen bladresten direct naast kwetsbare jonge planten.',
      'Bij zware aantasting: biologisch feromoon of toegestaan middel volgens etiket.',
    ],
    keywords: ['slak', 'naaktslak', 'slijm'],
    prevention: ['Kiemtray hoog zetten.', 'Mulch pas als planten groter zijn.'],
    affectedPlants: ['sla', 'kool', 'tomaat', 'komkommer', 'zonnebloem'],
  ),
  GardenPest(
    id: 'koolrups',
    nameNl: 'Koolrups (witte vlinder)',
    recognition:
        'Grote groene rupsen op koolgewassen; kale bladeren, zwarte uitwerpselen (korrels).',
    actionSteps: [
      'Haal rupsen en eitjes handmatig weg (dagelijks controleren).',
      'Spint net over gewas (fijne mazen) direct na uitplanten.',
      'Biologisch Bacillus thuringiensis (Bt) volgens instructie op kolen.',
      'Verwijder zwaar aangetaste bladeren en gooi niet op de compost bij actieve aantasting.',
      'Oogst restanten op, geen kool in winter laten staan.',
    ],
    keywords: ['koolrups', 'rups', 'witte vlinder', 'koolwitje'],
    prevention: ['Wisselteelt met niet-koolgewassen.', 'Vanggewas of net vanaf maart.'],
    affectedPlants: ['kool', 'broccoli', 'spruit', 'bloemkool', 'boerenkool'],
  ),
  GardenPest(
    id: 'koolvlieg',
    nameNl: 'Koolvlieg',
    recognition:
        'Kleine witte vluchtjes; larven bij wortels → planten verkleuren, groeistilstand, kunnen omvallen.',
    actionSteps: [
      'Gebruik koolvliegnet met fijne mazen (tot 2–3 weken na uitplanten).',
      'Zet koolwortel-stootpalen of vanggewas volgens productinstructie.',
      'Verwijder aangetaste planten, niet herplanten kool op dezelfde plek.',
      'Grond losmaken en wisselteelt: minimaal 3 jaar geen kool op die plek.',
      'Compost alleen van gezonde restanten.',
    ],
    keywords: ['koolvlieg', 'wortel', 'vlieg'],
    prevention: ['Zaai later in het seizoen.', 'Vochtigheid bij wortel beperken.'],
    affectedPlants: ['kool', 'radijs', 'koolrabi', 'spruit'],
  ),
  GardenPest(
    id: 'wolluis',
    nameNl: 'Wolluis',
    recognition:
        'Witte watten- of wolachtige klontjes in bladoksels en stengels; verzwakte plant.',
    actionSteps: [
      'Verwijder met een vochtige tandenborstel of wattenstaafje met alcohol (1:1 water).',
      'Spuit biologische zeepoplossing op verborgen plekken.',
      'Isoleer zwaar aangetaste kamerplanten.',
      'Controleer nieuwe scheuten na 1 week opnieuw.',
      'Verminder stikstof en verbeter luchtcirculatie.',
    ],
    keywords: ['wolluis', 'wol', 'witte vlek', 'mealybug'],
    prevention: ['Niet te warm en te droog binnen.', 'Regelmatig blad inspecteren.'],
    affectedPlants: ['tomaat', 'citrus', 'peper', 'aubergine'],
  ),
  GardenPest(
    id: 'spint',
    nameNl: 'Spint',
    recognition:
        'Fijn web onder bladeren; stipjes op blad, vergeling, droog blad bij ernstige aantasting.',
    actionSteps: [
      'Verhoog luchtvochtigheid (besprenkelen, niet nat blad ’s avonds).',
      'Spuit af met water en verwijder ernstig beschadigd blad.',
      'Gebruik biologisch roofmijt Phytoseiulus (kas) of natuurlijk middel volgens etiket.',
      'Vermijd te droge, warme plek (kas, zuidmuur).',
      'Herhaal behandeling, spint heeft korte levenscyclus.',
    ],
    keywords: ['spint', 'spin', 'web', 'stip'],
    prevention: ['Gelijkmatig water geven.', 'Niet te veel stikstof.'],
    affectedPlants: ['tomaat', 'komkommer', 'bonen', 'aardbei'],
  ),
  GardenPest(
    id: 'trips',
    nameNl: 'Trips',
    recognition:
        'Zilverglanzende strepen op blad; kleine langwerpige insecten in bloemen en blad.',
    actionSteps: [
      'Verwijder ernstig aangetast blad en bloemen.',
      'Geel of blauw plakvang in kas of serre.',
      'Biologische roofmijt of nematoden volgens leverancier.',
      'Houd planten voldoende vochtig, droogte verergert schade.',
      'Oogst restanten op na seizoen.',
    ],
    keywords: ['trips', 'zilver', 'strepen'],
    prevention: ['Onkruid en restanten verwijderen.', 'Net over jonge planten.'],
    affectedPlants: ['ui', 'leek', 'tomaat', 'avocado'],
  ),
  GardenPest(
    id: 'meeldauw',
    nameNl: 'Meeldauw',
    recognition:
        'Wit poeder op bladeren; vaak bij droog weer en dichte planten.',
    actionSteps: [
      'Verwijder aangetaste bladeren (niet op compost).',
      'Verbeter luchtcirculatie: uitdunnen, niet nat blad ’s nachts.',
      'Spuit melk-water (1:9) of biologisch zwavel/kaliumbicarbonaat volgens etiket.',
      'Geef water aan de voet, niet over het blad.',
      'Kies resistente rassen bij terugkerend probleem.',
    ],
    keywords: ['meeldauw', 'wit poeder', 'powdery'],
    prevention: ['Niet te dicht planten.', 'Voldoende ruimte in kas.'],
    affectedPlants: ['courgette', 'komkommer', 'tomaat', 'peper', 'aardbei'],
  ),
  GardenPest(
    id: 'valse_meeldauw',
    nameNl: 'Valse meeldauw (downy mildew)',
    recognition:
        'Gele vlekken boven blad, grijs/paars schimmel onder blad; vooral bij vochtig koel weer.',
    actionSteps: [
      'Verwijder aangetast blad direct.',
      'Verbeter drainage en luchtcirculatie.',
      'Vermijd bovenblad nat maken in de avond.',
      'Biologisch koperpreparaat alleen als toegestaan en volgens etiket.',
      'Wisselteelt, geen gevoelig gewas op dezelfde plek.',
    ],
    keywords: ['valse meeldauw', 'downy', 'grijs onder blad'],
    prevention: ['Resistente rassen.', 'Niet te vroeg zaaien in nat voorjaar.'],
    affectedPlants: ['sla', 'ui', 'spinazie', 'druif'],
  ),
  GardenPest(
    id: 'uienvlieg',
    nameNl: 'Uienvlieg',
    recognition:
        'Larven in bol/stengel van ui, prei, look; plant vergelt en kan rotten.',
    actionSteps: [
      'Gebruik insectengaas of vlinderproof net over het gewas.',
      'Wisselteelt: ui-familie max. 1× per 3 jaar op dezelfde plek.',
      'Verwijder en vernietig aangetaste planten (niet compost).',
      'Zaai/ plant op tijd, vermijd piekvlieg in voorjaar waar mogelijk.',
      'Vanggewas of feromonval volgens product.',
    ],
    keywords: ['uienvlieg', 'ui', 'prei', 'look'],
    prevention: ['Mulch pas na warme start.', 'Goede drainage.'],
    affectedPlants: ['ui', 'prei', 'knoflook', 'bosui'],
  ),
  GardenPest(
    id: 'wortelvlieg',
    nameNl: 'Wortelvlieg',
    recognition:
        'Rode/bruine gangen in wortel; blad kan rood/paars worden; wortels onsmakelijk.',
    actionSteps: [
      'Oogst vroeg en verwijder aangetaste wortels.',
      'Gebruik wortelvliegnet (60–80 cm hoog) rond bed.',
      'Zaai wortel later (juni) voor latere vlieg.',
      'Wisselteelt: geen wortelgewas 3 jaar op dezelfde plek.',
      'Diep losmaken en geen verse mest direct voor zaai.',
    ],
    keywords: ['wortelvlieg', 'wortel', 'gangen'],
    prevention: ['Resistente rassen.', 'Net direct na zaai.'],
    affectedPlants: ['wortel', 'pastinaak', 'radijs', 'peterselie'],
  ),
  GardenPest(
    id: 'bonenluis',
    nameNl: 'Zwarte bonenluis',
    recognition:
        'Zwarte keverachtige luis op stengelpunt van bonen; planten kunnen omvallen of verzwakken.',
    actionSteps: [
      'Knip aangetaste toppen af zodra je luizen ziet (boven blad).',
      'Spuit met waterstraal of biologische zeep.',
      'Plant bonen later of gebruik vroege rassen vóór piek.',
      'Geen compost van zwaar aangetaste toppen in hetzelfde jaar.',
      'Wissel met niet-bonen gewassen volgend jaar.',
    ],
    keywords: ['bonenluis', 'bonen', 'zwarte luis'],
    prevention: ['Niet te vroeg zaaien in kou.', 'Goede steun voor stengels.'],
    affectedPlants: ['boon', 'tuinboon', 'snijboon'],
  ),
  GardenPest(
    id: 'kranszwam',
    nameNl: 'Kranszwam (bomen & struiken)',
    recognition:
        'Schimmelplaten aan stam, verzwakte takken, vruchten rotten; vaak bij pruim, appel, kers.',
    actionSteps: [
      'Zaag aangetaste takken terug tot gezond hout (desinfecteer zaag).',
      'Verwijder en verbrand schimmeldragers, niet compost.',
      'Houd stamvoet vrij van grondcontact en beschadiging.',
      'Snoei in droog weer; wondafsluiting op grote sneden.',
      'Overweeg resistent ras bij nieuwe aanplant.',
    ],
    keywords: ['kranszwam', 'schimmel', 'stam', 'pruim', 'boom'],
    prevention: ['Goede drainage.', 'Geen wondjes bij snoei.'],
    affectedPlants: ['pruim', 'appel', 'peer', 'kers'],
  ),
  GardenPest(
    id: 'schimmel',
    nameNl: 'Schimmel & rot (algemeen)',
    recognition:
        'Vlekken, slappe stengels, grijs/wit schimmel, snelle achteruitgang bij nat weer.',
    actionSteps: [
      'Verwijder aangetaste delen en verbeter drainage.',
      'Geef minder water; laat grond opdrogen tussen gietbeurten.',
      'Verhoog luchtcirculatie (uitdunnen, kas ventileren).',
      'Geen blad nat ’s avonds; water bij de voet.',
      'Biologisch middel alleen volgens etiket en wachttijd vóór oogst.',
    ],
    keywords: ['schimmel', 'rot', 'vlek', 'grijs', 'wit'],
    prevention: ['Schone gereedschappen.', 'Niet te dicht planten.'],
    affectedPlants: ['tomaat', 'aardbei', 'kool', 'paddenstoel'],
  ),
  GardenPest(
    id: 'vogels',
    nameNl: 'Vogels (zaden & fruit)',
    recognition:
        'Peulen/fruit beschadigd of weggepikt; zaden geoogst op jonge plant.',
    actionSteps: [
      'Net over bessen, pruimen of zaden (fijne mazen).',
      'Reflecterend lint of vogelverschrikker (wissel positie).',
      'Oogst rijp fruit snel; ochtend is vaak rustiger.',
      'Enkele planten als lokaas ver weg (optioneel).',
      'Geen giftige middelen, vogels zijn beschermd.',
    ],
    keywords: ['vogel', 'gepikt', 'zaden', 'pruim', 'aardbei'],
    prevention: ['Net voor rijping.', 'Schaduw voor zaden bij zonnebloem.'],
    affectedPlants: ['aardbei', 'pruim', 'kers', 'zonnebloem', 'boon'],
  ),
  GardenPest(
    id: 'nutrient',
    nameNl: 'Voedingstekort / verkeerde groei',
    recognition:
        'Gele bladeren, paarse randen, kleine bladgroei, doorschieten, niet altijd een plaag.',
    actionSteps: [
      'Controleer bemesting: stikstof (geel oud blad), kalium (bruine randen), magnesium.',
      'Geef compost of organische mest volgens gewastype.',
      'Meet pH indien mogelijk (kool houdt van iets kalkrijker).',
      'Pas watergift aan, te nat of te droog lijkt op “ziekte”.',
      'Herhaal scan na 2 weken om verbetering te zien.',
    ],
    keywords: ['geel', 'voeding', 'tekort', 'vergeeld', 'magnesium', 'stikstof'],
    prevention: ['Jaarlijks compost.', 'Wisselteelt.'],
    affectedPlants: ['alle'],
  ),
  GardenPest(
    id: 'droogte_stress',
    nameNl: 'Droogte- of hitte-stress',
    recognition:
        'Hangende bladeren overdag, bruine punten, bloemval, bittere/smalle vrucht.',
    actionSteps: [
      'Giet diep en minder vaak (ochtend).',
      'Mulch rond voet om vocht vast te houden.',
      'Schaduwdoek bij extreme hitte (>30 °C).',
      'Verwijder niet alles, laat blad beschutting geven.',
      'Pas verwachtingen aan bij hittegolf (minder oogst).',
    ],
    keywords: ['droog', 'hitte', 'hangen', 'bruin', 'stress', 'water'],
    prevention: ['Mulch.', 'Regenvat of druppelsysteem.'],
    affectedPlants: ['sla', 'tomaat', 'komkommer', 'basilicum'],
  ),
];

GardenPest? gardenPestById(String id) {
  for (final p in kGardenPests) {
    if (p.id == id) return p;
  }
  return null;
}
