import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_nutrition_guide.dart';
import 'nutrition_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

Widget _wrapNutritionCard(
  BuildContext context,
  PlantNutritionSection section,
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


class PlantNutritionGuideView extends StatelessWidget {
  const PlantNutritionGuideView({super.key, required this.guide});

  final PlantNutritionGuide guide;

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
              _NutritionRowWidget(
                row: guide.rows[i],
                maxWidth: maxWidth,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _NutritionRowWidget extends StatelessWidget {
  const _NutritionRowWidget({
    required this.row,
    required this.maxWidth,
  });

  final PlantNutritionRow row;
  final double maxWidth;

  bool get _stackColumns2 => maxWidth < 300;
  bool get _stackSplit => maxWidth < 520;

  @override
  Widget build(BuildContext context) {
    switch (row.kind) {
      case PlantNutritionRowKind.nutritionNeed:
        return _wrapNutritionCard(
          context,
          row.sections.first,
          _NutritionNeedSection(section: row.sections.first),
        );
      case PlantNutritionRowKind.soilBest:
        return _wrapNutritionCard(
          context,
          row.sections.first,
          _BestSoilSection(section: row.sections.first),
        );
      case PlantNutritionRowKind.columns2:
        return _buildColumns(
          context,
          row.sections,
          stackVertically: row.stackVertically,
        );
      case PlantNutritionRowKind.split:
        return _wrapNutritionCard(
          context,
          row.sections.first,
          _SplitSection(
            section: row.sections.first,
            stack: _stackSplit,
          ),
        );
      case PlantNutritionRowKind.fertilizerBest:
        return _wrapNutritionCard(
          context,
          row.sections.first,
          _BestFertilizerSection(section: row.sections.first),
        );
      case PlantNutritionRowKind.nutrients:
        return _wrapNutritionCard(
          context,
          row.sections.first,
          _NutrientsSection(section: row.sections.first),
        );
      case PlantNutritionRowKind.timeline:
        return _wrapNutritionCard(
          context,
          row.sections.first,
          _TimelineSection(section: row.sections.first),
        );
      case PlantNutritionRowKind.alert:
        final alert = row.alert;
        if (alert == null) return const SizedBox.shrink();
        return _NutritionAlertCard(alert: alert);
    }
  }

  Widget _buildColumns(
    BuildContext context,
    List<PlantNutritionSection> sections, {
    bool stackVertically = false,
  }) {
    if (stackVertically || _stackColumns2) {
      return Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _wrapNutritionCard(
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
            child: _wrapNutritionCard(
              context,
              sections[i],
              _ColumnSection(section: sections[i]),
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
        if (title.isNotEmpty)
          Text(
            title,
            style: t.textTheme.titleMedium?.copyWith(
              fontSize: 15,
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

class _NutritionNeedSection extends StatelessWidget {
  const _NutritionNeedSection({required this.section});

  final PlantNutritionSection section;

  @override
  Widget build(BuildContext context) {
    final need = section.nutritionNeed ?? NutritionNeedLevel.medium;
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        Text(
          section.summary ?? '',
          style: t.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            _NeedCard(
              leaves: 1,
              label: 'Laag',
              active: need == NutritionNeedLevel.low,
            ),
            const SizedBox(width: 8),
            _NeedCard(
              leaves: 2,
              label: 'Gemiddeld',
              active: need == NutritionNeedLevel.medium,
            ),
            const SizedBox(width: 8),
            _NeedCard(
              leaves: 3,
              label: 'Hoog',
              active: need == NutritionNeedLevel.high,
            ),
          ],
        ),
      ],
    );
  }
}

class _NeedCard extends StatelessWidget {
  const _NeedCard({
    required this.leaves,
    required this.label,
    required this.active,
  });

  final int leaves;
  final String label;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        decoration: BoxDecoration(
          color: active ? const Color(0xFFF0FDF4) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: active
                ? const Color(PlantDetailDesign.primaryGreen)
                    .withValues(alpha: 0.4)
                : const Color(PlantDetailDesign.border),
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 0; i < leaves; i++) ...[
                  if (i > 0) const SizedBox(width: 2),
                  Icon(
                    Icons.eco_rounded,
                    size: 16,
                    color: active
                        ? const Color(PlantDetailDesign.primaryGreen)
                        : const Color(PlantDetailDesign.textSecondary),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                    color: active
                        ? const Color(PlantDetailDesign.primaryGreen)
                        : const Color(PlantDetailDesign.textPrimary),
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BestSoilSection extends StatelessWidget {
  const _BestSoilSection({required this.section});

  final PlantNutritionSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final card = section.soilCards?.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (card != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(PlantDetailDesign.primaryGreen)
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NutritionIllustration(
                  kind: card.illustration,
                  size: NutritionIllustrationSize.compact,
                ),
                const SizedBox(height: 10),
                Text(
                  card.label,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  card.status,
                  style: t.textTheme.labelSmall?.copyWith(
                    color: const Color(PlantDetailDesign.primaryGreen),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _BestFertilizerSection extends StatelessWidget {
  const _BestFertilizerSection({required this.section});

  final PlantNutritionSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final card = section.fertilizerCards?.firstOrNull;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (card != null) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(PlantDetailDesign.primaryGreen)
                    .withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                NutritionIllustration(
                  kind: card.illustration,
                  size: NutritionIllustrationSize.compact,
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Color(PlantDetailDesign.primaryGreen),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        card.label,
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  card.status,
                  style: t.textTheme.labelSmall?.copyWith(
                    color: const Color(PlantDetailDesign.primaryGreen),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: t.textTheme.bodyMedium?.copyWith(
              height: 1.45,
            ),
          ),
        ],
      ],
    );
  }
}

class _ColumnSection extends StatelessWidget {
  const _ColumnSection({required this.section});

  final PlantNutritionSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.phRange != null) ...[
          const SizedBox(height: 12),
          _PhScale(range: section.phRange!),
        ],
        if (section.recommended) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 16,
                color: Color(PlantDetailDesign.primaryGreen),
              ),
              const SizedBox(width: 6),
              Text(
                'Aanbevolen',
                style: t.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(PlantDetailDesign.primaryGreen),
                ),
              ),
            ],
          ),
        ],
        if (section.items != null && section.items!.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...section.items!.map((item) => _ListItemRow(item: item)),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: t.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ],
        if (section.illustration != null) ...[
          const SizedBox(height: 12),
          NutritionIllustration(
            kind: section.illustration!,
            size: section.illustrationSize,
          ),
        ],
      ],
    );
  }
}

class _PhScale extends StatelessWidget {
  const _PhScale({required this.range});

  final NutritionPhRange range;

  @override
  Widget build(BuildContext context) {
    final span = range.max - range.min;
    final idealStart = (range.idealMin - range.min) / span;
    final idealWidth = (range.idealMax - range.idealMin) / span;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final w = constraints.maxWidth;
            return Stack(
              children: [
                Container(
                  height: 10,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(6),
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFFEF4444),
                        Color(0xFFF59E0B),
                        Color(0xFF22C55E),
                        Color(0xFF3B82F6),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: w * idealStart,
                  width: w * idealWidth,
                  child: Container(
                    height: 10,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 6),
        Text(
          'Ideaal: ${range.idealMin.toStringAsFixed(1)} – ${range.idealMax.toStringAsFixed(1)}',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
        ),
      ],
    );
  }
}

class _NutrientsSection extends StatelessWidget {
  const _NutrientsSection({required this.section});

  final PlantNutritionSection section;

  @override
  Widget build(BuildContext context) {
    final rows = section.nutrients ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _NutrientRow(row: rows[i]),
        ],
      ],
    );
  }
}

class _NutrientRow extends StatelessWidget {
  const _NutrientRow({required this.row});

  final NutritionNutrientRow row;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(row.color).withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
          child: Text(
            row.letter,
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Color(row.color),
                ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                row.name,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                row.summary,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.35,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 72,
          child: NutritionIllustration(
            kind: row.illustration,
            size: NutritionIllustrationSize.small,
          ),
        ),
      ],
    );
  }
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.section, required this.stack});

  final PlantNutritionSection section;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final text = _TextBlock(section: section);
    final illustration = section.illustration;
    if (illustration == null) return text;

    final image = NutritionIllustration(kind: illustration);
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

  final PlantNutritionSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.items != null) ...[
          const SizedBox(height: 10),
          ...section.items!.map((item) => _ListItemRow(item: item)),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: t.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
      ],
    );
  }
}

class _ListItemRow extends StatelessWidget {
  const _ListItemRow({required this.item});

  final NutritionListItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            size: 8,
            color: Color(PlantDetailDesign.primaryGreen),
          ),
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

class _TimelineSection extends StatelessWidget {
  const _TimelineSection({required this.section});

  final PlantNutritionSection section;

  @override
  Widget build(BuildContext context) {
    final stages = section.timeline ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 14),
        FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: Row(
            children: [
              for (var i = 0; i < stages.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.only(top: 24),
                    child: Icon(Icons.arrow_forward_rounded, size: 14),
                  ),
                SizedBox(
                  width: 72,
                  child: _TimelineStageCard(stage: stages[i]),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _TimelineStageCard extends StatelessWidget {
  const _TimelineStageCard({required this.stage});

  final NutritionTimelineStage stage;

  IconData get _icon => switch (stage.icon) {
        NutritionTimelineIcon.plant => Icons.spa_outlined,
        NutritionTimelineIcon.grow => Icons.eco_outlined,
        NutritionTimelineIcon.bloom => Icons.local_florist_outlined,
        NutritionTimelineIcon.fruit => Icons.circle_outlined,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        children: [
          Icon(_icon, size: 22, color: const Color(PlantDetailDesign.primaryGreen)),
          const SizedBox(height: 4),
          Text(
            stage.label,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
          ),
          Text(
            stage.detail,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  color: const Color(PlantDetailDesign.textSecondary),
                ),
          ),
        ],
      ),
    );
  }
}

class _NutritionAlertCard extends StatelessWidget {
  const _NutritionAlertCard({required this.alert});

  final PlantNutritionAlert alert;

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
              const Icon(Icons.smart_toy_outlined, size: 28, color: accent),
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
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const NutritionIllustration(
            kind: PlantNutritionIllustration.aiSchedule,
            size: NutritionIllustrationSize.normal,
          ),
        ],
      ),
    );
  }
}
