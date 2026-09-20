import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden_planner_task.dart';

/// Handmatig geplande tuininacties uit de Planner-tab.
class GardenPlannerTaskStore extends ChangeNotifier {
  static const _storageKey = 'garden_planner_tasks_v1';

  final List<GardenPlannerTask> _tasks = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<GardenPlannerTask> get all => List.unmodifiable(_tasks);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _tasks.clear();
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        _tasks.add(
          GardenPlannerTask.fromJson(item as Map<String, dynamic>),
        );
      }
    }
    _sort();
    _loaded = true;
    notifyListeners();
  }

  /// Taken in de komende 7 dagen (inclusief vandaag), niet afgerond.
  List<GardenPlannerTask> upcomingThisWeek({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final end = today.add(const Duration(days: 7));
    return _tasks
        .where(
          (t) =>
              !t.completed &&
              !t.dueDateOnly.isBefore(today) &&
              t.dueDateOnly.isBefore(end),
        )
        .toList();
  }

  /// Taken na de komende week, niet afgerond.
  List<GardenPlannerTask> plannedAfterWeek({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    final end = today.add(const Duration(days: 7));
    return _tasks
        .where((t) => !t.completed && !t.dueDateOnly.isBefore(end))
        .toList();
  }

  /// Niet-afgeronde taken op een specifieke dag.
  List<GardenPlannerTask> forDay(DateTime day) {
    final d = _dateOnly(day);
    return _tasks
        .where((t) => !t.completed && t.dueDateOnly == d)
        .toList();
  }

  int countToday({DateTime? now}) {
    final today = _dateOnly(now ?? DateTime.now());
    return forDay(today).length;
  }

  int countThisWeek({DateTime? now}) =>
      upcomingThisWeek(now: now).length;

  int countThisMonth({DateTime? now}) {
    final d = now ?? DateTime.now();
    return _tasks
        .where(
          (t) =>
              !t.completed &&
              t.dueDate.year == d.year &&
              t.dueDate.month == d.month,
        )
        .length;
  }

  int countThisSeason({DateTime? now}) {
    final d = now ?? DateTime.now();
    final seasonMonths = _seasonMonths(d.month);
    return _tasks
        .where(
          (t) =>
              !t.completed &&
              t.dueDate.year == d.year &&
              seasonMonths.contains(t.dueDate.month),
        )
        .length;
  }

  String seasonLabel({DateTime? now}) {
    final m = (now ?? DateTime.now()).month;
    if (m >= 3 && m <= 5) return 'Lente';
    if (m >= 6 && m <= 8) return 'Zomer';
    if (m >= 9 && m <= 11) return 'Herfst';
    return 'Winter';
  }

  Future<void> upsert(GardenPlannerTask task) async {
    final i = _tasks.indexWhere((t) => t.id == task.id);
    if (i >= 0) {
      _tasks[i] = task;
    } else {
      _tasks.add(task);
    }
    _sort();
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _tasks.removeWhere((t) => t.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> setCompleted(String id, bool completed) async {
    final i = _tasks.indexWhere((t) => t.id == id);
    if (i < 0) return;
    _tasks[i] = _tasks[i].copyWith(completed: completed);
    await _persist();
    notifyListeners();
  }

  void _sort() {
    _tasks.sort((a, b) {
      final byDate = a.dueDateOnly.compareTo(b.dueDateOnly);
      if (byDate != 0) return byDate;
      return (b.createdAt ?? b.dueDate)
          .compareTo(a.createdAt ?? a.dueDate);
    });
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _storageKey,
      jsonEncode(_tasks.map((t) => t.toJson()).toList()),
    );
  }

  static DateTime _dateOnly(DateTime d) =>
      DateTime(d.year, d.month, d.day);

  static Set<int> _seasonMonths(int month) {
    if (month >= 3 && month <= 5) return {3, 4, 5};
    if (month >= 6 && month <= 8) return {6, 7, 8};
    if (month >= 9 && month <= 11) return {9, 10, 11};
    return {12, 1, 2};
  }
}
