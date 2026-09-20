import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import 'garden_daily_tips.dart';

/// Dagelijkse melding met een tuinweetje (ochtend).
class DailyTipNotificationService {
  DailyTipNotificationService._();
  static final DailyTipNotificationService instance =
      DailyTipNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _ready = false;

  static const _notificationId = 3001;
  static const _channelId = 'tuinier_weetje';
  static const _lastSentKey = 'daily_tip_last_sent_day';

  Future<void> init() async {
    if (_ready) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.local);

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _plugin.initialize(const InitializationSettings(android: android));

    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    const channel = AndroidNotificationChannel(
      _channelId,
      'Weetje van de dag',
      description: 'Elke ochtend een kort weetje over tuinieren.',
      importance: Importance.defaultImportance,
    );
    await androidPlugin?.createNotificationChannel(channel);
    _ready = true;
  }

  Future<void> sync({required bool enabled}) async {
    await init();
    await _plugin.cancel(_notificationId);

    if (!enabled) return;

    final now = DateTime.now();
    final prefs = await SharedPreferences.getInstance();
    final todayKey = _dayKey(now);
    final morning = DateTime(now.year, now.month, now.day, 8, 30);

    if (now.isAfter(morning) && prefs.getString(_lastSentKey) != todayKey) {
      final tip = gardenTipOfTheDay(now);
      await _show(tip.title, tip.text);
      await prefs.setString(_lastSentKey, todayKey);
    }

    var next = morning;
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    final nextTip = gardenTipOfTheDay(next);
    final tzWhen = tz.TZDateTime.from(next, tz.local);

    await _plugin.zonedSchedule(
      _notificationId,
      'Weetje van de dag 🌱',
      '${nextTip.title}: ${nextTip.text}',
      tzWhen,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Weetje van de dag',
          channelDescription:
              'Elke ochtend een kort weetje over tuinieren.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> _show(String title, String body) {
    return _plugin.show(
      _notificationId,
      'Weetje van de dag 🌱',
      '$title · $body',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Weetje van de dag',
          channelDescription:
              'Elke ochtend een kort weetje over tuinieren.',
          importance: Importance.defaultImportance,
          priority: Priority.defaultPriority,
        ),
      ),
    );
  }

  String _dayKey(DateTime d) => '${d.year}-${d.month}-${d.day}';
}
