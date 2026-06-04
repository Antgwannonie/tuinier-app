/// Tuinplaag of ziekte met herkenning en bestrijding (NL moestuin).
class GardenPest {
  const GardenPest({
    required this.id,
    required this.nameNl,
    required this.recognition,
    required this.actionSteps,
    required this.keywords,
    this.prevention = const [],
    this.affectedPlants = const [],
  });

  final String id;
  final String nameNl;
  final String recognition;
  final List<String> actionSteps;
  final List<String> keywords;
  final List<String> prevention;
  final List<String> affectedPlants;
}
