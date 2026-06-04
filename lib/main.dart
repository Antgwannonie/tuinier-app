import 'package:flutter/material.dart';

import 'data/ai_settings_store.dart';
import 'data/garden_notes_store.dart';
import 'data/garden_history_store.dart';
import 'data/garden_profile_store.dart';
import 'data/my_garden_store.dart';
import 'data/vegetable_repository.dart';
import 'data/garden_notification_service.dart';
import 'data/garden_notifications_sync.dart';
import 'data/calendar_display_prefs_store.dart';
import 'data/plant_image_frame_prefs_store.dart';
import 'data/garden_scan_prefs_store.dart';
import 'data/recipe_notification_store.dart';
import 'data/weather_notification_service.dart';
import 'data/weather_prefs_store.dart';
import 'screens/main_shell_screen.dart';
import 'theme/tuinier_theme.dart';
import 'widgets/plant_image_frame_scope.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = VegetableRepository();
  final gardenStore = MyGardenStore();
  final profileStore = GardenProfileStore();
  final weatherPrefs = WeatherPrefsStore();
  final aiSettings = AiSettingsStore();
  final scanPrefs = GardenScanPrefsStore();
  final calendarPrefs = CalendarDisplayPrefsStore();
  final plantImageFramePrefs = PlantImageFramePrefsStore();
  final recipeNotificationStore = RecipeNotificationStore();
  final notesStore = GardenNotesStore();
  final historyStore = GardenHistoryStore();
  await WeatherNotificationService.instance.init();
  await GardenNotificationService.instance.init();
  await gardenStore.load();
  await profileStore.load();
  await notesStore.load();
  await historyStore.load();
  await profileStore.migrateLegacyHarvestedOutOfGarden(gardenStore);
  await weatherPrefs.load();
  await aiSettings.load();
  await scanPrefs.load();
  await calendarPrefs.load();
  await plantImageFramePrefs.load();
  await recipeNotificationStore.load();
  await syncGardenNotifications(
    profileStore: profileStore,
    gardenStore: gardenStore,
    repository: repository,
    scanPrefs: scanPrefs,
    notesStore: notesStore,
  );
  runApp(
    PlantImageFrameScope(
      store: plantImageFramePrefs,
      child: TuinierApp(
        repository: repository,
        gardenStore: gardenStore,
        profileStore: profileStore,
        weatherPrefs: weatherPrefs,
        aiSettings: aiSettings,
        scanPrefs: scanPrefs,
        calendarPrefs: calendarPrefs,
        recipeNotificationStore: recipeNotificationStore,
        notesStore: notesStore,
        historyStore: historyStore,
      ),
    ),
  );
}

class TuinierApp extends StatelessWidget {
  const TuinierApp({
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
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuinier',
      debugShowCheckedModeBanner: false,
      theme: buildTuinierTheme(brightness: Brightness.light),
      darkTheme: buildTuinierTheme(brightness: Brightness.dark),
      themeMode: ThemeMode.system,
      home: MainShellScreen(
        repository: repository,
        gardenStore: gardenStore,
        profileStore: profileStore,
        weatherPrefs: weatherPrefs,
        aiSettings: aiSettings,
        scanPrefs: scanPrefs,
        calendarPrefs: calendarPrefs,
        recipeNotificationStore: recipeNotificationStore,
        notesStore: notesStore,
        historyStore: historyStore,
      ),
    );
  }
}
