import 'package:flutter/material.dart';

import '../models/vegetable.dart';
import 'moestuin_companion_info.dart';
import 'plant_bloom_guide.dart';
import 'plant_encyclopedia_layout.dart';
import 'plant_search_filters.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';

part 'flower_overview_facts_map.dart';

/// Reden om deze bloem te planten (icoon + korte tekst).
class FlowerWhyPlantReason {
  const FlowerWhyPlantReason({
    this.imageAsset,
    this.icon,
    required this.label,
  });

  final String? imageAsset;
  final IconData? icon;
  final String label;
}

/// Bestuivers-waardering 0–5 sterren.
class FlowerPollinatorRatings {
  const FlowerPollinatorRatings({
    required this.bees,
    required this.butterflies,
    required this.bumblebees,
    required this.hoverflies,
  });

  final int bees;
  final int butterflies;
  final int bumblebees;
  final int hoverflies;
}

/// Kalenderrij met accentkleur voor bloemen-overzicht.
class FlowerCalendarMoment {
  const FlowerCalendarMoment({
    required this.timeline,
    required this.accentColor,
    this.imageAsset,
    this.icon,
  });

  final PlantMonthTimeline timeline;
  final Color accentColor;
  final String? imageAsset;
  final IconData? icon;
}

/// Geschikt-voor optie (border, pot, tuintype).
class FlowerSuitableOption {
  const FlowerSuitableOption({
    this.imageAsset,
    this.icon,
    required this.label,
  });

  final String? imageAsset;
  final IconData? icon;
  final String label;
}

/// Alle gegevens voor het bloemen-overzicht-tabblad.
class FlowerOverviewLayout {
  const FlowerOverviewLayout({
    required this.vegetableId,
    required this.nameNl,
    required this.standplaats,
    this.standplaatsSubtitle,
    required this.water,
    this.waterSubtitle,
    required this.difficulty,
    this.difficultySubtitle,
    required this.lifespan,
    this.lifespanSubtitle,
    required this.summary,
    required this.whyPlantReasons,
    required this.pollinatorRatings,
    required this.height,
    required this.width,
    required this.bloomPeriod,
    required this.bloomDuration,
    required this.calendarMoments,
    required this.flowerColors,
    required this.fragrance,
    required this.winterHardy,
    this.winterHardyDetail,
    required this.droughtResistant,
    this.droughtResistantDetail,
    required this.suitableFor,
    required this.keyFeatures,
    required this.tip,
  });

  final String vegetableId;
  final String nameNl;
  final String standplaats;
  final String? standplaatsSubtitle;
  final String water;
  final String? waterSubtitle;
  final String difficulty;
  final String? difficultySubtitle;
  final String lifespan;
  final String? lifespanSubtitle;
  final String summary;
  final List<FlowerWhyPlantReason> whyPlantReasons;
  final FlowerPollinatorRatings pollinatorRatings;
  final String height;
  final String width;
  final String bloomPeriod;
  final String bloomDuration;
  final List<FlowerCalendarMoment> calendarMoments;
  final List<Color> flowerColors;
  final String fragrance;
  final bool winterHardy;
  final String? winterHardyDetail;
  final bool droughtResistant;
  final String? droughtResistantDetail;
  final List<FlowerSuitableOption> suitableFor;
  final List<String> keyFeatures;
  final String tip;
}

FlowerOverviewLayout buildFlowerOverviewLayout(Vegetable vegetable) {
  final base = buildPlantEncyclopediaLayout(vegetable: vegetable);
  final companion = moestuinCompanionInfoForVegetable(vegetable);
  final bloomGuide = bloomGuideForVegetable(vegetable);
  final activities = calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  );
  final override = _kFlowerFacts[vegetable.id];

  final standplaats = override?.standplaats ?? _flowerStandplaats(vegetable, base);
  final standplaatsSubtitle =
      override?.standplaatsSubtitle ?? _sunSubtitle(vegetable.sunRequirement);
  final water = override?.water ?? _flowerWater(base.water, vegetable);
  final waterSubtitle =
      override?.waterSubtitle ?? _waterSubtitle(vegetable.water);
  final difficulty = override?.difficulty ?? base.difficulty;
  final difficultySubtitle = override?.difficultySubtitle ??
      (difficulty == 'Makkelijk' ? 'Geschikt voor beginners' : null);
  final lifespan = override?.lifespan ?? _flowerLifespan(base.lifespan, vegetable);
  final lifespanSubtitle =
      override?.lifespanSubtitle ?? _lifespanSubtitle(vegetable, lifespan);

  final summary = override?.summary ??
      (companion?.atAGlance.trim().isNotEmpty == true
          ? companion!.atAGlance
          : base.summaryShort);

  final whyPlant = override?.whyPlantReasons ??
      _defaultWhyPlantReasons(vegetable, companion);
  final pollinators = override?.pollinatorRatings ??
      _inferPollinatorRatings(vegetable, companion);
  final height = override?.height ?? base.height;
  final width = override?.width ?? base.width;
  final bloomPeriod =
      override?.bloomPeriod ?? _bloomPeriodLabel(vegetable, base, companion);
  final bloomDuration =
      override?.bloomDuration ?? _bloomDurationLabel(vegetable, bloomGuide);

  final calendar = override?.calendarMoments ??
      _buildCalendarMoments(vegetable, activities, base, companion, bloomGuide);

  final colors = override?.flowerColors ??
      _inferFlowerColors(vegetable.id, base.flowerColor);
  final fragrance =
      override?.fragrance ?? _inferFragrance(vegetable);
  final winterHardy = override?.winterHardy ?? _isWinterHardy(vegetable);
  final winterDetail = override?.winterHardyDetail ??
      (winterHardy ? 'Ja, tot ca. -15 °C' : 'Nee, bescherm of herplant');
  final droughtResistant =
      override?.droughtResistant ?? _isDroughtResistant(vegetable);
  final droughtDetail = override?.droughtResistantDetail ??
      (droughtResistant ? 'Ja, verdraagt droge perioden' : 'Nee, regelmatig water');

  final suitable = override?.suitableFor ??
      _defaultSuitableFor(vegetable);
  final features = override?.keyFeatures ??
      _defaultKeyFeatures(vegetable, companion, pollinators);
  final tip = override?.tip ??
      companion?.tip ??
      _defaultTip(vegetable, companion);

  return FlowerOverviewLayout(
    vegetableId: vegetable.id,
    nameNl: vegetable.nameNl,
    standplaats: standplaats,
    standplaatsSubtitle: standplaatsSubtitle,
    water: water,
    waterSubtitle: waterSubtitle,
    difficulty: difficulty,
    difficultySubtitle: difficultySubtitle,
    lifespan: lifespan,
    lifespanSubtitle: lifespanSubtitle,
    summary: summary,
    whyPlantReasons: whyPlant,
    pollinatorRatings: pollinators,
    height: height,
    width: width,
    bloomPeriod: bloomPeriod,
    bloomDuration: bloomDuration,
    calendarMoments: calendar,
    flowerColors: colors,
    fragrance: fragrance,
    winterHardy: winterHardy,
    winterHardyDetail: winterDetail,
    droughtResistant: droughtResistant,
    droughtResistantDetail: droughtDetail,
    suitableFor: suitable,
    keyFeatures: features,
    tip: tip,
  );
}

// ——— Defaults ———

String _flowerStandplaats(Vegetable v, PlantEncyclopediaLayout base) {
  switch (classifySun(v.sunRequirement)) {
    case SunFilter.fullSun:
      return 'Volle zon';
    case SunFilter.partialShade:
      return 'Halfschaduw';
    case SunFilter.shade:
      return 'Schaduw';
  }
}

String _sunSubtitle(String sunRequirement) {
  switch (classifySun(sunRequirement)) {
    case SunFilter.fullSun:
      return '6+ uur zon per dag';
    case SunFilter.partialShade:
      return '3–6 uur zon per dag';
    case SunFilter.shade:
      return 'Weinig direct zonlicht';
  }
}

String _flowerWater(String baseWater, Vegetable v) {
  switch (classifyWater(v.water)) {
    case WaterFilter.low:
      return 'Weinig';
    case WaterFilter.medium:
      return 'Gemiddeld';
    case WaterFilter.high:
      return 'Veel';
  }
}

String _waterSubtitle(String water) {
  final t = water.toLowerCase();
  if (t.contains('weinig') ||
      t.contains('droog') ||
      t.contains('tussen gietbeurten')) {
    return 'Geef pas water als de grond droog is';
  }
  if (t.contains('vochtig') || t.contains('regelmatig')) {
    return 'Houd de grond gelijkmatig vochtig';
  }
  return 'Pas aan op weer en standplaats';
}

String _flowerLifespan(String base, Vegetable v) {
  final cat = v.growthCategory?.toLowerCase() ?? '';
  if (cat.contains('meerjarig') ||
      v.keywords.any((k) => k.contains('meerjarig'))) {
    return 'Vaste plant';
  }
  if (base == 'Tweejarig') return 'Tweejarig';
  return 'Eenjarig';
}

String? _lifespanSubtitle(Vegetable v, String lifespan) {
  if (lifespan == 'Vaste plant') {
    return 'Winterhard en komt elk jaar terug';
  }
  if (lifespan == 'Eenjarig') {
    return 'Bloeit één seizoen, zaai opnieuw';
  }
  if (lifespan == 'Tweejarig') {
    return 'Bloeit vaak in het tweede jaar';
  }
  return null;
}

String _bloomPeriodLabel(
  Vegetable v,
  PlantEncyclopediaLayout base,
  MoestuinCompanionInfo? companion,
) {
  if (companion != null) {
    final months = _monthsFromText(companion.whenToPlant);
    if (months.isNotEmpty) {
      return formatPlantMonthRange(months);
    }
  }
  final fromHarvest = _monthsFromText(v.harvest);
  if (fromHarvest.isNotEmpty) {
    return formatPlantMonthRange(fromHarvest);
  }
  if (base.bloomPeriod.trim().isNotEmpty && base.bloomPeriod != '—') {
  final cleaned = base.bloomPeriod.replaceAll(RegExp(r'.*bloei\s*'), '');
    if (cleaned.trim().isNotEmpty) return cleaned.trim();
  }
  return 'Juni–september';
}

String _bloomDurationLabel(Vegetable v, PlantBloomGuide bloomGuide) {
  final blob = '${v.care} ${v.summary} ${v.harvest}'.toLowerCase();
  if (blob.contains('lang') || blob.contains('doorbloei')) return 'Lang';
  if (blob.contains('kort') || v.growthCategory?.contains('snelle') == true) {
    return 'Kort';
  }
  if (v.growthCategory?.toLowerCase().contains('meerjarig') == true) {
    return 'Lang';
  }
  return 'Gemiddeld';
}

List<FlowerWhyPlantReason> _defaultWhyPlantReasons(
  Vegetable v,
  MoestuinCompanionInfo? companion,
) {
  final reasons = <FlowerWhyPlantReason>[];
  if (companion != null) {
    for (final benefit in companion.benefits) {
      reasons.add(FlowerWhyPlantReason(
        imageAsset: _benefitAsset(benefit),
        label: _benefitLabel(benefit, companion),
      ));
    }
  }
  if (reasons.isEmpty) {
    reasons.add(const FlowerWhyPlantReason(
      imageAsset: 'assets/images/combination/combo_benefits.png',
      label: 'Verrijkt de moestuin met kleur en biodiversiteit',
    ));
  }
  final text = '${v.summary} ${v.care}'.toLowerCase();
  if (text.contains('geur') &&
      !reasons.any((r) => r.label.toLowerCase().contains('geur'))) {
    reasons.add(const FlowerWhyPlantReason(
      icon: Icons.spa_outlined,
      label: 'Aangename geur in de tuin',
    ));
  }
  return reasons.take(4).toList();
}

String _benefitAsset(CompanionBenefitKind kind) {
  switch (kind) {
    case CompanionBenefitKind.pestControl:
      return 'assets/images/combination/combo_pest_plants.png';
    case CompanionBenefitKind.pollination:
      return 'assets/images/bloom/bloom_pollinator_bee.png';
    case CompanionBenefitKind.soilHealth:
      return 'assets/images/combination/combo_soil_improvers.png';
    case CompanionBenefitKind.biodiversity:
      return 'assets/images/combination/combo_pollinators.png';
  }
}

String _benefitLabel(
  CompanionBenefitKind kind,
  MoestuinCompanionInfo companion,
) {
  switch (kind) {
    case CompanionBenefitKind.pestControl:
      return 'Helpt plagen af te schrikken';
    case CompanionBenefitKind.pollination:
      return 'Trekt bestuivers voor betere oogst';
    case CompanionBenefitKind.soilHealth:
      return 'Verbetert bodem en voedingsweb';
    case CompanionBenefitKind.biodiversity:
      return 'Verhoogt biodiversiteit in de tuin';
  }
}

FlowerPollinatorRatings _inferPollinatorRatings(
  Vegetable v,
  MoestuinCompanionInfo? companion,
) {
  final text =
      '${v.summary} ${v.care} ${v.harvest} ${companion?.atAGlance ?? ''}'
          .toLowerCase();
  var bees = 2;
  var butterflies = 2;
  var bumblebees = 2;
  var hoverflies = 2;

  if (companion?.benefits.contains(CompanionBenefitKind.pollination) == true) {
    bees += 2;
    bumblebees += 1;
  }
  if (companion?.benefits.contains(CompanionBenefitKind.biodiversity) == true) {
    butterflies += 1;
  }
  if (text.contains('bij')) bees += 2;
  if (text.contains('vlinder')) butterflies += 2;
  if (text.contains('hommel')) bumblebees += 2;
  if (text.contains('zweefvlieg')) hoverflies += 2;
  if (text.contains('bestui')) {
    bees += 1;
    bumblebees += 1;
  }
  if (isFlowerGuidePlant(v.id)) {
    bees += 1;
    butterflies += 1;
  }

  return FlowerPollinatorRatings(
    bees: bees.clamp(0, 5),
    butterflies: butterflies.clamp(0, 5),
    bumblebees: bumblebees.clamp(0, 5),
    hoverflies: hoverflies.clamp(0, 5),
  );
}

List<FlowerCalendarMoment> _buildCalendarMoments(
  Vegetable v,
  List<VegetableMonthActivity> activities,
  PlantEncyclopediaLayout base,
  MoestuinCompanionInfo? companion,
  PlantBloomGuide bloomGuide,
) {
  final preSow = _monthsForTypes(activities, {GardenTaskType.preSow});
  final sowOut = _monthsForTypes(activities, {GardenTaskType.sowOutdoors});
  final plantOut =
      _monthsForTypes(activities, {GardenTaskType.plantOutdoors});
  final harvest = _monthsForTypes(activities, {GardenTaskType.harvest});

  final sowIndoors = preSow.isNotEmpty
      ? preSow
      : _monthsFromText(v.sowingIndoors);
  final sowMonths = sowIndoors.isNotEmpty ? sowIndoors : sowOut;

  Set<int> bloomMonths = base.bloom?.months ?? {};
  if (bloomMonths.isEmpty) {
    bloomMonths = _monthsFromText(companion?.whenToPlant ?? '');
  }
  if (bloomMonths.isEmpty) {
    bloomMonths = _monthsFromText(v.harvest);
  }
  final bloom = bloomMonths.isNotEmpty ? bloomMonths : {6, 7, 8, 9};

  final seedHarvest = harvest.isNotEmpty
      ? harvest
      : _seedHarvestMonths(bloom);

  return [
    FlowerCalendarMoment(
      timeline: PlantMonthTimeline(
        label: sowIndoors.isNotEmpty ? 'Zaaien (binnen)' : 'Zaaien',
        months: sowMonths.isNotEmpty ? sowMonths : {3, 4},
      ),
      accentColor: const Color(0xFF43A047),
      imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      icon: Icons.eco_outlined,
    ),
    FlowerCalendarMoment(
      timeline: PlantMonthTimeline(
        label: 'Uitplanten',
        months: plantOut.isNotEmpty ? plantOut : base.planting.months,
      ),
      accentColor: const Color(0xFF2E7D32),
      imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      icon: Icons.yard_outlined,
    ),
    FlowerCalendarMoment(
      timeline: PlantMonthTimeline(label: 'Bloei', months: bloom),
      accentColor: const Color(0xFF7B1FA2),
      imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      icon: Icons.local_florist_outlined,
    ),
    FlowerCalendarMoment(
      timeline: PlantMonthTimeline(
        label: 'Zaadoogst',
        months: seedHarvest,
      ),
      accentColor: const Color(0xFFF57C00),
      imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      icon: Icons.grass_outlined,
    ),
  ];
}

Set<int> _seedHarvestMonths(Set<int> bloomMonths) {
  if (bloomMonths.isEmpty) return {9, 10};
  final max = bloomMonths.reduce((a, b) => a > b ? a : b);
  final out = <int>{};
  for (var m = max + 1; m <= 11; m++) {
    out.add(m);
  }
  if (out.isEmpty) return {10, 11};
  return out;
}

List<Color> _inferFlowerColors(String id, String colorText) {
  final fromOverride = _kFlowerColorHints[id];
  if (fromOverride != null) return fromOverride;

  final t = colorText.toLowerCase();
  final colors = <Color>[];
  if (t.contains('geel') || id.contains('goud') || id.contains('zonne')) {
    colors.add(const Color(0xFFFFC107));
  }
  if (t.contains('oranje') || id.contains('afrikaan') || id.contains('tagetes')) {
    colors.add(const Color(0xFFFF9800));
  }
  if (t.contains('rood') || id.contains('klaproos') || id.contains('zinnia')) {
    colors.add(const Color(0xFFE53935));
  }
  if (t.contains('paars') || id.contains('lavendel') || id.contains('monarda')) {
    colors.add(const Color(0xFF7B1FA2));
  }
  if (t.contains('roze') || id.contains('cosmos')) {
    colors.add(const Color(0xFFF48FB1));
  }
  if (t.contains('wit') || id.contains('alyssum') || id.contains('klaver')) {
    colors.add(const Color(0xFFF5F5F5));
  }
  if (t.contains('blauw') || id.contains('korenbloem') || id.contains('verbena')) {
    colors.add(const Color(0xFF42A5F5));
  }
  if (colors.isEmpty) {
    return const [
      Color(0xFFFFC107),
      Color(0xFFFF9800),
      Color(0xFFE53935),
    ];
  }
  return colors;
}

String _inferFragrance(Vegetable v) {
  final t = '${v.summary} ${v.care} ${v.id}'.toLowerCase();
  if (t.contains('lavendel') ||
      t.contains('geur') ||
      t.contains('salie') ||
      t.contains('tijm') ||
      t.contains('munt') ||
      t.contains('basilicum') ||
      t.contains('dille') ||
      t.contains('koriander')) {
    return 'Heerlijk geurend';
  }
  if (t.contains('afrikaan') || t.contains('tagetes')) {
    return 'Sterk geurend';
  }
  return 'Licht geurend of neutraal';
}

bool _isWinterHardy(Vegetable v) {
  final cat = v.growthCategory?.toLowerCase() ?? '';
  final blob = '${v.care} ${v.keywords.join(' ')}'.toLowerCase();
  if (cat.contains('meerjarig') ||
      blob.contains('meerjarig') ||
      blob.contains('vaste plant') ||
      blob.contains('winterhard')) {
    return true;
  }
  return false;
}

bool _isDroughtResistant(Vegetable v) {
  final t = '${v.water} ${v.care} ${v.summary}'.toLowerCase();
  return classifyWater(v.water) == WaterFilter.low ||
      t.contains('droog') ||
      t.contains('droogtolerant') ||
      v.id.contains('lavendel') ||
      v.id.contains('tijm') ||
      v.id.contains('salie') ||
      v.id.contains('rozemarijn');
}

List<FlowerSuitableOption> _defaultSuitableFor(Vegetable v) {
  final text = '${v.care} ${v.summary} ${v.sowingIndoors}'.toLowerCase();
  final options = <FlowerSuitableOption>[
    const FlowerSuitableOption(
      imageAsset: 'assets/images/location/location_open_ground.png',
      label: 'Border',
    ),
    const FlowerSuitableOption(
      imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
      label: 'Bijentuin',
    ),
    const FlowerSuitableOption(
      imageAsset: 'assets/images/combination/combo_benefits.png',
      label: 'Natuurtuin',
    ),
  ];
  if (text.contains('pot') ||
      v.spacingCm <= 35 ||
      v.id.contains('munt') ||
      v.id.contains('alyssum') ||
      v.id.contains('tagetes')) {
    options.insert(
      1,
      const FlowerSuitableOption(
        imageAsset: 'assets/images/location/location_pot.png',
        label: 'Pot',
      ),
    );
  }
  if (v.id.contains('zonnebloem') ||
      v.id.contains('cosmos') ||
      v.id.contains('zinnia') ||
      v.id.contains('goudsbloem') ||
      v.id.contains('lavendel')) {
    options.add(const FlowerSuitableOption(
      imageAsset: 'assets/images/harvest/harvest_basket.png',
      label: 'Pluktuin',
    ));
  }
  if (v.id.contains('vlinder') ||
      text.contains('vlinder') ||
      v.id.contains('cosmos') ||
      v.id.contains('verbena') ||
      v.id.contains('zonnehoed')) {
    options.add(const FlowerSuitableOption(
      imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
      label: 'Vlindertuin',
    ));
  }
  return options.take(6).toList();
}

List<String> _defaultKeyFeatures(
  Vegetable v,
  MoestuinCompanionInfo? companion,
  FlowerPollinatorRatings ratings,
) {
  final features = <String>[];
  if (ratings.bees >= 4) {
    features.add('Zeer aantrekkelijk voor bijen');
  } else if (ratings.bees >= 3) {
    features.add('Trekt bijen en bestuivers');
  }
  if (companion?.benefits.contains(CompanionBenefitKind.pestControl) == true) {
    features.add('Helpt plagen in de buurt te verminderen');
  }
  if (_isWinterHardy(v)) {
    features.add('Winterhard en meerjarig');
  }
  if (_isDroughtResistant(v)) {
    features.add('Verdraagt droogte goed');
  }
  if (classifySun(v.sunRequirement) == SunFilter.fullSun) {
    features.add('Houdt van een zonnige plek');
  }
  if (features.length < 3) {
    features.add('Eenvoudig te kweken in de moestuin');
  }
  if (features.length < 4) {
    features.add('Verrijkt borders en combinatieteelt');
  }
  return features.take(5).toList();
}

String _defaultTip(Vegetable v, MoestuinCompanionInfo? companion) {
  if (v.harvestTips.trim().isNotEmpty) {
    return v.harvestTips.trim();
  }
  if (v.care.trim().isNotEmpty) {
    return v.care.trim();
  }
  if (companion != null && companion.goodNearLabels.isNotEmpty) {
    return 'Plant bij ${companion.goodNearLabels.take(3).join(', ')} voor het beste effect.';
  }
  return 'Verwijder uitgebloeide bloemen voor langere bloei en gezondere planten.';
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

Set<int> _monthsFromText(String text) {
  const map = {
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
  final t = text.toLowerCase();
  final out = <int>{};
  for (final e in map.entries) {
    if (t.contains(e.key)) out.add(e.value);
  }
  return out;
}

// ——— Per-flower kleurhints ———

const Map<String, List<Color>> _kFlowerColorHints = {
  'lavendel': [
    Color(0xFF7B1FA2),
    Color(0xFF7986CB),
    Color(0xFFF48FB1),
    Color(0xFFF5F5F5),
  ],
  'zonnebloem': [Color(0xFFFFC107), Color(0xFFFF9800)],
  'goudsbloem': [Color(0xFFFF9800), Color(0xFFFFC107)],
  'cosmos': [Color(0xFFF48FB1), Color(0xFFE53935), Color(0xFFF5F5F5)],
  'afrikaantje': [Color(0xFFFF9800), Color(0xFFE53935), Color(0xFFFFC107)],
  'tagetes_patula': [Color(0xFFFF9800), Color(0xFFE53935)],
  'zinnia': [Color(0xFFE53935), Color(0xFFFF9800), Color(0xFFF48FB1)],
  'korenbloem': [Color(0xFF42A5F5), Color(0xFF7B1FA2)],
  'monarda': [Color(0xFFE53935), Color(0xFF7B1FA2)],
  'alyssum_sneeuw': [Color(0xFFF5F5F5), Color(0xFFE1BEE7)],
  'witte_klaver': [Color(0xFFF5F5F5)],
  'rode_klaver': [Color(0xFFE53935), Color(0xFFFF5252)],
};

// ——— Per-flower overrides ———

class _FlowerFacts {
  const _FlowerFacts({
    this.standplaats,
    this.standplaatsSubtitle,
    this.water,
    this.waterSubtitle,
    this.difficulty,
    this.difficultySubtitle,
    this.lifespan,
    this.lifespanSubtitle,
    this.summary,
    this.whyPlantReasons,
    this.pollinatorRatings,
    this.height,
    this.width,
    this.bloomPeriod,
    this.bloomDuration,
    this.calendarMoments,
    this.flowerColors,
    this.fragrance,
    this.winterHardy,
    this.winterHardyDetail,
    this.droughtResistant,
    this.droughtResistantDetail,
    this.suitableFor,
    this.keyFeatures,
    this.tip,
  });

  final String? standplaats;
  final String? standplaatsSubtitle;
  final String? water;
  final String? waterSubtitle;
  final String? difficulty;
  final String? difficultySubtitle;
  final String? lifespan;
  final String? lifespanSubtitle;
  final String? summary;
  final List<FlowerWhyPlantReason>? whyPlantReasons;
  final FlowerPollinatorRatings? pollinatorRatings;
  final String? height;
  final String? width;
  final String? bloomPeriod;
  final String? bloomDuration;
  final List<FlowerCalendarMoment>? calendarMoments;
  final List<Color>? flowerColors;
  final String? fragrance;
  final bool? winterHardy;
  final String? winterHardyDetail;
  final bool? droughtResistant;
  final String? droughtResistantDetail;
  final List<FlowerSuitableOption>? suitableFor;
  final List<String>? keyFeatures;
  final String? tip;
}

const _suitableFull = [
  FlowerSuitableOption(
    imageAsset: 'assets/images/location/location_open_ground.png',
    label: 'Border',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/location/location_pot.png',
    label: 'Pot',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/harvest/harvest_basket.png',
    label: 'Pluktuin',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
    label: 'Vlindertuin',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
    label: 'Bijentuin',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/combination/combo_benefits.png',
    label: 'Natuurtuin',
  ),
];

const _suitableMoestuinRand = [
  FlowerSuitableOption(
    imageAsset: 'assets/images/location/location_open_ground.png',
    label: 'Border',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/location/location_pot.png',
    label: 'Pot',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/combination/combo_pest_plants.png',
    label: 'Moestuinrand',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
    label: 'Bijentuin',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/combination/combo_benefits.png',
    label: 'Natuurtuin',
  ),
];

const _suitableGreenManure = [
  FlowerSuitableOption(
    imageAsset: 'assets/images/location/location_open_ground.png',
    label: 'Border',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/combination/combo_soil_improvers.png',
    label: 'Groenbemester',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
    label: 'Bijentuin',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/combination/combo_benefits.png',
    label: 'Natuurtuin',
  ),
];

const _suitablePotBee = [
  FlowerSuitableOption(
    imageAsset: 'assets/images/location/location_pot.png',
    label: 'Pot',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
    label: 'Bijentuin',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/combination/combo_benefits.png',
    label: 'Natuurtuin',
  ),
  FlowerSuitableOption(
    imageAsset: 'assets/images/location/location_open_ground.png',
    label: 'Border',
  ),
];
