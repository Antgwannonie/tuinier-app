import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'flower_card_summaries.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_search_filters.dart';
import 'plant_section_details.dart';

enum PlantNutritionIllustration {
  soilSand,
  soilLoam,
  soilClay,
  soilHumus,
  compostBin,
  fertCompost,
  fertWorm,
  fertCow,
  nitrogenLeaves,
  phosphorusRoots,
  potassiumFruits,
  plantingFeed,
  growthFeed,
  floweringFeed,
  fruitingFeed,
  deficiency,
  overfertilization,
  improveCompost,
  improveCoverCrop,
  improveMulch,
  improveOrganic,
  aiSchedule,
}

enum NutritionIllustrationSize { normal, compact, small }

enum NutritionNeedLevel { low, medium, high }

enum NutritionListMarker { check, bullet, warning }

class NutritionListItem {
  const NutritionListItem(
    this.text, {
    this.marker = NutritionListMarker.bullet,
  });

  final String text;
  final NutritionListMarker marker;
}

class NutritionSoilCard {
  const NutritionSoilCard({
    required this.label,
    required this.status,
    required this.illustration,
    this.highlighted = false,
  });

  final String label;
  final String status;
  final PlantNutritionIllustration illustration;
  final bool highlighted;
}

class NutritionFertilizerCard {
  const NutritionFertilizerCard({
    required this.rank,
    required this.label,
    required this.status,
    required this.illustration,
  });

  final int rank;
  final String label;
  final String status;
  final PlantNutritionIllustration illustration;
}

class NutritionNutrientRow {
  const NutritionNutrientRow({
    required this.letter,
    required this.name,
    required this.summary,
    required this.color,
    required this.illustration,
  });

  final String letter;
  final String name;
  final String summary;
  final int color;
  final PlantNutritionIllustration illustration;
}

class NutritionImproveCard {
  const NutritionImproveCard({
    required this.label,
    required this.illustration,
  });

  final String label;
  final PlantNutritionIllustration illustration;
}

class NutritionPhRange {
  const NutritionPhRange({
    required this.idealMin,
    required this.idealMax,
    this.min = 4.5,
    this.max = 8.5,
  });

  final double min;
  final double max;
  final double idealMin;
  final double idealMax;
}

class NutritionInfoTip {
  const NutritionInfoTip({required this.body});

  final String body;
}

class NutritionTimelineStage {
  const NutritionTimelineStage({
    required this.label,
    required this.detail,
    required this.icon,
  });

  final String label;
  final String detail;
  final NutritionTimelineIcon icon;
}

enum NutritionTimelineIcon { plant, grow, bloom, fruit }

class PlantNutritionSection {
  const PlantNutritionSection({
    this.title = '',
    this.subtitle,
    this.summary,
    this.items,
    this.illustration,
    this.illustrationSize = NutritionIllustrationSize.normal,
    this.infoTip,
    this.nutritionNeed,
    this.soilCards,
    this.phRange,
    this.fertilizerCards,
    this.nutrients,
    this.improveCards,
    this.timeline,
    this.recommended = false,
    this.details = const [],
  });

  final String title;
  final String? subtitle;
  final String? summary;
  final List<NutritionListItem>? items;
  final PlantNutritionIllustration? illustration;
  final NutritionIllustrationSize illustrationSize;
  final NutritionInfoTip? infoTip;
  final NutritionNeedLevel? nutritionNeed;
  final List<NutritionSoilCard>? soilCards;
  final NutritionPhRange? phRange;
  final List<NutritionFertilizerCard>? fertilizerCards;
  final List<NutritionNutrientRow>? nutrients;
  final List<NutritionImproveCard>? improveCards;
  final List<NutritionTimelineStage>? timeline;
  final bool recommended;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage =>
      title.isNotEmpty && details.isNotEmpty;
}

enum PlantNutritionRowKind {
  nutritionNeed,
  soilBest,
  columns2,
  split,
  fertilizerBest,
  nutrients,
  timeline,
  alert,
}

class PlantNutritionRow {
  const PlantNutritionRow({
    required this.kind,
    required this.sections,
    this.alert,
    this.stackVertically = false,
  });

  final PlantNutritionRowKind kind;
  final List<PlantNutritionSection> sections;
  final PlantNutritionAlert? alert;
  final bool stackVertically;
}

class PlantNutritionAlert {
  const PlantNutritionAlert({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class PlantNutritionGuide {
  const PlantNutritionGuide({required this.rows});

  final List<PlantNutritionRow> rows;
}

PlantNutritionGuide nutritionGuideForVegetable(Vegetable vegetable) {
  final built = _buildNutritionGuide(vegetable);
  return PlantNutritionGuide(
    rows: [
      for (final row in built.rows)
        PlantNutritionRow(
          kind: row.kind,
          alert: row.alert,
          stackVertically: row.stackVertically,
          sections: [
            for (final s in row.sections)
              PlantNutritionSection(
                title: s.title,
                subtitle: s.subtitle,
                summary: s.title.isEmpty
                    ? s.summary
                    : (isFlowerGuidePlant(vegetable.id)
                        ? flowerCardSummaryFor(
                            tab: 'nutrition',
                            title: s.title,
                            vegetable: vegetable,
                          )
                        : cropCardSummaryFor(
                            tab: 'nutrition',
                            title: s.title,
                            vegetable: vegetable,
                          )),
                items: s.items,
                illustration: s.illustration,
                illustrationSize: s.illustrationSize,
                infoTip: s.infoTip,
                nutritionNeed: s.nutritionNeed,
                soilCards: s.soilCards,
                phRange: s.phRange,
                fertilizerCards: s.fertilizerCards,
                nutrients: s.nutrients,
                improveCards: s.improveCards,
                timeline: s.timeline,
                recommended: s.recommended,
                details: s.title.isEmpty
                    ? const <PlantGuideDetailBlock>[]
                    : sectionDetailsFor(
                        tab: 'nutrition',
                        title: s.title,
                        vegetable: vegetable,
                      ),
              ),
          ],
        ),
    ],
  );
}

NutritionNeedLevel _nutritionNeedLevel(Vegetable v) {
  final blob = '${v.soilAndFood} ${v.care}'.toLowerCase();
  if (blob.contains('zeer rijk') ||
      blob.contains('veel voeding') ||
      blob.contains('rijk') && blob.contains('compost')) {
    return NutritionNeedLevel.high;
  }
  if (blob.contains('mager') ||
      blob.contains('weinig voeding') ||
      blob.contains('lichte grond') && !blob.contains('rijk')) {
    return NutritionNeedLevel.low;
  }
  return NutritionNeedLevel.medium;
}

NutritionPhRange _phRangeFor(Vegetable v) {
  final blob = v.soilAndFood.toLowerCase();
  if (blob.contains('zuur') || blob.contains('ph 5')) {
    return const NutritionPhRange(idealMin: 5.5, idealMax: 6.5);
  }
  if (blob.contains('basisch') || blob.contains('kalk')) {
    return const NutritionPhRange(idealMin: 6.5, idealMax: 7.5);
  }
  return const NutritionPhRange(idealMin: 6.0, idealMax: 7.0);
}

bool _isFruitCrop(Vegetable v) => cropFruitsForHarvest(v.id);

bool _isRootCrop(Vegetable v) {
  final blob = '${v.id} ${v.family} ${v.harvest}'.toLowerCase();
  return blob.contains('wortel') ||
      blob.contains('pastinaak') ||
      blob.contains('radijs') ||
      blob.contains('knol') ||
      blob.contains('biet');
}

({NutritionSoilCard card, String why}) _bestSoilFor(Vegetable v) {
  final blob = v.soilAndFood.toLowerCase();
  final rootCrop = _isRootCrop(v);

  if (blob.contains('zand') ||
      (blob.contains('licht') && blob.contains('doorlat')) ||
      (blob.contains('licht') && blob.contains('drainer')) ||
      (rootCrop && !blob.contains('humus') && !blob.contains('rijk'))) {
    return (
      card: const NutritionSoilCard(
        label: 'Zandgrond',
        status: 'Beste keuze',
        illustration: PlantNutritionIllustration.soilSand,
        highlighted: true,
      ),
      why: rootCrop
          ? 'Losse zandgrond laat wortels recht groeien en voorkomt rotten — voor een betere en schonere oogst bij wortelgewassen.'
          : 'Lichte, goed doorlatende zandgrond voorkomt natte voeten en geeft wortels zuurstof voor een gezonde oogst.',
    );
  }

  if (blob.contains('humus') ||
      blob.contains('compost') ||
      blob.contains('zeer rijk') ||
      blob.contains('composthoop') ||
      blob.contains('organisch')) {
    return (
      card: const NutritionSoilCard(
        label: 'Humusrijke grond',
        status: 'Beste keuze',
        illustration: PlantNutritionIllustration.soilHumus,
        highlighted: true,
      ),
      why: 'Humusrijke bodem levert voeding en vochtbuffer — ideaal voor een rijke en constante oogst.',
    );
  }

  if (blob.contains('vochtig') ||
      blob.contains('vocht houd') ||
      blob.contains('klei')) {
    return (
      card: const NutritionSoilCard(
        label: 'Kleigrond',
        status: 'Beste keuze',
        illustration: PlantNutritionIllustration.soilClay,
        highlighted: true,
      ),
      why: 'Kleigrond houdt vocht en voedingsstoffen goed vast — belangrijk voor stabiele groei en goede opbrengst.',
    );
  }

  return (
    card: const NutritionSoilCard(
      label: 'Leemgrond',
      status: 'Beste keuze',
      illustration: PlantNutritionIllustration.soilLoam,
      highlighted: true,
    ),
    why: 'Leemgrond combineert drainage met vochtvasthouding — de meest veelzijdige keuze voor een betrouwbare moestuinoogst.',
  );
}

({NutritionFertilizerCard card, String why}) _bestFertilizerFor(Vegetable v) {
  final blob = '${v.soilAndFood} ${v.care}'.toLowerCase();
  final need = _nutritionNeedLevel(v);
  final fruitCrop = _isFruitCrop(v);

  if (need == NutritionNeedLevel.low ||
      blob.contains('lichte bemesting') ||
      blob.contains('niet te veel stikstof') ||
      blob.contains('niet te veel bemest') ||
      blob.contains('weinig voeding')) {
    return (
      card: const NutritionFertilizerCard(
        rank: 1,
        label: 'Wormenmest',
        status: 'Beste keuze',
        illustration: PlantNutritionIllustration.fertWorm,
      ),
      why: 'Milde, direct beschikbare voeding zonder verbranding — past bij de lagere behoefte van deze plant.',
    );
  }

  if (need == NutritionNeedLevel.high &&
      (fruitCrop ||
          blob.contains('kalium') ||
          blob.contains('stabiel') ||
          blob.contains('veel voeding'))) {
    return (
      card: const NutritionFertilizerCard(
        rank: 1,
        label: 'Koeienmestkorrels',
        status: 'Beste keuze',
        illustration: PlantNutritionIllustration.fertCow,
      ),
      why: 'Langzaam vrijgevende organische mest geeft voeding gedurende het hele groeiseizoen — ideaal voor zware eters en vruchtgewassen.',
    );
  }

  return (
    card: const NutritionFertilizerCard(
      rank: 1,
      label: 'Compost',
      status: 'Beste keuze',
      illustration: PlantNutritionIllustration.fertCompost,
    ),
    why: 'Compost verbetert de bodemstructuur en levert gebalanceerde voeding — de veiligste basis voor de meeste moestuinplanten.',
  );
}

PlantNutritionGuide _buildNutritionGuide(Vegetable v) {
  final need = _nutritionNeedLevel(v);
  final ph = _phRangeFor(v);
  final soilText = v.soilAndFood.trim();
  final fruitCrop = _isFruitCrop(v);
  final isFlower = isFlowerGuidePlant(v.id);
  final bestSoil = _bestSoilFor(v);
  final bestFert = _bestFertilizerFor(v);
  String? flowerSum(String title) => isFlower
      ? flowerCardSummaryFor(tab: 'nutrition', title: title, vegetable: v)
      : null;

  final needSummary = switch (need) {
    NutritionNeedLevel.high =>
      soilText.isNotEmpty
          ? soilText
          : 'Hoge voedingsbehoefte; geef regelmatig organische mest.',
    NutritionNeedLevel.low =>
      soilText.isNotEmpty
          ? soilText
          : 'Lage tot matige voedingsbehoefte; niet te veel bemesten.',
    NutritionNeedLevel.medium =>
      soilText.isNotEmpty
          ? soilText
          : 'Matige voedingsbehoefte; compost bij het planten is vaak voldoende.',
  };

  return PlantNutritionGuide(
    rows: [
      PlantNutritionRow(
        kind: PlantNutritionRowKind.nutritionNeed,
        sections: [
          PlantNutritionSection(
            title: 'Voedingsbehoefte',
            subtitle: 'Hoeveel voeding heeft deze plant nodig?',
            summary: flowerSum('Voedingsbehoefte') ?? needSummary,
            nutritionNeed: need,
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.soilBest,
        sections: [
          PlantNutritionSection(
            title: 'Bodemsoort',
            subtitle: 'Deze plant groeit het beste in:',
            summary: flowerSum('Bodemsoort') ?? bestSoil.why,
            soilCards: [bestSoil.card],
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.columns2,
        sections: [
          PlantNutritionSection(
            title: 'pH-waarde',
            subtitle: 'Ideale zuurgraad van de bodem.',
            phRange: ph,
            summary: flowerSum('pH-waarde') ??
                'Ideaal: ${ph.idealMin.toStringAsFixed(1)} – ${ph.idealMax.toStringAsFixed(1)}',
          ),
          PlantNutritionSection(
            title: 'Compost',
            subtitle: 'Organische verbetering van de bodem.',
            summary: flowerSum('Compost') ??
                'Werk compost door de bovenlaag voor betere structuur en voeding.',
            illustration: PlantNutritionIllustration.compostBin,
            illustrationSize: NutritionIllustrationSize.compact,
            recommended: true,
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.fertilizerBest,
        sections: [
          PlantNutritionSection(
            title: 'Beste mest voor deze plant',
            subtitle: 'Aanbevolen mest op basis van de behoeften van deze plant.',
            summary: flowerSum('Beste mest voor deze plant') ?? bestFert.why,
            fertilizerCards: [bestFert.card],
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.nutrients,
        sections: [
          PlantNutritionSection(
            title: 'Belangrijkste voedingsstoffen',
            subtitle: 'N · P · K in het kort.',
            nutrients: [
              const NutritionNutrientRow(
                letter: 'N',
                name: 'Stikstof',
                summary: 'Bevordert blad- en stengelgroei.',
                color: 0xFF22C55E,
                illustration: PlantNutritionIllustration.nitrogenLeaves,
              ),
              const NutritionNutrientRow(
                letter: 'P',
                name: 'Fosfor',
                summary: 'Ondersteunt wortels en bloei.',
                color: 0xFF3B82F6,
                illustration: PlantNutritionIllustration.phosphorusRoots,
              ),
              NutritionNutrientRow(
                letter: 'K',
                name: 'Kalium',
                summary: isFlower
                    ? 'Versterkt bloei, stevigheid en winterhardheid.'
                    : fruitCrop
                        ? 'Versterkt vruchten en weerstand.'
                        : 'Versterkt weerstand en stevigheid.',
                color: 0xFFF59E0B,
                illustration: PlantNutritionIllustration.potassiumFruits,
              ),
            ],
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.split,
        sections: [
          PlantNutritionSection(
            title: 'Bemesten bij planten',
            subtitle: 'Start met voeding in het plantgat.',
            summary: flowerSum('Bemesten bij planten') ??
                'Meng compost of organische mest door het plantgat voor een sterke start.',
            illustration: PlantNutritionIllustration.plantingFeed,
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.columns2,
        sections: [
          PlantNutritionSection(
            title: 'Bemesten tijdens groei',
            subtitle: 'Voeding in de groeifase.',
            summary: flowerSum('Bemesten tijdens groei') ??
                'Geef elke 2 – 4 weken een lichte gift organische mest of vloeibare voeding.',
            illustration: PlantNutritionIllustration.growthFeed,
            illustrationSize: NutritionIllustrationSize.compact,
          ),
          PlantNutritionSection(
            title: 'Bemesten tijdens bloei',
            subtitle: 'Extra fosfor ondersteunt bloei.',
            summary: flowerSum('Bemesten tijdens bloei') ??
                'Kies een mest met meer fosfor (P) tijdens de bloeiperiode.',
            illustration: PlantNutritionIllustration.floweringFeed,
            illustrationSize: NutritionIllustrationSize.compact,
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.split,
        sections: [
          PlantNutritionSection(
            title: isFlower
                ? 'Bemesten na de bloei'
                : 'Bemesten ${cropLateStageLabel(v.id).substring(0, 1).toLowerCase()}${cropLateStageLabel(v.id).substring(1)}',
            subtitle: isFlower
                ? 'Kalium voor stevigheid en zaadvorming.'
                : fruitCrop
                    ? 'Kalium voor vruchtkwaliteit.'
                    : 'Kalium voor stevigheid en oogst.',
            summary: flowerSum('Bemesten na de bloei') ??
                (fruitCrop
                    ? 'Geef kaliumrijke voeding tijdens vruchtzetting voor stevigheid en smaak.'
                    : cropLateStageFeedHow(v.id)),
            illustration: PlantNutritionIllustration.fruitingFeed,
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.columns2,
        sections: [
          PlantNutritionSection(
            title: 'Tekort aan voeding',
            subtitle: 'Herken tekorten op tijd.',
            items: [
              const NutritionListItem('Geel wordende of bleke bladeren.'),
              const NutritionListItem('Langzame of stilstaande groei.'),
              const NutritionListItem('Kleine bladeren of dunne stengels.'),
              NutritionListItem(isFlower
                  ? 'Minder bloemen of kortere bloei dan verwacht.'
                  : fruitCrop
                      ? 'Minder bloemen of vruchten dan verwacht.'
                      : 'Zwakkere groei of mindere oogstkwaliteit.'),
            ],
            illustration: PlantNutritionIllustration.deficiency,
            illustrationSize: NutritionIllustrationSize.compact,
          ),
          PlantNutritionSection(
            title: 'Overbemesting',
            subtitle: 'Te veel mest schaadt de plant.',
            items: const [
              NutritionListItem('Verbrande of bruine bladranden.'),
              NutritionListItem('Donkere, glanzende bladeren.'),
              NutritionListItem('Snelle maar zwakke groei.'),
              NutritionListItem('Wortelverbranding bij jonge planten.'),
            ],
            illustration: PlantNutritionIllustration.overfertilization,
            illustrationSize: NutritionIllustrationSize.compact,
          ),
        ],
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.alert,
        sections: const [],
        alert: PlantNutritionAlert(
          title: 'Tip: bemesting',
          body:
              'Geef een lichte gift organische mest in het groeiseizoen. '
              'Werk compost bij voor langdurig effect op bodemstructuur en voeding.',
        ),
      ),
      PlantNutritionRow(
        kind: PlantNutritionRowKind.timeline,
        sections: [
          PlantNutritionSection(
            title: 'Voedingsschema (overzicht)',
            subtitle: 'Wanneer welke voeding?',
            timeline: [
              const NutritionTimelineStage(
                label: 'Uitplanten',
                detail: 'Compost',
                icon: NutritionTimelineIcon.plant,
              ),
              const NutritionTimelineStage(
                label: 'Groei',
                detail: 'Stikstof (N)',
                icon: NutritionTimelineIcon.grow,
              ),
              const NutritionTimelineStage(
                label: 'Bloei',
                detail: 'Fosfor (P)',
                icon: NutritionTimelineIcon.bloom,
              ),
              NutritionTimelineStage(
                label: isFlower ? 'Nazomer' : cropTimelineChipLabel(v.id),
                detail: 'Kalium (K)',
                icon: NutritionTimelineIcon.fruit,
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
