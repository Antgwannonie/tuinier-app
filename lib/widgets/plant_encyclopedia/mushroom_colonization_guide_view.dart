import 'package:flutter/material.dart';

import '../../data/mushroom_colonization_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'colonization_illustrations.dart';
import 'mushroom_guide_card.dart';
import 'plant_detail_widgets.dart';

class MushroomColonizationGuideView extends StatelessWidget {
  const MushroomColonizationGuideView({super.key, required this.guide});

  final MushroomColonizationGuide guide;

  static const _twoColBreakpoint = 520.0;
  static const _fourColBreakpoint = 640.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 32;
    final twoCol = width >= _twoColBreakpoint;
    final fourCol = width >= _fourColBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Wat is kolonisatie?',
          child: (summary) => _WhatIsCard(summary: summary),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Ideale omstandigheden',
          child: (summary) =>
              _EnvStatsRow(guide: guide, summary: summary, fourCol: fourCol),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Kolonisatieduur',
          child: (summary) => _DurationTimelineCard(
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
                    title: 'Gezond mycelium herkennen',
                    child: (summary) => _HealthyMyceliumCard(summary: summary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Volledige kolonisatie herkennen',
                    child: (summary) => _FullColonizationCard(summary: summary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Gezond mycelium herkennen',
            child: (summary) => _HealthyMyceliumCard(summary: summary),
          ),
          const SizedBox(height: 12),
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Volledige kolonisatie herkennen',
            child: (summary) => _FullColonizationCard(summary: summary),
          ),
        ],
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Groei controleren',
          child: (summary) =>
              _GrowthMonitoringCard(summary: summary, twoCol: twoCol),
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
                    title: 'Problemen tijdens kolonisatie',
                    child: (summary) =>
                        _ProblemsCard(problems: guide.problems, summary: summary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Veelgemaakte fouten',
                    child: (summary) => _MistakesCard(summary: summary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Problemen tijdens kolonisatie',
            child: (summary) =>
                _ProblemsCard(problems: guide.problems, summary: summary),
          ),
          const SizedBox(height: 12),
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Veelgemaakte fouten',
            child: (summary) => _MistakesCard(summary: summary),
          ),
        ],
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
        const _GreenSectionTitle('Wat is kolonisatie?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hero = ColonizationIllustration(
      assetPath: ColonizationAssets.hero,
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

class _EnvStatsRow extends StatelessWidget {
  const _EnvStatsRow({
    required this.guide,
    required this.summary,
    required this.fourCol,
  });

  final MushroomColonizationGuide guide;
  final String summary;
  final bool fourCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cards = [
      _EnvStatCard(
        icon: Icons.thermostat_rounded,
        iconColor: const Color(PlantDetailDesign.primaryGreen),
        value: guide.temperature,
        label: 'Ideale temperatuur',
        note: guide.temperatureNote,
      ),
      _EnvStatCard(
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF3B82F6),
        value: guide.humidity,
        label: 'Ideale luchtvochtigheid',
        note: guide.humidityNote,
      ),
      _EnvStatCard(
        icon: Icons.lightbulb_outline_rounded,
        iconColor: const Color(0xFF6B7280),
        value: guide.lightLabel,
        label: 'Licht of donker?',
        note: guide.lightBody,
        compactValue: true,
      ),
      _EnvStatCard(
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF6B7280),
        value: guide.ventilationLabel,
        label: 'Ventilatie',
        note: guide.ventilationBody,
        compactValue: true,
      ),
    ];

    if (fourCol) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _GreenSectionTitle('Ideale omstandigheden'),
          const SizedBox(height: 8),
          Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
          const SizedBox(height: 12),
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
          ),
        ],
      );
    }

    return Column(
      children: [
        const _GreenSectionTitle('Ideale omstandigheden'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[0]),
              const SizedBox(width: 8),
              Expanded(child: cards[1]),
            ],
          ),
        ),
        const SizedBox(height: 8),
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: cards[2]),
              const SizedBox(width: 8),
              Expanded(child: cards[3]),
            ],
          ),
        ),
      ],
    );
  }
}

class _EnvStatCard extends StatelessWidget {
  const _EnvStatCard({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
    required this.note,
    this.compactValue = false,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;
  final String note;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(icon, size: 28, color: iconColor),
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: (compactValue ? t.titleSmall : t.titleMedium)?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _DurationTimelineCard extends StatelessWidget {
  const _DurationTimelineCard({
    required this.stages,
    required this.summary,
    required this.twoCol,
  });

  final List<ColonizationTimelineStage> stages;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final timeline = _TimelineRow(stages: stages);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Kolonisatieduur'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
        timeline,
      ],
    );
  }
}

class _TimelineRow extends StatelessWidget {
  const _TimelineRow({required this.stages});

  final List<ColonizationTimelineStage> stages;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
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
          Expanded(
            child: Column(
              children: [
                ColonizationIllustration(
                  assetPath: stages[i].assetPath,
                  aspectRatio: 1,
                  compact: true,
                ),
                const SizedBox(height: 4),
                Text(
                  stages[i].label,
                  style: t.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
                Text(
                  stages[i].duration,
                  style: t.labelSmall?.copyWith(
                    fontSize: 8,
                    color: const Color(PlantDetailDesign.textSecondary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _HealthyMyceliumCard extends StatelessWidget {
  const _HealthyMyceliumCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 360;

    final checklist = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Gezond mycelium herkennen'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const image = ColonizationIllustration(
      assetPath: ColonizationAssets.healthyMycelium,
      circle: true,
    );

    return narrow
          ? Column(
              children: [checklist, const SizedBox(height: 10), image],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: checklist),
                const SizedBox(width: 8),
                image,
              ],
            );
  }
}

class _FullColonizationCard extends StatelessWidget {
  const _FullColonizationCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 360;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Volledige kolonisatie herkennen'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodySmall?.copyWith(height: 1.4)),
      ],
    );

    const image = ColonizationIllustration(
      assetPath: ColonizationAssets.fullBlock,
      circle: true,
    );

    return narrow
          ? Column(
              children: [textBlock, const SizedBox(height: 10), image],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: textBlock),
                const SizedBox(width: 8),
                image,
              ],
            );
  }
}

class _GrowthMonitoringCard extends StatelessWidget {
  const _GrowthMonitoringCard({required this.summary, required this.twoCol});

  final String summary;
  final bool twoCol;

  static const _items = [
    (Icons.visibility_outlined, 'Visuele controle'),
    (Icons.back_hand_outlined, 'Voelt stevig aan'),
    (Icons.air_outlined, 'Frisse, aardse geur'),
    (Icons.schedule_outlined, 'Noteer de voortgang'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final iconsRow = Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        for (final (icon, label) in _items)
          Expanded(
            child: Column(
              children: [
                Icon(
                  icon,
                  size: 24,
                  color: const Color(PlantDetailDesign.primaryGreen),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  textAlign: TextAlign.center,
                  style: t.labelSmall?.copyWith(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
      ],
    );

    const rackImage = ColonizationIllustration(
      assetPath: ColonizationAssets.rack,
      aspectRatio: 16 / 10,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Groei controleren'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(child: iconsRow),
                const SizedBox(width: 12),
                const Expanded(child: rackImage),
              ],
            )
          else ...[
            iconsRow,
            const SizedBox(height: 12),
            rackImage,
          ],
        ],
      );
  }
}

class _ProblemsCard extends StatelessWidget {
  const _ProblemsCard({required this.problems, required this.summary});

  final List<ColonizationProblem> problems;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget tile(ColonizationProblem problem) {
      return Column(
        children: [
          ColonizationIllustration(
            assetPath: problem.assetPath,
            aspectRatio: 1,
            compact: true,
          ),
          const SizedBox(height: 4),
          Text(
            problem.label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Problemen tijdens kolonisatie'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: tile(problems[0])),
              const SizedBox(width: 8),
              Expanded(child: tile(problems[1])),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(child: tile(problems[2])),
              const SizedBox(width: 8),
              Expanded(child: tile(problems[3])),
            ],
          ),
        ],
      );
  }
}

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({required this.summary});

  final String summary;

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
          Text(
            'Veelgemaakte fouten',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 8),
          Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
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
