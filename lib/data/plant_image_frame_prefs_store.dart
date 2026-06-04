import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/plant_image_frame_prefs.dart';

/// Opgeslagen foto-kader per gewas-id (Zoeken-kaart + detail).
class PlantImageFramePrefsStore extends ChangeNotifier {
  static const _storageKey = 'plant_image_frame_prefs_v1';

  final Map<String, PlantImageFramePrefs> _byVegetableId = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  PlantImageFramePrefs prefsFor(String vegetableId) {
    return _byVegetableId[vegetableId] ?? PlantImageFramePrefs.defaults;
  }

  bool hasCustom(String vegetableId) {
    return _byVegetableId.containsKey(vegetableId) &&
        !_byVegetableId[vegetableId]!.isNearDefaults();
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _byVegetableId.clear();
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw) as Map<String, dynamic>;
        for (final entry in decoded.entries) {
          final value = entry.value;
          if (value is Map<String, dynamic>) {
            _byVegetableId[entry.key] = PlantImageFramePrefs.fromJson(value);
          }
        }
      } catch (_) {
        _byVegetableId.clear();
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> saveFor(String vegetableId, PlantImageFramePrefs frame) async {
    if (frame.isNearDefaults()) {
      _byVegetableId.remove(vegetableId);
    } else {
      _byVegetableId[vegetableId] = frame;
    }
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode({
      for (final e in _byVegetableId.entries) e.key: e.value.toJson(),
    });
    await prefs.setString(_storageKey, encoded);
    notifyListeners();
  }

  Future<void> resetFor(String vegetableId) async {
    await saveFor(vegetableId, PlantImageFramePrefs.defaults);
  }
}
