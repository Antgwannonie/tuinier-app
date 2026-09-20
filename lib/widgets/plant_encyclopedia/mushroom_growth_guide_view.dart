import 'package:flutter/material.dart';

import '../../data/mushroom_growth_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'mushroom_growth_illustrations.dart';
import 'mushroom_guide_card.dart';

class MushroomGrowthGuideView extends StatelessWidget {
  const MushroomGrowthGuideView({super.key, required this.guide});

  final MushroomGrowthGuide guide;

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
          title: 'Wat gebeurt er tijdens de groei?',
          child: (summary) => _WhatIsCard(summary: summary),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'De groeifase in het kort',
          child: (summary) => _TimelineCard(
            stages: guide.timelineStages,
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
                    title: 'Ideale omstandigheden tijdens groei',
                    child: (summary) =>
                        _IdealConditionsCard(guide: guide, summary: summary),
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
            title: 'Ideale omstandigheden tijdens groei',
            child: (summary) =>
                _IdealConditionsCard(guide: guide, summary: summary),
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
          title: 'Fasen van de groei',
          child: (summary) => _GrowthPhasesCard(
            phases: guide.growthPhases,
            summary: summary,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Tips voor een gezonde groei',
          child: (summary) => _TipsCard(summary: summary, twoCol: twoCol),
        ),
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

class _WhatIsCard extends StatelessWidget {
  const _WhatIsCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stack = MediaQuery.sizeOf(context).width < 400;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Wat gebeurt er tijdens de groei?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hero = MushroomGrowthIllustration(
      assetPath: MushroomGrowthAssets.hero,
      aspectRatio: 4 / 3,
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

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.stages,
    required this.summary,
    required this.twoCol,
  });

  final List<GrowthTimelineStage> stages;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget stageTile(GrowthTimelineStage stage) {
      return Column(
        children: [
          Stack(
            alignment: Alignment.topRight,
            children: [
              MushroomGrowthIllustration(
                assetPath: stage.assetPath,
                aspectRatio: 1,
                compact: true,
              ),
              const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(
                  Icons.check_circle_rounded,
                  size: 16,
                  color: Color(PlantDetailDesign.primaryGreen),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            stage.label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
          Text(
            stage.duration,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontSize: 8,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('De groeifase in het kort'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              children: [
                for (var i = 0; i < stages.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Color(PlantDetailDesign.textSecondary),
                      ),
                    ),
                  Expanded(child: stageTile(stages[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < stages.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  stageTile(stages[i]),
                ],
              ],
            ),
        ],
      );
  }
}

class _IdealConditionsCard extends StatelessWidget {
  const _IdealConditionsCard({required this.guide, required this.summary});

  final MushroomGrowthGuide guide;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget conditionRow(IconData icon, Color color, String label, String value) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                style: t.labelSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            Text(
              value.split('.').first,
              style: t.labelSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Ideale omstandigheden tijdens groei'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 10),
          conditionRow(
            Icons.thermostat_rounded,
            const Color(PlantDetailDesign.primaryGreen),
            'Temperatuur',
            '${guide.temperature}. ${guide.temperatureNote}',
          ),
          conditionRow(
            Icons.water_drop_rounded,
            const Color(0xFF3B82F6),
            'Luchtvochtigheid',
            '${guide.humidity}. ${guide.humidityNote}',
          ),
          conditionRow(
            Icons.air_rounded,
            const Color(0xFF6B7280),
            'Ventilatie (${guide.ventilationLabel})',
            guide.ventilationLabel,
          ),
          conditionRow(
            Icons.wb_sunny_outlined,
            const Color(0xFFF59E0B),
            'Licht (${guide.lightLabel})',
            guide.lightLabel,
          ),
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Wat kun je verwachten?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );
  }
}

class _GrowthPhasesCard extends StatelessWidget {
  const _GrowthPhasesCard({
    required this.phases,
    required this.summary,
    required this.twoCol,
  });

  final List<GrowthPhaseCard> phases;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget phaseTile(GrowthPhaseCard phase) {
      return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(PlantDetailDesign.border)),
        ),
        child: Column(
          children: [
            MushroomGrowthIllustration(
              assetPath: phase.assetPath,
              aspectRatio: 1,
              compact: true,
            ),
            const SizedBox(height: 6),
            Text(
              phase.title,
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(fontWeight: FontWeight.w800),
            ),
            Text(
              phase.duration,
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(
                fontSize: 9,
                color: const Color(PlantDetailDesign.primaryGreen),
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 4),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Fasen van de groei'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < phases.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: phaseTile(phases[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < phases.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  phaseTile(phases[i]),
                ],
              ],
            ),
        ],
      );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({required this.summary, required this.twoCol});

  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Tips voor een gezonde groei'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const monitoring = MushroomGrowthIllustration(
      assetPath: MushroomGrowthAssets.monitoring,
      aspectRatio: 4 / 3,
    );

    return twoCol
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: textBlock),
              const SizedBox(width: 12),
              const SizedBox(width: 120, child: monitoring),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [textBlock, const SizedBox(height: 12), monitoring],
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

    final list = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Veelgemaakte fouten',
          style: t.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFFB71C1C),
          ),
        ),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PlantDetailDesign.cardPadding),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF5F5),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: const Color(0xFFFFCDD2)),
      ),
      child: twoCol
          ? Row(
              children: [
                Expanded(child: list),
                const SizedBox(width: 12),
                Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                list,
                const SizedBox(height: 8),
                Center(
                  child: Icon(
                    Icons.warning_amber_rounded,
                    size: 48,
                    color: const Color(0xFFDC2626).withValues(alpha: 0.35),
                  ),
                ),
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
            size: 20,
            color: Color(PlantDetailDesign.primaryGreen),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Tip: $text',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
