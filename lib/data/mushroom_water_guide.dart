import '../models/vegetable.dart';
import 'mushroom_card_summaries.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

class WaterMethodStep {
  const WaterMethodStep({
    required this.title,
    required this.body,
    this.assetPath,
    this.useClockIcon = false,
    this.useMagnifyIcon = false,
    this.useSprayIcon = false,
  });

  final String title;
  final String body;
  final String? assetPath;
  final bool useClockIcon;
  final bool useMagnifyIcon;
  final bool useSprayIcon;
}

class MushroomWaterGuide with MushroomGuideCardData {
  const MushroomWaterGuide({
    required this.whyBody,
    required this.humidity,
    required this.humidityNote,
    required this.mistingBody,
    required this.substrateMoistureBody,
    required this.waterQualityBody,
    required this.methodSteps,
    required this.tooDrySignals,
    required this.tooWetSignals,
    required this.tips,
    required this.mistakes,
    required this.footerTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String whyBody;
  final String humidity;
  final String humidityNote;
  final String mistingBody;
  final String substrateMoistureBody;
  final String waterQualityBody;
  final List<WaterMethodStep> methodSteps;
  final List<String> tooDrySignals;
  final List<String> tooWetSignals;
  final List<String> tips;
  final List<String> mistakes;
  final String footerTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_water';

const _methodSteps = [
  WaterMethodStep(
    title: 'Vernevelen',
    body: 'Gebruik een plantenspuit voor een fijne nevel.',
    useSprayIcon: true,
  ),
  WaterMethodStep(
    title: 'Gelijkmatig',
    body: 'Vernevel alle kanten gelijkmatig.',
    assetPath: '$_asset/water_step_even.png',
  ),
  WaterMethodStep(
    title: 'Meerdere keren per dag',
    body: 'Doe dit 2–4× per dag, afhankelijk van de omgeving.',
    useClockIcon: true,
  ),
  WaterMethodStep(
    title: 'Controleer',
    body: 'Controleer regelmatig of het substraat vochtig blijft.',
    useMagnifyIcon: true,
  ),
];

MushroomWaterGuide waterGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final style = _waterStyleFor(vegetable.id);

  final mistingFrequency = style == _WaterStyle.outdoor
      ? 'Controleer dagelijks en vernevel bij droog weer in het bed.'
      : 'Vernevel 2–3× per dag tijdens vruchtzetting; 1× per dag tijdens kolonisatie.';

  final methodSteps = [
    _methodSteps[0],
    _methodSteps[1],
    WaterMethodStep(
      title: 'Meerdere keren per dag',
      body: mistingFrequency,
      useClockIcon: true,
    ),
    _methodSteps[3],
  ];

  return MushroomWaterGuide(
    whyBody:
        'Water is essentieel voor de groei van $name. Het transporteert voedingsstoffen, houdt het mycelium gezond en zorgt voor de juiste omstandigheden tijdens vruchtzetting. Te weinig of te veel water kan de oogst schaden.',
    humidity: overview.humidity,
    humidityNote: 'Hoge luchtvochtigheid is cruciaal tijdens vruchtzetting.',
    mistingBody: mistingFrequency,
    substrateMoistureBody:
        'Het substraat moet vochtig aanvoelen, maar niet druipen. Knijp licht: er mag geen water uitkomen.',
    waterQualityBody:
        'Gebruik regenwater of gefilterd kraanwater op kamertemperatuur. Vermijd chloorrijk kraanwater.',
    methodSteps: methodSteps,
    tooDrySignals: const [
      'Langzame groei',
      'Kleine pinheads',
      'Substraat voelt droog aan',
      'Hoger besmettingsrisico',
    ],
    tooWetSignals: const [
      'Waterdruppels op het oppervlak',
      'Gele of bruine vlekken',
      'Slechte luchtcirculatie',
      'Risico op schimmel en rot',
    ],
    tips: [
      'Houd ${overview.humidity} luchtvochtigheid aan',
      'Vernevel vaak maar kort',
      'Zorg voor goede ventilatie na het vernevelen',
      'Gebruik een hygrometer om te meten',
      style == _WaterStyle.outdoor
          ? 'Pas watergift aan bij regen en droog weer'
          : 'Pas watergift aan op basis van temperatuur',
    ],
    mistakes: const [
      'Te veel water geven',
      'Chloorrijk kraanwater gebruiken',
      'Hoge luchtvochtigheid zonder ventilatie',
      'Onregelmatig water geven',
    ],
    footerTip:
        'Consistentie is de sleutel! Een stabiele vochtbalans zorgt voor gezonde paddenstoelen.',
    cardSummaries: {
      ...mushroomCardSummaries(
        tab: 'water',
        vegetable: vegetable,
        titles: const [
          'Waarom is water belangrijk?',
          'De ideale watercondities',
          'Hoe geef je water?',
          'Tips voor optimaal waterbeheer',
          'Veelgemaakte fouten',
        ],
      ),
      'Te droog': mushroomCardSummaryFor(
        tab: 'water',
        title: 'Te droog',
        vegetable: vegetable,
      ),
      'Te nat': mushroomCardSummaryFor(
        tab: 'water',
        title: 'Te nat',
        vegetable: vegetable,
      ),
    },
    cardDetails: {
      'Waarom is water belangrijk?': mushroomDetailBlocks(
        fullBody:
            'Water is essentieel voor de groei van $name. Het transporteert voedingsstoffen, houdt het mycelium gezond en zorgt voor de juiste omstandigheden tijdens vruchtzetting. Te weinig of te veel water kan de oogst schaden.',
      ),
      'De ideale watercondities': [
        PlantGuideDetailBlock(
          heading: 'Luchtvochtigheid',
          body: 'Hoge luchtvochtigheid is cruciaal tijdens vruchtzetting.',
        ),
        PlantGuideDetailBlock(
          heading: 'Bevochtigen',
          body: mistingFrequency,
        ),
        PlantGuideDetailBlock(
          heading: 'Substraatvochtigheid',
          body:
              'Het substraat moet vochtig aanvoelen, maar niet druipen. Knijp licht: er mag geen water uitkomen.',
        ),
        PlantGuideDetailBlock(
          heading: 'Waterkwaliteit',
          body:
              'Gebruik regenwater of gefilterd kraanwater op kamertemperatuur. Vermijd chloorrijk kraanwater.',
        ),
      ],
      'Hoe geef je water?': [
        for (final step in methodSteps)
          PlantGuideDetailBlock(heading: step.title, body: step.body),
      ],
      'Te droog': [
        PlantGuideDetailBlock(
          heading: 'Signalen',
          body: const [
            'Langzame groei',
            'Kleine pinheads',
            'Substraat voelt droog aan',
            'Hoger besmettingsrisico',
          ].join('\n'),
        ),
        PlantGuideDetailBlock(
          heading: 'Wat doe je?',
          body:
              'Vernevel vaker, kort en fijn. Controleer of het substraat weer licht vochtig aanvoelt.',
        ),
      ],
      'Te nat': [
        PlantGuideDetailBlock(
          heading: 'Signalen',
          body: const [
            'Waterdruppels op het oppervlak',
            'Gele of bruine vlekken',
            'Slechte luchtcirculatie',
            'Risico op schimmel en rot',
          ].join('\n'),
        ),
        PlantGuideDetailBlock(
          heading: 'Wat doe je?',
          body:
              'Minder vernevelen, meer ventileren, en laat het oppervlak licht opdrogen.',
        ),
      ],
      'Tips voor optimaal waterbeheer': [
        PlantGuideDetailBlock(
          heading: 'Alle tips',
          body: [
            'Houd ${overview.humidity} luchtvochtigheid aan',
            'Vernevel vaak maar kort',
            'Zorg voor goede ventilatie na het vernevelen',
            'Gebruik een hygrometer om te meten',
            style == _WaterStyle.outdoor
                ? 'Pas watergift aan bij regen en droog weer'
                : 'Pas watergift aan op basis van temperatuur',
          ].map((t) => '• $t').join('\n'),
        ),
      ],
      'Veelgemaakte fouten': [
        PlantGuideDetailBlock(
          heading: 'Vermijd dit',
          body: const [
            'Te veel water geven',
            'Chloorrijk kraanwater gebruiken',
            'Hoge luchtvochtigheid zonder ventilatie',
            'Onregelmatig water geven',
          ].map((t) => '• $t').join('\n'),
        ),
      ],
    },
  );
}

enum _WaterStyle { indoorKit, woodBlock, compost, outdoor }

_WaterStyle _waterStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _WaterStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _WaterStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _WaterStyle.outdoor;
    default:
      return _WaterStyle.indoorKit;
  }
}
