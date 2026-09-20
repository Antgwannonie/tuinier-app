import '../models/garden_plant_profile.dart';
import 'garden_profile_store.dart';
import 'insect_scan_store.dart';
import 'my_garden_store.dart';
import 'plant_health_warnings.dart';
import 'vegetable_repository.dart';

class GardenHealthScore {
  const GardenHealthScore({
    required this.total,
    required this.plantHealth,
    required this.insectBalance,
    required this.biodiversity,
    required this.plantCount,
    required this.warningCount,
    required this.beneficialInsects,
    required this.harmfulInsects,
    this.dangerPlants = 0,
    this.warningPlants = 0,
    this.unplantedPlants = 0,
    this.activeHarmfulSpecies = 0,
  });

  final int total;
  final int plantHealth;
  final int insectBalance;
  final int biodiversity;
  final int plantCount;
  final int warningCount;
  final int beneficialInsects;
  final int harmfulInsects;
  final int dangerPlants;
  final int warningPlants;
  final int unplantedPlants;
  final int activeHarmfulSpecies;
}

GardenHealthScore computeGardenHealthScore({
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required InsectScanStore insectStore,
}) {
  final space = gardenStore.activeSpace;
  final spaceId = space?.id ?? '';
  final ids = gardenStore.ids;

  if (ids.isEmpty && space == null) {
    return _emptyHealthScore();
  }

  final plantCount = ids.length;
  if (plantCount == 0) {
    return _emptyHealthScore();
  }

  final issues = countPlantHealthIssues(
    profileStore: profileStore,
    gardenStore: gardenStore,
    repository: repository,
  );

  final plantHealth = _computePlantHealth(
    plantCount: plantCount,
    issues: issues,
  );

  final activeInsects = insectStore.activeEntriesForSpace(spaceId);
  final beneficial =
      activeInsects.where((e) => e.benefit == InsectBenefit.beneficial).length;
  final harmfulEntries =
      activeInsects.where((e) => e.benefit == InsectBenefit.harmful).toList();
  final neutral =
      activeInsects.where((e) => e.benefit == InsectBenefit.neutral).length;

  final harmfulSpecies = _uniqueNames(harmfulEntries);
  final beneficialSpecies = _uniqueNames(
    activeInsects.where((e) => e.benefit == InsectBenefit.beneficial),
  );

  final insectBalance = _computeInsectBalance(
    beneficialSpecies: beneficialSpecies.length,
    harmfulSpecies: harmfulSpecies.length,
    hasScans: activeInsects.isNotEmpty,
  );

  final biodiversity = _computeBiodiversity(
    plantCount: plantCount,
    uniqueInsectSpecies: _uniqueNames(activeInsects).length,
    harmfulSpecies: harmfulSpecies.length,
  );

  final total = ((plantHealth * 0.5) +
          (insectBalance * 0.25) +
          (biodiversity * 0.25))
      .round()
      .clamp(0, 100);

  return GardenHealthScore(
    total: total,
    plantHealth: plantHealth,
    insectBalance: insectBalance,
    biodiversity: biodiversity,
    plantCount: plantCount,
    warningCount: issues.openIssuePlants,
    beneficialInsects: beneficial,
    harmfulInsects: harmfulEntries.length,
    dangerPlants: issues.dangerPlants,
    warningPlants: issues.warningPlants,
    unplantedPlants: issues.unplantedPlants,
    activeHarmfulSpecies: harmfulSpecies.length,
  );
}

GardenHealthScore _emptyHealthScore() {
  return const GardenHealthScore(
    total: 0,
    plantHealth: 0,
    insectBalance: 0,
    biodiversity: 0,
    plantCount: 0,
    warningCount: 0,
    beneficialInsects: 0,
    harmfulInsects: 0,
  );
}

int _computePlantHealth({
  required int plantCount,
  required PlantHealthIssueCounts issues,
}) {
  final dangerPenalty = (issues.dangerPlants / plantCount) * 45;
  final warningPenalty = (issues.warningPlants / plantCount) * 22;
  final unplantedPenalty = (issues.unplantedPlants / plantCount) * 12;

  return (100 - dangerPenalty - warningPenalty - unplantedPenalty)
      .round()
      .clamp(25, 100);
}

int _computeInsectBalance({
  required int beneficialSpecies,
  required int harmfulSpecies,
  required bool hasScans,
}) {
  if (!hasScans) return 78;

  return (84 + beneficialSpecies * 6 - harmfulSpecies * 14)
      .round()
      .clamp(30, 100);
}

int _computeBiodiversity({
  required int plantCount,
  required int uniqueInsectSpecies,
  required int harmfulSpecies,
}) {
  return (58 +
          uniqueInsectSpecies.clamp(0, 8) * 4 +
          plantCount.clamp(0, 18) -
          harmfulSpecies * 3)
      .round()
      .clamp(35, 100);
}

Set<String> _uniqueNames(Iterable<InsectScanEntry> entries) {
  return entries
      .map((e) => e.nameNl.trim().toLowerCase())
      .where((name) => name.isNotEmpty)
      .toSet();
}

/// Korte status op home / moestuin-kaarten.
String gardenHealthShortLabel(GardenHealthScore health) {
  if (health.plantCount == 0) return 'Nog leeg';
  if (health.total >= 90) return 'Goed';
  if (health.total >= 70) return 'Redelijk';
  return 'Let op';
}
