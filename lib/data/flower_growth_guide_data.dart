import '../models/vegetable.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'plant_encyclopedia_layout.dart';
import 'plant_guide_detail.dart';

const _asset = 'assets/images/flower_growth';

class FlowerGrowthStat {
  FlowerGrowthStat({
    required this.label,
    required this.value,
    required this.description,
    required this.imageAsset,
    this.details = const [],
  });

  final String label;
  final String value;
  final String description;
  final String imageAsset;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerGrowthPhase {
  FlowerGrowthPhase({
    required this.label,
    required this.description,
    required this.imageAsset,
    this.details = const [],
  });

  final String label;
  final String description;
  final String imageAsset;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerGrowthAction {
  FlowerGrowthAction({
    required this.label,
    required this.description,
    required this.imageAsset,
    this.details = const [],
  });

  final String label;
  final String description;
  final String imageAsset;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerGrowthSeason {
  FlowerGrowthSeason({
    required this.label,
    required this.months,
    required this.description,
    required this.imageAsset,
    this.details = const [],
  });

  final String label;
  final String months;
  final String description;
  final String imageAsset;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerGrowthMistake {
  FlowerGrowthMistake({
    required this.title,
    required this.body,
    this.details = const [],
  });

  final String title;
  final String body;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerGrowthGuide {
  FlowerGrowthGuide({
    required this.stats,
    required this.phases,
    required this.habitTitle,
    required this.habitDescription,
    required this.habitImage,
    required this.actions,
    required this.tip,
    required this.tipImage,
    required this.seasons,
    required this.mistakes,
    required this.mistakesImage,
  });

  final List<FlowerGrowthStat> stats;
  final List<FlowerGrowthPhase> phases;
  final String habitTitle;
  final String habitDescription;
  final String habitImage;
  final List<FlowerGrowthAction> actions;
  final String tip;
  final String tipImage;
  final List<FlowerGrowthSeason> seasons;
  final List<FlowerGrowthMistake> mistakes;
  final String mistakesImage;
}

final _lavendelGrowthGuide = FlowerGrowthGuide(
  stats: [
    FlowerGrowthStat(
      label: 'Hoogte',
      value: '30 – 60 cm',
      description: 'Wordt compact en blijft laag als struik.',
      imageAsset: '$_asset/flower_growth_height.png',
    ),
    FlowerGrowthStat(
      label: 'Breedte',
      value: '40 – 60 cm',
      description: 'Groei breed uit als lage, dichte struik.',
      imageAsset: '$_asset/flower_growth_width.png',
    ),
    FlowerGrowthStat(
      label: 'Groeisnelheid',
      value: 'Langzaam',
      description: 'Een vaste plant die rustig groeit.',
      imageAsset: '$_asset/flower_growth_speed.png',
    ),
    FlowerGrowthStat(
      label: 'Levensduur',
      value: 'Vaste plant',
      description: 'Komt elk jaar terug en kan jaren meegaan.',
      imageAsset: '$_asset/flower_growth_lifespan.png',
    ),
  ],
  phases: [
    FlowerGrowthPhase(
      label: 'Jonge plant',
      description: 'Wortelt en maakt eerste bladgroei.',
      imageAsset: '$_asset/flower_growth_phase_young.png',
    ),
    FlowerGrowthPhase(
      label: 'Groei',
      description: 'Compacte bladgroei en vestiging.',
      imageAsset: '$_asset/flower_growth_phase_growing.png',
    ),
    FlowerGrowthPhase(
      label: 'Bloei',
      description: 'Paarse bloemen in de zomer.',
      imageAsset: '$_asset/flower_growth_phase_bloom.png',
    ),
    FlowerGrowthPhase(
      label: 'Volwassen plant',
      description: 'Vaste, winterharde struik.',
      imageAsset: '$_asset/flower_growth_phase_adult.png',
    ),
  ],
  habitTitle: 'Groeiwijze',
  habitDescription:
      'Lavendel groeit als compacte, lage struik met zilvergroen blad '
      'en rechte bloemaren.',
  habitImage: '$_asset/flower_growth_habit.png',
  actions: [
    FlowerGrowthAction(
      label: 'Ondersteuning',
      description: 'Meestal niet nodig bij lavendel.',
      imageAsset: '$_asset/flower_growth_support.png',
    ),
    FlowerGrowthAction(
      label: 'Snoeien',
      description: 'Licht terug na bloei en in het voorjaar.',
      imageAsset: '$_asset/flower_growth_pruning.png',
    ),
    FlowerGrowthAction(
      label: 'Groei stimuleren',
      description: 'Volle zon en goed doorlatende grond.',
      imageAsset: '$_asset/flower_growth_stimulate.png',
    ),
    FlowerGrowthAction(
      label: 'Terugbloei',
      description: 'Mogelijk na uitgebloeide aren verwijderen.',
      imageAsset: '$_asset/flower_growth_rebloom.png',
    ),
  ],
  tip:
      'Tip: snoei lavendel licht terug na de bloei voor een compacte vorm '
      'en rijkere bloei volgend jaar.',
  tipImage: '$_asset/flower_growth_tip.png',
  seasons: [
    FlowerGrowthSeason(
      label: 'Lente',
      months: 'Maart – mei',
      description: 'Nieuwe scheuten en begin groei.',
      imageAsset: '$_asset/flower_growth_season_spring.png',
    ),
    FlowerGrowthSeason(
      label: 'Zomer',
      months: 'Juni – augustus',
      description: 'Volle bloei en actieve groei.',
      imageAsset: '$_asset/flower_growth_season_summer.png',
    ),
    FlowerGrowthSeason(
      label: 'Herfst',
      months: 'September – november',
      description: 'Groei vertraagt, plant rust uit.',
      imageAsset: '$_asset/flower_growth_season_autumn.png',
    ),
    FlowerGrowthSeason(
      label: 'Winter',
      months: 'December – februari',
      description: 'Winterrust; blad blijft vaak aan.',
      imageAsset: '$_asset/flower_growth_season_winter.png',
    ),
  ],
  mistakes: [
    FlowerGrowthMistake(
      title: 'Te veel water',
      body: 'Natte grond remt groei en veroorzaakt wortelrot.',
    ),
    FlowerGrowthMistake(
      title: 'Te weinig zon',
      body: 'Lavendel wordt slappe en langere groei zonder volle zon.',
    ),
    FlowerGrowthMistake(
      title: 'Te diep snoeien',
      body: 'Snoei niet in oud hout; dat groeit slecht terug.',
    ),
    FlowerGrowthMistake(
      title: 'Te veel stikstof',
      body: 'Veel blad, minder bloei en slappe groei.',
    ),
  ],
  mistakesImage: '$_asset/flower_growth_mistakes.png',
);

final Map<String, FlowerGrowthGuide> _kFlowerGrowthOverrides = {
  'lavendel': _lavendelGrowthGuide,
};

List<PlantGuideDetailBlock> _gd(
  Vegetable v,
  FlowerGuideProfile p,
  String title,
) =>
    flowerSectionDetailsFor(
      tab: 'growth',
      title: title,
      vegetable: v,
      profile: p,
    );

FlowerGrowthGuide _withGrowthDetails(FlowerGrowthGuide g, Vegetable v) {
  final p = flowerGuideProfileFor(v.id);
  String sum(String title) => flowerCardSummaryFor(
        tab: 'growth',
        title: title,
        vegetable: v,
        profile: p,
      );
  return FlowerGrowthGuide(
    stats: [
      for (final s in g.stats)
        FlowerGrowthStat(
          label: s.label,
          value: s.value,
          description: sum(s.label),
          imageAsset: s.imageAsset,
          details: _gd(v, p, s.label),
        ),
    ],
    phases: [
      for (final ph in g.phases)
        FlowerGrowthPhase(
          label: ph.label,
          description: sum(ph.label),
          imageAsset: ph.imageAsset,
          details: _gd(v, p, ph.label),
        ),
    ],
    habitTitle: g.habitTitle,
    habitDescription: sum(g.habitTitle.isNotEmpty ? g.habitTitle : 'Groeiwijze'),
    habitImage: g.habitImage,
    actions: [
      for (final a in g.actions)
        FlowerGrowthAction(
          label: a.label,
          description: sum(a.label),
          imageAsset: a.imageAsset,
          details: _gd(v, p, a.label),
        ),
    ],
    tip: g.tip,
    tipImage: g.tipImage,
    seasons: [
      for (final s in g.seasons)
        FlowerGrowthSeason(
          label: s.label,
          months: s.months,
          description: sum(s.label),
          imageAsset: s.imageAsset,
          details: _gd(v, p, s.label),
        ),
    ],
    mistakes: [
      for (final m in g.mistakes)
        FlowerGrowthMistake(
          title: m.title,
          body: sum(m.title),
          details: _gd(v, p, m.title),
        ),
    ],
    mistakesImage: g.mistakesImage,
  );
}

FlowerGrowthGuide flowerGrowthGuideForVegetable({
  required Vegetable vegetable,
  required PlantEncyclopediaLayout layout,
}) {
  final exact = _kFlowerGrowthOverrides[vegetable.id];
  if (exact != null) return _withGrowthDetails(exact, vegetable);
  return _withGrowthDetails(
    _buildFlowerGrowthGuide(vegetable, layout),
    vegetable,
  );
}

FlowerGrowthGuide _buildFlowerGrowthGuide(
  Vegetable vegetable,
  PlantEncyclopediaLayout layout,
) {
  final p = flowerGuideProfileFor(vegetable.id);
  final lifespan = layout.lifespan;
  final habit = p.habit.isNotEmpty
      ? p.habit
      : (layout.growthHabit.isNotEmpty ? layout.growthHabit : 'Struik');
  final dryPreferring = p.droughtResistant ||
      p.waterNeed.toLowerCase().contains('weinig') ||
      p.waterNeed.toLowerCase().contains('droog');

  return FlowerGrowthGuide(
    stats: [
      FlowerGrowthStat(
        label: 'Hoogte',
        value: layout.height,
        description: 'Verwachte hoogte voor ${vegetable.nameNl.toLowerCase()}.',
        imageAsset: '$_asset/flower_growth_height.png',
      ),
      FlowerGrowthStat(
        label: 'Breedte',
        value: layout.width,
        description: 'Verwachte breedte in volle grond of pot.',
        imageAsset: '$_asset/flower_growth_width.png',
      ),
      FlowerGrowthStat(
        label: 'Groeisnelheid',
        value: p.growthSpeed.isNotEmpty ? p.growthSpeed : 'Gemiddeld',
        description: 'Groei hangt af van zon, water en voeding.',
        imageAsset: '$_asset/flower_growth_speed.png',
      ),
      FlowerGrowthStat(
        label: 'Levensduur',
        value: lifespan,
        description: 'Hoe lang de plant meestal meegaat.',
        imageAsset: '$_asset/flower_growth_lifespan.png',
      ),
    ],
    phases: [
      FlowerGrowthPhase(
        label: 'Jonge plant',
        description: 'Wortelt na uitplanten of kieming.',
        imageAsset: '$_asset/flower_growth_phase_young.png',
      ),
      FlowerGrowthPhase(
        label: 'Groei',
        description: 'Actieve blad- en stengelgroei (${p.growthSpeed}).',
        imageAsset: '$_asset/flower_growth_phase_growing.png',
      ),
      FlowerGrowthPhase(
        label: 'Bloei',
        description: p.bloomPeriod.isNotEmpty
            ? 'Bloei: ${p.bloomPeriod}.'
            : 'Bloemperiode in het groeiseizoen.',
        imageAsset: '$_asset/flower_growth_phase_bloom.png',
      ),
      FlowerGrowthPhase(
        label: 'Volwassen plant',
        description: 'Volledig ontwikkelde plant ($habit).',
        imageAsset: '$_asset/flower_growth_phase_adult.png',
      ),
    ],
    habitTitle: 'Groeiwijze',
    habitDescription:
        '$habit — typische groeivorm van ${vegetable.nameNl.toLowerCase()}.',
    habitImage: '$_asset/flower_growth_habit.png',
    actions: [
      FlowerGrowthAction(
        label: 'Ondersteuning',
        description: p.supportAdvice.isNotEmpty
            ? p.supportAdvice
            : 'Steun indien nodig bij hoge of slappe groei.',
        imageAsset: '$_asset/flower_growth_support.png',
      ),
      FlowerGrowthAction(
        label: 'Snoeien',
        description: p.pruneAdvice.isNotEmpty
            ? p.pruneAdvice
            : 'Knip uitgebloeide delen en vorm licht bij.',
        imageAsset: '$_asset/flower_growth_pruning.png',
      ),
      FlowerGrowthAction(
        label: 'Groei stimuleren',
        description: 'Zon (${p.sunNeed}), lichte voeding en goede drainage.',
        imageAsset: '$_asset/flower_growth_stimulate.png',
      ),
      FlowerGrowthAction(
        label: 'Terugbloei',
        description: p.rebloomAdvice.isNotEmpty
            ? p.rebloomAdvice
            : 'Deadhead voor kans op tweede bloei.',
        imageAsset: '$_asset/flower_growth_rebloom.png',
      ),
    ],
    tip: p.tip.isNotEmpty
        ? 'Tip: ${p.tip}'
        : (dryPreferring
            ? 'Tip: geef matig water en veel zon voor gezonde, compacte groei.'
            : 'Tip: houd de grond gelijkmatig vochtig tijdens actieve groei.'),
    tipImage: '$_asset/flower_growth_tip.png',
    seasons: [
      FlowerGrowthSeason(
        label: 'Lente',
        months: 'Maart – mei',
        description: 'Start van nieuwe groei.',
        imageAsset: '$_asset/flower_growth_season_spring.png',
      ),
      FlowerGrowthSeason(
        label: 'Zomer',
        months: 'Juni – augustus',
        description: 'Hoogtepunt van bloei en groei.',
        imageAsset: '$_asset/flower_growth_season_summer.png',
      ),
      FlowerGrowthSeason(
        label: 'Herfst',
        months: 'September – november',
        description: 'Groei vertraagt.',
        imageAsset: '$_asset/flower_growth_season_autumn.png',
      ),
      FlowerGrowthSeason(
        label: 'Winter',
        months: 'December – februari',
        description: p.winterHardy
            ? 'Winterrust; vaak winterhard.'
            : 'Rustperiode; bescherm bij vorst.',
        imageAsset: '$_asset/flower_growth_season_winter.png',
      ),
    ],
    mistakes: [
      FlowerGrowthMistake(
        title: dryPreferring ? 'Te veel water' : 'Te weinig water',
        body: dryPreferring
            ? 'Natte grond remt groei.'
            : 'Uitdroging remt groei.',
      ),
      FlowerGrowthMistake(
        title: 'Te weinig zon',
        body: 'Bloemen hebben meestal veel licht nodig (${p.sunNeed}).',
      ),
      FlowerGrowthMistake(
        title: 'Te dicht planten',
        body: 'Geef ruimte (${p.plantSpacing}).',
      ),
      FlowerGrowthMistake(
        title: 'Te veel voeding',
        body: 'Kan slappe groei en minder bloei geven.',
      ),
    ],
    mistakesImage: '$_asset/flower_growth_mistakes.png',
  );
}
