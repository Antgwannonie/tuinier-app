import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_section_details.dart';

enum PlantGrowthIllustration {
  phaseGermination,
  phaseSeedling,
  phaseYoung,
  phaseGrowth,
  phaseBloom,
  phaseFruiting,
  phaseHarvest,
  growthDuration,
  harvestTime,
  heightPlant,
  widthSpread,
  habitCompact,
  habitBush,
  habitUpright,
  habitClimbing,
  habitCreeping,
  supportStake,
  supportTrellis,
  supportRope,
  supportNone,
  tying,
  topping,
  pruningSuckers,
  thinning,
  stimulateWater,
  stimulateNutrition,
  stimulateSun,
  stimulateTemp,
  problems,
  healthy,
  stress,
  aiAdvice,
}

enum GrowthIllustrationSize {
  normal,
  mediumCompact,
  compact,
  habit,
  phase,
  small,
  inline,
}

enum GrowthSpeedLevel { slow, medium, fast }

enum GrowthHabitKind { compact, bush, upright, climbing, creeping }

enum GrowthListMarker { check, bullet, warning }

class GrowthListItem {
  const GrowthListItem(
    this.text, {
    this.marker = GrowthListMarker.bullet,
  });

  final String text;
  final GrowthListMarker marker;
}

class GrowthPhaseTimelineItem {
  const GrowthPhaseTimelineItem({
    required this.label,
    required this.illustration,
    this.highlighted = false,
  });

  final String label;
  final PlantGrowthIllustration illustration;
  final bool highlighted;
}

class GrowthHabitCard {
  const GrowthHabitCard({
    required this.label,
    required this.illustration,
    required this.habit,
    this.highlighted = false,
  });

  final String label;
  final PlantGrowthIllustration illustration;
  final GrowthHabitKind habit;
  final bool highlighted;
}

class GrowthSupportOption {
  const GrowthSupportOption({
    required this.label,
    required this.illustration,
    this.recommended = false,
  });

  final String label;
  final PlantGrowthIllustration illustration;
  final bool recommended;
}

class GrowthStimulateFactor {
  const GrowthStimulateFactor({
    required this.label,
    required this.illustration,
  });

  final String label;
  final PlantGrowthIllustration illustration;
}

class PlantGrowthSection {
  const PlantGrowthSection({
    this.title = '',
    this.subtitle,
    this.summary,
    this.items,
    this.illustration,
    this.illustrationSize = GrowthIllustrationSize.normal,
    this.growthSpeed,
    this.phaseTimeline,
    this.habitCards,
    this.supportOptions,
    this.stimulateFactors,
    this.details = const [],
  });

  final String title;
  final String? subtitle;
  final String? summary;
  final List<GrowthListItem>? items;
  final PlantGrowthIllustration? illustration;
  final GrowthIllustrationSize illustrationSize;
  final GrowthSpeedLevel? growthSpeed;
  final List<GrowthPhaseTimelineItem>? phaseTimeline;
  final List<GrowthHabitCard>? habitCards;
  final List<GrowthSupportOption>? supportOptions;
  final List<GrowthStimulateFactor>? stimulateFactors;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage =>
      title.isNotEmpty && details.isNotEmpty;
}

enum PlantGrowthRowKind {
  phaseTimeline,
  columns2,
  habitGrid,
  speedAndSupport,
  split,
  stressAndAi,
}

class PlantGrowthRow {
  const PlantGrowthRow({
    required this.kind,
    required this.sections,
    this.alert,
    this.stackVertically = false,
  });

  final PlantGrowthRowKind kind;
  final List<PlantGrowthSection> sections;
  final PlantGrowthAlert? alert;
  final bool stackVertically;
}

class PlantGrowthAlert {
  const PlantGrowthAlert({
    required this.title,
    required this.body,
  });

  final String title;
  final String body;
}

class PlantGrowthGuide {
  const PlantGrowthGuide({required this.rows});

  final List<PlantGrowthRow> rows;
}

PlantGrowthGuide growthGuideForVegetable(Vegetable vegetable) {
  final built = _buildGrowthGuide(vegetable);
  return PlantGrowthGuide(
    rows: [
      for (final row in built.rows)
        PlantGrowthRow(
          kind: row.kind,
          alert: row.alert,
          stackVertically: row.stackVertically,
          sections: [
            for (final s in row.sections)
              PlantGrowthSection(
                title: s.title,
                subtitle: s.subtitle,
                summary: s.title.isEmpty
                    ? s.summary
                    : cropCardSummaryFor(
                        tab: 'growth',
                        title: s.title,
                        vegetable: vegetable,
                      ),
                items: s.items,
                illustration: s.illustration,
                illustrationSize: s.illustrationSize,
                growthSpeed: s.growthSpeed,
                phaseTimeline: s.phaseTimeline,
                habitCards: s.habitCards,
                supportOptions: s.supportOptions,
                stimulateFactors: s.stimulateFactors,
                details: s.title.isEmpty
                    ? const <PlantGuideDetailBlock>[]
                    : sectionDetailsFor(
                        tab: 'growth',
                        title: s.title,
                        vegetable: vegetable,
                      ),
              ),
          ],
        ),
    ],
  );
}

GrowthSpeedLevel _growthSpeedLevel(Vegetable v) {
  final cat = (v.growthCategory ?? '').toLowerCase();
  if (cat.contains('snelle')) return GrowthSpeedLevel.fast;
  if (cat.contains('meerjarig') || cat.contains('lang producerende')) {
    return GrowthSpeedLevel.slow;
  }
  return GrowthSpeedLevel.medium;
}

(String, String, String) _growthFacts(Vegetable v) {
  final cat = v.growthCategory?.toLowerCase() ?? '';
  String height;
  String width;
  String habit;

  if (cat.contains('boom') || cat.contains('fruit (boom)')) {
    height = '2–6 m';
    width = '2–4 m';
    habit = 'Opgaand';
  } else if (cat.contains('bes') ||
      v.id.contains('braam') ||
      v.id.contains('framboos')) {
    height = '1–2 m';
    width = '1–2 m';
    habit = 'Struikvormig';
  } else if (cat.contains('kruiden') || v.spacingCm <= 30) {
    height = '20–60 cm';
    width = '20–40 cm';
    habit = 'Compact';
  } else if (v.spacingCm >= 80) {
    height = '80–200 cm';
    width = '${v.spacingCm}–${v.rowSpacingCm} cm';
    habit = 'Opgaand';
  } else {
    height = '30–80 cm';
    width = '${v.spacingCm}–${v.rowSpacingCm} cm';
    habit = 'Opgaand';
  }

  if (v.id.contains('pompoen') ||
      v.id.contains('komkommer') ||
      v.id.contains('courgette')) {
    habit = 'Kruipend';
  } else if (v.id.contains('tomaat') ||
      v.id.contains('bonen') ||
      v.id.contains('erwt') ||
      v.id.contains('komkommer')) {
    habit = 'Klimmend';
  }

  return (height, width, habit);
}

GrowthHabitKind _habitKindFromLabel(String label) {
  return switch (label) {
    'Compact' => GrowthHabitKind.compact,
    'Struikvormig' => GrowthHabitKind.bush,
    'Klimmend' => GrowthHabitKind.climbing,
    'Kruipend' => GrowthHabitKind.creeping,
    _ => GrowthHabitKind.upright,
  };
}

(String, String) _durationFacts(Vegetable v) {
  final raw = v.cropDuration?.trim();
  if (raw != null && raw.isNotEmpty) {
    return (raw, '$raw vanaf zaaien');
  }
  final cat = (v.growthCategory ?? '').toLowerCase();
  if (cat.contains('snelle')) {
    return ('30 – 60 dagen (gemiddeld)', '45 dagen vanaf zaaien');
  }
  if (cat.contains('meerjarig')) {
    return ('Meerjarig (doorlopend)', 'Eerste oogst na 1–2 jaar');
  }
  return ('90 – 120 dagen (gemiddeld)', '90 dagen vanaf zaaien');
}

int _highlightPhaseIndex(Vegetable v) {
  final blob =
      '${v.harvest} ${v.summary} ${v.growthCategory}'.toLowerCase();
  if (blob.contains('oogst') || blob.contains('vrucht')) return 6;
  if (blob.contains('vruchtvorm')) return 5;
  if (blob.contains('bloei')) return 4;
  if (blob.contains('zaai') || blob.contains('kiem')) return 0;
  return 3;
}

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

bool _isClimbing(Vegetable v) {
  final blob = '${v.care} ${v.id}'.toLowerCase();
  return blob.contains('klim') ||
      blob.contains('tomaat') ||
      blob.contains('bonen') ||
      blob.contains('erwt');
}

bool _isTomatoLike(Vegetable v) {
  return v.id.contains('tomaat');
}

bool _needsTopping(Vegetable v) {
  final id = v.id.toLowerCase();
  return id.contains('tomaat') ||
      id.contains('paprika') ||
      id.contains('basil') ||
      id.contains('basilicum') ||
      id.contains('pompoen') ||
      id.contains('meloen');
}

List<GrowthSupportOption> _supportOptions(Vegetable v) {
  final climbing = _isClimbing(v);
  final support = _needsSupport(v);
  return [
    GrowthSupportOption(
      label: 'Bamboestok',
      illustration: PlantGrowthIllustration.supportStake,
      recommended: support && !climbing,
    ),
    GrowthSupportOption(
      label: 'Klimrek',
      illustration: PlantGrowthIllustration.supportTrellis,
      recommended: climbing,
    ),
    GrowthSupportOption(
      label: 'Touw',
      illustration: PlantGrowthIllustration.supportRope,
      recommended: support,
    ),
    GrowthSupportOption(
      label: 'Geen steun nodig',
      illustration: PlantGrowthIllustration.supportNone,
      recommended: !support,
    ),
  ];
}

PlantGrowthGuide _buildGrowthGuide(Vegetable v) {
  final speed = _growthSpeedLevel(v);
  final facts = _growthFacts(v);
  final durations = _durationFacts(v);
  final highlight = _highlightPhaseIndex(v);
  final habitKind = _habitKindFromLabel(facts.$3);
  final tomato = _isTomatoLike(v);
  final support = _needsSupport(v);

  final isFruit = cropFruitsForHarvest(v.id);

  final phaseDefs = [
    ('Kieming', PlantGrowthIllustration.phaseGermination),
    ('Zaailing', PlantGrowthIllustration.phaseSeedling),
    ('Jonge plant', PlantGrowthIllustration.phaseYoung),
    ('Groei', PlantGrowthIllustration.phaseGrowth),
    ('Bloei', PlantGrowthIllustration.phaseBloom),
    if (isFruit) ('Vruchtvorming', PlantGrowthIllustration.phaseFruiting),
    ('Oogst', PlantGrowthIllustration.phaseHarvest),
  ];

  const habitDefs = [
    ('Compact', PlantGrowthIllustration.habitCompact, GrowthHabitKind.compact),
    ('Struikvormig', PlantGrowthIllustration.habitBush, GrowthHabitKind.bush),
    ('Opgaand', PlantGrowthIllustration.habitUpright, GrowthHabitKind.upright),
    ('Klimmend', PlantGrowthIllustration.habitClimbing, GrowthHabitKind.climbing),
    ('Kruipend', PlantGrowthIllustration.habitCreeping, GrowthHabitKind.creeping),
  ];

  return PlantGrowthGuide(
    rows: [
      PlantGrowthRow(
        kind: PlantGrowthRowKind.phaseTimeline,
        sections: [
          PlantGrowthSection(
            title: 'Groeifases',
            subtitle: 'Hoe lang duurt de volledige groei?',
            phaseTimeline: [
              for (var i = 0; i < phaseDefs.length; i++)
                GrowthPhaseTimelineItem(
                  label: phaseDefs[i].$1,
                  illustration: phaseDefs[i].$2,
                  highlighted: i == highlight,
                ),
            ],
          ),
        ],
      ),
      PlantGrowthRow(
        kind: PlantGrowthRowKind.columns2,
        sections: [
          PlantGrowthSection(
            title: 'Groeiduur',
            subtitle: 'Totale duur van zaad tot oogst.',
            summary: durations.$1,
            illustration: PlantGrowthIllustration.growthDuration,
            illustrationSize: GrowthIllustrationSize.compact,
          ),
          PlantGrowthSection(
            title: 'Tijd tot oogst',
            subtitle: 'Wanneer kun je oogsten?',
            summary: durations.$2,
            illustration: PlantGrowthIllustration.harvestTime,
            illustrationSize: GrowthIllustrationSize.compact,
          ),
        ],
      ),
      PlantGrowthRow(
        kind: PlantGrowthRowKind.columns2,
        sections: [
          PlantGrowthSection(
            title: 'Hoogte',
            subtitle: 'Verwachte hoogte bij volwassenheid.',
            summary: facts.$1,
            illustration: PlantGrowthIllustration.heightPlant,
            illustrationSize: GrowthIllustrationSize.compact,
          ),
          PlantGrowthSection(
            title: 'Breedte',
            subtitle: 'Hoeveel ruimte neemt de plant in?',
            summary: facts.$2,
            illustration: PlantGrowthIllustration.widthSpread,
            illustrationSize: GrowthIllustrationSize.compact,
          ),
        ],
      ),
      PlantGrowthRow(
        kind: PlantGrowthRowKind.habitGrid,
        sections: [
          PlantGrowthSection(
            title: 'Groeiwijze',
            subtitle: 'Hoe groeit deze plant van nature?',
            habitCards: [
              for (final h in habitDefs)
                GrowthHabitCard(
                  label: h.$1,
                  illustration: h.$2,
                  habit: h.$3,
                  highlighted: h.$3 == habitKind,
                ),
            ],
          ),
        ],
      ),
      PlantGrowthRow(
        kind: PlantGrowthRowKind.speedAndSupport,
        sections: [
          PlantGrowthSection(
            title: 'Groeisnelheid',
            subtitle: 'Hoe snel groeit deze plant?',
            growthSpeed: speed,
          ),
          PlantGrowthSection(
            title: 'Ondersteuning',
            subtitle: 'Welke steun past bij dit gewas?',
            supportOptions: _supportOptions(v),
          ),
        ],
      ),
      PlantGrowthRow(
        kind: PlantGrowthRowKind.columns2,
        sections: [
          PlantGrowthSection(
            title: 'Opbinden',
            subtitle: 'Stengels vastzetten aan steun.',
            summary: support
                ? 'Bind de hoofdstengel losjes aan een stok of rek. '
                    'Gebruik zacht touw en laat ruimte voor verdikking.'
                : 'Meestal niet nodig bij dit gewas. '
                    'Bind alleen bij wind of zware bloemen.',
            illustration: PlantGrowthIllustration.tying,
            illustrationSize: GrowthIllustrationSize.mediumCompact,
          ),
          PlantGrowthSection(
            title: 'Toppen',
            subtitle: 'Groei top afsnijden.',
            summary: tomato
                ? 'Verwijder de top na voldoende trossen om de groei te sturen '
                    'en energie naar vruchten te sturen.'
                : _needsTopping(v)
                    ? 'Toppen stimuleert zijgroei en een vollere plant.'
                    : 'Meestal niet nodig bij dit gewas.',
            illustration: PlantGrowthIllustration.topping,
            illustrationSize: GrowthIllustrationSize.mediumCompact,
          ),
        ],
      ),
      if (tomato || v.id.contains('paprika') || v.id.contains('aubergine'))
        PlantGrowthRow(
          kind: PlantGrowthRowKind.split,
          sections: [
            PlantGrowthSection(
              title: 'Dieven',
              subtitle: 'Zijscheuten verwijderen.',
              summary: tomato
                  ? 'Verwijder zijscheuten (dieven) in de oksel van het blad. '
                      'Zo blijft de plant luchtig en gaat energie naar vruchten.'
                  : 'Verwijder ongewenste zijscheuten om de plant compact te houden '
                      'en luchtcirculatie te verbeteren.',
              illustration: PlantGrowthIllustration.pruningSuckers,
            ),
          ],
        ),
      PlantGrowthRow(
        kind: PlantGrowthRowKind.columns2,
        stackVertically: true,
        sections: [
          PlantGrowthSection(
            title: 'Uitdunnen',
            subtitle: 'Overvolle rijen verlichten.',
            summary:
                'Verwijder overtollige zaailingen zodat overblijvende planten '
                'genoeg licht, water en voeding krijgen.',
            illustration: PlantGrowthIllustration.thinning,
            illustrationSize: GrowthIllustrationSize.normal,
          ),
          PlantGrowthSection(
            title: 'Groei stimuleren',
            subtitle: 'Factoren voor gezonde groei.',
            stimulateFactors: const [
              GrowthStimulateFactor(
                label: 'Water',
                illustration: PlantGrowthIllustration.stimulateWater,
              ),
              GrowthStimulateFactor(
                label: 'Voeding',
                illustration: PlantGrowthIllustration.stimulateNutrition,
              ),
              GrowthStimulateFactor(
                label: 'Zonlicht',
                illustration: PlantGrowthIllustration.stimulateSun,
              ),
              GrowthStimulateFactor(
                label: 'Temperatuur',
                illustration: PlantGrowthIllustration.stimulateTemp,
              ),
            ],
          ),
        ],
      ),
      PlantGrowthRow(
        kind: PlantGrowthRowKind.columns2,
        stackVertically: true,
        sections: [
          PlantGrowthSection(
            title: 'Groeiproblemen',
            subtitle: 'Veelvoorkomende oorzaken.',
            items: const [
              GrowthListItem('Te weinig licht of te dicht op elkaar.'),
              GrowthListItem('Te natte of verzuurde grond.'),
              GrowthListItem('Tekort aan voeding of water.'),
              GrowthListItem('Plagen of ziektes op jonge bladeren.'),
            ],
            illustration: PlantGrowthIllustration.problems,
            illustrationSize: GrowthIllustrationSize.normal,
          ),
          PlantGrowthSection(
            title: 'Tekenen van gezonde groei',
            subtitle: 'Herken goede ontwikkeling.',
            items: const [
              GrowthListItem('Nieuwe bladeren', marker: GrowthListMarker.check),
              GrowthListItem('Fris groen blad', marker: GrowthListMarker.check),
              GrowthListItem('Gelijkmatige groei', marker: GrowthListMarker.check),
              GrowthListItem('Stevige stengel', marker: GrowthListMarker.check),
            ],
            illustration: PlantGrowthIllustration.healthy,
            illustrationSize: GrowthIllustrationSize.normal,
          ),
        ],
      ),
      PlantGrowthRow(
        kind: PlantGrowthRowKind.stressAndAi,
        sections: [
          PlantGrowthSection(
            title: 'Tekenen van groeistress',
            subtitle: 'Signalen dat de plant vastloopt.',
            items: const [
              GrowthListItem('Groei blijft achter', marker: GrowthListMarker.warning),
              GrowthListItem('Bladvergeling of krullen', marker: GrowthListMarker.warning),
              GrowthListItem('Hangende of slap blad', marker: GrowthListMarker.warning),
            ],
            illustration: PlantGrowthIllustration.stress,
            illustrationSize: GrowthIllustrationSize.normal,
          ),
        ],
        alert: PlantGrowthAlert(
          title: 'Tip: groeichecklist',
          body:
              'Controleer regelmatig op gelijkmatige groei. '
              'Pas water, voeding en steun aan waar nodig — zeker bij wisselend weer.',
        ),
      ),
    ],
  );
}
