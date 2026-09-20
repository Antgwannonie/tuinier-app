import 'package:flutter/material.dart';

import '../../data/mushroom_harvest_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'mushroom_guide_card.dart';
import 'mushroom_harvest_illustrations.dart';

class MushroomHarvestGuideView extends StatelessWidget {
  const MushroomHarvestGuideView({super.key, required this.guide});

  final MushroomHarvestGuide guide;

  static const _twoColBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 32;
    final twoCol = width >= _twoColBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Wanneer en hoe oogst je?',
          child: (summary) => _HeroCard(summary: summary),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Wanneer is het tijd om te oogsten?',
          child: (summary) => _TimingCard(
            cards: guide.timingCards,
            summary: summary,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Hoe oogst je?',
          child: (summary) => _MethodCard(
            steps: guide.methodSteps,
            summary: summary,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Na het oogsten',
          child: (summary) => _AfterHarvestCard(
            items: guide.afterHarvestItems,
            summary: summary,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        if (twoCol)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Tips voor een betere opbrengst',
                    child: (summary) => _TipsCard(summary: summary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Wat kun je verwachten?',
                    child: (summary) => _ExpectationsCard(summary: summary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Tips voor een betere opbrengst',
            child: (summary) => _TipsCard(summary: summary),
          ),
          const SizedBox(height: 12),
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Wat kun je verwachten?',
            child: (summary) => _ExpectationsCard(summary: summary),
          ),
        ],
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Veelgemaakte fouten',
          child: (summary) => _MistakesCard(summary: summary, twoCol: twoCol),
        ),
        const SizedBox(height: 12),
        _FooterTipCard(text: guide.footerTip),
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

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stack = MediaQuery.sizeOf(context).width < 400;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Wanneer en hoe oogst je?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hero = MushroomHarvestIllustration(
      assetPath: MushroomHarvestAssets.hero,
      aspectRatio: 16 / 10,
    );

    return stack
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [textBlock, const SizedBox(height: 12), hero],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: textBlock),
                const SizedBox(width: 12),
                const SizedBox(width: 130, child: hero),
              ],
            );
  }
}

class _TimingCard extends StatelessWidget {
  const _TimingCard({
    required this.cards,
    required this.summary,
    required this.twoCol,
  });

  final List<HarvestTimingCard> cards;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget timingTile(HarvestTimingCard card) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          MushroomHarvestIllustration(
            assetPath: card.assetPath,
            aspectRatio: 16 / 10,
            compact: true,
          ),
          const SizedBox(height: 8),
          Text(
            card.title,
            style: t.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      );
    }

    Widget row(int start, int end) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = start; i < end; i++) ...[
            if (i > start) const SizedBox(width: 10),
            Expanded(child: timingTile(cards[i])),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Wanneer is het tijd om te oogsten?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 10),
        if (twoCol) ...[
          row(0, 2),
          const SizedBox(height: 10),
          row(2, 4),
        ] else ...[
          for (var i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 10),
            timingTile(cards[i]),
          ],
        ],
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.steps,
    required this.summary,
    required this.twoCol,
  });

  final List<HarvestMethodStep> steps;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget stepTile(HarvestMethodStep step) {
      return Column(
        children: [
          MushroomHarvestIllustration(
            assetPath: step.assetPath,
            aspectRatio: 1,
            compact: true,
          ),
          const SizedBox(height: 6),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 11,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Hoe oogst je?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 14),
          if (twoCol)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 28, left: 2, right: 2),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: const Color(PlantDetailDesign.primaryGreen)
                            .withValues(alpha: 0.6),
                      ),
                    ),
                  Expanded(child: stepTile(steps[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  stepTile(steps[i]),
                ],
              ],
            ),
        ],
      );
  }
}

class _AfterHarvestCard extends StatelessWidget {
  const _AfterHarvestCard({
    required this.items,
    required this.summary,
    required this.twoCol,
  });

  final List<HarvestAfterItem> items;
  final String summary;
  final bool twoCol;

  static IconData _iconFor(String icon) {
    return switch (icon) {
      'water' => Icons.water_drop_outlined,
      'fan' => Icons.air_rounded,
      'thermometer' => Icons.thermostat_rounded,
      'refresh' => Icons.autorenew_rounded,
      _ => Icons.check_circle_outline,
    };
  }

  static Color _iconColorFor(String icon) {
    return switch (icon) {
      'water' => const Color(0xFF3B82F6),
      'fan' => const Color(0xFF6B7280),
      'thermometer' => const Color(0xFFDC2626),
      'refresh' => const Color(PlantDetailDesign.primaryGreen),
      _ => const Color(PlantDetailDesign.primaryGreen),
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget itemTile(HarvestAfterItem item) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(PlantDetailDesign.border)),
        ),
        child: Column(
          children: [
            Icon(
              _iconFor(item.icon),
              size: 28,
              color: _iconColorFor(item.icon),
            ),
            const SizedBox(height: 6),
            Text(
              item.title,
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    Widget row(int start, int end) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (var i = start; i < end; i++) ...[
            if (i > start) const SizedBox(width: 8),
            Expanded(child: itemTile(items[i])),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Na het oogsten'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol) ...[
            row(0, 2),
            const SizedBox(height: 8),
            row(2, 4),
          ] else ...[
            row(0, 2),
            const SizedBox(height: 8),
            row(2, 4),
          ],
        ],
      );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Tips voor een betere opbrengst'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );
  }
}

class _ExpectationsCard extends StatelessWidget {
  const _ExpectationsCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(PlantDetailDesign.cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E7),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: const Color(0xFFFFE082)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GreenSectionTitle('Wat kun je verwachten?'),
          const SizedBox(height: 8),
          Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
          const SizedBox(height: 12),
          const Center(
            child: Icon(
              Icons.shopping_basket_outlined,
              size: 40,
              color: Color(0xFFF59E0B),
            ),
          ),
        ],
      ),
    );
  }
}

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({required this.summary, required this.twoCol});

  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PlantDetailDesign.cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: const Color(0xFFFFCDD2)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 12,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                size: 20,
                color: Color(0xFFB71C1C),
              ),
              const SizedBox(width: 8),
              Text(
                'Veelgemaakte fouten',
                style: t.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFB71C1C),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(summary, style: t.bodySmall?.copyWith(height: 1.35)),
        ],
      ),
    );
  }
}

class _FooterTipCard extends StatelessWidget {
  const _FooterTipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
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
          const Icon(
            Icons.lightbulb_outline,
            size: 22,
            color: Color(PlantDetailDesign.primaryGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tip: $text',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: const Color(PlantDetailDesign.textPrimary),
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
