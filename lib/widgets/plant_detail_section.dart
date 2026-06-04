import 'package:flutter/material.dart';

import 'tuin_heading.dart';

/// Vaste horizontale marge voor de plant-detailpagina.
const double kPlantDetailPadding = 16;

/// Sectiekop op de plant-detailpagina.
class PlantDetailSectionHeader extends StatelessWidget {
  const PlantDetailSectionHeader({
    super.key,
    required this.title,
    this.icon,
  });

  final String title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        kPlantDetailPadding,
        20,
        kPlantDetailPadding,
        10,
      ),
      child: TuinHeading(
        title,
        icon: icon,
        fontSize: t.textTheme.titleMedium?.fontSize,
      ),
    );
  }
}

/// Inhoud in één kaart met gelijke padding.
class PlantDetailSectionCard extends StatelessWidget {
  const PlantDetailSectionCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(14),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: kPlantDetailPadding),
      child: Material(
        color: cs.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: cs.outlineVariant.withValues(alpha: 0.35),
          ),
        ),
        child: Padding(
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}

/// Label + waarde (geen extra uitklapper).
class PlantDetailFactRow extends StatelessWidget {
  const PlantDetailFactRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
  });

  final String label;
  final String value;
  final String? icon;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Text(icon!, style: const TextStyle(fontSize: 18, height: 1.3)),
            const SizedBox(width: 10),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: t.textTheme.labelMedium?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: t.textTheme.bodyMedium?.copyWith(height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
