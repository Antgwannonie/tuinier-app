import '../models/add_plant_wizard_models.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_grow_approach.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import 'home_upcoming_items.dart';
import 'plant_season_activation.dart';
import 'plant_start_flow.dart';
import 'planting_season_status.dart';
import 'planting_timing_advice.dart';
import 'wizard_first_steps.dart';

PlantGrowApproach? resolvePlantGrowApproach(GardenPlantProfile? profile) {
  if (profile?.plantGrowApproach != null) return profile!.plantGrowApproach;
  return switch (profile?.plantStartMethod) {
    PlantStartMethod.preSowIndoors || PlantStartMethod.sowOutdoors =>
      PlantGrowApproach.seed,
    PlantStartMethod.plantOutdoors => PlantGrowApproach.seedling,
    null => null,
  };
}

WizardGrowLocation wizardLocationFromProfile(GardenPlantProfile profile) {
  return switch (profile.location) {
    GardenLocation.outdoor => WizardGrowLocation.outdoor,
    GardenLocation.greenhouse => WizardGrowLocation.greenhouse,
    GardenLocation.balcony => WizardGrowLocation.balcony,
    GardenLocation.windowsill => WizardGrowLocation.indoor,
  };
}

WizardSunHours wizardSunFromProfile(GardenPlantProfile profile) {
  return switch (profile.sunLevel) {
    SunLevel.low => WizardSunHours.little,
    SunLevel.medium => WizardSunHours.normal,
    SunLevel.high => WizardSunHours.enough,
  };
}

bool hasPendingPlantingTask({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  DateTime? reference,
}) {
  if (profile == null || profile.isPlanted || !profile.isMoestuinActive) {
    return false;
  }
  if (profileAwaitingOutdoorPlanting(profile)) return false;
  if (isMoestuinOffSeasonWaiting(
    profile: profile,
    vegetable: vegetable,
    reference: reference,
  )) {
    return false;
  }
  final status = plantingSeasonStatusForGrowApproach(
    vegetable: vegetable,
    growApproach: resolvePlantGrowApproach(profile),
    plantStartMethod: profile.plantStartMethod,
    reference: reference,
  );
  return status.phase == PlantingSeasonPhase.activeNow ||
      status.phase == PlantingSeasonPhase.daysLeft;
}

String pendingPlantingTaskLabel({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
}) {
  return plantingActionButtonLabel(
    vegetable: vegetable,
    profile: profile,
  );
}

/// Knop op de moestuin-kaart, gekoppeld aan wizard-keuzes (bijv. «Op balkon zaaien»).
String plantingActionButtonLabel({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
}) {
  if (profileAwaitingOutdoorPlanting(profile)) {
    return outdoorPlantingActionLabel;
  }

  final approach = resolvePlantGrowApproach(profile) ?? PlantGrowApproach.seed;
  final method = profile.plantStartMethod ??
      plantStartMethodForApproach(
        approach: approach,
        available: availablePlantStartMethods(vegetable),
        suggested: suggestedPlantStartMethod(vegetable: vegetable),
      );

  if (method == PlantStartMethod.preSowIndoors) {
    return switch (profile.location) {
      GardenLocation.windowsill => 'Op vensterbank voorzaaien',
      GardenLocation.balcony => 'Op balkon voorzaaien',
      GardenLocation.greenhouse => 'In kas voorzaaien',
      GardenLocation.outdoor => 'Binnen voorzaaien',
    };
  }

  final verb = switch (approach) {
    PlantGrowApproach.seed => 'zaaien',
    PlantGrowApproach.seedling => 'planten',
    PlantGrowApproach.adult => 'planten',
  };

  return switch (profile.location) {
    GardenLocation.balcony => 'Op balkon $verb',
    GardenLocation.greenhouse => 'In kas $verb',
    GardenLocation.windowsill => 'Binnen $verb',
    GardenLocation.outdoor => method == PlantStartMethod.plantOutdoors
        ? 'Buiten planten'
        : 'Buiten zaaien',
  };
}

/// Bevestigingsknop onder de zaai-/plantinstructies.
String plantingCompleteButtonLabel({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
}) {
  return '${plantingActionButtonLabel(vegetable: vegetable, profile: profile)} '
      'afgerond';
}

String plantingSetupSummaryLine(GardenPlantProfile profile) {
  return 'Jouw keuze: ${profile.location.label.toLowerCase()} · '
      '${profile.sunLevel.label.toLowerCase()}';
}

WizardFirstSteps buildPlantingGuidanceSteps({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();
  if (profileAwaitingOutdoorPlanting(profile)) {
    return buildWizardFirstSteps(
      vegetable: vegetable,
      intent: PlantAddIntent.startNow,
      location: wizardLocationFromProfile(profile),
      sunHours: wizardSunFromProfile(profile),
      timing: assessPlantingTiming(vegetable: vegetable, profile: profile),
      season: plantingSeasonStatusForSowStart(
        vegetable.id,
        reference: ref,
        vegetable: vegetable,
      ),
      growApproach: PlantGrowApproach.seedling,
      plantStartMethod: PlantStartMethod.plantOutdoors,
    );
  }
  return buildPlantingTaskFirstSteps(
    vegetable: vegetable,
    profile: profile,
    reference: ref,
  );
}

bool shouldUsePlantingGuidanceSheet(GardenPlantProfile? profile) {
  if (profile == null) return false;
  if (profileAwaitingOutdoorPlanting(profile)) return true;
  return !profile.isPlanted;
}

WizardFirstSteps buildPlantingTaskFirstSteps({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();
  final approach = resolvePlantGrowApproach(profile) ?? PlantGrowApproach.seed;
  final method = profile.plantStartMethod ??
      plantStartMethodForApproach(
        approach: approach,
        available: availablePlantStartMethods(vegetable),
        suggested: suggestedPlantStartMethod(vegetable: vegetable, reference: ref),
      );
  final preview = profile.copyWith(isPlanted: false);
  return buildWizardFirstSteps(
    vegetable: vegetable,
    intent: PlantAddIntent.startNow,
    location: wizardLocationFromProfile(profile),
    sunHours: wizardSunFromProfile(profile),
    timing: assessPlantingTiming(vegetable: vegetable, profile: preview),
    season: plantingSeasonStatusForSowStart(
      vegetable.id,
      reference: ref,
      vegetable: vegetable,
    ),
    growApproach: approach,
    plantStartMethod: method,
  );
}
