import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/moestuin_pinned_action.dart';
import '../data/plant_scheduled_actions.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'mark_planted_sheet.dart';

/// Na sheet-sluiting: tab-wissel naar scan in het volgende frame.
void scheduleNavigateToPlantScan(VoidCallback? navigate) {
  if (navigate == null) return;
  WidgetsBinding.instance.addPostFrameCallback((_) => navigate());
}

bool isPlantingScheduledAction(PlantScheduledAction action) {
  if (action.kind == PlantScheduledActionKind.planPlant) return true;
  if (action.kind != PlantScheduledActionKind.calendar) return false;
  final topic = action.topic.toLowerCase();
  return topic.contains('zaai') ||
      topic.contains('plant') ||
      topic.contains('voorzaai');
}

/// Na zaaien/planten: geen automatische scan — gebruiker tikt «Eerste scan».
bool shouldNavigateToScanAfterHomeAction({
  required PlantScheduledAction scheduled,
  required GardenPlantProfile? profile,
}) {
  return false;
}

/// Actie die nu op een plantkaart hoort.
enum GardenHomeActionKind {
  planPlant,
  firstPhoto,
  weeklyScan,
  harvest,
  calendarHarvest,
  aiWarning,
  seasonWarning,
  aiCoach,
  calendarCountdown,
}

class GardenHomeAction {
  const GardenHomeAction({
    required this.vegetable,
    required this.kind,
    required this.subtitle,
    this.scheduled,
  });

  final Vegetable vegetable;
  final GardenHomeActionKind kind;
  final String subtitle;
  final PlantScheduledAction? scheduled;

  bool get isPlantInfo =>
      scheduled != null && isPlantInfoScheduledActionKind(scheduled!.kind);

  bool get isPlantTask => !isPlantInfo;
}

enum GardenHomeActionListFilter {
  all,
  tasks,
  info,
}

List<GardenHomeAction> filterGardenHomeActions(
  List<GardenHomeAction> actions,
  GardenHomeActionListFilter filter,
) {
  return switch (filter) {
    GardenHomeActionListFilter.all => actions,
    GardenHomeActionListFilter.tasks =>
      actions.where((a) => a.isPlantTask).toList(),
    GardenHomeActionListFilter.info =>
      actions.where((a) => a.isPlantInfo).toList(),
  };
}

/// Meest urgente actie per plant, gesorteerd op urgentie (home / dashboard).
List<GardenHomeAction> collectGardenHomeActions({
  required VegetableRepository repository,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required GardenScanPrefsStore scanPrefs,
  int? month,
}) {
  return collectUrgentGardenHomeActions(
    vegetableIds: gardenStore.ids,
    vegetableById: repository.byId,
    profileFor: profileStore.profileFor,
    scanPrefs: scanPrefs,
    month: month,
  );
}

/// Eén meest urgente actie per plant, hoogste urgentie eerst.
List<GardenHomeAction> collectUrgentGardenHomeActions({
  required Iterable<String> vegetableIds,
  required Vegetable? Function(String id) vegetableById,
  required GardenPlantProfile? Function(String id) profileFor,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  final m = month ?? DateTime.now().month;
  final out = <GardenHomeAction>[];

  for (final id in vegetableIds) {
    final veg = vegetableById(id);
    if (veg == null) continue;
    final profile = profileFor(id);
    final pinned = pinnedMoestuinCardAction(
      vegetable: veg,
      profile: profile,
      scanPrefs: scanPrefs,
      month: m,
      reference: reference,
    );
    if (pinned == null) continue;
    out.add(
      gardenHomeActionFromScheduled(vegetable: veg, action: pinned),
    );
  }

  out.sort((a, b) {
    final sa = a.scheduled;
    final sb = b.scheduled;
    if (sa == null && sb == null) return 0;
    if (sa == null) return 1;
    if (sb == null) return -1;
    return comparePlantScheduledActions(sa, sb);
  });
  return out;
}

/// Alle geplande acties over alle planten — gesorteerd op urgentie.
List<GardenHomeAction> collectAllGardenHomeActions({
  required Iterable<String> vegetableIds,
  required Vegetable? Function(String id) vegetableById,
  required GardenPlantProfile? Function(String id) profileFor,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  final m = month ?? DateTime.now().month;
  final out = <GardenHomeAction>[];

  for (final id in vegetableIds) {
    final veg = vegetableById(id);
    if (veg == null) continue;
    final profile = profileFor(id);
    final scheduled = collectPlantScheduledActions(
      vegetable: veg,
      profile: profile,
      scanPrefs: scanPrefs,
      month: m,
      reference: reference,
    );
    for (final action in scheduled) {
      out.add(gardenHomeActionFromScheduled(vegetable: veg, action: action));
    }
  }

  out.sort((a, b) {
    final sa = a.scheduled;
    final sb = b.scheduled;
    if (sa == null && sb == null) return 0;
    if (sa == null) return 1;
    if (sb == null) return -1;
    return comparePlantScheduledActions(sa, sb);
  });
  return out;
}

/// Geplande home-acties voor één plant (zelfde bron als het home-raster).
List<GardenHomeAction> gardenHomeActionsForPlant({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
}) {
  final scheduled = collectPlantScheduledActions(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    month: month,
  );
  return [
    for (final action in scheduled)
      gardenHomeActionFromScheduled(vegetable: vegetable, action: action),
  ];
}

GardenHomeAction gardenHomeActionFromScheduled({
  required Vegetable vegetable,
  required PlantScheduledAction action,
}) {
  final kind = switch (action.kind) {
    PlantScheduledActionKind.aiWarning => GardenHomeActionKind.aiWarning,
    PlantScheduledActionKind.aiLetOp => GardenHomeActionKind.aiWarning,
    PlantScheduledActionKind.seasonWarning => GardenHomeActionKind.seasonWarning,
    PlantScheduledActionKind.planPlant => GardenHomeActionKind.planPlant,
    PlantScheduledActionKind.firstScan => GardenHomeActionKind.firstPhoto,
    PlantScheduledActionKind.weeklyScan => GardenHomeActionKind.weeklyScan,
    PlantScheduledActionKind.harvest => GardenHomeActionKind.harvest,
    PlantScheduledActionKind.aiCoach => GardenHomeActionKind.aiCoach,
    PlantScheduledActionKind.aiRecommended => GardenHomeActionKind.aiCoach,
    PlantScheduledActionKind.calendar => GardenHomeActionKind.calendarCountdown,
  };

  return GardenHomeAction(
    vegetable: vegetable,
    kind: kind,
    subtitle: _homeActionSubtitle(action),
    scheduled: action,
  );
}

String _homeActionSubtitle(PlantScheduledAction action) {
  final base = action.moestuinLabel;
  final warning = action.warningNote?.trim();
  if (warning == null || warning.isEmpty) return base;
  return '$base\n⚠ $warning';
}

Future<bool> commitVegetablePlanted({
  required GardenProfileStore profileStore,
  required String vegetableId,
  required MarkPlantedResult result,
}) async {
  await profileStore.ensureProfile(vegetableId);
  await profileStore.markAsPlanted(
    vegetableId,
    plantedAt: result.plantedAt,
    location: result.location,
    sunLevel: result.sunLevel,
    plantingDateUnknown: result.plantingDateUnknown,
    plantStartMethod: result.plantStartMethod,
    completeOutdoorPlanting: result.completeOutdoorPlanting,
  );
  return profileStore.profileFor(vegetableId)?.isPlanted == true;
}

Future<void> markVegetableAsPlanted({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenProfileStore profileStore,
  required GardenScanPrefsStore scanPrefs,
  VoidCallback? onDone,
  VoidCallback? onNavigateToScan,
}) async {
  final profile = profileStore.profileFor(vegetable.id);
  final result = await showMarkPlantedSheet(
    context,
    vegetable: vegetable,
    daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
    existingProfile: profile,
  );
  if (result == null) return;
  final planted = await commitVegetablePlanted(
    profileStore: profileStore,
    vegetableId: vegetable.id,
    result: result,
  );
  onDone?.call();
  if (context.mounted) {
    if (planted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '${vegetable.nameNl}: zaaien/planten afgerond. '
            'Volgende stap: $kFirstScanCardLabel op je plantkaart.',
          ),
        ),
      );
    }
  }
}
