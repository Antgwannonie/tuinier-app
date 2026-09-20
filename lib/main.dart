import 'package:flutter/material.dart';

import 'data/ai_settings_store.dart';
import 'data/garden_notes_store.dart';
import 'data/garden_history_store.dart';
import 'data/garden_planner_task_store.dart';
import 'data/insect_scan_store.dart';
import 'data/weed_scan_store.dart';
import 'data/garden_profile_store.dart';
import 'data/my_garden_store.dart';
import 'data/vegetable_repository.dart';
import 'data/garden_notification_service.dart';
import 'data/garden_notifications_sync.dart';
import 'data/plant_season_activation.dart';
import 'data/calendar_display_prefs_store.dart';
import 'data/plant_image_frame_prefs_store.dart';
import 'data/garden_scan_prefs_store.dart';
import 'data/recipe_notification_store.dart';
import 'data/daily_tip_notification_service.dart';
import 'data/daily_tip_prefs_store.dart';
import 'data/weather_notification_service.dart';
import 'data/weather_notifications_sync.dart';
import 'data/weather_prefs_store.dart';
import 'navigation/tuinier_shell_navigation.dart';
import 'screens/main_shell_screen.dart';
import 'theme/tuinier_theme.dart';
import 'widgets/plant_image_frame_scope.dart';
import 'widgets/tuinier_scan_stores_scope.dart';

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
  final plannerTaskStore = GardenPlannerTaskStore();
  final insectScanStore = InsectScanStore();
  final weedScanStore = WeedScanStore();
  final dailyTipPrefs = DailyTipPrefsStore();
  await WeatherNotificationService.instance.init();
  await GardenNotificationService.instance.init();
  await DailyTipNotificationService.instance.init();
  await gardenStore.load();
  await profileStore.load();
  await notesStore.load();
  await historyStore.load();
  await plannerTaskStore.load();
  await insectScanStore.load();
  await weedScanStore.load();
  await profileStore.migrateLegacyHarvestedOutOfGarden(gardenStore);
  await profileStore.reactivatePlantsForSeason(
    gardenStore: gardenStore,
    repository: repository,
  );
  await syncMoestuinSeasonActivation(
    gardenStore: gardenStore,
    profileStore: profileStore,
    repository: repository,
  );
  await profileStore.syncArchivedTuinSpaces(gardenStore);
  await profileStore.purgeIneligibleArchivedProfiles();
  await weatherPrefs.load();
  await aiSettings.load();
  await scanPrefs.load();
  await calendarPrefs.load();
  await plantImageFramePrefs.load();
  await recipeNotificationStore.load();
  await dailyTipPrefs.load();
  await syncGardenNotifications(
    profileStore: profileStore,
    gardenStore: gardenStore,
    repository: repository,
    scanPrefs: scanPrefs,
    notesStore: notesStore,
  );
  await DailyTipNotificationService.instance.sync(
    enabled: dailyTipPrefs.notificationsEnabled,
  );
  await syncWeatherNotifications(
    weatherPrefs: weatherPrefs,
    aiSettings: aiSettings,
    gardenStore: gardenStore,
    profileStore: profileStore,
    repository: repository,
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
        plannerTaskStore: plannerTaskStore,
        insectScanStore: insectScanStore,
        weedScanStore: weedScanStore,
        dailyTipPrefs: dailyTipPrefs,
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
  Widget build(BuildContext context) {
    return TuinierScanStoresScope(
      insectScanStore: insectScanStore,
      weedScanStore: weedScanStore,
      child: MaterialApp(
        title: 'Tuinier',
        debugShowCheckedModeBanner: false,
        theme: buildTuinierTheme(brightness: Brightness.light),
        darkTheme: buildTuinierTheme(brightness: Brightness.light),
        themeMode: ThemeMode.light,
        home: MainShellScreen(
          key: mainShellKey,
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
          plannerTaskStore: plannerTaskStore,
          insectScanStore: insectScanStore,
          weedScanStore: weedScanStore,
          dailyTipPrefs: dailyTipPrefs,
        ),
      ),
    );
  }
}
