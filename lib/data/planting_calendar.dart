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
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
    hint: 'Zaaien of planten; snelle oogst binnen ~5 weken.',
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
    type: GardenTaskType.plantOutdoors,
    months: [5],
  ),
  VegetableMonthActivity(
    vegetableId: 'bosui',
    type: GardenTaskType.harvest,
    months: [7, 8],
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
    type: GardenTaskType.plantOutdoors,
    months: [6],
    hint: 'Pas na ijsheiligen / half juni.',
  ),
  VegetableMonthActivity(
    vegetableId: 'bonen_sperzie',
    type: GardenTaskType.harvest,
    months: [7, 8, 9],
  ),
  VegetableMonthActivity(
    vegetableId: 'snijbonen',
    type: GardenTaskType.plantOutdoors,
    months: [6],
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
    type: GardenTaskType.harvest,
    months: [4, 5, 6],
    hint: 'Stop oogst vóór juli.',
  ),
  VegetableMonthActivity(
    vegetableId: 'asperge',
    type: GardenTaskType.harvest,
    months: [4, 5, 6],
  ),
  VegetableMonthActivity(
    vegetableId: 'prei',
    type: GardenTaskType.plantOutdoors,
    months: [5, 6],
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
    vegetableId: 'lente_ui',
    type: GardenTaskType.sowOutdoors,
    months: [3, 4, 5, 6, 7, 8],
  ),
  VegetableMonthActivity(
    vegetableId: 'lente_ui',
    type: GardenTaskType.harvest,
    months: [5, 6, 7, 8, 9, 10],
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

/// Taaktypes die in deze maand minstens één gewas hebben.
List<GardenTaskType> taskTypesForMonth(int month) {
  final types = <GardenTaskType>{};
  for (final a in kPlantingCalendar) {
    if (a.months.contains(month)) types.add(a.type);
  }
  return types.toList()..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));
}

List<MonthTaskEntry> monthTasksFor(int month, {GardenTaskType? taskFilter}) {
  final byId = <String, List<VegetableMonthActivity>>{};
  for (final a in kPlantingCalendar) {
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
  return kPlantingCalendar.where((a) {
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
