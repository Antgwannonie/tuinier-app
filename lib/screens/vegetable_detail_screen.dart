import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/harvest_self_check.dart';
import '../data/my_garden_store.dart';
import '../data/plant_encyclopedia_layout.dart';
import '../data/plant_scan_history.dart';
import '../data/planting_season_status.dart';
import '../data/planting_timing_advice.dart';
import '../data/garden_plant_schedule.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../widgets/remove_from_garden.dart';
import '../widgets/home_moestuin_actions.dart';
import '../widgets/planting_timing_success_card.dart';
import '../widgets/plant_encyclopedia/plant_info_tab.dart';
import '../widgets/plant_encyclopedia/plant_overview_tab.dart';
import '../widgets/plant_encyclopedia/plant_detail_widgets.dart';
import '../widgets/moestuin_harvest_sheet.dart';
import '../widgets/plant_scan_timeline.dart';
import '../widgets/vegetable_hero_image.dart';
import '../utils/plant_display_info.dart';
import '../theme/tuinier_colors.dart';

enum VegetableDetailSection {
  info,
  scanHistory,
}

enum VegetableDetailPresentation {
  encyclopedia,
  combined,
}

class VegetableDetailScreen extends StatefulWidget {
  const VegetableDetailScreen({
    super.key,
    required this.vegetable,
    this.focusMonth,
    this.gardenStore,
    this.repository,
    this.profileStore,
    this.scanPrefs,
    this.onGoToPlantScan,
    this.initialSection = VegetableDetailSection.info,
    this.presentation = VegetableDetailPresentation.encyclopedia,
  });

  final Vegetable vegetable;
  final int? focusMonth;
  final MyGardenStore? gardenStore;
  final VegetableRepository? repository;
  final GardenProfileStore? profileStore;
  final GardenScanPrefsStore? scanPrefs;
  final VoidCallback? onGoToPlantScan;
  final VegetableDetailSection initialSection;
  final VegetableDetailPresentation presentation;

  @override
  State<VegetableDetailScreen> createState() => _VegetableDetailScreenState();
}

class _VegetableDetailScreenState extends State<VegetableDetailScreen> {
  late PlantEncyclopediaLayout _layout;

  @override
  void initState() {
    super.initState();
    _layout = _buildLayout();
    widget.profileStore?.addListener(_onStoresChanged);
    widget.gardenStore?.addListener(_onStoresChanged);
  }

  @override
  void didUpdateWidget(covariant VegetableDetailScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.vegetable.id != widget.vegetable.id) {
      _layout = _buildLayout();
    }
  }

  PlantEncyclopediaLayout _buildLayout() => buildPlantEncyclopediaLayout(
        vegetable: widget.vegetable,
        seasonAdvice: plantingSeasonAdviceFor(widget.vegetable),
      );

  @override
  void dispose() {
    widget.profileStore?.removeListener(_onStoresChanged);
    widget.gardenStore?.removeListener(_onStoresChanged);
    super.dispose();
  }

  void _onStoresChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profileStore?.profileFor(widget.vegetable.id);
    return _buildScaffold(profile);
  }

  Widget _buildScaffold(GardenPlantProfile? profile) {
    final isFavorite =
        widget.gardenStore?.contains(widget.vegetable.id) ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Scaffold(
        backgroundColor: const Color(PlantDetailDesign.card),
        body: SafeArea(
          top: false,
          bottom: false,
          child: _PlantDetailTabSection(
          layout: _layout,
          vegetable: widget.vegetable,
          profile: profile,
          profileStore: widget.profileStore,
          gardenStore: widget.gardenStore,
          repository: widget.repository,
          scanPrefs: widget.scanPrefs,
          encyclopediaOnly: widget.presentation ==
              VegetableDetailPresentation.encyclopedia,
          initialSection: widget.initialSection,
          onGoToPlantScan: widget.onGoToPlantScan,
          isFavorite: isFavorite,
          onBack: () => Navigator.of(context).pop(),
          onFavorite: widget.gardenStore != null
              ? () async {
                  if (isFavorite) return;
                  await widget.gardenStore!.add(widget.vegetable.id);
                  await widget.profileStore?.ensureProfile(widget.vegetable.id);
                  if (mounted) setState(() {});
                }
              : null,
        ),
      ),
    ),
    );
  }
}

class _PlantDetailTabSection extends StatefulWidget {
  const _PlantDetailTabSection({
    required this.layout,
    required this.vegetable,
    required this.profile,
    required this.profileStore,
    required this.gardenStore,
    required this.repository,
    required this.scanPrefs,
    required this.encyclopediaOnly,
    required this.initialSection,
    required this.isFavorite,
    required this.onBack,
    this.onGoToPlantScan,
    this.onFavorite,
  });

  final PlantEncyclopediaLayout layout;
  final Vegetable vegetable;
  final GardenPlantProfile? profile;
  final GardenProfileStore? profileStore;
  final MyGardenStore? gardenStore;
  final VegetableRepository? repository;
  final GardenScanPrefsStore? scanPrefs;
  final bool encyclopediaOnly;
  final VegetableDetailSection initialSection;
  final bool isFavorite;
  final VoidCallback onBack;
  final VoidCallback? onGoToPlantScan;
  final VoidCallback? onFavorite;

  @override
  State<_PlantDetailTabSection> createState() => _PlantDetailTabSectionState();
}

class _PlantDetailTabSectionState extends State<_PlantDetailTabSection> {
  late final PageController _pageController;
  late int _pageIndex;

  bool get _showScanTab =>
      !widget.encyclopediaOnly &&
      widget.gardenStore != null &&
      widget.gardenStore!.contains(widget.vegetable.id) &&
      widget.profileStore != null &&
      widget.profile != null;

  int get _pageCount => _showScanTab ? 3 : 2;

  @override
  void initState() {
    super.initState();
    final wantScan = widget.initialSection ==
            VegetableDetailSection.scanHistory &&
        _showScanTab;
    _pageIndex = wantScan ? 2.clamp(0, _pageCount - 1) : 0;
    _pageController = PageController(initialPage: _pageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _goToPage(int index) {
    if (index == _pageIndex) return;
    setState(() => _pageIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.profile;
    final store = widget.profileStore;
    final inGarden = widget.gardenStore != null &&
        widget.gardenStore!.contains(widget.vegetable.id) &&
        store != null;
    final canRemove = !widget.encyclopediaOnly &&
        inGarden &&
        widget.repository != null &&
        widget.scanPrefs != null;
    final showHarvestButton = !widget.encyclopediaOnly &&
        inGarden &&
        profile != null &&
        (isHomeHarvestActionDue(profile, vegetable: widget.vegetable) ||
            isReadyToHarvest(profile, vegetable: widget.vegetable));

    final pages = <Widget>[
      PlantOverviewTab(
        layout: widget.layout,
        vegetable: widget.vegetable,
        useNestedScroll: true,
      ),
      PlantInfoTab(
        layout: widget.layout,
        vegetable: widget.vegetable,
        useNestedScroll: true,
      ),
      if (_showScanTab && profile != null && store != null)
        _ScanHistoryTab(
          profile: profile,
          profileStore: store,
          onGoToPlantScan: widget.onGoToPlantScan,
          useNestedScroll: true,
        ),
    ];

    final top = MediaQuery.paddingOf(context).top;
    final heroH = PlantDetailDesign.detailHeroHeight(MediaQuery.sizeOf(context));

    return Stack(
      children: [
        NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            final slivers = <Widget>[
              SliverOverlapAbsorber(
                handle:
                    NestedScrollView.sliverOverlapAbsorberHandleFor(context),
                sliver: SliverPersistentHeader(
                  pinned: true,
                  delegate: _PlantDetailHeaderDelegate(
                    vegetable: widget.vegetable,
                    heroHeight: heroH,
                    pageIndex: _pageIndex,
                    showScanTab: _showScanTab,
                    onSelect: _goToPage,
                    topInset: top,
                  ),
                ),
              ),
            ];

        if (showHarvestButton && profile != null && store != null) {
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _HarvestActionButton(
                  vegetable: widget.vegetable,
                  profile: profile,
                  profileStore: store,
                ),
              ),
            ),
          );
        }

        if (!widget.encyclopediaOnly && inGarden && profile != null) {
          slivers.add(
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: _GardenActionsStrip(
                  canRemove: canRemove,
                  showMarkPlanted:
                      !profile.isPlanted && widget.scanPrefs != null,
                  onRemove: canRemove
                      ? () async {
                          final removed = await confirmAndRemoveFromGarden(
                            context,
                            vegetable: widget.vegetable,
                            gardenStore: widget.gardenStore!,
                            profileStore: store,
                            repository: widget.repository!,
                            scanPrefs: widget.scanPrefs!,
                          );
                          if (!mounted) return;
                          if (removed) Navigator.of(context).pop();
                        }
                      : null,
                  onMarkPlanted: widget.scanPrefs != null
                      ? () async {
                          await store.ensureProfile(widget.vegetable.id);
                          if (!mounted) return;
                          await markVegetableAsPlanted(
                            context: context,
                            vegetable: widget.vegetable,
                            profileStore: store,
                            scanPrefs: widget.scanPrefs!,
                          );
                        }
                      : null,
                ),
              ),
            ),
          );

          final timing = seasonDisplayFor(
            vegetable: widget.vegetable,
            profile: profile,
          );
          if (timing.hasPositive) {
            slivers.add(
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                  child: PlantingTimingSuccessCard(assessment: timing),
                ),
              ),
            );
          }
        }

        return slivers;
          },
          body: ColoredBox(
            color: Colors.white,
            child: PageView(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              children: pages,
            ),
          ),
        ),
        Positioned(
          top: top + 8,
          left: 12,
          child: _CircleIconButton(
            icon: Icons.arrow_back,
            onPressed: widget.onBack,
          ),
        ),
        Positioned(
          top: top + 8,
          right: 12,
          child: _CircleIconButton(
            icon: widget.isFavorite ? Icons.favorite : Icons.favorite_border,
            onPressed: widget.onFavorite,
            iconColor: widget.isFavorite ? const Color(0xFFE11D48) : null,
          ),
        ),
      ],
    );
  }
}

class _PlantDetailHero {
  static const headerOverlap = 8.0;
  static const topCornerRadius = 32.0;
}

/// Hero-foto + wit paneel (titel/tabs) in één laag — ronde hoeken over de foto.
class _PlantDetailHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PlantDetailHeaderDelegate({
    required this.vegetable,
    required this.heroHeight,
    required this.pageIndex,
    required this.showScanTab,
    required this.onSelect,
    required this.topInset,
  });

  static const _tabsHeight = 50.0;
  static const _titleHeight = 118.0;
  static const _titleTopPadding = 12.0;

  final Vegetable vegetable;
  final double heroHeight;
  final int pageIndex;
  final bool showScanTab;
  final ValueChanged<int> onSelect;
  final double topInset;

  double get _effectiveTabsHeight => _tabsHeight;

  @override
  double get minExtent => topInset + _effectiveTabsHeight;

  @override
  double get maxExtent =>
      heroHeight + _titleHeight + _effectiveTabsHeight;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    final t = Theme.of(context).textTheme;
    final range = (maxExtent - minExtent).clamp(1.0, double.infinity);
    final collapseT = (shrinkOffset / range).clamp(0.0, 1.0);
    final extent = (maxExtent - shrinkOffset).clamp(minExtent, maxExtent);

    final safeTop = topInset * collapseT;
    final heroH = (heroHeight * (1 - collapseT)).clamp(0.0, heroHeight);
    final titleH = (_titleHeight * (1 - collapseT)).clamp(0.0, _titleHeight);
    final overlap =
        _PlantDetailHero.headerOverlap * (1 - collapseT).clamp(0.0, 1.0);
    final cornerRadius =
        _PlantDetailHero.topCornerRadius * (1 - collapseT).clamp(0.0, 1.0);
    final latin = latinNameForVegetable(vegetable);
    final english = englishNameForVegetable(vegetable);
    final plantType = plantCategoryForVegetable(vegetable);
    final showLatin = titleH > 38 && collapseT < 0.35 && latin != null;
    final showEnglish = titleH > 54 && collapseT < 0.28 && english != null;
    final showPlantType = titleH > 72 && collapseT < 0.22;
    final heroFade = heroHeight > 0 ? (heroH / heroHeight).clamp(0.0, 1.0) : 0.0;

    final panelTop = safeTop + heroH - overlap;
    final tabsH = _effectiveTabsHeight;
    final panelHeight = titleH + tabsH + overlap;
    final panelRadius = cornerRadius > 1
        ? BorderRadius.only(
            topLeft: Radius.circular(cornerRadius),
            topRight: Radius.circular(cornerRadius),
          )
        : BorderRadius.zero;
    final heroBehindPanel = heroH + overlap + (cornerRadius > 1 ? cornerRadius : 0);

    return SizedBox(
      height: extent,
      child: Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          if (heroH > 1)
            Positioned(
              top: safeTop,
              left: -2,
              right: -2,
              height: heroBehindPanel.clamp(heroH, extent),
              child: Opacity(
                opacity: heroFade,
                child: VegetableHeroImage(
                  vegetable: vegetable,
                  expand: true,
                  useAtlasIllustration: true,
                  detailHero: true,
                  borderRadius: BorderRadius.zero,
                ),
              ),
            ),
          Positioned(
            top: panelTop.clamp(safeTop, extent),
            left: 0,
            right: 0,
            height: panelHeight.clamp(_tabsHeight, extent),
            child: ClipRRect(
              borderRadius: panelRadius,
              clipBehavior: Clip.antiAlias,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: overlapsContent
                      ? const [
                          BoxShadow(
                            color: Color(0x1A000000),
                            blurRadius: 8,
                            offset: Offset(0, -1),
                          ),
                        ]
                      : null,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                  if (titleH > 28)
                    SizedBox(
                      height: titleH,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          20,
                          _titleTopPadding,
                          20,
                          4,
                        ),
                        child: Align(
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.center,
                            child: _PlantDetailTitleBlock(
                              vegetable: vegetable,
                              showLatin: showLatin,
                              showEnglish: showEnglish,
                              showPlantType: showPlantType,
                              titleStyle: t,
                            ),
                          ),
                        ),
                      ),
                    ),
                  SizedBox(
                    height: tabsH,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: _PlantDetailTabStrip(
                        pageIndex: pageIndex,
                        showScanTab: showScanTab,
                        onSelect: onSelect,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          ),
          // Witte statusbalk-afdekking alleen tijdens inklappen; uitgeklapt
          // loopt de herofoto tot bovenaan het scherm door.
          if (safeTop > 0.5)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: safeTop,
              child: const ColoredBox(color: Colors.white),
            ),
        ],
      ),
    );
  }

  @override
  bool shouldRebuild(covariant _PlantDetailHeaderDelegate oldDelegate) {
    return oldDelegate.pageIndex != pageIndex ||
        oldDelegate.showScanTab != showScanTab ||
        oldDelegate.vegetable.id != vegetable.id ||
        oldDelegate.topInset != topInset ||
        oldDelegate.heroHeight != heroHeight;
  }
}

class _PlantDetailTabStrip extends StatelessWidget {
  const _PlantDetailTabStrip({
    required this.pageIndex,
    required this.showScanTab,
    required this.onSelect,
  });

  final int pageIndex;
  final bool showScanTab;
  final ValueChanged<int> onSelect;

  static const _tabs = [
    (
      label: 'Overzicht',
      asset: 'assets/images/overview/detail_tab_overview.png',
      icon: Icons.eco_outlined,
    ),
    (
      label: 'Plant info',
      asset: 'assets/images/overview/detail_tab_plant_info.png',
      icon: Icons.description_outlined,
    ),
    (
      label: 'Scans',
      asset: null,
      icon: Icons.photo_camera_outlined,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final count = showScanTab ? 3 : 2;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: List.generate(count, (i) {
          final active = pageIndex == i;
          final tab = _tabs[i];
          final color = active
              ? const Color(PlantDetailDesign.primaryGreen)
              : const Color(PlantDetailDesign.textSecondary);

          return Expanded(
            child: InkWell(
              onTap: () => onSelect(i),
              child: SizedBox(
                height: 50,
                child: Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                          if (tab.asset != null)
                            Image.asset(
                              tab.asset!,
                              width: 22,
                              height: 22,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                              errorBuilder: (_, __, ___) =>
                                  Icon(tab.icon, size: 18, color: color),
                            )
                          else
                            Icon(tab.icon, size: 18, color: color),
                          const SizedBox(width: 5),
                          Text(
                            tab.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight:
                                  active ? FontWeight.w700 : FontWeight.w500,
                              fontSize: active ? 14 : 12,
                              letterSpacing: 0.1,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    if (active)
                      Positioned(
                        left: 8,
                        right: 8,
                        bottom: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            color: const Color(PlantDetailDesign.primaryGreen),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

class _PlantDetailTitleBlock extends StatelessWidget {
  const _PlantDetailTitleBlock({
    required this.vegetable,
    required this.showLatin,
    required this.showEnglish,
    required this.showPlantType,
    required this.titleStyle,
  });

  final Vegetable vegetable;
  final bool showLatin;
  final bool showEnglish;
  final bool showPlantType;
  final TextTheme titleStyle;

  @override
  Widget build(BuildContext context) {
    final latin = latinNameForVegetable(vegetable);
    final english = englishNameForVegetable(vegetable);
    final plantType = plantCategoryForVegetable(vegetable);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          vegetable.nameNl,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: titleStyle.headlineSmall?.copyWith(
            fontWeight: FontWeight.w800,
            height: 1.05,
            color: const Color(PlantDetailDesign.primaryGreen),
          ),
        ),
        if (showLatin && latin != null) ...[
          const SizedBox(height: 2),
          Text(
            latin,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: titleStyle.bodySmall?.copyWith(
              fontStyle: FontStyle.italic,
              height: 1.05,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
        if (showEnglish && english != null) ...[
          const SizedBox(height: 2),
          Text(
            english,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: titleStyle.bodySmall?.copyWith(
              height: 1.05,
              color: const Color(PlantDetailDesign.textSecondary),
            ),
          ),
        ],
        if (showPlantType) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F8E9),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: const Color(PlantDetailDesign.primaryGreen)
                    .withValues(alpha: 0.2),
              ),
            ),
            child: Text(
              plantType,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: titleStyle.labelSmall?.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 10,
                height: 1.1,
                color: const Color(PlantDetailDesign.primaryGreen),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.onPressed,
    this.iconColor,
  });

  final IconData icon;
  final VoidCallback? onPressed;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 2,
      shadowColor: Colors.black26,
      color: Colors.white,
      shape: const CircleBorder(),
      child: IconButton(
        icon: Icon(
          icon,
          color: iconColor ?? const Color(PlantDetailDesign.textPrimary),
        ),
        onPressed: onPressed,
      ),
    );
  }
}

class _ScanHistoryTab extends StatelessWidget {
  const _ScanHistoryTab({
    required this.profile,
    required this.profileStore,
    this.onGoToPlantScan,
    this.useNestedScroll = false,
  });

  final GardenPlantProfile profile;
  final GardenProfileStore profileStore;
  final VoidCallback? onGoToPlantScan;
  final bool useNestedScroll;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final children = <Widget>[
      if (!profile.isPlanted)
        Text(
          'Markeer deze plant als geplant om scans op te slaan.',
          style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        )
      else if (plantScanEntries(profile).isEmpty)
        Text(
          'Nog geen scans. Maak je eerste foto via Taken of de Scan-knop.',
          style: t.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
        )
      else
        PlantScanTimeline(
          key: ValueKey('scan-history-${profile.vegetableId}'),
          profileStore: profileStore,
          profile: profile,
        ),
      if (profile.isPlanted && onGoToPlantScan != null) ...[
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: onGoToPlantScan,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(
            profile.lastAnalysis == null
                ? 'Eerste foto scannen'
                : needsWeeklyScan(profile)
                    ? 'Nieuwe scan maken'
                    : 'Foto bijwerken',
          ),
        ),
      ],
    ];

    if (useNestedScroll) {
      return CustomScrollView(
        slivers: [
          SliverOverlapInjector(
            handle: NestedScrollView.sliverOverlapAbsorberHandleFor(context),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate(children),
            ),
          ),
        ],
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: children,
    );
  }
}

class _HarvestActionButton extends StatelessWidget {
  const _HarvestActionButton({
    required this.vegetable,
    required this.profile,
    required this.profileStore,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final GardenProfileStore profileStore;

  @override
  Widget build(BuildContext context) {
    final selfCheck = isAiHarvestVisuallyUncertain(profile, vegetable);
    final label = moestuinHarvestCardButtonLabel(
      vegetable: vegetable,
      profile: profile,
      selfCheckMode: selfCheck,
    );

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () => showMoestuinHarvestSheet(
          context: context,
          vegetable: vegetable,
          profile: profile,
          profileStore: profileStore,
          selfCheckMode: selfCheck,
        ),
        icon: Icon(
          selfCheck ? Icons.grass_outlined : Icons.event_available_outlined,
          size: 18,
        ),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: TuinierColors.primary,
          side: BorderSide(color: TuinierColors.primary.withValues(alpha: 0.45)),
        ),
      ),
    );
  }
}

class _GardenActionsStrip extends StatelessWidget {
  const _GardenActionsStrip({
    required this.canRemove,
    required this.showMarkPlanted,
    this.onRemove,
    this.onMarkPlanted,
  });

  final bool canRemove;
  final bool showMarkPlanted;
  final VoidCallback? onRemove;
  final VoidCallback? onMarkPlanted;

  @override
  Widget build(BuildContext context) {
    return PlantDetailCard(
      padding: const EdgeInsets.all(12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (showMarkPlanted && onMarkPlanted != null)
            FilledButton.icon(
              onPressed: onMarkPlanted,
              icon: const Icon(Icons.yard_outlined, size: 18),
              label: const Text('Markeer als geplant'),
            ),
          if (canRemove && onRemove != null)
            OutlinedButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline, size: 18),
              label: const Text('Uit moestuin'),
            ),
        ],
      ),
    );
  }
}
