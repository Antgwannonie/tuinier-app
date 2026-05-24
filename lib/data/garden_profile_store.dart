import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden_plant_profile.dart';

/// Profielen per gewas in Mijn moestuin (locatie, zon, AI-scan).
class GardenProfileStore extends ChangeNotifier {
  static const _storageKey = 'garden_plant_profiles_v3';

  final Map<String, GardenPlantProfile> _profiles = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Iterable<GardenPlantProfile> get all => _profiles.values;

  GardenPlantProfile? profileFor(String vegetableId) => _profiles[vegetableId];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _profiles.clear();
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final profile =
            GardenPlantProfile.fromJson(item as Map<String, dynamic>);
        _profiles[profile.vegetableId] = profile;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> ensureProfile(
    String vegetableId, {
    DateTime? plantedAt,
    GardenLocation location = GardenLocation.outdoor,
    SunLevel sunLevel = SunLevel.medium,
    bool isPlanted = false,
  }) async {
    if (_profiles.containsKey(vegetableId)) return;
    final start = plantedAt ?? DateTime.now();
    _profiles[vegetableId] = GardenPlantProfile(
      vegetableId: vegetableId,
      plantedAt: start,
      location: location,
      sunLevel: sunLevel,
      isPlanted: isPlanted,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> markAsPlanted(
    String vegetableId, {
    DateTime? plantedAt,
    GardenLocation? location,
    SunLevel? sunLevel,
  }) async {
    final existing = _profiles[vegetableId];
    final start = plantedAt ?? DateTime.now();
    final profile = (existing ?? GardenPlantProfile.defaults(vegetableId))
        .copyWith(
      plantedAt: start,
      location: location,
      sunLevel: sunLevel,
      isPlanted: true,
      clearAnalysis: false,
    );
    await saveProfile(profile);
  }

  Future<void> saveProfile(GardenPlantProfile profile) async {
    _profiles[profile.vegetableId] = profile;
    await _persist();
    notifyListeners();
  }

  Future<void> removeProfile(String vegetableId) async {
    if (_profiles.remove(vegetableId) != null) {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> clear() async {
    if (_profiles.isEmpty) return;
    _profiles.clear();
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_profiles.values.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
