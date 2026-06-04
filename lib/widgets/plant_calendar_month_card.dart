import 'package:flutter/material.dart';

import '../data/planting_calendar.dart';
import 'plant_detail_section.dart';

/// Compacte kalenderregels voor de huidige maand op de detailpagina.
class PlantCalendarMonthCard extends StatelessWidget {
  const PlantCalendarMonthCard({
    super.key,
    required this.monthName,
    required this.tasks,
  });

  final String monthName;
  final List<VegetableMonthActivity> tasks;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return PlantDetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.calendar_month_outlined, size: 20, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Kalender · $monthName',
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...tasks.map((a) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(_icon(a.type), size: 20, color: cs.primary),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          a.type.label,
                          style: t.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        if (a.hint != null && a.hint!.trim().isNotEmpty)
                          Text(
                            a.hint!,
                            style: t.textTheme.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              height: 1.35,
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _icon(GardenTaskType type) {
    switch (type) {
      case GardenTaskType.plantOutdoors:
        return Icons.yard_outlined;
      case GardenTaskType.sowOutdoors:
        return Icons.grass_outlined;
      case GardenTaskType.preSow:
        return Icons.spa_outlined;
      case GardenTaskType.harvest:
        return Icons.shopping_basket_outlined;
    }
  }
}
