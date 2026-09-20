import '../models/garden_plant_profile.dart';

int weeksSinceDate(DateTime from, [DateTime? reference]) {
  final ref = reference ?? DateTime.now();
  final a = DateTime(from.year, from.month, from.day);
  final b = DateTime(ref.year, ref.month, ref.day);
  return (b.difference(a).inDays / 7).round().clamp(0, 520);
}

/// Zaaidatum/plantdatum vs. scan, geen Home-actie, wel meldingen-tab.
bool isPlantingDateMismatchWarning(String text) {
  final t = text.toLowerCase();
  if (t.isEmpty) return false;
  return t.contains('zaaidatum') ||
      t.contains('plantdatum') ||
      t.contains('komt niet overeen') ||
      t.contains('stems niet overeen') ||
      t.contains('past niet bij') ||
      t.contains('klopt niet met') ||
      t.contains('ingevulde zaai') ||
      t.contains('ingevulde zaaidatum') ||
      t.contains('ingevulde datum') ||
      t.contains('foto lijkt niet') ||
      t.contains('weken verder dan je datum') ||
      t.contains('weken jonger dan je datum') ||
      t.contains('volgens je datum') ||
      t.contains('op de foto:') ||
      t.contains('weken groei') ||
      t.contains('mismatch') ||
      t.contains('met de scan') ||
      (t.contains('datum') && t.contains('scan')) ||
      (t.contains('foto') && t.contains('datum')) ||
      (t.contains('zaai') && t.contains('scan'));
}

/// Profiel heeft een open zaaidatum-/foto-conflict (na scan).
bool profileHasDatePhotoMismatch(GardenPlantProfile? profile) {
  if (profile == null || !profile.isPlanted || profile.plantingDateUnknown) {
    return false;
  }
  final ai = profile.lastAnalysis;
  if (ai == null) return false;
  if (ai.plantedDateMatchesPhoto == false) return true;
  return datePhotoWarningsFor(profile).isNotEmpty;
}

bool isCropScanMismatchWarning(String text) {
  final t = text.toLowerCase();
  if (t.isEmpty) return false;
  return t.contains('verkeerd gewas') ||
      t.contains('hoort niet bij dit gewas') ||
      t.contains('niet bij dit gewas') ||
      t.contains('cropmismatch') ||
      (t.contains('lijkt geen') && t.contains('scannen'));
}

bool _textMatchesProfileDatePhotoInfo(
  GardenPlantProfile profile,
  String text,
) {
  final trimmed = text.trim();
  if (trimmed.isEmpty) return false;
  final note = profile.lastAnalysis?.datePhotoComparisonNote?.trim();
  if (note != null && note.isNotEmpty) {
    if (trimmed == note ||
        trimmed.contains(note) ||
        note.contains(trimmed)) {
      return true;
    }
  }
  for (final line in datePhotoWarningsFor(profile)) {
    if (trimmed == line ||
        trimmed.contains(line) ||
        line.contains(trimmed)) {
      return true;
    }
  }
  return false;
}

/// Scan-/datum-info en gewas-mismatch: niet op Home, wel bij meldingen/scans.
bool shouldExcludeFromHomeActions(
  String text, {
  GardenPlantProfile? profile,
}) {
  if (isPlantingDateMismatchWarning(text) ||
      isCropScanMismatchWarning(text)) {
    return true;
  }
  if (profile != null && _textMatchesProfileDatePhotoInfo(profile, text)) {
    return true;
  }
  final ai = profile?.lastAnalysis;
  if (ai != null && ai.hasCropMismatch) {
    final mismatch = ai.cropMismatchWarning?.trim();
    if (mismatch != null && mismatch.isNotEmpty) {
      final trimmed = text.trim();
      if (trimmed == mismatch ||
          trimmed.contains(mismatch) ||
          mismatch.contains(trimmed)) {
        return true;
      }
    }
  }
  if (profile != null &&
      profileHasDatePhotoMismatch(profile) &&
      isPlantingDateMismatchWarning(text)) {
    return true;
  }
  return false;
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
