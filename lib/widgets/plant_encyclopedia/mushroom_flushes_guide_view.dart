import 'package:flutter/material.dart';

import '../../data/mushroom_flushes_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'flushes_illustrations.dart';
import 'mushroom_guide_card.dart';

class MushroomFlushesGuideView extends StatelessWidget {
  const MushroomFlushesGuideView({super.key, required this.guide});

  final MushroomFlushesGuide guide;

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
        wrapMushroomGuideCard(
          context: context,
          title: 'Wat zijn flushes?',
          summary: guide.cardSummary('Wat zijn flushes?'),
          details: guide.cardDetail('Wat zijn flushes?'),
          child: _WhatAreFlushesCard(
            summary: guide.cardSummary('Wat zijn flushes?'),
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'De flush cyclus',
          summary: guide.cardSummary('De flush cyclus'),
          details: guide.cardDetail('De flush cyclus'),
          child: _CycleCard(
            steps: guide.cycleSteps,
            summary: guide.cardSummary('De flush cyclus'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Hoeveel flushes kun je verwachten?',
          summary: guide.cardSummary('Hoeveel flushes kun je verwachten?'),
          details: guide.cardDetail('Hoeveel flushes kun je verwachten?'),
          child: _StatsCard(
            cards: guide.statCards,
            summary: guide.cardSummary('Hoeveel flushes kun je verwachten?'),
            fourCol: fourCol,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Zo start je een nieuwe flush',
          summary: guide.cardSummary('Zo start je een nieuwe flush'),
          details: guide.cardDetail('Zo start je een nieuwe flush'),
          child: _RestartCard(
            steps: guide.restartSteps,
            summary: guide.cardSummary('Zo start je een nieuwe flush'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Optimale omstandigheden na het oogsten',
          summary: guide.cardSummary('Optimale omstandigheden na het oogsten'),
          details: guide.cardDetail('Optimale omstandigheden na het oogsten'),
          child: _ConditionsCard(
            guide: guide,
            summary: guide.cardSummary('Optimale omstandigheden na het oogsten'),
            fourCol: fourCol,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        _TipCard(text: guide.conditionsTip),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Veelvoorkomende problemen tussen flushes',
          summary: guide.cardSummary('Veelvoorkomende problemen tussen flushes'),
          details: guide.cardDetail('Veelvoorkomende problemen tussen flushes'),
          child: _ProblemsCard(
            problems: guide.problems,
            summary: guide.cardSummary('Veelvoorkomende problemen tussen flushes'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        _FeedingTipCard(text: guide.feedingTip),
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

class _TipCard extends StatelessWidget {
  const _TipCard({required this.text});

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

class _WhatAreFlushesCard extends StatelessWidget {
  const _WhatAreFlushesCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stack = MediaQuery.sizeOf(context).width < 400;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Wat zijn flushes?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hero = FlushesIllustration(
      assetPath: FlushesAssets.hero,
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
                const SizedBox(width: 140, child: hero),
              ],
            );
  }
}

class _CycleCard extends StatelessWidget {
  const _CycleCard({
    required this.steps,
    required this.summary,
    required this.twoCol,
  });

  final List<FlushCycleStep> steps;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget stepVisual(FlushCycleStep step) {
      if (step.assetPath != null) {
        return FlushesIllustration(
          assetPath: step.assetPath!,
          aspectRatio: 1,
          compact: true,
        );
      }
      final icon = step.useWaterIcon
          ? Icons.water_drop_rounded
          : Icons.schedule_rounded;
      final color = step.useWaterIcon
          ? const Color(0xFF3B82F6)
          : const Color(PlantDetailDesign.primaryGreen);
      return Icon(icon, size: 36, color: color);
    }

    Widget stepTile(FlushCycleStep step) {
      return Column(
        children: [
          stepVisual(step),
          const SizedBox(height: 4),
          Text(
            step.number,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          Text(
            step.label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('De flush cyclus'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.arrow_forward_rounded,
                        size: 14,
                        color: Color(PlantDetailDesign.primaryGreen),
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

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.cards,
    required this.summary,
    required this.fourCol,
    required this.twoCol,
  });

  final List<FlushStatCard> cards;
  final String summary;
  final bool fourCol;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget statTile(FlushStatCard card) {
      return Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FAF7),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(PlantDetailDesign.border)),
        ),
        child: Column(
          children: [
            Text(
              card.value,
              textAlign: TextAlign.center,
              style: t.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            Text(
              card.label,
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ),
      );
    }

    Widget row(int start, int end) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = start; i < end; i++) ...[
              if (i > start) const SizedBox(width: 8),
              Expanded(child: statTile(cards[i])),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Hoeveel flushes kun je verwachten?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.4)),
        const SizedBox(height: 12),
          if (fourCol)
            row(0, 4)
          else if (twoCol) ...[
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

class _RestartCard extends StatelessWidget {
  const _RestartCard({
    required this.steps,
    required this.summary,
    required this.twoCol,
  });

  final List<FlushRestartStep> steps;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget stepVisual(FlushRestartStep step) {
      if (step.assetPath != null) {
        return FlushesIllustration(
          assetPath: step.assetPath!,
          aspectRatio: 1,
          compact: true,
        );
      }
      final icon = step.useBrushIcon
          ? Icons.cleaning_services_outlined
          : step.useSprayIcon
              ? Icons.opacity_rounded
              : step.useFanIcon
                  ? Icons.air_rounded
                  : Icons.schedule_rounded;
      final color = step.useSprayIcon
          ? const Color(0xFF3B82F6)
          : step.useFanIcon
              ? const Color(0xFF6B7280)
              : const Color(PlantDetailDesign.primaryGreen);
      return Icon(icon, size: 36, color: color);
    }

    Widget stepTile(FlushRestartStep step) {
      return Column(
        children: [
          stepVisual(step),
          const SizedBox(height: 6),
          Text(
            step.label,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Zo start je een nieuwe flush'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (twoCol)
            Row(
              children: [
                for (var i = 0; i < steps.length; i++) ...[
                  if (i > 0)
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 2),
                      child: Icon(
                        Icons.arrow_forward_ios_rounded,
                        size: 10,
                        color: Color(PlantDetailDesign.textSecondary),
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

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({
    required this.guide,
    required this.summary,
    required this.fourCol,
    required this.twoCol,
  });

  final MushroomFlushesGuide guide;
  final String summary;
  final bool fourCol;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final factors = [
      _FactorData(
        icon: Icons.thermostat_rounded,
        iconColor: const Color(0xFFDC2626),
        value: guide.temperature,
        label: 'Temperatuur',
        note: guide.temperatureNote,
      ),
      _FactorData(
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF3B82F6),
        value: guide.humidity,
        label: 'Luchtvochtigheid',
        note: guide.humidityNote,
      ),
      _FactorData(
        icon: Icons.air_rounded,
        iconColor: const Color(0xFF6B7280),
        value: 'Ventilatie',
        label: 'Frisse lucht',
        note: guide.ventilationNote,
        compactValue: true,
      ),
      _FactorData(
        icon: Icons.wb_sunny_outlined,
        iconColor: const Color(0xFFF59E0B),
        value: 'Licht',
        label: 'Indirect',
        note: guide.lightNote,
        compactValue: true,
      ),
      _FactorData(
        icon: Icons.grass_rounded,
        iconColor: const Color(0xFF16A34A),
        value: 'Vochtig',
        label: 'Substraat',
        note: guide.substrateNote,
        compactValue: true,
      ),
    ];

    Widget row(List<_FactorData> items) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _FactorTile(data: items[i])),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Optimale omstandigheden na het oogsten'),
        const SizedBox(height: 8),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 12),
          if (fourCol)
            row(factors)
          else if (twoCol) ...[
            row(factors.sublist(0, 3)),
            const SizedBox(height: 8),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: _FactorTile(data: factors[3])),
                  const SizedBox(width: 8),
                  Expanded(child: _FactorTile(data: factors[4])),
                ],
              ),
            ),
          ] else ...[
            row(factors.sublist(0, 2)),
            const SizedBox(height: 8),
            row(factors.sublist(2, 4)),
            const SizedBox(height: 8),
            _FactorTile(data: factors[4]),
          ],
        ],
      );
  }
}

class _FactorData {
  const _FactorData({
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
}

class _FactorTile extends StatelessWidget {
  const _FactorTile({required this.data});

  final _FactorData data;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        children: [
          Icon(data.icon, size: 26, color: data.iconColor),
          const SizedBox(height: 6),
          Text(
            data.value,
            textAlign: TextAlign.center,
            style: (data.compactValue ? t.labelMedium : t.titleSmall)?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
              fontSize: data.compactValue ? 11 : null,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            data.label,
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

class _ProblemsCard extends StatelessWidget {
  const _ProblemsCard({
    required this.problems,
    required this.summary,
    required this.twoCol,
  });

  final List<FlushProblem> problems;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget problemTile(FlushProblem problem) {
      return Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topRight,
            children: [
              SizedBox(
                width: 56,
                child: FlushesIllustration(
                  assetPath: problem.assetPath,
                  aspectRatio: 1,
                  compact: true,
                ),
              ),
              Positioned(
                right: -4,
                top: -4,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Color(0xFFDC2626),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 10, color: Colors.white),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            problem.title,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(0xFFB71C1C),
            ),
          ),
        ],
      );
    }

    Widget row(int start, int end) {
      return Row(
        children: [
          for (var i = start; i < end; i++) ...[
            if (i > start) const SizedBox(width: 8),
            Expanded(child: problemTile(problems[i])),
          ],
        ],
      );
    }

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
            'Veelvoorkomende problemen tussen flushes',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 8),
          Text(summary, style: t.bodySmall?.copyWith(height: 1.35)),
          const SizedBox(height: 12),
          if (twoCol) ...[
            row(0, 3),
            const SizedBox(height: 12),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(child: problemTile(problems[3])),
                  const SizedBox(width: 8),
                  Expanded(child: problemTile(problems[4])),
                ],
              ),
            ),
          ] else ...[
            row(0, 2),
            const SizedBox(height: 12),
            row(2, 4),
            const SizedBox(height: 12),
            problemTile(problems[4]),
          ],
        ],
      ),
    );
  }
}

class _FeedingTipCard extends StatelessWidget {
  const _FeedingTipCard({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final twoCol = MediaQuery.sizeOf(context).width - 32 >= 520.0;

    final textBlock = Row(
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
            'Extra tip: $text',
            style: t.bodyMedium?.copyWith(
              height: 1.4,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );

    const image = FlushesIllustration(
      assetPath: FlushesAssets.feeding,
      aspectRatio: 4 / 3,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFC8E6C9)),
      ),
      child: twoCol
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: textBlock),
                const SizedBox(width: 12),
                const SizedBox(width: 100, child: image),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [textBlock, const SizedBox(height: 12), image],
            ),
    );
  }
}
