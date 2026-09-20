import 'package:flutter/material.dart';

/// Hoe de gebruiker het gewas wil starten (wizard stap 3).
enum PlantGrowApproach {
  seed,
  seedling,
  adult,
}

extension PlantGrowApproachLabels on PlantGrowApproach {
  String get title => switch (this) {
        PlantGrowApproach.seed => 'Zaad',
        PlantGrowApproach.seedling => 'Zaailing',
        PlantGrowApproach.adult => 'Volwassen plant',
      };

  String get subtitle => switch (this) {
        PlantGrowApproach.seed => 'Ik ga zaaien.',
        PlantGrowApproach.seedling =>
          'Ik gebruik een plantje (opgekweekt uit zaad).',
        PlantGrowApproach.adult => 'Ik gebruik een volwassen plant.',
      };

  IconData get icon => switch (this) {
        PlantGrowApproach.seed => Icons.grass_rounded,
        PlantGrowApproach.seedling => Icons.spa_rounded,
        PlantGrowApproach.adult => Icons.local_florist_rounded,
      };

  String get summaryLabel => switch (this) {
        PlantGrowApproach.seed => 'Zaad',
        PlantGrowApproach.seedling => 'Zaailing',
        PlantGrowApproach.adult => 'Volwassen plant',
      };

  /// Klikbare taak op fase-kaart en in Taken.
  String get taskLabel => switch (this) {
        PlantGrowApproach.seed => 'Zaaien',
        PlantGrowApproach.seedling => 'Zaailing planten',
        PlantGrowApproach.adult => 'Volwassen plant planten',
      };
}

PlantGrowApproach? plantGrowApproachFromName(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final approach in PlantGrowApproach.values) {
    if (approach.name == raw) return approach;
  }
  return null;
}
