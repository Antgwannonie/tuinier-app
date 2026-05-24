import 'package:flutter/material.dart';

import 'weather_service.dart';

enum GardenWeatherLevel { ok, watch, alert }

class GardenWeatherTip {
  const GardenWeatherTip({
    required this.title,
    required this.body,
    required this.level,
    required this.icon,
  });

  final String title;
  final String body;
  final GardenWeatherLevel level;
  final IconData icon;
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
        title: 'Hitte — extra water geven',
        body: 'Geef vroeg in de ochtend water. Jonge planten en kas '
            'beschermen met schaduwdoek. Niet bemesten bij extreme hitte.',
        level: GardenWeatherLevel.alert,
        icon: Icons.wb_sunny,
      ),
    );
  } else if (forecast.currentTempC >= 26 ||
      (today != null && today.maxTempC >= 28)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Warm — letten op droogte',
        body: 'Mulch rond planten helpt vocht vasthouden. '
            'Bladgroenten middag niet sproeien (verbranding).',
        level: GardenWeatherLevel.watch,
        icon: Icons.water_drop_outlined,
      ),
    );
  }

  if (today != null && today.minTempC <= 0) {
    tips.add(
      const GardenWeatherTip(
        title: 'Vorst vannacht — beschermen',
        body: 'Dek jonge planten, aardbeien en tomaten af. '
            'Oogst gevoelige bladgroenten vóór de vorst.',
        level: GardenWeatherLevel.alert,
        icon: Icons.ac_unit,
      ),
    );
  } else if ((tomorrow != null && tomorrow.minTempC <= 2) ||
      (today != null && today.minTempC <= 2)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Kou op komst',
        body: 'Geen gevoelige plantjes buiten zetten. '
            'Kas ventileren overdag, dicht bij koude nacht.',
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
        body: 'Geen extra sproeien. Controleer drainage bij potten. '
            'Niet omploegen op natte kleigrond.',
        level: GardenWeatherLevel.watch,
        icon: Icons.umbrella,
      ),
    );
  }

  if (forecast.currentWindKmh >= 50 ||
      (today != null && today.maxWindKmh >= 55)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Harde wind',
        body: 'Bind hoge planten en tomaten vast. '
            'Kasdeuren goed vergrendelen. Oogst geen grote bladgroenten.',
        level: GardenWeatherLevel.alert,
        icon: Icons.air,
      ),
    );
  } else if (forecast.currentWindKmh >= 35 ||
      (today != null && today.maxWindKmh >= 40)) {
    tips.add(
      const GardenWeatherTip(
        title: 'Flinke wind',
        body: 'Controleer klimrekken en schermen. '
            'Jonge plantjes beschutten.',
        level: GardenWeatherLevel.watch,
        icon: Icons.flag_outlined,
      ),
    );
  }

  if (today != null && today.code >= 95) {
    tips.add(
      const GardenWeatherTip(
        title: 'Onweer',
        body: 'Blijf uit de kas bij bliksem. '
            'Dek gevoelige planten af tegen hagel.',
        level: GardenWeatherLevel.alert,
        icon: Icons.thunderstorm,
      ),
    );
  }

  if (tips.isEmpty) {
    tips.add(
      GardenWeatherTip(
        title: 'Gunstig tuinweer',
        body: 'Vandaag ${weatherCodeLabelNl(forecast.currentCode).toLowerCase()} — '
            'goed moment voor onderhoud en oogst.',
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

String notificationSummary(List<GardenWeatherTip> tips) {
  final urgent = tips.where((t) => t.level == GardenWeatherLevel.alert).toList();
  if (urgent.isNotEmpty) {
    return urgent.map((t) => t.title).take(2).join(' · ');
  }
  final watch = tips.where((t) => t.level == GardenWeatherLevel.watch).toList();
  if (watch.isNotEmpty) return watch.first.title;
  return tips.first.title;
}
