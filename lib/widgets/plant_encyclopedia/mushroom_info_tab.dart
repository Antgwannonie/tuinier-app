import 'package:flutter/material.dart';

import '../../data/mushroom_facts_guide.dart';
import '../../data/mushroom_colonization_guide.dart';
import '../../data/mushroom_environment_guide.dart';
import '../../data/mushroom_fruiting_guide.dart';
import '../../data/mushroom_flushes_guide.dart';
import '../../data/mushroom_growth_guide.dart';
import '../../data/mushroom_harvest_guide.dart';
import '../../data/mushroom_inoculation_guide.dart';
import '../../data/mushroom_info_guide.dart';
import '../../data/mushroom_info_layout.dart';
import '../../data/mushroom_problems_guide.dart';
import '../../data/mushroom_storage_guide.dart';
import '../../data/mushroom_substrate_guide.dart';
import '../../data/mushroom_water_guide.dart';
import '../../data/plant_encyclopedia_layout.dart';
import '../../models/vegetable.dart';
import 'mushroom_facts_guide_view.dart';
import 'mushroom_colonization_guide_view.dart';
import 'mushroom_environment_guide_view.dart';
import 'mushroom_fruiting_guide_view.dart';
import 'mushroom_flushes_guide_view.dart';
import 'mushroom_growth_guide_view.dart';
import 'mushroom_harvest_guide_view.dart';
import 'mushroom_inoculation_guide_view.dart';
import 'mushroom_info_category_tab_bar.dart';
import 'mushroom_info_guide_view.dart';
import 'mushroom_substrate_guide_view.dart';
import 'mushroom_problems_guide_view.dart';
import 'mushroom_storage_guide_view.dart';
import 'mushroom_water_guide_view.dart';

/// Paddenstoel Info-tab: 12 eigen onderwerpen, zelfde navigatie als Plant Info.
class MushroomInfoTab extends StatefulWidget {
  const MushroomInfoTab({
    super.key,
    required this.vegetable,
    this.useNestedScroll = false,
  });

  final Vegetable vegetable;
  final bool useNestedScroll;

  @override
  State<MushroomInfoTab> createState() => _MushroomInfoTabState();
}

class _MushroomInfoTabState extends State<MushroomInfoTab> {
  late int _pageIndex;
  final _chipScroll = ScrollController();
  late List<MushroomInfoCategoryContent> _categories;

  @override
  void initState() {
    super.initState();
    _pageIndex = 0;
    _categories = mushroomInfoCategoriesFor(widget.vegetable);
  }

  @override
  void didUpdateWidget(covariant MushroomInfoTab oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vegetable.id != widget.vegetable.id) {
      _categories = mushroomInfoCategoriesFor(widget.vegetable);
      _pageIndex = 0;
    }
  }

  @override
  void dispose() {
    _chipScroll.dispose();
    super.dispose();
  }

  void _scrollChipsTo(int index) {
    if (!_chipScroll.hasClients) return;
    const itemWidth =
        MushroomInfoCategoryTabBar.tabWidth + MushroomInfoCategoryTabBar.tabSpacing;
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

  void _onHorizontalSwipe(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity < -280) {
      _goToPage(_pageIndex + 1);
    } else if (velocity > 280) {
      _goToPage(_pageIndex - 1);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_categories.isEmpty) {
      return const Center(child: Text('Geen paddenstoel-info beschikbaar.'));
    }

    final category = _categories[_pageIndex];
    final guide = category.guide;

    Widget content;
    if (category.id == MushroomInfoCategoryId.substraat) {
      content = MushroomSubstrateGuideView(
        guide: substrateGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.enten) {
      content = MushroomInoculationGuideView(
        guide: inoculationGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.kolonisatie) {
      content = MushroomColonizationGuideView(
        guide: colonizationGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.vruchtvorming) {
      content = MushroomFruitingGuideView(
        guide: fruitingGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.omgeving) {
      content = MushroomEnvironmentGuideView(
        guide: environmentGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.water) {
      content = MushroomWaterGuideView(
        guide: waterGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.groei) {
      content = MushroomGrowthGuideView(
        guide: growthGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.oogsten) {
      content = MushroomHarvestGuideView(
        guide: harvestGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.flushes) {
      content = MushroomFlushesGuideView(
        guide: flushesGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.problemen) {
      content = MushroomProblemsGuideView(
        guide: problemsGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.bewaren) {
      content = MushroomStorageGuideView(
        guide: storageGuideForVegetable(widget.vegetable),
      );
    } else if (category.id == MushroomInfoCategoryId.weetjes) {
      content = MushroomFactsGuideView(
        guide: factsGuideForVegetable(widget.vegetable),
      );
    } else if (guide.hasContent) {
      content = MushroomInfoGuideView(guide: guide);
    } else {
      content = const Text(
        'Geen inhoud voor dit onderwerp.',
        style: TextStyle(
          color: Color(PlantDetailDesign.textSecondary),
        ),
      );
    }

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
            delegate: PinnedMushroomCategoryTabBarDelegate(
              categories: _categories,
              selectedIndex: _pageIndex,
              scrollController: _chipScroll,
              onSelected: _goToPage,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            sliver: SliverToBoxAdapter(child: content),
          ),
        ],
      ),
    );
  }
}
