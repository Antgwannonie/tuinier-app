import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_sowing_guide.dart';
import 'plant_detail_widgets.dart';
import 'sowing_illustrations.dart';

const _sowingGreen = Color(PlantDetailDesign.primaryGreen);

/// Detailpagina bij tikken op een Zaaien-kop.
class PlantSowingDetailScreen extends StatelessWidget {
  const PlantSowingDetailScreen({super.key, required this.section});

  final PlantSowingGuideSection section;

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
            color: _sowingGreen,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          if (section.illustration != null) ...[
            SowingIllustration(kind: section.illustration!),
            const SizedBox(height: 16),
          ],
          Text(
            section.summary,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
          if (section.whenText != null || section.howText != null) ...[
            const SizedBox(height: 16),
            _InfoRow(label: 'Wanneer', value: section.whenText ?? '—'),
            const SizedBox(height: 8),
            _InfoRow(label: 'Hoe', value: section.howText ?? '—'),
          ],
          if (section.sowMonths != null && section.sowMonths!.isNotEmpty) ...[
            const SizedBox(height: 16),
            PlantMonthTimelineRow(
              timeline: PlantMonthTimeline(
                label: section.title,
                months: section.sowMonths!,
              ),
              compact: true,
              comfortable: true,
            ),
          ],
          const SizedBox(height: 20),
          for (final block in section.details) ...[
            Text(
              block.heading,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: _sowingGreen,
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

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7F4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: t.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: _sowingGreen,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
