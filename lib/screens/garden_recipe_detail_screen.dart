import 'package:flutter/material.dart';

import '../data/vegetable_repository.dart';
import '../models/garden_recipe.dart';

class GardenRecipeDetailScreen extends StatelessWidget {
  const GardenRecipeDetailScreen({
    super.key,
    required this.recipe,
    required this.gardenIds,
    required this.repository,
  });

  final GardenRecipe recipe;
  final Set<String> gardenIds;
  final VegetableRepository repository;

  bool _fromGarden(String ingredient) {
    for (final id in recipe.vegetableIds) {
      if (!gardenIds.contains(id)) continue;
      final name = repository.byId(id)?.nameNl;
      if (name != null &&
          ingredient.toLowerCase().contains(name.toLowerCase())) {
        return true;
      }
      if (ingredient.contains('uit de tuin') ||
          ingredient.contains('(uit de tuin)')) {
        return true;
      }
    }
    return ingredient.contains('(uit de tuin)');
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final match = recipe.matchCount(gardenIds);
    final total = recipe.vegetableIds.length;
    final full = recipe.canMakeFully(gardenIds);
    final missingNames = recipe
        .missingIds(gardenIds)
        .map((id) => repository.byId(id)?.nameNl ?? id)
        .toList();
    final minutes = recipe.prepMinutes + recipe.cookMinutes;

    return Scaffold(
      appBar: AppBar(title: Text(recipe.title)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
        children: [
          Material(
            color: cs.surfaceContainerLow,
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.summary,
                    style: t.textTheme.bodyLarge?.copyWith(height: 1.4),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _StatItem(
                        icon: Icons.schedule_outlined,
                        label: '$minutes min',
                      ),
                      _StatItem(
                        icon: Icons.people_outline,
                        label: '${recipe.servings} pers.',
                      ),
                      _StatItem(
                        icon: Icons.eco_outlined,
                        label: full ? 'Volledig uit tuin' : '$match/$total uit tuin',
                        emphasized: match > 0,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (!full && missingNames.isNotEmpty) ...[
            const SizedBox(height: 10),
            Material(
              color: cs.secondaryContainer.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.add_circle_outline, size: 20, color: cs.secondary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Nog niet in je moestuin: ${missingNames.join(', ')}.',
                        style: t.textTheme.bodyMedium?.copyWith(height: 1.35),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 22),
          _DetailSection(
            title: 'Ingrediënten',
            child: Material(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  for (var i = 0; i < recipe.ingredients.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.35)),
                    _IngredientRow(
                      text: recipe.ingredients[i],
                      fromGarden: _fromGarden(recipe.ingredients[i]),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 22),
          _DetailSection(
            title: 'Bereiding',
            child: Material(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                child: Column(
                  children: recipe.steps.asMap().entries.map((e) {
                    return Padding(
                      padding: EdgeInsets.only(top: e.key == 0 ? 0 : 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 26,
                            child: Text(
                              '${e.key + 1}.',
                              style: t.textTheme.labelLarge?.copyWith(
                                color: cs.primary,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              e.value,
                              style: t.textTheme.bodyMedium?.copyWith(height: 1.45),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          if (recipe.tips != null) ...[
            const SizedBox(height: 16),
            Material(
              color: cs.tertiaryContainer.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20, color: cs.tertiary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        recipe.tips!,
                        style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailSection extends StatelessWidget {
  const _DetailSection({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 8),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        child,
      ],
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.label,
    this.emphasized = false,
  });

  final IconData icon;
  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Expanded(
      child: Column(
        children: [
          Icon(
            icon,
            size: 20,
            color: emphasized ? cs.primary : cs.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: t.textTheme.labelSmall?.copyWith(
              color: emphasized ? cs.primary : cs.onSurfaceVariant,
              fontWeight: emphasized ? FontWeight.w600 : FontWeight.w500,
              height: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}

class _IngredientRow extends StatelessWidget {
  const _IngredientRow({
    required this.text,
    required this.fromGarden,
  });

  final String text;
  final bool fromGarden;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            fromGarden ? Icons.eco_outlined : Icons.circle_outlined,
            size: 18,
            color: fromGarden ? cs.primary : cs.outline,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: t.textTheme.bodyMedium?.copyWith(
                fontWeight: fromGarden ? FontWeight.w600 : FontWeight.normal,
                color: fromGarden ? cs.onSurface : cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
