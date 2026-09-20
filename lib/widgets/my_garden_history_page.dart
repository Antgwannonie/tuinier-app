import 'package:flutter/material.dart';

import '../data/crop_harvest_kind.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_scan_history.dart';
import '../data/plant_scan_photo_store.dart';
import '../data/vegetable_image_info.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'plant_history_sheet.dart';
import 'resume_plants_from_history_sheet.dart';
import '../theme/plant_setup_palette.dart';
import 'vegetable_hero_image.dart';

class MyGardenHistoryPage extends StatefulWidget {
  const MyGardenHistoryPage({
    super.key,
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
  State<MyGardenHistoryPage> createState() => _MyGardenHistoryPageState();
}

class _MyGardenHistoryPageState extends State<MyGardenHistoryPage> {
  int? _selectedYear;
  bool _filterExpanded = false;
  String? _selectedTuinSpaceKey;

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_refresh);
    widget.profileStore.addListener(_refresh);
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await widget.profileStore.syncArchivedTuinSpaces(widget.gardenStore);
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    widget.gardenStore.removeListener(_refresh);
    widget.profileStore.removeListener(_refresh);
    super.dispose();
  }

  void _refresh() {
    if (mounted) setState(() {});
  }

  List<_HistorySeason> _seasons() {
    final byYear = <int, List<_PlantHistoryItem>>{};

    for (final profile in widget.profileStore.archivedProfiles) {
      final year = profile.archivedAt!.year;
      final veg = widget.repository.byId(profile.vegetableId);
      if (veg == null) continue;
      (byYear[year] ??= []).add(
        _PlantHistoryItem(vegetable: veg, profile: profile),
      );
    }

    final years = byYear.keys.toList()..sort();
    return years.map((year) {
      final plants = byYear[year]!
        ..sort((a, b) => a.vegetable.nameNl.compareTo(b.vegetable.nameNl));
      return _HistorySeason(year: year, plants: plants);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final seasons = _seasons();
    if (seasons.isEmpty) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
        children: [
          _emptyCard(
            context,
            icon: Icons.archive_outlined,
            title: 'Nog geen history',
            body:
                'Planten verschijnen hier als je ze volledig geoogst hebt, '
                'uit je moestuin haalt of een nieuwe moestuin start.',
          ),
        ],
      );
    }

    _selectedYear ??= seasons.last.year;
    final selectedYear = _selectedYear!;
    final season =
        seasons.where((s) => s.year == selectedYear).firstOrNull ?? seasons.last;
    final moestuinOptions = _moestuinOptionsFor(season);
    final showMoestuinFilter = moestuinOptions.isNotEmpty;
    final List<_PlantHistoryItem> filteredPlants;
    final String tuinSpaceFilter;
    final String moestuinName;

    if (showMoestuinFilter) {
      _selectedTuinSpaceKey = _resolveSelectedMoestuinKey(
        season,
        moestuinOptions,
        _selectedTuinSpaceKey,
      );
      tuinSpaceFilter = _selectedTuinSpaceKey!;
      filteredPlants = _plantsForMoestuinFilter(season, tuinSpaceFilter);
      moestuinName = moestuinOptions
          .firstWhere((o) => o.key == tuinSpaceFilter)
          .label;
    } else {
      filteredPlants = season.plants;
      tuinSpaceFilter = '';
      moestuinName = 'Moestuin';
    }

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _HistoryFilterPanel(
          seasons: seasons,
          selectedYear: selectedYear,
          moestuinOptions: showMoestuinFilter ? moestuinOptions : const [],
          selectedMoestuinKey: _selectedTuinSpaceKey,
          moestuinName: moestuinName,
          expanded: _filterExpanded,
          onToggle: () => setState(() => _filterExpanded = !_filterExpanded),
          onYearSelected: (year) => setState(() {
            _selectedYear = year;
            _selectedTuinSpaceKey = null;
            _filterExpanded = false;
          }),
          onMoestuinSelected: (key) => setState(() {
            _selectedTuinSpaceKey = key;
            _filterExpanded = false;
          }),
        ),
        const SizedBox(height: 14),
        _HistorySeasonView(
          year: season.year,
          plants: filteredPlants,
          moestuinName: moestuinName,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          gardenStore: widget.gardenStore,
          repository: widget.repository,
          onRestored: _refresh,
        ),
      ],
    );
  }

  List<_MoestuinHistoryOption> _moestuinOptionsFor(_HistorySeason season) {
    final spaces = widget.gardenStore.historyFilterSpaces;
    return spaces
        .map((space) {
          final count = season.plants
              .where(
                (item) => item.profile.archivedTuinSpaceId == space.id,
              )
              .length;
          return _MoestuinHistoryOption(
            key: space.id,
            label: space.name,
            plantCount: count,
          );
        })
        .toList();
  }

  String? _resolveSelectedMoestuinKey(
    _HistorySeason season,
    List<_MoestuinHistoryOption> options,
    String? current,
  ) {
    if (options.isEmpty) return null;
    if (current != null && options.any((o) => o.key == current)) {
      return current;
    }
    final withPlants = options.where((o) => o.plantCount > 0).toList();
    if (withPlants.isNotEmpty) return withPlants.first.key;
    return options.first.key;
  }

  List<_PlantHistoryItem> _plantsForMoestuinFilter(
    _HistorySeason season,
    String tuinSpaceKey,
  ) {
    return season.plants
        .where((item) => item.profile.archivedTuinSpaceId == tuinSpaceKey)
        .toList();
  }

  Widget _emptyCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String body,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 40, color: cs.primary),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            body,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.4,
                ),
          ),
        ],
      ),
    );
  }
}

class _MoestuinHistoryOption {
  const _MoestuinHistoryOption({
    required this.key,
    required this.label,
    required this.plantCount,
  });

  final String key;
  final String label;
  final int plantCount;

  _MoestuinHistoryOption copyWith({int? plantCount}) => _MoestuinHistoryOption(
        key: key,
        label: label,
        plantCount: plantCount ?? this.plantCount,
      );
}

/// Inklapbaar filter: jaar en moestuin als chips.
class _HistoryFilterPanel extends StatelessWidget {
  const _HistoryFilterPanel({
    required this.seasons,
    required this.selectedYear,
    required this.moestuinOptions,
    required this.selectedMoestuinKey,
    required this.moestuinName,
    required this.expanded,
    required this.onToggle,
    required this.onYearSelected,
    required this.onMoestuinSelected,
  });

  final List<_HistorySeason> seasons;
  final int selectedYear;
  final List<_MoestuinHistoryOption> moestuinOptions;
  final String? selectedMoestuinKey;
  final String moestuinName;
  final bool expanded;
  final VoidCallback onToggle;
  final ValueChanged<int> onYearSelected;
  final ValueChanged<String> onMoestuinSelected;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);
    final years = List<_HistorySeason>.from(seasons)
      ..sort((a, b) => b.year.compareTo(a.year));
    final selectedSeason = years.firstWhere((s) => s.year == selectedYear);
    final plantCount = moestuinOptions
        .where((o) => o.key == selectedMoestuinKey)
        .map((o) => o.plantCount)
        .firstOrNull;

    return Material(
      color: p.cardBackground,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.cardBorder),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: onToggle,
            child: Padding(
              padding: EdgeInsets.fromLTRB(14, 14, 12, expanded ? 10 : 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.tune_rounded, size: 20, color: p.activeIcon),
                      const SizedBox(width: 8),
                      Text(
                        'Filter',
                        style: t.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        expanded ? 'Sluiten' : 'Wijzigen',
                        style: t.textTheme.labelMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(width: 4),
                      AnimatedRotation(
                        turns: expanded ? 0.5 : 0,
                        duration: const Duration(milliseconds: 200),
                        child: Icon(
                          Icons.expand_more,
                          size: 22,
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                  if (!expanded) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _HistoryActiveFilterChip(
                          icon: Icons.calendar_month_outlined,
                          label: '$selectedYear',
                          detail: selectedSeason.plants.length == 1
                              ? '1 plant'
                              : '${selectedSeason.plants.length} planten',
                        ),
                        if (moestuinOptions.isNotEmpty)
                          _HistoryActiveFilterChip(
                            icon: Icons.yard_outlined,
                            label: moestuinName,
                            detail: plantCount == null
                                ? null
                                : plantCount == 1
                                    ? '1 plant'
                                    : '$plantCount planten',
                          ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            alignment: Alignment.topCenter,
            child: expanded
                ? Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Divider(height: 1, color: p.cardBorder),
                        const SizedBox(height: 14),
                        Text(
                          'Jaar',
                          style: t.textTheme.labelLarge?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: p.sectionLabel,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: years.map((season) {
                            final count = season.plants.length;
                            return _HistoryFilterChoiceChip(
                              label: '${season.year}',
                              count: count,
                              selected: season.year == selectedYear,
                              onTap: () => onYearSelected(season.year),
                            );
                          }).toList(),
                        ),
                        if (moestuinOptions.isNotEmpty) ...[
                          const SizedBox(height: 18),
                          Text(
                            'Moestuin',
                            style: t.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: p.sectionLabel,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: moestuinOptions.map((option) {
                              return _HistoryFilterChoiceChip(
                                label: option.label,
                                count: option.plantCount,
                                selected: option.key == selectedMoestuinKey,
                                onTap: () => onMoestuinSelected(option.key),
                              );
                            }).toList(),
                          ),
                        ],
                      ],
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}

/// Huidige keuze zichtbaar als filter dicht is.
class _HistoryActiveFilterChip extends StatelessWidget {
  const _HistoryActiveFilterChip({
    required this.icon,
    required this.label,
    this.detail,
  });

  final IconData icon;
  final String label;
  final String? detail;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final p = PlantSetupPalette.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: p.chipSelectedBackground.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: p.chipSelectedBackground.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: p.activeIcon),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: p.chipSelectedForeground,
                ),
              ),
              if (detail != null)
                Text(
                  detail!,
                  style: t.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HistoryFilterChoiceChip extends StatelessWidget {
  const _HistoryFilterChoiceChip({
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
    final t = Theme.of(context);
    final cs = Theme.of(context).colorScheme;
    final p = PlantSetupPalette.of(context);
    final countLabel = count == 1 ? '1' : '$count';

    return Material(
      color: selected ? p.chipSelectedBackground : p.chipIdleBackground,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: t.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? p.chipSelectedForeground
                      : p.chipIdleForeground,
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: selected
                      ? p.chipSelectedForeground.withValues(alpha: 0.18)
                      : cs.surface.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  countLabel,
                  style: t.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected
                        ? p.chipSelectedForeground
                        : p.chipIdleForeground,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistorySeasonView extends StatelessWidget {
  const _HistorySeasonView({
    required this.year,
    required this.plants,
    required this.moestuinName,
    required this.profileStore,
    required this.scanPrefs,
    required this.gardenStore,
    required this.repository,
    required this.onRestored,
  });

  final int year;
  final List<_PlantHistoryItem> plants;
  final String moestuinName;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final MyGardenStore gardenStore;
  final VegetableRepository repository;
  final VoidCallback onRestored;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    if (plants.isEmpty) {
      return _emptyFilterCard(context, moestuinName: moestuinName, year: year);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReuseInMoestuinCard(
          plantCount: plants.length,
          onReuse: () async {
            final rows = plants
                .map(
                  (item) => HistoryResumePlantRow(
                    vegetable: item.vegetable,
                    profile: item.profile,
                    alreadyInGarden: gardenStore.contains(item.vegetable.id) ||
                        profileStore.activeProfileFor(item.vegetable.id) !=
                            null,
                  ),
                )
                .toList();
            final ok = await showResumePlantsFromHistorySheet(
              context,
              plants: rows,
              year: year,
              moestuinName: moestuinName,
              gardenStore: gardenStore,
              profileStore: profileStore,
              repository: repository,
              scanPrefs: scanPrefs,
            );
            if (ok) onRestored();
          },
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.58,
          ),
          itemCount: plants.length,
          itemBuilder: (context, index) {
            final item = plants[index];
            return _ArchivedPlantCard(
              vegetable: item.vegetable,
              profile: item.profile,
              onTap: () {
                final scanCount = plantScanEntries(item.profile).length;
                showPlantHistorySheet(
                  context: context,
                  vegetable: item.vegetable,
                  profile: item.profile,
                  profileStore: profileStore,
                  scanPrefs: scanPrefs,
                  gardenStore: gardenStore,
                  initialTabIndex: scanCount > 0 ? 1 : 0,
                );
              },
            );
          },
        ),
      ],
    );
  }

  Widget _emptyFilterCard(
    BuildContext context, {
    required String moestuinName,
    required int year,
  }) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        'Geen history voor $moestuinName in $year.\n'
        'Kies een ander jaar of een andere moestuin.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.35,
            ),
      ),
    );
  }
}

class _ArchivedPlantCard extends StatelessWidget {
  const _ArchivedPlantCard({
    required this.vegetable,
    required this.profile,
    required this.onTap,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final scanCount = plantScanEntries(profile).length;
    final hasScanPhoto = PlantScanPhotoStore.exists(profile.lastScanPhotoPath);
    final listAsset = vegetableImageFor(vegetable.id).assetPath;
    final useZoekenListImage = !hasScanPhoto && listAsset != null;
    final archived = profile.archivedAt;
    final status = profile.harvestedPercent >= 100
        ? (isEdibleMoestuinBloomCrop(vegetable)
            ? 'Afgerond'
            : isOrnamentalOnlyMoestuinCrop(vegetable)
                ? 'Seizoen afgerond'
                : 'Geoogst ${profile.harvestedPercent}%')
        : 'Verwijderd';

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: BorderRadius.circular(14),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: ColoredBox(
                color: useZoekenListImage
                    ? const Color(0xFF0A0A0A)
                    : Colors.transparent,
                child: VegetableHeroImage(
                  vegetable: vegetable,
                  scanPhotoPath: profile.lastScanPhotoPath,
                  expand: true,
                  borderRadius: BorderRadius.zero,
                  useAtlasIllustration: useZoekenListImage,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vegetable.nameNl,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    status,
                    style: t.textTheme.labelSmall?.copyWith(
                      color: cs.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    scanCount == 0
                        ? 'Geen scans'
                        : scanCount == 1
                            ? '1 scan'
                            : '$scanCount scans',
                    style: t.textTheme.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                    ),
                  ),
                  if (archived != null)
                    Text(
                      'In history ${archived.day}-${archived.month}-${archived.year}',
                      style: t.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
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

class _HistorySeason {
  const _HistorySeason({
    required this.year,
    required this.plants,
  });

  final int year;
  final List<_PlantHistoryItem> plants;
}

class _PlantHistoryItem {
  const _PlantHistoryItem({
    required this.vegetable,
    required this.profile,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
}

class _ReuseInMoestuinCard extends StatelessWidget {
  const _ReuseInMoestuinCard({
    required this.plantCount,
    required this.onReuse,
  });

  final int plantCount;
  final VoidCallback onReuse;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final p = PlantSetupPalette.of(context);

    return Material(
      color: p.chipSelectedBackground.withValues(alpha: 0.22),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: p.chipSelectedBackground.withValues(alpha: 0.55)),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: plantCount == 0 ? null : onReuse,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: p.confirmButton,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.replay_rounded,
                  color: p.confirmButtonForeground,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Planten weer hervatten',
                      style: t.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Deze planten weer gebruiken voor een frisse start',
                      style: t.textTheme.labelSmall?.copyWith(
                        color: p.activeIcon,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: p.activeIcon),
            ],
          ),
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
