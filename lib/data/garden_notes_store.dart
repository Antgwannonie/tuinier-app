import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/garden_note.dart';
/// Opgeslagen tuin-notities (alleen door jou geschreven).
class GardenNotesStore extends ChangeNotifier {
  static const _storageKey = 'garden_notes_v1';

  final List<GardenNote> _notes = [];
  bool _loaded = false;

  bool get isLoaded => _loaded;
  List<GardenNote> get all => List.unmodifiable(_notes);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_storageKey);
    _notes.clear();
    var removedAi = false;
    if (raw != null && raw.isNotEmpty) {
      final list = jsonDecode(raw) as List<dynamic>;
      for (final item in list) {
        final note = GardenNote.fromJson(item as Map<String, dynamic>);
        if (note.source == GardenNoteSource.ai) {
          removedAi = true;
          continue;
        }
        _notes.add(note);
      }
    }
    _notes.sort((a, b) => a.date.compareTo(b.date));
    _loaded = true;
    if (removedAi) await _persist();
    notifyListeners();
  }

  List<GardenNote> forDay(DateTime day) {
    final d = DateTime(day.year, day.month, day.day);
    return _notes
        .where(
          (n) =>
              n.source == GardenNoteSource.user &&
              n.date.year == d.year &&
              n.date.month == d.month &&
              n.date.day == d.day,
        )
        .toList()
      ..sort(
        (a, b) => (b.createdAt ?? b.date).compareTo(a.createdAt ?? a.date),
      );
  }

  List<GardenNote> calendarNotes() => _notes
      .where((n) => n.onCalendar && n.source == GardenNoteSource.user)
      .toList();

  bool hasNotesOnDay(DateTime day) => forDay(day).isNotEmpty;

  bool hasCalendarMarkerOnDay(DateTime day) =>
      forDay(day).any((n) => n.onCalendar);

  Future<void> upsert(GardenNote note) async {
    final i = _notes.indexWhere((n) => n.id == note.id);
    if (i >= 0) {
      _notes[i] = note;
    } else {
      _notes.add(note);
    }
    _notes.sort((a, b) => a.date.compareTo(b.date));
    await _persist();
    notifyListeners();
  }

  Future<void> remove(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _persist();
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = jsonEncode(_notes.map((n) => n.toJson()).toList());
    await prefs.setString(_storageKey, encoded);
  }
}
