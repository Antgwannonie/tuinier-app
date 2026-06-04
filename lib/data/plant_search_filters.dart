import '../models/vegetable.dart';
import 'moestuin_companion_plants.dart';
import 'planting_calendar.dart';
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
    this.sunFilters = const {},
    this.waterFilters = const {},
    this.seasonFilters = const {},
  });

  final PlantBrowseKind browse;
  final Set<SunFilter> sunFilters;
  final Set<WaterFilter> waterFilters;
  final Set<SeasonFilter> seasonFilters;

  int get activeFilterCount {
    var n = 0;
    if (browse != PlantBrowseKind.all) n++;
    n += sunFilters.length;
    n += waterFilters.length;
    n += seasonFilters.length;
    return n;
  }

  PlantSearchCriteria copyWith({
    PlantBrowseKind? browse,
    Set<SunFilter>? sunFilters,
    Set<WaterFilter>? waterFilters,
    Set<SeasonFilter>? seasonFilters,
  }) {
    return PlantSearchCriteria(
      browse: browse ?? this.browse,
      sunFilters: sunFilters ?? this.sunFilters,
      waterFilters: waterFilters ?? this.waterFilters,
      seasonFilters: seasonFilters ?? this.seasonFilters,
    );
  }
}

bool plantMatchesBrowse(String vegetableId, PlantBrowseKind browse) {
  if (browse == PlantBrowseKind.all) return true;
  return browseKindForPlant(vegetableId) == browse;
}

bool plantMatchesCriteria(Vegetable v, PlantSearchCriteria criteria) {
  if (!plantMatchesBrowse(v.id, criteria.browse)) return false;

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
