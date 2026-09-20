import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'crop_lifecycle_metadata.dart';
import 'garden_countdown.dart';
import 'plant_season_activation.dart';
import 'planting_calendar.dart';
import 'planting_season_status.dart';

/// Past moestuin-activiteit aan na een AI-scan.
GardenPlantProfile applyPlantLifecycleAfterScan({
  required GardenPlantProfile profile,
  required PlantAiAnalysis analysis,
  required Vegetable vegetable,
  DateTime? reference,
}) {
  if (!analysis.matchesSelectedCrop || analysis.hasCropMismatch) {
    return profile;
  }
  if (!profile.isMoestuinActive) {
    return profile;
  }

  final ref = reference ?? DateTime.now();
  final month = ref.month;
  final insight = analysis.insight;
  var updated = profile;

  if (insight?.plantLikelyDead == true) {
    updated = updated.copyWith(awaitingDeathConfirmation: true);
  }

  final stillPossible = analysis.harvestStillPossibleThisSeason == true ||
      insight?.moreHarvestExpectedThisSeason == true;
  final outsideOfficialHarvest =
      isOutsideOfficialHarvestMonths(vegetable, month);

  if (outsideOfficialHarvest && stillPossible) {
    updated = updated.copyWith(seasonBeyondCalendar: true);
  } else if (!stillPossible || !outsideOfficialHarvest) {
    updated = updated.copyWith(seasonBeyondCalendar: false);
  }

  return updated;
}

/// Heractiveert een niet-actieve plant als het nieuwe seizoen begint.
GardenPlantProfile? tryReactivatePlantForSeason({
  required GardenPlantProfile profile,
  required Vegetable vegetable,
  required int month,
  DateTime? reference,
}) {
  if (profile.isMoestuinActive) return null;
  if (profile.inactiveReason == PlantMoestuinInactiveReason.confirmedDead) {
    return null;
  }

  final ref = reference ?? DateTime.now();

  if (profile.inactiveReason == PlantMoestuinInactiveReason.offSeason) {
    if (!isPlantingSeasonActiveNow(
      vegetable: vegetable,
      plantStartMethod: profile.plantStartMethod,
      reference: ref,
    )) {
      return null;
    }
    return profile.copyWith(
      isMoestuinActive: true,
      clearInactive: true,
      isPlanted: false,
      harvestedPercent: 0,
      harvestSessionsThisSeason: 0,
      seasonBeyondCalendar: false,
      awaitingDeathConfirmation: false,
      awaitingOutdoorPlanting: false,
    );
  }

  if (lifecycleTypeFor(vegetable) == CropLifecycleType.perennial) {
    if (!isPerennialActiveSeasonOpen(vegetable, month)) return null;
    return profile.copyWith(
      isMoestuinActive: true,
      clearInactive: true,
      isPlanted: true,
      harvestedPercent: 0,
      harvestSessionsThisSeason: 0,
      seasonBeyondCalendar: false,
      awaitingDeathConfirmation: false,
    );
  }

  if (!isPlantingSeasonOpen(vegetable, month)) return null;
  return profile.copyWith(
    isMoestuinActive: true,
    clearInactive: true,
    isPlanted: false,
    harvestedPercent: 0,
    harvestSessionsThisSeason: 0,
    seasonBeyondCalendar: false,
    awaitingDeathConfirmation: false,
  );
}

String moestuinActivityStatusLabel({
  required GardenPlantProfile profile,
  required Vegetable vegetable,
  int? month,
}) {
  if (profile.isMoestuinActive) {
    if (profile.seasonBeyondCalendar) {
      return 'Seizoen voorbij · scans voor late oogst';
    }
    if (profile.awaitingDeathConfirmation) {
      return 'Controleer of plant dood is';
    }
    return '';
  }

  final reason = profile.inactiveReason;
  if (reason == PlantMoestuinInactiveReason.confirmedDead) {
    return 'Niet actief · ${reason!.shortLabel}';
  }
  if (reason == PlantMoestuinInactiveReason.harvestComplete) {
    return 'Niet actief · ${reason!.shortLabel} dit seizoen';
  }
  if (reason == PlantMoestuinInactiveReason.offSeason) {
    return 'Niet actief · wacht op zaai-/plantseizoen';
  }
  if (reason != null) {
    return 'Niet actief · ${reason.shortLabel}';
  }
  return 'Niet actief';
}

/// Dagen tot heractivering voor een niet-actieve plant in de moestuin.
int? daysUntilInactiveMoestuinReopens({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final today = reference ?? DateTime.now();
  if (lifecycleTypeFor(vegetable) == CropLifecycleType.perennial) {
    int? best;
    for (final type in const [
      GardenTaskType.preSow,
      GardenTaskType.sowOutdoors,
      GardenTaskType.plantOutdoors,
      GardenTaskType.harvest,
    ]) {
      final status = gardenStatusForTask(vegetable.id, type, today);
      if (status == null) continue;
      if (status.isActiveNow) return 0;
      if (status.daysUntil > 0) {
        best = best == null
            ? status.daysUntil
            : (status.daysUntil < best ? status.daysUntil : best);
      }
    }
    return best;
  }

  return daysUntilNextPlantingSeason(
    vegetable.id,
    reference: today,
    vegetable: vegetable,
  );
}

/// Volgende actie op de kaart: aftelling tot nieuw seizoen.
String moestuinInactiveNextSeasonLabel({
  required GardenPlantProfile profile,
  required Vegetable vegetable,
  DateTime? reference,
}) {
  if (profile.inactiveReason == PlantMoestuinInactiveReason.confirmedDead) {
    return 'Geen taak';
  }

  final days = daysUntilInactiveMoestuinReopens(
    vegetable: vegetable,
    reference: reference,
  );
  if (days == null) return 'Geen taak';
  if (days <= 0) return 'Nu: Nieuw seizoen';
  if (days == 1) return 'Over 1 dag: Nieuw seizoen';
  return 'Over $days dagen: Nieuw seizoen';
}

String seasonBeyondCalendarNotice(GardenPlantProfile profile) {
  final ai = profile.lastAnalysis;
  final note = ai?.seasonTimingWarning?.trim();
  if (note != null && note.isNotEmpty) return note;
  return 'Het officiële oogstseizoen is voorbij, maar volgens de scan kan er '
      'nog geoogst worden.';
}

bool showConfirmDeadPlantButton(GardenPlantProfile profile) =>
    profile.awaitingDeathConfirmation && profile.isMoestuinActive;

List<String> harvestAlternativeLines(GardenPlantProfile profile) {
  final tips = profile.lastAnalysis?.insight?.harvestAlternativeTips;
  if (tips == null || tips.isEmpty) return const [];
  return tips;
}

List<String> deadPlantVerificationSteps(GardenPlantProfile profile) {
  final steps = profile.lastAnalysis?.insight?.deadPlantCheckSteps;
  if (steps == null || steps.isEmpty) return const [];
  return steps;
}
