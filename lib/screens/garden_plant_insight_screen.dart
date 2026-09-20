import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/garden_plant_insight_body.dart';
import '../widgets/remove_from_garden.dart';

/// Moestuin-plant: inzichten en scan-geschiedenis (geen atlas/teeltinfo).
class GardenPlantInsightScreen extends StatelessWidget {
  const GardenPlantInsightScreen({
    super.key,
    required this.vegetable,
    required this.profileStore,
    required this.scanPrefs,
    this.gardenStore,
    this.repository,
    this.onGoToPlantScan,
    this.initialSection = GardenPlantInsightSection.insights,
  });

  final Vegetable vegetable;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final MyGardenStore? gardenStore;
  final VegetableRepository? repository;
  final VoidCallback? onGoToPlantScan;
  final GardenPlantInsightSection initialSection;

  @override
  Widget build(BuildContext context) {
    final canRemove = gardenStore != null &&
        repository != null &&
        gardenStore!.contains(vegetable.id);

    return ListenableBuilder(
      listenable: profileStore,
      builder: (context, _) {
        final profile = profileStore.profileFor(vegetable.id);
        return Scaffold(
          backgroundColor: TuinierColors.background,
          appBar: AppBar(
            backgroundColor: TuinierColors.background,
            surfaceTintColor: Colors.transparent,
            title: Text(
              vegetable.nameNl.toUpperCase(),
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                letterSpacing: 1.2,
                fontSize: 15,
              ),
            ),
            centerTitle: true,
            actions: [
              if (canRemove)
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Uit moestuin halen',
                  onPressed: () async {
                    final removed = await confirmAndRemoveFromGarden(
                      context,
                      vegetable: vegetable,
                      gardenStore: gardenStore!,
                      profileStore: profileStore,
                      repository: repository!,
                      scanPrefs: scanPrefs,
                    );
                    if (removed && context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
            ],
          ),
          body: GardenPlantInsightBody(
            vegetable: vegetable,
            profileStore: profileStore,
            scanPrefs: scanPrefs,
            gardenStore: gardenStore,
            repository: repository,
            onGoToPlantScan: onGoToPlantScan,
            initialSection: initialSection,
          ),
          bottomNavigationBar: profile != null &&
                  onGoToPlantScan != null
              ? PlantInsightScanButton(
                  profile: profile,
                  onScan: onGoToPlantScan!,
                )
              : null,
        );
      },
    );
  }
}
