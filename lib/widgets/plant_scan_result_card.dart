import 'package:flutter/material.dart';

import '../data/crop_bloom_countdown.dart';
import '../data/plant_scan_persist_policy.dart';
import '../data/weather_service.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import 'garden_warning_style.dart';
import 'plant_ai_insight_sections.dart';

/// Volledig scanresultaat — dynamisch AI-rapport.
class PlantScanResultCard extends StatelessWidget {
  const PlantScanResultCard({
    super.key,
    required this.analysis,
    this.vegetable,
    this.previousAnalysis,
    this.weather,
    this.scanPhotoPath,
    this.onNewScan,
    this.savedToHistory = true,
    this.showNotSavedNotice,
    this.ornamentalBloomOnly = false,
    this.edibleBloomDual = false,
  });

  final PlantAiAnalysis analysis;
  final Vegetable? vegetable;
  final PlantAiAnalysis? previousAnalysis;
  final WeatherForecast? weather;
  final String? scanPhotoPath;
  final VoidCallback? onNewScan;

  /// False wanneer de scan wel is getoond maar niet in de geschiedenis staat.
  final bool savedToHistory;

  /// Toon de «niet opgeslagen»-melding (standaard: alleen bij [savedToHistory] false).
  final bool? showNotSavedNotice;

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

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final showNotSaved = showNotSavedNotice ?? !savedToHistory;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(14),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showNotSaved) ...[
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.all(8),
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
              PlantAiInsightSections(
                analysis: analysis,
                vegetable: vegetable,
                previousAnalysis: previousAnalysis,
                weather: weather,
                scanPhotoPath: scanPhotoPath,
                onNewScan: onNewScan,
                ornamentalBloomOnly: ornamentalBloomOnly,
                edibleBloomDual: edibleBloomDual,
              ),
            ] else if (!analysis.hasCropMismatch) ...[
              const SizedBox(height: 8),
              Text(
                analysis.phaseLabel,
                style: t.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (!ornamentalBloomOnly &&
                  !edibleBloomDual &&
                  analysis.daysUntilHarvest != null)
                Text(
                  analysis.phase == PlantAiPhase.ripe
                      ? 'Nu oogsten'
                      : 'Geschatte oogst over ±${analysis.daysUntilHarvest} dagen',
                  style: t.textTheme.bodyLarge,
                ),
              if (ornamentalBloomOnly || edibleBloomDual) ...[
                if (analysisIsInBloom(analysis))
                  Text(
                    'Nu in bloei',
                    style: t.textTheme.bodyLarge,
                  )
                else if (analysis.daysUntilBloom != null &&
                    analysis.daysUntilBloom! > 0)
                  Text(
                    'Geschatte bloei over ±${analysis.daysUntilBloom} dagen',
                    style: t.textTheme.bodyLarge,
                  ),
              ],
              if (analysis.fruitHarvestNote != null &&
                  analysis.fruitHarvestNote!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  analysis.fruitHarvestNote!,
                  style: t.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (ornamentalBloomOnly &&
                  analysis.bloomSeasonNote != null &&
                  analysis.bloomSeasonNote!.trim().isNotEmpty)
                Text(
                  analysis.bloomSeasonNote!,
                  style: t.textTheme.bodyLarge,
                ),
              if (analysis.harvestWindowLabel.isNotEmpty)
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
              if (analysis.advice.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  analysis.advice,
                  style: t.textTheme.bodyMedium,
                ),
              ],
              if (analysis.datePhotoComparisonNote != null &&
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
              if (analysis.seasonTimingWarning != null &&
                  analysis.seasonTimingWarning!.trim().isNotEmpty) ...[
                const SizedBox(height: 8),
                Text(
                  analysis.seasonTimingWarning!,
                  style: t.textTheme.bodyMedium?.copyWith(
                    color: GardenWarningStyle.foreground(cs),
                  ),
                ),
              ],
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
