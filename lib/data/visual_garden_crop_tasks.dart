import '../models/garden_planner_task.dart';
import '../models/visual_garden_plan.dart';
import 'garden_planner_task_store.dart';
import 'vegetable_repository.dart';

/// Maakt planner-taken voor planten in een teeltplan.
Future<int> generateTasksForCropPlan({
  required GardenPlannerTaskStore taskStore,
  required VegetableRepository repository,
  required VisualGardenBed bed,
  required VisualCropPlan plan,
}) async {
  if (!taskStore.isLoaded) await taskStore.load();

  var created = 0;
  final plantIds = plan.plantIds.toList();
  final start = plan.startDateOnly;
  final end = plan.endDateOnly;
  final mid = start.add(Duration(days: end.difference(start).inDays ~/ 2));
  final harvest = end.subtract(const Duration(days: 3));

  for (final plantId in plantIds) {
    final v = repository.byId(plantId);
    final name = v?.nameNl ?? 'Plant';

    final tasks = <({String title, String body, DateTime due})>[
      (
        title: '$name zaaien',
        body: 'Teeltplan “${plan.name}” · bak ${bed.name}',
        due: start,
      ),
      (
        title: '$name uitplanten / verzorgen',
        body: 'Teeltplan “${plan.name}” · bak ${bed.name}',
        due: mid.isBefore(start) ? start.add(const Duration(days: 14)) : mid,
      ),
      (
        title: '$name oogsten',
        body: 'Teeltplan “${plan.name}” · bak ${bed.name}',
        due: harvest.isBefore(start) ? end : harvest,
      ),
    ];

    for (final t in tasks) {
      // Voorkom exacte dubbele titel+datum+plant.
      final exists = taskStore.all.any(
        (e) =>
            e.vegetableId == plantId &&
            e.title == t.title &&
            e.dueDateOnly ==
                DateTime(t.due.year, t.due.month, t.due.day),
      );
      if (exists) continue;

      await taskStore.upsert(
        GardenPlannerTask(
          id: 'crop_task_${plan.id}_${plantId}_${t.title.hashCode}_${t.due.millisecondsSinceEpoch}',
          title: t.title,
          body: t.body,
          dueDate: t.due,
          vegetableId: plantId,
          priority: GardenPlannerTaskPriority.medium,
          createdAt: DateTime.now(),
        ),
      );
      created++;
    }
  }
  return created;
}
