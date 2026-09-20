import 'package:flutter/material.dart';

import '../../data/mushroom_storage_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import 'mushroom_guide_card.dart';
import 'storage_illustrations.dart';

class MushroomStorageGuideView extends StatelessWidget {
  const MushroomStorageGuideView({super.key, required this.guide});

  final MushroomStorageGuide guide;

  static const _twoColBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 32;
    final twoCol = width >= _twoColBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        wrapMushroomGuideCard(
          context: context,
          title: 'Waarom goed bewaren belangrijk is',
          summary: guide.cardSummary('Waarom goed bewaren belangrijk is'),
          details: guide.cardDetail('Waarom goed bewaren belangrijk is'),
          child: _HeroCard(
            summary: guide.cardSummary('Waarom goed bewaren belangrijk is'),
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Bewaarmethoden',
          summary: guide.cardSummary('Bewaarmethoden'),
          details: guide.cardDetail('Bewaarmethoden'),
          child: _MethodsSection(
            methods: guide.methods,
            summary: guide.cardSummary('Bewaarmethoden'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Stappen voor bewaren in de koelkast',
          summary: guide.cardSummary('Stappen voor bewaren in de koelkast'),
          details: guide.cardDetail('Stappen voor bewaren in de koelkast'),
          child: _FridgeStepsCard(
            steps: guide.fridgeSteps,
            summary: guide.cardSummary('Stappen voor bewaren in de koelkast'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Hoe lang kun je ze bewaren?',
          summary: guide.cardSummary('Hoe lang kun je ze bewaren?'),
          details: guide.cardDetail('Hoe lang kun je ze bewaren?'),
          child: _ShelfLifeCard(
            summary: guide.cardSummary('Hoe lang kun je ze bewaren?'),
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Tips voor optimaal bewaren',
          summary: guide.cardSummary('Tips voor optimaal bewaren'),
          details: guide.cardDetail('Tips voor optimaal bewaren'),
          child: _TipsCard(
            summary: guide.cardSummary('Tips voor optimaal bewaren'),
            twoCol: twoCol,
          ),
        ),
        const SizedBox(height: 12),
        wrapMushroomGuideCard(
          context: context,
          title: 'Verschillen in kwaliteit',
          summary: guide.cardSummary('Verschillen in kwaliteit'),
          details: guide.cardDetail('Verschillen in kwaliteit'),
          child: _QualitySection(
            cards: guide.qualityCards,
            summary: guide.cardSummary('Verschillen in kwaliteit'),
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
        const _GreenSectionTitle('Waarom goed bewaren belangrijk is'),
        const SizedBox(height: 8),
        Text(summary, style: t.bodyMedium?.copyWith(height: 1.45)),
      ],
    );

    const hero = StorageIllustration(
      assetPath: StorageAssets.hero,
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

class _MethodsSection extends StatelessWidget {
  const _MethodsSection({
    required this.methods,
    required this.summary,
    required this.twoCol,
  });

  final List<StorageMethodCard> methods;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    Widget methodCard(StorageMethodCard method) {
      return _MethodCard(method: method);
    }

    Widget row(List<StorageMethodCard> items) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < items.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: methodCard(items[i])),
            ],
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Bewaarmethoden'),
        const SizedBox(height: 8),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 10),
        if (twoCol)
          row(methods)
        else ...[
          row(methods.sublist(0, 2)),
          const SizedBox(height: 8),
          row(methods.sublist(2, 4)),
        ],
      ],
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({required this.method});

  final StorageMethodCard method;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(PlantDetailDesign.card),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                storageMethodIcon(method.icon),
                size: 18,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  method.title,
                  style: t.labelLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StorageIllustration(
            assetPath: method.assetPath,
            aspectRatio: 16 / 10,
            compact: true,
          ),
          const SizedBox(height: 8),
          for (final check in method.checkmarks.take(1))
            Text(
              check,
              textAlign: TextAlign.center,
              style: t.labelSmall?.copyWith(height: 1.3),
            ),
        ],
      ),
    );
  }
}

class _FridgeStepsCard extends StatelessWidget {
  const _FridgeStepsCard({
    required this.steps,
    required this.summary,
    required this.twoCol,
  });

  final List<StorageFridgeStep> steps;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    Widget stepVisual(StorageFridgeStep step) {
      if (step.assetPath != null) {
        return StorageIllustration(
          assetPath: step.assetPath!,
          aspectRatio: 1,
          compact: true,
        );
      }
      return const Icon(
        Icons.schedule_rounded,
        size: 36,
        color: Color(PlantDetailDesign.primaryGreen),
      );
    }

    Widget stepTile(StorageFridgeStep step) {
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
        const _GreenSectionTitle('Stappen voor bewaren in de koelkast'),
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

class _ShelfLifeCard extends StatelessWidget {
  const _ShelfLifeCard({required this.summary});

  final String summary;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Hoe lang kun je ze bewaren?'),
        const SizedBox(height: 8),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _GreenSectionTitle('Tips voor optimaal bewaren'),
        const SizedBox(height: 8),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
      ],
    );
  }
}

class _QualitySection extends StatelessWidget {
  const _QualitySection({
    required this.cards,
    required this.summary,
    required this.twoCol,
  });

  final List<StorageQualityCard> cards;
  final String summary;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const _GreenSectionTitle('Verschillen in kwaliteit'),
        const SizedBox(height: 8),
        Text(
          summary,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 10),
        if (twoCol)
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < cards.length; i++) ...[
                  if (i > 0) const SizedBox(width: 8),
                  Expanded(child: _QualityCard(card: cards[i])),
                ],
              ],
            ),
          )
        else
          Column(
            children: [
              for (var i = 0; i < cards.length; i++) ...[
                if (i > 0) const SizedBox(height: 8),
                _QualityCard(card: cards[i]),
              ],
            ],
          ),
      ],
    );
  }
}

class _QualityCard extends StatelessWidget {
  const _QualityCard({required this.card});

  final StorageQualityCard card;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    final (icon, color) = switch (card.level) {
      StorageQualityLevel.fresh => (
          Icons.check_circle_rounded,
          const Color(PlantDetailDesign.primaryGreen),
        ),
      StorageQualityLevel.warning => (
          Icons.warning_amber_rounded,
          const Color(0xFFF59E0B),
        ),
      StorageQualityLevel.bad => (
          Icons.cancel_rounded,
          const Color(0xFFDC2626),
        ),
    };

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: const Color(PlantDetailDesign.card),
        borderRadius: BorderRadius.circular(PlantDetailDesign.cardRadius),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  card.title,
                  style: t.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          StorageIllustration(
            assetPath: card.assetPath,
            aspectRatio: 16 / 10,
            compact: true,
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
