import 'package:flutter/material.dart';

import '../../data/flower_overview_data.dart';
import '../../data/mushroom_overview_data.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_search_filters.dart';
import '../../models/vegetable.dart';
import 'flower_overview_tab.dart';
import 'mushroom_overview_tab.dart';
import 'overview_illustrations.dart';
import 'plant_detail_widgets.dart';

abstract final class _StatTileColors {
  static const standplaats = Color(0xFFFFF3E0);
  static const water = Color(0xFFE3F2FD);
  static const moeilijkheid = Color(0xFFF3E5F5);
  static const levensduur = Color(0xFFE8F5E9);
  static const voeding = Color(0xFFFFF9C4);
  static const locatie = Color(0xFFE8F5E9);
  static const groeiCard = Color(0xFFE8F5E9);
  static const ruimteCard = Color(0xFFFFF8E1);
  static const oogstCard = Color(0xFFE3F2FD);
}

class PlantOverviewTab extends StatelessWidget {
  const PlantOverviewTab({
    super.key,
    required this.layout,
    this.vegetable,
    this.useNestedScroll = false,
  });

  final PlantEncyclopediaLayout layout;
  final Vegetable? vegetable;
  final bool useNestedScroll;

  static const _tripleBreakpoint = 380.0;

  @override
  Widget build(BuildContext context) {
    final v = vegetable;
    if (v != null && kMushroomPlantIds.contains(v.id)) {
      return MushroomOverviewTab(
        vegetable: v,
        layout: buildMushroomOverviewLayout(v),
        useNestedScroll: useNestedScroll,
      );
    }

    if (v != null && isFlowerGuidePlant(v.id)) {
      return FlowerOverviewTab(
        vegetable: v,
        layout: buildFlowerOverviewLayout(v),
        useNestedScroll: useNestedScroll,
      );
    }

    const padding = EdgeInsets.fromLTRB(16, 0, 16, 32);
    final children = _vegetableContent(context);

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

  List<Widget> _vegetableContent(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    final stackTriple = width < _tripleBreakpoint;

    return [
      PlantMonthTimelineRow(timeline: layout.sowing),
      const SizedBox(height: 4),
      GridView.count(
        crossAxisCount: 2,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        childAspectRatio: 2.1,
        children: [
          PlantStatTile(
            imageAsset: OverviewAssets.standplaats,
            label: 'Standplaats',
            value: layout.standplaats,
            backgroundColor: _StatTileColors.standplaats,
          ),
          PlantStatTile(
            imageAsset: OverviewAssets.water,
            label: 'Water',
            value: layout.water,
            backgroundColor: _StatTileColors.water,
          ),
          PlantStatTile(
            imageAsset: OverviewAssets.moeilijkheid,
            label: 'Moeilijkheid',
            value: layout.difficulty,
            backgroundColor: _StatTileColors.moeilijkheid,
          ),
          PlantStatTile(
            imageAsset: OverviewAssets.levensduur,
            label: 'Levensduur',
            value: layout.lifespan,
            backgroundColor: _StatTileColors.levensduur,
          ),
          PlantStatTile(
            imageAsset: OverviewAssets.voeding,
            label: 'Voeding',
            value: layout.voeding,
            backgroundColor: _StatTileColors.voeding,
          ),
          PlantStatTile(
            imageAsset: OverviewAssets.locatie,
            label: 'Locatie',
            value: layout.locatieOutdoor,
            subtitle: layout.locatieContainer,
            backgroundColor: _StatTileColors.locatie,
          ),
        ],
      ),
      const SizedBox(height: 12),
      if (stackTriple)
        Column(
          children: [
            _groeiCard(),
            const SizedBox(height: 8),
            _ruimteCard(),
            const SizedBox(height: 8),
            _oogstTijdCard(),
          ],
        )
      else
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _groeiCard()),
              const SizedBox(width: 8),
              Expanded(child: _ruimteCard()),
              const SizedBox(width: 8),
              Expanded(child: _oogstTijdCard()),
            ],
          ),
        ),
      const SizedBox(height: 12),
      PlantYieldCard(
        level: layout.opbrengstLevel,
        detail: layout.opbrengstDetail,
        imageAsset: OverviewAssets.opbrengst,
      ),
      const SizedBox(height: 12),
      PlantOverviewMomentsStrip(
        sowing: layout.sowing,
        planting: layout.planting,
        harvest: layout.harvest,
        bloom: layout.bloom,
        sowingIcon: OverviewAssets.zaaien,
        plantingIcon: OverviewAssets.uitplanten,
        harvestIcon: OverviewAssets.oogsten,
        bloomIcon: OverviewAssets.bloei,
      ),
      if (layout.keyPoints.isNotEmpty) ...[
        const SizedBox(height: 12),
        PlantOverviewSummaryCard(
          points: layout.keyPoints,
          imageAsset: OverviewAssets.samenvatting,
        ),
      ] else if (layout.summaryShort.trim().isNotEmpty) ...[
        const SizedBox(height: 12),
        PlantSummaryCard(
          text: layout.summaryShort,
          imageAsset: OverviewAssets.samenvatting,
        ),
      ],
      if (layout.didYouKnow.trim().isNotEmpty) ...[
        const SizedBox(height: 12),
        PlantDidYouKnowCard(
          text: layout.didYouKnow,
          imageAsset: OverviewAssets.weetjes,
        ),
      ],
    ];
  }

  Widget _groeiCard() {
    return PlantSpecMiniCard(
      title: 'Groei & formaat',
      imageAsset: OverviewAssets.groei,
      backgroundColor: _StatTileColors.groeiCard,
      compact: true,
      lines: [
        ('Hoogte', layout.height),
        ('Breedte', layout.width),
        ('Groeiwijze', layout.growthHabit),
      ],
    );
  }

  Widget _ruimteCard() {
    return PlantSpecMiniCard(
      title: 'Ruimte',
      imageAsset: OverviewAssets.ruimte,
      backgroundColor: _StatTileColors.ruimteCard,
      compact: true,
      lines: [
        ('Plantafstand', layout.plantSpacing),
        ('Rijafstand', layout.rowSpacing),
      ],
    );
  }

  Widget _oogstTijdCard() {
    return PlantSpecMiniCard(
      title: 'Tijd tot oogst',
      imageAsset: OverviewAssets.oogstTijd,
      backgroundColor: _StatTileColors.oogstCard,
      compact: true,
      lines: [
        ('Eerste oogst', layout.firstHarvest),
        ('Oogstperiode', layout.harvestPeriod),
      ],
    );
  }
}
