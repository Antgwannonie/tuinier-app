/// Hoe de gebruiker het gewas is gestart (zaaien / planten).
enum PlantStartMethod {
  preSowIndoors,
  sowOutdoors,
  plantOutdoors,
}

extension PlantStartMethodLabels on PlantStartMethod {
  String get cardLabel => switch (this) {
        PlantStartMethod.preSowIndoors => 'Binnen voorzaaien',
        PlantStartMethod.sowOutdoors => 'Buiten zaaien',
        PlantStartMethod.plantOutdoors => 'Buiten planten',
      };

  String get dateFieldLabel => switch (this) {
        PlantStartMethod.preSowIndoors => 'Binnen voorgezaaid op',
        PlantStartMethod.sowOutdoors => 'Buiten gezaaid op',
        PlantStartMethod.plantOutdoors => 'Buiten geplant op',
      };

  String get confirmSheetLabel => switch (this) {
        PlantStartMethod.preSowIndoors => 'Binnen voorgezaaid',
        PlantStartMethod.sowOutdoors => 'Buiten gezaaid',
        PlantStartMethod.plantOutdoors => 'Buiten geplant',
      };
}

PlantStartMethod? plantStartMethodFromName(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  for (final m in PlantStartMethod.values) {
    if (m.name == raw) return m;
  }
  return null;
}
