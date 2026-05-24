import 'dart:convert';

import 'package:http/http.dart' as http;

/// Huidig weer + komende dagen (Open-Meteo, gratis).
class WeatherForecast {
  const WeatherForecast({
    required this.placeName,
    required this.currentTempC,
    required this.currentCode,
    required this.currentWindKmh,
    required this.currentPrecipMm,
    required this.daily,
  });

  final String placeName;
  final double currentTempC;
  final int currentCode;
  final double currentWindKmh;
  final double currentPrecipMm;
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
  });

  final DateTime date;
  final int code;
  final double maxTempC;
  final double minTempC;
  final double precipMm;
  final double maxWindKmh;
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
      '&current=temperature_2m,weather_code,precipitation,wind_speed_10m'
      '&daily=weather_code,temperature_2m_max,temperature_2m_min,'
      'precipitation_sum,wind_speed_10m_max'
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
        ),
      );
    }

    return WeatherForecast(
      placeName: placeName,
      currentTempC: (current['temperature_2m'] as num).toDouble(),
      currentCode: (current['weather_code'] as num).toInt(),
      currentWindKmh: (current['wind_speed_10m'] as num).toDouble(),
      currentPrecipMm: (current['precipitation'] as num).toDouble(),
      daily: days,
    );
  }
}

String weatherCodeLabelNl(int code) {
  if (code == 0) return 'Helder';
  if (code <= 3) return 'Deels bewolkt';
  if (code <= 48) return 'Mist / bewolkt';
  if (code <= 57) return 'Motregen';
  if (code <= 67) return 'Regen';
  if (code <= 77) return 'Sneeuw';
  if (code <= 82) return 'Buien';
  if (code <= 86) return 'Sneeuwbuien';
  if (code <= 99) return 'Onweer';
  return 'Wisselend';
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
