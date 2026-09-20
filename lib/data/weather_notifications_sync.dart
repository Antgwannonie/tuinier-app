import 'ai_settings_store.dart';
import 'garden_profile_store.dart';
import 'my_garden_store.dart';
import 'vegetable_repository.dart';
import 'weather_notification_service.dart';
import 'weather_prefs_store.dart';

/// Plant weer-meldingen opnieuw in (dagelijkse AI-samenvatting).
Future<void> syncWeatherNotifications({
  required WeatherPrefsStore weatherPrefs,
  required AiSettingsStore aiSettings,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
}) {
  return WeatherNotificationService.instance.sync(
    enabled: weatherPrefs.notificationsEnabled,
    lat: weatherPrefs.lat,
    lon: weatherPrefs.lon,
    placeName: weatherPrefs.placeName,
    apiKey: aiSettings.apiKey,
    gardenIds: gardenStore.ids,
    profileStore: profileStore,
    repository: repository,
    gardenName: gardenStore.activeSpace?.name,
  );
}
