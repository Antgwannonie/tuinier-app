import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/home_task_timing.dart';
import '../data/moestuin_next_action.dart';
import '../data/my_garden_store.dart';
import '../data/garden_plant_schedule.dart';
import '../data/planting_calendar.dart';
import '../data/planting_calendar_fallback.dart';
import '../data/plant_health_warnings.dart';
import '../data/plant_scheduled_actions.dart';
import '../data/insect_scan_store.dart';
import '../data/vegetable_repository.dart';
import '../data/vegetable_image_info.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'home_moestuin_actions.dart';
import 'plant_history_sheet.dart';
import 'vegetable_hero_image.dart';
import '../data/plant_scan_history.dart';
import '../data/plant_scan_photo_store.dart';
import '../theme/tuinier_theme.dart';
import 'moestuin_overview_card.dart';
import 'tuin_heading.dart';

/// Mijn moestuin, raster met foto, naam en actieknoppen onderaan.
class HomeMoestuinSection extends StatelessWidget {
  const HomeMoestuinSection({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.month,
    required this.monthName,
    required this.taskEntriesById,
    required this.taskIconFor,
    required this.onAddPlant,
    required this.onOpenDetail,
    this.onGoToPlantScan,
    this.onMarkedPlanted,
    this.onOpenInsight,
    this.insectStore,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final int month;
  final String monthName;
  final Map<String, HomeTaskEntry> taskEntriesById;
  final IconData Function(GardenTaskType) taskIconFor;
  final VoidCallback onAddPlant;
  final void Function(Vegetable veg, {bool openScanHistoryTab}) onOpenDetail;
  final void Function({String? vegetableId, bool harvestProbe})? onGoToPlantScan;
  final VoidCallback? onMarkedPlanted;
  final VoidCallback? onOpenInsight;
  final InsectScanStore? insectStore;

  List<Vegetable> _allPlants() {
    final list = <Vegetable>[];
    for (final id in gardenStore.ids) {
      final v = repository.byId(id);
      if (v != null) list.add(v);
    }
    list.sort((a, b) => a.nameNl.compareTo(b.nameNl));
    return list;
  }

  ({List<Vegetable> pending, List<Vegetable> done}) _partitionPlants(
    Map<String, GardenHomeAction> actionsById,
    Map<String, HomeTaskEntry> entriesById,
  ) {
    final pending = <Vegetable>[];
    final done = <Vegetable>[];
    for (final veg in _allPlants()) {
      final profile = profileStore.profileFor(veg.id);
      final awaitingPlant = profile == null || !profile.isPlanted;
      final awaitingFirstScan =
          profile != null && awaitingFirstPhotoScan(profile);
      final needs = plantNeedsMoestuinAction(
        hasHomeAction: actionsById.containsKey(veg.id),
        taskEntry: entriesById[veg.id],
        awaitingPlant: awaitingPlant,
        awaitingFirstScan: awaitingFirstScan,
      );
      if (needs) {
        pending.add(veg);
      } else {
        done.add(veg);
      }
    }
    pending.sort((a, b) {
      final aAct = actionsById[a.id];
      final bAct = actionsById[b.id];
      if (aAct != null && bAct != null) {
        final sa = aAct.scheduled;
        final sb = bAct.scheduled;
        if (sa != null && sb != null) {
          final cmp = comparePlantScheduledActions(sa, sb);
          if (cmp != 0) return cmp;
        }
      } else if (aAct != null) {
        return -1;
      } else if (bAct != null) {
        return 1;
      }
      return a.nameNl.compareTo(b.nameNl);
    });
    return (pending: pending, done: done);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final actions = collectGardenHomeActions(
      repository: repository,
      gardenStore: gardenStore,
      profileStore: profileStore,
      scanPrefs: scanPrefs,
      month: month,
    );
    final actionsById = <String, GardenHomeAction>{};
    for (final action in actions) {
      actionsById.putIfAbsent(action.vegetable.id, () => action);
    }
    final parts = _partitionPlants(actionsById, taskEntriesById);

    final plantCount = gardenStore.ids.length;
    final pendingCount = parts.pending.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (insectStore != null)
          MoestuinOverviewCard(
            gardenStore: gardenStore,
            profileStore: profileStore,
            repository: repository,
            insectStore: insectStore!,
            monthName: monthName,
            plantCount: plantCount,
            pendingCount: pendingCount,
            onOpenInsight: onOpenInsight,
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (gardenStore.isEmpty)
                _EmptyGardenCard(onAdd: onAddPlant)
              else ...[
                if (parts.pending.isNotEmpty) ...[
                  const _MoestuinSectionHeader(
                    title: 'Nu aan de slag',
                    icon: Icons.bolt_outlined,
                    emphasized: true,
                  ),
                  const SizedBox(height: 10),
                  _PlantGrid(
                    plants: parts.pending,
                    month: month,
                    actionsById: actionsById,
                    entriesById: taskEntriesById,
                    gardenStore: gardenStore,
                    repository: repository,
                    profileStore: profileStore,
                    scanPrefs: scanPrefs,
                    taskIconFor: taskIconFor,
                    dimmed: false,
                    onOpenDetail: onOpenDetail,
                    onGoToPlantScan: onGoToPlantScan,
                    onMarkedPlanted: onMarkedPlanted,
                  ),
                ],
                if (parts.done.isNotEmpty) ...[
                  if (parts.pending.isNotEmpty) const SizedBox(height: 20),
                  _MoestuinSectionHeader(
                    title: 'Even rust',
                    subtitle: parts.done.length == 1
                        ? '1 plant, geen taak nu'
                        : '${parts.done.length} planten, geen taak nu',
                    icon: Icons.check_circle_outline,
                    emphasized: false,
                  ),
                  const SizedBox(height: 10),
                  _PlantGrid(
                    plants: parts.done,
                    month: month,
                    actionsById: actionsById,
                    entriesById: taskEntriesById,
                    gardenStore: gardenStore,
                    repository: repository,
                    profileStore: profileStore,
                    scanPrefs: scanPrefs,
                    taskIconFor: taskIconFor,
                    dimmed: true,
                    onOpenDetail: onOpenDetail,
                    onGoToPlantScan: onGoToPlantScan,
                    onMarkedPlanted: onMarkedPlanted,
                  ),
                ],
                const SizedBox(height: 14),
                _AddPlantGridCard(onTap: onAddPlant),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MoestuinSectionCard extends StatelessWidget {
  const _MoestuinSectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TuinHeading(
            title,
            icon: icon,
            fontSize: 16,
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

class _MoestuinSectionHeader extends StatelessWidget {
  const _MoestuinSectionHeader({
    required this.title,
    this.subtitle,
    required this.icon,
    required this.emphasized,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final iconColor = emphasized ? cs.primary : cs.onSurfaceVariant;
    final titleStyle = tuinDisplayStyle(
      context,
      base: t.textTheme.titleSmall,
      fontSize: 17,
      color: emphasized ? cs.onSurface : cs.onSurfaceVariant,
    );
    final subtitleText = subtitle;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor),
        const SizedBox(width: 8),
        Expanded(
          child: subtitleText == null
              ? Text(title, style: titleStyle)
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: titleStyle),
                    Text(
                      subtitleText,
                      style: t.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _EmptyGardenCard extends StatelessWidget {
  const _EmptyGardenCard({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return _MoestuinSectionCard(
      title: 'Je moestuin is leeg',
      icon: Icons.eco_outlined,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Kies groenten die je kweekt. Je ziet hier wat er '
            'deze maand te doen is, scannen, planten en oogsten.',
            style: t.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Eerste groente toevoegen'),
          ),
        ],
      ),
    );
  }
}

class _PlantGrid extends StatelessWidget {
  const _PlantGrid({
    required this.plants,
    required this.month,
    required this.actionsById,
    required this.entriesById,
    required this.gardenStore,
    required this.repository,
    required this.profileStore,
    required this.scanPrefs,
    required this.taskIconFor,
    required this.dimmed,
    required this.onOpenDetail,
    this.onGoToPlantScan,
    this.onMarkedPlanted,
  });

  final List<Vegetable> plants;
  final int month;
  final Map<String, GardenHomeAction> actionsById;
  final Map<String, HomeTaskEntry> entriesById;
  final MyGardenStore gardenStore;
  final VegetableRepository repository;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final IconData Function(GardenTaskType) taskIconFor;
  final bool dimmed;
  final void Function(Vegetable veg, {bool openScanHistoryTab}) onOpenDetail;
  final void Function({String? vegetableId, bool harvestProbe})? onGoToPlantScan;
  final VoidCallback? onMarkedPlanted;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.56,
      ),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        final veg = plants[index];
        final profile = profileStore.profileFor(veg.id);
        final countdown = dimmed
            ? nextMoestuinActionCountdown(
                vegetable: veg,
                profile: profile,
              )
            : null;
        final canMarkPlanted = profile != null && !profile.isPlanted;
        final taskEntry = entriesById[veg.id];

        return _MoestuinPlantCard(
          vegetable: veg,
          profile: profile,
          scanPhotoPath: profile?.lastScanPhotoPath,
          action: actionsById[veg.id],
          taskEntry: taskEntry,
          plantActionIcon: _plantActionIcon(
            vegetable: veg,
            month: month,
            taskEntry: taskEntry,
            taskIconFor: taskIconFor,
            awaitingPlant: canMarkPlanted,
          ),
          dimmed: dimmed,
          countdownLine: countdown,
          onOpenDetail: ({bool openScanHistoryTab = false}) =>
              onOpenDetail(veg, openScanHistoryTab: openScanHistoryTab),
          onScan: onGoToPlantScan != null
              ? () => onGoToPlantScan!(vegetableId: veg.id)
              : null,
          onMarkPlanted: canMarkPlanted
              ? () => markVegetableAsPlanted(
                    context: context,
                    vegetable: veg,
                    profileStore: profileStore,
                    scanPrefs: scanPrefs,
                    onDone: onMarkedPlanted,
                  )
              : null,
          onOpenPlantHistory: profile != null && profile.isPlanted
              ? () => showPlantHistorySheet(
                    context: context,
                    vegetable: veg,
                    profile: profile,
                    profileStore: profileStore,
                    scanPrefs: scanPrefs,
                    gardenStore: gardenStore,
                    onScan: onGoToPlantScan != null
                        ? () => onGoToPlantScan!(vegetableId: veg.id)
                        : null,
                    onProbeHarvestScan: onGoToPlantScan != null
                        ? () => onGoToPlantScan!(
                              vegetableId: veg.id,
                              harvestProbe: true,
                            )
                        : null,
                    onHarvestSynced: onMarkedPlanted,
                  )
              : null,
        );
      },
    );
  }
}

IconData _plantActionIcon({
  required Vegetable vegetable,
  required int month,
  required HomeTaskEntry? taskEntry,
  required IconData Function(GardenTaskType) taskIconFor,
  required bool awaitingPlant,
}) {
  if (awaitingPlant) {
    final plantingActs = calendarActivitiesForVegetable(
      vegetable.id,
      vegetable: vegetable,
    )
        .where(
          (a) =>
              a.months.contains(month) &&
              (a.type == GardenTaskType.plantOutdoors ||
                  a.type == GardenTaskType.sowOutdoors ||
                  a.type == GardenTaskType.preSow),
        )
        .toList()
      ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));
    if (plantingActs.isNotEmpty) {
      return taskIconFor(plantingActs.first.type);
    }
  }
  if (taskEntry != null) {
    return taskIconFor(taskEntry.activity.type);
  }
  return Icons.yard_outlined;
}

class _MoestuinPlantCard extends StatelessWidget {
  const _MoestuinPlantCard({
    required this.vegetable,
    this.profile,
    this.scanPhotoPath,
    this.action,
    this.taskEntry,
    required this.plantActionIcon,
    this.dimmed = false,
    this.countdownLine,
    required this.onOpenDetail,
    this.onScan,
    this.onMarkPlanted,
    this.onOpenPlantHistory,
  });

  final Vegetable vegetable;
  final GardenPlantProfile? profile;
  final String? scanPhotoPath;
  final GardenHomeAction? action;
  final HomeTaskEntry? taskEntry;
  final IconData plantActionIcon;
  final bool dimmed;
  final String? countdownLine;
  final void Function({bool openScanHistoryTab}) onOpenDetail;
  final VoidCallback? onScan;
  final VoidCallback? onMarkPlanted;
  final VoidCallback? onOpenPlantHistory;

  bool get _scanUrgent =>
      !dimmed &&
      action != null &&
      (action!.kind == GardenHomeActionKind.firstPhoto ||
          action!.kind == GardenHomeActionKind.weeklyScan ||
          action!.kind == GardenHomeActionKind.harvest ||
          action!.kind == GardenHomeActionKind.calendarHarvest);

  bool get _showMarkPlanted =>
      onMarkPlanted != null && profile != null && !profile!.isPlanted;

  bool get _plantHighlight {
    if (dimmed || !_showMarkPlanted) return false;
    if (action?.kind == GardenHomeActionKind.planPlant) return true;
    final timing = taskEntry?.timing;
    if (timing?.isActiveNow ?? false) return true;
    return false;
  }

  bool get _historyHighlight {
    if (_showMarkPlanted || dimmed || profile == null) return false;
    if (plantScanEntries(profile!).isNotEmpty) return true;
    if (profile!.lastAnalysis != null) return true;
    return action?.kind == GardenHomeActionKind.firstPhoto ||
        action?.kind == GardenHomeActionKind.weeklyScan;
  }

  String get _middleTooltip =>
      _showMarkPlanted ? 'Markeer als geplant' : 'Jouw plant';

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final timing = taskEntry?.timing;
    final taskActive = !dimmed && (timing?.isActiveNow ?? false);
    final taskLocked = !dimmed && timing != null && !timing.isActiveNow;
    final warningLevel = profile != null
        ? plantWarningHighlightLevel(
            profile: profile,
            vegetable: vegetable,
          )
        : PlantWarningHighlightLevel.none;
    final warningAccent = warningLevel != PlantWarningHighlightLevel.none
        ? warningAccentColors(cs, warningLevel)
        : null;
    final infoWarningHighlight =
        warningLevel != PlantWarningHighlightLevel.none;

    final subtitle = dimmed
        ? (countdownLine ?? 'Geen taak nu nodig')
        : (action?.subtitle ??
            timing?.countdownLabel ??
            (taskActive
                ? 'Nu: ${taskEntry?.activity.type.label}'
                : (_showMarkPlanted ? 'Nog niet geplant' : null)));

    final hasScanPhoto = PlantScanPhotoStore.exists(scanPhotoPath);
    final listAsset = vegetableImageFor(vegetable.id).assetPath;
    final useZoekenListImage = !hasScanPhoto && listAsset != null;

    return Opacity(
      opacity: dimmed ? 0.88 : 1,
      child: Material(
        color: dimmed
            ? cs.surfaceContainerLow.withValues(alpha: 0.75)
            : cs.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: dimmed
                ? cs.outlineVariant.withValues(alpha: 0.35)
                : cs.outlineVariant.withValues(alpha: 0.45),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColoredBox(
                    color: useZoekenListImage
                        ? const Color(0xFF0A0A0A)
                        : Colors.transparent,
                    child: VegetableHeroImage(
                      vegetable: vegetable,
                      scanPhotoPath: scanPhotoPath,
                      expand: true,
                      borderRadius: BorderRadius.zero,
                      useAtlasIllustration: useZoekenListImage,
                    ),
                  ),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.65),
                          ],
                        ),
                      ),
                      padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                      child: Text(
                        vegetable.nameNl,
                        style: t.textTheme.titleSmall?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  if (taskLocked)
                    const Positioned(
                      top: 8,
                      left: 8,
                      child: Icon(
                        Icons.lock_outline,
                        size: 18,
                        color: Colors.white70,
                      ),
                    ),
                ],
              ),
            ),
            if (subtitle != null && subtitle.isNotEmpty)
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 6, 8, 0),
                child: Text(
                  subtitle,
                  style: t.textTheme.labelSmall?.copyWith(
                    color: dimmed
                        ? cs.onSurfaceVariant.withValues(alpha: 0.85)
                        : cs.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                    fontStyle: dimmed ? FontStyle.italic : FontStyle.normal,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _RoundActionButton(
                    icon: Icons.photo_camera_outlined,
                    tooltip: 'Scan',
                    highlighted: _scanUrgent,
                    enabled: onScan != null,
                    onPressed: onScan,
                  ),
                  _RoundActionButton(
                    icon: _showMarkPlanted
                        ? plantActionIcon
                        : Icons.eco_outlined,
                    tooltip: _middleTooltip,
                    highlighted:
                        _showMarkPlanted ? _plantHighlight : _historyHighlight,
                    enabled: _showMarkPlanted
                        ? onMarkPlanted != null
                        : onOpenPlantHistory != null,
                    onPressed:
                        _showMarkPlanted ? onMarkPlanted : onOpenPlantHistory,
                  ),
                  _RoundActionButton(
                    icon: Icons.info_outline,
                    tooltip: 'Teeltinfo',
                    highlighted: taskActive,
                    enabled: true,
                    onPressed: () => onOpenDetail(),
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

class _RoundActionButton extends StatelessWidget {
  const _RoundActionButton({
    required this.icon,
    required this.tooltip,
    required this.highlighted,
    required this.enabled,
    this.onPressed,
    this.accentBackground,
    this.accentForeground,
  });

  final IconData icon;
  final String tooltip;
  final bool highlighted;
  final bool enabled;
  final VoidCallback? onPressed;
  final Color? accentBackground;
  final Color? accentForeground;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = accentBackground ??
        (highlighted ? cs.primaryContainer : cs.surfaceContainerHighest);
    final fg = accentForeground ??
        (highlighted ? cs.onPrimaryContainer : cs.onSurfaceVariant);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: bg,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: enabled ? onPressed : null,
          child: SizedBox(
            width: 38,
            height: 38,
            child: Icon(
              icon,
              size: 19,
              color: enabled ? fg : fg.withValues(alpha: 0.35),
            ),
          ),
        ),
      ),
    );
  }
}

class _AddPlantGridCard extends StatelessWidget {
  const _AddPlantGridCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context);

    return Material(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: cs.primary.withValues(alpha: 0.45),
          width: 1.5,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_circle_outline, size: 22, color: cs.primary),
              const SizedBox(width: 8),
              Text(
                'Groente toevoegen',
                style: t.textTheme.titleSmall?.copyWith(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
