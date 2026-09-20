import 'package:flutter/material.dart';

import '../data/add_plant_apply.dart';
import '../data/garden_notifications_sync.dart';
import '../data/plant_season_activation.dart';
import '../data/ai_settings_store.dart';
import '../data/garden_daily_tips.dart';
import '../data/garden_health_score.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/garden_weather_advice.dart';
import '../data/home_upcoming_items.dart';
import '../data/insect_scan_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../data/weather_notifications_sync.dart';
import '../data/weather_prefs_store.dart';
import '../data/weather_service.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';
import '../theme/tuinier_theme.dart';
import '../widgets/add_plant_setup_sheet.dart';
import '../widgets/garden_health_plant_icon.dart';
import '../widgets/home_green_pattern.dart';
import '../widgets/home_weather_badge.dart';
import '../widgets/garden_home_action_list_tile.dart';
import '../widgets/home_action_detail_sheet.dart';
import '../widgets/home_moestuin_actions.dart';
import '../widgets/tuin_space_switcher.dart';
import '../widgets/vegetable_thumbnail.dart';
import 'my_garden_screen.dart';
import '../widgets/garden_plant_insight_body.dart';
import 'garden_plant_insight_screen.dart';
import 'vegetable_detail_screen.dart';
import 'weather_screen.dart';

/// Home-dashboard volgens mockup: groene gezondheid, witte lijstkaarten, AI-tip.
class DashboardHomeScreen extends StatefulWidget {
  const DashboardHomeScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.scanPrefs,
    required this.insectScanStore,
    required this.weatherPrefs,
    required this.aiSettings,
    this.onGoToMoestuin,
    this.onGoToPlantScan,
    this.onGoToPlanner,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final InsectScanStore insectScanStore;
  final WeatherPrefsStore weatherPrefs;
  final AiSettingsStore aiSettings;
  final VoidCallback? onGoToMoestuin;
  final void Function({String? vegetableId})? onGoToPlantScan;
  final VoidCallback? onGoToPlanner;

  @override
  State<DashboardHomeScreen> createState() => _DashboardHomeScreenState();
}

class _DashboardHomeScreenState extends State<DashboardHomeScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherForecast? _forecast;
  bool _weatherLoading = true;

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_refresh);
    widget.profileStore.addListener(_refresh);
    _loadWeather();
    _ensurePinnedActions();
  }

  Future<void> _ensurePinnedActions() async {
    await widget.profileStore.ensurePinnedMoestuinActions(
      vegetableIds: widget.gardenStore.ids,
      vegetableById: widget.repository.byId,
      scanPrefs: widget.scanPrefs,
    );
  }

  @override
  void dispose() {
    widget.gardenStore.removeListener(_refresh);
    widget.profileStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() => setState(() {});

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
      await syncWeatherNotifications(
        weatherPrefs: widget.weatherPrefs,
        aiSettings: widget.aiSettings,
        gardenStore: widget.gardenStore,
        profileStore: widget.profileStore,
        repository: widget.repository,
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _forecast = null;
        _weatherLoading = false;
      });
    }
  }

  String get _greeting {
    final h = DateTime.now().hour;
    if (h < 12) return 'Goedemorgen';
    if (h < 18) return 'Goedemiddag';
    return 'Goedenavond';
  }

  void _openSettings() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => MyGardenScreen(
          repository: widget.repository,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          weatherPrefs: widget.weatherPrefs,
          aiSettings: widget.aiSettings,
          onGoToPlantScan: widget.onGoToPlantScan,
        ),
      ),
    );
  }

  void _openDetail(Vegetable veg, {bool scanHistory = false}) {
    final inGarden = widget.gardenStore.contains(veg.id);
    if (inGarden) {
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(
          builder: (_) => GardenPlantInsightScreen(
            vegetable: veg,
            profileStore: widget.profileStore,
            scanPrefs: widget.scanPrefs,
            gardenStore: widget.gardenStore,
            repository: widget.repository,
            initialSection: scanHistory
                ? GardenPlantInsightSection.scanHistory
                : GardenPlantInsightSection.insights,
            onGoToPlantScan: widget.onGoToPlantScan != null
                ? () => widget.onGoToPlantScan!(vegetableId: veg.id)
                : null,
          ),
        ),
      );
      return;
    }

    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(
          vegetable: veg,
          focusMonth: DateTime.now().month,
          repository: widget.repository,
          presentation: VegetableDetailPresentation.encyclopedia,
        ),
      ),
    );
  }

  void _openWeather() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => WeatherScreen(
          weatherPrefs: widget.weatherPrefs,
          aiSettings: widget.aiSettings,
          gardenStore: widget.gardenStore,
          profileStore: widget.profileStore,
          repository: widget.repository,
        ),
      ),
    );
  }

  void _onTaskTap(GardenHomeAction action) {
    final profile = widget.profileStore.profileFor(action.vegetable.id);
    showHomeActionDetailSheet(
      context: context,
      action: action,
      profile: profile,
      profileStore: widget.profileStore,
      scanPrefs: widget.scanPrefs,
      onGoToScan: widget.onGoToPlantScan == null
          ? null
          : () => widget.onGoToPlantScan!(vegetableId: action.vegetable.id),
      onOpenPlantDetail: () => _openDetail(action.vegetable),
    );
  }

  Future<void> _addToGarden(Vegetable veg) async {
    if (widget.gardenStore.contains(veg.id)) {
      _openDetail(veg);
      return;
    }

    final setup = await showAddPlantSetupSheet(
      context,
      vegetable: veg,
      repository: widget.repository,
      aiSettings: widget.aiSettings,
    );
    if (setup == null || !mounted) return;

    final added = await applyAddPlantSetup(
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      setup: setup,
      repository: widget.repository,
      scanPrefs: widget.scanPrefs,
    );
    if (!mounted) return;
    if (added) {
      await syncGardenNotifications(
        profileStore: widget.profileStore,
        gardenStore: widget.gardenStore,
        repository: widget.repository,
        scanPrefs: widget.scanPrefs,
      );
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          addPlantSuccessMessage(
            plantName: veg.nameNl,
            setup: setup,
            added: added,
            vegetable: veg,
          ),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showDailyTip(GardenDailyTip tip) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) {
        final t = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: TuinierColors.primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: TuinierColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Weetje van de dag',
                        style: tuinDisplayStyle(
                          ctx,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  tip.title,
                  style: tuinDisplayStyle(
                    ctx,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  tip.text,
                  style: t.textTheme.bodyMedium?.copyWith(
                    height: 1.45,
                    color: TuinierColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final month = DateTime.now().month;
    final health = computeGardenHealthScore(
      gardenStore: widget.gardenStore,
      profileStore: widget.profileStore,
      repository: widget.repository,
      insectStore: widget.insectScanStore,
    );
    final actions = collectAllGardenHomeActions(
      vegetableIds: widget.gardenStore.ids,
      vegetableById: widget.repository.byId,
      profileFor: widget.profileStore.profileFor,
      scanPrefs: widget.scanPrefs,
      month: month,
    );
    final tip = gardenTipOfTheDay();

    final upcomingPlant = collectUpcomingPlantItems(
      vegetables: widget.repository.all,
      inGarden: widget.gardenStore.contains,
      profileFor: widget.profileStore.profileFor,
    );
    final upcomingHarvest = collectUpcomingHarvestItems(
      vegetables: widget.repository.all,
      inGarden: widget.gardenStore.contains,
      profileFor: widget.profileStore.profileFor,
    );
    final weatherAlerts = urgentWeatherTipsForActions(_forecast);
    final taskItems = actions;

    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        centerTitle: true,
        leading: IconButton(
          tooltip: 'Menu',
          icon: const Icon(Icons.menu),
          onPressed: _openSettings,
        ),
        title: TuinSpaceSwitcher(
          gardenStore: widget.gardenStore,
        ),
        actions: [
          IconButton(
            tooltip: 'Weetje van de dag',
            onPressed: () => _showDailyTip(tip),
            icon: const Icon(Icons.auto_awesome_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadWeather,
        color: TuinierColors.primary,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 96),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                      Text(
                        '$_greeting!',
                        style: tuinDisplayStyle(
                          context,
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: TuinierColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        widget.gardenStore.isEmpty
                            ? 'Voeg je eerste plant toe in Moestuin.'
                            : health.total >= 75
                                ? 'Je tuin doet het goed vandaag.'
                                : 'Er is vandaag wat aandacht nodig.',
                        style: t.textTheme.bodySmall?.copyWith(
                          color: TuinierColors.textSecondary,
                          height: 1.25,
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                HomeWeatherBadge(
                  loading: _weatherLoading,
                  forecast: _forecast,
                  onTap: _openWeather,
                ),
              ],
            ),
            const SizedBox(height: 10),
            _HealthHeroCard(
              score: health.total,
              label: gardenHealthShortLabel(health),
              isEmpty: health.plantCount == 0,
              onTap: widget.onGoToMoestuin,
            ),
            const SizedBox(height: 24),
            _ActiesSection(
              plantTasks: taskItems,
              weatherAlerts: weatherAlerts,
              profileStore: widget.profileStore,
              onTaskTap: _onTaskTap,
              onWeatherTap: _openWeather,
              onEmptyTap: widget.onGoToMoestuin,
            ),
            const SizedBox(height: 20),
            _BinnenkortSection(
              plantItems: upcomingPlant,
              harvestItems: upcomingHarvest,
              onOpenDetail: _openDetail,
              onAddToGarden: _addToGarden,
            ),
          ],
        ),
      ),
    );
  }
}

// Sectiekaart: grijs buiten, wit binnen

class _HomeSectionCard extends StatelessWidget {
  const _HomeSectionCard({
    required this.title,
    required this.trailing,
    required this.child,
    this.headerAction,
  });

  final String title;
  final String trailing;
  final Widget child;
  final Widget? headerAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: TuinierDecorations.sectionCard(radius: 20),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  title,
                  style: tuinDisplayStyle(
                    context,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: TuinierColors.textPrimary,
                  ),
                ),
                const Spacer(),
                if (headerAction != null) ...[
                  headerAction!,
                  const SizedBox(width: 4),
                ],
                Text(
                  trailing,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TuinierColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            decoration: TuinierDecorations.innerListCard(),
            clipBehavior: Clip.antiAlias,
            child: child,
          ),
        ],
      ),
    );
  }
}

/// Taken & plantinfo op home, scrollbaar (ca. 3 rijen zichtbaar).
class _ActiesSection extends StatefulWidget {
  const _ActiesSection({
    super.key,
    required this.plantTasks,
    required this.weatherAlerts,
    required this.profileStore,
    required this.onTaskTap,
    required this.onWeatherTap,
    this.onEmptyTap,
  });

  final List<GardenHomeAction> plantTasks;
  final List<GardenWeatherTip> weatherAlerts;
  final GardenProfileStore profileStore;
  final ValueChanged<GardenHomeAction> onTaskTap;
  final VoidCallback onWeatherTap;
  final VoidCallback? onEmptyTap;

  @override
  State<_ActiesSection> createState() => _ActiesSectionState();
}

class _ActiesSectionState extends State<_ActiesSection> {
  GardenHomeActionListFilter _filter = GardenHomeActionListFilter.all;

  static const _visibleRows = 3;
  static const _maxListHeight = 300.0;

  List<GardenHomeAction> get _filteredPlantItems =>
      filterGardenHomeActions(widget.plantTasks, _filter);

  int get _taskCount =>
      widget.plantTasks.where((item) => item.isPlantTask).length;

  int get _infoCount =>
      widget.plantTasks.where((item) => item.isPlantInfo).length;

  int get _visiblePlantCount => _filteredPlantItems.length;

  int get _totalCount => _visiblePlantCount + widget.weatherAlerts.length;

  String get _trailingLabel {
    if (widget.plantTasks.isEmpty && widget.weatherAlerts.isEmpty) {
      return 'Geen items';
    }
    final parts = <String>[];
    if (_taskCount > 0) {
      parts.add('$_taskCount ${_taskCount == 1 ? 'taak' : 'taken'}');
    }
    if (_infoCount > 0) {
      parts.add('$_infoCount info');
    }
    if (widget.weatherAlerts.isNotEmpty) {
      parts.add('${widget.weatherAlerts.length} weer');
    }
    return parts.join(' · ');
  }

  @override
  Widget build(BuildContext context) {
    final Widget listContent;
    if (_totalCount == 0) {
      listContent = _SectionEmptyText(
        text: _filter == GardenHomeActionListFilter.all
            ? 'Geen taken of info voor vandaag. Lekker bezig!'
            : _filter == GardenHomeActionListFilter.tasks
                ? 'Geen taken voor dit filter.'
                : 'Geen plantinfo voor dit filter.',
        onTap: widget.onEmptyTap,
      );
    } else if (_totalCount > _visibleRows) {
      listContent = _ScrollableHomeList(
        itemCount: _totalCount,
        maxHeight: _maxListHeight,
        visibleRows: _visibleRows,
        itemBuilder: (context, i) => _buildRow(i),
      );
    } else {
      listContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < _totalCount; i++) ...[
            if (i > 0) const _ListDivider(),
            _buildRow(i),
          ],
        ],
      );
    }

    return _HomeSectionCard(
      title: 'Taken & plant info',
      trailing: _trailingLabel,
      headerAction: _ActionFilterButton(
        filter: _filter,
        onChanged: (value) => setState(() => _filter = value),
      ),
      child: listContent,
    );
  }

  Widget _buildRow(int index) {
    if (index < widget.weatherAlerts.length) {
      final tip = widget.weatherAlerts[index];
      return _WeatherActionRow(
        tip: tip,
        onTap: widget.onWeatherTap,
      );
    }
    final action = _filteredPlantItems[index - widget.weatherAlerts.length];
    return _TaskRow(
      action: action,
      profile: widget.profileStore.profileFor(action.vegetable.id),
      onTap: () => widget.onTaskTap(action),
    );
  }
}

class _ActionFilterButton extends StatelessWidget {
  const _ActionFilterButton({
    required this.filter,
    required this.onChanged,
  });

  final GardenHomeActionListFilter filter;
  final ValueChanged<GardenHomeActionListFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<GardenHomeActionListFilter>(
      tooltip: 'Filter taken en info',
      initialValue: filter,
      onSelected: onChanged,
      icon: Icon(
        Icons.filter_list_rounded,
        size: 20,
        color: filter == GardenHomeActionListFilter.all
            ? TuinierColors.iconMuted
            : TuinierColors.primary,
      ),
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: GardenHomeActionListFilter.all,
          child: Text('Alles'),
        ),
        PopupMenuItem(
          value: GardenHomeActionListFilter.tasks,
          child: Text('Taken'),
        ),
        PopupMenuItem(
          value: GardenHomeActionListFilter.info,
          child: Text('Info'),
        ),
      ],
    );
  }
}

class _ScrollableHomeList extends StatefulWidget {
  const _ScrollableHomeList({
    required this.itemCount,
    required this.itemBuilder,
    required this.maxHeight,
    required this.visibleRows,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final double maxHeight;
  final int visibleRows;

  @override
  State<_ScrollableHomeList> createState() => _ScrollableHomeListState();
}

class _ScrollableHomeListState extends State<_ScrollableHomeList> {
  final _scrollController = ScrollController();
  double _thumbTop = 0;
  double _thumbHeight = 40;

  static const _trackWidth = 4.0;
  static const _trackPaddingV = 10.0;
  static const _trackPaddingH = 8.0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_syncThumb);
    WidgetsBinding.instance.addPostFrameCallback((_) => _syncThumb());
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  double get _trackHeight => widget.maxHeight - _trackPaddingV * 2;

  void _syncThumb() {
    if (!_scrollController.hasClients) return;
    final pos = _scrollController.position;
    final ratio = widget.visibleRows / widget.itemCount;
    final thumbH = (_trackHeight * ratio).clamp(28.0, _trackHeight);
    final travel = _trackHeight - thumbH;
    final top = pos.maxScrollExtent <= 0
        ? 0.0
        : (pos.pixels / pos.maxScrollExtent) * travel;
    setState(() {
      _thumbHeight = thumbH;
      _thumbTop = top;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.maxHeight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              physics: const BouncingScrollPhysics(),
              primary: false,
              itemCount: widget.itemCount,
              separatorBuilder: (_, __) => const _ListDivider(),
              itemBuilder: widget.itemBuilder,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              4,
              _trackPaddingV,
              _trackPaddingH,
              _trackPaddingV,
            ),
            child: SizedBox(
              width: _trackWidth,
              height: _trackHeight,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0xFFE5E7EB),
                      borderRadius: BorderRadius.circular(2),
                    ),
                    child: const SizedBox.expand(),
                  ),
                  Positioned(
                    top: _thumbTop,
                    left: 0,
                    right: 0,
                    height: _thumbHeight,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: TuinierColors.primary.withValues(alpha: 0.55),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Binnenkort, tabs Planten / Oogsten, scrollbare volledige lijst.
class _BinnenkortSection extends StatefulWidget {
  const _BinnenkortSection({
    required this.plantItems,
    required this.harvestItems,
    required this.onOpenDetail,
    required this.onAddToGarden,
  });

  final List<HomeUpcomingItem> plantItems;
  final List<HomeUpcomingItem> harvestItems;
  final void Function(Vegetable veg, {bool scanHistory}) onOpenDetail;
  final Future<void> Function(Vegetable veg) onAddToGarden;

  static const _visibleRows = 3;
  static const _maxListHeight = 300.0;

  @override
  State<_BinnenkortSection> createState() => _BinnenkortSectionState();
}

class _BinnenkortSectionState extends State<_BinnenkortSection> {
  int _tab = 0;

  List<HomeUpcomingItem> get _items =>
      _tab == 0 ? widget.plantItems : widget.harvestItems;

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final total = widget.plantItems.length + widget.harvestItems.length;

    final Widget listContent;
    if (items.isEmpty) {
      listContent = _SectionEmptyText(
        text: _tab == 0
            ? 'Geen zaai- of plantperiode binnenkort.'
            : 'Geen oogstperiode binnenkort.',
      );
    } else if (items.length > _BinnenkortSection._visibleRows) {
      listContent = _ScrollableHomeList(
        itemCount: items.length,
        maxHeight: _BinnenkortSection._maxListHeight,
        visibleRows: _BinnenkortSection._visibleRows,
        itemBuilder: (context, i) => _UpcomingRow(
          item: items[i],
          onTap: () => widget.onOpenDetail(items[i].vegetable),
          onAdd: items[i].inGarden
              ? null
              : () => widget.onAddToGarden(items[i].vegetable),
        ),
      );
    } else {
      listContent = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < items.length; i++) ...[
            if (i > 0) const _ListDivider(),
            _UpcomingRow(
              item: items[i],
              onTap: () => widget.onOpenDetail(items[i].vegetable),
              onAdd: items[i].inGarden
                  ? null
                  : () => widget.onAddToGarden(items[i].vegetable),
            ),
          ],
        ],
      );
    }

    return Container(
      decoration: TuinierDecorations.sectionCard(radius: 20),
      padding: const EdgeInsets.fromLTRB(12, 14, 12, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Text(
                  'Binnenkort',
                  style: tuinDisplayStyle(
                    context,
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                    color: TuinierColors.textPrimary,
                  ),
                ),
                const Spacer(),
                Text(
                  total == 0
                      ? 'Geen gewassen'
                      : '$total ${total == 1 ? 'gewas' : 'gewassen'}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: TuinierColors.textSecondary,
                        fontWeight: FontWeight.w400,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _BinnenkortTabChip(
                label: 'Planten',
                count: widget.plantItems.length,
                selected: _tab == 0,
                onTap: () => setState(() => _tab = 0),
              ),
              const SizedBox(width: 8),
              _BinnenkortTabChip(
                label: 'Oogsten',
                count: widget.harvestItems.length,
                selected: _tab == 1,
                onTap: () => setState(() => _tab = 1),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: TuinierDecorations.innerListCard(),
            clipBehavior: Clip.antiAlias,
            child: listContent,
          ),
        ],
      ),
    );
  }
}

class _BinnenkortTabChip extends StatelessWidget {
  const _BinnenkortTabChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TuinierColors.primary : TuinierColors.card,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected ? TuinierColors.primary : TuinierColors.border,
            ),
          ),
          child: Text(
            '$label ($count)',
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
                  color: selected ? TuinierColors.card : TuinierColors.textPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
          ),
        ),
      ),
    );
  }
}

class _UpcomingRow extends StatelessWidget {
  const _UpcomingRow({
    required this.item,
    required this.onTap,
    this.onAdd,
  });

  final HomeUpcomingItem item;
  final VoidCallback onTap;
  final VoidCallback? onAdd;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            VegetableThumbnail(
              vegetable: item.vegetable,
              size: 76,
              borderRadius: 16,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.vegetable.nameNl,
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      color: TuinierColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.label,
                    style: t.textTheme.bodySmall?.copyWith(
                      color: TuinierColors.textSecondary,
                      fontWeight: FontWeight.w400,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            if (onAdd != null)
              IconButton(
                tooltip: 'Toevoegen aan moestuin',
                icon: const Icon(Icons.add_circle_outline),
                color: TuinierColors.primary,
                onPressed: onAdd,
              )
            else
              Icon(
                Icons.chevron_right,
                color: TuinierColors.iconMuted,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _SectionEmptyText extends StatelessWidget {
  const _SectionEmptyText({required this.text, this.onTap});

  final String text;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Text(
          text,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: TuinierColors.textSecondary,
              ),
        ),
      ),
    );
  }
}

class _ListDivider extends StatelessWidget {
  const _ListDivider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: const Color(0xFFEBEBEB),
      indent: 14,
      endIndent: 14,
    );
  }
}

// Tuingezondheid (groene kaart)

class _HealthHeroCard extends StatelessWidget {
  const _HealthHeroCard({
    required this.score,
    required this.label,
    this.isEmpty = false,
    this.onTap,
  });

  final int score;
  final String label;
  final bool isEmpty;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: HomeGreenPattern(
          borderRadius: 24,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 14, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.eco_outlined,
                            size: 15,
                            color: TuinierColors.card.withValues(alpha: 0.92),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Tuingezondheid',
                            style: tuinDisplayStyle(
                              context,
                              fontSize: 13,
                              fontWeight: FontWeight.w400,
                              color: TuinierColors.card.withValues(alpha: 0.92),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            isEmpty ? '—' : '$score/100',
                            style: tuinScoreStyle(
                              context,
                              fontSize: 34,
                              color: TuinierColors.card,
                            )?.copyWith(fontWeight: FontWeight.w600),
                          ),
                          if (!isEmpty) ...[
                            const SizedBox(width: 8),
                            Text(
                              '$label >',
                              style: tuinDisplayStyle(
                                context,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                color: TuinierColors.card,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Voeg planten toe',
                          style: tuinDisplayStyle(
                            context,
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                            color: TuinierColors.card.withValues(alpha: 0.88),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                SizedBox(
                  width: 76,
                  height: 76,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 76,
                        height: 76,
                        child: CircularProgressIndicator(
                          value: isEmpty ? 0 : score / 100,
                          strokeWidth: 4,
                          strokeCap: StrokeCap.round,
                          backgroundColor:
                              const Color(0xFF1B5E20).withValues(alpha: 0.7),
                          color: isEmpty
                              ? TuinierColors.lightGreen.withValues(alpha: 0.35)
                              : TuinierColors.lightGreen,
                        ),
                      ),
                      Positioned.fill(
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: GardenHealthPlantIcon(
                            score: isEmpty ? 0 : score,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Weer: zie HomeWeatherBadge

// Taken

class _WeatherActionRow extends StatelessWidget {
  const _WeatherActionRow({
    required this.tip,
    required this.onTap,
  });

  final GardenWeatherTip tip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: TuinierColors.error,
                shape: BoxShape.circle,
              ),
              child: Icon(tip.icon, size: 22, color: TuinierColors.card),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Weer · ${tip.title}',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w400,
                      fontSize: 15,
                      height: 1.35,
                      color: TuinierColors.textPrimary,
                    ),
              ),
            ),
            const SizedBox(width: 10),
            Icon(
              Icons.chevron_right,
              color: TuinierColors.iconMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskRow extends StatelessWidget {
  const _TaskRow({
    required this.action,
    required this.profile,
    required this.onTap,
  });

  final GardenHomeAction action;
  final GardenPlantProfile? profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
        child: Row(
          children: [
            Expanded(
              child: GardenHomeActionListTile(
                action: action,
                profile: profile,
                onTap: onTap,
                showChevron: false,
                compact: true,
                interactive: false,
              ),
            ),
            VegetableThumbnail(
              vegetable: action.vegetable,
              size: 72,
              borderRadius: 14,
            ),
            const SizedBox(width: 10),
            const Icon(
              Icons.chevron_right,
              color: TuinierColors.iconMuted,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
