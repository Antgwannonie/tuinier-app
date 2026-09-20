import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'flower_card_summaries.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_search_filters.dart';
import 'plant_section_details.dart';

enum PlantWaterIllustration {
  wateringCan,
  germinationSpray,
  growthStages,
  floweringStages,
  fruitingStages,
  tooLittleWater,
  tooMuchWater,
  waterQuality,
  potWatering,
  greenhouseWater,
}

enum WaterIllustrationSize { normal, compact, inline }

enum WaterNeedLevel { low, medium, high }

enum WaterListMarker { check, drop, warning }

class WaterListItem {
  const WaterListItem(
    this.text, {
    this.marker = WaterListMarker.check,
  });

  final String text;
  final WaterListMarker marker;
}

class WaterSensitivityCard {
  const WaterSensitivityCard({
    required this.label,
    required this.filledDrops,
    required this.totalDrops,
    required this.caption,
  });

  final String label;
  final int filledDrops;
  final int totalDrops;
  final String caption;
}

class WaterQualityOption {
  const WaterQualityOption({
    required this.label,
    required this.tag,
    this.highlighted = false,
  });

  final String label;
  final String tag;
  final bool highlighted;
}

class WaterInfoTip {
  const WaterInfoTip({required this.body});

  final String body;
}

class PlantWaterSection {
  const PlantWaterSection({
    this.title = '',
    this.subtitle,
    this.summary,
    this.items,
    this.illustration,
    this.illustrationSize = WaterIllustrationSize.normal,
    this.infoTip,
    this.waterNeed,
    this.sensitivity,
    this.qualityOptions,
    this.illustrationFirst = false,
    this.details = const [],
  });

  final String title;
  final String? subtitle;
  final String? summary;
  final List<WaterListItem>? items;
  final PlantWaterIllustration? illustration;
  final WaterIllustrationSize illustrationSize;
  final WaterInfoTip? infoTip;
  final WaterNeedLevel? waterNeed;
  final WaterSensitivityCard? sensitivity;
  final List<WaterQualityOption>? qualityOptions;
  final bool illustrationFirst;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage =>
      title.isNotEmpty && details.isNotEmpty;
}

enum PlantWaterRowKind {
  waterNeed,
  split,
  columns2,
  waterQuality,
  alert,
}

class PlantWaterRow {
  const PlantWaterRow({
    required this.kind,
    required this.sections,
    this.alert,
  });

  final PlantWaterRowKind kind;
  final List<PlantWaterSection> sections;
  final PlantWaterAlert? alert;
}

class PlantWaterAlert {
  const PlantWaterAlert({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class PlantWaterGuide {
  const PlantWaterGuide({required this.rows});

  final List<PlantWaterRow> rows;
}

PlantWaterGuide waterGuideForVegetable(Vegetable vegetable) {
  final built = _buildWaterGuide(vegetable);
  return PlantWaterGuide(
    rows: [
      for (final row in built.rows)
        PlantWaterRow(
          kind: row.kind,
          alert: row.alert,
          sections: [
            for (final s in row.sections)
              PlantWaterSection(
                title: s.title,
                subtitle: s.subtitle,
                summary: s.title.isEmpty
                    ? s.summary
                    : (isFlowerGuidePlant(vegetable.id)
                        ? flowerCardSummaryFor(
                            tab: 'water',
                            title: s.title,
                            vegetable: vegetable,
                          )
                        : cropCardSummaryFor(
                            tab: 'water',
                            title: s.title,
                            vegetable: vegetable,
                          )),
                items: s.items,
                illustration: s.illustration,
                illustrationSize: s.illustrationSize,
                infoTip: s.infoTip,
                waterNeed: s.waterNeed,
                sensitivity: s.sensitivity,
                qualityOptions: s.qualityOptions,
                illustrationFirst: s.illustrationFirst,
                details: s.title.isEmpty
                    ? const <PlantGuideDetailBlock>[]
                    : sectionDetailsFor(
                        tab: 'water',
                        title: s.title,
                        vegetable: vegetable,
                      ),
              ),
          ],
        ),
    ],
  );
}

WaterNeedLevel _waterNeedLevel(Vegetable v) {
  final blob = '${v.water} ${v.care}'.toLowerCase();
  if (blob.contains('zeer veel') ||
      blob.contains('veel water') ||
      blob.contains('regelmatig vocht') ||
      blob.contains('gelijkmatig vocht') ||
      blob.contains('niet laten uitdrogen')) {
    return WaterNeedLevel.high;
  }
  if (blob.contains('droogte') ||
      blob.contains('weinig water') ||
      blob.contains('droog') && blob.contains('tolerant')) {
    return WaterNeedLevel.low;
  }
  return WaterNeedLevel.medium;
}

bool _isFruitCrop(Vegetable v) => cropFruitsForHarvest(v.id);

(int drought, int wet) _sensitivityDrops(Vegetable v) {
  final blob = '${v.water} ${v.commonIssues} ${v.care}'.toLowerCase();
  final drought = blob.contains('droogte') || blob.contains('uitdrogen')
      ? 2
      : blob.contains('veel water') || blob.contains('gelijkmatig')
          ? 1
          : 2;
  final wet = blob.contains('rot') ||
          blob.contains('te nat') ||
          blob.contains('doorzakt')
      ? 1
      : 2;
  return (drought, wet);
}

PlantWaterGuide _buildWaterGuide(Vegetable v) {
  final need = _waterNeedLevel(v);
  final waterText = v.water.trim();
  final (droughtDrops, wetDrops) = _sensitivityDrops(v);
  final fruitCrop = _isFruitCrop(v);
  final isFlower = isFlowerGuidePlant(v.id);
  String? flowerSum(String title) => isFlower
      ? flowerCardSummaryFor(tab: 'water', title: title, vegetable: v)
      : null;

  final needSummary = switch (need) {
    WaterNeedLevel.high =>
      waterText.isNotEmpty
          ? waterText
          : 'Hoge waterbehoefte; houd de grond gelijkmatig vochtig.',
    WaterNeedLevel.low =>
      waterText.isNotEmpty
          ? waterText
          : 'Lage tot matige waterbehoefte; laat de grond tussen gietbeurten opdrogen.',
    WaterNeedLevel.medium =>
      waterText.isNotEmpty
          ? waterText
          : 'Matige waterbehoefte; geef water wanneer de bovenlaag droog aanvoelt.',
  };

  return PlantWaterGuide(
    rows: [
      PlantWaterRow(
        kind: PlantWaterRowKind.waterNeed,
        sections: [
          PlantWaterSection(
            title: 'Waterbehoefte',
            subtitle: 'Hoeveel water heeft deze plant nodig?',
            summary: flowerSum('Waterbehoefte') ?? needSummary,
            waterNeed: need,
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.split,
        sections: [
          PlantWaterSection(
            title: 'Water geven',
            subtitle: 'Hoe en wanneer geef je water?',
            summary: flowerSum('Water geven') ??
                'Geef ’s ochtends bij de voet, diep en minder vaak. '
                    'Nat blad ’s avonds verhoogt schimmelrisico in het NL-klimaat.',
            items: const [
              WaterListItem('Geef water in de ochtend of avond.'),
              WaterListItem('Water bij de wortels, niet over het blad.'),
              WaterListItem('Geef liever grondig dan een beetje elke dag.'),
              WaterListItem('Mulch helpt vocht vasthouden in de zomer.'),
            ],
            illustration: PlantWaterIllustration.wateringCan,
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.split,
        sections: [
          PlantWaterSection(
            title: 'Tijdens kieming',
            subtitle: 'Water bij het zaaien en opkweken.',
            summary: flowerSum('Tijdens kieming') ??
                'Houd de grond licht vochtig tot de zaailingen opkomen. '
                    'Te nat veroorzaakt schimmels; te droog stopt de kieming.',
            illustration: PlantWaterIllustration.germinationSpray,
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.split,
        sections: [
          PlantWaterSection(
            title: 'Tijdens groei',
            subtitle: 'Water tijdens de groeifase.',
            summary: flowerSum('Tijdens groei') ??
                (need == WaterNeedLevel.high
                    ? 'Geef regelmatig water zodra de grond opdroogt. '
                        'Gelijkmatig vocht bevordert sterke groei.'
                    : 'Geef water wanneer de bovenlaag droog aanvoelt. '
                        'Pas de frequentie aan bij warm of regenachtig weer.'),
            illustration: PlantWaterIllustration.growthStages,
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.split,
        sections: [
          PlantWaterSection(
            title: 'Tijdens bloei',
            subtitle: 'Water tijdens de bloeiperiode.',
            summary: flowerSum('Tijdens bloei') ??
                (fruitCrop
                    ? 'Meer water tijdens bloei ondersteunt gezonde bloemen en vruchtzetting.'
                    : 'Houd de grond gelijkmatig vochtig tijdens bloei; droge stress remt groei en oogst.'),
            illustration: PlantWaterIllustration.floweringStages,
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.split,
        sections: [
          PlantWaterSection(
            title: isFlower ? 'Na de bloei' : cropLateStageLabel(v.id),
            subtitle: isFlower
                ? 'Water na de bloei en tijdens zaadvorming.'
                : fruitCrop
                    ? 'Water wanneer vruchten zich ontwikkelen.'
                    : 'Water in de late groeifase.',
            summary: flowerSum('Na de bloei') ??
                (fruitCrop
                    ? 'Voldoende water is cruciaal voor vruchtgrootte en smaak. '
                        'Onregelmatig water kan misvorming of barsten veroorzaken.'
                    : '${cropLateStageWaterHow(v.id)} '
                        'Pas de geeffrequentie aan op het NL-weer.'),
            illustration: PlantWaterIllustration.fruitingStages,
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.columns2,
        sections: [
          PlantWaterSection(
            title: 'Droogtegevoeligheid',
            subtitle: 'Hoe gevoelig is deze plant voor droogte?',
            sensitivity: WaterSensitivityCard(
              label: 'Droogtegevoeligheid',
              filledDrops: droughtDrops,
              totalDrops: 3,
              caption: droughtDrops >= 2
                  ? 'Matig gevoelig'
                  : 'Redelijk tolerant',
            ),
          ),
          PlantWaterSection(
            title: 'Natte grond gevoeligheid',
            subtitle: 'Hoe gevoelig is deze plant voor natte voeten?',
            sensitivity: WaterSensitivityCard(
              label: 'Natte grond',
              filledDrops: wetDrops,
              totalDrops: 3,
              caption: wetDrops <= 1 ? 'Gevoelig' : 'Matig tolerant',
            ),
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.columns2,
        sections: [
          PlantWaterSection(
            title: 'Tekenen van te weinig water',
            subtitle: 'Herken uitdroging op tijd.',
            items: const [
              WaterListItem('Hangende of slapende bladeren.', marker: WaterListMarker.drop),
              WaterListItem('Droge, broze bladranden.', marker: WaterListMarker.drop),
              WaterListItem('Langzame of stilstaande groei.', marker: WaterListMarker.drop),
              WaterListItem('Lichtgekleurde of krullende bladeren.', marker: WaterListMarker.drop),
            ],
            illustration: PlantWaterIllustration.tooLittleWater,
            illustrationSize: WaterIllustrationSize.compact,
          ),
          PlantWaterSection(
            title: 'Tekenen van te veel water',
            subtitle: 'Herken overbewatering op tijd.',
            items: const [
              WaterListItem('Geel wordende bladeren.', marker: WaterListMarker.drop),
              WaterListItem('Slappe stengels ondanks natte grond.', marker: WaterListMarker.drop),
              WaterListItem('Muffe geur uit de potgrond.', marker: WaterListMarker.drop),
              WaterListItem('Wortelrot of algen op het oppervlak.', marker: WaterListMarker.drop),
            ],
            illustration: PlantWaterIllustration.tooMuchWater,
            illustrationSize: WaterIllustrationSize.compact,
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.waterQuality,
        sections: [
          PlantWaterSection(
            title: 'Waterkwaliteit',
            subtitle: 'Wat is het beste water?',
            qualityOptions: const [
              WaterQualityOption(
                label: 'Regenwater',
                tag: 'Beste keuze',
                highlighted: true,
              ),
              WaterQualityOption(label: 'Sloot- of putwater', tag: 'Goed'),
              WaterQualityOption(label: 'Kraanwater', tag: 'Geschikt'),
            ],
            illustration: PlantWaterIllustration.waterQuality,
            infoTip: WaterInfoTip(
              body: v.soilAndFood.toLowerCase().contains('zuur') ||
                      v.soilAndFood.toLowerCase().contains('kalk')
                  ? 'Let op kalkgevoeligheid: regenwater is vaak zachter dan kraanwater.'
                  : 'Regenwater is zacht en geschikt voor de meeste moestuiniers.',
            ),
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.columns2,
        sections: [
          PlantWaterSection(
            title: 'Water in potten',
            subtitle: 'Extra aandacht bij potteelt.',
            summary:
                'Potten drogen sneller uit dan volle grond. '
                'Controleer dagelijks en geef water tot het uit de drainage loopt.',
            illustration: PlantWaterIllustration.potWatering,
            illustrationSize: WaterIllustrationSize.compact,
          ),
          PlantWaterSection(
            title: 'Water in kas',
            subtitle: 'Water in kas of tunnel.',
            summary:
                'In de kas verdampt water sneller. '
                'Ventileer bij warm weer en houd de grond gelijkmatig vochtig.',
            illustration: PlantWaterIllustration.greenhouseWater,
            illustrationSize: WaterIllustrationSize.compact,
          ),
        ],
      ),
      PlantWaterRow(
        kind: PlantWaterRowKind.alert,
        sections: const [],
        alert: PlantWaterAlert(
          title: 'Tip: water geven',
          body:
              'Houd de grond gelijkmatig vochtig in het groeiseizoen. '
              'Check met je vinger 2–3 cm diep of de grond nog vochtig aanvoelt.',
        ),
      ),
    ],
  );
}
