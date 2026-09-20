import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_transplant_guide.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'plant_transplant_detail_screen.dart';
import 'transplant_illustrations.dart';

/// Uitplanten-tab: kaarten met samenvatting; tik voor uitgebreide info.
class PlantTransplantGuideView extends StatelessWidget {
  const PlantTransplantGuideView({super.key, required this.guide});

  final PlantTransplantGuide guide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < guide.rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _TransplantRowWidget(
                row: guide.rows[i],
                maxWidth: constraints.maxWidth,
              ),
            ],
          ],
        );
      },
    );
  }
}

Widget _wrapCard(BuildContext context, PlantTransplantSection section, Widget child) {
  if (!section.hasDetailPage) {
    return PlantDetailCard(child: child);
  }
  return PlantDetailCard(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => PlantTransplantDetailScreen(section: section),
            ),
          );
        },
        child: child,
      ),
    ),
  );
}

class _TransplantRowWidget extends StatelessWidget {
  const _TransplantRowWidget({
    required this.row,
    required this.maxWidth,
  });

  final PlantTransplantRow row;
  final double maxWidth;

  bool get _stackColumns3 => maxWidth < 520;
  bool get _stackColumns2 => maxWidth < 280;
  bool get _stackSplit => maxWidth < 560;

  @override
  Widget build(BuildContext context) {
    switch (row.kind) {
      case PlantTransplantRowKind.single:
      case PlantTransplantRowKind.iconRow:
        final section = row.sections.first;
        return _wrapCard(
          context,
          section,
          _TransplantSectionContent(
            section: section,
            imageOnSide: section.illustrationSize ==
                    TransplantIllustrationSize.large &&
                maxWidth >= 480,
          ),
        );
      case PlantTransplantRowKind.split:
        final main = row.sections.first;
        if (_stackSplit) {
          return _wrapCard(
            context,
            main,
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TransplantSectionContent(section: main),
                if (row.sections.length > 1 &&
                    row.sections[1].illustration != null) ...[
                  const SizedBox(height: 16),
                  TransplantIllustration(
                    kind: row.sections[1].illustration!,
                    size: row.sections[1].illustrationSize,
                  ),
                ],
              ],
            ),
          );
        }
        return _wrapCard(
          context,
          main,
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _TransplantSectionContent(section: main),
              ),
              if (row.sections.length > 1 &&
                  row.sections[1].illustration != null) ...[
                const SizedBox(width: 12),
                Expanded(
                  child: TransplantIllustration(
                    kind: row.sections[1].illustration!,
                    size: row.sections[1].illustrationSize,
                  ),
                ),
              ],
            ],
          ),
        );
      case PlantTransplantRowKind.columns2:
        return _buildColumns(
          context,
          row.sections,
          2,
          _stackColumns2,
          compact: false,
        );
      case PlantTransplantRowKind.columns2Compact:
        return _buildColumns(
          context,
          row.sections,
          2,
          _stackColumns2,
          compact: true,
        );
      case PlantTransplantRowKind.columns3:
        return _buildColumns(
          context,
          row.sections,
          3,
          _stackColumns3,
          compact: false,
        );
      case PlantTransplantRowKind.timingGroup:
        return _buildTimingGroup(context, row.sections);
      case PlantTransplantRowKind.alerts:
        final alerts = row.alerts ?? const [];
        if (alerts.isEmpty) return const SizedBox.shrink();
        if (_stackColumns2) {
          return Column(
            children: [
              for (var i = 0; i < alerts.length; i++) ...[
                if (i > 0) const SizedBox(height: 10),
                _TransplantAlertCard(alert: alerts[i]),
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < alerts.length; i++) ...[
              if (i > 0) const SizedBox(width: 10),
              Expanded(child: _TransplantAlertCard(alert: alerts[i])),
            ],
          ],
        );
    }
  }

  Widget _buildTimingGroup(
    BuildContext context,
    List<PlantTransplantSection> sections,
  ) {
    if (sections.length < 3) {
      return _buildColumns(context, sections, 2, _stackColumns2, compact: true);
    }

    final top = sections.take(2).toList();
    final mistakes = sections[2];

    return Column(
      children: [
        _buildColumns(context, top, 2, _stackColumns2, compact: true),
        const SizedBox(height: 12),
        _wrapCard(
          context,
          mistakes,
          _TransplantSectionContent(
            section: mistakes,
            imageOnSide: maxWidth >= 480,
          ),
        ),
      ],
    );
  }

  Widget _buildColumns(
    BuildContext context,
    List<PlantTransplantSection> sections,
    int count,
    bool stack, {
    required bool compact,
  }) {
    final items = sections.take(count).toList();
    if (stack) {
      return Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _wrapCard(
              context,
              items[i],
              _TransplantSectionContent(
                section: items[i],
                forceCompactImage: compact,
              ),
            ),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _wrapCard(
              context,
              items[i],
              _TransplantSectionContent(
                section: items[i],
                forceCompactImage: compact,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _TransplantSectionContent extends StatelessWidget {
  const _TransplantSectionContent({
    required this.section,
    this.forceCompactImage = false,
    this.imageOnSide = false,
  });

  final PlantTransplantSection section;
  final bool forceCompactImage;
  final bool imageOnSide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final hasTitle = section.title.isNotEmpty;
    final imageSize = forceCompactImage
        ? TransplantIllustrationSize.compact
        : section.illustrationSize;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (hasTitle)
          Text(
            section.title,
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          if (hasTitle) const SizedBox(height: 6),
          Text(
            section.summary!,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.4,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
        if (section.months != null && section.months!.isNotEmpty) ...[
          const SizedBox(height: 14),
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
          const SizedBox(height: 10),
          ...section.items!.map((item) => _ListItemRow(item: item)),
        ],
        if (section.steps != null && section.steps!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: section.steps!.map((step) {
              return Text(
                step,
                style: t.textTheme.labelSmall?.copyWith(
                  color: const Color(PlantDetailDesign.textPrimary),
                  fontWeight: FontWeight.w500,
                ),
              );
            }).toList(),
          ),
        ],
        if (section.chips != null && section.chips!.isNotEmpty) ...[
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            alignment: WrapAlignment.start,
            children: section.chips!.map((chip) {
              return SizedBox(
                width: 64,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      transplantChipIcon(chip.icon),
                      size: 26,
                      color: const Color(PlantDetailDesign.primaryGreen),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      chip.label,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: t.textTheme.labelSmall?.copyWith(
                        fontSize: 10,
                        height: 1.2,
                        color: const Color(PlantDetailDesign.textPrimary),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
        if (section.hasDetailPage)
          const GuideMeerInfoFooter(margin: EdgeInsets.only(top: 12)),
      ],
    );

    if (section.illustration == null) return textBlock;

    final illustration = TransplantIllustration(
      kind: section.illustration!,
      size: imageSize,
    );

    if (imageOnSide) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: textBlock),
          const SizedBox(width: 12),
          Expanded(child: illustration),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        textBlock,
        const SizedBox(height: 12),
        illustration,
      ],
    );
  }
}

class _ListItemRow extends StatelessWidget {
  const _ListItemRow({required this.item});

  final TransplantListItem item;

  @override
  Widget build(BuildContext context) {
    final isCross = item.marker == TransplantListMarker.cross;
    final color = isCross
        ? const Color(0xFFEF4444)
        : const Color(PlantDetailDesign.primaryGreen);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            isCross ? Icons.close_rounded : Icons.check_rounded,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    height: 1.4,
                    color: const Color(PlantDetailDesign.textPrimary),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TransplantAlertCard extends StatelessWidget {
  const _TransplantAlertCard({required this.alert});

  final PlantTransplantAlert alert;

  @override
  Widget build(BuildContext context) {
    const accent = Color(PlantDetailDesign.primaryGreen);
    const bg = Color(0xFFF0FDF4);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(transplantChipIcon(alert.icon), size: 20, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: accent,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  alert.body,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        height: 1.35,
                        color: const Color(PlantDetailDesign.textPrimary),
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
