import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../data/garden_profile_store.dart';
import '../data/plant_scan_history.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import 'garden_warning_style.dart';
import 'plant_scan_timeline.dart';

/// Jouw plant — compact overzicht met duidelijke actie.
class PlantAiDataSections extends StatelessWidget {
  const PlantAiDataSections({
    super.key,
    required this.profile,
    required this.profileStore,
    required this.daysUntilFirstPhoto,
    required this.weeklyScanIntervalDays,
    this.onScan,
    this.includeScanHistory = true,
  });

  final GardenPlantProfile profile;
  final GardenProfileStore profileStore;
  final int daysUntilFirstPhoto;
  final int weeklyScanIntervalDays;
  final VoidCallback? onScan;
  final bool includeScanHistory;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final analysis = profile.lastAnalysis;
    final needsPhoto = profile.isPlanted &&
        analysis == null &&
        needsFirstPhoto(
          profile,
          daysUntilFirstPhoto: daysUntilFirstPhoto,
        );
    final awaitingFirst = profile.isPlanted && awaitingFirstPhotoScan(profile);

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
          Row(
            children: [
              Icon(Icons.eco_outlined, color: cs.primary, size: 22),
              const SizedBox(width: 8),
              Text(
                'Status',
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _StatusChip(
                  icon: Icons.yard_outlined,
                  label: profile.isPlanted
                      ? profilePlantedDateLabel(profile)
                      : 'Nog niet geplant',
                  active: profile.isPlanted,
                ),
                _StatusChip(
                  icon: Icons.photo_camera_outlined,
                  label: analysis != null
                      ? 'Gescand'
                      : (awaitingFirst
                          ? kFirstScanShortLabel
                          : 'Nog geen foto'),
                  active: analysis != null,
                  urgent: needsPhoto,
                ),
                if (profile.isPlanted &&
                    needsWeeklyScan(profile) &&
                    analysis != null)
                  _StatusChip(
                    icon: Icons.photo_camera_outlined,
                    label: 'Nieuwe scan',
                    active: false,
                    urgent: true,
                  ),
                if (profile.predictedHarvestAt != null)
                  _StatusChip(
                    icon: Icons.shopping_basket_outlined,
                    label: 'Oogst ${formatDateShortNl(profile.predictedHarvestAt!)}',
                    active: true,
                  )
                else if (analysis?.daysUntilHarvest != null)
                  _StatusChip(
                    icon: Icons.schedule,
                    label: analysis!.phase == PlantAiPhase.ripe
                        ? 'Oogst nu'
                        : 'Oogst ±${analysis.daysUntilHarvest}d',
                    active: false,
                    urgent: analysis.daysUntilHarvest! <= 7,
                  ),
              ],
            ),
            if (!profile.isPlanted) ...[
              const SizedBox(height: 12),
              Text(
                'Staat hij in de grond? Tik op het plant-icoon op de '
                'plantkaart (midden).',
                style: t.textTheme.bodyMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ] else if (onScan != null) ...[
              const SizedBox(height: 14),
              if (analysis == null) ...[
                Text(
                  kFirstScanMotivationMessage,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Leg je plek in de grond vast — ook zonder zichtbare kiem.',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),
              ],
              FilledButton.icon(
                onPressed: onScan,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(
                  analysis == null
                      ? 'Eerste foto scannen'
                      : needsWeeklyScan(profile)
                          ? 'Nieuwe scan maken'
                          : 'Foto bijwerken',
                ),
              ),
            ],
            if (includeScanHistory &&
                plantScanEntries(profile).isNotEmpty) ...[
              const SizedBox(height: 14),
              PlantScanTimeline(
                key: ValueKey('scan-timeline-${profile.vegetableId}'),
                profileStore: profileStore,
                profile: profile,
              ),
            ] else if (analysis != null &&
                (!includeScanHistory ||
                    plantScanEntries(profile).isEmpty)) ...[
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),
              _AnalysisSummary(analysis: analysis),
            ],
            if (profile.nextScanDue != null) ...[
              const SizedBox(height: 8),
              _DetailRow(
                label: 'Volgende scan',
                value: needsWeeklyScan(profile)
                    ? 'Nu (elke $weeklyScanIntervalDays dagen)'
                    : formatDateShortNl(profile.nextScanDue!),
              ),
            ],
            if (!includeScanHistory &&
                plantScanEntries(profile).isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Bekijk al je scans op het tabblad Scans.',
                style: t.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
            ],
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text(
                '${profile.location.label} · ${profile.sunLevel.label}',
                style: t.textTheme.labelMedium?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
    );
  }

}

class _StatusChip extends StatelessWidget {
  const _StatusChip({
    required this.icon,
    required this.label,
    required this.active,
    this.urgent = false,
  });

  final IconData icon;
  final String label;
  final bool active;
  final bool urgent;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final bg = urgent
        ? GardenWarningStyle.background(cs)
        : active
            ? cs.primaryContainer
            : cs.surfaceContainerHighest;
    final fg = urgent
        ? GardenWarningStyle.foreground(cs)
        : active
            ? cs.onPrimaryContainer
            : cs.onSurfaceVariant;

    return Container(
      constraints: const BoxConstraints(maxWidth: double.infinity),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: fg,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnalysisSummary extends StatelessWidget {
  const _AnalysisSummary({required this.analysis});

  final PlantAiAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (analysis.healthScore != null) ...[
          Text(
            'Gezondheid ${analysis.healthScore}/100 · '
            'Groei ${analysis.insight?.growthScore ?? '—'}/100',
            style: t.textTheme.labelMedium?.copyWith(
              color: t.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(
          analysis.phaseLabel,
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (analysis.daysUntilHarvest != null)
          Text(
            analysis.phase == PlantAiPhase.ripe
                ? 'Klaar om te oogsten'
                : 'Oogst over ±${analysis.daysUntilHarvest} dagen',
            style: t.textTheme.bodyMedium,
          ),
        Text(
          analysis.harvestWindowLabel,
          style: t.textTheme.labelMedium?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
        if (analysis.displaySummary.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(analysis.displaySummary, style: t.textTheme.bodySmall),
        ],
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: t.textTheme.labelMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: t.textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}
