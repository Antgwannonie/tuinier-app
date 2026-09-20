import '../models/vegetable.dart';
import 'plant_combination_guide.dart';
import 'plant_search_filters.dart';

/// Advies voor een moestuinplan: buren, wisselteelt en ruimte.
class MoestuinPlanAdvice {
  const MoestuinPlanAdvice({
    required this.goodCompanions,
    required this.badNeighbors,
    required this.successors,
    required this.predecessors,
    required this.flowerCompanions,
    required this.layoutHints,
    required this.warnings,
  });

  final List<String> goodCompanions;
  final List<String> badNeighbors;
  final List<String> successors;
  final List<String> predecessors;
  final List<String> flowerCompanions;
  final List<String> layoutHints;
  final List<String> warnings;
}

/// Bouwt teeltadvies op basis van geselecteerde gewassen en optionele afmetingen.
MoestuinPlanAdvice buildMoestuinPlanAdvice({
  required List<Vegetable> selected,
  double? bedWidthCm,
  double? bedHeightCm,
}) {
  final good = <String>{};
  final bad = <String>{};
  final successors = <String>{};
  final predecessors = <String>{};
  final flowers = <String>{};
  final warnings = <String>[];
  final layoutHints = <String>[];

  for (final v in selected) {
    final guide = combinationGuideForVegetable(v);
    for (final section in guide.sections) {
      final title = section.title.toLowerCase();
      final chips = [
        ...section.details.map((d) => d.heading),
        ...?section.checklist,
      ];
      if (title.contains('goede buren') || title.contains('gezelschap')) {
        good.addAll(chips.take(4));
      }
      if (title.contains('slechte')) {
        bad.addAll(chips.take(4));
      }
      if (title.contains('opvolger') || title.contains('na oogst')) {
        successors.addAll(chips.take(4));
      }
      if (title.contains('voorganger')) {
        predecessors.addAll(chips.take(3));
      }
      if (title.contains('bestuiv') ||
          title.contains('bloem') ||
          title.contains('plaag')) {
        flowers.addAll(chips.take(3));
      }
    }

    // Heuristiek: nuttige bloemen bij groenten.
    if (kGroentePlantIds.contains(v.id) ||
        browseKindForPlant(v.id) == PlantBrowseKind.groente) {
      flowers.addAll(const [
        'Afrikaantje',
        'Goudsbloem',
        'Oost-Indische kers',
        'Lavendel',
      ]);
    }
  }

  // Conflicten binnen selectie (zelfde familie / bekende slechte paren).
  for (var i = 0; i < selected.length; i++) {
    for (var j = i + 1; j < selected.length; j++) {
      final a = selected[i];
      final b = selected[j];
      if (a.family.isNotEmpty &&
          a.family.toLowerCase() == b.family.toLowerCase() &&
          a.family.toLowerCase().contains('kool')) {
        warnings.add(
          '${a.nameNl} en ${b.nameNl} zijn beide koolfamilie — '
          'houd afstand of wissel volgend seizoen.',
        );
      }
      if (_isNightshade(a) && _isNightshade(b) && a.id != b.id) {
        warnings.add(
          '${a.nameNl} en ${b.nameNl} (nachtschade) beter niet pal naast elkaar.',
        );
      }
    }
  }

  if (bedWidthCm != null && bedHeightCm != null && bedWidthCm > 0) {
    final areaM2 = (bedWidthCm * bedHeightCm) / 10000;
    layoutHints.add(
      'Oppervlak ≈ ${areaM2.toStringAsFixed(1)} m² '
      '(${bedWidthCm.round()} × ${bedHeightCm.round()} cm).',
    );

    var usedCm = 0.0;
    for (final v in selected) {
      final spacing = v.spacingCm.toDouble().clamp(10, 120);
      final row = v.rowSpacingCm.toDouble().clamp(10, 120);
      final footprint = spacing * row;
      usedCm += footprint;
      final fitsAcross = (bedWidthCm / spacing).floor();
      final fitsAlong = (bedHeightCm / row).floor();
      final slots = (fitsAcross * fitsAlong).clamp(0, 999);
      if (slots <= 0) {
        warnings.add(
          '${v.nameNl} past krap: plantafstand ${spacing.round()} cm '
          'is groter dan de bak.',
        );
      } else {
        layoutHints.add(
          '${v.nameNl}: ca. $slots plantplek(ken) '
          '(${spacing.round()} × ${row.round()} cm).',
        );
      }
    }

    final bedAreaCm2 = bedWidthCm * bedHeightCm;
    if (usedCm > bedAreaCm2 * 1.15) {
      warnings.add(
        'Je selectie vraagt waarschijnlijk meer ruimte dan de bak — '
        'kies minder planten of een grotere bak.',
      );
    } else if (selected.isNotEmpty) {
      layoutHints.add(
        'Tip: zet hoge planten (mais, tomaten) aan de noordkant zodat '
        'lagere gewassen licht houden.',
      );
      layoutHints.add(
        'Na oogst van snelle teelt (sla, radijs) kun je direct een '
        'opvolger zaaien uit de wisselteelt-lijst.',
      );
    }
  } else if (selected.isNotEmpty) {
    layoutHints.add(
      'Voeg bakafmetingen toe (advanced) om te zien hoeveel planten '
      'naast elkaar passen.',
    );
  }

  if (flowers.isEmpty) {
    flowers.addAll(const ['Afrikaantje', 'Goudsbloem', 'Facelia']);
  }

  return MoestuinPlanAdvice(
    goodCompanions: good.take(8).toList(),
    badNeighbors: bad.take(8).toList(),
    successors: successors.take(8).toList(),
    predecessors: predecessors.take(6).toList(),
    flowerCompanions: flowers.take(6).toList(),
    layoutHints: layoutHints,
    warnings: warnings.take(6).toList(),
  );
}

bool _isNightshade(Vegetable v) {
  final id = v.id.toLowerCase();
  final fam = v.family.toLowerCase();
  return fam.contains('nachtschade') ||
      id.contains('tomaat') ||
      id.contains('paprika') ||
      id.contains('aubergine') ||
      id.contains('aardappel');
}
