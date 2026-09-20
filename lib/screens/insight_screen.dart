import 'package:flutter/material.dart';

import '../data/daily_tip_notification_service.dart';
import '../data/daily_tip_prefs_store.dart';
import '../data/garden_insight_snapshot.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/insect_scan_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../data/weather_prefs_store.dart';
import '../data/weather_service.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/garden_insight_dashboard.dart';
import '../widgets/tuin_space_switcher.dart';

/// AI-tuindashboard: gezondheid, problemen, acties en trends.
class InsightScreen extends StatefulWidget {
  const InsightScreen({
    super.key,
    required this.gardenStore,
    required this.profileStore,
    required this.repository,
    required this.insectStore,
    required this.weatherPrefs,
    required this.scanPrefs,
    required this.dailyTipPrefs,
  });

  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final VegetableRepository repository;
  final InsectScanStore insectStore;
  final WeatherPrefsStore weatherPrefs;
  final GardenScanPrefsStore scanPrefs;
  final DailyTipPrefsStore dailyTipPrefs;

  @override
  State<InsightScreen> createState() => _InsightScreenState();
}

class _InsightScreenState extends State<InsightScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherForecast? _forecast;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_onDataChanged);
    widget.profileStore.addListener(_onDataChanged);
    widget.insectStore.addListener(_onDataChanged);
    widget.weatherPrefs.addListener(_onDataChanged);
    widget.dailyTipPrefs.addListener(_onDataChanged);
    _loadWeather();
  }

  @override
  void dispose() {
    widget.gardenStore.removeListener(_onDataChanged);
    widget.profileStore.removeListener(_onDataChanged);
    widget.insectStore.removeListener(_onDataChanged);
    widget.weatherPrefs.removeListener(_onDataChanged);
    widget.dailyTipPrefs.removeListener(_onDataChanged);
    super.dispose();
  }

  Future<void> _onDailyTipNotificationsChanged(bool enabled) async {
    await widget.dailyTipPrefs.setNotificationsEnabled(enabled);
    await DailyTipNotificationService.instance.sync(enabled: enabled);
  }

  void _onDataChanged() => setState(() {});

  Future<void> _loadWeather() async {
    setState(() => _weatherLoading = true);
    try {
      final forecast = await _weatherService.fetch(
        lat: widget.weatherPrefs.lat,
        lon: widget.weatherPrefs.lon,
        placeName: widget.weatherPrefs.placeName,
      );
      if (!mounted) return;
      setState(() {
        _forecast = forecast;
        _weatherLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _forecast = null;
        _weatherLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = buildGardenInsightSnapshot(
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
      insectStore: widget.insectStore,
      scanPrefs: widget.scanPrefs,
      forecast: _forecast,
    );

    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        title: const Text('Inzicht'),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: TuinierColors.border, height: 1),
        ),
        actions: [
          IconButton(
            tooltip: 'Verversen',
            onPressed: _loadWeather,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            if (widget.gardenStore.hasMultipleSpaces) ...[
              Align(
                alignment: Alignment.centerLeft,
                child: TuinSpaceSwitcher(
                  gardenStore: widget.gardenStore,
                  useTitleStyle: false,
                ),
              ),
              const SizedBox(height: 12),
            ],
            Text(
              snapshot.moestuinName,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 12),
            GardenInsightDashboard(
              snapshot: snapshot,
              dailyTipPrefs: widget.dailyTipPrefs,
              insectStore: widget.insectStore,
              onResolveHarmfulPest: (id) => widget.insectStore.resolveEntry(id),
              onDailyTipNotificationsChanged: _onDailyTipNotificationsChanged,
              weatherLoading: _weatherLoading,
              onRefreshWeather: _loadWeather,
            ),
          ],
        ),
      ),
    );
  }
}
