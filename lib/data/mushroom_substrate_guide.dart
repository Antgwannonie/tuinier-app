import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

/// Eén icoon/illustratie met label (stro, zaagsel, houtsoort).
class SubstrateMaterialOption {
  const SubstrateMaterialOption({
    required this.label,
    required this.assetPath,
  });

  final String label;
  final String assetPath;
}

/// Stap in substraat-voorbereiding.
class SubstratePrepStep {
  const SubstratePrepStep({
    required this.title,
    required this.body,
    required this.assetPath,
  });

  final String title;
  final String body;
  final String assetPath;
}

/// Volledige substraat-gids voor één paddenstoel.
class MushroomSubstrateGuide with MushroomGuideCardData {
  const MushroomSubstrateGuide({
    required this.mushroomName,
    required this.whatIsSubstrateBody,
    required this.substratePurposeBody,
    required this.bestBody,
    required this.alternativesBody,
    required this.alternatives,
    required this.woodTypesBody,
    required this.woodTypes,
    required this.moistureBody,
    required this.prepIntro,
    required this.prepSteps,
    required this.pasteurizeBody,
    required this.sterilizeBody,
    required this.temperatureBody,
    required this.mistakes,
    required this.prevention,
    required this.checklist,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String mushroomName;
  final String whatIsSubstrateBody;
  final String substratePurposeBody;
  final String bestBody;
  final String alternativesBody;
  final List<SubstrateMaterialOption> alternatives;
  final String woodTypesBody;
  final List<SubstrateMaterialOption> woodTypes;
  final String moistureBody;
  final String prepIntro;
  final List<SubstratePrepStep> prepSteps;
  final String pasteurizeBody;
  final String sterilizeBody;
  final String temperatureBody;
  final List<String> mistakes;
  final List<String> prevention;
  final List<String> checklist;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_substrate';

MushroomSubstrateGuide substrateGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final style = _growStyleFor(vegetable.id);

  final alternatives = switch (style) {
    _SubstrateStyle.woodBlock => const [
        SubstrateMaterialOption(
          label: 'Eiken',
          assetPath: '$_asset/substrate_wood_beech.png',
        ),
        SubstrateMaterialOption(
          label: 'Beuken',
          assetPath: '$_asset/substrate_wood_beech.png',
        ),
        SubstrateMaterialOption(
          label: 'Essen',
          assetPath: '$_asset/substrate_wood_poplar.png',
        ),
      ],
    _SubstrateStyle.compost => const [
        SubstrateMaterialOption(
          label: 'Compost',
          assetPath: '$_asset/substrate_stro.png',
        ),
        SubstrateMaterialOption(
          label: 'Stro',
          assetPath: '$_asset/substrate_stro.png',
        ),
        SubstrateMaterialOption(
          label: 'Casing',
          assetPath: '$_asset/substrate_zaagsel.png',
        ),
      ],
    _SubstrateStyle.outdoor => const [
        SubstrateMaterialOption(
          label: 'Compost',
          assetPath: '$_asset/substrate_stro.png',
        ),
        SubstrateMaterialOption(
          label: 'Mulch',
          assetPath: '$_asset/substrate_zaagsel.png',
        ),
        SubstrateMaterialOption(
          label: 'Houtsnippers',
          assetPath: '$_asset/substrate_chips.png',
        ),
      ],
    _SubstrateStyle.indoorKit => const [
        SubstrateMaterialOption(
          label: 'Stro',
          assetPath: '$_asset/substrate_stro.png',
        ),
        SubstrateMaterialOption(
          label: 'Zaagsel',
          assetPath: '$_asset/substrate_zaagsel.png',
        ),
        SubstrateMaterialOption(
          label: 'Houtsnippers',
          assetPath: '$_asset/substrate_chips.png',
        ),
      ],
  };

  final woodTypes = switch (style) {
    _SubstrateStyle.woodBlock => const [
        SubstrateMaterialOption(
          label: 'Eiken',
          assetPath: '$_asset/substrate_wood_beech.png',
        ),
        SubstrateMaterialOption(
          label: 'Beuken',
          assetPath: '$_asset/substrate_wood_beech.png',
        ),
        SubstrateMaterialOption(
          label: 'Essen',
          assetPath: '$_asset/substrate_wood_poplar.png',
        ),
      ],
    _SubstrateStyle.compost => const [
        SubstrateMaterialOption(
          label: 'Paardenmest',
          assetPath: '$_asset/substrate_stro.png',
        ),
        SubstrateMaterialOption(
          label: 'Kalk',
          assetPath: '$_asset/substrate_zaagsel.png',
        ),
        SubstrateMaterialOption(
          label: 'Torf',
          assetPath: '$_asset/substrate_chips.png',
        ),
      ],
    _SubstrateStyle.outdoor => const [
        SubstrateMaterialOption(
          label: 'Populier',
          assetPath: '$_asset/substrate_wood_poplar.png',
        ),
        SubstrateMaterialOption(
          label: 'Wilg',
          assetPath: '$_asset/substrate_wood_willow.png',
        ),
        SubstrateMaterialOption(
          label: 'Bladeren',
          assetPath: '$_asset/substrate_chips.png',
        ),
      ],
    _SubstrateStyle.indoorKit => const [
        SubstrateMaterialOption(
          label: 'Populier',
          assetPath: '$_asset/substrate_wood_poplar.png',
        ),
        SubstrateMaterialOption(
          label: 'Wilg',
          assetPath: '$_asset/substrate_wood_willow.png',
        ),
        SubstrateMaterialOption(
          label: 'Beuk',
          assetPath: '$_asset/substrate_wood_beech.png',
        ),
      ],
  };

  final alternativesBody = switch (style) {
    _SubstrateStyle.woodBlock =>
      'Hardhoutblokken van eiken of beuk zijn ideaal. Gebruik vers, onbehandeld hout.',
    _SubstrateStyle.compost =>
      'Gecomposteerde mest met stro en een casinglaag van turf of kalk.',
    _SubstrateStyle.outdoor =>
      'Compost, mulch en houtsnippers. Ook bladeren en stro werken goed in een buitenbed.',
    _SubstrateStyle.indoorKit =>
      'Naast stro en zaagsel kun je ook koffiedik, karton of maïsstengels gebruiken als mengsel.',
  };

  final woodTypesBody = switch (style) {
    _SubstrateStyle.woodBlock =>
      'Eiken en beuk zijn klassiek voor $name. Essen en populier werken ook, maar koloniseren soms trager.',
    _SubstrateStyle.compost =>
      'Goed doorgewerkte compost met de juiste pH en vochtigheid is essentieel voor champignons.',
    _SubstrateStyle.outdoor =>
      'Zachthout zoals populier en wilg verrotten snel en zijn ideaal voor buitenbedden.',
    _SubstrateStyle.indoorKit =>
      'Zachthout zoals populier en wilg zijn ideaal. Beuk en essen werken ook, maar groeien iets trager.',
  };

  final bestBody = switch (style) {
    _SubstrateStyle.woodBlock =>
      '$name groeit het beste op hardhoutblokken rijk aan lignine. ${overview.substrate}.',
    _SubstrateStyle.compost =>
      '$name heeft goed doorgewerkte compost nodig met een casinglaag. ${overview.substrate}.',
    _SubstrateStyle.outdoor =>
      '$name gedijt op compost- en mulchbedden buiten. ${overview.substrate}.',
    _SubstrateStyle.indoorKit =>
      '$name groeit het beste op substraat rijk aan lignocellulose, zoals stro, zaagsel en houtsnippers. ${overview.substrate}.',
  };

  final pasteurizeBody = _isOutdoor(style)
      ? 'Verhit het bed indirect tot 60–80 °C gedurende 1–2 uur, of laat composteren tot 60–70 °C.'
      : 'Verhit het substraat tot 60–80 °C gedurende 1–2 uur om bacteriën en ongewenste schimmels te doden, maar voedingsstoffen te behouden.';

  final sterilizeBody = style == _SubstrateStyle.compost ||
          style == _SubstrateStyle.indoorKit
      ? 'Voor zuiver substraat: volledige sterilisatie op 121 °C gedurende 60–90 minuten in een drukketel.'
      : 'Houtblokken worden vaak gesteriliseerd vóór inoculatie. Buitenbedden worden gepasteuriseerd in plaats van gesteriliseerd.';

  final whatIsSubstrateBody = switch (style) {
    _SubstrateStyle.woodBlock =>
      'Substraat is het voedingsmedium waarop het mycelium van $name groeit. '
      'Bij houtbewerkende soorten is dat meestal hardhout rijk aan lignine — '
      'het mycelium breekt houtvezels af en gebruikt die als energiebron.',
    _SubstrateStyle.compost =>
      'Substraat is de bodemlaag waarin het mycelium van $name leeft en zich verspreidt. '
      'Voor champignons is dat goed doorgewerkte compost, vaak met een aparte casinglaag erboven.',
    _SubstrateStyle.outdoor =>
      'Substraat is het organische materiaal in je buitenbed waar $name op groeit — '
      'compost, mulch, stro of houtsnippers waar het mycelium zich doorheen koloniseert.',
    _SubstrateStyle.indoorKit =>
      'Substraat is het mengsel van organische materialen waarin het mycelium van $name groeit. '
      'Meestal stro, zaagsel of houtsnippers: cellulose en lignine die het schimmelnetwerk voedt.',
  };

  final substratePurposeBody = switch (style) {
    _SubstrateStyle.woodBlock =>
      'Je gebruikt substraat om spawn te laten koloniseren tot het hout volledig wit is. '
      'Daarna triggert je omstandigheden (schok, vocht, frisse lucht) vruchtvorming op het blok.',
    _SubstrateStyle.compost =>
      'Substraat voedt het mycelium tijdens kolonisatie en houdt vocht vast tijdens de flushes. '
      'De casinglaag helpt bij vochtregulatie en beschermt het mycelium tot de paddenstoelen opkomen.',
    _SubstrateStyle.outdoor =>
      'In een buitenbed dient substraat als langdurige voedingsbron en vochtspons. '
      'Het geeft het mycelium ruimte om te koloniseren en jaar na jaar nieuwe oogsten te leveren.',
    _SubstrateStyle.indoorKit =>
      'Substraat is de basis van je kweek: eerst koloniseert het mycelium het mengsel, '
      'daarna gebruik je hetzelfde substraat om vruchtvorming en meerdere flushes te krijgen.',
  };

  return MushroomSubstrateGuide(
    mushroomName: name,
    whatIsSubstrateBody: whatIsSubstrateBody,
    substratePurposeBody: substratePurposeBody,
    bestBody: bestBody,
    alternativesBody: alternativesBody,
    alternatives: alternatives,
    woodTypesBody: woodTypesBody,
    woodTypes: woodTypes,
    moistureBody:
        'Het substraat moet een vochtgehalte hebben van 60–70 %. Knijp in het substraat: er mag een paar druppels uitkomen, maar het mag niet druipen.',
    prepIntro: 'Volg deze stappen voor een perfect voorbereid substraat.',
    prepSteps: const [
      SubstratePrepStep(
        title: 'Mengen',
        body: 'Meng de droge ingrediënten goed door elkaar.',
        assetPath: '$_asset/substrate_step_mix.png',
      ),
      SubstratePrepStep(
        title: 'Bevochtigen',
        body: 'Voeg water toe tot het juiste vochtgehalte is bereikt.',
        assetPath: '$_asset/substrate_step_moisten.png',
      ),
      SubstratePrepStep(
        title: 'Pasteuriseren',
        body: 'Verhit om schadelijke organismen te doden.',
        assetPath: '$_asset/substrate_step_pasteurize.png',
      ),
      SubstratePrepStep(
        title: 'Afkoelen',
        body: 'Laat afkoelen tot kamertemperatuur vóór enten.',
        assetPath: '$_asset/substrate_step_cool.png',
      ),
    ],
    pasteurizeBody: pasteurizeBody,
    sterilizeBody: sterilizeBody,
    temperatureBody:
        'Het substraat moet tussen de 20 °C en 25 °C zijn voordat je gaat enten. Te warm substraat doodt spawn; te koud vertraagt kolonisatie.',
    mistakes: const [
      'Te nat substraat',
      'Te droog substraat',
      'Onvoldoende pasteurisatie',
      'Enten bij te warm substraat',
      'Vuile werkplek',
    ],
    prevention: const [
      'Werk schoon en desinfecteer handen',
      'Gebruik schone materialen',
      'Ventileer na pasteurisatie',
      'Dek substraat af tot enten',
    ],
    checklist: const [
      'Vochtgehalte correct',
      'Substraat goed voorbereid',
      'Temperatuur 20–25 °C',
      'Werkplek gedesinfecteerd',
      'Klaar om te enten!',
    ],
    cardSummaries: mushroomCardSummaries(
      tab: 'substrate',
      vegetable: vegetable,
      titles: const [
        'Wat is substraat?',
        'Waarvoor gebruik je het?',
        'Beste substraat',
        'Alternatieve substraten',
        'Geschikte houtsoorten',
        'Ideaal vochtgehalte',
        'Substraat voorbereiden',
        'Pasteuriseren',
        'Steriliseren',
        'Temperatuur van het substraat',
        'Veelgemaakte fouten',
        'Besmetting voorkomen',
      ],
    ),
    cardDetails: {
      'Wat is substraat?': mushroomDetailBlocks(fullBody: whatIsSubstrateBody),
      'Waarvoor gebruik je het?':
          mushroomDetailBlocks(fullBody: substratePurposeBody),
      'Beste substraat': mushroomDetailBlocks(fullBody: bestBody),
      'Alternatieve substraten':
          mushroomDetailBlocks(fullBody: alternativesBody),
      'Geschikte houtsoorten': mushroomDetailBlocks(fullBody: woodTypesBody),
      'Ideaal vochtgehalte': mushroomDetailBlocks(
        fullBody:
            'Het substraat moet een vochtgehalte hebben van 60–70 %. Knijp in het substraat: er mag een paar druppels uitkomen, maar het mag niet druipen.',
      ),
      'Substraat voorbereiden': [
        PlantGuideDetailBlock(heading: 'Intro', body: 'Volg deze stappen voor een perfect voorbereid substraat.'),
        for (final s in const [
          SubstratePrepStep(
            title: 'Mengen',
            body: 'Meng de droge ingrediënten goed door elkaar.',
            assetPath: '$_asset/substrate_step_mix.png',
          ),
          SubstratePrepStep(
            title: 'Bevochtigen',
            body: 'Voeg water toe tot het juiste vochtgehalte is bereikt.',
            assetPath: '$_asset/substrate_step_moisten.png',
          ),
          SubstratePrepStep(
            title: 'Pasteuriseren',
            body: 'Verhit om schadelijke organismen te doden.',
            assetPath: '$_asset/substrate_step_pasteurize.png',
          ),
          SubstratePrepStep(
            title: 'Afkoelen',
            body: 'Laat afkoelen tot kamertemperatuur vóór enten.',
            assetPath: '$_asset/substrate_step_cool.png',
          ),
        ])
          PlantGuideDetailBlock(heading: s.title, body: s.body),
      ],
      'Pasteuriseren': mushroomDetailBlocks(fullBody: pasteurizeBody),
      'Steriliseren': mushroomDetailBlocks(fullBody: sterilizeBody),
      'Temperatuur van het substraat': mushroomDetailBlocks(
        fullBody:
            'Het substraat moet tussen de 20 °C en 25 °C zijn voordat je gaat enten. Te warm substraat doodt spawn; te koud vertraagt kolonisatie.',
      ),
      'Veelgemaakte fouten': mushroomDetailBlocks(
        fullBody: const [
          'Te nat substraat',
          'Te droog substraat',
          'Onvoldoende pasteurisatie',
          'Enten bij te warm substraat',
          'Vuile werkplek',
        ].map((m) => '• $m').join('\n'),
      ),
      'Besmetting voorkomen': mushroomDetailBlocks(
        fullBody: const [
          'Werk schoon en desinfecteer handen',
          'Gebruik schone materialen',
          'Ventileer na pasteurisatie',
          'Dek substraat af tot enten',
        ].map((p) => '• $p').join('\n'),
      ),
    },
  );
}

enum _SubstrateStyle { indoorKit, woodBlock, compost, outdoor }

bool _isOutdoor(_SubstrateStyle style) => style == _SubstrateStyle.outdoor;

_SubstrateStyle _growStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _SubstrateStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _SubstrateStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _SubstrateStyle.outdoor;
    default:
      return _SubstrateStyle.indoorKit;
  }
}
