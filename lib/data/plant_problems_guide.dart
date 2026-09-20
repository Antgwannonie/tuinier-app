import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'pest_guide_lookup.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_section_details.dart';

enum PlantProblemsIllustration {
  symptoms,
  insects,
  fungus,
  nutrients,
  water,
  weather,
  pollination,
  growth,
  pot,
  greenhouse,
  animals,
}

class ProblemsDetailBlock {
  const ProblemsDetailBlock({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

class PlantProblemsSection {
  const PlantProblemsSection({
    required this.title,
    required this.summary,
    required this.illustration,
    required this.details,
  });

  final String title;
  final String summary;
  final PlantProblemsIllustration illustration;
  final List<ProblemsDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

enum PlantProblemsRowKind {
  fullWidth,
  columns2,
}

class PlantProblemsRow {
  const PlantProblemsRow({
    required this.kind,
    required this.sections,
  });

  final PlantProblemsRowKind kind;
  final List<PlantProblemsSection> sections;
}

class PlantProblemsGuide {
  const PlantProblemsGuide({required this.rows});

  final List<PlantProblemsRow> rows;
}

PlantProblemsGuide problemsGuideForVegetable(Vegetable vegetable) {
  final built = _buildProblemsGuide(vegetable);
  return PlantProblemsGuide(
    rows: [
      for (final row in built.rows)
        PlantProblemsRow(
          kind: row.kind,
          sections: [
            for (final s in row.sections)
              PlantProblemsSection(
                title: s.title,
                summary: s.title.isEmpty
                    ? s.summary
                    : cropCardSummaryFor(
                        tab: 'problems',
                        title: s.title,
                        vegetable: vegetable,
                      ),
                illustration: s.illustration,
                details: _mergeDetails(
                  s.details,
                  sectionDetailsFor(
                    tab: 'problems',
                    title: s.title,
                    vegetable: vegetable,
                  ),
                ),
              ),
          ],
        ),
    ],
  );
}

List<ProblemsDetailBlock> _mergeDetails(
  List<ProblemsDetailBlock> handWritten,
  List<PlantGuideDetailBlock> generated,
) {
  final existingHeadings = handWritten.map((b) => b.heading.toLowerCase()).toSet();
  final merged = [...handWritten];
  for (final g in generated) {
    if (!existingHeadings.contains(g.heading.toLowerCase()) && g.body.trim().isNotEmpty) {
      merged.add(ProblemsDetailBlock(heading: g.heading, body: g.body));
    }
  }
  return merged;
}

List<ProblemsDetailBlock> _insectDetails(Vegetable v) {
  final pests = pestsForVegetable(v).take(3).map((p) => p.nameNl).toList();
  final pestHint = pests.isNotEmpty
      ? 'Let extra op: ${pests.join(', ')}.'
      : 'Controleer regelmatig onder bladeren en in groeipunten.';

  return [
    ProblemsDetailBlock(
      heading: 'Waarom ontstaat dit?',
      body:
          'Insecten zoeken voedsel, schuilplaats en warmte. Zwakke of stressvolle planten trekken plagen sneller aan. $pestHint',
    ),
  if (v.commonIssues.trim().isNotEmpty)
      ProblemsDetailBlock(
        heading: 'Bij ${v.nameNl}',
        body: v.commonIssues,
      ),
    const ProblemsDetailBlock(
      heading: 'Hoe herken je het?',
      body:
          'Kleine gaatjes, kleverige honingdauw, spintwebjes, vergeling of gekrulde bladeren zijn veelvoorkomende signalen.',
    ),
    const ProblemsDetailBlock(
      heading: 'Oplossing',
      body:
          'Verwijder zieke bladeren, spoel bladluis weg met water, gebruik biologische bestrijding (lieveheersbeestje, nematoden) en houd planten gezond met goede voeding.',
    ),
    const ProblemsDetailBlock(
      heading: 'Voorkomen',
      body:
          'Wisselteelt, goede luchtcirculatie, niet te dicht planten en regelmatig controleren voorkomt de meeste plagen.',
    ),
  ];
}

PlantProblemsGuide _buildProblemsGuide(Vegetable v) {
  final issues = v.commonIssues.trim();
  final care = v.care.trim();
  final water = v.water.trim();

  return PlantProblemsGuide(
    rows: [
      PlantProblemsRow(
        kind: PlantProblemsRowKind.fullWidth,
        sections: [
          PlantProblemsSection(
            title: 'Symptomen herkennen',
            summary: cropFruitsForHarvest(v.id)
                ? 'Herken problemen aan bladeren, stengels, bloemen en vruchten.'
                : 'Herken problemen aan bladeren, stengels, wortels en groei.',
            illustration: PlantProblemsIllustration.symptoms,
            details: [
              ProblemsDetailBlock(
                heading: 'Waar kijk je naar?',
                body: cropFruitsForHarvest(v.id)
                    ? 'Bladeren: verkleuring, vlekken, krullen, gaatjes. Stengels: scheuren, zwarte plekken. Bloemen en vruchten: afvallen, misvorming, rot.'
                    : 'Bladeren: verkleuring, vlekken, krullen, gaatjes. Stengels: scheuren, zwarte plekken. Groei: stilstand, doorschieten, rotte of misvormde oogstdelen.',
              ),
              if (issues.isNotEmpty)
                ProblemsDetailBlock(
                  heading: 'Bij ${v.nameNl}',
                  body: issues,
                ),
              const ProblemsDetailBlock(
                heading: 'Wat nu?',
                body:
                    'Noteer wanneer symptomen beginnen en of ze zich verspreiden. Vergelijk met gezonde planten in dezelfde rij — dat helpt de oorzaak te vinden.',
              ),
            ],
          ),
        ],
      ),
      PlantProblemsRow(
        kind: PlantProblemsRowKind.fullWidth,
        sections: [
          PlantProblemsSection(
            title: 'Insecten & Plagen',
            summary:
                'Ontdek schadelijke insecten en plagen, de schade die ze veroorzaken en hoe je ze kunt bestrijden.',
            illustration: PlantProblemsIllustration.insects,
            details: _insectDetails(v),
          ),
        ],
      ),
      PlantProblemsRow(
        kind: PlantProblemsRowKind.fullWidth,
        sections: [
          PlantProblemsSection(
            title: 'Schimmels & Ziekten',
            summary:
                'Leer schimmels en ziekten herkennen, waarom ze ontstaan en hoe je ze voorkomt en behandelt.',
            illustration: PlantProblemsIllustration.fungus,
            details: [
              const ProblemsDetailBlock(
                heading: 'Waarom ontstaat dit?',
                body:
                    'Schimmels gedijen bij vocht, weinig wind en dichte beplanting. Meeldauw, roest en verrotting verspreiden zich snel in warme, vochtige omstandigheden.',
              ),
              if (issues.isNotEmpty)
                ProblemsDetailBlock(
                  heading: 'Risico bij ${v.nameNl}',
                  body: issues,
                ),
              const ProblemsDetailBlock(
                heading: 'Oplossing',
                body:
                    'Verwijder aangetaste delen, verbeter luchtcirculatie, geef water bij de wortel (niet over blad) en gebruik biologische fungicide indien nodig.',
              ),
              const ProblemsDetailBlock(
                heading: 'Voorkomen',
                body:
                    'Niet te dicht planten, ochtendwater geven, mulchen en geen nat blad laten staan.',
              ),
            ],
          ),
        ],
      ),
      PlantProblemsRow(
        kind: PlantProblemsRowKind.fullWidth,
        sections: [
          PlantProblemsSection(
            title: 'Voedingstekorten',
            summary:
                'Herken tekorten aan voedingsstoffen en leer hoe je je plant weer gezond krijgt.',
            illustration: PlantProblemsIllustration.nutrients,
            details: [
              const ProblemsDetailBlock(
                heading: 'Waarom ontstaat dit?',
                body:
                    'Te weinig stikstof geeft gele bladeren. Tekort aan kalium of magnesium toont zich als bruine randen of geel tussen de nerven.',
              ),
              ProblemsDetailBlock(
                heading: 'Bij ${v.nameNl}',
                body: v.soilAndFood.isNotEmpty
                    ? v.soilAndFood
                    : 'Geef een uitgebalanceerde organische mest volgens het groeistadium.',
              ),
              const ProblemsDetailBlock(
                heading: 'Oplossing',
                body:
                    'Geef de juiste mest (stikstof voor blad, kalium voor bloei/vrucht) en verbeter de bodem met compost.',
              ),
            ],
          ),
        ],
      ),
      PlantProblemsRow(
        kind: PlantProblemsRowKind.fullWidth,
        sections: [
          PlantProblemsSection(
            title: 'Waterproblemen',
            summary:
                'Te weinig of te veel water? Herken de signalen en leer hoe je het oplost.',
            illustration: PlantProblemsIllustration.water,
            details: [
              const ProblemsDetailBlock(
                heading: 'Te weinig water',
                body:
                    'Slappe, hangende bladeren die ’s avonds nog niet herstellen. Oplossing: gelijkmatig water geven, mulchen om uitdroging te vertragen.',
              ),
              const ProblemsDetailBlock(
                heading: 'Te veel water',
                body:
                    'Gele bladeren, rottende wortels, muffe geur. Oplossing: minder gieten, drainage verbeteren, laat bovenste laag drogen.',
              ),
              if (water.isNotEmpty)
                ProblemsDetailBlock(
                  heading: 'Waterbehoefte ${v.nameNl}',
                  body: water,
                ),
            ],
          ),
        ],
      ),
      PlantProblemsRow(
        kind: PlantProblemsRowKind.columns2,
        sections: [
          PlantProblemsSection(
            title: 'Weerproblemen',
            summary:
                'Bescherm je planten tegen hitte, vorst, wind, hagel en extreme regenval.',
            illustration: PlantProblemsIllustration.weather,
            details: const [
              ProblemsDetailBlock(
                heading: 'Hitte & droogte',
                body:
                    'Schaduwdoek, extra water vroeg in de ochtend, mulchen. Bladeren kunnen verbranden bij >30 °C.',
              ),
              ProblemsDetailBlock(
                heading: 'Vorst & kou',
                body:
                    'Vliesdoek of tunnel, planten binnen halen in pot. Vorst beschadigt cellen in blad en vrucht.',
              ),
              ProblemsDetailBlock(
                heading: 'Wind & hagel',
                body:
                    'Windscherm plaatsen, hoge planten binden. Na hagel verwijder beschadigd blad.',
              ),
            ],
          ),
          PlantProblemsSection(
            title: 'Bestuivingsproblemen',
            summary: cropFruitsForHarvest(v.id)
                ? 'Waarom ontstaan er weinig of geen vruchten? Ontdek de oorzaken en oplossingen.'
                : 'Meestal niet relevant bij dit gewas — je oogst geen vruchten uit de bloem.',
            illustration: PlantProblemsIllustration.pollination,
            details: cropFruitsForHarvest(v.id)
                ? const [
                    ProblemsDetailBlock(
                      heading: 'Waarom geen vruchten?',
                      body:
                          'Te weinig insecten, te koud, te vochtig of gesloten bloemen zonder bestuiving. Kruisbestuivers hebben soms hulp nodig.',
                    ),
                    ProblemsDetailBlock(
                      heading: 'Oplossing',
                      body:
                          'Trekk bloemen aan (goudsbloem, lavendel), bestuif handmatig bij komkommer/pompoen, vermijd bestrijdingsmiddelen tijdens bloei.',
                    ),
                  ]
                : const [
                    ProblemsDetailBlock(
                      heading: 'Waarom niet relevant?',
                      body:
                          'Bij blad-, wortel- en bolgewassen oogst je geen vruchten uit bloemen. Bestuiving speelt hier geen rol voor je oogst.',
                    ),
                    ProblemsDetailBlock(
                      heading: 'Wel opletten',
                      body:
                          'Als je zaad wilt winnen van bladgewassen (sla, spinazie) is bestuiving wél belangrijk. Laat de plant dan doorschieten en bloeien.',
                    ),
                  ],
          ),
        ],
      ),
      PlantProblemsRow(
        kind: PlantProblemsRowKind.fullWidth,
        sections: [
          PlantProblemsSection(
            title: 'Groeiproblemen',
            summary:
                'Je plant groeit niet goed? Ontdek de mogelijke oorzaken en hoe je de groei stimuleert.',
            illustration: PlantProblemsIllustration.growth,
            details: [
              const ProblemsDetailBlock(
                heading: 'Mogelijke oorzaken',
                body:
                    'Te weinig licht, koude bodem, wortelconcurrentie, ziekte of verkeerde voeding remmen groei.',
              ),
              if (care.isNotEmpty)
                ProblemsDetailBlock(
                  heading: 'Verzorging ${v.nameNl}',
                  body: care,
                ),
              const ProblemsDetailBlock(
                heading: 'Oplossing',
                body:
                    'Controleer standplaats, geef lichte bemesting, verwijder zieke delen en zorg voor voldoende ruimte tussen planten.',
              ),
            ],
          ),
        ],
      ),
      PlantProblemsRow(
        kind: PlantProblemsRowKind.columns2,
        sections: [
          PlantProblemsSection(
            title: 'Problemen in potten',
            summary:
                'Veelvoorkomende problemen bij planten in potten en hoe je ze voorkomt en oplost.',
            illustration: PlantProblemsIllustration.pot,
            details: const [
              ProblemsDetailBlock(
                heading: 'Veelvoorkomende problemen',
                body:
                    'Uitdrogen, wortelrot door slechte drainage, uitputting van voedingsstoffen in kleine potten.',
              ),
              ProblemsDetailBlock(
                heading: 'Oplossing',
                body:
                    'Pot met drainagegat, goede potgrond, regelmatig bemesten en op tijd verpotten.',
              ),
            ],
          ),
          PlantProblemsSection(
            title: 'Problemen in kas',
            summary:
                'Specifieke problemen in de kas, zoals te warm, te vochtig of slechte ventilatie.',
            illustration: PlantProblemsIllustration.greenhouse,
            details: const [
              ProblemsDetailBlock(
                heading: 'Waarom in de kas?',
                body:
                    'Hoge luchtvochtigheid bevordert schimmel. Te weinig ventilatie veroorzaakt oververhitting.',
              ),
              ProblemsDetailBlock(
                heading: 'Oplossing',
                body:
                    'Ventileer dagelijks, monitor temperatuur, geef water bij de wortel en vermijd nat blad.',
              ),
            ],
          ),
        ],
      ),
      PlantProblemsRow(
        kind: PlantProblemsRowKind.fullWidth,
        sections: [
          PlantProblemsSection(
            title: 'Dierenschade',
            summary:
                'Bescherm je planten tegen schade door dieren zoals slakken, vogels, muizen en konijnen.',
            illustration: PlantProblemsIllustration.animals,
            details: const [
              ProblemsDetailBlock(
                heading: 'Schade herkennen',
                body:
                    'Slakken: grote gaten in blad. Vogels: pikken in vruchten. Konijnen en muizen: afgeknaagde stengels en jonge scheuten.',
              ),
              ProblemsDetailBlock(
                heading: 'Oplossing',
                body:
                    'Slakkenkorrels, vogelnet, hekwerk rond bed, op tijd oogsten. Haal val en schuilplaatsen weg.',
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
