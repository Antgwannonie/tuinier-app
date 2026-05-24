import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Instelbare intervallen voor eerste foto en wekelijkse scan.
class GardenScanPrefsStore extends ChangeNotifier {
  static const _firstPhotoKey = 'garden_days_until_first_photo';
  static const _weeklyKey = 'garden_weekly_scan_interval_days';

  static const int defaultDaysUntilFirstPhoto = 14;
  static const int defaultWeeklyScanIntervalDays = 7;

  static const int minDaysUntilFirstPhoto = 3;
  static const int maxDaysUntilFirstPhoto = 60;
  static const int minWeeklyScanIntervalDays = 3;
  static const int maxWeeklyScanIntervalDays = 30;

  int _daysUntilFirstPhoto = defaultDaysUntilFirstPhoto;
  int _weeklyScanIntervalDays = defaultWeeklyScanIntervalDays;
  bool _loaded = false;

  bool get isLoaded => _loaded;
  int get daysUntilFirstPhoto => _daysUntilFirstPhoto;
  int get weeklyScanIntervalDays => _weeklyScanIntervalDays;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _daysUntilFirstPhoto = _clamp(
      prefs.getInt(_firstPhotoKey) ?? defaultDaysUntilFirstPhoto,
      minDaysUntilFirstPhoto,
      maxDaysUntilFirstPhoto,
    );
    _weeklyScanIntervalDays = _clamp(
      prefs.getInt(_weeklyKey) ?? defaultWeeklyScanIntervalDays,
      minWeeklyScanIntervalDays,
      maxWeeklyScanIntervalDays,
    );
    _loaded = true;
    notifyListeners();
  }

  Future<void> setDaysUntilFirstPhoto(int days) async {
    final v = _clamp(days, minDaysUntilFirstPhoto, maxDaysUntilFirstPhoto);
    if (_daysUntilFirstPhoto == v) return;
    _daysUntilFirstPhoto = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_firstPhotoKey, v);
    notifyListeners();
  }

  Future<void> setWeeklyScanIntervalDays(int days) async {
    final v = _clamp(days, minWeeklyScanIntervalDays, maxWeeklyScanIntervalDays);
    if (_weeklyScanIntervalDays == v) return;
    _weeklyScanIntervalDays = v;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_weeklyKey, v);
    notifyListeners();
  }

  int _clamp(int value, int min, int max) => value.clamp(min, max);
}
