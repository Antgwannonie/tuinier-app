import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/insect_scan_store.dart';
import '../data/add_plant_apply.dart';
import '../data/ai_settings_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/plant_season_activation.dart';
import '../data/garden_history_store.dart';
import '../data/my_garden_store.dart';
import '../data/home_task_timing.dart';
import '../data/planting_calendar.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/weather_prefs_store.dart';
import '../data/garden_plant_schedule.dart';
import '../widgets/home_moestuin_actions.dart';
import '../data/plant_health_warnings.dart';
import '../widgets/home_moestuin_section.dart';
import '../widgets/start_new_moestuin.dart';
import '../widgets/garden_warning_style.dart';
import '../widgets/my_garden_history_page.dart';
import '../widgets/plant_health_warning_sheet.dart';
import '../widgets/tuin_space_switcher.dart';
import '../widgets/add_plant_wizard_screen.dart';
import 'my_garden_screen.dart';
import 'vegetable_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.historyStore,
    required this.insectScanStore,
    required this.aiSettings,
    required this.weatherPrefs,
    this.onGoToPlantScan,
    this.onGoToInsight,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final GardenHistoryStore historyStore;
  final InsectScanStore insectScanStore;
  final AiSettingsStore aiSettings;
  final WeatherPrefsStore weatherPrefs;
  final void Function({String? vegetableId, bool harvestProbe})? onGoToPlantScan;
  final VoidCallback? onGoToInsight;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _refreshPending = false;

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

  void _onGardenChanged() {
    if (!mounted || _refreshPending) return;
    _refreshPending = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _refreshPending = false;
      if (!mounted) return;
      setState(() {});
    });
  }

  Future<void> _openAddVegetable() async {
    final setup = await showAddPlantWizard(
      context,
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
    final veg = widget.repository.byId(setup.vegetableId);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addPlantSuccessMessage(
            plantName: veg?.nameNl ?? 'Plant',
            setup: setup,
            added: added,
            vegetable: veg,
          ),
        ),
        duration: const Duration(seconds: 2),
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

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          appBar: AppBar(
            centerTitle: true,
            title: Text(
              'Moestuin history',
              style: Theme.of(ctx).appBarTheme.titleTextStyle,
            ),
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

  Map<String, HomeTaskEntry> _taskEntriesByVegetable(int month) {
    return homeTaskEntriesByVegetableForMonth(
      month: month,
      vegetableIds: widget.gardenStore.ids,
      useAiFor: widget.gardenStore.contains,
      profileFor: widget.profileStore.profileFor,
      vegetableById: widget.repository.byId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final month = DateTime.now().month;
    final monthName = kMonthNamesNl[month];
    final taskEntriesById = _taskEntriesByVegetable(month);

    final actionsNow = collectGardenHomeActions(
      repository: widget.repository,
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      scanPrefs: widget.scanPrefs,
      month: month,
    );
    final warningEntries = profilesWithActiveWarnings(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
    );
    final warningIds = warningEntries.map((e) => e.vegetable.id).toSet();
    final actionById = <String, GardenHomeAction>{};
    for (final action in actionsNow) {
      actionById.putIfAbsent(action.vegetable.id, () => action);
    }
    final actionBellEntries = <GardenBellActionEntry>[];
    final bellVegetableIds = <String>{};

    for (final action in actionsNow) {
      if (action.kind != GardenHomeActionKind.firstPhoto) continue;
      final id = action.vegetable.id;
      if (warningIds.contains(id)) continue;
      if (!bellVegetableIds.add(id)) continue;
      actionBellEntries.add(
        GardenBellActionEntry(
          vegetable: action.vegetable,
          message: kFirstScanMotivationMessage,
        ),
      );
    }

    for (final e in taskEntriesById.values) {
      if (!e.timing.isActiveNow) continue;
      final veg = widget.repository.byId(e.vegetableId);
      if (veg == null) continue;
      if (warningIds.contains(veg.id)) continue;
      if (!bellVegetableIds.add(veg.id)) continue;
      final action = actionById[veg.id];
      actionBellEntries.add(
        GardenBellActionEntry(
          vegetable: veg,
          message: action != null && action.subtitle.isNotEmpty
              ? 'Taak nu: ${action.subtitle}'
              : 'Taak nu: ${e.activity.type.label}',
        ),
      );
    }
    final bellCount = warningEntries.length + actionBellEntries.length;

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: widget.gardenStore.isEmpty ? 48 : 88,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Moestuin history',
              visualDensity: VisualDensity.compact,
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: const Icon(Icons.history),
              onPressed: _openHistory,
            ),
            if (!widget.gardenStore.isEmpty)
              IconButton(
                tooltip: 'Nieuwe moestuin',
                visualDensity: VisualDensity.compact,
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _startNewMoestuin,
              ),
          ],
        ),
        title: TuinSpaceSwitcher(gardenStore: widget.gardenStore),
        actions: [
          if (bellCount > 0)
            IconButton(
              tooltip: 'Meldingen ($bellCount)',
              onPressed: () {
                showGardenWarningsOverview(
                  context: context,
                  profileStore: widget.profileStore,
                  repository: widget.repository,
                  entries: warningEntries,
                  actionEntries: actionBellEntries,
                  onOpenPlantDetail: (veg) => _openDetail(veg, month),
                );
              },
              icon: Badge(
                backgroundColor:
                    GardenWarningStyle.badgeSolid(Theme.of(context).colorScheme),
                label: Text(
                  '$bellCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: GardenWarningStyle.icon(Theme.of(context).colorScheme),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Instellingen',
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
        padding: const EdgeInsets.only(bottom: 88),
        children: [
          HomeMoestuinSection(
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            insectStore: widget.insectScanStore,
            onOpenInsight: widget.onGoToInsight,
            month: month,
            monthName: monthName,
            taskEntriesById: taskEntriesById,
            taskIconFor: _taskIcon,
            onAddPlant: _openAddVegetable,
            onOpenDetail: (veg, {openScanHistoryTab = false}) =>
                _openDetail(
                  veg,
                  month,
                  openScanHistoryTab: openScanHistoryTab,
                ),
            onGoToPlantScan: widget.onGoToPlantScan,
            onMarkedPlanted: () => syncGardenNotifications(
              profileStore: widget.profileStore,
              gardenStore: widget.gardenStore,
              repository: widget.repository,
              scanPrefs: widget.scanPrefs,
            ),
          ),
        ],
      ),
    );
  }

  IconData _taskIcon(GardenTaskType type) {
    switch (type) {
      case GardenTaskType.plantOutdoors:
        return Icons.yard_outlined;
      case GardenTaskType.sowOutdoors:
        return Icons.grass_outlined;
      case GardenTaskType.preSow:
        return Icons.spa_outlined;
      case GardenTaskType.harvest:
        return Icons.shopping_basket_outlined;
    }
  }

  void _openDetail(
    Vegetable veg,
    int month, {
    bool openScanHistoryTab = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(
          vegetable: veg,
          focusMonth: month,
          gardenStore: widget.gardenStore,
          repository: widget.repository,
          profileStore: widget.gardenStore.contains(veg.id)
              ? widget.profileStore
              : null,
          scanPrefs: widget.scanPrefs,
          initialSection: openScanHistoryTab
              ? VegetableDetailSection.scanHistory
              : VegetableDetailSection.info,
          onGoToPlantScan: widget.gardenStore.contains(veg.id) &&
                  widget.onGoToPlantScan != null
              ? () => widget.onGoToPlantScan!(vegetableId: veg.id)
              : null,
        ),
      ),
    );
  }
}
