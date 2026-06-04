import 'package:flutter/material.dart';

import '../data/garden_notifications_sync.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';

/// Bevestigt en start een lege moestuin; huidige planten gaan naar History.
Future<bool> confirmAndStartNewMoestuin(
  BuildContext context, {
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required GardenScanPrefsStore scanPrefs,
}) async {
  if (gardenStore.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Je moestuin is al leeg.')),
    );
    return false;
  }

  final plantCount = gardenStore.count;
  final year = DateTime.now().year;

  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.warning_amber_rounded, color: cs.error, size: 32),
        title: const Text('Nieuwe moestuin starten?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weet je het zeker?',
              style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              plantCount == 1
                  ? 'De 1 plant in je huidige moestuin wordt verwijderd uit Mijn moestuin.'
                  : 'Alle $plantCount planten in je huidige moestuin worden verwijderd uit Mijn moestuin.',
            ),
            const SizedBox(height: 8),
            Text(
              'Ze blijven bewaard in History ($year), met scans en gegevens. '
              'Daar kun je dezelfde planten later opnieuw in Mijn moestuin zetten.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Je begint daarna met een lege moestuin en kunt opnieuw groenten kiezen.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Nee'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ja, opslaan en legen'),
          ),
        ],
      );
    },
  );
  if (ok != true) return false;

  final result = await profileStore.archiveGardenAndClear(gardenStore);
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
          result.count == 1
              ? '1 plant opgeslagen in History — je moestuin is nu leeg'
              : '${result.count} planten opgeslagen in History — je moestuin is nu leeg',
        ),
      ),
    );
  }
  return true;
}
