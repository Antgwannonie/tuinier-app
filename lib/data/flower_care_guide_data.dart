import '../models/vegetable.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'plant_encyclopedia_layout.dart';
import 'plant_guide_detail.dart';

const _asset = 'assets/images/flower_care';

class FlowerCareChip {
  FlowerCareChip({required this.label, required this.imageAsset});

  final String label;
  final String imageAsset;
}

class FlowerCareSection {
  FlowerCareSection({
    required this.title,
    required this.body,
    required this.imageAsset,
    this.chips = const [],
    this.details = const [],
  });

  final String title;
  final String body;
  final String imageAsset;
  final List<FlowerCareChip> chips;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerCareMistake {
  FlowerCareMistake({
    required this.title,
    required this.body,
    this.details = const [],
  });

  final String title;
  final String body;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerCareGuide {
  FlowerCareGuide({
    required this.sections,
    required this.mistakes,
    required this.mistakesImage,
    required this.tips,
    required this.tipsImage,
    this.tipsDetails = const [],
  });

  final List<FlowerCareSection> sections;
  final List<FlowerCareMistake> mistakes;
  final String mistakesImage;
  final List<String> tips;
  final String tipsImage;
  final List<PlantGuideDetailBlock> tipsDetails;
}

final _lavendelCareGuide = FlowerCareGuide(
  sections: [
    FlowerCareSection(
      title: 'Dagelijkse verzorging',
      body:
          'Controleer op waterbehoefte, ongedierte en uitgebloeide bloemen.',
      imageAsset: '$_asset/flower_care_daily.png',
    ),
    FlowerCareSection(
      title: 'Wekelijkse verzorging',
      body:
          'Verwijder dode bloemen en bladeren. Controleer de algehele gezondheid.',
      imageAsset: '$_asset/flower_care_weekly.png',
    ),
    FlowerCareSection(
      title: 'Snoeien',
      body:
          'Snoei in het voorjaar en na de bloei om de plant compact en vitaal te houden.',
      imageAsset: '$_asset/flower_care_pruning.png',
    ),
    FlowerCareSection(
      title: 'Uitgebloeide bloemen verwijderen',
      body:
          'Verwijder uitgebloeide bloemen regelmatig voor meer nieuwe bloei en een nettere plant.',
      imageAsset: '$_asset/flower_care_deadhead.png',
    ),
    FlowerCareSection(
      title: 'Opbinden',
      body:
          'Bind hoge stelen vast om omvallen te voorkomen, vooral bij wind en regen.',
      imageAsset: '$_asset/flower_care_staking.png',
    ),
    FlowerCareSection(
      title: 'Ondersteuning',
      body:
          'Gebruik stokken, ringen of klimrekken voor extra steun bij groei en bloei.',
      imageAsset: '$_asset/flower_care_support.png',
      chips: [
        FlowerCareChip(
          label: 'Stokken',
          imageAsset: '$_asset/flower_care_chip_stakes.png',
        ),
        FlowerCareChip(
          label: 'Klimrekken',
          imageAsset: '$_asset/flower_care_chip_trellis.png',
        ),
      ],
    ),
    FlowerCareSection(
      title: 'Mulchen',
      body:
          'Breng een laag mulch aan om vocht vast te houden en onkruid te onderdrukken.',
      imageAsset: '$_asset/flower_care_mulch.png',
      chips: [
        FlowerCareChip(
          label: 'Houtsnippers',
          imageAsset: '$_asset/flower_care_chip_woodchips.png',
        ),
        FlowerCareChip(
          label: 'Grind',
          imageAsset: '$_asset/flower_care_chip_gravel.png',
        ),
      ],
    ),
    FlowerCareSection(
      title: 'Winterbescherming',
      body:
          'Bescherm wortels in strenge vorst met mulch of vliesdoek, vooral jongere planten.',
      imageAsset: '$_asset/flower_care_winter.png',
    ),
    FlowerCareSection(
      title: 'Verzorging in pot',
      body:
          'Geef regelmatig water, gebruik voeding in het groeiseizoen en verpot om de 2 – 3 jaar.',
      imageAsset: '$_asset/flower_care_pot.png',
      chips: [
        FlowerCareChip(
          label: 'Water geven',
          imageAsset: '$_asset/flower_care_chip_watering.png',
        ),
        FlowerCareChip(
          label: 'Verpotten',
          imageAsset: '$_asset/flower_care_chip_repot.png',
        ),
      ],
    ),
    FlowerCareSection(
      title: 'Verzorging tijdens bloei',
      body:
          'Geef iets extra water en voeding voor een langere en rijkere bloei.',
      imageAsset: '$_asset/flower_care_bloom.png',
      chips: [
        FlowerCareChip(
          label: 'Extra water',
          imageAsset: '$_asset/flower_care_chip_extra_water.png',
        ),
        FlowerCareChip(
          label: 'Voeding',
          imageAsset: '$_asset/flower_care_chip_feed.png',
        ),
      ],
    ),
    FlowerCareSection(
      title: 'Verzorging tijdens droogte',
      body:
          'Geef diep water in de ochtend of avond. Mulch helpt uitdroging voorkomen.',
      imageAsset: '$_asset/flower_care_drought.png',
      chips: [
        FlowerCareChip(
          label: 'Diep water',
          imageAsset: '$_asset/flower_care_chip_deep_water.png',
        ),
        FlowerCareChip(
          label: 'Mulch',
          imageAsset: '$_asset/flower_care_chip_mulch.png',
        ),
      ],
    ),
    FlowerCareSection(
      title: 'Verzorging tijdens regenachtige periodes',
      body:
          'Zorg voor goede luchtcirculatie en drainage om schimmel te voorkomen.',
      imageAsset: '$_asset/flower_care_rain.png',
      chips: [
        FlowerCareChip(
          label: 'Luchtcirculatie',
          imageAsset: '$_asset/flower_care_chip_airflow.png',
        ),
        FlowerCareChip(
          label: 'Drainage',
          imageAsset: '$_asset/flower_care_chip_drainage.png',
        ),
      ],
    ),
    FlowerCareSection(
      title: 'Verzorging na de bloei',
      body:
          'Snoei licht terug, verwijder zaadknoppen als je geen zaad wilt en bereid de plant voor op het volgende seizoen.',
      imageAsset: '$_asset/flower_care_after_bloom.png',
      chips: [
        FlowerCareChip(
          label: 'Licht snoeien',
          imageAsset: '$_asset/flower_care_chip_light_prune.png',
        ),
        FlowerCareChip(
          label: 'Zaadknoppen verwijderen',
          imageAsset: '$_asset/flower_care_chip_remove_seeds.png',
        ),
      ],
    ),
    FlowerCareSection(
      title: 'Jaarlijkse onderhoudskalender',
      body:
          'Een overzicht per seizoen van de belangrijkste verzorgingstaken.',
      imageAsset: '$_asset/flower_care_calendar.png',
      chips: [
        FlowerCareChip(
          label: 'Lente',
          imageAsset: '$_asset/flower_care_chip_spring.png',
        ),
        FlowerCareChip(
          label: 'Zomer',
          imageAsset: '$_asset/flower_care_chip_summer.png',
        ),
        FlowerCareChip(
          label: 'Herfst',
          imageAsset: '$_asset/flower_care_chip_autumn.png',
        ),
        FlowerCareChip(
          label: 'Winter',
          imageAsset: '$_asset/flower_care_chip_winter.png',
        ),
      ],
    ),
  ],
  mistakes: [
    FlowerCareMistake(
      title: 'Te veel water geven',
      body: 'Natte grond veroorzaakt wortelrot bij lavendel.',
    ),
    FlowerCareMistake(
      title: 'Te veel mest geven',
      body: 'Veel stikstof geeft blad ten koste van bloei.',
    ),
    FlowerCareMistake(
      title: 'Niet snoeien',
      body: 'Zonder snoei wordt lavendel slank en minder vitaal.',
    ),
    FlowerCareMistake(
      title: 'Slechte drainage',
      body: 'Staand water is funest voor lavendelwortels.',
    ),
    FlowerCareMistake(
      title: 'Geen winterbescherming',
      body: 'Jonge planten kunnen schade oplopen bij strenge vorst.',
    ),
  ],
  mistakesImage: '$_asset/flower_care_mistakes.png',
  tips: [
    'Lavendel houdt van zon, lucht en een arme, goed doorlatende grond.',
    'Snoei nooit in het oude hout; daar loopt de plant niet meer uit.',
  ],
  tipsImage: '$_asset/flower_care_tips.png',
);

List<PlantGuideDetailBlock> _cd(
  Vegetable v,
  FlowerGuideProfile p,
  String title,
) =>
    flowerSectionDetailsFor(
      tab: 'care',
      title: title,
      vegetable: v,
      profile: p,
    );

FlowerCareGuide _withCareDetails(FlowerCareGuide g, Vegetable v) {
  final p = flowerGuideProfileFor(v.id);
  return FlowerCareGuide(
    sections: [
      for (final s in g.sections)
        FlowerCareSection(
          title: s.title,
          body: flowerCardSummaryFor(
            tab: 'care',
            title: s.title,
            vegetable: v,
            profile: p,
          ),
          imageAsset: s.imageAsset,
          chips: s.chips,
          details: _cd(v, p, s.title),
        ),
    ],
    mistakes: [
      for (final m in g.mistakes)
        FlowerCareMistake(
          title: m.title,
          body: flowerCardSummaryFor(
            tab: 'care',
            title: m.title,
            vegetable: v,
            profile: p,
          ),
          details: _cd(v, p, m.title),
        ),
    ],
    mistakesImage: g.mistakesImage,
    tips: g.tips,
    tipsImage: g.tipsImage,
    tipsDetails: _cd(v, p, 'Verzorgingstips'),
  );
}

FlowerCareGuide flowerCareGuideForVegetable({
  required Vegetable vegetable,
  required PlantEncyclopediaLayout layout,
}) {
  if (vegetable.id == 'lavendel') {
    return _withCareDetails(_lavendelCareGuide, vegetable);
  }

  final p = flowerGuideProfileFor(vegetable.id);
  final isAnnual = !p.winterHardy && p.key != FlowerProfileKey.mediterranean;
  final isMediterranean = p.key == FlowerProfileKey.mediterranean;
  final winterBody = isAnnual
      ? 'Eenjarig; niet overwinteren. Opruimen na eerste vorst.'
      : (isMediterranean
          ? 'Bescherm tegen natte NL-winters — drainage is crucialer dan vorstbescherming.'
          : (p.winterAdvice.isNotEmpty
              ? p.winterAdvice
              : 'Bescherm kwetsbare planten bij strenge vorst.'));
  final supportBody = p.supportAdvice.isNotEmpty
      ? p.supportAdvice
      : 'Steun hoge of slappe stelen bij wind.';

  final guide = FlowerCareGuide(
    sections: [
      FlowerCareSection(
        title: 'Dagelijkse verzorging',
        body:
            'Controleer water (${p.waterNeed}), blad en bloemen op problemen.',
        imageAsset: '$_asset/flower_care_daily.png',
      ),
      FlowerCareSection(
        title: 'Wekelijkse verzorging',
        body: 'Verwijder dode delen en controleer de gezondheid.',
        imageAsset: '$_asset/flower_care_weekly.png',
      ),
      FlowerCareSection(
        title: 'Snoeien',
        body: p.pruneAdvice.isNotEmpty
            ? p.pruneAdvice
            : 'Snoei na de bloei en in het voorjaar indien nodig.',
        imageAsset: '$_asset/flower_care_pruning.png',
      ),
      FlowerCareSection(
        title: 'Uitgebloeide bloemen verwijderen',
        body: p.deadheadAdvice.isNotEmpty
            ? p.deadheadAdvice
            : 'Deadheading houdt de plant netjes en kan bloei verlengen.',
        imageAsset: '$_asset/flower_care_deadhead.png',
      ),
      FlowerCareSection(
        title: 'Opbinden',
        body: supportBody,
        imageAsset: '$_asset/flower_care_staking.png',
      ),
      FlowerCareSection(
        title: 'Ondersteuning',
        body: supportBody,
        imageAsset: '$_asset/flower_care_support.png',
        chips: [
          FlowerCareChip(
            label: 'Stokken',
            imageAsset: '$_asset/flower_care_chip_stakes.png',
          ),
          FlowerCareChip(
            label: 'Klimrekken',
            imageAsset: '$_asset/flower_care_chip_trellis.png',
          ),
        ],
      ),
      FlowerCareSection(
        title: 'Mulchen',
        body: p.mulchAdvice.isNotEmpty
            ? p.mulchAdvice
            : (isMediterranean
                ? 'Grind of schelpen houden wortelzone droog; vermijd natte mulch.'
                : 'Mulch houdt vocht vast en onderdrukt onkruid.'),
        imageAsset: '$_asset/flower_care_mulch.png',
        chips: [
          FlowerCareChip(
            label: isMediterranean ? 'Grind' : 'Houtsnippers',
            imageAsset: isMediterranean
                ? '$_asset/flower_care_chip_gravel.png'
                : '$_asset/flower_care_chip_woodchips.png',
          ),
          FlowerCareChip(
            label: isMediterranean ? 'Schelpen' : 'Grind',
            imageAsset: '$_asset/flower_care_chip_gravel.png',
          ),
        ],
      ),
      FlowerCareSection(
        title: 'Winterbescherming',
        body: winterBody,
        imageAsset: '$_asset/flower_care_winter.png',
      ),
      FlowerCareSection(
        title: 'Verzorging in pot',
        body: p.potAdvice.isNotEmpty
            ? p.potAdvice
            : 'Regelmatig water en af en toe verpotten.',
        imageAsset: '$_asset/flower_care_pot.png',
        chips: [
          FlowerCareChip(
            label: 'Water geven',
            imageAsset: '$_asset/flower_care_chip_watering.png',
          ),
          FlowerCareChip(
            label: 'Verpotten',
            imageAsset: '$_asset/flower_care_chip_repot.png',
          ),
        ],
      ),
      FlowerCareSection(
        title: 'Verzorging tijdens bloei',
        body: 'Extra aandacht voor water (${p.waterNeed}) en voeding tijdens bloei.',
        imageAsset: '$_asset/flower_care_bloom.png',
        chips: [
          FlowerCareChip(
            label: 'Extra water',
            imageAsset: '$_asset/flower_care_chip_extra_water.png',
          ),
          FlowerCareChip(
            label: 'Voeding',
            imageAsset: '$_asset/flower_care_chip_feed.png',
          ),
        ],
      ),
      FlowerCareSection(
        title: 'Verzorging tijdens droogte',
        body: p.droughtResistant
            ? 'Droogtetolerant; geef diep water bij aanhoudende droogte.'
            : 'Diep water geven en mulch aanbrengen.',
        imageAsset: '$_asset/flower_care_drought.png',
        chips: [
          FlowerCareChip(
            label: 'Diep water',
            imageAsset: '$_asset/flower_care_chip_deep_water.png',
          ),
          FlowerCareChip(
            label: 'Mulch',
            imageAsset: '$_asset/flower_care_chip_mulch.png',
          ),
        ],
      ),
      FlowerCareSection(
        title: 'Verzorging tijdens regenachtige periodes',
        body: isMediterranean
            ? 'Natte NL-winters zijn dodelijker dan vorst; zorg voor perfecte drainage.'
            : 'Zorg voor lucht en drainage om schimmel te voorkomen.',
        imageAsset: '$_asset/flower_care_rain.png',
        chips: [
          FlowerCareChip(
            label: 'Luchtcirculatie',
            imageAsset: '$_asset/flower_care_chip_airflow.png',
          ),
          FlowerCareChip(
            label: 'Drainage',
            imageAsset: '$_asset/flower_care_chip_drainage.png',
          ),
        ],
      ),
      FlowerCareSection(
        title: 'Verzorging na de bloei',
        body: p.pruneAdvice.isNotEmpty
            ? p.pruneAdvice
            : (isAnnual
                ? 'Laat zaad rijpen voor volgend jaar of ruim de plant op.'
                : 'Licht terugsnoeien en zaadknoppen verwijderen indien gewenst.'),
        imageAsset: '$_asset/flower_care_after_bloom.png',
        chips: [
          FlowerCareChip(
            label: 'Licht snoeien',
            imageAsset: '$_asset/flower_care_chip_light_prune.png',
          ),
          FlowerCareChip(
            label: 'Zaadknoppen verwijderen',
            imageAsset: '$_asset/flower_care_chip_remove_seeds.png',
          ),
        ],
      ),
      FlowerCareSection(
        title: 'Jaarlijkse onderhoudskalender',
        body: 'Belangrijkste taken per seizoen voor ${vegetable.nameNl}.',
        imageAsset: '$_asset/flower_care_calendar.png',
        chips: [
          FlowerCareChip(
            label: 'Lente',
            imageAsset: '$_asset/flower_care_chip_spring.png',
          ),
          FlowerCareChip(
            label: 'Zomer',
            imageAsset: '$_asset/flower_care_chip_summer.png',
          ),
          FlowerCareChip(
            label: 'Herfst',
            imageAsset: '$_asset/flower_care_chip_autumn.png',
          ),
          FlowerCareChip(
            label: 'Winter',
            imageAsset: '$_asset/flower_care_chip_winter.png',
          ),
        ],
      ),
    ],
    mistakes: [
      for (final m in (p.mistakes.isNotEmpty
          ? p.mistakes.take(5)
          : const [
              'Te veel water geven — natte grond remt groei.',
              'Te veel mest geven — veel blad, minder bloemen.',
              'Niet snoeien — plant wordt slank en minder vitaal.',
              'Slechte drainage — staand water is schadelijk.',
            ]))
        FlowerCareMistake(
          title: m.contains('—') ? m.split('—').first.trim() : m,
          body: m.contains('—') ? m.split('—').skip(1).join('—').trim() : m,
        ),
    ],
    mistakesImage: '$_asset/flower_care_mistakes.png',
    tips: [
      p.tip.isNotEmpty ? p.tip : 'Kies een standplaats die past bij de soort.',
      p.pruneAdvice.isNotEmpty
          ? p.pruneAdvice
          : 'Snoei op tijd en verwijder uitgebloeide bloemen.',
    ],
    tipsImage: '$_asset/flower_care_tips.png',
  );
  return _withCareDetails(guide, vegetable);
}
