import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Voorkeur voor dagelijkse tuinweetje-melding.
class DailyTipPrefsStore extends ChangeNotifier {
  static const _notifyKey = 'daily_tip_notifications';

  bool _notificationsEnabled = true;

  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notifyKey) ?? true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifyKey, enabled);
  }
}
