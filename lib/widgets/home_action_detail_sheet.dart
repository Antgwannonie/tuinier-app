import 'package:flutter/material.dart';

import '../data/garden_home_action_visual.dart';
import '../data/garden_profile_store.dart';
import '../data/garden_plant_schedule.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/home_action_completion.dart';
import '../data/home_action_plan.dart';
import '../data/home_action_step_icon.dart';
import '../data/plant_pending_planting.dart';
import '../data/plant_scheduled_actions.dart';
import '../data/plant_start_flow.dart';
import '../models/garden_plant_profile.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';
import 'home_moestuin_actions.dart';
import 'mark_planted_sheet.dart';
import 'vegetable_thumbnail.dart';

/// Groot detail-scherm voor één home-actie met stappenplan.
Future<void> showHomeActionDetailSheet({
  required BuildContext context,
  required GardenHomeAction action,
  required GardenPlantProfile? profile,
  required GardenProfileStore profileStore,
  required GardenScanPrefsStore scanPrefs,
  VoidCallback? onGoToScan,
  VoidCallback? onOpenPlantDetail,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return _HomeActionDetailSheet(
        action: action,
        profile: profile,
        profileStore: profileStore,
        scanPrefs: scanPrefs,
        onGoToScan: onGoToScan,
        onOpenPlantDetail: onOpenPlantDetail,
      );
    },
  );
}

class _HomeActionDetailSheet extends StatefulWidget {
  const _HomeActionDetailSheet({
    required this.action,
    required this.profile,
    required this.profileStore,
    required this.scanPrefs,
    this.onGoToScan,
    this.onOpenPlantDetail,
  });

  final GardenHomeAction action;
  final GardenPlantProfile? profile;
  final GardenProfileStore profileStore;
  final GardenScanPrefsStore scanPrefs;
  final VoidCallback? onGoToScan;
  final VoidCallback? onOpenPlantDetail;

  @override
  State<_HomeActionDetailSheet> createState() => _HomeActionDetailSheetState();
}

class _HomeActionDetailSheetState extends State<_HomeActionDetailSheet> {
  bool _completing = false;

  GardenPlantProfile? get _profile =>
      widget.profileStore.profileFor(widget.action.vegetable.id) ??
      widget.profile;

  Future<void> _markCompleted() async {
    final scheduled = widget.action.scheduled;
    if (scheduled == null || _completing) return;
    setState(() => _completing = true);

    final profile = _profile;
    if (scheduled.kind == PlantScheduledActionKind.planPlant &&
        profile != null) {
      if (!profile.isPlanted) {
        final planted = await commitVegetablePlanted(
          profileStore: widget.profileStore,
          vegetableId: widget.action.vegetable.id,
          result: markPlantedResultFromProfile(profile),
        );
        if (!mounted) return;
        if (!planted) {
          setState(() => _completing = false);
          return;
        }
      } else if (profileAwaitingOutdoorPlanting(profile)) {
        final planted = await commitVegetablePlanted(
          profileStore: widget.profileStore,
          vegetableId: widget.action.vegetable.id,
          result: markPlantedResultFromProfile(profile),
        );
        if (!mounted) return;
        final updated =
            widget.profileStore.profileFor(widget.action.vegetable.id);
        if (!planted ||
            (updated != null && profileAwaitingOutdoorPlanting(updated))) {
          setState(() => _completing = false);
          return;
        }
      }
    }

    if (!mounted) return;
    final latestProfile =
        widget.profileStore.profileFor(widget.action.vegetable.id) ?? profile;

    if (scheduled.kind == PlantScheduledActionKind.firstScan &&
        widget.onGoToScan != null) {
      Navigator.pop(context);
      scheduleNavigateToPlantScan(widget.onGoToScan);
      return;
    }

    await widget.profileStore.ensureProfile(widget.action.vegetable.id);

    final completed = await markHomeActionCompleted(
      profileStore: widget.profileStore,
      vegetableId: widget.action.vegetable.id,
      kindName: scheduled.kind.name,
      topic: scheduled.topic,
      activeLabel: scheduled.activeLabel,
      detailBody: scheduled.detailBody,
      vegetable: widget.action.vegetable,
      scanPrefs: widget.scanPrefs,
    );
    if (!mounted) return;
    if (!completed) {
      setState(() => _completing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Taak kon niet worden opgeslagen. Probeer opnieuw.'),
        ),
      );
      return;
    }
    Navigator.pop(context);

    final label = switch (scheduled.kind) {
      PlantScheduledActionKind.planPlant when latestProfile != null =>
        '${widget.action.vegetable.nameNl}: '
            '${plantingCompleteButtonLabel(vegetable: widget.action.vegetable, profile: latestProfile)}. '
            'Volgende stap: $kFirstScanCardLabel op je plantkaart.',
      _ => '${widget.action.vegetable.nameNl}: taak afgevinkt',
    };
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(label)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final profile = _profile;
    final scheduled = widget.action.scheduled;
    final plan = buildHomeActionPlan(action: widget.action, profile: profile);
    final visual = gardenHomeActionVisual(widget.action, profile);
    final completeLabel = scheduled == null
        ? 'Taak uitgevoerd'
        : completeHomeActionButtonLabel(
            kindName: scheduled.kind.name,
            vegetable: widget.action.vegetable,
            profile: profile,
          );

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.72,
      minChildSize: 0.45,
      maxChildSize: 0.92,
      builder: (context, scrollController) {
        return SafeArea(
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _ActionHeroIcon(visual: visual),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          plan.headline,
                          style:
                              Theme.of(context).textTheme.titleLarge?.copyWith(
                                    fontWeight: FontWeight.w700,
                                    fontSize: 22,
                                  ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          plan.summary,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: TuinierColors.textSecondary,
                                    height: 1.45,
                                  ),
                        ),
                      ],
                    ),
                  ),
                  VegetableThumbnail(
                    vegetable: widget.action.vegetable,
                    size: 64,
                    borderRadius: 14,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                'Stappenplan voor deze taak',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 12),
              ...plan.steps.asMap().entries.map((entry) {
                final i = entry.key + 1;
                final step = entry.value;
                final stepIcon = homeActionStepIcon(
                  step: step,
                  actionKind: widget.action.kind,
                  index: entry.key,
                );
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Container(
                    decoration: TuinierDecorations.card(
                      radius: 16,
                      shadow: false,
                      bordered: true,
                      color: TuinierColors.card,
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _ActionStepIconBadge(
                          icon: stepIcon,
                          stepNumber: i,
                          accent: visual.color,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                step.title,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleSmall
                                    ?.copyWith(fontWeight: FontWeight.w600),
                              ),
                              if (step.detail != null &&
                                  step.detail!.trim().isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  step.detail!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: TuinierColors.textSecondary,
                                        height: 1.4,
                                      ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
              const SizedBox(height: 16),
              if (scheduled != null)
                FilledButton.icon(
                  onPressed: _completing ? null : _markCompleted,
                  icon: _completing
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.check_circle_rounded),
                  label: Text(completeLabel),
                ),
              if (widget.onGoToScan != null &&
                  (widget.action.kind == GardenHomeActionKind.firstPhoto ||
                      widget.action.kind == GardenHomeActionKind.weeklyScan ||
                      widget.action.kind == GardenHomeActionKind.planPlant ||
                      (scheduled != null &&
                          isPlantingScheduledAction(scheduled)))) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    scheduleNavigateToPlantScan(widget.onGoToScan);
                  },
                  icon: const Icon(Icons.photo_camera_rounded),
                  label: const Text('Naar scan'),
                ),
              ],
              if (widget.onOpenPlantDetail != null) ...[
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onOpenPlantDetail?.call();
                  },
                  icon: const Icon(Icons.eco_rounded),
                  label: const Text('Plantdetail'),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _ActionHeroIcon extends StatelessWidget {
  const _ActionHeroIcon({required this.visual});

  final GardenHomeActionVisual visual;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            visual.color,
            Color.lerp(visual.color, Colors.black, 0.18)!,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: visual.color.withValues(alpha: 0.28),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(visual.icon, color: Colors.white, size: 30),
    );
  }
}

class _ActionStepIconBadge extends StatelessWidget {
  const _ActionStepIconBadge({
    required this.icon,
    required this.stepNumber,
    required this.accent,
  });

  final IconData icon;
  final int stepNumber;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  accent,
                  Color.lerp(accent, Colors.black, 0.16)!,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: accent.withValues(alpha: 0.22),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 23),
          ),
          Positioned(
            right: -2,
            top: -2,
            child: Container(
              width: 18,
              height: 18,
              decoration: BoxDecoration(
                color: TuinierColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: accent, width: 1.5),
              ),
              child: Center(
                child: Text(
                  '$stepNumber',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: accent,
                    fontSize: 10,
                    height: 1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
