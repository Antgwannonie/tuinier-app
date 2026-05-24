/// Verzameling groenten onder één kopje (bijv. "Bieten", "Sla soorten").
class VegetableGroup {
  const VegetableGroup({
    required this.id,
    required this.nameNl,
    required this.vegetableIds,
  });

  final String id;
  final String nameNl;

  /// ids uit [Vegetable.id] — geen dubbele ids per groep.
  final List<String> vegetableIds;
}
