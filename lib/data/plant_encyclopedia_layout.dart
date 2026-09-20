import 'dart:math' as math;
import 'dart:ui' show Size;

import '../models/vegetable.dart';
import 'moestuin_companion_info.dart';
import 'plant_search_filters.dart';
import 'plant_location_guide.dart';
import 'plant_sowing_guide.dart';
import 'plant_transplant_guide.dart';
import 'plant_nutrition_guide.dart';
import 'plant_water_guide.dart';
import 'plant_growth_guide.dart';
import 'plant_bloom_guide.dart';
import 'plant_harvest_guide.dart';
import 'plant_care_guide.dart';
import 'plant_problems_guide.dart';
import 'plant_combination_guide.dart';
import 'plant_weetjes_guide.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';
import 'planting_season_status.dart';
import 'vegetable_overview_data.dart';

/// Design tokens voor de plantencyclopedie.
abstract final class PlantDetailDesign {
  static const primaryGreen = 0xFF2E7D32;
  static const accentGreen = 0xFF43A047;
  static const background = 0xFFF3FAF4;
  static const card = 0xFFFFFFFF;
  static const border = 0xFFE8ECEA;
  static const textPrimary = 0xFF1D1D1F;
  static const textSecondary = 0xFF6B7280;
  static const warning = 0xFFF59E0B;
  static const success = 0xFF22C55E;
  static const cardRadius = 16.0;
  static const cardPadding = 16.0;

  /// Detail-hero: breder/hoger beeld (Plant Parent ~40% schermhoogte).
  static const detailBannerAspectRatio = 1.38;
  static const detailHeroHeightFraction = 0.38;
  static const detailHeroMaxHeightFraction = 0.48;

  static double detailHeroHeight(Size screen) {
    final byFraction = screen.height * detailHeroHeightFraction;
    final byAspect = screen.width / detailBannerAspectRatio;
    final maxH = screen.height * detailHeroMaxHeightFraction;
    final preferred = math.max(byFraction, byAspect);
    return preferred.clamp(160.0, maxH);
  }
}

enum PlantSuitability { suitable, limited, notRecommended }

extension PlantSuitabilityLabel on PlantSuitability {
  String get label {
    switch (this) {
      case PlantSuitability.suitable:
        return 'Geschikt';
      case PlantSuitability.limited:
        return 'Beperkt';
      case PlantSuitability.notRecommended:
        return 'Niet aanbevolen';
    }
  }
}

class PlantMonthTimeline {
  const PlantMonthTimeline({required this.label, required this.months});

  final String label;
  final Set<int> months;
}

class PlantInfoBlock {
  const PlantInfoBlock({
    required this.title,
    required this.body,
    this.timeline,
    this.suitability,
    this.isWarning = false,
    this.tags = const [],
  });

  final String title;
  final String body;
  final PlantMonthTimeline? timeline;
  final Map<String, PlantSuitability>? suitability;
  final bool isWarning;
  final List<String> tags;
}

enum PlantInfoCategoryId {
  zaaien,
  uitplanten,
  standplaats,
  water,
  voeding,
  groei,
  bloei,
  oogsten,
  verzorging,
  problemen,
  combinatieteelt,
  weetjes,
}

extension PlantInfoCategoryIdMeta on PlantInfoCategoryId {
  String get label {
    switch (this) {
      case PlantInfoCategoryId.zaaien:
        return 'Zaaien';
      case PlantInfoCategoryId.uitplanten:
        return 'Uitplanten';
      case PlantInfoCategoryId.standplaats:
        return 'Standplaats';
      case PlantInfoCategoryId.water:
        return 'Water';
      case PlantInfoCategoryId.voeding:
        return 'Voeding';
      case PlantInfoCategoryId.groei:
        return 'Groei';
      case PlantInfoCategoryId.bloei:
        return 'Bloei';
      case PlantInfoCategoryId.oogsten:
        return 'Oogsten';
      case PlantInfoCategoryId.verzorging:
        return 'Verzorging';
      case PlantInfoCategoryId.problemen:
        return 'Problemen';
      case PlantInfoCategoryId.combinatieteelt:
        return 'Combinatie';
      case PlantInfoCategoryId.weetjes:
        return 'Weetjes';
    }
  }

  /// Bloemen gebruiken andere tabnamen waar de inhoud anders is (bijv. zaadoogst).
  String labelForPlant({bool isFlower = false}) {
    if (isFlower && this == PlantInfoCategoryId.oogsten) {
      return 'Zaadoogst';
    }
    if (isFlower && this == PlantInfoCategoryId.combinatieteelt) {
      return 'Combinaties';
    }
    return label;
  }

  String get iconName {
    switch (this) {
      case PlantInfoCategoryId.zaaien:
        return 'eco';
      case PlantInfoCategoryId.uitplanten:
        return 'yard';
      case PlantInfoCategoryId.standplaats:
        return 'wb_sunny';
      case PlantInfoCategoryId.water:
        return 'water_drop';
      case PlantInfoCategoryId.voeding:
        return 'compost';
      case PlantInfoCategoryId.groei:
        return 'trending_up';
      case PlantInfoCategoryId.bloei:
        return 'local_florist';
      case PlantInfoCategoryId.oogsten:
        return 'shopping_basket';
      case PlantInfoCategoryId.verzorging:
        return 'content_cut';
      case PlantInfoCategoryId.problemen:
        return 'shield';
      case PlantInfoCategoryId.combinatieteelt:
        return 'thumb_up';
      case PlantInfoCategoryId.weetjes:
        return 'lightbulb';
    }
  }
}

class PlantInfoCategoryContent {
  const PlantInfoCategoryContent({
    required this.id,
    required this.blocks,
    this.sowingGuide,
    this.transplantGuide,
    this.locationGuide,
    this.waterGuide,
    this.nutritionGuide,
    this.growthGuide,
    this.bloomGuide,
    this.harvestGuide,
    this.careGuide,
    this.problemsGuide,
    this.combinationGuide,
    this.weetjesGuide,
  });

  final PlantInfoCategoryId id;
  final List<PlantInfoBlock> blocks;
  final PlantSowingGuide? sowingGuide;
  final PlantTransplantGuide? transplantGuide;
  final PlantLocationGuide? locationGuide;
  final PlantWaterGuide? waterGuide;
  final PlantNutritionGuide? nutritionGuide;
  final PlantGrowthGuide? growthGuide;
  final PlantBloomGuide? bloomGuide;
  final PlantHarvestGuide? harvestGuide;
  final PlantCareGuide? careGuide;
  final PlantProblemsGuide? problemsGuide;
  final PlantCombinationGuide? combinationGuide;
  final PlantWeetjesGuide? weetjesGuide;
}

class PlantEncyclopediaLayout {
  const PlantEncyclopediaLayout({
    required this.summaryShort,
    required this.standplaats,
    required this.water,
    required this.difficulty,
    required this.lifespan,
    required this.voeding,
    required this.locatieOutdoor,
    required this.locatieContainer,
    required this.sowing,
    required this.planting,
    this.bloom,
    required this.harvest,
    required this.keyPoints,
    required this.height,
    required this.width,
    required this.growthHabit,
    required this.plantSpacing,
    required this.rowSpacing,
    required this.firstHarvest,
    required this.harvestPeriod,
    required this.opbrengstLevel,
    required this.opbrengstDetail,
    required this.bloomPeriod,
    required this.flowerColor,
    required this.beeFriendly,
    required this.didYouKnow,
    required this.categories,
  });

  final String summaryShort;
  final String standplaats;
  final String water;
  final String difficulty;
  final String lifespan;
  final String voeding;
  final String locatieOutdoor;
  final String locatieContainer;
  final PlantMonthTimeline sowing;
  final PlantMonthTimeline planting;
  final PlantMonthTimeline? bloom;
  final PlantMonthTimeline harvest;
  final List<String> keyPoints;
  final String height;
  final String width;
  final String growthHabit;
  final String plantSpacing;
  final String rowSpacing;
  final String firstHarvest;
  final String harvestPeriod;
  final String opbrengstLevel;
  final String opbrengstDetail;
  final String bloomPeriod;
  final String flowerColor;
  final String beeFriendly;
  final String didYouKnow;
  final List<PlantInfoCategoryContent> categories;
}

const _monthLetters = ['J', 'F', 'M', 'A', 'M', 'J', 'J', 'A', 'S', 'O', 'N', 'D'];

String monthLettersLabel() => _monthLetters.join(' ');

PlantEncyclopediaLayout buildPlantEncyclopediaLayout({
  required Vegetable vegetable,
  PlantingSeasonAdvice? seasonAdvice,
}) {
  final companion = moestuinCompanionInfoForVegetable(vegetable);
  final activities = calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  );
  final sowMonths = _monthsForTypes(
    activities,
    {GardenTaskType.preSow, GardenTaskType.sowOutdoors},
  );
  final plantMonths = _monthsForTypes(activities, {GardenTaskType.plantOutdoors});
  final harvestMonths = _monthsForTypes(activities, {GardenTaskType.harvest});

  final sun = _standplaatsLabel(vegetable.sunRequirement);
  final water = _waterLabel(vegetable.water);
  final difficulty = _difficultyLabel(vegetable);
  final lifespan = _lifespanLabel(vegetable);

  final summary = _shortSummary(vegetable.summary, companion?.atAGlance);
  final keyPoints = _keyPoints(vegetable, companion, seasonAdvice);
  final growth = _growthFacts(vegetable);
  final bloomHarvest = _bloomHarvestSummary(vegetable, companion, harvestMonths);
  final bloomMonths = companion == null && _containsBloom(vegetable)
      ? _monthsFromHarvestText(bloomHarvest.$1)
      : <int>{};
  final bloomTimeline = bloomMonths.isNotEmpty
      ? PlantMonthTimeline(label: 'Bloei', months: bloomMonths)
      : null;
  final locatie = _locatieLabels(vegetable);
  final opbrengst = _opbrengstFacts(vegetable);

  final layout = PlantEncyclopediaLayout(
    summaryShort: summary,
    standplaats: sun,
    water: water,
    difficulty: difficulty,
    lifespan: lifespan,
    voeding: _voedingLabel(vegetable),
    locatieOutdoor: locatie.$1,
    locatieContainer: locatie.$2,
    sowing: PlantMonthTimeline(label: 'Zaaien', months: sowMonths),
    planting: PlantMonthTimeline(label: 'Uitplanten', months: plantMonths),
    bloom: bloomTimeline,
    harvest: PlantMonthTimeline(
      label: companion != null ? 'Bloei' : 'Oogsten',
      months: harvestMonths.isNotEmpty
          ? harvestMonths
          : _monthsFromHarvestText(vegetable.harvest),
    ),
    keyPoints: keyPoints,
    height: growth.$1,
    width: growth.$2,
    growthHabit: growth.$3,
    plantSpacing: '${vegetable.spacingCm} cm',
    rowSpacing: vegetable.rowSpacingCm > vegetable.spacingCm
        ? '${vegetable.spacingCm}–${vegetable.rowSpacingCm} cm'
        : '${vegetable.rowSpacingCm} cm',
    firstHarvest: _firstHarvestLabel(vegetable),
    harvestPeriod: bloomHarvest.$2 != '—' && bloomHarvest.$2.isNotEmpty
        ? bloomHarvest.$2
        : vegetable.harvest.trim().isNotEmpty
            ? vegetable.harvest.trim()
            : '—',
    opbrengstLevel: opbrengst.$1,
    opbrengstDetail: opbrengst.$2,
    bloomPeriod: bloomHarvest.$1,
    flowerColor: bloomHarvest.$3,
    beeFriendly: bloomHarvest.$4,
    didYouKnow: _didYouKnow(vegetable, companion),
    categories: _buildCategories(
      vegetable: vegetable,
      companion: companion,
      sowMonths: sowMonths,
      plantMonths: plantMonths,
      harvestMonths: harvestMonths,
    ),
  );

  return _applyVegetableOverviewFacts(vegetable: vegetable, layout: layout);
}

PlantEncyclopediaLayout _applyVegetableOverviewFacts({
  required Vegetable vegetable,
  required PlantEncyclopediaLayout layout,
}) {
  // Bloemen en paddenstoelen hebben eigen overzicht-tabs.
  if (kMushroomPlantIds.contains(vegetable.id) ||
      isFlowerGuidePlant(vegetable.id)) {
    return layout;
  }
  final facts = vegetableOverviewFactsFor(vegetable.id);
  if (facts == null) return layout;

  final sowOrPlant = facts.sowMonths.isNotEmpty
      ? facts.sowMonths
      : facts.plantMonths;
  final sowLabel =
      facts.sowMonths.isNotEmpty ? 'Zaaien' : 'Planten';

  return PlantEncyclopediaLayout(
    summaryShort: facts.summaryShort,
    standplaats: facts.standplaats,
    water: facts.water,
    difficulty: facts.difficulty,
    lifespan: facts.lifespan,
    voeding: facts.voeding,
    locatieOutdoor: facts.locatieOutdoor,
    locatieContainer: facts.locatieContainer,
    sowing: PlantMonthTimeline(label: sowLabel, months: sowOrPlant),
    planting: PlantMonthTimeline(
      label: 'Uitplanten',
      months: facts.plantMonths,
    ),
    bloom: layout.bloom,
    harvest: PlantMonthTimeline(
      label: 'Oogsten',
      months: facts.harvestMonths,
    ),
    keyPoints: facts.keyPoints,
    height: facts.height,
    width: facts.width,
    growthHabit: facts.growthHabit,
    plantSpacing: facts.plantSpacing,
    rowSpacing: facts.rowSpacing,
    firstHarvest: facts.firstHarvest,
    harvestPeriod: facts.harvestPeriod,
    opbrengstLevel: facts.opbrengstLevel,
    opbrengstDetail: facts.opbrengstDetail,
    bloomPeriod: layout.bloomPeriod,
    flowerColor: layout.flowerColor,
    beeFriendly: layout.beeFriendly,
    didYouKnow: facts.didYouKnow,
    categories: layout.categories,
  );
}

Set<int> _monthsForTypes(
  List<VegetableMonthActivity> activities,
  Set<GardenTaskType> types,
) {
  final out = <int>{};
  for (final a in activities) {
    if (types.contains(a.type)) out.addAll(a.months);
  }
  return out;
}

Set<int> _monthsFromHarvestText(String harvest) {
  final map = {
    'januari': 1,
    'februari': 2,
    'maart': 3,
    'april': 4,
    'mei': 5,
    'juni': 6,
    'juli': 7,
    'augustus': 8,
    'september': 9,
    'oktober': 10,
    'november': 11,
    'december': 12,
  };
  final t = harvest.toLowerCase();
  final out = <int>{};
  for (final e in map.entries) {
    if (t.contains(e.key)) out.add(e.value);
  }
  return out;
}

String _standplaatsLabel(String sunRequirement) {
  switch (classifySun(sunRequirement)) {
    case SunFilter.fullSun:
      return 'Zon';
    case SunFilter.partialShade:
      return 'Halfschaduw';
    case SunFilter.shade:
      return 'Schaduw';
  }
}

String _waterLabel(String water) {
  switch (classifyWater(water)) {
    case WaterFilter.low:
      return 'Laag';
    case WaterFilter.medium:
      return 'Gemiddeld';
    case WaterFilter.high:
      return 'Hoog';
  }
}

String _difficultyLabel(Vegetable v) {
  final blob =
      '${v.id} ${v.growthCategory ?? ''} ${v.summary} ${v.care}'.toLowerCase();
  if (blob.contains('moeilijk') ||
      blob.contains('veeleisend') ||
      blob.contains('kas nodig') ||
      v.id.contains('meloen') ||
      v.id.contains('aubergine') ||
      v.id.contains('watermeloen')) {
    return 'Moeilijk';
  }
  if (blob.contains('makkelijk') ||
      v.id.contains('radijs') ||
      v.id.contains('sla') ||
      v.id.contains('spinazie') ||
      v.id.contains('bonen') ||
      v.id.contains('tuinkers') ||
      v.growthCategory?.toLowerCase().contains('snelle') == true) {
    return 'Makkelijk';
  }
  return 'Gemiddeld';
}

String _lifespanLabel(Vegetable v) {
  final cat = v.growthCategory?.toLowerCase() ?? '';
  final blob = '${v.family} ${v.keywords.join(' ')}'.toLowerCase();
  if (cat.contains('meerjarig') ||
      blob.contains('meerjarig') ||
      blob.contains('vaste plant') ||
      blob.contains('boom') ||
      blob.contains('struik')) {
    return 'Meerjarig';
  }
  if (blob.contains('tweejarig') || v.id.contains('witlof')) {
    return 'Tweejarig';
  }
  return 'Eenjarig';
}

String _voedingLabel(Vegetable v) {
  final blob = '${v.soilAndFood} ${v.care}'.toLowerCase();
  if (blob.contains('zwaar') ||
      blob.contains('veel compost') ||
      blob.contains('zeer rijk') ||
      blob.contains('voedingsrijk')) {
    return 'Hoog';
  }
  if (blob.contains('arm') ||
      blob.contains('weinig') ||
      blob.contains('licht bemest') ||
      blob.contains('niet bemesten')) {
    return 'Laag';
  }
  return 'Gemiddeld';
}

(String, String) _locatieLabels(Vegetable v) {
  final blob =
      '${v.care} ${v.sowingIndoors} ${v.transplant} ${v.summary} ${v.harvestTips}'
          .toLowerCase();
  final outdoor = blob.contains('kas') ||
          blob.contains('serre') ||
          blob.contains('tunnel') ||
          blob.contains('onder glas')
      ? 'Buiten / Kas'
      : blob.contains('alleen binnen') || blob.contains('binnen voorzaaien')
          ? 'Binnen / Kas'
          : 'Buiten';
  final container = v.spacingCm <= 35 ||
          blob.contains('pot') ||
          blob.contains('balkon') ||
          blob.contains('bak')
      ? 'Pot / Balkon'
      : v.spacingCm >= 80
          ? 'Volle grond'
          : 'Bed / Pot';
  return (outdoor, container);
}

String _firstHarvestLabel(Vegetable v) {
  if (v.cropDuration != null && v.cropDuration!.trim().isNotEmpty) {
    return v.cropDuration!.trim();
  }
  final cat = v.growthCategory?.toLowerCase() ?? '';
  if (cat.contains('snelle')) return '±25–40 dagen';
  if (cat.contains('middelmatige')) return '±50–70 dagen';
  if (cat.contains('lang producerende')) return '±60–90 dagen';
  return '±60–80 dagen';
}

(String, String) _opbrengstFacts(Vegetable v) {
  final blob =
      '${v.summary} ${v.harvestTips} ${v.growthCategory ?? ''}'.toLowerCase();
  final level = blob.contains('productief') ||
          blob.contains('hoge opbrengst') ||
          blob.contains('dooroogst') ||
          v.growthCategory?.toLowerCase().contains('lang producerende') == true
      ? 'Hoge opbrengst'
      : blob.contains('beperkte opbrengst') || blob.contains('weinig')
          ? 'Beperkte opbrengst'
          : 'Gemiddelde opbrengst';

  if (v.id.contains('komkommer')) {
    return (level, '10–20 komkommers per plant');
  }
  if (v.id.contains('courgette') || v.id.contains('patisson')) {
    return (level, 'Regelmatig jong plukken voor doorproductie');
  }
  if (v.id.contains('tomaat')) {
    return (level, 'Veel vruchten per plant bij goede verzorging');
  }
  if (v.harvestTips.trim().isNotEmpty) {
    return (level, _firstSentence(v.harvestTips));
  }
  return (level, v.summary.trim().isNotEmpty ? _firstSentence(v.summary) : '—');
}

String _shortSummary(String summary, String? companionGlance) {
  final source = (companionGlance?.trim().isNotEmpty == true)
      ? companionGlance!.trim()
      : summary.trim();
  if (source.isEmpty) {
    return 'Bekijk de teeltinfo voor zaaien, standplaats en oogst.';
  }
  final lines = <String>[];
  var rest = source;
  while (rest.isNotEmpty && lines.length < 4) {
    final dot = rest.indexOf('.');
    if (dot > 0 && dot < 120) {
      lines.add(rest.substring(0, dot + 1).trim());
      rest = rest.substring(dot + 1).trim();
    } else {
      lines.add(
        rest.length > 140 ? '${rest.substring(0, 137).trim()}…' : rest,
      );
      break;
    }
  }
  return lines.join(' ');
}

List<String> _keyPoints(
  Vegetable v,
  MoestuinCompanionInfo? companion,
  PlantingSeasonAdvice? seasonAdvice,
) {
  final points = <String>[];
  final sun = v.sunRequirement.toLowerCase();
  if (sun.contains('zon')) points.add('Veel zon nodig');
  if (sun.contains('half')) points.add('Halfschaduw is oké');
  final w = classifyWater(v.water);
  if (w == WaterFilter.high) points.add('Regelmatig water geven');
  if (w == WaterFilter.low) points.add('Kan droge periodes verdragen');
  if (_difficultyLabel(v) == 'Makkelijk') {
    points.add('Geschikt voor beginners');
  }
  if (v.care.toLowerCase().contains('vorst') ||
      v.transplant.toLowerCase().contains('vorst') ||
      v.sowingOutdoors.toLowerCase().contains('ijsheiligen')) {
    points.add('Gevoelig voor vorst');
  }
  if (v.spacingCm <= 25 || v.care.toLowerCase().contains('pot')) {
    points.add('Geschikt voor potten');
  }
  if (v.growthCategory?.toLowerCase().contains('lang producerende') == true ||
      v.harvestTips.toLowerCase().contains('dooroogst') ||
      v.summary.toLowerCase().contains('productief')) {
    points.add('Hoge opbrengst');
  }
  if (v.care.toLowerCase().contains('beschut') ||
      v.sunRequirement.toLowerCase().contains('warm')) {
    points.add('Beschutte plek aanbevolen');
  }
  if (companion != null) {
    points.add('Nuttig in de moestuin');
    if (companion.benefits.any(
      (b) => b == CompanionBenefitKind.pollination,
    )) {
      points.add('Trekt bestuivers');
    }
  }
  if (seasonAdvice != null && seasonAdvice.shortLabel.trim().isNotEmpty) {
    points.add(seasonAdvice.shortLabel.trim());
  }
  if (points.isEmpty && v.harvestTips.trim().isNotEmpty) {
    points.add(_firstSentence(v.harvestTips));
  }
  return points.take(6).toList();
}

(String, String, String) _growthFacts(Vegetable v) {
  final cat = v.growthCategory?.toLowerCase() ?? '';
  String height;
  String width;
  String habit;

  if (cat.contains('boom') || cat.contains('fruit (boom)')) {
    height = '2–6 m (afhankelijk van ras)';
    width = '2–4 m';
    habit = 'Boom of struik';
  } else if (cat.contains('bes') || v.id.contains('braam') || v.id.contains('framboos')) {
    height = '1–2 m';
    width = '1–2 m';
    habit = 'Struik met scheuten';
  } else if (cat.contains('kruiden') || v.spacingCm <= 30) {
    height = '20–60 cm';
    width = '20–40 cm';
    habit = 'Kruid of laag gewas';
  } else if (v.spacingCm >= 80) {
    height = '80–200 cm';
    width = '${v.spacingCm}–${v.rowSpacingCm} cm';
    habit = 'Opgaand gewas';
  } else {
    height = '30–80 cm';
    width = '${v.spacingCm}–${v.rowSpacingCm} cm tussen planten';
    habit = cat.contains('snelle') ? 'Snelle groeier' : 'Recht opgaand';
  }

  if (v.id.contains('tomaat') ||
      v.id.contains('bonen') ||
      v.id.contains('erwt') ||
      v.id.contains('courgette')) {
    habit = 'Klimmend of rankend mogelijk';
  }

  return (height, width, habit);
}

(String, String, String, String) _bloomHarvestSummary(
  Vegetable v,
  MoestuinCompanionInfo? companion,
  Set<int> harvestMonths,
) {
  final harvestText = v.harvest.trim();
  final bloom = companion != null
      ? companion.whenToPlant
      : (_containsBloom(v) ? harvestText : '—');
  final harvest = companion == null ? harvestText : 'Niet van toepassing';
  final bee = companion != null ||
          v.keywords.any((k) => k.contains('bij')) ||
          v.growthCategory?.toLowerCase().contains('bloemen') == true
      ? 'Ja'
      : 'Soms';
  final color = companion != null
      ? 'Variabel (geel, oranje, paars)'
      : (_flowerColorGuess(v) ?? '—');
  return (bloom, harvest, color, bee);
}

bool _containsBloom(Vegetable v) {
  final t = '${v.harvest} ${v.summary} ${v.growthCategory}'.toLowerCase();
  return t.contains('bloei');
}

String? _flowerColorGuess(Vegetable v) {
  final t = '${v.summary} ${v.harvest} ${v.nameNl}'.toLowerCase();
  if (t.contains('wit')) return 'Wit';
  if (t.contains('geel')) return 'Geel';
  if (t.contains('rood') || t.contains('rode')) return 'Rood';
  if (t.contains('paars')) return 'Paars';
  if (t.contains('oranje')) return 'Oranje';
  return null;
}

String _didYouKnow(Vegetable v, MoestuinCompanionInfo? companion) {
  if (companion?.tip != null && companion!.tip!.trim().isNotEmpty) {
    return companion.tip!.trim();
  }
  final issues = v.commonIssues.trim();
  if (issues.isNotEmpty) {
    return _firstSentence(issues);
  }
  return _firstSentence(v.summary);
}

String _firstSentence(String text) {
  final t = text.trim();
  if (t.isEmpty) return '';
  final dot = t.indexOf('.');
  if (dot > 0 && dot < 160) return t.substring(0, dot + 1);
  return t.length > 120 ? '${t.substring(0, 117).trim()}…' : t;
}

Map<String, PlantSuitability> _locationSuitability(Vegetable v) {
  final blob =
      '${v.care} ${v.sowingIndoors} ${v.transplant} ${v.sunRequirement}'
          .toLowerCase();
  final sun = classifySun(v.sunRequirement);
  return {
    'Zon': sun == SunFilter.fullSun
        ? PlantSuitability.suitable
        : PlantSuitability.limited,
    'Halfschaduw': sun == SunFilter.partialShade
        ? PlantSuitability.suitable
        : PlantSuitability.limited,
    'Schaduw': sun == SunFilter.shade
        ? PlantSuitability.suitable
        : PlantSuitability.notRecommended,
    'Pot': blob.contains('pot') || v.spacingCm <= 35
        ? PlantSuitability.suitable
        : PlantSuitability.limited,
    'Kas': blob.contains('kas') || blob.contains('tunnel')
        ? PlantSuitability.suitable
        : PlantSuitability.limited,
    'Balkon': v.spacingCm <= 40 && !blob.contains('boom')
        ? PlantSuitability.suitable
        : PlantSuitability.limited,
    'Volle grond': blob.contains('pot alleen')
        ? PlantSuitability.limited
        : PlantSuitability.suitable,
  };
}

List<PlantInfoCategoryContent> _buildCategories({
  required Vegetable vegetable,
  required MoestuinCompanionInfo? companion,
  required Set<int> sowMonths,
  required Set<int> plantMonths,
  required Set<int> harvestMonths,
}) {
  final v = vegetable;
  final sowTimeline = PlantMonthTimeline(label: 'Zaaien', months: sowMonths);
  final plantTimeline =
      PlantMonthTimeline(label: 'Uitplanten', months: plantMonths);
  final harvestTimeline = PlantMonthTimeline(
    label: companion != null ? 'Bloei' : 'Oogst',
    months: harvestMonths,
  );
  final sowingGuide = sowingGuideForVegetable(v);
  final transplantGuide = transplantGuideForVegetable(v);
  final locationGuide = locationGuideForVegetable(v);
  final waterGuide = waterGuideForVegetable(v);
  final nutritionGuide = nutritionGuideForVegetable(v);
  final growthGuide = growthGuideForVegetable(v);
  final bloomGuide = bloomGuideForVegetable(v);
  final harvestGuide = harvestGuideForVegetable(v);
  final careGuide = careGuideForVegetable(v);
  final problemsGuide = problemsGuideForVegetable(v);
  final combinationGuide = combinationGuideForVegetable(v);
  final weetjesGuide = weetjesGuideForVegetable(v);

  return [
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.zaaien,
      blocks: const [],
      sowingGuide: sowingGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.uitplanten,
      blocks: const [],
      transplantGuide: transplantGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.standplaats,
      blocks: const [],
      locationGuide: locationGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.water,
      blocks: const [],
      waterGuide: waterGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.voeding,
      blocks: const [],
      nutritionGuide: nutritionGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.groei,
      blocks: const [],
      growthGuide: growthGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.bloei,
      blocks: const [],
      bloomGuide: bloomGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.oogsten,
      blocks: const [],
      harvestGuide: harvestGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.verzorging,
      blocks: const [],
      careGuide: careGuide,
    ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.problemen,
      blocks: const [],
      problemsGuide: problemsGuide,
    ),
    if (!kMushroomPlantIds.contains(v.id))
      PlantInfoCategoryContent(
        id: PlantInfoCategoryId.combinatieteelt,
        blocks: const [],
        combinationGuide: combinationGuide,
      ),
    PlantInfoCategoryContent(
      id: PlantInfoCategoryId.weetjes,
      blocks: const [],
      weetjesGuide: weetjesGuide,
    ),
  ];
}

bool _has(String? value) {
  if (value == null) return false;
  final t = value.trim();
  return t.isNotEmpty &&
      t != '—' &&
      t != '-' &&
      !t.toLowerCase().contains('zie kalender in de app');
}
