import '../models/vegetable.dart';
import '../models/vegetable_group.dart';
import 'vegetables_data.dart';

/// Lokale repository (later te vervangen door API + cache na login).
class VegetableRepository {
  static const _categoryOrder = <String, int>{
    'Snelle groeiers': 0,
    'Middelmatige groeiers': 1,
    'Lang producerende zomerplanten': 2,
  };

  List<Vegetable> get all {
    final list = List<Vegetable>.from(kVegetablesSeed);
    list.sort((a, b) {
      final ca = _categoryOrder[a.growthCategory] ?? 99;
      final cb = _categoryOrder[b.growthCategory] ?? 99;
      if (ca != cb) return ca.compareTo(cb);
      return a.nameNl.compareTo(b.nameNl);
    });
    return List.unmodifiable(list);
  }

  List<Vegetable> search(String query) {
    return all.where((v) => v.matchesQuery(query)).toList();
  }

  Vegetable? byId(String id) {
    for (final v in kVegetablesSeed) {
      if (v.id == id) return v;
    }
    return null;
  }

  List<Vegetable> inGroup(VegetableGroup group) {
    final list = <Vegetable>[];
    for (final id in group.vegetableIds) {
      final v = byId(id);
      if (v != null) list.add(v);
    }
    list.sort((a, b) => a.nameNl.compareTo(b.nameNl));
    return list;
  }
}
