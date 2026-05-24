import 'package:flutter/material.dart';

import '../data/garden_weather_advice.dart';
import '../data/weather_notification_service.dart';
import '../data/weather_prefs_store.dart';
import '../data/weather_service.dart';

/// Weer voor de moestuin + tuinadvies en meldingen.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    required this.weatherPrefs,
  });

  final WeatherPrefsStore weatherPrefs;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();
  WeatherForecast? _forecast;
  List<GardenWeatherTip> _tips = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    widget.weatherPrefs.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.weatherPrefs.removeListener(_load);
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final forecast = await _service.fetch(
        lat: widget.weatherPrefs.lat,
        lon: widget.weatherPrefs.lon,
        placeName: widget.weatherPrefs.placeName,
      );
      final tips = gardenTipsFromForecast(forecast);
      await WeatherNotificationService.instance.maybeNotify(
        forecast: forecast,
        enabled: widget.weatherPrefs.notificationsEnabled,
      );
      if (!mounted) return;
      setState(() {
        _forecast = forecast;
        _tips = tips;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _pickCity() async {
    final picked = await showModalBottomSheet<WeatherCityOption>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Kies je tuinlocatie',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            ...kWeatherCities.map(
              (c) => ListTile(
                title: Text(c.name),
                trailing: widget.weatherPrefs.placeName == c.name
                    ? const Icon(Icons.check)
                    : null,
                onTap: () => Navigator.pop(ctx, c),
              ),
            ),
          ],
        ),
      ),
    );
    if (picked == null) return;
    await widget.weatherPrefs.setLocation(
      lat: picked.lat,
      lon: picked.lon,
      placeName: picked.name,
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weer & tuin'),
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Verversen',
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Weer kon niet laden',
                          style: t.textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(_error!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: _load,
                          child: const Text('Opnieuw proberen'),
                        ),
                      ],
                    ),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                    children: [
                      OutlinedButton.icon(
                        onPressed: _pickCity,
                        icon: const Icon(Icons.place_outlined),
                        label: Text(widget.weatherPrefs.placeName),
                        style: OutlinedButton.styleFrom(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 12,
                          ),
                        ),
                      ),
                      if (_forecast != null) ...[
                        const SizedBox(height: 12),
                        _CurrentCard(forecast: _forecast!),
                        const SizedBox(height: 16),
                        Text(
                          'Komende dagen',
                          style: t.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 118,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _forecast!.daily.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemBuilder: (_, i) {
                              final d = _forecast!.daily[i];
                              return _DayChip(day: d);
                            },
                          ),
                        ),
                      ],
                      const SizedBox(height: 20),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: const Text('Weer-meldingen'),
                        subtitle: const Text(
                          'Bij hitte, vorst, storm of veel regen (max. 1× per dag)',
                        ),
                        value: widget.weatherPrefs.notificationsEnabled,
                        onChanged: widget.weatherPrefs.setNotificationsEnabled,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Wat te doen in de tuin',
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._tips.map((tip) => _TipCard(tip: tip)),
                    ],
                  ),
                ),
    );
  }
}

class _CurrentCard extends StatelessWidget {
  const _CurrentCard({required this.forecast});

  final WeatherForecast forecast;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Text(
              weatherEmoji(forecast.currentCode),
              style: const TextStyle(fontSize: 48),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${forecast.currentTempC.round()}°C',
                    style: t.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(weatherCodeLabelNl(forecast.currentCode)),
                  Text(
                    'Wind ${forecast.currentWindKmh.round()} km/u',
                    style: t.textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({required this.day});

  final DailyWeather day;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final weekdays = ['ma', 'di', 'wo', 'do', 'vr', 'za', 'zo'];
    final label = weekdays[day.date.weekday - 1];

    return Container(
      width: 88,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: t.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(label, style: t.textTheme.labelLarge),
          Text(
            weatherEmoji(day.code),
            style: const TextStyle(fontSize: 22),
          ),
          Text(
            '${day.maxTempC.round()}° / ${day.minTempC.round()}°',
            style: t.textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard({required this.tip});

  final GardenWeatherTip tip;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final Color bg;
    final Color border;
    switch (tip.level) {
      case GardenWeatherLevel.ok:
        bg = t.colorScheme.primaryContainer.withValues(alpha: 0.35);
        border = t.colorScheme.primary.withValues(alpha: 0.3);
      case GardenWeatherLevel.watch:
        bg = Colors.orange.withValues(alpha: 0.12);
        border = Colors.orange.withValues(alpha: 0.45);
      case GardenWeatherLevel.alert:
        bg = t.colorScheme.errorContainer.withValues(alpha: 0.45);
        border = t.colorScheme.error.withValues(alpha: 0.5);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: border),
        ),
        child: ListTile(
          leading: Icon(tip.icon, color: t.colorScheme.onSurface),
          title: Text(
            tip.title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(tip.body),
        ),
      ),
    );
  }
}
