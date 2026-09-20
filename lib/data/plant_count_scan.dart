/// Foto-slots voor multi-plant scan (aantal planten → hoeveel foto's).
enum ScanPhotoSlotKind {
  /// Elke plant apart (≤5 planten).
  neutral,

  /// Zwakkere exemplaren (>5 planten, steekproef).
  worst,

  /// Sterkere exemplaren (>5 planten, steekproef).
  best,
}

class ScanPhotoSlot {
  const ScanPhotoSlot({
    required this.label,
    required this.kind,
  });

  final String label;
  final ScanPhotoSlotKind kind;
}

/// Hoeveel losse foto's nodig zijn voor dit aantal planten.
int requiredPhotoCount(int plantCount) {
  if (plantCount <= 0) return 1;
  if (plantCount <= 5) return plantCount;
  return 5;
}

/// Labels per fotostap.
List<ScanPhotoSlot> scanPhotoSlotsForPlantCount(int plantCount) {
  final count = requiredPhotoCount(plantCount);
  if (plantCount <= 5) {
    return List.generate(
      count,
      (i) => ScanPhotoSlot(
        label: plantCount == 1 ? 'Jouw plant' : 'Plant ${i + 1}',
        kind: ScanPhotoSlotKind.neutral,
      ),
    );
  }
  return const [
    ScanPhotoSlot(
      label: 'Slechtste plant',
      kind: ScanPhotoSlotKind.worst,
    ),
    ScanPhotoSlot(
      label: 'Op één na slechtste plant',
      kind: ScanPhotoSlotKind.worst,
    ),
    ScanPhotoSlot(
      label: 'Mooiste plant',
      kind: ScanPhotoSlotKind.best,
    ),
    ScanPhotoSlot(
      label: 'Tweede mooiste plant',
      kind: ScanPhotoSlotKind.best,
    ),
    ScanPhotoSlot(
      label: 'Derde mooiste plant',
      kind: ScanPhotoSlotKind.best,
    ),
  ];
}

String multiScanIntroText(int plantCount) {
  if (plantCount <= 1) {
    return 'Maak één foto van je plant.';
  }
  if (plantCount <= 5) {
    return 'Je hebt $plantCount planten, maak van elke plant één losse foto.';
  }
  return 'Je hebt $plantCount planten, maak 5 losse foto\'s: '
      '2 van je zwakste en 3 van je mooiste planten.';
}
