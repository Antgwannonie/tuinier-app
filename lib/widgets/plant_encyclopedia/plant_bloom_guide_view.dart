import 'package:flutter/material.dart';

import '../../data/plant_bloom_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'bloom_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

Widget _wrapBloomCard(
  BuildContext context,
  PlantBloomSection section,
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


const _bloomPink = Color(0xFFDB2777);
const _bloomPinkLight = Color(0xFFFDF2F8);

class PlantBloomGuideView extends StatelessWidget {
  const PlantBloomGuideView({super.key, required this.guide});

  final PlantBloomGuide guide;

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
              _BloomRowWidget(row: guide.rows[i], maxWidth: maxWidth),
            ],
          ],
        );
      },
    );
  }
}

class _BloomRowWidget extends StatelessWidget {
  const _BloomRowWidget({required this.row, required this.maxWidth});

  final PlantBloomRow row;
  final double maxWidth;

  bool get _stackColumns2 => !maxWidth.isFinite || maxWidth < 300;
  bool get _stackSplit => !maxWidth.isFinite || maxWidth < 520;

  @override
  Widget build(BuildContext context) {
    switch (row.kind) {
      case PlantBloomRowKind.bloomPeriod:
        return _wrapBloomCard(
          context,
          row.sections.first,
          _BloomPeriodSection(section: row.sections.first),
        );
      case PlantBloomRowKind.columns2:
        return _buildColumns(
          context,
          row.sections,
          stackVertically: row.stackVertically,
        );
      case PlantBloomRowKind.optionGrid:
        return _wrapBloomCard(
          context,
          row.sections.first,
          _OptionGridSection(section: row.sections.first),
        );
      case PlantBloomRowKind.iconGrid:
        return _wrapBloomCard(
          context,
          row.sections.first,
          _IconGridSection(section: row.sections.first),
        );
      case PlantBloomRowKind.split:
        return _wrapBloomCard(
          context,
          row.sections.first,
          _SplitSection(
            section: row.sections.first,
            stack: _stackSplit,
          ),
        );
      case PlantBloomRowKind.problemsHealthy:
        return _wrapBloomCard(
          context,
          row.sections.first,
          _ProblemsHealthySection(
            healthy: row.sections[0],
            problems: row.sections[1],
            stack: _stackSplit,
          ),
        );
    }
  }

  Widget _buildColumns(
    BuildContext context,
    List<PlantBloomSection> sections, {
    bool stackVertically = false,
  }) {
    if (stackVertically || _stackColumns2) {
      return Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _wrapBloomCard(
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
            child: _wrapBloomCard(
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

class _BloomPeriodSection extends StatelessWidget {
  const _BloomPeriodSection({required this.section});

  final PlantBloomSection section;

  @override
  Widget build(BuildContext context) {
    final months = section.bloomMonths ?? const <int>{};

    return LayoutBuilder(
      builder: (context, constraints) {
        final stack = constraints.maxWidth < 520;
        final text = Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _SectionHeader(title: section.title, subtitle: section.subtitle),
            if (months.isNotEmpty) ...[
              const SizedBox(height: 12),
              PlantMonthTimelineRow(
                timeline: PlantMonthTimeline(
                  label: section.title,
                  months: months,
                ),
                compact: true,
                accentColor: _bloomPink,
              ),
            ],
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
        final image = section.illustration != null
            ? BloomIllustration(
                kind: section.illustration!,
                size: BloomIllustrationSize.compact,
              )
            : const SizedBox.shrink();

        if (stack) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              text,
              if (section.illustration != null) ...[
                const SizedBox(height: 12),
                image,
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: text),
            const SizedBox(width: 12),
            SizedBox(width: 120, child: image),
          ],
        );
      },
    );
  }
}

class _ColumnSection extends StatelessWidget {
  const _ColumnSection({required this.section});

  final PlantBloomSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final problems = section.problems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.showCalendarIcon) ...[
          const SizedBox(height: 12),
          const Center(
            child: Icon(
              Icons.calendar_month_rounded,
              size: 40,
              color: _bloomPink,
            ),
          ),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            textAlign:
                section.showCalendarIcon ? TextAlign.center : TextAlign.start,
            style: t.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
        ],
        if (problems != null && problems.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final p in problems) ...[
            _ProblemRow(item: p),
            const SizedBox(height: 10),
          ],
        ],
        if (section.checklist != null && section.checklist!.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final item in section.checklist!) _ChecklistRow(item: item),
        ],
        if (section.illustration != null &&
            problems == null &&
            !section.showCalendarIcon) ...[
          const SizedBox(height: 12),
          BloomIllustration(
            kind: section.illustration!,
            size: section.illustrationSize,
          ),
        ],
        if (section.illustration != null &&
            section.checklist != null &&
            section.checklist!.isNotEmpty) ...[
          const SizedBox(height: 12),
          BloomIllustration(
            kind: section.illustration!,
            size: section.illustrationSize,
          ),
        ],
      ],
    );
  }
}

class _ProblemRow extends StatelessWidget {
  const _ProblemRow({required this.item});

  final BloomProblemItem item;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 56,
          child: BloomIllustration(
            kind: item.illustration,
            size: BloomIllustrationSize.icon,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.title,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                item.description,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      height: 1.35,
                      fontSize: 11,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});

  final BloomListItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_rounded,
            size: 18,
            color: Color(PlantDetailDesign.primaryGreen),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontSize: 13,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OptionGridSection extends StatelessWidget {
  const _OptionGridSection({required this.section});

  final PlantBloomSection section;

  @override
  Widget build(BuildContext context) {
    final options = section.options ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            section.summary!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.4,
                ),
          ),
        ],
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth >= 520 ? 3 : 1;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: options.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: crossCount == 3 ? 0.78 : 2.4,
              ),
              itemBuilder: (_, i) => _OptionCard(option: options[i]),
            );
          },
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.option});

  final BloomOption option;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final highlighted = option.highlighted;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlighted ? _bloomPinkLight : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? _bloomPink.withValues(alpha: 0.45)
              : const Color(PlantDetailDesign.border),
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: BloomIllustration(
              kind: option.illustration,
              size: BloomIllustrationSize.icon,
            ),
          ),
          Text(
            option.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
          if (option.description != null) ...[
            const SizedBox(height: 4),
            Text(
              option.description!,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.textTheme.bodySmall?.copyWith(
                fontSize: 9,
                height: 1.3,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _IconGridSection extends StatelessWidget {
  const _IconGridSection({required this.section});

  final PlantBloomSection section;

  @override
  Widget build(BuildContext context) {
    final factors = section.iconFactors ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < factors.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _IconFactorCard(factor: factors[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _IconFactorCard extends StatelessWidget {
  const _IconFactorCard({required this.factor});

  final BloomOption factor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BloomIllustration(
          kind: factor.illustration,
          size: BloomIllustrationSize.icon,
        ),
        const SizedBox(height: 6),
        Text(
          factor.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _ProblemsHealthySection extends StatelessWidget {
  const _ProblemsHealthySection({
    required this.healthy,
    required this.problems,
    required this.stack,
  });

  final PlantBloomSection healthy;
  final PlantBloomSection problems;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final problemsList = problems.problems ?? const [];
    final healthyContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: healthy.title, subtitle: healthy.subtitle),
        if (healthy.checklist != null && healthy.checklist!.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final item in healthy.checklist!) _ChecklistRow(item: item),
        ],
      ],
    );
    final healthyImage = healthy.illustration != null
        ? BloomIllustration(
            kind: healthy.illustration!,
            size: healthy.illustrationSize,
          )
        : const SizedBox.shrink();

    final problemsBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _SectionHeader(title: problems.title, subtitle: problems.subtitle),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < problemsList.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _ProblemCard(item: problemsList[i])),
            ],
          ],
        ),
      ],
    );

    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          healthyContent,
          if (healthy.illustration != null) ...[
            const SizedBox(height: 12),
            healthyImage,
          ],
          problemsBlock,
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: healthyContent),
            const SizedBox(width: 12),
            SizedBox(width: 120, child: healthyImage),
          ],
        ),
        problemsBlock,
      ],
    );
  }
}

class _ProblemCard extends StatelessWidget {
  const _ProblemCard({required this.item});

  final BloomProblemItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        BloomIllustration(
          kind: item.illustration,
          size: BloomIllustrationSize.icon,
        ),
        const SizedBox(height: 6),
        Text(
          item.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
        ),
        const SizedBox(height: 2),
        Text(
          item.description,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                height: 1.3,
                fontSize: 10,
              ),
        ),
      ],
    );
  }
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.section, required this.stack});

  final PlantBloomSection section;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final text = _SplitTextBlock(section: section);
    final illustration = section.illustration;
    if (illustration == null) return text;

    final image = BloomIllustration(kind: illustration);
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

class _SplitTextBlock extends StatelessWidget {
  const _SplitTextBlock({required this.section});

  final PlantBloomSection section;

  @override
  Widget build(BuildContext context) {
    final steps = section.steps;
    final badge = section.recommendedBadge;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (badge != null) ...[
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: badge.contains('Ja')
                    ? const Color(0xFFF0FDF4)
                    : const Color(0xFFF3F4F6),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: badge.contains('Ja')
                      ? const Color(PlantDetailDesign.primaryGreen)
                          .withValues(alpha: 0.4)
                      : const Color(PlantDetailDesign.border),
                ),
              ),
              child: Text(
                badge,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: badge.contains('Ja')
                          ? const Color(PlantDetailDesign.primaryGreen)
                          : const Color(PlantDetailDesign.textSecondary),
                    ),
              ),
            ),
          ),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  fontSize: 13,
                ),
          ),
        ],
        if (steps != null && steps.isNotEmpty) ...[
          const SizedBox(height: 12),
          for (final step in steps) _NumberedStepRow(item: step),
        ],
      ],
    );
  }
}

class _NumberedStepRow extends StatelessWidget {
  const _NumberedStepRow({required this.item});

  final BloomListItem item;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: _bloomPink,
              shape: BoxShape.circle,
            ),
            child: Text(
              '${item.number ?? 1}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontSize: 12,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
