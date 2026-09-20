import 'package:flutter/material.dart';

import '../../data/flower_combinations_guide_data.dart';
import '../../data/plant_combination_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

/// Flower-only Combinaties-layout: tekst boven, chips en afbeelding eronder
/// (zoals Problemen). Geen moestuin-combinatieteelt layout met detailnavigatie.
class FlowerCombinationsGuideView extends StatelessWidget {
  const FlowerCombinationsGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantCombinationGuide guide;

  static const _wideBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final g = flowerCombinationsGuideForVegetable(vegetable);
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < g.sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _SectionCard(section: g.sections[i], wide: wide),
        ],
        const SizedBox(height: 12),
        _TipCard(tip: g.tip, imageAsset: g.tipImage),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.wide});

  final FlowerCombinationSection section;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: section.title,
        summary: section.body,
        details: section.details,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              section.title,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              section.body,
              style: t.bodySmall?.copyWith(
                height: 1.4,
                color: const Color(PlantDetailDesign.textPrimary),
              ),
            ),
            if (section.bullets.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final bullet in section.bullets)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '\u2022  ',
                        style: t.bodySmall?.copyWith(
                          height: 1.4,
                          fontWeight: FontWeight.w800,
                          color: const Color(PlantDetailDesign.primaryGreen),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          bullet,
                          style: t.bodySmall?.copyWith(
                            height: 1.4,
                            color: const Color(PlantDetailDesign.textPrimary),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            if (section.chips.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ChipRow(chips: section.chips, wide: wide),
            ],
            if (section.benefits.isNotEmpty) ...[
              const SizedBox(height: 12),
              _BenefitsBox(benefits: section.benefits),
            ],
            if (section.imageAsset != null) ...[
              const SizedBox(height: 12),
              _UnderTextImage(
                assetPath: section.imageAsset!,
                height: wide ? 160 : 140,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.chips, required this.wide});

  final List<FlowerCombinationChip> chips;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    if (wide && chips.length <= 4) {
      return IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            for (var i = 0; i < chips.length; i++) ...[
              if (i > 0) const SizedBox(width: 8),
              Expanded(child: _ChipTile(chip: chips[i])),
            ],
          ],
        ),
      );
    }

    return SizedBox(
      height: 96,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: chips.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return SizedBox(
            width: 88,
            child: _ChipTile(chip: chips[index]),
          );
        },
      ),
    );
  }
}

class _ChipTile extends StatelessWidget {
  const _ChipTile({required this.chip});

  final FlowerCombinationChip chip;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            chip.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              fontSize: 10,
              height: 1.15,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _UnderTextImage(assetPath: chip.imageAsset, height: 52),
          ),
        ],
      ),
    );
  }
}

class _BenefitsBox extends StatelessWidget {
  const _BenefitsBox({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F8E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Voordelen',
            style: t.labelLarge?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 8),
          for (var i = 0; i < benefits.length; i++)
            Padding(
              padding: EdgeInsets.only(
                bottom: i == benefits.length - 1 ? 0 : 6,
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: Color(PlantDetailDesign.primaryGreen),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      benefits[i],
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
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip, required this.imageAsset});

  final String tip;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tip',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            tip,
            style: t.bodySmall?.copyWith(
              height: 1.4,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
          const SizedBox(height: 12),
          _UnderTextImage(assetPath: imageAsset, height: 110),
        ],
      ),
    );
  }
}

class _UnderTextImage extends StatelessWidget {
  const _UnderTextImage({
    required this.assetPath,
    this.height = 140,
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
