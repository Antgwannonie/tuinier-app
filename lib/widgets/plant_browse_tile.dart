import 'package:flutter/material.dart';

import '../data/planting_season_status.dart';
import '../data/vegetable_image_info.dart';
import '../models/vegetable.dart';
import 'vegetable_thumbnail.dart';

/// Plantregel Zoeken — tekst alleen (geen pictogram), vlak zonder kaart-raster.
class PlantBrowseTile extends StatelessWidget {
  const PlantBrowseTile({
    super.key,
    required this.vegetable,
    required this.onOpenDetail,
    this.seasonStatus,
    this.inGarden = false,
    this.onToggleGarden,
    this.dimmed = false,
    this.showDivider = true,
  });

  final Vegetable vegetable;
  final VoidCallback onOpenDetail;
  final PlantingSeasonStatus? seasonStatus;
  final bool inGarden;
  final VoidCallback? onToggleGarden;
  final bool dimmed;
  final bool showDivider;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final seasonLabel = seasonStatus != null &&
            seasonStatus!.searchListLabel.isNotEmpty
        ? seasonStatus!.searchListLabel
        : null;

    return Opacity(
      opacity: dimmed ? 0.72 : 1,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onOpenDetail,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
                child: Row(
                  children: [
                    _listLeading(context),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            vegetable.nameNl,
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                              height: 1.15,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (seasonLabel != null) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 6,
                                  color: _seasonColor(cs, seasonStatus!),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    seasonLabel,
                                    style: t.textTheme.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      height: 1.2,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (onToggleGarden != null)
                      IconButton(
                        visualDensity: VisualDensity.compact,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(
                          minWidth: 36,
                          minHeight: 36,
                        ),
                        tooltip: inGarden
                            ? 'Uit Mijn moestuin'
                            : 'Toevoegen aan Mijn moestuin',
                        icon: Icon(
                          inGarden
                              ? Icons.check_circle
                              : Icons.add_circle_outline,
                          color: inGarden ? cs.primary : cs.onSurfaceVariant,
                          size: 22,
                        ),
                        onPressed: onToggleGarden,
                      ),
                    Icon(
                      Icons.chevron_right,
                      size: 22,
                      color: cs.onSurfaceVariant.withValues(alpha: 0.65),
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (showDivider)
            Divider(
              height: 1,
              thickness: 1,
              color: cs.outlineVariant.withValues(alpha: 0.35),
            ),
        ],
      ),
    );
  }

  Widget _listLeading(BuildContext context) {
    final info = vegetableImageFor(vegetable.id);
    const side = 88.0;

    if (info.assetPath != null && info.transparentAsset) {
      return SizedBox(
        width: side,
        height: side,
        child: VegetableThumbnail(
          vegetable: vegetable,
          size: side,
        ),
      );
    }

    if (info.assetPath != null || info.imageUrl != null) {
      return VegetableThumbnail(
        vegetable: vegetable,
        size: side,
        borderRadius: 12,
      );
    }

    return SizedBox(
      width: side,
      height: side,
      child: Center(
        child: Text(
          info.emoji,
          style: const TextStyle(fontSize: 40),
        ),
      ),
    );
  }

  Color _seasonColor(ColorScheme cs, PlantingSeasonStatus status) {
    if (status.isSeasonEnded) return cs.onSurfaceVariant;
    switch (status.phase) {
      case PlantingSeasonPhase.activeNow:
        return cs.primary;
      case PlantingSeasonPhase.daysLeft:
      case PlantingSeasonPhase.startsSoon:
        return cs.tertiary;
      default:
        return cs.onSurfaceVariant;
    }
  }
}
