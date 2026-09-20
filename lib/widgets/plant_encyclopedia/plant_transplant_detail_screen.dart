import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_transplant_guide.dart';
import 'plant_detail_widgets.dart';
import 'transplant_illustrations.dart';

const _transplantGreen = Color(PlantDetailDesign.primaryGreen);

/// Detailpagina bij tikken op een Uitplanten-kop.
class PlantTransplantDetailScreen extends StatelessWidget {
  const PlantTransplantDetailScreen({super.key, required this.section});

  final PlantTransplantSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: const Color(PlantDetailDesign.textPrimary),
        elevation: 0,
        title: Text(
          section.title,
          style: t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: _transplantGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (section.illustration != null) ...[
            TransplantIllustration(kind: section.illustration!),
            const SizedBox(height: 16),
          ],
          if (section.summary != null && section.summary!.isNotEmpty)
            Text(
              section.summary!,
              style: t.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
          if (section.months != null && section.months!.isNotEmpty) ...[
            const SizedBox(height: 16),
            PlantMonthTimelineRow(
              timeline: PlantMonthTimeline(
                label: section.title,
                months: section.months!,
              ),
              compact: true,
              comfortable: true,
            ),
          ],
          if (section.items != null && section.items!.isNotEmpty) ...[
            const SizedBox(height: 16),
            for (final item in section.items!) ...[
              _DetailListRow(item: item),
              const SizedBox(height: 6),
            ],
          ],
          if (section.steps != null && section.steps!.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final step in section.steps!)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Text('• $step', style: t.textTheme.bodyMedium),
              ),
          ],
          const SizedBox(height: 20),
          for (final block in section.details) ...[
            Text(
              block.heading,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: _transplantGreen,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              block.body,
              style: t.textTheme.bodyMedium?.copyWith(
                height: 1.55,
                fontSize: 14,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ],
      ),
    );
  }
}

class _DetailListRow extends StatelessWidget {
  const _DetailListRow({required this.item});
  final TransplantListItem item;

  @override
  Widget build(BuildContext context) {
    final isCross = item.marker == TransplantListMarker.cross;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          isCross ? Icons.close_rounded : Icons.check_rounded,
          size: 18,
          color: isCross ? const Color(0xFFEF4444) : _transplantGreen,
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(item.text)),
      ],
    );
  }
}
