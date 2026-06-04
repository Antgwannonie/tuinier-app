import '../models/vegetable.dart';
import 'planting_calendar.dart';
import 'planting_calendar_supplement.dart';

/// Standaard zaai-/plantkalender als een gewas nog geen eigen regels heeft.
List<VegetableMonthActivity> defaultPlantingActivitiesFor(Vegetable vegetable) {
  final id = vegetable.id;
  final family = vegetable.family.toLowerCase();
  final category = vegetable.growthCategory?.toLowerCase() ?? '';
  final keywords = vegetable.keywords.map((k) => k.toLowerCase()).join(' ');

  if (family.contains('paddestoel') || keywords.contains('paddenstoel')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.preSow,
        months: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
        hint: 'Binnen op substraa of growkit.',
      ),
    ];
  }

  if (category.contains('moestuin-bloemen') ||
      keywords.contains('nuttige bloemen') ||
      keywords.contains('bestuiving')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.sowOutdoors,
        months: [3, 4, 5, 6],
        hint: 'Zaaien voor zomerbloei.',
      ),
    ];
  }

  if (keywords.contains('kruid') ||
      family.contains('lipbloem') ||
      family.contains('schermbloem')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.preSow,
        months: [3, 4, 5],
        hint: 'Voorzaaien binnen of in kas.',
      ),
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [5, 6, 7],
        hint: 'Uitplanten op warme, beschutte plek.',
      ),
    ];
  }

  if (family.contains('kool') || keywords.contains('kool')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.preSow,
        months: [3, 4],
      ),
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [5, 6, 7],
      ),
    ];
  }

  if (family.contains('peul') || keywords.contains('boon') || keywords.contains('erwt')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.sowOutdoors,
        months: [4, 5],
        hint: 'Direct zaaien buiten.',
      ),
    ];
  }

  if (family.contains('uien') || keywords.contains('ui') || keywords.contains('look')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [3, 4, 10, 11],
        hint: 'Plantui of winterteelt afhankelijk van ras.',
      ),
    ];
  }

  if (category.contains('snelle')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.sowOutdoors,
        months: [4, 5, 6, 7, 8],
        hint: 'Doorzaaien mogelijk voor langere oogst.',
      ),
    ];
  }

  if (category.contains('lang producerende') || category.contains('zomer')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.preSow,
        months: [3, 4],
      ),
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [5, 6],
      ),
    ];
  }

  if (category.contains('fruit') ||
      category.contains('boom') ||
      category.contains('bes') ||
      keywords.contains('fruitboom') ||
      keywords.contains('fruit')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [3, 4, 10, 11],
        hint: 'Planten in rustperiode of voorjaar.',
      ),
    ];
  }

  if (category.contains('meerjarig')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [3, 4, 5],
        hint: 'Planten of delen in voorjaar.',
      ),
    ];
  }

  // Algemene moestuin-default (NL).
  return [
    VegetableMonthActivity(
      vegetableId: id,
      type: GardenTaskType.preSow,
      months: [3, 4],
    ),
    VegetableMonthActivity(
      vegetableId: id,
      type: GardenTaskType.plantOutdoors,
      months: [5, 6],
    ),
  ];
}

List<int> defaultHarvestMonthsFor(Vegetable vegetable) {
  final category = vegetable.growthCategory?.toLowerCase() ?? '';
  final keywords =
      vegetable.keywords.map((k) => k.toLowerCase()).join(' ');

  if (category.contains('fruit') ||
      category.contains('boom') ||
      category.contains('bes') ||
      keywords.contains('fruit')) {
    return [7, 8, 9, 10];
  }
  if (keywords.contains('kruid') || category.contains('kruid')) {
    return [6, 7, 8, 9];
  }
  if (category.contains('snelle')) {
    return [5, 6, 7, 8, 9];
  }
  return [7, 8, 9];
}

/// Volledige fallback-kalender (zaai/plant + oogst) voor gewassen zonder eigen regels.
List<VegetableMonthActivity> defaultCalendarActivitiesFor(Vegetable vegetable) {
  return [
    ...defaultPlantingActivitiesFor(vegetable),
    VegetableMonthActivity(
      vegetableId: vegetable.id,
      type: GardenTaskType.harvest,
      months: defaultHarvestMonthsFor(vegetable),
      hint: 'Oogstperiode indicatief; zie teeltinfo.',
    ),
  ];
}

List<VegetableMonthActivity> _explicitForVegetable(String vegetableId) {
  return [
    ...kPlantingCalendar,
    ...kPlantingCalendarSupplement,
  ].where((a) => a.vegetableId == vegetableId).toList();
}

/// Kalenderregels voor zaai/plant: eerst expliciet, anders fallback op gewastype.
List<VegetableMonthActivity> plantingActivitiesForVegetable(
  String vegetableId, {
  Vegetable? vegetable,
}) {
  const plantingTypes = {
    GardenTaskType.preSow,
    GardenTaskType.sowOutdoors,
    GardenTaskType.plantOutdoors,
  };

  final explicit = _explicitForVegetable(vegetableId)
      .where((a) => plantingTypes.contains(a.type))
      .toList();
  if (explicit.isNotEmpty) return explicit;

  if (vegetable != null && vegetable.id == vegetableId) {
    return defaultPlantingActivitiesFor(vegetable);
  }
  return const [];
}

/// Alle kalenderactiviteiten voor één gewas (inclusief oogst).
List<VegetableMonthActivity> calendarActivitiesForVegetable(
  String vegetableId, {
  Vegetable? vegetable,
}) {
  final explicit = _explicitForVegetable(vegetableId);
  if (explicit.isNotEmpty) return explicit;
  if (vegetable != null && vegetable.id == vegetableId) {
    return defaultCalendarActivitiesFor(vegetable);
  }
  return const [];
}
