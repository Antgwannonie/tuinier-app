import '../models/garden_pest.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'garden_pests_data.dart';

/// Zoek plagen op naam, symptoom of trefwoord.
List<GardenPest> searchGardenPests(String query) {
  final q = query.trim().toLowerCase();
  if (q.isEmpty) return List<GardenPest>.from(kGardenPests);

  return kGardenPests.where((p) {
    if (p.nameNl.toLowerCase().contains(q)) return true;
    if (p.recognition.toLowerCase().contains(q)) return true;
    for (final k in p.keywords) {
      if (k.contains(q) || q.contains(k)) return true;
    }
    for (final plant in p.affectedPlants) {
      if (plant.contains(q)) return true;
    }
    return false;
  }).toList();
}

/// Koppel AI-waarschuwing of tekst aan plagen uit de gids.
List<GardenPest> pestsMatchingText(String text) {
  final t = text.toLowerCase();
  final scored = <GardenPest, int>{};

  for (final p in kGardenPests) {
    var score = 0;
    if (t.contains(p.nameNl.toLowerCase())) score += 5;
    for (final k in p.keywords) {
      if (t.contains(k)) score += 3;
    }
    if (score > 0) scored[p] = score;
  }

  final list = scored.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return list.map((e) => e.key).toList();
}

List<GardenPest> pestsForWarning(String warning) =>
    pestsMatchingText(warning);

/// Plagen die passen bij veelvoorkomende problemen van dit gewas.
List<GardenPest> pestsForVegetable(Vegetable vegetable) {
  final fromIssues = pestsMatchingText(vegetable.commonIssues);
  final fromName = pestsMatchingText(
    '${vegetable.nameNl} ${vegetable.family} ${vegetable.keywords.join(' ')}',
  );

  final seen = <String>{};
  final out = <GardenPest>[];
  for (final p in [...fromIssues, ...fromName]) {
    if (seen.add(p.id)) out.add(p);
  }
  return out;
}

List<GardenPest> pestsForWarningsAndPlant({
  required List<String> warnings,
  required Vegetable vegetable,
  GardenPlantProfile? profile,
}) {
  final seen = <String>{};
  final out = <GardenPest>[];

  void addAll(Iterable<GardenPest> list) {
    for (final p in list) {
      if (seen.add(p.id)) out.add(p);
    }
  }

  for (final w in warnings) {
    addAll(pestsForWarning(w));
  }
  addAll(pestsForVegetable(vegetable));

  final advice = profile?.lastAnalysis?.advice;
  if (advice != null && advice.isNotEmpty) {
    addAll(pestsMatchingText(advice));
  }

  return out;
}
