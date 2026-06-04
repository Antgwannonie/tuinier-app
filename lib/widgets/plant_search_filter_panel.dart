import 'package:flutter/material.dart';

import '../data/plant_search_filters.dart';

/// Inklapbare filterblokken voor het zoekscherm (compact).
class PlantSearchFilterPanel extends StatelessWidget {
  const PlantSearchFilterPanel({
    super.key,
    required this.criteria,
    required this.onChanged,
  });

  final PlantSearchCriteria criteria;
  final ValueChanged<PlantSearchCriteria> onChanged;

  static const _browseOrder = [
    PlantBrowseKind.all,
    PlantBrowseKind.groente,
    PlantBrowseKind.companionGarden,
    PlantBrowseKind.flowersPlants,
    PlantBrowseKind.fruitTrees,
    PlantBrowseKind.herbs,
    PlantBrowseKind.legumes,
    PlantBrowseKind.mushrooms,
    PlantBrowseKind.other,
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Material(
      color: cs.surfaceContainerLowest.withValues(alpha: 0.4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _FilterSection(
            storageKey: const PageStorageKey<String>('filter_soort'),
            title: 'Soort',
            subtitle: criteria.browse == PlantBrowseKind.all
                ? null
                : criteria.browse.label,
            initiallyExpanded: false,
            child: _chipWrap(
              children: _browseOrder.map((kind) {
                return _FilterChip(
                  label: kind.emoji.isEmpty
                      ? kind.label
                      : '${kind.emoji} ${kind.label}',
                  selected: criteria.browse == kind,
                  onTap: () => onChanged(criteria.copyWith(browse: kind)),
                );
              }).toList(),
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withValues(alpha: 0.35)),
          _FilterSection(
            storageKey: const PageStorageKey<String>('filter_environment'),
            title: 'Standplaats & seizoen',
            subtitle: _environmentSubtitle(criteria),
            initiallyExpanded: false,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _miniLabel(context, 'Zon'),
                _chipWrap(
                  children: SunFilter.values.map((f) {
                    return _FilterChip(
                      label: '${f.emoji} ${f.label}',
                      selected: criteria.sunFilters.contains(f),
                      onTap: () => onChanged(
                        criteria.copyWith(
                          sunFilters: _toggle(criteria.sunFilters, f),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
                _miniLabel(context, 'Water'),
                _chipWrap(
                  children: WaterFilter.values.map((f) {
                    return _FilterChip(
                      label: '${f.emoji} ${f.label}',
                      selected: criteria.waterFilters.contains(f),
                      onTap: () => onChanged(
                        criteria.copyWith(
                          waterFilters: _toggle(criteria.waterFilters, f),
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 4),
                _miniLabel(context, 'Seizoen'),
                _chipWrap(
                  children: SeasonFilter.values.map((f) {
                    return _FilterChip(
                      label: '${f.emoji} ${f.label}',
                      selected: criteria.seasonFilters.contains(f),
                      onTap: () => onChanged(
                        criteria.copyWith(
                          seasonFilters: _toggle(criteria.seasonFilters, f),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static String? _environmentSubtitle(PlantSearchCriteria c) {
    final parts = <String>[];
    if (c.sunFilters.isNotEmpty) {
      parts.add(c.sunFilters.map((f) => f.label).join(', '));
    }
    if (c.waterFilters.isNotEmpty) {
      parts.add(c.waterFilters.map((f) => f.label).join(', '));
    }
    if (c.seasonFilters.isNotEmpty) {
      parts.add(c.seasonFilters.map((f) => f.label).join(', '));
    }
    return parts.isEmpty ? null : parts.join(' · ');
  }

  static Set<T> _toggle<T>(Set<T> current, T value) {
    final next = Set<T>.from(current);
    if (next.contains(value)) {
      next.remove(value);
    } else {
      next.add(value);
    }
    return next;
  }

  static Widget _miniLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
              fontSize: 11,
            ),
      ),
    );
  }

  static Widget _chipWrap({required List<Widget> children}) {
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: children,
    );
  }
}

class _FilterSection extends StatelessWidget {
  const _FilterSection({
    required this.storageKey,
    required this.title,
    required this.subtitle,
    required this.child,
    required this.initiallyExpanded,
  });

  final PageStorageKey<String> storageKey;
  final String title;
  final String? subtitle;
  final Widget child;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Theme(
      data: t.copyWith(
        dividerColor: Colors.transparent,
        visualDensity: VisualDensity.compact,
      ),
      child: ExpansionTile(
        key: storageKey,
        initiallyExpanded: initiallyExpanded,
        dense: true,
        visualDensity: VisualDensity.compact,
        tilePadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        collapsedShape: const Border(),
        shape: const Border(),
        childrenPadding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        iconColor: cs.onSurfaceVariant,
        collapsedIconColor: cs.onSurfaceVariant,
        title: Text(
          title,
          style: t.textTheme.labelLarge?.copyWith(
            fontWeight: FontWeight.w600,
            height: 1.1,
          ),
        ),
        subtitle: subtitle == null
            ? null
            : Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: t.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  height: 1.1,
                ),
              ),
        children: [child],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Material(
      color: selected
          ? cs.primaryContainer
          : cs.surfaceContainerHighest.withValues(alpha: 0.55),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Text(
            label,
            style: t.textTheme.labelSmall?.copyWith(
              fontSize: 12,
              fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              color: selected ? cs.onPrimaryContainer : cs.onSurfaceVariant,
              height: 1.1,
            ),
          ),
        ),
      ),
    );
  }
}
