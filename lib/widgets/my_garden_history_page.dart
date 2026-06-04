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
import 'restore_moestuin_from_history.dart';
import 'tuin_heading.dart';
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

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_refresh);
    widget.profileStore.addListener(_refresh);
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
          _headerCard(context),
          const SizedBox(height: 16),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
      children: [
        _headerCard(context),
        const SizedBox(height: 12),
        _yearChips(context, seasons, selectedYear),
        const SizedBox(height: 14),
        _HistorySeasonView(
          season: season,
          profileStore: widget.profileStore,
          scanPrefs: widget.scanPrefs,
          gardenStore: widget.gardenStore,
          repository: widget.repository,
          onRestored: _refresh,
        ),
      ],
    );
  }

  Widget _headerCard(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const TuinHeading('Moestuin History', icon: Icons.history, fontSize: 20),
          const SizedBox(height: 6),
          Text(
            'Bekijk geoogste en verwijderde planten per jaar. '
            'Met de knop zet je dezelfde planten opnieuw in Mijn moestuin — '
            'history blijft gewoon staan.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }

  Widget _yearChips(
    BuildContext context,
    List<_HistorySeason> seasons,
    int selectedYear,
  ) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: seasons.map((season) {
        return ChoiceChip(
          label: Text('${season.year} (${season.plants.length})'),
          selected: selectedYear == season.year,
          showCheckmark: false,
          onSelected: (_) => setState(() => _selectedYear = season.year),
        );
      }).toList(),
    );
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

class _HistorySeasonView extends StatelessWidget {
  const _HistorySeasonView({
    required this.season,
    required this.profileStore,
    required this.scanPrefs,
    required this.gardenStore,
    required this.repository,
    required this.onRestored,
  });

  final _HistorySeason season;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final MyGardenStore gardenStore;
  final VegetableRepository repository;
  final VoidCallback onRestored;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    final moestuinBatches = profileStore.moestuinBatchesForYear(season.year);
    final archivedProfiles =
        season.plants.map((item) => item.profile).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ReuseInMoestuinCard(
          plantCount: season.plants.length,
          year: season.year,
          onReuse: () async {
            final ok = await confirmAndCopyHistorySeasonToGarden(
              context,
              year: season.year,
              archivedProfiles: archivedProfiles,
              gardenStore: gardenStore,
              profileStore: profileStore,
              repository: repository,
              scanPrefs: scanPrefs,
            );
            if (ok) onRestored();
          },
        ),
        if (moestuinBatches.isNotEmpty) ...[
          const SizedBox(height: 10),
          ...moestuinBatches.map(
            (batch) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RestoreMoestuinCard(
                batch: batch,
                onRestore: () async {
                  final ok = await confirmAndRestoreMoestuinBatch(
                    context,
                    batch: batch,
                    gardenStore: gardenStore,
                    profileStore: profileStore,
                    repository: repository,
                    scanPrefs: scanPrefs,
                  );
                  if (ok) onRestored();
                },
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Row(
          children: [
            TuinHeading('${season.year}', fontSize: 22),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: cs.secondaryContainer.withValues(alpha: 0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Archief',
                style: t.textTheme.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: cs.onSecondaryContainer,
                ),
              ),
            ),
            const Spacer(),
            Text(
              '${season.plants.length} plant${season.plants.length == 1 ? '' : 'en'}',
              style: t.textTheme.labelMedium?.copyWith(
                color: cs.onSurfaceVariant,
              ),
            ),
          ],
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
          itemCount: season.plants.length,
          itemBuilder: (context, index) {
            final item = season.plants[index];
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
    required this.year,
    required this.onReuse,
  });

  final int plantCount;
  final int year;
  final VoidCallback onReuse;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: cs.primaryContainer.withValues(alpha: 0.4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: cs.primary.withValues(alpha: 0.25)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.add_circle_outline, color: cs.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Opnieuw in Mijn moestuin',
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              plantCount == 1
                  ? 'Zet de plant van $year op je lijst — fris seizoen, history blijft.'
                  : 'Zet alle $plantCount planten van $year op je lijst — fris seizoen, history blijft.',
              style: t.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: plantCount == 0 ? null : onReuse,
              icon: const Icon(Icons.yard_outlined, size: 20),
              label: Text(
                plantCount == 1
                    ? 'Plant in moestuin zetten'
                    : 'Alle planten in moestuin zetten',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RestoreMoestuinCard extends StatelessWidget {
  const _RestoreMoestuinCard({
    required this.batch,
    required this.onRestore,
  });

  final MoestuinHistoryBatch batch;
  final VoidCallback onRestore;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final date =
        '${batch.archivedAt.day}-${batch.archivedAt.month}-${batch.archivedAt.year}';

    return Material(
      color: cs.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(
          color: cs.outlineVariant.withValues(alpha: 0.45),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.archive_outlined, color: cs.primary, size: 22),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Opgeslagen moestuin-snapshot',
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${batch.plantCount} plant${batch.plantCount == 1 ? '' : 'en'} · opgeslagen $date',
              style: t.textTheme.bodySmall?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.3,
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.tonalIcon(
              onPressed: onRestore,
              icon: const Icon(Icons.copy_all_outlined, size: 20),
              label: const Text('Deze snapshot in moestuin zetten'),
            ),
          ],
        ),
      ),
    );
  }
}

extension<T> on Iterable<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
