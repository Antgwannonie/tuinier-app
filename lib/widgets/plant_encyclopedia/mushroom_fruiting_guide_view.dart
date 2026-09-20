import 'package:flutter/material.dart';

import '../../data/mushroom_fruiting_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'mushroom_fruiting_illustrations.dart';
import 'mushroom_guide_card.dart';

class MushroomFruitingGuideView extends StatelessWidget {
  const MushroomFruitingGuideView({super.key, required this.guide});

  final MushroomFruitingGuide guide;

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
          title: 'Wat is vruchtvorming?',
          child: (summary) => _WhatIsCard(summary: summary),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Omstandigheden',
          child: (summary) => _FactorsGrid(
            factors: guide.factors,
            summary: summary,
            fourCol: fourCol,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Van pinhead tot oogst',
          child: (summary) => _TimelineCard(
            stages: guide.timelineStages,
            summary: summary,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Vruchtvorming stimuleren',
          child: (summary) => _StimulateCard(
            actions: guide.stimulateActions,
            summary: summary,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Problemen bij vruchtvorming',
          child: (summary) => _ProblemsCard(
            problems: guide.problems,
            summary: summary,
            twoCol: twoCol,
          ),
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
        const _GreenSectionTitle('Wat is vruchtvorming?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hero = MushroomFruitingIllustration(
      assetPath: MushroomFruitingAssets.hero,
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

class _FactorsGrid extends StatelessWidget {
  const _FactorsGrid({
    required this.factors,
    required this.summary,
    required this.fourCol,
    required this.twoCol,
  });

  final List<FruitingFactor> factors;
  final String summary;
  final bool fourCol;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget row(List<FruitingFactor> items) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _FactorTile(factor: items[i])),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Omstandigheden'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
        if (fourCol) ...[
            row(factors.sublist(0, 4)),
            const SizedBox(height: 8),
            row(factors.sublist(4, 8)),
          ] else if (twoCol) ...[
            row(factors.sublist(0, 2)),
            const SizedBox(height: 8),
            row(factors.sublist(2, 4)),
            const SizedBox(height: 8),
            row(factors.sublist(4, 6)),
            const SizedBox(height: 8),
            row(factors.sublist(6, 8)),
          ] else
            Column(
              children: [
                for (var i = 0; i < factors.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 8),
                  row(factors.sublist(i, i + 2 > factors.length ? factors.length : i + 2)),
                ],
              ],
            ),
        ],
      );
  }
}

class _FactorTile extends StatelessWidget {
  const _FactorTile({required this.factor});

  final FruitingFactor factor;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget visual;
    if (factor.assetPath != null) {
      visual = MushroomFruitingIllustration(
        assetPath: factor.assetPath!,
        aspectRatio: 1,
        compact: true,
      );
    } else {
      final icon = factor.useCalendarIcon
          ? Icons.calendar_month_rounded
          : factor.useThermometerIcon
              ? Icons.thermostat_rounded
              : factor.useHumidityIcon
                  ? Icons.water_drop_rounded
                  : factor.useSunIcon
                      ? Icons.wb_sunny_outlined
                      : factor.useFanIcon
                          ? Icons.air_rounded
                          : factor.useCo2Icon
                              ? Icons.cloud_outlined
                              : Icons.schedule_rounded;
      final color = factor.useThermometerIcon
          ? const Color(0xFFDC2626)
          : factor.useHumidityIcon
              ? const Color(0xFF3B82F6)
              : factor.useSunIcon
                  ? const Color(0xFFF59E0B)
                  : const Color(PlantDetailDesign.primaryGreen);
      visual = Icon(icon, size: 32, color: color);
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        children: [
          Text(
            factor.title,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(height: factor.assetPath != null ? 56 : 36, child: Center(child: visual)),
          const SizedBox(height: 4),
          Text(
            factor.value,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimelineCard extends StatelessWidget {
  const _TimelineCard({
    required this.stages,
    required this.summary,
    required this.twoCol,
  });

  final List<FruitingTimelineStage> stages;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget stageTile(FruitingTimelineStage stage) {
      return Column(
        children: [
          MushroomFruitingIllustration(
            assetPath: stage.assetPath,
            aspectRatio: 1,
            compact: true,
          ),
          const SizedBox(height: 6),
          Text(
            stage.label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            stage.duration,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontSize: 9,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Van pinhead tot oogst'),
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
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(PlantDetailDesign.primaryGreen),
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

class _StimulateCard extends StatelessWidget {
  const _StimulateCard({
    required this.actions,
    required this.summary,
    required this.twoCol,
  });

  final List<FruitingStimulateAction> actions;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget actionTile(FruitingStimulateAction action) {
      final icon = action.useWaterIcon
          ? Icons.water_drop_rounded
          : action.useFanIcon
              ? Icons.air_rounded
              : action.useThermometerIcon
                  ? Icons.thermostat_rounded
                  : action.useSunIcon
                      ? Icons.wb_sunny_outlined
                      : Icons.cloud_outlined;
      final color = action.useWaterIcon
          ? const Color(0xFF3B82F6)
          : action.useSunIcon
              ? const Color(0xFFF59E0B)
              : const Color(PlantDetailDesign.primaryGreen);

      return Column(
        children: [
          Icon(icon, size: 28, color: color),
          const SizedBox(height: 6),
          Text(
            action.label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              height: 1.3,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Vruchtvorming stimuleren'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              children: [
                for (var i = 0; i < actions.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: actionTile(actions[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < actions.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: actionTile(actions[i])),
                      if (i + 1 < actions.length) ...[
                        const SizedBox(width: 8),
                        Expanded(child: actionTile(actions[i + 1])),
                      ],
                    ],
                  ),
                ],
              ],
            ),
        ],
      );
  }
}

class _ProblemsCard extends StatelessWidget {
  const _ProblemsCard({
    required this.problems,
    required this.summary,
    required this.twoCol,
  });

  final List<FruitingProblem> problems;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget problemTile(FruitingProblem problem) {
      return Column(
        children: [
          MushroomFruitingIllustration(
            assetPath: problem.assetPath,
            aspectRatio: 1,
            compact: true,
          ),
          const SizedBox(height: 6),
          const Icon(Icons.cancel_rounded, size: 16, color: Color(0xFFB71C1C)),
          const SizedBox(height: 4),
          Text(
            problem.title,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB71C1C),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Problemen bij vruchtvorming',
          style: t.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(0xFFB71C1C),
          ),
        ),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              children: [
                for (var i = 0; i < problems.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: problemTile(problems[i])),
                ],
              ],
            )
          else
            Column(
              children: [
                for (var i = 0; i < problems.length; i += 2) ...[
                  if (i > 0) const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(child: problemTile(problems[i])),
                      if (i + 1 < problems.length) ...[
                        const SizedBox(width: 8),
                        Expanded(child: problemTile(problems[i + 1])),
                      ],
                    ],
                  ),
                ],
              ],
            ),
        ],
      );
  }
}

class _FooterTipCard extends StatelessWidget {
  const _FooterTipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final narrow = MediaQuery.sizeOf(context).width < 400;

    final tip = Row(
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
    );

    const image = SizedBox(
      width: 80,
      child: MushroomFruitingIllustration(
        assetPath: MushroomFruitingAssets.tip,
        aspectRatio: 1,
        compact: true,
      ),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: narrow
          ? Column(
              children: [tip, const SizedBox(height: 10), image],
            )
          : Row(
              children: [
                Expanded(child: tip),
                const SizedBox(width: 10),
                image,
              ],
            ),
    );
  }
}
