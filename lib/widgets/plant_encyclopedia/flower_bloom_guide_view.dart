import 'package:flutter/material.dart';

import '../../data/flower_bloom_guide_data.dart';
import '../../data/plant_bloom_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

/// Flower-only Bloei-layout: tekst boven, afbeelding eronder (zoals Uitplanten).
/// Geen plant-/vrucht-koppen zoals “tijd tot vruchtvorming”.
class FlowerBloomGuideView extends StatelessWidget {
  const FlowerBloomGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantBloomGuide guide;

  static const _wideBreakpoint = 520.0;
  static const _imageHeight = 100.0;

  /// Deze secties krijgen een eigen kaart over de volle breedte,
  /// onder elkaar, zodat er meer ruimte is voor tekst.
  static const _fullWidthLabels = {
    'Herbloei',
    'Uitgebloeide bloemen verwijderen',
    'Bloei stimuleren',
    'Zelfbestuiver',
    'Bestuivers',
  };

  @override
  Widget build(BuildContext context) {
    final g = flowerBloomGuideForVegetable(
      vegetable: vegetable,
      layout: layout,
    );
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;
    final gridFacts = [
      for (final fact in g.facts)
        if (!_fullWidthLabels.contains(fact.label)) fact,
    ];
    final fullWidthFacts = [
      for (final fact in g.facts)
        if (_fullWidthLabels.contains(fact.label)) fact,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _FactsGrid(facts: gridFacts, wide: wide),
        for (final fact in fullWidthFacts) ...[
          const SizedBox(height: 12),
          _FullWidthFactCard(fact: fact),
        ],
        const SizedBox(height: 12),
        _DidYouKnowBanner(
          text: g.didYouKnow,
          imageAsset: g.didYouKnowImage,
        ),
        const SizedBox(height: 12),
        _BloomCalendarCard(months: g.calendar),
        const SizedBox(height: 12),
        _ExtraTipsCard(tips: g.extraTips, wide: wide),
        const SizedBox(height: 12),
        _MistakesCard(mistakes: g.mistakes),
      ],
    );
  }
}

class _FactsGrid extends StatelessWidget {
  const _FactsGrid({required this.facts, required this.wide});

  final List<FlowerBloomFact> facts;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: wide ? 5 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.zero,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: wide ? 0.68 : 0.72,
      children: [for (final fact in facts) _FactCard(fact: fact)],
    );
  }
}

class _FactCard extends StatelessWidget {
  const _FactCard({required this.fact});

  final FlowerBloomFact fact;

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
                color: const Color(0xFF6A1B9A),
                height: 1.2,
              ),
            ),
            if (fact.scentDots != null) ...[
              const SizedBox(height: 6),
              _ScentDots(filled: fact.scentDots!),
            ],
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
                height: FlowerBloomGuideView._imageHeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kaart over de volle breedte: tekst boven, afbeelding eronder.
class _FullWidthFactCard extends StatelessWidget {
  const _FullWidthFactCard({required this.fact});

  final FlowerBloomFact fact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

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
              color: const Color(0xFF6A1B9A),
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
          _UnderTextImage(
            assetPath: fact.imageAsset,
            height: 120,
          ),
        ],
        ),
      ),
    );
  }
}

class _ScentDots extends StatelessWidget {
  const _ScentDots({required this.filled});

  final int filled;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 5; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: i < filled
                  ? const Color(0xFF8E24AA)
                  : const Color(0xFFE1BEE7),
            ),
          ),
        ],
      ],
    );
  }
}

class _DidYouKnowBanner extends StatelessWidget {
  const _DidYouKnowBanner({
    required this.text,
    required this.imageAsset,
  });

  final String text;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF3E5F5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE1BEE7)),
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
                  color: Color(0xFFE1BEE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lightbulb_outline_rounded,
                  size: 18,
                  color: Color(0xFF6A1B9A),
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
          _UnderTextImage(assetPath: imageAsset, height: 120),
        ],
      ),
    );
  }
}

class _BloomCalendarCard extends StatelessWidget {
  const _BloomCalendarCard({required this.months});

  final List<FlowerBloomMonth> months;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bloeikalender',
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
                final blooming =
                    month.status != FlowerBloomCalendarStatus.none;
                return SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      Text(
                        month.shortLabel,
                        style: t.labelMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: blooming
                              ? const Color(0xFF6A1B9A)
                              : const Color(PlantDetailDesign.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Expanded(
                        child: _UnderTextImage(
                          assetPath: flowerBloomCalendarImage(month.status),
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
                          color: blooming
                              ? const Color(0xFF6A1B9A)
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
                  'Exacte timing hangt af van weer, standplaats en snoei.',
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

class _ExtraTipsCard extends StatelessWidget {
  const _ExtraTipsCard({required this.tips, required this.wide});

  final List<FlowerBloomExtraTip> tips;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Extra tips voor een rijke bloei',
            style: t.titleSmall?.copyWith(
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
                  for (var i = 0; i < tips.length; i++) ...[
                    if (i > 0) const SizedBox(width: 8),
                    Expanded(child: _ExtraTipTile(tip: tips[i])),
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
              children: [for (final tip in tips) _ExtraTipTile(tip: tip)],
            ),
        ],
      ),
    );
  }
}

class _ExtraTipTile extends StatelessWidget {
  const _ExtraTipTile({required this.tip});

  final FlowerBloomExtraTip tip;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return wrapGuideDetailCard(
      context: context,
      title: tip.title,
      summary: tip.body,
      details: tip.details,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(PlantDetailDesign.border)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tip.title,
              style: t.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              tip.body,
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
              child: _UnderTextImage(assetPath: tip.imageAsset, height: 72),
            ),
          ],
        ),
      ),
    );
  }
}

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({required this.mistakes});

  final List<FlowerBloomMistake> mistakes;

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
