/// Oude gewas-ids die zijn samengevoegd met een andere entry.
const Map<String, String> kVegetableIdMigrations = {
  'lente_ui': 'bosui',
};

String normalizeVegetableId(String id) => kVegetableIdMigrations[id] ?? id;

Set<String> normalizeVegetableIds(Iterable<String> ids) {
  return ids.map(normalizeVegetableId).toSet();
}
