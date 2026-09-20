import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'flower_card_summaries.dart';
import 'plant_search_filters.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';

part 'plant_sowing_guide_entries.dart';

/// Illustraties voor de zaaien-sectie (vector in de app).
enum PlantSowingIllustration {
  indoorTray,
  outdoorSoil,
  seedDepth,
  germinationTimeline,
  temperatureRange,
  lightGermination,
  waterGermination,
  prickOut,
  potUp,
}

enum PlantSowingAlertKind { frost, info }

/// Blok op de detailpagina van een zaaien-kop.
class SowingDetailBlock {
  const SowingDetailBlock({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

/// Eén kaart in de zaaien-gids (samenvatting + optionele detailpagina).
class PlantSowingGuideSection {
  const PlantSowingGuideSection({
    required this.title,
    required this.summary,
    this.whenText,
    this.howText,
    this.sowMonths,
    this.illustration,
    this.details = const [],
  });

  final String title;

  /// Korte tekst op de kaart (voorkant).
  final String summary;
  final String? whenText;
  final String? howText;

  /// Actieve maanden (1–12) voor de J F M A … tijdlijn.
  final Set<int>? sowMonths;
  final PlantSowingIllustration? illustration;

  /// Uitgebreide info bij tikken op de kaart.
  final List<SowingDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class PlantSowingAlert {
  const PlantSowingAlert({
    required this.kind,
    required this.title,
    required this.body,
  });

  final PlantSowingAlertKind kind;
  final String title;
  final String body;
}

class PlantSowingGuide {
  const PlantSowingGuide({
    required this.sections,
    this.alerts = const [],
  });

  final List<PlantSowingGuideSection> sections;
  final List<PlantSowingAlert> alerts;
}

PlantSowingGuide sowingGuideForVegetable(Vegetable vegetable) {
  final exact = kPlantSowingGuides[vegetable.id];
  final built = exact ?? _buildSowingGuide(vegetable);
  final isFlower = isFlowerGuidePlant(vegetable.id);
  String summaryFor(String title) => isFlower
      ? flowerCardSummaryFor(tab: 'sowing', title: title, vegetable: vegetable)
      : cropCardSummaryFor(tab: 'sowing', title: title, vegetable: vegetable);
  return PlantSowingGuide(
    alerts: built.alerts,
    sections: [
      for (final s in built.sections)
        PlantSowingGuideSection(
          title: s.title,
          summary: s.title.isEmpty ? s.summary : summaryFor(s.title),
          whenText: s.whenText,
          howText: s.howText,
          sowMonths: s.sowMonths,
          illustration: s.illustration,
          details: s.details,
        ),
    ],
  );
}

PlantSowingGuide _buildSowingGuide(Vegetable vegetable) {
  final hasIndoors = vegetable.sowingIndoors.trim().isNotEmpty;
  final hasOutdoors = vegetable.sowingOutdoors.trim().isNotEmpty;

  final sections = <PlantSowingGuideSection>[
    PlantSowingGuideSection(
      title: 'Binnen zaaien',
      summary: hasIndoors
          ? vegetable.sowingIndoors.trim()
          : 'Niet van toepassing of zaai direct buiten.',
      whenText: hasIndoors ? _extractWhen(vegetable.sowingIndoors) : null,
      howText: hasIndoors ? _extractHow(vegetable.sowingIndoors) : null,
      sowMonths: hasIndoors ? _indoorSowMonths(vegetable) : null,
      illustration: PlantSowingIllustration.indoorTray,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body: hasIndoors
              ? 'Binnen voorzaaien geeft een voorsprong op het seizoen en '
                  'beschermt jonge planten tegen kou. Gebruik de aangegeven '
                  'periode als richtlijn voor het Nederlandse klimaat.'
              : 'Voor deze teelt is voorzaaien vaak niet nodig of niet gebruikelijk. '
                  'Direct buiten zaaien of planten is dan praktischer.',
        ),
        SowingDetailBlock(
          heading: 'Hoe doe je het?',
          body: hasIndoors
              ? vegetable.sowingIndoors.trim()
              : 'Sla voorzaaien over tenzij je experimenteert met een vroege teelt.',
        ),
      ],
    ),
    PlantSowingGuideSection(
      title: 'Buiten zaaien',
      summary: hasOutdoors
          ? vegetable.sowingOutdoors.trim()
          : 'Zaai buiten wanneer bodem en weer het toelaten.',
      whenText: hasOutdoors ? _extractWhen(vegetable.sowingOutdoors) : null,
      howText: hasOutdoors ? _extractHow(vegetable.sowingOutdoors) : null,
      sowMonths: hasOutdoors ? _outdoorSowMonths(vegetable) : null,
      illustration: PlantSowingIllustration.outdoorSoil,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body:
              'Buiten zaaien volgt de bodemtemperatuur en het risico op nachtvorst. '
              'Te vroeg zaaien vertraagt kieming of doodt jonge planten.',
        ),
        SowingDetailBlock(
          heading: 'Hoe doe je het?',
          body: hasOutdoors
              ? vegetable.sowingOutdoors.trim()
              : 'Wacht tot de grond bewerkbaar en warm genoeg is.',
        ),
      ],
    ),
    const PlantSowingGuideSection(
      title: 'Zaaidiepte',
      summary: 'Zaai niet te diep; houd de grond gelijkmatig vochtig.',
      illustration: PlantSowingIllustration.seedDepth,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body:
              'Te diep gezaaide zaden hebben te weinig energie om boven te komen. '
              'Vuistregel: ongeveer 2–3× de zaaddikte.',
        ),
      ],
    ),
    const PlantSowingGuideSection(
      title: 'Kiemduur',
      summary: 'Meestal 5 – 14 dagen bij voldoende warmte en vocht.',
      illustration: PlantSowingIllustration.germinationTimeline,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body:
              'Kiemduur hangt af van temperatuur, vocht en zaadkwaliteit. '
              'Kouder weer verlengt de kiemtijd sterk.',
        ),
      ],
    ),
    const PlantSowingGuideSection(
      title: 'Kiemtemperatuur',
      summary: 'Meestal 18 – 24 °C voor een goede kieming.',
      illustration: PlantSowingIllustration.temperatureRange,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body:
              'Elke soort heeft een optimale bodemtemperatuur. Onder het minimum '
              'kiemen zaden traag of rotten weg.',
        ),
      ],
    ),
    const PlantSowingGuideSection(
      title: 'Licht tijdens kieming',
      summary: 'Veel zaden kiemen beter op een lichte, warme plek.',
      illustration: PlantSowingIllustration.lightGermination,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body:
              'Sommige zaden zijn lichtkiemers (niet of nauwelijks bedekken), '
              'andere donkerkiemers (licht afdekken met grond).',
        ),
      ],
    ),
    const PlantSowingGuideSection(
      title: 'Water tijdens kieming',
      summary: 'Grond licht vochtig houden, niet laten uitdrogen.',
      illustration: PlantSowingIllustration.waterGermination,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body:
              'Een uitgedroogd zaad stopt met kiemen. Natte, koude grond veroorzaakt '
              'juist rotting. Gelijkmatig vochtig is het doel.',
        ),
      ],
    ),
    const PlantSowingGuideSection(
      title: 'Verspenen',
      summary: 'Verplant zaailingen als ze 2 – 4 echte bladjes hebben.',
      illustration: PlantSowingIllustration.prickOut,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body:
              'Verspenen geeft elke zaailing ruimte en voorkomt langgerekte, '
              'zwakke planten in een volle tray.',
        ),
      ],
    ),
    const PlantSowingGuideSection(
      title: 'Oppotten',
      summary: 'Verpot wanneer de wortels de pot uitgroeien.',
      illustration: PlantSowingIllustration.potUp,
      details: [
        SowingDetailBlock(
          heading: 'Waarom dit advies?',
          body:
              'Te kleine potten remmen groei. Oppotten in verse grond houdt de '
              'plant sterk tot het uitplantmoment.',
        ),
      ],
    ),
  ];

  final alerts = <PlantSowingAlert>[];
  final issues = vegetable.commonIssues.toLowerCase();
  final care = '${vegetable.care} ${vegetable.transplant}'.toLowerCase();
  if (issues.contains('vorst') ||
      care.contains('vorst') ||
      care.contains('ijsheiligen')) {
    alerts.add(
      const PlantSowingAlert(
        kind: PlantSowingAlertKind.frost,
        title: 'Vorstgevoelig',
        body: 'Bescherm jonge planten tegen nachtvorst.',
      ),
    );
  }

  return PlantSowingGuide(sections: sections, alerts: alerts);
}

String? _extractWhen(String text) {
  final t = text.trim();
  if (t.isEmpty) return null;
  final semi = t.indexOf(';');
  if (semi > 0) return t.substring(0, semi).trim();
  final dot = t.indexOf('.');
  if (dot > 0 && dot < 60) return t.substring(0, dot).trim();
  return t.length > 48 ? '${t.substring(0, 45).trim()}…' : t;
}

String? _extractHow(String text) {
  final t = text.trim();
  if (t.isEmpty) return null;
  final semi = t.indexOf(';');
  if (semi > 0 && semi < t.length - 1) {
    return t.substring(semi + 1).trim();
  }
  return 'Zie de teeltkalender voor het juiste moment.';
}

Set<int> _indoorSowMonths(Vegetable vegetable) {
  final fromCal = _monthsForSowTypes(
    vegetable,
    {GardenTaskType.preSow},
  );
  if (fromCal.isNotEmpty) return fromCal;
  return _monthsFromSowingText(vegetable.sowingIndoors);
}

Set<int> _outdoorSowMonths(Vegetable vegetable) {
  var fromCal = _monthsForSowTypes(
    vegetable,
    {GardenTaskType.sowOutdoors},
  );
  if (fromCal.isEmpty) {
    fromCal = _monthsForSowTypes(
      vegetable,
      {GardenTaskType.plantOutdoors},
    );
  }
  if (fromCal.isNotEmpty) return fromCal;
  return _monthsFromSowingText(vegetable.sowingOutdoors);
}

Set<int> _monthsForSowTypes(
  Vegetable vegetable,
  Set<GardenTaskType> types,
) {
  final activities = calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  );
  final out = <int>{};
  for (final activity in activities) {
    if (types.contains(activity.type)) {
      out.addAll(activity.months);
    }
  }
  return out;
}

const _monthNameToNumber = {
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

Set<int> _monthsFromSowingText(String text) {
  final t = text.toLowerCase();
  final out = <int>{};
  for (final entry in _monthNameToNumber.entries) {
    if (t.contains(entry.key)) {
      out.add(entry.value);
    }
  }
  if (out.isEmpty) return out;

  final sorted = out.toList()..sort();
  if (sorted.length >= 2) {
    final filled = <int>{};
    for (var m = sorted.first; m <= sorted.last; m++) {
      filled.add(m);
    }
    return filled;
  }
  return out;
}
