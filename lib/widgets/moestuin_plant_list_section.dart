import 'dart:io';

import 'package:flutter/material.dart';

import '../data/crop_bloom_countdown.dart';
import '../data/insect_scan_store.dart';
import '../data/plant_scan_photo_store.dart';
import '../data/moestuin_card_metrics.dart';
import '../data/vegetable_image_info.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_plant_schedule.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/plant_lifecycle.dart';
import '../data/plant_season_activation.dart';
import '../data/harvest_self_check.dart';
import '../data/my_garden_store.dart';
import '../data/plant_scan_history.dart';
import '../data/plant_pending_planting.dart';
import '../data/plant_scheduled_actions.dart';
import '../data/plant_start_flow.dart';
import '../data/vegetable_repository.dart';
import '../data/vegetables_data.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../screens/moestuin_screen.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';
import '../widgets/plant_browse_tile.dart';
import '../widgets/home_action_detail_sheet.dart';
import '../widgets/home_moestuin_actions.dart';
import '../widgets/moestuin_card_insight_sheets.dart';
import '../widgets/moestuin_harvest_sheet.dart';
import '../widgets/moestuin_plant_tasks_sheet.dart';
import '../widgets/scan_photo_viewer.dart';

/// Verticale plantenlijst voor de Moestuin-tab.
class MoestuinPlantListSection extends StatelessWidget {
  const MoestuinPlantListSection({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.month,
    required this.monthName,
    required this.filter,
    required this.searchQuery,
    required this.insectStore,
    required this.onOpenDetail,
    this.onToggleInGarden,
    this.onGoToPlantScan,
    this.onMarkPlanted,
    this.onMarkedPlanted,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final int month;
  final String monthName;
  final MoestuinListFilter filter;
  final String searchQuery;
  final InsectScanStore insectStore;
  final void Function(Vegetable veg, {bool openScanHistoryTab}) onOpenDetail;
  final Future<void> Function(Vegetable veg)? onToggleInGarden;
  final void Function({String? vegetableId, bool harvestProbe})? onGoToPlantScan;
  final Future<void> Function(Vegetable veg)? onMarkPlanted;
  final VoidCallback? onMarkedPlanted;

  /// Toegevoegd aan moestuin maar wacht nog op het zaai-/plantseizoen.
  bool _isAwaitingSeason(GardenPlantProfile? profile, Vegetable vegetable) {
    if (profile == null) return true;
    if (isMoestuinOffSeasonWaiting(profile: profile, vegetable: vegetable)) {
      return true;
    }
    return !profile.isPlanted;
  }

  bool _hasBeenScanned(GardenPlantProfile? profile) {
    if (profile == null) return false;
    return plantScanEntries(profile).isNotEmpty;
  }

  /// Oogstbaar met uitklapbare oogst-tab (zelf controleren of AI bevestigd).
  bool _showsHarvestExpandable(
    GardenPlantProfile? profile,
    Vegetable vegetable,
  ) {
    if (profile == null || !profile.isMoestuinActive || !profile.isPlanted) {
      return false;
    }
    return isHarvestPossiblyReady(profile, vegetable);
  }

  int _plantSortOrder(Vegetable a, Vegetable b) {
    final aProfile = profileStore.profileFor(a.id);
    final bProfile = profileStore.profileFor(b.id);
    final aInactive = aProfile?.isMoestuinActive == false ||
        isMoestuinOffSeasonWaiting(profile: aProfile, vegetable: a);
    final bInactive = bProfile?.isMoestuinActive == false ||
        isMoestuinOffSeasonWaiting(profile: bProfile, vegetable: b);
    if (aInactive != bInactive) return aInactive ? 1 : -1;
    final aHarvestTab = _showsHarvestExpandable(aProfile, a);
    final bHarvestTab = _showsHarvestExpandable(bProfile, b);
    if (aHarvestTab != bHarvestTab) return aHarvestTab ? -1 : 1;
    final aScanned = _hasBeenScanned(aProfile);
    final bScanned = _hasBeenScanned(bProfile);
    if (aScanned != bScanned) return aScanned ? -1 : 1;
    final aAwaiting = _isAwaitingSeason(aProfile, a);
    final bAwaiting = _isAwaitingSeason(bProfile, b);
    if (aAwaiting != bAwaiting) return aAwaiting ? 1 : -1;
    return a.nameNl.compareTo(b.nameNl);
  }

  List<Vegetable> _plants() {
    final query = searchQuery.trim().toLowerCase();
    final list = <Vegetable>[];
    for (final id in gardenStore.ids) {
      final v = repository.byId(id);
      if (v == null) continue;
      final profile = profileStore.profileFor(id);
      if (!filter.matches(profile)) continue;
      if (query.isNotEmpty && !v.nameNl.toLowerCase().contains(query)) {
        continue;
      }
      list.add(v);
    }
    list.sort(_plantSortOrder);
    return list;
  }

  Widget _moestuinCardFor(BuildContext context, Vegetable veg) {
    final profile = profileStore.profileFor(veg.id);
    final metrics = computeMoestuinCardMetrics(
      vegetable: veg,
      profile: profile,
      scanPrefs: scanPrefs,
      month: month,
    );

    final inactive = profile != null &&
        (profile.isMoestuinActive == false ||
            isMoestuinOffSeasonWaiting(
              profile: profile,
              vegetable: veg,
            ));
    final openPlantScan = onGoToPlantScan != null
        ? () => onGoToPlantScan!(vegetableId: veg.id)
        : null;
    final scanRoute = openPlantScan;
    final canScan = openPlantScan != null &&
        !inactive &&
        profile?.isPlanted == true;
    final canMarkPlanted = !inactive &&
        profile != null &&
        needsMoestuinPlantingButton(
          vegetable: veg,
          profile: profile,
        ) &&
        onMarkPlanted != null;
    final canFirstScan = !inactive &&
        profile != null &&
        profile.isPlanted &&
        awaitingFirstPhotoScan(profile) &&
        onGoToPlantScan != null;
    final showHarvest = !inactive &&
        profile != null &&
        (metrics.harvestReady || _showsHarvestExpandable(profile, veg));
    final selfCheckHarvest = profile != null &&
        isAiHarvestVisuallyUncertain(profile, veg);
    final probeHarvestRoute = scanRoute != null && selfCheckHarvest
        ? () => onGoToPlantScan!(
              vegetableId: veg.id,
              harvestProbe: true,
            )
        : null;

    return _MoestuinPlantCard(
      vegetable: veg,
      profile: profile,
      metrics: metrics,
      scanPhotoPath: profile?.lastScanPhotoPath,
      isInactive: inactive,
      showConfirmDead:
          profile != null && showConfirmDeadPlantButton(profile),
      onConfirmDead: profile != null && showConfirmDeadPlantButton(profile)
          ? () => profileStore.confirmPlantDead(veg.id)
          : null,
      onTap: () => onOpenDetail(veg),
      onMarkPlanted: canMarkPlanted ? () => onMarkPlanted!(veg) : null,
      onFirstScan: canFirstScan
          ? () => onGoToPlantScan!(vegetableId: veg.id)
          : null,
      onScan: canScan ? () => onGoToPlantScan!(vegetableId: veg.id) : null,
      showHarvestAction: showHarvest,
      selfCheckHarvest: selfCheckHarvest,
      onHarvest: showHarvest
          ? () => showMoestuinHarvestSheet(
                context: context,
                vegetable: veg,
                profile: profile,
                profileStore: profileStore,
                selfCheckMode: selfCheckHarvest,
                onSeasonFinished: onMarkedPlanted,
                onProbeHarvestScan: probeHarvestRoute,
              )
          : null,
      onProbeHarvest: probeHarvestRoute,
      onOpenPhase: () {
        if (profile != null &&
            hasPendingPlantingTask(vegetable: veg, profile: profile)) {
          final actions = collectPlantScheduledActions(
            vegetable: veg,
            profile: profile,
            scanPrefs: scanPrefs,
            month: month,
          );
          PlantScheduledAction? planting;
          for (final action in actions) {
            if (action.kind == PlantScheduledActionKind.planPlant) {
              planting = action;
              break;
            }
          }
          if (planting != null) {
            showHomeActionDetailSheet(
              context: context,
              action: gardenHomeActionFromScheduled(
                vegetable: veg,
                action: planting,
              ),
              profile: profile,
              profileStore: profileStore,
              scanPrefs: scanPrefs,
              onGoToScan: scanRoute,
              onOpenPlantDetail: () => onOpenDetail(veg),
            );
            return;
          }
        }
        showMoestuinPhaseSheet(
          context: context,
          vegetable: veg,
          metrics: metrics,
        );
      },
      onOpenGrowth: () => showMoestuinGrowthSheet(
        context: context,
        vegetable: veg,
        metrics: metrics,
        profile: profile,
      ),
      onOpenHealth: () => showMoestuinHealthSheet(
        context: context,
        vegetable: veg,
        metrics: metrics,
      ),
      onOpenHarvestInsight: () => showMoestuinHarvestInsightSheet(
        context: context,
        vegetable: veg,
        profile: profile,
        onScan: canScan ? () => onGoToPlantScan!(vegetableId: veg.id) : null,
      ),
      onOpenTasks: () => showMoestuinPlantTasksSheet(
        context: context,
        vegetable: veg,
        profile: profile,
        scanPrefs: scanPrefs,
        profileStore: profileStore,
        month: month,
        onGoToScan: scanRoute,
        onOpenPlantDetail: () => onOpenDetail(veg),
      ),
    );
  }

  List<Vegetable> _catalogResults() {
    final q = searchQuery.trim();
    if (q.isEmpty) return const [];

    final results = <Vegetable>[];
    for (final veg in kVegetablesSeed) {
      if (veg.matchesQuery(q)) results.add(veg);
    }
    results.sort((a, b) => a.nameNl.compareTo(b.nameNl));
    return results;
  }

  ({List<Vegetable> inGarden, List<Vegetable> notInGarden})
      _splitSearchResults() {
    final inGarden = <Vegetable>[];
    final notInGarden = <Vegetable>[];
    for (final veg in _catalogResults()) {
      if (gardenStore.contains(veg.id)) {
        final profile = profileStore.profileFor(veg.id);
        if (filter.matches(profile)) inGarden.add(veg);
      } else {
        notInGarden.add(veg);
      }
    }
    inGarden.sort(_plantSortOrder);
    return (inGarden: inGarden, notInGarden: notInGarden);
  }

  bool get _isSearching => searchQuery.trim().isNotEmpty;

  Widget _emptyMessage(BuildContext context, String message) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 96),
      children: [
        Text(
          message,
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TuinierColors.textSecondary,
              ),
        ),
      ],
    );
  }

  Widget _emptyGardenMessage(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(32, 32, 32, 96),
      children: [
        Icon(
          Icons.yard_outlined,
          size: 48,
          color: TuinierColors.iconMuted.withValues(alpha: 0.6),
        ),
        const SizedBox(height: 16),
        Text(
          'Je moestuin is nog leeg',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: TuinierColors.textPrimary,
              ),
        ),
        const SizedBox(height: 8),
        Text(
          'Voeg je eerste gewas toe om gezondheid en taken te volgen.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: TuinierColors.textSecondary,
              ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isSearching) {
      final split = _splitSearchResults();
      final total = split.inGarden.length + split.notInGarden.length;
      if (total == 0) {
        return _emptyMessage(
          context,
          'Geen gewassen gevonden voor "${searchQuery.trim()}".',
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.only(bottom: 96),
        itemCount: total,
        itemBuilder: (context, index) {
          if (index < split.inGarden.length) {
            return _moestuinCardFor(context, split.inGarden[index]);
          }

          final catalogIndex = index - split.inGarden.length;
          final veg = split.notInGarden[catalogIndex];
          return PlantBrowseTile(
            vegetable: veg,
            inGarden: false,
            onOpenDetail: () => onOpenDetail(veg),
            onToggleGarden:
                onToggleInGarden == null ? null : () => onToggleInGarden!(veg),
            showDivider: index < total - 1,
          );
        },
      );
    }

    final plants = _plants();

    if (gardenStore.isEmpty) {
      return _emptyGardenMessage(context);
    }

    if (plants.isEmpty) {
      return _emptyMessage(context, 'Geen gewassen gevonden.');
    }

    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80),
      itemCount: plants.length,
      itemBuilder: (context, index) {
        return _moestuinCardFor(context, plants[index]);
      },
    );
  }
}

class _MoestuinPlantCard extends StatelessWidget {
  const _MoestuinPlantCard({
    required this.vegetable,
    this.profile,
    required this.metrics,
    this.scanPhotoPath,
    this.isInactive = false,
    this.showConfirmDead = false,
    this.onConfirmDead,
    required this.onTap,
    this.onMarkPlanted,
    this.onFirstScan,
    this.onScan,
    this.showHarvestAction = false,
    this.selfCheckHarvest = false,
    this.onHarvest,
    this.onProbeHarvest,
    required this.onOpenPhase,
    required this.onOpenGrowth,
    required this.onOpenHealth,
    required this.onOpenHarvestInsight,
    required this.onOpenTasks,
  });

  static const _cardRadius = 16.0;
  static const _imageWidth = 106.0;
  static const _imageHeight = 138.0;
  static const _imageCornerRadius = 12.0;
  static final _imageRadius = BorderRadius.circular(_imageCornerRadius);

  final Vegetable vegetable;
  final GardenPlantProfile? profile;
  final MoestuinCardMetrics metrics;
  final String? scanPhotoPath;
  final bool isInactive;
  final bool showConfirmDead;
  final VoidCallback? onConfirmDead;
  final VoidCallback onTap;
  final VoidCallback? onMarkPlanted;
  final VoidCallback? onFirstScan;
  final VoidCallback? onScan;
  final bool showHarvestAction;
  final bool selfCheckHarvest;
  final VoidCallback? onHarvest;
  final VoidCallback? onProbeHarvest;
  final VoidCallback onOpenPhase;
  final VoidCallback onOpenGrowth;
  final VoidCallback onOpenHealth;
  final VoidCallback onOpenHarvestInsight;
  final VoidCallback onOpenTasks;

  Widget _plantImage() {
    final image = _MoestuinPlantImage(
      vegetable: vegetable,
      scanPhotoPath: scanPhotoPath,
      width: _imageWidth,
      height: _imageHeight,
      borderRadius: _imageRadius,
      desaturated: isInactive,
    );
    return image;
  }

  Widget? _plantingButton() {
    if (onMarkPlanted == null || profile == null) return null;
    final label = pendingPlantingTaskLabel(
      vegetable: vegetable,
      profile: profile!,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: onMarkPlanted,
          icon: const Icon(Icons.eco_outlined, size: 18),
          label: Text(label),
        ),
      ),
    );
  }

  Widget? _firstScanButton() {
    if (onFirstScan == null) return null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.tonalIcon(
          onPressed: onFirstScan,
          icon: const Icon(Icons.photo_camera_outlined, size: 18),
          label: const Text(kFirstScanCardLabel),
        ),
      ),
    );
  }

  Widget? _confirmDeadButton() {
    if (!showConfirmDead || onConfirmDead == null) return null;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          onPressed: onConfirmDead,
          icon: const Icon(Icons.eco_outlined, size: 18),
          label: const Text('Plant is dood, niet actief zetten'),
          style: OutlinedButton.styleFrom(
            foregroundColor: TuinierColors.error,
            side: BorderSide(
              color: TuinierColors.error.withValues(alpha: 0.5),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final healthColor = metrics.healthPercent != null
        ? TuinierColors.plantHealthColor(metrics.healthPercent!)
        : TuinierColors.textSecondary;
    final cardColor = isInactive
        ? const Color(0xFFE2E2E2)
        : TuinierColors.card;
    final scanMetricLabel = isInactive &&
            metrics.scanMode == MoestuinMetricTileMode.countdown
        ? 'Seizoen over'
        : 'Scan over';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_cardRadius),
          boxShadow: !isInactive ? TuinierDecorations.cardShadow : null,
          border: isInactive
              ? Border.all(color: TuinierColors.border.withValues(alpha: 0.9))
              : null,
        ),
        child: Material(
          color: cardColor,
          borderRadius: BorderRadius.circular(_cardRadius),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                InkWell(
                  onTap: onTap,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _plantImage(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      vegetable.nameNl,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: t.titleMedium?.copyWith(
                                        fontSize: 19,
                                        fontWeight: FontWeight.w700,
                                        color: TuinierColors.textPrimary,
                                        height: 1.15,
                                      ),
                                    ),
                                  ),
                                  _HealthRing(
                                    percent: metrics.healthPercent,
                                    color: healthColor,
                                  ),
                                  const Icon(
                                    Icons.chevron_right,
                                    size: 18,
                                    color: TuinierColors.iconMuted,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              InkWell(
                                onTap: onOpenHealth,
                                borderRadius: BorderRadius.circular(999),
                                child: _HealthBadge(
                                  label: metrics.healthBadgeLabel,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    flex: 11,
                                    child: _PhaseGrowthCell(
                                      label: 'Fase',
                                      icon: metrics.phaseIcon,
                                      value: metrics.phaseLabel,
                                      onTap: onOpenPhase,
                                    ),
                                  ),
                                  Container(
                                    width: 1,
                                    height: 42,
                                    margin: const EdgeInsets.symmetric(
                                      horizontal: 4,
                                    ),
                                    color: TuinierColors.border,
                                  ),
                                  Expanded(
                                    flex: 12,
                                    child: _PhaseGrowthCell(
                                      label: 'Groei-score',
                                      icon: Icons.trending_up_rounded,
                                      value: metrics.growthScoreLabel,
                                      valueColor: metrics.growthScoreColor,
                                      onTap: onOpenGrowth,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (_plantingButton() != null) _plantingButton()!,
                if (_firstScanButton() != null) _firstScanButton()!,
                if (_confirmDeadButton() != null) _confirmDeadButton()!,
                const Divider(height: 1, color: TuinierColors.border),
                SizedBox(
                  height: _BottomMetricTile.height,
                  child: Row(
                    children: [
                      Expanded(
                        child: _BottomMetricTile(
                          icon: Icons.calendar_today_outlined,
                          label: moestuinMilestoneTileLabel(vegetable),
                          value: metrics.harvestValue,
                          mode: metrics.harvestMode,
                          onTap: () {
                            if (showHarvestAction && onHarvest != null) {
                              onHarvest!();
                              return;
                            }
                            if (metrics.harvestMode ==
                                    MoestuinMetricTileMode.needsAttention &&
                                onProbeHarvest != null) {
                              onProbeHarvest!();
                              return;
                            }
                            if (metrics.harvestMode ==
                                    MoestuinMetricTileMode.needsAttention &&
                                onScan != null) {
                              onScan!();
                              return;
                            }
                            onOpenHarvestInsight();
                          },
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        color: TuinierColors.border,
                      ),
                      Expanded(
                        child: _BottomMetricTile(
                          icon: Icons.photo_camera_outlined,
                          label: scanMetricLabel,
                          value: metrics.scanValue,
                          mode: metrics.scanMode,
                          onTap: () {
                            if (metrics.scanReady && onScan != null) {
                              onScan!();
                              return;
                            }
                            if (onFirstScan != null &&
                                profile != null &&
                                awaitingFirstPhotoScan(profile!)) {
                              onFirstScan!();
                              return;
                            }
                            onTap();
                          },
                        ),
                      ),
                      const VerticalDivider(
                        width: 1,
                        color: TuinierColors.border,
                      ),
                      Expanded(
                        child: _BottomMetricTile(
                          icon: Icons.checklist_rtl_outlined,
                          label: 'Taken & info',
                          value: metrics.tasksValue,
                          mode: metrics.openTaskCount > 0
                              ? MoestuinMetricTileMode.actionReady
                              : MoestuinMetricTileMode.inactive,
                          onTap: onOpenTasks,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
    );
  }
}

class _HealthRing extends StatelessWidget {
  const _HealthRing({required this.percent, required this.color});

  final int? percent;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final ringColor = percent != null ? color : TuinierColors.border;
    final progress = percent == null
        ? 1.0
        : (percent! / 100.0).clamp(0.05, 1.0);

    return SizedBox(
      width: 38,
      height: 38,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: TuinierColors.border,
            color: percent == null ? TuinierColors.border : ringColor,
          ),
          Text(
            percent != null ? '$percent%' : '—',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontSize: 9,
                  fontWeight: FontWeight.w700,
                  color: percent != null ? color : TuinierColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _HealthBadge extends StatelessWidget {
  const _HealthBadge({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: TuinierColors.cardTintGreen,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.eco_outlined,
            size: 14,
            color: TuinierColors.primary,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: TuinierColors.primary,
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }
}

class _PhaseGrowthCell extends StatelessWidget {
  const _PhaseGrowthCell({
    required this.label,
    required this.icon,
    required this.value,
    this.valueColor,
    this.onTap,
  });

  final String label;
  final IconData icon;
  final String value;
  final Color? valueColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.only(right: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: TuinierColors.textSecondary,
                    fontSize: 12,
                  ),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 1),
                  child: Icon(
                    icon,
                    size: 14,
                    color: valueColor ?? TuinierColors.warning,
                  ),
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    value.isEmpty ? '—' : value,
                    maxLines: 2,
                    softWrap: true,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                          fontSize: 13,
                          color: valueColor ?? TuinierColors.textPrimary,
                          height: 1.2,
                        ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BottomMetricTile extends StatelessWidget {
  const _BottomMetricTile({
    required this.icon,
    required this.label,
    required this.value,
    this.mode = MoestuinMetricTileMode.inactive,
    this.onTap,
  });

  static const height = 90.0;

  final IconData icon;
  final String label;
  final String value;
  final MoestuinMetricTileMode mode;
  final VoidCallback? onTap;

  Color get _valueColor {
    return switch (mode) {
      MoestuinMetricTileMode.actionReady => TuinierColors.primary,
      MoestuinMetricTileMode.needsAttention => TuinierColors.warning,
      MoestuinMetricTileMode.countdown => TuinierColors.textPrimary,
      MoestuinMetricTileMode.inactive => TuinierColors.textPrimary,
    };
  }

  Color? get _backgroundColor {
    return switch (mode) {
      MoestuinMetricTileMode.actionReady => TuinierColors.cardTintGreen,
      MoestuinMetricTileMode.needsAttention =>
        TuinierColors.warning.withValues(alpha: 0.08),
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Material(
      color: _backgroundColor ?? Colors.transparent,
      child: InkWell(
        onTap: onTap,
        splashColor: TuinierColors.primary.withValues(alpha: 0.12),
        highlightColor: TuinierColors.cardTintGreen,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 8, 4, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 22, color: TuinierColors.primary),
                  const Spacer(),
                  Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: TuinierColors.iconMuted.withValues(alpha: 0.85),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.labelSmall?.copyWith(
                      color: TuinierColors.textSecondary,
                      fontSize: 12,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: t.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: _valueColor,
                      height: 1.15,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Snijdt alle vier hoeken van het plantfoto-geraamte af.
class _RRectImageClipper extends CustomClipper<Path> {
  _RRectImageClipper(this.borderRadius);

  final BorderRadius borderRadius;

  @override
  Path getClip(Size size) {
    final rect = Offset.zero & size;
    return Path()
      ..addRRect(borderRadius.resolve(TextDirection.ltr).toRRect(rect));
  }

  @override
  bool shouldReclip(covariant _RRectImageClipper oldClipper) =>
      oldClipper.borderRadius != borderRadius;
}

/// Standaard planticoon; na eerste scan de echte scanfoto (langwerpig).
class _MoestuinPlantImage extends StatelessWidget {
  const _MoestuinPlantImage({
    required this.vegetable,
    this.scanPhotoPath,
    required this.width,
    required this.height,
    required this.borderRadius,
    this.desaturated = false,
  });

  final Vegetable vegetable;
  final String? scanPhotoPath;
  final double width;
  final double height;
  final BorderRadius borderRadius;
  final bool desaturated;

  double get _radius => borderRadius.topLeft.x;

  Widget _framed({required Color background, Widget? child}) {
    return ClipPath(
      clipper: _RRectImageClipper(borderRadius),
      child: Material(
        color: background,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_radius),
        ),
        child: SizedBox(
          width: width,
          height: height,
          child: child,
        ),
      ),
    );
  }

  Widget _wrapVisual(Widget child) {
    if (!desaturated) return child;
    return ColorFiltered(
      colorFilter: const ColorFilter.matrix(<double>[
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0.2126, 0.7152, 0.0722, 0, 0,
        0, 0, 0, 0.82, 0,
      ]),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (PlantScanPhotoStore.exists(scanPhotoPath)) {
      return _wrapVisual(
        GestureDetector(
          onTap: () => showScanPhotoViewer(context, scanPhotoPath!),
          child: ClipPath(
            clipper: _RRectImageClipper(borderRadius),
            child: Container(
              width: width,
              height: height,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(_radius),
                image: DecorationImage(
                  image: FileImage(File(scanPhotoPath!)),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        ),
      );
    }

    return _wrapVisual(_stockPortrait(context));
  }

  Widget _stockPortrait(BuildContext context) {
    final info = vegetableImageFor(vegetable.id);
    final bg = info.transparentAsset
        ? TuinierColors.cardTintGreen
        : (info.greenBackground
            ? TuinierColors.cardTintGreen
            : TuinierColors.card);

    return _framed(
      background: bg,
      child: ClipRect(
        child: _stockImage(context, info),
      ),
    );
  }

  Widget _stockImage(BuildContext context, VegetableImageInfo info) {
    if (info.assetPath != null) {
      final dpr = MediaQuery.devicePixelRatioOf(context);
      final cachePx = (height * dpr).round().clamp(128, 1024);

      Widget image = Image.asset(
        info.assetPath!,
        fit: BoxFit.cover,
        width: width,
        height: height,
        cacheWidth: cachePx,
        cacheHeight: cachePx,
        filterQuality: FilterQuality.high,
        errorBuilder: (_, __, ___) => _emojiFallback(info),
      );

      if (info.thumbnailScale > 1.0) {
        image = Transform.scale(scale: info.thumbnailScale, child: image);
      }

      return image;
    }

    if (info.imageUrl != null) {
      return Image.network(
        info.imageUrl!,
        fit: BoxFit.cover,
        width: width,
        height: height,
        errorBuilder: (_, __, ___) => _emojiFallback(info),
      );
    }

    return _emojiFallback(info);
  }

  Widget _emojiFallback(VegetableImageInfo info) {
    return Center(
      child: Text(
        info.emoji,
        style: TextStyle(fontSize: height * 0.42),
      ),
    );
  }
}
