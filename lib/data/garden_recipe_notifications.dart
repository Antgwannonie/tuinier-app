import '../models/garden_plant_profile.dart';
import '../models/garden_recipe.dart';
import '../models/vegetable.dart';
import 'garden_plant_schedule.dart';
import 'garden_recipes_data.dart';

enum RecipeNotificationKind {
  full,
  harvestReady,
}

/// In-app melding op Mijn recepten (badge + highlight).
class RecipeNotification {
  const RecipeNotification({
    required this.recipe,
    required this.kind,
    required this.harvestableVegetableIds,
  });

  final GardenRecipe recipe;
  final RecipeNotificationKind kind;
  final List<String> harvestableVegetableIds;

  String get id => recipe.id;

  String get fingerprint {
    final harvest = [...harvestableVegetableIds]..sort();
    return '${kind.name}:${harvest.join(',')}';
  }

  String get shortLabel {
    switch (kind) {
      case RecipeNotificationKind.full:
        if (harvestableVegetableIds.isNotEmpty) {
          return 'Klaar om te maken — oogst uit je tuin';
        }
        return 'Volledig recept uit je moestuin';
      case RecipeNotificationKind.harvestReady:
        return 'Oogstbaar uit je tuin';
    }
  }
}

Set<String> harvestableGardenVegetableIds(
  Iterable<String> gardenIds, {
  required GardenPlantProfile? Function(String id) profileFor,
  Vegetable? Function(String id)? vegetableFor,
}) {
  final out = <String>{};
  for (final id in gardenIds) {
    final profile = profileFor(id);
    final veg = vegetableFor?.call(id);
    if (profile != null &&
        profile.isPlanted &&
        isReadyToHarvest(profile, vegetable: veg)) {
      out.add(id);
    }
  }
  return out;
}

/// Actieve receptmeldingen (nog niet bekeken / situatie gewijzigd).
List<RecipeNotification> activeRecipeNotifications({
  required Set<String> gardenIds,
  required GardenPlantProfile? Function(String id) profileFor,
  required bool Function(String recipeId, String fingerprint) isAcknowledged,
  Vegetable? Function(String id)? vegetableFor,
}) {
  if (gardenIds.isEmpty) return const [];

  final book = personalizedRecipeBook(gardenIds);
  final harvestable = harvestableGardenVegetableIds(
    gardenIds,
    profileFor: profileFor,
    vegetableFor: vegetableFor,
  );
  final seen = <String>{};
  final out = <RecipeNotification>[];

  void consider(GardenRecipe recipe) {
    if (!seen.add(recipe.id)) return;

    final matched = recipe.matchedIds(gardenIds);
    final matchedHarvest =
        matched.where(harvestable.contains).toList(growable: false);
    final full = recipe.canMakeFully(gardenIds);

    RecipeNotification? notification;
    if (full) {
      notification = RecipeNotification(
        recipe: recipe,
        kind: RecipeNotificationKind.full,
        harvestableVegetableIds: matchedHarvest,
      );
    } else if (matchedHarvest.isNotEmpty) {
      notification = RecipeNotification(
        recipe: recipe,
        kind: RecipeNotificationKind.harvestReady,
        harvestableVegetableIds: matchedHarvest,
      );
    }

    if (notification == null) return;
    if (isAcknowledged(recipe.id, notification.fingerprint)) return;
    out.add(notification);
  }

  for (final r in book.readyNow) {
    consider(r);
  }
  for (final r in book.withYourVegetables) {
    consider(r);
  }

  out.sort((a, b) {
    final kindOrder = a.kind.index.compareTo(b.kind.index);
    if (kindOrder != 0) return kindOrder;
    return a.recipe.title.compareTo(b.recipe.title);
  });

  return out;
}
