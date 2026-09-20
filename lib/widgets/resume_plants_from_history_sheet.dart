import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_scan_photo_store.dart';
import '../data/vegetable_image_info.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../theme/plant_setup_palette.dart';
import 'plant_setup_sheet_ui.dart';
import 'restore_moestuin_from_history.dart';
import 'vegetable_hero_image.dart';

/// Unieke sleutel per gearchiveerd profiel (zelfde gewas, ander archief-moment).
String historyPlantSelectionId(GardenPlantProfile profile) {
  final at = profile.archivedAt;
  if (at == null) return profile.vegetableId;
  return '${profile.vegetableId}:${at.millisecondsSinceEpoch}';
}

class HistoryResumePlantRow {
  const HistoryResumePlantRow({
    required this.vegetable,
    required this.profile,
    required this.alreadyInGarden,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final bool alreadyInGarden;

  String get selectionId => historyPlantSelectionId(profile);
}

/// Sheet: kies planten om te hervatten of hele moestuin in één keer.
Future<bool> showResumePlantsFromHistorySheet(
  BuildContext context, {
  required List<HistoryResumePlantRow> plants,
  required int year,
  required String moestuinName,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required GardenScanPrefsStore scanPrefs,
}) {
  if (plants.isEmpty) return Future.value(false);

  return showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    useRootNavigator: true,
    backgroundColor: Colors.transparent,
    builder: (sheetContext) {
      final height = MediaQuery.sizeOf(sheetContext).height * 0.78;
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
        ),
        child: SizedBox(
          height: height,
          child: _ResumePlantsSheet(
            plants: plants,
            year: year,
            moestuinName: moestuinName,
            gardenStore: gardenStore,
            profileStore: profileStore,
            repository: repository,
            scanPrefs: scanPrefs,
          ),
        ),
      );
    },
  ).then((value) => value ?? false);
}

class _ResumePlantsSheet extends StatefulWidget {
  const _ResumePlantsSheet({
    required this.plants,
    required this.year,
    required this.moestuinName,
    required this.gardenStore,
    required this.profileStore,
    required this.repository,
    required this.scanPrefs,
  });

  final List<HistoryResumePlantRow> plants;
  final int year;
  final String moestuinName;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final VegetableRepository repository;
  final GardenScanPrefsStore scanPrefs;

  @override
  State<_ResumePlantsSheet> createState() => _ResumePlantsSheetState();
}

class _ResumePlantsSheetState extends State<_ResumePlantsSheet> {
  final Set<String> _selected = {};

  List<HistoryResumePlantRow> get _selectable =>
      widget.plants.where((p) => !p.alreadyInGarden).toList();

  void _toggle(String id, bool? value) {
    setState(() {
      if (value == true) {
        _selected.add(id);
      } else {
        _selected.remove(id);
      }
    });
  }

  List<GardenPlantProfile> _profilesForSelection(Set<String> ids) {
    return widget.plants
        .where((p) => ids.contains(p.selectionId))
        .map((p) => p.profile)
        .toList();
  }

  Future<void> _resumeAll() async {
    final profiles = widget.plants.map((p) => p.profile).toList();
    final ok = await confirmAndCopyHistorySeasonToGarden(
      context,
      year: widget.year,
      archivedProfiles: profiles,
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
      confirmTitle: 'Hele moestuin hervatten?',
    );
    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
  }

  Future<void> _resumeSelected() async {
    if (_selected.isEmpty) return;
    final profiles = _profilesForSelection(_selected);
    final ok = await confirmAndCopyHistorySeasonToGarden(
      context,
      year: widget.year,
      archivedProfiles: profiles,
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    if (!mounted) return;
    if (ok) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);
    final sorted = List<HistoryResumePlantRow>.from(widget.plants)
      ..sort((a, b) => a.vegetable.nameNl.compareTo(b.vegetable.nameNl));
    final selectableCount = _selectable.length;
    final selectedCount = _selected.length;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        top: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: const PlantSetupSheetHeader(
                centered: true,
                title: 'Planten weer hervatten',
                subtitle: 'Vink aan wat je terug wilt in Mijn moestuin',
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: OutlinedButton.icon(
                onPressed: selectableCount == 0 ? null : _resumeAll,
                icon: const Icon(Icons.yard_outlined),
                label: const Text('Hele moestuin hervatten'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: p.activeIcon,
                  side: BorderSide(color: p.chipSelectedBackground),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                '${widget.moestuinName} · ${widget.year}',
                style: t.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 12),
                itemCount: sorted.length,
                separatorBuilder: (_, __) => const SizedBox(height: 2),
                itemBuilder: (context, index) {
                  final row = sorted[index];
                  return _ResumePlantCheckboxRow(
                    row: row,
                    selected: _selected.contains(row.selectionId),
                    onToggle: (value) => _toggle(row.selectionId, value),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: FilledButton(
                onPressed: selectedCount == 0 ? null : _resumeSelected,
                style: FilledButton.styleFrom(
                  backgroundColor: p.confirmButton,
                  foregroundColor: p.confirmButtonForeground,
                  disabledBackgroundColor:
                      p.confirmButton.withValues(alpha: 0.45),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: Text(
                  selectedCount == 0
                      ? 'Kies één of meer planten'
                      : selectedCount == 1
                          ? 'Hervat 1 plant'
                          : 'Hervat $selectedCount planten',
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ResumePlantCheckboxRow extends StatelessWidget {
  const _ResumePlantCheckboxRow({
    required this.row,
    required this.selected,
    required this.onToggle,
  });

  final HistoryResumePlantRow row;
  final bool selected;
  final ValueChanged<bool?> onToggle;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);
    final disabled = row.alreadyInGarden;
    final hasScanPhoto =
        PlantScanPhotoStore.exists(row.profile.lastScanPhotoPath);
    final listAsset = vegetableImageFor(row.vegetable.id).assetPath;
    final useAtlasList = !hasScanPhoto && listAsset != null;

    return Material(
      color: disabled
          ? cs.surfaceContainerLow.withValues(alpha: 0.65)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: disabled ? null : () => onToggle(!selected),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          child: Row(
            children: [
              Checkbox(
                value: disabled ? false : selected,
                onChanged: disabled ? null : onToggle,
                activeColor: p.activeIcon,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: ColoredBox(
                    color: useAtlasList
                        ? const Color(0xFF0A0A0A)
                        : Colors.transparent,
                    child: VegetableHeroImage(
                      vegetable: row.vegetable,
                      scanPhotoPath: row.profile.lastScanPhotoPath,
                      height: 52,
                      borderRadius: BorderRadius.circular(10),
                      useAtlasIllustration: useAtlasList,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      row.vegetable.nameNl,
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: disabled ? cs.onSurfaceVariant : cs.onSurface,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      disabled
                          ? 'Staat al in je moestuin'
                          : 'Fris seizoen, history blijft staan',
                      style: t.textTheme.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        height: 1.25,
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
