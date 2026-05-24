import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_calendar.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'mark_planted_sheet.dart';
import 'vegetable_thumbnail.dart';

/// Actiekaarten bovenaan Start: planten, foto's, oogst.
class HomeMoestuinActions extends StatelessWidget {
  const HomeMoestuinActions({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    this.onGoToPlantScan,
    this.onMarkedPlanted,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final void Function({String? vegetableId})? onGoToPlantScan;
  final VoidCallback? onMarkedPlanted;

  @override
  Widget build(BuildContext context) {
    if (gardenStore.isEmpty) return const SizedBox.shrink();

    final month = DateTime.now().month;
    final items = _collectItems(month);
    if (items.isEmpty) return const SizedBox.shrink();

    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Jouw moestuin — actie',
            style: t.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          ...items.map((item) => _ActionTile(
                item: item,
                onScan: onGoToPlantScan,
                onMarkPlanted: (veg) => _markPlanted(context, veg),
              )),
        ],
      ),
    );
  }

  List<_HomeActionItem> _collectItems(int month) {
    final out = <_HomeActionItem>[];

    for (final id in gardenStore.ids) {
      final veg = repository.byId(id);
      if (veg == null) continue;
      final profile = profileStore.profileFor(id);

      if (profile == null || !profile.isPlanted) {
        final acts = kPlantingCalendar.where(
          (a) =>
              a.vegetableId == id &&
              a.months.contains(month) &&
              (a.type == GardenTaskType.plantOutdoors ||
                  a.type == GardenTaskType.sowOutdoors ||
                  a.type == GardenTaskType.preSow),
        );
        if (acts.isNotEmpty) {
          out.add(
            _HomeActionItem(
              vegetable: veg,
              kind: _HomeActionKind.planPlant,
              title: '${veg.nameNl} — ${acts.first.type.label}',
              subtitle: acts.first.hint ?? 'Staat op je lijst, nog niet geplant',
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
          _HomeActionItem(
            vegetable: veg,
            kind: _HomeActionKind.firstPhoto,
            title: '${veg.nameNl} — eerste foto',
            subtitle:
                'Maak een scan zodat oogst en kalender automatisch kloppen',
          ),
        );
      } else if (needsWeeklyScan(profile)) {
        out.add(
          _HomeActionItem(
            vegetable: veg,
            kind: _HomeActionKind.weeklyScan,
            title: '${veg.nameNl} — wekelijkse update',
            subtitle: 'Nieuwe foto voor bijgewerkte AI-data',
          ),
        );
      }

      if (isReadyToHarvest(profile)) {
        out.add(
          _HomeActionItem(
            vegetable: veg,
            kind: _HomeActionKind.harvest,
            title: '${veg.nameNl} — oogsten',
            subtitle: profile.lastAnalysis?.harvestWindowLabel ??
                'Volgens je laatste scan',
          ),
        );
      } else {
        final harvestMonth = profile.predictedHarvestAt?.month;
        if (harvestMonth == month) {
          final acts = kPlantingCalendar.where(
            (a) =>
                a.vegetableId == id &&
                a.type == GardenTaskType.harvest &&
                a.months.contains(month),
          );
          if (acts.isNotEmpty) {
            out.add(
              _HomeActionItem(
                vegetable: veg,
                kind: _HomeActionKind.calendarHarvest,
                title: '${veg.nameNl} — oogstperiode',
                subtitle: profile.predictedHarvestAt != null
                    ? 'AI: rond ${profile.predictedHarvestAt!.day}-${profile.predictedHarvestAt!.month}'
                    : (acts.first.hint ?? 'Oogstperiode volgens kalender'),
              ),
            );
          }
        }
      }
    }

    return out;
  }

  Future<void> _markPlanted(BuildContext context, Vegetable veg) async {
    final result = await showMarkPlantedSheet(
      context,
      vegetableName: veg.nameNl,
      daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
    );
    if (result == null) return;
    await profileStore.ensureProfile(veg.id);
    await profileStore.markAsPlanted(
      veg.id,
      plantedAt: result.plantedAt,
      location: result.location,
      sunLevel: result.sunLevel,
    );
    onMarkedPlanted?.call();
  }
}

enum _HomeActionKind {
  planPlant,
  firstPhoto,
  weeklyScan,
  harvest,
  calendarHarvest,
}

class _HomeActionItem {
  const _HomeActionItem({
    required this.vegetable,
    required this.kind,
    required this.title,
    required this.subtitle,
  });

  final Vegetable vegetable;
  final _HomeActionKind kind;
  final String title;
  final String subtitle;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.item,
    this.onScan,
    required this.onMarkPlanted,
  });

  final _HomeActionItem item;
  final void Function({String? vegetableId})? onScan;
  final void Function(Vegetable veg) onMarkPlanted;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            VegetableThumbnail(vegetable: item.vegetable, size: 44),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(item.subtitle, style: t.textTheme.bodySmall),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      if (item.kind == _HomeActionKind.planPlant)
                        FilledButton.tonal(
                          onPressed: () => onMarkPlanted(item.vegetable),
                          child: const Text('Geplant ✓'),
                        ),
                      if (item.kind == _HomeActionKind.firstPhoto ||
                          item.kind == _HomeActionKind.weeklyScan ||
                          item.kind == _HomeActionKind.harvest)
                        FilledButton.tonalIcon(
                          onPressed: onScan == null
                              ? null
                              : () => onScan!(
                                    vegetableId: item.vegetable.id,
                                  ),
                          icon: const Icon(Icons.photo_camera_outlined, size: 18),
                          label: const Text('Scan'),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
