import 'package:flutter/material.dart';

import '../data/planting_season_status.dart';
import '../data/vegetable_image_info.dart';
import '../models/vegetable.dart';
import 'vegetable_hero_image.dart';

/// Plantkaart in atlas — 2 kolommen (Zoeken-tab).
class AtlasPlantCard extends StatelessWidget {
  const AtlasPlantCard({
    super.key,
    required this.vegetable,
    required this.inGarden,
    this.awaitingPlant = false,
    this.seasonStatus,
    required this.onOpenDetail,
    this.onToggleGarden,
    this.onMarkPlanted,
  });

  final Vegetable vegetable;
  final bool inGarden;
  final bool awaitingPlant;
  final PlantingSeasonStatus? seasonStatus;
  final VoidCallback onOpenDetail;
  final VoidCallback? onToggleGarden;
  final VoidCallback? onMarkPlanted;

  bool get _freeAtlasIcon {
    final info = vegetableImageFor(vegetable.id);
    return info.transparentAsset && info.assetPath != null;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    final ended = seasonStatus?.isSeasonEnded ?? false;
    final seasonLabel = seasonStatus != null &&
            seasonStatus!.phase != PlantingSeasonPhase.noCalendar &&
            seasonStatus!.label.isNotEmpty
        ? seasonStatus!.label
        : null;
    final freeIcon = _freeAtlasIcon && !ended;

    final card = Material(
      color: cs.surfaceContainerLow,
      elevation: ended ? 0 : 1,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: freeIcon ? Clip.none : Clip.antiAlias,
      child: InkWell(
        onTap: onOpenDetail,
        borderRadius: BorderRadius.circular(16),
        child: freeIcon
            ? _freeIconBody(context, t, cs, seasonLabel)
            : _classicBody(context, t, cs, ended, seasonLabel),
      ),
    );

    return Opacity(
      opacity: ended ? 0.72 : 1,
      child: card,
    );
  }

  /// Atlas-icoon: één vrij beeldvlak, tekst op gradient (geen aparte hoeken).
  Widget _freeIconBody(
    BuildContext context,
    ThemeData t,
    ColorScheme cs,
    String? seasonLabel,
  ) {
    return Stack(
        clipBehavior: Clip.none,
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: VegetableHeroImage(
              vegetable: vegetable,
              expand: true,
              borderRadius: BorderRadius.zero,
              useAtlasIllustration: true,
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(16),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.35, 1.0],
                  colors: [
                    Colors.transparent,
                    Colors.black.withValues(alpha: 0.35),
                    Colors.black.withValues(alpha: 0.78),
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  10,
                  28,
                  10,
                  seasonLabel != null ? 8 : 12,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      vegetable.nameNl,
                      style: t.textTheme.titleSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        height: 1.15,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (seasonLabel != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              seasonLabel,
                              style: t.textTheme.labelSmall?.copyWith(
                                color: _seasonLabelColor(cs, seasonStatus!),
                                fontWeight: FontWeight.w600,
                                height: 1.2,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Icon(
                            Icons.chevron_right,
                            size: 18,
                            color: cs.primary,
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
          if (onToggleGarden != null || onMarkPlanted != null)
            Positioned(
              top: 8,
              right: 8,
              child: _gardenButton(cs),
            ),
        ],
    );
  }

  Widget _classicBody(
    BuildContext context,
    ThemeData t,
    ColorScheme cs,
    bool ended,
    String? seasonLabel,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (ended)
                ColorFiltered(
                  colorFilter: const ColorFilter.matrix(<double>[
                    0.35, 0.45, 0.2, 0, 0,
                    0.35, 0.45, 0.2, 0, 0,
                    0.35, 0.45, 0.2, 0, 0,
                    0, 0, 0, 1, 0,
                  ]),
                  child: VegetableHeroImage(
                    vegetable: vegetable,
                    expand: true,
                    borderRadius: BorderRadius.zero,
                    useAtlasIllustration: true,
                  ),
                )
              else
                VegetableHeroImage(
                  vegetable: vegetable,
                  expand: true,
                  borderRadius: BorderRadius.zero,
                  useAtlasIllustration: true,
                ),
              if (ended)
                Container(
                  color: Colors.black.withValues(alpha: 0.35),
                ),
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withValues(alpha: ended ? 0.75 : 0.65),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(10, 20, 10, 8),
                  child: Text(
                    vegetable.nameNl,
                    style: t.textTheme.titleSmall?.copyWith(
                      color: ended
                          ? Colors.white.withValues(alpha: 0.88)
                          : Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              if (onToggleGarden != null || onMarkPlanted != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: _gardenButton(cs),
                ),
            ],
          ),
        ),
        if (seasonLabel != null)
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    seasonLabel,
                    style: t.textTheme.labelSmall?.copyWith(
                      color: ended
                          ? cs.onSurfaceVariant.withValues(alpha: 0.75)
                          : _seasonLabelColor(cs, seasonStatus!),
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  size: 18,
                  color: ended
                      ? cs.onSurfaceVariant.withValues(alpha: 0.5)
                      : cs.primary,
                ),
              ],
            ),
          )
        else
          const Padding(
            padding: EdgeInsets.only(bottom: 8),
          ),
      ],
    );
  }

  Widget _gardenButton(ColorScheme cs) {
    return Material(
      color: awaitingPlant
          ? cs.tertiaryContainer
          : inGarden
              ? cs.primary
              : Colors.black.withValues(alpha: 0.45),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: awaitingPlant ? onMarkPlanted : onToggleGarden,
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: Icon(
            awaitingPlant || inGarden ? Icons.yard : Icons.add,
            size: 22,
            color: awaitingPlant
                ? cs.onTertiaryContainer
                : inGarden
                    ? cs.onPrimary
                    : Colors.white,
          ),
        ),
      ),
    );
  }

  Color _seasonLabelColor(ColorScheme cs, PlantingSeasonStatus status) {
    if (status.isSeasonEnded) {
      return cs.onSurfaceVariant.withValues(alpha: 0.75);
    }
    if (status.phase == PlantingSeasonPhase.activeNow ||
        status.phase == PlantingSeasonPhase.daysLeft) {
      return cs.primary;
    }
    return cs.onSurfaceVariant;
  }
}
