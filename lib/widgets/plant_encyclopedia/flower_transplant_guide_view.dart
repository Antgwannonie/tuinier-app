import 'package:flutter/material.dart';

import '../../data/flower_card_summaries.dart';
import '../../data/flower_transplant_guide_data.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_transplant_guide.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'seasonal_month_calendar.dart';

/// Flower-only Uitplanten-layout volgens mockup: tekst boven, afbeelding eronder.
class FlowerTransplantGuideView extends StatelessWidget {
  const FlowerTransplantGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantTransplantGuide guide;

  static const _wideBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final g = flowerTransplantGuideForVegetable(vegetable);
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _PeriodCard(guide: g),
        const SizedBox(height: 12),
        _ConditionsCard(guide: g, wide: wide),
        const SizedBox(height: 12),
        _HardeningCard(guide: g),
        const SizedBox(height: 12),
        _SpacingRow(guide: g, wide: wide),
        const SizedBox(height: 12),
        _BestLocationCard(guide: g),
        const SizedBox(height: 12),
        _SoilPrepCard(guide: g, wide: wide),
        const SizedBox(height: 12),
        _WaterSupportRow(guide: g, wide: wide),
        const SizedBox(height: 12),
        _ProtectionCard(guide: g),
        const SizedBox(height: 12),
        _TimingRow(guide: g, wide: wide),
        const SizedBox(height: 12),
        _MistakesCard(guide: g),
      ],
    );
  }
}

class _PeriodCard extends StatelessWidget {
  const _PeriodCard({required this.guide});

  final FlowerTransplantGuide guide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: 'Uitplantperiode',
        summary: guide.periodLabel,
        details: guide.detailsFor('Uitplantperiode'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Uitplantperiode',
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              guide.periodLabel,
              style: t.bodyMedium?.copyWith(
                height: 1.35,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            const SizedBox(height: 12),
            SeasonalMonthCalendar(
              months: guide.periodMonths,
              label: null,
              compact: true,
              showTitle: false,
            ),
          ],
        ),
      ),
    );
  }
}

class _ConditionsCard extends StatelessWidget {
  const _ConditionsCard({required this.guide, required this.wide});

  final FlowerTransplantGuide guide;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: 'Uitplantvoorwaarden',
        summary: guide.conditions.take(2).join(' '),
        details: guide.detailsFor('Uitplantvoorwaarden'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Uitplantvoorwaarden',
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 10),
            if (wide)
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(child: _BulletList(items: guide.conditions)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _UnderTextImage(assetPath: guide.conditionsImage),
                  ),
                ],
              )
            else ...[
              _BulletList(items: guide.conditions),
              const SizedBox(height: 12),
              _UnderTextImage(assetPath: guide.conditionsImage),
            ],
          ],
        ),
      ),
    );
  }
}

class _HardeningCard extends StatelessWidget {
  const _HardeningCard({required this.guide});

  final FlowerTransplantGuide guide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: 'Afharden',
        summary: _transplantSummary(guide, 'Afharden'),
        details: guide.detailsFor('Afharden'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Afharden',
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _transplantSummary(guide, 'Afharden'),
              style: t.bodySmall?.copyWith(
                color: const Color(PlantDetailDesign.textSecondary),
              ),
            ),
            const SizedBox(height: 12),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  for (var i = 0; i < guide.hardeningSteps.length; i++) ...[
                    if (i > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 16,
                          color: const Color(PlantDetailDesign.primaryGreen)
                              .withValues(alpha: 0.55),
                        ),
                      ),
                    _HardeningStepChip(step: guide.hardeningSteps[i]),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            _UnderTextImage(assetPath: guide.hardeningImage, height: 240),
          ],
        ),
      ),
    );
  }
}

class _HardeningStepChip extends StatelessWidget {
  const _HardeningStepChip({required this.step});

  final FlowerHardeningStep step;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      width: 92,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.eco_outlined,
            size: 20,
            color: Color(PlantDetailDesign.primaryGreen),
          ),
          const SizedBox(height: 6),
          Text(
            step.label,
            textAlign: TextAlign.center,
            style: t.labelMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            step.detail,
            textAlign: TextAlign.center,
            style: t.bodySmall?.copyWith(
              fontSize: 11,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SpacingRow extends StatelessWidget {
  const _SpacingRow({required this.guide, required this.wide});

  final FlowerTransplantGuide guide;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _TextAboveImageCard(
        guide: guide,
        title: 'Plantafstand',
        body: guide.plantSpacing,
        imageAsset: guide.plantSpacingImage,
      ),
      _TextAboveImageCard(
        guide: guide,
        title: 'Rijafstand',
        body: guide.rowSpacing,
        imageAsset: guide.rowSpacingImage,
      ),
      _TextAboveImageCard(
        guide: guide,
        title: 'Plantdiepte',
        body: guide.plantingDepth,
        imageAsset: guide.plantingDepthImage,
      ),
    ];

    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: cards[i]),
            ],
          ],
        ),
      );
    }

    return Column(
      children: [
        for (var i = 0; i < cards.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          cards[i],
        ],
      ],
    );
  }
}

class _BestLocationCard extends StatelessWidget {
  const _BestLocationCard({required this.guide});

  final FlowerTransplantGuide guide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: 'Beste locatie',
        summary: _transplantSummary(guide, 'Beste locatie'),
        details: guide.detailsFor('Beste locatie'),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Beste locatie',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _transplantSummary(guide, 'Beste locatie'),
            style: t.bodySmall?.copyWith(
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              for (final loc in guide.locations)
                SizedBox(
                  width: 72,
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: loc.suitable
                              ? const Color(0xFFE8F5E9)
                              : const Color(0xFFF5F5F5),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: loc.suitable
                                ? const Color(0xFFC8E6C9)
                                : const Color(PlantDetailDesign.border),
                          ),
                        ),
                        child: Icon(
                          loc.icon,
                          color: loc.suitable
                              ? const Color(PlantDetailDesign.primaryGreen)
                              : const Color(PlantDetailDesign.textSecondary),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}

class _SoilPrepCard extends StatelessWidget {
  const _SoilPrepCard({required this.guide, required this.wide});

  final FlowerTransplantGuide guide;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: 'Bodemvoorbereiding',
        summary: guide.soilPrepItems.take(2).join(' '),
        details: guide.detailsFor('Bodemvoorbereiding'),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bodemvoorbereiding',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 10),
          if (wide)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _BulletList(items: guide.soilPrepItems)),
                const SizedBox(width: 12),
                Expanded(
                  child: _UnderTextImage(assetPath: guide.soilPrepImage),
                ),
              ],
            )
          else ...[
            _BulletList(items: guide.soilPrepItems),
            const SizedBox(height: 12),
            _UnderTextImage(assetPath: guide.soilPrepImage),
          ],
        ],
        ),
      ),
    );
  }
}

class _WaterSupportRow extends StatelessWidget {
  const _WaterSupportRow({required this.guide, required this.wide});

  final FlowerTransplantGuide guide;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _ChecklistImageCard(
        guide: guide,
        title: 'Water na uitplanten',
        items: guide.waterItems,
        imageAsset: guide.waterImage,
      ),
      _ChecklistImageCard(
        guide: guide,
        title: 'Ondersteuning nodig',
        items: guide.supportItems,
        imageAsset: guide.supportImage,
      ),
    ];

    if (wide) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 8),
            Expanded(child: cards[1]),
          ],
        ),
      );
    }

    return Column(
      children: [
        cards[0],
        const SizedBox(height: 8),
        cards[1],
      ],
    );
  }
}

class _ProtectionCard extends StatelessWidget {
  const _ProtectionCard({required this.guide});

  final FlowerTransplantGuide guide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: 'Bescherming na uitplanten',
        summary: _transplantSummary(guide, 'Bescherming na uitplanten'),
        details: guide.detailsFor('Bescherming na uitplanten'),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Bescherming na uitplanten',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _transplantSummary(guide, 'Bescherming na uitplanten'),
            style: t.bodySmall?.copyWith(
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            alignment: WrapAlignment.spaceBetween,
            children: [
              for (final item in guide.protectionItems)
                SizedBox(
                  width: 76,
                  child: Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE3F2FD),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(PlantDetailDesign.border),
                          ),
                        ),
                        child: Icon(
                          item.icon,
                          color: const Color(PlantDetailDesign.primaryGreen),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        item.label,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: t.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          _UnderTextImage(assetPath: guide.protectionImage, height: 240),
        ],
        ),
      ),
    );
  }
}

class _TimingRow extends StatelessWidget {
  const _TimingRow({required this.guide, required this.wide});

  final FlowerTransplantGuide guide;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _TextAboveImageCard(
        guide: guide,
        title: 'Tijd tot aanslaan',
        body: guide.timeToEstablish,
        imageAsset: guide.timeToEstablishImage,
      ),
      _TextAboveImageCard(
        guide: guide,
        title: 'Tijd tot eerste groei',
        body: guide.timeToGrowth,
        imageAsset: guide.timeToGrowthImage,
      ),
    ];

    if (wide || MediaQuery.sizeOf(context).width >= 360) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(child: cards[0]),
            const SizedBox(width: 8),
            Expanded(child: cards[1]),
          ],
        ),
      );
    }

    return Column(
      children: [
        cards[0],
        const SizedBox(height: 8),
        cards[1],
      ],
    );
  }
}

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({required this.guide});

  final FlowerTransplantGuide guide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: 'Veelgemaakte fouten',
        summary: guide.mistakes.take(2).map((e) => e.title).join(', '),
        details: guide.detailsFor('Veelgemaakte fouten'),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Veelgemaakte fouten',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(0xFFB71C1C),
            ),
          ),
          const SizedBox(height: 10),
          for (final item in guide.mistakes)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFEBEE),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: const BoxDecoration(
                      color: Color(0xFFE53935),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: t.labelLarge?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: const Color(PlantDetailDesign.textPrimary),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.body,
                          style: t.bodySmall?.copyWith(
                            height: 1.35,
                            color: const Color(PlantDetailDesign.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 4),
          _UnderTextImage(assetPath: guide.mistakesImage, height: 240),
        ],
        ),
      ),
    );
  }
}

class _TextAboveImageCard extends StatelessWidget {
  const _TextAboveImageCard({
    required this.guide,
    required this.title,
    required this.body,
    required this.imageAsset,
  });

  final FlowerTransplantGuide guide;
  final String title;
  final String body;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      padding: const EdgeInsets.all(12),
      child: wrapGuideDetailCard(
        context: context,
        title: title,
        summary: body,
        details: guide.detailsFor(title),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              body,
              style: t.bodySmall?.copyWith(
                height: 1.35,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            const SizedBox(height: 10),
            _UnderTextImage(assetPath: imageAsset, height: 220),
          ],
        ),
      ),
    );
  }
}

class _ChecklistImageCard extends StatelessWidget {
  const _ChecklistImageCard({
    required this.guide,
    required this.title,
    required this.items,
    required this.imageAsset,
  });

  final FlowerTransplantGuide guide;
  final String title;
  final List<String> items;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      padding: const EdgeInsets.all(12),
      child: wrapGuideDetailCard(
        context: context,
        title: title,
        summary: items.take(2).join(' '),
        details: guide.detailsFor(title),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 8),
            _BulletList(items: items),
            const SizedBox(height: 10),
            _UnderTextImage(assetPath: imageAsset, height: 220),
          ],
        ),
      ),
    );
  }
}

class _BulletList extends StatelessWidget {
  const _BulletList({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final item in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: Color(PlantDetailDesign.primaryGreen),
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item,
                    style: t.bodySmall?.copyWith(
                      height: 1.35,
                      color: const Color(PlantDetailDesign.textPrimary),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

String _transplantSummary(FlowerTransplantGuide guide, String title) {
  final v = guide.vegetable;
  if (v == null) {
    return switch (title) {
      'Afharden' => 'Laat de plant wennen aan buiten.',
      'Beste locatie' => 'Kies de juiste plek voor optimale groei.',
      'Bescherming na uitplanten' =>
        'Bescherm jonge planten tegen weersinvloeden en plagen.',
      _ => title,
    };
  }
  return flowerCardSummaryFor(
    tab: 'transplant',
    title: title,
    vegetable: v,
  );
}

class _UnderTextImage extends StatelessWidget {
  const _UnderTextImage({
    required this.assetPath,
    this.height = 280,
  });

  final String assetPath;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        alignment: Alignment.center,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 28),
        ),
      ),
    );
  }
}
