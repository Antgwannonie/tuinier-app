import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/planting_calendar.dart';
import 'seasonal_month_calendar.dart';

/// Maandkalender in tuinplanner-stijl met seizoensillustratie.
class PlantMonthTimelineRow extends StatelessWidget {
  const PlantMonthTimelineRow({
    super.key,
    required this.timeline,
    this.compact = false,
    this.comfortable = false,
    this.accentColor,
  });

  final PlantMonthTimeline timeline;
  final bool compact;
  /// Meer ruimte tussen maandletters — handig onder Wanneer/Hoe.
  final bool comfortable;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return SeasonalMonthCalendar(
      months: timeline.months,
      label: timeline.label,
      compact: compact,
      showTitle: !compact,
      accentColor:
          accentColor ?? const Color(PlantDetailDesign.primaryGreen),
    );
  }
}

/// Witte kaart met schaduw volgens designsysteem.
class PlantDetailCard extends StatelessWidget {
  const PlantDetailCard({
    super.key,
    required this.child,
    this.padding,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(PlantDetailDesign.cardPadding),
      decoration: BoxDecoration(
        color: const Color(PlantDetailDesign.card),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }
}

class PlantDetailSectionTitle extends StatelessWidget {
  const PlantDetailSectionTitle({
    super.key,
    required this.title,
    this.icon,
    this.imageAsset,
    this.iconSize = 24,
  });

  final String title;
  final IconData? icon;
  final String? imageAsset;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset!,
            width: iconSize,
            height: iconSize,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Icon(
              icon ?? Icons.eco_outlined,
              size: iconSize,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          )
        else
          Icon(
            icon ?? Icons.eco_outlined,
            size: iconSize,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(PlantDetailDesign.primaryGreen),
                ),
          ),
        ),
      ],
    );
  }
}

class PlantStatTile extends StatelessWidget {
  const PlantStatTile({
    super.key,
    this.icon,
    this.imageAsset,
    required this.label,
    required this.value,
    this.subtitle,
    this.iconColor,
    this.backgroundColor,
    this.valueMaxLines,
    this.subtitleMaxLines,
    this.expandToFill = false,
  });

  final IconData? icon;
  final String? imageAsset;
  final String label;
  final String value;
  final String? subtitle;
  final Color? iconColor;
  final Color? backgroundColor;
  final int? valueMaxLines;
  final int? subtitleMaxLines;
  /// Vult de beschikbare celhoogte (handig in gelijke overview-grids).
  final bool expandToFill;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final valueLines = valueMaxLines ?? (subtitle == null ? 2 : 2);
    final subLines = subtitleMaxLines ?? 2;

    final content = Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (imageAsset != null)
          Image.asset(
            imageAsset!,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Icon(
              icon ?? Icons.eco_outlined,
              size: 26,
              color: iconColor ?? const Color(PlantDetailDesign.primaryGreen),
            ),
          )
        else
          Icon(
            icon ?? Icons.eco_outlined,
            size: 26,
            color: iconColor ?? const Color(PlantDetailDesign.primaryGreen),
          ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: expandToFill ? MainAxisSize.max : MainAxisSize.min,
            children: [
              Text(
                label,
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(PlantDetailDesign.textPrimary),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                maxLines: valueLines,
                overflow: TextOverflow.ellipsis,
                style: t.bodySmall?.copyWith(
                  color: const Color(PlantDetailDesign.textSecondary),
                  height: 1.25,
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: subLines,
                  overflow: TextOverflow.ellipsis,
                  style: t.bodySmall?.copyWith(
                    color: const Color(PlantDetailDesign.textSecondary),
                    height: 1.25,
                    fontSize: 11.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );

    return Container(
      width: double.infinity,
      height: expandToFill ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(0xFFF1F3F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: (backgroundColor ?? const Color(0xFFF1F3F2)).withValues(
            alpha: 0.6,
          ),
        ),
      ),
      child: content,
    );
  }
}

/// Mintgroene samenvattingskaart onder de eigenschappen.
class PlantSummaryCard extends StatelessWidget {
  const PlantSummaryCard({
    super.key,
    required this.text,
    this.imageAsset,
  });

  final String text;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Color(PlantDetailDesign.primaryGreen),
                  ),
                )
              else
                const Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Color(PlantDetailDesign.primaryGreen),
                ),
              const SizedBox(width: 8),
              Text(
                'Samenvatting',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(PlantDetailDesign.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            text,
            style: t.bodyMedium?.copyWith(
              height: 1.45,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Binnenste rij voor teeltmoment (zonder eigen kaartrand).
class PlantMomentRow extends StatelessWidget {
  const PlantMomentRow({
    super.key,
    required this.timeline,
    this.icon,
    this.imageAsset,
    this.iconColor,
    this.accentColor,
  });

  final PlantMonthTimeline timeline;
  final IconData? icon;
  final String? imageAsset;
  final Color? iconColor;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final color = iconColor ?? const Color(PlantDetailDesign.primaryGreen);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (imageAsset != null)
              Image.asset(
                imageAsset!,
                width: 28,
                height: 28,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) =>
                    Icon(icon ?? Icons.eco_outlined, size: 22, color: color),
              )
            else
              Icon(icon ?? Icons.eco_outlined, size: 22, color: color),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    timeline.label,
                    style: t.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: const Color(PlantDetailDesign.textPrimary),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    formatPlantMonthRange(timeline.months),
                    style: t.bodySmall?.copyWith(
                      color: const Color(PlantDetailDesign.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        PlantMonthTimelineRow(
          timeline: timeline,
          compact: true,
          accentColor: accentColor,
        ),
      ],
    );
  }
}

/// Sectiekaart met kop in de kaart (overzicht-tab).
class PlantOverviewSectionCard extends StatelessWidget {
  const PlantOverviewSectionCard({
    super.key,
    required this.title,
    this.icon,
    this.imageAsset,
    required this.children,
  });

  final String title;
  final IconData? icon;
  final String? imageAsset;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          PlantDetailSectionTitle(
            title: title,
            icon: icon,
            imageAsset: imageAsset,
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

/// Losse kaart per teeltmoment (zaaien, uitplanten, oogst).
class PlantMomentCard extends StatelessWidget {
  const PlantMomentCard({
    super.key,
    required this.timeline,
    required this.icon,
    this.iconColor,
  });

  final PlantMonthTimeline timeline;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(PlantDetailDesign.card),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: PlantMomentRow(
        timeline: timeline,
        icon: icon,
        iconColor: iconColor,
      ),
    );
  }
}

/// Compacte specs-kaart (groei of oogst) voor naast elkaar in een rij.
class PlantSpecMiniCard extends StatelessWidget {
  const PlantSpecMiniCard({
    super.key,
    required this.title,
    this.icon,
    this.imageAsset,
    required this.lines,
    this.iconColor,
    this.backgroundColor,
    this.compact = false,
  });

  final String title;
  final IconData? icon;
  final String? imageAsset;
  final List<(String label, String value)> lines;
  final Color? iconColor;
  final Color? backgroundColor;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.all(compact ? 10 : 14),
      decoration: BoxDecoration(
        color: backgroundColor ?? const Color(PlantDetailDesign.card),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  width: compact ? 20 : 24,
                  height: compact ? 20 : 24,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => Icon(
                    icon ?? Icons.eco_outlined,
                    size: 20,
                    color: iconColor ??
                        const Color(PlantDetailDesign.primaryGreen),
                  ),
                )
              else
                Icon(
                  icon ?? Icons.eco_outlined,
                  size: 20,
                  color:
                      iconColor ?? const Color(PlantDetailDesign.primaryGreen),
                ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  title,
                  style: t.labelLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: compact ? 12 : null,
                    color: const Color(PlantDetailDesign.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 8 : 10),
          ...lines.map((line) {
            return Padding(
              padding: EdgeInsets.only(bottom: compact ? 4 : 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    line.$1,
                    style: t.labelSmall?.copyWith(
                      fontSize: compact ? 10 : null,
                      color: const Color(PlantDetailDesign.textSecondary),
                    ),
                  ),
                  Text(
                    line.$2,
                    style: t.bodySmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      fontSize: compact ? 11 : null,
                      color: const Color(PlantDetailDesign.textPrimary),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

/// Gele tip-kaart onderaan het overzicht.
class PlantDidYouKnowCard extends StatelessWidget {
  const PlantDidYouKnowCard({
    super.key,
    required this.text,
    this.imageAsset,
  });

  final String text;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.star_rounded,
                    size: 20,
                    color: Color(0xFFF59E0B),
                  ),
                )
              else
                const Icon(
                  Icons.star_rounded,
                  size: 20,
                  color: Color(0xFFF59E0B),
                ),
              const SizedBox(width: 8),
              Text(
                'Goed om te weten',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(PlantDetailDesign.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: t.bodyMedium?.copyWith(
              height: 1.45,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

/// Horizontale rij met zaaien, uitplanten en oogst (overzicht-tab).
class PlantOverviewMomentsStrip extends StatelessWidget {
  const PlantOverviewMomentsStrip({
    super.key,
    required this.sowing,
    required this.planting,
    required this.harvest,
    this.bloom,
    this.sowingIcon,
    this.plantingIcon,
    this.harvestIcon,
    this.bloomIcon,
  });

  final PlantMonthTimeline sowing;
  final PlantMonthTimeline planting;
  final PlantMonthTimeline harvest;
  final PlantMonthTimeline? bloom;
  final String? sowingIcon;
  final String? plantingIcon;
  final String? harvestIcon;
  final String? bloomIcon;

  @override
  Widget build(BuildContext context) {
    final items = <_MomentStripItem>[
      _MomentStripItem(
        timeline: sowing,
        imageAsset: sowingIcon,
        icon: Icons.eco_outlined,
      ),
      _MomentStripItem(
        timeline: planting,
        imageAsset: plantingIcon,
        icon: Icons.yard_outlined,
      ),
      if (bloom != null)
        _MomentStripItem(
          timeline: bloom!,
          imageAsset: bloomIcon,
          icon: Icons.local_florist_outlined,
        ),
      _MomentStripItem(
        timeline: harvest,
        imageAsset: harvestIcon,
        icon: Icons.shopping_basket_outlined,
      ),
    ];

    return PlantDetailCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlantDetailSectionTitle(
            title: 'Belangrijkste momenten',
            imageAsset: 'assets/images/overview/overview_calendar.png',
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++) ...[
                if (i > 0)
                  Container(
                    width: 1,
                    height: 72,
                    margin: const EdgeInsets.symmetric(horizontal: 6),
                    color: const Color(PlantDetailDesign.border),
                  ),
                Expanded(child: _MomentStripTile(item: items[i])),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

class _MomentStripItem {
  const _MomentStripItem({
    required this.timeline,
    this.imageAsset,
    required this.icon,
  });

  final PlantMonthTimeline timeline;
  final String? imageAsset;
  final IconData icon;
}

class _MomentStripTile extends StatelessWidget {
  const _MomentStripTile({required this.item});

  final _MomentStripItem item;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        if (item.imageAsset != null)
          Image.asset(
            item.imageAsset!,
            width: 32,
            height: 32,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (_, __, ___) => Icon(
              item.icon,
              size: 28,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          )
        else
          Icon(
            item.icon,
            size: 28,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
        const SizedBox(height: 6),
        Text(
          item.timeline.label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: t.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: const Color(PlantDetailDesign.textPrimary),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          formatPlantMonthRange(item.timeline.months),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: t.bodySmall?.copyWith(
            fontSize: 11,
            height: 1.2,
            color: const Color(PlantDetailDesign.textSecondary),
          ),
        ),
      ],
    );
  }
}

/// Opbrengst-kaart in het overzicht.
class PlantYieldCard extends StatelessWidget {
  const PlantYieldCard({
    super.key,
    required this.level,
    required this.detail,
    this.imageAsset,
  });

  final String level;
  final String detail;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              width: 36,
              height: 36,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.shopping_basket_outlined,
                size: 32,
                color: Color(PlantDetailDesign.primaryGreen),
              ),
            )
          else
            const Icon(
              Icons.shopping_basket_outlined,
              size: 32,
              color: Color(PlantDetailDesign.primaryGreen),
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Opbrengst',
                  style: t.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(PlantDetailDesign.textPrimary),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  level,
                  style: t.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(PlantDetailDesign.primaryGreen),
                  ),
                ),
                if (detail.trim().isNotEmpty && detail != '—') ...[
                  const SizedBox(height: 4),
                  Text(
                    detail,
                    style: t.bodySmall?.copyWith(
                      height: 1.35,
                      color: const Color(PlantDetailDesign.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Samenvatting met checklist in twee kolommen (overzicht-tab).
class PlantOverviewSummaryCard extends StatelessWidget {
  const PlantOverviewSummaryCard({
    super.key,
    required this.points,
    this.imageAsset,
  });

  final List<String> points;
  final String? imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final items = points.where((p) => p.trim().isNotEmpty).toList();
    if (items.isEmpty) return const SizedBox.shrink();

    final split = (items.length / 2).ceil();
    final left = items.take(split).toList();
    final right = items.skip(split).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE082)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (imageAsset != null)
                Image.asset(
                  imageAsset!,
                  width: 24,
                  height: 24,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lightbulb_outline,
                    size: 20,
                    color: Color(PlantDetailDesign.primaryGreen),
                  ),
                )
              else
                const Icon(
                  Icons.lightbulb_outline,
                  size: 20,
                  color: Color(PlantDetailDesign.primaryGreen),
                ),
              const SizedBox(width: 8),
              Text(
                'Samenvatting',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(PlantDetailDesign.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  children: left
                      .map((text) => PlantChecklistItem(text: text))
                      .toList(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  children: right
                      .map((text) => PlantChecklistItem(text: text))
                      .toList(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class PlantChecklistItem extends StatelessWidget {
  const PlantChecklistItem({super.key, required this.text});

  final String text;

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
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Color(0xFFE8F5E9),
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 16,
              color: Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.35,
                    color: const Color(PlantDetailDesign.textPrimary),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class PlantFactLine extends StatelessWidget {
  const PlantFactLine({
    super.key,
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: const Color(PlantDetailDesign.textSecondary),
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(PlantDetailDesign.textPrimary),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

IconData plantCategoryIcon(PlantInfoCategoryId id) {
  switch (id) {
    case PlantInfoCategoryId.zaaien:
      return Icons.eco_outlined;
    case PlantInfoCategoryId.uitplanten:
      return Icons.yard_outlined;
    case PlantInfoCategoryId.standplaats:
      return Icons.wb_sunny_outlined;
    case PlantInfoCategoryId.water:
      return Icons.water_drop_outlined;
    case PlantInfoCategoryId.voeding:
      return Icons.grass_outlined;
    case PlantInfoCategoryId.groei:
      return Icons.trending_up_outlined;
    case PlantInfoCategoryId.bloei:
      return Icons.local_florist_outlined;
    case PlantInfoCategoryId.oogsten:
      return Icons.shopping_basket_outlined;
    case PlantInfoCategoryId.verzorging:
      return Icons.content_cut_outlined;
    case PlantInfoCategoryId.problemen:
      return Icons.shield_outlined;
    case PlantInfoCategoryId.combinatieteelt:
      return Icons.thumb_up_outlined;
    case PlantInfoCategoryId.weetjes:
      return Icons.lightbulb_outline;
  }
}

Widget plantSuitabilityIcon(PlantSuitability s) {
  switch (s) {
    case PlantSuitability.suitable:
      return const Icon(Icons.check, size: 16, color: Color(PlantDetailDesign.success));
    case PlantSuitability.limited:
      return const Icon(Icons.warning_amber_rounded,
          size: 16, color: Color(PlantDetailDesign.warning));
    case PlantSuitability.notRecommended:
      return const Icon(Icons.close, size: 16, color: Color(0xFFEF4444));
  }
}
