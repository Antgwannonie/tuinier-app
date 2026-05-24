import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lokaal opgeslagen lijst met groenten die de gebruiker zelf verbouwt.
/// Later: sync met account + meldingen alleen voor deze ids.
class MyGardenStore extends ChangeNotifier {
  static const _storageKey = 'my_garden_vegetable_ids';
  static const _notificationsKey = 'notifications_enabled';

  final Set<String> _ids = {};
  bool _loaded = false;
  bool _notificationsEnabled = true;

  bool get isLoaded => _loaded;

  bool get notificationsEnabled => _notificationsEnabled;

  Set<String> get ids => Set.unmodifiable(_ids);

  bool get isEmpty => _ids.isEmpty;

  bool get isNotEmpty => _ids.isNotEmpty;

  int get count => _ids.length;

  bool contains(String vegetableId) => _ids.contains(vegetableId);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getStringList(_storageKey) ?? [];
    _ids
      ..clear()
      ..addAll(saved);
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;
    _loaded = true;
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    notifyListeners();
  }

  Future<void> add(String vegetableId) async {
    if (_ids.add(vegetableId)) {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> remove(String vegetableId) async {
    if (_ids.remove(vegetableId)) {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> toggle(String vegetableId) async {
    if (_ids.contains(vegetableId)) {
      await remove(vegetableId);
    } else {
      await add(vegetableId);
    }
  }

  Future<void> clear() async {
    if (_ids.isEmpty) return;
    _ids.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_storageKey, _ids.toList()..sort());
  }
}
