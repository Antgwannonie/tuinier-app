import '../models/add_plant_setup_result.dart';
import '../models/add_plant_wizard_models.dart';
import '../models/vegetable.dart';
import 'garden_plant_schedule.dart';
import 'garden_profile_store.dart';
import 'moestuin_pinned_action.dart';
import 'my_garden_store.dart';
import 'plant_scan_consistency.dart';
import 'plant_scan_photo_store.dart';
import 'plant_season_activation.dart';
import 'garden_scan_prefs_store.dart';
import 'store_update_batch.dart';
import 'vegetable_repository.dart';
/// Lets the wizard close animation finish before disk writes + list rebuild.
const addPlantApplyDefer = Duration(milliseconds: 260);

/// Persist a new plant once, with a single UI refresh at the end.
Future<bool> applyAddPlantSetup({
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required AddPlantSetupResult setup,
  VegetableRepository? repository,
  GardenScanPrefsStore? scanPrefs,
  bool deferForRouteAnimation = true,
}) async {
  if (gardenStore.contains(setup.vegetableId)) {
    return false;
  }

  final vegetable = repository?.byId(setup.vegetableId);
  final today = DateTime.now();
  final waitForSeason = setup.intent.waitsForSeason &&
      vegetable != null &&
      shouldMarkInactiveUntilPlantingSeason(
        vegetable: vegetable,
        isPlanted: setup.isPlanted,
        growApproach: setup.growApproach,
        plantStartMethod: setup.plantStartMethod,
        reference: today,
      );

  if (deferForRouteAnimation) {
    await Future<void>.delayed(addPlantApplyDefer);
  }

  var added = false;
  await runStoreBatch(() async {
    if (gardenStore.contains(setup.vegetableId)) return;
    await gardenStore.add(setup.vegetableId);
    added = true;
    await profileStore.beginFreshPlantInGarden(
      setup.vegetableId,
      plantedAt: setup.plantedAt,
      location: setup.location,
      sunLevel: setup.sunLevel,
      isPlanted: setup.isPlanted,
      plantingDateUnknown: setup.plantingDateUnknown,
      plantStartMethod: setup.plantStartMethod,
      plantGrowApproach: setup.isPlanted ? null : setup.growApproach,
      userReportedPhase: setup.reportedAiPhase,
    );

    if (waitForSeason) {
      final profile = profileStore.profileFor(setup.vegetableId);
      if (profile != null) {
        await profileStore.saveProfile(
          applyOffSeasonInactiveState(profile),
        );
      }
    }

    if (setup.initialScan != null && setup.isPlanted && vegetable != null) {
      await _persistWizardInitialScan(
        profileStore: profileStore,
        vegetable: vegetable,
        vegetableId: setup.vegetableId,
        initialScan: setup.initialScan!,
        scanPrefs: scanPrefs,
      );
    } else if (vegetable != null && scanPrefs != null && !setup.isPlanted) {
      final profile = profileStore.profileFor(setup.vegetableId);
      if (profile != null) {
        await profileStore.saveProfile(
          syncPinnedMoestuinAction(
            profile: profile,
            vegetable: vegetable,
            scanPrefs: scanPrefs,
          ),
        );
      }
    }
  });
  return added;
}

Future<void> _persistWizardInitialScan({
  required GardenProfileStore profileStore,
  required Vegetable vegetable,
  required String vegetableId,
  required WizardInitialScan initialScan,
  GardenScanPrefsStore? scanPrefs,
}) async {
  final profile = profileStore.profileFor(vegetableId);
  if (profile == null) return;

  final weeklyInterval = scanPrefs?.weeklyScanIntervalDays ??
      GardenScanPrefsStore.defaultWeeklyScanIntervalDays;

  final photoPath = await PlantScanPhotoStore.saveScanPhoto(
    vegetableId,
    initialScan.photoBytes,
  );
  final fingerprint = fingerprintImageBytes(initialScan.photoBytes);
  var updated = applyAiScanToProfile(
    profile,
    initialScan.analysis,
    weeklyScanIntervalDays: weeklyInterval,
    vegetable: vegetable,
    imageFingerprint: fingerprint,
    newScanPhotoPath: photoPath,
    forcePersist: true,
  );
  updated = updated.copyWith(
    userReportedPhase: null,
    plantingDateUnknown: profile.plantingDateUnknown,
  );
  if (scanPrefs != null) {
    updated = syncPinnedMoestuinAction(
      profile: updated,
      vegetable: vegetable,
      scanPrefs: scanPrefs,
    );
  }
  await profileStore.saveProfile(updated);
}
