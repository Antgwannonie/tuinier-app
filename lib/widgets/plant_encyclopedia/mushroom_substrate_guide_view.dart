import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/mushroom_substrate_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'mushroom_guide_card.dart';
import 'substrate_illustrations.dart';

/// Substraat-tab in mockup-stijl voor alle paddenstoelen.
class MushroomSubstrateGuideView extends StatelessWidget {
  const MushroomSubstrateGuideView({super.key, required this.guide});

  final MushroomSubstrateGuide guide;

  static const _twoColBreakpoint = 520.0;
  static const _threeColBreakpoint = 680.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 32;
    final twoCol = width >= _twoColBreakpoint;
    final threeCol = width >= _threeColBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Wat is substraat?',
          child: (summary) => _IntroSection(
            title: 'Wat is substraat?',
            summary: summary,
            imageAsset: SubstrateAssets.best,
          ),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Waarvoor gebruik je het?',
          child: (summary) => _IntroSection(
            title: 'Waarvoor gebruik je het?',
            summary: summary,
            imageAsset: SubstrateAssets.best,
          ),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Beste substraat',
          child: (summary) => _BestSubstrateCard(summary: summary),
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
                    title: 'Alternatieve substraten',
                    child: (summary) => _MaterialOptionsCard(
                      number: 2,
                      title: 'Alternatieve substraten',
                      summary: summary,
                      options: guide.alternatives,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Geschikte houtsoorten',
                    child: (summary) => _MaterialOptionsCard(
                      number: 3,
                      title: 'Geschikte houtsoorten',
                      summary: summary,
                      options: guide.woodTypes,
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Alternatieve substraten',
            child: (summary) => _MaterialOptionsCard(
              number: 2,
              title: 'Alternatieve substraten',
              summary: summary,
              options: guide.alternatives,
            ),
          ),
          const SizedBox(height: 12),
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Geschikte houtsoorten',
            child: (summary) => _MaterialOptionsCard(
              number: 3,
              title: 'Geschikte houtsoorten',
              summary: summary,
              options: guide.woodTypes,
            ),
          ),
        ],
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Ideaal vochtgehalte',
          child: (summary) => _MoistureCard(summary: summary),
        ),
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Substraat voorbereiden',
          child: (summary) => _PrepCard(guide: guide, summary: summary),
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
                    title: 'Pasteuriseren',
                    child: (summary) => _TreatmentCard(
                      number: 6,
                      title: 'Pasteuriseren',
                      summary: summary,
                      assetPath: SubstrateAssets.pasteurize,
                      duration: '1–2 uur',
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: mushroomGuideCard(
                    context: context,
                    guide: guide,
                    title: 'Steriliseren',
                    child: (summary) => _TreatmentCard(
                      number: 7,
                      title: 'Steriliseren',
                      summary: summary,
                      assetPath: SubstrateAssets.sterilize,
                      duration: '60–90 min',
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Pasteuriseren',
            child: (summary) => _TreatmentCard(
              number: 6,
              title: 'Pasteuriseren',
              summary: summary,
              assetPath: SubstrateAssets.pasteurize,
              duration: '1–2 uur',
            ),
          ),
          const SizedBox(height: 12),
          mushroomGuideCard(
            context: context,
            guide: guide,
            title: 'Steriliseren',
            child: (summary) => _TreatmentCard(
              number: 7,
              title: 'Steriliseren',
              summary: summary,
              assetPath: SubstrateAssets.sterilize,
              duration: '60–90 min',
            ),
          ),
        ],
        const SizedBox(height: 12),
        mushroomGuideCard(
          context: context,
          guide: guide,
          title: 'Temperatuur van het substraat',
          child: (summary) => _TemperatureCard(summary: summary),
        ),
        const SizedBox(height: 12),
        if (threeCol)
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
                const SizedBox(width: 10),
                Expanded(child: _ChecklistCard(items: guide.checklist)),
              ],
            ),
          )
        else if (twoCol)
          Column(
            children: [
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
              ),
              const SizedBox(height: 12),
              _ChecklistCard(items: guide.checklist),
            ],
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
          const SizedBox(height: 12),
          _ChecklistCard(items: guide.checklist),
        ],
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

class _IntroSection extends StatelessWidget {
  const _IntroSection({
    required this.title,
    required this.summary,
    required this.imageAsset,
  });

  final String title;
  final String summary;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stack = MediaQuery.sizeOf(context).width < 400;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _GreenSectionTitle(title),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    final image = SubstrateIllustration(
      assetPath: imageAsset,
      aspectRatio: 4 / 3,
    );

    return stack
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [textBlock, const SizedBox(height: 12), image],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: textBlock),
                const SizedBox(width: 12),
                SizedBox(width: 140, child: image),
              ],
            );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.number, required this.title});

  final int number;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      '$number. $title',
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
    );
  }
}

class _BestSubstrateCard extends StatelessWidget {
  const _BestSubstrateCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stack = MediaQuery.sizeOf(context).width < 400;

    final text = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionTitle(number: 1, title: 'Beste substraat'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const image = SubstrateIllustration(
      assetPath: SubstrateAssets.best,
      aspectRatio: 4 / 3,
    );

    return stack
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [text, const SizedBox(height: 12), image],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: text),
                const SizedBox(width: 12),
                SizedBox(width: 140, child: image),
              ],
            );
  }
}

class _MaterialOptionsCard extends StatelessWidget {
  const _MaterialOptionsCard({
    required this.number,
    required this.title,
    required this.summary,
    required this.options,
  });

  final int number;
  final String title;
  final String summary;
  final List<SubstrateMaterialOption> options;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(number: number, title: title),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
        Row(
            children: [
              for (var i = 0; i < options.length; i++) ...[
                if (i > 0) const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    children: [
                      SubstrateIllustration(
                        assetPath: options[i].assetPath,
                        aspectRatio: 1,
                        compact: true,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        options[i].label,
                        textAlign: TextAlign.center,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ],
      );
  }
}

class _MoistureCard extends StatelessWidget {
  const _MoistureCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 400;

    return narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionTitle(number: 4, title: 'Ideaal vochtgehalte'),
                const SizedBox(height: 8),
                Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
                const SizedBox(height: 12),
                const SubstrateIllustration(
                  assetPath: SubstrateAssets.moistChips,
                  aspectRatio: 16 / 9,
                ),
                const SizedBox(height: 12),
                const Center(child: _MoistureGauge()),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(
                        number: 4,
                        title: 'Ideaal vochtgehalte',
                      ),
                      const SizedBox(height: 8),
                      Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
                      const SizedBox(height: 12),
                      const SizedBox(
                        width: 120,
                        child: SubstrateIllustration(
                          assetPath: SubstrateAssets.moistChips,
                          aspectRatio: 1,
                          compact: true,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(flex: 2, child: _MoistureGauge()),
              ],
            );
  }
}

class _MoistureGauge extends StatelessWidget {
  const _MoistureGauge();

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        SizedBox(
          height: 80,
          width: 140,
          child: CustomPaint(
            painter: _MoistureGaugePainter(),
            size: const Size(140, 80),
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF0FDF4),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: const Color(PlantDetailDesign.primaryGreen)
                  .withValues(alpha: 0.35),
            ),
          ),
          child: Text(
            '60–70 % Ideaal',
            style: t.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                'Droog',
                textAlign: TextAlign.center,
                style: t.labelSmall?.copyWith(fontSize: 10),
              ),
            ),
            Expanded(
              child: Text(
                'Nat',
                textAlign: TextAlign.center,
                style: t.labelSmall?.copyWith(fontSize: 10),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MoistureGaugePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height - 6);
    final radius = size.width / 2 - 8;

    const colors = [
      Color(0xFFFFF3E0),
      Color(0xFFFFE0B2),
      Color(0xFF86EFAC),
      Color(0xFF22C55E),
    ];

    for (var i = 0; i < colors.length; i++) {
      final start = math.pi + (math.pi / colors.length) * i;
      final sweep = math.pi / colors.length;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        start,
        sweep,
        false,
        Paint()
          ..color = colors[i]
          ..style = PaintingStyle.stroke
          ..strokeWidth = 10,
      );
    }

    const needleValue = 0.55;
    final angle = math.pi + math.pi * needleValue;
    final end = Offset(
      center.dx + math.cos(angle) * (radius - 4),
      center.dy + math.sin(angle) * (radius - 4),
    );
    canvas.drawLine(
      center,
      end,
      Paint()
        ..color = const Color(PlantDetailDesign.textPrimary)
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.drawCircle(
      center,
      4,
      Paint()..color = const Color(PlantDetailDesign.textPrimary),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _PrepCard extends StatelessWidget {
  const _PrepCard({required this.guide, required this.summary});

  final MushroomSubstrateGuide guide;
  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 520;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _SectionTitle(number: 5, title: 'Substraat voorbereiden'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 14),
          if (narrow)
            Column(
              children: [
                for (var i = 0; i < guide.prepSteps.length; i++) ...[
                  if (i > 0) const SizedBox(height: 10),
                  _PrepStepTile(step: guide.prepSteps[i]),
                ],
              ],
            )
          else
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < guide.prepSteps.length; i++) ...[
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
                  Expanded(child: _PrepStepTile(step: guide.prepSteps[i])),
                ],
              ],
            ),
        ],
      );
  }
}

class _PrepStepTile extends StatelessWidget {
  const _PrepStepTile({required this.step});

  final SubstratePrepStep step;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      children: [
        SubstrateIllustration(
          assetPath: step.assetPath,
          aspectRatio: 1,
          compact: true,
        ),
        const SizedBox(height: 6),
        Text(
          step.title,
          textAlign: TextAlign.center,
          style: t.labelMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ],
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({
    required this.number,
    required this.title,
    required this.summary,
    required this.assetPath,
    required this.duration,
  });

  final int number;
  final String title;
  final String summary;
  final String assetPath;
  final String duration;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionTitle(number: number, title: title),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
        Stack(
            alignment: Alignment.bottomRight,
            children: [
              SubstrateIllustration(assetPath: assetPath, aspectRatio: 4 / 3),
              Container(
                margin: const EdgeInsets.all(6),
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(PlantDetailDesign.border)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.schedule, size: 14, color: Color(0xFFE53935)),
                    const SizedBox(width: 4),
                    Text(
                      duration,
                      style: t.labelSmall?.copyWith(fontWeight: FontWeight.w700),
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

class _TemperatureCard extends StatelessWidget {
  const _TemperatureCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 420;

    return narrow
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SectionTitle(number: 8, title: 'Temperatuur van het substraat'),
                const SizedBox(height: 8),
                Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
                const SizedBox(height: 12),
                const _ThermometerGraphic(),
                const SizedBox(height: 12),
                const SubstrateIllustration(
                  assetPath: SubstrateAssets.temperature,
                  aspectRatio: 16 / 9,
                ),
              ],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _SectionTitle(
                        number: 8,
                        title: 'Temperatuur van het substraat',
                      ),
                      const SizedBox(height: 8),
                      Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
                      const SizedBox(height: 12),
                      const _ThermometerGraphic(),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const SizedBox(
                  width: 110,
                  child: SubstrateIllustration(
                    assetPath: SubstrateAssets.temperature,
                    aspectRatio: 3 / 4,
                  ),
                ),
              ],
            );
  }
}

class _ThermometerGraphic extends StatelessWidget {
  const _ThermometerGraphic();

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
              height: 44,
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

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      number: 9,
      title: 'Veelgemaakte fouten',
      summary: summary,
      backgroundColor: const Color(0xFFFFF5F5),
      borderColor: const Color(0xFFFFCDD2),
      titleColor: const Color(0xFFB71C1C),
      icon: Icons.close_rounded,
      iconColor: const Color(0xFFE53935),
    );
  }
}

class _PreventionCard extends StatelessWidget {
  const _PreventionCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return _ListCard(
      number: 10,
      title: 'Besmetting voorkomen',
      summary: summary,
      backgroundColor: const Color(0xFFF0FDF4),
      borderColor: const Color(0xFFC8E6C9),
      titleColor: const Color(PlantDetailDesign.primaryGreen),
      icon: Icons.check_rounded,
      iconColor: const Color(PlantDetailDesign.primaryGreen),
    );
  }
}

class _ChecklistCard extends StatelessWidget {
  const _ChecklistCard({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
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
            '11. Controlelijst',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.check_box_outline_blank_rounded,
                    size: 18,
                    color: const Color(PlantDetailDesign.primaryGreen)
                        .withValues(alpha: 0.7),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      item,
                      style: t.bodySmall?.copyWith(height: 1.35),
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

class _ListCard extends StatelessWidget {
  const _ListCard({
    required this.number,
    required this.title,
    required this.summary,
    required this.backgroundColor,
    required this.borderColor,
    required this.titleColor,
    required this.icon,
    required this.iconColor,
  });

  final int number;
  final String title;
  final String summary;
  final Color backgroundColor;
  final Color borderColor;
  final Color titleColor;
  final IconData icon;
  final Color iconColor;

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
            '$number. $title',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: titleColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        ],
      ),
    );
  }
}
