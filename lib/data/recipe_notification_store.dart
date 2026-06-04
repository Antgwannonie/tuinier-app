import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Onthoudt welke receptmelding de gebruiker al heeft gezien (per fingerprint).
class RecipeNotificationStore extends ChangeNotifier {
  static const _prefsKey = 'recipe_notification_ack_v1';

  final Map<String, String> _acknowledgedFingerprints = {};

  bool get isLoaded => _loaded;
  bool _loaded = false;

  bool isAcknowledged(String recipeId, String fingerprint) {
    return _acknowledgedFingerprints[recipeId] == fingerprint;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    _acknowledgedFingerprints.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          for (final entry in decoded.entries) {
            final key = entry.key?.toString();
            final value = entry.value?.toString();
            if (key != null && value != null && key.isNotEmpty) {
              _acknowledgedFingerprints[key] = value;
            }
          }
        }
      } catch (_) {
        // corrupt data — start fresh
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> acknowledge(String recipeId, String fingerprint) async {
    if (_acknowledgedFingerprints[recipeId] == fingerprint) return;
    _acknowledgedFingerprints[recipeId] = fingerprint;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, jsonEncode(_acknowledgedFingerprints));
  }
}
