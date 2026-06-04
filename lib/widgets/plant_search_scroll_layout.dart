import 'package:flutter/material.dart';

import '../data/plant_search_filters.dart';
import 'clearable_search_field.dart';
import 'plant_search_filter_panel.dart';

/// Zoekveld vast bovenaan; filters scrollen mee (geen lege ruimte).
class PlantSearchScrollLayout extends StatelessWidget {
  const PlantSearchScrollLayout({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.criteria,
    required this.onCriteriaChanged,
    required this.slivers,
    this.countLabel,
    this.searchFillColor,
    this.bottomPadding = 88,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final PlantSearchCriteria criteria;
  final ValueChanged<PlantSearchCriteria> onCriteriaChanged;
  final List<Widget> slivers;
  final String? countLabel;
  final Color? searchFillColor;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return CustomScrollView(
      cacheExtent: 320,
      slivers: [
        SliverPersistentHeader(
          pinned: true,
          delegate: _PinnedSearchHeaderDelegate(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ClearableSearchField(
                controller: searchController,
                onChanged: onSearchChanged,
                hintText: 'Zoek op naam, familie of trefwoord…',
                fillColor: searchFillColor ??
                    Color.lerp(cs.surface, cs.primary, 0.08),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: RepaintBoundary(
            child: PlantSearchFilterPanel(
              key: const PageStorageKey<String>('plant_search_filters'),
              criteria: criteria,
              onChanged: onCriteriaChanged,
            ),
          ),
        ),
        if (countLabel != null)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
                countLabel!,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ...slivers,
        SliverPadding(padding: EdgeInsets.only(bottom: bottomPadding)),
      ],
    );
  }
}

class _PinnedSearchHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PinnedSearchHeaderDelegate({required this.child});

  final Widget child;

  static const _height = 64.0;

  @override
  double get minExtent => _height;

  @override
  double get maxExtent => _height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _PinnedSearchHeaderDelegate oldDelegate) =>
      oldDelegate.child != child;
}
