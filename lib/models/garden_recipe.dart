/// Recept met groenten uit de moestuin.
class GardenRecipe {
  const GardenRecipe({
    required this.id,
    required this.title,
    required this.summary,
    required this.vegetableIds,
    required this.servings,
    required this.prepMinutes,
    required this.cookMinutes,
    required this.ingredients,
    required this.steps,
    this.tips,
  });

  final String id;
  final String title;
  final String summary;
  final List<String> vegetableIds;
  final int servings;
  final int prepMinutes;
  final int cookMinutes;
  final List<String> ingredients;
  final List<String> steps;
  final String? tips;

  int matchCount(Set<String> gardenIds) =>
      vegetableIds.where(gardenIds.contains).length;

  List<String> matchedIds(Set<String> gardenIds) =>
      vegetableIds.where(gardenIds.contains).toList();

  List<String> missingIds(Set<String> gardenIds) =>
      vegetableIds.where((id) => !gardenIds.contains(id)).toList();

  /// Alle groenten van dit recept staan in Mijn moestuin.
  bool canMakeFully(Set<String> gardenIds) =>
      vegetableIds.isNotEmpty &&
      vegetableIds.every(gardenIds.contains);

  double matchFraction(Set<String> gardenIds) {
    if (vegetableIds.isEmpty) return 0;
    return matchCount(gardenIds) / vegetableIds.length;
  }
}

/// Receptenboek afgestemd op de huidige inhoud van Mijn moestuin.
class PersonalizedRecipeBook {
  const PersonalizedRecipeBook({
    required this.gardenIds,
    required this.readyNow,
    required this.withYourVegetables,
  });

  final Set<String> gardenIds;
  /// Recept waarbij elke tuin-groente van het recept in je moestuin staat.
  final List<GardenRecipe> readyNow;
  /// Recept met minstens één match; overige tuin-groenten ontbreken nog in je lijst.
  final List<GardenRecipe> withYourVegetables;

  bool get isEmpty => readyNow.isEmpty && withYourVegetables.isEmpty;

  int get totalCount => readyNow.length + withYourVegetables.length;
}
