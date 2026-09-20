import 'package:flutter/material.dart';

import '../../data/mushroom_overview_data.dart';
import '../../data/plant_bloom_guide.dart';
import '../../data/plant_care_guide.dart';
import '../../data/plant_combination_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../data/plant_growth_guide.dart';
import '../../data/plant_harvest_guide.dart';
import '../../data/plant_location_guide.dart';
import '../../data/plant_nutrition_guide.dart';
import '../../data/plant_problems_guide.dart';
import '../../data/plant_search_filters.dart';
import '../../data/plant_sowing_guide.dart';
import '../../data/plant_transplant_guide.dart';
import '../../data/plant_water_guide.dart';
import '../../data/plant_weetjes_guide.dart';
import '../../models/vegetable.dart';
import 'flower_bloom_guide_view.dart';
import 'flower_care_guide_view.dart';
import 'flower_combinations_guide_view.dart';
import 'flower_growth_guide_view.dart';
import 'flower_location_guide_view.dart';
import 'flower_nutrition_guide_view.dart';
import 'flower_problems_guide_view.dart';
import 'flower_seed_harvest_guide_view.dart';
import 'flower_sowing_guide_view.dart';
import 'flower_transplant_guide_view.dart';
import 'flower_water_guide_view.dart';
import 'flower_weetjes_guide_view.dart';
import 'mushroom_info_tab.dart';
import 'plant_bloom_guide_view.dart';
import 'plant_care_guide_view.dart';
import 'plant_combination_guide_view.dart';
import 'plant_growth_guide_view.dart';
import 'plant_harvest_guide_view.dart';
import 'plant_info_category_tab_bar.dart';
import 'plant_location_guide_view.dart';
import 'plant_nutrition_guide_view.dart';
import 'plant_problems_guide_view.dart';
import 'plant_sowing_guide_view.dart';
import 'plant_transplant_guide_view.dart';
import 'plant_water_guide_view.dart';
import 'plant_weetjes_guide_view.dart';

class PlantInfoTab extends StatefulWidget {
  const PlantInfoTab({
    super.key,
    required this.layout,
    required this.vegetable,
    this.useNestedScroll = false,
  });

  final PlantEncyclopediaLayout layout;
  final Vegetable vegetable;
  final bool useNestedScroll;

  @override
  State<PlantInfoTab> createState() => _PlantInfoTabState();
}

class _PlantInfoTabState extends State<PlantInfoTab> {
  late int _pageIndex;
  final _chipScroll = ScrollController();

  List<PlantInfoCategoryContent> get _categories => widget.layout.categories;

  @override
  void initState() {
    super.initState();
    _pageIndex = 0;
  }

  @override
  void dispose() {
    _chipScroll.dispose();
    super.dispose();
  }

  void _scrollChipsTo(int index) {
    if (!_chipScroll.hasClients) return;
    const itemWidth =
        PlantInfoCategoryTabBar.tabWidth + PlantInfoCategoryTabBar.tabSpacing;
    final viewport = _chipScroll.position.viewportDimension;
    final target = (index * itemWidth) - (viewport - itemWidth) / 2 + 8;
    _chipScroll.animateTo(
      target.clamp(0, _chipScroll.position.maxScrollExtent),
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  void _goToPage(int index) {
    if (index < 0 || index >= _categories.length || index == _pageIndex) {
      return;
    }
    setState(() => _pageIndex = index);
    _scrollChipsTo(index);
  }

  List<PlantInfoBlock> _blocksFor(int index) {
    return _categories[index]
        .blocks
        .where((b) => b.body.trim().isNotEmpty)
        .toList();
  }

  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -280) {
      _goToPage(_pageIndex + 1);
    } else if (velocity > 280) {
      _goToPage(_pageIndex - 1);
    }
  }

  Widget? _guideChildFor(PlantInfoCategoryContent category) {
    switch (category.id) {
      case PlantInfoCategoryId.zaaien:
        final guide = sowingGuideForVegetable(widget.vegetable);
        if (guide.sections.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerSowingGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantSowingGuideView(guide: guide);
      case PlantInfoCategoryId.uitplanten:
        final guide = transplantGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerTransplantGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantTransplantGuideView(guide: guide);
      case PlantInfoCategoryId.standplaats:
        final guide = locationGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerLocationGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantLocationGuideView(guide: guide);
      case PlantInfoCategoryId.water:
        final guide = waterGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerWaterGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantWaterGuideView(guide: guide);
      case PlantInfoCategoryId.voeding:
        final guide = nutritionGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerNutritionGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantNutritionGuideView(guide: guide);
      case PlantInfoCategoryId.groei:
        final guide = growthGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerGrowthGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantGrowthGuideView(guide: guide);
      case PlantInfoCategoryId.bloei:
        final guide = bloomGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerBloomGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantBloomGuideView(guide: guide);
      case PlantInfoCategoryId.oogsten:
        final guide = harvestGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerSeedHarvestGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantHarvestGuideView(guide: guide);
      case PlantInfoCategoryId.verzorging:
        final guide = careGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerCareGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantCareGuideView(guide: guide);
      case PlantInfoCategoryId.problemen:
        final guide = problemsGuideForVegetable(widget.vegetable);
        if (guide.rows.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerProblemsGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantProblemsGuideView(guide: guide);
      case PlantInfoCategoryId.combinatieteelt:
        final guide = combinationGuideForVegetable(widget.vegetable);
        if (guide.sections.isEmpty) return null;
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerCombinationsGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        return PlantCombinationGuideView(guide: guide);
      case PlantInfoCategoryId.weetjes:
        final guide = weetjesGuideForVegetable(widget.vegetable);
        if (isFlowerGuidePlant(widget.vegetable.id)) {
          return FlowerWeetjesGuideView(
            vegetable: widget.vegetable,
            layout: widget.layout,
            guide: guide,
          );
        }
        if (!guide.hasContent) return null;
        return PlantWeetjesGuideView(guide: guide, vegetable: widget.vegetable);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isMushroomVegetable(widget.vegetable)) {
      return MushroomInfoTab(
        vegetable: widget.vegetable,
        useNestedScroll: widget.useNestedScroll,
      );
    }

    if (_categories.isEmpty) {
      return const Center(child: Text('Geen extra info beschikbaar.'));
    }

    final blocks = _blocksFor(_pageIndex);
    final category = _categories[_pageIndex];
    final contentSliver = _contentSliver(category, blocks);

    return GestureDetector(
      onHorizontalDragEnd: _onHorizontalSwipe,
      behavior: HitTestBehavior.deferToChild,
      child: CustomScrollView(
        slivers: [
          if (widget.useNestedScroll)
            SliverOverlapInjector(
              handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
            ),
          SliverPersistentHeader(
            pinned: false,
            floating: false,
            delegate: PinnedCategoryTabBarDelegate(
              categories: _categories,
              selectedIndex: _pageIndex,
              scrollController: _chipScroll,
              onSelected: _goToPage,
              isFlower: isFlowerGuidePlant(widget.vegetable.id),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            sliver: contentSliver,
          ),
        ],
      ),
    );
  }

  Widget _contentSliver(
    PlantInfoCategoryContent category,
    List<PlantInfoBlock> blocks,
  ) {
    final guideChild = _guideChildFor(category);
    if (guideChild != null) {
      return SliverToBoxAdapter(child: guideChild);
    }

    if (blocks.isEmpty) {
      return const SliverToBoxAdapter(
        child: Text(
          'Geen inhoud voor dit onderwerp.',
          style: TextStyle(
            color: Color(PlantDetailDesign.textSecondary),
          ),
        ),
      );
    }

    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final block = blocks[index];
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < blocks.length - 1 ? 12 : 0,
            ),
            child: PlantInfoBlockCard(block: block),
          );
        },
        childCount: blocks.length,
      ),
    );
  }
}
