import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/vegetable.dart';
import 'my_garden_store.dart';
import 'vegetable_repository.dart';

/// Hoe de plantkalender gefilterd wordt.
enum CalendarViewMode {
  myGarden,
  all,
  custom,
}

/// Categorieën om de kalender minder druk te maken.
enum CalendarPlantCategory {
  groenten,
  fruit,
  kruiden,
  paddestoelen,
  meerjarig,
  companionFlowers,
}

extension CalendarPlantCategoryLabel on CalendarPlantCategory {
  String get label {
    switch (this) {
      case CalendarPlantCategory.groenten:
        return 'Groenten';
      case CalendarPlantCategory.fruit:
        return 'Fruit & bessen';
      case CalendarPlantCategory.kruiden:
        return 'Kruiden';
      case CalendarPlantCategory.paddestoelen:
        return 'Paddestoelen';
      case CalendarPlantCategory.meerjarig:
        return 'Meerjarig';
      case CalendarPlantCategory.companionFlowers:
        return 'Nuttige moestuinbloemen';
    }
  }

  String get storageKey => name;
}

CalendarPlantCategory calendarCategoryFor(Vegetable vegetable) {
  final family = vegetable.family.toLowerCase();
  final category = vegetable.growthCategory?.toLowerCase() ?? '';
  final keywords =
      vegetable.keywords.map((k) => k.toLowerCase()).join(' ');

  if (category.contains('moestuin-bloemen') ||
      keywords.contains('nuttige bloemen') ||
      keywords.contains('gezelschapsplant')) {
    return CalendarPlantCategory.companionFlowers;
  }
  if (family.contains('paddestoel') || keywords.contains('paddenstoel')) {
    return CalendarPlantCategory.paddestoelen;
  }
  if (category.contains('fruit') ||
      category.contains('boom') ||
      category.contains('bes') ||
      keywords.contains('fruitboom') ||
      keywords.contains('fruit')) {
    return CalendarPlantCategory.fruit;
  }
  if (keywords.contains('kruid') ||
      category.contains('kruid') ||
      family.contains('lipbloem')) {
    return CalendarPlantCategory.kruiden;
  }
  if (category.contains('meerjarig') ||
      keywords.contains('rabarber') ||
      keywords.contains('asperge')) {
    return CalendarPlantCategory.meerjarig;
  }
  return CalendarPlantCategory.groenten;
}

/// Welke gewassen in de kalender zichtbaar zijn.
class CalendarDisplayPrefsStore extends ChangeNotifier {
  static const _modeKey = 'calendar_view_mode';
  static const _customIdsKey = 'calendar_custom_vegetable_ids';
  static const _categoriesKey = 'calendar_enabled_categories';

  CalendarViewMode _mode = CalendarViewMode.myGarden;
  Set<String> _customIds = {};
  Set<CalendarPlantCategory> _enabledCategories =
      Set<CalendarPlantCategory>.from(CalendarPlantCategory.values);
  bool _loaded = false;

  bool get isLoaded => _loaded;
  CalendarViewMode get mode => _mode;
  Set<String> get customIds => Set.unmodifiable(_customIds);
  Set<CalendarPlantCategory> get enabledCategories =>
      Set.unmodifiable(_enabledCategories);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final modeName = prefs.getString(_modeKey);
    _mode = CalendarViewMode.values.firstWhere(
      (m) => m.name == modeName,
      orElse: () => CalendarViewMode.myGarden,
    );
    _customIds = (prefs.getStringList(_customIdsKey) ?? []).toSet();
    final catKeys = prefs.getStringList(_categoriesKey);
    if (catKeys == null || catKeys.isEmpty) {
      _enabledCategories = Set<CalendarPlantCategory>.from(
        CalendarPlantCategory.values,
      );
    } else {
      _enabledCategories = {
        for (final key in catKeys)
          CalendarPlantCategory.values.firstWhere(
            (c) => c.storageKey == key,
            orElse: () => CalendarPlantCategory.groenten,
          ),
      };
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> setMode(CalendarViewMode mode) async {
    if (_mode == mode) return;
    _mode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
    notifyListeners();
  }

  Future<void> setCustomIds(Set<String> ids) async {
    _customIds = ids;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_customIdsKey, ids.toList()..sort());
    notifyListeners();
  }

  Future<void> toggleCustomId(String id, bool selected) async {
    final next = Set<String>.from(_customIds);
    if (selected) {
      next.add(id);
    } else {
      next.remove(id);
    }
    await setCustomIds(next);
  }

  Future<void> setCategoryEnabled(
    CalendarPlantCategory category,
    bool enabled,
  ) async {
    final next = Set<CalendarPlantCategory>.from(_enabledCategories);
    if (enabled) {
      next.add(category);
    } else {
      next.remove(category);
    }
    if (next.isEmpty) {
      next.add(CalendarPlantCategory.groenten);
    }
    _enabledCategories = next;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _categoriesKey,
      next.map((c) => c.storageKey).toList()..sort(),
    );
    notifyListeners();
  }

  bool passesCategoryFilter(Vegetable? vegetable) {
    if (vegetable == null) return false;
    return _enabledCategories.contains(calendarCategoryFor(vegetable));
  }

  /// Gewas-ids die op de kalender getoond worden.
  ///
  /// Met [gardenOnly] (Planner-tab) alleen planten uit de moestuin; nooit de
  /// volledige database. Zonder moestuinplanten: lege set.
  Set<String> visibleVegetableIds({
    required VegetableRepository repository,
    required MyGardenStore gardenStore,
    bool gardenOnly = false,
  }) {
    Iterable<String> candidateIds;
    if (gardenOnly) {
      candidateIds = gardenStore.ids;
    } else {
      switch (_mode) {
        case CalendarViewMode.myGarden:
          // Alleen moestuinplanten — geen fallback naar de hele database.
          candidateIds = gardenStore.ids;
        case CalendarViewMode.all:
          candidateIds = repository.all.map((v) => v.id);
        case CalendarViewMode.custom:
          candidateIds = _customIds;
      }
    }

    final filtered = <String>{
      for (final id in candidateIds)
        if (passesCategoryFilter(repository.byId(id))) id,
    };
    return filtered;
  }

  String subtitle({
    required MyGardenStore gardenStore,
    required int visibleCount,
    required int totalCount,
    bool gardenOnly = false,
  }) {
    if (gardenOnly) {
      if (gardenStore.isEmpty) {
        return 'Mijn moestuin · voeg eerst planten toe';
      }
      return 'Mijn moestuin · $visibleCount plant(en)';
    }
    final modeLabel = switch (_mode) {
      CalendarViewMode.myGarden =>
        gardenStore.isEmpty ? 'Mijn moestuin (leeg)' : 'Mijn moestuin',
      CalendarViewMode.all => 'Alle groenten',
      CalendarViewMode.custom => 'Zelf gekozen',
    };
    return '$modeLabel · $visibleCount van $totalCount zichtbaar';
  }
}
