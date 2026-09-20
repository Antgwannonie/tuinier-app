import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/tuin_space.dart';
import 'vegetable_id_migrations.dart';
import 'store_update_batch.dart';

/// Planten in de actieve moestuin + meerdere benoemde moestuinen.
class MyGardenStore extends ChangeNotifier {
  static const _legacyIdsKey = 'my_garden_vegetable_ids';
  static const _spacesKey = 'tuin_spaces_v1';
  static const _activeKey = 'tuin_spaces_active_id';
  static const _notificationsKey = 'notifications_enabled';

  final Map<String, TuinSpace> _spaces = {};
  String _activeId = '';
  bool _loaded = false;
  bool _notificationsEnabled = true;

  bool get isLoaded => _loaded;
  bool get notificationsEnabled => _notificationsEnabled;

  Set<String> get ids =>
      Set.unmodifiable(_spaces[_activeId]?.plantIds ?? const {});

  bool get isEmpty => ids.isEmpty;
  bool get isNotEmpty => ids.isNotEmpty;
  int get count => ids.length;

  void _notify() => notifyStore(this);

  bool contains(String vegetableId) => ids.contains(vegetableId);

  TuinSpace? get activeSpace => _spaces[_activeId];

  List<TuinSpace> get allSpaces {
    final list = _spaces.values.toList()
      ..sort((a, b) => a.name.compareTo(b.name));
    return list;
  }

  /// Moestuinen voor history-filter (zonder oude tuintype-namen).
  List<TuinSpace> get historyFilterSpaces {
    return _spaces.values
        .where((s) => !_isLegacyTypeOnlyName(s.name))
        .toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }

  bool get hasMultipleSpaces => _spaces.length > 1;

  /// Oude tuintype-namen uit coach-versie (geen echte moestuinen).
  static const _legacyTypeOnlyNames = {
    'bloementuin',
    'kruidentuin',
    'fruitgaard',
    'kamerplanten',
    'siertuin',
    'natuurtuin',
    'gemengde tuin',
  };

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _notificationsEnabled = prefs.getBool(_notificationsKey) ?? true;

    _spaces.clear();
    final rawSpaces = prefs.getString(_spacesKey);
    if (rawSpaces != null && rawSpaces.isNotEmpty) {
      final data = jsonDecode(rawSpaces) as Map<String, dynamic>;
      final gardens = data['gardens'] as List<dynamic>? ?? [];
      for (final item in gardens) {
        final space = TuinSpace.fromJson(item as Map<String, dynamic>);
        _spaces[space.id] = _normalizeSpace(space);
      }
      _activeId = data['activeId'] as String? ?? '';
    }

    if (_spaces.isEmpty) {
      await _migrateFromLegacy(prefs);
    }

    _purgeLegacyTypeNamedSpaces();
    if (_spaces.isEmpty) {
      await _migrateFromLegacy(prefs);
    }

    if (_activeId.isEmpty || !_spaces.containsKey(_activeId)) {
      _activeId = _spaces.keys.first;
    }

    _loaded = true;
    await _persist(prefs);
    _notify();
  }

  Future<void> _migrateFromLegacy(SharedPreferences prefs) async {
    final saved = prefs.getStringList(_legacyIdsKey) ?? [];
    final migrated = normalizeVegetableIds(saved);
    final id = 'moestuin_${DateTime.now().millisecondsSinceEpoch}';
    _spaces[id] = TuinSpace(
      id: id,
      name: 'Mijn moestuin',
      place: TuinSpacePlace.outdoor,
      plantIds: migrated.toSet(),
    );
    _activeId = id;
  }

  bool _isLegacyTypeOnlyName(String name) =>
      _legacyTypeOnlyNames.contains(name.trim().toLowerCase());

  /// Verwijdert auto-aangemaakte tuintypes; planten gaan naar één moestuin.
  bool _purgeLegacyTypeNamedSpaces() {
    final legacyIds = <String>[];
    for (final e in _spaces.entries) {
      if (_isLegacyTypeOnlyName(e.value.name)) {
        legacyIds.add(e.key);
      }
    }
    if (legacyIds.isEmpty) return false;

    String? targetId;
    for (final e in _spaces.entries) {
      if (!_isLegacyTypeOnlyName(e.value.name)) {
        targetId = e.key;
        break;
      }
    }
    if (targetId == null) {
      for (final e in _spaces.entries) {
        if (e.value.name.trim().toLowerCase() == 'mijn moestuin') {
          targetId = e.key;
          break;
        }
      }
    }
    targetId ??= legacyIds.isNotEmpty ? legacyIds.first : null;
    if (targetId == null) return false;

    var target = _spaces[targetId]!;
    final toRemove = legacyIds.where((id) => id != targetId).toList();
    var merged = Set<String>.from(target.plantIds);
    for (final id in toRemove) {
      merged = merged.union(_spaces[id]!.plantIds);
      _spaces.remove(id);
    }

    final name = _isLegacyTypeOnlyName(target.name) ? 'Mijn moestuin' : target.name;
    _spaces[targetId] = target.copyWith(name: name, plantIds: merged);
    _activeId = targetId;
    return true;
  }

  TuinSpace _normalizeSpace(TuinSpace space) {
    final migrated = normalizeVegetableIds(space.plantIds.toList());
    if (migrated.length == space.plantIds.length &&
        migrated.every(space.plantIds.contains)) {
      return space;
    }
    return space.copyWith(plantIds: migrated.toSet());
  }

  Future<String> createSpace({
    required String name,
    TuinSpacePlace place = TuinSpacePlace.outdoor,
  }) async {
    final trimmed = name.trim();
    final id = 'moestuin_${DateTime.now().millisecondsSinceEpoch}';
    _spaces[id] = TuinSpace(
      id: id,
      name: trimmed.isEmpty ? 'Moestuin' : trimmed,
      place: place,
      plantIds: {},
    );
    _activeId = id;
    await _persist();
    _notify();
    return id;
  }

  Future<void> setActiveSpace(String spaceId) async {
    if (!_spaces.containsKey(spaceId) || spaceId == _activeId) return;
    _activeId = spaceId;
    await _persist();
    _notify();
  }

  /// Verwijdert een moestuin. Geeft plant-ids terug die nergens meer staan.
  Future<Set<String>> deleteSpace(String spaceId) async {
    final space = _spaces[spaceId];
    if (space == null) return {};

    final removedPlantIds = Set<String>.from(space.plantIds);
    _spaces.remove(spaceId);

    if (_spaces.isEmpty) {
      final id = 'moestuin_${DateTime.now().millisecondsSinceEpoch}';
      _spaces[id] = TuinSpace(
        id: id,
        name: 'Mijn moestuin',
        place: TuinSpacePlace.outdoor,
        plantIds: {},
      );
      _activeId = id;
    } else if (_activeId == spaceId) {
      _activeId = _spaces.keys.first;
    }

    final stillPresent = _spaces.values
        .expand((s) => s.plantIds)
        .toSet();
    final orphaned = removedPlantIds.difference(stillPresent);

    await _persist();
    _notify();
    return orphaned;
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notificationsKey, enabled);
    _notify();
  }

  Future<void> add(String vegetableId) async {
    final space = _spaces[_activeId];
    if (space == null) return;
    if (space.plantIds.add(vegetableId)) {
      await _persist();
      _notify();
    }
  }

  Future<void> remove(String vegetableId) async {
    final space = _spaces[_activeId];
    if (space == null) return;
    if (space.plantIds.remove(vegetableId)) {
      await _persist();
      _notify();
    }
  }

  Future<void> toggle(String vegetableId) async {
    if (contains(vegetableId)) {
      await remove(vegetableId);
    } else {
      await add(vegetableId);
    }
  }

  Future<void> clear() async {
    final space = _spaces[_activeId];
    if (space == null || space.plantIds.isEmpty) return;
    _spaces[_activeId] = space.copyWith(plantIds: {});
    await _persist();
    _notify();
  }

  Future<void> _persist([SharedPreferences? prefs]) async {
    final p = prefs ?? await SharedPreferences.getInstance();
    final payload = {
      'activeId': _activeId,
      'gardens': _spaces.values.map((s) => s.toJson()).toList(),
    };
    await p.setString(_spacesKey, jsonEncode(payload));
    await p.setString(_activeKey, _activeId);
    await p.setStringList(_legacyIdsKey, ids.toList()..sort());
  }
}
