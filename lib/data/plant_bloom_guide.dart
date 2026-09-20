import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_section_details.dart';
import 'crop_harvest_kind.dart';
import 'moestuin_companion_info.dart';

enum PlantBloomIllustration {
  periodFlower,
  firstBloom,
  fruitTiming,
  pollinationSelf,
  pollinationCross,
  pollinationManual,
  pollinatorBee,
  pollinatorBumblebee,
  pollinatorButterfly,
  stimulateSun,
  stimulateWater,
  stimulatePotassium,
  deadheadShears,
  manualPollination,
  problemDrop,
  problemNoBloom,
  problemFewFlowers,
  healthyBloom,
  edibleFlowers,
  edibleFruitsOnly,
  edibleNot,
  flowerMale,
  flowerFemale,
}

/// Hoe mannelijke/vrouwelijke bloemen (of planten) bij dit gewas zitten.
enum FlowerSexKind {
  /// Één bloem heeft zowel meeldraden als stamper (tomaat, paprika, …).
  perfect,

  /// Aparte mannelijke en vrouwelijke bloemen op dezelfde plant (courgette, …).
  monoecious,

  /// Aparte mannelijke en vrouwelijke planten (kiwi, duindoorn, …).
  dioecious,
}

enum BloomIllustrationSize {
  normal,
  compact,
  icon,
}

enum PollinationKind { self, cross, manual }

enum EdibleBloomKind { flowers, fruitsOnly, notEdible }

enum BloomListMarker { number, check, bullet }

class BloomListItem {
  const BloomListItem(
    this.text, {
    this.marker = BloomListMarker.bullet,
    this.number,
  });

  final String text;
  final BloomListMarker marker;
  final int? number;
}

class BloomOption {
  const BloomOption({
    required this.label,
    required this.illustration,
    this.description,
    this.highlighted = false,
  });

  final String label;
  final PlantBloomIllustration illustration;
  final String? description;
  final bool highlighted;
}

class BloomProblemItem {
  const BloomProblemItem({
    required this.title,
    required this.description,
    required this.illustration,
  });

  final String title;
  final String description;
  final PlantBloomIllustration illustration;
}

class PlantBloomSection {
  const PlantBloomSection({
    this.title = '',
    this.subtitle,
    this.summary,
    this.bloomMonths,
    this.illustration,
    this.illustrationSize = BloomIllustrationSize.normal,
    this.options,
    this.iconFactors,
    this.problems,
    this.checklist,
    this.steps,
    this.recommendedBadge,
    this.showCalendarIcon = false,
    this.details = const [],
  });

  final String title;
  final String? subtitle;
  final String? summary;
  final Set<int>? bloomMonths;
  final PlantBloomIllustration? illustration;
  final BloomIllustrationSize illustrationSize;
  final List<BloomOption>? options;
  final List<BloomOption>? iconFactors;
  final List<BloomProblemItem>? problems;
  final List<BloomListItem>? checklist;
  final List<BloomListItem>? steps;
  final String? recommendedBadge;
  final bool showCalendarIcon;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage =>
      title.isNotEmpty && details.isNotEmpty;
}

enum PlantBloomRowKind {
  bloomPeriod,
  columns2,
  optionGrid,
  iconGrid,
  split,
  problemsHealthy,
}

class PlantBloomRow {
  const PlantBloomRow({
    required this.kind,
    required this.sections,
    this.stackVertically = false,
  });

  final PlantBloomRowKind kind;
  final List<PlantBloomSection> sections;
  final bool stackVertically;
}

class PlantBloomGuide {
  const PlantBloomGuide({required this.rows});

  final List<PlantBloomRow> rows;
}

PlantBloomGuide bloomGuideForVegetable(Vegetable vegetable) {
  final built = _buildBloomGuide(vegetable);
  return PlantBloomGuide(
    rows: [
      for (final row in built.rows)
        PlantBloomRow(
          kind: row.kind,
          stackVertically: row.stackVertically,
          sections: [
            for (final s in row.sections)
              PlantBloomSection(
                title: s.title,
                subtitle: s.subtitle,
                summary: s.title.isEmpty
                    ? s.summary
                    : cropCardSummaryFor(
                        tab: 'bloom',
                        title: s.title,
                        vegetable: vegetable,
                      ),
                bloomMonths: s.bloomMonths,
                illustration: s.illustration,
                illustrationSize: s.illustrationSize,
                options: s.options,
                iconFactors: s.iconFactors,
                problems: s.problems,
                checklist: s.checklist,
                steps: s.steps,
                recommendedBadge: s.recommendedBadge,
                showCalendarIcon: s.showCalendarIcon,
                details: s.title.isEmpty
                    ? const <PlantGuideDetailBlock>[]
                    : sectionDetailsFor(
                        tab: 'bloom',
                        title: s.title,
                        vegetable: vegetable,
                      ),
              ),
          ],
        ),
    ],
  );
}

Set<int> _monthsFromText(String text) {
  const map = {
    'januari': 1,
    'februari': 2,
    'maart': 3,
    'april': 4,
    'mei': 5,
    'juni': 6,
    'juli': 7,
    'augustus': 8,
    'september': 9,
    'oktober': 10,
    'november': 11,
    'december': 12,
  };
  final t = text.toLowerCase();
  final out = <int>{};
  for (final e in map.entries) {
    if (t.contains(e.key)) out.add(e.value);
  }
  return out;
}

Set<int> _bloomMonths(Vegetable v, MoestuinCompanionInfo? companion) {
  if (companion != null) {
    final fromCompanion = _monthsFromText(companion.whenToPlant);
    if (fromCompanion.isNotEmpty) return fromCompanion;
  }

  final harvestMonths = _monthsFromText(v.harvest);
  if (harvestMonths.isNotEmpty) {
    final out = <int>{};
    for (final m in harvestMonths) {
      out.add(m);
      if (m > 1) out.add(m - 1);
    }
    return out;
  }

  final blob = '${v.summary} ${v.harvest} ${v.growthCategory}'.toLowerCase();
  if (blob.contains('bloei')) {
    return _monthsFromText(blob);
  }

  return {6, 7, 8, 9};
}

String _firstBloomText(Vegetable v) {
  final raw = v.cropDuration?.trim();
  if (raw != null && raw.isNotEmpty) {
    final digits = RegExp(r'(\d+)').firstMatch(raw);
    if (digits != null) {
      return 'Ongeveer ${digits.group(1)} dagen na zaaien.';
    }
    return 'Ongeveer $raw na zaaien.';
  }
  final cat = (v.growthCategory ?? '').toLowerCase();
  if (cat.contains('snelle')) return 'Ongeveer 45 dagen na zaaien.';
  if (cat.contains('meerjarig')) return 'Vaak in het tweede jaar na planten.';
  return 'Ongeveer 60 dagen na zaaien.';
}

bool _isFruitCrop(Vegetable v) {
  if (isMoestuinBloomCrop(v) && !isEdibleMoestuinBloomCrop(v)) {
    return false;
  }
  // Peulgewassen tellen hier mee: bloei → peul/vruchtzetting.
  final cat = cropHarvestCategoryFor(v.id);
  return cat == CropHarvestCategory.fruit ||
      cat == CropHarvestCategory.legume;
}

PollinationKind pollinationKindForVegetable(Vegetable v) {
  final id = v.id.toLowerCase();
  final key = cropProfileKeyFor(v.id);
  if (id.contains('courgette') ||
      id.contains('pompoen') ||
      id.contains('komkommer') ||
      id.contains('meloen') ||
      key == CropProfileKey.ui ||
      key == CropProfileKey.prei) {
    return PollinationKind.cross;
  }
  if (id.contains('tomaat') ||
      id.contains('paprika') ||
      id.contains('aubergine') ||
      id.contains('boon') ||
      id.contains('erwt')) {
    return PollinationKind.self;
  }
  if (isMoestuinBloomCrop(v)) return PollinationKind.cross;
  return PollinationKind.self;
}

PollinationKind _pollinationKind(Vegetable v) => pollinationKindForVegetable(v);

bool _manualPollinationUseful(Vegetable v, PollinationKind kind) {
  return kind == PollinationKind.cross ||
      v.id.contains('komkommer') ||
      v.id.contains('courgette') ||
      v.id.contains('pompoen');
}

FlowerSexKind flowerSexKindForVegetable(Vegetable v) {
  final id = v.id.toLowerCase();
  final blob =
      '${v.id} ${v.nameNl} ${v.summary} ${v.care} ${v.growthCategory}'
          .toLowerCase();

  if (id.contains('kiwi') ||
      id.contains('duindoorn') ||
      id.contains('spinazie') ||
      blob.contains('mannelijke + vrouwelijke plant') ||
      blob.contains('mannelijke en vrouwelijke plant') ||
      blob.contains('tweehuizig')) {
    return FlowerSexKind.dioecious;
  }

  if (id.contains('courgette') ||
      id.contains('pompoen') ||
      id.contains('komkommer') ||
      id.contains('meloen') ||
      id.contains('augurk') ||
      id.contains('patisson') ||
      id.contains('spaghetti_pompoen') ||
      id.contains('mais') ||
      id.contains('maïs') ||
      blob.contains('mannelijke en vrouwelijke bloem') ||
      blob.contains('eenslachtige bloem')) {
    return FlowerSexKind.monoecious;
  }

  return FlowerSexKind.perfect;
}

({String summary, String maleTitle, String maleBody, String femaleTitle, String femaleBody})
    _flowerSexCopy(Vegetable v, FlowerSexKind kind) {
  switch (kind) {
    case FlowerSexKind.monoecious:
      return (
        summary:
            'Deze plant maakt aparte mannelijke en vrouwelijke bloemen op '
            'dezelfde plant. Alleen de vrouwelijke bloem kan een vrucht vormen, '
            'nadat ze bestoven is met stuifmeel van een mannelijke bloem.',
        maleTitle: 'Mannelijke bloem',
        maleBody:
            'Meestal op een lange, dunne steel. In het hart zitten meeldraden '
            'met geel stuifmeel. Vormt zelf geen vrucht — wel nodig voor '
            'bestuiving.',
        femaleTitle: 'Vrouwelijke bloem',
        femaleBody:
            'Herkenbaar aan een klein vruchtbeginsel (een mini-vruchtje) '
            'direct achter de bloem. Na goede bestuiving groeit dat uit tot '
            'de vrucht.',
      );
    case FlowerSexKind.dioecious:
      return (
        summary:
            'Bij dit gewas zitten mannelijke en vrouwelijke bloemen niet op '
            'dezelfde plant. Voor vruchten of bessen heb je meestal een '
            'mannelijke én een vrouwelijke plant nodig.',
        maleTitle: 'Mannelijke plant',
        maleBody:
            'Maakt mannelijke bloemen met stuifmeel. Zonder een mannelijke '
            'plant in de buurt wordt de vrouwelijke plant vaak niet goed '
            'bestoven.',
        femaleTitle: 'Vrouwelijke plant',
        femaleBody:
            'Maakt vrouwelijke bloemen die na bestuiving vrucht of bes vormen. '
            'Zorg dat er een mannelijke plant in de buurt staat.',
      );
    case FlowerSexKind.perfect:
      return (
        summary:
            'Elke bloem van deze plant heeft zowel mannelijke als vrouwelijke '
            'delen. Je hoeft dus geen aparte “mannetjes-” en “vrouwtjesbloemen” '
            'te zoeken — wel helpt het soms om te weten welk deel wat doet.',
        maleTitle: 'Mannelijk deel (meeldraden)',
        maleBody:
            'De meeldraden zitten in de bloem en maken stuifmeel. Bij '
            'zelfbestuivers kan dat stuifmeel op dezelfde bloem terechtkomen.',
        femaleTitle: 'Vrouwelijk deel (stamper)',
        femaleBody:
            'De stamper zit in het midden van de bloem. Als daar stuifmeel op '
            'komt, kan er vruchtzetting of zaadvorming volgen.',
      );
  }
}

List<BloomListItem> _manualPollinationStepsFor(FlowerSexKind sexKind) {
  if (sexKind == FlowerSexKind.monoecious) {
    return const [
      BloomListItem(
        'Pluk ’s ochtends een verse mannelijke bloem (lange steel, geen vruchtbeginsel).',
        marker: BloomListMarker.number,
        number: 1,
      ),
      BloomListItem(
        'Verwijder voorzichtig de bloemblaadjes zodat de meeldraden met stuifmeel vrijkomen.',
        marker: BloomListMarker.number,
        number: 2,
      ),
      BloomListItem(
        'Dep het stuifmeel in het hart van een vrouwelijke bloem (met klein vruchtbeginsel erachter).',
        marker: BloomListMarker.number,
        number: 3,
      ),
    ];
  }
  return _manualPollinationSteps();
}

bool _deadheadRecommended(Vegetable v, MoestuinCompanionInfo? companion) {
  if (companion != null || isMoestuinBloomCrop(v)) return true;
  final care = v.care.toLowerCase();
  return care.contains('uitgebloeid') ||
      care.contains('deadhead') ||
      care.contains('knip') && care.contains('bloem');
}

EdibleBloomKind _edibleKind(Vegetable v) {
  if (isOrnamentalOnlyMoestuinCrop(v)) return EdibleBloomKind.notEdible;
  if (isEdibleMoestuinBloomCrop(v)) return EdibleBloomKind.flowers;
  if (_isFruitCrop(v)) return EdibleBloomKind.fruitsOnly;
  final text =
      '${v.summary} ${v.harvest} ${v.harvestTips}'.toLowerCase();
  if (text.contains('eetbare bloem') || text.contains('bloemen eetbaar')) {
    return EdibleBloomKind.flowers;
  }
  return EdibleBloomKind.fruitsOnly;
}

List<BloomOption> _pollinationOptions(PollinationKind active, {required bool manualUseful}) {
  return [
    BloomOption(
      label: 'Zelfbestuivend',
      illustration: PlantBloomIllustration.pollinationSelf,
      highlighted: active == PollinationKind.self,
    ),
    BloomOption(
      label: 'Kruisbestuivend',
      illustration: PlantBloomIllustration.pollinationCross,
      highlighted: active == PollinationKind.cross,
    ),
    BloomOption(
      label: 'Handmatige bestuiving mogelijk',
      illustration: PlantBloomIllustration.pollinationManual,
      highlighted: manualUseful,
    ),
  ];
}

List<BloomOption> _pollinatorFactors() {
  return const [
    BloomOption(
      label: 'Bijen',
      illustration: PlantBloomIllustration.pollinatorBee,
    ),
    BloomOption(
      label: 'Hommels',
      illustration: PlantBloomIllustration.pollinatorBumblebee,
    ),
    BloomOption(
      label: 'Vlinders',
      illustration: PlantBloomIllustration.pollinatorButterfly,
    ),
  ];
}

List<BloomOption> _stimulateFactors() {
  return const [
    BloomOption(
      label: 'Veel zonlicht',
      illustration: PlantBloomIllustration.stimulateSun,
    ),
    BloomOption(
      label: 'Regelmatig water geven',
      illustration: PlantBloomIllustration.stimulateWater,
    ),
    BloomOption(
      label: 'Kaliumrijke voeding',
      illustration: PlantBloomIllustration.stimulatePotassium,
    ),
  ];
}

List<BloomOption> _edibleOptions(EdibleBloomKind active) {
  return [
    BloomOption(
      label: 'Eetbare bloemen',
      description: 'De bloemen zijn eetbaar.',
      illustration: PlantBloomIllustration.edibleFlowers,
      highlighted: active == EdibleBloomKind.flowers,
    ),
    BloomOption(
      label: 'Alleen vruchten eetbaar',
      description: 'De bloemen niet, maar de vruchten wel.',
      illustration: PlantBloomIllustration.edibleFruitsOnly,
      highlighted: active == EdibleBloomKind.fruitsOnly,
    ),
    BloomOption(
      label: 'Niet eetbaar',
      description: 'Zowel bloemen als vruchten zijn niet eetbaar.',
      illustration: PlantBloomIllustration.edibleNot,
      highlighted: active == EdibleBloomKind.notEdible,
    ),
  ];
}

List<BloomProblemItem> _bloomProblems() {
  return const [
    BloomProblemItem(
      title: 'Bloemen vallen af',
      description:
          'Knoppen of bloemen vallen af voordat ze vruchten vormen.',
      illustration: PlantBloomIllustration.problemDrop,
    ),
    BloomProblemItem(
      title: 'Geen bloei',
      description: 'De plant vormt helemaal geen bloemen.',
      illustration: PlantBloomIllustration.problemNoBloom,
    ),
    BloomProblemItem(
      title: 'Weinig bloemen',
      description: 'De plant heeft wel bloemen, maar erg weinig.',
      illustration: PlantBloomIllustration.problemFewFlowers,
    ),
  ];
}

List<BloomListItem> _healthyBloomChecklist() {
  return const [
    BloomListItem('Veel bloemknoppen', marker: BloomListMarker.check),
    BloomListItem('Gezonde, stevige bloemen', marker: BloomListMarker.check),
    BloomListItem('Langdurige bloei', marker: BloomListMarker.check),
  ];
}

List<BloomListItem> _manualPollinationSteps() {
  return const [
    BloomListItem(
      'Gebruik een zacht kwastje of wattenstaafje.',
      marker: BloomListMarker.number,
      number: 1,
    ),
    BloomListItem(
      'Raak de meeldraden (het gele stuifmeel) in het hart van de bloem aan.',
      marker: BloomListMarker.number,
      number: 2,
    ),
    BloomListItem(
      'Breng het stuifmeel over op de stamper (het vrouwelijke deel) in het midden.',
      marker: BloomListMarker.number,
      number: 3,
    ),
  ];
}

PlantBloomGuide _buildBloomGuide(Vegetable v) {
  final companion = moestuinCompanionInfoForVegetable(v);
  final bloomMonths = _bloomMonths(v, companion);
  final pollination = _pollinationKind(v);
  final edible = _edibleKind(v);
  final fruitCrop = _isFruitCrop(v);
  final deadhead = _deadheadRecommended(v, companion);
  final manualUseful = _manualPollinationUseful(v, pollination);
  final flowerSex = flowerSexKindForVegetable(v);
  final sexCopy = _flowerSexCopy(v, flowerSex);

  final bloomSummary = bloomMonths.isEmpty
      ? 'Bloeit in het groeiseizoen.'
      : 'Bloeit ${_monthRangeNl(bloomMonths).toLowerCase()}.';

  return PlantBloomGuide(
    rows: [
      PlantBloomRow(
        kind: PlantBloomRowKind.bloomPeriod,
        sections: [
          PlantBloomSection(
            title: 'Bloeiperiode',
            subtitle: 'Wanneer bloeit de plant?',
            summary: bloomSummary,
            bloomMonths: bloomMonths,
            illustration: PlantBloomIllustration.periodFlower,
          ),
        ],
      ),
      PlantBloomRow(
        kind: PlantBloomRowKind.columns2,
        sections: [
          PlantBloomSection(
            title: 'Eerste bloei',
            subtitle: 'Wanneer verschijnen de eerste bloemen?',
            summary: _firstBloomText(v),
            illustration: PlantBloomIllustration.firstBloom,
            illustrationSize: BloomIllustrationSize.compact,
            showCalendarIcon: true,
          ),
          if (fruitCrop)
            PlantBloomSection(
              title: 'Tijd tot vruchtvorming',
              subtitle:
                  'Hoe lang duurt het tot de eerste vruchten verschijnen na de bloei?',
              summary: '7 – 14 dagen na bloei.',
              illustration: PlantBloomIllustration.fruitTiming,
              illustrationSize: BloomIllustrationSize.compact,
            ),
          if (!fruitCrop)
            PlantBloomSection(
              title: 'Bloei en oogst',
              subtitle: 'Wat betekent bloei voor dit gewas?',
              summary: cropFruitsForHarvest(v.id)
                  ? '7 – 14 dagen na bloei.'
                  : 'Bij dit gewas oogst je geen vruchten uit de bloem. '
                      'Bloei kan doorschieten signaleren.',
              illustration: PlantBloomIllustration.fruitTiming,
              illustrationSize: BloomIllustrationSize.compact,
            ),
        ],
      ),
      PlantBloomRow(
        kind: PlantBloomRowKind.optionGrid,
        sections: [
          PlantBloomSection(
            title: 'Zelfbestuiver',
            subtitle: pollination == PollinationKind.self
                ? 'Ja — deze plant bestuift zichzelf'
                : 'Nee — geen zelfbestuiver (kruisbestuiving)',
            summary: pollination == PollinationKind.self
                ? (fruitCrop
                    ? 'Eén plant is meestal genoeg voor bloei en vruchtzetting. '
                        'Insecten of wind kunnen nog helpen, maar zijn niet altijd nodig.'
                    : 'Eén plant is meestal genoeg voor bloei en zaadvorming. '
                        'Insecten of wind kunnen nog helpen, maar zijn niet altijd nodig.')
                : 'Voor goede bestuiving zijn insecten, wind of een tweede '
                    'plant/ras nodig. Handmatig bestuiven kan helpen.',
            options:
                _pollinationOptions(pollination, manualUseful: manualUseful),
          ),
        ],
      ),
      PlantBloomRow(
        kind: PlantBloomRowKind.columns2,
        stackVertically: true,
        sections: [
          PlantBloomSection(
            title: flowerSex == FlowerSexKind.dioecious
                ? 'Mannelijke en vrouwelijke planten'
                : 'Mannelijke en vrouwelijke bloemen',
            subtitle: flowerSex == FlowerSexKind.monoecious
                ? 'Aparte bloemen — zo herken je ze'
                : flowerSex == FlowerSexKind.dioecious
                    ? 'Aparte planten nodig voor vruchtzetting'
                    : 'Beide delen zitten in één bloem',
            summary: sexCopy.summary,
          ),
          PlantBloomSection(
            title: sexCopy.maleTitle,
            summary: sexCopy.maleBody,
            illustration: PlantBloomIllustration.flowerMale,
            illustrationSize: BloomIllustrationSize.compact,
          ),
          PlantBloomSection(
            title: sexCopy.femaleTitle,
            summary: sexCopy.femaleBody,
            illustration: PlantBloomIllustration.flowerFemale,
            illustrationSize: BloomIllustrationSize.compact,
          ),
        ],
      ),
      PlantBloomRow(
        kind: PlantBloomRowKind.iconGrid,
        sections: [
          PlantBloomSection(
            title: 'Bestuivers',
            subtitle: 'Welke insecten helpen bij de bestuiving?',
            iconFactors: _pollinatorFactors(),
          ),
        ],
      ),
      PlantBloomRow(
        kind: PlantBloomRowKind.iconGrid,
        sections: [
          PlantBloomSection(
            title: 'Bloei stimuleren',
            subtitle: 'Wat helpt voor meer bloemen?',
            iconFactors: _stimulateFactors(),
          ),
        ],
      ),
      PlantBloomRow(
        kind: PlantBloomRowKind.split,
        sections: [
          PlantBloomSection(
            title: 'Bloemen verwijderen',
            subtitle: 'Moet je uitgebloeide bloemen verwijderen?',
            summary: deadhead
                ? (fruitCrop
                    ? 'Dit stimuleert nieuwe bloei en vruchtvorming.'
                    : 'Dit stimuleert nieuwe bloei en houdt de plant productief.')
                : 'Meestal niet nodig bij deze teelt.',
            recommendedBadge: deadhead ? 'Ja, aanbevolen' : 'Niet nodig',
            illustration: PlantBloomIllustration.deadheadShears,
          ),
        ],
      ),
      if (manualUseful)
        PlantBloomRow(
          kind: PlantBloomRowKind.split,
          sections: [
            PlantBloomSection(
              title: 'Zelf je bloem bestuiven',
              subtitle: flowerSex == FlowerSexKind.monoecious
                  ? 'Van mannelijke naar vrouwelijke bloem'
                  : 'Hoe doe je dat?',
              steps: _manualPollinationStepsFor(flowerSex),
              illustration: PlantBloomIllustration.manualPollination,
            ),
          ],
        ),
      PlantBloomRow(
        kind: PlantBloomRowKind.problemsHealthy,
        sections: [
          PlantBloomSection(
            title: 'Tekenen van gezonde bloei',
            subtitle: 'Hoe herken je een gezonde bloei?',
            checklist: _healthyBloomChecklist(),
            illustration: PlantBloomIllustration.healthyBloom,
            illustrationSize: BloomIllustrationSize.compact,
          ),
          PlantBloomSection(
            title: 'Problemen tijdens bloei',
            subtitle: 'Veelvoorkomende problemen.',
            problems: _bloomProblems(),
          ),
        ],
      ),
      PlantBloomRow(
        kind: PlantBloomRowKind.optionGrid,
        sections: [
          PlantBloomSection(
            title: 'Eetbaar of niet',
            subtitle: 'Wat kun je eten aan deze plant?',
            options: _edibleOptions(edible),
          ),
        ],
      ),
    ],
  );
}

String _monthRangeNl(Set<int> months) {
  const names = [
    '',
    'januari',
    'februari',
    'maart',
    'april',
    'mei',
    'juni',
    'juli',
    'augustus',
    'september',
    'oktober',
    'november',
    'december',
  ];
  if (months.isEmpty) return '—';
  final sorted = months.toList()..sort();
  final parts = <String>[];
  var start = sorted.first;
  var prev = sorted.first;

  void flush(int end) {
    if (start == end) {
      parts.add('van ${names[start]}');
    } else {
      parts.add('van ${names[start]} tot ${names[end]}');
    }
  }

  for (var i = 1; i < sorted.length; i++) {
    final m = sorted[i];
    if (m == prev + 1) {
      prev = m;
    } else {
      flush(prev);
      start = m;
      prev = m;
    }
  }
  flush(prev);
  return parts.join(', ');
}
