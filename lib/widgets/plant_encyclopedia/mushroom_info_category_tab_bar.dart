import 'package:flutter/material.dart';

import '../../data/mushroom_info_layout.dart';
import '../../data/plant_encyclopedia_layout.dart';

/// Horizontale tab-balk voor Paddenstoel Info (zelfde stijl als Plant Info).
class MushroomInfoCategoryTabBar extends StatelessWidget {
  const MushroomInfoCategoryTabBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    this.scrollController,
  });

  final List<MushroomInfoCategoryContent> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ScrollController? scrollController;

  static const tabWidth = 82.0;
  static const tabSpacing = 8.0;
  static const barHeight = 104.0;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: barHeight,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final cat = categories[index];
          final active = selectedIndex >= 0 && index == selectedIndex;
          return Padding(
            padding: EdgeInsets.only(
              right: index < categories.length - 1 ? tabSpacing : 0,
            ),
            child: _MushroomInfoCategoryTab(
              label: cat.id.label,
              categoryId: cat.id,
              active: active,
              onTap: () => onSelected(index),
            ),
          );
        },
      ),
    );
  }
}

class _MushroomInfoCategoryTab extends StatelessWidget {
  const _MushroomInfoCategoryTab({
    required this.label,
    required this.categoryId,
    required this.active,
    required this.onTap,
  });

  final String label;
  final MushroomInfoCategoryId categoryId;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
          fontSize: 11,
          fontWeight: active ? FontWeight.w700 : FontWeight.w600,
          color: active
              ? const Color(PlantDetailDesign.primaryGreen)
              : const Color(PlantDetailDesign.textPrimary),
        );

    return SizedBox(
      width: MushroomInfoCategoryTabBar.tabWidth,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              color: active
                  ? const Color(0xFFF0FDF4)
                  : const Color(PlantDetailDesign.card),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: active
                    ? const Color(PlantDetailDesign.primaryGreen)
                        .withValues(alpha: 0.4)
                    : const Color(PlantDetailDesign.border),
                width: active ? 1.5 : 1,
              ),
              boxShadow: active
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x0A000000),
                        blurRadius: 6,
                        offset: Offset(0, 2),
                      ),
                    ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 44,
                  child: Center(
                    child: MushroomInfoCategoryTabIcon(id: categoryId),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: textStyle,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Watercolor pictogrammen per paddenstoel-info-onderwerp (zelfde stijl als plant-tabs).
class MushroomInfoCategoryTabIcon extends StatelessWidget {
  const MushroomInfoCategoryTabIcon({super.key, required this.id});

  final MushroomInfoCategoryId id;

  static const _assetRoot = 'assets/images/mushroom_info_tabs';

  static const _tabAssets = {
    MushroomInfoCategoryId.substraat: '$_assetRoot/tab_substraat.png',
    MushroomInfoCategoryId.enten: '$_assetRoot/tab_enten.png',
    MushroomInfoCategoryId.kolonisatie: '$_assetRoot/tab_kolonisatie.png',
    MushroomInfoCategoryId.vruchtvorming: '$_assetRoot/tab_vruchtvorming.png',
    MushroomInfoCategoryId.omgeving: '$_assetRoot/tab_omgeving.png',
    MushroomInfoCategoryId.water: '$_assetRoot/tab_water.png',
    MushroomInfoCategoryId.groei: '$_assetRoot/tab_groei.png',
    MushroomInfoCategoryId.oogsten: '$_assetRoot/tab_oogsten.png',
    MushroomInfoCategoryId.flushes: '$_assetRoot/tab_flushes.png',
    MushroomInfoCategoryId.bewaren: '$_assetRoot/tab_bewaren.png',
    MushroomInfoCategoryId.problemen: '$_assetRoot/tab_problemen.png',
    MushroomInfoCategoryId.weetjes: '$_assetRoot/tab_weetjes.png',
  };

  @override
  Widget build(BuildContext context) {
    final asset = _tabAssets[id];
    if (asset == null) {
      return const Icon(
        Icons.eco_rounded,
        size: 30,
        color: Color(PlantDetailDesign.primaryGreen),
      );
    }

    return Image.asset(
      asset,
      width: 46,
      height: 44,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.high,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => const Icon(
        Icons.eco_rounded,
        size: 30,
        color: Color(PlantDetailDesign.primaryGreen),
      ),
    );
  }
}

class PinnedMushroomCategoryTabBarDelegate extends SliverPersistentHeaderDelegate {
  PinnedMushroomCategoryTabBarDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.scrollController,
    required this.onSelected,
  });

  final List<MushroomInfoCategoryContent> categories;
  final int selectedIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelected;

  @override
  double get minExtent => MushroomInfoCategoryTabBar.barHeight;

  @override
  double get maxExtent => MushroomInfoCategoryTabBar.barHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Colors.white,
      child: MushroomInfoCategoryTabBar(
        categories: categories,
        selectedIndex: selectedIndex,
        scrollController: scrollController,
        onSelected: onSelected,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant PinnedMushroomCategoryTabBarDelegate oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.categories != categories;
  }
}
