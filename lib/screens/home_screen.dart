import 'package:flutter/material.dart';

import '../data/garden_growth_engine.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_calendar.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_scan_prefs_store.dart';
import '../widgets/home_moestuin_actions.dart';
import '../widgets/vegetable_search_button.dart';
import '../widgets/vegetable_thumbnail.dart';
import 'add_vegetable_screen.dart';
import 'my_garden_screen.dart';
import 'vegetable_detail_screen.dart';
import 'vegetable_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    this.onGoToPlantScan,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final void Function({String? vegetableId})? onGoToPlantScan;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  GardenTaskType? _taskFilter;
  _StartScope _scope = _StartScope.myGarden;
  Set<String> _customVegetableIds = {};

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_onGardenChanged);
    widget.profileStore.addListener(_onGardenChanged);
  }

  @override
  void dispose() {
    widget.gardenStore.removeListener(_onGardenChanged);
    widget.profileStore.removeListener(_onGardenChanged);
    super.dispose();
  }

  void _onGardenChanged() => setState(() {});

  void _openAddVegetable() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AddVegetableScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
        ),
      ),
    );
  }

  void _openGardenManage() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MyGardenScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          onGoToPlantScan: widget.onGoToPlantScan,
        ),
      ),
    );
  }

  List<MonthTaskEntry> _entriesForMonth(int month, GardenTaskType? filter) {
    var entries = monthTasksFor(month, taskFilter: filter);
    switch (_scope) {
      case _StartScope.myGarden:
        entries = entries
            .where((e) => widget.gardenStore.contains(e.vegetableId))
            .toList();
        break;
      case _StartScope.all:
        break;
      case _StartScope.custom:
        entries = entries
            .where((e) => _customVegetableIds.contains(e.vegetableId))
            .toList();
        break;
    }
    return entries;
  }

  @override
  Widget build(BuildContext context) {
    final month = DateTime.now().month;
    final monthName = kMonthNamesNl[month];
    final availableTypes = taskTypesForMonth(month);
    final activeFilter = _resolveFilter(availableTypes);
    final monthEntries = _entriesForMonth(month, activeFilter);
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn moestuin'),
        actions: [
          IconButton(
            tooltip: 'Lijst en instellingen',
            icon: const Icon(Icons.tune),
            onPressed: _openGardenManage,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _openAddVegetable,
        tooltip: 'Groente toevoegen',
        child: const Icon(Icons.add),
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          VegetableSearchButton(onTap: _openAtlas),
          HomeMoestuinActions(
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            onGoToPlantScan: widget.onGoToPlantScan,
            onMarkedPlanted: () => syncGardenNotifications(
              profileStore: widget.profileStore,
              gardenStore: widget.gardenStore,
              repository: widget.repository,
              scanPrefs: widget.scanPrefs,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 12),
            child: Text(
              'Taken van $monthName',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (availableTypes.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Geen taken voor $monthName in de kalender.',
                style: t.textTheme.bodyLarge,
              ),
            )
          else ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
              child: Material(
                color: t.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.tune,
                            size: 20,
                            color: t.colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Filter: wat doe je nu?',
                            style: t.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: availableTypes.map((type) {
                          final selected = activeFilter == type;
                          return FilterChip(
                            selected: selected,
                            showCheckmark: true,
                            avatar: Icon(
                              _taskIcon(type),
                              size: 18,
                              color: selected
                                  ? t.colorScheme.onSecondaryContainer
                                  : t.colorScheme.onSurfaceVariant,
                            ),
                            label: Text(
                              type.label,
                              style: TextStyle(
                                fontWeight: selected
                                    ? FontWeight.w600
                                    : FontWeight.w500,
                              ),
                            ),
                            selectedColor: t.colorScheme.secondaryContainer,
                            onSelected: (_) =>
                                setState(() => _taskFilter = type),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: OutlinedButton.icon(
                onPressed: _openScopeFilter,
                icon: const Icon(Icons.filter_alt_outlined),
                label: Text(_scopeLabel),
                style: OutlinedButton.styleFrom(
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            if (_scope == _StartScope.custom) ...[
              const SizedBox(height: 10),
              _ChosenVegetablesBar(
                repository: widget.repository,
                ids: _customVegetableIds,
                onEdit: _openScopeFilter,
                onRemove: (id) => setState(() => _customVegetableIds.remove(id)),
              ),
            ],
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
              child: Text(
                activeFilter != null
                    ? '${monthEntries.length} groente(n) — ${activeFilter.label.toLowerCase()}'
                    : 'Kies een filter',
                style: t.textTheme.labelLarge?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            if (monthEntries.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  _scope == _StartScope.myGarden &&
                          widget.gardenStore.isEmpty
                      ? 'U heeft nog geen groente geselecteerd.'
                      : 'Geen groenten voor dit filter in $monthName.',
                  style: t.textTheme.bodyLarge,
                ),
              )
            else
              ...monthEntries.map((entry) {
                final veg = widget.repository.byId(entry.vegetableId);
                if (veg == null) return const SizedBox.shrink();
                return _MonthTaskCard(
                  vegetable: veg,
                  activities: entry.tasks,
                  insight: widget.gardenStore.contains(veg.id)
                      ? growthInsightFor(
                          veg,
                          widget.profileStore.profileFor(veg.id),
                          null,
                          widget.scanPrefs.daysUntilFirstPhoto,
                        )
                      : null,
                  onTap: () => _openDetail(veg, month),
                  onScanPlant: widget.gardenStore.contains(veg.id)
                      ? () => widget.onGoToPlantScan?.call(vegetableId: veg.id)
                      : null,
                );
              }),
          ],
        ],
      ),
    );
  }

  IconData _taskIcon(GardenTaskType type) {
    switch (type) {
      case GardenTaskType.plantOutdoors:
        return Icons.yard_outlined;
      case GardenTaskType.sowOutdoors:
        return Icons.grass;
      case GardenTaskType.preSow:
        return Icons.spa_outlined;
      case GardenTaskType.harvest:
        return Icons.shopping_basket_outlined;
    }
  }

  GardenTaskType? _resolveFilter(List<GardenTaskType> available) {
    if (available.isEmpty) return null;
    if (_taskFilter != null && available.contains(_taskFilter)) {
      return _taskFilter;
    }
    return available.first;
  }

  void _openDetail(Vegetable veg, int month) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(
          vegetable: veg,
          focusMonth: month,
          profileStore: widget.gardenStore.contains(veg.id)
              ? widget.profileStore
              : null,
          scanPrefs: widget.scanPrefs,
          onGoToPlantScan: widget.gardenStore.contains(veg.id) &&
                  widget.onGoToPlantScan != null
              ? () => widget.onGoToPlantScan!(vegetableId: veg.id)
              : null,
        ),
      ),
    );
  }

  void _openAtlas() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VegetableListScreen(repository: widget.repository),
      ),
    );
  }

  String get _scopeLabel {
    switch (_scope) {
      case _StartScope.myGarden:
        final count = widget.gardenStore.count;
        return count == 0
            ? 'Weergave: Mijn moestuin (nog leeg)'
            : 'Weergave: Mijn moestuin ($count)';
      case _StartScope.all:
        return 'Weergave: Alle groenten';
      case _StartScope.custom:
        final count = _customVegetableIds.length;
        return 'Weergave: Gekozen groenten ($count)';
    }
  }

  Future<void> _openScopeFilter() async {
    final selection = await showModalBottomSheet<_ScopeSelection>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => _StartScopeSheet(
        repository: widget.repository,
        currentScope: _scope,
        currentCustomIds: _customVegetableIds,
      ),
    );
    if (selection == null || !mounted) return;
    setState(() {
      _scope = selection.scope;
      _customVegetableIds = selection.customIds;
    });
  }
}

class _ChosenVegetablesBar extends StatelessWidget {
  const _ChosenVegetablesBar({
    required this.repository,
    required this.ids,
    required this.onEdit,
    required this.onRemove,
  });

  final VegetableRepository repository;
  final Set<String> ids;
  final VoidCallback onEdit;
  final void Function(String id) onRemove;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Material(
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Gekozen groenten',
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Wijzigen'),
                  ),
                ],
              ),
              if (ids.isEmpty)
                Text(
                  'Nog geen groenten gekozen. Tik op Wijzigen om te selecteren.',
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                )
              else
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ids.map((id) {
                    final veg = repository.byId(id);
                    if (veg == null) return const SizedBox.shrink();
                    return InputChip(
                      label: Text(veg.nameNl),
                      onDeleted: () => onRemove(id),
                      deleteIcon: const Icon(Icons.close, size: 18),
                    );
                  }).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

enum _StartScope { myGarden, all, custom }

class _ScopeSelection {
  const _ScopeSelection({
    required this.scope,
    required this.customIds,
  });

  final _StartScope scope;
  final Set<String> customIds;
}

class _StartScopeSheet extends StatefulWidget {
  const _StartScopeSheet({
    required this.repository,
    required this.currentScope,
    required this.currentCustomIds,
  });

  final VegetableRepository repository;
  final _StartScope currentScope;
  final Set<String> currentCustomIds;

  @override
  State<_StartScopeSheet> createState() => _StartScopeSheetState();
}

class _StartScopeSheetState extends State<_StartScopeSheet> {
  late _StartScope _scope;
  late Set<String> _ids;
  final TextEditingController _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scope = widget.currentScope;
    _ids = {...widget.currentCustomIds};
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.repository.all;
    final q = _search.text.trim().toLowerCase();
    final filtered = all.where((v) {
      if (q.isEmpty) return true;
      return v.matchesQuery(q);
    }).toList();

    return SafeArea(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.84,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 20, 8),
              child: Text(
                'Wat wil je zien op Start?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ),
            RadioListTile<_StartScope>(
              value: _StartScope.myGarden,
              groupValue: _scope,
              title: const Text('Mijn moestuin'),
              subtitle: const Text('Alleen groenten uit Mijn moestuin'),
              onChanged: (v) => setState(() => _scope = v!),
            ),
            RadioListTile<_StartScope>(
              value: _StartScope.all,
              groupValue: _scope,
              title: const Text('Alle groenten'),
              subtitle: const Text('Laat alle taken uit de kalender zien'),
              onChanged: (v) => setState(() => _scope = v!),
            ),
            RadioListTile<_StartScope>(
              value: _StartScope.custom,
              groupValue: _scope,
              title: const Text('Gekozen groenten'),
              subtitle: Text(
                _ids.isEmpty
                    ? 'Selecteer groenten via zoeken'
                    : '${_ids.length} geselecteerd',
              ),
              onChanged: (v) => setState(() => _scope = v!),
            ),
            if (_scope == _StartScope.custom) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: 'Zoek groente…',
                    prefixIcon: const Icon(Icons.search),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    isDense: true,
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: filtered.length,
                  itemBuilder: (_, i) {
                    final v = filtered[i];
                    final selected = _ids.contains(v.id);
                    return CheckboxListTile(
                      value: selected,
                      title: Text(v.nameNl),
                      subtitle: Text(v.family),
                      controlAffinity: ListTileControlAffinity.leading,
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _ids.add(v.id);
                          } else {
                            _ids.remove(v.id);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
            ] else
              const Spacer(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton.icon(
                onPressed: () {
                  Navigator.pop(
                    context,
                    _ScopeSelection(scope: _scope, customIds: _ids),
                  );
                },
                icon: const Icon(Icons.check),
                label: const Text('Toepassen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MonthTaskCard extends StatelessWidget {
  const _MonthTaskCard({
    required this.vegetable,
    required this.activities,
    required this.onTap,
    this.insight,
    this.onScanPlant,
  });

  final Vegetable vegetable;
  final List<VegetableMonthActivity> activities;
  final VoidCallback onTap;
  final PlantGrowthInsight? insight;
  final VoidCallback? onScanPlant;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final primary = activities.first;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  VegetableThumbnail(vegetable: vegetable),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      vegetable.nameNl,
                      style: t.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
              if (insight != null) ...[
                const SizedBox(height: 8),
                Text(
                  '${insight!.scheduleStatus.emoji} ${insight!.summaryLine}',
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  insight!.needsScan
                      ? 'Tip: maak een foto in Plant scan'
                      : 'Oogst: ${insight!.harvestWindowLabel} '
                          '(${insight!.confidencePercent}% zeker)',
                  style: t.textTheme.labelMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ] else if (primary.hint != null) ...[
                const SizedBox(height: 8),
                Text(
                  primary.hint!,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              if (onScanPlant != null) ...[
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onScanPlant,
                    icon: const Icon(Icons.photo_camera_outlined, size: 18),
                    label: Text(
                      insight?.needsScan == true
                          ? 'Plant scannen'
                          : 'Nieuwe foto scannen',
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 4),
              Text(
                'Tik voor volledige uitleg →',
                style: t.textTheme.labelMedium?.copyWith(
                  color: t.colorScheme.primary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
