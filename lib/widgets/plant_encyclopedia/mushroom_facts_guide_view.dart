import 'package:flutter/material.dart';

import '../../data/mushroom_facts_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'facts_illustrations.dart';
import 'mushroom_guide_card.dart';

class MushroomFactsGuideView extends StatelessWidget {
  const MushroomFactsGuideView({super.key, required this.guide});

  final MushroomFactsGuide guide;

  static const _twoColBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 32;
    final twoCol = width >= _twoColBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapMushroomGuideCard(
          context: context,
          title: 'Ontdek de fascinerende wereld van paddenstoelen',
          summary: guide.cardSummary(
            'Ontdek de fascinerende wereld van paddenstoelen',
          ),
          details: guide.cardDetail(
            'Ontdek de fascinerende wereld van paddenstoelen',
          ),
          child: _HeroBanner(
            summary: guide.cardSummary(
              'Ontdek de fascinerende wereld van paddenstoelen',
            ),
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Top 6 weetjes',
          summary: guide.cardSummary('Top 6 weetjes'),
          details: guide.cardDetail('Top 6 weetjes'),
          child: _TopFactsSection(
            facts: guide.topFacts,
            summary: guide.cardSummary('Top 6 weetjes'),
            width: width,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Wist je dat?',
          summary: guide.cardSummary('Wist je dat?'),
          details: guide.cardDetail('Wist je dat?'),
          child: _DidYouKnowSection(
            items: guide.didYouKnow,
            summary: guide.cardSummary('Wist je dat?'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Leuke feitjes over kweek',
          summary: guide.cardSummary('Leuke feitjes over kweek'),
          details: guide.cardDetail('Leuke feitjes over kweek'),
          child: _CultivationSection(
            summary: guide.cardSummary('Leuke feitjes over kweek'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Soorten in de spotlight',
          summary: guide.cardSummary('Soorten in de spotlight'),
          details: guide.cardDetail('Soorten in de spotlight'),
          child: _SpotlightSection(
            species: guide.spotlightSpecies,
            summary: guide.cardSummary('Soorten in de spotlight'),
          ),
        ),
        const SizedBox(height: 12),
        _FooterCta(text: guide.footerText),
      ],
    );
  }
}

class _GreenSectionTitle extends StatelessWidget {
  const _GreenSectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
    );
  }
}

class _HeroBanner extends StatelessWidget {
  const _HeroBanner({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return ClipRRect(
      borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
      child: Stack(
        children: [
          const FactsIllustration(
            assetPath: FactsAssets.hero,
            aspectRatio: 16 / 9,
            borderRadius: 0,
          ),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.15),
                    Colors.black.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 14,
            right: 14,
            bottom: 14,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Ontdek de fascinerende wereld van paddenstoelen',
                  style: t.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.25,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  summary,
                  style: t.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TopFactsSection extends StatelessWidget {
  const _TopFactsSection({
    required this.facts,
    required this.summary,
    required this.width,
  });

  final List<FactsTopItem> facts;
  final String summary;
  final double width;

  int get _columns {
    if (width >= 680) return 3;
    if (width >= 400) return 2;
    return 1;
  }

  @override
  Widget build(BuildContext context) {
    final cols = _columns;
    final rows = <Widget>[];

    for (var i = 0; i < facts.length; i += cols) {
      final chunk = facts.skip(i).take(cols).toList();
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var j = 0; j < cols; j++) ...[
              if (j > 0) const SizedBox(width: 8),
              Expanded(
                child: j < chunk.length
                    ? _TopFactCard(fact: chunk[j])
                    : const SizedBox.shrink(),
              ),
            ],
          ],
        ),
      );
      if (i + cols < facts.length) {
        rows.add(const SizedBox(height: 8));
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Top 6 weetjes'),
        const SizedBox(height: 8),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 10),
        ...rows,
      ],
    );
  }
}

class _TopFactCard extends StatelessWidget {
  const _TopFactCard({required this.fact});

  final FactsTopItem fact;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(PlantDetailDesign.card),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 26,
                height: 26,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: Color(PlantDetailDesign.primaryGreen),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${fact.number}',
                  style: t.labelMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fact.title,
                  style: t.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          FactsIllustration(
            assetPath: fact.assetPath,
            aspectRatio: 16 / 10,
            compact: true,
          ),
        ],
      ),
    );
  }
}

class _DidYouKnowSection extends StatelessWidget {
  const _DidYouKnowSection({
    required this.items,
    required this.summary,
    required this.twoCol,
  });

  final List<FactsDidYouKnowItem> items;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    Widget itemTile(FactsDidYouKnowItem item) {
      final t = Theme.of(context).textTheme;
      return Column(
        children: [
          Icon(
            item.icon,
            size: 32,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
          const SizedBox(height: 8),
          Text(
            item.stat,
            textAlign: TextAlign.center,
            style: t.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Wist je dat?'),
        const SizedBox(height: 8),
        Text(summary, style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: itemTile(items[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < items.length; i++) ...[
                  if (i > 0) const SizedBox(height: 14),
                  itemTile(items[i]),
                ],
              ],
            ),
        ],
      );
  }
}

class _CultivationSection extends StatelessWidget {
  const _CultivationSection({required this.summary, required this.twoCol});

  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final bulletList = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Leuke feitjes over kweek'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const image = FactsIllustration(
      assetPath: FactsAssets.cultivation,
      aspectRatio: 4 / 3,
      compact: true,
    );

    return twoCol
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(width: 140, child: image),
                const SizedBox(width: 14),
                Expanded(child: bulletList),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                bulletList,
                const SizedBox(height: 12),
                image,
              ],
            );
  }
}

class _SpotlightSection extends StatelessWidget {
  const _SpotlightSection({required this.species, required this.summary});

  final List<FactsSpotlightSpecies> species;
  final String summary;

  @override
  Widget build(BuildContext context) {
    if (species.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Soorten in de spotlight'),
        const SizedBox(height: 8),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 168,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: species.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (context, index) {
              final s = species[index];
              return _SpotlightCard(species: s);
            },
          ),
        ),
      ],
    );
  }
}

class _SpotlightCard extends StatelessWidget {
  const _SpotlightCard({required this.species});

  final FactsSpotlightSpecies species;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final highlight = species.isCurrent;

    return Container(
      width: 120,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: highlight ? const Color(0xFFE8F5E9) : const Color(PlantDetailDesign.card),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(
          color: highlight
              ? const Color(PlantDetailDesign.primaryGreen)
              : const Color(PlantDetailDesign.border),
          width: highlight ? 2 : 1,
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.asset(
                species.assetPath,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.image_not_supported_outlined,
                  color: Color(PlantDetailDesign.textSecondary),
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            species.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlight
                  ? const Color(PlantDetailDesign.primaryGreen)
                  : null,
            ),
          ),
          if (highlight) ...[
            const SizedBox(height: 2),
            Text(
              'Jij kijkt',
              style: t.labelSmall?.copyWith(
                fontSize: 9,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _FooterCta extends StatelessWidget {
  const _FooterCta({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFE3F2FD),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFBBDEFB)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.lightbulb_outline_rounded,
                size: 24,
                color: Color(0xFF1565C0),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Blijf nieuwsgierig!',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1565C0),
                          ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            height: 1.4,
                            color: const Color(0xFF37474F),
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        Positioned(
          right: 8,
          bottom: 4,
          child: Icon(
            Icons.eco_outlined,
            size: 48,
            color: const Color(0xFF1565C0).withValues(alpha: 0.12),
          ),
        ),
      ],
    );
  }
}
