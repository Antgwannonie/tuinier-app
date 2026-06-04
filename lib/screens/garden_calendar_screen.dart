import 'package:flutter/material.dart';

import '../data/calendar_display_prefs_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_calendar.dart';
import '../models/garden_personal_event.dart';
import '../data/vegetable_image_info.dart';
import '../data/vegetable_repository.dart';
import '../data/garden_notes_store.dart';
import '../models/garden_note.dart';
import '../widgets/garden_note_card.dart';
import '../widgets/calendar_filter_sheet.dart';
import '../widgets/month_calendar_grid.dart';
import 'vegetable_detail_screen.dart';

/// Volledige kalender: swipe tussen maanden, groente-emoji’s per dag.
class GardenCalendarScreen extends StatefulWidget {
  const GardenCalendarScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.calendarPrefs,
    this.initialMonth,
    this.initialYear,
    this.embedded = false,
    this.showAppBar = true,
    this.notesStore,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final CalendarDisplayPrefsStore calendarPrefs;
  final GardenNotesStore? notesStore;
  final int? initialMonth;
  final int? initialYear;

  /// In ondernavigatie: geen terug-knop / pop met resultaat.
  final bool embedded;

  /// Verbergen wanneer kalender in Notities-hub zit.
  final bool showAppBar;

  static const int _baseYear = 2024;
  static const int _monthSpan = 36;

  @override
  State<GardenCalendarScreen> createState() => _GardenCalendarScreenState();
}

class _GardenCalendarScreenState extends State<GardenCalendarScreen> {
  late final PageController _pageController;
  late int _month;
  late int _year;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _month = widget.initialMonth ?? now.month;
    _year = widget.initialYear ?? now.year;
    _pageController = PageController(
      initialPage: _pageIndexFor(_year, _month),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  int _pageIndexFor(int year, int month) {
    return (year - GardenCalendarScreen._baseYear) * 12 + month - 1;
  }

  void _applyPageIndex(int index) {
    final clamped = index.clamp(0, GardenCalendarScreen._monthSpan - 1);
    final month = (clamped % 12) + 1;
    final year = GardenCalendarScreen._baseYear + clamped ~/ 12;
    setState(() {
      _month = month;
      _year = year;
    });
  }

  void _openCalendarFilter() {
    showCalendarFilterSheet(
      context: context,
      prefs: widget.calendarPrefs,
      repository: widget.repository,
      gardenStore: widget.gardenStore,
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthName = kMonthNamesNl[_month];

    return ListenableBuilder(
      listenable: widget.calendarPrefs,
      builder: (context, _) {
        final visibleIds = widget.calendarPrefs.visibleVegetableIds(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
        );
        final calendarNote = widget.calendarPrefs.subtitle(
          gardenStore: widget.gardenStore,
          visibleCount: visibleIds.length,
          totalCount: widget.repository.all.length,
        );

        return _buildScaffold(
          context,
          monthName: monthName,
          calendarNote: calendarNote,
          visibleIds: visibleIds,
        );
      },
    );
  }

  Widget _buildScaffold(
    BuildContext context, {
    required String monthName,
    required String calendarNote,
    required Set<String> visibleIds,
  }) {
    final scaffold = Scaffold(
      appBar: widget.showAppBar
          ? AppBar(
              title: Text('Kalender · $monthName $_year'),
              actions: [
                IconButton(
                  onPressed: _openCalendarFilter,
                  tooltip: 'Kalender filter',
                  icon: const Icon(Icons.tune),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(36),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      calendarNote,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ),
                ),
              ),
            )
          : null,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!widget.showAppBar)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Kalender · $monthName $_year',
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          calendarNote,
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _openCalendarFilter,
                    tooltip: 'Kalender filter',
                    icon: const Icon(Icons.tune),
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: kWeekdayLabelsNl
                  .map(
                    (d) => Expanded(
                      child: Center(
                        child: Text(
                          d,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: _applyPageIndex,
              itemCount: GardenCalendarScreen._monthSpan,
              itemBuilder: (context, pageIndex) {
                final month = (pageIndex % 12) + 1;
                final year = GardenCalendarScreen._baseYear + pageIndex ~/ 12;
                return Padding(
                  padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                  child: MonthCalendarGrid(
                    month: month,
                    year: year,
                    gardenVegetableIds: visibleIds,
                    profileStore: widget.profileStore,
                    gardenStore: widget.gardenStore,
                    repository: widget.repository,
                    scanPrefs: widget.scanPrefs,
                    notesStore: widget.notesStore,
                    onDayTap: (day, activities, personal, dayNotes) =>
                        _showDaySheet(
                      context,
                      month,
                      year,
                      day,
                      activities,
                      personal,
                      dayNotes,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(
              'Swipe links/rechts · tik op een dag met notities of emoji’s',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) return scaffold;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          Navigator.pop(
            context,
            GardenCalendarResult(month: _month, year: _year),
          );
        }
      },
      child: scaffold,
    );
  }

  void _showDaySheet(
    BuildContext context,
    int month,
    int year,
    int day,
    List<VegetableMonthActivity> activities,
    List<GardenPersonalEvent> personalEvents,
    List<GardenNote> dayNotes,
  ) {
    final monthName = kMonthNamesNl[month];
    final calendarNotes =
        dayNotes.where((n) => n.onCalendar).toList();
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        builder: (_, scroll) => SafeArea(
          child: ListView(
            controller: scroll,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Text(
                '$day $monthName $year',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 12),
              if (calendarNotes.isNotEmpty) ...[
                Text(
                  'Notities',
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ...calendarNotes.map(
                  (n) => GardenNoteCard(
                    note: n,
                    repository: widget.repository,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              if (personalEvents.isNotEmpty) ...[
                Text(
                  'Jouw planning (AI & moestuin)',
                  style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 8),
                ...personalEvents.map((e) {
                  final veg = widget.repository.byId(e.vegetableId);
                  return ListTile(
                    leading: Text(e.type.emoji,
                        style: const TextStyle(fontSize: 28)),
                    title: Text(e.title),
                    subtitle: Text(e.subtitle ?? e.type.label),
                  );
                }),
                const SizedBox(height: 12),
              ],
              Text(
                'Algemene kalender',
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              ...activities.map((a) {
                final veg = widget.repository.byId(a.vegetableId);
                if (veg == null) return const SizedBox.shrink();
                final info = vegetableImageFor(a.vegetableId);
                return ListTile(
                  leading: Text(
                    info.emoji,
                    style: const TextStyle(fontSize: 32),
                  ),
                  title: Text(veg.nameNl),
                  subtitle: Text(a.type.label),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.pop(ctx);
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => VegetableDetailScreen(
                          vegetable: veg,
                          focusMonth: month,
                          gardenStore: widget.gardenStore,
                          repository: widget.repository,
                          profileStore: widget.profileStore,
                          scanPrefs: widget.scanPrefs,
                        ),
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }

}

/// Resultaat bij terugkeren van de kalender.
class GardenCalendarResult {
  const GardenCalendarResult({required this.month, required this.year});

  final int month;
  final int year;
}
