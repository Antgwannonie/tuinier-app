import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';

/// AI-data in kopjes (moestuin + detail).
class PlantAiDataSections extends StatelessWidget {
  const PlantAiDataSections({
    super.key,
    required this.profile,
    required this.daysUntilFirstPhoto,
    required this.weeklyScanIntervalDays,
    this.onScan,
  });

  final GardenPlantProfile profile;
  final int daysUntilFirstPhoto;
  final int weeklyScanIntervalDays;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final analysis = profile.lastAnalysis;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _SectionCard(
          title: 'Status',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                profile.isPlanted
                    ? 'In de grond sinds ${profile.plantedAt.day}-${profile.plantedAt.month}-${profile.plantedAt.year}'
                    : 'Nog niet geplant — wacht op jouw bevestiging',
                style: t.textTheme.bodyLarge,
              ),
              Text(
                '${profile.location.label} · ${profile.sunLevel.label}',
                style: t.textTheme.labelMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        if (!profile.isPlanted)
          _SectionCard(
            title: 'Planning',
            child: Text(
              'Zodra het zaai-/plantmoment is, zie je dit op Start. '
              'Vink “geplant” aan als het in de grond staat.',
              style: t.textTheme.bodyMedium,
            ),
          )
        else if (analysis == null) ...[
          _SectionCard(
            title: 'Eerste foto',
            child: Text(
              needsFirstPhoto(
                profile,
                daysUntilFirstPhoto: daysUntilFirstPhoto,
              )
                  ? 'Maak nu je eerste scan — de AI vult daarna je kalender.'
                  : 'Eerste foto rond ${firstPhotoDueDate(profile, daysUntilFirstPhoto: daysUntilFirstPhoto).day}-'
                      '${firstPhotoDueDate(profile, daysUntilFirstPhoto: daysUntilFirstPhoto).month} '
                      '(±$daysUntilFirstPhoto dagen na planten).',
              style: t.textTheme.bodyMedium,
            ),
          ),
        ] else ...[
          _SectionCard(
            title: 'Laatste scan',
            subtitle: _fmt(analysis.scannedAt),
            child: _AnalysisBody(analysis: analysis),
          ),
          if (profile.predictedHarvestAt != null)
            _SectionCard(
              title: 'Oogst in kalender',
              child: Text(
                'Verwacht op ${profile.predictedHarvestAt!.day}-${profile.predictedHarvestAt!.month}-${profile.predictedHarvestAt!.year}',
                style: t.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          if (profile.nextScanDue != null)
            _SectionCard(
              title: 'Volgende scan',
              child: Text(
                needsWeeklyScan(profile)
                    ? 'Nu bijwerken met een nieuwe foto (elke $weeklyScanIntervalDays dagen).'
                    : 'Rond ${profile.nextScanDue!.day}-${profile.nextScanDue!.month}-${profile.nextScanDue!.year}',
                style: t.textTheme.bodyMedium,
              ),
            ),
          if (profile.scanHistory.length > 1)
            _SectionCard(
              title: 'Scan-geschiedenis',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: profile.scanHistory.reversed.take(5).map((s) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '${_fmt(s.scannedAt)} — ${s.phaseLabel} '
                      '(${s.confidencePercent}%)',
                      style: t.textTheme.bodySmall,
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
        if (onScan != null) ...[
          const SizedBox(height: 8),
          FilledButton.tonalIcon(
            onPressed: onScan,
            icon: const Icon(Icons.photo_camera_outlined),
            label: Text(analysis == null ? 'Eerste foto scannen' : 'Nieuwe scan'),
          ),
        ],
      ],
    );
  }

  String _fmt(DateTime d) =>
      '${d.day}-${d.month}-${d.year} ${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.child,
    this.subtitle,
  });

  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: t.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: t.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  style: t.textTheme.labelSmall?.copyWith(
                    color: t.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
              const SizedBox(height: 8),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalysisBody extends StatelessWidget {
  const _AnalysisBody({required this.analysis});

  final PlantAiAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          analysis.phaseLabel,
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        if (analysis.daysUntilHarvest != null)
          Text(
            analysis.phase == PlantAiPhase.ripe
                ? 'Nu oogsten'
                : 'Oogst over ±${analysis.daysUntilHarvest} dagen',
          ),
        Text('Venster: ${analysis.harvestWindowLabel}'),
        Text('Betrouwbaarheid: ${analysis.confidencePercent}%'),
        const SizedBox(height: 6),
        Text(analysis.advice),
      ],
    );
  }
}
