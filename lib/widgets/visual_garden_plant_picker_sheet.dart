import 'package:flutter/material.dart';

import '../data/crop_lifecycle_metadata.dart';
import '../data/moestuin_companion_plants.dart';
import '../data/my_garden_store.dart';
import '../data/plant_encyclopedia_layout.dart';
import '../data/plant_planner_spacing.dart';
import '../data/plant_search_filters.dart';
import '../data/planting_season_status.dart';
import '../data/vegetable_repository.dart';
import '../data/visual_garden_companion_match.dart';
import '../data/visual_garden_crop_suggest.dart';
import '../models/vegetable.dart';
import '../models/visual_garden_plan.dart';
import '../theme/tuinier_colors.dart';
import 'clearable_search_field.dart';
import 'plant_encyclopedia/plant_info_tab.dart';
import 'plant_encyclopedia/plant_overview_tab.dart';
import 'plant_guide_filter_sheet.dart';
import 'plants_guide_card.dart';

class VisualGardenPlantPickerOutcome {
  const VisualGardenPlantPickerOutcome.plant(this.plant)
      : requestSmartPlan = false;

  const VisualGardenPlantPickerOutcome.smartPlan()
      : plant = null,
        requestSmartPlan = true;

  final Vegetable? plant;
  final bool requestSmartPlan;
}

const _kMonthNamesNl = <String>[
  '',
  'januari',
  'februari',
  'maart',
  'april',
  'mei',
  'juni',
  'juli',
  'augustus',
  'september',
  'oktober',
  'november',
  'december',
];

/// Volledige plantkiezer (atlas-stijl) voor de moestuinbak-planner.
Future<VisualGardenPlantPickerOutcome?> showVisualGardenPlantPicker({
  required BuildContext context,
  required VegetableRepository repository,
  required MyGardenStore gardenStore,
  List<String> companionSeedIds = const [],
  bool offerSmartPlan = true,
  /// Vorig teeltplan: filter op “na oogst van …” / datum.
  VisualCropPlan? previousCropPlan,
}) {
  return Navigator.of(context).push<VisualGardenPlantPickerOutcome>(
    MaterialPageRoute(
      builder: (_) => VisualGardenPlantPickerPage(
        repository: repository,
        gardenStore: gardenStore,
        companionSeedIds: companionSeedIds,
        offerSmartPlan: offerSmartPlan,
        previousCropPlan: previousCropPlan,
      ),
    ),
  );
}

class VisualGardenPlantPickerPage extends StatefulWidget {
  const VisualGardenPlantPickerPage({
    super.key,
    required this.repository,
    required this.gardenStore,
    this.companionSeedIds = const [],
    this.offerSmartPlan = true,
    this.previousCropPlan,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final List<String> companionSeedIds;
  final bool offerSmartPlan;
  final VisualCropPlan? previousCropPlan;

  @override
  State<VisualGardenPlantPickerPage> createState() =>
      _VisualGardenPlantPickerPageState();
}

class _VisualGardenPlantPickerPageState
    extends State<VisualGardenPlantPickerPage> {
  final _search = TextEditingController();
  PlantSearchCriteria _criteria = const PlantSearchCriteria(
    browse: PlantBrowseKind.groente,
  );
  bool _onlyGoodCompanions = false;
  bool _handyOnly = false;
  Vegetable? _comboAnchor;
  DateTime? _sowDate;
  /// Na oogst van deze plant uit het vorige teeltplan.
  PreviousCropHarvestSlot? _afterHarvest;

  List<PreviousCropHarvestSlot> get _harvestSlots {
    final plan = widget.previousCropPlan;
    if (plan == null || plan.placements.isEmpty) return const [];
    return previousCropHarvestSlots(
      plan: plan,
      repository: widget.repository,
    );
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  bool get _hasQuickFilter =>
      _onlyGoodCompanions ||
      _handyOnly ||
      _comboAnchor != null ||
      _sowDate != null ||
      _afterHarvest != null;

  List<Vegetable> get _items {
    var list = searchFilteredPlants(
      repository: widget.repository,
      criteria: _criteria,
      searchQuery: _search.text,
    );
    list = list.where((v) => !kMushroomPlantIds.contains(v.id)).toList();
    if (_criteria.browse == PlantBrowseKind.mushrooms) {
      list = const [];
    }

    if (_handyOnly) {
      list = list
          .where((v) => kMoestuinCompanionPlantIds.contains(v.id))
          .toList();
    }

    // Filter op maand: na oogst óf gekozen zaai-datum.
    final filterMonth = _afterHarvest?.harvestMonth ?? _sowDate?.month;
    if (filterMonth != null) {
      final nextMonth = (filterMonth % 12) + 1;
      list = list.where((v) {
        final months = <int>{}
          ..addAll(sowingMonthsForPlant(v))
          ..addAll(plantingMonthsFor(v));
        if (months.isEmpty) return true;
        return months.contains(filterMonth) || months.contains(nextMonth);
      }).toList();
    }

    // Opvolger mag de vrijgekomen plantzone niet overschrijden.
    if (_afterHarvest != null) {
      final cap = _afterHarvest!.spacingCm;
      list = list.where((v) {
        final spacing = plannerSpacingCmForVegetable(v);
        return spacing <= cap + 0.5;
      }).toList();
    }

    if (_comboAnchor != null) {
      list = list
          .where(
            (v) => isGoodCompanionOf(
              candidate: v,
              repository: widget.repository,
              anchorPlantIds: [_comboAnchor!.id],
            ),
          )
          .where((v) => v.id != _comboAnchor!.id)
          .toList();
    } else if (_onlyGoodCompanions && widget.companionSeedIds.isNotEmpty) {
      list = list
          .where(
            (v) => isGoodCompanionOf(
              candidate: v,
              repository: widget.repository,
              anchorPlantIds: widget.companionSeedIds,
            ),
          )
          .toList();
    }
    return list;
  }

  Future<void> _openFilters() async {
    final next = await showPlantGuideFilterSheet(
      context: context,
      initial: _criteria,
    );
    if (next == null || !mounted) return;
    setState(() {
      _criteria = next.browse == PlantBrowseKind.mushrooms
          ? next.copyWith(browse: PlantBrowseKind.groente)
          : next;
    });
  }

  void _clearQuickFilters() {
    setState(() {
      _criteria = const PlantSearchCriteria(browse: PlantBrowseKind.groente);
      _onlyGoodCompanions = false;
      _handyOnly = false;
      _comboAnchor = null;
      _sowDate = null;
      _afterHarvest = null;
    });
  }

  Future<void> _pickComboAnchor() async {
    final picked = await showDialog<Vegetable>(
      context: context,
      builder: (ctx) => _PlantAnchorDialog(repository: widget.repository),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _comboAnchor = picked;
      _handyOnly = false;
      _sowDate = null;
      _afterHarvest = null;
      _onlyGoodCompanions = false;
    });
  }

  Future<void> _pickSowDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _sowDate ?? now,
      firstDate: DateTime(now.year - 1),
      lastDate: DateTime(now.year + 2),
      helpText: 'Kies wanneer je wilt zaaien/planten',
      cancelText: 'Annuleren',
      confirmText: 'Toon planten',
    );
    if (picked == null || !mounted) return;
    setState(() {
      _sowDate = picked;
      _afterHarvest = null;
      _handyOnly = false;
      _comboAnchor = null;
      _onlyGoodCompanions = false;
    });
  }

  Future<void> _pickAfterHarvest() async {
    final slots = _harvestSlots;
    if (slots.isEmpty) return;
    if (_afterHarvest != null) {
      setState(() => _afterHarvest = null);
      return;
    }
    final picked = await showDialog<PreviousCropHarvestSlot>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Na oogst van welke plant?'),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: slots.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final s = slots[i];
              return ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  s.plant.nameNl,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  'Klaar rond ${_kMonthNamesNl[s.harvestMonth]} · '
                  'plek ±${s.spacingCm.round()} cm',
                ),
                onTap: () => Navigator.pop(ctx, s),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuleren'),
          ),
        ],
      ),
    );
    if (picked == null || !mounted) return;
    setState(() {
      _afterHarvest = picked;
      _sowDate = null;
      _handyOnly = false;
      _comboAnchor = null;
      _onlyGoodCompanions = false;
    });
  }

  void _toggleHandy(bool on) {
    setState(() {
      _handyOnly = on;
      if (on) {
        _comboAnchor = null;
        _sowDate = null;
        _afterHarvest = null;
        _onlyGoodCompanions = false;
        _criteria = _criteria.copyWith(browse: PlantBrowseKind.companionGarden);
      } else if (_criteria.browse == PlantBrowseKind.companionGarden) {
        _criteria = _criteria.copyWith(browse: PlantBrowseKind.groente);
      }
    });
  }

  String get _hintText {
    if (_afterHarvest != null) {
      final m = _kMonthNamesNl[_afterHarvest!.harvestMonth];
      return 'Opvolgers na oogst van ${_afterHarvest!.plant.nameNl} '
          '(rond $m). Alleen planten die dan gezaaid/geplant kunnen én '
          'in die plantzone passen.';
    }
    if (_comboAnchor != null) {
      return 'Goede combinaties bij ${_comboAnchor!.nameNl}. '
          'Tik een plant om toe te voegen.';
    }
    if (_handyOnly) {
      return 'Handige moestuinplanten tegen plagen en voor bijen/bestuiving.';
    }
    if (_sowDate != null) {
      final m = _kMonthNamesNl[_sowDate!.month];
      return 'Planten die in $m gezaaid of geplant kunnen worden.';
    }
    if (_harvestSlots.isNotEmpty) {
      return 'Tip: kies “Na oogst van…” om planten te zien die passen '
          'zodra een eerdere plant klaar is — niet iedereen is tegelijk klaar.';
    }
    return 'Paddenstoelen zijn verborgen — die horen niet in de grondbak. '
        'Filter op zon, klimmers, plantafstand, seizoen en meer.';
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final hasCompanionSeed = widget.companionSeedIds.isNotEmpty;
    final badgeCount = _criteria.activeFilterCount +
        (_onlyGoodCompanions ? 1 : 0) +
        (_handyOnly ? 1 : 0) +
        (_comboAnchor != null ? 1 : 0) +
        (_sowDate != null ? 1 : 0) +
        (_afterHarvest != null ? 1 : 0);

    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        title: const Text('Plant toevoegen'),
        backgroundColor: TuinierColors.background,
        foregroundColor: TuinierColors.textPrimary,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Filters',
            onPressed: _openFilters,
            icon: Badge(
              isLabelVisible: badgeCount > 0,
              label: Text('$badgeCount'),
              child: const Icon(Icons.tune_rounded),
            ),
          ),
        ],
      ),
      body: items.isEmpty
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: _PickerFilterHeader(
                    search: _search,
                    onSearchChanged: (_) => setState(() {}),
                    criteria: _criteria,
                    comboAnchor: _comboAnchor,
                    handyOnly: _handyOnly,
                    sowDate: _sowDate,
                    afterHarvest: _afterHarvest,
                    showAfterHarvest: _harvestSlots.isNotEmpty,
                    offerSmartPlan: widget.offerSmartPlan,
                    hasCompanionSeed: hasCompanionSeed,
                    onlyGoodCompanions: _onlyGoodCompanions,
                    hasQuickFilter: _hasQuickFilter,
                    hintText: _hintText,
                    onOpenFilters: _openFilters,
                    onComboTap: () {
                      if (_comboAnchor != null) {
                        setState(() => _comboAnchor = null);
                      } else {
                        _pickComboAnchor();
                      }
                    },
                    onToggleHandy: _toggleHandy,
                    onSowDateTap: () {
                      if (_sowDate != null) {
                        setState(() => _sowDate = null);
                      } else {
                        _pickSowDate();
                      }
                    },
                    onAfterHarvestTap: _pickAfterHarvest,
                    onSmartPlan: () {
                      Navigator.of(context).pop(
                        const VisualGardenPlantPickerOutcome.smartPlan(),
                      );
                    },
                    onOnlyGoodCompanions: (v) => setState(() {
                      _onlyGoodCompanions = v;
                      if (v) {
                        _comboAnchor = null;
                        _handyOnly = false;
                        _sowDate = null;
                        _afterHarvest = null;
                      }
                    }),
                    onClearQuickFilters: _clearQuickFilters,
                  ),
                ),
                const Expanded(
                  child: Center(child: Text('Geen planten gevonden')),
                ),
              ],
            )
          : CustomScrollView(
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  sliver: SliverToBoxAdapter(
                    child: _PickerFilterHeader(
                      search: _search,
                      onSearchChanged: (_) => setState(() {}),
                      criteria: _criteria,
                      comboAnchor: _comboAnchor,
                      handyOnly: _handyOnly,
                      sowDate: _sowDate,
                      afterHarvest: _afterHarvest,
                      showAfterHarvest: _harvestSlots.isNotEmpty,
                      offerSmartPlan: widget.offerSmartPlan,
                      hasCompanionSeed: hasCompanionSeed,
                      onlyGoodCompanions: _onlyGoodCompanions,
                      hasQuickFilter: _hasQuickFilter,
                      hintText: _hintText,
                      onOpenFilters: _openFilters,
                      onComboTap: () {
                        if (_comboAnchor != null) {
                          setState(() => _comboAnchor = null);
                        } else {
                          _pickComboAnchor();
                        }
                      },
                      onToggleHandy: _toggleHandy,
                      onSowDateTap: () {
                        if (_sowDate != null) {
                          setState(() => _sowDate = null);
                        } else {
                          _pickSowDate();
                        }
                      },
                      onAfterHarvestTap: _pickAfterHarvest,
                      onSmartPlan: () {
                        Navigator.of(context).pop(
                          const VisualGardenPlantPickerOutcome.smartPlan(),
                        );
                      },
                      onOnlyGoodCompanions: (v) => setState(() {
                        _onlyGoodCompanions = v;
                        if (v) {
                          _comboAnchor = null;
                          _handyOnly = false;
                          _sowDate = null;
                          _afterHarvest = null;
                        }
                      }),
                      onClearQuickFilters: _clearQuickFilters,
                    ),
                  ),
                ),
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 24),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 0.78,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (context, i) {
                        final v = items[i];
                        return PlantsGuideCard(
                          vegetable: v,
                          onTap: () => _openPlantPreview(v),
                        );
                      },
                      childCount: items.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Future<void> _openPlantPreview(Vegetable vegetable) async {
    final added = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (_) => _VisualGardenPlantPreviewPage(vegetable: vegetable),
      ),
    );
    if (added == true && mounted) {
      Navigator.of(context).pop(
        VisualGardenPlantPickerOutcome.plant(vegetable),
      );
    }
  }
}

/// Zoekveld + filterchips; scrollt mee met de plantenlijst.
class _PickerFilterHeader extends StatelessWidget {
  const _PickerFilterHeader({
    required this.search,
    required this.onSearchChanged,
    required this.criteria,
    required this.comboAnchor,
    required this.handyOnly,
    required this.sowDate,
    required this.afterHarvest,
    required this.showAfterHarvest,
    required this.offerSmartPlan,
    required this.hasCompanionSeed,
    required this.onlyGoodCompanions,
    required this.hasQuickFilter,
    required this.hintText,
    required this.onOpenFilters,
    required this.onComboTap,
    required this.onToggleHandy,
    required this.onSowDateTap,
    required this.onAfterHarvestTap,
    required this.onSmartPlan,
    required this.onOnlyGoodCompanions,
    required this.onClearQuickFilters,
  });

  final TextEditingController search;
  final ValueChanged<String> onSearchChanged;
  final PlantSearchCriteria criteria;
  final Vegetable? comboAnchor;
  final bool handyOnly;
  final DateTime? sowDate;
  final PreviousCropHarvestSlot? afterHarvest;
  final bool showAfterHarvest;
  final bool offerSmartPlan;
  final bool hasCompanionSeed;
  final bool onlyGoodCompanions;
  final bool hasQuickFilter;
  final String hintText;
  final VoidCallback onOpenFilters;
  final VoidCallback onComboTap;
  final ValueChanged<bool> onToggleHandy;
  final VoidCallback onSowDateTap;
  final VoidCallback onAfterHarvestTap;
  final VoidCallback onSmartPlan;
  final ValueChanged<bool> onOnlyGoodCompanions;
  final VoidCallback onClearQuickFilters;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ClearableSearchField(
          controller: search,
          hintText: 'Zoek een plant…',
          onChanged: onSearchChanged,
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            FilterChip(
              label: Text(
                criteria.hasActiveFilters
                    ? 'Filters (${criteria.activeFilterCount})'
                    : 'Filters',
              ),
              selected: criteria.hasActiveFilters,
              onSelected: (_) => onOpenFilters(),
              avatar: const Icon(Icons.tune, size: 18),
            ),
            if (showAfterHarvest)
              FilterChip(
                label: Text(
                  afterHarvest == null
                      ? 'Na oogst van…'
                      : 'Na ${afterHarvest!.plant.nameNl}',
                ),
                selected: afterHarvest != null,
                onSelected: (_) => onAfterHarvestTap(),
                avatar: const Icon(Icons.yard_outlined, size: 18),
              ),
            FilterChip(
              label: Text(
                comboAnchor == null
                    ? 'Combinaties'
                    : 'Bij ${comboAnchor!.nameNl}',
              ),
              selected: comboAnchor != null,
              onSelected: (_) => onComboTap(),
              avatar: const Icon(Icons.hub_outlined, size: 18),
            ),
            FilterChip(
              label: const Text('Handig tegen plagen'),
              selected: handyOnly,
              onSelected: onToggleHandy,
              avatar: const Icon(Icons.bug_report_outlined, size: 18),
            ),
            FilterChip(
              label: Text(
                sowDate == null
                    ? 'Zaai-/plantdatum'
                    : _kMonthNamesNl[sowDate!.month],
              ),
              selected: sowDate != null,
              onSelected: (_) => onSowDateTap(),
              avatar: const Icon(Icons.calendar_month_outlined, size: 18),
            ),
            if (offerSmartPlan)
              ActionChip(
                label: const Text('Slim tuinplan'),
                avatar: const Icon(Icons.auto_awesome, size: 18),
                onPressed: onSmartPlan,
              ),
            if (hasCompanionSeed)
              FilterChip(
                label: const Text('Goede buren in bak'),
                selected: onlyGoodCompanions,
                onSelected: onOnlyGoodCompanions,
              ),
            if (criteria.hasActiveFilters || hasQuickFilter)
              ActionChip(
                label: const Text('Wis filters'),
                onPressed: onClearQuickFilters,
              ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          hintText,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
      ],
    );
  }
}

class _PlantAnchorDialog extends StatefulWidget {
  const _PlantAnchorDialog({required this.repository});

  final VegetableRepository repository;

  @override
  State<_PlantAnchorDialog> createState() => _PlantAnchorDialogState();
}

class _PlantAnchorDialogState extends State<_PlantAnchorDialog> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final q = _search.text.trim().toLowerCase();
    final plants = widget.repository.all.where((v) {
      if (kMushroomPlantIds.contains(v.id)) return false;
      if (q.isEmpty) return true;
      return v.nameNl.toLowerCase().contains(q) ||
          v.keywords.any((k) => k.toLowerCase().contains(q));
    }).toList()
      ..sort((a, b) => a.nameNl.compareTo(b.nameNl));

    return AlertDialog(
      title: const Text('Combinaties van welke plant?'),
      content: SizedBox(
        width: double.maxFinite,
        height: 420,
        child: Column(
          children: [
            TextField(
              controller: _search,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Zoek plant…',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: plants.length,
                itemBuilder: (context, i) {
                  final v = plants[i];
                  return ListTile(
                    title: Text(v.nameNl),
                    subtitle: Text(v.family),
                    onTap: () => Navigator.pop(context, v),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuleren'),
        ),
      ],
    );
  }
}

class _VisualGardenPlantPreviewPage extends StatefulWidget {
  const _VisualGardenPlantPreviewPage({required this.vegetable});

  final Vegetable vegetable;

  @override
  State<_VisualGardenPlantPreviewPage> createState() =>
      _VisualGardenPlantPreviewPageState();
}

class _VisualGardenPlantPreviewPageState
    extends State<_VisualGardenPlantPreviewPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  late final PlantEncyclopediaLayout _layout;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _layout = buildPlantEncyclopediaLayout(
      vegetable: widget.vegetable,
      seasonAdvice: plantingSeasonAdviceFor(widget.vegetable),
    );
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final v = widget.vegetable;
    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        title: Text(v.nameNl),
        backgroundColor: TuinierColors.background,
        foregroundColor: TuinierColors.textPrimary,
        elevation: 0,
        bottom: TabBar(
          controller: _tabs,
          labelColor: TuinierColors.primary,
          unselectedLabelColor: TuinierColors.textSecondary,
          indicatorColor: TuinierColors.primary,
          tabs: const [
            Tab(text: 'Overzicht'),
            Tab(text: 'Info'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          PlantOverviewTab(
            layout: _layout,
            vegetable: v,
          ),
          PlantInfoTab(
            layout: _layout,
            vegetable: v,
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: TuinierColors.primary,
              minimumSize: const Size.fromHeight(48),
            ),
            child: const Text(
              'Toevoegen',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
    );
  }
}

/// Toont voorgestelde planten voor een volgende teelt na de oogst.
Future<void> showSuccessionPlanSheet({
  required BuildContext context,
  required List<Vegetable> plants,
  required String bedName,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Plan na de oogst — $bedName',
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 18,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Deze planten passen goed als tweede teelt (andere families / '
                'later zaaien). Noteer ze of voeg ze later zelf toe.',
                style: TextStyle(color: TuinierColors.textSecondary),
              ),
              const SizedBox(height: 12),
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.sizeOf(ctx).height * 0.5,
                ),
                child: plants.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Geen opvolgplannen gevonden.'),
                      )
                    : ListView.separated(
                        shrinkWrap: true,
                        itemCount: plants.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (_, i) {
                          final v = plants[i];
                          final months = sowingMonthsForPlant(v).toList()
                            ..sort();
                          final monthLabel = months.isEmpty
                              ? 'Zaai wanneer geschikt'
                              : 'Zaai o.a. in: ${months.map((m) => _kMonthNamesNl[m]).join(', ')}';
                          return ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(
                              v.nameNl,
                              style: const TextStyle(fontWeight: FontWeight.w700),
                            ),
                            subtitle: Text(monthLabel),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => Navigator.pop(ctx),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2F6B32),
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Begrepen'),
              ),
            ],
          ),
        ),
      );
    },
  );
}
