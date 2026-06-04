import '../models/garden_plant_profile.dart';

int weeksSinceDate(DateTime from, [DateTime? reference]) {
  final ref = reference ?? DateTime.now();
  final a = DateTime(from.year, from.month, from.day);
  final b = DateTime(ref.year, ref.month, ref.day);
  return (b.difference(a).inDays / 7).round().clamp(0, 520);
}

/// Meldingen: zaaidatum vs. foto (na AI-scan).
List<String> datePhotoWarningsFor(GardenPlantProfile? profile) {
  if (profile == null || !profile.isPlanted || profile.plantingDateUnknown) {
    return const [];
  }
  final ai = profile.lastAnalysis;
  if (ai == null) return const [];
  if (ai.harvestStillPossibleThisSeason == true) return const [];

  final statedWeeks = weeksSinceDate(profile.plantedAt, ai.scannedAt);
  final photoWeeks = ai.estimatedWeeksGrowing;
  final weekGap = photoWeeks != null ? (photoWeeks - statedWeeks).abs() : 0;
  final mismatch = ai.plantedDateMatchesPhoto == false || weekGap >= 3;

  if (!mismatch) return const [];

  final lines = <String>[];
  if (ai.datePhotoComparisonNote != null &&
      ai.datePhotoComparisonNote!.trim().isNotEmpty) {
    lines.add(ai.datePhotoComparisonNote!.trim());
  } else {
    lines.add(
      'De plant op je foto lijkt niet te passen bij je ingevulde '
      'zaai-/plantdatum.',
    );
  }

  if (photoWeeks != null) {
    lines.add(
      'Volgens je datum: ongeveer $statedWeeks weken geleden. '
      'Op de foto: ongeveer $photoWeeks weken groei.',
    );
  }

  return lines;
}

/// Info bij onbekende zaaidatum (alleen fotoschatting).
List<String> photoAgeInfoForUnknownDate(GardenPlantProfile? profile) {
  if (profile == null || !profile.plantingDateUnknown) return const [];
  final ai = profile.lastAnalysis;
  final weeks = ai?.estimatedWeeksGrowing;
  if (weeks == null) return const [];
  return [
    'Scan: plant lijkt al ongeveer $weeks weken te groeien (alleen op foto).',
  ];
}
