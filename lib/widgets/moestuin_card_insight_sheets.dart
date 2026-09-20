import 'package:flutter/material.dart';

import '../data/crop_bloom_countdown.dart';
import '../data/moestuin_card_metrics.dart';
import '../data/scan_report_builder.dart';
import '../data/scan_report_modules.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';

Future<void> showMoestuinPhaseSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required MoestuinCardMetrics metrics,
}) {
  return _showInsightSheet(
    context: context,
    title: 'Fase · ${vegetable.nameNl}',
    subtitle: metrics.phaseLabel.isEmpty ? 'Nog geen scan' : metrics.phaseLabel,
    icon: metrics.phaseIcon,
    body: metrics.phaseDetail,
  );
}

Future<void> showMoestuinGrowthSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required MoestuinCardMetrics metrics,
  GardenPlantProfile? profile,
}) {
  final insight = profile?.lastAnalysis?.insight;
  final tips = <String>[
    if (metrics.growthScoreDetail.isNotEmpty) metrics.growthScoreDetail,
    if (insight?.waterAdvice?.isNotEmpty == true) insight!.waterAdvice!,
    if (insight?.sunlightAdvice?.isNotEmpty == true) insight!.sunlightAdvice!,
    if (insight?.pruningAdvice?.isNotEmpty == true) insight!.pruningAdvice!,
    for (final action in insight?.recommendedActions ?? [])
      if (action.title.isNotEmpty)
        action.description?.isNotEmpty == true
            ? '${action.title}: ${action.description}'
            : action.title,
    for (final p in insight?.problems ?? [])
      if (p.isNotEmpty) p,
  ];
  return _showInsightSheet(
    context: context,
    title: 'Groei-score · ${vegetable.nameNl}',
    subtitle: metrics.growthScoreLabel,
    icon: Icons.trending_up_rounded,
    body: tips.isEmpty
        ? metrics.growthScoreDetail
        : tips.join('\n\n'),
    accentColor: metrics.growthScoreColor,
  );
}

Future<void> showMoestuinHealthSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required MoestuinCardMetrics metrics,
}) {
  return _showInsightSheet(
    context: context,
    title: 'Gezondheid · ${vegetable.nameNl}',
    subtitle: metrics.healthBadgeLabel,
    icon: Icons.eco_outlined,
    body: metrics.healthDetailLines.join('\n\n'),
    accentColor: metrics.healthPercent != null
        ? TuinierColors.plantHealthColor(metrics.healthPercent!)
        : TuinierColors.textSecondary,
    trailing: metrics.healthPercent != null
        ? '${metrics.healthPercent}%'
        : null,
  );
}

Future<void> showMoestuinHarvestInsightSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  VoidCallback? onScan,
}) {
  final analysis = profile?.lastAnalysis;
  final observation = analysis != null
      ? buildHarvestMilestoneObservation(
          analysis: analysis,
          vegetable: vegetable,
        )
      : null;

  if (observation == null) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final bottom = MediaQuery.paddingOf(ctx).bottom;
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${cropMilestoneObservationTitle(vegetable)} · ${vegetable.nameNl}',
                  style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Maak een scan om oogst- of bloei-info van de AI te zien.',
                  style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                        height: 1.45,
                        color: TuinierColors.textPrimary,
                      ),
                ),
                if (onScan != null) ...[
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      onScan();
                    },
                    child: const Text('Scan nu'),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  final scoreColor = observationScoreColor(observation.scorePercent);
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final bottom = MediaQuery.paddingOf(ctx).bottom;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(
                    observation.icon,
                    color: observation.iconColor ?? TuinierColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      '${observation.title} · ${vegetable.nameNl}',
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  Text(
                    '${observation.scorePercent}%',
                    style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: scoreColor,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                scanHarvestChanceStatusLabel(observation.scorePercent),
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      color: scoreColor,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              observationDescriptionText(
                observation.description,
                fontSize: 14,
                height: 1.45,
              ),
            ],
          ),
        ),
      );
    },
  );
}

Future<void> _showInsightSheet({
  required BuildContext context,
  required String title,
  required String subtitle,
  required IconData icon,
  required String body,
  Color? accentColor,
  String? trailing,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final bottom = MediaQuery.paddingOf(ctx).bottom;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Icon(icon, color: accentColor ?? TuinierColors.primary),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                  ),
                  if (trailing != null)
                    Text(
                      trailing,
                      style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: accentColor ?? TuinierColors.primary,
                          ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                subtitle,
                style: Theme.of(ctx).textTheme.titleSmall?.copyWith(
                      color: accentColor ?? TuinierColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                body,
                style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                      height: 1.45,
                      color: TuinierColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
