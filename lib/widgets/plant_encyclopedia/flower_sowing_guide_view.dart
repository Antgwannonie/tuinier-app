import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../data/flower_card_summaries.dart';
import '../../data/flower_sowing_guide_data.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_sowing_guide.dart';
import '../../models/vegetable.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';
import 'seasonal_month_calendar.dart';

class FlowerSowingGuideView extends StatelessWidget {
  const FlowerSowingGuideView({
    super.key,
    required this.vegetable,
    required this.layout,
    required this.guide,
  });

  final Vegetable vegetable;
  final PlantEncyclopediaLayout layout;
  final PlantSowingGuide guide;

  static const _twoColBreakpoint = 520.0;
  static const _largeDetailImageSize = 544.0;

  static double _constrainedDetailImageSize(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    return math.min(_largeDetailImageSize, screenWidth * 0.8);
  }

  @override
  Widget build(BuildContext context) {
    final flowerGuide = flowerSowingGuideForVegetable(vegetable);
    final twoCol = MediaQuery.sizeOf(context).width >= _twoColBreakpoint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PlantDetailCard(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: twoCol
              ? Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: wrapGuideDetailCard(
                        context: context,
                        title: 'Binnen zaaien',
                        summary: flowerCardSummaryFor(
                          tab: 'sowing',
                          title: 'Binnen zaaien',
                          vegetable: vegetable,
                        ),
                        details: flowerGuide.indoorDetails,
                        child: SeasonalMonthCalendar(
                          months: flowerGuide.indoorMonths,
                          label: 'Binnen zaaien',
                          compact: true,
                          showTitle: true,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: wrapGuideDetailCard(
                        context: context,
                        title: 'Buiten zaaien',
                        summary: flowerCardSummaryFor(
                          tab: 'sowing',
                          title: 'Buiten zaaien',
                          vegetable: vegetable,
                        ),
                        details: flowerGuide.outdoorDetails,
                        child: SeasonalMonthCalendar(
                          months: flowerGuide.outdoorMonths,
                          label: 'Buiten zaaien',
                          compact: true,
                          showTitle: true,
                        ),
                      ),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    wrapGuideDetailCard(
                      context: context,
                      title: 'Binnen zaaien',
                      summary: flowerCardSummaryFor(
                        tab: 'sowing',
                        title: 'Binnen zaaien',
                        vegetable: vegetable,
                      ),
                      details: flowerGuide.indoorDetails,
                      child: SeasonalMonthCalendar(
                        months: flowerGuide.indoorMonths,
                        label: 'Binnen zaaien',
                        compact: true,
                        showTitle: true,
                      ),
                    ),
                    const SizedBox(height: 8),
                    wrapGuideDetailCard(
                      context: context,
                      title: 'Buiten zaaien',
                      summary: flowerCardSummaryFor(
                        tab: 'sowing',
                        title: 'Buiten zaaien',
                        vegetable: vegetable,
                      ),
                      details: flowerGuide.outdoorDetails,
                      child: SeasonalMonthCalendar(
                        months: flowerGuide.outdoorMonths,
                        label: 'Buiten zaaien',
                        compact: true,
                        showTitle: true,
                      ),
                    ),
                  ],
                ),
        ),
        const SizedBox(height: 12),
        if (twoCol)
          Row(
            children: [
              Expanded(
                child: wrapGuideDetailCard(
                  context: context,
                  title: 'Kiemduur',
                  summary: flowerGuide.kiemduur,
                  details: flowerGuide.kiemduurDetails,
                  child: _GerminationStatCard(
                    label: 'Kiemduur',
                    value: flowerGuide.kiemduur,
                    imageAsset:
                        'assets/images/flower_sowing/flower_sowing_germination.png',
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: wrapGuideDetailCard(
                  context: context,
                  title: 'Kiemtemperatuur',
                  summary: flowerGuide.kiemtemperatuur,
                  details: flowerGuide.kiemtempDetails,
                  child: _GerminationStatCard(
                    label: 'Kiemtemperatuur',
                    value: flowerGuide.kiemtemperatuur,
                    imageAsset:
                        'assets/images/flower_sowing/flower_sowing_temperature.png',
                  ),
                ),
              ),
            ],
          )
        else ...[
          wrapGuideDetailCard(
            context: context,
            title: 'Kiemduur',
            summary: flowerGuide.kiemduur,
            details: flowerGuide.kiemduurDetails,
            child: _GerminationStatCard(
              label: 'Kiemduur',
              value: flowerGuide.kiemduur,
              imageAsset:
                  'assets/images/flower_sowing/flower_sowing_germination.png',
            ),
          ),
          const SizedBox(height: 8),
          wrapGuideDetailCard(
            context: context,
            title: 'Kiemtemperatuur',
            summary: flowerGuide.kiemtemperatuur,
            details: flowerGuide.kiemtempDetails,
            child: _GerminationStatCard(
              label: 'Kiemtemperatuur',
              value: flowerGuide.kiemtemperatuur,
              imageAsset:
                  'assets/images/flower_sowing/flower_sowing_temperature.png',
            ),
          ),
        ],
        const SizedBox(height: 12),
        PlantDetailCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Zaaidetails',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(PlantDetailDesign.primaryGreen),
                    ),
              ),
              const SizedBox(height: 12),
              _SowingDetailsGrid(
                details: flowerGuide.details,
                twoCol: twoCol,
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        PlantDetailCard(
          padding: const EdgeInsets.fromLTRB(12, 14, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Stapsgewijs zaaien',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: const Color(PlantDetailDesign.primaryGreen),
                    ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 130,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: flowerGuide.steps.length,
                  separatorBuilder: (_, __) => Padding(
                    padding: const EdgeInsets.only(top: 36),
                    child: Icon(
                      Icons.arrow_forward_rounded,
                      size: 14,
                      color: const Color(PlantDetailDesign.primaryGreen)
                          .withValues(alpha: 0.5),
                    ),
                  ),
                  itemBuilder: (context, index) {
                    return _SowingStepTile(
                      step: flowerGuide.steps[index],
                      stepNumber: index + 1,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        wrapGuideDetailCard(
          context: context,
          title: 'Veelgemaakte fouten',
          summary: flowerGuide.mistakes.take(2).join(' '),
          details: flowerGuide.mistakesDetails,
          child: _FlowerMistakesCard(
            items: flowerGuide.mistakes,
            imageAsset:
                'assets/images/flower_sowing/flower_sowing_mistakes.png',
          ),
        ),
      ],
    );
  }
}

class _SowingDetailsGrid extends StatelessWidget {
  const _SowingDetailsGrid({
    required this.details,
    required this.twoCol,
  });

  final List<FlowerSowingDetail> details;
  final bool twoCol;

  @override
  Widget build(BuildContext context) {
    if (!twoCol) {
      return Column(
        children: [
          for (var i = 0; i < details.length; i++) ...[
            if (i > 0) const SizedBox(height: 8),
            _SowingDetailCard(detail: details[i]),
          ],
        ],
      );
    }

    final rows = <Widget>[];
    for (var i = 0; i < details.length; i += 2) {
      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: _SowingDetailCard(detail: details[i])),
            if (i + 1 < details.length) ...[
              const SizedBox(width: 8),
              Expanded(child: _SowingDetailCard(detail: details[i + 1])),
            ] else
              const Expanded(child: SizedBox.shrink()),
          ],
        ),
      );
      if (i + 2 < details.length) {
        rows.add(const SizedBox(height: 8));
      }
    }
    return Column(children: rows);
  }
}

class _GerminationStatCard extends StatelessWidget {
  const _GerminationStatCard({
    required this.label,
    required this.value,
    required this.imageAsset,
  });

  final String label;
  final String value;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final imageSize = FlowerSowingGuideView._constrainedDetailImageSize(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 6,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: t.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: t.bodyMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: const Color(PlantDetailDesign.textPrimary),
              height: 1.25,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Image.asset(
              imageAsset,
              width: imageSize,
              height: imageSize,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.eco_outlined,
                size: 48,
                color: Color(PlantDetailDesign.primaryGreen),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SowingDetailCard extends StatelessWidget {
  const _SowingDetailCard({required this.detail});

  final FlowerSowingDetail detail;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final imageSize = FlowerSowingGuideView._constrainedDetailImageSize(context);

    return wrapGuideDetailCard(
      context: context,
      title: detail.label,
      summary: detail.description.isNotEmpty ? detail.description : detail.value,
      details: detail.details,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(PlantDetailDesign.border)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 6,
              offset: Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              detail.label,
              style: t.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              detail.value,
              style: t.bodyMedium?.copyWith(
                fontWeight: FontWeight.w800,
                color: const Color(PlantDetailDesign.textPrimary),
                height: 1.25,
              ),
            ),
            if (detail.description.isNotEmpty) ...[
              const SizedBox(height: 2),
              Text(
                detail.description,
                style: t.bodySmall?.copyWith(
                  fontSize: 11,
                  height: 1.3,
                  color: const Color(PlantDetailDesign.textSecondary),
                ),
              ),
            ],
            const SizedBox(height: 8),
            Center(
              child: Image.asset(
                detail.imageAsset,
                width: imageSize,
                height: imageSize,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.high,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.eco_outlined,
                  size: 48,
                  color: Color(PlantDetailDesign.primaryGreen),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SowingStepTile extends StatelessWidget {
  const _SowingStepTile({
    required this.step,
    required this.stepNumber,
  });

  final FlowerSowingStep step;
  final int stepNumber;

  static const _tileWidth = 88.0;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return SizedBox(
      width: _tileWidth,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.topLeft,
            children: [
              Image.asset(
                step.imageAsset,
                width: _tileWidth,
                height: 56,
                fit: BoxFit.contain,
                filterQuality: FilterQuality.medium,
                errorBuilder: (_, __, ___) => const SizedBox(
                  width: _tileWidth,
                  height: 56,
                  child: Icon(Icons.image_not_supported_outlined, size: 20),
                ),
              ),
              Container(
                width: 18,
                height: 18,
                margin: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Color(PlantDetailDesign.primaryGreen),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  '$stepNumber',
                  style: t.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            step.title,
            textAlign: TextAlign.center,
            style: t.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              fontSize: 10,
              height: 1.2,
              color: const Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowerAssetImage extends StatelessWidget {
  const _FlowerAssetImage({
    required this.assetPath,
    this.aspectRatio = 4 / 3,
  });

  final String assetPath;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Image.asset(
        assetPath,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.medium,
        errorBuilder: (_, __, ___) => const Center(
          child: Icon(Icons.image_not_supported_outlined, size: 28),
        ),
      ),
    );
  }
}

class _FlowerMistakesCard extends StatelessWidget {
  const _FlowerMistakesCard({
    required this.items,
    required this.imageAsset,
  });

  final List<String> items;
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
          _FlowerAssetImage(assetPath: imageAsset, aspectRatio: 16 / 9),
          const SizedBox(height: 10),
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE53935).withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 12,
                      color: Color(0xFFE53935),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      item,
                      style: t.bodySmall?.copyWith(fontSize: 11, height: 1.35),
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
