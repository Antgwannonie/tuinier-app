import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_section_details.dart';
import 'crop_harvest_kind.dart';
import 'moestuin_companion_info.dart';

enum PlantHarvestIllustration {
  periodBasket,
  timeCalendar,
  ripeTomato,
  methodCut,
  methodPick,
  methodTwist,
  frequencyCalendar,
  yieldCrate,
  continueFlower,
  storageFridge,
  storageCool,
  storagePantry,
  freezeSnowflake,
  drySun,
  seedPacket,
  perfectTomato,
  edibleFruit,
  edibleLeaf,
  edibleFlower,
  edibleRoot,
  edibleShoot,
  edibleSeed,
}

enum HarvestIllustrationSize {
  normal,
  compact,
  icon,
}

enum HarvestListMarker { check, warning, cross, bullet, none }

class HarvestListItem {
  const HarvestListItem(
    this.text, {
    this.marker = HarvestListMarker.bullet,
    this.highlighted = false,
  });

  final String text;
  final HarvestListMarker marker;
  final bool highlighted;
}

class HarvestOption {
  const HarvestOption({
    required this.label,
    required this.illustration,
    this.description,
    this.highlighted = false,
  });

  final String label;
  final PlantHarvestIllustration illustration;
  final String? description;
  final bool highlighted;
}

class HarvestBadgeSection {
  const HarvestBadgeSection({
    required this.badgeText,
    required this.illustration,
  });

  final String badgeText;
  final PlantHarvestIllustration illustration;
}

class PlantHarvestSection {
  const PlantHarvestSection({
    this.title = '',
    this.subtitle,
    this.summary,
    this.harvestMonths,
    this.illustration,
    this.illustrationSize = HarvestIllustrationSize.normal,
    this.options,
    this.checklist,
    this.statusItems,
    this.badge,
    this.showCalendarClock = false,
    this.yesNoAnswer,
    this.problems,
    this.edibleParts,
    this.details = const [],
  });

  final String title;
  final String? subtitle;
  final String? summary;
  final Set<int>? harvestMonths;
  final PlantHarvestIllustration? illustration;
  final HarvestIllustrationSize illustrationSize;
  final List<HarvestOption>? options;
  final List<HarvestListItem>? checklist;
  final List<HarvestListItem>? statusItems;
  final String? badge;
  final bool showCalendarClock;
  final String? yesNoAnswer;
  final List<HarvestListItem>? problems;
  final List<HarvestOption>? edibleParts;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage =>
      title.isNotEmpty && details.isNotEmpty;
}

enum PlantHarvestRowKind {
  harvestPeriod,
  columns2,
  split,
  iconGrid,
  checklist,
  statusList,
  badgeColumns2,
  yesNoColumns2,
  problemsPerfect,
  edibleGrid,
}

class PlantHarvestRow {
  const PlantHarvestRow({
    required this.kind,
    required this.sections,
    this.stackVertically = false,
  });

  final PlantHarvestRowKind kind;
  final List<PlantHarvestSection> sections;
  final bool stackVertically;
}

class PlantHarvestGuide {
  const PlantHarvestGuide({required this.rows});

  final List<PlantHarvestRow> rows;
}

PlantHarvestGuide harvestGuideForVegetable(Vegetable vegetable) {
  final built = _buildHarvestGuide(vegetable);
  return PlantHarvestGuide(
    rows: [
      for (final row in built.rows)
        PlantHarvestRow(
          kind: row.kind,
          stackVertically: row.stackVertically,
          sections: [
            for (final s in row.sections)
              PlantHarvestSection(
                title: s.title,
                subtitle: s.subtitle,
                summary: s.title.isEmpty
                    ? s.summary
                    : cropCardSummaryFor(
                        tab: 'harvest',
                        title: s.title,
                        vegetable: vegetable,
                      ),
                harvestMonths: s.harvestMonths,
                illustration: s.illustration,
                illustrationSize: s.illustrationSize,
                options: s.options,
                checklist: s.checklist,
                statusItems: s.statusItems,
                badge: s.badge,
                showCalendarClock: s.showCalendarClock,
                yesNoAnswer: s.yesNoAnswer,
                problems: s.problems,
                edibleParts: s.edibleParts,
                details: s.title.isEmpty
                    ? const <PlantGuideDetailBlock>[]
                    : sectionDetailsFor(
                        tab: 'harvest',
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

Set<int> _harvestMonths(Vegetable v, MoestuinCompanionInfo? companion) {
  if (companion != null) {
    final m = _monthsFromText(companion.whenToPlant);
    if (m.isNotEmpty) return m;
  }
  return _monthsFromText(v.harvest);
}

String _timeToHarvest(Vegetable v) {
  final raw = v.cropDuration?.trim();
  if (raw != null && raw.isNotEmpty) {
    return '$raw na zaaien of uitplanten';
  }
  final cat = (v.growthCategory ?? '').toLowerCase();
  if (cat.contains('snelle')) return '30 – 45 dagen na uitplanten';
  if (cat.contains('meerjarig')) return 'Eerste oogst na 1 – 2 jaar';
  return '70 – 85 dagen na uitplanten';
}

List<HarvestListItem> _ripenessChecklist(Vegetable v) {
  final id = v.id.toLowerCase();
  if (id.contains('tomaat')) {
    return const [
      HarvestListItem('Volledig op kleur', marker: HarvestListMarker.check),
      HarvestListItem('Stevig maar licht zacht', marker: HarvestListMarker.check),
      HarvestListItem('Makkelijk los van de steel', marker: HarvestListMarker.check),
    ];
  }
  if (id.contains('paprika')) {
    return const [
      HarvestListItem('Juiste kleur voor het ras', marker: HarvestListMarker.check),
      HarvestListItem('Stevig en glanzend', marker: HarvestListMarker.check),
      HarvestListItem('Volgroeide grootte', marker: HarvestListMarker.check),
    ];
  }
  if (id.contains('sla') || id.contains('spinazie') || id.contains('blad')) {
    return const [
      HarvestListItem('Voldoende bladvolume', marker: HarvestListMarker.check),
      HarvestListItem('Fris groen van kleur', marker: HarvestListMarker.check),
      HarvestListItem('Niet doorschietend', marker: HarvestListMarker.check),
    ];
  }
  return const [
    HarvestListItem('Juiste kleur voor de soort', marker: HarvestListMarker.check),
    HarvestListItem('Stevig en gezond', marker: HarvestListMarker.check),
    HarvestListItem('Goede grootte', marker: HarvestListMarker.check),
  ];
}

List<HarvestOption> _harvestMethods(Vegetable v) {
  final id = v.id.toLowerCase();
  final cut = id.contains('sla') ||
      id.contains('kool') ||
      id.contains('snij') ||
      id.contains('blad');
  final twist = id.contains('tomaat') || id.contains('komkommer');
  return [
    HarvestOption(
      label: 'Knippen',
      illustration: PlantHarvestIllustration.methodCut,
      highlighted: cut,
    ),
    HarvestOption(
      label: 'Plukken',
      illustration: PlantHarvestIllustration.methodPick,
      highlighted: !cut && !twist,
    ),
    HarvestOption(
      label: 'Draaien',
      illustration: PlantHarvestIllustration.methodTwist,
      highlighted: twist,
    ),
  ];
}

String _harvestFrequency(Vegetable v) {
  final id = v.id.toLowerCase();
  if (id.contains('tomaat') ||
      id.contains('courgette') ||
      id.contains('komkommer') ||
      id.contains('bonen')) {
    return 'Elke 2 – 3 dagen. Regelmatig oogsten zorgt voor meer nieuwe vruchten.';
  }
  if (id.contains('sla') || id.contains('spinazie')) {
    return 'Doorlopend. Snij regelmatig blad af voor hergroei.';
  }
  return 'Afhankelijk van soort; oogst wanneer rijp.';
}

(String, String) _yieldEstimates(Vegetable v) {
  final id = v.id.toLowerCase();
  if (id.contains('tomaat')) return ('3 – 5 kg per plant', '8 – 12 kg per m²');
  if (id.contains('courgette') || id.contains('pompoen')) {
    return ('4 – 8 kg per plant', '10 – 15 kg per m²');
  }
  if (id.contains('sla') || id.contains('spinazie')) {
    return ('200 – 400 g per plant', '1 – 2 kg per m²');
  }
  if (id.contains('wortel') || id.contains('ui') || id.contains('prei')) {
    return ('1 – 2 kg per plant', '3 – 6 kg per m²');
  }
  return ('2 – 4 kg per plant', '5 – 10 kg per m²');
}

List<HarvestListItem> _stimulateChecklist() {
  return const [
    HarvestListItem('Regelmatig water geven', marker: HarvestListMarker.check),
    HarvestListItem('Voldoende zonlicht', marker: HarvestListMarker.check),
    HarvestListItem('Kaliumrijke voeding', marker: HarvestListMarker.check),
    HarvestListItem('Regelmatig oogsten', marker: HarvestListMarker.check),
  ];
}

List<HarvestListItem> _continueGrowthItems(Vegetable v) {
  final id = v.id.toLowerCase();
  final continuous = id.contains('tomaat') ||
      id.contains('courgette') ||
      id.contains('komkommer') ||
      id.contains('bonen') ||
      id.contains('sla');
  final oneTime = id.contains('wortel') ||
      id.contains('ui') ||
      id.contains('kool') ||
      id.contains('prei');

  return [
    HarvestListItem(
      'Nieuwe bloemen en vruchten',
      marker: HarvestListMarker.bullet,
      highlighted: continuous,
    ),
    HarvestListItem(
      'Plant blijft doorgroeien',
      marker: HarvestListMarker.check,
      highlighted: continuous,
    ),
    HarvestListItem(
      'Eenmalige oogst',
      marker: HarvestListMarker.cross,
      highlighted: oneTime,
    ),
  ];
}

List<HarvestOption> _storageOptions() {
  return const [
    HarvestOption(
      label: 'Koelkast',
      illustration: PlantHarvestIllustration.storageFridge,
      description: '7 – 14 dagen',
    ),
    HarvestOption(
      label: 'Koele plek',
      illustration: PlantHarvestIllustration.storageCool,
      description: '1 – 2 weken',
    ),
    HarvestOption(
      label: 'Voorraadkast',
      illustration: PlantHarvestIllustration.storagePantry,
      description: '5 – 10 dagen',
    ),
  ];
}

(String, String) _freezeInfo(Vegetable v) {
  final id = v.id.toLowerCase();
  if (id.contains('tomaat') ||
      id.contains('bonen') ||
      id.contains('erwt') ||
      id.contains('spinazie')) {
    return (
      'Ja, invriezen kan',
      'Voorbereiden en luchtdicht invriezen voor beste kwaliteit.',
    );
  }
  if (id.contains('sla') || id.contains('komkommer')) {
    return ('Nee, niet geschikt', 'Vers gebruiken geeft de beste smaak.');
  }
  return (
    'Beperkt mogelijk',
    'Niet alle soorten zijn geschikt om in te vriezen.',
  );
}

(String, String) _dryInfo(Vegetable v) {
  final id = v.id.toLowerCase();
  if (id.contains('tomaat') ||
      id.contains('peper') ||
      id.contains('kruiden') ||
      id.contains('basil') ||
      id.contains('tijm')) {
    return (
      'Ja, drogen kan',
      'Droog op een donkere, goed geventileerde plek.',
    );
  }
  return (
    'Meestal niet nodig',
    'Vers oogsten en direct gebruiken is vaak beter.',
  );
}

(String, String) _seedSaveInfo(Vegetable v) {
  final id = v.id.toLowerCase();
  if (id.contains('tomaat') ||
      id.contains('boon') ||
      id.contains('erwt') ||
      id.contains('sla') ||
      isMoestuinBloomCrop(v)) {
    return (
      'Ja, zaden kunnen worden geoogst',
      'Bewaar droog en koel voor volgend seizoen.',
    );
  }
  return (
    'Beperkt of hybride',
    'Bij F1-hybriden zijn zaden vaak niet geschikt om te bewaren.',
  );
}

List<HarvestListItem> _harvestProblems(Vegetable v) {
  if (cropFruitsForHarvest(v.id)) {
    return const [
      HarvestListItem('Te kleine vruchten', marker: HarvestListMarker.warning),
      HarvestListItem('Vruchten barsten', marker: HarvestListMarker.warning),
      HarvestListItem('Rotte plekken', marker: HarvestListMarker.warning),
      HarvestListItem('Te vroeg rijpen', marker: HarvestListMarker.warning),
    ];
  }
  return const [
    HarvestListItem('Te kleine oogst', marker: HarvestListMarker.warning),
    HarvestListItem('Doorschieten', marker: HarvestListMarker.warning),
    HarvestListItem('Rotte plekken', marker: HarvestListMarker.warning),
    HarvestListItem('Te laat geoogst', marker: HarvestListMarker.warning),
  ];
}

List<HarvestListItem> _perfectHarvestChecklist() {
  return const [
    HarvestListItem('Juiste kleur', marker: HarvestListMarker.check),
    HarvestListItem('Juiste grootte', marker: HarvestListMarker.check),
    HarvestListItem('Goede stevigheid', marker: HarvestListMarker.check),
    HarvestListItem('Vol en gezond uiterlijk', marker: HarvestListMarker.check),
  ];
}

Set<String> _ediblePartsFor(Vegetable v) {
  if (isOrnamentalOnlyMoestuinCrop(v)) return {};
  final parts = cropEdiblePartKeysFor(v.id);
  if (isEdibleMoestuinBloomCrop(v)) {
    parts.addAll({'flower', 'leaf'});
  }
  return parts;
}

List<HarvestOption> _ediblePartOptions(Set<String> active) {
  return [
    HarvestOption(
      label: 'Vruchten',
      illustration: PlantHarvestIllustration.edibleFruit,
      highlighted: active.contains('fruit'),
    ),
    HarvestOption(
      label: 'Bladeren',
      illustration: PlantHarvestIllustration.edibleLeaf,
      highlighted: active.contains('leaf'),
    ),
    HarvestOption(
      label: 'Bloemen',
      illustration: PlantHarvestIllustration.edibleFlower,
      highlighted: active.contains('flower'),
    ),
    HarvestOption(
      label: 'Wortels',
      illustration: PlantHarvestIllustration.edibleRoot,
      highlighted: active.contains('root'),
    ),
    HarvestOption(
      label: 'Scheuten',
      illustration: PlantHarvestIllustration.edibleShoot,
      highlighted: active.contains('shoot'),
    ),
    HarvestOption(
      label: 'Zaden',
      illustration: PlantHarvestIllustration.edibleSeed,
      highlighted: active.contains('seed'),
    ),
  ];
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
  if (months.isEmpty) return 'In het groeiseizoen.';
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
  return 'Oogst ${parts.join(', ')}.';
}

PlantHarvestGuide _buildHarvestGuide(Vegetable v) {
  final companion = moestuinCompanionInfoForVegetable(v);
  final harvestMonths = _harvestMonths(v, companion);
  final yield = _yieldEstimates(v);
  final freeze = _freezeInfo(v);
  final dry = _dryInfo(v);
  final seeds = _seedSaveInfo(v);
  final edible = _ediblePartsFor(v);
  final isFruit = cropFruitsForHarvest(v.id);

  return PlantHarvestGuide(
    rows: [
      PlantHarvestRow(
        kind: PlantHarvestRowKind.harvestPeriod,
        sections: [
          PlantHarvestSection(
            title: 'Oogstperiode',
            subtitle:
                'Wanneer kun je oogsten? Bekijk in welke maanden de plant klaar is om te oogsten.',
            summary: _monthRangeNl(harvestMonths),
            harvestMonths: harvestMonths,
            illustration: PlantHarvestIllustration.periodBasket,
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.columns2,
        sections: [
          PlantHarvestSection(
            title: 'Tijd tot oogst',
            subtitle:
                'Hoe lang duurt het vanaf zaaien of uitplanten tot de eerste oogst?',
            summary: _timeToHarvest(v),
            showCalendarClock: true,
          ),
          PlantHarvestSection(
            title: 'Oogstfrequentie',
            subtitle: isFruit
                ? 'Hoe vaak kun je oogsten? Eénmalig of regelmatig voor nieuwe vruchten?'
                : 'Hoe vaak kun je oogsten? Eénmalig of doorlopend?',
            summary: _harvestFrequency(v),
            illustration: PlantHarvestIllustration.frequencyCalendar,
            illustrationSize: HarvestIllustrationSize.compact,
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.split,
        sections: [
          PlantHarvestSection(
            title: 'Oogstrijp herkennen',
            subtitle: isFruit
                ? 'Hoe weet je of de plant klaar is om te oogsten? Leer de tekenen van rijpe vruchten herkennen.'
                : 'Hoe weet je of de plant klaar is om te oogsten? Herken het juiste oogstmoment.',
            illustration: PlantHarvestIllustration.ripeTomato,
            checklist: _ripenessChecklist(v),
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.iconGrid,
        sections: [
          PlantHarvestSection(
            title: 'Hoe oogsten',
            subtitle: isFruit
                ? 'Wat is de beste manier om te oogsten zonder de plant of vruchten te beschadigen?'
                : 'Wat is de beste manier om te oogsten zonder de plant te beschadigen?',
            options: _harvestMethods(v),
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.badgeColumns2,
        sections: [
          PlantHarvestSection(
            title: 'Opbrengst per plant',
            subtitle: 'Wat kun je ongeveer verwachten per plant?',
            badge: yield.$1,
            illustration: PlantHarvestIllustration.yieldCrate,
          ),
          PlantHarvestSection(
            title: 'Opbrengst per m²',
            subtitle: 'Wat kun je ongeveer verwachten per vierkante meter?',
            badge: yield.$2,
            illustration: PlantHarvestIllustration.yieldCrate,
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.checklist,
        sections: [
          PlantHarvestSection(
            title: 'Oogst stimuleren',
            subtitle: 'Wat helpt voor een betere en rijkere oogst?',
            checklist: _stimulateChecklist(),
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.statusList,
        sections: [
          PlantHarvestSection(
            title: 'Doorgroeien na oogst',
            subtitle:
                'Wat gebeurt er na de oogst? Komt er nog een nieuwe oogst?',
            statusItems: _continueGrowthItems(v),
            illustration: PlantHarvestIllustration.continueFlower,
            illustrationSize: HarvestIllustrationSize.icon,
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.iconGrid,
        sections: [
          PlantHarvestSection(
            title: 'Bewaren',
            subtitle:
                'Hoe bewaar je de oogst het beste en hoelang blijft het goed?',
            options: _storageOptions(),
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.yesNoColumns2,
        sections: [
          PlantHarvestSection(
            title: 'Invriezen',
            subtitle: isFruit
                ? 'Kan deze groente of vrucht worden ingevroren? Hoe bereid je het voor?'
                : 'Kan dit gewas worden ingevroren? Hoe bereid je het voor?',
            yesNoAnswer: freeze.$1,
            summary: freeze.$2,
            illustration: PlantHarvestIllustration.freezeSnowflake,
          ),
          PlantHarvestSection(
            title: 'Drogen',
            subtitle: isFruit
                ? 'Kan deze groente of vrucht gedroogd worden? Ideaal voor kruiden en sommige groenten.'
                : 'Kan dit gewas gedroogd worden? Ideaal voor kruiden en sommige groenten.',
            yesNoAnswer: dry.$1,
            summary: dry.$2,
            illustration: PlantHarvestIllustration.drySun,
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.split,
        sections: [
          PlantHarvestSection(
            title: 'Zaden bewaren',
            subtitle:
                'Kan je zelf zaden oogsten en bewaren voor volgend seizoen?',
            yesNoAnswer: seeds.$1,
            summary: seeds.$2,
            illustration: PlantHarvestIllustration.seedPacket,
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.problemsPerfect,
        sections: [
          PlantHarvestSection(
            title: 'Tekenen van perfecte oogst',
            subtitle: 'Hoe herken je het perfecte moment om te oogsten?',
            checklist: _perfectHarvestChecklist(),
            illustration: PlantHarvestIllustration.perfectTomato,
            illustrationSize: HarvestIllustrationSize.compact,
          ),
          PlantHarvestSection(
            title: 'Oogstproblemen',
            subtitle:
                'Veelvoorkomende problemen tijdens de oogst en hoe je ze voorkomt.',
            problems: _harvestProblems(v),
          ),
        ],
      ),
      PlantHarvestRow(
        kind: PlantHarvestRowKind.edibleGrid,
        sections: [
          PlantHarvestSection(
            title: 'Eetbare delen',
            subtitle: 'Welke delen van deze plant kun je eten?',
            edibleParts: _ediblePartOptions(edible),
          ),
        ],
      ),
    ],
  );
}
