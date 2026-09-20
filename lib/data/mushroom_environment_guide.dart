import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

class EnvironmentLocationOption {
  const EnvironmentLocationOption({
    required this.title,
    required this.body,
    required this.benefits,
    required this.assetPath,
  });

  final String title;
  final String body;
  final List<String> benefits;
  final String assetPath;
}

class EnvironmentPhase {
  const EnvironmentPhase({
    required this.label,
    required this.assetPath,
    required this.stats,
  });

  final String label;
  final String assetPath;
  final List<String> stats;
}

class EnvironmentMistake {
  const EnvironmentMistake({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class MushroomEnvironmentGuide with MushroomGuideCardData {
  const MushroomEnvironmentGuide({
    required this.heroBody,
    required this.locations,
    required this.temperature,
    required this.temperatureNote,
    required this.humidity,
    required this.humidityNote,
    required this.ventilationValue,
    required this.ventilationNote,
    required this.lightValue,
    required this.lightNote,
    required this.restValue,
    required this.restNote,
    required this.stabilityTip,
    required this.phases,
    required this.mistakes,
    required this.monitoringTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String heroBody;
  final List<EnvironmentLocationOption> locations;
  final String temperature;
  final String temperatureNote;
  final String humidity;
  final String humidityNote;
  final String ventilationValue;
  final String ventilationNote;
  final String lightValue;
  final String lightNote;
  final String restValue;
  final String restNote;
  final String stabilityTip;
  final List<EnvironmentPhase> phases;
  final List<EnvironmentMistake> mistakes;
  final String monitoringTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_environment';

const _locations = [
  EnvironmentLocationOption(
    title: 'Binnen',
    body: 'Kweek in huis, schuur of kweektent met volledige controle.',
    benefits: [
      'Volledige controle',
      'Het hele jaar door',
      'Ideaal voor beginners',
    ],
    assetPath: '$_asset/environment_indoor.png',
  ),
  EnvironmentLocationOption(
    title: 'Buiten',
    body: 'Natuurlijke teelt in bed, op hout of in de tuin.',
    benefits: [
      'Natuurlijk klimaat',
      'Lage kosten',
      'Seizoensgebonden',
    ],
    assetPath: '$_asset/environment_outdoor.png',
  ),
  EnvironmentLocationOption(
    title: 'Kas',
    body: 'Beschutte teelt met extra licht en ventilatie.',
    benefits: [
      'Meer licht',
      'Betere ventilatie',
      'Goede controle',
    ],
    assetPath: '$_asset/environment_greenhouse.png',
  ),
  EnvironmentLocationOption(
    title: 'Kelder',
    body: 'Koele, vochtige ruimte met stabiele temperatuur.',
    benefits: [
      'Constante temperatuur',
      'Hoge luchtvochtigheid',
      'Weinig licht nodig',
    ],
    assetPath: '$_asset/environment_cellar.png',
  ),
];

const _phases = [
  EnvironmentPhase(
    label: 'Kolonisatie',
    assetPath: '$_asset/environment_phase_colonization.png',
    stats: ['20–25 °C', 'Weinig licht', 'Hoge luchtvochtigheid'],
  ),
  EnvironmentPhase(
    label: 'Vruchtvorming',
    assetPath: '$_asset/environment_phase_pinning.png',
    stats: ['15–20 °C', 'Hoge luchtvochtigheid', 'Goede ventilatie'],
  ),
  EnvironmentPhase(
    label: 'Groei',
    assetPath: '$_asset/environment_phase_growth.png',
    stats: ['15–20 °C', 'Frisse lucht', 'Indirect licht'],
  ),
  EnvironmentPhase(
    label: 'Oogst',
    assetPath: '$_asset/environment_phase_harvest.png',
    stats: ['15–20 °C', 'Stabiel houden', 'Beste opbrengst'],
  ),
];

const _mistakes = [
  EnvironmentMistake(
    title: 'Te weinig ventilatie',
    body: 'Leidt tot CO₂-opbouw en schimmelvorming.',
  ),
  EnvironmentMistake(
    title: 'Temperatuurschommelingen',
    body: 'Veroorzaakt stress en vertraagt de groei.',
  ),
  EnvironmentMistake(
    title: 'Te veel direct licht',
    body: 'Droogt het substraat uit en remt groei.',
  ),
  EnvironmentMistake(
    title: 'Te lage luchtvochtigheid',
    body: 'Leidt tot uitdroging en slechte opbrengst.',
  ),
];

MushroomEnvironmentGuide environmentGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final style = _envStyleFor(vegetable.id);

  final recommendedLocation = switch (style) {
    _EnvStyle.outdoor => 'Buiten in een beschut bed is ideaal voor $name.',
    _EnvStyle.woodBlock =>
      'Een koele kelder of schuur met stabiele temperatuur past goed bij $name op houtblokken.',
    _EnvStyle.compost =>
      'Een donkere, vochtige ruimte zoals een kelder is ideaal voor $name op compost.',
    _EnvStyle.indoorKit =>
      'Binnen in een kweektent of koele ruimte is het beste voor $name.',
  };

  final indoorBody = switch (style) {
    _EnvStyle.outdoor =>
      'Vooruitkweken in tray is mogelijk, maar de hoofdteelt van $name gebeurt buiten.',
    _ => 'Ideale plek: ${overview.location}${overview.locationSubtitle != null ? ' (${overview.locationSubtitle})' : ''}.',
  };

  final locations = [
    EnvironmentLocationOption(
      title: 'Binnen',
      body: indoorBody,
      benefits: _locations[0].benefits,
      assetPath: _locations[0].assetPath,
    ),
    EnvironmentLocationOption(
      title: 'Buiten',
      body: style == _EnvStyle.outdoor
          ? 'Geschikt voor $name: compost- of mulchbed in halfschaduw, beschut tegen wind.'
          : 'Niet aanbevolen voor $name in ons klimaat, behalve in een beschutte kas.',
      benefits: _locations[1].benefits,
      assetPath: _locations[1].assetPath,
    ),
    EnvironmentLocationOption(
      title: 'Kas',
      body: style == _EnvStyle.outdoor
          ? 'Een kas biedt bescherming en helpt de luchtvochtigheid stabiel te houden.'
          : 'Een verwarmde kas met vochtigheidsregeling is ideaal voor vruchtzetting van $name.',
      benefits: _locations[2].benefits,
      assetPath: _locations[2].assetPath,
    ),
    EnvironmentLocationOption(
      title: 'Kelder',
      body: style == _EnvStyle.compost || style == _EnvStyle.indoorKit
          ? 'Koele kelder (${overview.temperature}) is uitstekend voor $name.'
          : 'Een koele, vochtige kelder kan geschikt zijn bij stabiele temperatuur.',
      benefits: _locations[3].benefits,
      assetPath: _locations[3].assetPath,
    ),
  ];

  return MushroomEnvironmentGuide(
    heroBody:
        'Stabiliteit in temperatuur, luchtvochtigheid, ventilatie en rust is de sleutel tot succesvolle teelt van $name. $recommendedLocation',
    locations: locations,
    temperature: overview.temperature,
    temperatureNote: 'Afhankelijk van de soort en groeifase.',
    humidity: overview.humidity,
    humidityNote: 'Hoog en stabiel houden tijdens vruchtzetting.',
    ventilationValue: overview.ventilation,
    ventilationNote:
        '${overview.ventilationSubtitle ?? 'Frisse lucht'} — voorkomt CO₂-opbouw en schimmel.',
    lightValue: _lightShort(overview.light),
    lightNote: 'Geen direct zonlicht nodig voor de meeste soorten.',
    restValue: 'Rust',
    restNote: 'Vermijd trillingen, tocht en onnodige verstoringen.',
    stabilityTip:
        'Stabiliteit is belangrijker dan perfectie. Kleine aanpassingen zijn beter dan grote schommelingen.',
    phases: _phases,
    mistakes: _mistakes,
    monitoringTip:
        'Meet regelmatig met een thermometer en hygrometer. Noteer je waarden om patronen te herkennen.',
    cardSummaries: mushroomCardSummaries(
      tab: 'environment',
      vegetable: vegetable,
      titles: const [
        'De ideale omgeving',
        'Kies je kweekomgeving',
        'Ideale omgevingsfactoren',
        'Omgeving per groeifase',
        'Veelgemaakte fouten',
      ],
    ),
    cardDetails: {
      'De ideale omgeving': mushroomDetailBlocks(
        fullBody:
            'Stabiliteit in temperatuur, luchtvochtigheid, ventilatie en rust is de sleutel tot succesvolle teelt van $name. $recommendedLocation',
      ),
      'Kies je kweekomgeving': [
        for (final loc in locations)
          PlantGuideDetailBlock(
            heading: loc.title,
            body: '${loc.body}\n\nVoordelen:\n${loc.benefits.map((b) => '• $b').join('\n')}',
          ),
      ],
      'Ideale omgevingsfactoren': [
        PlantGuideDetailBlock(
          heading: 'Temperatuur',
          body: '${overview.temperature}\nAfhankelijk van de soort en groeifase.',
        ),
        PlantGuideDetailBlock(
          heading: 'Luchtvochtigheid',
          body: '${overview.humidity}\nHoog en stabiel houden tijdens vruchtzetting.',
        ),
        PlantGuideDetailBlock(
          heading: 'Ventilatie',
          body:
              '${overview.ventilation}\n${overview.ventilationSubtitle ?? 'Frisse lucht'} — voorkomt CO₂-opbouw en schimmel.',
        ),
        PlantGuideDetailBlock(
          heading: _lightShort(overview.light),
          body: 'Geen direct zonlicht nodig voor de meeste soorten.',
        ),
        const PlantGuideDetailBlock(
          heading: 'Rust',
          body: 'Vermijd trillingen, tocht en onnodige verstoringen.',
        ),
        PlantGuideDetailBlock(
          heading: 'Tip',
          body:
              'Stabiliteit is belangrijker dan perfectie. Kleine aanpassingen zijn beter dan grote schommelingen.',
        ),
      ],
      'Omgeving per groeifase': [
        for (final p in _phases)
          PlantGuideDetailBlock(
            heading: p.label,
            body: p.stats.join('\n'),
          ),
      ],
      'Veelgemaakte fouten': [
        for (final m in _mistakes)
          PlantGuideDetailBlock(heading: m.title, body: m.body),
      ],
    },
  );
}

String _lightShort(String light) {
  if (light.toLowerCase().contains('donker')) return 'Donker';
  if (light.toLowerCase().contains('indirect')) return 'Indirect licht';
  return light.split(',').first.trim();
}

enum _EnvStyle { indoorKit, woodBlock, compost, outdoor }

_EnvStyle _envStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _EnvStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _EnvStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _EnvStyle.outdoor;
    default:
      return _EnvStyle.indoorKit;
  }
}
