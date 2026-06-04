import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class GardenYearLayoutItem {
  const GardenYearLayoutItem({
    required this.vegetableId,
    required this.x,
    required this.y,
    required this.w,
    required this.h,
  });

  final String vegetableId;
  final double x;
  final double y;
  final double w;
  final double h;

  Map<String, dynamic> toJson() => {
        'vegetableId': vegetableId,
        'x': x,
        'y': y,
        'w': w,
        'h': h,
      };

  factory GardenYearLayoutItem.fromJson(Map<String, dynamic> json) {
    return GardenYearLayoutItem(
      vegetableId: json['vegetableId'] as String,
      x: (json['x'] as num?)?.toDouble() ?? 0,
      y: (json['y'] as num?)?.toDouble() ?? 0,
      w: (json['w'] as num?)?.toDouble() ?? 80,
      h: (json['h'] as num?)?.toDouble() ?? 80,
    );
  }
}

class GardenYearPlan {
  const GardenYearPlan({
    required this.year,
    this.vegetableIds = const [],
    this.bedWidthCm = 300,
    this.bedHeightCm = 200,
    this.layout = const [],
  });

  final int year;
  final List<String> vegetableIds;
  final double bedWidthCm;
  final double bedHeightCm;
  final List<GardenYearLayoutItem> layout;

  GardenYearPlan copyWith({
    List<String>? vegetableIds,
    double? bedWidthCm,
    double? bedHeightCm,
    List<GardenYearLayoutItem>? layout,
  }) {
    return GardenYearPlan(
      year: year,
      vegetableIds: vegetableIds ?? this.vegetableIds,
      bedWidthCm: bedWidthCm ?? this.bedWidthCm,
      bedHeightCm: bedHeightCm ?? this.bedHeightCm,
      layout: layout ?? this.layout,
    );
  }

  Map<String, dynamic> toJson() => {
        'year': year,
        'vegetableIds': vegetableIds,
        'bedWidthCm': bedWidthCm,
        'bedHeightCm': bedHeightCm,
        'layout': layout.map((e) => e.toJson()).toList(),
      };

  factory GardenYearPlan.fromJson(Map<String, dynamic> json) {
    return GardenYearPlan(
      year: json['year'] as int,
      vegetableIds: (json['vegetableIds'] as List<dynamic>? ?? [])
          .whereType<String>()
          .toList(),
      bedWidthCm: (json['bedWidthCm'] as num?)?.toDouble() ?? 300,
      bedHeightCm: (json['bedHeightCm'] as num?)?.toDouble() ?? 200,
      layout: (json['layout'] as List<dynamic>? ?? [])
          .whereType<Map<String, dynamic>>()
          .map(GardenYearLayoutItem.fromJson)
          .toList(),
    );
  }
}

class GardenHistoryStore extends ChangeNotifier {
  static const _storageKey = 'garden_history_plans_v1';
  final Map<int, GardenYearPlan> _plans = {};
  bool _loaded = false;

  bool get isLoaded => _loaded;

  Iterable<GardenYearPlan> get allPlans =>
      _plans.values.toList()..sort((a, b) => a.year.compareTo(b.year));

  GardenYearPlan? planFor(int year) => _plans[year];

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _plans.clear();
    if (raw != null && raw.isNotEmpty) {
      final data = jsonDecode(raw) as List<dynamic>;
      for (final item in data) {
        final plan = GardenYearPlan.fromJson(item as Map<String, dynamic>);
        _plans[plan.year] = plan;
      }
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> savePlan(GardenYearPlan plan) async {
    _plans[plan.year] = plan;
    await _persist();
    notifyListeners();
  }

  Future<void> setVegetables(int year, List<String> ids) async {
    final existing = _plans[year] ?? GardenYearPlan(year: year);
    await savePlan(existing.copyWith(vegetableIds: ids..sort()));
  }

  Future<void> setBedSize(int year, double widthCm, double heightCm) async {
    final existing = _plans[year] ?? GardenYearPlan(year: year);
    await savePlan(
      existing.copyWith(
        bedWidthCm: widthCm.clamp(80, 4000),
        bedHeightCm: heightCm.clamp(80, 4000),
      ),
    );
  }

  Future<void> setLayout(int year, List<GardenYearLayoutItem> items) async {
    final existing = _plans[year] ?? GardenYearPlan(year: year);
    await savePlan(existing.copyWith(layout: items));
  }

  Future<void> removeYear(int year) async {
    if (_plans.remove(year) != null) {
      await _persist();
      notifyListeners();
    }
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final json = jsonEncode(
      (_plans.values.toList()..sort((a, b) => a.year.compareTo(b.year)))
          .map((e) => e.toJson())
          .toList(),
    );
    await prefs.setString(_storageKey, json);
  }
}

