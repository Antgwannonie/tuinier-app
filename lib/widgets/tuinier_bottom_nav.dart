import 'package:flutter/material.dart';

/// Ondernavigatie met opvallende AI-scan in het midden.
class TuinierBottomNav extends StatelessWidget {
  const TuinierBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;

  static const int tabHome = 0;
  static const int tabNotes = 1;
  static const int tabScan = 2;
  static const int tabSearch = 3;
  static const int tabWeather = 4;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surface,
      elevation: 8,
      shadowColor: cs.shadow.withValues(alpha: 0.12),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _SideNavItem(
                icon: Icons.yard_outlined,
                selectedIcon: Icons.yard,
                label: 'Moestuin',
                selected: selectedIndex == tabHome,
                onTap: () => onSelected(tabHome),
              ),
              _SideNavItem(
                icon: Icons.edit_note_outlined,
                selectedIcon: Icons.edit_note,
                label: 'Notities',
                selected: selectedIndex == tabNotes,
                onTap: () => onSelected(tabNotes),
              ),
              _CenterScanNavItem(
                selected: selectedIndex == tabScan,
                onTap: () => onSelected(tabScan),
              ),
              _SideNavItem(
                icon: Icons.search_outlined,
                selectedIcon: Icons.search,
                label: 'Zoeken',
                selected: selectedIndex == tabSearch,
                onTap: () => onSelected(tabSearch),
              ),
              _SideNavItem(
                icon: Icons.cloud_outlined,
                selectedIcon: Icons.cloud,
                label: 'Weer',
                selected: selectedIndex == tabWeather,
                onTap: () => onSelected(tabWeather),
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
    final cs = t.colorScheme;
    final color = selected ? cs.primary : cs.onSurfaceVariant;

    return Expanded(
      child: InkWell(
        onTap: onTap,
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
              ),
            ),
          ],
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
    final cs = t.colorScheme;
    final iconColor = selected ? cs.primary : cs.onSurfaceVariant;
    final borderColor = selected ? cs.primary : cs.outline.withValues(alpha: 0.65);
    final fillColor = selected
        ? cs.primaryContainer.withValues(alpha: 0.85)
        : cs.surfaceContainerHighest.withValues(alpha: 0.95);

    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: fillColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: borderColor,
                  width: selected ? 3 : 2.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: selected
                        ? cs.primary.withValues(alpha: 0.18)
                        : cs.shadow.withValues(alpha: 0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                selected
                    ? Icons.photo_camera
                    : Icons.photo_camera_outlined,
                size: 26,
                color: iconColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'AI-scan',
              maxLines: 1,
              style: t.textTheme.labelSmall?.copyWith(
                color: iconColor,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
