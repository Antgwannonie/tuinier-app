import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/visual_garden_plan.dart';

/// Persistence voor de visuele moestuinplanner (cm-coördinaten).
class VisualGardenPlanStore extends ChangeNotifier {
  static const _storageKey = 'visual_garden_plan_v1';

  VisualGardenPlan? _plan;
  bool _loaded = false;
  String? _selectedBedId;

  bool get isLoaded => _loaded;
  VisualGardenPlan? get plan => _plan;
  String? get selectedBedId => _selectedBedId;

  VisualGardenBed? get selectedBed {
    final p = _plan;
    if (p == null || _selectedBedId == null) return null;
    for (final b in p.beds) {
      if (b.id == _selectedBedId) return b;
    }
    return null;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    if (raw != null && raw.isNotEmpty) {
      _plan = VisualGardenPlan.fromJson(
        jsonDecode(raw) as Map<String, dynamic>,
      );
      if (_plan!.beds.isNotEmpty) {
        _selectedBedId ??= _plan!.beds.first.id;
      }
    } else {
      final now = DateTime.now();
      _plan = VisualGardenPlan(
        id: 'plan_${now.millisecondsSinceEpoch}',
        name: 'Mijn moestuin',
        createdAt: now,
        updatedAt: now,
        beds: const [],
      );
    }
    _loaded = true;
    notifyListeners();
  }

  void selectBed(String? bedId) {
    _selectedBedId = bedId;
    notifyListeners();
  }

  Future<void> addBed(VisualGardenBed bed) async {
    final p = _plan;
    if (p == null) return;
    var toAdd = bed;
    if (toAdd.cropPlans.isEmpty) {
      toAdd = _withDefaultCropPlan(toAdd);
    }
    _plan = p.copyWith(
      beds: [...p.beds, toAdd],
      updatedAt: DateTime.now(),
    );
    _selectedBedId = toAdd.id;
    await _persist();
    notifyListeners();
  }

  Future<void> updateBed(VisualGardenBed bed) async {
    final p = _plan;
    if (p == null) return;
    _plan = p.copyWith(
      beds: [
        for (final b in p.beds)
          if (b.id == bed.id) bed else b,
      ],
      updatedAt: DateTime.now(),
    );
    await _persist();
    notifyListeners();
  }

  Future<void> removeBed(String bedId) async {
    final p = _plan;
    if (p == null) return;
    final beds = p.beds.where((b) => b.id != bedId).toList();
    _plan = p.copyWith(beds: beds, updatedAt: DateTime.now());
    if (_selectedBedId == bedId) {
      _selectedBedId = beds.isEmpty ? null : beds.first.id;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> duplicateBed(String bedId) async {
    final p = _plan;
    if (p == null) return;
    VisualGardenBed? src;
    for (final b in p.beds) {
      if (b.id == bedId) {
        src = b;
        break;
      }
    }
    if (src == null) return;
    final now = DateTime.now();
    final copy = VisualGardenBed(
      id: 'bed_${now.millisecondsSinceEpoch}_${math.Random().nextInt(9999)}',
      name: '${src.name} (kopie)',
      verticesCm: List.of(src.verticesCm),
      wallHeightCm: src.wallHeightCm,
      borderColorValue: src.borderColorValue,
      fillColorValue: src.fillColorValue,
      cropPlans: [
        for (final plan in src.cropPlans)
          VisualCropPlan(
            id: 'crop_${now.millisecondsSinceEpoch}_${math.Random().nextInt(9999)}',
            name: plan.name,
            startDate: plan.startDate,
            endDate: plan.endDate,
            seasonLabel: plan.seasonLabel,
            placements: [
              for (final pl in plan.placements)
                PlantPlacement(
                  id: 'pl_${now.millisecondsSinceEpoch}_${math.Random().nextInt(9999)}',
                  plantId: pl.plantId,
                  xCm: pl.xCm,
                  yCm: pl.yCm,
                  spacingCm: pl.spacingCm,
                  createdAt: now,
                ),
            ],
          ),
      ],
      activeCropPlanId: null,
    );
    final withActive = copy.copyWith(
      activeCropPlanId:
          copy.cropPlans.isEmpty ? null : copy.cropPlans.first.id,
    );
    await addBed(withActive);
  }

  Future<void> setActiveCropPlan(String bedId, String cropPlanId) async {
    final bed = _bed(bedId);
    if (bed == null) return;
    if (!bed.cropPlans.any((p) => p.id == cropPlanId)) return;
    await updateBed(bed.copyWith(activeCropPlanId: cropPlanId));
  }

  Future<void> addCropPlan(String bedId, VisualCropPlan plan) async {
    final bed = _bed(bedId);
    if (bed == null) return;
    await updateBed(
      bed.copyWith(
        cropPlans: [...bed.cropPlans, plan],
        activeCropPlanId: plan.id,
      ),
    );
  }

  Future<void> updateCropPlan(String bedId, VisualCropPlan plan) async {
    final bed = _bed(bedId);
    if (bed == null) return;
    await updateBed(
      bed.copyWith(
        cropPlans: [
          for (final p in bed.cropPlans)
            if (p.id == plan.id) plan else p,
        ],
      ),
    );
  }

  Future<void> removeCropPlan(String bedId, String cropPlanId) async {
    final bed = _bed(bedId);
    if (bed == null) return;
    if (bed.cropPlans.length <= 1) return; // altijd minstens één plan
    final plans = bed.cropPlans.where((p) => p.id != cropPlanId).toList();
    final active = bed.activeCropPlanId == cropPlanId
        ? plans.first.id
        : bed.activeCropPlanId;
    await updateBed(
      bed.copyWith(cropPlans: plans, activeCropPlanId: active),
    );
  }

  Future<void> upsertPlacement(String bedId, PlantPlacement placement) async {
    final bed = _bed(bedId);
    if (bed == null) return;
    final active = bed.activeCropPlan;
    if (active == null) {
      final withPlan = _withDefaultCropPlan(bed);
      await updateBed(withPlan);
      return upsertPlacement(bedId, placement);
    }
    final list = [...active.placements];
    final i = list.indexWhere((p) => p.id == placement.id);
    if (i >= 0) {
      list[i] = placement;
    } else {
      list.add(placement);
    }
    await updateCropPlan(bedId, active.copyWith(placements: list));
  }

  Future<void> removePlacement(String bedId, String placementId) async {
    final bed = _bed(bedId);
    if (bed == null) return;
    final active = bed.activeCropPlan;
    if (active == null) return;
    await updateCropPlan(
      bedId,
      active.copyWith(
        placements:
            active.placements.where((p) => p.id != placementId).toList(),
      ),
    );
  }

  /// Wis alle planten uit het actieve teeltplan van deze bak.
  Future<void> clearPlacements(String bedId) async {
    final bed = _bed(bedId);
    if (bed == null) return;
    final active = bed.activeCropPlan;
    if (active == null || active.placements.isEmpty) return;
    await updateCropPlan(
      bedId,
      active.copyWith(placements: const []),
    );
  }

  VisualGardenBed? _bed(String id) {
    final p = _plan;
    if (p == null) return null;
    for (final b in p.beds) {
      if (b.id == id) return b;
    }
    return null;
  }

  VisualGardenBed _withDefaultCropPlan(VisualGardenBed bed) {
    if (bed.cropPlans.isNotEmpty) return bed;
    final now = DateTime.now();
    final endMonth = now.month + 2 > 12 ? now.month + 2 - 12 : now.month + 2;
    final endYear = now.month + 2 > 12 ? now.year + 1 : now.year;
    final plan = VisualCropPlan(
      id: 'crop_${now.millisecondsSinceEpoch}',
      name: 'Teeltplan 1',
      startDate: DateTime(now.year, now.month, 1),
      endDate: DateTime(endYear, endMonth + 1, 0),
      seasonLabel: VisualCropPlan.seasonForMonth(now.month),
      placements: const [],
    );
    return bed.copyWith(cropPlans: [plan], activeCropPlanId: plan.id);
  }

  Future<void> replacePlan(VisualGardenPlan plan) async {
    _plan = plan;
    if (_selectedBedId != null &&
        plan.beds.every((b) => b.id != _selectedBedId)) {
      _selectedBedId = plan.beds.isEmpty ? null : plan.beds.first.id;
    } else if (_selectedBedId == null && plan.beds.isNotEmpty) {
      _selectedBedId = plan.beds.first.id;
    }
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final p = _plan;
    if (p == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(p.toJson()));
  }
}
