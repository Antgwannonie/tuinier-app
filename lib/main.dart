import 'package:flutter/material.dart';

import 'data/ai_settings_store.dart';
import 'data/garden_profile_store.dart';
import 'data/my_garden_store.dart';
import 'data/vegetable_repository.dart';
import 'data/garden_notification_service.dart';
import 'data/garden_notifications_sync.dart';
import 'data/garden_scan_prefs_store.dart';
import 'data/weather_notification_service.dart';
import 'data/weather_prefs_store.dart';
import 'screens/main_shell_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final repository = VegetableRepository();
  final gardenStore = MyGardenStore();
  final profileStore = GardenProfileStore();
  final weatherPrefs = WeatherPrefsStore();
  final aiSettings = AiSettingsStore();
  final scanPrefs = GardenScanPrefsStore();
  await WeatherNotificationService.instance.init();
  await GardenNotificationService.instance.init();
  await gardenStore.load();
  await profileStore.load();
  await weatherPrefs.load();
  await aiSettings.load();
  await scanPrefs.load();
  await syncGardenNotifications(
    profileStore: profileStore,
    gardenStore: gardenStore,
    repository: repository,
    scanPrefs: scanPrefs,
  );
  runApp(TuinierApp(
    repository: repository,
    gardenStore: gardenStore,
    profileStore: profileStore,
    weatherPrefs: weatherPrefs,
    aiSettings: aiSettings,
    scanPrefs: scanPrefs,
  ));
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
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final WeatherPrefsStore weatherPrefs;
  final AiSettingsStore aiSettings;
  final GardenScanPrefsStore scanPrefs;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tuinier',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2E7D32),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF66BB6A),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      home: MainShellScreen(
        repository: repository,
        gardenStore: gardenStore,
        profileStore: profileStore,
        weatherPrefs: weatherPrefs,
        aiSettings: aiSettings,
        scanPrefs: scanPrefs,
      ),
    );
  }
}
