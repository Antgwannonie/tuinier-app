import 'package:flutter/material.dart';

import '../data/garden_plant_schedule.dart';
import '../data/plant_pending_planting.dart';
import '../data/plant_start_flow.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import 'mark_planted_sheet.dart';
import 'plant_setup_sheet_ui.dart';

/// Instructies + afgerond-knop (geen formulier) op basis van wizard-keuzes.
class PlantingGuidanceSheet extends StatelessWidget {
  const PlantingGuidanceSheet({
    super.key,
    required this.vegetable,
    required this.profile,
  });

  final Vegetable vegetable;
  final GardenPlantProfile profile;

  bool get _outdoorCompletion => profileAwaitingOutdoorPlanting(profile);

  MarkPlantedResult _result() => markPlantedResultFromProfile(profile);

  @override
  Widget build(BuildContext context) {
    final guidance = buildPlantingGuidanceSteps(
      vegetable: vegetable,
      profile: profile,
    );
    final actionLabel = plantingActionButtonLabel(
      vegetable: vegetable,
      profile: profile,
    );
    final completeLabel = plantingCompleteButtonLabel(
      vegetable: vegetable,
      profile: profile,
    );

    return PlantSetupSheetFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlantSetupSheetHeader(
              title: vegetable.nameNl,
              badge: actionLabel,
              subtitle: _outdoorCompletion
                  ? 'Zo plant je je voorgezaaide plant buiten. Daarna kun je '
                      'scannen voor je AI-samenvatting.'
                  : 'Zo pak je het aan op basis van jouw keuzes. Daarna kun '
                      'je scannen voor je AI-samenvatting.',
            ),
            if (!_outdoorCompletion) ...[
              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: TuinierColors.cardTintGreen.withValues(alpha: 0.45),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  plantingSetupSummaryLine(profile),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: TuinierColors.textPrimary,
                      ),
                ),
              ),
            ],
            const SizedBox(height: 20),
            const PlantSetupSectionLabel('Zo doe je het'),
            ...[
              for (var i = 0; i < guidance.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GuidanceStepCard(
                    index: i + 1,
                    body: guidance.steps[i],
                  ),
                ),
            ],
            if (guidance.offSeason != null) ...[
              _GuidanceStepCard(
                index: guidance.steps.length + 1,
                title: 'Buiten het seizoen',
                body: guidance.offSeason!.body,
                accent: true,
              ),
              for (final tip in guidance.offSeason!.extraTips)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _GuidanceStepCard(
                    index: null,
                    title: 'Tip',
                    body: tip,
                    accent: true,
                  ),
                ),
            ],
            const SizedBox(height: 8),
            PlantSetupConfirmButton(
              label: completeLabel,
              onPressed: () => Navigator.pop(context, _result()),
            ),
            const SizedBox(height: 8),
            Text(
              'Daarna: $kFirstScanCardLabel op je plantkaart in de moestuin.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: TuinierColors.textSecondary,
                    height: 1.35,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidanceStepCard extends StatelessWidget {
  const _GuidanceStepCard({
    required this.body,
    this.index,
    this.title,
    this.accent = false,
  });

  final int? index;
  final String? title;
  final String body;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: accent
            ? TuinierColors.cardTintGreen.withValues(alpha: 0.35)
            : TuinierColors.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TuinierColors.border.withValues(alpha: 0.7),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (index != null)
            Container(
              width: 28,
              height: 28,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: TuinierColors.primary.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: Text(
                '$index',
                style: t.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: TuinierColors.primary,
                ),
              ),
            ),
          if (index != null) const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: t.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  body,
                  style: t.bodyMedium?.copyWith(
                    color: TuinierColors.textSecondary,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
