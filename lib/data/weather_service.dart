import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Huidig weer + komende dagen (Open-Meteo, gratis).
class WeatherForecast {
  const WeatherForecast({
    required this.placeName,
    required this.currentTempC,
    required this.currentCode,
    required this.currentWindKmh,
    required this.currentPrecipMm,
    required this.currentHumidityPercent,
    required this.currentUvIndex,
    required this.isDay,
    required this.daily,
  });

  final String placeName;
  final double currentTempC;
  final int currentCode;
  final double currentWindKmh;
  final double currentPrecipMm;
  final int currentHumidityPercent;
  final double currentUvIndex;
  final bool isDay;
  final List<DailyWeather> daily;
}

class DailyWeather {
  const DailyWeather({
    required this.date,
    required this.code,
    required this.maxTempC,
    required this.minTempC,
    required this.precipMm,
    required this.maxWindKmh,
    required this.precipChancePercent,
    required this.maxUvIndex,
    required this.sunrise,
    required this.sunset,
  });

  final DateTime date;
  final int code;
  final double maxTempC;
  final double minTempC;
  final double precipMm;
  final double maxWindKmh;
  final int precipChancePercent;
  final double maxUvIndex;
  final DateTime sunrise;
  final DateTime sunset;

  bool isDayAt(DateTime moment) {
    return !moment.isBefore(sunrise) && moment.isBefore(sunset);
  }
}

class WeatherService {
  Future<WeatherForecast> fetch({
    required double lat,
    required double lon,
    required String placeName,
  }) async {
    final uri = Uri.parse(
      'https://api.open-meteo.com/v1/forecast'
      '?latitude=$lat&longitude=$lon'
      '&current=temperature_2m,relative_humidity_2m,weather_code,'
      'precipitation,wind_speed_10m,uv_index,is_day'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_sum,wind_speed_10m_max,precipitation_probability_max,'
      'uv_index_max,sunrise,sunset'
      '&timezone=Europe%2FAmsterdam&forecast_days=7',
    );

    final response = await http.get(uri).timeout(const Duration(seconds: 15));
    if (response.statusCode != 200) {
      throw Exception('Weer niet beschikbaar (${response.statusCode})');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final current = json['current'] as Map<String, dynamic>;
    final daily = json['daily'] as Map<String, dynamic>;

    final dates = (daily['time'] as List).cast<String>();
    final codes = (daily['weather_code'] as List).cast<num>();
    final maxT = (daily['temperature_2m_max'] as List).cast<num>();
    final minT = (daily['temperature_2m_min'] as List).cast<num>();
    final precip = (daily['precipitation_sum'] as List).cast<num>();
    final wind = (daily['wind_speed_10m_max'] as List).cast<num>();
    final precipProb =
        (daily['precipitation_probability_max'] as List).cast<num>();
    final uvMax = (daily['uv_index_max'] as List).cast<num>();
    final sunrises = (daily['sunrise'] as List).cast<String>();
    final sunsets = (daily['sunset'] as List).cast<String>();

    final days = <DailyWeather>[];
    for (var i = 0; i < dates.length; i++) {
      days.add(
        DailyWeather(
          date: DateTime.parse(dates[i]),
          code: codes[i].toInt(),
          maxTempC: maxT[i].toDouble(),
          minTempC: minT[i].toDouble(),
          precipMm: precip[i].toDouble(),
          maxWindKmh: wind[i].toDouble(),
          precipChancePercent: precipProb[i].round(),
          maxUvIndex: uvMax[i].toDouble(),
          sunrise: DateTime.parse(sunrises[i]),
          sunset: DateTime.parse(sunsets[i]),
        ),
      );
    }

    return WeatherForecast(
      placeName: placeName,
      currentTempC: (current['temperature_2m'] as num).toDouble(),
      currentCode: (current['weather_code'] as num).toInt(),
      currentWindKmh: (current['wind_speed_10m'] as num).toDouble(),
      currentPrecipMm: (current['precipitation'] as num).toDouble(),
      currentHumidityPercent:
          (current['relative_humidity_2m'] as num).round(),
      currentUvIndex: (current['uv_index'] as num?)?.toDouble() ?? 0,
      isDay: (current['is_day'] as num?)?.toInt() == 1,
      daily: days,
    );
  }
}

String weatherCodeLabelNl(int code, {bool isDay = true}) {
  if (code == 0) return isDay ? 'Helder' : 'Heldere nacht';
  if (code <= 3) return isDay ? 'Deels bewolkt' : 'Deels bewolkt (nacht)';
  if (code <= 48) return isDay ? 'Mist / bewolkt' : 'Bewolkt (nacht)';
  if (code <= 57) return 'Motregen';
  if (code <= 67) return 'Regen';
  if (code <= 77) return 'Sneeuw';
  if (code <= 82) return 'Buien';
  if (code <= 86) return 'Sneeuwbuien';
  if (code <= 99) return 'Onweer';
  return 'Wisselend';
}

/// Icoon voor 7-dagenweer: mixt WMO-code met regenkans en -hoeveelheid.
int dailyWeatherIconCode(DailyWeather day, {bool isDay = true}) {
  final code = day.code;
  final chance = day.precipChancePercent;
  final mm = day.precipMm;

  if (code >= 95) return code;
  if (code >= 71 && code <= 77) return code;
  if (code >= 85 && code <= 86) return code;

  final heavy = chance >= 88 && mm >= 2.5;
  final wet = chance >= 72 || mm >= 2;
  final showery = chance >= 40 || mm >= 0.35;
  final mostlyDry = chance < 35 && mm < 0.25;

  if (mostlyDry) {
    if (code <= 1) return 0;
    if (code <= 3) return isDay ? 2 : 3;
    if (code <= 48) return 3;
  }

  if (showery && !heavy) {
    if (isDay) return 53;
    return wet ? 55 : 3;
  }

  if (wet && !heavy) {
    if (code >= 51 && code <= 67) return code.clamp(55, 63);
    return 61;
  }

  if (heavy) {
    if (code >= 80 && code <= 82) return code;
    return code >= 61 && code <= 67 ? code : 65;
  }

  if (code >= 51 && code <= 67) {
    if (chance < 65) return isDay ? 53 : 55;
    if (chance < 82) return isDay ? 53 : 61;
    return code;
  }

  if (code >= 80 && code <= 82) return isDay ? 80 : 82;
  if (code <= 3) return code;
  if (code <= 48) return showery ? (isDay ? 2 : 3) : code;

  return code;
}

String weatherEmoji(int code) {
  if (code == 0) return '☀️';
  if (code <= 3) return '🌤️';
  if (code <= 48) return '☁️';
  if (code <= 57) return '🌦️';
  if (code <= 67) return '🌧️';
  if (code <= 77) return '❄️';
  if (code <= 82) return '🌧️';
  if (code <= 86) return '🌨️';
  return '⛈️';
}

IconData weatherIconRounded(int code) {
  if (code == 0) return Icons.wb_sunny_rounded;
  if (code <= 3) return Icons.wb_cloudy_rounded;
  if (code <= 48) return Icons.cloud_rounded;
  if (code <= 57) return Icons.grain_rounded;
  if (code <= 67) return Icons.umbrella_rounded;
  if (code <= 77) return Icons.ac_unit_rounded;
  if (code <= 86) return Icons.cloud_queue_rounded;
  return Icons.thunderstorm_rounded;
}
