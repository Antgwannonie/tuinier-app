import 'package:flutter/material.dart';

import '../data/garden_health_score.dart';
import '../data/garden_profile_store.dart';
import '../data/insect_scan_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../theme/plant_setup_palette.dart';
import '../theme/tuinier_theme.dart';

/// Compacte samenvatting: maand, planten, acties en tuingezondheid.
class MoestuinOverviewCard extends StatelessWidget {
  const MoestuinOverviewCard({
    super.key,
    required this.gardenStore,
    required this.profileStore,
    required this.repository,
    required this.insectStore,
    required this.monthName,
    required this.plantCount,
    required this.pendingCount,
    this.onOpenInsight,
  });

  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final VegetableRepository repository;
  final InsectScanStore insectStore;
  final String monthName;
  final int plantCount;
  final int pendingCount;
  final VoidCallback? onOpenInsight;

  String _actionsLabel(bool isEmpty) {
    if (isEmpty) return 'Voeg je eerste groente toe';
    if (pendingCount == 0) return 'Geen open taken';
    return pendingCount == 1
        ? '1 openstaande taak'
        : '$pendingCount openstaande taken';
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final p = PlantSetupPalette.of(context);
    final score = computeGardenHealthScore(
      gardenStore: gardenStore,
      profileStore: profileStore,
      repository: repository,
      insectStore: insectStore,
    );
    final isEmpty = plantCount == 0;
    final plantsLabel = plantCount == 1 ? '1 plant' : '$plantCount planten';
    final scoreLabel = isEmpty ? '—' : '${score.total}';
    final hasOpenActions = !isEmpty && pendingCount > 0;
    final accent = p.activeIcon;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Material(
        color: p.cardBackground,
        elevation: 0,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpenInsight,
          borderRadius: BorderRadius.circular(12),
          splashColor: cs.primary.withValues(alpha: 0.08),
          highlightColor: cs.primary.withValues(alpha: 0.04),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        TextSpan(
                          children: [
                            TextSpan(
                              text: monthName,
                              style: tuinAccentDisplayStyle(
                                context,
                                fontSize: 22,
                                color: cs.onSurface,
                              ),
                            ),
                            if (!isEmpty) ...[
                              TextSpan(
                                text: ' · ',
                                style: t.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurface,
                                ),
                              ),
                              TextSpan(
                                text: plantsLabel,
                                style: t.textTheme.labelMedium?.copyWith(
                                  color: cs.onSurface,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _actionsLabel(isEmpty),
                        style: t.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: hasOpenActions || isEmpty
                              ? accent
                              : cs.onSurfaceVariant,
                          height: 1.2,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Tuingezondheid',
                      style: t.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: accent,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEmpty ? '—' : '$scoreLabel/100',
                      style: t.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: accent,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
                if (onOpenInsight != null) ...[
                  const SizedBox(width: 6),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 22,
                    color: cs.onSurfaceVariant.withValues(alpha: 0.75),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
