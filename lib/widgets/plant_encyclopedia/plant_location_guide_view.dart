import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_location_guide.dart';
import 'location_illustrations.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

/// Standplaats-tab volgens mockup: zonkaarten, locatieraster en splits.
class PlantLocationGuideView extends StatelessWidget {
  const PlantLocationGuideView({super.key, required this.guide});

  final PlantLocationGuide guide;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < guide.rows.length; i++) ...[
              if (i > 0) const SizedBox(height: 12),
              _LocationRowWidget(
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

Widget _wrapLocationCard(
  BuildContext context,
  PlantLocationSection section,
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

class _LocationRowWidget extends StatelessWidget {
  const _LocationRowWidget({
    required this.row,
    required this.maxWidth,
  });

  final PlantLocationRow row;
  final double maxWidth;

  bool get _stackColumns2 => maxWidth < 300;
  bool get _stackSplit => maxWidth < 520;

  @override
  Widget build(BuildContext context) {
    switch (row.kind) {
      case PlantLocationRowKind.single:
        return _wrapLocationCard(
          context,
          row.sections.first,
          _LocationSectionContent(section: row.sections.first),
        );
      case PlantLocationRowKind.sunExposure:
        return _wrapLocationCard(
          context,
          row.sections.first,
          _SunExposureSection(section: row.sections.first),
        );
      case PlantLocationRowKind.locationGrid:
        return _wrapLocationCard(
          context,
          row.sections.first,
          _LocationGridSection(section: row.sections.first),
        );
      case PlantLocationRowKind.humidityRow:
        return _wrapLocationCard(
          context,
          row.sections.first,
          _HumiditySection(section: row.sections.first),
        );
      case PlantLocationRowKind.split:
        return _wrapLocationCard(
          context,
          row.sections.first,
          _SplitSection(
            section: row.sections.first,
            stack: _stackSplit,
          ),
        );
      case PlantLocationRowKind.imageBelow:
        return _wrapLocationCard(
          context,
          row.sections.first,
          _ImageBelowSection(section: row.sections.first),
        );
      case PlantLocationRowKind.columns2:
        return _buildColumns(context, row.sections, compact: false);
      case PlantLocationRowKind.columns2Compact:
        return _buildColumns(context, row.sections, compact: true);
    }
  }

  Widget _buildColumns(
    BuildContext context,
    List<PlantLocationSection> sections, {
    required bool compact,
  }) {
    if (_stackColumns2) {
      return Column(
        children: [
          for (var i = 0; i < sections.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            _wrapLocationCard(
              context,
              sections[i],
              _LocationSectionContent(
                section: sections[i],
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
        for (var i = 0; i < sections.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: _wrapLocationCard(
              context,
              sections[i],
              _LocationSectionContent(
                section: sections[i],
                forceCompactImage: compact,
              ),
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

class _SunExposureSection extends StatelessWidget {
  const _SunExposureSection({required this.section});

  final PlantLocationSection section;

  @override
  Widget build(BuildContext context) {
    final cards = section.sunCards ?? const [];
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 14),
        Row(
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 4),
              Expanded(child: _SunCard(card: cards[i])),
            ],
          ],
        ),
        if (section.summary != null) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: t.textTheme.bodySmall?.copyWith(
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
      ],
    );
  }
}

class _SunCard extends StatelessWidget {
  const _SunCard({required this.card});

  final LocationSunCard card;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final highlighted = card.highlighted;
    final accent = locationSunLevelColor(card.level, highlighted: highlighted);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
      decoration: BoxDecoration(
        color: highlighted
            ? const Color(0xFFF0FDF4)
            : const Color(PlantDetailDesign.card),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.35)
              : const Color(PlantDetailDesign.border),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(
            locationSunLevelAsset(card.level),
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Icon(
              locationSunLevelIcon(card.level),
              size: 24,
              color: accent,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            card.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            card.status,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
              color: highlighted
                  ? const Color(PlantDetailDesign.primaryGreen)
                  : const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationGridSection extends StatelessWidget {
  const _LocationGridSection({required this.section});

  final PlantLocationSection section;

  @override
  Widget build(BuildContext context) {
    final spots = section.spotCards ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 14),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossCount = constraints.maxWidth < 300 ? 2 : 3;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: spots.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossCount,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.82,
              ),
              itemBuilder: (context, index) => _SpotCard(spot: spots[index]),
            );
          },
        ),
      ],
    );
  }
}

class _SpotCard extends StatelessWidget {
  const _SpotCard({required this.spot});

  final LocationSpotCard spot;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final markerColor = locationMarkerColor(spot.suitability);

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        children: [
          if (spot.illustration != null)
            Expanded(
              child: LocationIllustration(
                kind: spot.illustration!,
                size: LocationIllustrationSize.small,
              ),
            )
          else
            const Spacer(),
          const SizedBox(height: 4),
          Text(
            spot.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(locationMarkerIcon(spot.suitability), size: 14, color: markerColor),
              const SizedBox(width: 4),
              Flexible(
                child: Text(
                  spot.status,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: markerColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SplitSection extends StatelessWidget {
  const _SplitSection({required this.section, required this.stack});

  final PlantLocationSection section;
  final bool stack;

  @override
  Widget build(BuildContext context) {
    final illustration = section.illustration;
    final tip = section.infoTip;
    final imageFirst = section.illustrationFirst;

    if (illustration == null) {
      return _LocationTextBlock(section: section);
    }

    final text = _LocationTextBlock(
      section: PlantLocationSection(
        title: section.title,
        subtitle: section.subtitle,
        summary: section.summary,
        items: section.items,
        dimensions: section.dimensions,
        iconLabels: section.iconLabels,
      ),
    );

    final image = LocationIllustration(
      kind: illustration,
      size: section.illustrationSize,
    );

    if (section.illustrationSize == LocationIllustrationSize.inline) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(title: section.title, subtitle: section.subtitle),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              image,
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (section.items != null)
                      ...section.items!.map((i) => _MarkerListItem(item: i)),
                    if (tip != null) ...[
                      const SizedBox(height: 10),
                      _InfoTipBox(tip: tip),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (imageFirst) ...[
            image,
            const SizedBox(height: 14),
          ],
          text,
          if (!imageFirst) ...[
            const SizedBox(height: 14),
            image,
          ],
          if (tip != null) ...[
            const SizedBox(height: 12),
            _InfoTipBox(tip: tip),
          ],
        ],
      );
    }

    if (tip != null && section.dimensions != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(title: section.title, subtitle: section.subtitle),
          if (section.dimensions != null) ...[
            const SizedBox(height: 10),
            ...section.dimensions!.map((d) => _DimensionRow(dimension: d)),
          ],
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: image),
              const SizedBox(width: 12),
              Expanded(child: _InfoTipBox(tip: tip)),
            ],
          ),
        ],
      );
    }

    if (tip != null && imageFirst) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionHeader(title: section.title, subtitle: section.subtitle),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: image),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (section.items != null)
                      ...section.items!.map((i) => _MarkerListItem(item: i)),
                    const SizedBox(height: 12),
                    _InfoTipBox(tip: tip),
                  ],
                ),
              ),
            ],
          ),
        ],
      );
    }

    final left = imageFirst ? image : text;
    final right = imageFirst ? text : image;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(child: left),
        const SizedBox(width: 12),
        Expanded(child: right),
      ],
    );
  }
}

class _ImageBelowSection extends StatelessWidget {
  const _ImageBelowSection({required this.section});

  final PlantLocationSection section;

  @override
  Widget build(BuildContext context) {
    final illustration = section.illustration;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _LocationTextBlock(
          section: PlantLocationSection(
            title: section.title,
            subtitle: section.subtitle,
            items: section.items,
            infoTip: section.infoTip,
          ),
        ),
        if (illustration != null) ...[
          const SizedBox(height: 14),
          LocationIllustration(
            kind: illustration,
            size: section.illustrationSize == LocationIllustrationSize.large
                ? LocationIllustrationSize.large
                : LocationIllustrationSize.compact,
          ),
        ],
      ],
    );
  }
}

class _HumiditySection extends StatelessWidget {
  const _HumiditySection({required this.section});

  final PlantLocationSection section;

  @override
  Widget build(BuildContext context) {
    final options = section.humidityOptions ?? const [];
    final tip = section.infoTip;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionHeader(title: section.title, subtitle: section.subtitle),
        const SizedBox(height: 10),
        Row(
          children: [
            for (var i = 0; i < options.length; i++) ...[
              if (i > 0) const SizedBox(width: 6),
              Expanded(child: _HumidityCard(option: options[i])),
            ],
          ],
        ),
        if (tip != null) ...[
          const SizedBox(height: 10),
          _InfoTipBox(tip: tip),
        ],
      ],
    );
  }
}

class _HumidityCard extends StatelessWidget {
  const _HumidityCard({required this.option});

  final LocationHumidityOption option;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final selected = option.selected;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFFF0FDF4) : const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: selected
              ? const Color(PlantDetailDesign.primaryGreen).withValues(alpha: 0.4)
              : const Color(PlantDetailDesign.border),
        ),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < option.drops; i++) ...[
                if (i > 0) const SizedBox(width: 2),
                Icon(
                  Icons.water_drop_rounded,
                  size: 14,
                  color: selected
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF93C5FD),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            option.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelSmall?.copyWith(
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              fontSize: 9,
              color: selected
                  ? const Color(PlantDetailDesign.primaryGreen)
                  : const Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _LocationTextBlock extends StatelessWidget {
  const _LocationTextBlock({required this.section});

  final PlantLocationSection section;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (section.title.isNotEmpty)
          _SectionHeader(title: section.title, subtitle: section.subtitle),
        if (section.items != null && section.items!.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...section.items!.map((item) => _MarkerListItem(item: item)),
        ],
        if (section.dimensions != null && section.dimensions!.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...section.dimensions!.map((dim) => _DimensionRow(dimension: dim)),
        ],
        if (section.iconLabels != null && section.iconLabels!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(
            spacing: 16,
            runSpacing: 8,
            children: section.iconLabels!.map((item) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.check_rounded,
                    size: 18,
                    color: Color(PlantDetailDesign.primaryGreen),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    item.text,
                    style: t.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ],
        if (section.summary != null && section.summary!.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            section.summary!,
            style: t.textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
        if (section.infoTip != null &&
            section.dimensions == null &&
            section.illustration == null) ...[
          const SizedBox(height: 12),
          _InfoTipBox(tip: section.infoTip!),
        ],
        if (section.infoTip != null &&
            section.dimensions != null &&
            section.illustration != null) ...[
          const SizedBox(height: 12),
          _InfoTipBox(tip: section.infoTip!),
        ],
      ],
    );
  }
}

class _LocationSectionContent extends StatelessWidget {
  const _LocationSectionContent({
    required this.section,
    this.forceCompactImage = false,
  });

  final PlantLocationSection section;
  final bool forceCompactImage;

  @override
  Widget build(BuildContext context) {
    final imageSize = forceCompactImage
        ? LocationIllustrationSize.compact
        : section.illustrationSize;

    final text = _LocationTextBlock(section: section);

    if (section.illustration == null) return text;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        text,
        const SizedBox(height: 12),
        LocationIllustration(
          kind: section.illustration!,
          size: imageSize == LocationIllustrationSize.normal
              ? LocationIllustrationSize.compact
              : imageSize,
        ),
      ],
    );
  }
}

class _MarkerListItem extends StatelessWidget {
  const _MarkerListItem({required this.item});

  final LocationListItem item;

  @override
  Widget build(BuildContext context) {
    final color = locationMarkerColor(item.marker);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(locationMarkerIcon(item.marker), size: 18, color: color),
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

class _DimensionRow extends StatelessWidget {
  const _DimensionRow({required this.dimension});

  final LocationDimension dimension;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              dimension.label,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              dimension.value,
              style: t.textTheme.bodyMedium?.copyWith(
                color: const Color(PlantDetailDesign.textSecondary),
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

  final LocationInfoTip tip;

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
