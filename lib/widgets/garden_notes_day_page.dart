import 'package:flutter/material.dart';

import '../data/garden_notes_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_calendar.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_note.dart';
import 'garden_note_card.dart';
import 'garden_note_editor_sheet.dart';

/// Overzicht van alle notities (datum kies je bij aanmaken).
class GardenNotesDayPage extends StatefulWidget {
  const GardenNotesDayPage({
    super.key,
    required this.notesStore,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
  });

  final GardenNotesStore notesStore;
  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;

  @override
  State<GardenNotesDayPage> createState() => GardenNotesDayPageState();
}

class GardenNotesDayPageState extends State<GardenNotesDayPage> {
  Future<void> _addNote() async {
    final result = await showGardenNoteEditor(
      context: context,
      repository: widget.repository,
      gardenStore: widget.gardenStore,
    );
    if (result == null || !mounted) return;

    final note = result.note.copyWith(onCalendar: result.addToCalendar);
    await widget.notesStore.upsert(note);
    await syncGardenNotifications(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
      notesStore: widget.notesStore,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Notitie opgeslagen')),
    );
  }

  Future<void> _editNote(GardenNote note) async {
    if (note.source == GardenNoteSource.ai) return;
    final result = await showGardenNoteEditor(
      context: context,
      repository: widget.repository,
      gardenStore: widget.gardenStore,
      existing: note,
    );
    if (result == null || !mounted) return;

    final updated = result.note.copyWith(onCalendar: result.addToCalendar);
    await widget.notesStore.upsert(updated);
    await syncGardenNotifications(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
      notesStore: widget.notesStore,
    );
  }

  Future<void> _deleteNote(GardenNote note) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Notitie verwijderen?'),
        content: Text('“${note.title}” wordt gewist.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Verwijderen'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    await widget.notesStore.remove(note.id);
    await syncGardenNotifications(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
      notesStore: widget.notesStore,
    );
  }

  List<DateTime> _sortedDays(List<GardenNote> notes) {
    final days = <DateTime>{};
    for (final n in notes) {
      days.add(n.dateOnly);
    }
    final list = days.toList()..sort();
    return list;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return ListenableBuilder(
      listenable: widget.notesStore,
      builder: (context, _) {
        final notes = List<GardenNote>.from(widget.notesStore.all)
          ..sort((a, b) {
            final d = a.date.compareTo(b.date);
            if (d != 0) return d;
            return (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date);
          });

        if (notes.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Nog geen notities.\n'
                'Tik op + voor een tuintaak of een notitie over groenten.',
                textAlign: TextAlign.center,
                style: t.textTheme.bodyLarge?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          );
        }

        final days = _sortedDays(notes);
        final children = <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              'Al je notities',
              style: t.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ];

        for (final day in days) {
          final dayNotes = notes
              .where(
                (n) =>
                    n.date.year == day.year &&
                    n.date.month == day.month &&
                    n.date.day == day.day,
              )
              .toList();
          children.add(
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
              child: Text(
                '${kMonthNamesNl[day.month]} ${day.day}',
                style: t.textTheme.labelLarge?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
          for (final n in dayNotes) {
            children.add(
              GardenNoteCard(
                note: n,
                repository: widget.repository,
                onTap: n.source == GardenNoteSource.user
                    ? () => _editNote(n)
                    : null,
                onDelete: n.source == GardenNoteSource.user
                    ? () => _deleteNote(n)
                    : null,
              ),
            );
          }
        }

        return ListView(
          padding: const EdgeInsets.only(bottom: 80),
          children: children,
        );
      },
    );
  }

  void openAddNote() => _addNote();
}
