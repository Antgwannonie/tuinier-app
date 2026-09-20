import '../models/vegetable.dart';
import '../models/vegetable_group.dart';
import 'moestuin_companion_plants.dart';
import 'planting_calendar.dart';
import 'underground_crop.dart';
import 'vegetable_groups.dart';
import 'vegetable_repository.dart';

/// Soort-filter op het zoekscherm (voorheen Soort + Verzameling samengevoegd).
enum PlantBrowseKind {
  all,
  groente,
  flowersPlants,
  fruitTrees,
  herbs,
  legumes,
  mushrooms,
  companionGarden,
  other;

  String get label {
    switch (this) {
      case PlantBrowseKind.all:
        return 'Alles';
      case PlantBrowseKind.groente:
        return 'Groente';
      case PlantBrowseKind.flowersPlants:
        return 'Bloemen & planten';
      case PlantBrowseKind.fruitTrees:
        return 'Fruit & bomen';
      case PlantBrowseKind.herbs:
        return 'Kruiden';
      case PlantBrowseKind.legumes:
        return 'Peulvruchten';
      case PlantBrowseKind.mushrooms:
        return 'Paddestoelen';
      case PlantBrowseKind.companionGarden:
        return 'Tegen plagen & bijen';
      case PlantBrowseKind.other:
        return 'Overig';
    }
  }

  String get emoji {
    switch (this) {
      case PlantBrowseKind.companionGarden:
        return '🐞';
      case PlantBrowseKind.flowersPlants:
        return '🌸';
      case PlantBrowseKind.herbs:
        return '🌿';
      case PlantBrowseKind.fruitTrees:
        return '🍎';
      case PlantBrowseKind.legumes:
        return '🫛';
      case PlantBrowseKind.mushrooms:
        return '🍄';
      case PlantBrowseKind.groente:
        return '🥬';
      default:
        return '';
    }
  }
}

enum SunFilter {
  fullSun,
  partialShade,
  shade;

  String get label {
    switch (this) {
      case SunFilter.fullSun:
        return 'Veel zon';
      case SunFilter.partialShade:
        return 'Halfschaduw';
      case SunFilter.shade:
        return 'Schaduw';
    }
  }

  String get emoji {
    switch (this) {
      case SunFilter.fullSun:
        return '☀️';
      case SunFilter.partialShade:
        return '🌤';
      case SunFilter.shade:
        return '🌑';
    }
  }
}

enum WaterFilter {
  high,
  medium,
  low;

  String get label {
    switch (this) {
      case WaterFilter.high:
        return 'Veel water';
      case WaterFilter.medium:
        return 'Gemiddeld';
      case WaterFilter.low:
        return 'Weinig';
    }
  }

  String get emoji => '💧';
}

enum SeasonFilter {
  spring,
  summer,
  autumn;

  String get label {
    switch (this) {
      case SeasonFilter.spring:
        return 'Voorjaar';
      case SeasonFilter.summer:
        return 'Zomer';
      case SeasonFilter.autumn:
        return 'Herfst';
    }
  }

  String get emoji => '📅';
}

enum PlantHabitFilter {
  climber,
  nonClimber;

  String get label {
    switch (this) {
      case PlantHabitFilter.climber:
        return 'Klimmers';
      case PlantHabitFilter.nonClimber:
        return 'Geen klimmer';
    }
  }

  String get emoji {
    switch (this) {
      case PlantHabitFilter.climber:
        return '🪜';
      case PlantHabitFilter.nonClimber:
        return '🌱';
    }
  }
}

/// Plantafstand voor bakplanning.
enum SpacingFilter {
  compact,
  medium,
  wide;

  String get label {
    switch (this) {
      case SpacingFilter.compact:
        return 'Compact (≤ 20 cm)';
      case SpacingFilter.medium:
        return 'Gemiddeld (21–40 cm)';
      case SpacingFilter.wide:
        return 'Ruim (> 40 cm)';
    }
  }

  String get emoji {
    switch (this) {
      case SpacingFilter.compact:
        return '▫️';
      case SpacingFilter.medium:
        return '◻️';
      case SpacingFilter.wide:
        return '⬜';
    }
  }

  bool matches(int spacingCm) {
    switch (this) {
      case SpacingFilter.compact:
        return spacingCm <= 20;
      case SpacingFilter.medium:
        return spacingCm >= 21 && spacingCm <= 40;
      case SpacingFilter.wide:
        return spacingCm > 40;
    }
  }
}

enum PlantGrowthSpeedFilter {
  fast,
  medium,
  long;

  String get label {
    switch (this) {
      case PlantGrowthSpeedFilter.fast:
        return 'Snel oogstrijp (≤45 d)';
      case PlantGrowthSpeedFilter.medium:
        return 'Gemiddeld (46–80 d)';
      case PlantGrowthSpeedFilter.long:
        return 'Langzaam (>80 d)';
    }
  }

  String get emoji => '⏱️';
}

/// Korte maandnamen voor zaai-filters.
const List<String> kSowingMonthShortLabels = [
  '',
  'jan',
  'feb',
  'mrt',
  'apr',
  'mei',
  'jun',
  'jul',
  'aug',
  'sep',
  'okt',
  'nov',
  'dec',
];

enum PlantHarvestLocationFilter {
  underground,
  aboveGround;

  String get label {
    switch (this) {
      case PlantHarvestLocationFilter.underground:
        return 'Ondergronds';
      case PlantHarvestLocationFilter.aboveGround:
        return 'Bovengronds';
    }
  }

  String get emoji {
    switch (this) {
      case PlantHarvestLocationFilter.underground:
        return '🥔';
      case PlantHarvestLocationFilter.aboveGround:
        return '🥬';
    }
  }
}

/// Volgorde verzamelgroepen in het filterpaneel (plantengids).
const List<String> kPlantGuideVegetableGroupFilterOrder = [
  'tomaten',
  'paprika_peper',
  'komkommer_familie',
  'bonen',
  'wortelgroenten',
  'bieten',
  'kolen',
  'bladgroenten',
  'sla_soorten',
  'uien',
  'aardappel',
  'aubergine',
  'mais',
  'meloenen',
  'meerjarig',
  'aziatische_groenten',
  'kruiden',
  'moestuin_bloemen',
  'bloemen_zaden',
  'fruit_bomen',
  'bessen',
  'paddestoelen',
];

const Map<String, String> kVegetableGroupFilterEmojis = {
  'tomaten': '🍅',
  'paprika_peper': '🫑',
  'komkommer_familie': '🥒',
  'bonen': '🫛',
  'wortelgroenten': '🥕',
  'bieten': '🟣',
  'kolen': '🥬',
  'bladgroenten': '🥬',
  'sla_soorten': '🥗',
  'uien': '🧅',
  'aardappel': '🥔',
  'aubergine': '🍆',
  'mais': '🌽',
  'meloenen': '🍈',
  'meerjarig': '🌿',
  'aziatische_groenten': '🥢',
  'kruiden': '🌿',
  'moestuin_bloemen': '🌼',
  'bloemen_zaden': '🌸',
  'fruit_bomen': '🍎',
  'bessen': '🫐',
  'paddestoelen': '🍄',
};

/// Groepslidmaatschap per plant-id (voor filters).
final Map<String, Set<String>> kPlantVegetableGroupIds = () {
  final map = <String, Set<String>>{};
  for (final g in kVegetableGroups) {
    for (final id in g.vegetableIds) {
      map.putIfAbsent(id, () => <String>{}).add(g.id);
    }
  }
  return map;
}();

VegetableGroup? vegetableGroupByIdForFilter(String groupId) {
  for (final g in kVegetableGroups) {
    if (g.id == groupId) return g;
  }
  return null;
}

bool plantMatchesVegetableGroups(String vegetableId, Set<String> groupIds) {
  if (groupIds.isEmpty) return true;
  final membership = kPlantVegetableGroupIds[vegetableId];
  if (membership == null) return false;
  return membership.any(groupIds.contains);
}

bool isClimbingVegetable(Vegetable v) {
  const climberIds = {
    'tomaat',
    'snoeptomaat',
    'cherrytomaat',
    'pruimtomaat',
    'vleestomaat',
    'trostomaat',
    'cocktailtomaat',
    'balkontomaat',
    'honingtomaat',
    'komkommer',
    'snackkomkommer',
    'cucamelon',
    'augurk',
    'courgette',
    'courgette_geel',
    'patisson',
    'patisson_geel',
    'snijbonen',
    'sugarsnaps',
    'tuinerwt',
    'doperwt',
    'peultjes',
    'haricots_verts',
    'pompoen',
    'reuzen_pompoen',
    'pompoen_hokkaido',
    'pompoen_butternut',
    'watermeloen',
    'meloen',
    'galia_meloen',
    'honingmeloen',
    'pepino',
    'druif',
    'framboos',
    'braam',
    'kiwi',
    'aardbei',
    'aardbei_everbearer',
    'okra',
  };
  if (climberIds.contains(v.id)) return true;

  final hay =
      '${v.care} ${v.summary} ${v.transplant} ${v.sunRequirement} ${v.keywords.join(' ')}'
          .toLowerCase();
  return hay.contains('klim') ||
      hay.contains('rank') ||
      hay.contains('stokboon') ||
      hay.contains('stokbonen') ||
      hay.contains('trellis') ||
      hay.contains('klimrek') ||
      hay.contains('klimras') ||
      hay.contains('uitbinden') ||
      hay.contains('steunpaal') ||
      hay.contains('steunpaal') ||
      (hay.contains('steun') && !hay.contains('geen steun'));
}

/// Middelpunt van `cropDuration` in dagen, of null als niet parsebaar.
int? cropDurationDaysMidpoint(Vegetable v) {
  final raw = v.cropDuration?.toLowerCase().trim();
  if (raw == null || raw.isEmpty) return null;
  if (raw.contains('lang seizoen') ||
      raw.contains('seizoensproductie') ||
      raw.contains('meerjarig')) {
    return 120;
  }
  final range = RegExp(r'(\d+)\s*(?:[–\-]|tot)\s*(\d+)').firstMatch(raw);
  if (range != null) {
    final a = int.tryParse(range.group(1)!);
    final b = int.tryParse(range.group(2)!);
    if (a != null && b != null) return ((a + b) / 2).round();
  }
  final single = RegExp(r'(\d+)').firstMatch(raw);
  if (single != null) return int.tryParse(single.group(1)!);
  return null;
}

PlantGrowthSpeedFilter? growthSpeedForPlant(Vegetable v) {
  final days = cropDurationDaysMidpoint(v);
  if (days != null) {
    if (days <= 45) return PlantGrowthSpeedFilter.fast;
    if (days <= 80) return PlantGrowthSpeedFilter.medium;
    return PlantGrowthSpeedFilter.long;
  }
  final cat = (v.growthCategory ?? '').toLowerCase();
  if (cat.contains('snelle')) return PlantGrowthSpeedFilter.fast;
  if (cat.contains('lang producerende') ||
      cat.contains('zomerplant') ||
      cat.contains('meerjarig')) {
    return PlantGrowthSpeedFilter.long;
  }
  if (cat.contains('middelmatige')) return PlantGrowthSpeedFilter.medium;
  return null;
}

/// Zaaimaanden (voorzaai + buiten zaaien), voor bakplanning.
Set<int> sowingMonthsForPlant(Vegetable v) {
  final months = <int>{}
    ..addAll(_monthsFromText('${v.sowingIndoors} ${v.sowingOutdoors}'));
  for (final a in allPlantingCalendarActivities()) {
    if (a.vegetableId != v.id) continue;
    if (a.type == GardenTaskType.preSow ||
        a.type == GardenTaskType.sowOutdoors) {
      months.addAll(a.months);
    }
  }
  return months;
}

const Set<String> _kHerbGroupIds = {'kruiden'};
const Set<String> _kFlowerGroupIds = {'bloemen_zaden'};
const Set<String> _kCompanionGroupIds = {'moestuin_bloemen'};
const Set<String> _kFruitGroupIds = {'fruit_bomen', 'aardbeien'};
const Set<String> _kLegumeGroupIds = {'bonen'};
const Set<String> _kMushroomGroupIds = {'paddestoelen'};

const Set<String> _kGroenteGroupIds = {
  'bieten',
  'sla_soorten',
  'bladgroenten',
  'wortelgroenten',
  'tomaten',
  'paprika_peper',
  'komkommer_familie',
  'uien',
  'kolen',
  'aardappel',
  'aubergine',
  'mais',
  'meerjarig',
};

Set<String> _plantIdsInGroups(Set<String> groupIds) {
  final ids = <String>{};
  for (final g in kVegetableGroups) {
    if (groupIds.contains(g.id)) ids.addAll(g.vegetableIds);
  }
  return ids;
}

final Set<String> kHerbPlantIds = _plantIdsInGroups(_kHerbGroupIds);
final Set<String> kFlowerPlantIds = _plantIdsInGroups(_kFlowerGroupIds);
final Set<String> kCompanionGardenPlantIds = {
  ..._plantIdsInGroups(_kCompanionGroupIds),
  ...kMoestuinCompanionPlantIds,
};
final Set<String> kFruitPlantIds = _plantIdsInGroups(_kFruitGroupIds);
final Set<String> kLegumePlantIds = _plantIdsInGroups(_kLegumeGroupIds);
final Set<String> kMushroomPlantIds = _plantIdsInGroups(_kMushroomGroupIds);
final Set<String> kGroentePlantIds = _plantIdsInGroups(_kGroenteGroupIds);

final Set<String> kAllGroupedPlantIds = () {
  final ids = <String>{};
  for (final g in kVegetableGroups) {
    ids.addAll(g.vegetableIds);
  }
  return ids;
}();

PlantBrowseKind browseKindForPlant(String vegetableId) {
  if (kCompanionGardenPlantIds.contains(vegetableId)) {
    return PlantBrowseKind.companionGarden;
  }
  if (kHerbPlantIds.contains(vegetableId)) return PlantBrowseKind.herbs;
  if (kFlowerPlantIds.contains(vegetableId)) return PlantBrowseKind.flowersPlants;
  if (kFruitPlantIds.contains(vegetableId)) return PlantBrowseKind.fruitTrees;
  if (kLegumePlantIds.contains(vegetableId)) return PlantBrowseKind.legumes;
  if (kMushroomPlantIds.contains(vegetableId)) return PlantBrowseKind.mushrooms;
  if (kGroentePlantIds.contains(vegetableId)) return PlantBrowseKind.groente;
  if (!kAllGroupedPlantIds.contains(vegetableId)) {
    return PlantBrowseKind.other;
  }
  return PlantBrowseKind.other;
}

PlantBrowseKind browseKindForGroupId(String? groupId) {
  if (groupId == null) return PlantBrowseKind.all;
  if (_kCompanionGroupIds.contains(groupId)) {
    return PlantBrowseKind.companionGarden;
  }
  if (_kFlowerGroupIds.contains(groupId)) {
    return PlantBrowseKind.flowersPlants;
  }
  if (_kFruitGroupIds.contains(groupId)) return PlantBrowseKind.fruitTrees;
  if (_kHerbGroupIds.contains(groupId)) return PlantBrowseKind.herbs;
  if (_kLegumeGroupIds.contains(groupId)) return PlantBrowseKind.legumes;
  if (_kMushroomGroupIds.contains(groupId)) return PlantBrowseKind.mushrooms;
  if (_kGroenteGroupIds.contains(groupId)) return PlantBrowseKind.groente;
  return PlantBrowseKind.all;
}

bool isFlowerGuidePlant(String vegetableId) {
  final groups = kPlantVegetableGroupIds[vegetableId];
  if (groups == null) return false;
  return groups.contains('moestuin_bloemen') ||
      groups.contains('bloemen_zaden') ||
      kCompanionGardenPlantIds.contains(vegetableId);
}

SunFilter classifySun(String sunRequirement) {
  final t = sunRequirement.toLowerCase();
  final hasHalf = t.contains('halfschaduw') ||
      t.contains('halfzon') ||
      t.contains('halfschad');
  final hasShade = t.contains('schaduw');
  if (hasShade && !hasHalf && !t.contains('licht tot')) {
    if (t.contains('licht') && !hasHalf) return SunFilter.partialShade;
    if (!hasHalf) return SunFilter.shade;
  }
  if (hasHalf || (t.contains('licht') && hasShade)) {
    return SunFilter.partialShade;
  }
  if (t.contains('volle zon') ||
      t.contains('veel zon') ||
      (t.contains('zon') && !hasShade)) {
    return SunFilter.fullSun;
  }
  return SunFilter.partialShade;
}

WaterFilter classifyWater(String water) {
  final t = water.toLowerCase();
  if (t.contains('weinig') ||
      t.contains('droog houden') ||
      t.contains('tussen gietbeurten laten drogen') ||
      t.contains('laat bovenste') ||
      (t.contains('matig') && !t.contains('gelijkmatig') && !t.contains('veel'))) {
    return WaterFilter.low;
  }
  if (t.contains('veel water') ||
      t.contains('veel vocht') ||
      t.contains('niet uitdrogen') ||
      (t.contains('regelmatig') && !t.contains('matig'))) {
    return WaterFilter.high;
  }
  if (t.contains('gelijkmatig') || t.contains('regelmatig')) {
    return WaterFilter.high;
  }
  return WaterFilter.medium;
}

const Map<SeasonFilter, Set<int>> _seasonMonths = {
  SeasonFilter.spring: {2, 3, 4, 5},
  SeasonFilter.summer: {5, 6, 7, 8},
  SeasonFilter.autumn: {8, 9, 10, 11},
};

const Map<String, int> _monthTokens = {
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

Set<int> _monthsFromText(String text) {
  final t = text.toLowerCase();
  final months = <int>{};
  for (final entry in _monthTokens.entries) {
    if (t.contains(entry.key)) months.add(entry.value);
  }
  return months;
}

Set<int> _activityMonthsForPlant(String vegetableId) {
  final months = <int>{};
  for (final a in kPlantingCalendar) {
    if (a.vegetableId != vegetableId) continue;
    months.addAll(a.months);
  }
  return months;
}

Set<SeasonFilter> seasonsForPlant(Vegetable v) {
  final months = <int>{}
    ..addAll(_monthsFromText(
      '${v.sowingIndoors} ${v.sowingOutdoors} ${v.transplant} ${v.harvest}',
    ))
    ..addAll(_activityMonthsForPlant(v.id));

  final seasons = <SeasonFilter>{};
  for (final entry in _seasonMonths.entries) {
    if (months.any(entry.value.contains)) seasons.add(entry.key);
  }
  if (seasons.isEmpty) {
    seasons.addAll(SeasonFilter.values);
  }
  return seasons;
}

class PlantSearchCriteria {
  const PlantSearchCriteria({
    this.browse = PlantBrowseKind.all,
    this.vegetableGroupIds = const {},
    this.sunFilters = const {},
    this.waterFilters = const {},
    this.seasonFilters = const {},
    this.habitFilters = const {},
    this.growthSpeedFilters = const {},
    this.harvestLocationFilters = const {},
    this.spacingFilters = const {},
    this.sowingMonthFilters = const {},
    this.flowersOnly = false,
  });

  final PlantBrowseKind browse;
  final Set<String> vegetableGroupIds;
  final Set<SunFilter> sunFilters;
  final Set<WaterFilter> waterFilters;
  final Set<SeasonFilter> seasonFilters;
  final Set<PlantHabitFilter> habitFilters;
  final Set<PlantGrowthSpeedFilter> growthSpeedFilters;
  final Set<PlantHarvestLocationFilter> harvestLocationFilters;
  final Set<SpacingFilter> spacingFilters;
  /// Maanden 1–12 waarin gezaaid mag worden.
  final Set<int> sowingMonthFilters;
  final bool flowersOnly;

  bool get hasActiveFilters => activeFilterCount > 0;

  int get activeFilterCount {
    var n = 0;
    if (browse != PlantBrowseKind.all) n++;
    n += vegetableGroupIds.length;
    n += sunFilters.length;
    n += waterFilters.length;
    n += seasonFilters.length;
    n += habitFilters.length;
    n += growthSpeedFilters.length;
    n += harvestLocationFilters.length;
    n += spacingFilters.length;
    n += sowingMonthFilters.length;
    if (flowersOnly) n++;
    return n;
  }

  PlantSearchCriteria cleared() => const PlantSearchCriteria();

  PlantSearchCriteria copyWith({
    PlantBrowseKind? browse,
    Set<String>? vegetableGroupIds,
    Set<SunFilter>? sunFilters,
    Set<WaterFilter>? waterFilters,
    Set<SeasonFilter>? seasonFilters,
    Set<PlantHabitFilter>? habitFilters,
    Set<PlantGrowthSpeedFilter>? growthSpeedFilters,
    Set<PlantHarvestLocationFilter>? harvestLocationFilters,
    Set<SpacingFilter>? spacingFilters,
    Set<int>? sowingMonthFilters,
    bool? flowersOnly,
  }) {
    return PlantSearchCriteria(
      browse: browse ?? this.browse,
      vegetableGroupIds: vegetableGroupIds ?? this.vegetableGroupIds,
      sunFilters: sunFilters ?? this.sunFilters,
      waterFilters: waterFilters ?? this.waterFilters,
      seasonFilters: seasonFilters ?? this.seasonFilters,
      habitFilters: habitFilters ?? this.habitFilters,
      growthSpeedFilters: growthSpeedFilters ?? this.growthSpeedFilters,
      harvestLocationFilters:
          harvestLocationFilters ?? this.harvestLocationFilters,
      spacingFilters: spacingFilters ?? this.spacingFilters,
      sowingMonthFilters: sowingMonthFilters ?? this.sowingMonthFilters,
      flowersOnly: flowersOnly ?? this.flowersOnly,
    );
  }
}

bool plantMatchesBrowse(String vegetableId, PlantBrowseKind browse) {
  if (browse == PlantBrowseKind.all) return true;
  return browseKindForPlant(vegetableId) == browse;
}

bool plantMatchesCriteria(Vegetable v, PlantSearchCriteria criteria) {
  if (criteria.vegetableGroupIds.isNotEmpty) {
    if (!plantMatchesVegetableGroups(v.id, criteria.vegetableGroupIds)) {
      return false;
    }
  } else if (!plantMatchesBrowse(v.id, criteria.browse)) {
    return false;
  }

  if (criteria.flowersOnly && !isFlowerGuidePlant(v.id)) {
    return false;
  }

  if (criteria.habitFilters.isNotEmpty) {
    final climbs = isClimbingVegetable(v);
    final matchesHabit = criteria.habitFilters.any((h) {
      return switch (h) {
        PlantHabitFilter.climber => climbs,
        PlantHabitFilter.nonClimber => !climbs,
      };
    });
    if (!matchesHabit) return false;
  }

  if (criteria.growthSpeedFilters.isNotEmpty) {
    final speed = growthSpeedForPlant(v);
    if (speed == null || !criteria.growthSpeedFilters.contains(speed)) {
      return false;
    }
  }

  if (criteria.harvestLocationFilters.isNotEmpty) {
    final underground = isUndergroundCrop(v);
    final matchesLocation = criteria.harvestLocationFilters.any((h) {
      return switch (h) {
        PlantHarvestLocationFilter.underground => underground,
        PlantHarvestLocationFilter.aboveGround => !underground,
      };
    });
    if (!matchesLocation) return false;
  }

  if (criteria.sunFilters.isNotEmpty) {
    if (!criteria.sunFilters.contains(classifySun(v.sunRequirement))) {
      return false;
    }
  }

  if (criteria.waterFilters.isNotEmpty) {
    if (!criteria.waterFilters.contains(classifyWater(v.water))) {
      return false;
    }
  }

  if (criteria.seasonFilters.isNotEmpty) {
    final seasons = seasonsForPlant(v);
    if (!criteria.seasonFilters.any(seasons.contains)) return false;
  }

  if (criteria.sowingMonthFilters.isNotEmpty) {
    final months = sowingMonthsForPlant(v);
    if (!criteria.sowingMonthFilters.any(months.contains)) return false;
  }

  if (criteria.spacingFilters.isNotEmpty) {
    if (!criteria.spacingFilters.any((f) => f.matches(v.spacingCm))) {
      return false;
    }
  }

  return true;
}

List<Vegetable> searchFilteredPlants({
  required VegetableRepository repository,
  required PlantSearchCriteria criteria,
  required String searchQuery,
}) {
  var list = repository.all
      .where((v) => plantMatchesCriteria(v, criteria))
      .toList();

  final q = searchQuery.trim();
  if (q.isNotEmpty) {
    list = list.where((v) => v.matchesQuery(q)).toList();
  }

  list.sort((a, b) => a.nameNl.compareTo(b.nameNl));
  return list;
}
