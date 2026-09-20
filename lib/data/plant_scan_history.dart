import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import 'crop_bloom_countdown.dart';
import 'plant_scan_photo_store.dart';

/// Eén scan met optionele foto.
class PlantScanEntry {
  const PlantScanEntry({
    required this.analysis,
    this.photoPath,
  });

  final PlantAiAnalysis analysis;
  final String? photoPath;
}

bool scansAreDuplicates(PlantAiAnalysis a, PlantAiAnalysis b) {
  if (a.scannedAt.difference(b.scannedAt).inMinutes.abs() > 3) {
    return false;
  }
  return a.phase == b.phase &&
      a.phaseLabel == b.phaseLabel &&
      a.daysUntilHarvest == b.daysUntilHarvest &&
      a.harvestWindowLabel == b.harvestWindowLabel &&
      a.advice == b.advice;
}

/// Verwijdert opeenvolgende dubbele scans (zelfde analyse opnieuw opgeslagen).
List<PlantAiAnalysis> dedupeScanHistory(List<PlantAiAnalysis> history) {
  if (history.isEmpty) return history;
  final out = <PlantAiAnalysis>[history.first];
  for (var i = 1; i < history.length; i++) {
    if (!scansAreDuplicates(out.last, history[i])) {
      out.add(history[i]);
    }
  }
  return out;
}

/// Gekoppelde scans + foto's voor weergave (oudste → nieuwste).
List<PlantScanEntry> plantScanEntries(GardenPlantProfile profile) {
  var history = dedupeScanHistory(profile.scanHistory);
  if (history.isEmpty && profile.lastAnalysis != null) {
    history = [profile.lastAnalysis!];
  }

  final paths = profile.scanPhotoPaths
      .where(PlantScanPhotoStore.exists)
      .toList();

  final entries = <PlantScanEntry>[];
  for (var i = 0; i < history.length; i++) {
    String? path;
    if (paths.isNotEmpty) {
      final pathIndex = paths.length - history.length + i;
      if (pathIndex >= 0 && pathIndex < paths.length) {
        path = paths[pathIndex];
      }
    }
    entries.add(PlantScanEntry(analysis: history[i], photoPath: path));
  }
  return entries;
}

/// Korte regels voor scan 2, 3, … — alleen wat nieuw of gewijzigd is.
List<String> followUpScanLines(
  PlantAiAnalysis previous,
  PlantAiAnalysis current,
) {
  final lines = <String>[];

  if (previous.phase != current.phase ||
      previous.phaseLabel != current.phaseLabel) {
    lines.add('Fase: ${current.phaseLabel}');
  }

  final prevCountdown = cropCountdownDaysAtScan(previous, null);
  final currCountdown = cropCountdownDaysAtScan(current, null);
  final prevBloomDays = previous.daysUntilBloom;
  final currBloomDays = current.daysUntilBloom;

  if (prevCountdown != currCountdown ||
      prevBloomDays != currBloomDays ||
      previous.daysUntilHarvest != current.daysUntilHarvest) {
    final changeLine = formatCropCountdownChangeLine(current);
    if (changeLine.isNotEmpty) {
      lines.add(changeLine);
    } else if (current.daysUntilHarvest != null) {
      lines.add(
        current.phase == PlantAiPhase.ripe
            ? 'Klaar om te oogsten'
            : 'Oogst over ±${current.daysUntilHarvest} dagen',
      );
    }
  } else if (current.daysUntilHarvest != null &&
      current.phase == PlantAiPhase.ripe) {
    lines.add('Klaar om te oogsten');
  } else if (analysisIsInBloom(current)) {
    lines.add('Nu in bloei');
  }

  if (previous.harvestWindowLabel != current.harvestWindowLabel &&
      current.harvestWindowLabel.isNotEmpty) {
    lines.add(current.harvestWindowLabel);
  }

  final note = current.comparisonNote?.trim();
  if (note != null && note.isNotEmpty) {
    lines.add(note);
  } else if (current.matchedPrevious) {
    lines.add('Zelfde stadium als vorige scan.');
  }

  if (current.advice != previous.advice && current.advice.trim().isNotEmpty) {
    lines.add(current.advice.trim());
  }

  if (lines.isEmpty) {
    lines.add('Geen nieuwe wijzigingen t.o.v. vorige scan.');
  }
  return lines;
}

int _scanTimeKey(PlantAiAnalysis a) => a.scannedAt.millisecondsSinceEpoch;

List<PlantAiAnalysis> _resolvedHistory(GardenPlantProfile profile) {
  var history = dedupeScanHistory(profile.scanHistory);
  if (history.isEmpty && profile.lastAnalysis != null) {
    history = [profile.lastAnalysis!];
  }
  return history;
}

List<String> _resolvedPhotoPaths(
  GardenPlantProfile profile,
  int historyLength,
) {
  return profile.scanPhotoPaths
      .where(PlantScanPhotoStore.exists)
      .toList();
}

/// Profiel leegmaken voor een nieuwe zaai-/plantronde (geen oude oogst/scans).
GardenPlantProfile resetProfileScanStateForNewPlanting(
  GardenPlantProfile profile,
) {
  return profile.copyWith(
    clearAnalysis: true,
    scanHistory: const [],
    scanPhotoPaths: const [],
    clearLastScanPhoto: true,
    clearScanFingerprint: true,
    clearHarvest: true,
    clearNextScan: true,
    clearPinnedMoestuinAction: true,
    plantHealthAcknowledged: false,
    warningsDismissedFromBell: false,
    seasonBeyondCalendar: false,
    awaitingDeathConfirmation: false,
  );
}

/// Verwijdert één scan (en bijbehorende foto) uit het profiel.
GardenPlantProfile removeScanEntry(
  GardenPlantProfile profile,
  PlantAiAnalysis target,
) {
  final history = List<PlantAiAnalysis>.from(_resolvedHistory(profile));
  final idx = history.indexWhere((a) => _scanTimeKey(a) == _scanTimeKey(target));
  if (idx < 0) return profile;

  var paths = _resolvedPhotoPaths(profile, history.length);
  if (paths.length > history.length) {
    paths = paths.sublist(paths.length - history.length);
  }

  String? removedPath;
  if (paths.isNotEmpty) {
    final pathIdx = paths.length - history.length + idx;
    if (pathIdx >= 0 && pathIdx < paths.length) {
      removedPath = paths.removeAt(pathIdx);
    }
  }
  if (removedPath != null) {
    PlantScanPhotoStore.deleteFile(removedPath);
  }

  history.removeAt(idx);

  if (history.isEmpty) {
    return profile.copyWith(
      clearAnalysis: true,
      scanHistory: const [],
      scanPhotoPaths: const [],
      clearLastScanPhoto: true,
      clearScanFingerprint: true,
      clearHarvest: true,
      clearNextScan: true,
    );
  }

  final last = history.last;
  DateTime? harvestAt;
  final days = last.daysUntilHarvest;
  if (days != null) {
    harvestAt = DateTime(
      last.scannedAt.year,
      last.scannedAt.month,
      last.scannedAt.day,
    ).add(Duration(days: days));
  } else if (last.phase == PlantAiPhase.ripe) {
    harvestAt = DateTime(
      last.scannedAt.year,
      last.scannedAt.month,
      last.scannedAt.day,
    );
  }

  var updated = profile.copyWith(
    scanHistory: history,
    scanPhotoPaths: paths,
    lastAnalysis: last,
    lastScanPhotoPath: paths.isNotEmpty ? paths.last : null,
    predictedHarvestAt: harvestAt,
    clearHarvest: harvestAt == null,
  );
  return normalizeProfileScans(updated);
}

/// Ruimt dubbele scans en overtollige foto-paden op (bij laden / na scan).
GardenPlantProfile normalizeProfileScans(GardenPlantProfile profile) {
  final deduped = dedupeScanHistory(profile.scanHistory);
  var paths = List<String>.from(profile.scanPhotoPaths);

  if (deduped.isEmpty) {
    if (paths.isNotEmpty) {
      PlantScanPhotoStore.deletePaths(paths);
    }
    return profile.copyWith(
      scanHistory: const [],
      scanPhotoPaths: const [],
      clearLastScanPhoto: true,
    );
  }

  while (paths.length > deduped.length) {
    PlantScanPhotoStore.deleteFile(paths.removeAt(0));
  }

  final lastPath = paths.isNotEmpty ? paths.last : profile.lastScanPhotoPath;

  return profile.copyWith(
    scanHistory: deduped,
    scanPhotoPaths: paths,
    lastAnalysis: deduped.last,
    lastScanPhotoPath: lastPath,
    lastScanImageFingerprint: profile.lastScanImageFingerprint,
  );
}
