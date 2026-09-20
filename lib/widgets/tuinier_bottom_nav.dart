import 'package:flutter/material.dart';

import '../theme/tuinier_colors.dart';
import '../theme/tuinier_decorations.dart';

/// Ondernavigatie: Home | Moestuin | Scan | Planner | Planten.
class TuinierBottomNav extends StatelessWidget {
  const TuinierBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const int tabDashboard = 0;
  static const int tabMoestuin = 1;
  static const int tabScan = 2;
  static const int tabPlanner = 3;
  static const int tabPlants = 4;

  static const int tabInsight = tabPlants;

  static const int tabHome = tabDashboard;
  static const int tabNotes = tabPlanner;
  static const int tabSearch = tabMoestuin;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: TuinierDecorations.bottomNavBorder(),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 8, 4, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _SideNavItem(
                icon: Icons.home_outlined,
                selectedIcon: Icons.home,
                label: 'Home',
                selected: selectedIndex == tabDashboard,
                onTap: () => onSelected(tabDashboard),
              ),
              _SideNavItem(
                icon: Icons.yard_outlined,
                selectedIcon: Icons.yard,
                label: 'Moestuin',
                selected: selectedIndex == tabMoestuin,
                onTap: () => onSelected(tabMoestuin),
              ),
              _CenterScanNavItem(
                selected: selectedIndex == tabScan,
                onTap: () => onSelected(tabScan),
              ),
              _SideNavItem(
                icon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month,
                label: 'Planner',
                selected: selectedIndex == tabPlanner,
                onTap: () => onSelected(tabPlanner),
              ),
              _SideNavItem(
                icon: Icons.local_florist_outlined,
                selectedIcon: Icons.local_florist,
                label: 'Planten',
                selected: selectedIndex == tabPlants,
                onTap: () => onSelected(tabPlants),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SideNavItem extends StatelessWidget {
  const _SideNavItem({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final color = selected ? TuinierColors.primary : TuinierColors.iconMuted;

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(selected ? selectedIcon : icon, color: color, size: 24),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                  height: 1.1,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CenterScanNavItem extends StatelessWidget {
  const _CenterScanNavItem({
    required this.selected,
    required this.onTap,
  });

  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return Expanded(
      child: Transform.translate(
        offset: const Offset(0, -12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: TuinierColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TuinierColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: selected
                        ? TuinierColors.card.withValues(alpha: 0.5)
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
                child: const Icon(
                  Icons.photo_camera_outlined,
                  size: 28,
                  color: TuinierColors.card,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Scan',
                style: t.textTheme.labelSmall?.copyWith(
                  color: selected
                      ? TuinierColors.primary
                      : TuinierColors.iconMuted,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
