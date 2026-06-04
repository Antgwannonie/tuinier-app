import 'package:flutter/material.dart';

import '../data/plant_quick_summary.dart';
import 'plant_detail_section.dart';

/// Korte samenvatting bovenaan de infopagina.
class PlantQuickSummaryCard extends StatelessWidget {
  const PlantQuickSummaryCard({
    super.key,
    required this.summary,
  });

  final PlantQuickSummary summary;

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
              Icon(
                summary.isCompanion ? Icons.eco_outlined : Icons.info_outline,
                size: 20,
                color: cs.primary,
              ),
              const SizedBox(width: 8),
              Text(
                summary.isCompanion ? 'Nut in de moestuin' : 'In het kort',
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            summary.headline,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: cs.onSurface,
            ),
          ),
          if (summary.benefitTags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: summary.benefitTags.map((tag) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: cs.tertiaryContainer.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: t.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
          if (summary.points.isNotEmpty) ...[
            const SizedBox(height: 8),
            Divider(
              height: 1,
              color: cs.outlineVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 4),
            ...summary.points.map(
              (p) => PlantDetailFactRow(
                label: p.label,
                value: p.value,
                icon: p.icon,
              ),
            ),
          ],
          if (summary.tip != null) ...[
            const SizedBox(height: 4),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                summary.tip!,
                style: t.textTheme.bodySmall?.copyWith(
                  height: 1.35,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
          if (summary.seasonEnded) ...[
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: cs.errorContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Zaai-/plantseizoen is voorbij. Bewaar dit gewas voor volgend jaar.',
                style: t.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: cs.onErrorContainer,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
