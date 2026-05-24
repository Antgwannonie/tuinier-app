import 'package:flutter/material.dart';

import '../data/planting_calendar.dart';
import '../data/vegetable_image_info.dart';
import '../models/garden_personal_event.dart';

/// Eén dag in de maandkalender — past zich aan de celgrootte aan (geen overflow).
class CalendarDayCell extends StatelessWidget {
  const CalendarDayCell({
    super.key,
    required this.day,
    required this.activities,
    this.personalEvents = const [],
    required this.isToday,
    this.onTap,
  });

  final int day;
  final List<VegetableMonthActivity> activities;
  final List<GardenPersonalEvent> personalEvents;
  final bool isToday;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final uniqueIds = <String>{};
    for (final a in activities) {
      uniqueIds.add(a.vegetableId);
      if (uniqueIds.length >= 3) break;
    }
    final emojis =
        uniqueIds.map((id) => vegetableImageFor(id).emoji).toList();
    final personalMarks = personalEvents
        .map((e) => e.type.emoji)
        .toSet()
        .take(2)
        .join();

    final hasContent = activities.isNotEmpty || personalEvents.isNotEmpty;

    final bg = isToday
        ? t.colorScheme.primaryContainer
        : hasContent
            ? t.colorScheme.secondaryContainer.withValues(alpha: 0.45)
            : t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35);

    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(10),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                '$day',
                textAlign: TextAlign.center,
                maxLines: 1,
                style: t.textTheme.labelMedium?.copyWith(
                  fontWeight: isToday ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 12,
                ),
              ),
              Expanded(
                child: !hasContent
                    ? const SizedBox.shrink()
                    : FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (emojis.isNotEmpty)
                              Text(
                                emojis.join(),
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontSize: 14,
                                  height: 1.1,
                                ),
                              ),
                            if (personalMarks.isNotEmpty)
                              Text(
                                personalMarks,
                                style: const TextStyle(fontSize: 11),
                              ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
