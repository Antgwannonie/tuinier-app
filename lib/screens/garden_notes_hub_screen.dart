import 'package:flutter/material.dart';

import '../data/garden_notes_store.dart';
import '../data/garden_profile_store.dart';
import '../data/calendar_display_prefs_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../widgets/garden_notes_day_page.dart';
import 'garden_calendar_screen.dart';

/// Notities-tab met swipe naar kalender.
class GardenNotesHubScreen extends StatefulWidget {
  const GardenNotesHubScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.calendarPrefs,
    required this.notesStore,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final CalendarDisplayPrefsStore calendarPrefs;
  final GardenNotesStore notesStore;

  @override
  State<GardenNotesHubScreen> createState() => _GardenNotesHubScreenState();
}

class _GardenNotesHubScreenState extends State<GardenNotesHubScreen> {
  final PageController _pageController = PageController();
  final GlobalKey<GardenNotesDayPageState> _dayPageKey = GlobalKey();
  int _pageIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final title = _pageIndex == 0 ? 'Notities' : 'Kalender';

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
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
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: cs.surfaceContainerHighest.withValues(alpha: 0.6),
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
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: selected ? cs.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: t.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: selected ? cs.onPrimary : cs.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
