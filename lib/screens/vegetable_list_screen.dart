import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_season_status.dart';
import '../data/plant_search_filters.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../widgets/plant_browse_tile.dart';
import '../widgets/plant_search_scroll_layout.dart';
import 'pest_guide_screen.dart';
import 'vegetable_detail_screen.dart';

/// Zoeken-tab: scrollbare plantenlijst (1 kolom) met plagen-knop (FAB).
class VegetableListScreen extends StatefulWidget {
  const VegetableListScreen({
    super.key,
    required this.repository,
    this.initialGroupId,
    this.gardenStore,
    this.profileStore,
    this.scanPrefs,
    this.embedded = false,
  });

  final VegetableRepository repository;
  final String? initialGroupId;
  final MyGardenStore? gardenStore;
  final GardenProfileStore? profileStore;
  final GardenScanPrefsStore? scanPrefs;
  final bool embedded;

  @override
  State<VegetableListScreen> createState() => _VegetableListScreenState();
}

class _VegetableListScreenState extends State<VegetableListScreen> {
  final TextEditingController _search = TextEditingController();
  PlantSearchCriteria _criteria = const PlantSearchCriteria();
  List<Vegetable> _visible = const [];
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGroupId;
    if (initial != null) {
      _criteria = PlantSearchCriteria(
        browse: browseKindForGroupId(initial),
      );
    }
    widget.gardenStore?.addListener(_onGardenChanged);
    _rebuildVisible();
    _search.addListener(_onSearchTextChanged);
  }

  void _onGardenChanged() {
    if (mounted) _rebuildVisible();
  }

  void _onSearchTextChanged() {
    final q = _search.text;
    if (q == _lastQuery) return;
    _lastQuery = q;
    _rebuildVisible();
  }

  void _rebuildVisible() {
    final next = searchFilteredPlants(
      repository: widget.repository,
      criteria: _criteria,
      searchQuery: _search.text,
    );
    final activeOrUpcoming = <Vegetable>[];
    final seasonEnded = <Vegetable>[];
    for (final v in next) {
      final season = plantingSeasonStatusFor(
        v.id,
        vegetable: v,
      );
      if (season.isSeasonEnded) {
        seasonEnded.add(v);
      } else {
        activeOrUpcoming.add(v);
      }
    }
    final ordered = [...activeOrUpcoming, ...seasonEnded];
    if (!mounted) return;
    setState(() => _visible = ordered);
  }

  @override
  void dispose() {
    widget.gardenStore?.removeListener(_onGardenChanged);
    _search.removeListener(_onSearchTextChanged);
    _search.dispose();
    super.dispose();
  }

  void _openPestGuide() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PestGuideScreen(
          initialQuery: _search.text.trim().isEmpty ? null : _search.text.trim(),
        ),
      ),
    );
  }

  void _openDetail(Vegetable v) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(
          vegetable: v,
          gardenStore: widget.gardenStore,
          repository: widget.repository,
          profileStore: widget.gardenStore?.contains(v.id) == true
              ? widget.profileStore
              : null,
          scanPrefs: widget.scanPrefs,
        ),
      ),
    );
  }

  Future<void> _toggleInGarden(Vegetable v) async {
    final store = widget.gardenStore;
    if (store == null) return;

    if (store.contains(v.id)) {
      await store.remove(v.id);
      await widget.profileStore?.removeProfile(v.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${v.nameNl} uit Mijn moestuin')),
      );
      return;
    }

    await widget.profileStore?.ensureProfile(v.id);
    await store.add(v.id);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${v.nameNl} toegevoegd aan Mijn moestuin')),
    );
  }

  void _resetFilters() {
    setState(() => _criteria = const PlantSearchCriteria());
    _rebuildVisible();
  }

  void _onCriteriaChanged(PlantSearchCriteria next) {
    setState(() => _criteria = next);
    _rebuildVisible();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final veggies = _visible;
    final hasActiveFilters = _criteria.activeFilterCount > 0;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Zoeken'),
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
        actions: [
          if (hasActiveFilters)
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Wis filters'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openPestGuide,
        tooltip: 'Plagen opzoeken',
        child: const Icon(Icons.pest_control),
      ),
      body: PlantSearchScrollLayout(
        searchController: _search,
        onSearchChanged: (_) {},
        criteria: _criteria,
        onCriteriaChanged: _onCriteriaChanged,
        countLabel: '${veggies.length} soort(en)',
        searchFillColor: Color.lerp(cs.surface, cs.primary, 0.08),
        slivers: [
          if (veggies.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Geen resultaten.\nPas zoekterm of filters aan.',
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodyLarge?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final v = veggies[index];
                  final inGarden =
                      widget.gardenStore?.contains(v.id) ?? false;
                  final season = plantingSeasonStatusFor(
                    v.id,
                    vegetable: v,
                  );
                  return PlantBrowseTile(
                    key: ValueKey(v.id),
                    vegetable: v,
                    inGarden: inGarden,
                    dimmed: season.isSeasonEnded,
                    showDivider: index < veggies.length - 1,
                    seasonStatus: season.phase ==
                            PlantingSeasonPhase.noCalendar
                        ? null
                        : season,
                    onOpenDetail: () => _openDetail(v),
                    onToggleGarden: widget.gardenStore != null
                        ? () => _toggleInGarden(v)
                        : null,
                  );
                },
                childCount: veggies.length,
              ),
            ),
        ],
      ),
    );
  }
}
