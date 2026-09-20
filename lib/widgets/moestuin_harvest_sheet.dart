import 'package:flutter/material.dart';

import '../data/crop_lifecycle_metadata.dart';
import '../data/garden_profile_store.dart';
import '../data/harvest_self_check.dart';
import '../data/harvest_tricks.dart';
import '../data/underground_crop.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import 'plant_harvest_info_sheet.dart';

/// Tekst-tab onderaan met uitleg en acties rond oogst / seizoen afronden.
Future<void> showMoestuinHarvestSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required GardenProfileStore profileStore,
  required bool selfCheckMode,
  VoidCallback? onSeasonFinished,
  VoidCallback? onProbeHarvestScan,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.52,
        minChildSize: 0.38,
        maxChildSize: 0.88,
        builder: (context, scrollController) {
          return SafeArea(
            child: _MoestuinHarvestSheetBody(
              scrollController: scrollController,
              vegetable: vegetable,
              profile: profile,
              profileStore: profileStore,
              selfCheckMode: selfCheckMode,
              onSeasonFinished: onSeasonFinished,
              onProbeHarvestScan: onProbeHarvestScan,
            ),
          );
        },
      );
    },
  );
}

String moestuinHarvestCardButtonLabel({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required bool selfCheckMode,
}) {
  if (selfCheckMode) {
    return isUndergroundHarvestConfirmed(profile, vegetable)
        ? 'Seizoen afronden'
        : 'Mogelijk oogstbaar';
  }
  return 'Oogst afgerond?';
}

String moestuinHarvestCardHintText({
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required bool selfCheckMode,
}) {
  if (selfCheckMode) {
    return selfCheckHarvestExpandHint();
  }

  final insight = profile.lastAnalysis?.insight;
  final continuous = insight?.moreHarvestExpectedThisSeason == false
      ? false
      : (insight?.moreHarvestExpectedThisSeason == true ||
          harvestPatternFor(vegetable) == CropHarvestPattern.continuous);

  if (continuous) {
    return 'Zolang er nog iets te oogsten valt: houd de plant actief bij '
        'in je moestuin.\n\n'
        'Geen oogst meer in zicht? Rond het seizoen af. Dan stoppen we de '
        'plant voor dit seizoen. Tot volgend seizoen.\n\n'
        'Alles over oogsten en rijpheid vind je bij Oogst-info.';
  }
  if (hasExtendedHarvestTricks(vegetable)) {
    return extendedHarvestExpandHint();
  }
  return 'Één oogst per seizoen. Alles geoogst? Rond het seizoen af.\n\n'
      'Dan stoppen we de plant voor dit seizoen. Tot volgend seizoen.\n\n'
      'Alles over oogsten en rijpheid vind je bij Oogst-info.';
}

/// Bevestigt en zet de plant niet-actief voor dit seizoen.
Future<bool> confirmAndFinishMoestuinSeason({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenProfileStore profileStore,
  required bool selfCheckMode,
  VoidCallback? onSeasonFinished,
}) async {
  final ok = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    useRootNavigator: true,
    builder: (ctx) => AlertDialog(
      title: const Text('Seizoen afronden?'),
      content: Text(
        selfCheckMode
            ? 'Weet je zeker dat ${vegetable.nameNl} klaar is voor dit '
                'seizoen en alles geoogst is?\n\n'
                'De plant blijft in je moestuin maar wordt niet-actief. Bij een '
                'nieuw seizoen wordt hij weer actief en kun je opnieuw beginnen met '
                'zaaien of planten.'
            : 'Weet je zeker dat ${vegetable.nameNl} klaar is voor dit '
                'seizoen?\n\n'
                'De plant blijft in je moestuin maar wordt niet-actief. Bij een '
                'nieuw seizoen wordt hij weer actief en kun je opnieuw beginnen met '
                'zaaien of planten.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: const Text('Annuleren'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          child: const Text('Seizoen afronden'),
        ),
      ],
    ),
  );
  if (ok != true) return false;

  await profileStore.setMoestuinInactive(vegetable.id);
  onSeasonFinished?.call();
  if (context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${vegetable.nameNl} is niet-actief. Bij een nieuw seizoen '
          'kun je weer zaaien of planten.',
        ),
      ),
    );
  }
  return true;
}

class _MoestuinHarvestSheetBody extends StatefulWidget {
  const _MoestuinHarvestSheetBody({
    required this.scrollController,
    required this.vegetable,
    required this.profile,
    required this.profileStore,
    required this.selfCheckMode,
    this.onSeasonFinished,
    this.onProbeHarvestScan,
  });

  final ScrollController scrollController;
  final Vegetable vegetable;
  final GardenPlantProfile profile;
  final GardenProfileStore profileStore;
  final bool selfCheckMode;
  final VoidCallback? onSeasonFinished;
  final VoidCallback? onProbeHarvestScan;

  @override
  State<_MoestuinHarvestSheetBody> createState() =>
      _MoestuinHarvestSheetBodyState();
}

class _MoestuinHarvestSheetBodyState extends State<_MoestuinHarvestSheetBody> {
  bool _finishing = false;

  String get _title => moestuinHarvestCardButtonLabel(
        vegetable: widget.vegetable,
        profile: widget.profile,
        selfCheckMode: widget.selfCheckMode,
      );

  Future<void> _finishSeason() async {
    if (_finishing) return;
    setState(() => _finishing = true);
    final finished = await confirmAndFinishMoestuinSeason(
      context: context,
      vegetable: widget.vegetable,
      profileStore: widget.profileStore,
      selfCheckMode: widget.selfCheckMode,
      onSeasonFinished: widget.onSeasonFinished,
    );
    if (!mounted) return;
    setState(() => _finishing = false);
    if (finished) Navigator.of(context).pop();
  }

  void _openInfo() {
    showPlantHarvestInfoSheet(
      context: context,
      vegetable: widget.vegetable,
      profile: widget.profile,
      selfCheckMode: widget.selfCheckMode,
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return ListView(
      controller: widget.scrollController,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      children: [
        Text(
          _title,
          style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 12),
        Text(
          moestuinHarvestCardHintText(
            vegetable: widget.vegetable,
            profile: widget.profile,
            selfCheckMode: widget.selfCheckMode,
          ),
          style: t.textTheme.bodyMedium?.copyWith(
            color: TuinierColors.textSecondary,
            height: 1.45,
          ),
        ),
        const SizedBox(height: 20),
        Material(
          color: TuinierColors.cardTintGreen.withValues(alpha: 0.35),
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            onTap: _openInfo,
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 20,
                    color: TuinierColors.primary,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Oogst-info',
                      style: t.textTheme.titleSmall?.copyWith(
                        color: TuinierColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    size: 20,
                    color: TuinierColors.primary.withValues(alpha: 0.8),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (widget.selfCheckMode && widget.onProbeHarvestScan != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.of(context).pop();
              widget.onProbeHarvestScan?.call();
            },
            icon: const Icon(Icons.camera_alt_outlined),
            label: const Text('Proefoogst-scan'),
          ),
        ],
        const SizedBox(height: 16),
        FilledButton.tonal(
          onPressed: _finishing ? null : _finishSeason,
          child: _finishing
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Seizoen afronden'),
        ),
      ],
    );
  }
}
