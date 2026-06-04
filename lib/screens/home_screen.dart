import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_history_store.dart';
import '../data/my_garden_store.dart';
import '../data/home_task_timing.dart';
import '../data/planting_calendar.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/garden_plant_schedule.dart';
import '../data/garden_recipe_notifications.dart';
import '../widgets/home_moestuin_actions.dart';
import '../data/plant_health_warnings.dart';
import '../data/recipe_notification_store.dart';
import '../widgets/home_moestuin_section.dart';
import '../widgets/start_new_moestuin.dart';
import '../widgets/garden_warning_style.dart';
import '../widgets/my_garden_history_page.dart';
import '../widgets/my_garden_recipes_page.dart';
import '../widgets/plant_health_warning_sheet.dart';
import '../widgets/tuin_moestuin_title.dart';
import 'add_vegetable_screen.dart';
import 'my_garden_screen.dart';
import 'vegetable_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.recipeNotificationStore,
    required this.historyStore,
    this.onGoToPlantScan,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final RecipeNotificationStore recipeNotificationStore;
  final GardenHistoryStore historyStore;
  final void Function({String? vegetableId, bool harvestProbe})? onGoToPlantScan;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_onGardenChanged);
    widget.profileStore.addListener(_onGardenChanged);
    widget.recipeNotificationStore.addListener(_onGardenChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    widget.gardenStore.removeListener(_onGardenChanged);
    widget.profileStore.removeListener(_onGardenChanged);
    widget.recipeNotificationStore.removeListener(_onGardenChanged);
    super.dispose();
  }

  List<RecipeNotification> _activeRecipeNotifications() {
    return activeRecipeNotifications(
      gardenIds: widget.gardenStore.ids,
      profileFor: widget.profileStore.profileFor,
      isAcknowledged: widget.recipeNotificationStore.isAcknowledged,
      vegetableFor: (id) => widget.repository.byId(id),
    );
  }

  Future<void> _acknowledgeRecipe(RecipeNotification notification) {
    return widget.recipeNotificationStore.acknowledge(
      notification.id,
      notification.fingerprint,
    );
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  void _onGardenChanged() => setState(() {});

  void _openAddVegetable() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AddVegetableScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
        ),
      ),
    );
  }

  Future<void> _startNewMoestuin() async {
    final started = await confirmAndStartNewMoestuin(
      context,
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    if (!started || !mounted) return;
    setState(() {});
  }

  void _openHistory() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => Scaffold(
          appBar: AppBar(
            title: const Text('History'),
          ),
          body: MyGardenHistoryPage(
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            repository: widget.repository,
            scanPrefs: widget.scanPrefs,
          ),
        ),
      ),
    ).then((_) {
      if (mounted) setState(() {});
    });
  }

  void _openGardenManage() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MyGardenScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          onGoToPlantScan: widget.onGoToPlantScan,
        ),
      ),
    );
  }

  Map<String, HomeTaskEntry> _taskEntriesByVegetable(int month) {
    return homeTaskEntriesByVegetableForMonth(
      month: month,
      vegetableIds: widget.gardenStore.ids,
      useAiFor: widget.gardenStore.contains,
      profileFor: widget.profileStore.profileFor,
      vegetableById: widget.repository.byId,
    );
  }

  @override
  Widget build(BuildContext context) {
    final month = DateTime.now().month;
    final monthName = kMonthNamesNl[month];
    final taskEntriesById = _taskEntriesByVegetable(month);

    final pageTitle = switch (_pageIndex) {
      0 => null,
      _ => 'Mijn recepten',
    };
    final actionsNow = collectGardenHomeActions(
      repository: widget.repository,
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      scanPrefs: widget.scanPrefs,
      month: month,
    );
    final warningEntries = profilesWithActiveWarnings(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
    );
    final warningIds = warningEntries.map((e) => e.vegetable.id).toSet();
    final actionById = {for (final a in actionsNow) a.vegetable.id: a};
    final actionBellEntries = <GardenBellActionEntry>[];
    final bellVegetableIds = <String>{};

    for (final action in actionsNow) {
      if (action.kind != GardenHomeActionKind.firstPhoto) continue;
      final id = action.vegetable.id;
      if (warningIds.contains(id)) continue;
      if (!bellVegetableIds.add(id)) continue;
      actionBellEntries.add(
        GardenBellActionEntry(
          vegetable: action.vegetable,
          message: kFirstScanMotivationMessage,
        ),
      );
    }

    for (final e in taskEntriesById.values) {
      if (!e.timing.isActiveNow) continue;
      final veg = widget.repository.byId(e.vegetableId);
      if (veg == null) continue;
      if (warningIds.contains(veg.id)) continue;
      if (!bellVegetableIds.add(veg.id)) continue;
      final action = actionById[veg.id];
      actionBellEntries.add(
        GardenBellActionEntry(
          vegetable: veg,
          message: action != null && action.subtitle.isNotEmpty
              ? 'Actie nu: ${action.subtitle}'
              : 'Actie nu: ${e.activity.type.label}',
        ),
      );
    }
    final bellCount = warningEntries.length + actionBellEntries.length;
    final recipeNotifications = _activeRecipeNotifications();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        leadingWidth: widget.gardenStore.isEmpty ? 48 : 88,
        leading: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'History',
              visualDensity: VisualDensity.compact,
              iconSize: 22,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
              icon: const Icon(Icons.history),
              onPressed: _openHistory,
            ),
            if (!widget.gardenStore.isEmpty)
              IconButton(
                tooltip: 'Nieuwe moestuin',
                visualDensity: VisualDensity.compact,
                iconSize: 22,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
                icon: const Icon(Icons.refresh_rounded),
                onPressed: _startNewMoestuin,
              ),
          ],
        ),
        title: pageTitle != null
            ? Text(pageTitle)
            : const TuinMoestuinTitle(),
        actions: [
          if (_pageIndex == 0 && bellCount > 0)
            IconButton(
              tooltip: 'Meldingen ($bellCount)',
              onPressed: () {
                showGardenWarningsOverview(
                  context: context,
                  profileStore: widget.profileStore,
                  repository: widget.repository,
                  entries: warningEntries,
                  actionEntries: actionBellEntries,
                  onOpenPlantDetail: (veg) => _openDetail(
                    veg,
                    month,
                    openWarningsTab: true,
                  ),
                );
              },
              icon: Badge(
                backgroundColor:
                    GardenWarningStyle.badgeSolid(Theme.of(context).colorScheme),
                label: Text(
                  '$bellCount',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                child: Icon(
                  Icons.notifications_active_outlined,
                  color: GardenWarningStyle.icon(Theme.of(context).colorScheme),
                ),
              ),
            ),
          IconButton(
            tooltip: 'Instellingen',
            icon: const Icon(Icons.tune),
            onPressed: _openGardenManage,
          ),
        ],
      ),
      floatingActionButton: _pageIndex == 0
          ? FloatingActionButton(
              onPressed: _openAddVegetable,
              tooltip: 'Groente toevoegen',
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: _HomePageSwitcher(
              index: _pageIndex,
              onChanged: _goToPage,
              recipesBadgeCount: recipeNotifications.length,
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              children: [
                ListView(
                  padding: const EdgeInsets.only(bottom: 88),
                  children: [
                    HomeMoestuinSection(
                      repository: widget.repository,
                      gardenStore: widget.gardenStore,
                      profileStore: widget.profileStore,
                      scanPrefs: widget.scanPrefs,
                      month: month,
                      monthName: monthName,
                      taskEntriesById: taskEntriesById,
                      taskIconFor: _taskIcon,
                      onAddPlant: _openAddVegetable,
                      onOpenDetail: (veg, {openWarningsTab = false}) =>
                          _openDetail(
                            veg,
                            month,
                            openWarningsTab: openWarningsTab,
                          ),
                      onGoToPlantScan: widget.onGoToPlantScan,
                      onMarkedPlanted: () => syncGardenNotifications(
                        profileStore: widget.profileStore,
                        gardenStore: widget.gardenStore,
                        repository: widget.repository,
                        scanPrefs: widget.scanPrefs,
                      ),
                    ),
                  ],
                ),
                MyGardenRecipesPage(
                  gardenStore: widget.gardenStore,
                  repository: widget.repository,
                  recipeNotifications: recipeNotifications,
                  onAcknowledgeRecipe: _acknowledgeRecipe,
                  onAddPlants: _openAddVegetable,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  IconData _taskIcon(GardenTaskType type) {
    switch (type) {
      case GardenTaskType.plantOutdoors:
        return Icons.yard_outlined;
      case GardenTaskType.sowOutdoors:
        return Icons.grass_outlined;
      case GardenTaskType.preSow:
        return Icons.spa_outlined;
      case GardenTaskType.harvest:
        return Icons.shopping_basket_outlined;
    }
  }

  void _openDetail(
    Vegetable veg,
    int month, {
    bool openWarningsTab = false,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(
          vegetable: veg,
          focusMonth: month,
          gardenStore: widget.gardenStore,
          repository: widget.repository,
          profileStore: widget.gardenStore.contains(veg.id)
              ? widget.profileStore
              : null,
          scanPrefs: widget.scanPrefs,
          initialSection: openWarningsTab
              ? VegetableDetailSection.warnings
              : VegetableDetailSection.info,
          onGoToPlantScan: widget.gardenStore.contains(veg.id) &&
                  widget.onGoToPlantScan != null
              ? () => widget.onGoToPlantScan!(vegetableId: veg.id)
              : null,
        ),
      ),
    );
  }

}

class _HomePageSwitcher extends StatelessWidget {
  const _HomePageSwitcher({
    required this.index,
    required this.onChanged,
    this.recipesBadgeCount = 0,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final int recipesBadgeCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              moestuinTitle: true,
              selected: index == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _Segment(
              label: 'Mijn recepten',
              selected: index == 1,
              onTap: () => onChanged(1),
              badgeCount: recipesBadgeCount,
            ),
          ),
        ],
      ),
    );
  }
}

class _Segment extends StatelessWidget {
  const _Segment({
    this.label,
    this.moestuinTitle = false,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  }) : assert(label != null || moestuinTitle);

  final String? label;
  final bool moestuinTitle;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final showBadge = badgeCount > 0 && !selected;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            color: selected ? cs.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(14),
          ),
          child: SizedBox(
            width: double.infinity,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                moestuinTitle
                    ? TuinMoestuinTitle(
                        compact: true,
                        color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                      )
                    : Text(
                        label!,
                        textAlign: TextAlign.center,
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? cs.onPrimary
                              : cs.onSurfaceVariant,
                        ),
                      ),
                if (showBadge)
                  Positioned(
                    right: 4,
                    top: -6,
                    child: Container(
                    constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: cs.tertiary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: t.textTheme.labelSmall?.copyWith(
                        color: cs.onTertiary,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                        height: 1,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
