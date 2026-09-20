import '../models/add_plant_wizard_models.dart';
import '../models/plant_grow_approach.dart';
import '../models/garden_plant_profile.dart';

import '../models/vegetable.dart';

import 'crop_lifecycle_metadata.dart';

import 'garden_plant_schedule.dart';
import 'garden_profile_store.dart';
import 'garden_scan_prefs_store.dart';
import 'moestuin_pinned_action.dart';
import 'plant_pending_planting.dart';



/// Normaliseert actietekst naar één onderwerp-sleutel.

String? semanticTopicKeyForAction(String text) {

  final t = text.toLowerCase();

  if (t.contains('water') ||

      t.contains('giet') ||

      t.contains('droog') ||

      t.contains('vocht') ||

      t.contains('bevochtig')) {

    return 'water';

  }

  if (t.contains('oogst') ||

      t.contains('pluk') ||

      t.contains('rijp') ||

      t.contains('harvest') ||

      t.contains('oogstbaar')) {

    return 'harvest';

  }

  if (t.contains('bladluis') || t.contains('luis')) return 'bladluis';

  if (t.contains('rups')) return 'rups';

  if (t.contains('slak')) return 'slak';

  if (t.contains('witte vlieg')) return 'witte_vlieg';

  if (t.contains('spint')) return 'spint';

  if (t.contains('trips')) return 'trips';

  if (t.contains('meeldauw')) return 'meeldauw';

  if (t.contains('schimmel')) return 'schimmel';

  if (t.contains('onkruid') || t.contains('onkr')) return 'onkruid';

  if (t.contains('bemest') ||

      t.contains('voeding') ||

      t.contains('stikstof') ||

      t.contains('kalium')) {

    return 'voeding';

  }

  if (t.contains('snoei')) return 'snoei';

  if (t.contains('scan') || t.contains('foto')) return 'scan';

  return null;

}



String homeActionDismissKey({

  required String kindName,

  required String topic,

  required String activeLabel,

  String? detailBody,

}) {

  final text = '$topic $activeLabel ${detailBody ?? ''}';

  final semantic = semanticTopicKeyForAction(text) ?? topic.toLowerCase();

  return '$kindName|$semantic';

}



bool isHomeActionCompleted({

  required GardenPlantProfile? profile,

  required String kindName,

  required String topic,

  required String activeLabel,

  String? detailBody,

}) {

  if (profile == null) return false;

  final key = homeActionDismissKey(

    kindName: kindName,

    topic: topic,

    activeLabel: activeLabel,

    detailBody: detailBody,

  );

  final doneAtScan = profile.completedHomeActions[key];
  if (doneAtScan == null) return false;

  final scanMs = profile.lastAnalysis?.scannedAt.millisecondsSinceEpoch;
  if (scanMs == null) {
    // Afgevinkt zonder scan: blijft weg tot de eerste AI-scan.
    return true;
  }

  return doneAtScan == scanMs;
}



bool isHarvestActionKind(String kindName) => kindName == 'harvest';



String completeHomeActionButtonLabel({

  required String kindName,

  required Vegetable vegetable,

  required GardenPlantProfile? profile,

}) {

  if (isHarvestActionKind(kindName)) {

    final insight = profile?.lastAnalysis?.insight;

    final continuous = insight?.moreHarvestExpectedThisSeason == true ||

        harvestPatternFor(vegetable) == CropHarvestPattern.continuous;

    return continuous ? 'Eerste fase geoogst' : 'Geoogst';

  }

  if (kindName == 'planPlant' && profile != null) {
    return plantingCompleteButtonLabel(
      vegetable: vegetable,
      profile: profile,
    );
  }

  if (kindName == 'firstScan') {
    return kFirstScanCardLabel;
  }

  return 'Taak uitgevoerd';

}



Future<bool> markHomeActionCompleted({

  required GardenProfileStore profileStore,

  required String vegetableId,

  required String kindName,

  required String topic,

  required String activeLabel,

  String? detailBody,

  Vegetable? vegetable,

  GardenScanPrefsStore? scanPrefs,

}) async {

  final profile = profileStore.profileFor(vegetableId);

  if (profile == null) return false;



  final key = homeActionDismissKey(

    kindName: kindName,

    topic: topic,

    activeLabel: activeLabel,

    detailBody: detailBody,

  );

  final scanMs = profile.lastAnalysis?.scannedAt.millisecondsSinceEpoch ??

      DateTime.now().millisecondsSinceEpoch;



  var updated = profile.copyWith(

    completedHomeActions: {

      ...profile.completedHomeActions,

      key: scanMs,

    },

  );



  if (isHarvestActionKind(kindName)) {

    updated = updated.copyWith(

      harvestSessionsThisSeason: profile.harvestSessionsThisSeason + 1,

    );

  }



  await profileStore.saveProfile(updated);

  if (vegetable != null && scanPrefs != null) {
    final current = profileStore.profileFor(vegetableId);
    if (current != null) {
      final synced = syncPinnedMoestuinAction(
        profile: current,
        vegetable: vegetable,
        scanPrefs: scanPrefs,
      );
      if (synced.pinnedMoestuinActionKey != current.pinnedMoestuinActionKey ||
          synced.pinnedMoestuinActionAtScanMs !=
              current.pinnedMoestuinActionAtScanMs) {
        await profileStore.saveProfile(synced);
      }
    }
  }

  return true;
}


