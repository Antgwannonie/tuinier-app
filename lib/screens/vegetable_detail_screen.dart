import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/my_garden_store.dart';
import '../data/planting_calendar.dart';
import '../data/planting_calendar_fallback.dart';
import '../data/planting_season_status.dart';
import '../data/plant_health_warnings.dart';
import '../data/plant_quick_summary.dart';
import '../data/moestuin_companion_info.dart';
import '../data/planting_timing_advice.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../widgets/remove_from_garden.dart';
import '../widgets/home_moestuin_actions.dart';
import '../widgets/vegetable_thumbnail.dart';
import '../widgets/planting_timing_success_card.dart';
import '../widgets/plant_quick_summary_card.dart';
import '../widgets/plant_calendar_month_card.dart';
import '../widgets/plant_detail_section.dart';
import '../widgets/vegetable_info_accordion.dart';
import '../widgets/plant_health_warning_sheet.dart';

enum VegetableDetailSection {
  info,
  warnings,
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
  });

  final Vegetable vegetable;
  final int? focusMonth;
  final MyGardenStore? gardenStore;
  final VegetableRepository? repository;
  final GardenProfileStore? profileStore;
  final GardenScanPrefsStore? scanPrefs;
  final VoidCallback? onGoToPlantScan;
  final VegetableDetailSection initialSection;

  @override
  State<VegetableDetailScreen> createState() => _VegetableDetailScreenState();
}

class _VegetableDetailScreenState extends State<VegetableDetailScreen> {
  late int _sectionIndex;

  @override
  void initState() {
    super.initState();
    _sectionIndex =
        widget.initialSection == VegetableDetailSection.warnings ? 1 : 0;
  }

  List<VegetableMonthActivity> _monthTasks() {
    final month = widget.focusMonth ?? DateTime.now().month;
    return calendarActivitiesForVegetable(
      widget.vegetable.id,
      vegetable: widget.vegetable,
    )
        .where((a) => a.months.contains(month))
        .toList()
      ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));
  }

  @override
  Widget build(BuildContext context) {
    final store = widget.profileStore;
    return Scaffold(
      body: store != null
          ? ListenableBuilder(
              listenable: store,
              builder: (context, _) =>
                  _buildBody(store.profileFor(widget.vegetable.id)),
            )
          : _buildBody(null),
    );
  }

  Widget _buildBody(GardenPlantProfile? profile) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final month = widget.focusMonth ?? DateTime.now().month;
    final monthTasks = _monthTasks();
    final monthName = kMonthNamesNl[month];
    final store = widget.profileStore;
    final inGarden = widget.gardenStore != null &&
        widget.gardenStore!.contains(widget.vegetable.id) &&
        store != null;
    final canRemove = inGarden &&
        widget.repository != null &&
        widget.scanPrefs != null;
    final seasonAdvice = plantingSeasonAdviceFor(widget.vegetable);
    final isCompanion =
        moestuinCompanionInfoForVegetable(widget.vegetable) != null;
    final quickSummary = buildPlantQuickSummary(
      vegetable: widget.vegetable,
      seasonAdvice: seasonAdvice,
    );
    final warningLevel = inGarden && profile != null
        ? plantWarningHighlightLevel(
            profile: profile,
            vegetable: widget.vegetable,
          )
        : PlantWarningHighlightLevel.none;
    final warningAccent = warningLevel != PlantWarningHighlightLevel.none
        ? warningAccentColors(cs, warningLevel)
        : null;

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          pinned: true,
          title: Text(widget.vegetable.nameNl),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            if (canRemove)
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Uit Mijn moestuin halen',
                onPressed: () async {
                  final removed = await confirmAndRemoveFromGarden(
                    context,
                    vegetable: widget.vegetable,
                    gardenStore: widget.gardenStore!,
                    profileStore: store!,
                    repository: widget.repository!,
                    scanPrefs: widget.scanPrefs!,
                  );
                  if (removed && context.mounted) {
                    Navigator.of(context).pop();
                  }
                },
              ),
          ],
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  kPlantDetailPadding,
                  16,
                  kPlantDetailPadding,
                  0,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    VegetableThumbnail(
                      vegetable: widget.vegetable,
                      size: 72,
                      borderRadius: 12,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.vegetable.nameNl,
                            style: t.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (widget.vegetable.nameLatin != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              widget.vegetable.nameLatin!,
                              style: t.textTheme.bodyMedium?.copyWith(
                                fontStyle: FontStyle.italic,
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _TagChip(label: widget.vegetable.family),
                              if (widget.vegetable.growthCategory != null &&
                                  widget.vegetable.growthCategory!
                                      .trim()
                                      .isNotEmpty)
                                _TagChip(
                                  label: widget.vegetable.growthCategory!,
                                ),
                              if (isCompanion)
                                _TagChip(
                                  label: 'Nuttig in de moestuin',
                                  highlight: true,
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              if (inGarden && profile != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPlantDetailPadding,
                  ),
                  child: SegmentedButton<int>(
                    showSelectedIcon: false,
                    segments: [
                      const ButtonSegment(
                        value: 0,
                        label: Text('Teeltinfo'),
                        icon: Icon(Icons.menu_book_outlined, size: 18),
                      ),
                      ButtonSegment(
                        value: 1,
                        icon: Icon(
                          Icons.warning_amber_rounded,
                          size: 18,
                          color: _sectionIndex == 1
                              ? warningAccent?.foreground
                              : warningLevel !=
                                      PlantWarningHighlightLevel.none
                                  ? warningAccent?.foreground
                                  : null,
                        ),
                        label: Text(
                          warningLevel != PlantWarningHighlightLevel.none
                              ? 'Meldingen'
                              : 'Meldingen',
                        ),
                      ),
                    ],
                    selected: {_sectionIndex},
                    onSelectionChanged: (s) =>
                        setState(() => _sectionIndex = s.first),
                  ),
                ),
                const SizedBox(height: 14),
              ],
              if (_sectionIndex == 0) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPlantDetailPadding,
                  ),
                  child: PlantQuickSummaryCard(summary: quickSummary),
                ),
                if (inGarden && profile != null && store != null) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kPlantDetailPadding,
                    ),
                    child: _GardenActionsCard(
                      canRemove: canRemove,
                      showMarkPlanted:
                          !profile.isPlanted && widget.scanPrefs != null,
                      onRemove: () async {
                        final removed = await confirmAndRemoveFromGarden(
                          context,
                          vegetable: widget.vegetable,
                          gardenStore: widget.gardenStore!,
                          profileStore: store,
                          repository: widget.repository!,
                          scanPrefs: widget.scanPrefs!,
                        );
                        if (removed && context.mounted) {
                          Navigator.of(context).pop();
                        }
                      },
                      onMarkPlanted: widget.scanPrefs != null
                          ? () async {
                              await store.ensureProfile(widget.vegetable.id);
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
                ],
                if (inGarden && profile != null) ...[
                  Builder(
                    builder: (context) {
                      final timing = seasonDisplayFor(
                        vegetable: widget.vegetable,
                        profile: profile,
                      );
                      if (timing.hasPositive) {
                        return Padding(
                          padding: const EdgeInsets.fromLTRB(
                            kPlantDetailPadding,
                            12,
                            kPlantDetailPadding,
                            0,
                          ),
                          child: PlantingTimingSuccessCard(
                            assessment: timing,
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ],
                if (monthTasks.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: kPlantDetailPadding,
                    ),
                    child: PlantCalendarMonthCard(
                      monthName: monthName,
                      tasks: monthTasks,
                    ),
                  ),
                ],
                const PlantDetailSectionHeader(
                  title: 'Alle teeltinfo',
                  icon: Icons.menu_book_outlined,
                ),
                VegetableInfoAccordion(
                  vegetable: widget.vegetable,
                  seasonAdvice: seasonAdvice.accordionLines.isEmpty
                      ? null
                      : seasonAdvice,
                ),
              ] else if (inGarden && profile != null && store != null) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: kPlantDetailPadding,
                  ),
                  child: PlantHealthWarningsPanel.fromProfile(
                    vegetable: widget.vegetable,
                    profile: profile,
                    profileStore: store,
                    onAcknowledgeAi: activeAiWarningsFor(profile).isNotEmpty
                        ? () async {
                            await store.acknowledgePlantHealth(
                              widget.vegetable.id,
                            );
                            if (mounted) setState(() {});
                          }
                        : null,
                  ),
                ),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, this.highlight = false});

  final String label;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: highlight
            ? cs.tertiaryContainer
            : cs.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: highlight ? cs.onTertiaryContainer : null,
            ),
      ),
    );
  }
}

class _GardenActionsCard extends StatelessWidget {
  const _GardenActionsCard({
    required this.canRemove,
    required this.showMarkPlanted,
    required this.onRemove,
    this.onMarkPlanted,
  });

  final bool canRemove;
  final bool showMarkPlanted;
  final VoidCallback onRemove;
  final VoidCallback? onMarkPlanted;

  @override
  Widget build(BuildContext context) {
    return PlantDetailSectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mijn moestuin',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 10),
          if (showMarkPlanted && onMarkPlanted != null)
            FilledButton.icon(
              onPressed: onMarkPlanted,
              icon: const Icon(Icons.yard_outlined),
              label: const Text('Markeer als geplant'),
            ),
          if (canRemove) ...[
            if (showMarkPlanted) const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: onRemove,
              icon: const Icon(Icons.remove_circle_outline),
              label: const Text('Uit Mijn moestuin halen'),
            ),
          ],
        ],
      ),
    );
  }
}
