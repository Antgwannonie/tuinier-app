import 'package:flutter/material.dart';

import '../data/weather_service.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'scan_result_body.dart';

/// AI-scanrapport — delegeert naar tabbed scanresultaat.
class DynamicScanReport extends StatelessWidget {
  const DynamicScanReport({
    super.key,
    required this.analysis,
    this.vegetable,
    this.previousAnalysis,
    this.weather,
    this.scanPhotoPath,
    this.onNewScan,
    this.onGoToMoestuin,
    this.compact = false,
    this.ornamentalBloomOnly = false,
    this.edibleBloomDual = false,
  });

  final PlantAiAnalysis analysis;
  final Vegetable? vegetable;
  final PlantAiAnalysis? previousAnalysis;
  final WeatherForecast? weather;
  final String? scanPhotoPath;
  final VoidCallback? onNewScan;
  final VoidCallback? onGoToMoestuin;
  final bool compact;
  final bool ornamentalBloomOnly;
  final bool edibleBloomDual;

  @override
  Widget build(BuildContext context) {
    return ScanResultBody(
      analysis: analysis,
      vegetable: vegetable,
      previousAnalysis: previousAnalysis,
      weather: weather,
      onNewScan: onNewScan,
      onGoToMoestuin: onGoToMoestuin,
    );
  }
}
