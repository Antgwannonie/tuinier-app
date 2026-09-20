import 'package:flutter/material.dart';

import '../../data/plant_encyclopedia_layout.dart';
import 'plant_detail_widgets.dart';

/// Horizontale koppen-balk voor Plant Info (tegel-knoppen met icoon + label).
class PlantInfoCategoryTabBar extends StatelessWidget {
  const PlantInfoCategoryTabBar({
    super.key,
    required this.categories,
    required this.selectedIndex,
    required this.onSelected,
    this.scrollController,
    this.isFlower = false,
  });

  final List<PlantInfoCategoryContent> categories;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final ScrollController? scrollController;
  final bool isFlower;

  /// Geen actieve tegel wanneer [selectedIndex] < 0.

  static const tabWidth = 82.0;
  static const tabSpacing = 8.0;
  static const barHeight = 98.0;

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
            child: _PlantInfoCategoryTab(
              label: cat.id.labelForPlant(isFlower: isFlower),
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

class _PlantInfoCategoryTab extends StatelessWidget {
  const _PlantInfoCategoryTab({
    required this.label,
    required this.categoryId,
    required this.active,
    required this.onTap,
  });

  final String label;
  final PlantInfoCategoryId categoryId;
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
      width: PlantInfoCategoryTabBar.tabWidth,
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
                    child: PlantInfoCategoryTabIcon(id: categoryId),
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

/// Watercolor pictogrammen per plantinfo-onderwerp.
class PlantInfoCategoryTabIcon extends StatelessWidget {
  const PlantInfoCategoryTabIcon({super.key, required this.id});

  final PlantInfoCategoryId id;

  static const _tabAssets = {
    PlantInfoCategoryId.zaaien:
        'assets/images/plant_info_tabs/tab_zaaien.png',
    PlantInfoCategoryId.uitplanten:
        'assets/images/plant_info_tabs/tab_uitplanten.png',
    PlantInfoCategoryId.standplaats:
        'assets/images/plant_info_tabs/tab_standplaats.png',
    PlantInfoCategoryId.water: 'assets/images/plant_info_tabs/tab_water.png',
    PlantInfoCategoryId.voeding:
        'assets/images/plant_info_tabs/tab_voeding.png',
    PlantInfoCategoryId.groei: 'assets/images/plant_info_tabs/tab_groei.png',
    PlantInfoCategoryId.bloei: 'assets/images/plant_info_tabs/tab_bloei.png',
    PlantInfoCategoryId.oogsten:
        'assets/images/plant_info_tabs/tab_oogsten.png',
    PlantInfoCategoryId.verzorging:
        'assets/images/plant_info_tabs/tab_verzorging.png',
    PlantInfoCategoryId.problemen:
        'assets/images/plant_info_tabs/tab_problemen.png',
    PlantInfoCategoryId.combinatieteelt:
        'assets/images/plant_info_tabs/tab_combinatie.png',
    PlantInfoCategoryId.weetjes:
        'assets/images/plant_info_tabs/tab_weetjes.png',
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

/// Blijft plakken bij scrollen in het overzicht.
class PinnedCategoryTabBarDelegate extends SliverPersistentHeaderDelegate {
  PinnedCategoryTabBarDelegate({
    required this.categories,
    required this.selectedIndex,
    required this.scrollController,
    required this.onSelected,
    this.isFlower = false,
  });

  final List<PlantInfoCategoryContent> categories;
  final int selectedIndex;
  final ScrollController scrollController;
  final ValueChanged<int> onSelected;
  final bool isFlower;

  @override
  double get minExtent => PlantInfoCategoryTabBar.barHeight;

  @override
  double get maxExtent => PlantInfoCategoryTabBar.barHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Colors.white,
      child: PlantInfoCategoryTabBar(
        categories: categories,
        selectedIndex: selectedIndex,
        scrollController: scrollController,
        onSelected: onSelected,
        isFlower: isFlower,
      ),
    );
  }

  @override
  bool shouldRebuild(covariant PinnedCategoryTabBarDelegate oldDelegate) {
    return oldDelegate.selectedIndex != selectedIndex ||
        oldDelegate.categories != categories ||
        oldDelegate.isFlower != isFlower;
  }
}

class PlantInfoBlockCard extends StatelessWidget {
  const PlantInfoBlockCard({super.key, required this.block});

  final PlantInfoBlock block;

  @override
  Widget build(BuildContext context) {
    return PlantDetailCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                block.isWarning
                    ? Icons.warning_amber_outlined
                    : Icons.info_outline,
                size: 18,
                color: block.isWarning
                    ? const Color(PlantDetailDesign.warning)
                    : const Color(PlantDetailDesign.primaryGreen),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  block.title,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            block.body,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  height: 1.45,
                  color: const Color(PlantDetailDesign.textPrimary),
                ),
          ),
          if (block.timeline != null && block.timeline!.months.isNotEmpty) ...[
            const SizedBox(height: 14),
            PlantMonthTimelineRow(timeline: block.timeline!, compact: true),
          ],
          if (block.suitability != null && block.suitability!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...block.suitability!.entries.map((e) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    plantSuitabilityIcon(e.value),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        e.key,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                    Text(
                      e.value.label,
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                            color: const Color(PlantDetailDesign.textSecondary),
                          ),
                    ),
                  ],
                ),
              );
            }),
          ],
          if (block.tags.isNotEmpty) ...[
            const SizedBox(height: 12),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: block.tags.map((tag) {
                final good = block.title.toLowerCase().contains('goede');
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: (good
                            ? const Color(PlantDetailDesign.success)
                            : const Color(0xFFEF4444))
                        .withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    tag,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: good
                              ? const Color(PlantDetailDesign.primaryGreen)
                              : const Color(0xFFB91C1C),
                        ),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
