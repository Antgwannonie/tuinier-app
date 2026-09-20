import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_section_details.dart';

enum PlantCareIllustration {
  dailyMagnify,
  weeklyClipboard,
  maintenanceShears,
  pruningShears,
  topping,
  suckering,
  tying,
  supportTrellis,
  mulch,
  weed,
  heatShade,
  coldCover,
  frostCover,
  windFence,
  rainCloud,
  animalSnail,
  animalBird,
  animalRabbit,
  animalMouse,
  healthyPlant,
  warningLeaf,
  seasonSpring,
  seasonSummer,
  seasonAutumn,
  seasonWinter,
  winterWrap,
  potPlant,
  greenhouse,
}

enum CareIllustrationSize {
  normal,
  compact,
  icon,
}

enum CareListMarker { check, bullet, warning }

class CareListItem {
  const CareListItem(this.text, {this.marker = CareListMarker.bullet});

  final String text;
  final CareListMarker marker;
}

class CareIconOption {
  const CareIconOption({
    required this.label,
    required this.illustration,
  });

  final String label;
  final PlantCareIllustration illustration;
}

class PlantCareSection {
  const PlantCareSection({
    this.title = '',
    this.subtitle,
    this.summary,
    this.checklist,
    this.illustration,
    this.illustrationSize = CareIllustrationSize.compact,
    this.iconOptions,
    this.details = const [],
  });

  final String title;
  final String? subtitle;
  final String? summary;
  final List<CareListItem>? checklist;
  final PlantCareIllustration? illustration;
  final CareIllustrationSize illustrationSize;
  final List<CareIconOption>? iconOptions;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage =>
      title.isNotEmpty && details.isNotEmpty;
}

enum PlantCareRowKind {
  columns2,
  iconGrid,
}

class PlantCareRow {
  const PlantCareRow({
    required this.kind,
    required this.sections,
    this.stackVertically = false,
  });

  final PlantCareRowKind kind;
  final List<PlantCareSection> sections;
  final bool stackVertically;
}

class PlantCareGuide {
  const PlantCareGuide({required this.rows});

  final List<PlantCareRow> rows;
}

PlantCareGuide careGuideForVegetable(Vegetable vegetable) {
  final built = _buildCareGuide(vegetable);
  return PlantCareGuide(
    rows: [
      for (final row in built.rows)
        PlantCareRow(
          kind: row.kind,
          stackVertically: row.stackVertically,
          sections: [
            for (final s in row.sections)
              PlantCareSection(
                title: s.title,
                subtitle: s.subtitle,
                summary: s.title.isEmpty
                    ? s.summary
                    : cropCardSummaryFor(
                        tab: 'care',
                        title: s.title,
                        vegetable: vegetable,
                      ),
                checklist: s.checklist,
                illustration: s.illustration,
                illustrationSize: s.illustrationSize,
                iconOptions: s.iconOptions,
                details: s.title.isEmpty
                    ? const <PlantGuideDetailBlock>[]
                    : sectionDetailsFor(
                        tab: 'care',
                        title: s.title,
                        vegetable: vegetable,
                      ),
              ),
          ],
        ),
    ],
  );
}

bool _needsTopping(Vegetable v) {
  final id = v.id.toLowerCase();
  return id.contains('tomaat') ||
      id.contains('paprika') ||
      id.contains('basil') ||
      id.contains('basilicum');
}

bool _needsSuckering(Vegetable v) => v.id.contains('tomaat');

bool _needsSupport(Vegetable v) {
  final blob = '${v.care} ${v.id}'.toLowerCase();
  return blob.contains('steun') ||
      blob.contains('bind') ||
      blob.contains('tomaat') ||
      blob.contains('bonen') ||
      blob.contains('courgette') ||
      blob.contains('komkommer') ||
      blob.contains('erwt');
}

bool _isPerennial(Vegetable v) {
  final cat = (v.growthCategory ?? '').toLowerCase();
  return cat.contains('meerjarig') || cat.contains('boom');
}

bool _suitsPot(Vegetable v) => v.spacingCm <= 45;

bool _suitsGreenhouse(Vegetable v) {
  final blob =
      '${v.sowingIndoors} ${v.transplant} ${v.care}'.toLowerCase();
  return blob.contains('kas') ||
      blob.contains('tunnel') ||
      blob.contains('glazen');
}

PlantCareGuide _buildCareGuide(Vegetable v) {
  final perennial = _isPerennial(v);
  final toppingNote = _needsTopping(v)
      ? 'Belangrijk bij deze teelt.'
      : 'Meestal niet nodig bij deze soort.';
  final suckerNote = _needsSuckering(v)
      ? (cropFruitsForHarvest(v.id)
          ? 'Verwijder dieven voor betere vruchtrijping.'
          : 'Verwijder dieven voor een sterkere hoofdstengel.')
      : 'Niet van toepassing bij deze teelt.';
  final supportNote = _needsSupport(v)
      ? 'Aanbevolen voor deze plant.'
      : 'Vaak niet nodig bij deze soort.';

  return PlantCareGuide(
    rows: [
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Dagelijkse controle',
            subtitle:
                'Controleer dagelijks of de plant gezond is en goed groeit.',
            checklist: const [
              CareListItem('Bladeren', marker: CareListMarker.bullet),
              CareListItem('Groei', marker: CareListMarker.bullet),
              CareListItem('Schade', marker: CareListMarker.bullet),
              CareListItem('Verkleuring', marker: CareListMarker.bullet),
            ],
            illustration: PlantCareIllustration.dailyMagnify,
          ),
          PlantCareSection(
            title: 'Wekelijkse controle',
            subtitle: 'Controleer wekelijks de belangrijkste punten.',
            checklist: const [
              CareListItem('Water', marker: CareListMarker.bullet),
              CareListItem('Voeding', marker: CareListMarker.bullet),
              CareListItem('Groei', marker: CareListMarker.bullet),
              CareListItem('Plagen', marker: CareListMarker.bullet),
            ],
            illustration: PlantCareIllustration.weeklyClipboard,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Onderhoud',
            subtitle:
                'Houd de plant en omgeving schoon voor gezonde groei.',
            checklist: const [
              CareListItem('Oude bladeren verwijderen',
                  marker: CareListMarker.bullet),
              CareListItem('Onkruid wieden', marker: CareListMarker.bullet),
              CareListItem('Netjes houden', marker: CareListMarker.bullet),
            ],
            illustration: PlantCareIllustration.maintenanceShears,
          ),
          PlantCareSection(
            title: 'Snoeien',
            subtitle: 'Snoei voor sterkere groei en betere luchtcirculatie.',
            checklist: const [
              CareListItem('Wanneer snoeien', marker: CareListMarker.bullet),
              CareListItem('Hoe snoeien', marker: CareListMarker.bullet),
              CareListItem('Waarom snoeien', marker: CareListMarker.bullet),
            ],
            illustration: PlantCareIllustration.pruningShears,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          if (_needsTopping(v))
            PlantCareSection(
              title: 'Toppen',
              subtitle:
                  'Verwijder de groeipunt voor een vollere plant. $toppingNote',
              illustration: PlantCareIllustration.topping,
            ),
          if (_needsSuckering(v))
            PlantCareSection(
              title: 'Dieven',
              subtitle:
                  'Verwijder zijscheuten, vooral bij tomaten. $suckerNote',
              illustration: PlantCareIllustration.suckering,
            ),
          if (!_needsTopping(v) && !_needsSuckering(v))
            PlantCareSection(
              title: 'Snoeien',
              subtitle:
                  'Snoei dood of ziek blad voor betere luchtcirculatie.',
              illustration: PlantCareIllustration.pruningShears,
            ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Opbinden',
            subtitle:
                'Bind de plant voor steun met touw of plantenclips. $supportNote',
            illustration: PlantCareIllustration.tying,
          ),
          PlantCareSection(
            title: 'Ondersteunen',
            subtitle:
                'Geef zware of klimmende planten steun met stokken of netten. $supportNote',
            illustration: PlantCareIllustration.supportTrellis,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Mulchen',
            subtitle: 'Bedek de bodem met organisch materiaal.',
            checklist: const [
              CareListItem('Minder onkruid', marker: CareListMarker.bullet),
              CareListItem('Minder uitdroging', marker: CareListMarker.bullet),
              CareListItem('Betere bodem', marker: CareListMarker.bullet),
            ],
            illustration: PlantCareIllustration.mulch,
          ),
          PlantCareSection(
            title: 'Onkruidbeheer',
            subtitle: 'Houd onkruid onder controle rond je planten.',
            illustration: PlantCareIllustration.weed,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Beschermen tegen hitte',
            subtitle:
                'Geef schaduw en extra water op hete dagen boven 30 °C.',
            illustration: PlantCareIllustration.heatShade,
          ),
          PlantCareSection(
            title: 'Beschermen tegen kou',
            subtitle:
                'Bescherm bij koude temperaturen met vliesdoek of binnen zetten.',
            illustration: PlantCareIllustration.coldCover,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Beschermen tegen vorst',
            subtitle: 'Bescherm bij nachtvorst en strenge kou.',
            illustration: PlantCareIllustration.frostCover,
          ),
          PlantCareSection(
            title: 'Beschermen tegen wind',
            subtitle:
                'Zet een windscherm voor hoge of kwetsbare planten.',
            illustration: PlantCareIllustration.windFence,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Beschermen tegen regen',
            subtitle:
                'Voorkom te veel regen om schimmel en ziekten te vermijden.',
            illustration: PlantCareIllustration.rainCloud,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.iconGrid,
        sections: [
          PlantCareSection(
            title: 'Beschermen tegen dieren',
            subtitle: 'Bescherm tegen ongewenste dieren in de tuin.',
            iconOptions: const [
              CareIconOption(
                label: 'Slakken',
                illustration: PlantCareIllustration.animalSnail,
              ),
              CareIconOption(
                label: 'Vogels',
                illustration: PlantCareIllustration.animalBird,
              ),
              CareIconOption(
                label: 'Konijnen',
                illustration: PlantCareIllustration.animalRabbit,
              ),
              CareIconOption(
                label: 'Muizen',
                illustration: PlantCareIllustration.animalMouse,
              ),
            ],
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Gezonde plant herkennen',
            subtitle: 'Zo herken je een gezonde plant.',
            checklist: const [
              CareListItem('Groene kleur', marker: CareListMarker.check),
              CareListItem('Stevige bladeren', marker: CareListMarker.check),
              CareListItem('Sterke groei', marker: CareListMarker.check),
            ],
            illustration: PlantCareIllustration.healthyPlant,
          ),
          PlantCareSection(
            title: 'Waarschuwingssignalen',
            subtitle: 'Let op deze signalen van problemen.',
            checklist: const [
              CareListItem('Gele bladeren', marker: CareListMarker.warning),
              CareListItem('Slappe bladeren', marker: CareListMarker.warning),
              CareListItem('Vlekken', marker: CareListMarker.warning),
              CareListItem('Gestagneerde groei',
                  marker: CareListMarker.warning),
            ],
            illustration: PlantCareIllustration.warningLeaf,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.iconGrid,
        sections: [
          PlantCareSection(
            title: 'Seizoensverzorging',
            subtitle: 'Pas je verzorging aan per seizoen.',
            iconOptions: const [
              CareIconOption(
                label: 'Lente',
                illustration: PlantCareIllustration.seasonSpring,
              ),
              CareIconOption(
                label: 'Zomer',
                illustration: PlantCareIllustration.seasonSummer,
              ),
              CareIconOption(
                label: 'Herfst',
                illustration: PlantCareIllustration.seasonAutumn,
              ),
              CareIconOption(
                label: 'Winter',
                illustration: PlantCareIllustration.seasonWinter,
              ),
            ],
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Winterbescherming',
            subtitle: perennial
                ? 'Bescherm meerjarige planten in de winter.'
                : 'Eenjarige teelt: ruim op na het seizoen.',
            checklist: perennial
                ? const [
                    CareListItem('Afdekken', marker: CareListMarker.bullet),
                    CareListItem('Inpakken', marker: CareListMarker.bullet),
                    CareListItem('Binnen halen', marker: CareListMarker.bullet),
                  ]
                : const [
                    CareListItem('Opruimen na oogst',
                        marker: CareListMarker.bullet),
                    CareListItem('Compost of groenafval',
                        marker: CareListMarker.bullet),
                  ],
            illustration: PlantCareIllustration.winterWrap,
          ),
          PlantCareSection(
            title: 'Verzorging in pot',
            subtitle: _suitsPot(v)
                ? 'Geschikt voor potteelt op balkon of terras.'
                : 'Mogelijk in grote pot; let op voldoende ruimte.',
            checklist: const [
              CareListItem('Regelmatig water geven',
                  marker: CareListMarker.bullet),
              CareListItem('Bemesten', marker: CareListMarker.bullet),
              CareListItem('Niet laten uitdrogen',
                  marker: CareListMarker.bullet),
            ],
            illustration: PlantCareIllustration.potPlant,
          ),
        ],
      ),
      PlantCareRow(
        kind: PlantCareRowKind.columns2,
        sections: [
          PlantCareSection(
            title: 'Verzorging in kas',
            subtitle: _suitsGreenhouse(v)
                ? 'Ideaal in kas of tunnel voor deze teelt.'
                : 'Kan in kas; let op ventilatie en vocht.',
            checklist: const [
              CareListItem('Ventileren', marker: CareListMarker.bullet),
              CareListItem('Luchtvochtigheid', marker: CareListMarker.bullet),
              CareListItem('Temperatuur bewaken',
                  marker: CareListMarker.bullet),
            ],
            illustration: PlantCareIllustration.greenhouse,
          ),
        ],
      ),
    ],
  );
}
