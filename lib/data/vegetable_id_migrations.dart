/// Oude gewas-ids die zijn samengevoegd met een andere entry.
///
/// Sleutel = verwijderde alias, waarde = canonieke id (meest gangbare NL-naam).
const Map<String, String> kVegetableIdMigrations = {
  'paprika': 'rode_paprika',
  'lente_ui': 'bosui',
  'topinambur': 'aardpeer',
  'raapsteeltjes': 'raapstelen',
  'phacelia_tanacetifolia': 'facelia',
  'rode_bes_grootvrucht': 'rode_bes',
  'kruisbess': 'zwarte_bes',
  'aalbes': 'zwarte_bes',
  'raps_kool': 'chinese_kool',
  'lavendel_bloei': 'lavendel',
  'framboos_zomer': 'framboos',
  'braam_zonder_doorn': 'braam',
};

/// Zoektermen die naar het canonieke gewas moeten leiden.
const Map<String, List<String>> kVegetableSearchAliases = {
  'rode_paprika': ['paprika', 'paprika rood', 'rode paprika zoet'],
  'stiefmoedje': ['viooltje', 'viool'],
  'lupine_groenbemester': ['lupine', 'groenbemester lupine'],
  'ringelbloem': ['goudsbloem', 'calendula'],
  'aardpeer': ['topinambur'],
  'raapstelen': ['raapsteeltjes', 'raapsteel'],
  'facelia': ['phacelia', 'phacelia tanacetifolia'],
  'zwarte_bes': ['aalbes', 'kruisbess', 'cassis'],
  'rode_bes': ['grootvrucht rode bes', 'rode bes grootvrucht'],
  'chinese_kool': ['raps kool', 'napa', 'pekinensis'],
  'lavendel': ['lavendel bloei'],
  'framboos': ['zomerframboos'],
  'braam': ['doornloze braam', 'braam zonder doorn'],
  'bosui': ['lente-ui', 'lente ui'],
};

String normalizeVegetableId(String id) => kVegetableIdMigrations[id] ?? id;

Set<String> normalizeVegetableIds(Iterable<String> ids) {
  return ids.map(normalizeVegetableId).toSet();
}

bool vegetableMatchesQuery(String query, {
  required String nameNl,
  String? nameLatin,
  String? family,
  String? growthCategory,
  required List<String> keywords,
  required String vegetableId,
}) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return true;
  final aliases = kVegetableSearchAliases[vegetableId] ?? const [];
  final hay = [
    nameNl,
    if (nameLatin != null) nameLatin,
    if (family != null) family,
    if (growthCategory != null) growthCategory,
    ...keywords,
    ...aliases,
  ].join(' ').toLowerCase();
  return hay.contains(q);
}
