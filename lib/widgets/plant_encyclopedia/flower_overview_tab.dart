import 'package:flutter/material.dart';

import '../../data/flower_overview_data.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../models/vegetable.dart';
import 'flower_overview_illustrations.dart';
import 'overview_illustrations.dart';
import 'plant_detail_widgets.dart';

abstract final class _FlowerColors {
  static const standplaats = Color(0xFFFFF3E0);
  static const water = Color(0xFFE3F2FD);
  static const moeilijkheid = Color(0xFFF3E5F5);
  static const levensduur = Color(0xFFE8F5E9);
  static const size = Color(0xFFE8F5E9);
  static const bloom = Color(0xFFF3E5F5);
  static const tip = Color(0xFFFFF8E7);
  static const star = Color(0xFF7B1FA2);
}

class FlowerOverviewTab extends StatelessWidget {
  const FlowerOverviewTab({
    super.key,
    required this.vegetable,
    required this.layout,
    this.useNestedScroll = false,
  });

  final Vegetable vegetable;
  final FlowerOverviewLayout layout;
  final bool useNestedScroll;

  static const _wideBreakpoint = 520.0;

  List<Widget> _content(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final wide = width >= _wideBreakpoint;

    return [
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.zero,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        // Hoger dan 2.0 zodat value + subtitle volledig in gelijke cards past.
        childAspectRatio: 1.45,
        children: [
          PlantStatTile(
            imageAsset: OverviewAssets.standplaats,
            label: 'Standplaats',
            value: layout.standplaats,
            subtitle: layout.standplaatsSubtitle,
            backgroundColor: _FlowerColors.standplaats,
            valueMaxLines: 2,
            subtitleMaxLines: 3,
            expandToFill: true,
          ),
          PlantStatTile(
            imageAsset: OverviewAssets.water,
            label: 'Water',
            value: layout.water,
            subtitle: layout.waterSubtitle,
            backgroundColor: _FlowerColors.water,
            valueMaxLines: 2,
            subtitleMaxLines: 3,
            expandToFill: true,
          ),
          PlantStatTile(
            imageAsset: OverviewAssets.moeilijkheid,
            label: 'Moeilijkheid',
            value: layout.difficulty,
            subtitle: layout.difficultySubtitle,
            backgroundColor: _FlowerColors.moeilijkheid,
            valueMaxLines: 2,
            subtitleMaxLines: 3,
            expandToFill: true,
          ),
          PlantStatTile(
            imageAsset: OverviewAssets.levensduur,
            label: 'Levensduur',
            value: layout.lifespan,
            subtitle: layout.lifespanSubtitle,
            backgroundColor: _FlowerColors.levensduur,
            valueMaxLines: 2,
            subtitleMaxLines: 3,
            expandToFill: true,
          ),
        ],
      ),
      const SizedBox(height: 12),
      PlantSummaryCard(
        text: layout.summary,
        imageAsset: OverviewAssets.samenvatting,
      ),
      const SizedBox(height: 12),
      if (wide)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _sizeCard()),
              const SizedBox(width: 8),
              Expanded(child: _bloomCard()),
            ],
          ),
        )
      else ...[
        _sizeCard(),
        const SizedBox(height: 8),
        _bloomCard(),
      ],
      const SizedBox(height: 12),
      if (wide)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _whyPlantCard()),
              const SizedBox(width: 8),
              Expanded(child: _natureValueCard()),
            ],
          ),
        )
      else ...[
        _whyPlantCard(),
        const SizedBox(height: 8),
        _natureValueCard(),
      ],
      const SizedBox(height: 12),
      _momentsCard(),
      const SizedBox(height: 12),
      if (wide)
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _traitsCard()),
              const SizedBox(width: 8),
              Expanded(child: _weatherCard()),
            ],
          ),
        )
      else ...[
        _traitsCard(),
        const SizedBox(height: 8),
        _weatherCard(),
      ],
      const SizedBox(height: 12),
      _suitableCard(),
      const SizedBox(height: 12),
      _featuresCard(),
      if (layout.tip.trim().isNotEmpty) ...[
        const SizedBox(height: 12),
        _tipBar(),
      ],
    ];
  }

  Widget _whyPlantCard() {
    return PlantOverviewSectionCard(
      title: 'Waarom deze bloem planten?',
      imageAsset: FlowerOverviewAssets.whyPlant,
      children: [
        for (var i = 0; i < layout.whyPlantReasons.length; i++) ...[
          if (i > 0) const SizedBox(height: 10),
          _ReasonRow(reason: layout.whyPlantReasons[i]),
        ],
      ],
    );
  }

  Widget _natureValueCard() {
    final r = layout.pollinatorRatings;
    return PlantOverviewSectionCard(
      title: 'Waarde voor de natuur',
      imageAsset: FlowerOverviewAssets.natureValue,
      children: [
        _PollinatorRow(
          asset: FlowerOverviewAssets.bee,
          label: 'Bijen',
          stars: r.bees,
        ),
        const SizedBox(height: 8),
        _PollinatorRow(
          asset: FlowerOverviewAssets.butterfly,
          label: 'Vlinders',
          stars: r.butterflies,
        ),
        const SizedBox(height: 8),
        _PollinatorRow(
          asset: FlowerOverviewAssets.bumblebee,
          label: 'Hommels',
          stars: r.bumblebees,
        ),
        const SizedBox(height: 8),
        _PollinatorRow(
          asset: FlowerOverviewAssets.hoverfly,
          label: 'Zweefvliegen',
          stars: r.hoverflies,
        ),
      ],
    );
  }

  Widget _sizeCard() {
    return PlantSpecMiniCard(
      title: 'Grootte',
      imageAsset: OverviewAssets.groei,
      backgroundColor: _FlowerColors.size,
      lines: [
        ('Hoogte', layout.height),
        ('Breedte', layout.width),
      ],
    );
  }

  Widget _bloomCard() {
    return PlantSpecMiniCard(
      title: 'Bloei',
      imageAsset: OverviewAssets.bloei,
      backgroundColor: _FlowerColors.bloom,
      lines: [
        ('Periode', layout.bloomPeriod),
        ('Bloeiduur', layout.bloomDuration),
      ],
    );
  }

  Widget _momentsCard() {
    return PlantDetailCard(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PlantDetailSectionTitle(
            title: 'Belangrijkste momenten',
            imageAsset: OverviewAssets.momenten,
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < layout.calendarMoments.length; i++) ...[
            if (i > 0) ...[
              const SizedBox(height: 6),
              const Divider(height: 1, color: Color(PlantDetailDesign.border)),
              const SizedBox(height: 10),
            ],
            _FlowerMomentRow(moment: layout.calendarMoments[i]),
          ],
        ],
      ),
    );
  }

  Widget _traitsCard() {
    return PlantOverviewSectionCard(
      title: 'Bloemkenmerken',
      imageAsset: FlowerOverviewAssets.traits,
      children: [
        Text(
          'Kleur',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(PlantDetailDesign.textPrimary),
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final color in layout.flowerColors)
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(PlantDetailDesign.border),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            const Icon(
              Icons.spa_outlined,
              size: 20,
              color: Color(PlantDetailDesign.primaryGreen),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Geur: ${layout.fragrance}',
                style: const TextStyle(
                  color: Color(PlantDetailDesign.textSecondary),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherCard() {
    return PlantOverviewSectionCard(
      title: 'Weerbestendigheid',
      imageAsset: FlowerOverviewAssets.weather,
      children: [
        _WeatherRow(
          asset: FlowerOverviewAssets.frost,
          label: 'Winterhard',
          positive: layout.winterHardy,
          detail: layout.winterHardyDetail,
        ),
        const SizedBox(height: 10),
        _WeatherRow(
          asset: FlowerOverviewAssets.drought,
          label: 'Droogtebestendig',
          positive: layout.droughtResistant,
          detail: layout.droughtResistantDetail,
        ),
      ],
    );
  }

  Widget _suitableCard() {
    return PlantOverviewSectionCard(
      title: 'Geschikt voor',
      imageAsset: FlowerOverviewAssets.suitable,
      children: [
        LayoutBuilder(
          builder: (context, constraints) {
            final cols = constraints.maxWidth >= 400 ? 3 : 2;
            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              padding: EdgeInsets.zero,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 0.95,
              ),
              itemCount: layout.suitableFor.length,
              itemBuilder: (context, index) {
                final item = layout.suitableFor[index];
                return _SuitableTile(option: item);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _featuresCard() {
    return PlantOverviewSectionCard(
      title: 'Belangrijkste eigenschappen',
      imageAsset: FlowerOverviewAssets.features,
      children: [
        for (var i = 0; i < layout.keyFeatures.length; i++) ...[
          if (i > 0) const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.check_circle_rounded,
                size: 20,
                color: Color(PlantDetailDesign.success),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  layout.keyFeatures[i],
                  style: const TextStyle(
                    color: Color(PlantDetailDesign.textPrimary),
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _tipBar() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _FlowerColors.tip,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFFFE0B2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowerOverviewIcon(
            asset: FlowerOverviewAssets.tip,
            size: 32,
            fallbackIcon: Icons.lightbulb_outline_rounded,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tip',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(PlantDetailDesign.textPrimary),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  layout.tip,
                  style: const TextStyle(
                    color: Color(PlantDetailDesign.textSecondary),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const padding = EdgeInsets.fromLTRB(16, 0, 16, 32);
    final children = _content(context);

    if (useNestedScroll) {
      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: padding,
            sliver: SliverList(
              delegate: SliverChildListDelegate(children),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: padding,
      children: children,
    );
  }
}

class _FlowerMomentRow extends StatelessWidget {
  const _FlowerMomentRow({required this.moment});

  final FlowerCalendarMoment moment;

  @override
  Widget build(BuildContext context) {
    return PlantMomentRow(
      timeline: moment.timeline,
      imageAsset: moment.imageAsset,
      icon: moment.icon,
      iconColor: moment.accentColor,
      accentColor: moment.accentColor,
    );
  }
}

class _ReasonRow extends StatelessWidget {
  const _ReasonRow({required this.reason});

  final FlowerWhyPlantReason reason;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (reason.imageAsset != null)
          FlowerOverviewIcon(asset: reason.imageAsset!, size: 26)
        else
          Icon(
            reason.icon ?? Icons.eco_outlined,
            size: 22,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            reason.label,
            style: const TextStyle(
              color: Color(PlantDetailDesign.textPrimary),
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}

class _PollinatorRow extends StatelessWidget {
  const _PollinatorRow({
    required this.asset,
    required this.label,
    required this.stars,
  });

  final String asset;
  final String label;
  final int stars;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FlowerOverviewIcon(asset: asset, size: 24),
        const SizedBox(width: 8),
        Expanded(
          flex: 2,
          child: Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: List.generate(5, (i) {
              final filled = i < stars;
              return Icon(
                filled ? Icons.star_rounded : Icons.star_outline_rounded,
                size: 16,
                color: filled
                    ? _FlowerColors.star
                    : const Color(PlantDetailDesign.border),
              );
            }),
          ),
        ),
      ],
    );
  }
}

class _WeatherRow extends StatelessWidget {
  const _WeatherRow({
    required this.asset,
    required this.label,
    required this.positive,
    this.detail,
  });

  final String asset;
  final String label;
  final bool positive;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        FlowerOverviewIcon(asset: asset, size: 24),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(PlantDetailDesign.textPrimary),
                ),
              ),
              if (detail != null && detail!.trim().isNotEmpty)
                Text(
                  detail!,
                  style: const TextStyle(
                    color: Color(PlantDetailDesign.textSecondary),
                  ),
                ),
            ],
          ),
        ),
        Icon(
          positive ? Icons.check_circle_rounded : Icons.cancel_outlined,
          size: 20,
          color: positive
              ? const Color(PlantDetailDesign.success)
              : const Color(PlantDetailDesign.textSecondary),
        ),
      ],
    );
  }
}

class _SuitableTile extends StatelessWidget {
  const _SuitableTile({required this.option});

  final FlowerSuitableOption option;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAF8),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(PlantDetailDesign.border)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (option.imageAsset != null)
            FlowerOverviewIcon(asset: option.imageAsset!, size: 32)
          else
            Icon(
              option.icon ?? Icons.yard_outlined,
              size: 28,
              color: const Color(PlantDetailDesign.primaryGreen),
            ),
          const SizedBox(height: 6),
          Text(
            option.label,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(PlantDetailDesign.textPrimary),
            ),
          ),
        ],
      ),
    );
  }
}
