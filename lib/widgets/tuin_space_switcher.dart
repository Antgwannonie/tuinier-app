import 'package:flutter/material.dart';

import '../data/my_garden_store.dart';
import '../models/tuin_space.dart';
import '../theme/plant_setup_palette.dart';
import '../theme/tuinier_colors.dart';
import '../theme/tuinier_theme.dart';
import 'plant_setup_sheet_ui.dart';

/// Tik op de moestuinnaam in de app bar om van moestuin te wisselen.
class TuinSpaceSwitcher extends StatelessWidget {
  const TuinSpaceSwitcher({
    super.key,
    required this.gardenStore,
    this.useTitleStyle = true,
    this.centered = false,
    this.onPlanMoestuin,
    this.onAddExistingMoestuin,
  });

  final MyGardenStore gardenStore;
  final bool useTitleStyle;
  final bool centered;
  final VoidCallback? onPlanMoestuin;
  final VoidCallback? onAddExistingMoestuin;

  @override
  Widget build(BuildContext context) {
    final space = gardenStore.activeSpace;
    final label = space?.name ?? 'Mijn moestuin';
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final width = MediaQuery.sizeOf(context).width;

    final textStyle = useTitleStyle
        ? tuinAccentDisplayStyle(
            context,
            fontSize: t.appBarTheme.titleTextStyle?.fontSize ?? 30,
            color: cs.onSurface,
          )
        : t.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: TuinierColors.textPrimary,
          );

    final iconSize = useTitleStyle ? 26.0 : 22.0;
    final maxTitleWidth = width - 140;

    final titleRow = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxTitleWidth),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: centered ? TextAlign.center : TextAlign.start,
              style: textStyle,
            ),
          ),
          SizedBox(width: useTitleStyle ? 2 : 4),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: iconSize,
            color: useTitleStyle
                ? cs.onSurfaceVariant
                : TuinierColors.textPrimary,
          ),
        ],
      ),
    );

    return Tooltip(
      message: 'Wissel van moestuin',
      child: InkWell(
        onTap: () => _openPicker(context),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: centered ? Center(child: titleRow) : titleRow,
        ),
      ),
    );
  }

  Future<void> _openPicker(BuildContext context) async {
    final rootContext = context;
    final picked = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      useRootNavigator: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _MoestuinPickerSheet(
        gardenStore: gardenStore,
        rootContext: rootContext,
        onPlanMoestuin: onPlanMoestuin,
        onAddExistingMoestuin: onAddExistingMoestuin,
      ),
    );
    if (!rootContext.mounted || picked == null || picked == '__new__') return;
    await gardenStore.setActiveSpace(picked);
  }
}

class _MoestuinPickerSheet extends StatelessWidget {
  const _MoestuinPickerSheet({
    required this.gardenStore,
    required this.rootContext,
    this.onPlanMoestuin,
    this.onAddExistingMoestuin,
  });

  final MyGardenStore gardenStore;
  final BuildContext rootContext;
  final VoidCallback? onPlanMoestuin;
  final VoidCallback? onAddExistingMoestuin;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);
    final spaces = gardenStore.allSpaces
        .where((s) => !_isHiddenLegacyName(s.name))
        .toList();
    final active = gardenStore.activeSpace?.id;

    return Material(
      color: cs.surface,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      child: SafeArea(
        top: false,
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
          children: [
            const PlantSetupSheetHeader(
              centered: true,
              title: 'Jouw moestuinen',
              subtitle: 'Kies welke moestuin je nu wilt bekijken.',
            ),
            const SizedBox(height: 12),
            ...spaces.map((s) {
              final isActive = active == s.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: isActive
                      ? p.chipSelectedBackground.withValues(alpha: 0.35)
                      : p.cardBackground,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(
                      color: isActive ? p.chipSelectedBackground : p.cardBorder,
                      width: isActive ? 1.5 : 1,
                    ),
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => Navigator.pop(context, s.id),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.yard_outlined,
                            color: isActive ? p.activeIcon : cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  s.name,
                                  style: t.textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                Text(
                                  '${s.plantCount} plant'
                                  '${s.plantCount == 1 ? '' : 'en'} · '
                                  '${s.place.label}',
                                  style: t.textTheme.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isActive)
                            Icon(Icons.check_circle, color: p.activeIcon),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            Material(
              color: p.badgeBackground.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.pop(context);
                  onAddExistingMoestuin?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.playlist_add_rounded, color: p.activeIcon),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Moestuin toevoegen',
                              style: t.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'geef een naam en standplaats op',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Material(
              color: p.badgeBackground.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () {
                  Navigator.pop(context);
                  onPlanMoestuin?.call();
                },
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.add_circle_outline, color: p.activeIcon),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Moestuin plannen',
                              style: t.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              'plan nu jou moestuin voor volgend seizoen',
                              style: t.textTheme.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _isHiddenLegacyName(String name) {
    const hidden = {
      'natuurtuin',
      'kruidentuin',
      'bloementuin',
      'fruitgaard',
      'kamerplanten',
      'siertuin',
      'gemengde tuin',
    };
    return hidden.contains(name.trim().toLowerCase());
  }
}
