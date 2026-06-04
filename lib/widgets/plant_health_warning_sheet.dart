import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/plant_age_warnings.dart';
import '../data/plant_health_warnings.dart';
import '../data/planting_timing_advice.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'collapsible_garden_warning.dart';
import 'garden_warning_style.dart';
import 'pest_action_guide_sheet.dart';

/// Waarschuwingen: seizoen + datum/foto + AI-scan.
Future<void> showPlantHealthWarningSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required GardenProfileStore profileStore,
}) {
  final seasonLines = activeSeasonWarningsFor(
    profile: profile,
    vegetable: vegetable,
  );
  final dateLines = activeDatePhotoWarningsFor(profile);
  final aiLines = activeAiWarningsFor(profile);
  final scanInfoLines = lowPriorityScanInfoFor(profile);
  if (seasonLines.isEmpty &&
      dateLines.isEmpty &&
      aiLines.isEmpty &&
      scanInfoLines.isEmpty) {
    return Future.value();
  }

  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.35,
        maxChildSize: 0.92,
        builder: (context, scrollController) {
          return ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            children: [
              PlantHealthWarningsPanel(
                vegetable: vegetable,
                profile: profile,
                profileStore: profileStore,
                seasonWarnings: seasonLines,
                dateWarnings: dateLines,
                aiWarnings: aiLines,
                scanInfoLines: scanInfoLines,
                timing: seasonDisplayFor(
                  vegetable: vegetable,
                  profile: profile,
                ),
                onAcknowledgeAi: aiLines.isNotEmpty
                    ? () async {
                        await profileStore.acknowledgePlantHealth(
                          vegetable.id,
                        );
                        if (ctx.mounted) Navigator.pop(ctx);
                      }
                    : null,
              ),
            ],
          );
        },
      );
    },
  );
}

class GardenBellActionEntry {
  const GardenBellActionEntry({
    required this.vegetable,
    required this.message,
  });

  final Vegetable vegetable;
  final String message;
}

/// Overzicht van alle planten met meldingen.
Future<void> showGardenWarningsOverview({
  required BuildContext context,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required List<({GardenPlantProfile profile, Vegetable vegetable})> entries,
  List<GardenBellActionEntry> actionEntries = const [],
  void Function(Vegetable vegetable)? onOpenPlantDetail,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      final t = Theme.of(ctx);
      final cs = t.colorScheme;
      return ListenableBuilder(
        listenable: profileStore,
        builder: (context, _) {
          final visible = entries.where((e) {
            final p =
                profileStore.profileFor(e.vegetable.id) ?? e.profile;
            return profileShowsInBell(
              profile: p,
              vegetable: e.vegetable,
            );
          }).toList();
          final warningIds = visible.map((e) => e.vegetable.id).toSet();
          final visibleActions = actionEntries
              .where((a) => !warningIds.contains(a.vegetable.id))
              .toList();
          final hasAny = visible.isNotEmpty || visibleActions.isNotEmpty;

          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Meldingen',
                    style: t.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (!hasAny)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Text(
                        'Geen open meldingen in de bel.',
                        textAlign: TextAlign.center,
                        style: t.textTheme.bodyMedium?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    )
                  else
                    Flexible(
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: visible.length + visibleActions.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          if (i < visible.length) {
                            final e = visible[i];
                            final latestProfile =
                                profileStore.profileFor(e.vegetable.id) ??
                                    e.profile;
                            final lines = allActiveWarningsFor(
                              profile: latestProfile,
                              vegetable: e.vegetable,
                            );

                            return ListTile(
                              leading: Icon(
                                Icons.warning_amber_rounded,
                                color: GardenWarningStyle.icon(cs),
                              ),
                              title: Text(e.vegetable.nameNl),
                              subtitle: Text(
                                lines.join(' · '),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    tooltip: 'Verwijderen uit bel',
                                    icon: Icon(
                                      Icons.close_rounded,
                                      color: GardenWarningStyle.icon(cs),
                                    ),
                                    onPressed: () async {
                                      await profileStore.dismissWarningsFromBell(
                                        e.vegetable.id,
                                      );
                                    },
                                  ),
                                  const Icon(Icons.chevron_right),
                                ],
                              ),
                              onTap: () {
                                Navigator.pop(ctx);
                                if (onOpenPlantDetail != null) {
                                  onOpenPlantDetail(e.vegetable);
                                } else {
                                  showPlantHealthWarningSheet(
                                    context: context,
                                    vegetable: e.vegetable,
                                    profile: latestProfile,
                                    profileStore: profileStore,
                                  );
                                }
                              },
                            );
                          }

                          final action = visibleActions[i - visible.length];
                          return ListTile(
                            leading: Icon(
                              Icons.info_outline,
                              color: cs.primary,
                            ),
                            title: Text(action.vegetable.nameNl),
                            subtitle: Text(
                              action.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            trailing: const Icon(Icons.chevron_right),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      );
    },
  );
}

/// Meldingen op de infopagina of in een bottom sheet.
class PlantHealthWarningsPanel extends StatelessWidget {
  const PlantHealthWarningsPanel({
    super.key,
    required this.vegetable,
    required this.profile,
    required this.profileStore,
    required this.seasonWarnings,
    required this.dateWarnings,
    required this.aiWarnings,
    required this.scanInfoLines,
    required this.timing,
    this.onAcknowledgeAi,
    this.showTitle = true,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final GardenProfileStore profileStore;
  final List<String> seasonWarnings;
  final List<String> dateWarnings;
  final List<String> aiWarnings;
  final List<String> scanInfoLines;
  final PlantingTimingAssessment timing;
  final Future<void> Function()? onAcknowledgeAi;
  final bool showTitle;

  List<String> get _seasonOnly {
    final dateSet = dateWarnings.toSet();
    return seasonWarnings.where((s) => !dateSet.contains(s)).toList();
  }

  static PlantHealthWarningsPanel fromProfile({
    required Vegetable vegetable,
    required GardenPlantProfile profile,
    required GardenProfileStore profileStore,
    Future<void> Function()? onAcknowledgeAi,
    bool showTitle = false,
  }) {
    final seasonLines = activeSeasonWarningsFor(
      profile: profile,
      vegetable: vegetable,
    );
    final dateLines = activeDatePhotoWarningsFor(profile);
    final aiLines = activeAiWarningsFor(profile);
    final scanInfoLines = lowPriorityScanInfoFor(profile);
    return PlantHealthWarningsPanel(
      vegetable: vegetable,
      profile: profile,
      profileStore: profileStore,
      seasonWarnings: seasonLines,
      dateWarnings: dateLines,
      aiWarnings: aiLines,
      scanInfoLines: scanInfoLines,
      timing: seasonDisplayFor(vegetable: vegetable, profile: profile),
      onAcknowledgeAi: onAcknowledgeAi,
      showTitle: showTitle,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final seasonOnly = _seasonOnly;
    final hasContent = dateWarnings.isNotEmpty ||
        seasonOnly.isNotEmpty ||
        aiWarnings.isNotEmpty ||
        scanInfoLines.isNotEmpty;

    if (!hasContent) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: cs.primary.withValues(alpha: 0.75),
            ),
            const SizedBox(height: 12),
            Text(
              'Geen open meldingen',
              style: t.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Seizoen, scan en plantdatum zien er goed uit.',
              textAlign: TextAlign.center,
              style: t.textTheme.bodyMedium?.copyWith(
                color: cs.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (showTitle) ...[
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                color: GardenWarningStyle.icon(cs),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  vegetable.nameNl,
                  style: t.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],
        if (dateWarnings.isNotEmpty) ...[
          CollapsibleGardenWarning(
              title: 'Datum en foto',
              icon: Icons.compare_arrows,
              subtitle: dateWarnings.first,
              bodyLines: dateWarnings,
              initiallyExpanded: true,
              tone: GardenNoticeTone.warning,
            ),
        ],
        if (seasonOnly.isNotEmpty) ...[
          const SizedBox(height: 12),
          CollapsibleGardenWarning(
              title: 'Seizoen en plantmoment',
              icon: Icons.calendar_month_outlined,
              subtitle: seasonOnly.first,
              bodyLines: seasonOnly,
              footer: timing.alternativeLabel != null
                  ? 'Alternatief\n${timing.alternativeLabel}'
                  : null,
              initiallyExpanded: dateWarnings.isEmpty,
              tone: GardenNoticeTone.warning,
            ),
        ],
        if (aiWarnings.isNotEmpty) ...[
          const SizedBox(height: 12),
          CollapsibleGardenWarning(
              title: 'AI-scan (plantgezondheid)',
              icon: Icons.bug_report_outlined,
              subtitle: aiWarnings.first,
              bodyLines: aiWarnings,
              initiallyExpanded: false,
              tone: GardenNoticeTone.danger,
            ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: () {
                showPestActionGuideSheet(
                  context: context,
                  vegetable: vegetable,
                  warningText: aiWarnings.first,
                  profile: profile,
                );
              },
              icon: const Icon(Icons.help_outline, size: 18),
              label: const Text('Hoe actie ondernemen?'),
              style: TextButton.styleFrom(
                visualDensity: VisualDensity.compact,
              ),
            ),
          ),
        ],
        if (scanInfoLines.isNotEmpty) ...[
          const SizedBox(height: 12),
          CollapsibleGardenWarning(
              title: 'Scan-informatie',
              icon: Icons.info_outline,
              subtitle: scanInfoLines.first,
              bodyLines: scanInfoLines,
              initiallyExpanded: false,
              tone: GardenNoticeTone.info,
            ),
        ],
        if (onAcknowledgeAi != null) ...[
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: () => onAcknowledgeAi!(),
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('AI-melding afgehandeld'),
          ),
        ],
      ],
    );
  }
}
