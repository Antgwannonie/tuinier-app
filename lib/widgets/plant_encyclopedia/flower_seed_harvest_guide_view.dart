import 'package:flutter/material.dart';

import '../../data/flower_seed_harvest_guide_data.dart';
import '../../data/flower_sowing_guide_data.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_harvest_guide.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'seasonal_month_calendar.dart';

/// Flower-only Zaadoogst-layout: tekst boven, afbeelding eronder (zoals Uitplanten).
/// Geen plant-oogst layout met vrucht-/groente-koppen.
class FlowerSeedHarvestGuideView extends StatelessWidget {
  const FlowerSeedHarvestGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantHarvestGuide guide;

  static const _wideBreakpoint = 520.0;
  static const _imageHeight = 100.0;

  /// Deze secties krijgen een eigen kaart over de volle breedte,
  /// onder elkaar, zodat er meer ruimte is voor tekst.
  static const _fullWidthLabels = {
    'Zaden verzamelen',
    'Zaden losmaken',
    'Zaden zeven',
    'Bewaren',
  };

  @override
  Widget build(BuildContext context) {
    final g = flowerSeedHarvestGuideForVegetable(
      vegetable: vegetable,
      layout: layout,
    );
    final sowingGuide = flowerSowingGuideForVegetable(vegetable);
    final sowMonths = {
      ...sowingGuide.indoorMonths,
      ...sowingGuide.outdoorMonths,
    };
    final harvestMonths = {
      for (final month in g.calendar)
        if (month.status != FlowerSeedCalendarStatus.none) month.month,
    };
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    FlowerSeedFact? whenFact;
    for (final fact in g.facts) {
      if (fact.label == 'Wanneer oogsten') {
        whenFact = fact;
        break;
      }
    }
    final gridFacts = [
      for (final fact in g.facts)
        if (fact != whenFact && !_fullWidthLabels.contains(fact.label)) fact,
    ];
    final fullWidthFacts = [
      for (final fact in g.facts)
        if (_fullWidthLabels.contains(fact.label)) fact,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (whenFact != null) ...[
          _FullWidthFactCard(
            fact: whenFact,
            calendarMonths: harvestMonths,
          ),
          const SizedBox(height: 12),
        ],
        _FactsGrid(facts: gridFacts, wide: wide),
        for (final fact in fullWidthFacts) ...[
          const SizedBox(height: 12),
          _FullWidthFactCard(fact: fact),
        ],
        const SizedBox(height: 12),
        _SelfSowBanner(
          title: g.selfSowTitle,
          period: g.selfSowPeriod,
          body: g.selfSowBody,
          imageAsset: g.selfSowImage,
          sowMonths: sowMonths,
        ),
        const SizedBox(height: 12),
        _TipsBanner(tips: g.tips, imageAsset: g.tipImage),
        const SizedBox(height: 12),
        _CalendarCard(months: g.calendar, note: g.calendarNote),
        const SizedBox(height: 12),
        _MistakesCard(mistakes: g.mistakes),
      ],
    );
  }
}

class _FactsGrid extends StatelessWidget {
  const _FactsGrid({required this.facts, required this.wide});

  final List<FlowerSeedFact> facts;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: wide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: wide ? 0.72 : 0.72,
      children: [for (final fact in facts) _FactCard(fact: fact)],
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.fact});

  final FlowerSeedFact fact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      padding: const EdgeInsets.all(10),
      child: wrapGuideDetailCard(
        context: context,
        title: fact.label,
        summary: fact.value,
        details: fact.details,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              fact.label,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
                fontSize: 13,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fact.value,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: t.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(0xFF5D4037),
                height: 1.2,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              fact.description,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: t.bodySmall?.copyWith(
                height: 1.3,
                fontSize: 11,
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: _UnderTextImage(
                assetPath: fact.imageAsset,
                height: FlowerSeedHarvestGuideView._imageHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kaart over de volle breedte: tekst boven, afbeelding (en eventueel
/// maandkalender) eronder.
class _FullWidthFactCard extends StatelessWidget {
  const _FullWidthFactCard({
    required this.fact,
    this.calendarMonths,
  });

  final FlowerSeedFact fact;
  final Set<int>? calendarMonths;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final months = calendarMonths;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: fact.label,
        summary: fact.value,
        details: fact.details,
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            fact.label,
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fact.value,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5D4037),
              height: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            fact.description,
            style: t.bodySmall?.copyWith(
              height: 1.35,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
          const SizedBox(height: 10),
          _UnderTextImage(assetPath: fact.imageAsset, height: 120),
          if (months != null && months.isNotEmpty) ...[
            const SizedBox(height: 12),
            SeasonalMonthCalendar(
              months: months,
              compact: true,
              showTitle: false,
              accentColor: const Color(0xFF5D4037),
            ),
          ],
        ],
        ),
      ),
    );
  }
}

class _SelfSowBanner extends StatelessWidget {
  const _SelfSowBanner({
    required this.title,
    required this.period,
    required this.body,
    required this.imageAsset,
    required this.sowMonths,
  });

  final String title;
  final String period;
  final String body;
  final String imageAsset;
  final Set<int> sowMonths;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
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
          const SizedBox(height: 4),
          Text(
            period,
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF5D4037),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            style: t.bodySmall?.copyWith(
              height: 1.4,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          if (sowMonths.isNotEmpty)
            SeasonalMonthCalendar(
              months: sowMonths,
              compact: true,
              showTitle: false,
            )
          else
            _UnderTextImage(assetPath: imageAsset, height: 130),
        ],
      ),
    );
  }
}

class _TipsBanner extends StatelessWidget {
  const _TipsBanner({required this.tips, required this.imageAsset});

  final List<String> tips;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F0E6),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8DCC8)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: Color(0xFFE8DCC8),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.eco_outlined,
                  size: 18,
                  color: Color(PlantDetailDesign.primaryGreen),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'Tips',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(PlantDetailDesign.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final tip in tips)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 6),
                    child: Icon(
                      Icons.circle,
                      size: 6,
                      color: Color(PlantDetailDesign.primaryGreen),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tip,
                      style: t.bodySmall?.copyWith(
                        height: 1.4,
                        color: const Color(PlantDetailDesign.textPrimary),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 8),
          _UnderTextImage(assetPath: imageAsset, height: 110),
        ],
      ),
    );
  }
}

class _CalendarCard extends StatelessWidget {
  const _CalendarCard({required this.months, required this.note});

  final List<FlowerSeedMonth> months;
  final String note;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Zaadoogst kalender',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 118,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: months.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (context, index) {
                final month = months[index];
                final active =
                    month.status != FlowerSeedCalendarStatus.none;
                return SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      Text(
                        month.shortLabel,
                        style: t.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: active
                              ? const Color(0xFF5D4037)
                              : const Color(PlantDetailDesign.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: _UnderTextImage(
                          assetPath: flowerSeedCalendarImage(month.status),
                          height: 48,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        month.statusLabel,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.bodySmall?.copyWith(
                          fontSize: 10,
                          height: 1.2,
                          fontWeight: FontWeight.w600,
                          color: active
                              ? const Color(0xFF5D4037)
                              : const Color(PlantDetailDesign.textSecondary),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                size: 16,
                color: Color(PlantDetailDesign.textSecondary),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  note,
                  style: t.bodySmall?.copyWith(
                    height: 1.35,
                    color: const Color(PlantDetailDesign.textSecondary),
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

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({required this.mistakes});

  final List<FlowerSeedMistake> mistakes;

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
        ],
      ),
    );
  }
}

class _UnderTextImage extends StatelessWidget {
  const _UnderTextImage({
    required this.assetPath,
    this.height = 100,
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
