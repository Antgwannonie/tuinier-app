import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../models/vegetable.dart';
import 'garden_weather_advice.dart';
import 'garden_weather_coach_service.dart';
import 'weather_service.dart';

enum WeatherImpactTone { success, good, warning, neutral }

class GardenWeatherImpactItem {
  const GardenWeatherImpactItem({
    required this.title,
    required this.icon,
    required this.statusLabel,
    required this.description,
    required this.tone,
  });

  final String title;
  final IconData icon;
  final String statusLabel;
  final String description;
  final WeatherImpactTone tone;
}

class GardenWeatherTodoCard {
  const GardenWeatherTodoCard({
    required this.title,
    required this.icon,
    required this.items,
    this.note,
  });

  final String title;
  final IconData icon;
  final List<String> items;
  final String? note;
}

enum GardenWeatherRiskKind { rain, wind, cold, none }

class GardenWeatherRiskItem {
  const GardenWeatherRiskItem({
    required this.kind,
    required this.label,
  });

  final GardenWeatherRiskKind kind;
  final String label;
}

class GardenCropWeatherAdvice {
  const GardenCropWeatherAdvice({
    required this.vegetable,
    required this.advice,
    required this.statusLabel,
    required this.attentionNeeded,
  });

  final Vegetable vegetable;
  final String advice;
  final String statusLabel;
  final bool attentionNeeded;
}

class GardenWeatherDashboard {
  const GardenWeatherDashboard({
    required this.scoreToday,
    required this.coachSummary,
    required this.recommendedActions,
    required this.impacts,
    required this.todoCards,
    required this.risks,
    required this.cropAdvices,
    required this.usedAi,
  });

  final double scoreToday;
  final String coachSummary;
  final List<String> recommendedActions;
  final List<GardenWeatherImpactItem> impacts;
  final List<GardenWeatherTodoCard> todoCards;
  final List<GardenWeatherRiskItem> risks;
  final List<GardenCropWeatherAdvice> cropAdvices;
  final bool usedAi;
}

class GardenWeatherDashboardService {
  const GardenWeatherDashboardService({required this.apiKey});

  final String apiKey;

  Future<GardenWeatherDashboard> build({
    required WeatherForecast forecast,
    required List<GardenWeatherTip> tips,
    required List<Vegetable> plantedCrops,
    String? gardenName,
  }) async {
    final base = buildRuleBasedGardenWeatherDashboard(
      forecast: forecast,
      tips: tips,
      plantedCrops: plantedCrops,
    );

    if (apiKey.trim().isEmpty) return base;

    try {
      final ai = await _fetchAiDashboard(
        forecast: forecast,
        tips: tips,
        plantedCrops: plantedCrops,
        gardenName: gardenName,
        base: base,
      );
      if (ai != null) return ai;
    } catch (_) {}
    return base;
  }

  Future<GardenWeatherDashboard?> _fetchAiDashboard({
    required WeatherForecast forecast,
    required List<GardenWeatherTip> tips,
    required List<Vegetable> plantedCrops,
    required String? gardenName,
    required GardenWeatherDashboard base,
  }) async {
    const models = [
      'gemini-2.5-flash',
      'gemini-2.0-flash',
      'gemini-2.5-flash-lite',
    ];

    final crops = plantedCrops.map((v) => v.nameNl).join(', ');
    final tipLines = tips
        .map((t) => '- ${t.title}: ${t.body} (${t.action})')
        .join('\n');
    final dayLines = forecast.daily
        .map(
          (d) =>
              '${d.date.day}-${d.date.month}: ${weatherCodeLabelNl(d.code)}, '
              '${d.minTempC.round()}-${d.maxTempC.round()}°C, '
              'regen ${d.precipMm.round()}mm (${d.precipChancePercent}%), '
              'wind ${d.maxWindKmh.round()}km/u',
        )
        .join('\n');

    final prompt = '''
Je bent een NL moestuin AI-coach. Genereer een weer-dashboard als JSON.

Locatie: ${forecast.placeName}
Nu: ${forecast.currentTempC.round()}°C, ${weatherCodeLabelNl(forecast.currentCode)}, wind ${forecast.currentWindKmh.round()} km/u, vochtigheid ${forecast.currentHumidityPercent}%, UV ${forecast.currentUvIndex.round()}
Planten: ${crops.isEmpty ? 'geen geplante gewassen' : crops}
Tips: $tipLines
Dagen: $dayLines

JSON schema:
{
  "scoreToday": number 0-10,
  "coachSummary": "2-3 zinnen",
  "recommendedActions": ["max 4 korte taken"],
  "impacts": [
    {"title":"Water geven","status":"Niet nodig|Goed moment|Uitstekend|Wacht","description":"..."},
    {"title":"Oogsten","status":"...","description":"..."},
    {"title":"Snoeien","status":"...","description":"..."},
    {"title":"Zaaien","status":"...","description":"..."}
  ],
  "todoCards": [
    {"title":"Oogsten","items":["sla","..."], "note": null},
    {"title":"Onderhoud","items":["..."]},
    {"title":"Voorbereiden","items":[],"note":"..."}
  ],
  "risks": ["korte regel", "..."],
  "crops": [
    {"name":"Tomaat","advice":"...","status":"LET OP|GOED"}
  ]
}
''';

    for (final model in models) {
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
                'temperature': 0.35,
                'responseMimeType': 'application/json',
              },
            }),
          )
          .timeout(const Duration(seconds: 30));

      if (response.statusCode != 200) continue;
      final decoded = jsonDecode(response.body) as Map<String, dynamic>;
      final text = _extractText(decoded);
      if (text == null) continue;
      final payload = _parseJson(text);
      final parsed = _parseAiPayload(payload, base, plantedCrops);
      if (parsed != null) return parsed;
    }
    return null;
  }

  GardenWeatherDashboard? _parseAiPayload(
    Map<String, dynamic> json,
    GardenWeatherDashboard base,
    List<Vegetable> plantedCrops,
  ) {
    final summary = (json['coachSummary'] as String?)?.trim();
    if (summary == null || summary.isEmpty) return null;

    final score = (json['scoreToday'] as num?)?.toDouble() ?? base.scoreToday;
    final actions = (json['recommendedActions'] as List<dynamic>?)
            ?.map((e) => '$e'.trim())
            .where((s) => s.isNotEmpty)
            .take(4)
            .toList() ??
        base.recommendedActions;

    final impacts = _parseImpacts(json['impacts'], base.impacts);
    final todos = _parseTodos(json['todoCards'], base.todoCards);
    final risks = _parseRisks(json['risks'], base.risks);
    final crops = _parseCrops(json['crops'], base.cropAdvices, plantedCrops);

    return GardenWeatherDashboard(
      scoreToday: score.clamp(0, 10),
      coachSummary: summary,
      recommendedActions: actions,
      impacts: impacts,
      todoCards: todos,
      risks: risks,
      cropAdvices: crops,
      usedAi: true,
    );
  }

  List<GardenWeatherImpactItem> _parseImpacts(
    dynamic raw,
    List<GardenWeatherImpactItem> fallback,
  ) {
    if (raw is! List || raw.length < 4) return fallback;
    const icons = [
      Icons.water_drop_outlined,
      Icons.shopping_basket_outlined,
      Icons.content_cut_outlined,
      Icons.yard_outlined,
    ];
    const titles = ['Water geven', 'Oogsten', 'Snoeien', 'Zaaien'];
    final out = <GardenWeatherImpactItem>[];
    for (var i = 0; i < 4; i++) {
      final m = raw[i];
      if (m is! Map) return fallback;
      final status = (m['status'] as String?)?.trim() ?? fallback[i].statusLabel;
      final desc = (m['description'] as String?)?.trim() ?? fallback[i].description;
      out.add(
        GardenWeatherImpactItem(
          title: titles[i],
          icon: icons[i],
          statusLabel: status,
          description: desc,
          tone: _toneFromStatus(status),
        ),
      );
    }
    return out;
  }

  List<GardenWeatherTodoCard> _parseTodos(
    dynamic raw,
    List<GardenWeatherTodoCard> fallback,
  ) {
    if (raw is! List || raw.isEmpty) return fallback;
    const icons = [
      Icons.shopping_basket_outlined,
      Icons.content_cut_outlined,
      Icons.shield_outlined,
    ];
    const defaultTitles = ['Oogsten', 'Onderhoud', 'Voorbereiden'];
    final out = <GardenWeatherTodoCard>[];
    for (var i = 0; i < raw.length && i < 3; i++) {
      final m = raw[i];
      if (m is! Map) continue;
      final items = (m['items'] as List<dynamic>?)
              ?.map((e) => '$e'.trim())
              .where((s) => s.isNotEmpty)
              .toList() ??
          fallback[i].items;
      out.add(
        GardenWeatherTodoCard(
          title: (m['title'] as String?)?.trim() ?? defaultTitles[i],
          icon: icons[i],
          items: items,
          note: (m['note'] as String?)?.trim(),
        ),
      );
    }
    return out.length == 3 ? out : fallback;
  }

  List<GardenWeatherRiskItem> _parseRisks(
    dynamic raw,
    List<GardenWeatherRiskItem> fallback,
  ) {
    if (raw is! List || raw.isEmpty) return fallback;
    const kinds = [
      GardenWeatherRiskKind.rain,
      GardenWeatherRiskKind.wind,
      GardenWeatherRiskKind.cold,
    ];
    return [
      for (var i = 0; i < raw.length && i < 5; i++)
        GardenWeatherRiskItem(
          kind: kinds[i % kinds.length],
          label: '${raw[i]}'.trim(),
        ),
    ];
  }

  List<GardenCropWeatherAdvice> _parseCrops(
    dynamic raw,
    List<GardenCropWeatherAdvice> fallback,
    List<Vegetable> plantedCrops,
  ) {
    if (raw is! List || raw.isEmpty) return fallback;
    final byName = {for (final v in plantedCrops) v.nameNl.toLowerCase(): v};
    final out = <GardenCropWeatherAdvice>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final name = (item['name'] as String?)?.trim();
      final advice = (item['advice'] as String?)?.trim();
      if (name == null || advice == null) continue;
      final veg = byName[name.toLowerCase()];
      if (veg == null) continue;
      final status = (item['status'] as String?)?.trim() ?? 'GOED';
      out.add(
        GardenCropWeatherAdvice(
          vegetable: veg,
          advice: advice,
          statusLabel: status,
          attentionNeeded: status.toUpperCase().contains('LET'),
        ),
      );
    }
    if (out.isEmpty) return fallback;
    for (final f in fallback) {
      if (!out.any((c) => c.vegetable.id == f.vegetable.id)) out.add(f);
    }
    return out;
  }

  WeatherImpactTone _toneFromStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('uitstekend') || s.contains('niet nodig')) {
      return WeatherImpactTone.success;
    }
    if (s.contains('goed')) return WeatherImpactTone.good;
    if (s.contains('wacht')) return WeatherImpactTone.warning;
    return WeatherImpactTone.neutral;
  }

  String? _extractText(Map<String, dynamic> decoded) {
    final candidates = decoded['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) return null;
    final content = candidates.first['content'] as Map<String, dynamic>?;
    final parts = content?['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) return null;
    return parts.first['text'] as String?;
  }

  Map<String, dynamic> _parseJson(String text) {
    var trimmed = text.trim();
    if (trimmed.startsWith('```')) {
      trimmed = trimmed.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      trimmed = trimmed.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return jsonDecode(trimmed) as Map<String, dynamic>;
  }
}

GardenWeatherDashboard buildRuleBasedGardenWeatherDashboard({
  required WeatherForecast forecast,
  required List<GardenWeatherTip> tips,
  required List<Vegetable> plantedCrops,
}) {
  final today = forecast.daily.isNotEmpty ? forecast.daily.first : null;
  final tomorrow =
      forecast.daily.length > 1 ? forecast.daily[1] : null;
  final score = _scoreFromForecast(forecast, tips);
  final coach = buildRuleBasedWeatherCoach(
    forecast: forecast,
    tips: tips,
    plantedCropNames: plantedCrops.map((v) => v.nameNl).toList(),
  );

  final rainSoon = _rainSoon(forecast);
  final dryDays = _dryDaysAhead(forecast);
  final coldSnap = _coldSnapDay(forecast);
  final windy = _windyDays(forecast);

  final impacts = [
    GardenWeatherImpactItem(
      title: 'Water geven',
      icon: Icons.water_drop_outlined,
      statusLabel: rainSoon || (today != null && today.precipMm >= 5)
          ? 'Niet nodig'
          : forecast.currentTempC >= 22
              ? 'Aanbevolen'
              : 'Goed moment',
      description: rainSoon
          ? 'Regen verwacht vanaf ${_dayLabel(tomorrow ?? today!)}.'
          : 'Bodemniveau droog, geef water in de ochtend.',
      tone: rainSoon ? WeatherImpactTone.success : WeatherImpactTone.good,
    ),
    GardenWeatherImpactItem(
      title: 'Oogsten',
      icon: Icons.shopping_basket_outlined,
      statusLabel: dryDays >= 2 ? 'Uitstekend' : 'Goed moment',
      description: dryDays >= 2
          ? 'Perfecte dagen om te oogsten.'
          : 'Oogst bij droog moment vandaag.',
      tone: dryDays >= 2 ? WeatherImpactTone.success : WeatherImpactTone.good,
    ),
    GardenWeatherImpactItem(
      title: 'Snoeien',
      icon: Icons.content_cut_outlined,
      statusLabel: dryDays >= 1 && (today?.maxWindKmh ?? 0) < 35
          ? 'Goed moment'
          : 'Wacht',
      description: dryDays >= 1 && (today?.maxWindKmh ?? 0) < 35
          ? 'Droog weer en weinig wind.'
          : 'Wacht op rustiger, droger weer.',
      tone: dryDays >= 1 && (today?.maxWindKmh ?? 0) < 35
          ? WeatherImpactTone.good
          : WeatherImpactTone.warning,
    ),
    GardenWeatherImpactItem(
      title: 'Zaaien',
      icon: Icons.yard_outlined,
      statusLabel: coldSnap != null || rainSoon ? 'Wacht' : 'Goed moment',
      description: coldSnap != null
          ? 'Beter vanaf ${_dayLabel(coldSnap)}.'
          : rainSoon
              ? 'Wacht tot het droger is.'
              : 'Mild weer, geschikt voor zaaien.',
      tone: coldSnap != null || rainSoon
          ? WeatherImpactTone.warning
          : WeatherImpactTone.good,
    ),
  ];

  final harvestCrops = _harvestCandidates(plantedCrops);
  final todoCards = [
    GardenWeatherTodoCard(
      title: 'Oogsten',
      icon: Icons.shopping_basket_outlined,
      items: harvestCrops,
    ),
    GardenWeatherTodoCard(
      title: 'Onderhoud',
      icon: Icons.content_cut_outlined,
      items: dryDays >= 1
          ? ['Snoeien', 'Onkruid verwijderen', 'Planten controleren']
          : ['Planten controleren', 'Drainage checken'],
    ),
    GardenWeatherTodoCard(
      title: 'Voorbereiden',
      icon: Icons.shield_outlined,
      items: const [],
      note: _prepareNote(forecast, coldSnap, rainSoon, windy),
    ),
  ];

  final risks = _buildRisks(forecast);
  final cropAdvices = sortCropWeatherAdvices(
    plantedCrops.map((v) => _cropAdvice(v, forecast, tips)).toList(),
  );

  return GardenWeatherDashboard(
    scoreToday: score,
    coachSummary: coach.summary,
    recommendedActions: coach.actionLines.isNotEmpty
        ? coach.actionLines
        : _defaultActions(forecast, plantedCrops),
    impacts: impacts,
    todoCards: todoCards,
    risks: risks,
    cropAdvices: cropAdvices,
    usedAi: false,
  );
}

double _scoreFromForecast(WeatherForecast forecast, List<GardenWeatherTip> tips) {
  var score = 10.0;
  for (final t in tips) {
    switch (t.level) {
      case GardenWeatherLevel.alert:
        score -= 2.5;
      case GardenWeatherLevel.watch:
        score -= 1.0;
      case GardenWeatherLevel.ok:
        break;
    }
  }
  if (forecast.currentWindKmh >= 50) score -= 1;
  if (forecast.currentTempC >= 32) score -= 1;
  return score.clamp(3.0, 10.0);
}

bool _rainSoon(WeatherForecast forecast) {
  for (var i = 1; i < forecast.daily.length && i <= 3; i++) {
    if (forecast.daily[i].precipMm >= 3 ||
        forecast.daily[i].precipChancePercent >= 50) {
      return true;
    }
  }
  return false;
}

int _dryDaysAhead(WeatherForecast forecast) {
  var count = 0;
  for (final d in forecast.daily.take(4)) {
    if (d.precipMm < 2 && d.precipChancePercent < 40) {
      count++;
    } else {
      break;
    }
  }
  return count;
}

DailyWeather? _coldSnapDay(WeatherForecast forecast) {
  for (var i = 1; i < forecast.daily.length; i++) {
    final d = forecast.daily[i];
    if (d.minTempC <= 4) return d;
  }
  return null;
}

DailyWeather? _windyDays(WeatherForecast forecast) {
  for (var i = 1; i < forecast.daily.length; i++) {
    if (forecast.daily[i].maxWindKmh >= 40) return forecast.daily[i];
  }
  return null;
}

List<String> _harvestCandidates(List<Vegetable> crops) {
  const leafy = ['sla', 'spinazie', 'snijbiet', 'rucola', 'postelein'];
  final out = <String>[];
  for (final v in crops) {
    final id = v.id.toLowerCase();
    final name = v.nameNl;
    if (leafy.any((k) => id.contains(k)) ||
        v.family.toLowerCase().contains('blad') ||
        v.family.toLowerCase().contains('kruis')) {
      out.add(name);
    }
  }
  if (out.isEmpty && crops.isNotEmpty) {
    return crops.take(3).map((v) => v.nameNl).toList();
  }
  return out.take(4).toList();
}

String? _prepareNote(
  WeatherForecast forecast,
  DailyWeather? coldSnap,
  bool rainSoon,
  DailyWeather? windy,
) {
  final parts = <String>[];
  if (rainSoon) {
    final day = forecast.daily.length > 1 ? forecast.daily[1] : forecast.daily.first;
    parts.add('${_dayLabel(day)} regen verwacht');
  }
  if (coldSnap != null) {
    parts.add('kou op ${_dayLabel(coldSnap)}');
  }
  if (windy != null) {
    parts.add('wind neemt toe ${_dayLabel(windy)}');
  }
  if (parts.isEmpty) return null;
  return '${parts.join('. ')}. Bescherm gevoelige planten.';
}

List<GardenWeatherRiskItem> _buildRisks(WeatherForecast forecast) {
  final risks = <GardenWeatherRiskItem>[];
  DailyWeather? heavyRain;
  DailyWeather? windy;
  DailyWeather? cold;

  for (var i = 1; i < forecast.daily.length; i++) {
    final d = forecast.daily[i];
    if (heavyRain == null && (d.precipMm >= 8 || d.precipChancePercent >= 60)) {
      heavyRain = d;
    }
    if (windy == null && d.maxWindKmh >= 38) windy = d;
    if (cold == null && d.minTempC <= 5) cold = d;
  }

  if (heavyRain != null) {
    risks.add(
      GardenWeatherRiskItem(
        kind: GardenWeatherRiskKind.rain,
        label: 'Veel regen verwacht vanaf ${_dayLabelFull(heavyRain)}',
      ),
    );
  }
  if (windy != null) {
    risks.add(
      GardenWeatherRiskItem(
        kind: GardenWeatherRiskKind.wind,
        label: 'Windkracht neemt toe vanaf ${_dayLabelFull(windy)}',
      ),
    );
  }
  if (cold != null) {
    risks.add(
      GardenWeatherRiskItem(
        kind: GardenWeatherRiskKind.cold,
        label:
            'Temperatuur daalt naar ${cold.minTempC.round()}° ${_dayLabelFull(cold)}',
      ),
    );
  }
  return risks;
}

GardenCropWeatherAdvice _cropAdvice(
  Vegetable veg,
  WeatherForecast forecast,
  List<GardenWeatherTip> tips,
) {
  final id = veg.id.toLowerCase();
  final name = veg.nameNl.toLowerCase();
  final cold = forecast.daily.any((d) => d.minTempC <= 3);
  final windy = forecast.daily.any((d) => d.maxWindKmh >= 42);
  final rainy = forecast.daily.any((d) => d.precipMm >= 8);
  final hot = forecast.daily.any((d) => d.maxTempC >= 30);

  String advice = 'Geen taak nodig';
  var attention = false;

  final frostSensitive =
      _isFrostSensitive(id, name) || veg.family.toLowerCase().contains('nachtschade');
  final rainSensitive = _isRainSensitive(id, name);

  if (rainy && cold && rainSensitive && frostSensitive) {
    advice = 'Beschermen tegen regen en kou';
    attention = true;
  } else if (cold && frostSensitive) {
    advice = 'Beschermen tegen kou';
    attention = true;
  } else if (rainy && rainSensitive) {
    advice = 'Beschermen tegen regen';
    attention = true;
  } else if (windy && (id.contains('zonnebloem') || name.contains('zonnebloem'))) {
    advice = 'Ondersteunen tegen wind';
    attention = true;
  } else if (hot && (id.contains('sla') || name.contains('sla'))) {
    advice = 'Schaduw bij hitte';
    attention = true;
  } else if (tips.any((t) => t.level == GardenWeatherLevel.alert)) {
    advice = 'Houd ${veg.nameNl} in de gaten';
    attention = true;
  }

  return GardenCropWeatherAdvice(
    vegetable: veg,
    advice: advice,
    statusLabel: attention ? 'LET OP' : 'GOED',
    attentionNeeded: attention,
  );
}

bool _isFrostSensitive(String id, String name) {
  return id.contains('tomaat') ||
      id.contains('komkommer') ||
      id.contains('paprika') ||
      id.contains('courgette') ||
      id.contains('aubergine') ||
      name.contains('mango');
}

bool _isRainSensitive(String id, String name) {
  return id.contains('tomaat') ||
      id.contains('komkommer') ||
      id.contains('basilicum') ||
      id.contains('sla');
}

List<String> _defaultActions(
  WeatherForecast forecast,
  List<Vegetable> crops,
) {
  final actions = <String>[];
  if (_dryDaysAhead(forecast) >= 2) {
    actions.add('Oogst geschikte bladgewassen');
  }
  if (_rainSoon(forecast)) {
    actions.add('Bescherm gevoelige planten');
  }
  if (crops.any((v) => v.id.contains('zonnebloem'))) {
    actions.add('Controleer steun voor hoge planten');
  }
  if (actions.isEmpty) actions.add('Plan onderhoud en oogst vandaag');
  return actions.take(4).toList();
}

String _dayLabel(DailyWeather day) {
  const weekdays = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];
  final today = DateTime.now();
  if (day.date.year == today.year &&
      day.date.month == today.month &&
      day.date.day == today.day) {
    return 'vandaag';
  }
  if (day.date.difference(DateTime(today.year, today.month, today.day)).inDays == 1) {
    return 'morgen';
  }
  return weekdays[day.date.weekday - 1];
}

String _dayLabelFull(DailyWeather day) {
  const weekdays = [
    'maandag',
    'dinsdag',
    'woensdag',
    'donderdag',
    'vrijdag',
    'zaterdag',
    'zondag',
  ];
  final today = DateTime.now();
  if (day.date.year == today.year &&
      day.date.month == today.month &&
      day.date.day == today.day) {
    return 'vandaag';
  }
  if (day.date.difference(DateTime(today.year, today.month, today.day)).inDays == 1) {
    return 'morgen';
  }
  return weekdays[day.date.weekday - 1];
}

/// Alleen gewassen met aandacht, gesorteerd zoals in het dashboard-design.
List<GardenCropWeatherAdvice> attentionCropAdvices(
  List<GardenCropWeatherAdvice> advices,
) {
  return sortCropWeatherAdvices(
    advices.where((a) => a.attentionNeeded).toList(),
  );
}

List<GardenCropWeatherAdvice> sortCropWeatherAdvices(
  List<GardenCropWeatherAdvice> advices,
) {
  final sorted = [...advices];
  sorted.sort((a, b) {
    final pa = _cropSortPriority(a);
    final pb = _cropSortPriority(b);
    if (pa != pb) return pa.compareTo(pb);
    return a.vegetable.nameNl.compareTo(b.vegetable.nameNl);
  });
  return sorted;
}

int _cropSortPriority(GardenCropWeatherAdvice advice) {
  final id = advice.vegetable.id.toLowerCase();
  final name = advice.vegetable.nameNl.toLowerCase();
  if (id.contains('tomaat') || name.contains('tomaat')) return 0;
  if (id.contains('komkommer') || name.contains('komkommer')) return 1;
  if (id.contains('zonnebloem') || name.contains('zonnebloem')) return 2;
  if (advice.advice.contains('regen en kou')) return 3;
  if (advice.advice.contains('kou')) return 4;
  if (advice.advice.contains('regen')) return 5;
  if (advice.advice.contains('wind')) return 6;
  return 10;
}

String uvLabelNl(double uv) {
  if (uv <= 2) return 'Laag';
  if (uv <= 5) return 'Matig';
  if (uv <= 7) return 'Hoog';
  return 'Zeer hoog';
}

Color impactToneColor(WeatherImpactTone tone) {
  return switch (tone) {
    WeatherImpactTone.success => const Color(0xFF22C55E),
    WeatherImpactTone.good => const Color(0xFF22C55E),
    WeatherImpactTone.warning => const Color(0xFFF59E0B),
    WeatherImpactTone.neutral => const Color(0xFF6B7280),
  };
}
