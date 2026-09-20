import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'garden_plant_insight_body.dart';

/// Geschiedenis en status van jouw plant (vanaf Mijn moestuin).
Future<void> showPlantHistorySheet({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required GardenProfileStore profileStore,
  required GardenScanPrefsStore scanPrefs,
  MyGardenStore? gardenStore,
  VoidCallback? onScan,
  VoidCallback? onProbeHarvestScan,
  Future<void> Function()? onMarkPlanted,
  VoidCallback? onHarvestSynced,
  int initialTabIndex = 0,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.78,
        minChildSize: 0.45,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return ListenableBuilder(
            listenable: profileStore,
            builder: (context, _) {
              final latest =
                  profileStore.profileFor(vegetable.id) ?? profile;
              final notPlanted = !latest.isPlanted;

              return SafeArea(
                child: Column(
                  children: [
                    if (notPlanted && onMarkPlanted != null)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                        child: FilledButton.tonalIcon(
                          onPressed: () async {
                            await onMarkPlanted!();
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                          icon: const Icon(Icons.yard_outlined),
                          label: const Text('Markeer als geplant'),
                        ),
                      ),
                    Expanded(
                      child: GardenPlantInsightBody(
                        scrollController: scrollController,
                        vegetable: vegetable,
                        profileStore: profileStore,
                        scanPrefs: scanPrefs,
                        gardenStore: gardenStore,
                        embedded: true,
                        onGoToPlantScan: onScan == null
                            ? null
                            : () {
                                Navigator.pop(ctx);
                                onScan();
                              },
                        initialSection: initialTabIndex == 1
                            ? GardenPlantInsightSection.scanHistory
                            : GardenPlantInsightSection.insights,
                        showHeader: true,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      );
    },
  );
}
