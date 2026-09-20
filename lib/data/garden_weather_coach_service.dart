import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart' show Icons;
import 'package:http/http.dart' as http;

import 'garden_weather_advice.dart';
import 'weather_service.dart';

/// AI- of regelgebaseerd weeradvies voor de moestuin.
class GardenWeatherCoachBrief {
  const GardenWeatherCoachBrief({
    required this.summary,
    required this.requiresAction,
    this.actionLines = const [],
    this.usedAi = false,
  });

  final String summary;
  final bool requiresAction;
  final List<String> actionLines;
  final bool usedAi;
}

class GardenWeatherCoachService {
  const GardenWeatherCoachService({required this.apiKey});

  final String apiKey;

  static const _models = [
    'gemini-2.5-flash-lite',
    'gemini-2.5-flash',
    'gemini-2.0-flash',
  ];

  static String? _cacheKey;
  static GardenWeatherCoachBrief? _cachedBrief;

  Future<GardenWeatherCoachBrief> coachForGarden({
    required WeatherForecast forecast,
    required List<GardenWeatherTip> tips,
    required List<String> plantedCropNames,
    String? gardenName,
  }) async {
    final fallback = buildRuleBasedWeatherCoach(
      forecast: forecast,
      tips: tips,
      plantedCropNames: plantedCropNames,
      gardenName: gardenName,
    );

    if (apiKey.trim().isEmpty) return fallback;

    final cacheKey = _coachCacheKey(
      forecast: forecast,
      tips: tips,
      plantedCropNames: plantedCropNames,
    );
    if (_cacheKey == cacheKey && _cachedBrief != null) {
      return _cachedBrief!;
    }

    try {
      final ai = await _fetchAiCoach(
        forecast: forecast,
        tips: tips,
        plantedCropNames: plantedCropNames,
        gardenName: gardenName,
      );
      if (ai != null) {
        _cacheKey = cacheKey;
        _cachedBrief = ai;
        return ai;
      }
    } catch (_) {
      // Regelgebaseerd fallback bij API-fout.
    }
    return fallback;
  }

  static void clearCache() {
    _cacheKey = null;
    _cachedBrief = null;
  }

  static String _coachCacheKey({
    required WeatherForecast forecast,
    required List<GardenWeatherTip> tips,
    required List<String> plantedCropNames,
  }) {
    final today = forecast.daily.isNotEmpty ? forecast.daily.first.date : DateTime.now();
    final tipSig = tips.map((t) => '${t.level.name}:${t.title}').join('|');
    return '${forecast.placeName}|${today.year}-${today.month}-${today.day}|'
        '${forecast.currentTempC.round()}|${forecast.currentCode}|$tipSig|'
        '${plantedCropNames.join(',')}';
  }

  Future<GardenWeatherCoachBrief?> _fetchAiCoach({
    required WeatherForecast forecast,
    required List<GardenWeatherTip> tips,
    required List<String> plantedCropNames,
    String? gardenName,
  }) async {
    final forecastLines = _forecastLines(forecast);
    final tipLines = tips
        .map(
          (t) =>
              '- [${t.level.name}] ${t.title}: ${t.body} Taak: ${t.action}',
        )
        .join('\n');
    final crops = plantedCropNames.isEmpty
        ? 'Geen planten gemarkeerd als geplant.'
        : plantedCropNames.join(', ');

    final prompt = '''
NL moestuin-coach. Kort weeradvies op basis van weer + planten.

Weer (${forecast.placeName}):
$forecastLines

Alerts:
$tipLines

Planten: $crops

JSON:
{"summary":"2-3 zinnen NL","requiresAction":true/false,"actionLines":["max 3"]}
''';

    for (final model in _models) {
      final response = await http
          .post(
            Uri.parse(
              'https://generativelanguage.googleapis.com/v1beta/models/'
              '$model:generateContent',
            ),
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': apiKey.trim(),
            },
            body: jsonEncode({
              'contents': [
                {
                  'parts': [
                    {'text': prompt},
                  ],
                },
              ],
              'generationConfig': {
                'temperature': 0.3,
                'maxOutputTokens': 384,
                'responseMimeType': 'application/json',
              },
            }),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) continue;

      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final text = _extractText(decoded);
      if (text == null) continue;

      final payload = _parseJsonPayload(text);
      final summary = (payload['summary'] as String?)?.trim();
      if (summary == null || summary.isEmpty) continue;

      final actions = (payload['actionLines'] as List<dynamic>?)
              ?.map((e) => '$e'.trim())
              .where((s) => s.isNotEmpty)
              .take(3)
              .toList() ??
          const <String>[];

      return GardenWeatherCoachBrief(
        summary: summary,
        requiresAction: payload['requiresAction'] == true,
        actionLines: actions,
        usedAi: true,
      );
    }
    return null;
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

  String _forecastLines(WeatherForecast forecast) {
    final buf = StringBuffer()
      ..writeln(
        'Nu: ${forecast.currentTempC.round()}°C, '
        '${weatherCodeLabelNl(forecast.currentCode)}, '
        'wind ${forecast.currentWindKmh.round()} km/u',
      );
    for (final day in forecast.daily.take(7)) {
      buf.writeln(
        '${day.date.day}-${day.date.month}: '
        '${weatherCodeLabelNl(day.code)}, '
        '${day.minTempC.round()}–${day.maxTempC.round()}°C, '
        'regen ${day.precipMm.round()} mm, '
        'wind ${day.maxWindKmh.round()} km/u',
      );
    }
    return buf.toString().trim();
  }
}

GardenWeatherCoachBrief buildRuleBasedWeatherCoach({
  required WeatherForecast forecast,
  required List<GardenWeatherTip> tips,
  required List<String> plantedCropNames,
  String? gardenName,
}) {
  final alerts =
      tips.where((t) => t.level == GardenWeatherLevel.alert).toList();
  final watches =
      tips.where((t) => t.level == GardenWeatherLevel.watch).toList();
  final cropLabel = plantedCropNames.isEmpty
      ? 'je moestuin'
      : plantedCropNames.take(5).join(', ');

  if (alerts.isEmpty && watches.isEmpty) {
    final ok = tips.isNotEmpty
        ? tips.first
        : const GardenWeatherTip(
            title: 'Gunstig tuinweer',
            body: 'Geen extreme omstandigheden verwacht.',
            action: 'Ga door met je normale tuinroutine.',
            level: GardenWeatherLevel.ok,
            icon: Icons.yard_outlined,
          );
    return GardenWeatherCoachBrief(
      summary: 'Het weer in ${forecast.placeName} ziet er gunstig uit voor '
          '$cropLabel. ${ok.body} Je hoeft nu geen extra maatregelen te nemen '
          'tegen het weer.',
      requiresAction: false,
    );
  }

  if (alerts.isNotEmpty) {
    final titles = alerts.map((t) => t.title.toLowerCase()).join(' en ');
    return GardenWeatherCoachBrief(
      summary: 'Voor $cropLabel is een taak nodig: $titles. '
          '${alerts.first.body}',
      requiresAction: true,
      actionLines: alerts.map((t) => t.action).toList(),
    );
  }

  return GardenWeatherCoachBrief(
    summary: 'Het weer vraagt aandacht voor $cropLabel: '
        '${watches.map((t) => t.title.toLowerCase()).join(', ')}. '
        '${watches.first.body} Nog geen directe alarmfase, maar houd het in de gaten.',
    requiresAction: false,
    actionLines: watches.map((t) => t.action).take(2).toList(),
  );
}

List<String> plantedCropNamesForGarden({
  required Iterable<String> gardenIds,
  required String? Function(String id) nameForId,
  required bool Function(String id) isPlanted,
}) {
  final names = <String>[];
  for (final id in gardenIds) {
    if (!isPlanted(id)) continue;
    final name = nameForId(id);
    if (name != null && name.isNotEmpty) names.add(name);
  }
  names.sort();
  return names;
}
