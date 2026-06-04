import 'package:flutter/material.dart';

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
        'Weet je zeker dat je ${vegetable.nameNl} uit je moestuin wilt halen? '
        'Scans en info blijven bewaard in History.',
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

  await gardenStore.remove(vegetable.id);
  await profileStore.archiveProfile(vegetable.id);
  await syncGardenNotifications(
    profileStore: profileStore,
    gardenStore: gardenStore,
    repository: repository,
    scanPrefs: scanPrefs,
  );

  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${vegetable.nameNl} staat nu in History'),
      ),
    );
  }
  return true;
}
