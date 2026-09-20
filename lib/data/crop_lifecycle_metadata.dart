import '../models/vegetable.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';

/// Eenjarig vs meerjarig gewas.
enum CropLifecycleType {
  annual,
  perennial,
}

/// Oogstgedrag binnen één groeiseizoen.
enum CropHarvestPattern {
  /// Eén oogstmoment (sla, wortel, ui).
  single,

  /// Doorlopend oogsten (tomaat, courgette, aardbei).
  continuous,
}

/// Waarom een plant niet-actief is in de moestuin (blijft zichtbaar).
enum PlantMoestuinInactiveReason {
  harvestComplete,
  confirmedDead,
  offSeason,
}

extension PlantMoestuinInactiveReasonLabel on PlantMoestuinInactiveReason {
  String get shortLabel {
    switch (this) {
      case PlantMoestuinInactiveReason.harvestComplete:
        return 'Volledig geoogst';
      case PlantMoestuinInactiveReason.confirmedDead:
        return 'Plant overleden';
      case PlantMoestuinInactiveReason.offSeason:
        return 'Wacht op seizoen';
    }
  }
}

PlantMoestuinInactiveReason? parsePlantMoestuinInactiveReason(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  try {
    return PlantMoestuinInactiveReason.values.byName(raw);
  } catch (_) {
    return null;
  }
}

bool isPerennialCrop(Vegetable vegetable) {
  final cat = (vegetable.growthCategory ?? '').toLowerCase();
  if (cat.contains('meerjarig')) return true;
  final fam = vegetable.family.toLowerCase();
  if (fam.contains('fruitboom') ||
      fam.contains('bes') ||
      fam.contains('struik')) {
    return true;
  }
  const perennialIds = {
    'rabarber',
    'asperge',
    'lavendel',
    'munt',
    'tijm',
    'salie',
    'rozemarijn',
    'aardbei',
    'framboos',
    'braam',
    'blauwe_bes',
    'rode_bes',
    'zwarte_bes',
    'kruisbes',
    'vlier',
    'druif',
    'appel',
    'peer',
    'kers',
    'pruim',
  };
  return perennialIds.contains(vegetable.id);
}

CropLifecycleType lifecycleTypeFor(Vegetable vegetable) =>
    isPerennialCrop(vegetable)
        ? CropLifecycleType.perennial
        : CropLifecycleType.annual;

const Set<String> _continuousHarvestIds = {
  'tomaat',
  'cherrytomaat',
  'courgette',
  'komkommer',
  'rode_paprika',
  'peper',
  'aubergine',
  'aardbei',
  'framboos',
  'braam',
  'rabarber',
  'asperge',
  'snijbiet',
  'postelein',
  'sla_snij',
  'boon_stok',
  'boon_sperzie',
  'doperwt',
  'sugar_snap',
  'kers',
};

CropHarvestPattern harvestPatternFor(Vegetable vegetable) {
  if (_continuousHarvestIds.contains(vegetable.id)) {
    return CropHarvestPattern.continuous;
  }
  if (isPerennialCrop(vegetable) && !isOrnamentalPerennial(vegetable)) {
    return CropHarvestPattern.continuous;
  }
  return CropHarvestPattern.single;
}

bool isOrnamentalPerennial(Vegetable vegetable) {
  final cat = (vegetable.growthCategory ?? '').toLowerCase();
  return cat.contains('sier') || cat.contains('randplant');
}

Set<int> harvestMonthsFor(Vegetable vegetable) {
  final activities = calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  );
  final fromCal = activities
      .where((a) => a.type == GardenTaskType.harvest)
      .expand((a) => a.months)
      .toSet();
  if (fromCal.isNotEmpty) return fromCal;
  return defaultHarvestMonthsFor(vegetable).toSet();
}

Set<int> plantingMonthsFor(Vegetable vegetable) {
  final activities = calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  );
  return activities
      .where(
        (a) =>
            a.type == GardenTaskType.preSow ||
            a.type == GardenTaskType.sowOutdoors ||
            a.type == GardenTaskType.plantOutdoors,
      )
      .expand((a) => a.months)
      .toSet();
}

/// Huidige maand valt buiten de officiële oogstmaanden op de kalender.
bool isOutsideOfficialHarvestMonths(Vegetable vegetable, int month) {
  final months = harvestMonthsFor(vegetable);
  if (months.isEmpty) return false;
  return !months.contains(month);
}

bool isPlantingSeasonOpen(Vegetable vegetable, int month) {
  return plantingMonthsFor(vegetable).contains(month);
}

bool isPerennialActiveSeasonOpen(Vegetable vegetable, int month) {
  if (isPlantingSeasonOpen(vegetable, month)) return true;
  return harvestMonthsFor(vegetable).contains(month);
}
