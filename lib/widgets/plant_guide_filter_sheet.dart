import 'package:flutter/material.dart';

import '../data/plant_search_filters.dart';
import '../theme/tuinier_colors.dart';

/// Opent het filterpaneel voor de plantengids.
Future<PlantSearchCriteria?> showPlantGuideFilterSheet({
  required BuildContext context,
  required PlantSearchCriteria initial,
}) {
  return showModalBottomSheet<PlantSearchCriteria>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => PlantGuideFilterSheet(initial: initial),
  );
}

class PlantGuideFilterSheet extends StatefulWidget {
  const PlantGuideFilterSheet({super.key, required this.initial});

  final PlantSearchCriteria initial;

  @override
  State<PlantGuideFilterSheet> createState() => _PlantGuideFilterSheetState();
}

class _PlantGuideFilterSheetState extends State<PlantGuideFilterSheet> {
  late PlantSearchCriteria _criteria = widget.initial;

  void _apply() => Navigator.of(context).pop(_criteria);

  void _clear() => setState(() => _criteria = const PlantSearchCriteria());

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;

    return SizedBox(
      height: maxH,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                  tooltip: 'Sluiten',
                ),
                Expanded(
                  child: Text(
                    'Filters',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
                TextButton(
                  onPressed: _criteria.hasActiveFilters ? _clear : null,
                  child: const Text('Wis alles'),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 16 + bottom),
              child: PlantGuideFilterSections(
                criteria: _criteria,
                onChanged: (next) => setState(() => _criteria = next),
              ),
            ),
          ),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _apply,
                  style: FilledButton.styleFrom(
                    backgroundColor: TuinierColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _criteria.hasActiveFilters
                        ? 'Toon resultaten (${_criteria.activeFilterCount} filters)'
                        : 'Toon alle gewassen',
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Gedeelde filtersecties (plantengids + toevoeg-scherm).
class PlantGuideFilterSections extends StatelessWidget {
  const PlantGuideFilterSections({
    super.key,
    required this.criteria,
    required this.onChanged,
  });

  final PlantSearchCriteria criteria;
  final ValueChanged<PlantSearchCriteria> onChanged;

  static const _browseOrder = [
    PlantBrowseKind.all,
    PlantBrowseKind.groente,
    PlantBrowseKind.legumes,
    PlantBrowseKind.herbs,
    PlantBrowseKind.flowersPlants,
    PlantBrowseKind.companionGarden,
    PlantBrowseKind.fruitTrees,
    PlantBrowseKind.mushrooms,
    PlantBrowseKind.other,
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _sectionTitle(context, 'Verzamelgroepen'),
        _sectionHint(context, 'Tomaten, bonen, wortelen, kolen…'),
        _chipWrap(
          children: [
            for (final groupId in kPlantGuideVegetableGroupFilterOrder)
              if (vegetableGroupByIdForFilter(groupId) != null)
                _FilterChip(
                  label: _groupChipLabel(groupId),
                  selected: criteria.vegetableGroupIds.contains(groupId),
                  onTap: () => onChanged(
                    criteria.copyWith(
                      vegetableGroupIds: _toggle(
                        criteria.vegetableGroupIds,
                        groupId,
                      ),
                    ),
                  ),
                ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Categorie'),
        _chipWrap(
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
        const SizedBox(height: 16),
        _sectionTitle(context, 'Standplaats'),
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
        const SizedBox(height: 8),
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
        const SizedBox(height: 16),
        _sectionTitle(context, 'Groei & oogst'),
        _sectionHint(
          context,
          'Kies planten die ongeveer even snel klaar zijn vanaf zaad',
        ),
        _chipWrap(
          children: [
            ...PlantHabitFilter.values.map((f) {
              return _FilterChip(
                label: '${f.emoji} ${f.label}',
                selected: criteria.habitFilters.contains(f),
                onTap: () => onChanged(
                  criteria.copyWith(
                    habitFilters: _toggle(criteria.habitFilters, f),
                  ),
                ),
              );
            }),
            ...PlantGrowthSpeedFilter.values.map((f) {
              return _FilterChip(
                label: '${f.emoji} ${f.label}',
                selected: criteria.growthSpeedFilters.contains(f),
                onTap: () => onChanged(
                  criteria.copyWith(
                    growthSpeedFilters: _toggle(
                      criteria.growthSpeedFilters,
                      f,
                    ),
                  ),
                ),
              );
            }),
            ...PlantHarvestLocationFilter.values.map((f) {
              return _FilterChip(
                label: '${f.emoji} ${f.label}',
                selected: criteria.harvestLocationFilters.contains(f),
                onTap: () => onChanged(
                  criteria.copyWith(
                    harvestLocationFilters: _toggle(
                      criteria.harvestLocationFilters,
                      f,
                    ),
                  ),
                ),
              );
            }),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Zaaimaand'),
        _sectionHint(
          context,
          'Zet planten met dezelfde zaaimaand bij elkaar in één bak',
        ),
        _chipWrap(
          children: [
            for (var m = 1; m <= 12; m++)
              _FilterChip(
                label: kSowingMonthShortLabels[m],
                selected: criteria.sowingMonthFilters.contains(m),
                onTap: () => onChanged(
                  criteria.copyWith(
                    sowingMonthFilters: _toggle(criteria.sowingMonthFilters, m),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Plantafstand'),
        _sectionHint(context, 'Handig voor hoeveel planten in je bak passen'),
        _chipWrap(
          children: SpacingFilter.values.map((f) {
            return _FilterChip(
              label: '${f.emoji} ${f.label}',
              selected: criteria.spacingFilters.contains(f),
              onTap: () => onChanged(
                criteria.copyWith(
                  spacingFilters: _toggle(criteria.spacingFilters, f),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        _sectionTitle(context, 'Seizoen & bloemen'),
        _chipWrap(
          children: [
            ...SeasonFilter.values.map((f) {
              return _FilterChip(
                label: '${f.emoji} ${f.label}',
                selected: criteria.seasonFilters.contains(f),
                onTap: () => onChanged(
                  criteria.copyWith(
                    seasonFilters: _toggle(criteria.seasonFilters, f),
                  ),
                ),
              );
            }),
            _FilterChip(
              label: '🌼 Bloemen',
              selected: criteria.flowersOnly,
              onTap: () => onChanged(
                criteria.copyWith(flowersOnly: !criteria.flowersOnly),
              ),
            ),
          ],
        ),
      ],
    );
  }

  static String _groupChipLabel(String groupId) {
    final group = vegetableGroupByIdForFilter(groupId);
    if (group == null) return groupId;
    final emoji = kVegetableGroupFilterEmojis[groupId] ?? '🌱';
    return '$emoji ${group.nameNl}';
  }

  static Widget _sectionTitle(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }

  static Widget _sectionHint(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: TuinierColors.textSecondary,
            ),
      ),
    );
  }

  static Widget _miniLabel(BuildContext context, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: TuinierColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }

  static Widget _chipWrap({required List<Widget> children}) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: children,
    );
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
    return FilterChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      onSelected: (_) => onTap(),
      selectedColor: TuinierColors.primary.withValues(alpha: 0.14),
      checkmarkColor: TuinierColors.primary,
      labelStyle: TextStyle(
        fontSize: 13,
        fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
        color: selected ? TuinierColors.primary : TuinierColors.textPrimary,
      ),
      side: BorderSide(
        color: selected ? TuinierColors.primary : TuinierColors.border,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}
