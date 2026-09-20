import 'dart:async';

import 'package:flutter/material.dart';

import '../data/ai_settings_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_weather_advice.dart';
import '../data/garden_weather_coach_service.dart';
import '../data/garden_weather_dashboard.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../data/weather_notifications_sync.dart';
import '../data/weather_prefs_store.dart';
import '../data/weather_service.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/weather/garden_weather_dashboard_view.dart';

/// AI moestuin-weerdashboard.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({
    super.key,
    required this.weatherPrefs,
    required this.aiSettings,
    required this.gardenStore,
    required this.profileStore,
    required this.repository,
    this.embedded = false,
  });

  final WeatherPrefsStore weatherPrefs;
  final AiSettingsStore aiSettings;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final VegetableRepository repository;
  final bool embedded;

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _service = WeatherService();
  WeatherForecast? _forecast;
  GardenWeatherDashboard? _dashboard;
  bool _loading = true;
  bool _coachLoading = false;
  String? _error;
  int _dashboardRequestId = 0;

  @override
  void initState() {
    super.initState();
    widget.weatherPrefs.addListener(_load);
    widget.gardenStore.addListener(_load);
    widget.profileStore.addListener(_load);
    _load();
  }

  @override
  void dispose() {
    widget.weatherPrefs.removeListener(_load);
    widget.gardenStore.removeListener(_load);
    widget.profileStore.removeListener(_load);
    super.dispose();
  }

  List<Vegetable> _plantedCrops() {
    final out = <Vegetable>[];
    for (final id in widget.gardenStore.ids) {
      if (!(widget.profileStore.profileFor(id)?.isPlanted ?? false)) continue;
      final veg = widget.repository.byId(id);
      if (veg != null) out.add(veg);
    }
    out.sort((a, b) => a.nameNl.compareTo(b.nameNl));
    return out;
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
      if (!mounted) return;
      setState(() {
        _forecast = forecast;
        _loading = false;
      });
      unawaited(_loadDashboard(forecast: forecast, tips: tips));
      unawaited(
        syncWeatherNotifications(
          weatherPrefs: widget.weatherPrefs,
          aiSettings: widget.aiSettings,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          repository: widget.repository,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _loadDashboard({
    required WeatherForecast forecast,
    required List<GardenWeatherTip> tips,
  }) async {
    final requestId = ++_dashboardRequestId;
    final crops = _plantedCrops();
    final base = buildRuleBasedGardenWeatherDashboard(
      forecast: forecast,
      tips: tips,
      plantedCrops: crops,
    );
    final hasAi = widget.aiSettings.apiKey.trim().isNotEmpty;

    if (hasAi) {
      GardenWeatherCoachService.clearCache();
    }

    setState(() {
      _dashboard = base;
      _coachLoading = hasAi;
    });

    if (!hasAi) return;

    unawaited(_loadAiCoach(
      requestId: requestId,
      forecast: forecast,
      tips: tips,
      crops: crops,
      base: base,
    ));
    unawaited(_loadAiDashboardDetails(
      requestId: requestId,
      forecast: forecast,
      tips: tips,
      crops: crops,
    ));
  }

  Future<void> _loadAiCoach({
    required int requestId,
    required WeatherForecast forecast,
    required List<GardenWeatherTip> tips,
    required List<Vegetable> crops,
    required GardenWeatherDashboard base,
  }) async {
    try {
      final coach = await GardenWeatherCoachService(
        apiKey: widget.aiSettings.apiKey,
      ).coachForGarden(
        forecast: forecast,
        tips: tips,
        plantedCropNames: crops.map((v) => v.nameNl).toList(),
        gardenName: widget.gardenStore.activeSpace?.name,
      );
      if (!mounted || requestId != _dashboardRequestId) return;
      final current = _dashboard ?? base;
      setState(() {
        _dashboard = GardenWeatherDashboard(
          scoreToday: base.scoreToday,
          coachSummary: coach.summary,
          recommendedActions: coach.actionLines.isNotEmpty
              ? coach.actionLines
              : base.recommendedActions,
          impacts: current.impacts,
          todoCards: current.todoCards,
          risks: current.risks,
          cropAdvices: current.cropAdvices,
          usedAi: coach.usedAi,
        );
        _coachLoading = false;
      });
    } catch (_) {
      if (!mounted || requestId != _dashboardRequestId) return;
      setState(() => _coachLoading = false);
    }
  }

  Future<void> _loadAiDashboardDetails({
    required int requestId,
    required WeatherForecast forecast,
    required List<GardenWeatherTip> tips,
    required List<Vegetable> crops,
  }) async {
    try {
      final full = await GardenWeatherDashboardService(
        apiKey: widget.aiSettings.apiKey,
      ).build(
        forecast: forecast,
        tips: tips,
        plantedCrops: crops,
        gardenName: widget.gardenStore.activeSpace?.name,
      );
      if (!mounted || requestId != _dashboardRequestId || !full.usedAi) return;
      final current = _dashboard;
      if (current == null) return;
      setState(() {
        _dashboard = GardenWeatherDashboard(
          scoreToday: current.scoreToday,
          coachSummary: current.coachSummary,
          recommendedActions: current.recommendedActions,
          impacts: full.impacts,
          todoCards: full.todoCards,
          risks: full.risks,
          cropAdvices: full.cropAdvices,
          usedAi: current.usedAi,
        );
      });
    } catch (_) {
      // Regelgebaseerde gewassen/risico's blijven staan.
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
  }

  Widget _buildBody(ThemeData t) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Weer kon niet laden', style: t.textTheme.titleMedium),
            const SizedBox(height: 8),
            Text(_error!, textAlign: TextAlign.center, style: t.textTheme.bodySmall),
            const SizedBox(height: 12),
            FilledButton(onPressed: _load, child: const Text('Opnieuw proberen')),
          ],
        ),
      );
    }

    final content = GardenWeatherDashboardView(
      forecast: _forecast!,
      dashboard: _dashboard,
      coachLoading: _coachLoading,
      placeName: widget.weatherPrefs.placeName,
      onPickCity: _pickCity,
    );

    if (widget.embedded) return content;

    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [content],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (widget.embedded) return _buildBody(Theme.of(context));

    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        title: const Text('Weer'),
        backgroundColor: TuinierColors.background,
        actions: [
          IconButton(
            onPressed: _loading ? null : _load,
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Verversen',
          ),
        ],
      ),
      body: _buildBody(Theme.of(context)),
    );
  }
}
