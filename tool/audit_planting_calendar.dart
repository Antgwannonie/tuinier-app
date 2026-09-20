import 'package:tuinier_app/data/planting_calendar.dart';
import 'package:tuinier_app/data/planting_calendar_fallback.dart';
import 'package:tuinier_app/data/planting_calendar_supplement.dart';
import 'package:tuinier_app/data/planting_season_status.dart';
import 'package:tuinier_app/data/vegetable_groups.dart';
import 'package:tuinier_app/data/vegetables_data.dart';
import 'package:tuinier_app/data/wizard_season_plan.dart';
import 'package:tuinier_app/models/add_plant_wizard_models.dart';

void main() {
  final explicitIds = <String>{
    for (final a in [...kPlantingCalendar, ...kPlantingCalendarSupplement])
      a.vegetableId,
  };

  final noSowWhenVegetablePassed = <String>[];
  final noSowWithoutVegetable = <String>[];
  final onlyGenericFallback = <String>[];
  final weakWizardLabel = <String>[];
  final groupInherited = <String>[];
  final explicitList = <String>[];

  for (final veg in kVegetablesSeed) {
    final id = veg.id;
    final withVeg = plantingActivitiesForVegetable(id, vegetable: veg)
        .where((a) =>
            a.type == GardenTaskType.preSow ||
            a.type == GardenTaskType.sowOutdoors)
        .toList();
    final withoutVeg = plantingActivitiesForVegetable(id)
        .where((a) =>
            a.type == GardenTaskType.preSow ||
            a.type == GardenTaskType.sowOutdoors)
        .toList();

    if (withVeg.isEmpty) noSowWhenVegetablePassed.add(id);
    if (withoutVeg.isEmpty) noSowWithoutVegetable.add(id);

    if (explicitIds.contains(id)) {
      explicitList.add(id);
    } else {
      final group = vegetableGroupContaining(id);
      final hasGroupTemplate = group != null &&
          group.vegetableIds.any(
            (member) => member != id && explicitIds.contains(member),
          );
      if (hasGroupTemplate) {
        groupInherited.add(id);
      } else {
        onlyGenericFallback.add(id);
      }
    }

    final plan = buildWizardSeasonPlan(
      vegetable: veg,
      approach: PlantGrowApproach.seed,
    );
    final sowStatus = plantingSeasonStatusForTaskTypes(
      id,
      types: const {
        GardenTaskType.preSow,
        GardenTaskType.sowOutdoors,
      },
      vegetable: veg,
    );
    if (sowStatus.phase == PlantingSeasonPhase.noCalendar ||
        plan.sowWindowLabel == 'maart tot september' ||
        plan.sowWindowLabel == 'Zie kalender in de app.' ||
        plan.sowWindowLabel.contains('zie teeltinfo')) {
      weakWizardLabel.add(id);
    }
  }

  print('=== Planting calendar audit (${kVegetablesSeed.length} plants) ===\n');
  print('Explicit calendar: ${explicitList.length}');
  print('Group inherited: ${groupInherited.length}');
  print('Category fallback only: ${onlyGenericFallback.length}');
  print('No sow data (with vegetable): ${noSowWhenVegetablePassed.length}');
  print('No sow data (id only, no vegetable): ${noSowWithoutVegetable.length}');
  print('Weak wizard sow label: ${weakWizardLabel.length}\n');

  void printList(String title, List<String> ids) {
    if (ids.isEmpty) {
      print('$title: none');
      return;
    }
    print('$title (${ids.length}):');
    for (final id in ids..sort()) {
      final name =
          kVegetablesSeed.firstWhere((v) => v.id == id, orElse: () => throw StateError(id)).nameNl;
      print('  - $id ($name)');
    }
    print('');
  }

  printList('CRITICAL: no sow calendar even with Vegetable object', noSowWhenVegetablePassed);
  printList('RISK: no sow calendar if vegetable object missing', noSowWithoutVegetable);
  printList('Weak/vague wizard sow window', weakWizardLabel);

  final slaGroupMissing = kVegetableGroups
      .firstWhere((g) => g.id == 'sla_soorten')
      .vegetableIds
      .where((id) => !explicitIds.contains(id) && !groupInherited.contains(id))
      .toList();
  printList('Sla group without explicit or inherited calendar', slaGroupMissing);
}
