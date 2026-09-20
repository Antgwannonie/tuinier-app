import 'package:flutter/material.dart';

import '../data/crop_lifecycle_metadata.dart';
import '../data/harvest_tricks.dart';
import '../data/plant_lifecycle.dart';
import '../data/planting_timing_advice.dart';
import '../data/underground_crop.dart';
import '../data/visible_fruit_crop.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import 'plant_ai_insight_sections.dart';

/// Volledige oogst-info voor één plant (vanaf moestuin-kaart).
Future<void> showPlantHarvestInfoSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  bool selfCheckMode = false,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return SafeArea(
            child: _PlantHarvestInfoBody(
              scrollController: scrollController,
              vegetable: vegetable,
              profile: profile,
              selfCheckMode: selfCheckMode,
            ),
          );
        },
      );
    },
  );
}

class _PlantHarvestInfoBody extends StatelessWidget {
  const _PlantHarvestInfoBody({
    required this.scrollController,
    required this.vegetable,
    required this.profile,
    this.selfCheckMode = false,
  });

  final ScrollController scrollController;
  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final bool selfCheckMode;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final analysis = profile.lastAnalysis;
    final insight = analysis?.insight;
    final cal = calendarLabelsFor(vegetable.id);
    final underground = isUndergroundCrop(vegetable);
    final visibleFruit = isVisibleFruitCrop(vegetable);
    final selfCheck = selfCheckMode || underground;
    final continuous = !underground &&
        (insight?.moreHarvestExpectedThisSeason == true ||
            harvestPatternFor(vegetable) == CropHarvestPattern.continuous);
    final undergroundNote = analysis?.undergroundHarvestNote?.trim() ?? '';
    final fruitNote = analysis?.fruitHarvestNote?.trim() ?? '';
    final extendedGuide = extendedHarvestGuideFor(vegetable);

    return ListView(
      controller: scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          'Oogst-info · ${vegetable.nameNl}',
          style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 6),
        Text(
          underground
              ? 'Ondergronds gewas. De AI ziet alleen het loof. Controleer '
                  'zelf door één plant uit de grond te trekken.'
              : visibleFruit && fruitNote.isNotEmpty
                  ? 'De AI beoordeelt zichtbare vruchten op grootte en rijpheid '
                      't.o.v. wat je in de supermarkt ziet.'
                  : extendedGuide != null
                  ? extendedGuide.leadIn
                  : selfCheck
                      ? 'De AI kan op de foto niet zeker zien of oogst rijp is. '
                          'Controleer zelf of je kunt oogsten.'
                      : continuous
                          ? 'Doorlopende oogst. Oogst regelmatig en houd de '
                              'plant actief bij in je moestuin.'
                          : 'Eenmalige of seizoensgebonden oogst.',
          style: t.textTheme.bodySmall?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 18),
        if (extendedGuide != null) ...[
          _SectionCard(
            title: 'Handige oogsttrucjes',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Meerdere keren oogsten',
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  extendedGuide.repeatedHarvest,
                  style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 14),
                Text(
                  'Alles in één keer oogsten',
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  extendedGuide.oneShotHarvest,
                  style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (visibleFruit && fruitNote.isNotEmpty) ...[
          _SectionCard(
            title: 'Vruchtgrootte op je foto',
            child: Text(
              fruitNote,
              style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (selfCheck && !underground && !visibleFruit) ...[
          _SectionCard(
            title: 'Let op: controleer zelf',
            child: Text(
              'Op basis van je scan lijkt oogst mogelijk, maar de AI kan het '
              'niet zeker weten. Kijk zelf of je plant rijp is voordat je '
              'oogst of het seizoen afrondt.',
              style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (underground) ...[
          _SectionCard(
            title: 'Let op: AI kan dit niet zeker weten',
            child: Text(
              undergroundNote.isNotEmpty
                  ? undergroundNote
                  : 'De oogst zit onder de grond. De AI schat op basis van '
                      'bladgroei en tijd sinds zaaien of planten of oogst '
                      'mogelijk is, maar kan het niet zeker weten. Trek één '
                      'plant uit de grond om zelf te controleren of het rijp is.',
              style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Zo herken je of het rijp is',
            child: Text(
              undergroundRipenessGuideFor(vegetable),
              style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (analysis != null) ...[
          _SectionCard(
            title: 'Laatste scan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  analysis.phaseLabel,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (analysis.harvestWindowLabel.trim().isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    analysis.harvestWindowLabel,
                    style: t.textTheme.bodySmall?.copyWith(height: 1.35),
                  ),
                ],
                if (analysis.daysUntilHarvest != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    analysis.phase == PlantAiPhase.ripe
                        ? 'Klaar om te oogsten'
                        : 'Oogst over ±${analysis.daysUntilHarvest} dagen',
                    style: t.textTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          if (insight != null && analysis.hasInsight) ...[
            const SizedBox(height: 12),
            _SectionCard(
              title: 'AI-advies',
              child: PlantAiInsightSections(
                analysis: analysis,
                compact: true,
              ),
            ),
          ],
        ] else
          _SectionCard(
            title: 'Nog geen scan',
            child: Text(
              'Maak een foto van je plant, de AI vertelt dan of en wanneer '
              'je kunt oogsten.',
              style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        const SizedBox(height: 12),
        _SectionCard(
          title: 'Oogstkalender',
          child: Text(
            _harvestCalendarText(cal.harvest, vegetable),
            style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ),
        if (vegetable.harvestTips?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Oogsttips',
            child: Text(
              vegetable.harvestTips!,
              style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
        if (insight != null && insight.harvestAlternativeTips.isNotEmpty) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Tips van je laatste scan',
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (final tip in insight.harvestAlternativeTips)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text('• $tip', style: t.textTheme.bodyMedium),
                  ),
              ],
            ),
          ),
        ],
        if (profile.seasonBeyondCalendar) ...[
          const SizedBox(height: 12),
          _SectionCard(
            title: 'Seizoen voorbij',
            child: Text(
              seasonBeyondCalendarNotice(profile),
              style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
            ),
          ),
        ],
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: TuinierColors.primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            underground
                ? 'Nog niet rijp bij je controle? Houd de plant actief bij, '
                    'je hoeft Seizoen afronden nog niet in te drukken.\n\n'
                    'Alles geoogst? Rond het seizoen af op de moestuin-kaart. '
                    'Dan stoppen we de plant voor dit seizoen. Tot volgend '
                    'seizoen.'
                : selfCheck
                    ? 'Nog niet rijp? Houd de plant actief bij in je '
                        'moestuin.\n\n'
                        'Klaar met oogsten? Rond het seizoen af op de '
                        'moestuin-kaart. Dan stoppen we de plant voor dit '
                        'seizoen. Tot volgend seizoen.'
                    : continuous
                        ? 'Rond het seizoen af op de moestuin-kaart als de hele '
                            'plant klaar is met oogsten. Tot die tijd: houd de '
                            'plant actief bij in je moestuin.\n\n'
                            'Dan stoppen we de plant voor dit seizoen. Tot '
                            'volgend seizoen.'
                        : extendedGuide != null
                            ? 'Blijf oogsten zolang de truc werkt, of rond af '
                                'na één grote oogst. Druk op Seizoen afronden '
                                'als je klaar bent.\n\n'
                                'Dan stoppen we de plant voor dit seizoen. Tot '
                                'volgend seizoen.'
                            : 'Dit gewas heeft meestal één oogst per seizoen. '
                                'Rond het seizoen af zodra alles geoogst is.\n\n'
                                'Dan stoppen we de plant voor dit seizoen. Tot '
                                'volgend seizoen.',
            style: t.textTheme.bodySmall?.copyWith(
              color: TuinierColors.textPrimary,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}

String _harvestCalendarText(String? calendarHarvest, Vegetable vegetable) {
  final fromCalendar = calendarHarvest?.trim();
  if (fromCalendar != null && fromCalendar.isNotEmpty) return fromCalendar;
  final fromVeg = vegetable.harvest?.trim();
  if (fromVeg != null && fromVeg.isNotEmpty) return fromVeg;
  return 'Geen kalenderinfo beschikbaar.';
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}
