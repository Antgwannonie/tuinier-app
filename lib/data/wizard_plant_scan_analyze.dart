import 'dart:typed_data';

import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'plant_photo_ai_service.dart';
import 'planting_calendar.dart';
import 'planting_timing_advice.dart';

/// AI-analyse voor de toevoeg-wizard (plant bestaat nog niet in de moestuin).
Future<PlantAiAnalysis> analyzeWizardPlantScan({
  required String apiKey,
  required Vegetable vegetable,
  required GardenPlantProfile previewProfile,
  required Uint8List imageBytes,
  String mimeType = 'image/jpeg',
}) async {
  final cal = calendarLabelsFor(vegetable.id);
  final timing = assessPlantingTiming(
    vegetable: vegetable,
    profile: previewProfile,
  );
  final outsideSeason = !previewProfile.plantingDateUnknown &&
      timing.status != PlantingTimingStatus.onTime &&
      timing.status != PlantingTimingStatus.noCalendar &&
      timing.status != PlantingTimingStatus.unknownDate;
  final daysSince = previewProfile.plantingDateUnknown
      ? null
      : DateTime.now()
          .difference(
            DateTime(
              previewProfile.plantedAt.year,
              previewProfile.plantedAt.month,
              previewProfile.plantedAt.day,
            ),
          )
          .inDays;

  final service = PlantPhotoAiService(apiKey: apiKey);
  return service.analyze(
    imageBytes: imageBytes,
    mimeType: mimeType,
    vegetable: vegetable,
    plantedAt: previewProfile.plantedAt,
    plantingDateUnknown: previewProfile.plantingDateUnknown,
    locationLabel: previewProfile.location.label,
    sunLabel: previewProfile.sunLevel.label,
    outsidePlantingSeason: outsideSeason,
    plantWindowLabel: cal.plant,
    harvestWindowLabel: cal.harvest,
    daysSinceStatedPlantDate: daysSince,
    isFirstScan: true,
  );
}
