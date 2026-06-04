import 'planting_calendar.dart';

/// Extra kalenderregels voor fruit, bessen en nieuwe atlas-gewassen.
const List<VegetableMonthActivity> kPlantingCalendarSupplement = [
  // Fruitbomen — planten / snoeien / oogst
  VegetableMonthActivity(
    vegetableId: 'appel',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4, 10, 11],
    hint: 'Container- of kuilaanplant; snoei in winter.',
  ),
  VegetableMonthActivity(
    vegetableId: 'appel',
    type: GardenTaskType.harvest,
    months: [9, 10],
    hint: 'Pluk rijp; bewaar koel.',
  ),
  VegetableMonthActivity(
    vegetableId: 'peer',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'peer',
    type: GardenTaskType.harvest,
    months: [9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'kers',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'kers',
    type: GardenTaskType.harvest,
    months: [6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'abrikoos',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4],
    hint: 'Beschut en warm.',
  ),
  VegetableMonthActivity(
    vegetableId: 'abrikoos',
    type: GardenTaskType.harvest,
    months: [7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'perzik',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'perzik',
    type: GardenTaskType.harvest,
    months: [7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'vijg',
    type: GardenTaskType.plantOutdoors,
    months: [4, 5],
    hint: 'Kas of warme muur.',
  ),
  VegetableMonthActivity(
    vegetableId: 'vijg',
    type: GardenTaskType.harvest,
    months: [8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'druif',
    type: GardenTaskType.plantOutdoors,
    months: [4, 5],
  ),
  VegetableMonthActivity(
    vegetableId: 'druif',
    type: GardenTaskType.harvest,
    months: [9, 10],
  ),
  // Bessen
  VegetableMonthActivity(
    vegetableId: 'framboos',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4, 10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'framboos',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'braam',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4, 10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'braam',
    type: GardenTaskType.harvest,
    months: [8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'blauwe_bes',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4, 10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'blauwe_bes',
    type: GardenTaskType.harvest,
    months: [7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'rode_bes',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4, 10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'rode_bes',
    type: GardenTaskType.harvest,
    months: [6, 7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'zwarte_bes',
    type: GardenTaskType.plantOutdoors,
    months: [10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'zwarte_bes',
    type: GardenTaskType.harvest,
    months: [7, 8],
  ),
  // Grote fruitgewassen
  VegetableMonthActivity(
    vegetableId: 'watermeloen',
    type: GardenTaskType.preSow,
    months: [4, 5],
  ),
  VegetableMonthActivity(
    vegetableId: 'watermeloen',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'watermeloen',
    type: GardenTaskType.harvest,
    months: [8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'meloen',
    type: GardenTaskType.preSow,
    months: [4, 5],
  ),
  VegetableMonthActivity(
    vegetableId: 'meloen',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'meloen',
    type: GardenTaskType.harvest,
    months: [8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'kiwi',
    type: GardenTaskType.plantOutdoors,
    months: [4, 5],
    hint: 'Muur of pergola; mannelijk + vrouwelijk ras.',
  ),
  VegetableMonthActivity(
    vegetableId: 'kiwi',
    type: GardenTaskType.harvest,
    months: [10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'physalis',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'physalis',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'physalis',
    type: GardenTaskType.harvest,
    months: [8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'witlof',
    type: GardenTaskType.sowOutdoors,
    months: [5, 6],
    hint: 'Voor wortel in zomer; witte tooi in herfst.',
  ),
  VegetableMonthActivity(
    vegetableId: 'witlof',
    type: GardenTaskType.harvest,
    months: [11, 12, 1, 2],
  ),
  VegetableMonthActivity(
    vegetableId: 'veldsla',
    type: GardenTaskType.sowOutdoors,
    months: [3, 4, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'veldsla',
    type: GardenTaskType.harvest,
    months: [5, 6, 9, 10],
  ),
];
