import '../models/vegetable.dart';
import 'planting_calendar.dart';
import 'planting_calendar_supplement.dart';
import 'vegetable_groups.dart';

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
        type: GardenTaskType.sowOutdoors,
        months: [2, 3, 4],
        hint: 'Zaaien of sets voorbereiden.',
      ),
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [3, 4, 10, 11],
        hint: 'Plantui of winterteelt afhankelijk van ras.',
      ),
    ];
  }

  if (family.contains('composiet') ||
      keywords.contains('sla') ||
      id.contains('sla')) {
    return [
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.sowOutdoors,
        months: [3, 4, 5, 6, 7, 8, 9],
        hint: 'Direct zaaien buiten; doorzaaien tot laat in seizoen.',
      ),
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [4, 5, 6, 7, 8, 9],
        hint: 'Zaailingen uitplanten na vorst.',
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
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.plantOutdoors,
        months: [4, 5, 6, 7, 8, 9],
        hint: 'Zaailingen uitplanten in het groeiseizoen.',
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
        type: GardenTaskType.preSow,
        months: [2, 3, 4],
        hint: 'Zaad voorzaaien binnen.',
      ),
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.sowOutdoors,
        months: [3, 4, 5],
        hint: 'Direct zaaien buiten als het warm genoeg is.',
      ),
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
        type: GardenTaskType.preSow,
        months: [2, 3, 4],
        hint: 'Zaad voorzaaien binnen.',
      ),
      VegetableMonthActivity(
        vegetableId: id,
        type: GardenTaskType.sowOutdoors,
        months: [3, 4, 5],
        hint: 'Direct zaaien buiten.',
      ),
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
      type: GardenTaskType.sowOutdoors,
      months: [4, 5, 6],
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

List<VegetableMonthActivity> _groupTemplatePlantingActivities(
  String vegetableId,
) {
  final group = vegetableGroupContaining(vegetableId);
  if (group == null) return const [];

  const plantingTypes = {
    GardenTaskType.preSow,
    GardenTaskType.sowOutdoors,
    GardenTaskType.plantOutdoors,
  };

  final byType = <GardenTaskType, VegetableMonthActivity>{};

  for (final memberId in group.vegetableIds) {
    if (memberId == vegetableId) continue;
    final template = _explicitForVegetable(memberId)
        .where((a) => plantingTypes.contains(a.type))
        .toList();
    for (final a in template) {
      final existing = byType[a.type];
      if (existing == null) {
        byType[a.type] = VegetableMonthActivity(
          vegetableId: vegetableId,
          type: a.type,
          months: a.months,
          hint: a.hint,
        );
        continue;
      }
      final mergedMonths = {...existing.months, ...a.months}.toList()..sort();
      byType[a.type] = VegetableMonthActivity(
        vegetableId: vegetableId,
        type: a.type,
        months: mergedMonths,
        hint: existing.hint ?? a.hint,
      );
    }
  }

  return byType.values.toList();
}

List<VegetableMonthActivity> _mergePlantingActivitiesByType(
  List<VegetableMonthActivity> primary,
  List<VegetableMonthActivity> supplement,
  String vegetableId,
) {
  final byType = <GardenTaskType, VegetableMonthActivity>{
    for (final a in primary) a.type: a,
  };

  for (final a in supplement) {
    if (byType.containsKey(a.type)) continue;
    byType[a.type] = VegetableMonthActivity(
      vegetableId: vegetableId,
      type: a.type,
      months: a.months,
      hint: a.hint,
    );
  }

  return byType.values.toList();
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

  List<VegetableMonthActivity> base;
  if (explicit.isNotEmpty) {
    base = explicit;
  } else {
    final groupTemplate = _groupTemplatePlantingActivities(vegetableId);
    if (groupTemplate.isNotEmpty) {
      base = groupTemplate;
    } else if (vegetable != null && vegetable.id == vegetableId) {
      return defaultPlantingActivitiesFor(vegetable);
    } else {
      return const [];
    }
  }

  if (vegetable != null && vegetable.id == vegetableId) {
    return _mergePlantingActivitiesByType(
      base,
      defaultPlantingActivitiesFor(vegetable),
      vegetableId,
    );
  }
  return base;
}

/// Alle kalenderactiviteiten voor één gewas (inclusief oogst).
List<VegetableMonthActivity> calendarActivitiesForVegetable(
  String vegetableId, {
  Vegetable? vegetable,
}) {
  final explicit = _explicitForVegetable(vegetableId);

  if (vegetable != null && vegetable.id == vegetableId) {
    if (explicit.isEmpty) {
      return defaultCalendarActivitiesFor(vegetable);
    }

    const plantingTypes = {
      GardenTaskType.preSow,
      GardenTaskType.sowOutdoors,
      GardenTaskType.plantOutdoors,
    };

    final explicitPlanting =
        explicit.where((a) => plantingTypes.contains(a.type)).toList();
    final explicitHarvest =
        explicit.where((a) => a.type == GardenTaskType.harvest).toList();

    final planting = _mergePlantingActivitiesByType(
      explicitPlanting,
      defaultPlantingActivitiesFor(vegetable),
      vegetableId,
    );

    if (explicitHarvest.isNotEmpty) {
      return [...planting, ...explicitHarvest];
    }

    return [
      ...planting,
      VegetableMonthActivity(
        vegetableId: vegetableId,
        type: GardenTaskType.harvest,
        months: defaultHarvestMonthsFor(vegetable),
        hint: 'Oogstperiode indicatief; zie teeltinfo.',
      ),
    ];
  }

  if (explicit.isNotEmpty) return explicit;
  return const [];
}
