import 'package:flutter/material.dart';



import '../data/ai_settings_store.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_history_store.dart';

import '../data/my_garden_store.dart';

import '../data/vegetable_repository.dart';

import '../data/garden_notes_store.dart';
import '../data/calendar_display_prefs_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/recipe_notification_store.dart';

import '../data/weather_prefs_store.dart';

import 'garden_notes_hub_screen.dart';

import 'home_screen.dart';

import 'plant_scan_screen.dart';

import 'vegetable_list_screen.dart';

import 'weather_screen.dart';

import '../widgets/tuinier_bottom_nav.dart';



/// Hoofdscherm met vaste ondernavigatie.

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



  @override

  State<MainShellScreen> createState() => MainShellScreenState();

}



class MainShellScreenState extends State<MainShellScreen> {

  int _tabIndex = 0;

  String? _scanVegetableId;
  bool _scanHarvestProbe = false;

  static const int tabScan = TuinierBottomNav.tabScan;

  void goToPlantScan({String? vegetableId, bool harvestProbe = false}) {
    setState(() {
      _tabIndex = tabScan;
      _scanVegetableId = vegetableId;
      _scanHarvestProbe = harvestProbe;
    });
  }



  void _goToTab(int index) {

    setState(() {

      _tabIndex = index;

      if (index != tabScan) {
        _scanVegetableId = null;
        _scanHarvestProbe = false;
      }

    });

  }



  @override

  Widget build(BuildContext context) {

    return Scaffold(

      body: IndexedStack(

        index: _tabIndex,

        children: [

          HomeScreen(

            repository: widget.repository,

            gardenStore: widget.gardenStore,

            profileStore: widget.profileStore,

            scanPrefs: widget.scanPrefs,

            recipeNotificationStore: widget.recipeNotificationStore,

            onGoToPlantScan: goToPlantScan,
            historyStore: widget.historyStore,

          ),

          GardenNotesHubScreen(
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            calendarPrefs: widget.calendarPrefs,
            notesStore: widget.notesStore,
          ),

          PlantScanScreen(
            key: ValueKey('${_scanVegetableId ?? 'scan'}_$_scanHarvestProbe'),
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            aiSettings: widget.aiSettings,
            scanPrefs: widget.scanPrefs,
            notesStore: widget.notesStore,
            initialVegetableId: _scanVegetableId,
            initialHarvestProbe: _scanHarvestProbe,
          ),

          VegetableListScreen(
            repository: widget.repository,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            embedded: true,
          ),

          WeatherScreen(weatherPrefs: widget.weatherPrefs),

        ],

      ),

      bottomNavigationBar: TuinierBottomNav(
        selectedIndex: _tabIndex,
        onSelected: _goToTab,
      ),

    );

  }

}


