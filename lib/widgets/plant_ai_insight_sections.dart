import 'package:flutter/material.dart';

import '../data/weather_service.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'dynamic_scan_report.dart';

/// Uitgebreide AI-secties — delegeert naar het dynamische scanrapport.
class PlantAiInsightSections extends StatelessWidget {
  const PlantAiInsightSections({
    super.key,
    required this.analysis,
    this.vegetable,
    this.previousAnalysis,
    this.weather,
    this.scanPhotoPath,
    this.onNewScan,
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
  final bool compact;
  final bool ornamentalBloomOnly;
  final bool edibleBloomDual;

  @override
  Widget build(BuildContext context) {
    return DynamicScanReport(
      analysis: analysis,
      vegetable: vegetable,
      previousAnalysis: previousAnalysis,
      weather: weather,
      scanPhotoPath: scanPhotoPath,
      onNewScan: onNewScan,
      compact: compact,
      ornamentalBloomOnly: ornamentalBloomOnly,
      edibleBloomDual: edibleBloomDual,
    );
  }
}
