import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'moestuin_companion_info.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_search_filters.dart';
import 'plant_section_details.dart';

enum PlantCombinationIllustration {
  goodNeighbors,
  badNeighbors,
  plantFamily,
  cropRotation,
  predecessors,
  successors,
  companions,
  pestPlants,
  soilImprovers,
  nitrogenFixers,
  greenManure,
  spaceSaving,
  benefits,
  mistakes,
}

class CombinationDetailBlock {
  const CombinationDetailBlock({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

class PlantCombinationSection {
  const PlantCombinationSection({
    required this.title,
    required this.summary,
    required this.illustration,
    required this.details,
    this.checklist,
  });

  final String title;
  final String summary;
  final PlantCombinationIllustration illustration;
  final List<CombinationDetailBlock> details;
  final List<String>? checklist;

  bool get hasDetailPage => details.isNotEmpty;
}

class PlantCombinationGuide {
  const PlantCombinationGuide({required this.sections});

  final List<PlantCombinationSection> sections;
}

PlantCombinationGuide combinationGuideForVegetable(Vegetable vegetable) {
  if (kMushroomPlantIds.contains(vegetable.id)) {
    return const PlantCombinationGuide(sections: []);
  }
  final built = _buildCombinationGuide(vegetable);
  return PlantCombinationGuide(
    sections: [
      for (final s in built.sections)
        PlantCombinationSection(
          title: s.title,
          summary: s.title.isEmpty
              ? s.summary
              : cropCardSummaryFor(
                  tab: 'combination',
                  title: s.title,
                  vegetable: vegetable,
                ),
          illustration: s.illustration,
          checklist: s.checklist,
          details: _mergeCombinationDetails(
            s.details,
            sectionDetailsFor(
              tab: 'combination',
              title: s.title,
              vegetable: vegetable,
            ),
          ),
        ),
    ],
  );
}

List<CombinationDetailBlock> _mergeCombinationDetails(
  List<CombinationDetailBlock> handWritten,
  List<PlantGuideDetailBlock> generated,
) {
  final existingHeadings = handWritten.map((b) => b.heading.toLowerCase()).toSet();
  final merged = [...handWritten];
  for (final g in generated) {
    if (!existingHeadings.contains(g.heading.toLowerCase()) && g.body.trim().isNotEmpty) {
      merged.add(CombinationDetailBlock(heading: g.heading, body: g.body));
    }
  }
  return merged;
}

List<String> _badNeighborsFor(Vegetable v) {
  final p = cropProfileFor(v.id);
  if (p.badNeighbors.isNotEmpty) return p.badNeighbors.take(4).toList();
  final id = v.id.toLowerCase();
  final fam = v.family.toLowerCase();
  final bad = <String>[];

  if (id.contains('tomaat') || id.contains('paprika') || id.contains('aardappel')) {
    bad.addAll(['Venkel', 'Aardappel naast tomaat (ziekte)']);
  }
  if (id.contains('boon') || id.contains('erwt')) {
    bad.addAll(['Ui en look', 'Prei (remt groei)']);
  }
  if (id.contains('kool') || fam.contains('kool')) {
    bad.addAll(['Aardbei', 'Tomaten (concurrentie)']);
  }
  if (id.contains('wortel') || fam.contains('wortel')) {
    bad.addAll(['Venkel', 'Pastinaak (wortelvlieg)']);
  }
  if (id.contains('sla') || fam.contains('sla')) {
    bad.add('Kool (zelfde plagen)');
  }
  if (id.contains('venkel')) {
    bad.addAll(['Tomaat', 'Boon', 'Ui']);
  }
  if (bad.isEmpty) {
    bad.addAll([
      'Te veel van dezelfde familie op één plek',
      'Zware concurrenten voor water en licht',
    ]);
  }
  return bad.take(4).toList();
}

List<String> _predecessorsFor(Vegetable v) {
  final fam = v.family.toLowerCase();
  if (fam.contains('kool')) {
    return ['Erwten of bonen', 'Sla of spinazie', 'Aardappel'];
  }
  if (fam.contains('wortel') || fam.contains('uien')) {
    return ['Koolgewassen', 'Bonen', 'Sla'];
  }
  if (fam.contains('peul')) {
    return ['Aardappel', 'Kool', 'Wortelgewassen'];
  }
  return ['Bonen of erwten (stikstof)', 'Groene bemester', 'Sla of spinazie'];
}

List<String> _successorsFor(Vegetable v) {
  final fam = v.family.toLowerCase();
  if (fam.contains('peul')) {
    return ['Kool', 'Sla', 'Wortel'];
  }
  if (fam.contains('kool')) {
    return ['Wortel', 'Ui', 'Sla'];
  }
  if (fam.contains('uien')) {
    return ['Wortel', 'Sla', 'Aardappel'];
  }
  return ['Sla of spinazie', 'Wortel', 'Ui of look'];
}

List<String> _rotationPlanFor(Vegetable v) {
  final fam = v.family.toLowerCase();
  if (fam.contains('kool')) {
    return ['Jaar 1: kool', 'Jaar 2: wortel', 'Jaar 3: ui', 'Jaar 4: peul'];
  }
  if (fam.contains('peul')) {
    return ['Jaar 1: peul', 'Jaar 2: kool', 'Jaar 3: wortel', 'Jaar 4: vrucht'];
  }
  return ['Jaar 1: blad', 'Jaar 2: wortel', 'Jaar 3: ui', 'Jaar 4: peul'];
}

List<String> _commonMistakesFor(Vegetable v) {
  final id = v.id.toLowerCase();
  final mistakes = <String>[];
  if (id.contains('tomaat')) {
    mistakes.add('Tomaat + aardappel (zelfde ziekten)');
  }
  if (id.contains('venkel') || id.contains('ui')) {
    mistakes.add('Venkel + ui (remmen elkaar)');
  }
  if (id.contains('boon')) {
    mistakes.add('Boon + ui (slechte combinatie)');
  }
  mistakes.addAll([
    'Zelfde familie jaar op jaar op één plek',
    'Te dicht planten zonder ruimte voor buren',
    'Geen bloei voor bestuivers in de buurt',
  ]);
  return mistakes.take(5).toList();
}

List<CombinationDetailBlock> _goodNeighborDetails(
  Vegetable v,
  MoestuinCompanionInfo? companion,
  List<String> goodLabels,
) {
  if (goodLabels.isEmpty) {
    return [
      const CombinationDetailBlock(
        heading: 'Algemene tips',
        body:
            'Plant ui, look en kruiden tussen rijen. Wissel families en geef elke plant genoeg licht en ruimte.',
      ),
      CombinationDetailBlock(
        heading: 'Voor ${v.nameNl}',
        body:
            'Kies buren met andere wortelsystemen en voedingsbehoeften dan ${v.family.toLowerCase()}.',
      ),
    ];
  }
  return [
    CombinationDetailBlock(
      heading: 'Goede buren voor ${v.nameNl}',
      body: goodLabels.join(', '),
    ),
    if (companion?.tip != null)
      CombinationDetailBlock(heading: 'Tip', body: companion!.tip!),
    const CombinationDetailBlock(
      heading: 'Waarom werkt dit?',
      body:
          'Goede buren helpen met plagen, bestuiving, schaduw of bodemverbetering zonder dezelfde ziekten te delen.',
    ),
  ];
}

PlantCombinationGuide _buildCombinationGuide(Vegetable v) {
  final companion = moestuinCompanionInfoForVegetable(v);
  final p = cropProfileFor(v.id);
  final goodLabels = p.goodNeighbors.isNotEmpty
      ? p.goodNeighbors
      : (companion?.goodNearLabels ?? const <String>[]);
  final goodSummary = goodLabels.isNotEmpty
      ? '${v.nameNl} groeit goed naast ${goodLabels.take(4).join(', ')}.'
      : 'Planten die elkaar helpen groeien door plagen te weren, bodem te verbeteren of ruimte slim te delen.';
  final bad = p.badNeighbors.isNotEmpty ? p.badNeighbors.take(4).toList() : _badNeighborsFor(v);
  final predecessors = p.predecessors.isNotEmpty ? p.predecessors : _predecessorsFor(v);
  final successors = p.successors.isNotEmpty ? p.successors : _successorsFor(v);
  final rotation = _rotationPlanFor(v);
  final mistakes = _commonMistakesFor(v);
  final isMeerjarig = p.key == CropProfileKey.fruitZaad || p.key == CropProfileKey.meerjarig;

  final companionsList = p.companions.isNotEmpty
      ? p.companions
      : (companion?.goodNearLabels ?? const <String>[]);
  final pestPlants = p.pestPlants.isNotEmpty
      ? p.pestPlants.join(', ')
      : 'Ui, look, afrikaantje, lavendel en goudsbloem';
  final soilImp = p.soilImprovers.isNotEmpty
      ? p.soilImprovers.join(', ')
      : 'Compost, groenbemesters en diepwortelende planten';
  final nFix = p.nitrogenFixers.isNotEmpty
      ? p.nitrogenFixers.join(', ')
      : 'Erwten, bonen, klaver en lupine';

  return PlantCombinationGuide(
    sections: [
      PlantCombinationSection(
        title: 'Goede buren',
        summary: goodSummary,
        illustration: PlantCombinationIllustration.goodNeighbors,
        details: _goodNeighborDetails(v, companion, goodLabels),
      ),
      PlantCombinationSection(
        title: 'Slechte buren',
        summary:
            '${v.nameNl} houdt niet van ${bad.take(2).join(' of ')} als directe buur.',
        illustration: PlantCombinationIllustration.badNeighbors,
        details: [
          CombinationDetailBlock(
            heading: 'Vermijd bij ${v.nameNl}',
            body: bad.join(', '),
          ),
          const CombinationDetailBlock(
            heading: 'Waarom vermijden?',
            body:
                'Slechte buren delen ziekten, remmen groei met stoffen in de bodem of concurreren om water, licht en voeding.',
          ),
          const CombinationDetailBlock(
            heading: 'Wat nu?',
            body:
                'Houd minstens één rij afstand, wissel van plek volgend seizoen of kies een andere buur in hetzelfde bed.',
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Plantfamilie',
        summary:
            '${v.nameNl} hoort bij ${v.family}. Verwanten delen plagen en voedingsbehoeften.',
        illustration: PlantCombinationIllustration.plantFamily,
        details: [
          CombinationDetailBlock(
            heading: 'Familie van ${v.nameNl}',
            body: p.plantFamilyHint.isNotEmpty ? p.plantFamilyHint : v.family,
          ),
          const CombinationDetailBlock(
            heading: 'Wat betekent dit?',
            body:
                'Verwanten hebben vergelijkbare wortels, ziekten en mestbehoefte. Wissel daarom niet te snel met directe familie op dezelfde plek.',
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Wisselteelt',
        summary: isMeerjarig
            ? '${v.nameNl} is meerjarig — kies een vaste plek met goede buren.'
            : 'Voorkom bodemuitputting door slim te wisselen na ${v.nameNl}.',
        illustration: PlantCombinationIllustration.cropRotation,
        details: [
          if (isMeerjarig)
            CombinationDetailBlock(
              heading: 'Meerjarige teelt',
              body:
                  '${v.nameNl} blijft meerdere jaren op dezelfde plek. '
                  'Bedrotatie is niet van toepassing — zorg voor goede bodembedekking en bemesting rondom.',
            )
          else ...[
            CombinationDetailBlock(
              heading: 'Voorstel voor jouw tuin',
              body: rotation.join(' → '),
            ),
            CombinationDetailBlock(
              heading: 'Vuistregel',
              body: p.rotationYears.isNotEmpty
                  ? p.rotationYears
                  : 'Laat minstens 3 jaar tussen dezelfde plantfamilie op één plek.',
            ),
          ],
        ],
      ),
      PlantCombinationSection(
        title: 'Goede voorgangers',
        summary: '${v.nameNl} profiteert van deze voorgangers in het bed.',
        illustration: PlantCombinationIllustration.predecessors,
        details: [
          CombinationDetailBlock(
            heading: 'Geschikt als voorganger',
            body: predecessors.join(', '),
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Goede opvolgers',
        summary: 'Na ${v.nameNl} gedijen deze planten goed op dezelfde plek.',
        illustration: PlantCombinationIllustration.successors,
        details: [
          CombinationDetailBlock(
            heading: 'Plant hierna',
            body: successors.join(', '),
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Gezelschapsplanten',
        summary:
            'Bloemen en kruiden die ${v.nameNl} beschermen en bestuivers aantrekken.',
        illustration: PlantCombinationIllustration.companions,
        details: [
          CombinationDetailBlock(
            heading: 'Aanbevolen bij ${v.nameNl}',
            body: companionsList.isNotEmpty
                ? companionsList.join(', ')
                : 'Afrikaantje, goudsbloem, basilicum, lavendel',
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Planten tegen plagen',
        summary:
            'Natuurlijke geurbarrières die plagen op afstand houden bij ${v.nameNl}.',
        illustration: PlantCombinationIllustration.pestPlants,
        details: [
          CombinationDetailBlock(
            heading: 'Sterke hulplanten',
            body: '$pestPlants — verjagen of verstoren veel plagen met geur en bloei.',
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Bodemverbeteraars',
        summary:
            'Verbeteren de bodemstructuur en vruchtbaarheid voor ${v.nameNl}.',
        illustration: PlantCombinationIllustration.soilImprovers,
        details: [
          CombinationDetailBlock(
            heading: 'Hoe helpen ze?',
            body: '$soilImp — diepe wortels en organisch materiaal verbeteren structuur en vochtbuffer.',
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Stikstofbinders',
        summary:
            'Peulgewassen halen stikstof uit de lucht voor ${v.nameNl}.',
        illustration: PlantCombinationIllustration.nitrogenFixers,
        details: [
          CombinationDetailBlock(
            heading: 'Voorbeelden',
            body: '$nFix als tussenteelt of groenbemester.',
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Groene bemesters',
        summary:
            'Zaai tussendoor voor een gezonde bodem rond ${v.nameNl}.',
        illustration: PlantCombinationIllustration.greenManure,
        details: [
          const CombinationDetailBlock(
            heading: 'Geschikt',
            body:
                'Mosterd, phacelia, graanmengsels en klaver — omspitten vóór zaadrijpheid.',
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Ruimtebesparing',
        summary:
            'Slim combineren voor meer oogst op hetzelfde oppervlak.',
        illustration: PlantCombinationIllustration.spaceSaving,
        details: [
          const CombinationDetailBlock(
            heading: 'Technieken',
            body:
                'Hoge + lage planten, snelle tussen- en langzame hoofdteelt, randen benutten met kruiden.',
          ),
        ],
      ),
      PlantCombinationSection(
        title: 'Combinatievoordelen',
        summary:
            'Alle voordelen van goede plantcombinaties met ${v.nameNl}.',
        illustration: PlantCombinationIllustration.benefits,
        checklist: const [
          'Minder plagen',
          'Meer bestuivers',
          'Betere groei',
          'Hogere opbrengst',
          'Minder waterverlies',
        ],
        details: [
          if (p.comboBenefits.isNotEmpty)
            CombinationDetailBlock(
              heading: 'Voor ${v.nameNl}',
              body: p.comboBenefits,
            )
          else if (companion != null && companion.benefits.isNotEmpty)
            CombinationDetailBlock(
              heading: 'Voor ${v.nameNl}',
              body: companion.atAGlance,
            )
          else
            const CombinationDetailBlock(
              heading: 'Waarom combineren?',
              body:
                  'Goede combinaties verminderen plagen, trekken bestuivers aan en benutten ruimte en bodem efficiënter.',
            ),
        ],
      ),
      PlantCombinationSection(
        title: 'Veelgemaakte combinatiefouten',
        summary:
            'Vermijd deze fouten bij ${v.nameNl} in jouw moestuin.',
        illustration: PlantCombinationIllustration.mistakes,
        details: [
          CombinationDetailBlock(
            heading: 'Let op',
            body: p.comboMistakes.isNotEmpty
                ? p.comboMistakes
                : mistakes.map((m) => '• $m').join('\n'),
          ),
        ],
      ),
    ],
  );
}
