import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opgeslagen weerlocatie en melding-voorkeur.
class WeatherPrefsStore extends ChangeNotifier {
  static const _latKey = 'weather_lat';
  static const _lonKey = 'weather_lon';
  static const _placeKey = 'weather_place_name';
  static const _notifyKey = 'weather_notifications';

  static const double defaultLat = 52.37;
  static const double defaultLon = 4.89;
  static const String defaultPlace = 'Amsterdam';

  double _lat = defaultLat;
  double _lon = defaultLon;
  String _placeName = defaultPlace;
  bool _notificationsEnabled = true;

  double get lat => _lat;
  double get lon => _lon;
  String get placeName => _placeName;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    _lat = prefs.getDouble(_latKey) ?? defaultLat;
    _lon = prefs.getDouble(_lonKey) ?? defaultLon;
    _placeName = prefs.getString(_placeKey) ?? defaultPlace;
    _notificationsEnabled = prefs.getBool(_notifyKey) ?? true;
    notifyListeners();
  }

  Future<void> setLocation({
    required double lat,
    required double lon,
    required String placeName,
  }) async {
    _lat = lat;
    _lon = lon;
    _placeName = placeName;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_latKey, lat);
    await prefs.setDouble(_lonKey, lon);
    await prefs.setString(_placeKey, placeName);
    notifyListeners();
  }

  Future<void> setNotificationsEnabled(bool enabled) async {
    _notificationsEnabled = enabled;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_notifyKey, enabled);
    notifyListeners();
  }
}

/// Bekende NL-steden voor weer (zonder GPS).
class WeatherCityOption {
  const WeatherCityOption(this.name, this.lat, this.lon);

  final String name;
  final double lat;
  final double lon;
}

const List<WeatherCityOption> kWeatherCities = [
  WeatherCityOption('Amsterdam', 52.37, 4.89),
  WeatherCityOption('Rotterdam', 51.92, 4.48),
  WeatherCityOption('Utrecht', 52.09, 5.12),
  WeatherCityOption('Den Haag', 52.08, 4.31),
  WeatherCityOption('Eindhoven', 51.44, 5.48),
  WeatherCityOption('Groningen', 53.22, 6.57),
  WeatherCityOption('Maastricht', 50.85, 5.69),
  WeatherCityOption('Zwolle', 52.52, 6.09),
];
