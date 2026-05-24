import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_calendar.dart';
import '../models/garden_personal_event.dart';
import '../data/vegetable_image_info.dart';
import '../data/vegetable_repository.dart';
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
    this.initialMonth,
    this.initialYear,
    this.embedded = false,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final int? initialMonth;
  final int? initialYear;

  /// In ondernavigatie: geen terug-knop / pop met resultaat.
  final bool embedded;

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

  Set<String>? get _gardenFilter {
    if (widget.gardenStore.isEmpty) return null;
    return widget.gardenStore.ids.toSet();
  }

  @override
  Widget build(BuildContext context) {
    final monthName = kMonthNamesNl[_month];
    final gardenNote = widget.gardenStore.isEmpty
        ? 'Alle groenten uit de kalender'
        : 'Alleen jouw ${widget.gardenStore.count} groente(n) in Mijn moestuin';

    final scaffold = Scaffold(
      appBar: AppBar(
        title: Text('Kalender · $monthName $_year'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(36),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                gardenNote,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
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
                    gardenVegetableIds: _gardenFilter,
                    profileStore: widget.profileStore,
                    gardenStore: widget.gardenStore,
                    repository: widget.repository,
                    scanPrefs: widget.scanPrefs,
                    onDayTap: (day, activities, personal) => _showDaySheet(
                      context,
                      month,
                      year,
                      day,
                      activities,
                      personal,
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 4),
            child: Text(
              'Swipe links/rechts · tik op een dag met emoji’s',
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
  ) {
    final monthName = kMonthNamesNl[month];
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
