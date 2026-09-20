import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

class FruitingFactor {
  const FruitingFactor({
    required this.title,
    required this.value,
    required this.body,
    this.assetPath,
    this.useCalendarIcon = false,
    this.useThermometerIcon = false,
    this.useHumidityIcon = false,
    this.useSunIcon = false,
    this.useFanIcon = false,
    this.useCo2Icon = false,
    this.useClockIcon = false,
  });

  final String title;
  final String value;
  final String body;
  final String? assetPath;
  final bool useCalendarIcon;
  final bool useThermometerIcon;
  final bool useHumidityIcon;
  final bool useSunIcon;
  final bool useFanIcon;
  final bool useCo2Icon;
  final bool useClockIcon;
}

class FruitingTimelineStage {
  const FruitingTimelineStage({
    required this.label,
    required this.duration,
    required this.assetPath,
  });

  final String label;
  final String duration;
  final String assetPath;
}

class FruitingStimulateAction {
  const FruitingStimulateAction({
    required this.label,
    this.useWaterIcon = false,
    this.useFanIcon = false,
    this.useThermometerIcon = false,
    this.useSunIcon = false,
    this.useCo2Icon = false,
  });

  final String label;
  final bool useWaterIcon;
  final bool useFanIcon;
  final bool useThermometerIcon;
  final bool useSunIcon;
  final bool useCo2Icon;
}

class FruitingProblem {
  const FruitingProblem({
    required this.title,
    required this.body,
    required this.assetPath,
  });

  final String title;
  final String body;
  final String assetPath;
}

class MushroomFruitingGuide with MushroomGuideCardData {
  const MushroomFruitingGuide({
    required this.whatIsBody,
    required this.factors,
    required this.timelineStages,
    required this.stimulateActions,
    required this.problems,
    required this.footerTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String whatIsBody;
  final List<FruitingFactor> factors;
  final List<FruitingTimelineStage> timelineStages;
  final List<FruitingStimulateAction> stimulateActions;
  final List<FruitingProblem> problems;
  final String footerTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_fruiting';

const _timelineStages = [
  FruitingTimelineStage(
    label: 'Pinhead',
    duration: 'Dag 1–3',
    assetPath: '$_asset/fruiting_stage_pinhead.png',
  ),
  FruitingTimelineStage(
    label: 'Kleine knoppen',
    duration: 'Dag 4–6',
    assetPath: '$_asset/fruiting_stage_small.png',
  ),
  FruitingTimelineStage(
    label: 'Jonge paddenstoelen',
    duration: 'Dag 7–10',
    assetPath: '$_asset/fruiting_stage_young.png',
  ),
  FruitingTimelineStage(
    label: 'Volgroeide paddenstoelen',
    duration: 'Dag 11–14+',
    assetPath: '$_asset/fruiting_stage_mature.png',
  ),
];

const _problems = [
  FruitingProblem(
    title: 'Geen pinheads',
    body: 'Te hoog CO₂, verkeerde temperatuur of onvolledige kolonisatie.',
    assetPath: '$_asset/fruiting_problem_no_pins.png',
  ),
  FruitingProblem(
    title: 'Langzame groei',
    body: 'Temperatuur te laag of onvoldoende frisse lucht.',
    assetPath: '$_asset/fruiting_problem_slow.png',
  ),
  FruitingProblem(
    title: 'Misvormde paddenstoelen',
    body: 'Te weinig ventilatie of temperatuurschommelingen.',
    assetPath: '$_asset/fruiting_problem_deformed.png',
  ),
  FruitingProblem(
    title: 'Te droog of te nat',
    body: 'Onstabiele luchtvochtigheid remt pinhead-vorming.',
    assetPath: '$_asset/fruiting_problem_moisture.png',
  ),
];

MushroomFruitingGuide fruitingGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final style = _fruitingStyleFor(vegetable.id);

  final whenStart = switch (style) {
    _FruitingStyle.woodBlock =>
      'Na volledige kolonisatie: koel schok (5–10 °C lager) en verhoog luchtvochtigheid.',
    _FruitingStyle.compost =>
      'Na casinglaag en volledige kolonisatie: verlaag temperatuur licht en geef frisse lucht.',
    _FruitingStyle.outdoor =>
      'Na regenperiodes in late zomer/herfst; natuurlijke temperatuurdaling stimuleert vruchtzetting.',
    _FruitingStyle.indoorKit =>
      'Snijd de growkit open, vernevel 2–3× per dag en geef frisse lucht (CO₂ afvoeren).',
  };

  final harvestTime = overview.stages.length > 2
      ? overview.stages[2].duration
      : '7–14 dagen na pinheads';

  final factors = [
    FruitingFactor(
      title: 'Wanneer start het?',
      value: 'Start',
      body: whenStart,
      useCalendarIcon: true,
    ),
    FruitingFactor(
      title: 'Pinheads herkennen',
      value: 'Pinheads',
      body:
          'Kleine knobbeltjes verschijnen 3–7 dagen na openen van de kit of na een koelschok.',
      assetPath: '$_asset/fruiting_pinheads.png',
    ),
    FruitingFactor(
      title: 'Ideale temperatuur',
      value: overview.temperature.split(' ').first,
      body: 'Ideaal bereik voor vruchtzetting van $name.',
      useThermometerIcon: true,
    ),
    FruitingFactor(
      title: 'Ideale luchtvochtigheid',
      value: overview.humidity,
      body: 'Houd stabiel hoog tijdens pinhead-vorming.',
      useHumidityIcon: true,
    ),
    FruitingFactor(
      title: 'Lichtbehoefte',
      value: _lightShort(overview.light),
      body: overview.light,
      useSunIcon: true,
    ),
    FruitingFactor(
      title: 'Ventilatie',
      value: overview.ventilation,
      body:
          'Frisse lucht is essentieel — te weinig ventilatie geeft lange, dunne vruchtlichamen.',
      useFanIcon: true,
    ),
    FruitingFactor(
      title: 'CO₂-behoefte',
      value: 'Laag',
      body: 'Laag CO₂ (< 1000 ppm) stimuleert vruchtzetting bij $name.',
      useCo2Icon: true,
    ),
    FruitingFactor(
      title: 'Tijd tot eerste oogst',
      value: harvestTime,
      body: 'Van pinhead tot eerste oogst, afhankelijk van omstandigheden.',
      useClockIcon: true,
    ),
  ];

  return MushroomFruitingGuide(
    whatIsBody:
        'Vruchtvorming is de fase waarin pinheads uitgroeien tot oogstbare paddenstoelen. Voor $name zijn stabiele luchtvochtigheid, frisse lucht en de juiste temperatuur cruciaal.',
    factors: factors,
    timelineStages: _timelineStages,
    stimulateActions: const [
      FruitingStimulateAction(
        label: 'Verhoog de luchtvochtigheid',
        useWaterIcon: true,
      ),
      FruitingStimulateAction(
        label: 'Zorg voor voldoende verse lucht',
        useFanIcon: true,
      ),
      FruitingStimulateAction(
        label: 'Houd de temperatuur stabiel',
        useThermometerIcon: true,
      ),
      FruitingStimulateAction(
        label: 'Geef indirect licht',
        useSunIcon: true,
      ),
      FruitingStimulateAction(
        label: 'Verlaag de CO₂-concentratie',
        useCo2Icon: true,
      ),
    ],
    problems: _problems,
    footerTip:
        'Geduld en stabiliteit zijn de sleutel! Observeer dagelijks en pas kleine stappen aan in plaats van grote schommelingen.',
    cardSummaries: mushroomCardSummaries(
      tab: 'fruiting',
      vegetable: vegetable,
      titles: const [
        'Wat is vruchtvorming?',
        'Omstandigheden',
        'Van pinhead tot oogst',
        'Vruchtvorming stimuleren',
        'Problemen bij vruchtvorming',
      ],
    ),
    cardDetails: {
      'Wat is vruchtvorming?': mushroomDetailBlocks(
        fullBody:
            'Vruchtvorming is de fase waarin pinheads uitgroeien tot oogstbare paddenstoelen. Voor $name zijn stabiele luchtvochtigheid, frisse lucht en de juiste temperatuur cruciaal.',
      ),
      'Omstandigheden': [
        for (final f in factors)
          PlantGuideDetailBlock(heading: f.title, body: '${f.value}\n${f.body}'),
      ],
      'Van pinhead tot oogst': [
        for (final s in _timelineStages)
          PlantGuideDetailBlock(heading: '${s.label} (${s.duration})', body: 'Groei-fase van pinhead tot oogstbare paddenstoel.'),
      ],
      'Vruchtvorming stimuleren': mushroomDetailBlocks(
        fullBody: const [
          'Verhoog de luchtvochtigheid',
          'Zorg voor voldoende verse lucht',
          'Houd de temperatuur stabiel',
          'Geef indirect licht',
          'Verlaag de CO₂-concentratie',
        ].map((a) => '• $a').join('\n'),
      ),
      'Problemen bij vruchtvorming': [
        for (final p in _problems)
          PlantGuideDetailBlock(heading: p.title, body: p.body),
      ],
    },
  );
}

String _lightShort(String light) {
  if (light.toLowerCase().contains('donker')) return 'Donker';
  if (light.toLowerCase().contains('indirect')) return 'Indirect licht';
  return light.split(',').first.trim();
}

enum _FruitingStyle { indoorKit, woodBlock, compost, outdoor }

_FruitingStyle _fruitingStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _FruitingStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _FruitingStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _FruitingStyle.outdoor;
    default:
      return _FruitingStyle.indoorKit;
  }
}
