part of 'flower_overview_data.dart';

const Map<String, _FlowerFacts> _kFlowerFacts = {
  'zonnebloem': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag; beschut tegen wind',
    water: 'Gemiddeld',
    waterSubtitle: 'Regelmatig water in droge periodes',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Imposante eenjarige zomerbloem die bijen en hommels massaal aantrekt. '
        'Ideaal als windscherm en sier aan de zonnige rand van de moestuin, met eetbare zaden in het najaar.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en hommels voor betere bestuiving',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit langs het bed',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook voedselbron voor vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbare zaden en mooi in pluktuin',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 5,
      butterflies: 3,
      bumblebees: 5,
      hoverflies: 2,
    ),
    height: '150–250 cm',
    width: '40–60 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {3, 4},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (buiten)',
          months: {4, 5, 6},
        ),
        accentColor: Color(0xFF66BB6A),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFFC107),
      Color(0xFFFF9800),
      Color(0xFF8D6E63),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, geef water bij langdurige droogte',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Zeer aantrekkelijk voor bijen en hommels',
      'Kan dienen als windscherm',
      'Eetbare zaden in het najaar',
      'Makkelijk direct buiten te zaaien',
      'Hoge en opvallende zomerbloem',
    ],
    tip:
        'Plant aan de zonnige rand van het bed; geef hoge rassen een stevige stok en bescherm tegen harde wind.',
  ),
  'afrikaantje': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Klassieke moestuinbegeleider met sterke geur; wortels kunnen '
        'wortelknobbelaaltjes remmen (sterkst bij dichte voorteelt). '
        'Plant tussen rijen of per hoek bij tomaat, paprika en kool voor een lang bloeiend effect.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Kan wortelknobbelaaltjes remmen (dichte voorteelt)',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_soil_improvers.png',
        label: 'Nuttig tussen tomaat, paprika en kool',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verrijkt combinatieteelt in de moestuin',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 3,
      bumblebees: 2,
      hoverflies: 2,
    ),
    height: '30–80 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {3, 4, 5},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFF9800),
      Color(0xFFE53935),
      Color(0xFFFFC107),
    ],
    fragrance: 'Sterk geurend',
    winterHardy: false,
    winterHardyDetail: 'Nee, vorstgevoelig; eenjarig',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableMoestuinRand,
    keyFeatures: [
      'Kan wortelknobbelaaltjes remmen (dichte voorteelt)',
      'Sterk geurende moestuinbegeleider',
      'Lang bloeiend tot de vorst',
      'Geschikt tussen smalle paden',
      'Makkelijk voor te zaaien',
    ],
    tip:
        'Plant na de IJsheiligen; lage en hoge varianten tussen tomaten en kool. Lage tagetes past goed in smalle paden.',
  ),
  'goudsbloem': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Eetbare eenjarige bloem die lieveheersbeestjes tegen bladluis aantrekt. '
        'Bloeit lang door en verrijkt borders en moestuinranden met warme oranje en gele kleuren.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Trekt lieveheersbeestjes tegen bladluis',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Bloembladeren zijn eetbaar',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit in de tuin',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 4,
      bumblebees: 3,
      hoverflies: 4,
    ),
    height: '30–50 cm',
    width: '25–35 cm',
    bloomPeriod: 'Mei–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5, 6},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {5, 6, 7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFF9800),
      Color(0xFFFFC107),
      Color(0xFFE53935),
    ],
    fragrance: 'Kruidig-harsachtig',
    winterHardy: false,
    winterHardyDetail: 'Nee als meerjarig; verdraagt lichte vorst; zaai vanaf maart',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Eetbare bloembladeren',
      'Lang doorbloeiend',
      'Trekt lieveheersbeestjes',
      'Makkelijk door te zaaien',
      'Warme kleuren tot de vorst',
    ],
    tip:
        'Knip uitgebloeide bloemen weg voor doorbloei tot de eerste vorst.',
  ),
  'oostindische_kers': _FlowerFacts(
    standplaats: 'Volle zon tot lichte halfschaduw',
    standplaatsSubtitle: '6+ uur per dag; verdraagt lichte halfschaduw',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Eetbare vangplant die bladluis wegtrekt van kool en komkommer. '
        'Plant iets verder van hoofdteelt; bloeit rijk en houdt onkruid tegen op kale plekken.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Trek bladluis weg van kool en komkommer',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbare bloemen en blad',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Dekkend tapijt op lege plekken',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 3,
      bumblebees: 2,
      hoverflies: 2,
    ),
    height: '20–30 cm',
    width: '30–50 cm',
    bloomPeriod: 'Juni–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {5, 6},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFF9800),
      Color(0xFFE53935),
      Color(0xFFFFC107),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig en vorstgevoelig; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableMoestuinRand,
    keyFeatures: [
      'Eetbare bloemen en blad',
      'Vangplant voor bladluis',
      'Dekkend laag tapijt',
      'Lang bloeiend in de zomer',
      'Makkelijk direct te zaaien',
    ],
    tip:
        'Zaai na de IJsheiligen; niet te dicht op jonge koolplanten. Gebruik als lokmiddel iets verder van de hoofdteelt.',
  ),
  'komkommerkruid': _FlowerFacts(
    standplaats: 'Volle zon tot halfschaduw',
    standplaatsSubtitle: '6+ uur per dag; verdraagt halfschaduw',
    water: 'Gemiddeld tot veel',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Sterke bijenplant en klassieke buur van tomaten en courgette. '
        'Verbeterde vruchtzetting door betere bestuiving; ook sierlijk met blauwe sterbloemen.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Sterke bijenplant voor betere bestuiving',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit in de moestuin',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook aantrekkelijk voor vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar blad en bloemen',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 5,
      butterflies: 3,
      bumblebees: 3,
      hoverflies: 3,
    ),
    height: '60–100 cm',
    width: '30–50 cm',
    bloomPeriod: 'Mei–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {4, 5},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {5, 6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF42A5F5),
      Color(0xFF7B1FA2),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Zeer aantrekkelijk voor bijen',
      'Klassieke buur van tomaat',
      'Eetbaar blad en bloemen',
      'Helpt vruchtzetting',
      'Lang bloeiend',
    ],
    tip:
        'Zaai naast tomaten, courgette of komkommer; laat een deel doorbloeien voor bijen.',
  ),
  'facelia': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Top bijenplant en snelle groenbemester voor lege plekken na vroege oogst. '
        'Verbeterd bodemstructuur als je na bloei uitspit; paarse bloemen trekken massaal bestuivers.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Enorme bijenaantrek op paarse bloemen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_soil_improvers.png',
        label: 'Verbetert bodem als groenbemester',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Trekt ook vlinders en zweefvliegen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Vult lege plekken snel op',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 5,
      butterflies: 3,
      bumblebees: 4,
      hoverflies: 5,
    ),
    height: '40–70 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–augustus',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5, 6, 7, 8},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF7B1FA2),
      Color(0xFF42A5F5),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, sterft bij vorst; elk voorjaar opnieuw zaaien',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableGreenManure,
    keyFeatures: [
      'Zeer aantrekkelijk voor bijen',
      'Snelle groenbemester',
      'Ideaal na vroege oogst',
      'Trekt zweefvliegen',
      'Verbeterd bodemstructuur',
    ],
    tip:
        'Zaai in blokken op lege plek na radijs of sla; bijen komen massaal op de paarse bloemen.',
  ),
  'korenbloem': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig tot gemiddeld',
    waterSubtitle: 'Verdraagt droogte; geef bij langdurige droogte',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Eenvoudige randbloem met blauwe bloemen die bijen en nuttige insecten aantrekt. '
        'Makkelijk te zaaien langs paden en bij bonen of uien in de moestuin.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook geliefd bij vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit op de rand',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Sierlijk in pluktuin en border',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 4,
      bumblebees: 3,
      hoverflies: 3,
    ),
    height: '40–80 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–augustus',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 9, 10},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF42A5F5),
      Color(0xFF7B1FA2),
      Color(0xFFE53935),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; zaai voorjaar of herfst',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droge perioden goed',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Makkelijke randbloem',
      'Trekt bijen en vlinders',
      'Blauwe zomerbloemen',
      'Direct buiten te zaaien',
      'Past langs moestuinpaden',
    ],
    tip:
        'Zaai direct in volle grond langs de rand; dun uit voor stevige planten.',
  ),
  'cosmos': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig tot gemiddeld',
    waterSubtitle: 'Verdraagt droogte; geef bij langdurige droogte',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Lang bloeiende eenjarige met luchtige bloemen voor bijen en vlinders. '
        'Ideaal op de rand van de moestuin; bloeit door tot de eerste vorst bij regelmatig deadheading.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Langdurige voedselbron voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Zeer geliefd bij vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit op de rand',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Mooi in pluktuin en border',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 5,
      bumblebees: 3,
      hoverflies: 3,
    ),
    height: '80–120 cm',
    width: '30–45 cm',
    bloomPeriod: 'Juli–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {5, 6},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFF48FB1),
      Color(0xFFE53935),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig en vorstgevoelig; zaai elk voorjaar opnieuw',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droge perioden goed',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Zeer aantrekkelijk voor vlinders',
      'Lang doorbloeiend',
      'Luchtige zomerbloemen',
      'Makkelijk direct te zaaien',
      'Ideaal op moestuinrand',
    ],
    tip:
        'Zaai direct buiten na de vorstperiode; dun uit voor luchtige, rijke bloei.',
  ),
  'boekweit': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Snelle groenbemester en bijenplant die binnen enkele weken bloeit. '
        'Ideaal op lege plekken tussen rijen; verbetert bodem en trekt zweefvliegen.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Snelle bijenbron na inzaai',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_soil_improvers.png',
        label: 'Verbetert bodem als groenbemester',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Trekt nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Vult lege plekken snel op',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 2,
      bumblebees: 3,
      hoverflies: 5,
    ),
    height: '40–60 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Kort',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {5, 6, 7, 8},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFF5F5F5),
      Color(0xFFFFC107),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, sterft bij vorst; elk voorjaar opnieuw zaaien',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableGreenManure,
    keyFeatures: [
      'Snelle groenbemester',
      'Trekt zweefvliegen',
      'Bloeit binnen enkele weken',
      'Verbeterd bodem',
      'Flexibel in te zaaien',
    ],
    tip:
        'Zaai na half mei (IJsheiligen) als groenbemester op lege plek; bloeit snel en trekt massaal zweefvliegen.',
  ),
  'witte_klaver': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '4–6 uur zon; ook licht halfschaduw',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Meerjarig',
    lifespanSubtitle: 'Komt terug als tapijt; zaai opnieuw indien nodig',
    summary:
        'Laag groenbedekkend klaver dat stikstof vastlegt in de bodem. '
        'Ideaal onder fruitbomen of als tijdelijke tussenteelt langs paden.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_soil_improvers.png',
        label: 'Vangt stikstof en verbetert bodem',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en hommels',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Laag tapijt onder fruit of struiken',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Dekkend tegen onkruid',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 2,
      bumblebees: 4,
      hoverflies: 3,
    ),
    height: '15–25 cm',
    width: '30–50 cm',
    bloomPeriod: 'Mei–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5, 6, 7, 8, 9},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {5, 6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFF5F5F5),
      Color(0xFFE8F5E9),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: true,
    winterHardyDetail: 'Ja, winterhard als laag tapijt',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableGreenManure,
    keyFeatures: [
      'Vangt stikstof in de bodem',
      'Laag groenbedekkend tapijt',
      'Trekt bijen en hommels',
      'Ideaal onder fruit',
      'Tijdelijke tussenteelt',
    ],
    tip:
        'Vastlegt stikstof; goed als tussen-teelt of groenbedekker onder fruitbomen.',
  ),
  'rode_klaver': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '4–6 uur zon per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Meerjarig',
    lifespanSubtitle: 'Kan terugkomen; zaai opnieuw als tussenteelt',
    summary:
        'Groenbemester met roodroze bloemen die stikstof vastlegt. '
        'Zaai in voorjaar of na oogst; knip vóór je opnieuw zaait in het bed.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_soil_improvers.png',
        label: 'Vangt stikstof en verbetert bodem',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en hommels',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Tijdelijke tussenteelt tussen rijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook aantrekkelijk voor vlinders',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 3,
      bumblebees: 4,
      hoverflies: 3,
    ),
    height: '30–60 cm',
    width: '25–40 cm',
    bloomPeriod: 'Mei–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5, 8, 9},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {5, 6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFE53935),
      Color(0xFFFF5252),
      Color(0xFFF48FB1),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: true,
    winterHardyDetail: 'Ja, winterhard als groenbedekker',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableGreenManure,
    keyFeatures: [
      'Vangt stikstof in de bodem',
      'Groenbemester met bijenbloei',
      'Tijdelijke tussenteelt',
      'Trekt hommels',
      'Makkelijk in te zaaien',
    ],
    tip:
        'Zaai als groenbemester; knip of spit onder vóór je opnieuw groenten zaait.',
  ),
  'duizendblad': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig',
    waterSubtitle: 'Verdraagt droogte goed; weinig water nodig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Vaste plant',
    lifespanSubtitle: 'Winterhard en komt elk jaar terug',
    summary:
        'Kruidachtige vaste plant die parasietwespen en lieveheersbeestjes aantrekt. '
        'Versterkt buurtplanten bij kool, tomaat en komkommer met witte bloemtuilen.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Trekt parasietwespen en lieveheersbeestjes',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Witte bloemen voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit in de buurt',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Sierlijk en nuttig kruid',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 3,
      bumblebees: 3,
      hoverflies: 4,
    ),
    height: '40–70 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFF5F5F5),
      Color(0xFFFFC107),
    ],
    fragrance: 'Kruidig',
    winterHardy: true,
    winterHardyDetail: 'Ja, tot ca. -25 °C',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droge perioden goed',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Winterhard en meerjarig',
      'Trekt nuttige insecten',
      'Witte bloemtuilen',
      'Versterkt buurtplanten',
      'Droogtolerant',
    ],
    tip:
        'Plant bij kool, tomaat of komkommer; laat een deel staan voor nuttige insecten.',
  ),
  'zaadslurf': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Laag bloeitapijt met zoete geur dat zweefvliegen tegen bladluis aantrekt. '
        'Ideaal tussen lage gewassen als sla, aardbei, kool en tomaat.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Trekt zweefvliegen die bladluis eten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Zoete geur lokt bestuivers',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Laag tapijt op voorgrond van bed',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Dekkend en sierlijk',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 2,
      bumblebees: 2,
      hoverflies: 5,
    ),
    height: '10–20 cm',
    width: '20–40 cm',
    bloomPeriod: 'Juni–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {4, 5, 6},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFAFAFA),
      Color(0xFFF8BBD0),
      Color(0xFFE1BEE7),
    ],
    fragrance: 'Honingzoet geurend',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Trekt zweefvliegen tegen bladluis',
      'Laag bloeitapijt',
      'Zoete geur',
      'Ideaal tussen lage gewassen',
      'Lang bloeiend',
    ],
    tip:
        'Zaai tussen sla, aardbei of kool; zweefvliegen eten bladluis in de buurt.',
  ),
  'limnanthes': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld tot veel',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Het \'slakkenplantje\': enorme bijenmagnet met fel gele bloemen. '
        'Korte, rijke bloei in voorjaar en vroege zomer; ideaal bij aardbei, fruit en bonen.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Enorme bijenaantrek in het voorjaar',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verbetert bestuiving in de buurt',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook nuttig voor andere bestuivers',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Fel geel en vrolijk tapijt',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 5,
      butterflies: 2,
      bumblebees: 3,
      hoverflies: 3,
    ),
    height: '15–25 cm',
    width: '25–40 cm',
    bloomPeriod: 'April–juni',
    bloomDuration: 'Kort',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 9},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {4, 5, 6}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {8, 9}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFFC107),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Zeer aantrekkelijk voor bijen',
      'Fel geel voorjaarsbloei',
      'Kort en krachtig effect',
      'Ideaal bij aardbei',
      'Makkelijk te zaaien',
    ],
    tip:
        'Zaai vroeg in het voorjaar; korte maar intense bijenbloei rond fruit en bonen.',
  ),
  'monarda': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld tot veel',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig; niet laten uitdrogen',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Vaste plant',
    lifespanSubtitle: 'Winterhard en komt elk jaar terug',
    summary:
        'Vaste bloem met rode of paarse bloemen die hommels en bijen aantrekt. '
        'Helpt bestuiving van pompoenfamilie; plant bij courgette, komkommer en fruit.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en hommels',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook geliefd bij vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Helpt bestuiving pompoenfamilie',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Sierlijk en lang bloeiend',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 5,
      butterflies: 4,
      bumblebees: 4,
      hoverflies: 3,
    ),
    height: '60–90 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {3, 4},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFE53935),
      Color(0xFF7B1FA2),
    ],
    fragrance: 'Citrus-muntachtig',
    winterHardy: true,
    winterHardyDetail: 'Ja, tot ca. -20 °C',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Winterhard en meerjarig',
      'Zeer aantrekkelijk voor bijen',
      'Helpt pompoenbestuiving',
      'Rode en paarse bloemen',
      'Let op meeldauw bij slechte luchtcirculatie',
    ],
    tip:
        'Plant bij pompoen of courgette; zorg voor goede luchtcirculatie om meeldauw te voorkomen. Niet te droog maar ook geen nat blad.',
  ),
  'zonnehoed': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig tot gemiddeld',
    waterSubtitle: 'Verdraagt droogte; geef bij langdurige droogte',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Vaste plant',
    lifespanSubtitle: 'Winterhard en komt elk jaar terug',
    summary:
        'Vaste prairiebloem die vlinders en bijen aantrekt op de moestuinrand. '
        'Decoratief en nuttig; bloeit lang in de zomer en herfst.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Trekt vlinders massaal',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Voedselbron voor bijen en hommels',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit op de rand',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Mooi in pluktuin',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 4,
      bumblebees: 4,
      hoverflies: 3,
    ),
    height: '60–120 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {2, 3},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFE53935),
      Color(0xFFFF9800),
      Color(0xFFF48FB1),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: true,
    winterHardyDetail: 'Ja, tot ca. -25 °C',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droge perioden',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Winterhard en meerjarig',
      'Zeer aantrekkelijk voor vlinders',
      'Lang bloeiend',
      'Droogtolerant',
      'Ideaal op moestuinrand',
    ],
    tip:
        'Plant op een zonnige rand; laat uitgebloeide stengels staan voor vogels in het najaar.',
  ),
  'verbena': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig',
    waterSubtitle: 'Geef pas water als de grond droog is',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'In NL meestal als eenjarig; soms licht overwinterend',
    summary:
        'Lang bloeiende bijenbron (ijzerhard), ook geschikt in pot bij terras-tuin. '
        'Paarse luchtige schermen trekken bijen de hele zomer; verdraagt droge, zonnige plekken goed.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Langdurige bijenbron',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook aantrekkelijk voor vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit op rand',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Mooi in pot en border',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 4,
      bumblebees: 3,
      hoverflies: 3,
    ),
    height: '100–150 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {3, 4},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF7B1FA2),
      Color(0xFF42A5F5),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, in NL meestal als eenjarig behandelen',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droge periodes goed',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Lang doorbloeiend',
      'Trekt bijen de hele zomer',
      'Droogtetolerant',
      'Paarse luchtige schermen',
      'Ideaal op moestuinrand',
    ],
    tip:
        'Zaai voor binnen of koop jonge planten; behandel als eenjarig of mulch licht in milde winters.',
  ),
  'wilde_marjolein': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig',
    waterSubtitle: 'Verdraagt droogte goed; weinig water nodig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Vaste plant',
    lifespanSubtitle: 'Winterhard kruid dat terugkomt',
    summary:
        'Geurend kruid dat sommige insecten verstoort en bestuivers aantrekt. '
        'Traditionele buur bij kool, boon en wortel in combinatieteelt.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Geur verstoort sommige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen in de zomer',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Versterkt combinatieteelt',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar kruid en bloei',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 2,
      bumblebees: 2,
      hoverflies: 3,
    ),
    height: '30–50 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {4, 5},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFF48FB1),
      Color(0xFFE1BEE7),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, tot ca. -15 °C',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droge perioden',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Winterhard kruid',
      'Geur verstoort insecten',
      'Trekt bestuivers',
      'Bij kool en wortel',
      'Droogtolerant',
    ],
    tip:
        'Plant bij kool, boon of wortel; laat een deel bloeien voor bijen.',
  ),
  'hysop': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig',
    waterSubtitle: 'Verdraagt droogte; geef pas water als de grond droog is',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Vaste plant',
    lifespanSubtitle: 'Winterhard en komt elk jaar terug',
    summary:
        'Traditioneel kruid bij kool en druif met blauwe bijenbloemen. '
        'Helpt plagen verminderen en verrijkt de moestuin met geur en kleur.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Traditioneel bij kool en druif',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Blauwe bloemen voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Versterkt combinatieteelt',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar kruid en sier',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 3,
      bumblebees: 3,
      hoverflies: 2,
    ),
    height: '40–60 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {3, 4},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF42A5F5),
      Color(0xFF7B1FA2),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, tot ca. -20 °C',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, houdt van doorlatende grond',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Winterhard en meerjarig',
      'Blauwe bijenbloemen',
      'Traditioneel bij kool',
      'Droogtolerant',
      'Aangename kruidengeur',
    ],
    tip:
        'Plant bij kool of langs druif; snoei na bloei licht terug.',
  ),
  'mosterd_geel': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Groenbemester en vangplant voor koolvlieg op lege bedden. '
        'Verbeterd bodem, maar spit 4 weken vóór koolteelt onder — niet direct ervoor zaaien.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Vangt koolvlieg op lege bedden',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_soil_improvers.png',
        label: 'Verbetert bodem als groenbemester',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Gele bloemen voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Vult lege plekken snel',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 2,
      bumblebees: 2,
      hoverflies: 4,
    ),
    height: '40–80 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–september',
    bloomDuration: 'Kort',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5, 6, 7, 8, 9},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFFC107),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, sterft bij vorst; elk voorjaar opnieuw zaaien',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableGreenManure,
    keyFeatures: [
      'Vangt koolvlieg',
      'Snelle groenbemester',
      'Gele bloemen',
      'Vult lege bedden',
      'Verbeterd bodem',
    ],
    tip:
        'Niet direct vóór broccoli of spruitkool zaaien; spit 4 weken vóór koolteelt onder.',
  ),
  'klaproos': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag; mag magere grond',
    water: 'Weinig',
    waterSubtitle: 'Geef pas water als de grond droog is',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Wilde randbloem die biodiversiteit verhoogt in een natuurlijke hoek. '
        'Zaai direct in herfst of vroeg voorjaar; klaproos houdt niet van verplanten.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verhoogt biodiversiteit',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Rustplek voor nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen op de rand',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Sierlijk in wilde hoek',
      ),
    ],
    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 3,
      bumblebees: 2,
      hoverflies: 3,
    ),
    height: '50–80 cm',
    width: '25–40 cm',
    bloomPeriod: 'Mei–juli',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (direct)',
          months: {3, 4, 9, 10},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {5, 6, 7}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {8, 9}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],
    flowerColors: [
      Color(0xFFE53935),
      Color(0xFFFF5252),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; herfstzaad overwintert in de grond',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, houdt van drogere, magere grond',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Verhoogt biodiversiteit',
      'Direct zaaien, niet verplanten',
      'Magere grond oké',
      'Rode klaprozen',
      'Zaai herfst of voorjaar',
    ],
    tip:
        'Zaai oppervlakkig op vaste plek; niet verspenen, want klaproos heeft een penwortel.',
  ),
  'bijenmengsel': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Gemengd zaad met bloemen die bijen en bestuivers door het seizoen voeden. '
        'Strooi waar een plek leeg is tussen rijen, bij bonen, fruit of komkommer.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Voedt bijen door het hele seizoen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Snelle mix voor bestuiving',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook vlinders en nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Flexibel in te zaaien',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 5,
      butterflies: 4,
      bumblebees: 4,
      hoverflies: 4,
    ),
    height: '30–80 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5, 9},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFFC107),
      Color(0xFFFF9800),
      Color(0xFFE53935),
      Color(0xFF7B1FA2),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, vooral eenjarigen; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Zeer aantrekkelijk voor bijen',
      'Mix bloeit door het seizoen',
      'Flexibel in te zaaien',
      'Ideaal op lege plek',
      'Verbetert bestuiving',
    ],
    tip:
        'Strooi waar een plek leeg is; inzaaien tussen rijen of na vroege oogst.',
  ),
  'lindebloesem': _FlowerFacts(
    standplaats: 'Volle zon tot lichte halfschaduw',
    standplaatsSubtitle: 'Ruime standplaats; volwassen boom',
    water: 'Gemiddeld',
    waterSubtitle: 'Jonge bomen regelmatig water',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Boom',
    lifespanSubtitle: 'Meerjarige boom; geen eenjarige teelt',
    summary:
        'Hommel- en bijenboom op lange termijn voor de hele tuin. '
        'Alleen bij ruime tuin; in klein bed kies liever facelia of klaver in de moestuin.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Enorme hommel- en bijenboom',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Voedt bestuivers op grote schaal',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ondersteunt biodiversiteit in de tuin',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Geurige juni-bloei',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 5,
      butterflies: 3,
      bumblebees: 5,
      hoverflies: 2,
    ),
    height: '800–1500 cm',
    width: '400–800 cm',
    bloomPeriod: 'Juni–juli',
    bloomDuration: 'Kort',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Planten',
          months: {10, 11, 3},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloesemoogst', months: {6, 7}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFFC107),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, winterharde boom',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Enorme bijen- en hommelboom',
      'Geurige junibloei',
      'Langetermijn investering',
      'Ondersteunt hele tuin',
      'Winterhard',
    ],
    tip:
        'Plant als boom op ruime plek; bloesem oogsten voor thee in juni–juli. Geen keuze voor klein bed.',
  ),
  'tagetes_patula': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Lage tagetes met sterke begeleiding bij nachtschadegewassen. '
        'Kan wortelknobbelaaltjes remmen bij dichte voorteelt; ideaal in smalle paden tussen groenten.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Sterke begeleider bij nachtschade',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_soil_improvers.png',
        label: 'Kan aaltjes remmen bij dichte voorteelt',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Compact in smalle paden',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 2,
      bumblebees: 2,
      hoverflies: 2,
    ),
    height: '20–30 cm',
    width: '20–25 cm',
    bloomPeriod: 'Juni–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {4, 5},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFF9800),
      Color(0xFFE53935),
    ],
    fragrance: 'Sterk geurend',
    winterHardy: false,
    winterHardyDetail: 'Nee, vorstgevoelig; eenjarig',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableMoestuinRand,
    keyFeatures: [
      'Kan wortelknobbelaaltjes remmen (dichte voorteelt)',
      'Lage variant voor smalle paden',
      'Lang bloeiend',
      'Bij tomaat en paprika',
      'Compact en kleurrijk',
    ],
    tip:
        'Plant na de IJsheiligen; lage variant ideaal in smalle paden tussen groenten bij tomaat en aardappel.',
  ),
  'alyssum_sneeuw': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Laag wit bloeitapijt dat zweefvliegen tegen bladluis aantrekt. '
        'Mooi op de voorgrond van bedden, randen en in potten.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Trekt zweefvliegen tegen bladluis',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Kleine bloemen voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Laag op voorgrond van bed',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Wit tapijt in pot en border',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 3,
      bumblebees: 2,
      hoverflies: 4,
    ),
    height: '10–15 cm',
    width: '20–30 cm',
    bloomPeriod: 'Mei–september',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {4, 5, 6},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {5, 6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFF5F5F5),
      Color(0xFFE1BEE7),
    ],
    fragrance: 'Honingzoet geurend',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Trekt zweefvliegen',
      'Laag bodembedekkend',
      'Wit bloeitapijt',
      'Ideaal in potten',
      'Lang bloeiend',
    ],
    tip:
        'Laag bodembedekkend; ideaal aan randen, voorgrond van bedden en in potten.',
  ),
  'calendula_officinalis': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Eetbare goudsbloem die bladluis verstoort en lieveheersbeestjes aantrekt. '
        'Vrolijke rand langs paden; bloeit de hele zomer door bij regelmatig deadheading.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Vangt en verstoort bladluis',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbare bloembladeren',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Vrolijke rand langs paden',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 4,
      bumblebees: 3,
      hoverflies: 4,
    ),
    height: '30–50 cm',
    width: '25–40 cm',
    bloomPeriod: 'Mei–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5, 6},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {5, 6, 7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFF9800),
      Color(0xFFFFC107),
      Color(0xFFE53935),
    ],
    fragrance: 'Kruidig-harsachtig',
    winterHardy: false,
    winterHardyDetail: 'Nee als meerjarig; verdraagt lichte vorst; zaai vanaf maart',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Eetbare bloembladeren',
      'Trekt lieveheersbeestjes',
      'Lang doorbloeiend',
      'Vangt bladluis',
      'Warme kleuren',
    ],
    tip:
        'Knip uitgebloeide bloemen weg voor doorbloei; eetbare bloembladeren op salade.',
  ),
  'zinnia': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Warmteminnende eenjarige met rijke kleuren voor bijen en vlinders. '
        'Zaai pas na de IJsheiligen; houdt van een warme, zonnige plek in de moestuin.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Zeer geliefd bij vlinders',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen in de zomer',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Mooi in pluktuin',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verrijkt moestuinrand met kleur',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 5,
      bumblebees: 3,
      hoverflies: 2,
    ),
    height: '40–90 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {4, 5},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFE53935),
      Color(0xFFFF9800),
      Color(0xFFF48FB1),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, vorstgevoelig; eenjarig opnieuw zaaien',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Zeer aantrekkelijk voor vlinders',
      'Rijke zomerbloemen',
      'Lang doorbloeiend',
      'Warmteminnend',
      'Mooi in pluktuin',
    ],
    tip:
        'Zaai pas na de IJsheiligen; houdt van warme plekken en regelmatig deadheading.',
  ),
  'lupine_groenbemester': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen; spit onder voor bemesting',
    summary:
        'Peulgewas als groenbemester met rijke bloei voor hommels en bijen. '
        'Werk onder vóór zaadzetting als je groenbemesting wilt, niet voor zaad.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_soil_improvers.png',
        label: 'Verbetert bodem als groenbemester',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en hommels',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Vastlegt stikstof via wortels',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Sierlijke zomerbloei',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 4,
      bumblebees: 5,
      hoverflies: 2,
    ),
    height: '60–100 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–augustus',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {8, 9}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF7B1FA2),
      Color(0xFF42A5F5),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarige groenbemester',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableGreenManure,
    keyFeatures: [
      'Groenbemester met stikstof',
      'Trekt hommels',
      'Sierlijke zomerbloei',
      'Verbetert bodem',
      'Spit onder vóór zaad',
    ],
    tip:
        'Werk onder na de bloei en vóór zaadzetting als je groenbemesting wilt; niet laten uitzaaien in het bed.',
  ),
  'stiefmoedje': _FlowerFacts(
    standplaats: 'Halfschaduw',
    standplaatsSubtitle: '3–6 uur zon; koeler weer',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Tweejarig',
    lifespanSubtitle: 'Bloeit vaak in het tweede jaar; kan terugkomen',
    summary:
        'Koel-season bloem met gezichtjes; bloeit vroeg in voorjaar en herfst. '
        'Ideaal in pot, border of onder hogere planten; winterhard biennial.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Vroege voedselbron voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Kleur in voor- en najaar',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Mooi in pot en border',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Ook in koelere maanden actief',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 3,
      bumblebees: 2,
      hoverflies: 3,
    ),
    height: '15–25 cm',
    width: '20–30 cm',
    bloomPeriod: 'Maart–mei & september–november',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {6, 7, 8},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {3, 8, 9}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {3, 4, 5, 9, 10, 11}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {7, 8}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF7B1FA2),
      Color(0xFF42A5F5),
      Color(0xFFFFC107),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Licht geurend of neutraal',
    winterHardy: true,
    winterHardyDetail: 'Ja, winterhard tot ca. -15 °C',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Bloeit vroeg en laat in seizoen',
      'Winterhard biennial',
      'Geschikt in pot',
      'Koel-season kleur',
      'Compact en rijk',
    ],
    tip:
        'Zaai in zomer voor bloei volgend voorjaar; houdt van koelere, licht beschaduwde plekken.',
  ),
  'ringelbloem': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Eetbare goudsbloem (Calendula officinalis) met oranje bloemhoofden langs de moestuinrand. '
        'Trekt zweefvliegen en nuttige insecten; bloeit lang van mei tot oktober.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbare bloembladeren',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Verrijkt moestuinrand',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Trekt zweefvliegen',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 3,
      butterflies: 3,
      bumblebees: 2,
      hoverflies: 4,
    ),
    height: '30–50 cm',
    width: '25–40 cm',
    bloomPeriod: 'Mei–oktober',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {3, 4, 5, 6, 9},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {5, 6, 7, 8, 9, 10}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFF9800),
      Color(0xFFFFC107),
      Color(0xFFE53935),
    ],
    fragrance: 'Kruidig-harsachtig',
    winterHardy: false,
    winterHardyDetail: 'Nee als meerjarig; verdraagt lichte vorst; zaai vanaf maart',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Eetbare bloembladeren',
      'Trekt zweefvliegen',
      'Lang bloeiend',
      'Oranje bloemhoofden',
      'Rand langs moestuin',
    ],
    tip:
        'Plant langs de rand; verwijder uitgebloeide bloemen voor langere bloei.',
  ),
  'lavendel': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig',
    waterSubtitle: 'Geef pas water als de grond droog is',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Vaste plant',
    lifespanSubtitle: 'Winterhard en komt elk jaar terug',
    summary:
        'Geurende, winterharde vaste plant die bijen en vlinders aantrekt. '
        'Bloeit rijkelijk van juni tot september en is ideaal voor borders, potten en droge plekken.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Trekt bijen en hommels in de zomer',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Geur helpt wolluis en mot te verminderen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_butterfly.png',
        label: 'Vlinders bezoeken de bloemen regelmatig',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Mooi in pluktuin en droogbloemen',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 5,
      butterflies: 4,
      bumblebees: 4,
      hoverflies: 3,
    ),
    height: '60–80 cm',
    width: '40–60 cm',
    bloomPeriod: 'Juni–augustus',
    bloomDuration: 'Lang',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {2, 3, 4},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {10, 11}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF7B1FA2),
      Color(0xFF7986CB),
      Color(0xFFF48FB1),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, bij scherpe drainage; natte winters zijn riskanter dan vorst',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droogte uitstekend',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Winterhard en meerjarig',
      'Zeer aantrekkelijk voor bijen',
      'Heerlijke geur in de tuin',
      'Weinig water nodig',
      'Geschikt voor pot en border',
    ],
    tip:
        'Knip lavendel na de bloei licht terug om compact te houden. Plant op doorlatende grond; natte klei is funester dan kou.',
  ),
  'ui_bloei': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Tweejarig',
    lifespanSubtitle: 'Ui bloeit vaak in het tweede jaar',
    summary:
        'Laat bewust 2–3 uien doorbloeien voor bestuivers en combinatiewerking. '
        'Uiengeur helpt wortel en prei; bolvormige bloem voor bijen.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Uiengeur helpt wortel en prei',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Bolvormige bloem voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Gratis combinatiewerking uit eigen teelt',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Bewust deel laten staan',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 2,
      bumblebees: 3,
      hoverflies: 3,
    ),
    height: '80–120 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–juli',
    bloomDuration: 'Kort',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Planten / overwinteren',
          months: {3, 4, 9, 10},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei (jaar 2)', months: {6, 7}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {8, 9}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],
    flowerColors: [
      Color(0xFFF5F5F5),
      Color(0xFFFFC107),
    ],
    fragrance: 'Licht geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, overwintert als bol voor bloei in jaar 2',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water in groei',
    suitableFor: _suitableMoestuinRand,
    keyFeatures: [
      'Uiengeur helpt buurtplanten',
      'Gratis uit eigen teelt',
      'Trekt bijen',
      'Bolvormige bloem',
      'Bloeit in het tweede jaar',
    ],
    tip:
        'Laat bewust 2–3 overwinterde uien doorbloeien; oogst de rest voor keuken.',
  ),
  'look_bloei': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Bolgewas',
    lifespanSubtitle: 'Bloeit juni–juli na najaarsplanten',
    summary:
        'Laat knoflook of look doorbloeien voor afschrikkende geur rond buurtplanten. '
        'Helpt diverse plagen verminderen bij tomaat, aardbei en fruit.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Afschrikkende geur op diverse plagen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Bloei trekt bestuivers',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Gratis uit eigen teelt',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Sierlijk bolvormige bloem',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 2,
      bumblebees: 3,
      hoverflies: 2,
    ),
    height: '60–100 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–juli',
    bloomDuration: 'Kort',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Planten',
          months: {10, 11, 3},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {3, 4}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {8, 9}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFF5F5F5),
      Color(0xFFE8F5E9),
    ],
    fragrance: 'Sterk geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, winterhard',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableMoestuinRand,
    keyFeatures: [
      'Afschrikkende geur',
      'Gratis uit eigen teelt',
      'Trekt bestuivers',
      'Bij tomaat en fruit',
      'Bolvormige bloem',
    ],
    tip:
        'Laat een paar bolletjes doorbloeien; plant look in het najaar of vroege lente.',
  ),
  'dille_bloei': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Laat een deel dille doorbloeien voor zweefvliegen en parasietwespen. '
        'Ideaal tussen kool, komkommer en tomaat voor natuurlijke plaagbeheersing.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Trekt zweefvliegen en parasietwespen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Geel schermbloei voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Ideaal tussen kool',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar kruid en bloei',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 2,
      bumblebees: 2,
      hoverflies: 4,
    ),
    height: '60–120 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {4, 5, 6, 7},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFFFC107),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Trekt zweefvliegen',
      'Ideaal bij kool',
      'Eetbaar kruid',
      'Geel schermbloei',
      'Doorzaaien voor lang effect',
    ],
    tip:
        'Zaai elke paar weken door; laat een deel bloeien voor nuttige insecten.',
  ),
  'koriander_bloei': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Laat koriander doorbloeien voor nuttige insecten en bestuivers. '
        'Zaai elke 3 weken door voor lang effect; bloei trekt zweefvliegen.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Bloei trekt bijen en nuttige insecten',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Zweefvliegen tegen bladluis',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Doorzaaien voor lang effect',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar kruid en zaad',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 2,
      bumblebees: 2,
      hoverflies: 4,
    ),
    height: '30–60 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–augustus',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien',
          months: {4, 5, 6, 7, 8},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFF5F5F5),
      Color(0xFFE8F5E9),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: false,
    winterHardyDetail: 'Nee, eenjarig; zaai elk voorjaar opnieuw',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Trekt nuttige insecten',
      'Doorzaaien elke 3 weken',
      'Bij tomaat en komkommer',
      'Eetbaar zaad en blad',
      'Zweefvliegen tegen bladluis',
    ],
    tip:
        'Zaai regelmatig door; laat een deel schieten voor bijen en nuttige insecten.',
  ),
  'salie_bloei': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig',
    waterSubtitle: 'Verdraagt droogte goed; weinig water nodig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Vaste plant',
    lifespanSubtitle: 'Winterhard en komt elk jaar terug',
    summary:
        'Vaste salie in bloei helpt koolmot verminderen en trekt bestuivers. '
        'Plant bij kool, wortel of aardbei; blauwe bloemen in de vroege zomer.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Helpt koolmot verminderen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Blauwe zomerbloei voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Versterkt combinatieteelt',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar kruid en sier',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 3,
      bumblebees: 3,
      hoverflies: 2,
    ),
    height: '40–60 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juni–juli',
    bloomDuration: 'Kort',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Planten',
          months: {3, 4, 9, 10},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {4, 5, 10}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {7, 8}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFF7B1FA2),
      Color(0xFF42A5F5),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, tot ca. -15 °C',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droge perioden',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Winterhard en meerjarig',
      'Helpt koolmot verminderen',
      'Blauwe zomerbloei',
      'Bij koolgewassen',
      'Droogtolerant',
    ],
    tip:
        'Plant bij kool, wortel of aardbei; snoei na bloei licht terug.',
  ),
  'tijm_bloei': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Weinig',
    waterSubtitle: 'Geef pas water als de grond droog is',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Vaste plant',
    lifespanSubtitle: 'Winterhard en komt elk jaar terug',
    summary:
        'Laag droogtolerant kruid dat koolbladluis helpt verminderen. '
        'Plant bij kool, aardbei of tussen tegels; bloeit rijk in het voorjaar.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Helpt koolbladluis verminderen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Voorjaarsbloei voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Laag en combinatievriendelijk',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar kruid en sier',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 3,
      bumblebees: 3,
      hoverflies: 3,
    ),
    height: '10–25 cm',
    width: '20–30 cm',
    bloomPeriod: 'Juni–augustus',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Planten',
          months: {3, 4, 9},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {4, 5}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {6, 7, 8}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {8, 9}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFE8F5E9),
      Color(0xFFF5F5F5),
      Color(0xFFFFC107),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, tot ca. -20 °C',
    droughtResistant: true,
    droughtResistantDetail: 'Ja, verdraagt droogte uitstekend',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Winterhard en meerjarig',
      'Droogtolerant',
      'Helpt koolbladluis verminderen',
      'Laag en compact',
      'Heerlijke geur',
    ],
    tip:
        'Laag en droogtolerant; plant bij kool voor bladluiswerking.',
  ),
  'basilicum_bloei': _FlowerFacts(
    standplaats: 'Volle zon',
    standplaatsSubtitle: '6+ uur per dag',
    water: 'Gemiddeld tot veel',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Eenjarig',
    lifespanSubtitle: 'Bloeit één seizoen, zaai opnieuw',
    summary:
        'Laat een deel basilicum doorbloeien voor bijen naast tomaat en paprika. '
        'Versterkt combinatieteelt; knip rest voor keuken en laat enkele planten bloeien.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Versterkt tomaat en paprika',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Bloei trekt bestuivers',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'Gratis uit eigen kruidenbed',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar kruid en bloei',
      ),
    ],

    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 3,
      bumblebees: 2,
      hoverflies: 3,
    ),
    height: '30–50 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Zaaien (binnen)',
          months: {4, 5},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {5, 6}),
        accentColor: Color(0xFF2E7D32),
        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',
      ),
    ],

    flowerColors: [
      Color(0xFFE8F5E9),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: false,
    winterHardyDetail: 'Nee, vorstgevoelig',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, regelmatig water',
    suitableFor: _suitableFull,
    keyFeatures: [
      'Versterkt tomaat en paprika',
      'Bloei trekt bestuivers',
      'Eetbaar kruid',
      'Warmteminnend',
      'Gratis uit eigen teelt',
    ],
    tip:
        'Laat een deel bloeien voor bijen; knip de rest regelmatig voor keuken.',
  ),
  'munt_bloei': _FlowerFacts(
    standplaats: 'Halfschaduw',
    standplaatsSubtitle: 'Zon tot halfschaduw; vochtige grond',
    water: 'Veel',
    waterSubtitle: 'Houd de grond gelijkmatig vochtig',
    difficulty: 'Makkelijk',
    difficultySubtitle: 'Geschikt voor beginners',
    lifespan: 'Meerjarig',
    lifespanSubtitle: 'Winterhard; begrens wortels in pot',
    summary:
        'Muntbloei trekt bijen in de zomer en geurt sterk. '
        'De plant is winterhard; zet haar in pot tegen woekeren, niet tegen vorst.',
    whyPlantReasons: [
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/bloom/bloom_pollinator_bee.png',
        label: 'Zomerbloei voor bijen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_benefits.png',
        label: 'In pot goed te beheersen',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/combination/combo_pest_plants.png',
        label: 'Sterke geur in de moestuinrand',
      ),
      FlowerWhyPlantReason(
        imageAsset: 'assets/images/harvest/harvest_basket.png',
        label: 'Eetbaar kruid en sier',
      ),
    ],
    pollinatorRatings: FlowerPollinatorRatings(
      bees: 4,
      butterflies: 2,
      bumblebees: 2,
      hoverflies: 3,
    ),
    height: '30–60 cm',
    width: '25–40 cm',
    bloomPeriod: 'Juli–september',
    bloomDuration: 'Gemiddeld',
    calendarMoments: [
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(
          label: 'Planten',
          months: {4, 5, 9},
        ),
        accentColor: Color(0xFF43A047),
        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Bloei', months: {7, 8, 9}),
        accentColor: Color(0xFF7B1FA2),
        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',
      ),
      FlowerCalendarMoment(
        timeline: PlantMonthTimeline(label: 'Snoeien', months: {9, 10}),
        accentColor: Color(0xFFF57C00),
        imageAsset: 'assets/images/harvest/harvest_basket.png',
      ),
    ],
    flowerColors: [
      Color(0xFFE8F5E9),
      Color(0xFF7B1FA2),
      Color(0xFFF5F5F5),
    ],
    fragrance: 'Heerlijk geurend',
    winterHardy: true,
    winterHardyDetail: 'Ja, winterhard in NL; pot is tegen woekeren',
    droughtResistant: false,
    droughtResistantDetail: 'Nee, houdt van vochtige grond',
    suitableFor: _suitablePotBee,
    keyFeatures: [
      'Winterhard en meerjarig',
      'Altijd in pot tegen woekeren',
      'Trekt bijen',
      'Eetbaar kruid',
      'Vochtige standplaats',
    ],
    tip:
        'Altijd in pot plaatsen — wortels verspreiden zich snel in open grond.',
  ),
};
