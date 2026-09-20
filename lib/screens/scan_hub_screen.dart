import 'package:flutter/material.dart';

import '../data/ai_settings_store.dart';
import '../data/garden_notes_store.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/insect_scan_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_search_filters.dart';
import '../data/weed_scan_store.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import '../widgets/scan_hero_background.dart';
import '../widgets/scan_hub_assets.dart';
import '../widgets/scan_mode_selector.dart';
import '../widgets/vegetable_thumbnail.dart';
import 'plant_scan_screen.dart';
import 'scan_hub_types.dart';

/// Scan-hub volgens mockup; opent bestaande scan-flows.
class ScanHubScreen extends StatefulWidget {
  const ScanHubScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
    required this.aiSettings,
    required this.scanPrefs,
    required this.notesStore,
    this.insectScanStore,
    this.weedScanStore,
    this.initialVegetableId,
    this.initialHarvestProbe = false,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final AiSettingsStore aiSettings;
  final GardenScanPrefsStore scanPrefs;
  final GardenNotesStore notesStore;
  final InsectScanStore? insectScanStore;
  final WeedScanStore? weedScanStore;
  final String? initialVegetableId;
  final bool initialHarvestProbe;

  @override
  State<ScanHubScreen> createState() => _ScanHubScreenState();
}

class _ScanHubScreenState extends State<ScanHubScreen> {
  bool _showScan = false;
  ScanHubEntry? _entry;
  ScanSubjectMode? _initialScanMode;
  PlantBrowseKind? _plantBrowseFilter;
  String? _activeVegetableId;

  @override
  void initState() {
    super.initState();
    if (widget.initialVegetableId != null || widget.initialHarvestProbe) {
      _showScan = true;
      _entry = ScanHubEntry.plant;
      _initialScanMode = ScanSubjectMode.plant;
    }
  }

  @override
  void didUpdateWidget(ScanHubScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialVegetableId != oldWidget.initialVegetableId ||
        widget.initialHarvestProbe != oldWidget.initialHarvestProbe) {
      if (widget.initialVegetableId != null || widget.initialHarvestProbe) {
        setState(() {
          _showScan = true;
          _entry = ScanHubEntry.plant;
          _initialScanMode = ScanSubjectMode.plant;
        });
      }
    }
  }

  void _openEntry(ScanHubEntry entry) {
    setState(() {
      _showScan = true;
      _entry = entry;
      _initialScanMode = switch (entry) {
        ScanHubEntry.insect => ScanSubjectMode.insect,
        ScanHubEntry.weed => ScanSubjectMode.weed,
        ScanHubEntry.plant || ScanHubEntry.plantDisease => ScanSubjectMode.plant,
      };
      _plantBrowseFilter = null;
    });
  }

  void _backToHub() {
    setState(() {
      _showScan = false;
      _entry = null;
      _initialScanMode = null;
      _plantBrowseFilter = null;
      _activeVegetableId = null;
    });
  }

  List<_RecentScanRow> _recentScans() {
    final rows = <_RecentScanRow>[];
    for (final id in widget.gardenStore.ids) {
      final veg = widget.repository.byId(id);
      final profile = widget.profileStore.profileFor(id);
      final analysis = profile?.lastAnalysis;
      if (veg == null || analysis == null) continue;
      rows.add(
        _RecentScanRow(
          vegetable: veg,
          profile: profile!,
          analysis: analysis,
        ),
      );
    }
    rows.sort((a, b) => b.analysis.scannedAt.compareTo(a.analysis.scannedAt));
    return rows;
  }

  void _openRecentScan(_RecentScanRow row) {
    setState(() {
      _showScan = true;
      _entry = ScanHubEntry.plant;
      _activeVegetableId = row.vegetable.id;
      _initialScanMode = ScanSubjectMode.plant;
      _plantBrowseFilter = null;
    });
  }

  void _openAllScans(List<_RecentScanRow> all) {
    if (all.isEmpty) return;
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (ctx) => Scaffold(
          backgroundColor: TuinierColors.background,
          appBar: AppBar(
            centerTitle: true,
            title: const Text('Laatste scans'),
          ),
          body: ListView.separated(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            itemCount: all.length,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (_, i) => _RecentScanTile(
              row: all[i],
              onTap: () {
                Navigator.pop(ctx);
                _openRecentScan(all[i]);
              },
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_showScan) {
      return PlantScanScreen(
        key: ValueKey(
          'scan_${widget.initialVegetableId ?? 'hub'}_'
          '${widget.initialHarvestProbe}_$_entry',
        ),
        repository: widget.repository,
        gardenStore: widget.gardenStore,
        profileStore: widget.profileStore,
        aiSettings: widget.aiSettings,
        scanPrefs: widget.scanPrefs,
        notesStore: widget.notesStore,
        insectScanStore: widget.insectScanStore,
        weedScanStore: widget.weedScanStore,
        initialVegetableId:
            widget.initialVegetableId ?? _activeVegetableId,
        initialHarvestProbe: widget.initialHarvestProbe,
        initialScanMode: _initialScanMode,
        initialHubEntry: _entry,
        plantBrowseFilter: _plantBrowseFilter,
        showHubBack: _entry != null &&
            widget.initialVegetableId == null &&
            !widget.initialHarvestProbe,
        onBackToHub: _backToHub,
      );
    }

    final t = Theme.of(context);
    final cs = t.colorScheme;
    final allRecent = _recentScans();
    final recentPreview = allRecent.take(3).toList();

    return Scaffold(
      backgroundColor: TuinierColors.background,
      appBar: AppBar(
        centerTitle: true,
        title: const Text('AI Scan'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: TuinierColors.border, height: 1),
        ),
        actions: [
          IconButton(
            tooltip: 'Info',
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              showAboutDialog(
                context: context,
                applicationName: 'AI Scan',
                children: const [
                  Text(
                    'Maak een foto en krijg direct AI-advies over je '
                    'planten, onkruid, insecten of plantziektes.',
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 96),
        children: [
          _ScanHeroCard(onOpenEntry: _openEntry),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Laatste scans',
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (allRecent.isNotEmpty)
                TextButton(
                  onPressed: () => _openAllScans(allRecent),
                  style: TextButton.styleFrom(
                    foregroundColor: TuinierColors.primary,
                    padding: EdgeInsets.zero,
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    'Bekijk alles',
                    style: t.textTheme.labelLarge?.copyWith(
                      color: TuinierColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (recentPreview.isEmpty)
            Text(
              'Nog geen scans. Start met Plant of Onkruid.',
              style: t.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            )
          else
            ...recentPreview.map(
              (row) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _RecentScanTile(
                  row: row,
                  onTap: () => _openRecentScan(row),
                ),
              ),
            ),
        ],
      ),
    );
  }

  static String formatWhen(DateTime dt) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(dt.year, dt.month, dt.day);
    final time =
        '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    if (day == today) return 'Vandaag • $time';
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Gisteren • $time';
    }
    return '${dt.day}-${dt.month} • $time';
  }

  static ({String label, Color bg, Color fg}) statusStyle(
    PlantAiAnalysis analysis,
  ) {
    final nutrients = analysis.insight?.confirmedNutrients ?? const [];
    if (nutrients.isNotEmpty) {
      return (
        label: 'Tekort',
        bg: const Color(0xFFFEF3C7),
        fg: const Color(0xFFB45309),
      );
    }
    if (analysis.warnings.isNotEmpty) {
      return (
        label: 'Let op',
        bg: const Color(0xFFFFEDD5),
        fg: const Color(0xFFEA580C),
      );
    }
    return (
      label: 'Gezond',
      bg: const Color(0xFFDCFCE7),
      fg: const Color(0xFF15803D),
    );
  }
}

class _ScanHeroCard extends StatelessWidget {
  const _ScanHeroCard({required this.onOpenEntry});

  final ValueChanged<ScanHubEntry> onOpenEntry;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: Stack(
        clipBehavior: Clip.hardEdge,
        children: [
          const Positioned.fill(child: ScanHeroBackground()),
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.2),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 22),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                  Text(
                    'Wat wil je\nscannen?',
                    textAlign: TextAlign.center,
                    style: t.textTheme.headlineSmall?.copyWith(
                      color: TuinierColors.white,
                      fontWeight: FontWeight.w800,
                      height: 1.2,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Maak een foto en krijg direct\nAI advies.',
                    textAlign: TextAlign.center,
                    style: t.textTheme.bodyLarge?.copyWith(
                      color: TuinierColors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 22),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.08,
                    children: [
                      _ScanCategoryTile(
                        kind: ScanHubIconKind.plant,
                        label: 'Plant',
                        onTap: () => onOpenEntry(ScanHubEntry.plant),
                      ),
                      _ScanCategoryTile(
                        kind: ScanHubIconKind.weed,
                        label: 'Onkruid',
                        onTap: () => onOpenEntry(ScanHubEntry.weed),
                      ),
                      _ScanCategoryTile(
                        kind: ScanHubIconKind.insect,
                        label: 'Insect',
                        onTap: () => onOpenEntry(ScanHubEntry.insect),
                      ),
                      _ScanCategoryTile(
                        kind: ScanHubIconKind.disease,
                        label: 'Plant ziekte',
                        onTap: () => onOpenEntry(ScanHubEntry.plantDisease),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _ScanCategoryTile extends StatelessWidget {
  const _ScanCategoryTile({
    required this.kind,
    required this.label,
    required this.onTap,
  });

  final ScanHubIconKind kind;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Material(
      color: TuinierColors.white,
      borderRadius: BorderRadius.circular(18),
      elevation: 0,
      shadowColor: Colors.black.withValues(alpha: 0.15),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: TuinierColors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.14),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ScanHubCategoryIcon(kind: kind, size: 40, flat: true),
                const SizedBox(height: 10),
                Text(
                  label,
                  style: t.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: TuinierColors.primary,
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

class _RecentScanTile extends StatelessWidget {
  const _RecentScanTile({
    required this.row,
    required this.onTap,
  });

  final _RecentScanRow row;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final status = _ScanHubScreenState.statusStyle(row.analysis);

    return Material(
      color: TuinierColors.card,
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Ink(
          decoration: TuinierDecorations.card(radius: 16, shadow: false),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: VegetableThumbnail(
                    vegetable: row.vegetable,
                    size: 52,
                    borderRadius: 0,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        row.vegetable.nameNl,
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _ScanHubScreenState.formatWhen(row.analysis.scannedAt),
                        style: t.textTheme.bodySmall?.copyWith(
                          color: TuinierColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: status.bg,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: t.textTheme.labelSmall?.copyWith(
                      color: status.fg,
                      fontWeight: FontWeight.w700,
                    ),
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

class _RecentScanRow {
  const _RecentScanRow({
    required this.vegetable,
    required this.profile,
    required this.analysis,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final PlantAiAnalysis analysis;
}
