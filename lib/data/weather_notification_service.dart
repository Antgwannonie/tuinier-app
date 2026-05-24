import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'garden_weather_advice.dart';
import 'weather_service.dart';

/// Lokale meldingen bij slecht of extreem tuinweer.
class WeatherNotificationService {
  WeatherNotificationService._();
  static final WeatherNotificationService instance =
      WeatherNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const _lastNotifyKey = 'weather_last_notify_day';

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> maybeNotify({
    required WeatherForecast forecast,
    required bool enabled,
  }) async {
    if (!enabled) return;

    final tips = gardenTipsFromForecast(forecast);
    if (!hasUrgentGardenWeather(tips) &&
        !tips.any((t) => t.level == GardenWeatherLevel.watch)) {
      return;
    }

    final todayKey = _dayKey(DateTime.now());
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString(_lastNotifyKey) == todayKey) return;

    final summary = notificationSummary(tips);
    final body = tips.first.body;

    await _plugin.show(
      1001,
      'Tuinier weer — ${forecast.placeName}',
      '$summary\n$body',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'tuinier_weer',
          'Weer voor je moestuin',
          channelDescription:
              'Waarschuwingen bij hitte, vorst, storm of veel regen.',
          importance: Importance.high,
          priority: Priority.high,
        ),
      ),
    );

    await prefs.setString(_lastNotifyKey, todayKey);
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
