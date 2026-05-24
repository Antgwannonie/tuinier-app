import 'planting_calendar.dart';

/// Volgende of huidige tuinactie voor aftellen in Mijn moestuin.
class VegetableGardenStatus {
  const VegetableGardenStatus({
    required this.activity,
    required this.daysUntil,
    required this.isActiveNow,
    required this.periodStart,
    required this.periodEnd,
  });

  final VegetableMonthActivity activity;
  final int daysUntil;
  final bool isActiveNow;
  final DateTime periodStart;
  final DateTime periodEnd;

  String get actionShort => activity.type.shortLabel;

  String get countdownLine {
    if (isActiveNow) return 'Nu: $actionShort';
    if (daysUntil == 1) return 'Over 1 dag: $actionShort';
    return 'Over $daysUntil dagen: $actionShort';
  }
}

extension GardenTaskTypeShortLabel on GardenTaskType {
  String get shortLabel {
    switch (this) {
      case GardenTaskType.preSow:
        return 'Voorzaaien';
      case GardenTaskType.sowOutdoors:
        return 'Zaaien buiten';
      case GardenTaskType.plantOutdoors:
        return 'Planten';
      case GardenTaskType.harvest:
        return 'Oogsten';
    }
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

DateTime _periodStart(int year, VegetableMonthActivity activity, int month) {
  final day = activityCalendarDay(activity).clamp(1, daysInMonth(year, month));
  return DateTime(year, month, day);
}

/// Huidige of eerstvolgende actie voor een groente in de kalender.
VegetableGardenStatus? gardenStatusFor(String vegetableId, [DateTime? reference]) {
  final today = _dateOnly(reference ?? DateTime.now());
  final year = today.year;

  final activities = kPlantingCalendar
      .where((a) => a.vegetableId == vegetableId)
      .toList();
  if (activities.isEmpty) return null;

  VegetableGardenStatus? activeBest;
  VegetableGardenStatus? futureBest;
  int? futureDays;

  for (final y in [year, year + 1]) {
    for (final activity in activities) {
      for (final month in activity.months) {
        final start = _periodStart(y, activity, month);
        final end = DateTime(y, month, daysInMonth(y, month));

        if (!today.isBefore(start) && !today.isAfter(end)) {
          final candidate = VegetableGardenStatus(
            activity: activity,
            daysUntil: 0,
            isActiveNow: true,
            periodStart: start,
            periodEnd: end,
          );
          if (activeBest == null ||
              activity.type.sortOrder < activeBest.activity.type.sortOrder) {
            activeBest = candidate;
          }
          continue;
        }

        if (start.isAfter(today)) {
          final days = start.difference(today).inDays;
          if (futureDays == null || days < futureDays) {
            futureDays = days;
            futureBest = VegetableGardenStatus(
              activity: activity,
              daysUntil: days,
              isActiveNow: false,
              periodStart: start,
              periodEnd: end,
            );
          }
        }
      }
    }
  }

  return activeBest ?? futureBest;
}

/// Sorteer: eerst klaar voor actie, daarna op aantal dagen.
int compareGardenStatus(
  VegetableGardenStatus? a,
  VegetableGardenStatus? b,
) {
  if (a == null && b == null) return 0;
  if (a == null) return 1;
  if (b == null) return -1;
  if (a.isActiveNow != b.isActiveNow) {
    return a.isActiveNow ? -1 : 1;
  }
  return a.daysUntil.compareTo(b.daysUntil);
}
