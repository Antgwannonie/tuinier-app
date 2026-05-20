import '../models/vegetable.dart';
import 'vegetables_data.dart';

/// Lokale repository (later te vervangen door API + cache na login).
class VegetableRepository {
  List<Vegetable> get all => List.unmodifiable(kVegetablesSeed);

  List<Vegetable> search(String query) {
    final list =
        kVegetablesSeed.where((v) => v.matchesQuery(query)).toList()
          ..sort((a, b) => a.nameNl.compareTo(b.nameNl));

    return list;
  }

  Vegetable? byId(String id) {
    for (final v in kVegetablesSeed) {
      if (v.id == id) return v;
    }
    return null;
  }
}
