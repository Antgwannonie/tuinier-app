import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_water_guide.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'water_illustrations.dart';

/// Water-tab volgens mockup: gauge, splits, kolommen en AI-advies.
class PlantWaterGuideView extends StatelessWidget {
  const PlantWaterGuideView({super.key, required this.guide});

  final PlantWaterGuide guide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < guide.rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _WaterRowWidget(
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

Widget _wrapWaterCard(
  BuildContext context,
  PlantWaterSection section,
  Widget child,
) {
  return PlantDetailCard(
    child: wrapGuideDetailCard(
      context: context,
      title: section.title,
      summary: section.summary ?? section.subtitle,
      details: section.details,
      child: child,
    ),
  );
}

class _WaterRowWidget extends StatelessWidget {
  const _WaterRowWidget({
    required this.row,
    required this.maxWidth,
  });

  final PlantWaterRow row;
  final double maxWidth;

  bool get _stackColumns2 => maxWidth < 300;
  bool get _stackSplit => maxWidth < 520;

  @override
  Widget build(BuildContext context) {
    switch (row.kind) {
      case PlantWaterRowKind.waterNeed:
        return _wrapWaterCard(
          context,
          row.sections.first,
          _WaterNeedSection(section: row.sections.first),
        );
      case PlantWaterRowKind.split:
        return _wrapWaterCard(
          context,
          row.sections.first,
          _SplitSection(
            section: row.sections.first,
            stack: _stackSplit,
          ),
        );
      case PlantWaterRowKind.columns2:
        return _buildColumns(context, row.sections);
      case PlantWaterRowKind.waterQuality:
        return _wrapWaterCard(
          context,
          row.sections.first,
          _WaterQualitySection(
            section: row.sections.first,
            stack: _stackSplit,
          ),
        );
      case PlantWaterRowKind.alert:
        final alert = row.alert;
        if (alert == null) return const SizedBox.shrink();
        return _WaterAlertCard(alert: alert);
    }
  }

  Widget _buildColumns(BuildContext context, List<PlantWaterSection> sections) {
    if (_stackColumns2) {
      return Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _wrapWaterCard(
              context,
              sections[i],
              _WaterSectionContent(section: sections[i]),
            ),
          ],
        ],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _wrapWaterCard(
              context,
              sections[i],
              _WaterSectionContent(section: sections[i]),
            ),
          ),
        ],
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.subtitle});

  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
        ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: t.textTheme.bodySmall?.copyWith(
              height: 1.35,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

class _WaterNeedSection extends StatelessWidget {
  const _WaterNeedSection({required this.section});

  final PlantWaterSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                section.summary ?? '',
                style: t.textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: const Color(PlantDetailDesign.textPrimary),
                ),
              ),
            ),
            const SizedBox(width: 12),
            _WaterNeedGauge(level: section.waterNeed ?? WaterNeedLevel.medium),
          ],
        ),
      ],
    );
  }
}

class _WaterNeedGauge extends StatelessWidget {
  const _WaterNeedGauge({required this.level});

  final WaterNeedLevel level;

  double get _needleValue => switch (level) {
        WaterNeedLevel.low => 0.18,
        WaterNeedLevel.medium => 0.5,
        WaterNeedLevel.high => 0.82,
      };

  String get _label => switch (level) {
        WaterNeedLevel.low => 'Laag',
        WaterNeedLevel.medium => 'Gemiddeld',
        WaterNeedLevel.high => 'Hoog',
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SizedBox(
      width: 128,
      child: Column(
        children: [
          SizedBox(
            height: 72,
            width: 128,
            child: CustomPaint(
              painter: _GaugePainter(needleValue: _needleValue),
              size: const Size(128, 72),
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(PlantDetailDesign.primaryGreen)
                    .withValues(alpha: 0.35),
              ),
            ),
            child: Text(
              _label,
              textAlign: TextAlign.center,
              style: t.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _ScaleLabel(
                text: 'Laag',
                active: level == WaterNeedLevel.low,
              ),
              _ScaleLabel(
                text: 'Gemiddeld',
                active: level == WaterNeedLevel.medium,
              ),
              _ScaleLabel(
                text: 'Hoog',
                active: level == WaterNeedLevel.high,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScaleLabel extends StatelessWidget {
  const _ScaleLabel({required this.text, required this.active});

  final String text;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        text,
        textAlign: TextAlign.center,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontSize: 8,
              fontWeight: active ? FontWeight.w700 : FontWeight.w500,
              color: active
                  ? const Color(PlantDetailDesign.primaryGreen)
                  : const Color(PlantDetailDesign.textSecondary),
            ),
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({required this.needleValue});

  final double needleValue;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 8);
    final radius = size.width / 2 - 10;

    const colors = [
      Color(0xFFD1FAE5),
      Color(0xFF86EFAC),
      Color(0xFF22C55E),
      Color(0xFF15803D),
    ];

    for (var i = 0; i < colors.length; i++) {
      final start = math.pi + (math.pi / colors.length) * i;
      final sweep = math.pi / colors.length;
      final paint = Paint()
        ..color = colors[i]
        ..style = PaintingStyle.stroke
        ..strokeWidth = 10
        ..strokeCap = StrokeCap.butt;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        paint,
      );
    }

    final angle = math.pi + math.pi * needleValue;
    final needleEnd = Offset(
      center.dx + math.cos(angle) * (radius - 4),
      center.dy + math.sin(angle) * (radius - 4),
    );
    final needlePaint = Paint()
      ..color = const Color(PlantDetailDesign.textPrimary)
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, needleEnd, needlePaint);
    canvas.drawCircle(center, 4, Paint()..color = const Color(PlantDetailDesign.textPrimary));
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.needleValue != needleValue;
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.section, required this.stack});

  final PlantWaterSection section;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final illustration = section.illustration;
    final text = _WaterTextBlock(section: section);

    if (illustration == null) return text;

    final image = WaterIllustration(
      kind: illustration,
      size: section.illustrationSize,
    );

    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          text,
          const SizedBox(height: 12),
          image,
        ],
      );
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: text),
        const SizedBox(width: 12),
        Expanded(child: image),
      ],
    );
  }
}

class _WaterQualitySection extends StatelessWidget {
  const _WaterQualitySection({
    required this.section,
    required this.stack,
  });

  final PlantWaterSection section;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final options = section.qualityOptions ?? const [];
    final t = Theme.of(context);

    final table = Column(
      children: options.map((opt) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  opt.label,
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: opt.highlighted
                      ? const Color(0xFFF0FDF4)
                      : const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: opt.highlighted
                        ? const Color(PlantDetailDesign.primaryGreen)
                            .withValues(alpha: 0.35)
                        : const Color(PlantDetailDesign.border),
                  ),
                ),
                child: Text(
                  opt.tag,
                  style: t.textTheme.labelSmall?.copyWith(
                    fontSize: 11,
                    fontWeight: opt.highlighted ? FontWeight.w700 : FontWeight.w500,
                    color: opt.highlighted
                        ? const Color(PlantDetailDesign.primaryGreen)
                        : const Color(PlantDetailDesign.textSecondary),
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );

    final illustration = section.illustration != null
        ? WaterIllustration(kind: section.illustration!)
        : null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        if (stack) ...[
          table,
          if (illustration != null) ...[
            const SizedBox(height: 12),
            illustration,
          ],
        ] else
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: table),
              if (illustration != null) ...[
                const SizedBox(width: 12),
                Expanded(child: illustration),
              ],
            ],
          ),
        if (section.infoTip != null) ...[
          const SizedBox(height: 12),
          _InfoTipBox(tip: section.infoTip!),
        ],
      ],
    );
  }
}

class _WaterSectionContent extends StatelessWidget {
  const _WaterSectionContent({required this.section});

  final PlantWaterSection section;

  @override
  Widget build(BuildContext context) {
    final text = _WaterTextBlock(section: section);
    final illustration = section.illustration;

    if (illustration == null) return text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        text,
        const SizedBox(height: 12),
        WaterIllustration(
          kind: illustration,
          size: section.illustrationSize == WaterIllustrationSize.normal
              ? WaterIllustrationSize.compact
              : section.illustrationSize,
        ),
      ],
    );
  }
}

class _WaterTextBlock extends StatelessWidget {
  const _WaterTextBlock({required this.section});

  final PlantWaterSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (section.title.isNotEmpty)
          _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.sensitivity != null) ...[
          const SizedBox(height: 12),
          _SensitivityCard(card: section.sensitivity!),
        ],
        if (section.items != null && section.items!.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...section.items!.map((item) => _ListItemRow(item: item)),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ],
    );
  }
}

class _SensitivityCard extends StatelessWidget {
  const _SensitivityCard({required this.card});

  final WaterSensitivityCard card;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (var i = 0; i < card.totalDrops; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Icon(
                Icons.water_drop_rounded,
                size: 22,
                color: i < card.filledDrops
                    ? const Color(0xFF3B82F6)
                    : const Color(0xFFD1D5DB),
              ),
            ],
          ],
        ),
        const SizedBox(height: 6),
        Text(
          card.caption,
          style: t.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: const Color(PlantDetailDesign.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _ListItemRow extends StatelessWidget {
  const _ListItemRow({required this.item});

  final WaterListItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.marker) {
      WaterListMarker.check => Icons.check_rounded,
      WaterListMarker.drop => Icons.water_drop_outlined,
      WaterListMarker.warning => Icons.priority_high_rounded,
    };
    final color = switch (item.marker) {
      WaterListMarker.check => const Color(PlantDetailDesign.primaryGreen),
      WaterListMarker.drop => const Color(0xFF3B82F6),
      WaterListMarker.warning => const Color(PlantDetailDesign.warning),
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

class _InfoTipBox extends StatelessWidget {
  const _InfoTipBox({required this.tip});

  final WaterInfoTip tip;

  @override
  Widget build(BuildContext context) {
    const accent = Color(PlantDetailDesign.primaryGreen);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, size: 18, color: accent),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              tip.body,
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

class _WaterAlertCard extends StatelessWidget {
  const _WaterAlertCard({required this.alert});

  final PlantWaterAlert alert;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFEFF6FF);
    const accent = Color(0xFF3B82F6);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.water_drop_rounded, size: 28, color: accent),
          const SizedBox(width: 10),
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
                        height: 1.4,
                        color: const Color(PlantDetailDesign.textPrimary),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Column(
            children: [
              Icon(Icons.wb_sunny_rounded, size: 22, color: Color(0xFFF59E0B)),
              SizedBox(height: 4),
              Icon(
                Icons.eco_outlined,
                size: 18,
                color: Color(PlantDetailDesign.primaryGreen),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
