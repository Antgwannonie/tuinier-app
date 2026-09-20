import '../models/vegetable.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'plant_encyclopedia_layout.dart';
import 'plant_guide_detail.dart';

const _asset = 'assets/images/flower_seed_harvest';

enum FlowerSeedCalendarStatus {
  none,
  start,
  best,
}

class FlowerSeedFact {
  FlowerSeedFact({
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

class FlowerSeedMonth {
  FlowerSeedMonth({
    required this.month,
    required this.shortLabel,
    required this.status,
    required this.statusLabel,
  });

  final int month;
  final String shortLabel;
  final FlowerSeedCalendarStatus status;
  final String statusLabel;
}

class FlowerSeedMistake {
  FlowerSeedMistake({
    required this.title,
    required this.body,
    this.details = const [],
  });

  final String title;
  final String body;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerSeedHarvestGuide {
  FlowerSeedHarvestGuide({
    required this.facts,
    required this.selfSowTitle,
    required this.selfSowPeriod,
    required this.selfSowBody,
    required this.selfSowImage,
    required this.tips,
    required this.tipImage,
    required this.calendar,
    required this.calendarNote,
    required this.mistakes,
  });

  final List<FlowerSeedFact> facts;
  final String selfSowTitle;
  final String selfSowPeriod;
  final String selfSowBody;
  final String selfSowImage;
  final List<String> tips;
  final String tipImage;
  final List<FlowerSeedMonth> calendar;
  final String calendarNote;
  final List<FlowerSeedMistake> mistakes;
}

String flowerSeedCalendarImage(FlowerSeedCalendarStatus status) {
  return switch (status) {
    FlowerSeedCalendarStatus.none => '$_asset/flower_seed_cal_none.png',
    FlowerSeedCalendarStatus.start || FlowerSeedCalendarStatus.best =>
      '$_asset/flower_seed_cal_harvest.png',
  };
}

final _lavendelSeedHarvestGuide = FlowerSeedHarvestGuide(
  facts: [
    FlowerSeedFact(
      label: 'Wanneer oogsten',
      value: 'Juli – september',
      description:
          'Oogst als de zaaddozen bruin en droog zijn, maar nog dicht.',
      imageAsset: '$_asset/flower_seed_when.png',
    ),
    FlowerSeedFact(
      label: 'Zaadrijp herkennen',
      value: 'Bruin & droog',
      description:
          'Dozen zijn bruin, droog en kraken licht bij aanraking.',
      imageAsset: '$_asset/flower_seed_ripe.png',
    ),
    FlowerSeedFact(
      label: 'Zaden verzamelen',
      value: 'Knip de stengels af',
      description:
          'Knip aren met een stukje stengel en leg ze in een papieren zak.',
      imageAsset: '$_asset/flower_seed_collect.png',
    ),
    FlowerSeedFact(
      label: 'Drogen',
      value: '7 – 14 dagen',
      description:
          'Hang stengels ondersteboven op een droge, luchtige plek.',
      imageAsset: '$_asset/flower_seed_dry.png',
    ),
    FlowerSeedFact(
      label: 'Zaden losmaken',
      value: 'Wrijf of klop',
      description:
          'Wrijf de dozen tussen je handen of klop zacht boven een schaal.',
      imageAsset: '$_asset/flower_seed_loosen.png',
    ),
    FlowerSeedFact(
      label: 'Zaden zeven',
      value: 'Verwijder resten',
      description:
          'Zeef om resten en lege husken van de zaden te scheiden.',
      imageAsset: '$_asset/flower_seed_sieve.png',
    ),
    FlowerSeedFact(
      label: 'Bewaren',
      value: 'Luchtdicht & koel',
      description:
          'Bewaar in een luchtdichte pot of envelop op een koele, droge plek.',
      imageAsset: '$_asset/flower_seed_store.png',
    ),
    FlowerSeedFact(
      label: 'Houdbaarheid',
      value: '2 – 3 jaar',
      description: 'Lavendelzaden blijven ongeveer 3 jaar kiemkrachtig.',
      imageAsset: '$_asset/flower_seed_shelf.png',
    ),
  ],
  selfSowTitle: 'Zelf uitzaaien',
  selfSowPeriod: 'Februari – april',
  selfSowBody:
      'Zaai in trays bij 15 – 20 °C. Licht aandrukken; lavendelzaden '
      'kiemen beter met licht.',
  selfSowImage: '$_asset/flower_seed_sow.png',
  tips: [
    'Oogst alleen van gezonde, sterke planten.',
    'Laat een deel van de bloemen staan voor bijen.',
    'Bij kruisbestuiving kunnen nakomelingen afwijken van de moederplant.',
  ],
  tipImage: '$_asset/flower_seed_tip.png',
  calendar: [
    FlowerSeedMonth(
      month: 1,
      shortLabel: 'Jan',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
    FlowerSeedMonth(
      month: 2,
      shortLabel: 'Feb',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
    FlowerSeedMonth(
      month: 3,
      shortLabel: 'Mrt',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
    FlowerSeedMonth(
      month: 4,
      shortLabel: 'Apr',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
    FlowerSeedMonth(
      month: 5,
      shortLabel: 'Mei',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
    FlowerSeedMonth(
      month: 6,
      shortLabel: 'Jun',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
    FlowerSeedMonth(
      month: 7,
      shortLabel: 'Jul',
      status: FlowerSeedCalendarStatus.start,
      statusLabel: 'Begin oogst',
    ),
    FlowerSeedMonth(
      month: 8,
      shortLabel: 'Aug',
      status: FlowerSeedCalendarStatus.best,
      statusLabel: 'Beste periode',
    ),
    FlowerSeedMonth(
      month: 9,
      shortLabel: 'Sep',
      status: FlowerSeedCalendarStatus.best,
      statusLabel: 'Beste periode',
    ),
    FlowerSeedMonth(
      month: 10,
      shortLabel: 'Okt',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
    FlowerSeedMonth(
      month: 11,
      shortLabel: 'Nov',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
    FlowerSeedMonth(
      month: 12,
      shortLabel: 'Dec',
      status: FlowerSeedCalendarStatus.none,
      statusLabel: 'Niet oogsten',
    ),
  ],
  calendarNote:
      'Oogst bij voorkeur op een droge dag, nadat de ochtenddauw verdwenen is.',
  mistakes: [
    FlowerSeedMistake(
      title: 'Te vroeg oogsten',
      body: 'Groene dozen geven onrijpe zaden met slechte kieming.',
    ),
    FlowerSeedMistake(
      title: 'Te laat oogsten',
      body: 'Open dozen laten zaden op de grond vallen.',
    ),
    FlowerSeedMistake(
      title: 'Niet goed drogen',
      body: 'Vochtige zaden beschimmelen snel in de opslag.',
    ),
    FlowerSeedMistake(
      title: 'Verkeerd bewaren',
      body: 'Warmte en vocht maken zaden snel kiemonbekwaam.',
    ),
    FlowerSeedMistake(
      title: 'Te dik zaaien',
      body: 'Lavendelzaden mogen licht blijven; te dikke deklaag remt kieming.',
    ),
  ],
);

List<PlantGuideDetailBlock> _hd(
  Vegetable v,
  FlowerGuideProfile p,
  String title,
) =>
    flowerSectionDetailsFor(
      tab: 'harvest',
      title: title,
      vegetable: v,
      profile: p,
    );

FlowerSeedHarvestGuide _withSeedDetails(
  FlowerSeedHarvestGuide g,
  Vegetable v,
) {
  final p = flowerGuideProfileFor(v.id);
  String sum(String title) => flowerCardSummaryFor(
        tab: 'harvest',
        title: title,
        vegetable: v,
        profile: p,
      );
  return FlowerSeedHarvestGuide(
    facts: [
      for (final f in g.facts)
        FlowerSeedFact(
          label: f.label,
          value: f.value,
          description: sum(f.label),
          imageAsset: f.imageAsset,
          details: _hd(v, p, f.label),
        ),
    ],
    selfSowTitle: g.selfSowTitle,
    selfSowPeriod: g.selfSowPeriod,
    selfSowBody: sum(g.selfSowTitle),
    selfSowImage: g.selfSowImage,
    tips: g.tips,
    tipImage: g.tipImage,
    calendar: g.calendar,
    calendarNote: g.calendarNote,
    mistakes: [
      for (final m in g.mistakes)
        FlowerSeedMistake(
          title: m.title,
          body: sum(m.title),
          details: _hd(v, p, m.title),
        ),
    ],
  );
}

FlowerSeedHarvestGuide flowerSeedHarvestGuideForVegetable({
  required Vegetable vegetable,
  required PlantEncyclopediaLayout layout,
}) {
  if (vegetable.id == 'lavendel') {
    return _withSeedDetails(_lavendelSeedHarvestGuide, vegetable);
  }

  final p = flowerGuideProfileFor(vegetable.id);
  final when = p.seedHarvestAdvice.isNotEmpty
      ? (layout.harvestPeriod.trim().isEmpty
          ? 'Nazomer – herfst'
          : layout.harvestPeriod)
      : (layout.harvestPeriod.trim().isEmpty
          ? 'Nazomer – herfst'
          : layout.harvestPeriod);
  final advice = p.seedHarvestAdvice.isNotEmpty
      ? p.seedHarvestAdvice
      : 'Oogst als de zaaddozen droog en rijp zijn.';

  final harvestCalMonths = _seedHarvestMonths(p, layout);

  final guide = FlowerSeedHarvestGuide(
    facts: [
      FlowerSeedFact(
        label: 'Wanneer oogsten',
        value: when,
        description: advice,
        imageAsset: '$_asset/flower_seed_when.png',
      ),
      FlowerSeedFact(
        label: 'Zaadrijp herkennen',
        value: 'Droog & bruin',
        description: 'Dozen of zaadkapsels zijn droog en knisperen licht.',
        imageAsset: '$_asset/flower_seed_ripe.png',
      ),
      FlowerSeedFact(
        label: 'Zaden verzamelen',
        value: 'Knip of pluk',
        description: advice,
        imageAsset: '$_asset/flower_seed_collect.png',
      ),
      FlowerSeedFact(
        label: 'Drogen',
        value: '5 – 14 dagen',
        description: 'Laat zaden op een droge, luchtige plek narijpen.',
        imageAsset: '$_asset/flower_seed_dry.png',
      ),
      FlowerSeedFact(
        label: 'Zaden losmaken',
        value: 'Wrijf of klop',
        description: 'Maak zaden los boven een schaal of bakpapier.',
        imageAsset: '$_asset/flower_seed_loosen.png',
      ),
      FlowerSeedFact(
        label: 'Zaden zeven',
        value: 'Verwijder resten',
        description: 'Scheid zaden van blad en kaf.',
        imageAsset: '$_asset/flower_seed_sieve.png',
      ),
      FlowerSeedFact(
        label: 'Bewaren',
        value: 'Koel & droog',
        description: 'Bewaar in een envelop of pot op een koele plek.',
        imageAsset: '$_asset/flower_seed_store.png',
      ),
      FlowerSeedFact(
        label: 'Houdbaarheid',
        value: '1 – 3 jaar',
        description: 'Hangt af van soort; noteer het oogstjaar.',
        imageAsset: '$_asset/flower_seed_shelf.png',
      ),
    ],
    selfSowTitle: 'Zelf uitzaaien',
    selfSowPeriod: 'Voorjaar',
    selfSowBody: p.kiemduur.isNotEmpty
        ? 'Zaai volgens teeltinfo (kiemduur ${p.kiemduur}, ${p.kiemtemp}).'
        : 'Zaai in trays of bakjes volgens de zaai-instructie van de soort.',
    selfSowImage: '$_asset/flower_seed_sow.png',
    tips: [
      'Oogst van gezonde planten voor de beste zaden.',
      'Laat een deel van de bloemen staan voor insecten.',
      p.tip.isNotEmpty ? p.tip : 'Noteer soort en oogstdatum op de envelop.',
    ],
    tipImage: '$_asset/flower_seed_tip.png',
    calendar: [
      for (var m = 1; m <= 12; m++)
        FlowerSeedMonth(
          month: m,
          shortLabel: const [
            'Jan',
            'Feb',
            'Mrt',
            'Apr',
            'Mei',
            'Jun',
            'Jul',
            'Aug',
            'Sep',
            'Okt',
            'Nov',
            'Dec',
          ][m - 1],
          status: harvestCalMonths.contains(m)
              ? FlowerSeedCalendarStatus.best
              : FlowerSeedCalendarStatus.none,
          statusLabel:
              harvestCalMonths.contains(m) ? 'Oogstperiode' : 'Niet oogsten',
        ),
    ],
    calendarNote:
        'Oogst bij voorkeur op een droge dag, nadat de ochtenddauw verdwenen is.',
    mistakes: [
      FlowerSeedMistake(
        title: 'Te vroeg oogsten',
        body: 'Onrijpe zaden kiemen slecht.',
      ),
      FlowerSeedMistake(
        title: 'Te laat oogsten',
        body: 'Zaden vallen snel uit open dozijn.',
      ),
      FlowerSeedMistake(
        title: 'Niet goed drogen',
        body: 'Vocht leidt tot schimmel in de opslag.',
      ),
      FlowerSeedMistake(
        title: 'Verkeerd bewaren',
        body: 'Warmte en vocht verkorten de houdbaarheid.',
      ),
    ],
  );
  return _withSeedDetails(guide, vegetable);
}

Set<int> _seedHarvestMonths(
  FlowerGuideProfile p,
  PlantEncyclopediaLayout layout,
) {
  final harvestText = layout.harvestPeriod.toLowerCase();
  final bloomText = p.bloomPeriod.toLowerCase();
  const monthMap = {
    'jan': 1, 'feb': 2, 'mrt': 3, 'maa': 3,
    'apr': 4, 'mei': 5, 'jun': 6,
    'jul': 7, 'aug': 8, 'sep': 9,
    'okt': 10, 'nov': 11, 'dec': 12,
  };

  Set<int> parse(String text) {
    final months = <int>{};
    for (final entry in monthMap.entries) {
      if (text.contains(entry.key)) months.add(entry.value);
    }
    if (months.isEmpty) {
      if (text.contains('nazomer')) return {8, 9, 10};
      if (text.contains('herfst') || text.contains('najaar')) return {9, 10};
      if (text.contains('zomer')) return {7, 8, 9};
    }
    if (months.length == 2) {
      final sorted = months.toList()..sort();
      return {for (var m = sorted.first; m <= sorted.last; m++) m};
    }
    return months;
  }

  final fromHarvest = parse(harvestText);
  if (fromHarvest.isNotEmpty) return fromHarvest;
  final fromBloom = parse(bloomText);
  if (fromBloom.isNotEmpty) {
    return {for (final m in fromBloom) m + 1, for (final m in fromBloom) m + 2}
        .where((m) => m <= 12)
        .toSet();
  }
  return {8, 9, 10};
}
