import '../models/vegetable.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';

class HarvestTimingCard {
  const HarvestTimingCard({
    required this.title,
    required this.body,
    required this.assetPath,
  });

  final String title;
  final String body;
  final String assetPath;
}

class HarvestMethodStep {
  const HarvestMethodStep({
    required this.title,
    required this.body,
    required this.assetPath,
  });

  final String title;
  final String body;
  final String assetPath;
}

class HarvestAfterItem {
  const HarvestAfterItem({
    required this.title,
    required this.body,
    required this.icon,
  });

  final String title;
  final String body;
  final String icon;
}

class MushroomHarvestGuide with MushroomGuideCardData {
  const MushroomHarvestGuide({
    required this.heroBody,
    required this.timingCards,
    required this.methodSteps,
    required this.afterHarvestItems,
    required this.tips,
    required this.flushSummary,
    required this.yieldBody,
    required this.mistakes,
    required this.footerTip,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String heroBody;
  final List<HarvestTimingCard> timingCards;
  final List<HarvestMethodStep> methodSteps;
  final List<HarvestAfterItem> afterHarvestItems;
  final List<String> tips;
  final String flushSummary;
  final String yieldBody;
  final List<String> mistakes;
  final String footerTip;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _asset = 'assets/images/mushroom_harvest';

const _timingCards = [
  HarvestTimingCard(
    title: 'Juiste grootte',
    body: 'Hoed is volledig gevormd maar rand staat nog naar beneden of net plat.',
    assetPath: '$_asset/harvest_timing_size.png',
  ),
  HarvestTimingCard(
    title: 'Net voor sporenval',
    body: 'Oogst vóór de hoed volledig opent en sporen vrijkomen voor beste smaak.',
    assetPath: '$_asset/harvest_timing_spores.png',
  ),
  HarvestTimingCard(
    title: 'Stevig en gezond',
    body: 'Paddenstoel voelt stevig aan, geen vlekken, geen uitdroging of verkleuring.',
    assetPath: '$_asset/harvest_timing_healthy.png',
  ),
  HarvestTimingCard(
    title: 'Gelijke oogst',
    body: 'Oogst alle rijpe paddenstoelen tegelijk voor een gelijkmatige volgende flush.',
    assetPath: '$_asset/harvest_timing_even.png',
  ),
];

const _afterHarvestItems = [
  HarvestAfterItem(
    title: 'Bevochtig licht',
    body: 'Vernevel kort na oogst om het substraat vochtig te houden.',
    icon: 'water',
  ),
  HarvestAfterItem(
    title: 'Zorg voor ventilatie',
    body: 'Frisse lucht voorkomt CO₂-opbouw en schimmel na het oogsten.',
    icon: 'fan',
  ),
  HarvestAfterItem(
    title: 'Optimale omstandigheden',
    body: 'Houd temperatuur en luchtvochtigheid stabiel voor de volgende flush.',
    icon: 'thermometer',
  ),
  HarvestAfterItem(
    title: 'Nieuwe groeicyclus',
    body: 'Na rust volgt een nieuwe flush — geduld loont!',
    icon: 'refresh',
  ),
];

MushroomHarvestGuide harvestGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final style = _harvestStyleFor(vegetable.id);

  final heroBody = switch (style) {
    _HarvestStyle.outdoor =>
      'Oogsten is het moment waarop je de vruchten van $name uit het bed haalt. Buiten oogst je meestal in flushes — oogst op het juiste moment voor de beste smaak en volgende ronde.',
    _HarvestStyle.woodBlock =>
      'Oogsten is het moment waarop je de vruchten van $name van het houtblok haalt. Oogst stevig en schoon bij de basis voor de beste kwaliteit en volgende flush.',
    _HarvestStyle.compost =>
      'Oogsten is het moment waarop je de vruchten van $name van de compost haalt. Oogst regelmatig en gelijkmatig voor maximale opbrengst per flush.',
    _HarvestStyle.indoorKit =>
      'Oogsten is het moment waarop je de vruchten van $name van je substraatblok haalt. Oogst op het juiste moment voor de beste smaak, textuur en volgende flush.',
  };

  final methodSteps = switch (style) {
    _HarvestStyle.woodBlock => const [
        HarvestMethodStep(
          title: 'Voorbereiden',
          body: 'Was handen, draag handschoenen en desinfecteer mes of schaar.',
          assetPath: '$_asset/harvest_step_prepare.png',
        ),
        HarvestMethodStep(
          title: 'Grijp de basis',
          body: 'Pak de steel stevig vast bij de basis van de hoed.',
          assetPath: '$_asset/harvest_step_grasp.png',
        ),
        HarvestMethodStep(
          title: 'Snij schoon af',
          body: 'Snij met scherp mes vlak bij het houtblok. Trek niet.',
          assetPath: '$_asset/harvest_step_twist.png',
        ),
        HarvestMethodStep(
          title: 'Controleer de basis',
          body: 'Verwijder resten van steel. Laat het blok schoon achter.',
          assetPath: '$_asset/harvest_step_check.png',
        ),
      ],
    _HarvestStyle.outdoor => const [
        HarvestMethodStep(
          title: 'Voorbereiden',
          body: 'Was handen en neem een schoon mes of schaar mee.',
          assetPath: '$_asset/harvest_step_prepare.png',
        ),
        HarvestMethodStep(
          title: 'Grijp de basis',
          body: 'Pak de paddenstoel stevig vast bij de basis.',
          assetPath: '$_asset/harvest_step_grasp.png',
        ),
        HarvestMethodStep(
          title: 'Snij bij de basis',
          body: 'Snij schoon af bij het substraat. Niet rukken.',
          assetPath: '$_asset/harvest_step_twist.png',
        ),
        HarvestMethodStep(
          title: 'Controleer de basis',
          body: 'Verwijder resten. Laat het bed netjes achter.',
          assetPath: '$_asset/harvest_step_check.png',
        ),
      ],
    _ => const [
        HarvestMethodStep(
          title: 'Voorbereiden',
          body: 'Was handen, draag blauwe handschoenen en zorg voor schone omgeving.',
          assetPath: '$_asset/harvest_step_prepare.png',
        ),
        HarvestMethodStep(
          title: 'Grijp de basis',
          body: 'Pak de steel stevig vast bij de basis van de cluster.',
          assetPath: '$_asset/harvest_step_grasp.png',
        ),
        HarvestMethodStep(
          title: 'Draai en trek',
          body: 'Draai zachtjes en trek met een vloeiende beweging los.',
          assetPath: '$_asset/harvest_step_twist.png',
        ),
        HarvestMethodStep(
          title: 'Controleer de basis',
          body: 'Controleer of geen resten achterblijven op het substraat.',
          assetPath: '$_asset/harvest_step_check.png',
        ),
      ],
  };

  final tips = switch (style) {
    _HarvestStyle.outdoor => [
      'Oogst in de ochtend bij hoge luchtvochtigheid',
      'Oogst alle rijpe paddenstoelen tegelijk',
      'Gebruik een schoon, scherp mes',
      'Bescherm het bed na oogst tegen uitdroging',
      'Noteer oogstdatum voor volgende flush',
      'Oogst vóór sporen vrijkomen',
    ],
    _HarvestStyle.woodBlock => [
      'Oogst wanneer rand nog naar beneden staat',
      'Snij schoon bij het houtblok — niet rukken',
      'Oogst in de ochtend voor beste kwaliteit',
      'Verwijder alle rijpe vruchten per flush',
      'Houd luchtvochtigheid hoog na oogst',
      'Geef het blok rust voor de volgende flush',
    ],
    _HarvestStyle.compost => [
      'Oogst wanneer hoed net plat staat',
      'Twist niet — snij bij de basis',
      'Oogst gelijkmatig voor gelijke volgende flush',
      'Vernevel licht na elke oogst',
      'Houd compost vochtig maar niet nat',
      'Oogst vóór sporenregen',
    ],
    _HarvestStyle.indoorKit => [
      'Oogst wanneer rand nog naar beneden staat',
      'Draai en trek — niet rukken of scheuren',
      'Oogst alle rijpe clusters tegelijk',
      'Vernevel kort na oogst',
      'Houd growkit op dezelfde plek',
      'Oogst vóór sporen vrijkomen',
    ],
  };

  final mistakes = switch (style) {
    _HarvestStyle.outdoor => const [
      'Te laat oogsten — sporenregen en mindere smaak',
      'Te vroeg oogsten — kleinere opbrengst',
      'Rukken in plaats van snijden',
      'Substraat beschadigen bij oogst',
      'Niet alle rijpe vruchten oogsten',
    ],
    _HarvestStyle.woodBlock => const [
      'Te laat oogsten — hoed volledig open',
      'Rukken en houtblok beschadigen',
      'Resten van steel laten staan',
      'Substraat uit laten drogen na oogst',
      'Te vroeg oogsten — kleinere vruchten',
    ],
    _ => const [
      'Te laat oogsten — sporenregen en mindere smaak',
      'Te vroeg oogsten — kleinere opbrengst',
      'Rukken in plaats van draaien',
      'Substraat beschadigen bij oogst',
      'Niet alle rijpe paddenstoelen oogsten',
    ],
  };

  return MushroomHarvestGuide(
    heroBody: heroBody,
    timingCards: _timingCards,
    methodSteps: methodSteps,
    afterHarvestItems: _afterHarvestItems,
    tips: tips,
    flushSummary: overview.flushCount,
    yieldBody: overview.yield,
    mistakes: mistakes,
    footerTip:
        'Regelmatig en op het juiste moment oogsten zorgt voor gezonde flushes en maximale opbrengst!',
    cardSummaries: mushroomCardSummaries(
      tab: 'harvest',
      vegetable: vegetable,
      titles: const [
        'Wanneer en hoe oogst je?',
        'Wanneer is het tijd om te oogsten?',
        'Hoe oogst je?',
        'Na het oogsten',
        'Tips voor een betere opbrengst',
        'Wat kun je verwachten?',
        'Veelgemaakte fouten',
      ],
    ),
    cardDetails: {
      'Wanneer en hoe oogst je?': mushroomDetailBlocks(fullBody: heroBody),
      'Wanneer is het tijd om te oogsten?': [
        for (final c in _timingCards)
          PlantGuideDetailBlock(heading: c.title, body: c.body),
      ],
      'Hoe oogst je?': [
        for (final s in methodSteps)
          PlantGuideDetailBlock(heading: s.title, body: s.body),
      ],
      'Na het oogsten': [
        for (final a in _afterHarvestItems)
          PlantGuideDetailBlock(heading: a.title, body: a.body),
      ],
      'Tips voor een betere opbrengst':
          mushroomDetailBlocks(fullBody: tips.map((t) => '• $t').join('\n')),
      'Wat kun je verwachten?': mushroomDetailBlocks(
        fullBody:
            'Gemiddeld ${overview.flushCount}\nOpbrengst per flush: ${overview.yield}',
      ),
      'Veelgemaakte fouten':
          mushroomDetailBlocks(fullBody: mistakes.map((m) => '• $m').join('\n')),
    },
  );
}

enum _HarvestStyle { indoorKit, woodBlock, compost, outdoor }

_HarvestStyle _harvestStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _HarvestStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _HarvestStyle.compost;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _HarvestStyle.outdoor;
    default:
      return _HarvestStyle.indoorKit;
  }
}
