import 'package:flutter/material.dart';

import '../data/weather_service.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import '../navigation/scan_result_navigation.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/scan_result_body.dart';

/// Volledige pagina met scanresultaat (Taken + Plantinfo tabs).
class ScanResultScreen extends StatelessWidget {
  const ScanResultScreen({
    super.key,
    required this.analysis,
    this.vegetable,
    this.previousAnalysis,
    this.weather,
    this.onNewScan,
    this.onGoToMoestuin,
    this.onWizardContinue,
    this.wizardMode = false,
    this.initialTab = 0,
  });

  final PlantAiAnalysis analysis;
  final Vegetable? vegetable;
  final PlantAiAnalysis? previousAnalysis;
  final WeatherForecast? weather;
  final VoidCallback? onNewScan;
  final VoidCallback? onGoToMoestuin;
  /// In de toevoeg-wizard: ga door naar de volgende wizardstap.
  final VoidCallback? onWizardContinue;
  final bool wizardMode;
  final int initialTab;

  @override
  Widget build(BuildContext context) {
    final plantName = vegetable?.nameNl ?? 'Plant';

    return Scaffold(
      backgroundColor: TuinierColors.scanPageBackground,
      appBar: AppBar(
        backgroundColor: TuinierColors.scanPageBackground,
        surfaceTintColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Scanresultaat',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            Text(
              plantName,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TuinierColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
      body: ScanResultBody(
        analysis: analysis,
        vegetable: vegetable,
        previousAnalysis: previousAnalysis,
        weather: weather,
        onNewScan: wizardMode ? null : (onNewScan ?? () => Navigator.of(context).pop()),
        onGoToMoestuin: wizardMode
            ? null
            : (onGoToMoestuin ??
                () => goToMoestuinFromScanContext(
                      context,
                      popScanResult: true,
                    )),
        onWizardContinue: onWizardContinue,
        wizardMode: wizardMode,
        initialTab: initialTab,
      ),
    );
  }
}

Future<void> openScanResultScreen(
  BuildContext context, {
  required PlantAiAnalysis analysis,
  Vegetable? vegetable,
  PlantAiAnalysis? previousAnalysis,
  WeatherForecast? weather,
  VoidCallback? onNewScan,
  VoidCallback? onGoToMoestuin,
  VoidCallback? onWizardContinue,
  bool wizardMode = false,
  int initialTab = 0,
}) {
  final goMoestuin = onGoToMoestuin ??
      () => goToMoestuinFromScanContext(context, popScanResult: true);
  return Navigator.of(context).push<void>(
    MaterialPageRoute<void>(
      builder: (_) => ScanResultScreen(
        analysis: analysis,
        vegetable: vegetable,
        previousAnalysis: previousAnalysis,
        weather: weather,
        onNewScan: onNewScan,
        onGoToMoestuin: goMoestuin,
        onWizardContinue: onWizardContinue,
        wizardMode: wizardMode,
        initialTab: initialTab,
      ),
    ),
  );
}

bool scanResultSupportsFullPage(PlantAiAnalysis analysis) {
  return !analysis.hasCropMismatch && analysis.hasInsight;
}
