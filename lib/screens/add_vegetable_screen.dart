import 'package:flutter/material.dart';

import '../data/add_plant_apply.dart';
import '../data/ai_settings_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/plant_season_activation.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_search_filters.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../widgets/add_plant_setup_sheet.dart';
import '../widgets/home_moestuin_actions.dart';
import '../widgets/plant_search_scroll_layout.dart';
import '../widgets/vegetable_thumbnail.dart';

class AddVegetableScreen extends StatefulWidget {
  const AddVegetableScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.aiSettings,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final AiSettingsStore aiSettings;

  @override
  State<AddVegetableScreen> createState() => _AddVegetableScreenState();
}

class _AddVegetableScreenState extends State<AddVegetableScreen> {
  final TextEditingController _search = TextEditingController();
  PlantSearchCriteria _criteria = const PlantSearchCriteria();
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_refresh);
    widget.profileStore.addListener(_refresh);
    _search.addListener(_onSearchTextChanged);
  }

  @override
  void dispose() {
    widget.gardenStore.removeListener(_refresh);
    widget.profileStore.removeListener(_refresh);
    _search.removeListener(_onSearchTextChanged);
    _search.dispose();
    super.dispose();
  }

  void _onSearchTextChanged() {
    final q = _search.text;
    if (q == _lastQuery) return;
    _lastQuery = q;
    setState(() {});
  }

  void _refresh() => setState(() {});

  List<Vegetable> get _filtered => searchFilteredPlants(
        repository: widget.repository,
        criteria: _criteria,
        searchQuery: _search.text,
      );

  List<Vegetable> get _inGardenNotPlanted => _filtered
      .where((v) {
        if (!widget.gardenStore.contains(v.id)) return false;
        final p = widget.profileStore.profileFor(v.id);
        return p == null || !p.isPlanted;
      })
      .toList();

  List<Vegetable> get _available => _filtered
      .where((v) => !widget.gardenStore.contains(v.id))
      .toList();

  Future<void> _add(Vegetable v) async {
    final setup = await showAddPlantSetupSheet(
      context,
      vegetable: v,
      repository: widget.repository,
      aiSettings: widget.aiSettings,
    );
    if (setup == null || !mounted) return;

    final added = await applyAddPlantSetup(
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      setup: setup,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    if (!mounted) return;
    if (added) {
      await syncGardenNotifications(
        profileStore: widget.profileStore,
        gardenStore: widget.gardenStore,
        repository: widget.repository,
        scanPrefs: widget.scanPrefs,
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
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _markPlanted(Vegetable v) async {
    await widget.profileStore.ensureProfile(v.id);
    await markVegetableAsPlanted(
      context: context,
      vegetable: v,
      profileStore: widget.profileStore,
      scanPrefs: widget.scanPrefs,
    );
    if (mounted) setState(() {});
  }

  void _resetFilters() {
    setState(() => _criteria = const PlantSearchCriteria());
  }

  void _onCriteriaChanged(PlantSearchCriteria next) {
    setState(() => _criteria = next);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final inGarden = _inGardenNotPlanted;
    final list = _available;
    final hasActiveFilters = _criteria.activeFilterCount > 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groente toevoegen'),
        actions: [
          if (hasActiveFilters)
            TextButton(
              onPressed: _resetFilters,
              child: const Text('Wis filters'),
            ),
        ],
      ),
      body: PlantSearchScrollLayout(
        searchController: _search,
        onSearchChanged: (_) {},
        criteria: _criteria,
        onCriteriaChanged: _onCriteriaChanged,
        bottomPadding: 96,
        searchFillColor: Color.lerp(cs.surface, cs.primary, 0.08),
        slivers: [
          if (inGarden.isNotEmpty) ...[
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Text(
                  'Gepland voor het seizoen, nog niet gezaaid',
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.primary,
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, i) {
                  final v = inGarden[i];
                  return ListTile(
                    key: ValueKey('pending-${v.id}'),
                    leading: VegetableThumbnail(vegetable: v),
                    title: Text(v.nameNl),
                    subtitle: const Text(
                      'Staat op je lijst tot het zaai- of plantseizoen begint. '
                      'Markeer als geplant zodra het in de grond staat.',
                    ),
                    trailing: FilledButton.tonal(
                      onPressed: () => _markPlanted(v),
                      child: const Text('Geplant'),
                    ),
                  );
                },
                childCount: inGarden.length,
              ),
            ),
            const SliverToBoxAdapter(child: Divider(height: 24)),
          ],
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
                '${list.length} om toe te voegen',
                style: t.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ),
          if (list.isEmpty && inGarden.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Geen resultaat.\nPas zoekterm of filters aan.',
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
                (context, i) {
                  final v = list[i];
                  return Column(
                    key: ValueKey(v.id),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (i > 0) const Divider(height: 1),
                      ListTile(
                        leading: VegetableThumbnail(vegetable: v),
                        title: Text(v.nameNl),
                        subtitle: Text(v.family),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: cs.primary,
                          tooltip: 'Toevoegen',
                          onPressed: () => _add(v),
                        ),
                        onTap: () => _add(v),
                      ),
                    ],
                  );
                },
                childCount: list.length,
              ),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.check),
        label: const Text('Klaar'),
      ),
    );
  }
}
