import '../models/garden_recipe.dart';

/// Receptenboek gekoppeld aan groenten in Mijn moestuin.
const List<GardenRecipe> kGardenRecipes = [
  GardenRecipe(
    id: 'tuinsalade',
    title: 'Frisse tuinsalade',
    summary: 'Snelle salade met wat je vandaag oogst.',
    vegetableIds: ['sla', 'radijs', 'rucola'],
    servings: 4,
    prepMinutes: 15,
    cookMinutes: 0,
    ingredients: [
      '1 krop sla of mix sla (uit de tuin)',
      '1 bosje rucola (uit de tuin)',
      '8–12 radijzen (uit de tuin)',
      '2 el olijfolie',
      '1 el citroensap of azijn',
      'Zout en peper',
      'Optioneel: fetakaas of noten',
    ],
    steps: [
      'Was sla, rucola en radijs; laat goed drogen.',
      'Snijd radijs in dunne plakjes.',
      'Meng groenten in een grote kom.',
      'Klop olie, citroensap, zout en peper tot dressing.',
      'Besprenkel, meng voorzichtig en serveer direct.',
    ],
    tips: 'Oogst sla in de ochtend voor het knapperst.',
  ),
  GardenRecipe(
    id: 'wortelstoof',
    title: 'Hollandse wortelstoof',
    summary: 'Zachte wortelen met ui uit de tuin.',
    vegetableIds: ['wortel', 'bosui'],
    servings: 4,
    prepMinutes: 15,
    cookMinutes: 35,
    ingredients: [
      '600 g wortelen (uit de tuin)',
      '2 bosuitjes (uit de tuin)',
      '25 g boter',
      '1 tl suiker',
      '200 ml water of groentebouillon',
      'Zout, peper en peterselie',
    ],
    steps: [
      'Schil wortelen en snijd in schuine plakken.',
      'Snipper bosui; fruit in boter tot glazig.',
      'Voeg wortel en suiker toe; roer 2 minuten.',
      'Giet bouillon erbij; laat 25–30 min sudderen met deksel.',
      'Kruid en bestrooi met peterselie.',
    ],
  ),
  GardenRecipe(
    id: 'bietensoep',
    title: 'Romige bietensoep',
    summary: 'Dieprode soep van verse biet.',
    vegetableIds: ['rode_biet'],
    servings: 4,
    prepMinutes: 20,
    cookMinutes: 40,
    ingredients: [
      '4 middelgrote bieten (uit de tuin)',
      '1 ui (niet uit tuin)',
      '2 teentjes knoflook',
      '1 liter groentebouillon',
      '100 ml room of kokosmelk',
      'Olie, zout, peper',
      'Optioneel: zure room en dille',
    ],
    steps: [
      'Schil bieten en snijd in blokjes; snipper ui.',
      'Fruit ui in olie; voeg biet en knoflook toe.',
      'Giet bouillon erbij; kook 25 min tot zacht.',
      'Pureer glad; voeg room toe en breng op smaak.',
      'Serveer met lepel zure room en dille.',
    ],
    tips: 'Handschoenen dragen bij schillen. Biet kleurt alles mee.',
  ),
  GardenRecipe(
    id: 'sperziebonen',
    title: 'Sperziebonen met knoflook',
    summary: 'Simpel bijgerecht van jonge bonen.',
    vegetableIds: ['bonen_sperzie'],
    servings: 3,
    prepMinutes: 10,
    cookMinutes: 12,
    ingredients: [
      '400 g sperziebonen (uit de tuin)',
      '2 teentjes knoflook',
      '2 el olijfolie',
      'Zout en peper',
      'Optioneel: amandelschaafsel',
    ],
    steps: [
      'Top bonen af en kook 6–8 min in gezouten water.',
      'Giet af en spoel kort af met koud water.',
      'Fruit knoflook in olie (niet verbranden).',
      'Voeg bonen toe; bak 2 min en kruid.',
    ],
  ),
  GardenRecipe(
    id: 'snijbonen_roerbak',
    title: 'Snijbonen roerbak',
    summary: 'Knapperige bonen met sojasaus.',
    vegetableIds: ['snijbonen'],
    servings: 4,
    prepMinutes: 15,
    cookMinutes: 10,
    ingredients: [
      '400 g snijbonen (uit de tuin)',
      '1 wortel (optioneel, uit tuin)',
      '2 el sojasaus',
      '1 el sesamolie',
      '1 tl gember, vers',
      'Sesamzaad',
    ],
    steps: [
      'Snijd bonen schuin; wok op hoog vuur.',
      'Roerbak gember 30 seconden in sesamolie.',
      'Voeg bonen (en wortel) toe; bak 5–6 min knapperig.',
      'Voeg sojasaus toe; serveer met sesam.',
    ],
  ),
  GardenRecipe(
    id: 'tomatensalsa',
    title: 'Verse tomatensalsa',
    summary: 'Voor op brood, pasta of bij vlees.',
    vegetableIds: ['tomaat', 'snoeptomaat'],
    servings: 6,
    prepMinutes: 15,
    cookMinutes: 0,
    ingredients: [
      '500 g tomaten (mix uit tuin)',
      '1 bosui (uit de tuin)',
      '1 peper (optioneel, uit tuin)',
      '2 el olijfolie',
      '1 el limoensap',
      'Handvol basilicum (niet uit tuin)',
      'Zout',
    ],
    steps: [
      'Snijd tomaten in kleine blokjes; laat 10 min uitlekken.',
      'Snipper bosui en peper fijn.',
      'Meng alles met olie, limoensap en zout.',
      'Laat 30 min staan; roer basilicum erdoor.',
    ],
  ),
  GardenRecipe(
    id: 'gevulde_paprika',
    title: 'Gevulde paprika',
    summary: 'Bakken met rijst en tuinkruiden.',
    vegetableIds: ['rode_paprika'],
    servings: 4,
    prepMinutes: 25,
    cookMinutes: 45,
    ingredients: [
      '4 paprika\'s (uit de tuin)',
      '200 g rijst (niet uit tuin)',
      '300 g gehakt of linzen (niet uit tuin)',
      '1 ui, 1 blik tomaten',
      '100 g kaas geraspt',
      'Olie, zout, paprikapoeder',
    ],
    steps: [
      'Snijd kap van paprika\'s; verwijder zaden.',
      'Kook rijst halfgaar; meng met vulling en kruiden.',
      'Vul paprika\'s; zet in ovenschaal met tomatensaus.',
      'Bestrooi met kaas; bak 35–40 min op 180 °C.',
    ],
  ),
  GardenRecipe(
    id: 'aubergine_curry',
    title: 'Milde auberginecurry',
    summary: 'Cremige curry met tuinpeper en tomaat.',
    vegetableIds: ['aubergine', 'peper', 'tomaat'],
    servings: 4,
    prepMinutes: 20,
    cookMinutes: 35,
    ingredients: [
      '2 aubergines (uit de tuin)',
      '2 paprika\'s of pepers (uit de tuin)',
      '2 tomaten (uit de tuin)',
      '1 blik kokosmelk',
      '2 el currypasta of kruidenmix',
      'Rijst om te serveren',
    ],
    steps: [
      'Snijd aubergine in blokken; bestrooi met zout en laat 15 min zweeten.',
      'Bak aubergine goud in olie; zet apart.',
      'Fruit currypasta; voeg peper, tomaat en kokos toe.',
      'Laat 20 min sudderen; voeg aubergine terug en serveer met rijst.',
    ],
  ),
  GardenRecipe(
    id: 'spinaziepasta',
    title: 'Spinaziepasta met knoflook',
    summary: 'Snelle doordeweekse pasta.',
    vegetableIds: ['spinazie'],
    servings: 4,
    prepMinutes: 10,
    cookMinutes: 20,
    ingredients: [
      '300 g verse spinazie (uit de tuin)',
      '320 g pasta',
      '3 teentjes knoflook',
      '50 g parmezaan',
      'Olijfolie, zout, peper',
      'Optioneel: pijnboompitten',
    ],
    steps: [
      'Kook pasta volgens verpakking.',
      'Fruit knoflook in olie; voeg spinazie toe tot geslonken.',
      'Meng pasta door spinazie; voeg kaas en peper toe.',
      'Serveer met extra olie en pijnboompitten.',
    ],
  ),
  GardenRecipe(
    id: 'aardbei_crumble',
    title: 'Aardbeiencrumble',
    summary: 'Zoet dessert van zomerse aardbeien.',
    vegetableIds: ['aardbei'],
    servings: 6,
    prepMinutes: 20,
    cookMinutes: 35,
    ingredients: [
      '500 g aardbeien (uit de tuin)',
      '2 el suiker + 1 el maizena',
      '150 g bloem',
      '100 g boter',
      '80 g suiker (kruim)',
      'Vanille-ijs om te serveren',
    ],
    steps: [
      'Halveer aardbeien; meng met suiker en maizena in schaal.',
      'Wrijf bloem, boter en suiker tot kruim.',
      'Strooi kruim over fruit; bak 30–35 min op 180 °C.',
      'Laat 10 min rusten; serveer warm met ijs.',
    ],
  ),
  GardenRecipe(
    id: 'komkommersalade',
    title: 'Koele komkommersalade',
    summary: 'Licht bijgerecht met cucamelon.',
    vegetableIds: ['snackkomkommer', 'cucamelon'],
    servings: 4,
    prepMinutes: 15,
    cookMinutes: 0,
    ingredients: [
      '2 snackkomkommers (uit de tuin)',
      'Handvol cucamelons (uit de tuin)',
      '200 g yoghurt of zure room',
      '1 el dille',
      'Zout en witte peper',
    ],
    steps: [
      'Snijd komkommer in dunne plakjes; halveer cucamelons.',
      'Meng met yoghurt, dille, zout en peper.',
      'Laat 20 min koelen in de koelkast.',
    ],
  ),
  GardenRecipe(
    id: 'bosui_pancakes',
    title: 'Bosui-pannenkoekjes',
    summary: 'Hartige pannenkoeken als lunch.',
    vegetableIds: ['bosui'],
    servings: 4,
    prepMinutes: 15,
    cookMinutes: 20,
    ingredients: [
      '6 bosuitjes (uit de tuin)',
      '200 g bloem',
      '2 eieren',
      '250 ml melk',
      '1 tl bakpoeder',
      'Olie om te bakken',
      'Zout',
    ],
    steps: [
      'Snijd bosui in ringen.',
      'Klop beslag; roer bosui erdoor.',
      'Bak kleine pannenkoeken goud in olie.',
      'Serveer met zure room of dip.',
    ],
  ),
  GardenRecipe(
    id: 'ratatouille',
    title: 'Tuin-ratatouille',
    summary: 'Gestoofde mediterrane groenten uit je bed.',
    vegetableIds: ['aubergine', 'rode_paprika', 'peper', 'tomaat'],
    servings: 6,
    prepMinutes: 25,
    cookMinutes: 50,
    ingredients: [
      '1 aubergine (uit de tuin)',
      '2 paprika\'s (uit de tuin)',
      '2 pepers (uit de tuin)',
      '4 tomaten (uit de tuin)',
      '2 courgettes (niet uit tuin, optioneel)',
      '3 teentjes knoflook, tijm, olijfolie',
    ],
    steps: [
      'Snijd alle groenten in gelijke blokken.',
      'Bak aubergine apart tot goud; zet apart.',
      'Fruit ui en knoflook; voeg paprika en peper toe.',
      'Voeg tomaat toe; laat 30 min sudderen.',
      'Meng aubergine erdoor; kruid met tijm en olie.',
    ],
  ),
  GardenRecipe(
    id: 'radijs_boter',
    title: 'Radijs op boterbrood',
    summary: 'Klassiek Hollands als lunch of tussendoortje.',
    vegetableIds: ['radijs'],
    servings: 2,
    prepMinutes: 5,
    cookMinutes: 0,
    ingredients: [
      '1 bos radijs (uit de tuin)',
      '4 sneetjes volkorenbrood',
      'Boter en zeezout',
      'Optioneel: tuinkruiden',
    ],
    steps: [
      'Was radijs; snijd in dunne plakjes.',
      'Besmeer brood met boter.',
      'Leg radijs erop; bestrooi met zout.',
    ],
  ),
  GardenRecipe(
    id: 'rucola_pesto_pasta',
    title: 'Rucolapesto-pasta',
    summary: 'Pittige pesto van tuinrucola.',
    vegetableIds: ['rucola'],
    servings: 4,
    prepMinutes: 15,
    cookMinutes: 15,
    ingredients: [
      '50 g rucola (uit de tuin)',
      '30 g pijnboompitten',
      '50 g parmezaan',
      '1 teentje knoflook',
      '100 ml olijfolie',
      '320 g pasta',
    ],
    steps: [
      'Pureer rucola, pitten, kaas, knoflook en olie tot pesto.',
      'Kook pasta; bewaar een kop kookvocht.',
      'Meng pasta met pesto en een scheut kookvocht.',
    ],
  ),
  GardenRecipe(
    id: 'sla_wraps',
    title: 'Sla-wraps met tuinvulling',
    summary: 'Lichte wraps met wat je oogst.',
    vegetableIds: ['sla', 'tomaat', 'snackkomkommer'],
    servings: 4,
    prepMinutes: 20,
    cookMinutes: 0,
    ingredients: [
      '8 grote slabladeren (uit de tuin)',
      '2 tomaten (uit de tuin)',
      '1 snackkomkommer (uit de tuin)',
      '200 g kip of hummus (niet uit tuin)',
      'Saus naar keuze',
    ],
    steps: [
      'Was sla; droog voorzichtig.',
      'Snijd tomaat en komkommer in reepjes.',
      'Vul bladeren met eiwit en groenten; rol op.',
    ],
  ),
  GardenRecipe(
    id: 'snoeptomaat_snack',
    title: 'Warme snoeptomaatjes',
    summary: 'Simpele oven-snack van zoete tomaatjes.',
    vegetableIds: ['snoeptomaat'],
    servings: 2,
    prepMinutes: 5,
    cookMinutes: 20,
    ingredients: [
      '300 g snoeptomaatjes (uit de tuin)',
      '2 el olijfolie',
      '1 tl gedroogde oregano',
      'Zeezout',
    ],
    steps: [
      'Halveer grote tomaatjes; laat kleintjes heel.',
      'Meng met olie, oregano en zout op een bakplaat.',
      'Rooster 18–20 min op 200 °C tot ze licht karamelliseren.',
    ],
  ),
  GardenRecipe(
    id: 'peper_roerbak',
    title: 'Zoete peper roerbak',
    summary: 'Snel bijgerecht of op brood.',
    vegetableIds: ['peper'],
    servings: 3,
    prepMinutes: 10,
    cookMinutes: 12,
    ingredients: [
      '3 pepers (uit de tuin)',
      '1 el sojasaus',
      '1 el honing',
      'Sesamolie en sesamzaad',
    ],
    steps: [
      'Snijd pepers in reepjes.',
      'Roerbak op hoog vuur 5 min in sesamolie.',
      'Voeg sojasaus en honing toe; nog 2 min bakken.',
    ],
  ),
  GardenRecipe(
    id: 'spinazie_ei',
    title: 'Spinazie met ei',
    summary: 'Snelle lunch met verse spinazie.',
    vegetableIds: ['spinazie', 'bosui'],
    servings: 2,
    prepMinutes: 8,
    cookMinutes: 10,
    ingredients: [
      '200 g spinazie (uit de tuin)',
      '2 bosuitjes (uit de tuin)',
      '4 eieren',
      'Boter, zout, peper',
    ],
    steps: [
      'Snipper bosui; fruit kort in boter.',
      'Voeg spinazie toe tot geslonken.',
      'Klop eieren los, giet erover; roer tot gestold.',
    ],
  ),
];

int _recipeSortKey(GardenRecipe a, GardenRecipe b, Set<String> gardenIds) {
  final fullA = a.canMakeFully(gardenIds);
  final fullB = b.canMakeFully(gardenIds);
  if (fullA != fullB) return fullA ? -1 : 1;

  final frac = b.matchFraction(gardenIds).compareTo(a.matchFraction(gardenIds));
  if (frac != 0) return frac;

  final count = b.matchCount(gardenIds).compareTo(a.matchCount(gardenIds));
  if (count != 0) return count;

  return a.title.compareTo(b.title);
}

void _sortRecipes(List<GardenRecipe> list, Set<String> gardenIds) {
  list.sort((a, b) => _recipeSortKey(a, b, gardenIds));
}

/// Bouwt een persoonlijk receptenboek op basis van [gardenIds] (Mijn moestuin).
PersonalizedRecipeBook personalizedRecipeBook(Set<String> gardenIds) {
  if (gardenIds.isEmpty) {
    return const PersonalizedRecipeBook(
      gardenIds: {},
      readyNow: [],
      withYourVegetables: [],
    );
  }

  final matching = kGardenRecipes
      .where((r) => r.vegetableIds.any(gardenIds.contains))
      .toList();

  final readyNow = <GardenRecipe>[];
  final withYour = <GardenRecipe>[];

  for (final r in matching) {
    if (r.canMakeFully(gardenIds)) {
      readyNow.add(r);
    } else {
      withYour.add(r);
    }
  }

  _sortRecipes(readyNow, gardenIds);
  _sortRecipes(withYour, gardenIds);

  return PersonalizedRecipeBook(
    gardenIds: gardenIds,
    readyNow: readyNow,
    withYourVegetables: withYour,
  );
}
