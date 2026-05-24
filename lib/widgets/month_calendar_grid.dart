import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../models/garden_personal_event.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_calendar.dart';
import '../data/vegetable_repository.dart';
import 'calendar_day_cell.dart';

/// Maandraster dat de beschikbare hoogte vult (vaste rijhoogte, geen overflow).
class MonthCalendarGrid extends StatelessWidget {
  const MonthCalendarGrid({
    super.key,
    required this.month,
    required this.year,
    this.gardenVegetableIds,
    this.profileStore,
    this.gardenStore,
    this.repository,
    this.scanPrefs,
    required this.onDayTap,
  });

  final int month;
  final int year;
  final Set<String>? gardenVegetableIds;
  final GardenProfileStore? profileStore;
  final MyGardenStore? gardenStore;
  final VegetableRepository? repository;
  final GardenScanPrefsStore? scanPrefs;
  final void Function(
    int day,
    List<VegetableMonthActivity> activities,
    List<GardenPersonalEvent> personalEvents,
  ) onDayTap;

  static const double _spacing = 5;

  @override
  Widget build(BuildContext context) {
    final totalDays = daysInMonth(year, month);
    final firstWeekday = DateTime(year, month, 1).weekday;
    final leadingBlanks = firstWeekday - 1;
    final cellCount = leadingBlanks + totalDays;
    final rowCount = (cellCount + 6) ~/ 7;

    return LayoutBuilder(
      builder: (context, constraints) {
        final rowHeight =
            (constraints.maxHeight - _spacing * (rowCount - 1)) / rowCount;
        final cellHeight = rowHeight.clamp(48.0, 140.0);

        return GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            crossAxisSpacing: _spacing,
            mainAxisSpacing: _spacing,
            mainAxisExtent: cellHeight,
          ),
          itemCount: cellCount,
          itemBuilder: (context, index) {
            if (index < leadingBlanks) {
              return const SizedBox.shrink();
            }
            final day = index - leadingBlanks + 1;
            final activities = activitiesOnCalendarDay(
              month,
              day,
              onlyVegetableIds: gardenVegetableIds,
            );
            final personal = profileStore != null &&
                    gardenStore != null &&
                    repository != null &&
                    scanPrefs != null
                ? personalEventsOnDay(
                    year: year,
                    month: month,
                    day: day,
                    profileStore: profileStore!,
                    gardenStore: gardenStore!,
                    vegetableById: (id) => repository!.byId(id),
                    daysUntilFirstPhoto: scanPrefs!.daysUntilFirstPhoto,
                    weeklyScanIntervalDays: scanPrefs!.weeklyScanIntervalDays,
                  )
                : <GardenPersonalEvent>[];
            final now = DateTime.now();
            final isToday =
                now.year == year && now.month == month && now.day == day;

            return CalendarDayCell(
              day: day,
              activities: activities,
              personalEvents: personal,
              isToday: isToday,
              onTap: activities.isEmpty && personal.isEmpty
                  ? null
                  : () => onDayTap(day, activities, personal),
            );
          },
        );
      },
    );
  }
}
