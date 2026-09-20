import 'package:flutter/material.dart';

import '../data/add_plant_apply.dart';
import '../data/add_plant_wizard_analysis.dart';
import '../data/ai_settings_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_season_activation.dart';
import '../data/planting_season_status.dart';
import '../data/plant_search_filters.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/add_plant_setup_sheet.dart';
import '../widgets/plant_guide_filter_sheet.dart';
import '../widgets/plants_guide_card.dart';
import 'vegetable_detail_screen.dart';

/// Planten-tab: plantengids met raster (zoals referentie-app, tuinier-stijl).
class VegetableListScreen extends StatefulWidget {
  const VegetableListScreen({
    super.key,
    required this.repository,
    this.initialGroupId,
    this.gardenStore,
    this.profileStore,
    this.scanPrefs,
    this.aiSettings,
    this.embedded = false,
  });

  final VegetableRepository repository;
  final String? initialGroupId;
  final MyGardenStore? gardenStore;
  final GardenProfileStore? profileStore;
  final GardenScanPrefsStore? scanPrefs;
  final AiSettingsStore? aiSettings;
  final bool embedded;

  @override
  State<VegetableListScreen> createState() => VegetableListScreenState();
}

class VegetableListScreenState extends State<VegetableListScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  PlantSearchCriteria _criteria = const PlantSearchCriteria();
  List<Vegetable> _visible = const [];
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    final initial = widget.initialGroupId;
    if (initial != null) {
      _criteria = PlantSearchCriteria(
        vegetableGroupIds: {initial},
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

  /// Zoekveld leegmaken en naar boven scrollen (bij verlaten Planten-tab).
  void resetBrowseState() {
    var changed = false;
    if (_search.text.isNotEmpty) {
      _lastQuery = '';
      _search.clear();
      changed = true;
    }
    if (_scrollController.hasClients && _scrollController.offset > 0) {
      _scrollController.jumpTo(0);
    }
    if (changed) _rebuildVisible();
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
      final season = plantingSeasonStatusFor(v.id, vegetable: v);
      if (season.isSeasonEnded) {
        seasonEnded.add(v);
      } else {
        activeOrUpcoming.add(v);
      }
    }
    if (!mounted) return;
    setState(() => _visible = [...activeOrUpcoming, ...seasonEnded]);
  }

  @override
  void dispose() {
    widget.gardenStore?.removeListener(_onGardenChanged);
    _search.removeListener(_onSearchTextChanged);
    _search.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _openFilters() async {
    final next = await showPlantGuideFilterSheet(
      context: context,
      initial: _criteria,
    );
    if (next == null || !mounted) return;
    setState(() => _criteria = next);
    _rebuildVisible();
  }

  void _clearFilters() {
    setState(() => _criteria = const PlantSearchCriteria());
    _rebuildVisible();
  }

  void _openDetail(Vegetable v) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(
          vegetable: v,
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          presentation: VegetableDetailPresentation.encyclopedia,
        ),
      ),
    );
  }

  Future<void> _toggleInGarden(Vegetable v) async {
    final store = widget.gardenStore;
    final settings = widget.aiSettings;
    if (store == null || settings == null) return;

    if (store.contains(v.id)) {
      await store.remove(v.id);
      await widget.profileStore?.removeProfile(v.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${v.nameNl} uit je moestuin')),
      );
      return;
    }

    final setup = await showAddPlantSetupSheet(
      context,
      vegetable: v,
      repository: widget.repository,
      aiSettings: settings,
    );
    if (setup == null || !mounted) return;

    final profiles = widget.profileStore;
    if (profiles == null) return;

    final added = await applyAddPlantSetup(
      gardenStore: store,
      profileStore: profiles,
      setup: setup,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    if (!mounted) return;
    if (added) {
      await syncGardenNotifications(
        profileStore: profiles,
        gardenStore: store,
        repository: widget.repository,
        scanPrefs: widget.scanPrefs!,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addPlantSuccessMessage(
            plantName: v.nameNl,
            setup: setup,
            added: added,
            vegetable: v,
          ),
        ),
      ),
    );
  }

  List<Vegetable> get _gardenVegetables {
    final store = widget.gardenStore;
    if (store == null) return const [];
    return store.ids
        .map(widget.repository.byId)
        .whereType<Vegetable>()
        .toList();
  }

  List<Vegetable> get _popularVegetables {
    final gardenIds = widget.gardenStore?.ids.toSet() ?? {};
    return kWizardPopularPlantIds
        .map(widget.repository.byId)
        .whereType<Vegetable>()
        .where((v) => !gardenIds.contains(v.id))
        .toList();
  }

  List<Vegetable> get _catalogVegetables {
    final seen = <String>{
      ..._gardenVegetables.map((v) => v.id),
      ..._popularVegetables.map((v) => v.id),
    };
    return _visible.where((v) => !seen.contains(v.id)).toList();
  }

  bool get _isSearching => _search.text.trim().isNotEmpty;

  bool get _hasActiveFilters => _criteria.hasActiveFilters;

  @override
  Widget build(BuildContext context) {
    final gardenPlants = _gardenVegetables;
    final popular = _popularVegetables;
    final catalog = _catalogVegetables;
    final results = _visible;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.embedded
          ? null
          : AppBar(
              title: const Text('Plantengids'),
              actions: [
                IconButton(
                  onPressed: _openFilters,
                  icon: Badge(
                    isLabelVisible: _hasActiveFilters,
                    label: Text('${_criteria.activeFilterCount}'),
                    child: const Icon(Icons.tune),
                  ),
                  tooltip: 'Filters',
                ),
              ],
            ),
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            if (widget.embedded)
              const SliverToBoxAdapter(child: PlantsGuidePageHeader()),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: _PlantsGuideSearchBar(
                  controller: _search,
                  onSubmit: _rebuildVisible,
                  onOpenFilters: _openFilters,
                  activeFilterCount:
                      _hasActiveFilters ? _criteria.activeFilterCount : 0,
                ),
              ),
            ),
            if (_isSearching) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Text(
                    '${results.length} gewas${results.length == 1 ? '' : 'sen'} gevonden',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: TuinierColors.textSecondary,
                        ),
                  ),
                ),
              ),
              _buildGridSliver(results),
            ] else if (_hasActiveFilters) ...[
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${results.length} gewas${results.length == 1 ? '' : 'sen'} · ${_criteria.activeFilterCount} filter${_criteria.activeFilterCount == 1 ? '' : 's'}',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: TuinierColors.textSecondary,
                                  ),
                        ),
                      ),
                      TextButton(
                        onPressed: _clearFilters,
                        child: const Text('Wis'),
                      ),
                    ],
                  ),
                ),
              ),
              _buildGridSliver(results),
            ] else ...[
              if (gardenPlants.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: PlantsGuideSectionHeader(
                    title: 'In je moestuin',
                    subtitle:
                        'Teeltinfo voor de gewassen die je nu opvolgt',
                  ),
                ),
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: 228,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: gardenPlants.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 14),
                      itemBuilder: (context, index) {
                        final v = gardenPlants[index];
                        return SizedBox(
                          width: MediaQuery.sizeOf(context).width * 0.72,
                          child: PlantsGuideCard(
                            vegetable: v,
                            size: PlantsGuideCardSize.featured,
                            onTap: () => _openDetail(v),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
              if (popular.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: PlantsGuideSectionHeader(
                    title: 'Populaire gewassen',
                    subtitle:
                        'Favorieten voor de Nederlandse moestuin',
                  ),
                ),
                _buildGridSliver(popular),
              ],
              if (catalog.isNotEmpty) ...[
                const SliverToBoxAdapter(
                  child: PlantsGuideSectionHeader(
                    title: 'Alle gewassen',
                    subtitle: 'Blader door de volledige plantengids',
                  ),
                ),
                _buildGridSliver(catalog),
              ],
              if (gardenPlants.isEmpty &&
                  popular.isEmpty &&
                  catalog.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32),
                      child: Text(
                        'Geen gewassen gevonden.\nPas je zoekterm aan.',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: TuinierColors.textSecondary,
                            ),
                      ),
                    ),
                  ),
                ),
            ],
            const SliverPadding(padding: EdgeInsets.only(bottom: 24)),
          ],
        ),
      ),
    );
  }

  SliverPadding _buildGridSliver(List<Vegetable> items) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverGrid(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 14,
          crossAxisSpacing: 14,
          childAspectRatio: 0.78,
        ),
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final v = items[index];
            final season = plantingSeasonStatusFor(v.id, vegetable: v);
            return PlantsGuideCard(
              key: ValueKey(v.id),
              vegetable: v,
              onTap: () => _openDetail(v),
              dimmed: season.isSeasonEnded,
            );
          },
          childCount: items.length,
        ),
      ),
    );
  }
}

class _PlantsGuideSearchBar extends StatelessWidget {
  const _PlantsGuideSearchBar({
    required this.controller,
    required this.onSubmit,
    required this.onOpenFilters,
    this.activeFilterCount = 0,
  });

  final TextEditingController controller;
  final VoidCallback onSubmit;
  final VoidCallback onOpenFilters;
  final int activeFilterCount;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: TuinierColors.searchBar,
              borderRadius: BorderRadius.circular(28),
              border: Border.all(color: TuinierColors.border),
            ),
            padding: const EdgeInsets.only(left: 18, right: 4),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.search,
                    onSubmitted: (_) => onSubmit(),
                    decoration: const InputDecoration(
                      hintText: 'Zoek een gewas of teeltinfo',
                      border: InputBorder.none,
                      isDense: true,
                    ),
                  ),
                ),
                Material(
                  color: TuinierColors.primary,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: onSubmit,
                    child: const Padding(
                      padding: EdgeInsets.all(10),
                      child: Icon(
                        Icons.search,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Material(
          color: activeFilterCount > 0
              ? TuinierColors.primary.withValues(alpha: 0.12)
              : TuinierColors.searchBar,
          shape: const CircleBorder(),
          child: InkWell(
            customBorder: const CircleBorder(),
            onTap: onOpenFilters,
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Badge(
                isLabelVisible: activeFilterCount > 0,
                label: Text('$activeFilterCount'),
                child: Icon(
                  Icons.tune,
                  color: activeFilterCount > 0
                      ? TuinierColors.primary
                      : TuinierColors.primary,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
