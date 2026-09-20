import 'package:flutter/material.dart';

import '../data/garden_recipe_notifications.dart';
import '../data/garden_recipes_data.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_recipe.dart';
import '../screens/garden_recipe_detail_screen.dart';

/// Receptenboek dat meebeweegt met Mijn moestuin.
class MyGardenRecipesPage extends StatelessWidget {
  const MyGardenRecipesPage({
    super.key,
    required this.gardenStore,
    required this.repository,
    required this.recipeNotifications,
    required this.onAcknowledgeRecipe,
    this.onAddPlants,
  });

  final MyGardenStore gardenStore;
  final VegetableRepository repository;
  final List<RecipeNotification> recipeNotifications;
  final Future<void> Function(RecipeNotification notification) onAcknowledgeRecipe;
  final VoidCallback? onAddPlants;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: gardenStore,
      builder: (context, _) {
        final book = personalizedRecipeBook(gardenStore.ids);
        return _RecipesBody(
          book: book,
          repository: repository,
          recipeNotifications: recipeNotifications,
          onAcknowledgeRecipe: onAcknowledgeRecipe,
          onAddPlants: onAddPlants,
        );
      },
    );
  }
}

class _RecipesBody extends StatelessWidget {
  const _RecipesBody({
    required this.book,
    required this.repository,
    required this.recipeNotifications,
    required this.onAcknowledgeRecipe,
    this.onAddPlants,
  });

  final PersonalizedRecipeBook book;
  final VegetableRepository repository;
  final List<RecipeNotification> recipeNotifications;
  final Future<void> Function(RecipeNotification notification) onAcknowledgeRecipe;
  final VoidCallback? onAddPlants;

  Map<String, RecipeNotification> get _notificationByRecipeId {
    return {for (final n in recipeNotifications) n.id: n};
  }

  List<String> _gardenNames() {
    return book.gardenIds
        .map((id) => repository.byId(id)?.nameNl ?? id)
        .toList()
      ..sort();
  }

  Future<void> _openDetail(BuildContext context, GardenRecipe recipe) async {
    final notification = _notificationByRecipeId[recipe.id];
    if (notification != null) {
      await onAcknowledgeRecipe(notification);
    }
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GardenRecipeDetailScreen(
          recipe: recipe,
          gardenIds: book.gardenIds,
          repository: repository,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gardenNames = _gardenNames();

    if (book.gardenIds.isEmpty) {
      return _RecipesEmptyView(
        icon: Icons.menu_book_outlined,
        title: 'Jouw receptenboek',
        body:
            'Voeg groenten toe aan Mijn moestuin. Recepten worden dan '
            'automatisch gekozen op wat je in de tuin hebt.',
        action: onAddPlants == null
            ? null
            : FilledButton.icon(
                onPressed: onAddPlants,
                icon: const Icon(Icons.add),
                label: const Text('Groente toevoegen'),
              ),
      );
    }

    if (book.isEmpty) {
      return _RecipesEmptyView(
        icon: Icons.restaurant_menu_outlined,
        title: 'Nog geen recepten',
        body:
            'Met je huidige planten (${_shortPlantList(gardenNames)}) '
            'past nog niets in het boek. Voeg combinaties toe, '
            'sla met tomaat of wortel met bosui, voor nieuwe ideeën.',
        footer: _GardenPlantsStrip(names: gardenNames),
      );
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        if (recipeNotifications.isNotEmpty) ...[
          _RecipeNotificationsBanner(notifications: recipeNotifications),
          const SizedBox(height: 12),
        ],
        _RecipesSummaryHeader(
          recipeCount: book.totalCount,
          plantCount: gardenNames.length,
        ),
        if (gardenNames.isNotEmpty) ...[
          const SizedBox(height: 10),
          _GardenPlantsStrip(names: gardenNames),
        ],
        if (book.readyNow.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionLabel(
            title: 'Klaar om te maken',
            count: book.readyNow.length,
          ),
          ...book.readyNow.map(
            (r) => _RecipeListCard(
              recipe: r,
              gardenIds: book.gardenIds,
              notification: _notificationByRecipeId[r.id],
              onTap: () => _openDetail(context, r),
            ),
          ),
        ],
        if (book.withYourVegetables.isNotEmpty) ...[
          const SizedBox(height: 20),
          _SectionLabel(
            title: book.readyNow.isEmpty
                ? 'Passend bij je tuin'
                : 'Ook met jouw groenten',
            count: book.withYourVegetables.length,
          ),
          ...book.withYourVegetables.map(
            (r) => _RecipeListCard(
              recipe: r,
              gardenIds: book.gardenIds,
              notification: _notificationByRecipeId[r.id],
              onTap: () => _openDetail(context, r),
            ),
          ),
        ],
      ],
    );
  }
}

String _shortPlantList(List<String> names) {
  if (names.isEmpty) return '—';
  if (names.length <= 3) return names.join(', ');
  return '${names.take(2).join(', ')} en ${names.length - 2} meer';
}

class _RecipesEmptyView extends StatelessWidget {
  const _RecipesEmptyView({
    required this.icon,
    required this.title,
    required this.body,
    this.action,
    this.footer,
  });

  final IconData icon;
  final String title;
  final String body;
  final Widget? action;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 32, 24, 28),
      children: [
        Icon(icon, size: 48, color: cs.primary.withValues(alpha: 0.85)),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        Text(
          body,
          textAlign: TextAlign.center,
          style: t.textTheme.bodyMedium?.copyWith(
            color: cs.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        if (footer != null) ...[
          const SizedBox(height: 20),
          footer!,
        ],
        if (action != null) ...[
          const SizedBox(height: 24),
          SizedBox(width: double.infinity, child: action),
        ],
      ],
    );
  }
}

class _RecipesSummaryHeader extends StatelessWidget {
  const _RecipesSummaryHeader({
    required this.recipeCount,
    required this.plantCount,
  });

  final int recipeCount;
  final int plantCount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book_outlined, color: cs.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$recipeCount recept${recipeCount == 1 ? '' : 'en'}',
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Op basis van $plantCount plant${plantCount == 1 ? '' : 'en'} in je moestuin',
                    style: t.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GardenPlantsStrip extends StatelessWidget {
  const _GardenPlantsStrip({required this.names});

  final List<String> names;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: names.length,
        separatorBuilder: (_, __) => const SizedBox(width: 6),
        itemBuilder: (context, i) {
          return Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: cs.surfaceContainerHighest.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.eco_outlined, size: 14, color: cs.primary),
                const SizedBox(width: 4),
                Text(
                  names[i],
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _RecipeNotificationsBanner extends StatelessWidget {
  const _RecipeNotificationsBanner({required this.notifications});

  final List<RecipeNotification> notifications;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final count = notifications.length;
    final first = notifications.first;

    return Material(
      color: cs.tertiaryContainer.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.restaurant, size: 22, color: cs.tertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        count == 1
                            ? 'Nieuw recept voor jou'
                            : '$count nieuwe recepten',
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        count == 1
                            ? '${first.recipe.title}, ${first.shortLabel}'
                            : 'Open een recept om de melding weg te halen.',
                        style: t.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (count > 1) ...[
              const SizedBox(height: 10),
              ...notifications.take(3).map((n) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    children: [
                      Icon(
                        n.kind == RecipeNotificationKind.full
                            ? Icons.check_circle_outline
                            : Icons.eco_outlined,
                        size: 16,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          n.recipe.title,
                          style: t.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }),
              if (count > 3)
                Text(
                  'En ${count - 3} meer…',
                  style: t.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.title, required this.count});

  final String title;
  final int count;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                letterSpacing: 0.1,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: cs.secondaryContainer.withValues(alpha: 0.65),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$count',
              style: t.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RecipeListCard extends StatelessWidget {
  const _RecipeListCard({
    required this.recipe,
    required this.gardenIds,
    this.notification,
    required this.onTap,
  });

  final GardenRecipe recipe;
  final Set<String> gardenIds;
  final RecipeNotification? notification;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final match = recipe.matchCount(gardenIds);
    final total = recipe.vegetableIds.length;
    final full = recipe.canMakeFully(gardenIds);
    final minutes = recipe.prepMinutes + recipe.cookMinutes;
    final fraction = recipe.matchFraction(gardenIds);

    final highlighted = notification != null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: highlighted
            ? cs.primaryContainer.withValues(alpha: 0.35)
            : cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notification != null) ...[
                  Row(
                    children: [
                      Icon(
                        notification!.kind == RecipeNotificationKind.full
                            ? Icons.restaurant_menu
                            : Icons.eco_outlined,
                        size: 16,
                        color: cs.primary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          notification!.shortLabel,
                          style: t.textTheme.labelSmall?.copyWith(
                            color: cs.primary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                ],
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        recipe.title,
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  recipe.summary,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: t.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: fraction,
                    minHeight: 4,
                    backgroundColor: cs.surfaceContainerHighest,
                    color: full ? cs.primary : cs.primary.withValues(alpha: 0.55),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.schedule, size: 15, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(
                      '$minutes min · ${recipe.servings} pers.',
                      style: t.textTheme.labelMedium?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    _MatchBadge(full: full, match: match, total: total),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({
    required this.full,
    required this.match,
    required this.total,
  });

  final bool full;
  final int match;
  final int total;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: full
            ? cs.primaryContainer
            : cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        full ? 'Volledig' : '$match/$total',
        style: t.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: full ? cs.onPrimaryContainer : cs.onSurfaceVariant,
        ),
      ),
    );
  }
}
