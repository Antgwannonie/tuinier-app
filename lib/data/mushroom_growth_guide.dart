import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

class GrowthTimelineStage {
  const GrowthTimelineStage({
    required this.label,
    required this.duration,
    required this.assetPath,
  });

  final String label;
  final String duration;
  final String assetPath;
}

class GrowthPhaseCard {
  const GrowthPhaseCard({
    required this.title,
    required this.duration,
    required this.body,
    required this.assetPath,
  });

  final String title;
  final String duration;
  final String body;
  final String assetPath;
}

class MushroomGrowthGuide with MushroomGuideCardData {
  const MushroomGrowthGuide({
    required this.whatIsBody,
    required this.timelineStages,
    required this.temperature,
    required this.temperatureNote,
    required this.humidity,
    required this.humidityNote,
    required this.ventilationLabel,
    required this.ventilationBody,
    required this.lightLabel,
    required this.lightBody,
    required this.conditionsTip,
    required this.expectations,
    required this.patienceNote,
    required this.growthPhases,
    required this.tips,
    required this.mistakes,
    required this.footerTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String whatIsBody;
  final List<GrowthTimelineStage> timelineStages;
  final String temperature;
  final String temperatureNote;
  final String humidity;
  final String humidityNote;
  final String ventilationLabel;
  final String ventilationBody;
  final String lightLabel;
  final String lightBody;
  final String conditionsTip;
  final List<String> expectations;
  final String patienceNote;
  final List<GrowthPhaseCard> growthPhases;
  final List<String> tips;
  final List<String> mistakes;
  final String footerTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_growth';

const _timelineStages = [
  GrowthTimelineStage(
    label: 'Kolonisatie',
    duration: '7–21 dagen',
    assetPath: '$_asset/growth_timeline_colonization.png',
  ),
  GrowthTimelineStage(
    label: 'Vruchtvorming',
    duration: '7–14 dagen',
    assetPath: '$_asset/growth_timeline_fruiting.png',
  ),
  GrowthTimelineStage(
    label: 'Groei',
    duration: '5–10 dagen',
    assetPath: '$_asset/growth_timeline_growth.png',
  ),
  GrowthTimelineStage(
    label: 'Oogst',
    duration: '1 dag',
    assetPath: '$_asset/growth_timeline_harvest.png',
  ),
];

const _growthPhases = [
  GrowthPhaseCard(
    title: 'Begin groei',
    duration: 'Dag 1–3',
    body: 'Eerste pinheads verschijnen; houd vocht en temperatuur stabiel.',
    assetPath: '$_asset/growth_phase_begin.png',
  ),
  GrowthPhaseCard(
    title: 'Pinhead fase',
    duration: 'Dag 4–7',
    body: 'Kleine knoppen groeien uit; vermijd tocht en uitdroging.',
    assetPath: '$_asset/growth_phase_pinhead.png',
  ),
  GrowthPhaseCard(
    title: 'Snelle groei',
    duration: 'Dag 8–14',
    body: 'Hoeden en stelen groeien snel; controleer dagelijks.',
    assetPath: '$_asset/growth_phase_rapid.png',
  ),
  GrowthPhaseCard(
    title: 'Volgroeid',
    duration: 'Dag 15+',
    body: 'Paddenstoelen zijn rijp voor oogst; oogst op het juiste moment.',
    assetPath: '$_asset/growth_phase_mature.png',
  ),
];

MushroomGrowthGuide growthGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final style = _growthStyleFor(vegetable.id);

  final lightLabel = switch (style) {
    _GrowthStyle.compost => '8–12 uur indirect',
    _GrowthStyle.outdoor => 'Halfschaduw',
    _GrowthStyle.woodBlock => '8–12 uur indirect',
    _GrowthStyle.indoorKit => '8–12 uur indirect',
  };

  final lightBody = switch (style) {
    _GrowthStyle.compost =>
      'Indirect daglicht stimuleert vruchtvorming bij champignons. Geen direct zonlicht op de compost.',
    _GrowthStyle.outdoor =>
      'Halfschaduw of gefilterd licht onder bomen. Te veel zon droogt het bed uit.',
    _GrowthStyle.woodBlock =>
      'Indirect licht helpt bij vruchtzetting op houtblokken. Geen direct zonlicht.',
    _GrowthStyle.indoorKit =>
      'Indirect daglicht of LED-lamp 8–12 uur per dag. Geen direct zonlicht op de growkit.',
  };

  final ventilationLabel = switch (style) {
    _GrowthStyle.outdoor => 'Matig',
    _GrowthStyle.woodBlock => 'Matig',
    _GrowthStyle.compost => 'Matig',
    _GrowthStyle.indoorKit => 'Matig',
  };

  final ventilationBody = switch (style) {
    _GrowthStyle.outdoor =>
      'Zorg voor luchtuitwisseling zonder harde wind. Bescherm het bed tegen tocht.',
    _GrowthStyle.woodBlock =>
      'Frisse lucht voorkomt CO₂-opbouw. Open de kweekruimte kort na het vernevelen.',
    _GrowthStyle.compost =>
      'Goede ventilatie voorkomt schimmel. Houd luchtvochtigheid hoog na het luchten.',
    _GrowthStyle.indoorKit =>
      'Frisse lucht voorkomt CO₂-opbouw. Open de growkit kort na het vernevelen.',
  };

  final temperatureNote = switch (style) {
    _GrowthStyle.outdoor =>
      'Buiten is temperatuur minder controleerbaar; kies het juiste seizoen voor $name.',
    _GrowthStyle.woodBlock =>
      'Houtblokken reageren trager op temperatuur — houd de ruimte stabiel.',
    _GrowthStyle.compost =>
      'Compost warmt soms op; vermijd temperaturen boven 25 °C tijdens vruchtzetting.',
    _GrowthStyle.indoorKit =>
      'Houd de kweekruimte stabiel. Vermijd grote temperatuurschommelingen.',
  };

  final conditionsTip = switch (style) {
    _GrowthStyle.outdoor =>
      'Buiten is geduld belangrijk — laat het mycelium in zijn eigen tempo groeien.',
    _GrowthStyle.woodBlock =>
      'Houtblokken vragen geduld — de eerste vruchten komen soms pas na weken.',
    _GrowthStyle.compost =>
      'Champignons groeien in golven — houd condities stabiel tussen flushes.',
    _GrowthStyle.indoorKit =>
      'Consistentie is belangrijker dan perfectie — kleine afwijkingen zijn normaal.',
  };

  final patienceNote = switch (style) {
    _GrowthStyle.outdoor =>
      'Buiten duurt de groei langer. Eerste vruchten kunnen pas na ${overview.timeToHarvest} verschijnen.',
    _GrowthStyle.woodBlock =>
      'Houtblokken vragen geduld. Eerste vruchten na ${overview.timeToHarvest} zijn normaal.',
    _GrowthStyle.compost =>
      'Champignons groeien in flushes. Na de eerste oogst volgen vaak nog 2–3 rondes.',
    _GrowthStyle.indoorKit =>
      'De eerste oogst komt meestal na ${overview.timeToHarvest}. Daarna volgen extra flushes.',
  };

  return MushroomGrowthGuide(
    whatIsBody:
        'Tijdens de groeifase ontwikkelt het mycelium zich tot volwaardige paddenstoelen. Van wit netwerk tot oogstbare hoeden — voor $name duurt het hele traject gemiddeld ${overview.timeToHarvest}. Houd omstandigheden stabiel voor het beste resultaat.',
    timelineStages: _timelineStages,
    temperature: overview.temperature,
    temperatureNote: temperatureNote,
    humidity: overview.humidity,
    humidityNote: 'Hoge luchtvochtigheid is cruciaal tijdens vruchtzetting en groei.',
    ventilationLabel: ventilationLabel,
    ventilationBody: ventilationBody,
    lightLabel: lightLabel,
    lightBody: lightBody,
    conditionsTip: conditionsTip,
    expectations: [
      'Witte pinheads verschijnen na kolonisatie',
      'Hoeden groeien snel in 5–10 dagen',
      'Eerste oogst na ${overview.timeToHarvest}',
      overview.yield,
      overview.flushCount,
    ],
    patienceNote: patienceNote,
    growthPhases: _growthPhases,
    tips: [
      'Houd ${overview.humidity} luchtvochtigheid aan',
      'Vernevel regelmatig maar kort',
      'Vermijd tocht en direct zonlicht',
      'Controleer dagelijks op pinheads',
      'Noteer groeivoortgang in een logboek',
      style == _GrowthStyle.outdoor
          ? 'Pas watergift aan bij weersomstandigheden'
          : 'Gebruik een hygrometer en humidifier indien nodig',
    ],
    mistakes: const [
      'Te lage luchtvochtigheid',
      'Te veel of te weinig ventilatie',
      'Temperatuur te hoog of te laag',
      'Te vroeg of te laat oogsten',
      'Substraat te nat of te droog',
    ],
    footerTip:
        'Geduld en consistentie zijn de sleutel! Laat de paddenstoelen in hun eigen tempo groeien.',
    cardSummaries: mushroomCardSummaries(
      tab: 'growth',
      vegetable: vegetable,
      titles: const [
        'Wat gebeurt er tijdens de groei?',
        'De groeifase in het kort',
        'Ideale omstandigheden tijdens groei',
        'Wat kun je verwachten?',
        'Fasen van de groei',
        'Tips voor een gezonde groei',
        'Veelgemaakte fouten',
      ],
    ),
    cardDetails: {
      'Wat gebeurt er tijdens de groei?': mushroomDetailBlocks(
        fullBody:
            'Tijdens de groeifase ontwikkelt het mycelium zich tot volwaardige paddenstoelen. Van wit netwerk tot oogstbare hoeden — voor $name duurt het hele traject gemiddeld ${overview.timeToHarvest}. Houd omstandigheden stabiel voor het beste resultaat.',
      ),
      'De groeifase in het kort': [
        for (final s in _timelineStages)
          PlantGuideDetailBlock(heading: '${s.label} (${s.duration})', body: 'Fase in het groeitraject.'),
      ],
      'Ideale omstandigheden tijdens groei': [
        PlantGuideDetailBlock(heading: 'Temperatuur', body: '${overview.temperature}\n$temperatureNote'),
        PlantGuideDetailBlock(heading: 'Luchtvochtigheid', body: '${overview.humidity}\nHoge luchtvochtigheid is cruciaal tijdens vruchtzetting en groei.'),
        PlantGuideDetailBlock(heading: 'Ventilatie ($ventilationLabel)', body: ventilationBody),
        PlantGuideDetailBlock(heading: 'Licht ($lightLabel)', body: lightBody),
        PlantGuideDetailBlock(heading: 'Tip', body: conditionsTip),
      ],
      'Wat kun je verwachten?': mushroomDetailBlocks(
        fullBody: [
          'Witte pinheads verschijnen na kolonisatie',
          'Hoeden groeien snel in 5–10 dagen',
          'Eerste oogst na ${overview.timeToHarvest}',
          overview.yield,
          overview.flushCount,
          patienceNote,
        ].map((e) => '• $e').join('\n'),
      ),
      'Fasen van de groei': [
        for (final p in _growthPhases)
          PlantGuideDetailBlock(heading: '${p.title} (${p.duration})', body: p.body),
      ],
      'Tips voor een gezonde groei': mushroomDetailBlocks(
        fullBody: [
          'Houd ${overview.humidity} luchtvochtigheid aan',
          'Vernevel regelmatig maar kort',
          'Vermijd tocht en direct zonlicht',
          'Controleer dagelijks op pinheads',
          'Noteer groeivoortgang in een logboek',
          style == _GrowthStyle.outdoor
              ? 'Pas watergift aan bij weersomstandigheden'
              : 'Gebruik een hygrometer en humidifier indien nodig',
        ].map((t) => '• $t').join('\n'),
      ),
      'Veelgemaakte fouten': mushroomDetailBlocks(
        fullBody: const [
          'Te lage luchtvochtigheid',
          'Te veel of te weinig ventilatie',
          'Temperatuur te hoog of te laag',
          'Te vroeg of te laat oogsten',
          'Substraat te nat of te droog',
        ].map((m) => '• $m').join('\n'),
      ),
    },
  );
}

enum _GrowthStyle { indoorKit, woodBlock, compost, outdoor }

_GrowthStyle _growthStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _GrowthStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _GrowthStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _GrowthStyle.outdoor;
    default:
      return _GrowthStyle.indoorKit;
  }
}
