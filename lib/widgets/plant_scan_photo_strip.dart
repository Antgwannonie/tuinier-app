import 'dart:io';

import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../data/plant_scan_history.dart';
import '../models/garden_plant_profile.dart';

/// Horizontale rij scanfoto's om groei te vergelijken.
class PlantScanPhotoStrip extends StatelessWidget {
  const PlantScanPhotoStrip({
    super.key,
    required this.profile,
  });

  final GardenPlantProfile profile;

  @override
  Widget build(BuildContext context) {
    final scans = plantScanEntries(profile)
        .where((e) => e.photoPath != null)
        .toList();
    if (scans.isEmpty) return const SizedBox.shrink();
    if (scans.length == 1) return const SizedBox.shrink();

    final t = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Foto\'s vergelijken',
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 6),
        SizedBox(
          height: 88,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: scans.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final entry = scans[index];
              final isLatest = index == scans.length - 1;
              return _ScanThumb(
                path: entry.photoPath!,
                label: formatDateShortNl(entry.analysis.scannedAt),
                phaseLabel: entry.analysis.phaseLabel,
                isLatest: isLatest,
              );
            },
          ),
        ),
      ],
    );
  }
}

class _ScanThumb extends StatelessWidget {
  const _ScanThumb({
    required this.path,
    required this.label,
    this.phaseLabel,
    required this.isLatest,
  });

  final String path;
  final String label;
  final String? phaseLabel;
  final bool isLatest;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = isLatest ? cs.primary : cs.outlineVariant;

    return SizedBox(
      width: 72,
      child: Column(
        children: [
          Expanded(
            child: Material(
              elevation: isLatest ? 2 : 0,
              borderRadius: BorderRadius.circular(10),
              clipBehavior: Clip.antiAlias,
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(
                    color: borderColor,
                    width: isLatest ? 2 : 1,
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Image.file(
                  File(path),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  fontWeight: isLatest ? FontWeight.w700 : FontWeight.w500,
                  color: isLatest ? cs.primary : cs.onSurfaceVariant,
                ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (phaseLabel != null && phaseLabel!.isNotEmpty)
            Text(
              phaseLabel!,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontSize: 10,
                    color: cs.onSurfaceVariant,
                  ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
