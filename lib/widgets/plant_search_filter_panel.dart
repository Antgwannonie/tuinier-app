import 'package:flutter/material.dart';

import '../data/plant_search_filters.dart';
import 'plant_guide_filter_sheet.dart';

/// Inklapbare filterblokken voor het zoekscherm (compact).
class PlantSearchFilterPanel extends StatelessWidget {
  const PlantSearchFilterPanel({
    super.key,
    required this.criteria,
    required this.onChanged,
  });

  final PlantSearchCriteria criteria;
  final ValueChanged<PlantSearchCriteria> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerLowest.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
        child: PlantGuideFilterSections(
          criteria: criteria,
          onChanged: onChanged,
        ),
      ),
    );
  }
}
