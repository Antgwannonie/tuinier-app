import 'planting_calendar_fallback.dart';
import 'planting_calendar_supplement.dart';
import 'vegetables_data.dart';

/// Wat er in een bepaalde maand met een gewas aan de hand is.
enum GardenTaskType {
  preSow,
  sowOutdoors,
  plantOutdoors,
  harvest,
}

extension GardenTaskTypeLabel on GardenTaskType {
  String get label {
    switch (this) {
      case GardenTaskType.preSow:
        return 'Nu voorzaaien';
      case GardenTaskType.sowOutdoors:
        return 'Nu zaaien buiten';
      case GardenTaskType.plantOutdoors:
        return 'Nu planten buiten';
      case GardenTaskType.harvest:
        return 'Nu oogsten';
    }
  }

  int get sortOrder {
    switch (this) {
      case GardenTaskType.plantOutdoors:
        return 0;
      case GardenTaskType.sowOutdoors:
        return 1;
      case GardenTaskType.preSow:
        return 2;
      case GardenTaskType.harvest:
        return 3;
    }
  }
}

class VegetableMonthActivity {
  const VegetableMonthActivity({
    required this.vegetableId,
    required this.type,
    required this.months,
    this.hint,
    this.dayOfMonth,
  });

  final String vegetableId;
  final GardenTaskType type;

  /// Maanden 1–12 (januari = 1).
  final List<int> months;

  /// Korte actie voor op de startpagina.
  final String? hint;

  /// Optionele dag in de maand; anders verdeeld over de maand.
  final int? dayOfMonth;
}

/// Dag waarop een activiteit op de kalender staat.
int activityCalendarDay(VegetableMonthActivity activity) {
  if (activity.dayOfMonth != null) return activity.dayOfMonth!;
  return 3 + (activity.vegetableId.hashCode.abs() % 25);
}

/// Per gewas: wanneer voorzaaien, zaaien, planten of oogsten (NL moestuin).
const List<VegetableMonthActivity> kPlantingCalendar = [
  VegetableMonthActivity(
    vegetableId: 'radijs',
    type: GardenTaskType.sowOutdoors,
    months: [3, 4, 5, 6, 7, 8],
    hint: 'Doorzaaien mogelijk; snelle oogst.',
  ),
  VegetableMonthActivity(
    vegetableId: 'radijs',
    type: GardenTaskType.harvest,
    months: [6, 7],
    hint: 'Jong oogsten voor doorschieten.',
  ),
  VegetableMonthActivity(
    vegetableId: 'rucola',
    type: GardenTaskType.plantOutdoors,
    months: [5],
    hint: '1e ronde buiten; september 2e ronde.',
  ),
  VegetableMonthActivity(
    vegetableId: 'rucola',
    type: GardenTaskType.harvest,
    months: [6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'rucola',
    type: GardenTaskType.sowOutdoors,
    months: [9],
    hint: '2e ronde zaaien voor herfstoogst.',
  ),
  VegetableMonthActivity(
    vegetableId: 'rucola',
    type: GardenTaskType.harvest,
    months: [10],
    hint: '2e ronde oogsten.',
  ),
  VegetableMonthActivity(
    vegetableId: 'sla',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
    hint: 'Pluksla planten; regelmatig buitenblad plukken.',
  ),
  VegetableMonthActivity(
    vegetableId: 'sla',
    type: GardenTaskType.harvest,
    months: [6, 7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'spinazie',
    type: GardenTaskType.plantOutdoors,
    months: [5],
    hint: '1e ronde; september 2e ronde.',
  ),
  VegetableMonthActivity(
    vegetableId: 'spinazie',
    type: GardenTaskType.harvest,
    months: [6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'spinazie',
    type: GardenTaskType.sowOutdoors,
    months: [9],
    hint: '2e ronde voor herfst/winter.',
  ),
  VegetableMonthActivity(
    vegetableId: 'spinazie',
    type: GardenTaskType.harvest,
    months: [10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'bosui',
    type: GardenTaskType.sowOutdoors,
    months: [3, 4, 5],
    hint: 'Hoofdzaai lente (lente-ui).',
  ),
  VegetableMonthActivity(
    vegetableId: 'bosui',
    type: GardenTaskType.sowOutdoors,
    months: [7, 8],
    hint: '2e ronde zaaien (herfst oogst).',
  ),
  VegetableMonthActivity(
    vegetableId: 'bosui',
    type: GardenTaskType.harvest,
    months: [5, 6, 7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'wortel',
    type: GardenTaskType.sowOutdoors,
    months: [5],
    hint: 'Direct zaaien; niet verplanten.',
  ),
  VegetableMonthActivity(
    vegetableId: 'wortel',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'rode_biet',
    type: GardenTaskType.sowOutdoors,
    months: [7],
    hint: '2e ronde: zaaien voor oogst in september.',
  ),
  VegetableMonthActivity(
    vegetableId: 'rode_biet',
    type: GardenTaskType.harvest,
    months: [9],
  ),
  VegetableMonthActivity(
    vegetableId: 'bonen_sperzie',
    type: GardenTaskType.preSow,
    months: [5],
    hint: 'Optioneel voorzaaien in kas.',
  ),
  VegetableMonthActivity(
    vegetableId: 'bonen_sperzie',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
    hint: 'Buiten na ijsheiligen (half mei–juni).',
  ),
  VegetableMonthActivity(
    vegetableId: 'bonen_sperzie',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'snijbonen',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
    hint: 'Warmteminners; na vorst.',
  ),
  VegetableMonthActivity(
    vegetableId: 'snijbonen',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'cucamelon',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'cucamelon',
    type: GardenTaskType.harvest,
    months: [7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'snackkomkommer',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'snackkomkommer',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'snoeptomaat',
    type: GardenTaskType.preSow,
    months: [3, 4],
    hint: 'Voorzaaien onder glas of binnen.',
  ),
  VegetableMonthActivity(
    vegetableId: 'snoeptomaat',
    type: GardenTaskType.plantOutdoors,
    months: [5],
    hint: 'Uitplanten na vorst; steunen.',
  ),
  VegetableMonthActivity(
    vegetableId: 'snoeptomaat',
    type: GardenTaskType.harvest,
    months: [7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'tomaat',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'tomaat',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'tomaat',
    type: GardenTaskType.harvest,
    months: [7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'paprika',
    type: GardenTaskType.preSow,
    months: [2, 3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'paprika',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'paprika',
    type: GardenTaskType.harvest,
    months: [8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'peper',
    type: GardenTaskType.preSow,
    months: [2, 3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'peper',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'peper',
    type: GardenTaskType.harvest,
    months: [8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'aubergine',
    type: GardenTaskType.preSow,
    months: [2, 3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'aubergine',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'aubergine',
    type: GardenTaskType.harvest,
    months: [8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'aardbei',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'aardbei',
    type: GardenTaskType.harvest,
    months: [6, 7, 8, 9],
  ),
  // Extra veelgebruikte gewassen
  VegetableMonthActivity(
    vegetableId: 'rabarber',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4],
    hint: 'Kroon delen of planten in voorjaar.',
  ),
  VegetableMonthActivity(
    vegetableId: 'rabarber',
    type: GardenTaskType.harvest,
    months: [4, 5, 6],
    hint: 'Stop oogst vóór juli.',
  ),
  VegetableMonthActivity(
    vegetableId: 'asperge',
    type: GardenTaskType.preSow,
    months: [2, 3],
    hint: 'Zaaien of kroonplanten voorbereiden.',
  ),
  VegetableMonthActivity(
    vegetableId: 'asperge',
    type: GardenTaskType.plantOutdoors,
    months: [4],
    hint: 'Kroonplanten in greppel (NL).',
  ),
  VegetableMonthActivity(
    vegetableId: 'asperge',
    type: GardenTaskType.harvest,
    months: [4, 5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'prei',
    type: GardenTaskType.preSow,
    months: [2, 3, 4],
    hint: 'Voorzaaien in bak.',
  ),
  VegetableMonthActivity(
    vegetableId: 'prei',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'prei',
    type: GardenTaskType.harvest,
    months: [10, 11, 12, 1, 2, 3],
    hint: 'Langzaam oogsten door winter.',
  ),
  VegetableMonthActivity(
    vegetableId: 'komkommer',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'courgette',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'aardappel',
    type: GardenTaskType.plantOutdoors,
    months: [4, 5],
  ),
  VegetableMonthActivity(
    vegetableId: 'wittekool',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'wittekool',
    type: GardenTaskType.plantOutdoors,
    months: [6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'wittekool',
    type: GardenTaskType.harvest,
    months: [10, 11, 12],
  ),
  VegetableMonthActivity(
    vegetableId: 'rodekool',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'rodekool',
    type: GardenTaskType.plantOutdoors,
    months: [6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'rodekool',
    type: GardenTaskType.harvest,
    months: [10, 11, 12],
  ),
  VegetableMonthActivity(
    vegetableId: 'bloemkool',
    type: GardenTaskType.preSow,
    months: [3, 4, 5],
  ),
  VegetableMonthActivity(
    vegetableId: 'bloemkool',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'bloemkool',
    type: GardenTaskType.harvest,
    months: [7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'spruitkool',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'spruitkool',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'spruitkool',
    type: GardenTaskType.harvest,
    months: [10, 11, 12, 1],
  ),
  VegetableMonthActivity(
    vegetableId: 'andijvie',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6, 7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'andijvie',
    type: GardenTaskType.harvest,
    months: [6, 7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'paksoi',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6, 7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'paksoi',
    type: GardenTaskType.harvest,
    months: [5, 6, 7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'venkel',
    type: GardenTaskType.preSow,
    months: [3, 4, 5],
  ),
  VegetableMonthActivity(
    vegetableId: 'venkel',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'venkel',
    type: GardenTaskType.harvest,
    months: [8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'bleekselderij',
    type: GardenTaskType.preSow,
    months: [2, 3],
  ),
  VegetableMonthActivity(
    vegetableId: 'bleekselderij',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'bleekselderij',
    type: GardenTaskType.harvest,
    months: [9, 10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'postelein',
    type: GardenTaskType.sowOutdoors,
    months: [5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'postelein',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'tuinkers',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6, 7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'tuinkers',
    type: GardenTaskType.harvest,
    months: [4, 5, 6, 7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'tuinboon',
    type: GardenTaskType.sowOutdoors,
    months: [2, 3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'tuinboon',
    type: GardenTaskType.harvest,
    months: [6, 7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'sugarsnaps',
    type: GardenTaskType.sowOutdoors,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'sugarsnaps',
    type: GardenTaskType.harvest,
    months: [6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'sjalot',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'sjalot',
    type: GardenTaskType.harvest,
    months: [7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'pompoen',
    type: GardenTaskType.preSow,
    months: [4],
  ),
  VegetableMonthActivity(
    vegetableId: 'pompoen',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'pompoen',
    type: GardenTaskType.harvest,
    months: [9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'ijsbergsla',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'ijsbergsla',
    type: GardenTaskType.harvest,
    months: [6, 7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'koolraap',
    type: GardenTaskType.preSow,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'koolraap',
    type: GardenTaskType.plantOutdoors,
    months: [6],
  ),
  VegetableMonthActivity(
    vegetableId: 'koolraap',
    type: GardenTaskType.harvest,
    months: [10, 11, 12, 1, 2],
  ),
  VegetableMonthActivity(
    vegetableId: 'augurk',
    type: GardenTaskType.preSow,
    months: [4],
  ),
  VegetableMonthActivity(
    vegetableId: 'augurk',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'augurk',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'snijbiet',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'snijbiet',
    type: GardenTaskType.harvest,
    months: [6, 7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'artisjok',
    type: GardenTaskType.preSow,
    months: [2, 3],
  ),
  VegetableMonthActivity(
    vegetableId: 'artisjok',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'artisjok',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'zonnebloem',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5],
  ),
  VegetableMonthActivity(
    vegetableId: 'zonnebloem',
    type: GardenTaskType.harvest,
    months: [8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'mango',
    type: GardenTaskType.preSow,
    months: [3, 4, 5],
    hint: 'Pit of jonge plant binnen; min. 18–20 °C en veel licht.',
  ),
  VegetableMonthActivity(
    vegetableId: 'mango',
    type: GardenTaskType.plantOutdoors,
    months: [6, 7, 8],
    hint: 'Alleen op warm terras of in kas.',
  ),
  VegetableMonthActivity(
    vegetableId: 'mango',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
    hint: 'In kas of serre.',
  ),
  VegetableMonthActivity(
    vegetableId: 'avocado',
    type: GardenTaskType.preSow,
    months: [3, 4, 5],
    hint: 'Pit op water of zaaien binnen.',
  ),
  VegetableMonthActivity(
    vegetableId: 'avocado',
    type: GardenTaskType.plantOutdoors,
    months: [6, 7, 8],
    hint: 'Potplant naar buiten na vorst.',
  ),
  VegetableMonthActivity(
    vegetableId: 'avocado',
    type: GardenTaskType.harvest,
    months: [9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'patisson',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'patisson',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'patisson',
    type: GardenTaskType.harvest,
    months: [7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'cayenne_peper',
    type: GardenTaskType.preSow,
    months: [2, 3],
  ),
  VegetableMonthActivity(
    vegetableId: 'cayenne_peper',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'cayenne_peper',
    type: GardenTaskType.harvest,
    months: [8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'pinda',
    type: GardenTaskType.sowOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'pinda',
    type: GardenTaskType.harvest,
    months: [9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'pruim',
    type: GardenTaskType.plantOutdoors,
    months: [3, 11],
    hint: 'Boom planten in rustperiode.',
  ),
  VegetableMonthActivity(
    vegetableId: 'pruim',
    type: GardenTaskType.harvest,
    months: [8, 9],
  ),
  // Extra referentiegroenten (my_garden + atlas)
  VegetableMonthActivity(
    vegetableId: 'ui',
    type: GardenTaskType.preSow,
    months: [2, 3],
    hint: 'Zaaiplanten binnen.',
  ),
  VegetableMonthActivity(
    vegetableId: 'ui',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4],
    hint: 'Plantuien in de tuin.',
  ),
  VegetableMonthActivity(
    vegetableId: 'ui',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'doperwt',
    type: GardenTaskType.sowOutdoors,
    months: [3, 4],
    hint: 'Vroeg in het voorjaar.',
  ),
  VegetableMonthActivity(
    vegetableId: 'doperwt',
    type: GardenTaskType.harvest,
    months: [6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'boerenkool',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'boerenkool',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'boerenkool',
    type: GardenTaskType.harvest,
    months: [10, 11, 12, 1, 2, 3],
  ),
  VegetableMonthActivity(
    vegetableId: 'broccoli',
    type: GardenTaskType.preSow,
    months: [3, 4, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'broccoli',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'broccoli',
    type: GardenTaskType.harvest,
    months: [7, 8, 9, 10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'koolrabi',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'koolrabi',
    type: GardenTaskType.harvest,
    months: [6, 7, 8, 9, 10],
  ),
  VegetableMonthActivity(
    vegetableId: 'pastinaak',
    type: GardenTaskType.sowOutdoors,
    months: [3, 4],
    hint: 'Direct buiten zaaien.',
  ),
  VegetableMonthActivity(
    vegetableId: 'pastinaak',
    type: GardenTaskType.harvest,
    months: [10, 11, 12, 1, 2, 3],
  ),
  VegetableMonthActivity(
    vegetableId: 'raps_kool',
    type: GardenTaskType.preSow,
    months: [4, 5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'raps_kool',
    type: GardenTaskType.plantOutdoors,
    months: [6, 7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'raps_kool',
    type: GardenTaskType.harvest,
    months: [9, 10, 11],
  ),
  VegetableMonthActivity(
    vegetableId: 'knoflook',
    type: GardenTaskType.plantOutdoors,
    months: [10, 11],
    hint: 'Winterteelt: teentjes planten.',
  ),
  VegetableMonthActivity(
    vegetableId: 'knoflook',
    type: GardenTaskType.harvest,
    months: [6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'mais',
    type: GardenTaskType.preSow,
    months: [4, 5],
  ),
  VegetableMonthActivity(
    vegetableId: 'mais',
    type: GardenTaskType.sowOutdoors,
    months: [5, 6],
    hint: 'In blokken zaaien voor bestuiving.',
  ),
  VegetableMonthActivity(
    vegetableId: 'mais',
    type: GardenTaskType.harvest,
    months: [8, 9],
  ),
  // Kruiden
  VegetableMonthActivity(
    vegetableId: 'basilicum',
    type: GardenTaskType.preSow,
    months: [3, 4, 5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'basilicum',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'peterselie',
    type: GardenTaskType.preSow,
    months: [2, 3],
    hint: 'Kiemt traag — geduld.',
  ),
  VegetableMonthActivity(
    vegetableId: 'peterselie',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'dille',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6, 7],
  ),
  VegetableMonthActivity(
    vegetableId: 'tijm',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'tijm',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'munt',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4],
    hint: 'Liever in pot tegen uitlopen.',
  ),
  VegetableMonthActivity(
    vegetableId: 'bieslook',
    type: GardenTaskType.plantOutdoors,
    months: [3, 4],
    hint: 'Pol of stek in voorjaar.',
  ),
  VegetableMonthActivity(
    vegetableId: 'koriander',
    type: GardenTaskType.sowOutdoors,
    months: [4, 5, 6, 7, 8],
    hint: 'Doorzaaien tegen doorschieten.',
  ),
  VegetableMonthActivity(
    vegetableId: 'salie',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'salie',
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'oregano',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'oregano',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'rozemarijn',
    type: GardenTaskType.preSow,
    months: [3, 4],
  ),
  VegetableMonthActivity(
    vegetableId: 'rozemarijn',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
    hint: 'Beschut of op zuidmuur.',
  ),
  // Paddestoelen (binnen)
  VegetableMonthActivity(
    vegetableId: 'shiitake',
    type: GardenTaskType.preSow,
    months: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    hint: 'Substraat inoculeren binnen.',
  ),
  VegetableMonthActivity(
    vegetableId: 'oesterzwam',
    type: GardenTaskType.preSow,
    months: [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12],
    hint: 'Het hele jaar binnen op substraa.',
  ),
  VegetableMonthActivity(
    vegetableId: 'kastanjechampignon',
    type: GardenTaskType.preSow,
    months: [1, 2, 3, 4, 5, 9, 10, 11, 12],
    hint: 'Donkere, koele ruimte binnen.',
  ),
];

class MonthTaskEntry {
  const MonthTaskEntry({
    required this.vegetableId,
    required this.tasks,
  });

  final String vegetableId;
  final List<VegetableMonthActivity> tasks;
}

List<VegetableMonthActivity>? _mergedCalendarCache;

/// Cache legen na database-uitbreiding (tests / hot reload).
void invalidatePlantingCalendarCache() {
  _mergedCalendarCache = null;
}

List<VegetableMonthActivity> _baseCalendarEntries() => [
      ...kPlantingCalendar,
      ...kPlantingCalendarSupplement,
    ];

/// Alle zaai-/plant-/oogstregels voor elk gewas in de database.
List<VegetableMonthActivity> allPlantingCalendarActivities() {
  if (_mergedCalendarCache != null) return _mergedCalendarCache!;

  final out = <VegetableMonthActivity>[];
  final base = _baseCalendarEntries();

  for (final vegetable in kVegetablesSeed) {
    final explicit =
        base.where((a) => a.vegetableId == vegetable.id).toList();
    if (explicit.isNotEmpty) {
      out.addAll(explicit);
    } else {
      out.addAll(defaultCalendarActivitiesFor(vegetable));
    }
  }

  _mergedCalendarCache = List.unmodifiable(out);
  return _mergedCalendarCache!;
}

/// Taaktypes die in deze maand minstens één gewas hebben.
List<GardenTaskType> taskTypesForMonth(int month) {
  final types = <GardenTaskType>{};
  for (final a in allPlantingCalendarActivities()) {
    if (a.months.contains(month)) types.add(a.type);
  }
  return types.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}

List<MonthTaskEntry> monthTasksFor(int month, {GardenTaskType? taskFilter}) {
  final byId = <String, List<VegetableMonthActivity>>{};
  for (final a in allPlantingCalendarActivities()) {
    if (!a.months.contains(month)) continue;
    if (taskFilter != null && a.type != taskFilter) continue;
    byId.putIfAbsent(a.vegetableId, () => []).add(a);
  }

  final entries = byId.entries.map((e) {
    final tasks = List<VegetableMonthActivity>.from(e.value)
      ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));
    return MonthTaskEntry(vegetableId: e.key, tasks: tasks);
  }).toList();

  entries.sort((a, b) => a.vegetableId.compareTo(b.vegetableId));
  return entries;
}

/// Activiteiten op een specifieke dag (voor kalenderweergave).
List<VegetableMonthActivity> activitiesOnCalendarDay(
  int month,
  int day, {
  Set<String>? onlyVegetableIds,
}) {
  return allPlantingCalendarActivities().where((a) {
    if (!a.months.contains(month)) return false;
    if (activityCalendarDay(a) != day) return false;
    if (onlyVegetableIds != null &&
        !onlyVegetableIds.contains(a.vegetableId)) {
      return false;
    }
    return true;
  }).toList();
}

int daysInMonth(int year, int month) {
  return DateTime(year, month + 1, 0).day;
}

const List<String> kMonthNamesNl = [
  '',
  'januari',
  'februari',
  'maart',
  'april',
  'mei',
  'juni',
  'juli',
  'augustus',
  'september',
  'oktober',
  'november',
  'december',
];

const List<String> kWeekdayLabelsNl = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];
