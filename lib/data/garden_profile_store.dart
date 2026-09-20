import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_grow_approach.dart';
import '../models/plant_start_method.dart';
import '../models/tuin_space.dart';
import 'garden_history_eligibility.dart';
import 'my_garden_store.dart';
import 'crop_lifecycle_metadata.dart';
import 'plant_lifecycle.dart';
import 'plant_scan_history.dart';
import 'plant_scan_photo_store.dart';
import 'vegetable_id_migrations.dart';
import 'garden_scan_prefs_store.dart';
import 'moestuin_pinned_action.dart';
import '../models/vegetable.dart';
import 'vegetable_repository.dart';
import 'store_update_batch.dart';

/// Profielen per gewas in Mijn moestuin (locatie, zon, AI-scan).
class GardenProfileStore extends ChangeNotifier {
  static const _storageKey = 'garden_plant_profiles_v3';
  static const _batchSpaceMetaKey = 'moestuin_batch_space_meta_v1';

  final Map<String, GardenPlantProfile> _profiles = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  void _notify() => notifyStore(this);

  Iterable<GardenPlantProfile> get all => _profiles.values;

  GardenPlantProfile? profileFor(String vegetableId) => activeProfileFor(vegetableId);

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
        final storageKey = profile.isArchived && profile.archivedAt != null
            ? _archiveStorageKey(profile.vegetableId, profile.archivedAt!)
            : profile.vegetableId;
        _profiles[storageKey] = profile;
      }
    }
    needsPersist = _migrateLegacyProfileIds() || needsPersist;
    needsPersist = _normalizeArchiveStorageKeys() || needsPersist;
    needsPersist = _migrateLegacyHarvestedToInactive() || needsPersist;
    _loaded = true;
    if (needsPersist) await _persist();
    _notify();
  }

  /// Verplaatst profiel naar history als het een scan, oogst of uitbloeien heeft.
  /// Anders wordt het profiel verwijderd (geen history-regel).
  Future<bool> archiveProfile(
    String vegetableId, {
    DateTime? archivedAt,
    String? moestuinBatchId,
    MyGardenStore? gardenStore,
  }) async {
    final existing = _profiles.remove(vegetableId);
    if (existing == null || existing.isArchived) return false;
    if (!profileQualifiesForHistory(existing)) {
      await PlantScanPhotoStore.deleteAllFor(vegetableId);
      await _persist();
      _notify();
      return false;
    }
    final when = archivedAt ?? DateTime.now();
    final space = gardenStore?.activeSpace;
    final archived = existing.copyWith(
      archivedAt: when,
      moestuinBatchId: moestuinBatchId,
      archivedTuinSpaceId: space?.id,
      archivedTuinSpaceName: space?.name ?? 'Mijn moestuin',
    );
    _profiles[_archiveStorageKey(vegetableId, when)] = archived;
    await _persist();
    _notify();
    return true;
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
    var archivedCount = 0;
    for (final id in ids) {
      final kept = await archiveProfile(
        id,
        archivedAt: when,
        moestuinBatchId: batchId,
        gardenStore: gardenStore,
      );
      if (kept) archivedCount++;
    }
    await gardenStore.clear();
    final space = gardenStore.activeSpace;
    if (archivedCount > 0 && space != null) {
      await _rememberBatchSpace(
        batchId,
        spaceId: space.id,
        spaceName: space.name,
      );
    }
    return GardenArchiveBatchResult(
      count: archivedCount,
      archivedAt: archivedCount > 0 ? when : null,
      moestuinBatchId: archivedCount > 0 ? batchId : null,
    );
  }

  /// Verwijdert oude history zonder scan/oogst/uitbloeien.
  Future<void> purgeIneligibleArchivedProfiles() async {
    var changed = false;
    for (final entry in _profiles.entries.toList()) {
      final profile = entry.value;
      if (!profile.isArchived) continue;
      if (profileQualifiesForHistory(profile)) continue;
      _profiles.remove(entry.key);
      await PlantScanPhotoStore.deleteAllFor(profile.vegetableId);
      changed = true;
    }
    if (changed) {
      await _persist();
      _notify();
    }
  }

  /// Koppelt oude history aan je benoemde moestuinen (ids + batch-metadata).
  Future<void> syncArchivedTuinSpaces(MyGardenStore gardenStore) async {
    if (!_loaded) return;
    final spaces = gardenStore.historyFilterSpaces;
    if (spaces.isEmpty) return;

    var meta = await _loadBatchSpaceMeta();
    var metaChanged = false;
    var profilesChanged = false;

    final byBatch = <String, List<GardenPlantProfile>>{};
    for (final p in archivedProfiles) {
      final batchId = p.moestuinBatchId;
      if (batchId == null) continue;
      (byBatch[batchId] ??= []).add(p);
    }
    for (final entry in byBatch.entries) {
      if (meta.containsKey(entry.key)) continue;
      final withSpace = entry.value
          .where((p) => p.archivedTuinSpaceId != null)
          .toList();
      if (withSpace.isNotEmpty) {
        final ref = withSpace.first;
        meta[entry.key] = MoestuinBatchSpaceMeta(
          spaceId: ref.archivedTuinSpaceId!,
          spaceName: ref.archivedTuinSpaceName ?? '',
        );
        metaChanged = true;
      }
    }
    metaChanged =
        _inferMissingBatchSpaceMeta(meta, spaces, archivedProfiles.toList()) ||
        metaChanged;

    for (final entry in _profiles.entries.toList()) {
      var profile = entry.value;
      if (!profile.isArchived) continue;

      if (profile.archivedTuinSpaceId == null) {
        final resolved = _resolveArchivedTuinSpace(profile, spaces, meta);
        if (resolved != null) {
          profile = profile.copyWith(
            archivedTuinSpaceId: resolved.spaceId,
            archivedTuinSpaceName: resolved.spaceName,
          );
          _profiles[entry.key] = profile;
          profilesChanged = true;
        }
      }

      final batchId = profile.moestuinBatchId;
      final sid = profile.archivedTuinSpaceId;
      if (batchId != null &&
          sid != null &&
          !meta.containsKey(batchId)) {
        meta[batchId] = MoestuinBatchSpaceMeta(
          spaceId: sid,
          spaceName: profile.archivedTuinSpaceName ?? '',
        );
        metaChanged = true;
      }
    }

    if (metaChanged) await _saveBatchSpaceMeta(meta);

    if (metaChanged) {
      for (final entry in _profiles.entries.toList()) {
        var profile = entry.value;
        if (!profile.isArchived || profile.archivedTuinSpaceId != null) {
          continue;
        }
        final resolved = _resolveArchivedTuinSpace(profile, spaces, meta);
        if (resolved == null) continue;
        profile = profile.copyWith(
          archivedTuinSpaceId: resolved.spaceId,
          archivedTuinSpaceName: resolved.spaceName,
        );
        _profiles[entry.key] = profile;
        profilesChanged = true;
      }
    }

    if (profilesChanged) {
      await _persist();
      _notify();
    }
  }

  Future<Map<String, MoestuinBatchSpaceMeta>> _loadBatchSpaceMeta() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_batchSpaceMetaKey);
    if (raw == null || raw.isEmpty) return {};
    final map = jsonDecode(raw) as Map<String, dynamic>;
    return map.map(
      (key, value) => MapEntry(
        key,
        MoestuinBatchSpaceMeta.fromJson(value as Map<String, dynamic>),
      ),
    );
  }

  Future<void> _saveBatchSpaceMeta(
    Map<String, MoestuinBatchSpaceMeta> meta,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(
      meta.map((k, v) => MapEntry(k, v.toJson())),
    );
    await prefs.setString(_batchSpaceMetaKey, encoded);
  }

  Future<void> _rememberBatchSpace(
    String batchId, {
    required String spaceId,
    required String spaceName,
  }) async {
    final meta = await _loadBatchSpaceMeta();
    meta[batchId] = MoestuinBatchSpaceMeta(
      spaceId: spaceId,
      spaceName: spaceName,
    );
    await _saveBatchSpaceMeta(meta);
  }

  /// Gearchiveerde moestuinen (batch) die je in één keer kunt terugzetten.
  List<MoestuinHistoryBatch> moestuinBatchesForYear(
    int year, {
    String? tuinSpaceId,
  }) {
    final byBatch = <String, MoestuinHistoryBatch>{};
    for (final p in archivedProfiles) {
      final at = p.archivedAt;
      final batchId = p.moestuinBatchId;
      if (at == null || batchId == null || at.year != year) continue;
      if (!_profileMatchesTuinSpaceFilter(p, tuinSpaceId)) continue;
      final existing = byBatch[batchId];
      if (existing == null) {
        byBatch[batchId] = MoestuinHistoryBatch(
          batchId: batchId,
          archivedAt: at,
          plantCount: 1,
          tuinSpaceId: p.archivedTuinSpaceId,
          tuinSpaceName: p.archivedTuinSpaceName,
        );
      } else {
        byBatch[batchId] = MoestuinHistoryBatch(
          batchId: batchId,
          archivedAt: existing.archivedAt,
          plantCount: existing.plantCount + 1,
          tuinSpaceId: existing.tuinSpaceId ?? p.archivedTuinSpaceId,
          tuinSpaceName: existing.tuinSpaceName ?? p.archivedTuinSpaceName,
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
      _notify();
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
    if (changed) _notify();
  }

  /// Nieuw seizoen in de moestuin: leeg profiel zonder oude scans.
  /// Gearchiveerde history (andere opslagkeys) blijft ongewijzigd.
  Future<void> beginFreshPlantInGarden(
    String vegetableId, {
    DateTime? plantedAt,
    GardenLocation location = GardenLocation.outdoor,
    SunLevel sunLevel = SunLevel.medium,
    bool isPlanted = false,
    bool plantingDateUnknown = false,
    PlantStartMethod? plantStartMethod,
    PlantGrowApproach? plantGrowApproach,
    PlantAiPhase? userReportedPhase,
  }) async {
    final start = plantedAt ?? DateTime.now();
    final stale = _profiles[vegetableId];
    if (stale != null) {
      if (stale.isArchived) {
        final at = stale.archivedAt;
        if (at != null) {
          final archiveKey = _archiveStorageKey(vegetableId, at);
          _profiles.putIfAbsent(archiveKey, () => stale);
        }
      }
      _profiles.remove(vegetableId);
    }

    var profile = GardenPlantProfile(
      vegetableId: vegetableId,
      plantedAt: start,
      location: location,
      sunLevel: sunLevel,
      isPlanted: isPlanted,
      plantingDateUnknown: plantingDateUnknown,
      plantStartMethod: plantStartMethod,
      awaitingOutdoorPlanting:
          isPlanted && plantStartMethod == PlantStartMethod.preSowIndoors,
      plantGrowApproach: plantGrowApproach,
      userReportedPhase: userReportedPhase,
      isMoestuinActive: true,
    );
    profile = resetProfileScanStateForNewPlanting(profile).copyWith(
      plantedAt: start,
      location: location,
      sunLevel: sunLevel,
      isPlanted: isPlanted,
      plantingDateUnknown: plantingDateUnknown,
      plantStartMethod: plantStartMethod,
      awaitingOutdoorPlanting:
          isPlanted && plantStartMethod == PlantStartMethod.preSowIndoors,
      plantGrowApproach: plantGrowApproach,
      userReportedPhase: userReportedPhase,
      isMoestuinActive: true,
      clearInactive: true,
      clearInactiveSince: true,
      harvestedPercent: 0,
    );
    _profiles[vegetableId] = profile;
    await _persist();
    _notify();
  }

  Future<void> ensureProfile(
    String vegetableId, {
    DateTime? plantedAt,
    GardenLocation location = GardenLocation.outdoor,
    SunLevel sunLevel = SunLevel.medium,
    bool isPlanted = false,
    bool plantingDateUnknown = false,
    PlantStartMethod? plantStartMethod,
    PlantGrowApproach? plantGrowApproach,
    PlantAiPhase? userReportedPhase,
  }) async {
    final existing = _profiles[vegetableId];
    final start = plantedAt ?? DateTime.now();
    if (existing != null && !existing.isArchived) {
      final newDay = DateTime(start.year, start.month, start.day);
      final oldDay = DateTime(
        existing.plantedAt.year,
        existing.plantedAt.month,
        existing.plantedAt.day,
      );
      if (isPlanted && (!existing.isPlanted || newDay != oldDay)) {
        await markAsPlanted(
          vegetableId,
          plantedAt: start,
          location: location,
          sunLevel: sunLevel,
          plantingDateUnknown: plantingDateUnknown,
          plantStartMethod: plantStartMethod,
          userReportedPhase: userReportedPhase,
        );
      } else {
        _profiles[vegetableId] = existing.copyWith(
          plantedAt: start,
          location: location,
          sunLevel: sunLevel,
          isPlanted: isPlanted || existing.isPlanted,
          plantingDateUnknown: plantingDateUnknown,
          plantStartMethod: plantStartMethod ?? existing.plantStartMethod,
          plantGrowApproach: plantGrowApproach ?? existing.plantGrowApproach,
          userReportedPhase: userReportedPhase ?? existing.userReportedPhase,
        );
        await _persist();
        _notify();
      }
      return;
    }
    var profile = GardenPlantProfile(
      vegetableId: vegetableId,
      plantedAt: start,
      location: location,
      sunLevel: sunLevel,
      isPlanted: isPlanted,
      plantingDateUnknown: plantingDateUnknown,
      plantStartMethod: plantStartMethod,
      awaitingOutdoorPlanting:
          isPlanted && plantStartMethod == PlantStartMethod.preSowIndoors,
      plantGrowApproach: plantGrowApproach,
      userReportedPhase: userReportedPhase,
    );
    if (isPlanted) {
      profile = resetProfileScanStateForNewPlanting(profile);
    }
    _profiles[vegetableId] = profile;
    await _persist();
    _notify();
  }

  Future<void> markAsPlanted(
    String vegetableId, {
    DateTime? plantedAt,
    GardenLocation? location,
    SunLevel? sunLevel,
    bool? plantingDateUnknown,
    PlantStartMethod? plantStartMethod,
    PlantAiPhase? userReportedPhase,
    bool completeOutdoorPlanting = false,
  }) async {
    final existing = _profiles[vegetableId];
    final start = plantedAt ?? DateTime.now();
    final base = existing ?? GardenPlantProfile.defaults(vegetableId);
    final GardenPlantProfile profile;
    if (completeOutdoorPlanting) {
      profile = base.copyWith(
        location: location ?? GardenLocation.outdoor,
        sunLevel: sunLevel,
        awaitingOutdoorPlanting: false,
        plantingDateUnknown: plantingDateUnknown,
        harvestedPercent: 0,
        clearAnalysis: false,
      );
    } else {
      profile = resetProfileScanStateForNewPlanting(base).copyWith(
        plantedAt: start,
        location: location,
        sunLevel: sunLevel,
        isPlanted: true,
        plantingDateUnknown: plantingDateUnknown,
        plantStartMethod: plantStartMethod,
        awaitingOutdoorPlanting:
            plantStartMethod == PlantStartMethod.preSowIndoors,
        clearPlantGrowApproach: true,
        harvestedPercent: 0,
        userReportedPhase: userReportedPhase,
      );
    }
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
      _notify();
    }
  }

  Future<void> setHarvestProgress(String vegetableId, int percent) async {
    final existing = _profiles[vegetableId];
    if (existing == null) return;
    final next = percent.clamp(0, 100).toInt();
    if (existing.harvestedPercent == next) return;
    await saveProfile(existing.copyWith(harvestedPercent: next));
  }

  /// Zet plant op niet-actief in de moestuin (blijft zichtbaar).
  Future<void> setMoestuinInactive(
    String vegetableId, {
    PlantMoestuinInactiveReason reason =
        PlantMoestuinInactiveReason.harvestComplete,
  }) async {
    final existing = _profiles[vegetableId];
    if (existing == null || !existing.isMoestuinActive) return;
    await saveProfile(
      existing.copyWith(
        isMoestuinActive: false,
        inactiveReason: reason,
        inactiveSince: DateTime.now(),
        seasonBeyondCalendar: false,
        awaitingDeathConfirmation: false,
        harvestedPercent: reason == PlantMoestuinInactiveReason.harvestComplete
            ? 100
            : existing.harvestedPercent,
      ),
    );
  }

  /// Gebruiker bevestigt dat de plant dood is.
  Future<void> confirmPlantDead(String vegetableId) async {
    final existing = _profiles[vegetableId];
    if (existing == null) return;
    await saveProfile(
      existing.copyWith(
        isMoestuinActive: false,
        inactiveReason: PlantMoestuinInactiveReason.confirmedDead,
        inactiveSince: DateTime.now(),
        awaitingDeathConfirmation: false,
        seasonBeyondCalendar: false,
      ),
    );
  }

  /// Heractiveert planten waarvan het nieuwe seizoen is begonnen.
  Future<int> reactivatePlantsForSeason({
    required MyGardenStore gardenStore,
    required VegetableRepository repository,
    int? month,
  }) async {
    final m = month ?? DateTime.now().month;
    var count = 0;
    for (final id in gardenStore.ids) {
      final profile = _profiles[id];
      final veg = repository.byId(id);
      if (profile == null || veg == null) continue;
      final next = tryReactivatePlantForSeason(
        profile: profile,
        vegetable: veg,
        month: m,
        reference: DateTime.now(),
      );
      if (next != null) {
        await saveProfile(next);
        count++;
      }
    }
    return count;
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
    _notify();
  }

  /// Zet eerste pin voor planten die nog geen vastgezette actie hebben.
  Future<void> ensurePinnedMoestuinActions({
    required Iterable<String> vegetableIds,
    required Vegetable? Function(String id) vegetableById,
    required GardenScanPrefsStore scanPrefs,
  }) async {
    for (final id in vegetableIds) {
      final veg = vegetableById(id);
      final profile = profileFor(id);
      if (veg == null || profile == null) continue;
      if (profile.pinnedMoestuinActionKey?.isNotEmpty == true) continue;
      final synced = syncPinnedMoestuinAction(
        profile: profile,
        vegetable: veg,
        scanPrefs: scanPrefs,
      );
      if (synced.pinnedMoestuinActionKey != profile.pinnedMoestuinActionKey) {
        await saveProfile(synced);
      }
    }
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
      _notify();
    }
  }

  Future<void> clear() async {
    if (_profiles.isEmpty) return;
    _profiles.clear();
    await _persist();
    _notify();
  }

  /// Samengevoegde gewassen (bijv. lente_ui → bosui).
  bool _migrateLegacyProfileIds() {
    var changed = false;
    for (final entry in kVegetableIdMigrations.entries) {
      final legacy = _profiles.remove(entry.key);
      if (legacy == null) continue;
      changed = true;
      final target = entry.value;
      final existing = _profiles[target];
      if (existing == null) {
        _profiles[target] = legacy.copyWith(vegetableId: target);
        continue;
      }
      _profiles[target] = _mergeMigratedProfiles(
        canonicalId: target,
        primary: existing,
        secondary: legacy,
      );
    }
    return changed;
  }

  GardenPlantProfile _mergeMigratedProfiles({
    required String canonicalId,
    required GardenPlantProfile primary,
    required GardenPlantProfile secondary,
  }) {
    final scans = <PlantAiAnalysis>[
      ...primary.scanHistory,
      ...secondary.scanHistory,
    ];
    final photos = <String>[
      ...primary.scanPhotoPaths,
      ...secondary.scanPhotoPaths,
    ];
    final lastAnalysis = _newerAnalysis(primary.lastAnalysis, secondary.lastAnalysis);
    final primaryCount = primary.plantCount ?? 0;
    final secondaryCount = secondary.plantCount ?? 0;
    return primary.copyWith(
      vegetableId: canonicalId,
      plantedAt: primary.plantedAt.isBefore(secondary.plantedAt)
          ? primary.plantedAt
          : secondary.plantedAt,
      isPlanted: primary.isPlanted || secondary.isPlanted,
      scanHistory: scans,
      scanPhotoPaths: photos,
      lastAnalysis: lastAnalysis,
      predictedHarvestAt: primary.predictedHarvestAt ?? secondary.predictedHarvestAt,
      nextScanDue: primary.nextScanDue ?? secondary.nextScanDue,
      lastScanImageFingerprint:
          primary.lastScanImageFingerprint ?? secondary.lastScanImageFingerprint,
      lastScanPhotoPath: primary.lastScanPhotoPath ?? secondary.lastScanPhotoPath,
      harvestedPercent: primary.harvestedPercent > secondary.harvestedPercent
          ? primary.harvestedPercent
          : secondary.harvestedPercent,
      plantCount: primaryCount + secondaryCount > 0
          ? primaryCount + secondaryCount
          : null,
      isMoestuinActive: primary.isMoestuinActive || secondary.isMoestuinActive,
    );
  }

  PlantAiAnalysis? _newerAnalysis(
    PlantAiAnalysis? a,
    PlantAiAnalysis? b,
  ) {
    if (a == null) return b;
    if (b == null) return a;
    return a.scannedAt.isAfter(b.scannedAt) ? a : b;
  }

  /// Oude geoogste planten (100%) worden niet-actief i.p.v. verwijderd.
  bool _migrateLegacyHarvestedToInactive() {
    var changed = false;
    for (final entry in _profiles.entries.toList()) {
      final p = entry.value;
      if (p.isArchived) continue;
      if (p.harvestedPercent < 100) continue;
      if (!p.isMoestuinActive) continue;
      _profiles[entry.key] = p.copyWith(
        isMoestuinActive: false,
        inactiveReason: PlantMoestuinInactiveReason.harvestComplete,
        inactiveSince: p.inactiveSince ?? DateTime.now(),
      );
      changed = true;
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

bool _profileMatchesTuinSpaceFilter(
  GardenPlantProfile profile,
  String? tuinSpaceId,
) {
  if (tuinSpaceId == null) return true;
  return profile.archivedTuinSpaceId == tuinSpaceId;
}

int? _moestuinIdMillis(String id) {
  const prefix = 'moestuin_';
  if (!id.startsWith(prefix)) return null;
  return int.tryParse(id.substring(prefix.length));
}

TuinSpace? _spaceActiveAt(DateTime at, List<TuinSpace> spaces) {
  TuinSpace? best;
  int? bestMs;
  for (final space in spaces) {
    final ms = _moestuinIdMillis(space.id);
    if (ms == null) continue;
    if (ms <= at.millisecondsSinceEpoch &&
        (bestMs == null || ms > bestMs)) {
      best = space;
      bestMs = ms;
    }
  }
  return best ?? (spaces.isNotEmpty ? spaces.first : null);
}

bool _inferMissingBatchSpaceMeta(
  Map<String, MoestuinBatchSpaceMeta> meta,
  List<TuinSpace> spaces,
  List<GardenPlantProfile> archived,
) {
  if (spaces.isEmpty) return false;
  var changed = false;
  final batchAt = <String, DateTime>{};
  for (final profile in archived) {
    final batchId = profile.moestuinBatchId;
    final at = profile.archivedAt;
    if (batchId == null || at == null) continue;
    final existing = batchAt[batchId];
    if (existing == null || at.isBefore(existing)) {
      batchAt[batchId] = at;
    }
  }
  final batchIds = batchAt.keys.toList()
    ..sort((a, b) => batchAt[a]!.compareTo(batchAt[b]!));
  final sortedSpaces = List<TuinSpace>.from(spaces)
    ..sort(
      (a, b) => (_moestuinIdMillis(a.id) ?? 0)
          .compareTo(_moestuinIdMillis(b.id) ?? 0),
    );

  for (var i = 0; i < batchIds.length; i++) {
    final batchId = batchIds[i];
    if (meta.containsKey(batchId)) continue;
    final space = i < sortedSpaces.length
        ? sortedSpaces[i]
        : _spaceActiveAt(batchAt[batchId]!, sortedSpaces);
    if (space == null) continue;
    meta[batchId] = MoestuinBatchSpaceMeta(
      spaceId: space.id,
      spaceName: space.name,
    );
    changed = true;
  }
  return changed;
}

({String spaceId, String spaceName})? _resolveArchivedTuinSpace(
  GardenPlantProfile profile,
  List<TuinSpace> spaces,
  Map<String, MoestuinBatchSpaceMeta> meta,
) {
  if (spaces.isEmpty) return null;
  final batchId = profile.moestuinBatchId;
  final batchMeta = batchId != null ? meta[batchId] : null;
  if (batchMeta != null) {
    return (spaceId: batchMeta.spaceId, spaceName: batchMeta.spaceName);
  }
  final at = profile.archivedAt;
  if (at != null) {
    final space = _spaceActiveAt(at, spaces);
    if (space != null) {
      return (spaceId: space.id, spaceName: space.name);
    }
  }
  if (spaces.length == 1) {
    return (spaceId: spaces.first.id, spaceName: spaces.first.name);
  }
  final savedName = profile.archivedTuinSpaceName?.trim();
  if (savedName != null && savedName.isNotEmpty) {
    final matches = spaces
        .where(
          (s) => s.name.trim().toLowerCase() == savedName.toLowerCase(),
        )
        .toList();
    if (matches.length == 1) {
      return (spaceId: matches.first.id, spaceName: matches.first.name);
    }
  }
  return null;
}

class MoestuinBatchSpaceMeta {
  const MoestuinBatchSpaceMeta({
    required this.spaceId,
    required this.spaceName,
  });

  final String spaceId;
  final String spaceName;

  Map<String, dynamic> toJson() => {
        'spaceId': spaceId,
        'spaceName': spaceName,
      };

  factory MoestuinBatchSpaceMeta.fromJson(Map<String, dynamic> json) {
    return MoestuinBatchSpaceMeta(
      spaceId: json['spaceId'] as String,
      spaceName: json['spaceName'] as String? ?? '',
    );
  }
}

class MoestuinHistoryBatch {
  const MoestuinHistoryBatch({
    required this.batchId,
    required this.archivedAt,
    required this.plantCount,
    this.tuinSpaceId,
    this.tuinSpaceName,
  });

  final String batchId;
  final DateTime archivedAt;
  final int plantCount;
  final String? tuinSpaceId;
  final String? tuinSpaceName;
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
