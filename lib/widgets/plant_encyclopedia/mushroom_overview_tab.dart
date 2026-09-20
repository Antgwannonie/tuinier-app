import 'package:flutter/material.dart';

import '../../data/mushroom_overview_data.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../models/vegetable.dart';
import 'overview_illustrations.dart';
import 'plant_detail_widgets.dart';

abstract final class _MushroomColors {
  static const difficulty = Color(0xFFF3E5F5);
  static const location = Color(0xFFE8F5E9);
  static const temperature = Color(0xFFFFF3E0);
  static const humidity = Color(0xFFE3F2FD);
  static const harvestTime = Color(0xFFFFF9C4);
  static const yield = Color(0xFFFFE0B2);
  static const flushes = Color(0xFFE8F5E9);
  static const substrate = Color(0xFFEDE7F6);
  static const light = Color(0xFFE3F2FD);
  static const ventilation = Color(0xFFFFF9C4);
  static const summary = Color(0xFFE8F5E9);
  static const edibility = Color(0xFFFFF3E0);
  static const beginner = Color(0xFFE8F5E9);
  static const tip = Color(0xFFFFF8E7);
}

class MushroomOverviewTab extends StatelessWidget {
  const MushroomOverviewTab({
    super.key,
    required this.vegetable,
    required this.layout,
    this.useNestedScroll = false,
  });

  final Vegetable vegetable;
  final MushroomOverviewLayout layout;
  final bool useNestedScroll;

  List<Widget> _content(BuildContext context) {
    final crossAxisCount = MediaQuery.sizeOf(context).width < 340 ? 2 : 3;

    return [
      Text(
        layout.growSeasonNote,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              height: 1.4,
              fontSize: 13,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
      ),
      const SizedBox(height: 8),
      PlantMonthTimelineRow(timeline: layout.growSeason),
      const SizedBox(height: 12),
      GridView.count(
        crossAxisCount: crossAxisCount,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: crossAxisCount == 3 ? 0.95 : 1.35,
        children: [
          _stat(
            icon: Icons.eco_outlined,
            imageAsset: OverviewAssets.moeilijkheid,
            label: 'Moeilijkheid',
            value: layout.difficulty,
            subtitle: layout.difficultySubtitle,
            valueColor: layout.difficultyColor,
            backgroundColor: _MushroomColors.difficulty,
          ),
          _stat(
            icon: Icons.home_outlined,
            imageAsset: OverviewAssets.locatie,
            label: 'Kweeklocatie',
            value: layout.location,
            subtitle: layout.locationSubtitle,
            backgroundColor: _MushroomColors.location,
          ),
          _stat(
            icon: Icons.thermostat_outlined,
            label: 'Temperatuur',
            value: layout.temperature,
            subtitle: layout.temperatureSubtitle,
            backgroundColor: _MushroomColors.temperature,
          ),
          _stat(
            icon: Icons.water_drop_outlined,
            imageAsset: OverviewAssets.water,
            label: 'Luchtvochtigheid',
            value: layout.humidity,
            subtitle: layout.humiditySubtitle,
            backgroundColor: _MushroomColors.humidity,
          ),
          _stat(
            icon: Icons.schedule_outlined,
            imageAsset: OverviewAssets.oogstTijd,
            label: 'Tijd tot eerste oogst',
            value: layout.timeToHarvest,
            backgroundColor: _MushroomColors.harvestTime,
          ),
          _stat(
            icon: Icons.shopping_basket_outlined,
            imageAsset: OverviewAssets.opbrengst,
            label: 'Opbrengst',
            value: layout.yield,
            backgroundColor: _MushroomColors.yield,
          ),
          _stat(
            icon: Icons.autorenew_rounded,
            label: 'Aantal oogsten',
            value: layout.flushCount,
            backgroundColor: _MushroomColors.flushes,
          ),
          _stat(
            icon: Icons.forest_outlined,
            label: 'Substraat',
            value: layout.substrate,
            backgroundColor: _MushroomColors.substrate,
          ),
          _stat(
            icon: Icons.wb_sunny_outlined,
            imageAsset: OverviewAssets.standplaats,
            label: 'Lichtbehoefte',
            value: layout.light,
            backgroundColor: _MushroomColors.light,
          ),
        ],
      ),
      const SizedBox(height: 12),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              flex: 4,
              child: MushroomStatCard(
                icon: Icons.air_outlined,
                label: 'Ventilatie',
                value: layout.ventilation,
                subtitle: layout.ventilationSubtitle,
                backgroundColor: _MushroomColors.ventilation,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              flex: 8,
              child: MushroomSummaryCard(
                text: layout.summary,
                imageAsset: OverviewAssets.samenvatting,
              ),
            ),
          ],
        ),
      ),
      const SizedBox(height: 12),
      MushroomStagesTimeline(stages: layout.stages),
      const SizedBox(height: 12),
      IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: MushroomEdibilityCard(
                title: layout.edibility,
                subtitle: layout.edibilitySubtitle,
                stars: layout.edibilityStars,
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: MushroomBeginnerCard(
                suitability: layout.beginnerSuitability,
                subtitle: layout.beginnerSubtitle,
                recommended: layout.beginnerRecommended,
              ),
            ),
          ],
        ),
      ),
      if (layout.goodToKnow.trim().isNotEmpty) ...[
        const SizedBox(height: 12),
        PlantDidYouKnowCard(
          text: layout.goodToKnow,
          imageAsset: OverviewAssets.weetjes,
        ),
      ],
    ];
  }

  Widget _stat({
    required IconData icon,
    String? imageAsset,
    required String label,
    required String value,
    String? subtitle,
    Color? valueColor,
    required Color backgroundColor,
  }) {
    return MushroomStatCard(
      icon: icon,
      imageAsset: imageAsset,
      label: label,
      value: value,
      subtitle: subtitle,
      valueColor: valueColor,
      backgroundColor: backgroundColor,
    );
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.fromLTRB(16, 0, 16, 32);
    final children = _content(context);

    if (useNestedScroll) {
      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverList(
              delegate: SliverChildListDelegate(children),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: padding,
      children: children,
    );
  }
}

class MushroomStatCard extends StatelessWidget {
  const MushroomStatCard({
    super.key,
    required this.icon,
    this.imageAsset,
    required this.label,
    required this.value,
    this.subtitle,
    this.valueColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String? imageAsset;
  final String label;
  final String value;
  final String? subtitle;
  final Color? valueColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: backgroundColor.withValues(alpha: 0.7)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageAsset != null)
            Image.asset(
              imageAsset!,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => Icon(
                icon,
                size: 24,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            )
          else
            Icon(
              icon,
              size: 24,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          const Spacer(),
          Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
              height: 1.15,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 11,
              height: 1.2,
              color: valueColor ?? const Color(PlantDetailDesign.textSecondary),
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 1),
            Text(
              subtitle!,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall?.copyWith(
                fontSize: 10,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class MushroomSummaryCard extends StatelessWidget {
  const MushroomSummaryCard({
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _MushroomColors.summary,
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
                  width: 22,
                  height: 22,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.lightbulb_outline,
                    size: 18,
                    color: Color(PlantDetailDesign.primaryGreen),
                  ),
                )
              else
                const Icon(
                  Icons.lightbulb_outline,
                  size: 18,
                  color: Color(PlantDetailDesign.primaryGreen),
                ),
              const SizedBox(width: 6),
              Text(
                'Samenvatting',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(PlantDetailDesign.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: t.bodySmall?.copyWith(
              height: 1.4,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class MushroomStagesTimeline extends StatelessWidget {
  const MushroomStagesTimeline({super.key, required this.stages});

  final List<MushroomGrowthStage> stages;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlantDetailSectionTitle(
            title: 'Belangrijkste momenten',
            imageAsset: OverviewAssets.momenten,
          ),
          const SizedBox(height: 16),
          LayoutBuilder(
            builder: (context, constraints) {
              final itemWidth = constraints.maxWidth / stages.length;
              return Stack(
                alignment: Alignment.topCenter,
                children: [
                  Positioned(
                    top: 18,
                    left: itemWidth / 2,
                    right: itemWidth / 2,
                    child: Container(
                      height: 2,
                      color: const Color(PlantDetailDesign.border),
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final stage in stages)
                        SizedBox(
                          width: itemWidth,
                          child: Column(
                            children: [
                              Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: const Color(0xFFE8F5E9),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: const Color(0xFFC8E6C9),
                                  ),
                                ),
                                child: Icon(
                                  stage.icon,
                                  size: 18,
                                  color:
                                      const Color(PlantDetailDesign.primaryGreen),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                stage.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: t.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 11,
                                  color: const Color(PlantDetailDesign.textPrimary),
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                stage.duration,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: t.bodySmall?.copyWith(
                                  fontSize: 10,
                                  height: 1.2,
                                  color:
                                      const Color(PlantDetailDesign.textSecondary),
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class MushroomEdibilityCard extends StatelessWidget {
  const MushroomEdibilityCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.stars,
  });

  final String title;
  final String? subtitle;
  final int stars;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final clampedStars = stars.clamp(0, 5);

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _MushroomColors.edibility,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFCC80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.restaurant_outlined,
                size: 20,
                color: Color(PlantDetailDesign.primaryGreen),
              ),
              const SizedBox(width: 6),
              Text(
                'Eetbaarheid',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: const Color(PlantDetailDesign.textPrimary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: t.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
          if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              style: t.bodySmall?.copyWith(
                fontSize: 11,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
          ],
          const SizedBox(height: 8),
          Row(
            children: [
              for (var i = 0; i < 5; i++)
                Icon(
                  i < clampedStars ? Icons.star_rounded : Icons.star_outline_rounded,
                  size: 18,
                  color: const Color(0xFFF59E0B),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class MushroomBeginnerCard extends StatelessWidget {
  const MushroomBeginnerCard({
    super.key,
    required this.suitability,
    this.subtitle,
    required this.recommended,
  });

  final String suitability;
  final String? subtitle;
  final bool recommended;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: _MushroomColors.beginner,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.person_outline,
                    size: 20,
                    color: Color(PlantDetailDesign.primaryGreen),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Geschikt voor beginners',
                      style: t.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                        color: const Color(PlantDetailDesign.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                suitability,
                style: t.bodySmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: recommended
                      ? const Color(PlantDetailDesign.primaryGreen)
                      : const Color(PlantDetailDesign.textPrimary),
                ),
              ),
              if (subtitle != null && subtitle!.trim().isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: t.bodySmall?.copyWith(
                    fontSize: 11,
                    color: const Color(PlantDetailDesign.textSecondary),
                  ),
                ),
              ],
              const SizedBox(height: 28),
            ],
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Icon(
              recommended ? Icons.check_circle : Icons.cancel_outlined,
              size: 32,
              color: recommended
                  ? const Color(PlantDetailDesign.primaryGreen)
                  : const Color(0xFFE53935),
            ),
          ),
        ],
      ),
    );
  }
}
