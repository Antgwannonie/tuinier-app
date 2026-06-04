import 'package:flutter/material.dart';

import '../data/crop_harvest_kind.dart';
import '../data/garden_plant_schedule.dart';
import '../data/underground_crop.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_scan_history.dart';
import 'harvest_confirm_dialog.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'plant_ai_data_sections.dart';
import 'plant_scan_timeline.dart';
import 'vegetable_thumbnail.dart';

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
              final scanCount = plantScanEntries(latest).length;

              return SafeArea(
                child: _PlantHistorySheetBody(
                  scrollController: scrollController,
                  vegetable: vegetable,
                  profile: latest,
                  profileStore: profileStore,
                  scanPrefs: scanPrefs,
                  gardenStore: gardenStore,
                  notPlanted: notPlanted,
                  scanCount: scanCount,
                  onScan: onScan,
                  onProbeHarvestScan: onProbeHarvestScan,
                  onMarkPlanted: onMarkPlanted,
                  onHarvestSynced: onHarvestSynced,
                  initialTabIndex: initialTabIndex,
                  sheetContext: ctx,
                ),
              );
            },
          );
        },
      );
    },
  );
}

class _PlantHistorySheetBody extends StatefulWidget {
  const _PlantHistorySheetBody({
    required this.scrollController,
    required this.vegetable,
    required this.profile,
    required this.profileStore,
    required this.scanPrefs,
    required this.gardenStore,
    required this.notPlanted,
    required this.scanCount,
    required this.sheetContext,
    this.onScan,
    this.onProbeHarvestScan,
    this.onMarkPlanted,
    this.onHarvestSynced,
    this.initialTabIndex = 0,
  });

  final ScrollController scrollController;
  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final MyGardenStore? gardenStore;
  final bool notPlanted;
  final int scanCount;
  final BuildContext sheetContext;
  final VoidCallback? onScan;
  final VoidCallback? onProbeHarvestScan;
  final Future<void> Function()? onMarkPlanted;
  final VoidCallback? onHarvestSynced;
  final int initialTabIndex;

  @override
  State<_PlantHistorySheetBody> createState() => _PlantHistorySheetBodyState();
}

class _PlantHistorySheetBodyState extends State<_PlantHistorySheetBody> {
  late int _tabIndex;

  @override
  void initState() {
    super.initState();
    _tabIndex = widget.initialTabIndex.clamp(0, 1);
  }

  void _openScan() {
    Navigator.pop(widget.sheetContext);
    widget.onScan?.call();
  }

  bool get _showHarvestAction {
    final inGarden = widget.gardenStore?.contains(widget.vegetable.id) ?? false;
    return inGarden &&
        showHarvestSection(widget.profile, vegetable: widget.vegetable);
  }

  bool get _undergroundConfirmed => isUndergroundHarvestConfirmed(
        widget.profile,
        widget.vegetable,
      );

  Future<void> _finishCrop(CropHarvestUiCopy copy) async {
    await widget.profileStore.setHarvestProgress(widget.vegetable.id, 100);
    if (widget.gardenStore?.contains(widget.vegetable.id) == true) {
      await widget.profileStore.archiveProfile(widget.vegetable.id);
      await widget.gardenStore!.remove(widget.vegetable.id);
    }
    widget.onHarvestSynced?.call();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(copy.snackBarDone)),
    );
    if (widget.sheetContext.mounted) Navigator.pop(widget.sheetContext);
  }

  Future<void> _onFoodHarvestPressed() async {
    final copy = harvestUiCopyFor(
      widget.vegetable,
      plantNameNl: widget.vegetable.nameNl,
      forSeasonFinish: false,
    );
    final ok = await showHarvestConfirmDialog(
      context,
      copy: copy,
      plantNameNl: widget.vegetable.nameNl,
      isUnderground: isUndergroundCrop(widget.vegetable),
      harvestConfirmedByProbe: _undergroundConfirmed,
    );
    if (ok != true || !mounted) return;
    await _finishCrop(copy);
  }

  Future<void> _onSeasonFinishPressed() async {
    final copy = harvestUiCopyFor(
      widget.vegetable,
      plantNameNl: widget.vegetable.nameNl,
      forSeasonFinish: true,
    );
    final ok = await showHarvestConfirmDialog(
      context,
      copy: copy,
      plantNameNl: widget.vegetable.nameNl,
    );
    if (ok != true || !mounted) return;
    await _finishCrop(copy);
  }

  Future<void> _onHarvestPressed() async {
    if (isEdibleMoestuinBloomCrop(widget.vegetable)) {
      await _onFoodHarvestPressed();
      return;
    }
    final copy = harvestUiCopyFor(
      widget.vegetable,
      plantNameNl: widget.vegetable.nameNl,
    );
    final ok = await showHarvestConfirmDialog(
      context,
      copy: copy,
      plantNameNl: widget.vegetable.nameNl,
      isUnderground: isUndergroundCrop(widget.vegetable),
      harvestConfirmedByProbe: _undergroundConfirmed,
    );
    if (ok != true || !mounted) return;
    await _finishCrop(copy);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            VegetableThumbnail(
              vegetable: widget.vegetable,
              size: 52,
              borderRadius: 14,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.vegetable.nameNl,
                    style: t.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    widget.scanCount == 0
                        ? 'Nog geen scan-geschiedenis'
                        : widget.scanCount == 1
                            ? '1 opgeslagen scan'
                            : '${widget.scanCount} opgeslagen scans',
                    style: t.textTheme.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (widget.notPlanted && widget.onMarkPlanted != null) ...[
          const SizedBox(height: 14),
          FilledButton.tonalIcon(
            onPressed: () async {
              await widget.onMarkPlanted!();
              if (widget.sheetContext.mounted) {
                Navigator.pop(widget.sheetContext);
              }
            },
            icon: const Icon(Icons.yard_outlined),
            label: const Text('Markeer als geplant'),
          ),
        ],
        if (_showHarvestAction) ...[
          const SizedBox(height: 16),
          _HarvestReadyCard(
            vegetable: widget.vegetable,
            profile: widget.profile,
            onHarvested: _onHarvestPressed,
            onFoodHarvested: _onFoodHarvestPressed,
            onSeasonFinish: _onSeasonFinishPressed,
            onProbeScan: widget.onProbeHarvestScan,
          ),
        ],
        const SizedBox(height: 16),
        SegmentedButton<int>(
          showSelectedIcon: false,
          segments: [
            ButtonSegment(
              value: 0,
              label: const Text('Overzicht'),
              icon: Icon(
                Icons.dashboard_outlined,
                size: 18,
                color: _tabIndex == 0 ? cs.onSecondaryContainer : null,
              ),
            ),
            ButtonSegment(
              value: 1,
              label: Text(
                widget.scanCount > 0 ? 'Scans (${widget.scanCount})' : 'Scans',
              ),
              icon: Icon(
                Icons.history,
                size: 18,
                color: _tabIndex == 1 ? cs.onSecondaryContainer : null,
              ),
            ),
          ],
          selected: {_tabIndex},
          onSelectionChanged: (s) => setState(() => _tabIndex = s.first),
        ),
        const SizedBox(height: 16),
        if (_tabIndex == 0)
          PlantAiDataSections(
            profile: widget.profile,
            profileStore: widget.profileStore,
            daysUntilFirstPhoto: widget.scanPrefs.daysUntilFirstPhoto,
            weeklyScanIntervalDays: widget.scanPrefs.weeklyScanIntervalDays,
            onScan: widget.onScan != null ? _openScan : null,
            includeScanHistory: false,
          )
        else
          _ScanHistoryTab(
            profile: widget.profile,
            profileStore: widget.profileStore,
            onScan: widget.onScan != null ? _openScan : null,
          ),
      ],
    );
  }
}

class _ScanHistoryTab extends StatelessWidget {
  const _ScanHistoryTab({
    required this.profile,
    required this.profileStore,
    this.onScan,
  });

  final GardenPlantProfile profile;
  final GardenProfileStore profileStore;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final scans = plantScanEntries(profile);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: scans.isEmpty
          ? PlantScanHistoryEmpty(onScan: onScan)
          : PlantScanTimeline(
              key: ValueKey('scan-tab-${profile.vegetableId}'),
              profileStore: profileStore,
              profile: profile,
            ),
    );
  }
}

class _HarvestReadyCard extends StatelessWidget {
  const _HarvestReadyCard({
    required this.vegetable,
    required this.profile,
    required this.onHarvested,
    required this.onFoodHarvested,
    required this.onSeasonFinish,
    this.onProbeScan,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final VoidCallback onHarvested;
  final VoidCallback onFoodHarvested;
  final VoidCallback onSeasonFinish;
  final VoidCallback? onProbeScan;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context).textTheme;
    final underground = isUndergroundCrop(vegetable);
    final edibleBloom = isEdibleMoestuinBloomCrop(vegetable);
    final ornamentalOnly = isOrnamentalOnlyMoestuinCrop(vegetable);
    final dualUi = edibleBloom
        ? edibleBloomHarvestUiFor(vegetable, plantNameNl: vegetable.nameNl)
        : null;
    final confirmed = isUndergroundHarvestConfirmed(profile, vegetable);
    final ui = harvestUiCopyFor(vegetable, plantNameNl: vegetable.nameNl);
    final hint = underground
        ? undergroundHarvestHint(profile)
        : (edibleBloom || ornamentalOnly)
            ? bloomHintFromProfile(profile)
            : (profile.lastAnalysis?.harvestWindowLabel ??
                profile.lastAnalysis?.phaseLabel ??
                '');
    final sectionTitle = dualUi?.sectionTitle ?? ui.sectionTitle;
    final hintText = hint.trim().isNotEmpty
        ? hint
        : (dualUi?.sectionHintFallback ?? ui.sectionHintFallback);
    final icon = (edibleBloom || ornamentalOnly)
        ? Icons.local_florist_outlined
        : Icons.shopping_basket_outlined;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.tertiaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: cs.tertiary.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, color: cs.tertiary, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  underground && !confirmed
                      ? 'Mogelijk oogstbaar'
                      : sectionTitle,
                  style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          if (hintText.trim().isNotEmpty) ...[
            const SizedBox(height: 6),
            Text(
              hintText,
              style: t.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ],
          if (dualUi != null) ...[
            const SizedBox(height: 8),
            Text(
              dualUi.edibleChoiceNote,
              style: t.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          if (underground && !confirmed) ...[
            const SizedBox(height: 8),
            Text(
              'Trek eerst één plant uit de grond om te controleren. '
              'Maak daarna een foto van die proefplant — dan kan de AI '
              'bevestigen of je kunt oogsten.',
              style: t.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            if (onProbeScan != null) ...[
              const SizedBox(height: 10),
              FilledButton.tonalIcon(
                onPressed: onProbeScan,
                icon: const Icon(Icons.camera_alt_outlined, size: 20),
                label: const Text('Scan proefoogst'),
              ),
            ],
          ],
          if (underground && confirmed) ...[
            const SizedBox(height: 6),
            Text(
              'Proefoogst bevestigt dat oogsten kan.',
              style: t.labelMedium?.copyWith(
                color: cs.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
          const SizedBox(height: 12),
          if (dualUi != null) ...[
            FilledButton.icon(
              onPressed: onFoodHarvested,
              icon: const Icon(Icons.restaurant_outlined, size: 20),
              label: Text(dualUi.foodHarvest.buttonLabel),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onSeasonFinish,
              icon: const Icon(Icons.eco_outlined, size: 20),
              label: Text(dualUi.seasonFinish.buttonLabel),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ] else
            FilledButton.icon(
              onPressed: onHarvested,
              icon: Icon(
                ornamentalOnly ? Icons.eco_outlined : Icons.check_rounded,
                size: 20,
              ),
              label: Text(ui.buttonLabel),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
        ],
      ),
    );
  }
}
