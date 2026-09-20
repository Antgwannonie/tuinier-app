import 'package:flutter/material.dart';

import '../../data/flower_care_guide_data.dart';
import '../../data/plant_care_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_guide_detail.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

/// Flower-only Verzorging-layout: tekst boven, afbeelding eronder (zoals Uitplanten).
class FlowerCareGuideView extends StatelessWidget {
  const FlowerCareGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantCareGuide guide;

  static const _wideBreakpoint = 520.0;

  @override
  Widget build(BuildContext context) {
    final g = flowerCareGuideForVegetable(
      vegetable: vegetable,
      layout: layout,
    );
    final wide = MediaQuery.sizeOf(context).width >= _wideBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < g.sections.length; i++) ...[
          if (i > 0) const SizedBox(height: 12),
          _SectionCard(section: g.sections[i], wide: wide),
        ],
        const SizedBox(height: 12),
        _MistakesCard(
          mistakes: g.mistakes,
          imageAsset: g.mistakesImage,
        ),
        const SizedBox(height: 12),
        _TipsCard(tips: g.tips, imageAsset: g.tipsImage, details: g.tipsDetails),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.section, required this.wide});

  final FlowerCareSection section;
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
          if (section.chips.isNotEmpty) ...[
            const SizedBox(height: 12),
            _ChipRow(chips: section.chips, wide: wide),
          ],
          const SizedBox(height: 12),
          _UnderTextImage(assetPath: section.imageAsset, height: 140),
        ],
        ),
      ),
    );
  }
}

class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.chips, required this.wide});

  final List<FlowerCareChip> chips;
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

  final FlowerCareChip chip;

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

class _MistakesCard extends StatelessWidget {
  const _MistakesCard({
    required this.mistakes,
    required this.imageAsset,
  });

  final List<FlowerCareMistake> mistakes;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
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
          for (final item in mistakes)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: wrapGuideDetailCard(
                context: context,
                title: item.title,
                summary: item.body,
                details: item.details,
                child: Container(
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
              ),
            ),
          const SizedBox(height: 8),
          _UnderTextImage(assetPath: imageAsset, height: 100),
        ],
      ),
    );
  }
}

class _TipsCard extends StatelessWidget {
  const _TipsCard({
    required this.tips,
    required this.imageAsset,
    this.details = const [],
  });

  final List<String> tips;
  final String imageAsset;
  final List<PlantGuideDetailBlock> details;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return PlantDetailCard(
      child: wrapGuideDetailCard(
        context: context,
        title: 'Verzorgingstips',
        summary: tips.isNotEmpty ? tips.first : '',
        details: details,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Verzorgingstips',
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 10),
            for (final tip in tips)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 20,
                      height: 20,
                      decoration: const BoxDecoration(
                        color: Color(PlantDetailDesign.primaryGreen),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        tip,
                        style: t.bodySmall?.copyWith(
                          height: 1.4,
                          color: const Color(PlantDetailDesign.textPrimary),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 8),
            _UnderTextImage(assetPath: imageAsset, height: 100),
          ],
        ),
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
