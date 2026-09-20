import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_growth_guide.dart';
import 'growth_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

Widget _wrapGrowthCard(
  BuildContext context,
  PlantGrowthSection section,
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


class PlantGrowthGuideView extends StatelessWidget {
  const PlantGrowthGuideView({super.key, required this.guide});

  final PlantGrowthGuide guide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final maxWidth = constraints.maxWidth.isFinite
            ? constraints.maxWidth
            : MediaQuery.sizeOf(context).width - 32;
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < guide.rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _GrowthRowWidget(row: guide.rows[i], maxWidth: maxWidth),
            ],
          ],
        );
      },
    );
  }
}

class _GrowthRowWidget extends StatelessWidget {
  const _GrowthRowWidget({required this.row, required this.maxWidth});

  final PlantGrowthRow row;
  final double maxWidth;

  bool get _stackColumns2 => !maxWidth.isFinite || maxWidth < 300;
  bool get _stackSplit => !maxWidth.isFinite || maxWidth < 520;

  @override
  Widget build(BuildContext context) {
    switch (row.kind) {
      case PlantGrowthRowKind.phaseTimeline:
        return _wrapGrowthCard(
          context,
          row.sections.first,
          _PhaseTimelineSection(section: row.sections.first),
        );
      case PlantGrowthRowKind.columns2:
        return _buildColumns(
          context,
          row.sections, stackVertically: row.stackVertically);
      case PlantGrowthRowKind.habitGrid:
        return _wrapGrowthCard(
          context,
          row.sections.first,
          _HabitGridSection(section: row.sections.first),
        );
      case PlantGrowthRowKind.speedAndSupport:
        return _buildSpeedAndSupport(context, row.sections);
      case PlantGrowthRowKind.split:
        return _wrapGrowthCard(
          context,
          row.sections.first,
          _SplitSection(
            section: row.sections.first,
            stack: _stackSplit,
          ),
        );
      case PlantGrowthRowKind.stressAndAi:
        return _buildStressAndAi(
          context: context,
          section: row.sections.first,
          alert: row.alert,
        );
    }
  }

  Widget _buildColumns(
    BuildContext context,
    List<PlantGrowthSection> sections, {
    bool stackVertically = false,
  }) {
    if (stackVertically || _stackColumns2) {
      return Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _wrapGrowthCard(
              context,
              sections[i],
              _ColumnSection(section: sections[i])),
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
            child: _wrapGrowthCard(
              context,
              sections[i],
              _ColumnSection(section: sections[i]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSpeedAndSupport(
    BuildContext context,
    List<PlantGrowthSection> sections,
  ) {
    return Column(
      children: [
        _wrapGrowthCard(
          context,
          sections[0],
          _SpeedSection(section: sections[0]),
        ),
        const SizedBox(height: 12),
        _wrapGrowthCard(
          context,
          sections[1],
          _SupportSection(section: sections[1]),
        ),
      ],
    );
  }

  Widget _buildStressAndAi({
    required BuildContext context,
    required PlantGrowthSection section,
    PlantGrowthAlert? alert,
  }) {
    final stressCard = _wrapGrowthCard(
      context,
      section,
      _ColumnSection(section: section),
    );
    final aiCard = alert != null
        ? _GrowthAiCard(alert: alert)
        : const SizedBox.shrink();

    return Column(
      children: [stressCard, const SizedBox(height: 12), aiCard],
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

class _PhaseTimelineSection extends StatelessWidget {
  const _PhaseTimelineSection({required this.section});

  final PlantGrowthSection section;

  @override
  Widget build(BuildContext context) {
    final phases = section.phaseTimeline ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 14),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < phases.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 44, left: 2, right: 2),
                    child: Icon(Icons.arrow_forward_rounded, size: 14),
                  ),
                _PhaseTimelineCard(phase: phases[i]),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _PhaseTimelineCard extends StatelessWidget {
  const _PhaseTimelineCard({required this.phase});

  final GrowthPhaseTimelineItem phase;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final highlighted = phase.highlighted;

    return SizedBox(
      width: 104,
      child: Column(
        children: [
          GrowthIllustration(
            kind: phase.illustration,
            size: GrowthIllustrationSize.phase,
          ),
          const SizedBox(height: 6),
          Text(
            phase.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
              color: highlighted
                  ? const Color(PlantDetailDesign.primaryGreen)
                  : const Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitGridSection extends StatelessWidget {
  const _HabitGridSection({required this.section});

  final PlantGrowthSection section;

  @override
  Widget build(BuildContext context) {
    final cards = section.habitCards ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final cross = constraints.maxWidth < 360 ? 2 : 5;
            const imageHeight = 80.0;
            const labelHeight = 18.0;
            const gap = 4.0;
            final contentHeight = imageHeight + gap + labelHeight;
            final cellWidth =
                (constraints.maxWidth - (cross - 1) * 6) / cross;
            final aspectRatio = cellWidth / contentHeight;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: cards.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cross,
                mainAxisSpacing: 4,
                crossAxisSpacing: 6,
                childAspectRatio: aspectRatio,
              ),
              itemBuilder: (_, i) => _HabitCard(
                card: cards[i],
                imageHeight: imageHeight,
              ),
            );
          },
        ),
      ],
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({required this.card, required this.imageHeight});

  final GrowthHabitCard card;
  final double imageHeight;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final highlighted = card.highlighted;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: imageHeight,
          width: double.infinity,
          child: GrowthIllustration(
            kind: card.illustration,
            size: GrowthIllustrationSize.habit,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          card.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.textTheme.labelSmall?.copyWith(
            fontSize: 10,
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w600,
            color: highlighted
                ? const Color(PlantDetailDesign.primaryGreen)
                : const Color(PlantDetailDesign.textPrimary),
          ),
        ),
      ],
    );
  }
}

class _SpeedSection extends StatelessWidget {
  const _SpeedSection({required this.section});

  final PlantGrowthSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        Center(
          child: _GrowthSpeedGauge(
            level: section.growthSpeed ?? GrowthSpeedLevel.medium,
          ),
        ),
      ],
    );
  }
}

class _GrowthSpeedGauge extends StatelessWidget {
  const _GrowthSpeedGauge({required this.level});

  final GrowthSpeedLevel level;

  double get _needleValue => switch (level) {
        GrowthSpeedLevel.slow => 0.18,
        GrowthSpeedLevel.medium => 0.5,
        GrowthSpeedLevel.fast => 0.82,
      };

  String get _label => switch (level) {
        GrowthSpeedLevel.slow => 'Langzaam',
        GrowthSpeedLevel.medium => 'Gemiddeld',
        GrowthSpeedLevel.fast => 'Snel',
      };

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SizedBox(
      width: 140,
      child: Column(
        children: [
          SizedBox(
            height: 76,
            width: 140,
            child: CustomPaint(
              painter: _GaugePainter(needleValue: _needleValue),
              size: const Size(140, 76),
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
                text: 'Langzaam',
                active: level == GrowthSpeedLevel.slow,
              ),
              _ScaleLabel(
                text: 'Gemiddeld',
                active: level == GrowthSpeedLevel.medium,
              ),
              _ScaleLabel(
                text: 'Snel',
                active: level == GrowthSpeedLevel.fast,
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
    canvas.drawCircle(
      center,
      4,
      Paint()..color = const Color(PlantDetailDesign.textPrimary),
    );
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) =>
      oldDelegate.needleValue != needleValue;
}

class _SupportSection extends StatelessWidget {
  const _SupportSection({required this.section});

  final PlantGrowthSection section;

  @override
  Widget build(BuildContext context) {
    final options = section.supportOptions ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth >= 520 ? 4 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: crossCount == 4 ? 0.82 : 0.95,
              ),
              itemBuilder: (_, i) => _SupportCard(option: options[i]),
            );
          },
        ),
      ],
    );
  }
}

class _SupportCard extends StatelessWidget {
  const _SupportCard({required this.option});

  final GrowthSupportOption option;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final recommended = option.recommended;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: recommended ? const Color(0xFFF0FDF4) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: recommended
              ? const Color(PlantDetailDesign.primaryGreen)
                  .withValues(alpha: 0.35)
              : const Color(PlantDetailDesign.border),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: GrowthIllustration(
              kind: option.illustration,
              size: GrowthIllustrationSize.habit,
            ),
          ),
          Text(
            option.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: recommended ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColumnSection extends StatelessWidget {
  const _ColumnSection({required this.section});

  final PlantGrowthSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final factors = section.stimulateFactors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: t.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
        if (section.items != null && section.items!.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...section.items!.map((item) => _ListItemRow(item: item)),
        ],
        if (factors != null && factors.isNotEmpty) ...[
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: factors.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (_, i) => _StimulateCard(factor: factors[i]),
          ),
        ],
        if (section.illustration != null) ...[
          const SizedBox(height: 12),
          GrowthIllustration(
            kind: section.illustration!,
            size: section.illustrationSize,
          ),
        ],
      ],
    );
  }
}

class _StimulateCard extends StatelessWidget {
  const _StimulateCard({required this.factor});

  final GrowthStimulateFactor factor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GrowthIllustration(
          kind: factor.illustration,
          size: GrowthIllustrationSize.habit,
          plantFocus: true,
        ),
        const SizedBox(height: 6),
        Text(
          factor.label,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.section, required this.stack});

  final PlantGrowthSection section;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final text = _TextBlock(section: section);
    final illustration = section.illustration;
    if (illustration == null) return text;

    final image = GrowthIllustration(kind: illustration);
    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [text, const SizedBox(height: 12), image],
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

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.section});

  final PlantGrowthSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                ),
          ),
        ],
      ],
    );
  }
}

class _ListItemRow extends StatelessWidget {
  const _ListItemRow({required this.item});

  final GrowthListItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.marker) {
      GrowthListMarker.check => Icons.check_rounded,
      GrowthListMarker.warning => Icons.warning_amber_rounded,
      GrowthListMarker.bullet => Icons.fiber_manual_record,
    };
    final color = switch (item.marker) {
      GrowthListMarker.check => const Color(PlantDetailDesign.primaryGreen),
      GrowthListMarker.warning => const Color(PlantDetailDesign.warning),
      GrowthListMarker.bullet => const Color(PlantDetailDesign.primaryGreen),
    };
    final iconSize = item.marker == GrowthListMarker.bullet ? 8.0 : 18.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: iconSize, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GrowthAiCard extends StatelessWidget {
  const _GrowthAiCard({required this.alert});

  final PlantGrowthAlert alert;

  @override
  Widget build(BuildContext context) {
    const bg = Color(0xFFF0FDF4);
    const accent = Color(PlantDetailDesign.primaryGreen);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accent.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.smart_toy_outlined, size: 24, color: accent),
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
                            height: 1.4,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const GrowthIllustration(
            kind: PlantGrowthIllustration.aiAdvice,
            size: GrowthIllustrationSize.normal,
          ),
        ],
      ),
    );
  }
}
