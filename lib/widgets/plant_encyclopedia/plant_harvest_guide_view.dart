import 'package:flutter/material.dart';

import '../../data/plant_harvest_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'harvest_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

Widget _wrapHarvestCard(
  BuildContext context,
  PlantHarvestSection section,
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


const _harvestGreen = Color(PlantDetailDesign.primaryGreen);
const _harvestGreenLight = Color(0xFFF0FDF4);

class PlantHarvestGuideView extends StatelessWidget {
  const PlantHarvestGuideView({super.key, required this.guide});

  final PlantHarvestGuide guide;

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
              _HarvestRowWidget(row: guide.rows[i], maxWidth: maxWidth),
            ],
          ],
        );
      },
    );
  }
}

class _HarvestRowWidget extends StatelessWidget {
  const _HarvestRowWidget({required this.row, required this.maxWidth});

  final PlantHarvestRow row;
  final double maxWidth;

  bool get _stackColumns2 => !maxWidth.isFinite || maxWidth < 300;
  bool get _stackSplit => !maxWidth.isFinite || maxWidth < 520;

  @override
  Widget build(BuildContext context) {
    switch (row.kind) {
      case PlantHarvestRowKind.harvestPeriod:
        return _wrapHarvestCard(
          context,
          row.sections.first,
          _HarvestPeriodSection(section: row.sections.first),
        );
      case PlantHarvestRowKind.columns2:
        return _buildColumns(
          context,
          row.sections, stackVertically: row.stackVertically);
      case PlantHarvestRowKind.split:
        return _wrapHarvestCard(
          context,
          row.sections.first,
          _SplitSection(section: row.sections.first, stack: _stackSplit),
        );
      case PlantHarvestRowKind.iconGrid:
        return _wrapHarvestCard(
          context,
          row.sections.first,
          _IconGridSection(section: row.sections.first),
        );
      case PlantHarvestRowKind.checklist:
        return _wrapHarvestCard(
          context,
          row.sections.first,
          _ChecklistSection(section: row.sections.first),
        );
      case PlantHarvestRowKind.statusList:
        return _wrapHarvestCard(
          context,
          row.sections.first,
          _StatusListSection(section: row.sections.first),
        );
      case PlantHarvestRowKind.badgeColumns2:
        return _buildBadgeColumns(context, row.sections);
      case PlantHarvestRowKind.yesNoColumns2:
        return _buildColumns(
          context,
          row.sections,
          stackVertically: row.stackVertically,
          yesNo: true,
        );
      case PlantHarvestRowKind.problemsPerfect:
        return _wrapHarvestCard(
          context,
          row.sections.first,
          _ProblemsPerfectSection(
            perfect: row.sections[0],
            problems: row.sections[1],
            stack: _stackSplit,
          ),
        );
      case PlantHarvestRowKind.edibleGrid:
        return _wrapHarvestCard(
          context,
          row.sections.first,
          _EdibleGridSection(section: row.sections.first),
        );
    }
  }

  Widget _buildColumns(
    BuildContext context,
    List<PlantHarvestSection> sections, {
    bool stackVertically = false,
    bool yesNo = false,
  }) {
    if (stackVertically || _stackColumns2) {
      return Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _wrapHarvestCard(
              context,
              sections[i],
              yesNo
                  ? _YesNoSection(section: sections[i])
                  : _ColumnSection(section: sections[i]),
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
            child: _wrapHarvestCard(
              context,
              sections[i],
              yesNo
                  ? _YesNoSection(section: sections[i])
                  : _ColumnSection(section: sections[i]),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBadgeColumns(
    BuildContext context,
    List<PlantHarvestSection> sections,
  ) {
    if (_stackColumns2) {
      return Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _wrapHarvestCard(
              context,
              sections[i],
              _BadgeSection(section: sections[i])),
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
            child: _wrapHarvestCard(
              context,
              sections[i],
              _BadgeSection(section: sections[i])),
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
              color: _harvestGreen,
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

class _HarvestPeriodSection extends StatelessWidget {
  const _HarvestPeriodSection({required this.section});

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    final months = section.harvestMonths ?? const <int>{};

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
                accentColor: _harvestGreen,
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
            ? HarvestIllustration(
                kind: section.illustration!,
                size: HarvestIllustrationSize.compact,
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

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.showCalendarClock) ...[
          const SizedBox(height: 12),
          const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.calendar_month_rounded, size: 36, color: _harvestGreen),
              SizedBox(width: 12),
              Icon(Icons.schedule_rounded, size: 36, color: _harvestGreen),
            ],
          ),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            textAlign:
                section.showCalendarClock ? TextAlign.center : TextAlign.start,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  fontSize: 13,
                ),
          ),
        ],
        if (section.illustration != null && !section.showCalendarClock) ...[
          const SizedBox(height: 12),
          HarvestIllustration(
            kind: section.illustration!,
            size: section.illustrationSize,
          ),
        ],
      ],
    );
  }
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.section, required this.stack});

  final PlantHarvestSection section;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final text = _SplitTextBlock(section: section);
    final illustration = section.illustration;
    if (illustration == null) return text;

    final image = HarvestIllustration(kind: illustration);
    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [text, const SizedBox(height: 12), image],
      );
    }
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: image),
        const SizedBox(width: 12),
        Expanded(child: text),
      ],
    );
  }
}

class _SplitTextBlock extends StatelessWidget {
  const _SplitTextBlock({required this.section});

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.yesNoAnswer != null) ...[
          const SizedBox(height: 10),
          Text(
            section.yesNoAnswer!,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _harvestGreen,
                ),
          ),
        ],
        if (section.checklist != null && section.checklist!.isNotEmpty) ...[
          const SizedBox(height: 10),
          for (final item in section.checklist!) _ListItemRow(item: item),
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
      ],
    );
  }
}

class _BadgeSection extends StatelessWidget {
  const _BadgeSection({required this.section});

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        if (section.illustration != null)
          HarvestIllustration(
            kind: section.illustration!,
            size: HarvestIllustrationSize.compact,
          ),
        if (section.badge != null) ...[
          const SizedBox(height: 10),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: _harvestGreenLight,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: _harvestGreen.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                section.badge!,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                      color: _harvestGreen,
                    ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _YesNoSection extends StatelessWidget {
  const _YesNoSection({required this.section});

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        if (section.illustration != null)
          Center(
            child: SizedBox(
              width: 100,
              child: HarvestIllustration(
                kind: section.illustration!,
                size: HarvestIllustrationSize.icon,
              ),
            ),
          ),
        if (section.yesNoAnswer != null) ...[
          const SizedBox(height: 10),
          Text(
            section.yesNoAnswer!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: _harvestGreen,
                ),
          ),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            section.summary!,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  height: 1.4,
                  fontSize: 12,
                ),
          ),
        ],
      ],
    );
  }
}

class _ChecklistSection extends StatelessWidget {
  const _ChecklistSection({required this.section});

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    final items = section.checklist ?? const [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 10),
        for (final item in items) _ListItemRow(item: item),
      ],
    );
  }
}

class _StatusListSection extends StatelessWidget {
  const _StatusListSection({required this.section});

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    final items = section.statusItems ?? const [];
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (section.illustration != null) ...[
          SizedBox(
            width: 72,
            child: HarvestIllustration(
              kind: section.illustration!,
              size: HarvestIllustrationSize.icon,
            ),
          ),
          const SizedBox(width: 12),
        ],
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _SectionHeader(
                title: section.title,
                subtitle: section.subtitle,
              ),
              const SizedBox(height: 10),
              for (final item in items) _ListItemRow(item: item),
            ],
          ),
        ),
      ],
    );
  }
}

class _ListItemRow extends StatelessWidget {
  const _ListItemRow({required this.item});

  final HarvestListItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.marker) {
      HarvestListMarker.check => Icons.check_rounded,
      HarvestListMarker.warning => Icons.error_outline_rounded,
      HarvestListMarker.cross => Icons.close_rounded,
      HarvestListMarker.bullet => Icons.fiber_manual_record,
      HarvestListMarker.none => null,
    };
    final color = switch (item.marker) {
      HarvestListMarker.check => _harvestGreen,
      HarvestListMarker.warning => const Color(PlantDetailDesign.warning),
      HarvestListMarker.cross => const Color(PlantDetailDesign.textSecondary),
      HarvestListMarker.bullet => _harvestGreen,
      HarvestListMarker.none => Colors.transparent,
    };
    final iconSize = item.marker == HarvestListMarker.bullet ? 8.0 : 18.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null)
            Icon(icon, size: iconSize, color: color)
          else
            const SizedBox(width: 18),
          if (icon != null) const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontSize: 13,
                    fontWeight:
                        item.highlighted ? FontWeight.w700 : FontWeight.w400,
                    color: item.highlighted
                        ? const Color(PlantDetailDesign.textPrimary)
                        : const Color(PlantDetailDesign.textSecondary),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconGridSection extends StatelessWidget {
  const _IconGridSection({required this.section});

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    final options = section.options ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _OptionCard(option: options[i])),
            ],
          ],
        ),
      ],
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({required this.option});

  final HarvestOption option;

  @override
  Widget build(BuildContext context) {
    final highlighted = option.highlighted;

    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: highlighted ? _harvestGreenLight : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? _harvestGreen.withValues(alpha: 0.45)
              : const Color(PlantDetailDesign.border),
        ),
      ),
      child: Column(
        children: [
          HarvestIllustration(
            kind: option.illustration,
            size: HarvestIllustrationSize.icon,
          ),
          const SizedBox(height: 6),
          Text(
            option.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
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
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
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

class _ProblemsPerfectSection extends StatelessWidget {
  const _ProblemsPerfectSection({
    required this.perfect,
    required this.problems,
    required this.stack,
  });

  final PlantHarvestSection perfect;
  final PlantHarvestSection problems;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final problemsList = problems.problems ?? const [];
    final perfectContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: perfect.title, subtitle: perfect.subtitle),
        if (perfect.checklist != null && perfect.checklist!.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final item in perfect.checklist!) _ListItemRow(item: item),
        ],
      ],
    );
    final perfectImage = perfect.illustration != null
        ? HarvestIllustration(
            kind: perfect.illustration!,
            size: perfect.illustrationSize,
          )
        : const SizedBox.shrink();

    final problemsBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16),
        _SectionHeader(title: problems.title, subtitle: problems.subtitle),
        const SizedBox(height: 10),
        for (final item in problemsList) _ListItemRow(item: item),
      ],
    );

    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          perfectContent,
          if (perfect.illustration != null) ...[
            const SizedBox(height: 12),
            perfectImage,
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
            Expanded(child: perfectContent),
            const SizedBox(width: 12),
            SizedBox(width: 120, child: perfectImage),
          ],
        ),
        problemsBlock,
      ],
    );
  }
}

class _EdibleGridSection extends StatelessWidget {
  const _EdibleGridSection({required this.section});

  final PlantHarvestSection section;

  @override
  Widget build(BuildContext context) {
    final parts = section.edibleParts ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final narrow = constraints.maxWidth < 400;
            if (narrow) {
              return Column(
                children: [
                  for (var i = 0; i < parts.length; i += 3) ...[
                    if (i > 0) const SizedBox(height: 8),
                    Row(
                      children: [
                        for (var j = i; j < i + 3 && j < parts.length; j++) ...[
                          if (j > i) const SizedBox(width: 8),
                          Expanded(child: _EdiblePartCard(part: parts[j])),
                        ],
                      ],
                    ),
                  ],
                ],
              );
            }
            return Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < parts.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: _EdiblePartCard(part: parts[i])),
                ],
              ],
            );
          },
        ),
      ],
    );
  }
}

class _EdiblePartCard extends StatelessWidget {
  const _EdiblePartCard({required this.part});

  final HarvestOption part;

  @override
  Widget build(BuildContext context) {
    final highlighted = part.highlighted;
    return Opacity(
      opacity: highlighted ? 1 : 0.45,
      child: Column(
        children: [
          HarvestIllustration(
            kind: part.illustration,
            size: HarvestIllustrationSize.icon,
          ),
          const SizedBox(height: 4),
          Text(
            part.label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
                ),
          ),
        ],
      ),
    );
  }
}
