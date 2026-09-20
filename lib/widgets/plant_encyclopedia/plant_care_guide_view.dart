import 'package:flutter/material.dart';

import '../../data/plant_care_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'care_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

Widget _wrapCareCard(
  BuildContext context,
  PlantCareSection section,
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


const _careGreen = Color(PlantDetailDesign.primaryGreen);

class PlantCareGuideView extends StatelessWidget {
  const PlantCareGuideView({super.key, required this.guide});

  final PlantCareGuide guide;

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
              _CareRowWidget(row: guide.rows[i], maxWidth: maxWidth),
            ],
          ],
        );
      },
    );
  }
}

class _CareRowWidget extends StatelessWidget {
  const _CareRowWidget({required this.row, required this.maxWidth});

  final PlantCareRow row;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    switch (row.kind) {
      case PlantCareRowKind.columns2:
        return _buildColumns(
          context,
          row.sections, stackVertically: row.stackVertically);
      case PlantCareRowKind.iconGrid:
        return _wrapCareCard(
          context,
          row.sections.first,
          _IconGridSection(section: row.sections.first),
        );
    }
  }

  Widget _buildColumns(
    BuildContext context,
    List<PlantCareSection> sections, {
    bool stackVertically = false,
  }) {
    return Column(
      children: [
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _wrapCareCard(
              context,
              sections[i],
              _SplitSection(
              section: sections[i],
              stack: true,
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
              color: _careGreen,
            ),
          ),
        if (subtitle != null && subtitle!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: t.textTheme.bodySmall?.copyWith(
              height: 1.35,
              fontSize: 12,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.section, required this.stack});

  final PlantCareSection section;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final text = _TextBlock(section: section);
    final icons = section.iconOptions;
    if (icons != null && icons.isNotEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          text,
          const SizedBox(height: 12),
          _IconOptionsGrid(options: icons),
        ],
      );
    }

    final illustration = section.illustration;
    if (illustration == null) return text;

    final image = CareIllustration(
      kind: illustration,
      size: section.illustrationSize,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [text, const SizedBox(height: 12), image],
    );
  }
}

class _TextBlock extends StatelessWidget {
  const _TextBlock({required this.section});

  final PlantCareSection section;

  @override
  Widget build(BuildContext context) {
    final items = section.checklist ?? const [];
    final tip = section.summary ?? section.subtitle;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: tip),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 8),
          for (final item in items) _ListItemRow(item: item),
        ],
      ],
    );
  }
}

class _ListItemRow extends StatelessWidget {
  const _ListItemRow({required this.item});

  final CareListItem item;

  @override
  Widget build(BuildContext context) {
    final icon = switch (item.marker) {
      CareListMarker.check => Icons.check_rounded,
      CareListMarker.warning => Icons.error_outline_rounded,
      CareListMarker.bullet => Icons.fiber_manual_record,
    };
    final color = switch (item.marker) {
      CareListMarker.check => _careGreen,
      CareListMarker.warning => const Color(PlantDetailDesign.warning),
      CareListMarker.bullet => _careGreen,
    };
    final iconSize = item.marker == CareListMarker.bullet ? 8.0 : 16.0;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Icon(icon, size: iconSize, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              item.text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    fontSize: 12,
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

  final PlantCareSection section;

  @override
  Widget build(BuildContext context) {
    final options = section.iconOptions ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(
          title: section.title,
          subtitle: section.summary ?? section.subtitle,
        ),
        const SizedBox(height: 12),
        _IconOptionsGrid(options: options),
      ],
    );
  }
}

/// 2×2-raster zodat iconen (dieren, seizoenen) goed zichtbaar blijven.
class _IconOptionsGrid extends StatelessWidget {
  const _IconOptionsGrid({required this.options});

  final List<CareIconOption> options;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < options.length; i += 2) ...[
          if (i > 0) const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _IconOptionCard(option: options[i])),
              if (i + 1 < options.length) ...[
                const SizedBox(width: 10),
                Expanded(child: _IconOptionCard(option: options[i + 1])),
              ] else
                const Expanded(child: SizedBox.shrink()),
            ],
          ),
        ],
      ],
    );
  }
}

class _IconOptionCard extends StatelessWidget {
  const _IconOptionCard({required this.option});

  final CareIconOption option;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        CareIllustration(
          kind: option.illustration,
          size: CareIllustrationSize.icon,
        ),
        const SizedBox(height: 4),
        Text(
          option.label,
          textAlign: TextAlign.center,
          maxLines: 1,
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
