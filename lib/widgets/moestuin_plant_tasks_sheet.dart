import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/garden_scan_prefs_store.dart';
import '../data/plant_scheduled_actions.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/garden_home_action_list_tile.dart';
import 'home_action_detail_sheet.dart';
import 'home_moestuin_actions.dart';

Future<void> showMoestuinPlantTasksSheet({
  required BuildContext context,
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  required GardenProfileStore profileStore,
  int? month,
  VoidCallback? onGoToScan,
  VoidCallback? onOpenPlantDetail,
}) {
  final allItems = gardenHomeActionsForPlant(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    month: month,
  );
  final tasks = allItems.where((item) => item.isPlantTask).toList();
  final infoItems = allItems.where((item) => item.isPlantInfo).toList();

  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) {
      final bottom = MediaQuery.paddingOf(ctx).bottom;
      final totalCount = tasks.length + infoItems.length;
      return SafeArea(
        child: Padding(
          padding: EdgeInsets.fromLTRB(20, 0, 20, bottom + 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Taken & info · ${vegetable.nameNl}',
                style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                totalCount == 0
                    ? 'Geen open taken of info voor deze plant.'
                    : formatTasksAndInfoCount(
                        taskCount: tasks.length,
                        infoCount: infoItems.length,
                      ),
                style: Theme.of(ctx).textTheme.bodySmall?.copyWith(
                      color: TuinierColors.textSecondary,
                    ),
              ),
              const SizedBox(height: 16),
              if (totalCount == 0)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    'Alles bijgewerkt. Nieuwe taken en info verschijnen na een scan of wanneer het seizoen dat vraagt.',
                    textAlign: TextAlign.center,
                    style: Theme.of(ctx).textTheme.bodyMedium?.copyWith(
                          color: TuinierColors.textSecondary,
                        ),
                  ),
                )
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.sizeOf(ctx).height * 0.55,
                  ),
                  child: ListView(
                    shrinkWrap: true,
                    children: [
                      if (tasks.isNotEmpty) ...[
                        const _SectionHeader(title: 'Taken'),
                        ..._buildSectionItems(
                          context: ctx,
                          items: tasks,
                          profile: profile,
                          profileStore: profileStore,
                          scanPrefs: scanPrefs,
                          onGoToScan: onGoToScan,
                          onOpenPlantDetail: onOpenPlantDetail,
                        ),
                      ],
                      if (tasks.isNotEmpty && infoItems.isNotEmpty)
                        const SizedBox(height: 12),
                      if (infoItems.isNotEmpty) ...[
                        const _SectionHeader(title: 'Let op'),
                        ..._buildSectionItems(
                          context: ctx,
                          items: infoItems,
                          profile: profile,
                          profileStore: profileStore,
                          scanPrefs: scanPrefs,
                          onGoToScan: onGoToScan,
                          onOpenPlantDetail: onOpenPlantDetail,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    },
  );
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: TuinierColors.textSecondary,
            ),
      ),
    );
  }
}

List<Widget> _buildSectionItems({
  required BuildContext context,
  required List<GardenHomeAction> items,
  required GardenPlantProfile? profile,
  required GardenProfileStore profileStore,
  required GardenScanPrefsStore scanPrefs,
  VoidCallback? onGoToScan,
  VoidCallback? onOpenPlantDetail,
}) {
  return [
    for (var i = 0; i < items.length; i++) ...[
      if (i > 0) const Divider(height: 1),
      GardenHomeActionListTile(
        action: items[i],
        profile: profile,
        compact: true,
        onTap: () {
          Navigator.pop(context);
          showHomeActionDetailSheet(
            context: context,
            action: items[i],
            profile: profile,
            profileStore: profileStore,
            scanPrefs: scanPrefs,
            onGoToScan: onGoToScan,
            onOpenPlantDetail: onOpenPlantDetail,
          );
        },
      ),
    ],
  ];
}
