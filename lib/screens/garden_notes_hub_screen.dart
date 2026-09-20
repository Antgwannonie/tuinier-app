import 'package:flutter/material.dart';

import '../data/add_plant_apply.dart';
import '../data/ai_settings_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/plant_season_activation.dart';
import '../data/garden_notes_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_recipe_notifications.dart';
import '../data/calendar_display_prefs_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/recipe_notification_store.dart';
import '../data/vegetable_repository.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/garden_notes_day_page.dart';
import '../widgets/my_garden_recipes_page.dart';
import '../widgets/add_plant_wizard_screen.dart';
import 'garden_calendar_screen.dart';

/// Notities-tab met kalender en receptenboek.
class GardenNotesHubScreen extends StatefulWidget {
  const GardenNotesHubScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.calendarPrefs,
    required this.notesStore,
    required this.recipeNotificationStore,
    required this.aiSettings,
    this.plannerMode = false,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final CalendarDisplayPrefsStore calendarPrefs;
  final GardenNotesStore notesStore;
  final RecipeNotificationStore recipeNotificationStore;
  final AiSettingsStore aiSettings;
  final bool plannerMode;

  @override
  State<GardenNotesHubScreen> createState() => _GardenNotesHubScreenState();
}

class _GardenNotesHubScreenState extends State<GardenNotesHubScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<GardenNotesDayPageState> _dayPageKey = GlobalKey();
  int _pageIndex = 0;

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_onStoresChanged);
    widget.profileStore.addListener(_onStoresChanged);
    widget.recipeNotificationStore.addListener(_onStoresChanged);
  }

  @override
  void dispose() {
    _pageController.dispose();
    widget.gardenStore.removeListener(_onStoresChanged);
    widget.profileStore.removeListener(_onStoresChanged);
    widget.recipeNotificationStore.removeListener(_onStoresChanged);
    super.dispose();
  }

  void _onStoresChanged() => setState(() {});

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

  Future<void> _openAddVegetable() async {
    final setup = await showAddPlantWizard(
      context,
      repository: widget.repository,
      aiSettings: widget.aiSettings,
    );
    if (setup == null || !mounted) return;

    final added = await applyAddPlantSetup(
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      setup: setup,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    if (!mounted) return;
    if (!added) {
      final veg = widget.repository.byId(setup.vegetableId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${veg?.nameNl ?? 'Plant'} staat al in je moestuin')),
      );
      return;
    }
    await syncGardenNotifications(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    final veg = widget.repository.byId(setup.vegetableId);
    if (veg != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            addPlantSuccessMessage(
              plantName: veg.nameNl,
              setup: setup,
              added: true,
              vegetable: veg,
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recipeNotifications = _activeRecipeNotifications();
    final title = widget.plannerMode
        ? 'Planner'
        : switch (_pageIndex) {
            0 => 'Notities',
            1 => 'Kalender',
            _ => 'Mijn recepten',
          };

    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: TuinierColors.border, height: 1),
        ),
        title: Padding(
          padding: const EdgeInsets.only(left: 18),
          child: Text(title),
        ),
      ),
      floatingActionButton: _pageIndex == 0
          ? FloatingActionButton(
              onPressed: () => _dayPageKey.currentState?.openAddNote(),
              tooltip: 'Notitie toevoegen',
              child: const Icon(Icons.add),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: _NotesHubSwitcher(
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
                GardenNotesDayPage(
                  key: _dayPageKey,
                  notesStore: widget.notesStore,
                  repository: widget.repository,
                  gardenStore: widget.gardenStore,
                  profileStore: widget.profileStore,
                  scanPrefs: widget.scanPrefs,
                ),
                GardenCalendarScreen(
                  repository: widget.repository,
                  gardenStore: widget.gardenStore,
                  profileStore: widget.profileStore,
                  scanPrefs: widget.scanPrefs,
                  calendarPrefs: widget.calendarPrefs,
                  notesStore: widget.notesStore,
                  embedded: true,
                  showAppBar: false,
                  gardenOnly: widget.plannerMode,
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
}

class _NotesHubSwitcher extends StatelessWidget {
  const _NotesHubSwitcher({
    required this.index,
    required this.onChanged,
    this.recipesBadgeCount = 0,
  });

  final int index;
  final ValueChanged<int> onChanged;
  final int recipesBadgeCount;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: TuinierColors.card,
      borderRadius: BorderRadius.circular(12),
      child: Row(
        children: [
          Expanded(
            child: _Segment(
              label: 'Notities',
              selected: index == 0,
              onTap: () => onChanged(0),
            ),
          ),
          Expanded(
            child: _Segment(
              label: 'Kalender',
              selected: index == 1,
              onTap: () => onChanged(1),
            ),
          ),
          Expanded(
            child: _Segment(
              label: 'Recepten',
              selected: index == 2,
              onTap: () => onChanged(2),
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
    required this.label,
    required this.selected,
    required this.onTap,
    this.badgeCount = 0,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final showBadge = badgeCount > 0 && !selected;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          alignment: Alignment.center,
          children: [
            Text(
              label,
              textAlign: TextAlign.center,
              style: t.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w600,
                color: selected ? cs.onPrimary : cs.onSurfaceVariant,
                fontSize: 13,
              ),
            ),
            if (showBadge)
              Positioned(
                right: 2,
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
    );
  }
}
