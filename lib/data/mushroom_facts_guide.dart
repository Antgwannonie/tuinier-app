import 'package:flutter/material.dart';

import '../models/vegetable.dart';
import '../utils/plant_display_info.dart';
import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';
import 'plant_search_filters.dart';
import 'vegetable_image_info.dart';
import 'vegetable_repository.dart';

const _asset = 'assets/images/mushroom_facts';

class FactsTopItem {
  const FactsTopItem({
    required this.number,
    required this.title,
    required this.description,
    required this.assetPath,
  });

  final int number;
  final String title;
  final String description;
  final String assetPath;
}

class FactsDidYouKnowItem {
  const FactsDidYouKnowItem({
    required this.icon,
    required this.stat,
    required this.description,
  });

  final IconData icon;
  final String stat;
  final String description;
}

class FactsSpotlightSpecies {
  const FactsSpotlightSpecies({
    required this.id,
    required this.name,
    required this.assetPath,
    required this.isCurrent,
    this.shortFact,
  });

  final String id;
  final String name;
  final String assetPath;
  final bool isCurrent;
  final String? shortFact;
}

class MushroomFactsGuide with MushroomGuideCardData {
  const MushroomFactsGuide({
    required this.heroIntro,
    required this.topFacts,
    required this.didYouKnow,
    required this.cultivationBullets,
    required this.spotlightSpecies,
    required this.footerText,
    this.cardSummaries = const {},
    this.cardDetails = const {},
  });

  final String heroIntro;
  final List<FactsTopItem> topFacts;
  final List<FactsDidYouKnowItem> didYouKnow;
  final List<String> cultivationBullets;
  final List<FactsSpotlightSpecies> spotlightSpecies;
  final String footerText;
  @override
  final Map<String, String> cardSummaries;
  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;
}

const _defaultSpotlightIds = [
  'oesterzwam',
  'shiitake',
  'koningsoesterzwam',
  'enoki',
  'shimeji',
];

const _topFacts = [
  FactsTopItem(
    number: 1,
    title: 'Geen plant maar schimmel',
    description:
        'Paddenstoelen horen tot het rijk der schimmels — geen blad, wortels of fotosynthese zoals planten.',
    assetPath: '$_asset/facts_top1_fungus.png',
  ),
  FactsTopItem(
    number: 2,
    title: 'Mycelium motor',
    description:
        'Het mycelium is het onzichtbare netwerk onder de grond dat voedingsstoffen opneemt en vruchtlichamen voedt.',
    assetPath: '$_asset/facts_top2_mycelium.png',
  ),
  FactsTopItem(
    number: 3,
    title: 'Nuttig voor natuur',
    description:
        'Schimmels breken dood hout en bladeren af tot voedingsrijke grond — essentieel voor gezonde ecosystemen.',
    assetPath: '$_asset/facts_top3_nature.png',
  ),
  FactsTopItem(
    number: 4,
    title: 'Voedzaam & gezond',
    description:
        'Paddenstoelen zijn laag in calorieën, rijk aan eiwitten, vezels en B-vitamines — een echte superfood.',
    assetPath: '$_asset/facts_top4_nutrition.png',
  ),
  FactsTopItem(
    number: 5,
    title: 'Duizenden jaren gebruikt',
    description:
        'In Azië worden paddenstoelen al millennia geteeld en medicinaal gebruikt — shiitake al sinds 1209 n.Chr.',
    assetPath: '$_asset/facts_top5_history.png',
  ),
  FactsTopItem(
    number: 6,
    title: 'Duizenden soorten',
    description:
        'Wetenschappers kennen meer dan 14.000 eetbare soorten — maar slechts enkele tientallen worden commercieel geteeld.',
    assetPath: '$_asset/facts_top6_variety.png',
  ),
];

const _didYouKnow = [
  FactsDidYouKnowItem(
    icon: Icons.public_rounded,
    stat: 'Op alle continenten',
    description: 'Paddenstoelen groeien op elk continent behalve Antarctica.',
  ),
  FactsDidYouKnowItem(
    icon: Icons.hub_rounded,
    stat: 'Km\'s mycelium',
    description:
        'Eén paddenstoel kan een myceliumnetwerk van honderden kilometers onder de grond vormen.',
  ),
  FactsDidYouKnowItem(
    icon: Icons.water_drop_outlined,
    stat: '90–95% water',
    description: 'Vers geoogste paddenstoelen bestaan grotendeels uit water — daardoor zo kwetsbaar.',
  ),
  FactsDidYouKnowItem(
    icon: Icons.eco_outlined,
    stat: 'Natuurrecyclers',
    description:
        'Schimmels zijn de belangrijkste afbrekers van organisch materiaal in bossen en tuinen.',
  ),
];

String? _spotlightAssetFor(String id) {
  final info = kVegetableImages[id];
  if (info?.assetPath != null) return info!.assetPath;
  if (id == 'koningsoesterzwam') return '$_asset/facts_spotlight_king_oyster.png';
  return null;
}

List<FactsSpotlightSpecies> _spotlightFor(Vegetable current) {
  final repo = VegetableRepository();
  final ids = List<String>.from(_defaultSpotlightIds);

  if (kMushroomPlantIds.contains(current.id) && !ids.contains(current.id)) {
    ids.insert(0, current.id);
  } else if (ids.contains(current.id)) {
    ids.remove(current.id);
    ids.insert(0, current.id);
  }

  final seen = <String>{};
  final result = <FactsSpotlightSpecies>[];

  for (final id in ids) {
    if (seen.contains(id) || result.length >= 5) continue;
    seen.add(id);

    final v = repo.byId(id);
    if (v == null) continue;

    final asset = _spotlightAssetFor(id);
    if (asset == null) continue;

    final name = v.nameNl.split('(').first.trim();
    result.add(
      FactsSpotlightSpecies(
        id: id,
        name: name,
        assetPath: asset,
        isCurrent: id == current.id,
        shortFact: id == current.id
            ? buildMushroomOverviewLayout(v).goodToKnow
            : null,
      ),
    );
  }

  return result;
}

MushroomFactsGuide factsGuideForVegetable(Vegetable vegetable) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final name = vegetable.nameNl.split('(').first.trim();
  final latin = latinNameForVegetable(vegetable) ?? vegetable.nameLatin ?? '';

  final heroIntro = latin.isNotEmpty
      ? 'Paddenstoelen zoals $name ($latin) behoren tot een van de meest fascinerende '
          'levensvormen op aarde. ${overview.summary}'
      : 'Paddenstoelen zoals $name behoren tot een van de meest fascinerende '
          'levensvormen op aarde. ${overview.summary}';

  final cultivationBullets = [
    'Thuis kweken kan al vanaf een growkit — geen tuin nodig',
    'Mycelium groeit het best in een donkere, vochtige omgeving',
    'Eerste oogst vaak binnen 2–4 weken na vruchtzetting',
    'Eén substraatblok kan meerdere flushes (oogsten) geven',
  ];

  return MushroomFactsGuide(
    heroIntro: heroIntro,
    topFacts: _topFacts,
    didYouKnow: _didYouKnow,
    cultivationBullets: cultivationBullets,
    spotlightSpecies: _spotlightFor(vegetable),
    footerText:
        'Blijf nieuwsgierig — elke paddenstoelsoort heeft unieke eigenschappen. '
        'Ontdek meer in de andere info-tabs of begin met kweken van $name!',
    cardSummaries: mushroomCardSummaries(
      tab: 'facts',
      vegetable: vegetable,
      titles: const [
        'Ontdek de fascinerende wereld van paddenstoelen',
        'Top 6 weetjes',
        'Wist je dat?',
        'Leuke feitjes over kweek',
        'Soorten in de spotlight',
      ],
    ),
    cardDetails: {
      'Ontdek de fascinerende wereld van paddenstoelen':
          mushroomDetailBlocks(fullBody: heroIntro),
      'Top 6 weetjes': [
        for (final f in _topFacts)
          PlantGuideDetailBlock(
            heading: '${f.number}. ${f.title}',
            body: f.description,
          ),
      ],
      'Wist je dat?': [
        for (final d in _didYouKnow)
          PlantGuideDetailBlock(
            heading: d.stat,
            body: d.description,
          ),
      ],
      'Leuke feitjes over kweek': mushroomDetailBlocks(
        fullBody: cultivationBullets.map((b) => '• $b').join('\n'),
      ),
      'Soorten in de spotlight': [
        for (final s in _spotlightFor(vegetable))
          PlantGuideDetailBlock(
            heading: s.name,
            body: s.shortFact ?? 'Populaire paddenstoelsoort.',
          ),
      ],
    },
  );
}
