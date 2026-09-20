import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_sowing_guide.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'plant_sowing_detail_screen.dart';
import 'sowing_illustrations.dart';

/// Zaaien-tab: kaarten met samenvatting; tik voor uitgebreide info.
class PlantSowingGuideView extends StatelessWidget {
  const PlantSowingGuideView({
    super.key,
    required this.guide,
  });

  final PlantSowingGuide guide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < guide.sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _SowingGuideCard(section: guide.sections[i]),
        ],
        if (guide.alerts.isNotEmpty) ...[
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < guide.alerts.length; i++) ...[
                if (i > 0) const SizedBox(width: 10),
                Expanded(child: _SowingAlertCard(alert: guide.alerts[i])),
              ],
            ],
          ),
        ],
      ],
    );
  }
}

class _SowingGuideCard extends StatelessWidget {
  const _SowingGuideCard({required this.section});

  final PlantSowingGuideSection section;

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PlantSowingDetailScreen(section: section),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final hasTable = section.whenText != null || section.howText != null;
    final hasTimeline =
        section.sowMonths != null && section.sowMonths!.isNotEmpty;
    final tappable = section.hasDetailPage;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          section.title,
          style: t.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          section.summary,
          style: t.textTheme.bodyMedium?.copyWith(
            height: 1.4,
            color: const Color(PlantDetailDesign.textSecondary),
          ),
        ),
        if (hasTable) ...[
          const SizedBox(height: 14),
          const Row(
            children: [
              Expanded(child: _TableHeader(label: 'Wanneer')),
              SizedBox(width: 8),
              Expanded(child: _TableHeader(label: 'Hoe')),
            ],
          ),
          const SizedBox(height: 8),
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _TableCell(text: section.whenText ?? '—'),
                ),
                Container(
                  width: 1,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  color: const Color(PlantDetailDesign.border),
                ),
                Expanded(
                  child: _TableCell(text: section.howText ?? '—'),
                ),
              ],
            ),
          ),
        ],
        if (hasTimeline) ...[
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
        if (section.illustration != null) ...[
          const SizedBox(height: 16),
          SowingIllustration(kind: section.illustration!),
        ],
        if (tappable) const GuideMeerInfoFooter(margin: EdgeInsets.only(top: 12)),
      ],
    );

    if (!tappable) {
      return PlantDetailCard(child: content);
    }

    return PlantDetailCard(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _openDetail(context),
          borderRadius: BorderRadius.circular(12),
          child: content,
        ),
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  const _TableHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
    );
  }
}

class _TableCell extends StatelessWidget {
  const _TableCell({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodySmall?.copyWith(
            height: 1.35,
            color: const Color(PlantDetailDesign.textPrimary),
          ),
    );
  }
}

class _SowingAlertCard extends StatelessWidget {
  const _SowingAlertCard({required this.alert});

  final PlantSowingAlert alert;

  @override
  Widget build(BuildContext context) {
    final isFrost = alert.kind == PlantSowingAlertKind.frost;
    final bg = isFrost ? const Color(0xFFFFF1F2) : const Color(0xFFEEF6EE);
    final fg = isFrost ? const Color(0xFFBE123C) : const Color(0xFF2D472B);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            alert.title,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13,
              color: fg,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            alert.body,
            style: TextStyle(
              fontSize: 12,
              height: 1.35,
              color: fg.withValues(alpha: 0.9),
            ),
          ),
        ],
      ),
    );
  }
}
