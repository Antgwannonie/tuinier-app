import '../models/garden_note.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/vegetable.dart';

String _coachNoteId(DateTime at, int index) =>
    'coach_${at.millisecondsSinceEpoch}_$index';

/// Bouwt tuin-notities (bron: gebruiker) uit AI-coachvoorstellen.
List<GardenNote> buildCoachNotesFromAnalysis({
  required PlantAiAnalysis analysis,
  required Vegetable vegetable,
  required DateTime scanDate,
  String? scanPhotoPath,
  bool notify = true,
}) {
  final insight = analysis.insight;
  if (insight == null || insight.coachTasks.isEmpty) return const [];

  final base = DateTime(scanDate.year, scanDate.month, scanDate.day);
  return [
    for (var i = 0; i < insight.coachTasks.length; i++)
      if (insight.coachTasks[i].title.trim().isNotEmpty)
        GardenNote(
          id: _coachNoteId(scanDate, i),
          date: base.add(
            Duration(days: insight.coachTasks[i].dueInDays.clamp(0, 90)),
          ),
          title:
              '${vegetable.nameNl}: ${insight.coachTasks[i].title.trim()}',
          body: [
            if (insight.coachTasks[i].body != null &&
                insight.coachTasks[i].body!.trim().isNotEmpty)
              insight.coachTasks[i].body!,
            if (insight.summary.trim().isNotEmpty) '',
            if (insight.summary.trim().isNotEmpty)
              'AI-samenvatting: ${insight.summary.trim()}',
          ].where((s) => s.isNotEmpty).join('\n'),
          source: GardenNoteSource.user,
          vegetableIds: [vegetable.id],
          scanPhotoPath: scanPhotoPath,
          onCalendar: true,
          notify: notify,
          createdAt: DateTime.now(),
        ),
  ];
}

/// Extra taken als er geen coachTasks zijn maar wel aanbevolen acties.
List<GardenNote> fallbackCoachNotesFromActions({
  required PlantAiInsightReport insight,
  required Vegetable vegetable,
  required DateTime scanDate,
  int maxNotes = 3,
}) {
  if (insight.coachTasks.isNotEmpty) return const [];
  final base = DateTime(scanDate.year, scanDate.month, scanDate.day);
  final actions = insight.recommendedActions
      .where((a) => a.title.trim().isNotEmpty)
      .take(maxNotes)
      .toList();
  if (actions.isEmpty) return const [];

  return [
    for (var i = 0; i < actions.length; i++)
      GardenNote(
        id: _coachNoteId(scanDate, i),
        date: base.add(Duration(days: i + 1)),
        title: '${vegetable.nameNl}: ${actions[i].title.trim()}',
        body: actions[i].description?.trim() ?? insight.summary,
        source: GardenNoteSource.user,
        vegetableIds: [vegetable.id],
        onCalendar: true,
        notify: i == 0,
        createdAt: DateTime.now(),
      ),
  ];
}
