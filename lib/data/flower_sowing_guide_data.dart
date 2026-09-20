import '../models/vegetable.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'moestuin_companion_info.dart';
import 'plant_guide_detail.dart';
import 'plant_sowing_guide.dart';

class FlowerSowingDetail {
  FlowerSowingDetail({
    required this.label,
    required this.value,
    required this.description,
    required this.imageAsset,
    this.details = const [],
  });

  final String label;
  final String value;
  final String description;
  final String imageAsset;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerSowingStep {
  FlowerSowingStep({
    required this.title,
    required this.imageAsset,
  });

  final String title;
  final String imageAsset;
}

class FlowerSowingGuide {
  FlowerSowingGuide({
    required this.intro,
    required this.tip,
    required this.indoorMonths,
    required this.outdoorMonths,
    required this.kiemduur,
    required this.kiemtemperatuur,
    required this.details,
    required this.steps,
    required this.mistakes,
    this.mistakesDetails = const [],
    this.kiemduurDetails = const [],
    this.kiemtempDetails = const [],
    this.indoorDetails = const [],
    this.outdoorDetails = const [],
  });

  final String intro;
  final String tip;
  final Set<int> indoorMonths;
  final Set<int> outdoorMonths;
  final String kiemduur;
  final String kiemtemperatuur;
  final List<FlowerSowingDetail> details;
  final List<FlowerSowingStep> steps;
  final List<String> mistakes;
  final List<PlantGuideDetailBlock> mistakesDetails;
  final List<PlantGuideDetailBlock> kiemduurDetails;
  final List<PlantGuideDetailBlock> kiemtempDetails;
  final List<PlantGuideDetailBlock> indoorDetails;
  final List<PlantGuideDetailBlock> outdoorDetails;
}

const _flowerSowingAsset = 'assets/images/flower_sowing';

List<PlantGuideDetailBlock> _sd(
  Vegetable v,
  FlowerGuideProfile p,
  String title,
) =>
    flowerSectionDetailsFor(
      tab: 'sowing',
      title: title,
      vegetable: v,
      profile: p,
    );

FlowerSowingGuide flowerSowingGuideForVegetable(Vegetable vegetable) {
  if (vegetable.id == 'lavendel') {
    return _attachSowingDetails(_lavendelSowingGuideBase, vegetable);
  }
  return _buildFlowerSowingGuide(vegetable);
}

FlowerSowingGuide _attachSowingDetails(
  FlowerSowingGuide base,
  Vegetable vegetable,
) {
  final p = flowerGuideProfileFor(vegetable.id);
  return FlowerSowingGuide(
    intro: base.intro,
    tip: base.tip,
    indoorMonths: base.indoorMonths,
    outdoorMonths: base.outdoorMonths,
    kiemduur: base.kiemduur,
    kiemtemperatuur: base.kiemtemperatuur,
    details: [
      for (final d in base.details)
        FlowerSowingDetail(
          label: d.label,
          value: d.value,
          description: d.description,
          imageAsset: d.imageAsset,
          details: _sd(vegetable, p, d.label),
        ),
    ],
    steps: base.steps,
    mistakes: base.mistakes,
    mistakesDetails: _sd(vegetable, p, 'Veelgemaakte fouten'),
    kiemduurDetails: _sd(vegetable, p, 'Kiemduur'),
    kiemtempDetails: _sd(vegetable, p, 'Kiemtemperatuur'),
    indoorDetails: _sd(vegetable, p, 'Binnen zaaien'),
    outdoorDetails: _sd(vegetable, p, 'Buiten zaaien'),
  );
}

final _lavendelSowingGuideBase = FlowerSowingGuide(
  intro:
      'Lavendel zaai je het best binnen van februari tot april. '
      'Buiten kan vanaf mei, maar kieming duurt dan langer.',
  tip:
      'Lavendel kiemt langzaam en onregelmatig. Hou zaad warm (18–22 °C) en '
      'licht vochtig; zaai oppervlakkig (lichtkiemer).',
  indoorMonths: {2, 3, 4},
  outdoorMonths: {5, 6},
  kiemduur: '14–30 dagen',
  kiemtemperatuur: '18–22 °C',
  details: [
    FlowerSowingDetail(
      label: 'Zaaidiepte',
      value: '0,5 cm · oppervlakkig',
      description: 'Zaai lavendel oppervlakkig; het is een lichtkiemer.',
      imageAsset: '$_flowerSowingAsset/flower_sowing_depth.png',
    ),
    FlowerSowingDetail(
      label: 'Licht tijdens kieming',
      value: 'Lichtkiemer · veel licht',
      description: 'Bedek het zaad niet; plaats op een lichte, warme plek.',
      imageAsset: '$_flowerSowingAsset/flower_sowing_light.png',
    ),
    FlowerSowingDetail(
      label: 'Water tijdens kieming',
      value: 'Licht vochtig · niet nat',
      description: 'Houd de grond gelijkmatig vochtig zonder natte plekken.',
      imageAsset: '$_flowerSowingAsset/flower_sowing_water.png',
    ),
    FlowerSowingDetail(
      label: 'Verspenen',
      value: 'Na 2–4 echte bladjes',
      description: 'Verplant zaailingen in aparte potjes voor meer ruimte.',
      imageAsset: '$_flowerSowingAsset/flower_sowing_prick_out.png',
    ),
    FlowerSowingDetail(
      label: 'Oppotten',
      value: 'Bij ± 10 cm hoogte',
      description: 'Verpot wanneer de wortels de pot uitgroeien.',
      imageAsset: '$_flowerSowingAsset/flower_sowing_pot_up.png',
    ),
    FlowerSowingDetail(
      label: 'Afharden',
      value: '1–2 weken voor uitplant',
      description: 'Laat planten wennen aan buitenlucht en temperatuur.',
      imageAsset: '$_flowerSowingAsset/flower_sowing_hardening.png',
    ),
  ],
  steps: [
    FlowerSowingStep(
      title: 'Bak vullen met grond',
      imageAsset: '$_flowerSowingAsset/flower_sowing_step_1_tray.png',
    ),
    FlowerSowingStep(
      title: 'Zaad uitstrooien',
      imageAsset: '$_flowerSowingAsset/flower_sowing_step_2_seeds.png',
    ),
    FlowerSowingStep(
      title: 'Besproeien met water',
      imageAsset: '$_flowerSowingAsset/flower_sowing_step_3_water.png',
    ),
    FlowerSowingStep(
      title: 'Warme, lichte plek',
      imageAsset: '$_flowerSowingAsset/flower_sowing_step_4_cover.png',
    ),
    FlowerSowingStep(
      title: 'Zaailingen kiemen',
      imageAsset: '$_flowerSowingAsset/flower_sowing_step_5_seedlings.png',
    ),
  ],
  mistakes: [
    'Te diep zaaien — lavendel is een lichtkiemer.',
    'Te nat houden — zaad kan gaan schimmelen.',
    'Te koud zaaien — kieming stokt onder 15 °C.',
    'Te vroeg buiten zetten — jonge planten zijn vorstgevoelig.',
    'Te dicht zaaien — verspenen op tijd voor luchtige zaailingen.',
  ],
);

FlowerSowingGuide _buildFlowerSowingGuide(Vegetable vegetable) {
  final p = flowerGuideProfileFor(vegetable.id);
  final sowing = sowingGuideForVegetable(vegetable);
  final companion = moestuinCompanionInfoForVegetable(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();

  final prickOut = _sectionValue(sowing, 'Verspenen');
  final potUp = _sectionValue(sowing, 'Oppotten');
  final water = _sectionValue(sowing, 'Water tijdens kieming');

  final tip = companion?.whenToPlant.trim().isNotEmpty == true
      ? companion!.whenToPlant
      : (p.tip.isNotEmpty
          ? p.tip
          : 'Zaai niet te diep en houd de grond gelijkmatig vochtig tot de kieming.');

  return FlowerSowingGuide(
    intro:
        'Alles over zaaien van ${name.toLowerCase()}: wanneer, hoe diep en '
        'wat je nodig hebt voor een goede start.',
    tip: tip,
    indoorMonths: p.sowIndoorMonths.isNotEmpty
        ? p.sowIndoorMonths
        : _monthsForSection(sowing, 'Binnen zaaien'),
    outdoorMonths: p.sowOutdoorMonths.isNotEmpty
        ? p.sowOutdoorMonths
        : _monthsForSection(sowing, 'Buiten zaaien'),
    kiemduur: p.kiemduur.isNotEmpty ? p.kiemduur : '5–14 dagen',
    kiemtemperatuur: p.kiemtemp.isNotEmpty ? p.kiemtemp : '18–24 °C',
    details: [
      FlowerSowingDetail(
        label: 'Zaaidiepte',
        value: p.sowDepth.isNotEmpty ? p.sowDepth : 'Niet te diep',
        description: flowerCardSummaryFor(
          tab: 'sowing',
          title: 'Zaaidiepte',
          vegetable: vegetable,
          profile: p,
        ),
        imageAsset: '$_flowerSowingAsset/flower_sowing_depth.png',
        details: _sd(vegetable, p, 'Zaaidiepte'),
      ),
      FlowerSowingDetail(
        label: 'Licht tijdens kieming',
        value: p.sowLight.isNotEmpty ? p.sowLight : 'Lichte, warme plek',
        description: flowerCardSummaryFor(
          tab: 'sowing',
          title: 'Licht tijdens kieming',
          vegetable: vegetable,
          profile: p,
        ),
        imageAsset: '$_flowerSowingAsset/flower_sowing_light.png',
        details: _sd(vegetable, p, 'Licht tijdens kieming'),
      ),
      FlowerSowingDetail(
        label: 'Water tijdens kieming',
        value: water.isNotEmpty ? water : 'Licht vochtig houden',
        description: flowerCardSummaryFor(
          tab: 'sowing',
          title: 'Water tijdens kieming',
          vegetable: vegetable,
          profile: p,
        ),
        imageAsset: '$_flowerSowingAsset/flower_sowing_water.png',
        details: _sd(vegetable, p, 'Water tijdens kieming'),
      ),
      FlowerSowingDetail(
        label: 'Verspenen',
        value: prickOut.isNotEmpty ? prickOut : 'Na 2–4 echte bladjes',
        description: flowerCardSummaryFor(
          tab: 'sowing',
          title: 'Verspenen',
          vegetable: vegetable,
          profile: p,
        ),
        imageAsset: '$_flowerSowingAsset/flower_sowing_prick_out.png',
        details: _sd(vegetable, p, 'Verspenen'),
      ),
      FlowerSowingDetail(
        label: 'Oppotten',
        value: potUp.isNotEmpty ? potUp : 'Bij volle wortels',
        description: flowerCardSummaryFor(
          tab: 'sowing',
          title: 'Oppotten',
          vegetable: vegetable,
          profile: p,
        ),
        imageAsset: '$_flowerSowingAsset/flower_sowing_pot_up.png',
        details: _sd(vegetable, p, 'Oppotten'),
      ),
      FlowerSowingDetail(
        label: 'Afharden',
        value: '1–2 weken voor uitplant',
        description: flowerCardSummaryFor(
          tab: 'sowing',
          title: 'Afharden',
          vegetable: vegetable,
          profile: p,
        ),
        imageAsset: '$_flowerSowingAsset/flower_sowing_hardening.png',
        details: _sd(vegetable, p, 'Afharden'),
      ),
    ],
    steps: [
      FlowerSowingStep(
        title: 'Bak vullen met grond',
        imageAsset: '$_flowerSowingAsset/flower_sowing_step_1_tray.png',
      ),
      FlowerSowingStep(
        title: 'Zaad uitstrooien',
        imageAsset: '$_flowerSowingAsset/flower_sowing_step_2_seeds.png',
      ),
      FlowerSowingStep(
        title: 'Besproeien met water',
        imageAsset: '$_flowerSowingAsset/flower_sowing_step_3_water.png',
      ),
      FlowerSowingStep(
        title: 'Warme, lichte plek',
        imageAsset: '$_flowerSowingAsset/flower_sowing_step_4_cover.png',
      ),
      FlowerSowingStep(
        title: 'Zaailingen kiemen',
        imageAsset: '$_flowerSowingAsset/flower_sowing_step_5_seedlings.png',
      ),
    ],
    mistakes: p.mistakes.isNotEmpty
        ? p.mistakes
        : _defaultSowingMistakes(vegetable),
    mistakesDetails: _sd(vegetable, p, 'Veelgemaakte fouten'),
    kiemduurDetails: _sd(vegetable, p, 'Kiemduur'),
    kiemtempDetails: _sd(vegetable, p, 'Kiemtemperatuur'),
    indoorDetails: _sd(vegetable, p, 'Binnen zaaien'),
    outdoorDetails: _sd(vegetable, p, 'Buiten zaaien'),
  );
}

String _sectionValue(PlantSowingGuide guide, String title) {
  for (final section in guide.sections) {
    if (section.title == title) return section.summary.trim();
  }
  return '';
}

Set<int> _monthsForSection(PlantSowingGuide guide, String title) {
  for (final section in guide.sections) {
    if (section.title == title && section.sowMonths != null) {
      return section.sowMonths!;
    }
  }
  return const {};
}

List<String> _defaultSowingMistakes(Vegetable vegetable) {
  final issues = vegetable.commonIssues.toLowerCase();
  final mistakes = <String>[
    'Te diep zaaien — veel bloemzaden zijn lichtkiemers.',
    'Te nat houden — zaad kan gaan schimmelen.',
    'Te dicht zaaien — verspenen op tijd voor gezonde zaailingen.',
  ];
  if (issues.contains('vorst') ||
      vegetable.care.toLowerCase().contains('vorst')) {
    mistakes.add('Te vroeg buiten zetten — bescherm jonge planten tegen kou.');
  }
  mistakes.add('Te weinig licht — zaailingen worden lang en slappig.');
  return mistakes;
}
