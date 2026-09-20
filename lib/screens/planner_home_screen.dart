import 'package:flutter/material.dart';

import '../data/calendar_display_prefs_store.dart';
import '../data/garden_history_store.dart';
import '../data/garden_notes_store.dart';
import '../data/garden_planner_task_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_image_info.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_note.dart';
import '../models/garden_planner_task.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/garden_note_editor_sheet.dart';
import '../widgets/planner_task_editor_sheet.dart';
import 'garden_calendar_screen.dart';
import 'moestuin_visual_planner_screen.dart';

/// Planner-tab: mockup-layout met moestuinplan, taken en notes.
class PlannerHomeScreen extends StatefulWidget {
  const PlannerHomeScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.notesStore,
    required this.taskStore,
    required this.historyStore,
    required this.scanPrefs,
    required this.calendarPrefs,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenNotesStore notesStore;
  final GardenPlannerTaskStore taskStore;
  final GardenHistoryStore historyStore;
  final GardenScanPrefsStore scanPrefs;
  final CalendarDisplayPrefsStore calendarPrefs;

  @override
  State<PlannerHomeScreen> createState() => _PlannerHomeScreenState();
}

class _PlannerHomeScreenState extends State<PlannerHomeScreen> {
  late DateTime _selectedDay;
  final _scrollController = ScrollController();
  final _plannedKey = GlobalKey();
  final _notesKey = GlobalKey();

  static const _monthNames = [
    '',
    'januari',
    'februari',
    'maart',
    'april',
    'mei',
    'juni',
    'juli',
    'augustus',
    'september',
    'oktober',
    'november',
    'december',
  ];

  static const _weekdayShort = ['MA', 'DI', 'WO', 'DO', 'VR', 'ZA', 'ZO'];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
    widget.notesStore.addListener(_refresh);
    widget.taskStore.addListener(_refresh);
    widget.gardenStore.addListener(_refresh);
    widget.profileStore.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.notesStore.removeListener(_refresh);
    widget.taskStore.removeListener(_refresh);
    widget.gardenStore.removeListener(_refresh);
    widget.profileStore.removeListener(_refresh);
    _scrollController.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
      alignment: 0.08,
    );
  }

  List<GardenNote> get _recentNotes {
    final notes = widget.notesStore.all
        .where((n) => n.source == GardenNoteSource.user)
        .toList()
      ..sort((a, b) {
        final ac = a.createdAt ?? a.date;
        final bc = b.createdAt ?? b.date;
        return bc.compareTo(ac);
      });
    return notes;
  }

  Future<void> _openNoteEditor({GardenNote? existing}) async {
    final result = await showGardenNoteEditor(
      context: context,
      repository: widget.repository,
      gardenStore: widget.gardenStore,
      existing: existing,
      initialDate: _selectedDay,
    );
    if (result == null) return;
    await widget.notesStore.upsert(result.note);
  }

  Future<void> _openNoteViewer(GardenNote note) async {
    final action = await showGardenNoteViewer(
      context: context,
      note: note,
      repository: widget.repository,
    );
    if (!mounted || action == null) return;
    switch (action) {
      case GardenNoteViewerAction.edit:
        await _openNoteEditor(existing: note);
      case GardenNoteViewerAction.delete:
        await widget.notesStore.remove(note.id);
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Note verwijderd')),
        );
    }
  }

  Future<void> _openTaskEditor({GardenPlannerTask? existing}) async {
    final task = await showPlannerTaskEditor(
      context: context,
      repository: widget.repository,
      gardenStore: widget.gardenStore,
      existing: existing,
      initialDate: _selectedDay,
    );
    if (task == null) return;
    await widget.taskStore.upsert(task);
  }

  Future<void> _openMoestuinPlan() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MoestuinVisualPlannerScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          taskStore: widget.taskStore,
        ),
      ),
    );
  }

  Future<void> _openFullAgenda() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => GardenCalendarScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          calendarPrefs: widget.calendarPrefs,
          notesStore: widget.notesStore,
          gardenOnly: true,
          initialMonth: _selectedDay.month,
          initialYear: _selectedDay.year,
        ),
      ),
    );
  }

  bool get _selectedIsToday {
    final now = DateTime.now();
    return _selectedDay.year == now.year &&
        _selectedDay.month == now.month &&
        _selectedDay.day == now.day;
  }

  String get _dayTasksTitle {
    if (_selectedIsToday) return 'Taken voor vandaag';
    return 'Taken voor ${_selectedDay.day} ${_monthNames[_selectedDay.month]}';
  }

  @override
  Widget build(BuildContext context) {
    final dayTasks = widget.taskStore.forDay(_selectedDay);
    final notes = _recentNotes;

    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Planner'),
        backgroundColor: TuinierColors.background,
        foregroundColor: TuinierColors.textPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Agenda',
            onPressed: _openFullAgenda,
            icon: const Icon(Icons.calendar_month_outlined),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: TuinierColors.border, height: 1),
        ),
      ),
      body: ListView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _DateStrip(
            selected: _selectedDay,
            weekdayLabels: _weekdayShort,
            onSelected: (d) => setState(() => _selectedDay = d),
          ),
          const SizedBox(height: 18),
          KeyedSubtree(
            key: _plannedKey,
            child: _SectionHeader(
              title: _dayTasksTitle,
              onViewAll: dayTasks.isEmpty
                  ? null
                  : () => _openTaskListSheet(
                        title: _dayTasksTitle,
                        tasks: dayTasks,
                      ),
            ),
          ),
          const SizedBox(height: 10),
          if (dayTasks.isEmpty)
            _EmptyHint(
              text: _selectedIsToday
                  ? 'Geen taken voor vandaag. Plan er een via “Tuin taken plannen”.'
                  : 'Geen taken op ${_selectedDay.day} ${_monthNames[_selectedDay.month]}.',
            )
          else
            ...dayTasks.map(
              (task) => _PlannedTaskRow(
                task: task,
                repo: widget.repository,
                onTap: () => _openTaskEditor(existing: task),
                onComplete: () => widget.taskStore.setCompleted(task.id, true),
              ),
            ),
          const SizedBox(height: 22),
          KeyedSubtree(
            key: _notesKey,
            child: _SectionHeader(
              title: 'Notes',
              onViewAll: notes.isEmpty
                  ? null
                  : () => _openNotesListSheet(notes),
            ),
          ),
          const SizedBox(height: 10),
          if (notes.isEmpty)
            const _EmptyHint(
              text: 'Nog geen notes. Tik op “Notes maken” om te starten.',
            )
          else
            SizedBox(
              height: 132,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: notes.length.clamp(0, 20),
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (context, i) {
                  final note = notes[i];
                  return _NoteCard(
                    note: note,
                    onTap: () => _openNoteViewer(note),
                  );
                },
              ),
            ),
          const SizedBox(height: 22),
          _ActionCard(
            imageAsset: 'assets/images/planner/planner_card_moestuin.png',
            title: 'Moestuinplanner',
            body:
                'Geef hoeken en maten in, en plaats je planten op de juiste afstand.',
            buttonLabel: '+ Maak jouw moestuin',
            onTap: _openMoestuinPlan,
            onButton: _openMoestuinPlan,
          ),
          const SizedBox(height: 10),
          _ActionCard(
            imageAsset: 'assets/images/planner/planner_card_taken.png',
            title: 'Tuin taken plannen',
            body:
                'Plan en organiseer al je tuin taken voor deze week, '
                'maand of het hele seizoen.',
            buttonLabel: '+ Tuin taken plannen',
            onTap: () => _scrollTo(_plannedKey),
            onButton: () => _openTaskEditor(),
          ),
          const SizedBox(height: 10),
          _ActionCard(
            imageAsset: 'assets/images/planner/planner_card_notes.png',
            title: 'Notes maken',
            body:
                'Maak persoonlijke notities, ideeën en herinneringen '
                'voor je tuin.',
            buttonLabel: '+ Notes maken',
            onTap: () => _scrollTo(_notesKey),
            onButton: () => _openNoteEditor(),
          ),
        ],
      ),
    );
  }

  void _openTaskListSheet({
    required String title,
    required List<GardenPlannerTask> tasks,
  }) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            ...tasks.map(
              (task) => _PlannedTaskRow(
                task: task,
                repo: widget.repository,
                onTap: () {
                  Navigator.pop(ctx);
                  _openTaskEditor(existing: task);
                },
                onComplete: () => widget.taskStore.setCompleted(task.id, true),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openNotesListSheet(List<GardenNote> notes) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.65,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (_, scroll) => ListView(
          controller: scroll,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Text(
              'Alle notes',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 12),
            ...notes.map(
              (note) => ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  note.title.isEmpty ? 'Zonder titel' : note.title,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                subtitle: Text(
                  note.body,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: Text(
                  '${note.date.day} ${_monthNames[note.date.month]}',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
                onTap: () {
                  Navigator.pop(ctx);
                  _openNoteViewer(note);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateStrip extends StatelessWidget {
  const _DateStrip({
    required this.selected,
    required this.weekdayLabels,
    required this.onSelected,
  });

  final DateTime selected;
  final List<String> weekdayLabels;
  final ValueChanged<DateTime> onSelected;

  @override
  Widget build(BuildContext context) {
    final start = selected.subtract(Duration(days: selected.weekday - 1));
    return SizedBox(
      height: 64,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: 7,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final day = DateTime(start.year, start.month, start.day + i);
          final isSelected = day.year == selected.year &&
              day.month == selected.month &&
              day.day == selected.day;
          return InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: () => onSelected(day),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              decoration: BoxDecoration(
                color: isSelected ? TuinierColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    weekdayLabels[i],
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isSelected
                          ? Colors.white
                          : TuinierColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${day.day}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isSelected
                          ? Colors.white
                          : TuinierColors.textPrimary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  const _ActionCard({
    required this.imageAsset,
    required this.title,
    required this.body,
    required this.onTap,
    this.buttonLabel,
    this.onButton,
  });

  final String imageAsset;
  final String title;
  final String body;
  final VoidCallback onTap;
  final String? buttonLabel;
  final VoidCallback? onButton;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final onVariant = Theme.of(context).colorScheme.onSurfaceVariant;
    final label = buttonLabel?.replaceFirst(RegExp(r'^\+\s*'), '').trim();

    return Material(
      color: TuinierColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: TuinierColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.asset(
                      imageAsset,
                      width: 108,
                      height: 108,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.high,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          body,
                          style: textTheme.bodySmall?.copyWith(
                            height: 1.35,
                            color: onVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 4, top: 2),
                    child: Icon(
                      Icons.chevron_right_rounded,
                      color: TuinierColors.textSecondary,
                    ),
                  ),
                ],
              ),
              if (label != null && label.isNotEmpty) ...[
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onButton ?? onTap,
                    style: FilledButton.styleFrom(
                      backgroundColor: TuinierColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(42),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Icon(Icons.add, size: 18, color: Colors.white),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            label,
                            maxLines: 1,
                            softWrap: false,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              height: 1.1,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title, this.onViewAll});

  final String title;
  final VoidCallback? onViewAll;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ),
        if (onViewAll != null)
          TextButton(
            onPressed: onViewAll,
            child: const Text('Bekijk alles'),
          ),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: TuinierColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: TuinierColors.border),
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
      ),
    );
  }
}

class _PlannedTaskRow extends StatelessWidget {
  const _PlannedTaskRow({
    required this.task,
    required this.repo,
    required this.onTap,
    required this.onComplete,
  });

  final GardenPlannerTask task;
  final VegetableRepository repo;
  final VoidCallback onTap;
  final VoidCallback onComplete;

  @override
  Widget build(BuildContext context) {
    final veg =
        task.vegetableId != null ? repo.byId(task.vegetableId!) : null;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: TuinierColors.primary.withValues(alpha: 0.12),
        child: Text(
          veg != null ? vegetableImageFor(veg.id).emoji : '🌿',
        ),
      ),
      title: Text(task.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(
        '${task.dueDate.day}-${task.dueDate.month}-${task.dueDate.year}'
        '${veg != null ? ' · ${veg.nameNl}' : ' · Algemene tuin'}',
      ),
      trailing: IconButton(
        tooltip: 'Afgerond',
        onPressed: onComplete,
        icon: const Icon(Icons.check_circle_outline,
            color: TuinierColors.primary),
      ),
    );
  }
}

class _NoteCard extends StatelessWidget {
  const _NoteCard({required this.note, required this.onTap});

  final GardenNote note;
  final VoidCallback onTap;

  static const _colors = [
    Color(0xFFFFF59D),
    Color(0xFFC8E6C9),
    Color(0xFFBBDEFB),
    Color(0xFFF8BBD0),
  ];

  @override
  Widget build(BuildContext context) {
    final color = _colors[note.id.hashCode.abs() % _colors.length];
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        width: 148,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              note.title.isEmpty ? 'Zonder titel' : note.title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
            ),
            const SizedBox(height: 6),
            Expanded(
              child: Text(
                note.body,
                maxLines: 4,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, height: 1.3),
              ),
            ),
            Text(
              '${note.date.day} ${_monthShort(note.date.month)}',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF5D4037),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _monthShort(int m) {
    const names = [
      '',
      'jan',
      'feb',
      'mrt',
      'apr',
      'mei',
      'jun',
      'jul',
      'aug',
      'sep',
      'okt',
      'nov',
      'dec',
    ];
    return names[m];
  }
}
