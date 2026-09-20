import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

class FlushCycleStep {
  const FlushCycleStep({
    required this.number,
    required this.label,
    this.assetPath,
    this.useWaterIcon = false,
    this.useClockIcon = false,
  });

  final String number;
  final String label;
  final String? assetPath;
  final bool useWaterIcon;
  final bool useClockIcon;
}

class FlushStatCard {
  const FlushStatCard({
    required this.value,
    required this.label,
    required this.body,
  });

  final String value;
  final String label;
  final String body;
}

class FlushRestartStep {
  const FlushRestartStep({
    required this.label,
    required this.body,
    this.assetPath,
    this.useBrushIcon = false,
    this.useSprayIcon = false,
    this.useFanIcon = false,
    this.useClockIcon = false,
  });

  final String label;
  final String body;
  final String? assetPath;
  final bool useBrushIcon;
  final bool useSprayIcon;
  final bool useFanIcon;
  final bool useClockIcon;
}

class FlushProblem {
  const FlushProblem({
    required this.title,
    required this.body,
    required this.assetPath,
  });

  final String title;
  final String body;
  final String assetPath;
}

class MushroomFlushesGuide with MushroomGuideCardData {
  const MushroomFlushesGuide({
    required this.whatAreFlushesBody,
    required this.cycleSteps,
    required this.cycleTip,
    required this.statsIntro,
    required this.statCards,
    required this.restartSteps,
    required this.temperature,
    required this.temperatureNote,
    required this.humidity,
    required this.humidityNote,
    required this.ventilationNote,
    required this.lightNote,
    required this.substrateNote,
    required this.conditionsTip,
    required this.problems,
    required this.feedingTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String whatAreFlushesBody;
  final List<FlushCycleStep> cycleSteps;
  final String cycleTip;
  final String statsIntro;
  final List<FlushStatCard> statCards;
  final List<FlushRestartStep> restartSteps;
  final String temperature;
  final String temperatureNote;
  final String humidity;
  final String humidityNote;
  final String ventilationNote;
  final String lightNote;
  final String substrateNote;
  final String conditionsTip;
  final List<FlushProblem> problems;
  final String feedingTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_flushes';

const _cycleSteps = [
  FlushCycleStep(
    number: '1',
    label: 'Oogsten',
    assetPath: '$_asset/flushes_cycle_harvest.png',
  ),
  FlushCycleStep(
    number: '2',
    label: 'Herstellen',
    useWaterIcon: true,
  ),
  FlushCycleStep(
    number: '3',
    label: 'Rustperiode',
    useClockIcon: true,
  ),
  FlushCycleStep(
    number: '4',
    label: 'Nieuwe knopen',
    assetPath: '$_asset/flushes_cycle_pinheads.png',
  ),
  FlushCycleStep(
    number: '5',
    label: 'Volgende flush',
    assetPath: '$_asset/flushes_cycle_next.png',
  ),
];

const _restartSteps = [
  FlushRestartStep(
    label: 'Oogst volledig',
    body: 'Verwijder alle vruchtlichamen en resten van steel.',
    assetPath: '$_asset/flushes_cycle_harvest.png',
  ),
  FlushRestartStep(
    label: 'Maak schoon',
    body: 'Veeg substraat schoon met een schone borstel.',
    useBrushIcon: true,
  ),
  FlushRestartStep(
    label: 'Geef water',
    body: 'Vernevel licht of dompel kort onder water.',
    useSprayIcon: true,
  ),
  FlushRestartStep(
    label: 'Herstel omstandigheden',
    body: 'Zorg voor frisse lucht en stabiele temperatuur.',
    useFanIcon: true,
  ),
  FlushRestartStep(
    label: 'Geduld',
    body: 'Wacht 5–14 dagen op nieuwe pinheads.',
    useClockIcon: true,
  ),
];

const _problems = [
  FlushProblem(
    title: 'Substraat te droog',
    body: 'Mycelium stopt met groeien; pinheads drogen in.',
    assetPath: '$_asset/flushes_problem_dry.png',
  ),
  FlushProblem(
    title: 'Luchtstraat te nat',
    body: 'Waterdruppels op oppervlak; risico op bacteriën.',
    assetPath: '$_asset/flushes_problem_wet.png',
  ),
  FlushProblem(
    title: 'Schimmelgroei',
    body: 'Groene of zwarte vlekken wijzen op besmetting.',
    assetPath: '$_asset/flushes_problem_mold.png',
  ),
  FlushProblem(
    title: 'Langzame hergroei',
    body: 'Substraat raakt uitgeput; wacht langer tussen flushes.',
    assetPath: '$_asset/flushes_problem_slow.png',
  ),
  FlushProblem(
    title: 'Weinig pinheads',
    body: 'Te laag CO₂, te droog of te koud voor vruchtzetting.',
    assetPath: '$_asset/flushes_problem_few_pins.png',
  ),
];

MushroomFlushesGuide flushesGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final style = _flushesStyleFor(vegetable.id);

  final restPeriod = switch (style) {
    _FlushesStyle.woodBlock => '7–14 dagen',
    _FlushesStyle.compost => '5–10 dagen',
    _FlushesStyle.outdoor => '2–4 weken',
    _FlushesStyle.indoorKit => '5–10 dagen',
  };

  final cycleTip = switch (style) {
    _FlushesStyle.woodBlock =>
      'Houtblokken geven flushes over maanden. Na elke oogst: vernevel en wacht $restPeriod op nieuwe pinheads.',
    _FlushesStyle.compost =>
      'Champignons groeien in golven. Houd casinglaag vochtig en geef frisse lucht na elke flush.',
    _FlushesStyle.outdoor =>
      'Buiten flushes zijn seizoensgebonden. Regen en koelere nachten triggeren vaak nieuwe oogsten.',
    _FlushesStyle.indoorKit =>
      'Na elke flush: oogst schoon, vernevel 2–3× per dag en wacht $restPeriod. Koelschok kan een nieuwe flush triggeren.',
  };

  final statsIntro =
      'Het aantal flushes hangt af van substraat, soort en zorg. Voor $name: ${overview.flushCount}.';

  final statCards = _statCardsFor(style, overview);

  final restartSteps = [
    FlushRestartStep(
      label: 'Oogst volledig',
      body: style == _FlushesStyle.indoorKit
          ? 'Knip alle paddenstoelen bij de basis. Laat geen resten achter.'
          : 'Snij alle vruchtlichamen bij de basis. Verwijder losse stukken.',
      assetPath: '$_asset/flushes_cycle_harvest.png',
    ),
    _restartSteps[1],
    FlushRestartStep(
      label: 'Geef water',
      body: style == _FlushesStyle.outdoor
          ? 'Geef water bij droog weer; dek bed af met vochtige stro.'
          : 'Vernevel 2–3× per dag of dompel growkit kort onder water.',
      useSprayIcon: true,
    ),
    FlushRestartStep(
      label: 'Herstel omstandigheden',
      body:
          'Houd ${overview.temperature} en ${overview.humidity} aan. ${overview.ventilation}.',
      useFanIcon: true,
    ),
    FlushRestartStep(
      label: 'Geduld',
      body: 'Wacht $restPeriod op nieuwe pinheads.',
      useClockIcon: true,
    ),
  ];

  final feedingTip = switch (style) {
    _FlushesStyle.woodBlock =>
      'Na 2–3 flushes kan voedingswaarde afnemen. Dompel het blok kort onder water of vernevel extra. Houtblokken geven soms nog maanden flushes.',
    _FlushesStyle.compost =>
      'Na 2–3 flushes voeg je eventueel een dunne laag casing toe. Houd compost vochtig maar niet druipend.',
    _FlushesStyle.outdoor =>
      'Buitenbedden voeden zichzelf via compost. Voeg na de eerste flush een laag stro of mulch toe.',
    _FlushesStyle.indoorKit =>
      'Na 2–3 flushes kan voedingswaarde afnemen. Dompel de growkit 30 minuten onder water of geef een voedingsoplossing volgens instructies.',
  };

  return MushroomFlushesGuide(
    whatAreFlushesBody:
        'Een flush is een oogstgolf: alle paddenstoelen die in korte tijd uit hetzelfde substraat verschijnen. Na de eerste flush volgen er meestal extra rondes — voor $name gemiddeld ${overview.flushCount}. Elke flush levert ${overview.yield}, met afnemende opbrengst naarmate het substraat uitgeput raakt.',
    cycleSteps: _cycleSteps,
    cycleTip: cycleTip,
    statsIntro: statsIntro,
    statCards: statCards,
    restartSteps: restartSteps,
    temperature: overview.temperature,
    temperatureNote: 'Houd stabiel tussen flushes voor snelle hergroei.',
    humidity: overview.humidity,
    humidityNote: 'Hoog en stabiel houden na oogst.',
    ventilationNote:
        '${overview.ventilation}${overview.ventilationSubtitle != null ? ' — ${overview.ventilationSubtitle}' : ''}.',
    lightNote: overview.light,
    substrateNote: switch (style) {
      _FlushesStyle.woodBlock =>
        'Houtblok vochtig houden maar niet druipend.',
      _FlushesStyle.compost =>
        'Casinglaag gelijkmatig vochtig; geen plassen.',
      _FlushesStyle.outdoor =>
        'Bed bedekken met stro om vocht vast te houden.',
      _FlushesStyle.indoorKit =>
        'Substraat vochtig aanvoelen; knijptest zonder druppels.',
    },
    conditionsTip:
        'Consistentie tussen flushes is belangrijker dan perfectie. Kleine aanpassingen zijn beter dan grote schommelingen.',
    problems: _problems,
    feedingTip: feedingTip,
    cardSummaries: mushroomCardSummaries(
      tab: 'flushes',
      vegetable: vegetable,
      titles: const [
        'Wat zijn flushes?',
        'De flush cyclus',
        'Hoeveel flushes kun je verwachten?',
        'Zo start je een nieuwe flush',
        'Optimale omstandigheden na het oogsten',
        'Veelvoorkomende problemen tussen flushes',
      ],
    ),
    cardDetails: {
      'Wat zijn flushes?': mushroomDetailBlocks(
        fullBody:
            'Een flush is een oogstgolf: alle paddenstoelen die in korte tijd uit hetzelfde substraat verschijnen. Na de eerste flush volgen er meestal extra rondes — voor $name gemiddeld ${overview.flushCount}. Elke flush levert ${overview.yield}, met afnemende opbrengst naarmate het substraat uitgeput raakt.',
      ),
      'De flush cyclus': mushroomDetailBlocks(
        fullBody: '$cycleTip\n\n${_cycleSteps.map((s) => '${s.number}. ${s.label}').join('\n')}',
      ),
      'Hoeveel flushes kun je verwachten?': mushroomDetailBlocks(
        fullBody: '$statsIntro\n\n${statCards.map((c) => '${c.value} ${c.label}: ${c.body}').join('\n')}',
      ),
      'Zo start je een nieuwe flush': [
        for (final s in restartSteps)
          PlantGuideDetailBlock(heading: s.label, body: s.body),
      ],
      'Optimale omstandigheden na het oogsten': [
        PlantGuideDetailBlock(
          heading: 'Temperatuur',
          body: '${overview.temperature}\nHoud stabiel tussen flushes voor snelle hergroei.',
        ),
        PlantGuideDetailBlock(
          heading: 'Luchtvochtigheid',
          body: '${overview.humidity}\nHoog en stabiel houden na oogst.',
        ),
        PlantGuideDetailBlock(
          heading: 'Ventilatie',
          body:
              '${overview.ventilation}${overview.ventilationSubtitle != null ? ' — ${overview.ventilationSubtitle}' : ''}.',
        ),
        PlantGuideDetailBlock(heading: 'Licht', body: overview.light),
        PlantGuideDetailBlock(heading: 'Substraat', body: switch (style) {
          _FlushesStyle.woodBlock => 'Houtblok vochtig houden maar niet druipend.',
          _FlushesStyle.compost => 'Casinglaag gelijkmatig vochtig; geen plassen.',
          _FlushesStyle.outdoor => 'Bed bedekken met stro om vocht vast te houden.',
          _FlushesStyle.indoorKit =>
            'Substraat vochtig aanvoelen; knijptest zonder druppels.',
        }),
        PlantGuideDetailBlock(
          heading: 'Tip',
          body:
              'Consistentie tussen flushes is belangrijker dan perfectie. Kleine aanpassingen zijn beter dan grote schommelingen.',
        ),
        PlantGuideDetailBlock(heading: 'Extra', body: feedingTip),
      ],
      'Veelvoorkomende problemen tussen flushes': [
        for (final p in _problems)
          PlantGuideDetailBlock(heading: p.title, body: p.body),
      ],
    },
  );
}

List<FlushStatCard> _statCardsFor(
  _FlushesStyle style,
  MushroomOverviewLayout overview,
) {
  return switch (style) {
    _FlushesStyle.woodBlock => [
      const FlushStatCard(
        value: '2–4',
        label: 'flushes',
        body: 'Per houtblok over maanden',
      ),
      const FlushStatCard(
        value: '4–6',
        label: 'flushes',
        body: 'Met optimale verzorging',
      ),
      FlushStatCard(
        value: '6+',
        label: 'flushes',
        body: 'Zeldzaam; langdurige teelt',
      ),
      FlushStatCard(
        value: 'Daling',
        label: 'in opbrengst',
        body: overview.yield,
      ),
    ],
    _FlushesStyle.compost => [
      const FlushStatCard(
        value: '2–3',
        label: 'flushes',
        body: 'Per kweekronde',
      ),
      const FlushStatCard(
        value: '3–5',
        label: 'flushes',
        body: 'Met goede casing',
      ),
      const FlushStatCard(
        value: '5+',
        label: 'flushes',
        body: 'Professionele teelt',
      ),
      FlushStatCard(
        value: 'Daling',
        label: 'in opbrengst',
        body: overview.yield,
      ),
    ],
    _FlushesStyle.outdoor => [
      const FlushStatCard(
        value: '1–2',
        label: 'flushes',
        body: 'Per seizoen',
      ),
      const FlushStatCard(
        value: '2–3',
        label: 'flushes',
        body: 'Gunstig weer',
      ),
      const FlushStatCard(
        value: '3+',
        label: 'flushes',
        body: 'Meerdere jaren mogelijk',
      ),
      FlushStatCard(
        value: 'Daling',
        label: 'in opbrengst',
        body: overview.yield,
      ),
    ],
    _FlushesStyle.indoorKit => [
      FlushStatCard(
        value: '2–4',
        label: 'flushes',
        body: overview.flushCount,
      ),
      const FlushStatCard(
        value: '4–6',
        label: 'flushes',
        body: 'Met extra watergift',
      ),
      const FlushStatCard(
        value: '6+',
        label: 'flushes',
        body: 'Zeldzaam; optimale condities',
      ),
      FlushStatCard(
        value: 'Daling',
        label: 'in opbrengst',
        body: overview.yield,
      ),
    ],
  };
}

enum _FlushesStyle { indoorKit, woodBlock, compost, outdoor }

_FlushesStyle _flushesStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _FlushesStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _FlushesStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _FlushesStyle.outdoor;
    default:
      return _FlushesStyle.indoorKit;
  }
}
