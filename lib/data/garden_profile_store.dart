import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden_plant_profile.dart';
import 'my_garden_store.dart';
import 'plant_scan_history.dart';
import 'plant_scan_photo_store.dart';
import 'vegetable_id_migrations.dart';

/// Profielen per gewas in Mijn moestuin (locatie, zon, AI-scan).
class GardenProfileStore extends ChangeNotifier {
  static const _storageKey = 'garden_plant_profiles_v3';

  final Map<String, GardenPlantProfile> _profiles = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Iterable<GardenPlantProfile> get all => _profiles.values;

  GardenPlantProfile? profileFor(String vegetableId) => _profiles[vegetableId];

  /// Actieve (niet-gearchiveerde) profielen voor een gewas-id.
  GardenPlantProfile? activeProfileFor(String vegetableId) {
    final p = _profiles[vegetableId];
    if (p == null || p.isArchived) return null;
    return p;
  }

  /// Alle gearchiveerde seizoenen (inclusief oude opslagkeys).
  Iterable<GardenPlantProfile> get archivedProfiles =>
      _profiles.values.where((p) => p.isArchived);

  static String _archiveStorageKey(String vegetableId, DateTime archivedAt) =>
      'archived:$vegetableId:${archivedAt.millisecondsSinceEpoch}';

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _profiles.clear();
    var needsPersist = false;
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final rawProfile =
            GardenPlantProfile.fromJson(item as Map<String, dynamic>);
        final profile = normalizeProfileScans(rawProfile);
        if (profile.scanHistory.length != rawProfile.scanHistory.length ||
            profile.scanPhotoPaths.length != rawProfile.scanPhotoPaths.length) {
          needsPersist = true;
        }
        _profiles[profile.vegetableId] = profile;
      }
    }
    needsPersist = _migrateLegacyProfileIds() || needsPersist;
    needsPersist = _normalizeArchiveStorageKeys() || needsPersist;
    _loaded = true;
    if (needsPersist) await _persist();
    notifyListeners();
  }

  /// Verplaatst profiel naar history (scans blijven bewaard).
  Future<void> archiveProfile(
    String vegetableId, {
    DateTime? archivedAt,
    String? moestuinBatchId,
  }) async {
    final existing = _profiles.remove(vegetableId);
    if (existing == null || existing.isArchived) return;
    final when = archivedAt ?? DateTime.now();
    final archived = existing.copyWith(
      archivedAt: when,
      moestuinBatchId: moestuinBatchId,
    );
    _profiles[_archiveStorageKey(vegetableId, when)] = archived;
    await _persist();
    notifyListeners();
  }

  /// Archiveert alle planten in de actieve moestuin en maakt die leeg.
  /// Planten krijgen hetzelfde [moestuinBatchId] voor herstel uit History.
  Future<GardenArchiveBatchResult> archiveGardenAndClear(
    MyGardenStore gardenStore,
  ) async {
    final ids = gardenStore.ids.toList();
    if (ids.isEmpty) {
      return const GardenArchiveBatchResult(count: 0);
    }
    final when = DateTime.now();
    final batchId = 'moestuin_${when.millisecondsSinceEpoch}';
    for (final id in ids) {
      await archiveProfile(
        id,
        archivedAt: when,
        moestuinBatchId: batchId,
      );
    }
    await gardenStore.clear();
    return GardenArchiveBatchResult(
      count: ids.length,
      archivedAt: when,
      moestuinBatchId: batchId,
    );
  }

  /// Gearchiveerde moestuinen (batch) die je in één keer kunt terugzetten.
  List<MoestuinHistoryBatch> moestuinBatchesForYear(int year) {
    final byBatch = <String, MoestuinHistoryBatch>{};
    for (final p in archivedProfiles) {
      final at = p.archivedAt;
      final batchId = p.moestuinBatchId;
      if (at == null || batchId == null || at.year != year) continue;
      final existing = byBatch[batchId];
      if (existing == null) {
        byBatch[batchId] = MoestuinHistoryBatch(
          batchId: batchId,
          archivedAt: at,
          plantCount: 1,
        );
      } else {
        byBatch[batchId] = MoestuinHistoryBatch(
          batchId: batchId,
          archivedAt: existing.archivedAt,
          plantCount: existing.plantCount + 1,
        );
      }
    }
    final list = byBatch.values.toList()
      ..sort((a, b) => b.archivedAt.compareTo(a.archivedAt));
    return list;
  }

  /// Kopieert gearchiveerde planten naar Mijn moestuin (history blijft staan).
  Future<MoestuinRestoreResult> copyArchivedPlantsToGarden(
    Iterable<GardenPlantProfile> archivedSources,
    MyGardenStore gardenStore,
  ) async {
    var restored = 0;
    var skipped = 0;

    for (final profile in archivedSources) {
      final id = profile.vegetableId;
      if (!profile.isArchived) continue;
      if (gardenStore.contains(id) || activeProfileFor(id) != null) {
        skipped++;
        continue;
      }

      _profiles[id] = profile.freshSeasonCopy();
      await gardenStore.add(id);
      restored++;
    }

    if (restored > 0) {
      await _persist();
      notifyListeners();
    }
    return MoestuinRestoreResult(restored: restored, skipped: skipped);
  }

  /// Zet planten van een opgeslagen moestuin-batch terug in Mijn moestuin.
  Future<MoestuinRestoreResult> restoreMoestuinBatch(
    String moestuinBatchId,
    MyGardenStore gardenStore,
  ) {
    final archived = archivedProfiles
        .where((p) => p.moestuinBatchId == moestuinBatchId)
        .toList();
    return copyArchivedPlantsToGarden(archived, gardenStore);
  }

  /// Oude geoogste planten zonder archive-datum alsnog in history zetten.
  Future<void> migrateLegacyHarvestedOutOfGarden(
    MyGardenStore gardenStore,
  ) async {
    var changed = false;
    for (final entry in _profiles.entries.toList()) {
      final p = entry.value;
      if (p.isArchived) continue;
      if (entry.key != p.vegetableId) continue;
      if (gardenStore.contains(p.vegetableId)) continue;
      if (p.harvestedPercent < 100) continue;
      await archiveProfile(p.vegetableId);
      changed = true;
    }
    if (changed) notifyListeners();
  }

  Future<void> ensureProfile(
    String vegetableId, {
    DateTime? plantedAt,
    GardenLocation location = GardenLocation.outdoor,
    SunLevel sunLevel = SunLevel.medium,
    bool isPlanted = false,
    bool plantingDateUnknown = false,
  }) async {
    final existing = _profiles[vegetableId];
    if (existing != null && !existing.isArchived) return;
    final start = plantedAt ?? DateTime.now();
    _profiles[vegetableId] = GardenPlantProfile(
      vegetableId: vegetableId,
      plantedAt: start,
      location: location,
      sunLevel: sunLevel,
      isPlanted: isPlanted,
      plantingDateUnknown: plantingDateUnknown,
    );
    await _persist();
    notifyListeners();
  }

  Future<void> markAsPlanted(
    String vegetableId, {
    DateTime? plantedAt,
    GardenLocation? location,
    SunLevel? sunLevel,
    bool? plantingDateUnknown,
  }) async {
    final existing = _profiles[vegetableId];
    final start = plantedAt ?? DateTime.now();
    final profile = (existing ?? GardenPlantProfile.defaults(vegetableId))
        .copyWith(
      plantedAt: start,
      location: location,
      sunLevel: sunLevel,
      isPlanted: true,
      plantingDateUnknown: plantingDateUnknown,
      harvestedPercent: 0,
      clearAnalysis: false,
    );
    await saveProfile(profile);
  }

  /// Na wijziging scan-interval: volgende scan opnieuw berekenen vanaf laatste scan.
  Future<void> recalculateNextScanDueForAll(int weeklyScanIntervalDays) async {
    var changed = false;
    for (final entry in _profiles.entries.toList()) {
      final p = entry.value;
      final last = p.lastAnalysis;
      if (last == null) continue;
      final scanned = DateTime(
        last.scannedAt.year,
        last.scannedAt.month,
        last.scannedAt.day,
      );
      final due = scanned.add(Duration(days: weeklyScanIntervalDays));
      if (p.nextScanDue == null ||
          p.nextScanDue!.year != due.year ||
          p.nextScanDue!.month != due.month ||
          p.nextScanDue!.day != due.day) {
        _profiles[entry.key] = p.copyWith(nextScanDue: due);
        changed = true;
      }
    }
    if (changed) {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> setHarvestProgress(String vegetableId, int percent) async {
    final existing = _profiles[vegetableId];
    if (existing == null) return;
    final next = percent.clamp(0, 100).toInt();
    if (existing.harvestedPercent == next) return;
    await saveProfile(existing.copyWith(harvestedPercent: next));
  }

  String _storageKeyFor(GardenPlantProfile profile) {
    if (profile.isArchived && profile.archivedAt != null) {
      return _archiveStorageKey(profile.vegetableId, profile.archivedAt!);
    }
    return profile.vegetableId;
  }

  Future<void> saveProfile(GardenPlantProfile profile) async {
    final normalized = normalizeProfileScans(profile);
    _profiles[_storageKeyFor(normalized)] = normalized;
    await _persist();
    notifyListeners();
  }

  /// AI-waarschuwing afvinken na actie (verbergt melding op plant).
  Future<void> acknowledgePlantHealth(String vegetableId) async {
    final existing = _profiles[vegetableId];
    if (existing == null) return;
    if (existing.plantHealthAcknowledged) return;
    await saveProfile(
      existing.copyWith(plantHealthAcknowledged: true),
    );
  }

  /// Verberg melding in bel-overzicht; op plantdetail blijft zichtbaar.
  Future<void> dismissWarningsFromBell(String vegetableId) async {
    final existing = _profiles[vegetableId];
    if (existing == null || existing.warningsDismissedFromBell) return;
    await saveProfile(
      existing.copyWith(warningsDismissedFromBell: true),
    );
  }

  Future<void> removeProfile(String vegetableId) async {
    if (_profiles.remove(vegetableId) != null) {
      await PlantScanPhotoStore.deleteAllFor(vegetableId);
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

  /// Samengevoegde gewassen (bijv. lente_ui → bosui).
  bool _migrateLegacyProfileIds() {
    var changed = false;
    for (final entry in kVegetableIdMigrations.entries) {
      final legacy = _profiles.remove(entry.key);
      if (legacy == null) continue;
      changed = true;
      final target = entry.value;
      if (_profiles.containsKey(target)) continue;
      _profiles[target] = GardenPlantProfile(
        vegetableId: target,
        plantedAt: legacy.plantedAt,
        location: legacy.location,
        sunLevel: legacy.sunLevel,
        isPlanted: legacy.isPlanted,
        lastAnalysis: legacy.lastAnalysis,
        scanHistory: legacy.scanHistory,
        predictedHarvestAt: legacy.predictedHarvestAt,
        nextScanDue: legacy.nextScanDue,
        lastScanImageFingerprint: legacy.lastScanImageFingerprint,
        lastScanPhotoPath: legacy.lastScanPhotoPath,
        scanPhotoPaths: legacy.scanPhotoPaths,
        plantHealthAcknowledged: legacy.plantHealthAcknowledged,
        plantingDateUnknown: legacy.plantingDateUnknown,
        warningsDismissedFromBell: legacy.warningsDismissedFromBell,
        harvestedPercent: legacy.harvestedPercent,
        archivedAt: legacy.archivedAt,
        moestuinBatchId: legacy.moestuinBatchId,
      );
    }
    return changed;
  }

  bool _normalizeArchiveStorageKeys() {
    var changed = false;
    for (final entry in _profiles.entries.toList()) {
      final p = entry.value;
      if (!p.isArchived || p.archivedAt == null) continue;
      final expected = _archiveStorageKey(p.vegetableId, p.archivedAt!);
      if (entry.key == expected) continue;
      if (entry.key == p.vegetableId || entry.key.startsWith('archived:')) {
        _profiles.remove(entry.key);
        _profiles[expected] = p;
        changed = true;
      }
    }
    return changed;
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_profiles.values.map((p) => p.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}

class GardenArchiveBatchResult {
  const GardenArchiveBatchResult({
    required this.count,
    this.archivedAt,
    this.moestuinBatchId,
  });

  final int count;
  final DateTime? archivedAt;
  final String? moestuinBatchId;
}

class MoestuinHistoryBatch {
  const MoestuinHistoryBatch({
    required this.batchId,
    required this.archivedAt,
    required this.plantCount,
  });

  final String batchId;
  final DateTime archivedAt;
  final int plantCount;
}

class MoestuinRestoreResult {
  const MoestuinRestoreResult({
    required this.restored,
    required this.skipped,
  });

  final int restored;
  final int skipped;

  int get total => restored + skipped;
}
