import 'package:flutter/material.dart';

import '../data/garden_home_action_visual.dart';
import '../models/garden_plant_profile.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/home_moestuin_actions.dart';

/// Rij voor taken- of infolijsten (home + moestuin sheet).
class GardenHomeActionListTile extends StatelessWidget {
  const GardenHomeActionListTile({
    super.key,
    required this.action,
    required this.profile,
    required this.onTap,
    this.showChevron = true,
    this.compact = false,
    this.interactive = true,
  });

  final GardenHomeAction action;
  final GardenPlantProfile? profile;
  final VoidCallback onTap;
  final bool showChevron;
  final bool compact;
  final bool interactive;

  @override
  Widget build(BuildContext context) {
    final visual = gardenHomeActionVisual(action, profile);
    final scheduled = action.scheduled;

    final content = Padding(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 0 : 16,
        vertical: compact ? 10 : 14,
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: visual.color,
              shape: BoxShape.circle,
            ),
            child: Icon(visual.icon, size: 22, color: TuinierColors.card),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  visual.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 14 : 15,
                        height: 1.35,
                        color: TuinierColors.textPrimary,
                      ),
                ),
                if (compact && scheduled != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    action.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: TuinierColors.textSecondary,
                          height: 1.3,
                        ),
                  ),
                ],
              ],
            ),
          ),
          if (showChevron)
            const Icon(
              Icons.chevron_right,
              color: TuinierColors.iconMuted,
              size: 22,
            ),
        ],
      ),
    );

    if (!interactive) return content;

    return InkWell(
      onTap: onTap,
      child: content,
    );
  }
}
