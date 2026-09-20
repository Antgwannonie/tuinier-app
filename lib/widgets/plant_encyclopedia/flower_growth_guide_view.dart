import 'package:flutter/material.dart';

import '../../data/flower_growth_guide_data.dart';
import '../../data/flower_section_details.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_growth_guide.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

/// Flower-only Groei-layout: tekst boven, afbeelding eronder (zoals Uitplanten).
class FlowerGrowthGuideView extends StatelessWidget {
  const FlowerGrowthGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantGrowthGuide guide;

  static const _wideBreakpoint = 520.0;
  static const _imageHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    final g = flowerGrowthGuideForVegetable(
      vegetable: vegetable,
      layout: layout,
    );
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StatsGrid(stats: g.stats, wide: wide),
        const SizedBox(height: 12),
        _PhasesCard(phases: g.phases),
        const SizedBox(height: 12),
        _HabitCard(
          title: g.habitTitle,
          description: g.habitDescription,
          imageAsset: g.habitImage,
          vegetable: vegetable,
        ),
        const SizedBox(height: 12),
        _ActionsGrid(actions: g.actions, wide: wide),
        const SizedBox(height: 12),
        _TipBanner(text: g.tip, imageAsset: g.tipImage),
        const SizedBox(height: 12),
        _SeasonsGrid(seasons: g.seasons, wide: wide),
        const SizedBox(height: 12),
        _MistakesCard(
          mistakes: g.mistakes,
          imageAsset: g.mistakesImage,
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({required this.stats, required this.wide});

  final List<FlowerGrowthStat> stats;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < stats.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _StatCard(stat: stats[i])),
            ],
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.72,
      children: [for (final stat in stats) _StatCard(stat: stat)],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.stat});

  final FlowerGrowthStat stat;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      padding: const EdgeInsets.all(12),
      child: wrapGuideDetailCard(
        context: context,
        title: stat.label,
        summary: stat.value,
        details: stat.details,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              stat.label,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.value,
              style: t.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              stat.description,
              style: t.bodySmall?.copyWith(
                height: 1.35,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
            const SizedBox(height: 10),
            Flexible(
              child: _UnderTextImage(
                assetPath: stat.imageAsset,
                height: FlowerGrowthGuideView._imageHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhasesCard extends StatelessWidget {
  const _PhasesCard({required this.phases});

  final List<FlowerGrowthPhase> phases;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Groeifases',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: phases.length,
              separatorBuilder: (_, __) => Padding(
                padding: const EdgeInsets.only(top: 60),
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: const Color(PlantDetailDesign.primaryGreen)
                      .withValues(alpha: 0.55),
                ),
              ),
              itemBuilder: (context, index) {
                final phase = phases[index];
                return SizedBox(
                  width: 120,
                  child: wrapGuideDetailCard(
                    context: context,
                    title: phase.label,
                    summary: phase.description,
                    details: phase.details,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          phase.label,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(PlantDetailDesign.primaryGreen),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phase.description,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: t.bodySmall?.copyWith(
                            fontSize: 11,
                            height: 1.3,
                            color: const Color(PlantDetailDesign.textSecondary),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: _UnderTextImage(
                            assetPath: phase.imageAsset,
                            height: 100,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _HabitCard extends StatelessWidget {
  const _HabitCard({
    required this.title,
    required this.description,
    required this.imageAsset,
    required this.vegetable,
  });

  final String title;
  final String description;
  final String imageAsset;
  final Vegetable vegetable;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final details = flowerSectionDetailsFor(
      tab: 'growth',
      title: title,
      vegetable: vegetable,
    );

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: title,
        summary: description,
        details: details,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              description,
              style: t.bodySmall?.copyWith(
                height: 1.35,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            _UnderTextImage(
              assetPath: imageAsset,
              height: 140,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionsGrid extends StatelessWidget {
  const _ActionsGrid({required this.actions, required this.wide});

  final List<FlowerGrowthAction> actions;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < actions.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _ActionCard(action: actions[i])),
            ],
          ],
        ),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.75,
      children: [for (final action in actions) _ActionCard(action: action)],
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({required this.action});

  final FlowerGrowthAction action;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      padding: const EdgeInsets.all(12),
      child: wrapGuideDetailCard(
        context: context,
        title: action.label,
        summary: action.description,
        details: action.details,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            action.label,
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            action.description,
            style: t.bodySmall?.copyWith(
              height: 1.35,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          _UnderTextImage(
            assetPath: action.imageAsset,
            height: 90,
          ),
        ],
        ),
      ),
    );
  }
}

class _TipBanner extends StatelessWidget {
  const _TipBanner({required this.text, required this.imageAsset});

  final String text;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFC8E6C9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  size: 18,
                  color: Color(PlantDetailDesign.primaryGreen),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  text,
                  style: t.bodySmall?.copyWith(
                    height: 1.4,
                    color: const Color(PlantDetailDesign.textPrimary),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _UnderTextImage(assetPath: imageAsset, height: 100),
        ],
      ),
    );
  }
}

class _SeasonsGrid extends StatelessWidget {
  const _SeasonsGrid({required this.seasons, required this.wide});

  final List<FlowerGrowthSeason> seasons;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cards = [for (final season in seasons) _SeasonCard(season: season)];

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Seizoensgroei',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(PlantDetailDesign.primaryGreen),
                ),
          ),
          const SizedBox(height: 12),
          if (wide)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var i = 0; i < cards.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: cards[i]),
                  ],
                ],
              ),
            )
          else
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              childAspectRatio: 0.78,
              children: cards,
            ),
        ],
      ),
    );
  }
}

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({required this.season});

  final FlowerGrowthSeason season;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return wrapGuideDetailCard(
      context: context,
      title: season.label,
      summary: season.description,
      details: season.details,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F8E9),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(PlantDetailDesign.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              season.label,
              style: t.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              season.months,
              style: t.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              season.description,
              style: t.bodySmall?.copyWith(
                fontSize: 11,
                height: 1.3,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            _UnderTextImage(
              assetPath: season.imageAsset,
              height: 80,
            ),
          ],
        ),
      ),
    );
  }
}

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({
    required this.mistakes,
    required this.imageAsset,
  });

  final List<FlowerGrowthMistake> mistakes;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Veelgemaakte fouten',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 10),
          for (final item in mistakes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: wrapGuideDetailCard(
                context: context,
                title: item.title,
                summary: item.body,
                details: item.details,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFEBEE),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE53935),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.title,
                              style: t.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color:
                                    const Color(PlantDetailDesign.textPrimary),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.body,
                              style: t.bodySmall?.copyWith(
                                height: 1.35,
                                color: const Color(
                                    PlantDetailDesign.textSecondary),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          _UnderTextImage(
            assetPath: imageAsset,
            height: FlowerGrowthGuideView._imageHeight,
          ),
        ],
      ),
    );
  }
}

class _UnderTextImage extends StatelessWidget {
  const _UnderTextImage({
    required this.assetPath,
    required this.height,
  });

  final String assetPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 28),
        ),
      ),
    );
  }
}
