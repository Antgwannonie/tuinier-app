import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

class ColonizationTimelineStage {
  const ColonizationTimelineStage({
    required this.label,
    required this.duration,
    required this.assetPath,
  });

  final String label;
  final String duration;
  final String assetPath;
}

class ColonizationProblem {
  const ColonizationProblem({
    required this.label,
    required this.assetPath,
  });

  final String label;
  final String assetPath;
}

class MushroomColonizationGuide with MushroomGuideCardData {
  const MushroomColonizationGuide({
    required this.whatIsBody,
    required this.temperature,
    required this.temperatureNote,
    required this.humidity,
    required this.humidityNote,
    required this.lightLabel,
    required this.lightBody,
    required this.ventilationLabel,
    required this.ventilationBody,
    required this.durationSummary,
    required this.timelineStages,
    required this.healthySigns,
    required this.fullColonizationBody,
    required this.mistakes,
    required this.problems,
    required this.footerTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String whatIsBody;
  final String temperature;
  final String temperatureNote;
  final String humidity;
  final String humidityNote;
  final String lightLabel;
  final String lightBody;
  final String ventilationLabel;
  final String ventilationBody;
  final String durationSummary;
  final List<ColonizationTimelineStage> timelineStages;
  final List<String> healthySigns;
  final String fullColonizationBody;
  final List<String> mistakes;
  final List<ColonizationProblem> problems;
  final String footerTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_colonization';

const _timelineStages = [
  ColonizationTimelineStage(
    label: 'Start',
    duration: 'Dag 1',
    assetPath: '$_asset/colonization_stage_start.png',
  ),
  ColonizationTimelineStage(
    label: '25%',
    duration: 'Dag 3–5',
    assetPath: '$_asset/colonization_stage_25.png',
  ),
  ColonizationTimelineStage(
    label: '75%',
    duration: 'Dag 7–14',
    assetPath: '$_asset/colonization_stage_75.png',
  ),
  ColonizationTimelineStage(
    label: 'Volledig',
    duration: 'Dag 14–21',
    assetPath: '$_asset/colonization_stage_full.png',
  ),
];

const _problems = [
  ColonizationProblem(
    label: 'Langzame groei',
    assetPath: '$_asset/colonization_problem_slow.png',
  ),
  ColonizationProblem(
    label: 'Verkleuringen',
    assetPath: '$_asset/colonization_problem_discolor.png',
  ),
  ColonizationProblem(
    label: 'Natte plekken',
    assetPath: '$_asset/colonization_problem_wet.png',
  ),
  ColonizationProblem(
    label: 'Geen groei',
    assetPath: '$_asset/colonization_problem_nogrowth.png',
  ),
];

MushroomColonizationGuide colonizationGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final style = _colonStyleFor(vegetable.id);

  final durationSummary = overview.stages.length > 1
      ? 'Gemiddeld ${overview.stages[1].duration}'
      : 'Gemiddeld 7–21 dagen';

  final lightLabel = style == _ColonStyle.compost ? 'Donker' : 'Donker';
  final lightBody = switch (style) {
    _ColonStyle.compost =>
      'Kolonisatie gebeurt het best in volledige duisternis. Licht remt de groei van champignons.',
    _ColonStyle.outdoor =>
      'Donker of indirect licht; mycelium groeit onder de mulchlaag in het bed.',
    _ColonStyle.woodBlock =>
      'Donker bewaren in een schone ruimte. Geen direct zonlicht op het houtblok.',
    _ColonStyle.indoorKit =>
      'Donker of indirect licht tijdens kolonisatie. Sluit de growkit af en zet hem weg uit het licht.',
  };

  final ventilationLabel = switch (style) {
    _ColonStyle.outdoor => 'Laag',
    _ColonStyle.woodBlock => 'Laag',
    _ColonStyle.compost => 'Laag',
    _ColonStyle.indoorKit => 'Laag',
  };

  final ventilationBody = switch (style) {
    _ColonStyle.outdoor =>
      'Minimale luchtuitwisseling volstaat. Bescherm het bed tegen harde wind.',
    _ColonStyle.woodBlock =>
      'Minimale luchtuitwisseling volstaat. Te veel tocht droogt het houtblok uit.',
    _ColonStyle.compost =>
      'Minimale luchtuitwisseling. Te veel ventilatie droogt de compost uit.',
    _ColonStyle.indoorKit =>
      'Minimale luchtuitwisseling volstaat. Filteropeningen laten genoeg lucht door.',
  };

  final temperatureNote = switch (style) {
    _ColonStyle.outdoor =>
      'Vermijd temperaturen onder 10 °C of boven 28 °C in het bed.',
    _ColonStyle.woodBlock =>
      'Vermijd temperaturen onder 18 °C of boven 28 °C tijdens kolonisatie.',
    _ColonStyle.compost =>
      'Vermijd temperaturen onder 18 °C of boven 28 °C in de compost.',
    _ColonStyle.indoorKit =>
      'Vermijd temperaturen onder 18 °C of boven 28 °C in de kweekruimte.',
  };

  final fullColonizationBody = switch (style) {
    _ColonStyle.woodBlock =>
      'Het houtblok is volledig wit en voelt stevig aan. Geen bruine plekken meer zichtbaar — dan is $name klaar voor de volgende fase.',
    _ColonStyle.outdoor =>
      'Het substraat onder de mulch is gelijkmatig wit en stevig. Geen bruine plekken — dan is kolonisatie van $name voltooid.',
    _ColonStyle.compost =>
      'De compost is volledig wit en voelt compact aan. Geen bruine plekken meer — dan kun je de casinglaag aanbrengen.',
    _ColonStyle.indoorKit =>
      'Het substraat is volledig wit en voelt stevig aan. Geen bruine plekken meer zichtbaar — dan kun je de growkit openen.',
  };

  return MushroomColonizationGuide(
    whatIsBody:
        'Kolonisatie is de fase waarin het mycelium zich door het substraat verspreidt. Het witte netwerk groeit uit tot het hele substraat is overwoekerd. Voor $name duurt dit gemiddeld ${overview.stages.length > 1 ? overview.stages[1].duration : '7–21 dagen'}.',
    temperature: overview.temperature,
    temperatureNote: temperatureNote,
    humidity: overview.humidity,
    humidityNote: 'Houd het substraat gelijkmatig vochtig voor gezonde groei.',
    lightLabel: lightLabel,
    lightBody: lightBody,
    ventilationLabel: ventilationLabel,
    ventilationBody: ventilationBody,
    durationSummary: durationSummary,
    timelineStages: _timelineStages,
    healthySigns: const [
      'Wit en helder van kleur',
      'Stevig en dicht netwerk',
      'Gelijkmatige groei',
      'Aangename, aardse geur',
    ],
    fullColonizationBody: fullColonizationBody,
    mistakes: const [
      'Temperatuur te hoog of te laag',
      'Te veel ventilatie',
      'Substraat te nat of te droog',
      'Besmet broed gebruikt',
      'Te vaak controleren',
    ],
    problems: _problems,
    footerTip:
        'Rust en stabiliteit zijn de sleutel! Laat het mycelium ongestoord zijn werk doen.',
    cardSummaries: mushroomCardSummaries(
      tab: 'colonization',
      vegetable: vegetable,
      titles: const [
        'Wat is kolonisatie?',
        'Ideale omstandigheden',
        'Kolonisatieduur',
        'Gezond mycelium herkennen',
        'Volledige kolonisatie herkennen',
        'Groei controleren',
        'Problemen tijdens kolonisatie',
        'Veelgemaakte fouten',
      ],
    ),
    cardDetails: {
      'Wat is kolonisatie?': mushroomDetailBlocks(
        fullBody:
            'Kolonisatie is de fase waarin het mycelium zich door het substraat verspreidt. Het witte netwerk groeit uit tot het hele substraat is overwoekerd. Voor $name duurt dit gemiddeld ${overview.stages.length > 1 ? overview.stages[1].duration : '7–21 dagen'}.',
      ),
      'Ideale omstandigheden': [
        PlantGuideDetailBlock(heading: 'Temperatuur', body: '${overview.temperature}\n$temperatureNote'),
        PlantGuideDetailBlock(heading: 'Luchtvochtigheid', body: '${overview.humidity}\nHoud het substraat gelijkmatig vochtig voor gezonde groei.'),
        PlantGuideDetailBlock(heading: lightLabel, body: lightBody),
        PlantGuideDetailBlock(heading: 'Ventilatie ($ventilationLabel)', body: ventilationBody),
      ],
      'Kolonisatieduur': mushroomDetailBlocks(fullBody: durationSummary),
      'Gezond mycelium herkennen': mushroomDetailBlocks(
        fullBody: const [
          'Wit en helder van kleur',
          'Stevig en dicht netwerk',
          'Gelijkmatige groei',
          'Aangename, aardse geur',
        ].map((s) => '• $s').join('\n'),
      ),
      'Volledige kolonisatie herkennen':
          mushroomDetailBlocks(fullBody: fullColonizationBody),
      'Groei controleren': [
        for (final s in _timelineStages)
          PlantGuideDetailBlock(heading: '${s.label} (${s.duration})', body: 'Controleer visueel, voel en ruik tijdens deze fase.'),
      ],
      'Problemen tijdens kolonisatie': [
        for (final p in _problems)
          PlantGuideDetailBlock(heading: p.label, body: 'Herken en los dit probleem op tijdens kolonisatie.'),
      ],
      'Veelgemaakte fouten': mushroomDetailBlocks(
        fullBody: const [
          'Temperatuur te hoog of te laag',
          'Te veel ventilatie',
          'Substraat te nat of te droog',
          'Besmet broed gebruikt',
          'Te vaak controleren',
        ].map((m) => '• $m').join('\n'),
      ),
    },
  );
}

enum _ColonStyle { indoorKit, woodBlock, compost, outdoor }

_ColonStyle _colonStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _ColonStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _ColonStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _ColonStyle.outdoor;
    default:
      return _ColonStyle.indoorKit;
  }
}
