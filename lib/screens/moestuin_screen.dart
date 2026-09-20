import 'dart:async';

import 'package:flutter/material.dart';

import '../data/add_plant_apply.dart';
import '../data/garden_notifications_sync.dart';
import '../data/plant_season_activation.dart';
import '../data/ai_settings_store.dart';
import '../data/garden_planner_task_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/garden_history_store.dart';
import '../data/insect_scan_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_health_warnings.dart';
import '../data/planting_calendar.dart';
import '../data/vegetable_repository.dart';
import '../widgets/add_plant_setup_sheet.dart';
import '../widgets/add_plant_wizard_screen.dart';
import '../data/weather_prefs_store.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';
import '../widgets/garden_warning_style.dart';
import '../widgets/home_green_pattern.dart';
import '../widgets/home_moestuin_actions.dart';
import '../widgets/clearable_search_field.dart';
import '../widgets/create_tuin_space_sheet.dart';
import '../widgets/moestuin_plant_list_section.dart';
import '../widgets/my_garden_history_page.dart';
import '../widgets/plant_health_warning_sheet.dart';
import '../widgets/start_new_moestuin.dart';
import '../widgets/tuin_space_switcher.dart';
import 'my_garden_screen.dart';
import 'moestuin_visual_planner_screen.dart';
import 'pest_guide_screen.dart';
import '../widgets/garden_plant_insight_body.dart';
import 'garden_plant_insight_screen.dart';
import 'vegetable_detail_screen.dart';

/// Moestuin-tab: zoeken, filters, plantenlijst.
class MoestuinScreen extends StatefulWidget {
  const MoestuinScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.historyStore,
    required this.insectScanStore,
    required this.weatherPrefs,
    required this.aiSettings,
    this.taskStore,
    this.onGoToPlantScan,
    this.onGoToInsight,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final GardenHistoryStore historyStore;
  final InsectScanStore insectScanStore;
  final WeatherPrefsStore weatherPrefs;
  final AiSettingsStore aiSettings;
  final GardenPlannerTaskStore? taskStore;
  final void Function({String? vegetableId, bool harvestProbe})? onGoToPlantScan;
  final VoidCallback? onGoToInsight;

  @override
  State<MoestuinScreen> createState() => MoestuinScreenState();
}

class MoestuinScreenState extends State<MoestuinScreen> {
  MoestuinListFilter _filter = MoestuinListFilter.all;
  final _searchController = TextEditingController();
  String _searchQuery = '';
  Timer? _searchDebounce;
  int _bellCount = 0;
  bool _refreshPending = false;

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_refresh);
    widget.profileStore.addListener(_refresh);
    widget.profileStore.reactivatePlantsForSeason(
      gardenStore: widget.gardenStore,
      repository: widget.repository,
    ).then((_) => syncMoestuinSeasonActivation(
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
    )).then((changed) {
      if (!mounted || changed <= 0) return;
      syncGardenNotifications(
        profileStore: widget.profileStore,
        gardenStore: widget.gardenStore,
        repository: widget.repository,
        scanPrefs: widget.scanPrefs,
      );
    });
    _recomputeDerivedData();
  }

  @override
  void dispose() {
    widget.gardenStore.removeListener(_refresh);
    widget.profileStore.removeListener(_refresh);
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  bool get _isSearchActive => _searchController.text.trim().isNotEmpty;

  void _clearSearch() {
    _searchDebounce?.cancel();
    if (!_isSearchActive && _searchQuery.isEmpty) return;
    _searchController.clear();
    setState(() => _searchQuery = '');
    FocusManager.instance.primaryFocus?.unfocus();
  }

  /// Terug-knop: eerst zoekveld leegmaken. Geeft true als afgehandeld.
  bool handleSystemBack() {
    if (_isSearchActive) {
      _clearSearch();
      return true;
    }
    return false;
  }

  void _onSearchTextChanged(String value) {
    setState(() {});
    _searchDebounce?.cancel();
    if (value.trim().isEmpty) {
      if (_searchQuery.isNotEmpty) {
        setState(() => _searchQuery = '');
      }
      return;
    }
    _searchDebounce = Timer(const Duration(milliseconds: 280), () {
      if (!mounted) return;
      if (value == _searchQuery) return;
      setState(() => _searchQuery = value);
    });
  }

  void _recomputeDerivedData() {
    final month = DateTime.now().month;
    _bellCount = profilesWithActiveWarnings(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
    ).length;
  }

  void _refresh() {
    if (!mounted || _refreshPending) return;
    _refreshPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPending = false;
      if (!mounted) return;
      _recomputeDerivedData();
      setState(() {});
    });
  }

  Future<void> _openAddVegetable() async {
    final setup = await showAddPlantWizard(
      context,
      repository: widget.repository,
      aiSettings: widget.aiSettings,
      onOpenPlantsTab: widget.onGoToInsight == null
          ? null
          : () {
              Navigator.of(context).pop();
              widget.onGoToInsight!();
            },
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
    if (!added) {
      final veg = widget.repository.byId(setup.vegetableId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${veg?.nameNl ?? 'Plant'} staat al in je moestuin')),
      );
      return;
    }
    await syncGardenNotifications(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    await syncMoestuinSeasonActivation(
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
    );
    final veg = widget.repository.byId(setup.vegetableId);
    if (veg != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addPlantSuccessMessage(
              plantName: veg.nameNl,
              setup: setup,
              added: true,
              vegetable: veg,
            ),
          ),
        ),
      );
    }
  }

  void _openPestGuide() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const PestGuideScreen(),
      ),
    );
  }

  Future<void> _startNewMoestuin() async {
    final started = await confirmAndStartNewMoestuin(
      context,
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    if (!started || !mounted) return;
    setState(() {});
  }

  Future<void> _openMoestuinPlanner() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MoestuinVisualPlannerScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          taskStore: widget.taskStore,
        ),
      ),
    );
  }

  Future<void> _openCreateMoestuin() async {
    await showCreateMoestuinSheet(
      context,
      gardenStore: widget.gardenStore,
    );
    if (!mounted) return;
    setState(() {});
  }

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Moestuin history'),
          ),
          body: MyGardenHistoryPage(
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            repository: widget.repository,
            scanPrefs: widget.scanPrefs,
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openGardenManage() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MyGardenScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          weatherPrefs: widget.weatherPrefs,
          aiSettings: widget.aiSettings,
          onGoToPlantScan: widget.onGoToPlantScan,
        ),
      ),
    );
  }

  void _openWarnings(int month) {
    final warningEntries = profilesWithActiveWarnings(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
    );
    if (warningEntries.isEmpty) return;
    showGardenWarningsOverview(
      context: context,
      profileStore: widget.profileStore,
      repository: widget.repository,
      entries: warningEntries,
      actionEntries: const [],
      onOpenPlantDetail: (veg) => _openDetail(veg, month),
    );
  }

  void _showMenu(int month, int bellCount) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TuinierColors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Moestuin history'),
              onTap: () {
                Navigator.pop(ctx);
                _openHistory();
              },
            ),
            if (bellCount > 0)
              ListTile(
                leading: Icon(
                  Icons.notifications_outlined,
                  color: GardenWarningStyle.icon(Theme.of(ctx).colorScheme),
                ),
                title: Text('Meldingen ($bellCount)'),
                onTap: () {
                  Navigator.pop(ctx);
                  _openWarnings(month);
                },
              ),
            if (!widget.gardenStore.isEmpty)
              ListTile(
                leading: const Icon(Icons.refresh_rounded),
                title: const Text('Nieuwe moestuin'),
                onTap: () {
                  Navigator.pop(ctx);
                  _startNewMoestuin();
                },
              ),
            ListTile(
              leading: const Icon(Icons.tune),
              title: const Text('Instellingen'),
              onTap: () {
                Navigator.pop(ctx);
                _openGardenManage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.bug_report_outlined),
              title: const Text('Plagen & ziektes gids'),
              onTap: () {
                Navigator.pop(ctx);
                _openPestGuide();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleVegetableInGarden(Vegetable veg) async {
    if (widget.gardenStore.contains(veg.id)) {
      await widget.gardenStore.remove(veg.id);
      await widget.profileStore.removeProfile(veg.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${veg.nameNl} uit Mijn moestuin')),
      );
      return;
    }

    final setup = await showAddPlantSetupSheet(
      context,
      vegetable: veg,
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
    if (!added) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${veg.nameNl} staat al in je moestuin')),
      );
      return;
    }
    await syncGardenNotifications(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    await syncMoestuinSeasonActivation(
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
    );
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addPlantSuccessMessage(
            plantName: veg.nameNl,
            setup: setup,
            added: true,
            vegetable: veg,
          ),
        ),
      ),
    );
  }

  void _openDetail(
    Vegetable veg,
    int month, {
    bool openScanHistoryTab = false,
  }) {
    final inGarden = widget.gardenStore.contains(veg.id);
    if (inGarden) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => GardenPlantInsightScreen(
            vegetable: veg,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            gardenStore: widget.gardenStore,
            repository: widget.repository,
            initialSection: openScanHistoryTab
                ? GardenPlantInsightSection.scanHistory
                : GardenPlantInsightSection.insights,
            onGoToPlantScan: widget.onGoToPlantScan != null &&
                    widget.profileStore.profileFor(veg.id)?.isPlanted == true
                ? () => widget.onGoToPlantScan!(vegetableId: veg.id)
                : null,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(
          vegetable: veg,
          focusMonth: month,
          repository: widget.repository,
          presentation: VegetableDetailPresentation.encyclopedia,
        ),
      ),
    );
  }

  Widget _buildLeading(int month) {
    if (_isSearchActive) {
      return IconButton(
        tooltip: 'Terug naar moestuin',
        icon: const Icon(Icons.arrow_back),
        onPressed: _clearSearch,
      );
    }
    return IconButton(
      tooltip: 'Menu',
      icon: Badge(
        isLabelVisible: _bellCount > 0,
        backgroundColor: TuinierColors.error,
        smallSize: 8,
        child: const Icon(Icons.menu),
      ),
      onPressed: () => _showMenu(month, _bellCount),
    );
  }

  @override
  Widget build(BuildContext context) {
    final month = DateTime.now().month;
    final monthName = kMonthNamesNl[month];

    return Scaffold(
        backgroundColor: TuinierColors.background,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: AppBar(
            centerTitle: true,
            toolbarHeight: 60,
            backgroundColor: TuinierColors.background,
            foregroundColor: TuinierColors.textPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: _buildLeading(month),
            title: SizedBox(
              width: MediaQuery.sizeOf(context).width - 112,
              child: TuinSpaceSwitcher(
                gardenStore: widget.gardenStore,
                useTitleStyle: false,
                centered: true,
                onPlanMoestuin: _openMoestuinPlanner,
                onAddExistingMoestuin: _openCreateMoestuin,
              ),
            ),
          ),
        ),
        body: Stack(
          children: [
            Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
                  child: SizedBox(
                    height: 50,
                    child: ClearableSearchField(
                      controller: _searchController,
                      onChanged: _onSearchTextChanged,
                      hintText: 'Zoek een gewas...',
                      fillColor: TuinierDecorations.sectionCardFill,
                      borderRadius: 16,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      for (var i = 0;
                          i < MoestuinListFilter.values.length;
                          i++) ...[
                        if (i > 0) const SizedBox(width: 6),
                        Expanded(
                          child: _FilterChip(
                            label: MoestuinListFilter.values[i].label,
                            selected: _filter == MoestuinListFilter.values[i],
                            onTap: () => setState(
                              () => _filter = MoestuinListFilter.values[i],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Expanded(
                  child: MoestuinPlantListSection(
                    repository: widget.repository,
                    gardenStore: widget.gardenStore,
                    profileStore: widget.profileStore,
                    scanPrefs: widget.scanPrefs,
                    month: month,
                    monthName: monthName,
                    filter: _filter,
                    searchQuery: _searchQuery,
                    insectStore: widget.insectScanStore,
                    onOpenDetail: (veg, {openScanHistoryTab = false}) =>
                        _openDetail(
                      veg,
                      month,
                      openScanHistoryTab: openScanHistoryTab,
                    ),
                    onToggleInGarden: _toggleVegetableInGarden,
                    onGoToPlantScan: widget.onGoToPlantScan,
                    onMarkPlanted: (veg) => markVegetableAsPlanted(
                      context: context,
                      vegetable: veg,
                      profileStore: widget.profileStore,
                      scanPrefs: widget.scanPrefs,
                      onDone: () => syncGardenNotifications(
                        profileStore: widget.profileStore,
                        gardenStore: widget.gardenStore,
                        repository: widget.repository,
                        scanPrefs: widget.scanPrefs,
                      ),
                    ),
                    onMarkedPlanted: () => syncGardenNotifications(
                      profileStore: widget.profileStore,
                      gardenStore: widget.gardenStore,
                      repository: widget.repository,
                      scanPrefs: widget.scanPrefs,
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              right: 16,
              bottom: 12,
              child: FilledButton(
                onPressed: _openAddVegetable,
                child: const Icon(Icons.add, size: 22),
                style: FilledButton.styleFrom(
                  backgroundColor: TuinierColors.primary,
                  foregroundColor: Colors.white,
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  static const _chipPadding =
      EdgeInsets.symmetric(horizontal: 4, vertical: 9);

  @override
  Widget build(BuildContext context) {
    final labelWidget = Text(
      label,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: selected ? TuinierColors.card : TuinierColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
    );

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        splashColor: selected
            ? TuinierColors.card.withValues(alpha: 0.15)
            : TuinierColors.primary.withValues(alpha: 0.08),
        highlightColor: selected
            ? TuinierColors.card.withValues(alpha: 0.08)
            : TuinierColors.primary.withValues(alpha: 0.04),
        child: selected
            ? HomeGreenPattern(
                borderRadius: 14,
                child: Padding(
                  padding: _chipPadding,
                  child: SizedBox(
                    width: double.infinity,
                    child: labelWidget,
                  ),
                ),
              )
            : Container(
                width: double.infinity,
                padding: _chipPadding,
                decoration: BoxDecoration(
                  color: TuinierDecorations.sectionCardFill,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: labelWidget,
              ),
      ),
    );
  }
}

/// Filter op groeifase voor de moestuinlijst.
enum MoestuinListFilter {
  all('Alle'),
  seedling('Zaailingen'),
  growing('Groeiend'),
  harvestable('Oogstbaar');

  const MoestuinListFilter(this.label);
  final String label;

  bool matches(GardenPlantProfile? profile) {
    if (this == MoestuinListFilter.all) return true;
    final phase = profile?.lastAnalysis?.phase;
    if (phase == null) return this == MoestuinListFilter.seedling;
    switch (this) {
      case MoestuinListFilter.all:
        return true;
      case MoestuinListFilter.seedling:
        return phase == PlantAiPhase.seedling;
      case MoestuinListFilter.growing:
        return phase == PlantAiPhase.growing ||
            phase == PlantAiPhase.flowering ||
            phase == PlantAiPhase.fruiting;
      case MoestuinListFilter.harvestable:
        return phase == PlantAiPhase.almostRipe ||
            phase == PlantAiPhase.ripe ||
            profile?.lastAnalysis?.insight?.harvestReady == true;
    }
  }
}
