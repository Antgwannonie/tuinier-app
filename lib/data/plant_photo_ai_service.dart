import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'plant_ai_insight_mapper.dart';
import 'plant_ai_insight_prompt.dart';
import 'plant_scan_consistency.dart';
import 'planting_timing_advice.dart';
import 'crop_harvest_kind.dart';
import 'underground_crop.dart';

class PlantPhotoAiException implements Exception {
  PlantPhotoAiException(this.message);
  final String message;

  @override
  String toString() => message;
}

/// Analyseert een plantfoto via Google Gemini Vision.
class PlantPhotoAiService {
  const PlantPhotoAiService({required this.apiKey});

  final String apiKey;

  static const _models = [
    'gemini-2.5-flash',
    'gemini-2.0-flash',
    'gemini-2.5-flash-lite',
  ];

  Future<PlantAiAnalysis> analyze({
    required List<int> imageBytes,
    required String mimeType,
    required Vegetable vegetable,
    DateTime? plantedAt,
    bool plantingDateUnknown = false,
    String? locationLabel,
    String? sunLabel,
    bool outsidePlantingSeason = false,
    String? plantWindowLabel,
    String? harvestWindowLabel,
    int? daysSinceStatedPlantDate,
    PlantAiAnalysis? previousAnalysis,
    String? previousImageFingerprint,
    bool isFirstScan = false,
    bool isHarvestProbePhoto = false,
  }) async {
    final firstScan = isFirstScan || previousAnalysis == null;
    if (apiKey.trim().isEmpty) {
      throw PlantPhotoAiException(
        'Voeg eerst een Gemini API-sleutel toe (gratis via Google AI Studio).',
      );
    }

    final planted = plantingDateUnknown
        ? 'ONBEKEND (gebruiker weet zaaidatum niet; datum in app is niet de zaaidatum)'
        : plantedAt != null
            ? '${plantedAt.day}-${plantedAt.month}-${plantedAt.year}'
            : 'onbekend';
    final previousSection = previousAnalysis != null
        ? buildPreviousScanPromptSection(previousAnalysis)
        : '';
    final calPlant = plantWindowLabel ?? '—';
    final calHarvest = harvestWindowLabel ?? '—';
    final daysSince = plantingDateUnknown
        ? null
        : daysSinceStatedPlantDate ??
            (plantedAt != null
                ? DateTime.now()
                    .difference(
                      DateTime(
                        plantedAt.year,
                        plantedAt.month,
                        plantedAt.day,
                      ),
                    )
                    .inDays
                : null);
    final weeksSinceStated = daysSince != null ? (daysSince / 7).round() : null;

    final seasonNote = plantingDateUnknown
        ? 'Zaaidatum ONBEKEND: vergelijk GEEN zaaidatum met foto. Schat alleen leeftijd op de foto (estimatedWeeksGrowing). plantedDateMatchesPhoto = null.'
        : outsidePlantingSeason
            ? 'Ingave zaai/plantdatum valt BUITEN het NL-kalenderseizoen. De plant kan al langer in de tuin staan dan de ingevulde datum. Beoordeel op de foto of oogst dit seizoen nog haalbaar is.'
            : 'Zaaidatum valt binnen het kalenderseizoen of er is geen conflict.';

    final underground = isUndergroundCrop(vegetable);
    final ornamentalOnly = isOrnamentalOnlyMoestuinCrop(vegetable);
    final edibleBloom = isEdibleMoestuinBloomCrop(vegetable);
    final ornamentalSection = ornamentalOnly
        ? '''

MOESTUINBLOEM / RANDPLANT (${vegetable.nameNl}):
Dit is GEEN eetbaar groente-oogstgewas. Praat NIET over oogsten als maaltijd of «geoogst».
- harvestReady in insight: ALTIJD false.
- phase: bij bloei "flowering"; NIET "ripe" (tenzij volledig uitgebloeid en seizoen klaar).
- daysUntilHarvest: null.
- harvestWindowLabel: bloei-periode in NL (bv. "in bloei tot eerste vorst"), geen "oogst over X dagen".
- bloomSeasonNote VERPLICHT bij zichtbare bloei (2-3 zinnen NL): hoe de bloei eruitziet, nut voor bijen/insecten, eventueel uitgebloeide bloemen wegknippen.
- insight.summary, advice, ripenessNote: focus op bloei, standplaats, water — niet op oogsten.
- coachTasks: geen kind "harvest".
'''
        : '';
    final edibleBloomSection = edibleBloom
        ? '''

EETBARE MOESTUINBLOEM / KRUID (${vegetable.nameNl}):
De tuinier kan bloemen of blad ETEN én de plant laten bloeien voor insecten — beide zijn oké.
- Vermeld in bloomSeasonNote of ripenessNote dat eetbare delen geplukt kunnen worden (bloemen, blad).
- harvestReady in insight: true alleen als bloemen/blad op de foto duidelijk geschikt lijken om te eten/plukken.
- Zet ook in de tekst dat «Seizoen afronden» mogelijk is zonder te eten (uitbloeien voor bijen).
- phase bij bloei: "flowering"; niet "ripe" tenzij duidelijk uitgebloeid en klaar om op te ruimen.
- daysUntilHarvest: null (geen groente-oogst-countdown).
- harvestWindowLabel: bloei + eventueel «geschikt om te plukken» in NL.
- bloomSeasonNote VERPLICHT bij bloei (2-4 zinnen): bloei, insecten, én of het eetbaar lijkt.
- coachTasks: mag "harvest" alleen als eetbaar plukken; anders water/snoeien/check.
'''
        : '';
    final undergroundSection = underground && isHarvestProbePhoto
        ? '''

PROEFOOGST-FOTO (ondergronds gewas):
De gebruiker trok één ${vegetable.nameNl} uit de grond om te controleren of de oogst rijp is.
- Beoordeel het ZICHTBARE deel (wortel, knol, bol) op de foto — niet alleen blad.
- harvestReady in insight: true alleen als het geoogste deel duidelijk oogstrijp lijkt.
- phase "ripe" alleen bij duidelijke rijpheid; anders almost_ripe of growing met uitleg.
- undergroundHarvestNote: kort NL advies (bijv. nog even laten of nu oogsten).
- Wees conservatief: liever "nog even wachten" dan te vroeg geoogst.
'''
        : underground
            ? '''

ONDERGRONDS GEWAS (${vegetable.nameNl}):
De oogst zit onder de grond. Op een gewone plantfoto zie je die NIET — beoordeel alleen blad en groei boven de grond.
- Zet harvestReady in insight NOOIT op true alleen op basis van bladgroei.
- phase maximaal "almost_ripe" (niet "ripe") tenzij de foto een uitgetrokken wortel/knol toont.
- daysUntilHarvest: ruime schatting op basis van groei + kalender; liever iets later.
- undergroundHarvestNote VERPLICHT (2-4 zinnen NL): leg uit dat oogst misschien kan op basis van de plantgroei, maar dat de tuinier eerst één plant moet uitproberen. Daarna kan een foto van die uitgetrokken proefplant de AI helpen bevestigen of oogsten kan.
- ripenessNote in insight: zelfde boodschap in 1 zin.
'''
            : '';

    final prompt = '''
Je bent een ervaren Nederlandse moestuin-expert. De gebruiker scant onder "${vegetable.nameNl}" in de app — jij moet eerst controleren of de foto WÉL die plant toont.

Gewas in app (verwacht): ${vegetable.nameNl} (${vegetable.nameLatin ?? '—'})
Plantfamilie verwacht: ${vegetable.family}
Zaai/plantdatum gebruiker: $planted
Locatie: ${locationLabel ?? 'onbekend'}
Zon: ${sunLabel ?? 'onbekend'}
Kalender zaai/plant (NL): $calPlant
Kalender oogst (NL): $calHarvest
Buiten zaai/plantseizoen volgens kalender: ${outsidePlantingSeason ? 'ja' : 'nee'}
Dagen sinds ingevulde zaai/plantdatum: ${daysSince ?? 'n.v.t.'} (${weeksSinceStated != null ? '$weeksSinceStated weken' : 'onbekend'})
$seasonNote
Algemene teeltinfo oogst: ${vegetable.harvest}
Teelttijd: ${vegetable.cropDuration ?? 'niet opgegeven'}
$previousSection
${firstScan ? '''
EERSTE SCAN — ZAADBED / GROND (belangrijk):
De gebruiker start de plantgeschiedenis. De foto mag ALLEEN grond, potgrond, zaadbed,
mulch of een lege plantplek tonen — nog géén kiemplant zichtbaar is normaal en gewenst.
- Als je vooral aarde/grond/ritsen/mulch ziet zonder duidelijke plant: matchesSelectedCrop = true
  (het is hun ${vegetable.nameNl}-plek in de tuin, niet "verkeerd gewas").
- detectedPlantLabel: kort NL, bv. "zaadbed / grond" of "plantplek zonder kiemplant".
- phase: seedling
- phaseLabel: "Zaadbed vastgelegd (nog geen kiemplant zichtbaar)" of vergelijkbaar
- advice: bevestig dat de plek is geregistreerd; scan opnieuw zodra er een kiemplant zichtbaar is
- daysUntilHarvest: null, harvestWindowLabel: "nog geen plant zichtbaar"
- Geen cropMismatchWarning bij pure grond-/zaadbedfoto
- plantedDateMatchesPhoto: null (niet beoordelen op blad/grootte)
- confidencePercent: 70–85

Als wél al een kiemplant of jonge ${vegetable.nameNl} zichtbaar is: volg de normale stappen hieronder.

''' : ''}
STAP 1 — IDENTITEIT (ALTIJD EERST, vóór groeifase):
Vergelijk de foto met een echte ${vegetable.nameNl}. Kijk naar:
- bladvorm en bladrand (getand, glad, diep ingesneden?)
- samengesteld vs enkel blad (tomaat = samengesteld; peper = enkel blad)
- stengel (behaard/glad, paars/groen, kantig/rond?)
- typische bloemen/vruchten/kleur
- geur indien af te leiden uit context

matchesSelectedCrop: true ALLEEN als de plant overduidelijk ${vegetable.nameNl} is.
false bij een ANDER gewas (bv. cayennepeper i.p.v. tomaat, komkommer, basilicum, onkruid).
Bij twijfel tussen twee soorten: matchesSelectedCrop = false.
detectedPlantLabel: korte NL naam van wat je écht ziet (bv. "cayennepeper", "tomaat", "onbekende plant").
cropMismatchWarning: bij false VERPLICHT — duidelijke zin, bv. "Dit lijkt geen tomaat maar een cayennepeper. Kies cayennepeper bij het scannen."

Als matchesSelectedCrop = false:
- GEEN groei-/oogstadvies alsof het ${vegetable.nameNl} is
- phaseLabel: "Verkeerd gewas op foto"
- advice: kies het juiste gewas in de app en scan opnieuw
- harvestStillPossibleThisSeason, daysUntilHarvest: null
- zet cropMismatchWarning ook in warnings-array

STAP 2 — alleen als matchesSelectedCrop = true: groeifase en oogst.
VERPLICHT — vergelijk zaaidatum met foto (tenzij zaaidatum ONBEKEND):
1. Welke fase/grootte zie je op de foto?
2. Wat verwacht je na ${weeksSinceStated ?? '?'} weken voor ${vegetable.nameNl} (teelttijd)?
3. plantedDateMatchesPhoto: true als foto binnen ~2 weken past bij de datum, false als plant duidelijk ouder of jonger lijkt, null bij onbekende datum.
4. datePhotoComparisonNote: bij false (of twijfel ≥3 weken) een duidelijke NL zin voor de tuinier, bijv. "Op de foto lijkt de plant 8 weken verder dan je datum van …"; bij true kort bevestigen of null.
5. expectedWeeksFromStatedDate: ${weeksSinceStated ?? 'null'} als getal.
6. estimatedWeeksGrowing: alleen op basis van de foto.
7. Als er een vorige scan is: geef ALTIJD healthComparisonNote + healthImprovedSincePrevious. 
   Als vorige scan plaagsignalen had of warnings bevatte: zet pestLikelyResolvedSincePrevious op true/false.
8. Geef healthTrend als één van: improved | stable | worse | unknown.

Geef ALLEEN geldige JSON (geen markdown) met exact deze velden:
{
  "matchesPreviousScan": <true of false; verplicht als er een vorige scan is, anders false>,
  "comparisonNote": "1 zin: waarom wel/niet dezelfde fase als vorige scan",
  "phase": "seedling|growing|flowering|fruiting|almost_ripe|ripe",
  "phaseLabel": "korte Nederlandse faseomschrijving",
  "daysUntilHarvest": <int of null als al rijp>,
  "harvestWindowLabel": "bijv. over 2 weken of half augustus",
  "confidencePercent": <int 50-95>,
  "advice": "1-3 zinnen praktisch advies in het Nederlands",
  "warnings": ["alleen ziektes/plagen/urgent — geen seizoens- of datum-meldingen hier"],
  "harvestStillPossibleThisSeason": <true|false|null>,
  "seasonTimingWarning": <korte NL zin of null>,
  "estimatedWeeksGrowing": <int of null>,
  "plantedDateMatchesPhoto": <true|false|null>,
  "datePhotoComparisonNote": <NL zin of null>,
  "expectedWeeksFromStatedDate": <int of null>,
  "matchesSelectedCrop": <true|false>,
  "detectedPlantLabel": <NL naam op foto of null>,
  "cropMismatchWarning": <NL zin of null>,
  "healthImprovedSincePrevious": <true|false|null>,
  "pestLikelyResolvedSincePrevious": <true|false|null>,
  "healthComparisonNote": <NL zin of null>,
  "healthTrend": <"improved"|"stable"|"worse"|"unknown">,
  "photoShowsPlantingBedOnly": <true als alleen grond/zaadbed zonder zichtbare plant; anders false>,
  "undergroundHarvestNote": <NL of null; verplicht bij ondergronds gewas op plantfoto>,
  "bloomSeasonNote": <NL of null; verplicht bij moestuinbloem in bloei>,
$kPlantAiInsightJsonSchema
}
$undergroundSection
$ornamentalSection
$edibleBloomSection

${kPlantAiInsightInstructions.replaceAll('{gewas}', vegetable.nameNl)}

${ornamentalOnly ? 'Bij sier-moestuinbloem: geen "ripe", geen harvestReady, geen oogst-taal.' : edibleBloom ? 'Bij eetbare moestuinbloem: leg beide keuzes uit (plukken om te eten vs laten uitbloeien).' : 'Wees conservatief bij oogst: liever iets later dan te vroeg. Als de plant rijp lijkt, zet phase op "ripe" en daysUntilHarvest op 0.'}
${underground ? 'Bij ondergronds gewas: "ripe" en harvestReady alleen bij proefoogst-foto met zichtbare wortel/knol.' : ''}
Bij matchesPreviousScan true: wijzig phase, harvestWindowLabel en advies niet ten opzichte van de vorige scan (alleen daysUntilHarvest verlagen met verstreken dagen).
Als de plant groot is maar de kalender zegt "te laat", kan harvestStillPossibleThisSeason alsnog true zijn.
Forceer nooit matchesSelectedCrop true als blad/stengel duidelijk bij een ander gewas passen.
''';

    final body = {
      'contents': [
        {
          'parts': [
            {'text': prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Encode(imageBytes),
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1,
        'responseMimeType': 'application/json',
      },
    };

    Object? lastError;
    for (final model in _models) {
      try {
        final response = await _postGenerate(model, body);
        if (response.statusCode == 200) {
          final decoded = jsonDecode(response.body) as Map<String, dynamic>;
          final text = _extractText(decoded);
          if (text == null || text.isEmpty) {
            throw PlantPhotoAiException('Geen antwoord van de AI ontvangen.');
          }
          final json = _parseJsonPayload(text);
          final mapped = _mapAnalysis(
            json,
            vegetable,
            isHarvestProbePhoto: isHarvestProbePhoto,
          );
          final fingerprint = fingerprintImageBytes(imageBytes);
          final reconciled = reconcileWithPreviousScan(
            incoming: mapped,
            previous: previousAnalysis,
            scannedAt: mapped.scannedAt,
            previousImageFingerprint: previousImageFingerprint,
            currentImageFingerprint: fingerprint,
            aiMatchesPrevious: json['matchesPreviousScan'] as bool?,
          );
          return _applyOrnamentalScanRules(
            _applyUndergroundScanRules(
              reconciled,
              vegetable: vegetable,
              isHarvestProbePhoto: isHarvestProbePhoto,
            ),
            vegetable: vegetable,
          );
        }

        if (response.statusCode == 404) {
          lastError = response.body;
          continue;
        }

        throw PlantPhotoAiException(
          _friendlyApiError(response.statusCode, response.body),
        );
      } on PlantPhotoAiException {
        rethrow;
      } catch (e) {
        lastError = e;
      }
    }

    throw PlantPhotoAiException(
      _friendlyApiError(403, lastError?.toString() ?? ''),
    );
  }

  Future<http.Response> _postGenerate(String model, Map<String, dynamic> body) {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent',
    );
    return http
        .post(
          uri,
          headers: {
            'Content-Type': 'application/json',
            'x-goog-api-key': apiKey.trim(),
          },
          body: jsonEncode(body),
        )
        .timeout(const Duration(seconds: 45));
  }

  String? _extractText(Map<String, dynamic> decoded) {
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return null;
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return null;
    return parts.first['text'] as String?;
  }

  Map<String, dynamic> _parseJsonPayload(String text) {
    var trimmed = text.trim();
    if (trimmed.startsWith('```')) {
      trimmed = trimmed.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      trimmed = trimmed.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return jsonDecode(trimmed) as Map<String, dynamic>;
  }

  PlantAiAnalysis _applyUndergroundScanRules(
    PlantAiAnalysis analysis, {
    required Vegetable vegetable,
    required bool isHarvestProbePhoto,
  }) {
    var result = analysis.copyWith(isHarvestProbeScan: isHarvestProbePhoto);
    if (!isUndergroundCrop(vegetable)) return result;
    if (!isHarvestProbePhoto && result.phase == PlantAiPhase.ripe) {
      result = result.copyWith(
        phase: PlantAiPhase.almostRipe,
        phaseLabel: 'Mogelijk oogstbaar — controleer ondergronds',
      );
    }
    return result;
  }

  PlantAiAnalysis _applyOrnamentalScanRules(
    PlantAiAnalysis analysis, {
    required Vegetable vegetable,
  }) {
    if (!isOrnamentalOnlyMoestuinCrop(vegetable)) return analysis;
    var result = analysis;
    if (result.phase == PlantAiPhase.ripe ||
        result.phase == PlantAiPhase.almostRipe) {
      final label = result.phaseLabel.toLowerCase();
      result = result.copyWith(
        phase: PlantAiPhase.flowering,
        phaseLabel: label.contains('bloei') || label.contains('bloem')
            ? result.phaseLabel
            : 'Prachtig in bloei',
        daysUntilHarvest: null,
      );
    }
    final hw = result.harvestWindowLabel.toLowerCase();
    if (hw.contains('oogst') && !hw.contains('bloei')) {
      result = result.copyWith(
        harvestWindowLabel: 'In bloei — goed voor bijen en nuttige insecten',
      );
    }
    final insight = result.insight;
    if (insight != null) {
      result = result.copyWith(insight: insightForOrnamentalBloom(insight));
    }
    return result;
  }

  PlantAiAnalysis _mapAnalysis(
    Map<String, dynamic> json,
    Vegetable vegetable, {
    bool isHarvestProbePhoto = false,
  }) {
    final matchesCrop = json['matchesSelectedCrop'] as bool? ?? true;
    final detected =
        (json['detectedPlantLabel'] as String?)?.trim();
    var mismatch = (json['cropMismatchWarning'] as String?)?.trim();

    if (!matchesCrop) {
      mismatch ??=
          detected != null && detected.isNotEmpty
              ? 'Dit lijkt geen ${vegetable.nameNl} maar $detected. '
                  'Kies het juiste gewas bij het scannen.'
              : 'De plant op de foto lijkt niet bij ${vegetable.nameNl} te horen. '
                  'Kies het juiste gewas en scan opnieuw.';
      final warnings = <String>[mismatch];
      for (final w in (json['warnings'] as List<dynamic>? ?? const [])) {
        final s = w.toString().trim();
        if (s.isNotEmpty && s != mismatch) warnings.add(s);
      }
      return _enrichFromJson(
        PlantAiAnalysis(
        scannedAt: DateTime.now(),
        phase: PlantAiPhase.growing,
        phaseLabel: 'Verkeerd gewas op foto',
        daysUntilHarvest: null,
        harvestWindowLabel: '—',
        confidencePercent: 85,
        advice:
            'De foto past niet bij ${vegetable.nameNl}. '
            'Open het tabblad van de plant die je echt fotografeert en scan daar opnieuw.',
        warnings: warnings,
        matchedPrevious: json['matchesPreviousScan'] as bool? ?? false,
        comparisonNote: json['comparisonNote'] as String?,
        harvestStillPossibleThisSeason: null,
        seasonTimingWarning: null,
        estimatedWeeksGrowing: null,
        plantedDateMatchesPhoto: null,
        datePhotoComparisonNote: null,
        expectedWeeksFromStatedDate: null,
        matchesSelectedCrop: false,
        detectedPlantLabel: detected,
        cropMismatchWarning: mismatch,
        healthImprovedSincePrevious: null,
        pestLikelyResolvedSincePrevious: null,
        healthComparisonNote: null,
        healthTrend: PlantHealthTrend.unknown,
      ),
        json,
      );
    }

    final plantingBedOnly =
        json['photoShowsPlantingBedOnly'] as bool? ?? false;
    final phaseRaw = json['phase'] as String?;
    var phase = parsePlantAiPhase(phaseRaw) ?? PlantAiPhase.growing;
    var phaseLabel = json['phaseLabel'] as String? ?? phase.label;
    if (plantingBedOnly) {
      phase = PlantAiPhase.seedling;
      if (phaseLabel == phase.label || phaseLabel.isEmpty) {
        phaseLabel = 'Zaadbed vastgelegd (nog geen kiemplant)';
      }
    }
    final days = json['daysUntilHarvest'];
    final matchesPrevious = json['matchesPreviousScan'] as bool? ?? false;
    final harvestPossible = json['harvestStillPossibleThisSeason'];
    final warnings = (json['warnings'] as List<dynamic>?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final undergroundNote =
        (json['undergroundHarvestNote'] as String?)?.trim();
    final bloomNote = (json['bloomSeasonNote'] as String?)?.trim();
    return _enrichFromJson(
      PlantAiAnalysis(
        scannedAt: DateTime.now(),
        phase: phase,
        phaseLabel: phaseLabel,
        daysUntilHarvest: days is num ? days.toInt() : null,
        harvestWindowLabel:
            json['harvestWindowLabel'] as String? ?? 'zie advies',
        confidencePercent:
            ((json['confidencePercent'] as num?)?.toInt() ?? 75).clamp(50, 95),
        advice: json['advice'] as String? ?? '',
        warnings: warnings,
        matchedPrevious: matchesPrevious,
        comparisonNote: json['comparisonNote'] as String?,
        harvestStillPossibleThisSeason:
            harvestPossible is bool ? harvestPossible : null,
        seasonTimingWarning: json['seasonTimingWarning'] as String?,
        estimatedWeeksGrowing:
            (json['estimatedWeeksGrowing'] as num?)?.toInt(),
        plantedDateMatchesPhoto: json['plantedDateMatchesPhoto'] as bool?,
        datePhotoComparisonNote: json['datePhotoComparisonNote'] as String?,
        expectedWeeksFromStatedDate:
            (json['expectedWeeksFromStatedDate'] as num?)?.toInt(),
        matchesSelectedCrop: true,
        detectedPlantLabel: detected,
        cropMismatchWarning: mismatch,
        healthImprovedSincePrevious:
            json['healthImprovedSincePrevious'] as bool?,
        pestLikelyResolvedSincePrevious:
            json['pestLikelyResolvedSincePrevious'] as bool?,
        healthComparisonNote: json['healthComparisonNote'] as String?,
        healthTrend: parsePlantHealthTrend(json['healthTrend'] as String?),
        isHarvestProbeScan: isHarvestProbePhoto,
        undergroundHarvestNote:
            undergroundNote != null && undergroundNote.isNotEmpty
                ? undergroundNote
                : null,
        bloomSeasonNote:
            bloomNote != null && bloomNote.isNotEmpty ? bloomNote : null,
      ),
      json,
    );
  }

  PlantAiAnalysis _enrichFromJson(
    PlantAiAnalysis base,
    Map<String, dynamic> json,
  ) {
    if (base.hasCropMismatch) return base;
    final raw = parsePlantAiInsight(json);
    if (raw == null) return base;
    final insight = normalizeInsight(raw);
    final mergedWarnings = mergeAnalysisWarnings(
      legacyWarnings: base.warnings,
      insight: insight,
    );
    final adjustedDays = adjustHarvestDays(
      daysUntilHarvest: base.daysUntilHarvest,
      insight: insight,
    );
    final harvestLabel = insight.adjustedHarvestLabel?.trim().isNotEmpty == true
        ? insight.adjustedHarvestLabel!.trim()
        : base.harvestWindowLabel;
    final advice = base.advice.trim().isEmpty
        ? insight.summary
        : base.advice;
    final undergroundNote =
        (json['undergroundHarvestNote'] as String?)?.trim();
    final bloomNote = (json['bloomSeasonNote'] as String?)?.trim();
    return base.copyWith(
      warnings: mergedWarnings,
      daysUntilHarvest: adjustedDays,
      harvestWindowLabel: harvestLabel,
      advice: advice,
      insight: insight,
      undergroundHarvestNote: base.undergroundHarvestNote ??
          (undergroundNote != null && undergroundNote.isNotEmpty
              ? undergroundNote
              : null),
      bloomSeasonNote: base.bloomSeasonNote ??
          (bloomNote != null && bloomNote.isNotEmpty ? bloomNote : null),
    );
  }

  String _friendlyApiError(int code, String body) {
    final apiMessage = _extractApiMessage(body);
    if (apiMessage != null) {
      final lower = apiMessage.toLowerCase();
      if (lower.contains('api key') ||
          lower.contains('api_key') ||
          lower.contains('permission') ||
          code == 403) {
        return 'API-sleutel geweigerd: $apiMessage';
      }
      if (code == 429) {
        return 'Te veel verzoeken. Probeer het over een minuut opnieuw.';
      }
      return 'AI-fout: $apiMessage';
    }
    if (code == 400 || code == 403) {
      return 'API-sleutel ongeldig of Geen toegang. '
          'Controleer of Generative Language API aan staat in Google Cloud.';
    }
    if (code == 429) {
      return 'Te veel verzoeken. Probeer het over een minuut opnieuw.';
    }
    return 'AI-fout ($code). Controleer internet en API-sleutel.';
  }

  String? _extractApiMessage(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        final err = decoded['error'];
        if (err is Map<String, dynamic>) {
          return err['message'] as String?;
        }
      }
    } catch (_) {}
    return body.length > 200 ? '${body.substring(0, 200)}…' : body;
  }
}
