import 'package:flutter/material.dart';

import '../models/vegetable.dart';
import '../utils/plant_display_info.dart';
import 'plant_encyclopedia_layout.dart';
import 'plant_search_filters.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';

/// Eén stap in de paddenstoel-kweektijdlijn.
class MushroomGrowthStage {
  const MushroomGrowthStage({
    required this.label,
    required this.duration,
    this.icon = Icons.circle_outlined,
  });

  final String label;
  final String duration;
  final IconData icon;
}

/// Alle gegevens voor het paddenstoel-overzicht-tabblad.
class MushroomOverviewLayout {
  const MushroomOverviewLayout({
    required this.vegetableId,
    required this.nameNl,
    this.nameLatin,
    this.badgeLabel = 'Eetbare paddenstoel',
    required this.difficulty,
    this.difficultySubtitle,
    this.difficultyColor,
    required this.location,
    this.locationSubtitle,
    required this.temperature,
    this.temperatureSubtitle,
    required this.humidity,
    this.humiditySubtitle,
    required this.timeToHarvest,
    required this.yield,
    required this.flushCount,
    required this.substrate,
    required this.light,
    required this.ventilation,
    this.ventilationSubtitle,
    required this.summary,
    required this.stages,
    required this.edibility,
    this.edibilitySubtitle,
    required this.edibilityStars,
    required this.beginnerSuitability,
    this.beginnerSubtitle,
    required this.beginnerRecommended,
    required this.goodToKnow,
    required this.growSeason,
    required this.growSeasonNote,
  });

  final String vegetableId;
  final String nameNl;
  final String? nameLatin;
  final String badgeLabel;
  final String difficulty;
  final String? difficultySubtitle;
  final Color? difficultyColor;
  final String location;
  final String? locationSubtitle;
  final String temperature;
  final String? temperatureSubtitle;
  final String humidity;
  final String? humiditySubtitle;
  final String timeToHarvest;
  final String yield;
  final String flushCount;
  final String substrate;
  final String light;
  final String ventilation;
  final String? ventilationSubtitle;
  final String summary;
  final List<MushroomGrowthStage> stages;
  final String edibility;
  final String? edibilitySubtitle;
  final int edibilityStars;
  final String beginnerSuitability;
  final String? beginnerSubtitle;
  final bool beginnerRecommended;
  final String goodToKnow;

  /// Maanden waarin je deze paddenstoel kunt starten/kweken.
  final PlantMonthTimeline growSeason;

  /// Korte samenvatting boven de kalender (bijv. jaarrond + omstandigheden).
  final String growSeasonNote;
}

bool isMushroomVegetable(Vegetable vegetable) =>
    kMushroomPlantIds.contains(vegetable.id);

const _allYearMonths = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12};
const _coolIndoorMonths = {1, 2, 3, 4, 5, 9, 10, 11, 12};
const _outdoorStartMonths = {3, 4, 5};

enum _MushroomGrowStyle { indoorYearRound, coolIndoor, outdoor }

_MushroomGrowStyle _growStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _MushroomGrowStyle.indoorYearRound;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _MushroomGrowStyle.coolIndoor;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _MushroomGrowStyle.outdoor;
    default:
      return _MushroomGrowStyle.indoorYearRound;
  }
}

Set<int> _growMonthsFor(Vegetable vegetable) {
  final activities = calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  );
  final months = <int>{};
  for (final a in activities) {
    if (a.type == GardenTaskType.preSow ||
        a.type == GardenTaskType.sowOutdoors ||
        a.type == GardenTaskType.plantOutdoors) {
      months.addAll(a.months);
    }
  }
  if (months.isNotEmpty) return months;

  switch (_growStyleFor(vegetable.id)) {
    case _MushroomGrowStyle.coolIndoor:
      return {..._coolIndoorMonths};
    case _MushroomGrowStyle.outdoor:
      return {..._outdoorStartMonths};
    case _MushroomGrowStyle.indoorYearRound:
      return {..._allYearMonths};
  }
}

String _growSeasonNoteFor({
  required Vegetable vegetable,
  required Set<int> months,
  required String temperature,
  required String humidity,
}) {
  final name = vegetable.nameNl.split('(').first.trim();
  final yearRound = months.length == 12;
  final style = _growStyleFor(vegetable.id);

  if (yearRound) {
    return 'Het hele jaar door te kweken bij de juiste omstandigheden: '
        'temperatuur rond $temperature en luchtvochtigheid $humidity.';
  }
  if (style == _MushroomGrowStyle.outdoor) {
    return 'Start $name bij voorkeur in ${formatPlantMonthRange(months)} '
        'in een vochtig, schaduwrijk buitenbed.';
  }
  return 'Beste kweekperiode voor $name: ${formatPlantMonthRange(months)}. '
      'Houd $temperature en $humidity aan.';
}

({PlantMonthTimeline timeline, String note}) _growSeasonFor(
  Vegetable vegetable, {
  required String temperature,
  required String humidity,
}) {
  final months = _growMonthsFor(vegetable);
  return (
    timeline: PlantMonthTimeline(label: 'Wanneer kweken', months: months),
    note: _growSeasonNoteFor(
      vegetable: vegetable,
      months: months,
      temperature: temperature,
      humidity: humidity,
    ),
  );
}

MushroomOverviewLayout buildMushroomOverviewLayout(Vegetable vegetable) {
  final facts = _mushroomFacts[vegetable.id];
  if (facts != null) {
    final season = _growSeasonFor(
      vegetable,
      temperature: facts.temperature,
      humidity: facts.humidity,
    );
    return MushroomOverviewLayout(
      vegetableId: vegetable.id,
      nameNl: vegetable.nameNl,
      nameLatin: latinNameForVegetable(vegetable),
      badgeLabel: facts.badgeLabel,
      difficulty: facts.difficulty,
      difficultySubtitle: facts.difficultySubtitle,
      difficultyColor: facts.difficultyColor,
      location: facts.location,
      locationSubtitle: facts.locationSubtitle,
      temperature: facts.temperature,
      temperatureSubtitle: facts.temperatureSubtitle,
      humidity: facts.humidity,
      humiditySubtitle: facts.humiditySubtitle,
      timeToHarvest: facts.timeToHarvest,
      yield: facts.yield,
      flushCount: facts.flushCount,
      substrate: facts.substrate,
      light: facts.light,
      ventilation: facts.ventilation,
      ventilationSubtitle: facts.ventilationSubtitle,
      summary: facts.summary,
      stages: facts.stages,
      edibility: facts.edibility,
      edibilitySubtitle: facts.edibilitySubtitle,
      edibilityStars: facts.edibilityStars,
      beginnerSuitability: facts.beginnerSuitability,
      beginnerSubtitle: facts.beginnerSubtitle,
      beginnerRecommended: facts.beginnerRecommended,
      goodToKnow: facts.goodToKnow,
      growSeason: season.timeline,
      growSeasonNote: season.note,
    );
  }

  const temp = '15–22 °C';
  const humidity = '85–95 %';
  final season = _growSeasonFor(
    vegetable,
    temperature: temp,
    humidity: humidity,
  );
  return MushroomOverviewLayout(
    vegetableId: vegetable.id,
    nameNl: vegetable.nameNl,
    nameLatin: latinNameForVegetable(vegetable),
    difficulty: 'Gemiddeld',
    location: 'Binnen / schuur',
    temperature: temp,
    temperatureSubtitle: 'Ideaal',
    humidity: humidity,
    humiditySubtitle: 'Hoog',
    timeToHarvest: vegetable.cropDuration ?? '4–8 weken',
    yield: 'Zie teeltinfo',
    flushCount: '2–4 flushes',
    substrate: vegetable.soilAndFood,
    light: vegetable.sunRequirement,
    ventilation: 'Gemiddeld',
    ventilationSubtitle: 'Belangrijk',
    summary: vegetable.summary,
    stages: const [
      MushroomGrowthStage(label: 'Enten', duration: 'Dag 0', icon: Icons.grain),
      MushroomGrowthStage(
        label: 'Kolonisatie',
        duration: '7–14 dagen',
        icon: Icons.science_outlined,
      ),
      MushroomGrowthStage(
        label: 'Vruchtvorming',
        duration: '14–21 dagen',
        icon: Icons.spa_outlined,
      ),
      MushroomGrowthStage(
        label: 'Oogst',
        duration: '21–28 dagen',
        icon: Icons.shopping_basket_outlined,
      ),
    ],
    edibility: 'Eetbaar',
    edibilityStars: 4,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Geschikt',
    beginnerRecommended: true,
    goodToKnow: vegetable.care,
    growSeason: season.timeline,
    growSeasonNote: season.note,
  );
}

class _MushroomFacts {
  const _MushroomFacts({
    this.badgeLabel = 'Eetbare paddenstoel',
    required this.difficulty,
    this.difficultySubtitle,
    this.difficultyColor,
    required this.location,
    this.locationSubtitle,
    required this.temperature,
    this.temperatureSubtitle,
    required this.humidity,
    this.humiditySubtitle,
    required this.timeToHarvest,
    required this.yield,
    required this.flushCount,
    required this.substrate,
    required this.light,
    required this.ventilation,
    this.ventilationSubtitle,
    required this.summary,
    required this.stages,
    required this.edibility,
    this.edibilitySubtitle,
    required this.edibilityStars,
    required this.beginnerSuitability,
    this.beginnerSubtitle,
    required this.beginnerRecommended,
    required this.goodToKnow,
  });

  final String badgeLabel;
  final String difficulty;
  final String? difficultySubtitle;
  final Color? difficultyColor;
  final String location;
  final String? locationSubtitle;
  final String temperature;
  final String? temperatureSubtitle;
  final String humidity;
  final String? humiditySubtitle;
  final String timeToHarvest;
  final String yield;
  final String flushCount;
  final String substrate;
  final String light;
  final String ventilation;
  final String? ventilationSubtitle;
  final String summary;
  final List<MushroomGrowthStage> stages;
  final String edibility;
  final String? edibilitySubtitle;
  final int edibilityStars;
  final String beginnerSuitability;
  final String? beginnerSubtitle;
  final bool beginnerRecommended;
  final String goodToKnow;
}

const _easy = Color(0xFF43A047);
const _medium = Color(0xFFF57C00);
const _hard = Color(0xFFE53935);

const _kitStages = [
  MushroomGrowthStage(label: 'Enten', duration: 'Dag 0', icon: Icons.grain),
  MushroomGrowthStage(
    label: 'Kolonisatie',
    duration: '7–14 dagen',
    icon: Icons.science_outlined,
  ),
  MushroomGrowthStage(
    label: 'Vruchtvorming',
    duration: '14–21 dagen',
    icon: Icons.spa_outlined,
  ),
  MushroomGrowthStage(
    label: 'Oogst',
    duration: '21–28 dagen',
    icon: Icons.shopping_basket_outlined,
  ),
];

const _outdoorStages = [
  MushroomGrowthStage(
    label: 'Enten',
    duration: 'Maart–mei',
    icon: Icons.grain,
  ),
  MushroomGrowthStage(
    label: 'Kolonisatie',
    duration: 'Zomer',
    icon: Icons.science_outlined,
  ),
  MushroomGrowthStage(
    label: 'Vruchtvorming',
    duration: 'Late zomer',
    icon: Icons.spa_outlined,
  ),
  MushroomGrowthStage(
    label: 'Oogst',
    duration: 'Herfst',
    icon: Icons.shopping_basket_outlined,
  ),
];

const Map<String, _MushroomFacts> _mushroomFacts = {
  'oesterzwam': _MushroomFacts(
    difficulty: 'Makkelijk',
    difficultyColor: _easy,
    location: 'Binnen / Schuur',
    locationSubtitle: 'Kelder',
    temperature: '15–22 °C',
    temperatureSubtitle: 'Ideaal',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '21–28 dagen',
    yield: '500 g – 1 kg',
    flushCount: '3–5 flushes per kweek',
    substrate: 'Zaagsel, stro, koffiedik, graan',
    light: 'Indirect licht of weinig licht',
    ventilation: 'Gemiddeld',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Een zeer makkelijke en populaire paddenstoel met hoge opbrengst. Ideaal voor beginners en geschikt voor verschillende substraten en binnenomstandigheden.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Milde, heerlijke smaak',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Zeer geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Geef voldoende frisse lucht en houd de luchtvochtigheid stabiel voor de beste opbrengst.',
  ),
  'koningsoesterzwam': _MushroomFacts(
    difficulty: 'Makkelijk',
    difficultyColor: _easy,
    location: 'Binnen / Schuur',
    locationSubtitle: 'Kelder',
    temperature: '18–24 °C',
    temperatureSubtitle: 'Ideaal',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '3–5 weken',
    yield: '400 g – 800 g',
    flushCount: '2–3 flushes per kweek',
    substrate: 'Stro, hardhout of growkit',
    light: 'Indirect licht',
    ventilation: 'Gemiddeld',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Grote, stevige oesterzwam via populaire growkits. Vraagt iets meer ruimte maar is zeer betrouwbaar binnen.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Stevige, nootachtige smaak',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Zeer geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Snijd de kit open op de juiste plek en houd het substraat gelijkmatig vochtig.',
  ),
  'shiitake': _MushroomFacts(
    difficulty: 'Gemiddeld',
    difficultyColor: _medium,
    location: 'Binnen / Schuur',
    locationSubtitle: 'Koele ruimte',
    temperature: '12–20 °C',
    temperatureSubtitle: 'Koeler tijdens vruchtzetting',
    humidity: '80–90 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '8–12 weken',
    yield: '200 g – 500 g',
    flushCount: '2–4 flushes per blok',
    substrate: 'Zaagselblok / growkit (of eikenblok buiten)',
    light: 'Weinig licht / schaduw',
    ventilation: 'Matig',
    ventilationSubtitle: 'Geen tocht',
    summary:
        'Klassieke paddenstoel. Met growkit of zaagselblok oogst je in weken; op een eikenblok buiten duurt kolonisatie maanden tot een seizoen.',
    stages: const [
      MushroomGrowthStage(label: 'Enten', duration: 'Dag 0', icon: Icons.grain),
      MushroomGrowthStage(
        label: 'Kolonisatie',
        duration: '4–8 weken (kit)',
        icon: Icons.science_outlined,
      ),
      MushroomGrowthStage(
        label: 'Vruchtvorming',
        duration: '1–2 weken',
        icon: Icons.spa_outlined,
      ),
      MushroomGrowthStage(
        label: 'Oogst',
        duration: '8–12 weken (kit)',
        icon: Icons.shopping_basket_outlined,
      ),
    ],
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Rijk, umami smaak',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Met growkit geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Een koude schok (koel nachten) kan vruchtzetting stimuleren na kolonisatie. Buitenstammen vragen veel meer geduld.',
  ),
  'kastanjechampignon': _MushroomFacts(
    difficulty: 'Makkelijk',
    difficultyColor: _easy,
    location: 'Binnen',
    locationSubtitle: 'Donkere ruimte',
    temperature: '14–18 °C',
    temperatureSubtitle: 'Koel',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '4–6 weken',
    yield: '500 g – 1 kg',
    flushCount: '2–3 flushes per kweek',
    substrate: 'Compost met casinglaag',
    light: 'Volledige duisternis',
    ventilation: 'Matig',
    ventilationSubtitle: 'Frisse lucht, geen koude tocht',
    summary:
        'Bruine champignonvariant voor donkere, koele ruimtes. Populair via kant-en-klare kweeksets.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Stevige champignonsmaak',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Met growkit geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Houd de ruimte donker en koel; frisse lucht voorkomt lange, dunne stelen.',
  ),
  'portobello': _MushroomFacts(
    difficulty: 'Makkelijk',
    difficultyColor: _easy,
    location: 'Binnen',
    locationSubtitle: 'Donkere ruimte',
    temperature: '14–18 °C',
    temperatureSubtitle: 'Koel',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '5–7 weken',
    yield: '400 g – 800 g',
    flushCount: '2–3 flushes per kweek',
    substrate: 'Compost met casinglaag',
    light: 'Volledige duisternis',
    ventilation: 'Matig',
    ventilationSubtitle: 'Frisse lucht, geen koude tocht',
    summary:
        'Grote bruine champignon met stevige textuur. Zelfde teelt als gewone champignon, maar met bredere hoeden.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Vlezig en veelzijdig',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Met growkit geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Oogst net voordat de hoed volledig openspreidt voor de beste textuur.',
  ),
  'champignon_wit': _MushroomFacts(
    difficulty: 'Makkelijk',
    difficultyColor: _easy,
    location: 'Binnen',
    locationSubtitle: 'Donkere ruimte',
    temperature: '14–18 °C',
    temperatureSubtitle: 'Koel',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '4–6 weken',
    yield: '500 g – 1 kg',
    flushCount: '2–3 flushes per kweek',
    substrate: 'Compost met casinglaag',
    light: 'Volledige duisternis',
    ventilation: 'Matig',
    ventilationSubtitle: 'Frisse lucht, geen koude tocht',
    summary:
        'De bekendste champignon voor binnenteelt. Growkits maken kweken toegankelijk voor beginners.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Mild en universeel',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Zeer geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Zorg voor frisse lucht: te veel CO₂ geeft lange, dunne stelen. Werk hygiënisch tegen vervuiling.',
  ),
  'morielzwam': _MushroomFacts(
    difficulty: 'Moeilijk',
    difficultyColor: _hard,
    location: 'Buiten',
    locationSubtitle: 'Beschutte plek',
    temperature: '10–16 °C',
    temperatureSubtitle: 'Koel voorjaar',
    humidity: '70–85 %',
    humiditySubtitle: 'Matig tot hoog',
    timeToHarvest: '1–2 seizoenen',
    yield: 'Variabel',
    flushCount: '1 oogst per bed',
    substrate: 'Compost, mulch, kalkrijke grond',
    light: 'Halfschaduw',
    ventilation: 'Natuurlijk',
    ventilationSubtitle: 'Buitenlucht',
    summary:
        'Buitenkweek is uitdagend en vraagt geduld. Voor de meeste tuiniers zijn growkits of specialistische spawn betrouwbaarder.',
    stages: _outdoorStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Delicatesse met intense smaak',
    edibilityStars: 5,
    beginnerSuitability: 'Nee',
    beginnerSubtitle: 'Voor gevorderden',
    beginnerRecommended: false,
    goodToKnow:
        'Alleen oogsten als je de soort 100% zeker herkent; moriel heeft gevaarlijke lookalikes.',
  ),
  'lions_mane': _MushroomFacts(
    difficulty: 'Gemiddeld',
    difficultyColor: _medium,
    location: 'Binnen / Schuur',
    locationSubtitle: 'Koele ruimte',
    temperature: '15–20 °C',
    temperatureSubtitle: 'Ideaal',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '4–8 weken',
    yield: '200 g – 500 g',
    flushCount: '2–3 flushes per kweek',
    substrate: 'Hardhout, zaagsel of growkit',
    light: 'Weinig licht',
    ventilation: 'Matig',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Opvallende pluizige paddenstoel met zachte, kreeftachtige textuur. Populair via growkits op houtsubstraat.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Zacht en aromatisch',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Met growkit geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Oogst wanneer de “manen” nog wit en compact zijn, vóór vergeling.',
  ),
  'enoki': _MushroomFacts(
    difficulty: 'Gemiddeld',
    difficultyColor: _medium,
    location: 'Binnen',
    locationSubtitle: 'Koele kast',
    temperature: '10–15 °C',
    temperatureSubtitle: 'Koel tijdens vruchtzetting',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '4–6 weken',
    yield: '150 g – 300 g',
    flushCount: '2–3 flushes per kweek',
    substrate: 'Zaagsel, stro of growkit',
    light: 'Weinig licht',
    ventilation: 'Matig',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Slanke, witte paddenstoeltjes die koelere temperaturen prefereren. Ideaal in een koele kelderruimte.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Knapperig in soep en salade',
    edibilityStars: 4,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Met growkit geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Houd de omgeving koel en donker voor lange, witte stelen.',
  ),
  'shimeji': _MushroomFacts(
    difficulty: 'Makkelijk',
    difficultyColor: _easy,
    location: 'Binnen / Schuur',
    locationSubtitle: 'Kelder',
    temperature: '15–22 °C',
    temperatureSubtitle: 'Ideaal',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '4–6 weken',
    yield: '200 g – 400 g',
    flushCount: '2–3 flushes per kweek',
    substrate: 'Zaagsel, hout of growkit',
    light: 'Indirect licht',
    ventilation: 'Gemiddeld',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Kleine clusterzwammen met nootachtige smaak. Growkits zijn betrouwbaar en relatief snel.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Nootachtig en stevig',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Zeer geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Kook shimeji altijd even mee; rauw zijn ze wat bitter.',
  ),
  'maitake': _MushroomFacts(
    difficulty: 'Gemiddeld',
    difficultyColor: _medium,
    location: 'Binnen / Schuur',
    locationSubtitle: 'Koele ruimte',
    temperature: '15–22 °C',
    temperatureSubtitle: 'Ideaal',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '8–16 weken',
    yield: '300 g – 700 g',
    flushCount: '1–2 flushes per kweek',
    substrate: 'Hardhout, zaagsel of growkit',
    light: 'Weinig licht',
    ventilation: 'Matig',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Grote bladachtige clusters op houtsubstraat. Vraagt meer geduld maar levert indrukwekkende oogsten op.',
    stages: const [
      MushroomGrowthStage(label: 'Enten', duration: 'Dag 0', icon: Icons.grain),
      MushroomGrowthStage(
        label: 'Kolonisatie',
        duration: '3–6 weken',
        icon: Icons.science_outlined,
      ),
      MushroomGrowthStage(
        label: 'Vruchtvorming',
        duration: '2–4 weken',
        icon: Icons.spa_outlined,
      ),
      MushroomGrowthStage(
        label: 'Oogst',
        duration: '8–16 weken',
        icon: Icons.shopping_basket_outlined,
      ),
    ],
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Rijk en aromatisch',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Met growkit geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Snijd de hele cluster bij de basis; meerdere flushes zijn mogelijk op hetzelfde blok.',
  ),
  'reishi': _MushroomFacts(
    badgeLabel: 'Medicinale paddenstoel',
    difficulty: 'Moeilijk',
    difficultyColor: _hard,
    location: 'Binnen / Schuur',
    locationSubtitle: 'Warme ruimte',
    temperature: '20–28 °C',
    temperatureSubtitle: 'Warm',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '4–12 maanden',
    yield: 'Beperkt (medicinaal)',
    flushCount: '1 oogst per blok',
    substrate: 'Hardhoutblok (eiken, beuken)',
    light: 'Indirect licht',
    ventilation: 'Matig',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Langzaam groeiende lakzwam vooral gekweekt om medicinale toepassingen. Vraagt geduld, warmte en hoge luchtvochtigheid.',
    stages: const [
      MushroomGrowthStage(label: 'Enten', duration: 'Dag 0', icon: Icons.grain),
      MushroomGrowthStage(
        label: 'Kolonisatie',
        duration: '2–4 maanden',
        icon: Icons.science_outlined,
      ),
      MushroomGrowthStage(
        label: 'Vruchtvorming',
        duration: '1–3 maanden',
        icon: Icons.spa_outlined,
      ),
      MushroomGrowthStage(
        label: 'Oogst',
        duration: '4–12 maanden',
        icon: Icons.shopping_basket_outlined,
      ),
    ],
    edibility: 'Medicinaal gebruik',
    edibilitySubtitle: 'Thee en extracten',
    edibilityStars: 3,
    beginnerSuitability: 'Nee',
    beginnerSubtitle: 'Voor gevorderden',
    beginnerRecommended: false,
    goodToKnow:
        'Reishi is taai en bitter; meestal gebruikt als thee, poeder of extract.',
  ),
  'zomerpaddestoel': _MushroomFacts(
    difficulty: 'Makkelijk',
    difficultyColor: _easy,
    location: 'Binnen / Schuur',
    locationSubtitle: 'Kelder',
    temperature: '18–24 °C',
    temperatureSubtitle: 'Ideaal',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '4–6 weken',
    yield: '300 g – 600 g',
    flushCount: '2–4 flushes per kweek',
    substrate: 'Zaagsel, stro of growkit',
    light: 'Indirect licht',
    ventilation: 'Gemiddeld',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Populaire keukenpaddenstoel (pioppino) via growkits of zaagsel-substraat. Snelle en betrouwbare kweek.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Notig en stevig',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Zeer geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Oogst bij een halfopen hoed voor de beste smaak en houdbaarheid.',
  ),
  'nameko': _MushroomFacts(
    difficulty: 'Gemiddeld',
    difficultyColor: _medium,
    location: 'Binnen',
    locationSubtitle: 'Koele ruimte',
    temperature: '16–22 °C',
    temperatureSubtitle: 'Koeler dan oesterzwam',
    humidity: '85–95 %',
    humiditySubtitle: 'Hoog',
    timeToHarvest: '5–8 weken',
    yield: '200 g – 400 g',
    flushCount: '2–3 flushes per kweek',
    substrate: 'Stro, hout of growkit',
    light: 'Indirect licht',
    ventilation: 'Matig',
    ventilationSubtitle: 'Belangrijk',
    summary:
        'Amberkleurige paddenstoel met kenmerkende glans, populair in de Aziatische keuken. Growkits zijn de makkelijkste start.',
    stages: _kitStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Zacht met lichte nootachtige smaak',
    edibilityStars: 4,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Met growkit geschikt',
    beginnerRecommended: true,
    goodToKnow:
        'Houd de ruimte iets koeler dan bij oesterzwam voor mooie, glanzende hoeden.',
  ),
  'wijnrood_stropharia': _MushroomFacts(
    difficulty: 'Makkelijk',
    difficultyColor: _easy,
    location: 'Buiten',
    locationSubtitle: 'Compostbed / mulch',
    temperature: '15–22 °C',
    temperatureSubtitle: 'Buitentemperatuur',
    humidity: '70–90 %',
    humiditySubtitle: 'Matig tot hoog',
    timeToHarvest: '3–6 maanden',
    yield: '1 – 3 kg per bed',
    flushCount: '2–3 flushes per seizoen',
    substrate: 'Compost, mulch, houtsnippers',
    light: 'Halfschaduw',
    ventilation: 'Natuurlijk',
    ventilationSubtitle: 'Buitenlucht',
    summary:
        'Een van de makkelijkste buitenpaddenstoelen. Inoculeer een mulch- of compostbed in het voorjaar en oogst na de zomer.',
    stages: _outdoorStages,
    edibility: 'Uitstekend eetbaar',
    edibilitySubtitle: 'Stevig en nootachtig',
    edibilityStars: 5,
    beginnerSuitability: 'Ja',
    beginnerSubtitle: 'Goed voor buiten',
    beginnerRecommended: true,
    goodToKnow:
        'Houd het bed vochtig en bedek met mulch zodat het substraat niet uitdroogt.',
  ),
  'blauwe_ridderzwam': _MushroomFacts(
    difficulty: 'Gemiddeld',
    difficultyColor: _medium,
    location: 'Buiten',
    locationSubtitle: 'Schaduwplek',
    temperature: '10–18 °C',
    temperatureSubtitle: 'Koel in herfst',
    humidity: '75–90 %',
    humiditySubtitle: 'Matig tot hoog',
    timeToHarvest: '4–8 maanden',
    yield: 'Variabel per bed',
    flushCount: '1–2 flushes per seizoen',
    substrate: 'Compost, bladeren, houtmulch',
    light: 'Schaduw tot halfschaduw',
    ventilation: 'Natuurlijk',
    ventilationSubtitle: 'Buitenlucht',
    summary:
        'Smaakvolle herfstoogst op compost of bladeren. Vraagt geduld en zekere determinatie bij oogst.',
    stages: _outdoorStages,
    edibility: 'Goed eetbaar',
    edibilitySubtitle: 'Aromatisch en stevig',
    edibilityStars: 4,
    beginnerSuitability: 'Nee',
    beginnerSubtitle: 'Voor gevorderden',
    beginnerRecommended: false,
    goodToKnow:
        'Oogst alleen bij 100% zekere herkenning; verwar de soort nooit met giftige lookalikes.',
  ),
};
