import 'package:flutter/material.dart';

import '../../data/mushroom_water_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'mushroom_guide_card.dart';
import 'mushroom_water_illustrations.dart';

class MushroomWaterGuideView extends StatelessWidget {
  const MushroomWaterGuideView({super.key, required this.guide});

  final MushroomWaterGuide guide;

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
          title: 'Waarom is water belangrijk?',
          summary: guide.cardSummary('Waarom is water belangrijk?'),
          details: guide.cardDetail('Waarom is water belangrijk?'),
          child: _WhyCard(
            summary: guide.cardSummary('Waarom is water belangrijk?'),
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'De ideale watercondities',
          summary: guide.cardSummary('De ideale watercondities'),
          details: guide.cardDetail('De ideale watercondities'),
          child: _ConditionsCard(
            guide: guide,
            summary: guide.cardSummary('De ideale watercondities'),
            fourCol: fourCol,
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Hoe geef je water?',
          summary: guide.cardSummary('Hoe geef je water?'),
          details: guide.cardDetail('Hoe geef je water?'),
          child: _HowToWaterCard(
            steps: guide.methodSteps,
            summary: guide.cardSummary('Hoe geef je water?'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        const _GreenSectionTitle('Signalen: te droog of te nat'),
        const SizedBox(height: 10),
        if (twoCol)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: wrapMushroomGuideCard(
                    context: context,
                    title: 'Te droog',
                    summary: guide.cardSummary('Te droog'),
                    details: guide.cardDetail('Te droog'),
                    child: _SignalCard.dry(
                      summary: guide.cardSummary('Te droog'),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: wrapMushroomGuideCard(
                    context: context,
                    title: 'Te nat',
                    summary: guide.cardSummary('Te nat'),
                    details: guide.cardDetail('Te nat'),
                    child: _SignalCard.wet(
                      summary: guide.cardSummary('Te nat'),
                    ),
                  ),
                ),
              ],
            ),
          )
        else ...[
          wrapMushroomGuideCard(
            context: context,
            title: 'Te droog',
            summary: guide.cardSummary('Te droog'),
            details: guide.cardDetail('Te droog'),
            child: _SignalCard.dry(
              summary: guide.cardSummary('Te droog'),
            ),
          ),
          const SizedBox(height: 12),
          wrapMushroomGuideCard(
            context: context,
            title: 'Te nat',
            summary: guide.cardSummary('Te nat'),
            details: guide.cardDetail('Te nat'),
            child: _SignalCard.wet(
              summary: guide.cardSummary('Te nat'),
            ),
          ),
        ],
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Tips voor optimaal waterbeheer',
          summary: guide.cardSummary('Tips voor optimaal waterbeheer'),
          details: guide.cardDetail('Tips voor optimaal waterbeheer'),
          child: _TipsCard(
            summary: guide.cardSummary('Tips voor optimaal waterbeheer'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Veelgemaakte fouten',
          summary: guide.cardSummary('Veelgemaakte fouten'),
          details: guide.cardDetail('Veelgemaakte fouten'),
          child: _MistakesCard(
            summary: guide.cardSummary('Veelgemaakte fouten'),
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

class _WhyCard extends StatelessWidget {
  const _WhyCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final stack = MediaQuery.sizeOf(context).width < 400;

    final textBlock = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Waarom is water belangrijk?'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hero = MushroomWaterIllustration(
      assetPath: MushroomWaterAssets.hero,
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

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({
    required this.guide,
    required this.summary,
    required this.fourCol,
    required this.twoCol,
  });

  final MushroomWaterGuide guide;
  final String summary;
  final bool fourCol;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cards = [
      _ConditionTile(
        icon: Icons.water_drop_rounded,
        iconColor: const Color(0xFF3B82F6),
        value: guide.humidity,
        label: 'Luchtvochtigheid',
      ),
      _ConditionTile(
        icon: Icons.opacity_rounded,
        iconColor: const Color(0xFF3B82F6),
        value: 'Vernevelen',
        label: 'Bevochtigen',
        compactValue: true,
      ),
      _ConditionTile(
        imageAsset: MushroomWaterAssets.substrateMoisture,
        value: 'Vochtig',
        label: 'Substraatvochtigheid',
        compactValue: true,
      ),
      _ConditionTile(
        icon: Icons.water_drop_outlined,
        iconColor: const Color(0xFF2563EB),
        value: 'Schoon water',
        label: 'Waterkwaliteit',
        compactValue: true,
      ),
    ];

    Widget row(List<_ConditionTile> items) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: items[i]),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('De ideale watercondities'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
        const SizedBox(height: 12),
        if (fourCol)
          row(cards)
        else if (twoCol) ...[
          row(cards.sublist(0, 2)),
          const SizedBox(height: 8),
          row(cards.sublist(2, 4)),
        ] else ...[
          row(cards.sublist(0, 2)),
          const SizedBox(height: 8),
          row(cards.sublist(2, 4)),
        ],
      ],
    );
  }
}

class _ConditionTile extends StatelessWidget {
  const _ConditionTile({
    this.icon,
    this.iconColor,
    this.imageAsset,
    required this.value,
    required this.label,
    this.compactValue = false,
  });

  final IconData? icon;
  final Color? iconColor;
  final String? imageAsset;
  final String value;
  final String label;
  final bool compactValue;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget visual;
    if (imageAsset != null) {
      visual = SizedBox(
        height: 36,
        child: MushroomWaterIllustration(
          assetPath: imageAsset!,
          aspectRatio: 1,
          compact: true,
        ),
      );
    } else {
      visual = Icon(icon, size: 28, color: iconColor);
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
          visual,
          const SizedBox(height: 6),
          Text(
            value,
            textAlign: TextAlign.center,
            style: (compactValue ? t.labelMedium : t.titleSmall)?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFF2563EB),
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

class _HowToWaterCard extends StatelessWidget {
  const _HowToWaterCard({
    required this.steps,
    required this.summary,
    required this.twoCol,
  });

  final List<WaterMethodStep> steps;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget stepVisual(WaterMethodStep step) {
      if (step.assetPath != null) {
        return MushroomWaterIllustration(
          assetPath: step.assetPath!,
          aspectRatio: 1,
          compact: true,
        );
      }
      final icon = step.useSprayIcon
          ? Icons.opacity_rounded
          : step.useClockIcon
              ? Icons.schedule_rounded
              : Icons.search_rounded;
      return Icon(icon, size: 36, color: const Color(0xFF3B82F6));
    }

    Widget stepTile(WaterMethodStep step) {
      return Column(
        children: [
          stepVisual(step),
          const SizedBox(height: 6),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Hoe geef je water?'),
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

class _SignalCard extends StatelessWidget {
  const _SignalCard._({
    required this.title,
    required this.summary,
    required this.headerColor,
    required this.backgroundColor,
    required this.borderColor,
    required this.imageAsset,
  });

  factory _SignalCard.dry({required String summary}) {
    return _SignalCard._(
      title: 'Te droog',
      summary: summary,
      headerColor: const Color(0xFFE65100),
      backgroundColor: const Color(0xFFFFF8E1),
      borderColor: const Color(0xFFFFE082),
      imageAsset: MushroomWaterAssets.signalDry,
    );
  }

  factory _SignalCard.wet({required String summary}) {
    return _SignalCard._(
      title: 'Te nat',
      summary: summary,
      headerColor: const Color(0xFF1565C0),
      backgroundColor: const Color(0xFFE3F2FD),
      borderColor: const Color(0xFF90CAF9),
      imageAsset: MushroomWaterAssets.signalWet,
    );
  }

  final String title;
  final String summary;
  final Color headerColor;
  final Color backgroundColor;
  final Color borderColor;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final narrow = MediaQuery.sizeOf(context).width < 360;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: t.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: headerColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(summary, style: t.bodySmall?.copyWith(height: 1.35)),
      ],
    );

    final image = MushroomWaterIllustration(
      assetPath: imageAsset,
      aspectRatio: 1,
      compact: true,
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(PlantDetailDesign.cardPadding),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: borderColor),
      ),
      child: narrow
          ? Column(
              children: [content, const SizedBox(height: 10), image],
            )
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                const SizedBox(width: 8),
                SizedBox(width: 80, child: image),
              ],
            ),
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
        const _GreenSectionTitle('Tips voor optimaal waterbeheer'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hygrometer = MushroomWaterIllustration(
      assetPath: MushroomWaterAssets.hygrometer,
      aspectRatio: 4 / 3,
    );

    return twoCol
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: textBlock),
              const SizedBox(width: 12),
              const SizedBox(width: 120, child: hygrometer),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [textBlock, const SizedBox(height: 12), hygrometer],
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
        const SizedBox(height: 10),
        Text(summary, style: t.bodySmall?.copyWith(height: 1.35)),
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
