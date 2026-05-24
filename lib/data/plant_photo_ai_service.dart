import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';

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
    String? locationLabel,
    String? sunLabel,
  }) async {
    if (apiKey.trim().isEmpty) {
      throw PlantPhotoAiException(
        'Voeg eerst een Gemini API-sleutel toe (gratis via Google AI Studio).',
      );
    }

    final planted = plantedAt != null
        ? '${plantedAt.day}-${plantedAt.month}-${plantedAt.year}'
        : 'onbekend';
    final prompt = '''
Je bent een ervaren Nederlandse moestuin-expert. Bekijk de foto en beoordeel de groeifase van dit gewas.

Gewas: ${vegetable.nameNl} (${vegetable.nameLatin})
Geplant op: $planted
Locatie: ${locationLabel ?? 'onbekend'}
Zon: ${sunLabel ?? 'onbekend'}
Algemene teeltinfo oogst: ${vegetable.harvest}
Teelttijd: ${vegetable.cropDuration ?? 'niet opgegeven'}

Geef ALLEEN geldige JSON (geen markdown) met exact deze velden:
{
  "phase": "seedling|growing|flowering|fruiting|almost_ripe|ripe",
  "phaseLabel": "korte Nederlandse faseomschrijving",
  "daysUntilHarvest": <int of null als al rijp>,
  "harvestWindowLabel": "bijv. over 2 weken of half augustus",
  "confidencePercent": <int 50-95>,
  "advice": "1-3 zinnen praktisch advies in het Nederlands",
  "warnings": ["optionele waarschuwingen"]
}

Wees conservatief bij oogst: liever iets later dan te vroeg. Als de plant rijp lijkt, zet phase op "ripe" en daysUntilHarvest op 0.
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
        'temperature': 0.2,
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
          return _mapAnalysis(json);
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

  PlantAiAnalysis _mapAnalysis(Map<String, dynamic> json) {
    final phaseRaw = json['phase'] as String?;
    final phase = parsePlantAiPhase(phaseRaw) ?? PlantAiPhase.growing;
    final days = json['daysUntilHarvest'];
    return PlantAiAnalysis(
      scannedAt: DateTime.now(),
      phase: phase,
      phaseLabel: json['phaseLabel'] as String? ?? phase.label,
      daysUntilHarvest: days is num ? days.toInt() : null,
      harvestWindowLabel:
          json['harvestWindowLabel'] as String? ?? 'zie advies',
      confidencePercent:
          ((json['confidencePercent'] as num?)?.toInt() ?? 75).clamp(50, 95),
      advice: json['advice'] as String? ?? '',
      warnings: (json['warnings'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
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
