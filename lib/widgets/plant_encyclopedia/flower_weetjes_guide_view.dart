import 'package:flutter/material.dart';

import '../../data/flower_weetjes_guide_data.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_weetjes_guide.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

/// Bloem-specifieke Weetjes-layout in de stijl van de Problemen-tab:
/// introkaart, per sectie een witte kaart met titel, tekst, optionele chips
/// en illustratie, afgesloten met een Tip-kaart.
class FlowerWeetjesGuideView extends StatelessWidget {
  const FlowerWeetjesGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantWeetjesGuide guide;

  static const _wideBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final g = flowerWeetjesGuideForVegetable(vegetable);
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _IntroCard(intro: g.intro),
        for (final section in g.sections) ...[
          const SizedBox(height: 12),
          _SectionCard(section: section, wide: wide),
        ],
        const SizedBox(height: 12),
        _TipCard(tip: g.tip, imageAsset: g.tipImage),
      ],
    );
  }
}

class _IntroCard extends StatelessWidget {
  const _IntroCard({required this.intro});

  final String intro;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Weetjes',
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            intro,
            style: t.bodySmall?.copyWith(
              height: 1.4,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.wide});

  final FlowerWeetjesSection section;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final imageAsset = section.imageAsset;

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
            if (section.chips.isNotEmpty) ...[
              const SizedBox(height: 12),
              _ChipRow(chips: section.chips, wide: wide),
            ],
            if (imageAsset != null) ...[
              const SizedBox(height: 12),
              _UnderTextImage(
                assetPath: imageAsset,
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

  final List<FlowerWeetjesChip> chips;
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

  final FlowerWeetjesChip chip;

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
