import 'package:flutter/material.dart';

import '../data/garden_history_eligibility.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';

/// Bevestiging en verwijderen uit Mijn moestuin (profiel blijft in history).
Future<bool> confirmAndRemoveFromGarden(
  BuildContext context, {
  required Vegetable vegetable,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required GardenScanPrefsStore scanPrefs,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) => AlertDialog(
      title: const Text('Uit Mijn moestuin halen?'),
      content: Text(
        'Weet je zeker dat je ${vegetable.nameNl} uit je moestuin wilt halen?\n\n'
        'Alleen planten met een scan, geoogst gewas of uitgebloeide planten '
        'komen in History. Anders wordt alles verwijderd.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Ja, verwijderen'),
        ),
      ],
    ),
  );
  if (ok != true) return false;

  final profile = profileStore.profileFor(vegetable.id);
  await gardenStore.remove(vegetable.id);
  var keptInHistory = false;
  if (profile != null) {
    if (profileQualifiesForHistory(profile)) {
      keptInHistory = await profileStore.archiveProfile(
        vegetable.id,
        gardenStore: gardenStore,
      );
    } else {
      await profileStore.removeProfile(vegetable.id);
    }
  }
  await syncGardenNotifications(
    profileStore: profileStore,
    gardenStore: gardenStore,
    repository: repository,
    scanPrefs: scanPrefs,
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          keptInHistory
              ? '${vegetable.nameNl} staat nu in History'
              : '${vegetable.nameNl} is verwijderd (geen history)',
        ),
      ),
    );
  }
  return true;
}
