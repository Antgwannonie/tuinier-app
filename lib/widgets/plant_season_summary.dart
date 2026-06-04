import 'package:flutter/material.dart';

import '../data/planting_season_status.dart';

/// Seizoensstatus en type gewas onder de planttitel (detailpagina).
class PlantSeasonSummary extends StatelessWidget {
  const PlantSeasonSummary({
    super.key,
    required this.advice,
    this.growthCategory,
  });

  final PlantingSeasonAdvice advice;
  final String? growthCategory;

  @override
  Widget build(BuildContext context) {
    final season = advice.shortLabel.trim();
    final category = growthCategory?.trim() ?? '';
    if (season.isEmpty && category.isEmpty) {
      return const SizedBox.shrink();
    }

    final t = Theme.of(context);
    final cs = t.colorScheme;
    final ended = advice.isSeasonEnded;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (season.isNotEmpty)
          Text(
            season,
            style: t.textTheme.titleSmall?.copyWith(
              color: ended
                  ? cs.onSurfaceVariant
                  : cs.primary,
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        if (category.isNotEmpty) ...[
          if (season.isNotEmpty) const SizedBox(height: 4),
          Text(
            category,
            style: t.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
  }
}
