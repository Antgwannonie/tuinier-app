import 'package:flutter/material.dart';

import '../data/ai_settings_store.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../data/weather_notifications_sync.dart';
import '../data/weather_prefs_store.dart';

/// Instellingen voor Mijn moestuin (scan, meldingen).
class MyGardenScreen extends StatelessWidget {
  const MyGardenScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.weatherPrefs,
    required this.aiSettings,
    this.onGoToPlantScan,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final WeatherPrefsStore weatherPrefs;
  final AiSettingsStore aiSettings;
  final void Function({String? vegetableId})? onGoToPlantScan;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instellingen'),
      ),
      body: _SettingsBody(
        gardenStore: gardenStore,
        profileStore: profileStore,
        repository: repository,
        scanPrefs: scanPrefs,
        weatherPrefs: weatherPrefs,
        aiSettings: aiSettings,
      ),
    );
  }
}

class _SettingsBody extends StatefulWidget {
  const _SettingsBody({
    required this.gardenStore,
    required this.profileStore,
    required this.repository,
    required this.scanPrefs,
    required this.weatherPrefs,
    required this.aiSettings,
  });

  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final VegetableRepository repository;
  final GardenScanPrefsStore scanPrefs;
  final WeatherPrefsStore weatherPrefs;
  final AiSettingsStore aiSettings;

  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody> {
  @override
  void initState() {
    super.initState();
    widget.scanPrefs.addListener(_onPrefsChanged);
    widget.weatherPrefs.addListener(_onPrefsChanged);
  }

  @override
  void dispose() {
    widget.scanPrefs.removeListener(_onPrefsChanged);
    widget.weatherPrefs.removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _onPrefsChanged() => setState(() {});

  Future<void> _reschedule() async {
    await syncGardenNotifications(
      profileStore: widget.profileStore,
      gardenStore: widget.gardenStore,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
  }

  Future<void> _rescheduleWeather() async {
    await syncWeatherNotifications(
      weatherPrefs: widget.weatherPrefs,
      aiSettings: widget.aiSettings,
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scan = widget.scanPrefs;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Scan & herinneringen',
          style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'De eerste scan kan meteen na “geplant”. Hier stel je in na hoeveel '
          'dagen een extra herinnering komt als je nog niet gescand hebt, en '
          'hoe vaak je daarna opnieuw scant.',
          style: t.textTheme.bodyMedium?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Extra herinnering eerste foto',
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          '${scan.daysUntilFirstPhoto} dagen',
          style: t.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: t.colorScheme.primary,
          ),
        ),
        Slider(
          value: scan.daysUntilFirstPhoto.toDouble(),
          min: GardenScanPrefsStore.minDaysUntilFirstPhoto.toDouble(),
          max: GardenScanPrefsStore.maxDaysUntilFirstPhoto.toDouble(),
          divisions: GardenScanPrefsStore.maxDaysUntilFirstPhoto -
              GardenScanPrefsStore.minDaysUntilFirstPhoto,
          label: '${scan.daysUntilFirstPhoto} d',
          onChanged: (v) async {
            await scan.setDaysUntilFirstPhoto(v.round());
            await _reschedule();
          },
        ),
        const SizedBox(height: 16),
        Text(
          'Interval tussen scans',
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        Text(
          'Elke ${scan.weeklyScanIntervalDays} dagen',
          style: t.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: t.colorScheme.primary,
          ),
        ),
        Slider(
          value: scan.weeklyScanIntervalDays.toDouble(),
          min: GardenScanPrefsStore.minWeeklyScanIntervalDays.toDouble(),
          max: GardenScanPrefsStore.maxWeeklyScanIntervalDays.toDouble(),
          divisions: GardenScanPrefsStore.maxWeeklyScanIntervalDays -
              GardenScanPrefsStore.minWeeklyScanIntervalDays,
          label: '${scan.weeklyScanIntervalDays} d',
          onChanged: (v) async {
            final days = v.round();
            await scan.setWeeklyScanIntervalDays(days);
            await widget.profileStore.recalculateNextScanDueForAll(days);
            await _reschedule();
          },
        ),
        const Divider(height: 32),
        Text(
          'Meldingen',
          style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Meldingen aan'),
          subtitle: Text(
            widget.gardenStore.notificationsEnabled
                ? 'Herinneringen voor foto\'s en oogst staan aan'
                : 'Geen meldingen',
          ),
          value: widget.gardenStore.notificationsEnabled,
          onChanged: (v) async {
            await widget.gardenStore.setNotificationsEnabled(v);
            await _reschedule();
          },
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Weermeldingen'),
          subtitle: Text(
            widget.weatherPrefs.notificationsEnabled
                ? 'Elke ochtend (~07:30) een AI-samenvatting van het tuinweer'
                : 'Geen weer-meldingen',
          ),
          value: widget.weatherPrefs.notificationsEnabled,
          onChanged: (v) async {
            await widget.weatherPrefs.setNotificationsEnabled(v);
            await _rescheduleWeather();
          },
        ),
        const Divider(height: 32),
        Text(
          'Over Mijn moestuin',
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Je groenten en taken staan op het startscherm. '
          'Voeg groenten toe via + of via Alle groenten zoeken.',
          style: t.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
