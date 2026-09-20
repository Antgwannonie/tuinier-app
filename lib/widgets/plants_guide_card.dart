import 'package:flutter/material.dart';

import '../data/plant_guide_metrics.dart';
import '../models/vegetable.dart';
import '../theme/tuinier_colors.dart';
import 'vegetable_hero_image.dart';

enum PlantsGuideCardSize {
  featured,
  compact,
}

/// Fotokaart voor de Planten-tab (Plant Parent-stijl, tuinier-taal).
class PlantsGuideCard extends StatelessWidget {
  const PlantsGuideCard({
    super.key,
    required this.vegetable,
    required this.onTap,
    this.size = PlantsGuideCardSize.compact,
    this.seasonBadge,
    this.dimmed = false,
  });

  final Vegetable vegetable;
  final VoidCallback onTap;
  final PlantsGuideCardSize size;
  final String? seasonBadge;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final topicBadge = plantGuideTopicBadge(vegetable);
    final season = seasonBadge ?? plantGuideSeasonBadge(vegetable);
    final radius = size == PlantsGuideCardSize.featured ? 20.0 : 16.0;
    final height = size == PlantsGuideCardSize.featured ? 220.0 : null;

    return Opacity(
      opacity: dimmed ? 0.78 : 1,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Ink(
            height: height,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(radius),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  VegetableHeroImage(
                    vegetable: vegetable,
                    expand: true,
                    useAtlasIllustration: true,
                    borderRadius: BorderRadius.zero,
                  ),
                  if (dimmed)
                    Container(color: Colors.black.withValues(alpha: 0.22)),
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.55),
                            Colors.black.withValues(alpha: 0.82),
                          ],
                        ),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          size == PlantsGuideCardSize.featured ? 14 : 10,
                          28,
                          size == PlantsGuideCardSize.featured ? 14 : 10,
                          size == PlantsGuideCardSize.featured ? 14 : 12,
                        ),
                        child: Text(
                          vegetable.nameNl,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w800,
                            fontSize:
                                size == PlantsGuideCardSize.featured ? 20 : 15,
                            height: 1.15,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 10,
                    bottom: size == PlantsGuideCardSize.featured ? 52 : 44,
                    child: _PillBadge(
                      label: topicBadge,
                      background: Colors.black.withValues(alpha: 0.42),
                    ),
                  ),
                  if (season != null)
                    Positioned(
                      top: 10,
                      right: 10,
                      child: _PillBadge(
                        label: season,
                        background: const Color(0xFFFFF7ED),
                        foreground: const Color(0xFFC2410C),
                        icon: Icons.local_fire_department_rounded,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PillBadge extends StatelessWidget {
  const _PillBadge({
    required this.label,
    required this.background,
    this.foreground = Colors.white,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: foreground),
            const SizedBox(width: 3),
          ],
          Text(
            label,
            style: TextStyle(
              color: foreground,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

/// Sectiekop voor de plantengids.
class PlantsGuideSectionHeader extends StatelessWidget {
  const PlantsGuideSectionHeader({
    super.key,
    required this.title,
    required this.subtitle,
  });

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: TuinierColors.textPrimary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: TuinierColors.textSecondary,
                  height: 1.35,
                ),
          ),
        ],
      ),
    );
  }
}

/// Paginakop bovenaan de Planten-tab.
class PlantsGuidePageHeader extends StatelessWidget {
  const PlantsGuidePageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Plantengids',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: TuinierColors.headerDark,
                  height: 1.1,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Kennis voor een betere oogst',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: TuinierColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}
