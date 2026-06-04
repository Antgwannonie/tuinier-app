import 'package:flutter/material.dart';

import '../data/crop_harvest_kind.dart';
import '../data/garden_plant_schedule.dart';
import '../data/home_plant_display_text.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_calendar.dart';
import '../data/planting_calendar_fallback.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'mark_planted_sheet.dart';

/// Actie die nu op een plantkaart hoort.
enum GardenHomeActionKind {
  planPlant,
  firstPhoto,
  weeklyScan,
  harvest,
  calendarHarvest,
}

class GardenHomeAction {
  const GardenHomeAction({
    required this.vegetable,
    required this.kind,
    required this.subtitle,
  });

  final Vegetable vegetable;
  final GardenHomeActionKind kind;
  final String subtitle;
}

/// Verzamelt urgente acties per plant in de moestuin.
List<GardenHomeAction> collectGardenHomeActions({
  required VegetableRepository repository,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required GardenScanPrefsStore scanPrefs,
  int? month,
}) {
  final m = month ?? DateTime.now().month;
  final out = <GardenHomeAction>[];

  for (final id in gardenStore.ids) {
    final veg = repository.byId(id);
    if (veg == null) continue;
    final profile = profileStore.profileFor(id);

    if (profile == null || !profile.isPlanted) {
      final acts = calendarActivitiesForVegetable(id, vegetable: veg).where(
        (a) =>
            a.months.contains(m) &&
            (a.type == GardenTaskType.plantOutdoors ||
                a.type == GardenTaskType.sowOutdoors ||
                a.type == GardenTaskType.preSow),
      );
      if (acts.isNotEmpty) {
        final plantHint = shortTextForHomeCard(acts.first.hint, maxLen: 44);
        out.add(
          GardenHomeAction(
            vegetable: veg,
            kind: GardenHomeActionKind.planPlant,
            subtitle: plantHint.isNotEmpty ? plantHint : 'Nog niet geplant',
          ),
        );
      } else {
        out.add(
          GardenHomeAction(
            vegetable: veg,
            kind: GardenHomeActionKind.planPlant,
            subtitle: 'Nog niet geplant',
          ),
        );
      }
      continue;
    }

    if (needsFirstPhoto(
      profile,
      daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
    )) {
      out.add(
        GardenHomeAction(
          vegetable: veg,
          kind: GardenHomeActionKind.firstPhoto,
          subtitle: kFirstScanShortLabel,
        ),
      );
    } else if (needsWeeklyScan(profile)) {
      out.add(
        GardenHomeAction(
          vegetable: veg,
          kind: GardenHomeActionKind.weeklyScan,
          subtitle: 'Wekelijkse foto',
        ),
      );
    }

    if (isEdibleMoestuinBloomCrop(veg) &&
        showEdibleBloomHarvestSection(profile, veg)) {
      out.add(
        GardenHomeAction(
          vegetable: veg,
          kind: GardenHomeActionKind.harvest,
          subtitle: 'Eetbaar of seizoen afronden',
        ),
      );
    } else if (isOrnamentalOnlyMoestuinCrop(veg) &&
        showOrnamentalFinishSection(profile, veg)) {
      final bloom = shortTextForHomeCard(
        bloomHintFromProfile(profile),
        maxLen: 44,
      );
      out.add(
        GardenHomeAction(
          vegetable: veg,
          kind: GardenHomeActionKind.harvest,
          subtitle: bloom.isNotEmpty ? bloom : 'In bloei',
        ),
      );
    } else if (isReadyToHarvest(profile, vegetable: veg)) {
      out.add(
        GardenHomeAction(
          vegetable: veg,
          kind: GardenHomeActionKind.harvest,
          subtitle: profile.lastAnalysis?.harvestWindowLabel ??
              'Klaar om te oogsten',
        ),
      );
    } else {
      final harvestMonth = profile.predictedHarvestAt?.month;
      if (harvestMonth == m) {
        final acts = calendarActivitiesForVegetable(id, vegetable: veg).where(
          (a) => a.type == GardenTaskType.harvest && a.months.contains(m),
        );
        if (acts.isNotEmpty) {
          final harvestHint = shortTextForHomeCard(acts.first.hint, maxLen: 44);
          out.add(
            GardenHomeAction(
              vegetable: veg,
              kind: GardenHomeActionKind.calendarHarvest,
              subtitle: profile.predictedHarvestAt != null
                  ? 'Oogst rond ${profile.predictedHarvestAt!.day}-${profile.predictedHarvestAt!.month}'
                  : (harvestHint.isNotEmpty ? harvestHint : 'Oogstperiode'),
            ),
          );
        }
      }
    }
  }

  return out;
}

Future<void> markVegetableAsPlanted({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenProfileStore profileStore,
  required GardenScanPrefsStore scanPrefs,
  VoidCallback? onDone,
}) async {
    final result = await showMarkPlantedSheet(
      context,
      vegetable: vegetable,
      daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
    );
  if (result == null) return;
  await profileStore.ensureProfile(vegetable.id);
  await profileStore.markAsPlanted(
    vegetable.id,
    plantedAt: result.plantedAt,
    location: result.location,
    sunLevel: result.sunLevel,
    plantingDateUnknown: result.plantingDateUnknown,
  );
  onDone?.call();
}
