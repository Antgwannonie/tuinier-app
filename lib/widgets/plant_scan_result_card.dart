import 'package:flutter/material.dart';

import '../data/plant_scan_persist_policy.dart';
import '../models/plant_ai_analysis.dart';
import 'garden_warning_style.dart';
import 'plant_ai_insight_sections.dart';

/// Volledig scanresultaat — zelfde inhoud als op het Plant scan-scherm.
class PlantScanResultCard extends StatelessWidget {
  const PlantScanResultCard({
    super.key,
    required this.analysis,
    this.savedToHistory = true,
    this.ornamentalBloomOnly = false,
    this.edibleBloomDual = false,
  });

  final PlantAiAnalysis analysis;

  /// False wanneer de scan wel is getoond maar niet in de geschiedenis staat.
  final bool savedToHistory;

  /// Sier-moestuinbloem: geen oogst-taal in het kaartje.
  final bool ornamentalBloomOnly;

  /// Eetbare moestuinbloem: bloei + optioneel oogsten om te eten.
  final bool edibleBloomDual;

  bool _isLowPriorityInfo(String text) {
    final t = text.toLowerCase();
    return t.contains('zelfde foto als vorige scan') ||
        t.contains('zelfde plant en fase als vorige scan') ||
        t.contains('vergelijkbaar met vorige scan');
  }

  String _trendLabel(PlantHealthTrend trend) {
    switch (trend) {
      case PlantHealthTrend.improved:
        return 'Gezondheid: verbeterd';
      case PlantHealthTrend.stable:
        return 'Gezondheid: gelijk gebleven';
      case PlantHealthTrend.worse:
        return 'Gezondheid: achteruitgegaan';
      case PlantHealthTrend.unknown:
        return 'Gezondheid: nog onduidelijk';
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: cs.primaryContainer.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!savedToHistory) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GardenWarningStyle.infoBackground(cs),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GardenWarningStyle.infoIcon(cs).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20,
                      color: GardenWarningStyle.infoIcon(cs),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        scanNotPersistedMessage(analysis) ??
                            'Deze scan is niet opgeslagen in je geschiedenis.',
                        style: t.textTheme.bodySmall?.copyWith(
                          color: GardenWarningStyle.infoForeground(cs),
                          fontWeight: FontWeight.w600,
                          height: 1.35,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            Row(
              children: [
                Text(
                  'Resultaat',
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (analysis.matchedPrevious) ...[
                  const SizedBox(width: 8),
                  Chip(
                    label: const Text('Zelfde als vorige scan'),
                    visualDensity: VisualDensity.compact,
                    backgroundColor:
                        cs.secondaryContainer.withValues(alpha: 0.8),
                  ),
                ],
              ],
            ),
            if (analysis.hasCropMismatch) ...[
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: GardenWarningStyle.background(cs),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GardenWarningStyle.icon(cs).withValues(alpha: 0.5),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: GardenWarningStyle.icon(cs),
                      size: 22,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Verkeerd gewas gescand',
                            style: t.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: GardenWarningStyle.foreground(cs),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            analysis.cropMismatchWarning ??
                                'De foto hoort niet bij dit gewas.',
                            style: t.textTheme.bodyMedium?.copyWith(
                              color: GardenWarningStyle.foreground(cs),
                              height: 1.35,
                            ),
                          ),
                          if (analysis.detectedPlantLabel != null &&
                              analysis.detectedPlantLabel!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Op foto herkend als: ${analysis.detectedPlantLabel}',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: GardenWarningStyle.foreground(cs),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (analysis.advice.trim().isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  analysis.advice,
                  style: t.textTheme.bodyMedium?.copyWith(height: 1.35),
                ),
              ],
            ],
            if (!analysis.hasCropMismatch && analysis.hasInsight) ...[
              const SizedBox(height: 12),
              PlantAiInsightSections(
                analysis: analysis,
                ornamentalBloomOnly: ornamentalBloomOnly,
                edibleBloomDual: edibleBloomDual,
              ),
            ],
            if (analysis.comparisonNote != null &&
                analysis.comparisonNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                analysis.comparisonNote!,
                style: t.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            if (analysis.healthComparisonNote != null &&
                analysis.healthComparisonNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: GardenWarningStyle.infoBackground(cs),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: GardenWarningStyle.infoIcon(cs).withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      analysis.healthImprovedSincePrevious == true
                          ? Icons.trending_up
                          : Icons.monitor_heart_outlined,
                      size: 18,
                      color: GardenWarningStyle.infoIcon(cs),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '${_trendLabel(analysis.healthTrend)}\n${analysis.healthComparisonNote!}',
                        style: t.textTheme.bodySmall?.copyWith(
                          color: GardenWarningStyle.infoForeground(cs),
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (analysis.pestLikelyResolvedSincePrevious != null) ...[
                const SizedBox(height: 6),
                Text(
                  analysis.pestLikelyResolvedSincePrevious == true
                      ? 'Plaag lijkt verbeterd of verholpen t.o.v. vorige scan.'
                      : 'Plaagsignalen zijn nog zichtbaar t.o.v. vorige scan.',
                  style: t.textTheme.bodySmall?.copyWith(
                    color: GardenWarningStyle.infoForeground(cs),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
            const SizedBox(height: 8),
            if (!analysis.hasCropMismatch)
              Text(
                analysis.phaseLabel,
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (!analysis.hasCropMismatch &&
                !ornamentalBloomOnly &&
                !edibleBloomDual &&
                analysis.daysUntilHarvest != null)
              Text(
                analysis.phase == PlantAiPhase.ripe
                    ? 'Nu oogsten'
                    : 'Geschatte oogst over ±${analysis.daysUntilHarvest} dagen',
                style: t.textTheme.bodyLarge,
              ),
            if (!analysis.hasCropMismatch &&
                ornamentalBloomOnly &&
                analysis.bloomSeasonNote != null &&
                analysis.bloomSeasonNote!.trim().isNotEmpty)
              Text(
                analysis.bloomSeasonNote!,
                style: t.textTheme.bodyLarge,
              ),
            if (!analysis.hasCropMismatch &&
                analysis.harvestWindowLabel.isNotEmpty)
              Text(
                ornamentalBloomOnly
                    ? analysis.harvestWindowLabel
                    : 'Venster: ${analysis.harvestWindowLabel}',
                style: t.textTheme.bodyMedium,
              ),
            Text(
              'Betrouwbaarheid: ${analysis.confidencePercent}%',
              style: t.textTheme.labelLarge?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
            if (!analysis.hasCropMismatch && analysis.advice.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                analysis.advice,
                style: t.textTheme.bodyMedium,
              ),
            ],
            if (!analysis.hasCropMismatch &&
                analysis.datePhotoComparisonNote != null &&
                analysis.datePhotoComparisonNote!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                analysis.datePhotoComparisonNote!,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: analysis.plantedDateMatchesPhoto == false
                      ? GardenWarningStyle.foreground(cs)
                      : null,
                  fontWeight: analysis.plantedDateMatchesPhoto == false
                      ? FontWeight.w600
                      : null,
                ),
              ),
            ],
            if (!analysis.hasCropMismatch &&
                analysis.seasonTimingWarning != null &&
                analysis.seasonTimingWarning!.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                analysis.seasonTimingWarning!,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: GardenWarningStyle.foreground(cs),
                ),
              ),
            ],
            if (!analysis.hasCropMismatch &&
                analysis.estimatedWeeksGrowing != null &&
                analysis.estimatedWeeksGrowing! >= 2) ...[
              Text(
                'Geschat al ${analysis.estimatedWeeksGrowing} weken aan het groeien (foto).',
                style: t.textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
            ],
            if (analysis.warnings.isNotEmpty) ...[
              const SizedBox(height: 8),
              ...analysis.warnings.map(
                (w) {
                  final low = _isLowPriorityInfo(w);
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      '${low ? 'ℹ' : '⚠'} $w',
                      style: t.textTheme.bodyMedium?.copyWith(
                        color: low
                            ? GardenWarningStyle.infoForeground(cs)
                            : GardenWarningStyle.foreground(cs),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  );
                },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
