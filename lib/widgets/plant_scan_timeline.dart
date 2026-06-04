import 'dart:io';

import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../data/garden_profile_store.dart';
import '../data/plant_scan_history.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import 'plant_scan_result_card.dart';
import 'scan_photo_viewer.dart';

int _scanKey(PlantScanEntry entry) =>
    entry.analysis.scannedAt.millisecondsSinceEpoch;

/// Scan-geschiedenis — chronologische tijdlijn met uitklapbare details.
class PlantScanTimeline extends StatefulWidget {
  const PlantScanTimeline({
    super.key,
    required this.profileStore,
    required this.profile,
  });

  final GardenProfileStore profileStore;
  final GardenPlantProfile profile;

  @override
  State<PlantScanTimeline> createState() => _PlantScanTimelineState();
}

class _PlantScanTimelineState extends State<PlantScanTimeline> {
  final Set<int> _openScanKeys = {};

  @override
  void initState() {
    super.initState();
    _openLatestIfNeeded(plantScanEntries(widget.profile));
  }

  @override
  void didUpdateWidget(PlantScanTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profile.vegetableId != widget.profile.vegetableId) {
      _openScanKeys.clear();
      _openLatestIfNeeded(plantScanEntries(_profile));
    }
  }

  GardenPlantProfile get _profile =>
      widget.profileStore.profileFor(widget.profile.vegetableId) ??
      widget.profile;

  void _openLatestIfNeeded(List<PlantScanEntry> scans) {
    if (_openScanKeys.isEmpty && scans.isNotEmpty) {
      _openScanKeys.add(_scanKey(scans.last));
    }
  }

  void _syncOpenKeys(List<PlantScanEntry> scans) {
    final valid = scans.map(_scanKey).toSet();
    _openScanKeys.removeWhere((k) => !valid.contains(k));
  }

  void _toggleScan(PlantScanEntry entry) {
    final key = _scanKey(entry);
    setState(() {
      if (_openScanKeys.contains(key)) {
        _openScanKeys.remove(key);
      } else {
        _openScanKeys.add(key);
      }
    });
  }

  Future<void> _confirmDelete(PlantScanEntry entry) async {
    final date = formatDateShortNl(entry.analysis.scannedAt);
    final ok = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      useRootNavigator: true,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan verwijderen?'),
        content: Text(
          'Weet je zeker dat je de scan van $date wilt verwijderen? '
          'De foto en alle gegevens van deze scan worden gewist.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuleren'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Ja, verwijderen'),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) return;

    final key = _scanKey(entry);
    final updated = removeScanEntry(_profile, entry.analysis);
    await widget.profileStore.saveProfile(updated);
    if (!mounted) return;

    final scans = plantScanEntries(updated);
    setState(() {
      _openScanKeys.remove(key);
      _syncOpenKeys(scans);
      if (_openScanKeys.isEmpty && scans.isNotEmpty) {
        _openScanKeys.add(_scanKey(scans.last));
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final scans = plantScanEntries(profile);
    if (scans.isEmpty) return const SizedBox.shrink();

    _syncOpenKeys(scans);

    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var displayIndex = 0; displayIndex < scans.length; displayIndex++) ...[
          if (displayIndex > 0) const SizedBox(height: 10),
          _ScanTimelineTile(
            key: ValueKey(_scanKey(scans[scans.length - 1 - displayIndex])),
            entry: scans[scans.length - 1 - displayIndex],
            displayIndex: displayIndex,
            chronIndex: scans.length - 1 - displayIndex,
            isOpen: _openScanKeys.contains(
              _scanKey(scans[scans.length - 1 - displayIndex]),
            ),
            onToggle: () => _toggleScan(
              scans[scans.length - 1 - displayIndex],
            ),
            onDelete: () => _confirmDelete(
              scans[scans.length - 1 - displayIndex],
            ),
          ),
        ],
        const SizedBox(height: 4),
        Text(
          'Oudste scan onderaan · tik op een regel voor details',
          textAlign: TextAlign.center,
          style: t.textTheme.labelSmall?.copyWith(
            color: cs.onSurfaceVariant.withValues(alpha: 0.85),
          ),
        ),
      ],
    );
  }
}

class _ScanTimelineTile extends StatelessWidget {
  const _ScanTimelineTile({
    super.key,
    required this.entry,
    required this.displayIndex,
    required this.chronIndex,
    required this.isOpen,
    required this.onToggle,
    required this.onDelete,
  });

  final PlantScanEntry entry;
  final int displayIndex;
  final int chronIndex;
  final bool isOpen;
  final VoidCallback onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final a = entry.analysis;
    final isLatest = displayIndex == 0;
    final isFirst = chronIndex == 0;
    final date = formatDateShortNl(a.scannedAt);
    final title = isLatest
        ? 'Laatste scan'
        : isFirst
            ? 'Eerste scan'
            : 'Scan ${chronIndex + 1}';

    return Material(
      color: isOpen ? cs.surface : cs.surfaceContainerLow,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isLatest
              ? cs.primary.withValues(alpha: 0.35)
              : cs.outlineVariant.withValues(alpha: 0.4),
          width: isLatest ? 1.5 : 1,
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 8, 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ScanPhotoThumb(path: entry.photoPath, size: 56),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: t.textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            if (isLatest)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: cs.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Nieuwste',
                                  style: t.textTheme.labelSmall?.copyWith(
                                    color: cs.onPrimaryContainer,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          date,
                          style: t.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          a.phaseLabel,
                          maxLines: isOpen ? null : 2,
                          overflow: TextOverflow.ellipsis,
                          style: t.textTheme.bodySmall?.copyWith(
                            color: cs.onSurface,
                            fontWeight: FontWeight.w500,
                            height: 1.3,
                          ),
                        ),
                        if (!isOpen && a.healthScore != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Gezondheid ${a.healthScore}/100',
                            style: t.textTheme.labelSmall?.copyWith(
                              color: cs.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Column(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, size: 20),
                        tooltip: 'Scan verwijderen',
                        visualDensity: VisualDensity.compact,
                        onPressed: onDelete,
                      ),
                      Icon(
                        isOpen ? Icons.expand_less : Icons.expand_more,
                        color: cs.onSurfaceVariant,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (isOpen)
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 0, 12, 14),
              child: PlantScanResultCard(analysis: a),
            ),
        ],
      ),
    );
  }
}

class _ScanPhotoThumb extends StatelessWidget {
  const _ScanPhotoThumb({required this.path, this.size = 48});

  final String? path;
  final double size;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    if (path != null && File(path!).existsSync()) {
      return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => showScanPhotoViewer(context, path!),
          borderRadius: BorderRadius.circular(12),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(path!),
              width: size,
              height: size,
              fit: BoxFit.cover,
            ),
          ),
        ),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: cs.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Icon(
        Icons.photo_camera_outlined,
        color: cs.outline,
        size: size * 0.4,
      ),
    );
  }
}

/// Lege staat voor het tabblad Scans.
class PlantScanHistoryEmpty extends StatelessWidget {
  const PlantScanHistoryEmpty({
    super.key,
    this.onScan,
  });

  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Column(
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 48,
            color: cs.primary.withValues(alpha: 0.7),
          ),
          const SizedBox(height: 12),
          Text(
            'Nog geen scans',
            style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 6),
          Text(
            'Maak een foto om je plant te volgen. '
            'Elke scan komt hier terug met fase, gezondheid en advies.',
            textAlign: TextAlign.center,
            style: t.textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          if (onScan != null) ...[
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.photo_camera_outlined, size: 20),
              label: const Text('Eerste scan maken'),
            ),
          ],
        ],
      ),
    );
  }
}
