import 'package:flutter/material.dart';

import 'weather_service.dart';

enum GardenWeatherLevel { ok, watch, alert }

class GardenWeatherTip {
  const GardenWeatherTip({
    required this.title,
    required this.body,
    required this.action,
    required this.level,
    required this.icon,
  });

  final String title;
  final String body;
  /// Korte handelingsregel voor in de tuin.
  final String action;
  final GardenWeatherLevel level;
  final IconData icon;
}

/// Korte weersamenvatting voor Inzicht.
String weatherSummaryNl(WeatherForecast forecast) {
  final today = forecast.daily.isNotEmpty ? forecast.daily.first : null;
  final tomorrow =
      forecast.daily.length > 1 ? forecast.daily[1] : null;
  final parts = <String>[
    'Nu ${weatherCodeLabelNl(forecast.currentCode).toLowerCase()} '
        'en ${forecast.currentTempC.round()}°C in ${forecast.placeName}',
  ];

  if (today != null) {
    parts.add(
      'vandaag tot ${today.maxTempC.round()}°',
    );
  }
  if (tomorrow != null) {
    final label = weatherCodeLabelNl(tomorrow.code).toLowerCase();
    parts.add(
      'morgen $label (${tomorrow.minTempC.round()}–${tomorrow.maxTempC.round()}°)',
    );
  }
  return '${parts.first}${parts.length > 1 ? ', ${parts.sublist(1).join(', ')}' : ''}.';
}

List<GardenWeatherTip> gardenTipsFromForecast(WeatherForecast forecast) {
  final tips = <GardenWeatherTip>[];
  final today = forecast.daily.isNotEmpty ? forecast.daily.first : null;
  final tomorrow =
      forecast.daily.length > 1 ? forecast.daily[1] : null;

  if (forecast.currentTempC >= 30 ||
      (today != null && today.maxTempC >= 32)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Volle zon & hitte',
        body: 'Jonge planten en kasplanten drogen snel uit bij extreme warmte.',
        action: 'Geef vroeg water en hang schaduwdoek over gevoelige planten.',
        level: GardenWeatherLevel.alert,
        icon: Icons.wb_sunny,
      ),
    );
  } else if (forecast.currentTempC >= 26 ||
      (today != null && today.maxTempC >= 28)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Warm & zonnig',
        body: 'De bodem droogt sneller; bladgroenten kunnen middag verbranden.',
        action: 'Mulch aanbrengen en water geven in de ochtend.',
        level: GardenWeatherLevel.watch,
        icon: Icons.water_drop_outlined,
      ),
    );
  }

  if (today != null && today.minTempC <= 0) {
    tips.add(
      const GardenWeatherTip(
        title: 'Vorst vannacht',
        body: 'Jonge planten, aardbeien en tomaten zijn kwetsbaar voor nachtvorst.',
        action: 'Dek planten af en oogst gevoelige bladgroenten vandaag.',
        level: GardenWeatherLevel.alert,
        icon: Icons.ac_unit,
      ),
    );
  } else if ((tomorrow != null && tomorrow.minTempC <= 2) ||
      (today != null && today.minTempC <= 2)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Kou op komst',
        body: 'Gevoelige plantjes buiten kunnen schade oplopen.',
        action: 'Zet jonge planten binnen of in de kas; ventileer overdag.',
        level: GardenWeatherLevel.watch,
        icon: Icons.thermostat,
      ),
    );
  }

  if (forecast.currentPrecipMm > 2 ||
      (today != null && today.precipMm >= 15)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Veel regen',
        body: 'Natte grond en potten kunnen wortels laten verrotten.',
        action: 'Sproei niet extra en controleer drainage bij potten.',
        level: GardenWeatherLevel.watch,
        icon: Icons.umbrella,
      ),
    );
  }

  if (forecast.currentWindKmh >= 50 ||
      (today != null && today.maxWindKmh >= 55)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Dikke storm',
        body: 'Hoge planten en kassen lopen schade op bij harde wind.',
        action: 'Bind tomaten vast, vergrendel kasdeuren en beschut jonge planten.',
        level: GardenWeatherLevel.alert,
        icon: Icons.air,
      ),
    );
  } else if (forecast.currentWindKmh >= 35 ||
      (today != null && today.maxWindKmh >= 40)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Flinke wind',
        body: 'Klimrekken en schermen kunnen losraken.',
        action: 'Controleer steunen en zet kwetsbare plantjes uit de wind.',
        level: GardenWeatherLevel.watch,
        icon: Icons.flag_outlined,
      ),
    );
  }

  if (today != null && today.code >= 95) {
    tips.add(
      const GardenWeatherTip(
        title: 'Onweer',
        body: 'Bliksem en hagel kunnen planten en kassen beschadigen.',
        action: 'Blijf uit de kas bij onweer en dek gevoelige planten af.',
        level: GardenWeatherLevel.alert,
        icon: Icons.thunderstorm,
      ),
    );
  }

  if (tips.isEmpty) {
    tips.add(
      GardenWeatherTip(
        title: 'Gunstig tuinweer',
        body: 'Vandaag ${weatherCodeLabelNl(forecast.currentCode).toLowerCase()}, '
            'goed moment voor onderhoud en oogst.',
        action: 'Plan snoei, oogst of onderhoud voor vandaag of morgen.',
        level: GardenWeatherLevel.ok,
        icon: Icons.yard_outlined,
      ),
    );
  }

  return tips;
}

bool hasUrgentGardenWeather(List<GardenWeatherTip> tips) {
  return tips.any((t) => t.level == GardenWeatherLevel.alert);
}

/// Alleen echte beschermingsacties voor de home-actielijst.
List<GardenWeatherTip> urgentWeatherTipsForActions(WeatherForecast? forecast) {
  if (forecast == null) return const [];
  return gardenTipsFromForecast(forecast)
      .where((t) => t.level == GardenWeatherLevel.alert)
      .toList();
}

String notificationSummary(List<GardenWeatherTip> tips) {
  final urgent = tips.where((t) => t.level == GardenWeatherLevel.alert).toList();
  if (urgent.isNotEmpty) {
    return urgent.map((t) => t.title).take(2).join(' · ');
  }
  final watch = tips.where((t) => t.level == GardenWeatherLevel.watch).toList();
  if (watch.isNotEmpty) return watch.first.title;
  return tips.first.title;
}
