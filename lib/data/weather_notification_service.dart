import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'garden_profile_store.dart';
import 'garden_weather_advice.dart';
import 'garden_weather_coach_service.dart';
import 'vegetable_repository.dart';
import 'weather_service.dart';

/// Lokale meldingen: dagelijkse weersvoorspelling + AI-samenvatting voor de moestuin.
class WeatherNotificationService {
  WeatherNotificationService._();
  static final WeatherNotificationService instance =
      WeatherNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final WeatherService _weatherService = WeatherService();

  bool _ready = false;

  static const _scheduledId = 1001;
  static const _channelId = 'tuinier_weer';
  static const _lastNotifyKey = 'weather_last_notify_day';

  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await _plugin.initialize(settings);

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    const channel = AndroidNotificationChannel(
      _channelId,
      'Weer voor je moestuin',
      description:
          'Dagelijkse weersvoorspelling met AI-advies voor je moestuin.',
      importance: Importance.high,
    );
    await androidPlugin?.createNotificationChannel(channel);
    _ready = true;
  }

  /// Dagelijkse melding (07:30) + direct tonen bij eerste app-start na die tijd.
  Future<void> sync({
    required bool enabled,
    required double lat,
    required double lon,
    required String placeName,
    required String apiKey,
    required Iterable<String> gardenIds,
    required GardenProfileStore profileStore,
    required VegetableRepository repository,
    String? gardenName,
  }) async {
    await init();
    await _plugin.cancel(_scheduledId);

    if (!enabled) return;

    try {
      final forecast = await _weatherService.fetch(
        lat: lat,
        lon: lon,
        placeName: placeName,
      );
      final tips = gardenTipsFromForecast(forecast);
      final cropNames = plantedCropNamesForGarden(
        gardenIds: gardenIds,
        nameForId: (id) => repository.byId(id)?.nameNl,
        isPlanted: (id) => profileStore.profileFor(id)?.isPlanted ?? false,
      );
      final coach = await GardenWeatherCoachService(apiKey: apiKey)
          .coachForGarden(
        forecast: forecast,
        tips: tips,
        plantedCropNames: cropNames,
        gardenName: gardenName,
      );

      final title = _titleFor(coach, placeName);
      final body = _bodyFor(coach);
      final importance =
          coach.requiresAction ? Importance.max : Importance.high;
      final priority = coach.requiresAction ? Priority.max : Priority.high;

      final now = DateTime.now();
      final prefs = await SharedPreferences.getInstance();
      final todayKey = _dayKey(now);
      final morning = DateTime(now.year, now.month, now.day, 7, 30);

      if (now.isAfter(morning) && prefs.getString(_lastNotifyKey) != todayKey) {
        await _show(
          title: title,
          body: body,
          importance: importance,
          priority: priority,
        );
        await prefs.setString(_lastNotifyKey, todayKey);
      }

      var next = morning;
      if (!next.isAfter(now)) {
        next = next.add(const Duration(days: 1));
      }

      await _plugin.zonedSchedule(
        _scheduledId,
        title,
        body,
        tz.TZDateTime.from(next, tz.local),
        NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            'Weer voor je moestuin',
            channelDescription:
                'Dagelijkse weersvoorspelling met AI-advies voor je moestuin.',
            importance: importance,
            priority: priority,
          ),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } catch (_) {
      // Geen melding bij netwerk/API-fout.
    }
  }

  String _titleFor(GardenWeatherCoachBrief coach, String placeName) {
    if (coach.requiresAction) {
      return 'Tuinweer · taak nodig · $placeName';
    }
    return 'Tuinweer vandaag · $placeName';
  }

  String _bodyFor(GardenWeatherCoachBrief coach) {
    final parts = <String>[coach.summary.trim()];
    if (coach.requiresAction && coach.actionLines.isNotEmpty) {
      parts.add(coach.actionLines.first);
    }
    var text = parts.join(' ');
    if (text.length <= 280) return text;
    return '${text.substring(0, 277)}…';
  }

  Future<void> _show({
    required String title,
    required String body,
    required Importance importance,
    required Priority priority,
  }) {
    return _plugin.show(
      _scheduledId,
      title,
      body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Weer voor je moestuin',
          channelDescription:
              'Dagelijkse weersvoorspelling met AI-advies voor je moestuin.',
          importance: importance,
          priority: priority,
        ),
      ),
    );
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
