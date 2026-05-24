import 'dart:async';

import 'package:flutter/material.dart';

import '../data/garden_growth_engine.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import 'add_vegetable_screen.dart';
import '../data/garden_notifications_sync.dart';
import '../data/garden_scan_prefs_store.dart';
import '../widgets/vegetable_thumbnail.dart';
import 'vegetable_detail_screen.dart';

class MyGardenScreen extends StatefulWidget {
  const MyGardenScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    this.onGoToPlantScan,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final void Function({String? vegetableId})? onGoToPlantScan;

  @override
  State<MyGardenScreen> createState() => _MyGardenScreenState();
}

class _MyGardenScreenState extends State<MyGardenScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final TabController _tabs;
  Timer? _midnightTimer;
  DateTime? _countdownAnchorDay;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _countdownAnchorDay = _todayDateOnly();
    _scheduleMidnightRefresh();
    _tabs = TabController(length: 2, vsync: this)
      ..addListener(() {
        if (!_tabs.indexIsChanging) setState(() {});
      });
    widget.gardenStore.addListener(_onStoreChanged);
    widget.profileStore.addListener(_onStoreChanged);
    _ensureProfiles();
  }

  Future<void> _ensureProfiles() async {
    for (final id in widget.gardenStore.ids) {
      await widget.profileStore.ensureProfile(id);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _midnightTimer?.cancel();
    widget.gardenStore.removeListener(_onStoreChanged);
    widget.profileStore.removeListener(_onStoreChanged);
    _tabs.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshCountdownIfNewDay();
    }
  }

  DateTime _todayDateOnly() {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  void _scheduleMidnightRefresh() {
    _midnightTimer?.cancel();
    final now = DateTime.now();
    final nextMidnight = DateTime(now.year, now.month, now.day + 1);
    _midnightTimer = Timer(nextMidnight.difference(now), () {
      if (!mounted) return;
      _refreshCountdownIfNewDay();
      _scheduleMidnightRefresh();
    });
  }

  void _refreshCountdownIfNewDay() {
    final today = _todayDateOnly();
    if (_countdownAnchorDay == today) return;
    _countdownAnchorDay = today;
    setState(() {});
  }

  void _onStoreChanged() => setState(() {});

  List<Vegetable> get _myPlants {
    final list = <Vegetable>[];
    for (final id in widget.gardenStore.ids) {
      final v = widget.repository.byId(id);
      if (v != null) list.add(v);
    }
    list.sort((a, b) {
      final ia = growthInsightFor(
        a,
        widget.profileStore.profileFor(a.id),
        null,
        widget.scanPrefs.daysUntilFirstPhoto,
      );
      final ib = growthInsightFor(
        b,
        widget.profileStore.profileFor(b.id),
        null,
        widget.scanPrefs.daysUntilFirstPhoto,
      );
      final cmp = compareGrowthInsight(ia, ib);
      if (cmp != 0) return cmp;
      return a.nameNl.compareTo(b.nameNl);
    });
    return list;
  }

  void _openAdd() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => AddVegetableScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
        ),
      ),
    );
  }

  void _openDetail(Vegetable v) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(
          vegetable: v,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          onGoToPlantScan: widget.onGoToPlantScan != null
              ? () => widget.onGoToPlantScan!(vegetableId: v.id)
              : null,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final myPlants = _myPlants;
    final onListTab = _tabs.index == 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mijn moestuin'),
        bottom: TabBar(
          controller: _tabs,
          tabs: const [
            Tab(text: 'Mijn lijst'),
            Tab(text: 'Instellingen'),
          ],
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
            child: Text(
              'Maak je eigen moestuin door groenten toe te voegen en krijg '
              'meldingen van jouw favoriete groenten.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
          ),
          Expanded(
            child: TabBarView(
        controller: _tabs,
        children: [
          _MyListBody(
            myPlants: myPlants,
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            onDetail: _openDetail,
            onGoToPlantScan: widget.onGoToPlantScan,
          ),
          _SettingsBody(
            gardenStore: widget.gardenStore,
            profileStore: widget.profileStore,
            repository: widget.repository,
            scanPrefs: widget.scanPrefs,
          ),
        ],
            ),
          ),
        ],
      ),
      floatingActionButton: onListTab
          ? FloatingActionButton(
              onPressed: _openAdd,
              tooltip: 'Groente toevoegen',
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _MyListBody extends StatelessWidget {
  const _MyListBody({
    required this.myPlants,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.onDetail,
    this.onGoToPlantScan,
  });

  final List<Vegetable> myPlants;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final void Function(Vegetable) onDetail;
  final void Function({String? vegetableId})? onGoToPlantScan;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    if (myPlants.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.yard_outlined,
                size: 64,
                color: t.colorScheme.primary.withValues(alpha: 0.6),
              ),
              const SizedBox(height: 16),
              Text(
                'Nog geen groenten gekozen',
                style: t.textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Tik rechtsonder op + om groenten toe te voegen. '
                'Filter op verzameling (bieten, sla, …).',
                textAlign: TextAlign.center,
                style: t.textTheme.bodyMedium?.copyWith(
                  color: t.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            '${myPlants.length} soort(en) in jouw tuin',
            style: t.textTheme.labelLarge?.copyWith(
              color: t.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(12, 4, 12, 16),
            itemCount: myPlants.length,
            itemBuilder: (context, i) {
              final v = myPlants[i];
              final insight = growthInsightFor(
                v,
                profileStore.profileFor(v.id),
                null,
                scanPrefs.daysUntilFirstPhoto,
              );
              return _GardenPlantTile(
                vegetable: v,
                insight: insight,
                onTap: () => onDetail(v),
                onScan: () => onGoToPlantScan?.call(vegetableId: v.id),
                onRemove: () async {
                  await gardenStore.remove(v.id);
                  await profileStore.removeProfile(v.id);
                },
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: OutlinedButton.icon(
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Lijst legen?'),
                  content: const Text(
                    'Alle groenten worden uit jouw moestuinlijst verwijderd.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Annuleren'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Legen'),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await gardenStore.clear();
                await profileStore.clear();
              }
            },
            icon: const Icon(Icons.delete_outline),
            label: const Text('Hele lijst legen'),
          ),
        ),
      ],
    );
  }
}

class _GardenPlantTile extends StatelessWidget {
  const _GardenPlantTile({
    required this.vegetable,
    required this.insight,
    required this.onTap,
    this.onScan,
    required this.onRemove,
  });

  final Vegetable vegetable;
  final PlantGrowthInsight? insight;
  final VoidCallback onTap;
  final VoidCallback? onScan;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final onTrack = insight != null &&
        !insight!.needsScan &&
        insight!.scheduleStatus == GrowthScheduleStatus.onTrack;
    final readyNow = insight != null &&
        insight!.daysUntilNext != null &&
        insight!.daysUntilNext! <= 0;

    final bg = onTrack || readyNow
        ? cs.surfaceContainerLowest
        : cs.surfaceContainerHigh.withValues(alpha: 0.85);
    final titleColor = onTrack || readyNow
        ? cs.onSurface
        : cs.onSurface.withValues(alpha: 0.5);

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 4, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                VegetableThumbnail(vegetable: vegetable),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vegetable.nameNl,
                        style: t.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: titleColor,
                        ),
                      ),
                      if (insight != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${insight!.scheduleStatus.emoji} '
                          '${insight!.scheduleStatus.label}',
                          style: t.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          insight!.summaryLine,
                          style: t.textTheme.bodyMedium,
                        ),
                        Text(
                          'Oogst: ${insight!.harvestWindowLabel}',
                          style: t.textTheme.labelMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                        if (onScan != null)
                          TextButton.icon(
                            onPressed: onScan,
                            icon: const Icon(Icons.photo_camera_outlined, size: 18),
                            label: Text(
                              insight!.needsScan
                                  ? 'Plant scannen'
                                  : 'Nieuwe foto',
                            ),
                            style: TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
                if (insight != null && insight!.daysUntilNext != null)
                  _DaysBadge(days: insight!.daysUntilNext!, ready: readyNow),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  tooltip: 'Verwijderen',
                  onPressed: onRemove,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DaysBadge extends StatelessWidget {
  const _DaysBadge({required this.days, required this.ready});

  final int days;
  final bool ready;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final label = ready ? 'Nu' : '${days.clamp(0, 999)}d';

    return Container(
      margin: const EdgeInsets.only(right: 4, top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: ready
            ? cs.primaryContainer
            : cs.onSurface.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: ready
              ? cs.onPrimaryContainer
              : cs.onSurface.withValues(alpha: 0.45),
          fontWeight: FontWeight.w700,
          fontSize: 13,
        ),
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
  });

  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final VegetableRepository repository;
  final GardenScanPrefsStore scanPrefs;

  @override
  State<_SettingsBody> createState() => _SettingsBodyState();
}

class _SettingsBodyState extends State<_SettingsBody> {
  @override
  void initState() {
    super.initState();
    widget.scanPrefs.addListener(_onPrefsChanged);
  }

  @override
  void dispose() {
    widget.scanPrefs.removeListener(_onPrefsChanged);
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
          'Bepaal wanneer je de eerste foto maakt en hoe vaak je daarna '
          'opnieuw scant. Dit geldt voor kalender, Start en meldingen.',
          style: t.textTheme.bodyMedium?.copyWith(
            color: t.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'Eerste foto na planten',
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
            await scan.setWeeklyScanIntervalDays(v.round());
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
        const Divider(height: 32),
        Text(
          'Over Mijn moestuin',
          style: t.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Je lijst wordt op dit toestel opgeslagen. '
          'De startpagina toont taken voor groenten in jouw lijst.',
          style: t.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
