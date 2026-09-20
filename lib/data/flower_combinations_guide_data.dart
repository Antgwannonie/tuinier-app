import '../models/vegetable.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'plant_guide_detail.dart';

const _asset = 'assets/images/flower_combinations';

class FlowerCombinationChip {
  const FlowerCombinationChip({required this.label, required this.imageAsset});

  final String label;
  final String imageAsset;
}

class FlowerCombinationSection {
  const FlowerCombinationSection({
    required this.title,
    required this.body,
    this.chips = const [],
    this.bullets = const [],
    this.benefits = const [],
    this.imageAsset,
    this.details = const [],
  });

  final String title;
  final String body;
  final List<FlowerCombinationChip> chips;
  final List<String> bullets;
  final List<String> benefits;
  final String? imageAsset;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerCombinationsGuideData {
  const FlowerCombinationsGuideData({
    required this.intro,
    required this.sections,
    required this.tip,
    required this.tipImage,
  });

  final String intro;
  final List<FlowerCombinationSection> sections;
  final String tip;
  final String tipImage;
}

/// @Deprecated Prefer [flowerCombinationsGuideForVegetable].
const flowerCombinationsGuideData = FlowerCombinationsGuideData(
  intro:
      'Slimme plantcombinaties zorgen voor minder plagen, betere groei en '
      'een mooiere, gezondere tuin.',
  sections: [],
  tip: 'Observeer, experimenteer en ontdek wat in jouw tuin het beste werkt!',
  tipImage: '$_asset/fcombo_tip.png',
);

String _chipSlug(String label) {
  return label
      .toLowerCase()
      .replaceAll('ë', 'e')
      .replaceAll('é', 'e')
      .replaceAll('ö', 'o')
      .replaceAll('ü', 'u')
      .replaceAll('ï', 'i')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

FlowerCombinationChip _chip(String label) {
  final slug = _chipSlug(label);
  return FlowerCombinationChip(
    label: label,
    imageAsset: '$_asset/fcombo_chip_$slug.png',
  );
}

List<FlowerCombinationChip> _chips(List<String> labels) =>
    [for (final l in labels) _chip(l)];

List<PlantGuideDetailBlock> _cd(
  Vegetable v,
  FlowerGuideProfile p,
  String title,
) =>
    flowerSectionDetailsFor(
      tab: 'combination',
      title: title,
      vegetable: v,
      profile: p,
    );

List<String> _voorgangerChips(FlowerGuideProfile p) {
  switch (p.key) {
    case FlowerProfileKey.greenManure:
      return const ['Vroege sla', 'Radijs', 'Spinazie', 'Andere groenbemester'];
    case FlowerProfileKey.companionPest:
      return const ['Groenbemester', 'Klaver', 'Bladgewas', 'Graan'];
    case FlowerProfileKey.annualCut:
      return const ['Groenbemester', 'Peulvrucht', 'Klaver', 'Compost'];
    case FlowerProfileKey.mediterranean:
      return const ['Magere grond', 'Grind drainage', 'Geen zware bemesting'];
    case FlowerProfileKey.herbBloom:
      return const ['Composthoop', 'Groenbemester', 'Licht blad'];
    default:
      return const ['Groenbemester', 'Klaver', 'Licht blad', 'Compost'];
  }
}

List<String> _opvolgerChips(FlowerGuideProfile p) {
  switch (p.key) {
    case FlowerProfileKey.greenManure:
      return const ['Groente', 'Aardappel', 'Kool', 'Snijbloemen'];
    case FlowerProfileKey.companionPest:
      return const ['Groenbemester', 'Klaver', 'Bladgewas'];
    case FlowerProfileKey.annualCut:
      return const ['Groenbemester', 'Klaver', 'Spinazie'];
    case FlowerProfileKey.mediterranean:
      return const ['Zelfde plek (meerjarig)', 'Salie', 'Tijm'];
    case FlowerProfileKey.herbBloom:
      return const ['Groenbemester', 'Klaver', 'Licht gewas'];
    default:
      return const ['Groenbemester', 'Klaver', 'Licht gewas', 'Compost'];
  }
}

List<String> _plaagChips(FlowerGuideProfile p) {
  final fromProfile = p.goodNeighbors.where((n) =>
    !['Sla', 'Tomaat', 'Kool', 'Wortel', 'Paprika', 'Mais', 'Komkommer', 'Boon', 'Pompoen', 'Courgette', 'Aardbei', 'Aardappel', 'Prei', 'Spinazie', 'Rucola'].contains(n)
  ).take(3).toList();
  if (fromProfile.length >= 2) return fromProfile;
  switch (p.key) {
    case FlowerProfileKey.companionPest:
      return const ['Tagetes', 'Goudsbloem', 'Knoflook'];
    case FlowerProfileKey.greenManure:
      return const ['Facelia', 'Mosterd', 'Klaver'];
    case FlowerProfileKey.mediterranean:
      return const ['Lavendel', 'Salie', 'Tijm'];
    case FlowerProfileKey.herbBloom:
      return const ['Munt', 'Basilicum', 'Dille'];
    default:
      return const ['Afrikaantje', 'Goudsbloem', 'Kruiden'];
  }
}

List<String> _bestuiverChips(FlowerGuideProfile p) {
  switch (p.key) {
    case FlowerProfileKey.companionPest:
      return const ['Goudsbloem', 'Cosmos', 'Komkommerkruid', 'Zonnehoed'];
    case FlowerProfileKey.greenManure:
      return const ['Facelia', 'Klaver', 'Boekweit', 'Bijenmengsel'];
    case FlowerProfileKey.mediterranean:
      return const ['Tijm', 'Salie', 'Hysop', 'Wilde marjolein'];
    case FlowerProfileKey.herbBloom:
      return const ['Dille', 'Koriander', 'Basilicum', 'Munt'];
    case FlowerProfileKey.pollinator:
      return const ['Zonnehoed', 'Monarda', 'Duizendblad', 'Cosmos'];
    case FlowerProfileKey.treeBloom:
      return const ['Lindebloesem', 'Bijenweide', 'Klaver'];
    default:
      return const ['Cosmos', 'Zonnehoed', 'Komkommerkruid', 'Facelia'];
  }
}

List<String> _foutChips(FlowerGuideProfile p) {
  final fromProfile = p.mistakes.take(3).toList();
  return [
    ...fromProfile,
    'Te dicht planten',
    'Zelfde familie op dezelfde plek',
    'Verkeerde standplaats',
  ].take(6).toList();
}

FlowerCombinationsGuideData flowerCombinationsGuideForVegetable(Vegetable v) {
  final p = flowerGuideProfileFor(v.id);
  final name = v.nameNl.split('(').first.trim();
  final good = p.goodNeighbors.isNotEmpty
      ? p.goodNeighbors
      : const ['Kruiden', 'Andere bloemen', 'Bodembedekkers'];
  final bad = p.badNeighbors.isNotEmpty
      ? p.badNeighbors
      : const ['Te dichte concurrenten'];
  final benefits = p.benefits.isNotEmpty
      ? p.benefits
      : const [
          'Minder plagen',
          'Betere groei',
          'Meer biodiversiteit',
          'Mooie, harmonieuze tuin',
        ];

  String sum(String title) => flowerCardSummaryFor(
        tab: 'combination',
        title: title,
        vegetable: v,
        profile: p,
      );

  return FlowerCombinationsGuideData(
    intro:
        'Slimme plantcombinaties met $name zorgen voor minder plagen, betere '
        'groei en een mooiere, gezondere tuin.',
    sections: [
      FlowerCombinationSection(
        title: 'Goede buren',
        body: sum('Goede buren'),
        chips: _chips(good),
        imageAsset: '$_asset/combo_good_neighbors.png',
        details: _cd(v, p, 'Goede buren'),
      ),
      FlowerCombinationSection(
        title: 'Slechte buren',
        body: sum('Slechte buren'),
        chips: _chips(bad),
        imageAsset: '$_asset/combo_bad_neighbors.png',
        details: _cd(v, p, 'Slechte buren'),
      ),
      FlowerCombinationSection(
        title: 'Plantfamilie',
        body: sum('Plantfamilie'),
        bullets: const [
          'Vergelijkbare standplaatsbehoeften',
          'Vaak dezelfde plagen of ziekten',
          'Wissel families op het bed',
        ],
        imageAsset: '$_asset/combo_plant_family.png',
        details: _cd(v, p, 'Plantfamilie'),
      ),
      FlowerCombinationSection(
        title: 'Wisselteelt',
        body: sum('Wisselteelt'),
        chips: _chips(const ['Verse grond', 'Minder ziekten', 'Betere bodem', 'Afwisseling']),
        imageAsset: '$_asset/combo_crop_rotation.png',
        details: _cd(v, p, 'Wisselteelt'),
      ),
      FlowerCombinationSection(
        title: 'Goede voorgangers',
        body: sum('Goede voorgangers'),
        chips: _chips(_voorgangerChips(p)),
        imageAsset: '$_asset/combo_predecessors.png',
        details: _cd(v, p, 'Goede voorgangers'),
      ),
      FlowerCombinationSection(
        title: 'Goede opvolgers',
        body: sum('Goede opvolgers'),
        chips: _chips(_opvolgerChips(p)),
        imageAsset: '$_asset/combo_successors.png',
        details: _cd(v, p, 'Goede opvolgers'),
      ),
      FlowerCombinationSection(
        title: 'Gezelschapsplanten',
        body: sum('Gezelschapsplanten'),
        chips: _chips(good.take(6).toList()),
        benefits: benefits,
        imageAsset: '$_asset/combo_companions.png',
        details: _cd(v, p, 'Gezelschapsplanten'),
      ),
      FlowerCombinationSection(
        title: 'Planten tegen plagen',
        body: sum('Planten tegen plagen'),
        chips: _chips(_plaagChips(p)),
        imageAsset: '$_asset/combo_pest_plants.png',
        details: _cd(v, p, 'Planten tegen plagen'),
      ),
      FlowerCombinationSection(
        title: 'Planten die bestuivers aantrekken',
        body: sum('Planten die bestuivers aantrekken'),
        chips: _chips(_bestuiverChips(p)),
        imageAsset: '$_asset/combo_pollinators.png',
        details: _cd(v, p, 'Planten die bestuivers aantrekken'),
      ),
      FlowerCombinationSection(
        title: 'Bodemverbeteraars',
        body: sum('Bodemverbeteraars'),
        chips: _chips(const ['Smeerwortel', 'Boekweit', 'Gele mosterd']),
        imageAsset: '$_asset/combo_soil_improvers.png',
        details: _cd(v, p, 'Bodemverbeteraars'),
      ),
      FlowerCombinationSection(
        title: 'Stikstofbinders',
        body: sum('Stikstofbinders'),
        chips: _chips(const ['Witte klaver', 'Lupine', 'Bonen', 'Erwten']),
        imageAsset: '$_asset/combo_nitrogen_fixers.png',
        details: _cd(v, p, 'Stikstofbinders'),
      ),
      FlowerCombinationSection(
        title: 'Groene bemesters',
        body: sum('Groene bemesters'),
        chips: _chips(const ['Phacelia', 'Gele mosterd', 'Rogge', 'Klaver']),
        imageAsset: '$_asset/combo_green_manure.png',
        details: _cd(v, p, 'Groene bemesters'),
      ),
      FlowerCombinationSection(
        title: 'Ruimtebesparing',
        body: sum('Ruimtebesparing'),
        chips: _chips(const [
          'Hoog + laag',
          'Rijen combineren',
          'Onderbeplanting',
        ]),
        benefits: const [
          'Meer planten op dezelfde ruimte',
          'Bodem blijft bedekt',
          'Onkruidgroei verminderen',
          'Betere opbrengst',
        ],
        imageAsset: '$_asset/combo_space_saving.png',
        details: _cd(v, p, 'Ruimtebesparing'),
      ),
      FlowerCombinationSection(
        title: 'Combinatievoordelen',
        body: sum('Combinatievoordelen'),
        chips: _chips(const [
          'Minder plagen en ziekten',
          'Meer bestuivers en nuttige insecten',
          'Betere bodemstructuur',
          'Meer bloei en bestuiving',
          'Ruimte efficiënt gebruiken',
          'Mooie, harmonieuze beplanting',
        ]),
        imageAsset: '$_asset/combo_benefits.png',
        details: _cd(v, p, 'Combinatievoordelen'),
      ),
      FlowerCombinationSection(
        title: 'Veelgemaakte combinatiefouten',
        body: sum('Veelgemaakte combinatiefouten'),
        chips: _chips(_foutChips(p)),
        imageAsset: '$_asset/combo_mistakes.png',
        details: _cd(v, p, 'Veelgemaakte combinatiefouten'),
      ),
    ],
    tip: p.tip.isNotEmpty
        ? p.tip
        : 'Observeer, experimenteer en ontdek wat bij $name in jouw tuin '
            'het beste werkt!',
    tipImage: '$_asset/fcombo_tip.png',
  );
}
