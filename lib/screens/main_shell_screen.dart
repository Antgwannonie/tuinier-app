import 'package:flutter/material.dart';

import '../data/ai_settings_store.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/weather_prefs_store.dart';
import 'garden_calendar_screen.dart';
import 'home_screen.dart';
import 'my_garden_screen.dart';
import 'plant_scan_screen.dart';
import 'weather_screen.dart';

/// Hoofdscherm met ondernavigatie.
/// Ondermenu klapt in bij naar beneden scrollen (zoals X), komt terug bij omhoog.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.weatherPrefs,
    required this.aiSettings,
    required this.scanPrefs,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final WeatherPrefsStore weatherPrefs;
  final AiSettingsStore aiSettings;
  final GardenScanPrefsStore scanPrefs;

  @override
  State<MainShellScreen> createState() => MainShellScreenState();
}

class MainShellScreenState extends State<MainShellScreen> {
  int _tabIndex = 0;
  bool _navBarVisible = true;
  String? _scanVegetableId;

  static const int tabScan = 3;

  void goToPlantScan({String? vegetableId}) {
    setState(() {
      _tabIndex = tabScan;
      _scanVegetableId = vegetableId;
      _navBarVisible = true;
    });
  }

  void _goToTab(int index) {
    setState(() {
      _tabIndex = index;
      if (index != tabScan) _scanVegetableId = null;
      _navBarVisible = true;
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (notification.metrics.axis != Axis.vertical) return false;

    if (notification is ScrollUpdateNotification) {
      final delta = notification.scrollDelta ?? 0;
      if (delta > 4 &&
          notification.metrics.pixels > 48 &&
          _navBarVisible) {
        setState(() => _navBarVisible = false);
      } else if (delta < -4 && !_navBarVisible) {
        setState(() => _navBarVisible = true);
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final navHeight = MediaQuery.paddingOf(context).bottom + 80;

    return Scaffold(
      body: NotificationListener<ScrollNotification>(
        onNotification: _onScroll,
        child: IndexedStack(
          index: _tabIndex,
          children: [
            HomeScreen(
              repository: widget.repository,
              gardenStore: widget.gardenStore,
              profileStore: widget.profileStore,
              scanPrefs: widget.scanPrefs,
              onGoToPlantScan: goToPlantScan,
            ),
            GardenCalendarScreen(
              repository: widget.repository,
              gardenStore: widget.gardenStore,
              profileStore: widget.profileStore,
              scanPrefs: widget.scanPrefs,
              initialMonth: now.month,
              initialYear: now.year,
              embedded: true,
            ),
            WeatherScreen(weatherPrefs: widget.weatherPrefs),
            PlantScanScreen(
              key: ValueKey(_scanVegetableId ?? 'scan'),
              repository: widget.repository,
              gardenStore: widget.gardenStore,
              profileStore: widget.profileStore,
              aiSettings: widget.aiSettings,
              scanPrefs: widget.scanPrefs,
              initialVegetableId: _scanVegetableId,
            ),
            MyGardenScreen(
              repository: widget.repository,
              gardenStore: widget.gardenStore,
              profileStore: widget.profileStore,
              scanPrefs: widget.scanPrefs,
              onGoToPlantScan: goToPlantScan,
            ),
          ],
        ),
      ),
      bottomNavigationBar: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        height: _navBarVisible ? navHeight : 0,
        child: ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            child: NavigationBar(
              selectedIndex: _tabIndex,
              onDestinationSelected: _goToTab,
              destinations: const [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined),
                  selectedIcon: Icon(Icons.home),
                  label: 'Start',
                ),
                NavigationDestination(
                  icon: Icon(Icons.calendar_month_outlined),
                  selectedIcon: Icon(Icons.calendar_month),
                  label: 'Kalender',
                ),
                NavigationDestination(
                  icon: Icon(Icons.cloud_outlined),
                  selectedIcon: Icon(Icons.cloud),
                  label: 'Weer',
                ),
                NavigationDestination(
                  icon: Icon(Icons.photo_camera_outlined),
                  selectedIcon: Icon(Icons.photo_camera),
                  label: 'Scan',
                ),
                NavigationDestination(
                  icon: Icon(Icons.yard_outlined),
                  selectedIcon: Icon(Icons.yard),
                  label: 'Moestuin',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
