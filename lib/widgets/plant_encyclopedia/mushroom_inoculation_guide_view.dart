import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/mushroom_inoculation_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'inoculation_illustrations.dart';
import 'mushroom_guide_card.dart';

class MushroomInoculationGuideView extends StatelessWidget {
  const MushroomInoculationGuideView({super.key, required this.guide});

  final MushroomInoculationGuide guide;

  static const _twoColBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final twoCol = MediaQuery.sizeOf(context).width >= _twoColBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Wat is enten?',
          child: (summary) => _WhatIsCard(guide: guide, summary: summary),
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
                    title: 'Wanneer enten?',
                    child: (summary) => _WhenCard(summary: summary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Hoeveel broed gebruiken?',
                    child: (summary) => _SpawnRatioCard(summary: summary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Wanneer enten?',
            child: (summary) => _WhenCard(summary: summary),
          ),
          const SizedBox(height: 12),
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Hoeveel broed gebruiken?',
            child: (summary) => _SpawnRatioCard(summary: summary),
          ),
        ],
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Entmethode',
          child: (summary) => _MethodCard(guide: guide, summary: summary),
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
                    title: 'Temperatuur tijdens enten',
                    child: (summary) => _TemperatureCard(summary: summary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Hygiëne is cruciaal',
                    child: (summary) => _HygieneCard(summary: summary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Temperatuur tijdens enten',
            child: (summary) => _TemperatureCard(summary: summary),
          ),
          const SizedBox(height: 12),
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Hygiëne is cruciaal',
            child: (summary) => _HygieneCard(summary: summary),
          ),
        ],
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Benodigdheden',
          child: (summary) => _SuppliesCard(guide: guide, summary: summary),
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
                    title: 'Veelgemaakte fouten',
                    child: (summary) => _MistakesCard(summary: summary),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Besmetting voorkomen',
                    child: (summary) => _PreventionCard(summary: summary),
                  ),
                ),
              ],
            ),
          )
        else ...[
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Veelgemaakte fouten',
            child: (summary) => _MistakesCard(summary: summary),
          ),
          const SizedBox(height: 12),
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Besmetting voorkomen',
            child: (summary) => _PreventionCard(summary: summary),
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
  const _WhatIsCard({required this.guide, required this.summary});

  final MushroomInoculationGuide guide;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stack = MediaQuery.sizeOf(context).width < 400;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Wat is enten?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final spawn in guide.spawnTypes)
              Expanded(
                child: Column(
                  children: [
                    InoculationIllustration(
                      assetPath: spawn.assetPath,
                      compact: true,
                      circle: true,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      spawn.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: t.labelSmall?.copyWith(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );

    const hero = InoculationIllustration(
      assetPath: InoculationAssets.hero,
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

class _WhenCard extends StatelessWidget {
  const _WhenCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Wanneer enten?'),
        const SizedBox(height: 10),
        const Center(
          child: Icon(
            Icons.calendar_month_rounded,
            size: 48,
            color: Color(PlantDetailDesign.primaryGreen),
          ),
        ),
        const SizedBox(height: 10),
        Text(summary, style: t.bodySmall?.copyWith(height: 1.4)),
      ],
    );
  }
}

class _SpawnRatioCard extends StatelessWidget {
  const _SpawnRatioCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Hoeveel broed gebruiken?'),
        const SizedBox(height: 10),
        const Center(child: _SpawnDonutChart()),
        const SizedBox(height: 10),
        Text(summary, style: t.bodySmall?.copyWith(height: 1.4)),
      ],
    );
  }
}

class _SpawnDonutChart extends StatelessWidget {
  const _SpawnDonutChart();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SizedBox(
      height: 110,
      width: 110,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CustomPaint(
            size: const Size(110, 110),
            painter: _DonutPainter(),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🍄', style: TextStyle(fontSize: 20)),
              Text(
                'Broed',
                style: t.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: const Color(PlantDetailDesign.primaryGreen),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DonutPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 6;
    const stroke = 14.0;

    final rect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * 0.85,
      false,
      Paint()
        ..color = const Color(0xFFE5E7EB)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.butt,
    );
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * 0.15,
      false,
      Paint()
        ..color = const Color(PlantDetailDesign.primaryGreen)
        ..style = PaintingStyle.stroke
        ..strokeWidth = stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({required this.guide, required this.summary});

  final MushroomInoculationGuide guide;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 520;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Entmethode'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 14),
          if (narrow)
            Column(
              children: [
                for (var i = 0; i < guide.methodSteps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _MethodStepTile(step: guide.methodSteps[i]),
                ],
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < guide.methodSteps.length; i++) ...[
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
                  Expanded(child: _MethodStepTile(step: guide.methodSteps[i])),
                ],
              ],
            ),
        ],
      );
  }
}

class _MethodStepTile extends StatelessWidget {
  const _MethodStepTile({required this.step});

  final InoculationMethodStep step;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InoculationIllustration(
          assetPath: step.assetPath,
          aspectRatio: 1,
          compact: true,
        ),
        const SizedBox(height: 6),
        Text(
          step.title,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 11,
              ),
        ),
      ],
    );
  }
}

class _TemperatureCard extends StatelessWidget {
  const _TemperatureCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Temperatuur tijdens enten'),
        const SizedBox(height: 10),
        Text(summary, style: t.bodySmall?.copyWith(height: 1.4)),
        const SizedBox(height: 12),
        const _EntenThermometer(),
      ],
    );
  }
}

class _EntenThermometer extends StatelessWidget {
  const _EntenThermometer();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 18,
          height: 72,
          decoration: BoxDecoration(
            color: const Color(0xFFF3F4F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(PlantDetailDesign.border)),
          ),
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: 10,
              height: 48,
              margin: const EdgeInsets.only(bottom: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFE53935),
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: const Color(PlantDetailDesign.primaryGreen)
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            '20–25 °C Ideaal',
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
        ),
      ],
    );
  }
}

class _HygieneCard extends StatelessWidget {
  const _HygieneCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 400;

    return narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _GreenSectionTitle('Hygiëne is cruciaal'),
                const SizedBox(height: 8),
                Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
                const SizedBox(height: 10),
                const InoculationIllustration(
                  assetPath: InoculationAssets.hygieneSpray,
                  aspectRatio: 16 / 9,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _GreenSectionTitle('Hygiëne is cruciaal'),
                      const SizedBox(height: 8),
                      Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const SizedBox(
                  width: 90,
                  child: InoculationIllustration(
                    assetPath: InoculationAssets.hygieneSpray,
                    aspectRatio: 3 / 4,
                    compact: true,
                  ),
                ),
              ],
            );
  }
}

class _SuppliesCard extends StatelessWidget {
  const _SuppliesCard({required this.guide, required this.summary});

  final MushroomInoculationGuide guide;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 400;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Benodigdheden'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
          if (narrow)
            Wrap(
              spacing: 8,
              runSpacing: 12,
              children: [
                for (final item in guide.supplies)
                  SizedBox(
                    width: (MediaQuery.sizeOf(context).width - 64) / 3,
                    child: _SupplyTile(item: item),
                  ),
              ],
            )
          else
            Row(
              children: [
                for (var i = 0; i < guide.supplies.length; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: _SupplyTile(item: guide.supplies[i])),
                ],
              ],
            ),
        ],
      );
  }
}

class _SupplyTile extends StatelessWidget {
  const _SupplyTile({required this.item});

  final InoculationSupplyItem item;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InoculationIllustration(
          assetPath: item.assetPath,
          aspectRatio: 1,
          compact: true,
        ),
        const SizedBox(height: 4),
        Text(
          item.label,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                fontSize: 9,
                fontWeight: FontWeight.w600,
              ),
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
    return _ComparisonCard(
      title: 'Veelgemaakte fouten',
      summary: summary,
      backgroundColor: const Color(0xFFFFF5F5),
      borderColor: const Color(0xFFFFCDD2),
      titleColor: const Color(0xFFB71C1C),
      imageAsset: InoculationAssets.mistakes,
    );
  }
}

class _PreventionCard extends StatelessWidget {
  const _PreventionCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return _ComparisonCard(
      title: 'Besmetting voorkomen',
      summary: summary,
      backgroundColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFC8E6C9),
      titleColor: const Color(PlantDetailDesign.primaryGreen),
      imageAsset: InoculationAssets.prevention,
    );
  }
}

class _ComparisonCard extends StatelessWidget {
  const _ComparisonCard({
    required this.title,
    required this.summary,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.imageAsset,
  });

  final String title;
  final String summary;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          InoculationIllustration(
            assetPath: imageAsset,
            aspectRatio: 16 / 9,
            compact: true,
          ),
          const SizedBox(height: 8),
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
