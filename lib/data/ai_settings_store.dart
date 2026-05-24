import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../config/local_gemini_key.dart';

/// API-sleutel voor Google Gemini (gratis via aistudio.google.com).
class AiSettingsStore extends ChangeNotifier {
  static const _key = 'gemini_api_key_v1';

  String _apiKey = '';
  bool _loaded = false;

  bool get isLoaded => _loaded;
  String get apiKey => _apiKey;
  bool get hasApiKey => _apiKey.trim().isNotEmpty;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _apiKey = prefs.getString(_key) ?? '';
    await _syncLocalApiKey();
    _loaded = true;
    notifyListeners();
  }

  /// Overschrijft opgeslagen sleutel met `local_gemini_key.dart` (dev).
  Future<void> _syncLocalApiKey() async {
    final local = localGeminiApiKey.trim();
    if (local.isEmpty) return;
    if (_apiKey == local) return;
    _apiKey = local;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _apiKey);
  }

  /// Handmatig opnieuw laden uit lokaal bestand (bijv. na sleutel wijzigen).
  Future<void> reloadFromLocalFile() async {
    await _syncLocalApiKey();
    notifyListeners();
  }

  Future<void> setApiKey(String value) async {
    _apiKey = value.trim();
    final prefs = await SharedPreferences.getInstance();
    if (_apiKey.isEmpty) {
      await prefs.remove(_key);
    } else {
      await prefs.setString(_key, _apiKey);
    }
    notifyListeners();
  }
}
