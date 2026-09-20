import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/plant_scan_history.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';
import 'plant_insight_inzichten_tab.dart';
import 'plant_insight_scans_tab.dart';
import 'vegetable_hero_image.dart';

enum GardenPlantInsightSection {
  insights,
  scanHistory,
}

/// Inzichten + scan-geschiedenis voor een plant in de moestuin.
class GardenPlantInsightBody extends StatefulWidget {
  const GardenPlantInsightBody({
    super.key,
    required this.vegetable,
    required this.profileStore,
    required this.scanPrefs,
    this.gardenStore,
    this.repository,
    this.onGoToPlantScan,
    this.initialSection = GardenPlantInsightSection.insights,
    this.showHeader = true,
    this.scrollController,
    this.embedded = false,
  });

  final Vegetable vegetable;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final MyGardenStore? gardenStore;
  final VegetableRepository? repository;
  final VoidCallback? onGoToPlantScan;
  final GardenPlantInsightSection initialSection;
  final bool showHeader;
  final ScrollController? scrollController;
  final bool embedded;

  @override
  State<GardenPlantInsightBody> createState() => _GardenPlantInsightBodyState();
}

class _GardenPlantInsightBodyState extends State<GardenPlantInsightBody> {
  late int _sectionIndex;

  @override
  void initState() {
    super.initState();
    _sectionIndex =
        widget.initialSection == GardenPlantInsightSection.scanHistory ? 1 : 0;
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: widget.profileStore,
      builder: (context, _) {
        final profile =
            widget.profileStore.profileFor(widget.vegetable.id);
        if (profile == null) {
          return const Center(child: Text('Plant niet gevonden in moestuin.'));
        }
        return _buildContent(context, profile);
      },
    );
  }

  Widget _buildContent(BuildContext context, GardenPlantProfile profile) {
    final scanCount = plantScanEntries(profile).length;

    return ListView(
      controller: widget.scrollController,
      padding: EdgeInsets.fromLTRB(
        16,
        8,
        16,
        widget.embedded ? 24 : 100,
      ),
      children: [
        if (widget.showHeader) ...[
          _InsightPlantHeader(
            vegetable: widget.vegetable,
            profile: profile,
            scanCount: scanCount,
          ),
          const SizedBox(height: 14),
        ],
        _InsightTabBar(
          sectionIndex: _sectionIndex,
          scanCount: scanCount,
          onChanged: (i) => setState(() => _sectionIndex = i),
        ),
        const SizedBox(height: 16),
        if (_sectionIndex == 0)
          PlantInsightInzichtenTab(
            vegetable: widget.vegetable,
            profile: profile,
            onScan: widget.onGoToPlantScan,
          )
        else
          PlantInsightScansTab(
            vegetable: widget.vegetable,
            profile: profile,
            onScan: widget.onGoToPlantScan,
          ),
        if (!profile.isPlanted &&
            widget.gardenStore != null &&
            widget.repository != null) ...[
          const SizedBox(height: 16),
          Text(
            'Markeer deze plant als geplant om scans op te slaan.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TuinierColors.textSecondary,
                  height: 1.4,
                ),
          ),
        ],
      ],
    );
  }
}

class _InsightTabBar extends StatelessWidget {
  const _InsightTabBar({
    required this.sectionIndex,
    required this.scanCount,
    required this.onChanged,
  });

  final int sectionIndex;
  final int scanCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: TuinierColors.searchBar.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _TabChip(
              label: 'Inzichten',
              icon: Icons.insights_outlined,
              selected: sectionIndex == 0,
              onTap: () => onChanged(0),
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _TabChip(
              label: scanCount > 0 ? 'Scans ($scanCount)' : 'Scans',
              icon: Icons.photo_camera_outlined,
              selected: sectionIndex == 1,
              onTap: () => onChanged(1),
            ),
          ),
        ],
      ),
    );
  }
}

class _TabChip extends StatelessWidget {
  const _TabChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TuinierColors.card : Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      elevation: selected ? 1 : 0,
      shadowColor: Colors.black26,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 17,
                color: selected
                    ? TuinierColors.primary
                    : TuinierColors.textSecondary,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: selected
                      ? TuinierColors.primary
                      : TuinierColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InsightPlantHeader extends StatelessWidget {
  const _InsightPlantHeader({
    required this.vegetable,
    required this.profile,
    required this.scanCount,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final int scanCount;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final scanLine = scanCount == 0
        ? 'Nog geen opgeslagen scan'
        : scanCount == 1
            ? '1 opgeslagen scan'
            : '$scanCount opgeslagen scans';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: TuinierDecorations.card(
            radius: 14,
            shadow: false,
            bordered: true,
          ),
          clipBehavior: Clip.antiAlias,
          child: VegetableHeroImage(
            vegetable: vegetable,
            scanPhotoPath: profile.lastScanPhotoPath,
            expand: true,
            useAtlasIllustration: true,
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                vegetable.nameNl,
                style: t.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black,
                  height: 1.1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                scanLine,
                style: t.textTheme.bodySmall?.copyWith(
                  color: TuinierColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Vaste onderknop «Nieuwe scan maken» voor het inzichtenscherm.
class PlantInsightScanButton extends StatelessWidget {
  const PlantInsightScanButton({
    super.key,
    required this.profile,
    required this.onScan,
  });

  final GardenPlantProfile profile;
  final VoidCallback onScan;

  @override
  Widget build(BuildContext context) {
    if (!profile.isPlanted) return const SizedBox.shrink();

    final label = profile.lastAnalysis == null
        ? 'Eerste scan maken'
        : 'Nieuwe scan maken';

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
        child: FilledButton.icon(
          onPressed: onScan,
          icon: const Icon(Icons.photo_camera_outlined),
          label: Text(label),
          style: FilledButton.styleFrom(
            minimumSize: const Size.fromHeight(50),
            backgroundColor: TuinierColors.headerDark,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ),
    );
  }
}
