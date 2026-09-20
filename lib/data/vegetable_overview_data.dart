part 'vegetable_overview_entries.dart';

/// Gecureerde overzichtfeiten voor groenteplanten (NL-klimaat).
class VegetableOverviewFacts {
  const VegetableOverviewFacts({
    required this.sowMonths,
    this.plantMonths = const <int>{},
    required this.harvestMonths,
    required this.standplaats,
    required this.water,
    required this.difficulty,
    required this.lifespan,
    required this.locatieOutdoor,
    required this.locatieContainer,
    required this.voeding,
    required this.height,
    required this.width,
    required this.growthHabit,
    required this.plantSpacing,
    required this.rowSpacing,
    required this.firstHarvest,
    required this.harvestPeriod,
    required this.opbrengstLevel,
    required this.opbrengstDetail,
    required this.keyPoints,
    required this.summaryShort,
    required this.didYouKnow,
  });

  final Set<int> sowMonths;
  final Set<int> plantMonths;
  final Set<int> harvestMonths;
  final String standplaats;
  final String water;
  final String difficulty;
  final String lifespan;
  final String locatieOutdoor;
  final String locatieContainer;
  final String voeding;
  final String height;
  final String width;
  final String growthHabit;
  final String plantSpacing;
  final String rowSpacing;
  final String firstHarvest;
  final String harvestPeriod;
  final String opbrengstLevel;
  final String opbrengstDetail;
  final List<String> keyPoints;
  final String summaryShort;
  final String didYouKnow;
}

VegetableOverviewFacts? vegetableOverviewFactsFor(String vegetableId) =>
    kVegetableOverviewFacts[vegetableId];

bool hasVegetableOverviewFacts(String vegetableId) =>
    kVegetableOverviewFacts.containsKey(vegetableId);
