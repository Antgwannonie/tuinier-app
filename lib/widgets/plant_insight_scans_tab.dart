import 'dart:io';

import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../data/moestuin_card_metrics.dart';
import '../data/plant_scan_history.dart';
import '../data/scan_report_builder.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import '../screens/scan_result_screen.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';

/// Scans-tab: tijdlijn met foto, datum, gezondheid, oogstkans en fase.
class PlantInsightScansTab extends StatelessWidget {
  const PlantInsightScansTab({
    super.key,
    required this.vegetable,
    required this.profile,
    this.onScan,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    final scans = plantScanEntries(profile);
    if (scans.isEmpty) {
      return _EmptyScans(onScan: onScan);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = scans.length - 1; i >= 0; i--) ...[
          if (i < scans.length - 1) const SizedBox(height: 10),
          _ScanHistoryCard(
            entry: scans[i],
            vegetable: vegetable,
            previous: i > 0 ? scans[i - 1].analysis : null,
            isLatest: i == scans.length - 1,
            onTap: () => _openScan(
              context,
              scans[i].analysis,
              i > 0 ? scans[i - 1].analysis : null,
            ),
          ),
        ],
      ],
    );
  }

  void _openScan(
    BuildContext context,
    PlantAiAnalysis analysis,
    PlantAiAnalysis? previous,
  ) {
    if (!scanResultSupportsFullPage(analysis)) return;
    openScanResultScreen(
      context,
      analysis: analysis,
      vegetable: vegetable,
      previousAnalysis: previous,
      onNewScan: onScan,
    );
  }
}

class _EmptyScans extends StatelessWidget {
  const _EmptyScans({this.onScan});

  final VoidCallback? onScan;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: TuinierDecorations.card(radius: 16),
      child: Column(
        children: [
          const Icon(Icons.photo_library_outlined,
              size: 40, color: TuinierColors.iconMuted),
          const SizedBox(height: 12),
          Text(
            'Nog geen scans',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Je scan-geschiedenis verschijnt hier zodra je een foto hebt gemaakt.',
            textAlign: TextAlign.center,
            style: TextStyle(color: TuinierColors.textSecondary, height: 1.4),
          ),
          if (onScan != null) ...[
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: onScan,
              icon: const Icon(Icons.photo_camera_outlined),
              label: const Text('Scan maken'),
            ),
          ],
        ],
      ),
    );
  }
}

class _ScanHistoryCard extends StatelessWidget {
  const _ScanHistoryCard({
    required this.entry,
    required this.vegetable,
    required this.isLatest,
    required this.onTap,
    this.previous,
  });

  final PlantScanEntry entry;
  final Vegetable vegetable;
  final PlantAiAnalysis? previous;
  final bool isLatest;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final analysis = entry.analysis;
    final layout = analysis.hasInsight && analysis.insight != null
        ? buildScanReportLayout(
            analysis: analysis,
            vegetable: vegetable,
            previousAnalysis: previous,
          )
        : null;
    final health = layout?.scoreCards.isNotEmpty == true
        ? layout!.scoreCards.first.percent
        : moestuinPlantHealthPercent(
            analysis: analysis,
            vegetable: vegetable,
          );
    final harvest = layout != null && layout.scoreCards.length > 1
        ? layout.scoreCards[1].percent
        : null;

    return Material(
      color: TuinierColors.card,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isLatest
                  ? TuinierColors.primary.withValues(alpha: 0.4)
                  : TuinierColors.border,
            ),
            boxShadow: isLatest ? TuinierDecorations.cardShadow : null,
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: entry.photoPath != null &&
                          File(entry.photoPath!).existsSync()
                      ? Image.file(File(entry.photoPath!), fit: BoxFit.cover)
                      : Container(
                          color: TuinierColors.searchBar,
                          child: const Icon(Icons.eco_outlined,
                              color: TuinierColors.iconMuted),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          formatDateShortNl(analysis.scannedAt),
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                          ),
                        ),
                        if (isLatest) ...[
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: TuinierColors.scanHover,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text(
                              'Laatste',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: TuinierColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Gezondheid $health%'
                      '${harvest != null ? ' · Oogstkans $harvest%' : ''}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: TuinierColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      analysis.phaseLabel,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: TuinierColors.primary,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: TuinierColors.iconMuted, size: 22),
            ],
          ),
        ),
      ),
    );
  }
}
