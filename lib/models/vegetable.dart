/// Eén groentegewas in de referentiedatabase (MVP: alleen lokale data).
class Vegetable {
  const Vegetable({
    required this.id,
    required this.nameNl,
    this.nameLatin,
    required this.family,
    required this.summary,
    required this.sowingIndoors,
    required this.sowingOutdoors,
    required this.transplant,
    required this.harvest,
    required this.spacingCm,
    required this.rowSpacingCm,
    required this.sunRequirement,
    required this.water,
    required this.soilAndFood,
    required this.care,
    required this.harvestTips,
    required this.commonIssues,
    required this.keywords,
  });

  final String id;
  final String nameNl;
  final String? nameLatin;
  /// Voor filters (bijv. vlinderbloemen, bladgewassen).
  final String family;

  /// Korte intro (1–2 zinnen).
  final String summary;

  /// Typische periodes voor onder glas/kas of binnen voorzaaien (NL/BE).
  final String sowingIndoors;
  final String sowingOutdoors;
  final String transplant;
  final String harvest;

  final int spacingCm;
  final int rowSpacingCm;

  /// bv. "Volle zon" / "Halfschaduw ok"
  final String sunRequirement;
  final String water;
  final String soilAndFood;
  final String care;
  final String harvestTips;
  final String commonIssues;

  /// Voor zoeken; lowercase fragmenten.
  final List<String> keywords;

  bool matchesQuery(String raw) {
    final q = raw.trim().toLowerCase();
    if (q.isEmpty) return true;
    final hay = [
      nameNl,
      if (nameLatin != null) nameLatin!,
      family,
      ...keywords,
    ].join(' ').toLowerCase();
    return hay.contains(q);
  }
}
