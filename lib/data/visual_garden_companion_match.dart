import '../models/vegetable.dart';
import 'moestuin_companion_info.dart';
import 'plant_combination_guide.dart';
import 'vegetable_repository.dart';

/// Verzamelt NL-hints voor “goede buren” van één of meer ankerplanten.
Set<String> companionGoodHintsFor({
  required VegetableRepository repository,
  required Iterable<String> plantIds,
}) {
  final hints = <String>{};
  for (final id in plantIds) {
    final v = repository.byId(id);
    if (v == null) continue;

    final info = moestuinCompanionInfoForVegetable(v);
    if (info != null) {
      for (final label in info.goodNearLabels) {
        hints.add(label.toLowerCase());
      }
    }

    final guide = combinationGuideForVegetable(v);
    for (final section in guide.sections) {
      final title = section.title.toLowerCase();
      if (title.contains('goede buren') ||
          title.contains('gezelschap') ||
          title.contains('combinatie')) {
        for (final d in section.details) {
          hints.add(d.heading.toLowerCase());
        }
        for (final c in section.checklist ?? const <String>[]) {
          hints.add(c.toLowerCase());
        }
      }
    }
  }
  return hints;
}

Set<String> companionBadHintsFor({
  required VegetableRepository repository,
  required Iterable<String> plantIds,
}) {
  final hints = <String>{};
  for (final id in plantIds) {
    final v = repository.byId(id);
    if (v == null) continue;
    final guide = combinationGuideForVegetable(v);
    for (final section in guide.sections) {
      final title = section.title.toLowerCase();
      if (title.contains('slechte buren') || title.contains('vermijd')) {
        for (final d in section.details) {
          hints.add(d.heading.toLowerCase());
        }
        for (final c in section.checklist ?? const <String>[]) {
          hints.add(c.toLowerCase());
        }
      }
    }
  }
  return hints;
}

bool plantMatchesCompanionHints(Vegetable candidate, Set<String> hints) {
  if (hints.isEmpty) return false;
  final name = candidate.nameNl.toLowerCase();
  final hay = [
    name,
    ...candidate.keywords.map((k) => k.toLowerCase()),
    candidate.family.toLowerCase(),
  ].join(' ');
  return hints.any((h) => h.isNotEmpty && (hay.contains(h) || h.contains(name)));
}

bool isGoodCompanionOf({
  required Vegetable candidate,
  required VegetableRepository repository,
  required Iterable<String> anchorPlantIds,
}) {
  final ids = anchorPlantIds.toSet();
  if (ids.isEmpty) return true;
  if (ids.contains(candidate.id)) return true;
  final hints = companionGoodHintsFor(
    repository: repository,
    plantIds: ids,
  );
  if (hints.isEmpty) return true;
  return plantMatchesCompanionHints(candidate, hints);
}

bool isBadCompanionOf({
  required Vegetable candidate,
  required VegetableRepository repository,
  required Iterable<String> neighborPlantIds,
}) {
  final ids = neighborPlantIds.toSet();
  if (ids.isEmpty || ids.contains(candidate.id)) return false;
  final hints = companionBadHintsFor(
    repository: repository,
    plantIds: ids,
  );
  return plantMatchesCompanionHints(candidate, hints);
}
