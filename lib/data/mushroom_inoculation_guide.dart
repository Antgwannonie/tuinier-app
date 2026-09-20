import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'plant_guide_detail.dart';

class InoculationSpawnType {
  const InoculationSpawnType({
    required this.label,
    required this.assetPath,
  });

  final String label;
  final String assetPath;
}

class InoculationMethodStep {
  const InoculationMethodStep({
    required this.title,
    required this.assetPath,
  });

  final String title;
  final String assetPath;
}

class InoculationSupplyItem {
  const InoculationSupplyItem({
    required this.label,
    required this.assetPath,
  });

  final String label;
  final String assetPath;
}

class MushroomInoculationGuide with MushroomGuideCardData {
  const MushroomInoculationGuide({
    required this.whatIsBody,
    required this.spawnTypes,
    required this.whenBody,
    required this.whenTip,
    required this.spawnRatioBody,
    required this.spawnRatioTip,
    required this.methodSteps,
    required this.temperatureBody,
    required this.hygieneItems,
    required this.supplies,
    required this.mistakes,
    required this.prevention,
    required this.footerTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String whatIsBody;
  final List<InoculationSpawnType> spawnTypes;
  final String whenBody;
  final String whenTip;
  final String spawnRatioBody;
  final String spawnRatioTip;
  final List<InoculationMethodStep> methodSteps;
  final String temperatureBody;
  final List<String> hygieneItems;
  final List<InoculationSupplyItem> supplies;
  final List<String> mistakes;
  final List<String> prevention;
  final String footerTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_inoculation';

MushroomInoculationGuide inoculationGuideForVegetable(Vegetable vegetable) {
  final style = _inocStyleFor(vegetable.id);
  final name = vegetable.nameNl.split('(').first.trim();

  final whenBody = switch (style) {
    _InocStyle.outdoor =>
      'Ent in het voorjaar (maart–mei) wanneer het bed vochtig is en de temperatuur stabiel is tussen 15 °C en 22 °C.',
    _InocStyle.woodBlock =>
      'Ent zodra het houtblok is afgekoeld tot 20 °C–25 °C na eventuele sterilisatie.',
    _InocStyle.compost =>
      'Ent wanneer de compost is afgekoeld tot 20 °C–25 °C en goed is voorbereid.',
    _InocStyle.indoorKit =>
      'Ent zodra het substraat is afgekoeld tot tussen de 20 °C en 25 °C. Bij growkits volg je de meegeleverde instructies.',
  };

  final spawnRatioBody = switch (style) {
    _InocStyle.outdoor =>
      'Gebruik 50–100 g spawn per m² bed. Dat is ongeveer 5–10 % van het substraatgewicht.',
    _InocStyle.woodBlock =>
      'Gebruik 4–8 pluggen of 5–10 % zaagselbroed per houtblok, gelijkmatig verdeeld.',
    _InocStyle.compost =>
      'Meng 5–10 % spawn door de compost. Te veel broed is niet nodig en verspilt materiaal.',
    _InocStyle.indoorKit =>
      'Gebruik 10–20 % broed ten opzichte van het substraatgewicht. Bij growkits is de hoeveelheid al bepaald.',
  };

  final methodSteps = switch (style) {
    _InocStyle.woodBlock => const [
        InoculationMethodStep(
          title: 'Toevoegen',
          assetPath: '$_asset/inoculation_step_add.png',
        ),
        InoculationMethodStep(
          title: 'Inboren',
          assetPath: '$_asset/inoculation_step_mix.png',
        ),
        InoculationMethodStep(
          title: 'Afsluiten',
          assetPath: '$_asset/inoculation_step_seal.png',
        ),
        InoculationMethodStep(
          title: 'Wegzetten',
          assetPath: '$_asset/inoculation_step_store.png',
        ),
      ],
    _InocStyle.outdoor => const [
        InoculationMethodStep(
          title: 'Toevoegen',
          assetPath: '$_asset/inoculation_step_add.png',
        ),
        InoculationMethodStep(
          title: 'Mengen',
          assetPath: '$_asset/inoculation_step_mix.png',
        ),
        InoculationMethodStep(
          title: 'Afdekken',
          assetPath: '$_asset/inoculation_step_seal.png',
        ),
        InoculationMethodStep(
          title: 'Wegzetten',
          assetPath: '$_asset/inoculation_step_store.png',
        ),
      ],
    _ => const [
        InoculationMethodStep(
          title: 'Toevoegen',
          assetPath: '$_asset/inoculation_step_add.png',
        ),
        InoculationMethodStep(
          title: 'Mengen',
          assetPath: '$_asset/inoculation_step_mix.png',
        ),
        InoculationMethodStep(
          title: 'Afsluiten',
          assetPath: '$_asset/inoculation_step_seal.png',
        ),
        InoculationMethodStep(
          title: 'Wegzetten',
          assetPath: '$_asset/inoculation_step_store.png',
        ),
      ],
  };

  return MushroomInoculationGuide(
    whatIsBody:
        'Enten is het toevoegen van broed (mycelium) aan je voorbereide substraat, zodat het mycelium kan gaan groeien en het substraat koloniseert. Voor $name gebeurt dit ${style == _InocStyle.outdoor ? 'buiten in het bed' : 'binnen op schone wijze'}.',
    spawnTypes: const [
      InoculationSpawnType(
        label: 'Graanbroed',
        assetPath: '$_asset/inoculation_grain_spawn.png',
      ),
      InoculationSpawnType(
        label: 'Zaagselbroed',
        assetPath: '$_asset/inoculation_sawdust_spawn.png',
      ),
      InoculationSpawnType(
        label: 'Pluggenbroed',
        assetPath: '$_asset/inoculation_plug_spawn.png',
      ),
    ],
    whenBody: whenBody,
    whenTip: 'Te heet substraat kan het broed beschadigen. Wacht geduldig!',
    spawnRatioBody: spawnRatioBody,
    spawnRatioTip: 'Te veel broed is niet nodig. De natuur zorgt voor de rest!',
    methodSteps: methodSteps,
    temperatureBody:
        'Houd de temperatuur tijdens het enten tussen 20 °C en 25 °C. Vermijd extreme hitte of kou — dat kan het mycelium beschadigen.',
    hygieneItems: const [
      'Handen wassen en ontsmetten',
      'Materialen desinfecteren',
      'Schone, stofvrije ruimte',
      'Handschoenen dragen',
      'Geen tocht of luchtstromen',
    ],
    supplies: const [
      InoculationSupplyItem(
        label: 'Broed',
        assetPath: '$_asset/inoculation_supply_spawn.png',
      ),
      InoculationSupplyItem(
        label: 'Schoon substraat',
        assetPath: '$_asset/inoculation_supply_bucket.png',
      ),
      InoculationSupplyItem(
        label: 'Ontsmettingsmiddel',
        assetPath: '$_asset/inoculation_supply_spray.png',
      ),
      InoculationSupplyItem(
        label: 'Handschoenen',
        assetPath: '$_asset/inoculation_supply_gloves.png',
      ),
      InoculationSupplyItem(
        label: 'Filter',
        assetPath: '$_asset/inoculation_supply_filter.png',
      ),
    ],
    mistakes: const [
      'Verkeerde verhouding broed/substraat',
      'Onvoldoende desinfectie',
      'Vuile ruimte of gereedschap',
      'Enten bij verkeerde temperatuur',
      'Substraat te lang open laten liggen',
    ],
    prevention: const [
      'Rustig en geconcentreerd werken',
      'Alles van tevoren desinfecteren',
      'Vers broed gebruiken',
      'Direct afsluiten na enten',
      'Regelmatig controleren op besmetting',
    ],
    footerTip:
        'Een goede start is het halve werk! Ent schoon, werk rustig en geef je mycelium de beste kans om te groeien.',
    cardSummaries: mushroomCardSummaries(
      tab: 'inoculation',
      vegetable: vegetable,
      titles: const [
        'Wat is enten?',
        'Wanneer enten?',
        'Hoeveel broed gebruiken?',
        'Entmethode',
        'Temperatuur tijdens enten',
        'Hygiëne is cruciaal',
        'Benodigdheden',
        'Veelgemaakte fouten',
        'Besmetting voorkomen',
      ],
    ),
    cardDetails: {
      'Wat is enten?': mushroomDetailBlocks(
        fullBody:
            'Enten is het toevoegen van broed (mycelium) aan je voorbereide substraat, zodat het mycelium kan gaan groeien en het substraat koloniseert. Voor $name gebeurt dit ${style == _InocStyle.outdoor ? 'buiten in het bed' : 'binnen op schone wijze'}.',
      ),
      'Wanneer enten?': mushroomDetailBlocks(
        fullBody: '$whenBody\n\nTip: Te heet substraat kan het broed beschadigen. Wacht geduldig!',
      ),
      'Hoeveel broed gebruiken?': mushroomDetailBlocks(
        fullBody: '$spawnRatioBody\n\nTip: Te veel broed is niet nodig. De natuur zorgt voor de rest!',
      ),
      'Entmethode': [
        for (final s in methodSteps)
          PlantGuideDetailBlock(heading: s.title, body: 'Stap: ${s.title}'),
      ],
      'Temperatuur tijdens enten': mushroomDetailBlocks(
        fullBody:
            'Houd de temperatuur tijdens het enten tussen 20 °C en 25 °C. Vermijd extreme hitte of kou — dat kan het mycelium beschadigen.',
      ),
      'Hygiëne is cruciaal': mushroomDetailBlocks(
        fullBody: const [
          'Handen wassen en ontsmetten',
          'Materialen desinfecteren',
          'Schone, stofvrije ruimte',
          'Handschoenen dragen',
          'Geen tocht of luchtstromen',
        ].map((h) => '• $h').join('\n'),
      ),
      'Benodigdheden': mushroomDetailBlocks(
        fullBody: const [
          'Broed',
          'Schoon substraat',
          'Ontsmettingsmiddel',
          'Handschoenen',
          'Filter',
        ].map((s) => '• $s').join('\n'),
      ),
      'Veelgemaakte fouten': mushroomDetailBlocks(
        fullBody: const [
          'Verkeerde verhouding broed/substraat',
          'Onvoldoende desinfectie',
          'Vuile ruimte of gereedschap',
          'Enten bij verkeerde temperatuur',
          'Substraat te lang open laten liggen',
        ].map((m) => '• $m').join('\n'),
      ),
      'Besmetting voorkomen': mushroomDetailBlocks(
        fullBody: const [
          'Rustig en geconcentreerd werken',
          'Alles van tevoren desinfecteren',
          'Vers broed gebruiken',
          'Direct afsluiten na enten',
          'Regelmatig controleren op besmetting',
        ].map((p) => '• $p').join('\n'),
      ),
    },
  );
}

enum _InocStyle { indoorKit, woodBlock, compost, outdoor }

_InocStyle _inocStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _InocStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _InocStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _InocStyle.outdoor;
    default:
      return _InocStyle.indoorKit;
  }
}
