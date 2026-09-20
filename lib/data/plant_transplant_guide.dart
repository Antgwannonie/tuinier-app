import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'flower_card_summaries.dart';
import 'plant_crop_profiles.dart';
import 'plant_search_filters.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';

part 'plant_transplant_guide_entries.dart';

enum PlantTransplantIllustration {
  conditions,
  hardening,
  plantSpacing,
  rowSpacing,
  plantingDepth,
  bestLocation,
  soilPrep,
  waterAfter,
  support,
  protection,
  establish,
  growth,
  mistakes,
}

enum TransplantIllustrationSize { normal, compact, large }

enum TransplantListMarker { check, cross }

enum TransplantChipIcon {
  sun,
  partialSun,
  pot,
  greenhouse,
  openGround,
  wind,
  slug,
  frost,
  strongSun,
  sparkle,
  weather,
}

class TransplantDetailBlock {
  const TransplantDetailBlock({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

class TransplantListItem {
  const TransplantListItem(this.text, {this.marker = TransplantListMarker.check});

  final String text;
  final TransplantListMarker marker;
}

class TransplantIconChip {
  const TransplantIconChip({required this.icon, required this.label});

  final TransplantChipIcon icon;
  final String label;
}

class PlantTransplantSection {
  const PlantTransplantSection({
    this.title = '',
    this.summary,
    this.months,
    this.items,
    this.steps,
    this.illustration,
    this.illustrationSize = TransplantIllustrationSize.normal,
    this.chips,
    this.details = const [],
  });

  final String title;

  /// Korte tekst op de kaart (voorkant).
  final String? summary;
  final Set<int>? months;
  final List<TransplantListItem>? items;
  final List<String>? steps;
  final PlantTransplantIllustration? illustration;
  final TransplantIllustrationSize illustrationSize;
  final List<TransplantIconChip>? chips;

  /// Uitgebreide info bij tikken op de kaart.
  final List<TransplantDetailBlock> details;

  bool get hasDetailPage => title.isNotEmpty && details.isNotEmpty;
}

enum PlantTransplantRowKind {
  single,
  split,
  columns2,
  columns2Compact,
  columns3,
  iconRow,
  timingGroup,
  alerts,
}

class PlantTransplantRow {
  const PlantTransplantRow({
    required this.kind,
    required this.sections,
    this.alerts,
  });

  final PlantTransplantRowKind kind;
  final List<PlantTransplantSection> sections;
  final List<PlantTransplantAlert>? alerts;
}

class PlantTransplantAlert {
  const PlantTransplantAlert({
    required this.icon,
    required this.title,
    required this.body,
  });

  final TransplantChipIcon icon;
  final String title;
  final String body;
}

class PlantTransplantGuide {
  const PlantTransplantGuide({required this.rows});

  final List<PlantTransplantRow> rows;
}

PlantTransplantGuide transplantGuideForVegetable(Vegetable vegetable) {
  final exact = kPlantTransplantGuides[vegetable.id];
  final built = exact ?? _buildTransplantGuide(vegetable);
  final isFlower = isFlowerGuidePlant(vegetable.id);
  String summaryFor(String title) => isFlower
      ? flowerCardSummaryFor(
          tab: 'transplant',
          title: title,
          vegetable: vegetable,
        )
      : cropCardSummaryFor(
          tab: 'transplant',
          title: title,
          vegetable: vegetable,
        );
  return PlantTransplantGuide(
    rows: [
      for (final row in built.rows)
        PlantTransplantRow(
          kind: row.kind,
          sections: [
            for (final s in row.sections)
              PlantTransplantSection(
                title: s.title,
                summary: s.title.isEmpty
                    ? s.summary
                    : summaryFor(s.title),
                months: s.months,
                items: s.items,
                steps: s.steps,
                illustration: s.illustration,
                illustrationSize: s.illustrationSize,
                chips: s.chips,
                details: s.details,
              ),
          ],
        ),
    ],
  );
}

List<TransplantDetailBlock> _detail({
  required String why,
  required String how,
  required String tip,
  String? extra,
}) {
  return [
    TransplantDetailBlock(heading: 'Waarom dit advies?', body: why),
    TransplantDetailBlock(heading: 'Hoe doe je het?', body: how),
    TransplantDetailBlock(heading: 'Praktische tips', body: tip),
    if (extra != null)
      TransplantDetailBlock(heading: 'Extra info', body: extra),
  ];
}

PlantTransplantGuide _buildTransplantGuide(Vegetable vegetable) {
  final transplant = vegetable.transplant.trim();
  final plantMonths = _plantMonths(vegetable);
  final spacing = vegetable.spacingCm;
  final rowSpacing = vegetable.rowSpacingCm;
  final transplantSummary = transplant.isNotEmpty
      ? transplant
      : 'Plant uit wanneer het weer en de plant het toelaten.';
  final name = vegetable.nameNl;

  return PlantTransplantGuide(
    rows: [
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Uitplantperiode',
            summary: transplantSummary,
            months: plantMonths.isEmpty ? null : plantMonths,
            details: _detail(
              why:
                  'Te vroeg uitplanten bij kou of vorst remt groei of doodt jonge $name. De periode volgt het Nederlandse seizoen.',
              how: transplantSummary,
              tip:
                  'Gebruik een bodemthermometer en check het weerbericht op nachtvorst.',
              extra:
                  'Kas of vliesdoek kan 1–2 weken voorsprong geven, afhankelijk van de soort.',
            ),
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.split,
        sections: [
          PlantTransplantSection(
            title: 'Uitplantvoorwaarden',
            summary: 'Geen vorst, warme genoeg bodem, stevige plant.',
            items: const [
              TransplantListItem('Geen nachtvorst.'),
              TransplantListItem('Bodemtemperatuur boven 10 °C.'),
              TransplantListItem('Plant heeft 4–6 echte bladeren.'),
            ],
            details: _detail(
              why:
                  'Jonge planten verdragen kou, wind en droge lucht slecht. Pas uitplanten als plant én weer klaar zijn.',
              how:
                  'Wacht op vorstvrije nachten, voldoende blad en een hanteerbare wortelkluit.',
              tip: 'Plant bij voorkeur op een bewolkte dag of ’s avonds.',
            ),
          ),
          const PlantTransplantSection(
            illustration: PlantTransplantIllustration.conditions,
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Afharden',
            summary: 'Laat de plant 5–10 dagen wennen aan buiten.',
            steps: const [
              'Dag 1–2: paar uur buiten',
              'Dag 3–4: langer buiten',
              'Dag 5–7: bijna hele dag',
              'Daarna: ook ’s nachts als vorstvrij',
            ],
            illustration: PlantTransplantIllustration.hardening,
            details: _detail(
              why:
                  'Binnen gekweekte planten hebben dunner bladwas en slapper weefsel. Abrupt buiten zetten geeft bladverbranding of schok.',
              how:
                  'Zet $name dagelijks langer buiten op een beschutte plek; bescherm tegen felle middagzon en wind.',
              tip: 'Sla afharden niet over, ook niet bij “sterke” zaailingen.',
            ),
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.columns3,
        sections: [
          PlantTransplantSection(
            title: 'Plantafstand',
            summary: '$spacing cm tussen de planten.',
            illustration: PlantTransplantIllustration.plantSpacing,
            details: _detail(
              why:
                  'Te dicht planten geeft concurrentie om licht, water en lucht — meer ziekte.',
              how: 'Houd ongeveer $spacing cm hart-op-hart aan.',
              tip: 'In bakken mag het soms iets dichter bij bladgewassen; bij vruchtgewassen liever ruim.',
            ),
          ),
          PlantTransplantSection(
            title: 'Rijafstand',
            summary: '$rowSpacing cm tussen de rijen.',
            illustration: PlantTransplantIllustration.rowSpacing,
            details: _detail(
              why: 'Rijenruimte zorgt voor bereikbaarheid en luchtcirculatie.',
              how: 'Houd ongeveer $rowSpacing cm tussen de rijen.',
              tip: 'In vierkante meter-teelt werk je met blokken i.p.v. lange rijen.',
            ),
          ),
          PlantTransplantSection(
            title: 'Plantdiepte',
            summary: 'Op dezelfde diepte als in de pot.',
            illustration: PlantTransplantIllustration.plantingDepth,
            details: _detail(
              why:
                  'Te diep planten kan stengelrot geven; te ondiep laat wortels uitdrogen.',
              how: cropProfileKeyFor(vegetable.id) == CropProfileKey.tomaat
                  ? 'Bij tomaat mag de stengel iets dieper: er vormen zich extra wortels.'
                  : 'Zet de kluit gelijk met het grondoppervlak.',
              tip: 'Druk licht aan zodat er geen luchtgaten rond de kluit zitten.',
            ),
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Beste locaties',
            summary: vegetable.sunRequirement.trim().isEmpty
                ? 'Kies de juiste plek voor optimale groei.'
                : vegetable.sunRequirement.trim(),
            chips: const [
              TransplantIconChip(icon: TransplantChipIcon.sun, label: 'Zon'),
              TransplantIconChip(
                icon: TransplantChipIcon.partialSun,
                label: 'Halfschaduw',
              ),
              TransplantIconChip(icon: TransplantChipIcon.pot, label: 'Pot'),
              TransplantIconChip(
                icon: TransplantChipIcon.greenhouse,
                label: 'Kas',
              ),
              TransplantIconChip(
                icon: TransplantChipIcon.openGround,
                label: 'Volle grond',
              ),
            ],
            illustration: PlantTransplantIllustration.bestLocation,
            details: _detail(
              why:
                  'Licht, wind en bodem bepalen of $name aanslaat en productief wordt.',
              how:
                  'Match standplaats met zonbehoefte en kies beschutting bij windgevoelige planten.',
              tip: 'Vermijd lager gelegen plekken waar kou blijft hangen.',
            ),
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Bodemvoorbereiding',
            summary: 'Maak de grond los, onkruidvrij en voedzaam.',
            items: const [
              TransplantListItem('Compost of organische mest toevoegen.'),
              TransplantListItem('Grond losmaken en egaliseren.'),
              TransplantListItem('Onkruid en stenen verwijderen.'),
            ],
            illustration: PlantTransplantIllustration.soilPrep,
            details: _detail(
              why:
                  'Losse, levende grond laat wortels snel aanslaan. Compacte of verdichte grond remt groei.',
              how:
                  'Werk compost door de bovenlaag, maak plantgaten op maat van de kluit.',
              tip: 'Geen verse, hete mest direct in het plantgat bij gevoelige wortels.',
            ),
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.columns2Compact,
        sections: [
          PlantTransplantSection(
            title: 'Water na uitplanten',
            summary: 'Direct aangieten; eerste week vochtig houden.',
            items: const [
              TransplantListItem('Direct goed water geven.'),
              TransplantListItem('Eerste week extra vochtig houden.'),
            ],
            illustration: PlantTransplantIllustration.waterAfter,
            illustrationSize: TransplantIllustrationSize.compact,
            details: _detail(
              why:
                  'Na uitplanten zijn fijne haarwortels beschadigd; constant vocht voorkomt uitdrogingsstress.',
              how:
                  'Geef meteen een flinke gift aan de voet. Houd 5–10 dagen vochtig, daarna geleidelijk normaliseren.',
              tip: 'Mulch helpt verdamping te verminderen.',
            ),
          ),
          PlantTransplantSection(
            title: 'Ondersteuning',
            summary: 'Steun indien nodig voor klim- of hoge gewassen.',
            illustration: PlantTransplantIllustration.support,
            illustrationSize: TransplantIllustrationSize.compact,
            details: _detail(
              why:
                  'Zonder steun knakken of liggen veel vrucht- en klimgewassen straks plat.',
              how:
                  'Zet stok, kooi of latwerk meteen bij het uitplanten, niet pas als de plant groot is.',
              tip: 'Bind losjes vast; stengels dikken nog aan.',
            ),
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Bescherming na uitplanten',
            summary: 'Bescherm tegen vorst, wind, felle zon en slakken.',
            chips: const [
              TransplantIconChip(icon: TransplantChipIcon.wind, label: 'Tegen wind'),
              TransplantIconChip(icon: TransplantChipIcon.slug, label: 'Tegen slakken'),
              TransplantIconChip(icon: TransplantChipIcon.frost, label: 'Tegen nachtvorst'),
              TransplantIconChip(
                icon: TransplantChipIcon.strongSun,
                label: 'Tegen felle zon',
              ),
            ],
            illustration: PlantTransplantIllustration.protection,
            details: _detail(
              why:
                  'De eerste dagen is $name kwetsbaar voor weersextremen en vraatzucht.',
              how:
                  'Gebruik vliesdoek bij kou, net/gaas bij vogels, en slakkenbarrières waar nodig.',
              tip: 'Verwijder tijdelijke bescherming overdag bij warm, zonnig weer om oververhitting te voorkomen.',
            ),
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.columns3,
        sections: [
          PlantTransplantSection(
            title: 'Tijd tot aanslaan',
            summary: 'Meestal 1–2 weken.',
            illustration: PlantTransplantIllustration.establish,
            illustrationSize: TransplantIllustrationSize.compact,
            details: _detail(
              why:
                  'Aanslaan betekent dat nieuwe haarwortels de omliggende grond in groeien.',
              how:
                  'Verwacht 7–14 dagen. Verplant niet opnieuw in die periode.',
              tip: 'Slap blad ’s middags kan normaal zijn; ’s ochtends slap wijst op watertekort.',
            ),
          ),
          PlantTransplantSection(
            title: 'Tijd tot eerste groei',
            summary: 'Nieuwe groei vaak na 7–14 dagen.',
            illustration: PlantTransplantIllustration.growth,
            illustrationSize: TransplantIllustrationSize.compact,
            details: _detail(
              why:
                  'Eerst herstelt de wortel; pas daarna zie je duidelijk nieuw blad of scheuten.',
              how: 'Kijk naar fris groeipunt of nieuw blad in het hart.',
              tip: 'Geef geen zware stikstofmest direct na uitplanten.',
            ),
          ),
          PlantTransplantSection(
            title: 'Tijd tot eerste oogst',
            summary: vegetable.harvest.trim().isEmpty
                ? 'Zie teeltkalender / overzicht.'
                : vegetable.harvest.trim(),
            illustration: PlantTransplantIllustration.growth,
            illustrationSize: TransplantIllustrationSize.compact,
            details: _detail(
              why:
                  'Oogsttijd hangt af van soort, ras, weer en of je voorzaaide.',
              how: vegetable.harvest.trim().isEmpty
                  ? 'Raadpleeg de oogstkalender van deze plant in de app.'
                  : vegetable.harvest.trim(),
              tip:
                  'Noteer je uitplantdatum; zo leer je jouw microklimaat kennen.',
            ),
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Veelgemaakte fouten',
            summary: 'Vermijd schok, kou, droogte en te diep planten.',
            items: const [
              TransplantListItem(
                'Te vroeg buiten zetten.',
                marker: TransplantListMarker.cross,
              ),
              TransplantListItem(
                'Niet afharden.',
                marker: TransplantListMarker.cross,
              ),
              TransplantListItem(
                'Te diep of te los planten.',
                marker: TransplantListMarker.cross,
              ),
              TransplantListItem(
                'Te weinig water de eerste week.',
                marker: TransplantListMarker.cross,
              ),
            ],
            illustration: PlantTransplantIllustration.mistakes,
            illustrationSize: TransplantIllustrationSize.large,
            details: _detail(
              why:
                  'De meeste mislukkingen komen door stress in de eerste 10 dagen.',
              how:
                  'Houd checklist aan: afharden → juiste diepte → aangieten → beschermen.',
              tip: 'Liever één week later uitplanten dan één nacht te vroeg bij vorst.',
            ),
          ),
        ],
      ),
    ],
  );
}

Set<int> _plantMonths(Vegetable vegetable) {
  final activities = calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  );
  final out = <int>{};
  for (final activity in activities) {
    if (activity.type == GardenTaskType.plantOutdoors) {
      out.addAll(activity.months);
    }
  }
  return out;
}
