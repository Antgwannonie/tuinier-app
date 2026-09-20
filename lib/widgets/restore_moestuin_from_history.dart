import 'package:flutter/material.dart';

import '../data/garden_notifications_sync.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';

/// Bevestigt en kopieert planten uit history naar Mijn moestuin (history blijft).
Future<bool> confirmAndRestoreMoestuinBatch(
  BuildContext context, {
  required MoestuinHistoryBatch batch,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required GardenScanPrefsStore scanPrefs,
}) {
  return _confirmAndCopy(
    context,
    plantCount: batch.plantCount,
    dateLabel:
        '${batch.archivedAt.day}-${batch.archivedAt.month}-${batch.archivedAt.year}',
    title: 'Deze moestuin opnieuw gebruiken?',
    gardenStore: gardenStore,
    profileStore: profileStore,
    repository: repository,
    scanPrefs: scanPrefs,
    copy: () => profileStore.restoreMoestuinBatch(batch.batchId, gardenStore),
  );
}

/// Kopieert alle gearchiveerde planten van een jaar naar Mijn moestuin.
Future<bool> confirmAndCopyHistorySeasonToGarden(
  BuildContext context, {
  required int year,
  required List<GardenPlantProfile> archivedProfiles,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required GardenScanPrefsStore scanPrefs,
  String? confirmTitle,
}) {
  return _confirmAndCopy(
    context,
    plantCount: archivedProfiles.length,
    dateLabel: '$year',
    title: confirmTitle ?? 'Planten weer hervatten?',
    gardenStore: gardenStore,
    profileStore: profileStore,
    repository: repository,
    scanPrefs: scanPrefs,
    copy: () =>
        profileStore.copyArchivedPlantsToGarden(archivedProfiles, gardenStore),
  );
}

Future<bool> _confirmAndCopy(
  BuildContext context, {
  required int plantCount,
  required String dateLabel,
  required String title,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required GardenScanPrefsStore scanPrefs,
  required Future<MoestuinRestoreResult> Function() copy,
}) async {
  final hasCurrent = gardenStore.isNotEmpty;

  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) {
      final cs = Theme.of(ctx).colorScheme;
      return AlertDialog(
        icon: Icon(Icons.yard_outlined, color: cs.primary, size: 32),
        title: Text(title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plantCount == 1
                  ? 'Je hervat 1 plant uit $dateLabel in je huidige moestuin.'
                  : 'Je hervat $plantCount planten uit $dateLabel in je huidige moestuin.',
            ),
            const SizedBox(height: 10),
            Text(
              'Alsof je een nieuw seizoen start: opnieuw planten, zonder oude oogst of scans. '
              'Locatie en zon blijven; je geeft zelf aan wanneer iets weer in de grond staat.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 10),
            Text(
              'History blijft gewoon staan, je archief verandert niet.',
              style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                    color: cs.primary,
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
            ),
            if (hasCurrent) ...[
              const SizedBox(height: 10),
              Text(
                'Je huidige moestuin (${gardenStore.count} plant'
                '${gardenStore.count == 1 ? '' : 'en'}) blijft staan. '
                'Gewassen die je al hebt worden niet dubbel toegevoegd.',
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      height: 1.35,
                    ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ja, hervatten'),
          ),
        ],
      );
    },
  );
  if (ok != true) return false;

  final result = await copy();
  await syncGardenNotifications(
    profileStore: profileStore,
    gardenStore: gardenStore,
    repository: repository,
    scanPrefs: scanPrefs,
  );

  if (!context.mounted) return false;

  if (result.total == 0) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Geen planten gevonden om toe te voegen.'),
      ),
    );
    return false;
  }

  final msg = StringBuffer();
  if (result.restored > 0) {
    msg.write(
      result.restored == 1
          ? '1 plant hervat, fris seizoen in je moestuin'
          : '${result.restored} planten hervat, fris seizoen in je moestuin',
    );
  }
  if (result.skipped > 0) {
    if (msg.isNotEmpty) msg.write(' · ');
    msg.write(
      result.skipped == 1
          ? '1 stond al in je moestuin'
          : '${result.skipped} stonden al in je moestuin',
    );
  }
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(msg.toString())),
  );
  return result.restored > 0;
}
