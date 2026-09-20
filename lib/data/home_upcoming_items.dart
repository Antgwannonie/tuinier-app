import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'crop_harvest_kind.dart';
import 'garden_countdown.dart';
import 'garden_plant_schedule.dart';
import 'home_task_timing.dart';
import 'planting_calendar.dart';
import 'planting_season_status.dart';

/// Eén regel in de home-sectie “Binnenkort”.
class HomeUpcomingItem {
  const HomeUpcomingItem({
    required this.vegetable,
    required this.kind,
    required this.label,
    required this.inGarden,
    this.daysUntil,
    this.sortKey = 9999,
  });

  final Vegetable vegetable;
  final HomeUpcomingKind kind;
  final String label;
  final bool inGarden;
  final int? daysUntil;

  /// Lager = eerder in de lijst.
  final int sortKey;
}

enum HomeUpcomingKind {
  plant,
  harvest,
}

/// Hoe ver vooruit “binnenkort” reikt (atlas + moestuin) — 30 dagen.
const kHomeUpcomingMaxDays = 30;

List<HomeUpcomingItem> collectUpcomingPlantItems({
  required Iterable<Vegetable> vegetables,
  required bool Function(String id) inGarden,
  required GardenPlantProfile? Function(String id) profileFor,
  DateTime? reference,
}) {
  final today = reference ?? DateTime.now();
  final items = <HomeUpcomingItem>[];

  for (final veg in vegetables) {
    final garden = inGarden(veg.id);
    final profile = garden ? profileFor(veg.id) : null;
    if (profile != null && profile.isPlanted) continue;

    final status = plantingSeasonStatusFor(
      veg.id,
      reference: today,
      vegetable: veg,
    );

    switch (status.phase) {
      case PlantingSeasonPhase.activeNow:
        if (garden && (profile == null || !profile.isPlanted)) {
          // Nu planten → staat in Acties voor jou.
          continue;
        }
        items.add(
          HomeUpcomingItem(
            vegetable: veg,
            kind: HomeUpcomingKind.plant,
            label: status.searchListLabel,
            inGarden: garden,
            daysUntil: status.days ?? 0,
            sortKey: 0,
          ),
        );
      case PlantingSeasonPhase.daysLeft:
      case PlantingSeasonPhase.startsSoon:
        final days = status.days;
        if (days == null || days > kHomeUpcomingMaxDays) continue;
        items.add(
          HomeUpcomingItem(
            vegetable: veg,
            kind: HomeUpcomingKind.plant,
            label: status.searchListLabel,
            inGarden: garden,
            daysUntil: days,
            sortKey: days,
          ),
        );
      case PlantingSeasonPhase.seasonEnded:
      case PlantingSeasonPhase.noCalendar:
        break;
    }
  }

  items.sort((a, b) {
    final cmp = a.sortKey.compareTo(b.sortKey);
    if (cmp != 0) return cmp;
    return a.vegetable.nameNl.compareTo(b.vegetable.nameNl);
  });
  return items;
}

List<HomeUpcomingItem> collectUpcomingHarvestItems({
  required Iterable<Vegetable> vegetables,
  required bool Function(String id) inGarden,
  required GardenPlantProfile? Function(String id) profileFor,
  DateTime? reference,
}) {
  final today = reference ?? DateTime.now();
  final items = <HomeUpcomingItem>[];

  for (final veg in vegetables) {
    final garden = inGarden(veg.id);
    final profile = garden ? profileFor(veg.id) : null;

    if (garden && (profile == null || !profile.isPlanted)) continue;

    final aiTiming = garden && profile != null && profile.isPlanted
        ? resolveHomeTaskTiming(
            vegetable: veg,
            taskType: GardenTaskType.harvest,
            profile: profile,
            useAi: profile.lastAnalysis != null ||
                profile.predictedHarvestAt != null,
            reference: today,
          )
        : null;

    if (aiTiming != null && aiTiming.isActiveNow && _isHarvestDueNow(profile!, veg)) {
      continue;
    }

    if (aiTiming != null &&
        aiTiming.daysUntil != null &&
        aiTiming.daysUntil! <= kHomeUpcomingMaxDays) {
      items.add(
        HomeUpcomingItem(
          vegetable: veg,
          kind: HomeUpcomingKind.harvest,
          label: aiTiming.countdownLabel ?? 'Binnenkort oogsten',
          inGarden: garden,
          daysUntil: aiTiming.daysUntil,
          sortKey: aiTiming.daysUntil!,
        ),
      );
      continue;
    }

    final cal = gardenStatusForTask(veg.id, GardenTaskType.harvest, today);
    if (cal == null) continue;

    if (cal.isActiveNow) {
      if (garden &&
          profile != null &&
          profile.isPlanted &&
          _isHarvestDueNow(profile, veg)) {
        continue;
      }
      items.add(
        HomeUpcomingItem(
          vegetable: veg,
          kind: HomeUpcomingKind.harvest,
          label: cal.countdownLine,
          inGarden: garden,
          daysUntil: 0,
          sortKey: 0,
        ),
      );
      continue;
    }

    if (cal.daysUntil <= kHomeUpcomingMaxDays) {
      items.add(
        HomeUpcomingItem(
          vegetable: veg,
          kind: HomeUpcomingKind.harvest,
          label: cal.countdownLine,
          inGarden: garden,
          daysUntil: cal.daysUntil,
          sortKey: cal.daysUntil,
        ),
      );
    }
  }

  items.sort((a, b) {
    final cmp = a.sortKey.compareTo(b.sortKey);
    if (cmp != 0) return cmp;
    return a.vegetable.nameNl.compareTo(b.vegetable.nameNl);
  });
  return items;
}

bool isPlantingDueNow({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  DateTime? reference,
}) {
  if (profile != null && profile.isPlanted) return false;

  final status = plantingSeasonStatusForSowStart(
    vegetable.id,
    reference: reference,
    vegetable: vegetable,
  );
  if (status.phase == PlantingSeasonPhase.activeNow ||
      status.phase == PlantingSeasonPhase.daysLeft) {
    return true;
  }

  final days = daysUntilNextInitialPlantSeason(
    vegetable.id,
    reference: reference,
    vegetable: vegetable,
  );
  return days == 0;
}

bool isHarvestDueNow({
  required GardenPlantProfile profile,
  required Vegetable vegetable,
  DateTime? reference,
}) {
  return _isHarvestDueNow(profile, vegetable, reference: reference);
}

bool _isHarvestDueNow(
  GardenPlantProfile profile,
  Vegetable vegetable, {
  DateTime? reference,
}) {
  if (isEdibleMoestuinBloomCrop(vegetable) &&
      showEdibleBloomHarvestSection(profile, vegetable)) {
    return true;
  }
  if (isOrnamentalOnlyMoestuinCrop(vegetable) &&
      showOrnamentalFinishSection(profile, vegetable)) {
    return true;
  }

  if (!canUseAiHarvestAssessment(profile, vegetable: vegetable)) return false;

  if (isReadyToHarvest(profile, vegetable: vegetable)) return true;

  final analysis = profile.lastAnalysis!;
  final days = analysis.daysUntilHarvest;
  if (days != null && days <= 0) return true;
  if (analysis.phase == PlantAiPhase.ripe) return true;

  return false;
}
