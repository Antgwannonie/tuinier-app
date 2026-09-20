import '../models/vegetable.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'plant_bloom_guide.dart';
import 'plant_encyclopedia_layout.dart';
import 'plant_guide_detail.dart';

const _asset = 'assets/images/flower_bloom';

enum FlowerBloomCalendarStatus {
  none,
  buds,
  full,
  after,
}

class FlowerBloomFact {
  FlowerBloomFact({
    required this.label,
    required this.value,
    required this.description,
    required this.imageAsset,
    this.scentDots,
    this.details = const [],
  });

  final String label;
  final String value;
  final String description;
  final String imageAsset;

  /// 1–5; alleen gezet bij geursterkte.
  final int? scentDots;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerBloomMonth {
  FlowerBloomMonth({
    required this.month,
    required this.shortLabel,
    required this.status,
    required this.statusLabel,
  });

  final int month;
  final String shortLabel;
  final FlowerBloomCalendarStatus status;
  final String statusLabel;
}

class FlowerBloomExtraTip {
  FlowerBloomExtraTip({
    required this.title,
    required this.body,
    required this.imageAsset,
    this.details = const [],
  });

  final String title;
  final String body;
  final String imageAsset;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerBloomMistake {
  FlowerBloomMistake({
    required this.title,
    required this.body,
    this.details = const [],
  });

  final String title;
  final String body;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerBloomGuide {
  FlowerBloomGuide({
    required this.facts,
    required this.didYouKnow,
    required this.didYouKnowImage,
    required this.calendar,
    required this.extraTips,
    required this.mistakes,
  });

  final List<FlowerBloomFact> facts;
  final String didYouKnow;
  final String didYouKnowImage;
  final List<FlowerBloomMonth> calendar;
  final List<FlowerBloomExtraTip> extraTips;
  final List<FlowerBloomMistake> mistakes;
}

String flowerBloomCalendarImage(FlowerBloomCalendarStatus status) {
  return switch (status) {
    FlowerBloomCalendarStatus.none => '$_asset/flower_bloom_cal_none.png',
    FlowerBloomCalendarStatus.buds ||
    FlowerBloomCalendarStatus.full ||
    FlowerBloomCalendarStatus.after =>
      '$_asset/flower_bloom_cal_bloom.png',
  };
}

final _lavendelBloomGuide = FlowerBloomGuide(
  facts: [
    FlowerBloomFact(
      label: 'Bloeiperiode',
      value: 'Juni – augustus',
      description: 'Hoofdbloei in de zomermaanden.',
      imageAsset: '$_asset/flower_bloom_period.png',
    ),
    FlowerBloomFact(
      label: 'Bloeiduur',
      value: '8 – 10 weken',
      description: 'Lange bloeiperiode bij goede standplaats.',
      imageAsset: '$_asset/flower_bloom_duration.png',
    ),
    FlowerBloomFact(
      label: 'Bloemkleur',
      value: 'Paars / lavendelblauw',
      description: 'Klassieke lavendelkleur aan de aren.',
      imageAsset: '$_asset/flower_bloom_color.png',
    ),
    FlowerBloomFact(
      label: 'Bloemvorm',
      value: 'Aren / spikes',
      description: 'Rechtopstaande bloemaren met kleine bloempjes.',
      imageAsset: '$_asset/flower_bloom_shape.png',
    ),
    FlowerBloomFact(
      label: 'Geur',
      value: 'Zoet, kruidig, kalmerend',
      description: 'Sterke, herkenbare lavendelgeur.',
      imageAsset: '$_asset/flower_bloom_scent.png',
    ),
    FlowerBloomFact(
      label: 'Geursterkte',
      value: 'Sterk',
      description: 'Duidelijk aanwezig, vooral op warme dagen.',
      imageAsset: '$_asset/flower_bloom_scent_strength.png',
      scentDots: 3,
    ),
    FlowerBloomFact(
      label: 'Herbloei',
      value: 'Ja, na uitbloeien',
      description: 'Mogelijk na knippen van uitgebloeide aren.',
      imageAsset: '$_asset/flower_bloom_rebloom.png',
    ),
    FlowerBloomFact(
      label: 'Uitgebloeide bloemen verwijderen',
      value: 'Ja, aanbevolen',
      description: 'Stimuleert nieuwe bloei en houdt de struik netjes.',
      imageAsset: '$_asset/flower_bloom_deadhead.png',
    ),
    FlowerBloomFact(
      label: 'Bloei stimuleren',
      value: 'Zon + snoeien',
      description: 'Volle zon en lichte snoei geven de rijkste bloei.',
      imageAsset: '$_asset/flower_bloom_stimulate.png',
    ),
    FlowerBloomFact(
      label: 'Zelfbestuiver',
      value: 'Nee',
      description:
          'Lavendel wordt vooral door bijen en andere insecten bestoven.',
      imageAsset: '$_asset/flower_bloom_pollinators.png',
    ),
    FlowerBloomFact(
      label: 'Bestuivers',
      value: 'Bijen, hommels, vlinders',
      description: 'Zeer aantrekkelijk voor insecten.',
      imageAsset: '$_asset/flower_bloom_pollinators.png',
    ),
  ],
  didYouKnow:
      'Wist je dat? Lavendelbloemen zijn een feestmaal voor bijen en vlinders. '
      'Eén struik kan in volle bloei tientallen bestuivers aantrekken.',
  didYouKnowImage: '$_asset/flower_bloom_tip.png',
  calendar: [
    FlowerBloomMonth(
      month: 1,
      shortLabel: 'Jan',
      status: FlowerBloomCalendarStatus.none,
      statusLabel: 'Geen bloei',
    ),
    FlowerBloomMonth(
      month: 2,
      shortLabel: 'Feb',
      status: FlowerBloomCalendarStatus.none,
      statusLabel: 'Geen bloei',
    ),
    FlowerBloomMonth(
      month: 3,
      shortLabel: 'Mrt',
      status: FlowerBloomCalendarStatus.none,
      statusLabel: 'Geen bloei',
    ),
    FlowerBloomMonth(
      month: 4,
      shortLabel: 'Apr',
      status: FlowerBloomCalendarStatus.none,
      statusLabel: 'Geen bloei',
    ),
    FlowerBloomMonth(
      month: 5,
      shortLabel: 'Mei',
      status: FlowerBloomCalendarStatus.none,
      statusLabel: 'Geen bloei',
    ),
    FlowerBloomMonth(
      month: 6,
      shortLabel: 'Jun',
      status: FlowerBloomCalendarStatus.buds,
      statusLabel: 'Eerste knoppen',
    ),
    FlowerBloomMonth(
      month: 7,
      shortLabel: 'Jul',
      status: FlowerBloomCalendarStatus.full,
      statusLabel: 'Volle bloei',
    ),
    FlowerBloomMonth(
      month: 8,
      shortLabel: 'Aug',
      status: FlowerBloomCalendarStatus.full,
      statusLabel: 'Volle bloei',
    ),
    FlowerBloomMonth(
      month: 9,
      shortLabel: 'Sep',
      status: FlowerBloomCalendarStatus.after,
      statusLabel: 'Nabloei mogelijk',
    ),
    FlowerBloomMonth(
      month: 10,
      shortLabel: 'Okt',
      status: FlowerBloomCalendarStatus.none,
      statusLabel: 'Geen bloei',
    ),
    FlowerBloomMonth(
      month: 11,
      shortLabel: 'Nov',
      status: FlowerBloomCalendarStatus.none,
      statusLabel: 'Geen bloei',
    ),
    FlowerBloomMonth(
      month: 12,
      shortLabel: 'Dec',
      status: FlowerBloomCalendarStatus.none,
      statusLabel: 'Geen bloei',
    ),
  ],
  extraTips: [
    FlowerBloomExtraTip(
      title: 'Volle zon',
      body: 'Zet lavendel op de zonnigste plek voor volle aren.',
      imageAsset: '$_asset/flower_bloom_extra_sun.png',
    ),
    FlowerBloomExtraTip(
      title: 'Matig water',
      body: 'Te natte grond remt bloei; laat de grond eerst opdrogen.',
      imageAsset: '$_asset/flower_bloom_extra_water.png',
    ),
    FlowerBloomExtraTip(
      title: 'Aren knippen',
      body: 'Verwijder uitgebloeide aren voor een tweede bloei.',
      imageAsset: '$_asset/flower_bloom_extra_prune.png',
    ),
    FlowerBloomExtraTip(
      title: 'Weinig stikstof',
      body: 'Te veel mest geeft blad ten koste van bloemen.',
      imageAsset: '$_asset/flower_bloom_extra_feed.png',
    ),
  ],
  mistakes: [
    FlowerBloomMistake(
      title: 'Te veel water',
      body: 'Natte grond remt bloei en veroorzaakt wortelrot.',
    ),
    FlowerBloomMistake(
      title: 'Te weinig zon',
      body: 'In schaduw blijft de bloei mager en de geur zwakker.',
    ),
    FlowerBloomMistake(
      title: 'Te diep snoeien',
      body: 'Snoei niet in oud hout; daarna komen weinig nieuwe knoppen.',
    ),
    FlowerBloomMistake(
      title: 'Te veel mest',
      body: 'Veel stikstof geeft bladgroei in plaats van bloemen.',
    ),
    FlowerBloomMistake(
      title: 'Uitgebloeide aren laten zitten',
      body: 'Zonder knippen blijft herbloei vaak uit.',
    ),
  ],
);

List<PlantGuideDetailBlock> _bd(
  Vegetable v,
  FlowerGuideProfile p,
  String title,
) =>
    flowerSectionDetailsFor(
      tab: 'bloom',
      title: title,
      vegetable: v,
      profile: p,
    );

FlowerBloomGuide _withBloomDetails(FlowerBloomGuide g, Vegetable v) {
  final p = flowerGuideProfileFor(v.id);
  return FlowerBloomGuide(
    facts: [
      for (final f in g.facts)
        FlowerBloomFact(
          label: f.label,
          value: f.value,
          description: flowerCardSummaryFor(
            tab: 'bloom',
            title: f.label,
            vegetable: v,
            profile: p,
          ),
          imageAsset: f.imageAsset,
          scentDots: f.scentDots,
          details: _bd(v, p, f.label),
        ),
    ],
    didYouKnow: g.didYouKnow,
    didYouKnowImage: g.didYouKnowImage,
    calendar: g.calendar,
    extraTips: [
      for (final t in g.extraTips)
        FlowerBloomExtraTip(
          title: t.title,
          body: flowerCardSummaryFor(
            tab: 'bloom',
            title: t.title,
            vegetable: v,
            profile: p,
          ),
          imageAsset: t.imageAsset,
          details: _bd(v, p, t.title),
        ),
    ],
    mistakes: [
      for (final m in g.mistakes)
        FlowerBloomMistake(
          title: m.title,
          body: flowerCardSummaryFor(
            tab: 'bloom',
            title: m.title,
            vegetable: v,
            profile: p,
          ),
          details: _bd(v, p, m.title),
        ),
    ],
  );
}

FlowerBloomGuide flowerBloomGuideForVegetable({
  required Vegetable vegetable,
  required PlantEncyclopediaLayout layout,
}) {
  if (vegetable.id == 'lavendel') {
    return _withBloomDetails(_lavendelBloomGuide, vegetable);
  }

  final p = flowerGuideProfileFor(vegetable.id);
  final bloomPeriod = p.bloomPeriod.isNotEmpty
      ? p.bloomPeriod
      : (layout.bloomPeriod.trim().isEmpty ? 'Zomer' : layout.bloomPeriod);
  final flowerColor =
      layout.flowerColor.trim().isEmpty ? 'Zie soort' : layout.flowerColor;
  final beeFriendly =
      layout.beeFriendly.trim().isEmpty ? 'Ja' : layout.beeFriendly;
  final selfPollinator =
      pollinationKindForVegetable(vegetable) == PollinationKind.self;
  final flowerSex = flowerSexKindForVegetable(vegetable);
  final sexFact = switch (flowerSex) {
    FlowerSexKind.monoecious => (
        value: 'Apart mannelijk & vrouwelijk',
        description:
            'Deze plant heeft aparte mannelijke (stuifmeel) en vrouwelijke '
            '(vruchtbeginsel) bloemen op dezelfde plant.',
      ),
    FlowerSexKind.dioecious => (
        value: 'Apart mannelijke & vrouwelijke plant',
        description:
            'Mannelijke en vrouwelijke bloemen zitten op verschillende planten.',
      ),
    FlowerSexKind.perfect => (
        value: 'Beide delen in één bloem',
        description:
            'Elke bloem heeft mannelijke meeldraden én een vrouwelijke stamper.',
      ),
  };
  final scentDots = p.scentDots.clamp(1, 5);
  final scentLabel = scentDots >= 4
      ? 'Sterk'
      : (scentDots >= 2 ? 'Mild tot sterk' : 'Mild');

  final bloomMonths = _bloomMonthsFromProfile(p, layout);

  final guide = FlowerBloomGuide(
    facts: [
      FlowerBloomFact(
        label: 'Bloeiperiode',
        value: bloomPeriod,
        description: 'In NL meestal $bloomPeriod — later bij koud voorjaar.',
        imageAsset: '$_asset/flower_bloom_period.png',
      ),
      FlowerBloomFact(
        label: 'Bloeiduur',
        value: p.bloomDuration.isNotEmpty ? p.bloomDuration : 'Enkele weken',
        description: p.deadheadAdvice.isNotEmpty
            ? 'Verleng met: ${p.deadheadAdvice}'
            : 'Hangt af van weer, standplaats en knippen.',
        imageAsset: '$_asset/flower_bloom_duration.png',
      ),
      FlowerBloomFact(
        label: 'Bloemkleur',
        value: flowerColor,
        description: 'Dominante kleur; rassen kunnen afwijken.',
        imageAsset: '$_asset/flower_bloom_color.png',
      ),
      FlowerBloomFact(
        label: 'Bloemvorm',
        value: p.flowerForm.isNotEmpty ? p.flowerForm : 'Zie soort',
        description: p.flowerForm.isNotEmpty
            ? p.flowerForm
            : 'Vorm van bloemen of bloemtrossen.',
        imageAsset: '$_asset/flower_bloom_shape.png',
      ),
      FlowerBloomFact(
        label: 'Geur',
        value: p.fragrance.isNotEmpty ? p.fragrance : 'Soortafhankelijk',
        description: p.fragrance.isNotEmpty
            ? p.fragrance
            : 'Geur sterker op warme, droge dagen.',
        imageAsset: '$_asset/flower_bloom_scent.png',
      ),
      FlowerBloomFact(
        label: 'Geursterkte',
        value: scentLabel,
        description: 'Sterker bij warmte en volle zon (${p.sunNeed}).',
        imageAsset: '$_asset/flower_bloom_scent_strength.png',
        scentDots: scentDots,
      ),
      FlowerBloomFact(
        label: 'Herbloei',
        value: p.rebloomAdvice.isNotEmpty
            ? (p.rebloomAdvice.length <= 28
                ? p.rebloomAdvice
                : 'Na knippen')
            : 'Na knippen',
        description: p.rebloomAdvice.isNotEmpty
            ? p.rebloomAdvice
            : 'Vaak na knippen van uitgebloeide bloemen.',
        imageAsset: '$_asset/flower_bloom_rebloom.png',
      ),
      FlowerBloomFact(
        label: 'Uitgebloeide bloemen verwijderen',
        value: p.deadheadAdvice.toLowerCase().contains('niet')
            ? 'Liever niet'
            : 'Ja · regelmatig',
        description: p.deadheadAdvice.isNotEmpty
            ? p.deadheadAdvice
            : 'Houdt de plant netjes en kan bloei verlengen.',
        imageAsset: '$_asset/flower_bloom_deadhead.png',
      ),
      FlowerBloomFact(
        label: 'Bloei stimuleren',
        value: '${p.sunNeed} · passend water',
        description:
            'Prioriteit: ${p.sunNeed}, water (${p.waterNeed}), knippen en lichte voeding.',
        imageAsset: '$_asset/flower_bloom_stimulate.png',
      ),
      FlowerBloomFact(
        label: 'Zelfbestuiver',
        value: selfPollinator ? 'Ja' : 'Nee',
        description: selfPollinator
            ? 'Deze plant bestuift zichzelf; insecten kunnen nog helpen.'
            : 'Geen zelfbestuiver; insecten of kruisbestuiving zijn belangrijk.',
        imageAsset: '$_asset/flower_bloom_pollinators.png',
      ),
      FlowerBloomFact(
        label: 'Mannelijke & vrouwelijke bloemen',
        value: sexFact.value,
        description: sexFact.description,
        imageAsset: '$_asset/flower_bloom_pollinators.png',
      ),
      FlowerBloomFact(
        label: 'Bestuivers',
        value: beeFriendly,
        description: p.benefits.isNotEmpty
            ? p.benefits.take(2).join(' · ')
            : 'Waarde voor bijen, hommels en andere insecten.',
        imageAsset: '$_asset/flower_bloom_pollinators.png',
      ),
    ],
    didYouKnow: p.specialFact.isNotEmpty
        ? 'Wist je dat? ${p.specialFact}'
        : 'Wist je dat? Uitgebloeide bloemen op tijd knippen geeft bij veel '
            'soorten een langere of tweede bloei.',
    didYouKnowImage: '$_asset/flower_bloom_tip.png',
    calendar: [
      for (var m = 1; m <= 12; m++)
        FlowerBloomMonth(
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
          status: bloomMonths.contains(m)
              ? FlowerBloomCalendarStatus.full
              : FlowerBloomCalendarStatus.none,
          statusLabel: bloomMonths.contains(m) ? 'Bloei' : 'Geen bloei',
        ),
    ],
    extraTips: [
      FlowerBloomExtraTip(
        title: 'Standplaats',
        body: 'Zet op ${p.sunNeed.toLowerCase()} voor rijkere bloei.',
        imageAsset: '$_asset/flower_bloom_extra_sun.png',
      ),
      FlowerBloomExtraTip(
        title: 'Water',
        body: p.waterHow.isNotEmpty
            ? p.waterHow
            : 'Houd de grond gelijkmatig vochtig tijdens knopvorming.',
        imageAsset: '$_asset/flower_bloom_extra_water.png',
      ),
      FlowerBloomExtraTip(
        title: 'Uitgebloeid knippen',
        body: p.deadheadAdvice.isNotEmpty
            ? p.deadheadAdvice
            : 'Verwijder oude bloemen voor een nettere plant.',
        imageAsset: '$_asset/flower_bloom_extra_prune.png',
      ),
      FlowerBloomExtraTip(
        title: 'Passende voeding',
        body: p.fertiliserAdvice.isNotEmpty
            ? p.fertiliserAdvice
            : 'Te veel stikstof remt vaak de bloei.',
        imageAsset: '$_asset/flower_bloom_extra_feed.png',
      ),
    ],
    mistakes: [
      for (final m in (p.mistakes.isNotEmpty
          ? p.mistakes.take(4)
          : const [
              'Te weinig licht — zonder genoeg zon blijft bloei vaak mager.',
              'Te veel mest — veel blad ten koste van bloemen.',
              'Uitgebloeide bloemen laten zitten — herbloei blijft dan vaak uit.',
              'Verkeerde watergift — te nat of te droog remt knopvorming.',
            ]))
        FlowerBloomMistake(
          title: m.contains('—') ? m.split('—').first.trim() : m,
          body: m.contains('—') ? m.split('—').skip(1).join('—').trim() : m,
        ),
    ],
  );
  return _withBloomDetails(guide, vegetable);
}

Set<int> _bloomMonthsFromProfile(
  FlowerGuideProfile p,
  PlantEncyclopediaLayout layout,
) {
  final text = (p.bloomPeriod.isNotEmpty ? p.bloomPeriod : layout.bloomPeriod)
      .toLowerCase();
  const monthMap = {
    'jan': 1,
    'feb': 2,
    'mrt': 3, 'maa': 3,
    'apr': 4,
    'mei': 5,
    'jun': 6,
    'jul': 7,
    'aug': 8,
    'sep': 9,
    'okt': 10,
    'nov': 11,
    'dec': 12,
  };
  final months = <int>{};
  for (final entry in monthMap.entries) {
    if (text.contains(entry.key)) months.add(entry.value);
  }
  if (months.isEmpty) {
    if (text.contains('zomer')) return {6, 7, 8};
    if (text.contains('lente') || text.contains('voorjaar')) return {4, 5, 6};
    if (text.contains('herfst') || text.contains('najaar')) return {9, 10};
    return {6, 7, 8};
  }
  if (months.length == 2) {
    final sorted = months.toList()..sort();
    final result = <int>{};
    for (var m = sorted.first; m <= sorted.last; m++) {
      result.add(m);
    }
    return result;
  }
  return months;
}
