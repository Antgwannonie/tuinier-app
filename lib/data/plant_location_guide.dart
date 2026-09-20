import '../models/vegetable.dart';
import 'crop_card_summaries.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_search_filters.dart';
import 'vegetable_overview_data.dart';

enum PlantLocationIllustration {
  sunHours,
  spaceDimensions,
  plantSpacing,
  rowSpacing,
  wind,
  temperature,
  frost,
  humidity,
  greenhouseOutdoor,
  indoorGrowing,
  openGround,
  pot,
  raisedBed,
  balcony,
  greenhouse,
  indoor,
}

enum LocationIllustrationSize { normal, compact, small, inline, large }

enum LocationSuitabilityMarker { check, warning, cross }

enum LocationSunLevel {
  fullSun,
  partialShade,
  lightShade,
  shade,
}

enum LocationGrowSpot {
  openGround,
  pot,
  raisedBed,
  balcony,
  greenhouse,
  indoor,
}

class LocationListItem {
  const LocationListItem(
    this.text, {
    this.marker = LocationSuitabilityMarker.check,
  });

  final String text;
  final LocationSuitabilityMarker marker;
}

class LocationSunCard {
  const LocationSunCard({
    required this.level,
    required this.label,
    required this.status,
    this.highlighted = false,
  });

  final LocationSunLevel level;
  final String label;
  final String status;
  final bool highlighted;
}

class LocationSpotCard {
  const LocationSpotCard({
    required this.spot,
    required this.label,
    required this.status,
    required this.suitability,
    this.illustration,
  });

  final LocationGrowSpot spot;
  final String label;
  final String status;
  final LocationSuitabilityMarker suitability;
  final PlantLocationIllustration? illustration;
}

class LocationDimension {
  const LocationDimension({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;
}

class LocationHumidityOption {
  const LocationHumidityOption({
    required this.drops,
    required this.label,
    this.selected = false,
  });

  final int drops;
  final String label;
  final bool selected;
}

class LocationInfoTip {
  const LocationInfoTip({required this.body});

  final String body;
}

class PlantLocationSection {
  const PlantLocationSection({
    this.title = '',
    this.subtitle,
    this.summary,
    this.items,
    this.dimensions,
    this.illustration,
    this.illustrationSize = LocationIllustrationSize.normal,
    this.infoTip,
    this.sunCards,
    this.spotCards,
    this.humidityOptions,
    this.iconLabels,
    this.illustrationFirst = false,
    this.details = const [],
  });

  final String title;
  final String? subtitle;
  final String? summary;
  final List<LocationListItem>? items;
  final List<LocationDimension>? dimensions;
  final PlantLocationIllustration? illustration;
  final LocationIllustrationSize illustrationSize;
  final LocationInfoTip? infoTip;
  final List<LocationSunCard>? sunCards;
  final List<LocationSpotCard>? spotCards;
  final List<LocationHumidityOption>? humidityOptions;
  final List<LocationListItem>? iconLabels;
  final bool illustrationFirst;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => title.isNotEmpty && details.isNotEmpty;
}

enum PlantLocationRowKind {
  single,
  split,
  columns2,
  columns2Compact,
  sunExposure,
  locationGrid,
  humidityRow,
  imageBelow,
}

class PlantLocationRow {
  const PlantLocationRow({
    required this.kind,
    required this.sections,
  });

  final PlantLocationRowKind kind;
  final List<PlantLocationSection> sections;
}

class PlantLocationGuide {
  const PlantLocationGuide({required this.rows});

  final List<PlantLocationRow> rows;
}

PlantLocationGuide locationGuideForVegetable(Vegetable vegetable) {
  final built = _buildLocationGuide(vegetable);
  if (isFlowerGuidePlant(vegetable.id)) return built;
  return PlantLocationGuide(
    rows: [
      for (final row in built.rows)
        PlantLocationRow(
          kind: row.kind,
          sections: [
            for (final s in row.sections)
              PlantLocationSection(
                title: s.title,
                subtitle: s.subtitle,
                summary: s.title.isEmpty
                    ? s.summary
                    : cropCardSummaryFor(
                        tab: 'location',
                        title: s.title,
                        vegetable: vegetable,
                      ),
                items: s.items,
                dimensions: s.dimensions,
                illustration: s.illustration,
                illustrationSize: s.illustrationSize,
                infoTip: s.infoTip,
                sunCards: s.sunCards,
                spotCards: s.spotCards,
                humidityOptions: s.humidityOptions,
                iconLabels: s.iconLabels,
                illustrationFirst: s.illustrationFirst,
                details: s.details,
              ),
          ],
        ),
    ],
  );
}

enum _SpotFit { good, limited, bad }

LocationSuitabilityMarker _markerForFit(_SpotFit fit) {
  switch (fit) {
    case _SpotFit.good:
      return LocationSuitabilityMarker.check;
    case _SpotFit.limited:
      return LocationSuitabilityMarker.warning;
    case _SpotFit.bad:
      return LocationSuitabilityMarker.cross;
  }
}

String _statusForFit(_SpotFit fit) {
  switch (fit) {
    case _SpotFit.good:
      return 'Geschikt';
    case _SpotFit.limited:
      return 'Beperkt';
    case _SpotFit.bad:
      return 'Ongeschikt';
  }
}

Map<String, _SpotFit> _growSpotSuitability(Vegetable v) {
  final blob =
      '${v.care} ${v.sowingIndoors} ${v.transplant} ${v.sunRequirement}'
          .toLowerCase();
  return {
    'Volle grond': blob.contains('pot alleen') ? _SpotFit.limited : _SpotFit.good,
    'Pot': blob.contains('pot') || v.spacingCm <= 35
        ? _SpotFit.good
        : _SpotFit.limited,
    'Verhoogde bak': _SpotFit.good,
    'Balkon': v.spacingCm <= 40 && !blob.contains('boom')
        ? _SpotFit.good
        : _SpotFit.limited,
    'Kas': blob.contains('kas') ||
            blob.contains('tunnel') ||
            blob.contains('serre')
        ? _SpotFit.good
        : _SpotFit.limited,
    'Binnen': blob.contains('binnen') || blob.contains('vensterbank')
        ? _SpotFit.limited
        : _SpotFit.bad,
  };
}

List<LocationSunCard> _sunCardsFor(Vegetable v) {
  final sun = classifySun(v.sunRequirement);
  return [
    LocationSunCard(
      level: LocationSunLevel.fullSun,
      label: 'Volle zon',
      status: sun == SunFilter.fullSun ? 'Beste keuze' : 'Geschikt',
      highlighted: sun == SunFilter.fullSun,
    ),
    LocationSunCard(
      level: LocationSunLevel.partialShade,
      label: 'Halfschaduw',
      status: sun == SunFilter.partialShade ? 'Beste keuze' : 'Geschikt',
      highlighted: sun == SunFilter.partialShade,
    ),
    const LocationSunCard(
      level: LocationSunLevel.lightShade,
      label: 'Lichte schaduw',
      status: 'Mogelijk',
    ),
    LocationSunCard(
      level: LocationSunLevel.shade,
      label: 'Schaduw',
      status: sun == SunFilter.shade ? 'Mogelijk' : 'Niet aanbevolen',
      highlighted: sun == SunFilter.shade,
    ),
  ];
}

List<LocationDimension> _dimensionsFor(Vegetable v) {
  final cat = v.growthCategory?.toLowerCase() ?? '';
  String height;
  String width;
  String root;

  if (cat.contains('boom') || cat.contains('fruit (boom)')) {
    height = '2 – 6 m';
    width = '2 – 4 m';
    root = '60 – 100 cm';
  } else if (cat.contains('kruiden') || v.spacingCm <= 30) {
    height = '20 – 60 cm';
    width = '20 – 40 cm';
    root = '15 – 25 cm';
  } else if (v.spacingCm >= 80) {
    height = '80 – 200 cm';
    width = '${v.spacingCm} – ${v.rowSpacingCm} cm';
    root = '30 – 50 cm';
  } else {
    height = '60 – 120 cm';
    width = '${v.spacingCm} – ${v.rowSpacingCm} cm';
    root = '25 – 40 cm';
  }

  return [
    LocationDimension(label: 'Hoogte', value: height),
    LocationDimension(label: 'Breedte', value: width),
    LocationDimension(label: 'Worteldiepte', value: root),
  ];
}

bool _isFrostSensitive(Vegetable v) {
  final blob =
      '${v.commonIssues} ${v.care} ${v.transplant} ${v.sowingOutdoors}'.toLowerCase();
  return blob.contains('vorst') ||
      blob.contains('winterhard') ||
      blob.contains('ijsheiligen');
}

LocationSpotCard _spotCard(
  LocationGrowSpot spot,
  String label,
  _SpotFit fit,
  PlantLocationIllustration illustration,
) {
  return LocationSpotCard(
    spot: spot,
    label: label,
    status: _statusForFit(fit),
    suitability: _markerForFit(fit),
    illustration: illustration,
  );
}

PlantLocationGuide _buildLocationGuide(Vegetable v) {
  if (isFlowerGuidePlant(v.id)) {
    return _buildFlowerLocationGuide(v);
  }
  final p = cropProfileFor(v.id);
  final ov = vegetableOverviewFactsFor(v.id);
  final sunText =
      (ov?.standplaats ?? v.sunRequirement).trim().isNotEmpty
          ? (ov?.standplaats ?? v.sunRequirement).trim()
          : 'Zon';
  final spots = _growSpotSuitability(v);
  final frostSensitive =
      cropFrostSensitiveFor(v.id) || _isFrostSensitive(v);
  final kasSuit = p.kasPreferred
      ? _SpotFit.good
      : (spots['Kas'] ?? _SpotFit.limited);
  final buitenSuit = spots['Volle grond'] ?? _SpotFit.good;
  final binnenSuit = p.indoorSuitable
      ? _SpotFit.good
      : (spots['Binnen'] ?? _SpotFit.bad);
  final name = v.nameNl;
  final spacing = ov?.plantSpacing ?? '${v.spacingCm} cm';
  final row = ov?.rowSpacing ?? '${v.rowSpacingCm} cm';
  final height = ov?.height ?? _dimensionsFor(v).first.value;
  final width = ov?.width ?? _dimensionsFor(v)[1].value;
  final gap = p.note;

  return PlantLocationGuide(
    rows: [
      PlantLocationRow(
        kind: PlantLocationRowKind.sunExposure,
        sections: [
          PlantLocationSection(
            title: 'Ideale standplaats',
            subtitle: 'De beste plek voor deze plant.',
            summary: sunText,
            sunCards: _sunCardsFor(v),
            details: guideDetailBlocks(
              meaning:
                  'De ideale standplaats combineert licht, beschutting en grondtype zodat $name goed aanslaat en productief blijft.',
              why:
                  'Te weinig licht geeft slapte en minder oogst; te veel wind of kou remt groei. Voor $name: $sunText.',
              how:
                  'Kies een plek met ${p.sunHoursIdeal} zon (min. ${p.sunHoursMin}). Outdoor: ${ov?.locatieOutdoor ?? 'buiten/kas volgens overzicht'}. Container: ${ov?.locatieContainer ?? 'pot of volle grond'}.',
              tip:
                  'Vermijd koude laagtes en harde tocht. ${p.kasPreferred ? 'Kas of tunnel helpt in NL.' : 'Buiten lukt vaak goed met de juiste plek.'}',
              extra: gap,
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Zonuren per dag',
            subtitle: 'Hoeveel zonlicht heeft deze plant nodig?',
            items: [
              LocationListItem('Aanbevolen: ${p.sunHoursIdeal}'),
              LocationListItem('Minimum: ${p.sunHoursMin}'),
            ],
            summary:
                '${p.sunHoursIdeal} ideaal · minder zon = trager en minder oogst.',
            illustration: PlantLocationIllustration.sunHours,
            details: guideDetailBlocks(
              meaning:
                  'Zonuren bepalen fotosynthese, warmte en dus groeisnelheid en smaak.',
              why:
                  'Onder het minimum blijft $name vegetatief zwak. Ideaal ${p.sunHoursIdeal}; minimum ${p.sunHoursMin}.',
              how:
                  'Observeer de plek om 10:00, 13:00 en 16:00. Tel uren directe zon. Pas standplaats of potpositie aan.',
              tip:
                  'In de zomer verdraagt bladgewas soms halfschaduw; vruchtgewassen willen meestal volle zon.',
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.locationGrid,
        sections: [
          PlantLocationSection(
            title: 'Geschikte locaties',
            subtitle: 'Waar kan deze plant het beste groeien?',
            summary:
                'Volle grond, pot, bak, balkon, kas of binnen — per plek verschillend geschikt.',
            spotCards: [
              _spotCard(
                LocationGrowSpot.openGround,
                'Volle grond',
                spots['Volle grond']!,
                PlantLocationIllustration.openGround,
              ),
              _spotCard(
                LocationGrowSpot.pot,
                'Pot',
                spots['Pot']!,
                PlantLocationIllustration.pot,
              ),
              _spotCard(
                LocationGrowSpot.raisedBed,
                'Verhoogde bak',
                spots['Verhoogde bak']!,
                PlantLocationIllustration.raisedBed,
              ),
              _spotCard(
                LocationGrowSpot.balcony,
                'Balkon',
                spots['Balkon']!,
                PlantLocationIllustration.balcony,
              ),
              _spotCard(
                LocationGrowSpot.greenhouse,
                'Kas',
                kasSuit,
                PlantLocationIllustration.greenhouse,
              ),
              _spotCard(
                LocationGrowSpot.indoor,
                'Binnen',
                binnenSuit,
                PlantLocationIllustration.indoor,
              ),
            ],
            details: guideDetailBlocks(
              meaning:
                  'Niet elke teeltplek past: volume, warmte, drainage en licht verschillen sterk.',
              why:
                  'Potten warmen sneller op maar drogen sneller. Kas geeft warmte. Binnen mist vaak licht voor $name.',
              how:
                  'Volle grond: ${ov?.locatieOutdoor ?? 'standaard buiten'}. Container: ${ov?.locatieContainer ?? 'zie overzicht'}. Kas: ${p.kasPreferred ? 'sterk aanbevolen' : 'optioneel'}. Binnen: ${p.indoorSuitable ? 'mogelijk met veel licht' : 'meestal niet ideaal'}.',
              tip:
                'Kies potvolume groter dan de kluit verwacht; kleine potten stressen sneller.',
              extra: gap,
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Benodigde ruimte',
            subtitle: 'Geef deze plant voldoende ruimte om te groeien.',
            summary: 'Hoogte $height · breedte $width.',
            dimensions: [
              LocationDimension(label: 'Hoogte', value: height),
              LocationDimension(label: 'Breedte', value: width),
              LocationDimension(
                label: 'Worteldiepte',
                value: _dimensionsFor(v).last.value,
              ),
            ],
            illustration: PlantLocationIllustration.spaceDimensions,
            infoTip: const LocationInfoTip(
              body:
                  'Geef de plant genoeg groeiruimte voor een gezonde ontwikkeling.',
            ),
            illustrationFirst: true,
            details: guideDetailBlocks(
              meaning:
                  'Ruimte is hoogte, breedte én worteldiepte — niet alleen plantafstand.',
              why:
                  'Te krap: concurrentie, schimmel, zwakke planten. Habitus: ${ov?.growthHabit ?? p.growthHabit}.',
              how:
                  'Reserveer ca. $height hoogte en $width breedte. Plantafstand $spacing; rijafstand $row.',
              tip:
                  'Hoge gewassen: denk aan schaduw op buren. Rankers: latwerk spaart grondoppervlak.',
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.columns2Compact,
        sections: [
          PlantLocationSection(
            title: 'Plantafstand',
            summary: '$spacing tussen planten · luchtcirculatie.',
            illustration: PlantLocationIllustration.plantSpacing,
            illustrationSize: LocationIllustrationSize.compact,
            details: guideDetailBlocks(
              meaning: 'Hart-op-hart afstand tussen planten in de rij of in het vak.',
              why:
                  'Voldoende afstand beperkt concurrentie en ziekte bij $name.',
              how: 'Houd ongeveer $spacing hart-op-hart (uit overzicht/afmetingen).',
              tip:
                  'In bakken iets dichter bij bladgewassen; vruchtgewassen liever ruimer.',
            ),
          ),
          PlantLocationSection(
            title: 'Rijafstand',
            summary: '$row tussen rijen · pad en licht.',
            illustration: PlantLocationIllustration.rowSpacing,
            illustrationSize: LocationIllustrationSize.compact,
            details: guideDetailBlocks(
              meaning: 'Ruimte tussen evenwijdige rijen voor pad, lucht en licht.',
              why: 'Je kunt wieden/oogsten zonder planten te vertrappen.',
              how: 'Mik op ongeveer $row tussen rijen.',
              tip:
                  'Vierkante-meter-teelt: blokken i.p.v. lange rijen, wel plantafstand aanhouden.',
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Windgevoeligheid',
            subtitle: 'Hoe gevoelig is deze plant voor wind?',
            summary: 'Windgevoeligheid: ${p.windSensitivity}.',
            illustration: PlantLocationIllustration.wind,
            illustrationFirst: true,
            items: [
              LocationListItem(
                p.windSensitivity.toLowerCase().contains('laag')
                    ? 'Relatief windbestendig'
                    : 'Beschutting vaak nuttig',
              ),
              LocationListItem(
                'Beschutte plek aanbevolen',
                marker: LocationSuitabilityMarker.warning,
              ),
              LocationListItem(
                p.windSensitivity.toLowerCase().contains('hoog')
                    ? 'Gevoelig voor harde wind'
                    : 'Harde wind vermijden bij jonge planten',
                marker: LocationSuitabilityMarker.cross,
              ),
            ],
            details: guideDetailBlocks(
              meaning:
                  'Wind droogt blad uit, knakt stengels en koelt de plant af.',
              why:
                  'Voor $name is windgevoeligheid ${p.windSensitivity}. ${p.supportNeeded == 'Ja' || p.supportNeeded.toLowerCase().startsWith('ja') ? p.supportHow : 'Jonge planten zijn altijd kwetsbaarder.'}',
              how:
                  'Plant beschut bij haag/muur (niet té dicht voor licht). Zet steun vroeg. Gebruik tijdelijk windscherm na uitplanten.',
              tip: 'Potten waaien om: zware pot of vastzetten.',
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Temperatuur',
            subtitle: 'Ideale temperaturen voor groei.',
            summary: 'Ideaal ${p.tempIdeal}.',
            illustration: PlantLocationIllustration.temperature,
            illustrationSize: LocationIllustrationSize.inline,
            illustrationFirst: true,
            items: [
              LocationListItem('Ideaal: ${p.tempIdeal}'),
              LocationListItem('Minimum: ${p.tempMin}'),
              LocationListItem(
                'Maximum: ${p.tempMax}',
                marker: LocationSuitabilityMarker.cross,
              ),
            ],
            infoTip: LocationInfoTip(
              body:
                  'Buiten ${p.tempIdeal} kan groei stagneren of schade ontstaan.',
            ),
            details: guideDetailBlocks(
              meaning:
                  'Bodem- en luchttemperatuur sturen kieming, groei en vruchtzetting.',
              why:
                  '$name groeit het best bij ${p.tempIdeal}. Onder ${p.tempMin} stopt groei vaak; boven ${p.tempMax} stress/bloemval.',
              how:
                  'Gebruik kas/vlies bij kou. Bij hitte: schaduwdoek, water, ventilatie.',
              tip: 'Bodemthermometer helpt bij voorjaar-uitplant.',
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.imageBelow,
        sections: [
          PlantLocationSection(
            title: 'Vorstgevoeligheid',
            subtitle: 'Hoe goed kan deze plant tegen kou?',
            summary: frostSensitive
                ? 'Vorstgevoelig — bescherm of wacht op milde nachten.'
                : 'Redelijk koudeverdraagzaam; check ras en regio.',
            illustration: PlantLocationIllustration.frost,
            illustrationSize: LocationIllustrationSize.large,
            items: [
              LocationListItem(
                frostSensitive ? 'Niet winterhard als eenjarige teelt' : 'Kan koel weer aan',
              ),
              LocationListItem(
                frostSensitive
                    ? 'Licht tot sterk gevoelig voor vorst'
                    : 'Redelijk vorstbestendig',
                marker: frostSensitive
                    ? LocationSuitabilityMarker.warning
                    : LocationSuitabilityMarker.check,
              ),
              LocationListItem(
                frostSensitive
                    ? 'Vorstgevoelig'
                    : 'Kan lichte vorst verdragen',
                marker: frostSensitive
                    ? LocationSuitabilityMarker.cross
                    : LocationSuitabilityMarker.check,
              ),
            ],
            infoTip: LocationInfoTip(
              body: frostSensitive
                  ? p.protectCold
                  : 'Controleer vorstgevoeligheid per ras en regio.',
            ),
            details: guideDetailBlocks(
              meaning:
                  'Vorst beschadigt celvocht in blad en stengel; jonge planten zijn het kwetsbaarst.',
              why: frostSensitive
                  ? '$name is vorstgevoelig. Te vroeg buiten zetten geeft uitval.'
                  : '$name verdraagt koel weer beter, maar natte kou remt nog steeds wortels.',
              how: p.protectCold,
              tip:
                  'Liever een week later dan één nacht te vroeg. Kas/tunnel geeft voorsprong.',
              extra: gap,
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.humidityRow,
        sections: [
          PlantLocationSection(
            title: 'Luchtvochtigheid',
            subtitle: 'Hoeveel luchtvochtigheid heeft deze plant nodig?',
            summary: 'Richtlijn: ${p.humidityLevel}.',
            humidityOptions: [
              LocationHumidityOption(
                drops: 1,
                label: 'Laag',
                selected: p.humidityLevel.toLowerCase().contains('laag'),
              ),
              LocationHumidityOption(
                drops: 2,
                label: 'Gemiddeld',
                selected: p.humidityLevel.toLowerCase().contains('gemiddeld'),
              ),
              LocationHumidityOption(
                drops: 3,
                label: 'Hoog',
                selected: p.humidityLevel.toLowerCase().contains('hoog'),
              ),
            ],
            infoTip: LocationInfoTip(
              body:
                  'Voor $name is ${p.humidityLevel} luchtvochtigheid een goede richtlijn.',
            ),
            details: guideDetailBlocks(
              meaning:
                  'Luchtvochtigheid beïnvloedt verdamping, schimmelrisico en bladcomfort.',
              why:
                  'Te droog: slapte/spint. Te vochtig + stilstaande lucht: schimmel. Richtlijn: ${p.humidityLevel}.',
              how:
                  'Kas: ventileer. Buiten: niet te dicht planten. Besproei blad alleen als de soort dat verdraagt (vaak liever niet ’s avonds).',
              tip: p.greenhouseCare,
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Kas of Buiten',
            subtitle: 'Waar groeit deze plant het beste?',
            illustration: PlantLocationIllustration.greenhouseOutdoor,
            iconLabels: const [
              LocationListItem('Kas'),
              LocationListItem('Buiten'),
            ],
            summary: p.kasPreferred
                ? 'Kas of tunnel past vaak het best in NL.'
                : kasSuit == _SpotFit.good && buitenSuit == _SpotFit.good
                    ? 'Kan zowel in de kas als buiten groeien.'
                    : 'Meestal geschikt voor buiten of volle grond.',
            details: guideDetailBlocks(
              meaning:
                  'Kas geeft warmte en seizoensverlenging; buiten geeft licht en lucht.',
              why: p.kasPreferred
                  ? '$name is warmteminnend; in NL geeft kas betrouwbaardere oogst.'
                  : '$name doet het vaak goed buiten bij juiste standplaats.',
              how:
                  'Buiten: ${ov?.locatieOutdoor ?? 'volle grond/bak'}. Kas: ventileer overdag, bescherm tegen nachtkou.',
              tip: p.greenhouseCare,
            ),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.imageBelow,
        sections: [
          PlantLocationSection(
            title: 'Binnen kweken',
            subtitle: 'Is deze plant geschikt om binnen te kweken?',
            summary: p.indoorSuitable
                ? 'Mogelijk met veel licht (venster/kweeklamp).'
                : 'Meestal niet ideaal op lange termijn.',
            illustration: PlantLocationIllustration.indoorGrowing,
            illustrationSize: LocationIllustrationSize.large,
            items: [
              LocationListItem(
                binnenSuit == _SpotFit.good
                    ? 'Geschikt'
                    : 'Beperkt geschikt',
                marker: binnenSuit == _SpotFit.bad
                    ? LocationSuitabilityMarker.cross
                    : LocationSuitabilityMarker.check,
              ),
              const LocationListItem(
                'Tijdelijk mogelijk',
                marker: LocationSuitabilityMarker.warning,
              ),
              LocationListItem(
                binnenSuit == _SpotFit.bad
                    ? 'Niet geschikt'
                    : 'Niet ideaal op lange termijn',
                marker: binnenSuit == _SpotFit.bad
                    ? LocationSuitabilityMarker.cross
                    : LocationSuitabilityMarker.warning,
              ),
            ],
            infoTip: LocationInfoTip(
              body: p.indoorSuitable
                  ? 'Zet op de lichtste plek; draai de pot regelmatig.'
                  : 'Binnen kweken is voor $name meestal alleen tijdelijk (opkweek).',
            ),
            details: guideDetailBlocks(
              meaning:
                  'Binnen mist vaak lichtintensiteit en luchtvochtigheid van buiten/kas.',
              why: p.indoorSuitable
                  ? 'Kruiden en kiemen kunnen binnen; $name kan met genoeg licht.'
                  : 'De meeste groenten blijven binnen zwak of ziek zonder kweeklamp.',
              how:
                  'Zuidenraam of kweeklamp 12–16 u. Goede potgrond en drainage. ${p.potCare}',
              tip: 'Opkweek binnen → afharden → buiten/kas is vaak beter dan permanent binnen.',
              extra: gap,
            ),
          ),
        ],
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Flower-specific location guide
// ---------------------------------------------------------------------------

PlantLocationGuide _buildFlowerLocationGuide(Vegetable v) {
  final fp = flowerGuideProfileFor(v.id);
  String sum(String title) => flowerCardSummaryFor(
        tab: 'location',
        title: title,
        vegetable: v,
        profile: fp,
      );
  final ov = vegetableOverviewFactsFor(v.id);
  final spots = _growSpotSuitability(v);
  final frostSensitive = fp.frostSensitive;
  final kasSuit = spots['Kas'] ?? _SpotFit.limited;
  final binnenSuit = spots['Binnen'] ?? _SpotFit.bad;
  final name = v.nameNl;
  final height = ov?.height ?? _dimensionsFor(v).first.value;
  final width = ov?.width ?? _dimensionsFor(v)[1].value;

  List<PlantGuideDetailBlock> fd(String title) =>
      flowerSectionDetailsFor(
        tab: 'location',
        title: title,
        vegetable: v,
        profile: fp,
      );

  return PlantLocationGuide(
    rows: [
      PlantLocationRow(
        kind: PlantLocationRowKind.sunExposure,
        sections: [
          PlantLocationSection(
            title: 'Ideale standplaats',
            subtitle: 'De beste plek voor deze bloem.',
            summary: sum('Ideale standplaats'),
            sunCards: _sunCardsFor(v),
            details: fd('Ideale standplaats'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Zonuren per dag',
            subtitle: 'Hoeveel zonlicht heeft deze bloem nodig?',
            items: [
              LocationListItem('Aanbevolen: ${fp.sunHoursIdeal}'),
              LocationListItem('Minimum: ${fp.sunHoursMin}'),
            ],
            summary: sum('Zonuren per dag'),
            illustration: PlantLocationIllustration.sunHours,
            details: fd('Zonuren per dag'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.locationGrid,
        sections: [
          PlantLocationSection(
            title: 'Geschikte locaties',
            subtitle: 'Waar kan deze bloem het beste groeien?',
            summary: sum('Geschikte locaties'),
            spotCards: [
              _spotCard(
                LocationGrowSpot.openGround,
                'Volle grond',
                spots['Volle grond']!,
                PlantLocationIllustration.openGround,
              ),
              _spotCard(
                LocationGrowSpot.pot,
                'Pot',
                spots['Pot']!,
                PlantLocationIllustration.pot,
              ),
              _spotCard(
                LocationGrowSpot.raisedBed,
                'Verhoogde bak',
                spots['Verhoogde bak']!,
                PlantLocationIllustration.raisedBed,
              ),
              _spotCard(
                LocationGrowSpot.balcony,
                'Balkon',
                spots['Balkon']!,
                PlantLocationIllustration.balcony,
              ),
              _spotCard(
                LocationGrowSpot.greenhouse,
                'Kas',
                kasSuit,
                PlantLocationIllustration.greenhouse,
              ),
              _spotCard(
                LocationGrowSpot.indoor,
                'Binnen',
                binnenSuit,
                PlantLocationIllustration.indoor,
              ),
            ],
            details: fd('Geschikte locaties'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Benodigde ruimte',
            subtitle: 'Geef deze bloem voldoende ruimte om te groeien.',
            summary: sum('Benodigde ruimte'),
            dimensions: [
              LocationDimension(label: 'Hoogte', value: height),
              LocationDimension(label: 'Breedte', value: width),
              LocationDimension(
                label: 'Worteldiepte',
                value: _dimensionsFor(v).last.value,
              ),
            ],
            illustration: PlantLocationIllustration.spaceDimensions,
            infoTip: const LocationInfoTip(
              body:
                  'Geef de bloem genoeg ruimte voor goede luchtcirculatie en bloei.',
            ),
            illustrationFirst: true,
            details: fd('Benodigde ruimte'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.columns2Compact,
        sections: [
          PlantLocationSection(
            title: 'Plantafstand',
            summary: sum('Plantafstand'),
            illustration: PlantLocationIllustration.plantSpacing,
            illustrationSize: LocationIllustrationSize.compact,
            details: fd('Plantafstand'),
          ),
          PlantLocationSection(
            title: 'Rijafstand',
            summary: sum('Rijafstand'),
            illustration: PlantLocationIllustration.rowSpacing,
            illustrationSize: LocationIllustrationSize.compact,
            details: fd('Rijafstand'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Windgevoeligheid',
            subtitle: 'Hoe gevoelig is deze bloem voor wind?',
            summary: sum('Windgevoeligheid'),
            illustration: PlantLocationIllustration.wind,
            illustrationFirst: true,
            items: [
              LocationListItem(fp.supportAdvice),
              const LocationListItem(
                'Beschutte plek aanbevolen',
                marker: LocationSuitabilityMarker.warning,
              ),
              LocationListItem(
                'Harde wind: knakgevaar bij hoge stengels',
                marker: LocationSuitabilityMarker.cross,
              ),
            ],
            details: fd('Windgevoeligheid'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Temperatuur',
            subtitle: 'Ideale temperaturen voor bloei.',
            summary: sum('Temperatuur'),
            illustration: PlantLocationIllustration.temperature,
            illustrationSize: LocationIllustrationSize.inline,
            illustrationFirst: true,
            items: [
              LocationListItem(
                fp.frostSensitive
                    ? 'Niet vóór half mei uitplanten'
                    : 'Vroeg uitplanten mogelijk',
              ),
              LocationListItem(
                fp.winterHardy ? 'Winterhard' : 'Niet winterhard',
                marker: fp.winterHardy
                    ? LocationSuitabilityMarker.check
                    : LocationSuitabilityMarker.warning,
              ),
            ],
            infoTip: LocationInfoTip(
              body: fp.frostSensitive
                  ? 'Wacht op stabiel weer na IJsheiligen (± 15 mei). Late nachtvorst komt in NL nog regelmatig voor.'
                  : 'Redelijk koudeverdraagzaam; bescherm bij strenge vorst.',
            ),
            details: fd('Temperatuur'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.imageBelow,
        sections: [
          PlantLocationSection(
            title: 'Vorstgevoeligheid',
            subtitle: 'Hoe goed kan deze bloem tegen kou?',
            summary: sum('Vorstgevoeligheid'),
            illustration: PlantLocationIllustration.frost,
            illustrationSize: LocationIllustrationSize.large,
            items: [
              LocationListItem(
                frostSensitive
                    ? 'Gevoelig voor (nacht)vorst'
                    : fp.winterHardy
                        ? 'Winterhard'
                        : 'Kan koel weer aan',
              ),
              LocationListItem(
                frostSensitive
                    ? 'Na IJsheiligen (± 15 mei) veilig'
                    : 'Verdraagt milde voorjaarskou',
                marker: frostSensitive
                    ? LocationSuitabilityMarker.warning
                    : LocationSuitabilityMarker.check,
              ),
              LocationListItem(
                fp.winterAdvice,
                marker: frostSensitive
                    ? LocationSuitabilityMarker.cross
                    : LocationSuitabilityMarker.check,
              ),
            ],
            infoTip: LocationInfoTip(
              body: frostSensitive
                  ? 'Natte nachtvorst is in NL de grootste killer. Vliesdoek helpt bij late vorst.'
                  : 'Goed afwaterende grond is belangrijker dan vorst bij winterharde bloemen.',
            ),
            details: fd('Vorstgevoeligheid'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.humidityRow,
        sections: [
          PlantLocationSection(
            title: 'Luchtvochtigheid',
            subtitle: 'Hoeveel luchtvochtigheid heeft deze bloem nodig?',
            summary: sum('Luchtvochtigheid'),
            humidityOptions: [
              LocationHumidityOption(
                drops: 1,
                label: 'Laag',
                selected: fp.droughtResistant,
              ),
              LocationHumidityOption(
                drops: 2,
                label: 'Gemiddeld',
                selected: !fp.droughtResistant && !fp.waterNeed.toLowerCase().contains('veel'),
              ),
              LocationHumidityOption(
                drops: 3,
                label: 'Hoog',
                selected: fp.waterNeed.toLowerCase().contains('veel'),
              ),
            ],
            infoTip: LocationInfoTip(
              body: fp.droughtResistant
                  ? 'Droogtetolerante bloemen doen het beter bij lagere luchtvochtigheid. Natte lucht bevordert schimmel.'
                  : 'Gemiddelde vochtigheid is prima. Vermijd stilstaande vochtige lucht bij dichte beplanting.',
            ),
            details: fd('Luchtvochtigheid'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.split,
        sections: [
          PlantLocationSection(
            title: 'Kas of Buiten',
            subtitle: 'Waar groeit deze bloem het beste?',
            illustration: PlantLocationIllustration.greenhouseOutdoor,
            iconLabels: const [
              LocationListItem('Kas'),
              LocationListItem('Buiten'),
            ],
            summary: sum('Kas of Buiten'),
            details: fd('Kas of Buiten'),
          ),
        ],
      ),
      PlantLocationRow(
        kind: PlantLocationRowKind.imageBelow,
        sections: [
          PlantLocationSection(
            title: 'Binnen kweken',
            subtitle: 'Is deze bloem geschikt om binnen te kweken?',
            summary: sum('Binnen kweken'),
            illustration: PlantLocationIllustration.indoorGrowing,
            illustrationSize: LocationIllustrationSize.large,
            items: [
              LocationListItem(
                binnenSuit == _SpotFit.good
                    ? 'Geschikt'
                    : 'Beperkt geschikt',
                marker: binnenSuit == _SpotFit.bad
                    ? LocationSuitabilityMarker.cross
                    : LocationSuitabilityMarker.check,
              ),
              const LocationListItem(
                'Opkweek binnen mogelijk',
                marker: LocationSuitabilityMarker.warning,
              ),
              LocationListItem(
                binnenSuit == _SpotFit.bad
                    ? 'Niet geschikt voor permanente binnenteelt'
                    : 'Langdurig binnen vraagt kweeklamp',
                marker: binnenSuit == _SpotFit.bad
                    ? LocationSuitabilityMarker.cross
                    : LocationSuitabilityMarker.warning,
              ),
            ],
            infoTip: LocationInfoTip(
              body: binnenSuit != _SpotFit.bad
                  ? 'Zet op de lichtste plek; draai de pot regelmatig.'
                  : 'Binnen kweken lukt voor $name alleen als opkweek. Plant na afharden buiten.',
            ),
            details: fd('Binnen kweken'),
          ),
        ],
      ),
    ],
  );
}
