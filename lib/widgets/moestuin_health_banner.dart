import 'package:flutter/material.dart';

import '../data/garden_health_score.dart';
import '../data/garden_profile_store.dart';
import '../data/insect_scan_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';

/// Tuingezondheid in één oogopslag op het moestuin-tabblad.
class MoestuinHealthBanner extends StatelessWidget {
  const MoestuinHealthBanner({
    super.key,
    required this.gardenStore,
    required this.profileStore,
    required this.repository,
    required this.insectStore,
    this.onOpenInsight,
  });

  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final VegetableRepository repository;
  final InsectScanStore insectStore;
  final VoidCallback? onOpenInsight;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final t = Theme.of(context);
    final score = computeGardenHealthScore(
      gardenStore: gardenStore,
      profileStore: profileStore,
      repository: repository,
      insectStore: insectStore,
    );
    final moestuinName = gardenStore.activeSpace?.name ?? 'je moestuin';

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Material(
        color: cs.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onOpenInsight,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tuingezondheid',
                        style: t.textTheme.labelLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        score.plantCount == 0
                            ? 'Voeg planten toe aan $moestuinName'
                            : score.activeHarmfulSpecies > 0
                                ? '${score.activeHarmfulSpecies} actieve plaag'
                                    '${score.activeHarmfulSpecies == 1 ? '' : 'en'} · '
                                    '${score.warningCount} plant'
                                    '${score.warningCount == 1 ? '' : 'en'} '
                                    'met aandacht'
                                : '${score.beneficialInsects} nuttige insecten · '
                                    '${score.warningCount} plant'
                                    '${score.warningCount == 1 ? '' : 'en'} '
                                    'met aandacht',
                        style: t.textTheme.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      score.plantCount == 0 ? '—' : '${score.total}',
                      style: t.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: cs.primary,
                      ),
                    ),
                    Text(
                      '/100',
                      style: t.textTheme.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (onOpenInsight != null) ...[
                  const SizedBox(width: 4),
                  Icon(Icons.chevron_right, color: cs.onSurfaceVariant),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
