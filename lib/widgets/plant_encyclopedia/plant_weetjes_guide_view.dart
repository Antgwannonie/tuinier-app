import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_guide_detail.dart';
import '../../data/plant_section_details.dart';
import '../../data/plant_weetjes_guide.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'weetjes_illustrations.dart';

const _weetjesGreen = Color(PlantDetailDesign.primaryGreen);

class PlantWeetjesGuideView extends StatelessWidget {
  const PlantWeetjesGuideView({
    super.key,
    required this.guide,
    this.vegetable,
  });

  final PlantWeetjesGuide guide;
  final Vegetable? vegetable;

  static const _pairBreakpoint = 520.0;

  List<PlantGuideDetailBlock> _detailsFor(
    String title, {
    String? fullBody,
    String? summary,
  }) {
    if (vegetable == null) return const [];
    final generated =
        sectionDetailsFor(tab: 'weetjes', title: title, vegetable: vegetable!);
    final extra = fullBody?.trim() ?? '';
    if (extra.isEmpty) return generated;
    final sum = summary?.trim() ?? '';
    // Geen dubbele Uitleg als die al als korte kaarttekst (of identiek) staat.
    if (sum.isNotEmpty && extra.toLowerCase() == sum.toLowerCase()) {
      return generated;
    }
    return [
      PlantGuideDetailBlock(heading: 'Uitleg', body: extra),
      ...generated,
    ];
  }

  Widget _tappable(
    BuildContext context,
    String title,
    String summary, {
    String? fullBody,
    required Widget child,
  }) {
    final details = _detailsFor(title, fullBody: fullBody, summary: summary);
    if (details.isEmpty) return child;
    return wrapGuideDetailCard(
      context: context,
      title: title,
      summary: summary,
      details: details,
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final stackPairs = constraints.maxWidth < _pairBreakpoint;
        final originSum =
            guide.cardSummary('Oorsprong', fallback: guide.origin);
        final historySum =
            guide.cardSummary('Historie', fallback: guide.history);
        final nameSum =
            guide.cardSummary('Naam', fallback: guide.nameMeaning);
        final familySum =
            guide.cardSummary('Familie', fallback: guide.familyMembers);
        final specialSum = guide.cardSummary(
          'Bijzonderheden',
          fallback: guide.specialFeatures.isEmpty
              ? 'Opvallende kenmerken van deze plant.'
              : guide.specialFeatures.take(2).join(' '),
        );
        final edibleSum = guide.cardSummary(
          'Eetbare delen',
          fallback: guide.ediblePartsSummary,
        );
        final healthSum = guide.cardSummary(
          'Gezondheidsvoordelen',
          fallback: 'Voordelen van verse oogst uit eigen tuin.',
        );
        final kitchenSum = guide.cardSummary(
          'Gebruik in de keuken',
          fallback: 'Veelgebruikte bereidingen met verse oogst.',
        );
        final varietiesSum = guide.cardSummary(
          'Populaire rassen',
          fallback: guide.popularVarieties.isEmpty
              ? 'Veelgeteelde variëteiten voor de Nederlandse moestuin.'
              : guide.popularVarieties.take(3).join(' · '),
        );
        final surprisingSum = guide.cardSummary(
          'Verrassende toepassingen',
          fallback: 'Meer dan alleen eten: decoratie, thee of tuinhelpers.',
        );
        final funSum =
            guide.cardSummary('Wist-je-dat', fallback: guide.funFact);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlantDetailCard(
              child: _tappable(
                context,
                'Oorsprong',
                originSum,
                fullBody: guide.origin,
                child: _WeetjesCardContent(
                  title: 'Oorsprong',
                  body: originSum,
                  hero: PlantWeetjesIllustration.origin,
                ),
              ),
            ),
            const SizedBox(height: 12),
            PlantDetailCard(
              child: _tappable(
                context,
                'Historie',
                historySum,
                fullBody: guide.history,
                child: _WeetjesCardContent(
                  title: 'Historie',
                  body: historySum,
                  hero: PlantWeetjesIllustration.history,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _WeetjesPairRow(
              stack: stackPairs,
              left: PlantDetailCard(
                child: _tappable(
                  context,
                  'Naam',
                  nameSum,
                  fullBody: guide.nameMeaning,
                  child: _WeetjesCardContent(
                    title: 'Betekenis van de naam',
                    body: nameSum,
                  ),
                ),
              ),
              right: PlantDetailCard(
                child: _tappable(
                  context,
                  'Familie',
                  familySum,
                  fullBody: guide.familyMembers,
                  child: _WeetjesCardContent(
                    title: 'Familieleden',
                    body: familySum,
                    hero: PlantWeetjesIllustration.family,
                  ),
                ),
              ),
            ),
            if (guide.vruchtFamilieMembers.isNotEmpty) ...[
              const SizedBox(height: 12),
              PlantDetailCard(
                child: _tappable(
                  context,
                  'Plantenfamilie',
                  guide.cardSummary(
                    'Plantenfamilie',
                    fallback: guide.vruchtFamilieLabel != null
                        ? 'Verwant aan andere soorten in de ${guide.vruchtFamilieLabel}.'
                        : 'Verwant aan andere soorten in dezelfde plantenfamilie.',
                  ),
                  fullBody: guide.vruchtFamilieLabel != null
                      ? 'Verwant aan andere soorten in de ${guide.vruchtFamilieLabel}: ${guide.vruchtFamilieMembers.join(', ')}.'
                      : 'Verwant aan andere soorten in dezelfde plantenfamilie: ${guide.vruchtFamilieMembers.join(', ')}.',
                  child: _WeetjesCardContent(
                    title: 'Plantenfamilie',
                    body: guide.cardSummary(
                      'Plantenfamilie',
                      fallback: guide.vruchtFamilieLabel != null
                          ? 'Verwant aan andere soorten in de ${guide.vruchtFamilieLabel}.'
                          : 'Verwant aan andere soorten in dezelfde plantenfamilie.',
                    ),
                    chips: guide.vruchtFamilieMembers,
                    hero: PlantWeetjesIllustration.family,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            PlantDetailCard(
              child: _tappable(
                context,
                'Bijzonderheden',
                specialSum,
                fullBody: guide.specialFeatures.join('\n'),
                child: _WeetjesCardContent(
                  title: 'Bijzonderheden',
                  body: specialSum,
                ),
              ),
            ),
            const SizedBox(height: 12),
            PlantDetailCard(
              child: _tappable(
                context,
                'Eetbare delen',
                edibleSum,
                fullBody: guide.ediblePartsSummary,
                child: _WeetjesCardContent(
                  title: 'Eetbare delen',
                  body: edibleSum,
                  hero: PlantWeetjesIllustration.edibleParts,
                  chips: guide.ediblePartLabels,
                ),
              ),
            ),
            const SizedBox(height: 12),
            _WeetjesPairRow(
              stack: stackPairs,
              left: PlantDetailCard(
                child: _tappable(
                  context,
                  'Gezondheidsvoordelen',
                  healthSum,
                  fullBody: guide.healthBenefits.map((e) => e.label).join(', '),
                  child: _WeetjesIconGridContent(
                    title: 'Gezondheidsvoordelen',
                    intro: healthSum,
                    items: guide.healthBenefits,
                  ),
                ),
              ),
              right: PlantDetailCard(
                child: _tappable(
                  context,
                  'Gebruik in de keuken',
                  kitchenSum,
                  fullBody: guide.kitchenUses.map((e) => e.label).join(', '),
                  child: _WeetjesIconGridContent(
                    title: 'Gebruik in de keuken',
                    intro: kitchenSum,
                    items: guide.kitchenUses,
                  ),
                ),
              ),
            ),
            if (guide.popularVarieties.isNotEmpty) ...[
              const SizedBox(height: 12),
              PlantDetailCard(
                child: _tappable(
                  context,
                  'Populaire rassen',
                  varietiesSum,
                  fullBody: guide.popularVarieties.map((e) => e.label).join(', '),
                  child: _WeetjesScrollContent(
                    title: 'Populaire rassen',
                    intro: varietiesSum,
                    items: guide.popularVarieties,
                  ),
                ),
              ),
            ],
            if (guide.wildlife.isNotEmpty) ...[
              const SizedBox(height: 12),
              PlantDetailCard(
                child: _tappable(
                  context,
                  'Nuttige dieren',
                  guide.cardSummary(
                    'Nuttige dieren',
                    fallback: 'Bijen, hommels en lieveheersbeestjes helpen in de moestuin.',
                  ),
                  fullBody: guide.wildlife
                      .map((e) =>
                          e.detail != null && e.detail!.trim().isNotEmpty
                              ? '${e.label}: ${e.detail}'
                              : e.label)
                      .join('\n'),
                  child: _WeetjesIconGridContent(
                    title: 'Nuttige dieren',
                    intro: guide.cardSummary(
                      'Nuttige dieren',
                      fallback:
                          'Bijen, hommels en lieveheersbeestjes helpen in de moestuin.',
                    ),
                    items: guide.wildlife,
                  ),
                ),
              ),
            ],
            if (guide.worldProduction.isNotEmpty) ...[
              const SizedBox(height: 12),
              PlantDetailCard(
                child: _tappable(
                  context,
                  'Wereldproductie',
                  guide.cardSummary(
                    'Wereldproductie',
                    fallback: 'Wereldwijd geteeld; in NL vooral moestuin en kas.',
                  ),
                  fullBody: guide.worldProduction
                      .map((e) => e.label)
                      .join(', '),
                  child: _WeetjesIconGridContent(
                    title: 'Wereldproductie',
                    intro: guide.cardSummary(
                      'Wereldproductie',
                      fallback:
                          'Wereldwijd geteeld; in NL vooral moestuin en kas.',
                    ),
                    items: guide.worldProduction,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 12),
            PlantDetailCard(
              child: _tappable(
                context,
                'Verrassende toepassingen',
                surprisingSum,
                fullBody:
                    guide.surprisingUses.map((e) => e.label).join(', '),
                child: _WeetjesScrollContent(
                  title: 'Verrassende toepassingen',
                  intro: surprisingSum,
                  items: guide.surprisingUses,
                ),
              ),
            ),
            const SizedBox(height: 12),
            PlantDetailCard(
              child: _tappable(
                context,
                'Wist-je-dat',
                funSum,
                fullBody: guide.funFact,
                child: _WeetjesCardContent(
                  title: 'Leuk wist-je-datje',
                  body: funSum,
                  hero: PlantWeetjesIllustration.funFact,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _WeetjesPairRow extends StatelessWidget {
  const _WeetjesPairRow({
    required this.stack,
    required this.left,
    required this.right,
  });

  final bool stack;
  final Widget left;
  final Widget right;

  @override
  Widget build(BuildContext context) {
    if (stack) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          left,
          const SizedBox(height: 12),
          right,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: left),
          const SizedBox(width: 10),
          Expanded(child: right),
        ],
      ),
    );
  }
}

class _WeetjesSectionTitle extends StatelessWidget {
  const _WeetjesSectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: _weetjesGreen,
          ),
    );
  }
}

class _WeetjesBodyText extends StatelessWidget {
  const _WeetjesBodyText({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            height: 1.45,
            fontSize: 13,
            color: const Color(PlantDetailDesign.textPrimary),
          ),
    );
  }
}

class _WeetjesCardContent extends StatelessWidget {
  const _WeetjesCardContent({
    required this.title,
    required this.body,
    this.hero,
    this.chips,
  });

  final String title;
  final String body;
  final PlantWeetjesIllustration? hero;
  final List<String>? chips;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeetjesSectionTitle(title: title),
        const SizedBox(height: 8),
        _WeetjesBodyText(text: body),
        if (hero != null) ...[
          const SizedBox(height: 14),
          WeetjesHeroIllustration(kind: hero!),
        ],
        if (chips != null && chips!.isNotEmpty) ...[
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: chips!
                .map(
                  (c) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0FDF4),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _weetjesGreen.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Text(
                      c,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: _weetjesGreen,
                          ),
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}

class _WeetjesIconGridContent extends StatelessWidget {
  const _WeetjesIconGridContent({
    required this.title,
    required this.intro,
    required this.items,
  });

  final String title;
  final String intro;
  final List<WeetjesIconItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeetjesSectionTitle(title: title),
        const SizedBox(height: 6),
        _WeetjesBodyText(text: intro),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 12,
          alignment: WrapAlignment.center,
          children: [
            for (final item in items)
              SizedBox(
                width: 72,
                child: Column(
                  children: [
                    WeetjesIconIllustration(kind: item.illustration),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                            height: 1.2,
                          ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _WeetjesScrollContent extends StatelessWidget {
  const _WeetjesScrollContent({
    required this.title,
    required this.intro,
    required this.items,
  });

  final String title;
  final String intro;
  final List<WeetjesIconItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _WeetjesSectionTitle(title: title),
        const SizedBox(height: 6),
        _WeetjesBodyText(text: intro),
        const SizedBox(height: 12),
        SizedBox(
          height: 100,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 14),
            itemBuilder: (context, index) {
              final item = items[index];
              return SizedBox(
                width: 76,
                child: Column(
                  children: [
                    WeetjesIconIllustration(
                      kind: item.illustration,
                      size: 68,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.label,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style:
                          Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                              ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

