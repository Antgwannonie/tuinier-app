import 'package:flutter/material.dart';

import '../data/ai_settings_store.dart';
import '../data/calendar_display_prefs_store.dart';
import '../data/daily_tip_prefs_store.dart';
import '../data/garden_history_store.dart';
import '../data/garden_notes_store.dart';
import '../data/garden_planner_task_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/insect_scan_store.dart';
import '../data/weed_scan_store.dart';
import '../data/my_garden_store.dart';
import '../data/recipe_notification_store.dart';
import '../data/vegetable_repository.dart';
import '../data/weather_prefs_store.dart';
import '../widgets/tuinier_bottom_nav.dart';
import 'dashboard_home_screen.dart';
import 'planner_home_screen.dart';
import 'vegetable_list_screen.dart';
import '../data/moestuin_pinned_action.dart';
import 'moestuin_screen.dart';
import 'scan_hub_screen.dart';

/// Hoofdscherm met vaste ondernavigatie (nieuw ontwerp).
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.weatherPrefs,
    required this.aiSettings,
    required this.scanPrefs,
    required this.calendarPrefs,
    required this.recipeNotificationStore,
    required this.notesStore,
    required this.historyStore,
    required this.plannerTaskStore,
    required this.insectScanStore,
    required this.weedScanStore,
    required this.dailyTipPrefs,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final WeatherPrefsStore weatherPrefs;
  final AiSettingsStore aiSettings;
  final GardenScanPrefsStore scanPrefs;
  final CalendarDisplayPrefsStore calendarPrefs;
  final RecipeNotificationStore recipeNotificationStore;
  final GardenNotesStore notesStore;
  final GardenHistoryStore historyStore;
  final GardenPlannerTaskStore plannerTaskStore;
  final InsectScanStore insectScanStore;
  final WeedScanStore weedScanStore;
  final DailyTipPrefsStore dailyTipPrefs;

  @override
  State<MainShellScreen> createState() => MainShellScreenState();
}

class MainShellScreenState extends State<MainShellScreen> {
  int _tabIndex = 0;
  final List<int> _tabHistory = [TuinierBottomNav.tabDashboard];
  final GlobalKey<MoestuinScreenState> _moestuinKey =
      GlobalKey<MoestuinScreenState>();
  final GlobalKey<VegetableListScreenState> _plantsListKey =
      GlobalKey<VegetableListScreenState>();
  String? _scanVegetableId;
  bool _scanHarvestProbe = false;

  @override
  void initState() {
    super.initState();
    bumpMoestuinCountdownRotation();
  }

  static const int tabScan = TuinierBottomNav.tabScan;

  void goToPlantScan({String? vegetableId, bool harvestProbe = false}) {
    setState(() {
      if (_tabIndex != tabScan) {
        _tabHistory.add(tabScan);
      }
      _tabIndex = tabScan;
      _scanVegetableId = vegetableId;
      _scanHarvestProbe = harvestProbe;
    });
  }

  void goToPlantsTab() => _goToTab(TuinierBottomNav.tabPlants);

  void goToInsightTab() => goToPlantsTab();

  void goToMoestuinTab() => _goToTab(TuinierBottomNav.tabMoestuin);

  void goToPlannerTab() => _goToTab(TuinierBottomNav.tabPlanner);

  void _goToTab(int index) {
    if (index == _tabIndex) return;
    if (_tabIndex == TuinierBottomNav.tabPlants &&
        index != TuinierBottomNav.tabPlants) {
      _plantsListKey.currentState?.resetBrowseState();
    }
    if (index == TuinierBottomNav.tabMoestuin) {
      bumpMoestuinCountdownRotation();
    }
    setState(() {
      _tabHistory.add(index);
      _tabIndex = index;
      if (index != tabScan) {
        _scanVegetableId = null;
        _scanHarvestProbe = false;
      }
    });
  }

  void _handleSystemBack() {
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
      return;
    }

    if (_tabIndex == TuinierBottomNav.tabMoestuin &&
        (_moestuinKey.currentState?.handleSystemBack() ?? false)) {
      return;
    }

    if (_tabHistory.length > 1) {
      _tabHistory.removeLast();
      final previous = _tabHistory.last;
      if (_tabIndex == TuinierBottomNav.tabPlants &&
          previous != TuinierBottomNav.tabPlants) {
        _plantsListKey.currentState?.resetBrowseState();
      }
      setState(() {
        _tabIndex = previous;
        if (previous != tabScan) {
          _scanVegetableId = null;
          _scanHarvestProbe = false;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleSystemBack();
      },
      child: Scaffold(
      body: IndexedStack(
        index: _tabIndex,
        children: [
          DashboardHomeScreen(
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            insectScanStore: widget.insectScanStore,
            weatherPrefs: widget.weatherPrefs,
            aiSettings: widget.aiSettings,
            onGoToMoestuin: goToMoestuinTab,
            onGoToPlantScan: ({String? vegetableId}) =>
                goToPlantScan(vegetableId: vegetableId),
            onGoToPlanner: goToPlannerTab,
          ),
          MoestuinScreen(
            key: _moestuinKey,
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            historyStore: widget.historyStore,
            insectScanStore: widget.insectScanStore,
            weatherPrefs: widget.weatherPrefs,
            aiSettings: widget.aiSettings,
            taskStore: widget.plannerTaskStore,
            onGoToPlantScan: goToPlantScan,
            onGoToInsight: goToPlantsTab,
          ),
          ScanHubScreen(
            key: ValueKey('${_scanVegetableId ?? 'scan'}_$_scanHarvestProbe'),
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            aiSettings: widget.aiSettings,
            scanPrefs: widget.scanPrefs,
            notesStore: widget.notesStore,
            insectScanStore: widget.insectScanStore,
            weedScanStore: widget.weedScanStore,
            initialVegetableId: _scanVegetableId,
            initialHarvestProbe: _scanHarvestProbe,
          ),
          PlannerHomeScreen(
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            notesStore: widget.notesStore,
            taskStore: widget.plannerTaskStore,
            historyStore: widget.historyStore,
            scanPrefs: widget.scanPrefs,
            calendarPrefs: widget.calendarPrefs,
          ),
          VegetableListScreen(
            key: _plantsListKey,
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            aiSettings: widget.aiSettings,
            embedded: true,
          ),
        ],
      ),
      bottomNavigationBar: TuinierBottomNav(
        selectedIndex: _tabIndex,
        onSelected: _goToTab,
      ),
      ),
    );
  }
}
