import 'package:flutter/material.dart';

import '../data/planting_season_status.dart';
import '../models/vegetable.dart';
import 'plant_detail_section.dart';

/// Teeltinfo in één kaart met duidelijke secties (geen dubbele uitklappers).
class VegetableInfoAccordion extends StatelessWidget {
  const VegetableInfoAccordion({
    super.key,
    required this.vegetable,
    this.seasonAdvice,
  });

  final Vegetable vegetable;
  final PlantingSeasonAdvice? seasonAdvice;

  static bool _hasText(String? value) {
    if (value == null) return false;
    final t = value.trim();
    return t.isNotEmpty && t != '—' && t != '-';
  }

  List<_InfoGroup> _groups() {
    final groups = <_InfoGroup>[
      _InfoGroup(
        title: 'Zaaien & oogsten',
        icon: Icons.eco_outlined,
        items: [
          if (_hasText(vegetable.sowingIndoors))
            _InfoItem('Zaaien binnen / kas', vegetable.sowingIndoors),
          if (_hasText(vegetable.sowingOutdoors))
            _InfoItem('Zaaien buiten', vegetable.sowingOutdoors),
          if (_hasText(vegetable.transplant))
            _InfoItem('Planten / verplanten', vegetable.transplant),
          if (_hasText(vegetable.harvest))
            _InfoItem('Oogst', vegetable.harvest),
          if (_hasText(vegetable.cropDuration))
            _InfoItem('Groeitijd', vegetable.cropDuration!),
        ],
      ),
      _InfoGroup(
        title: 'Standplaats',
        icon: Icons.wb_sunny_outlined,
        items: [
          _InfoItem(
            'Afstand',
            '${vegetable.spacingCm} cm tussen planten · '
            '${vegetable.rowSpacingCm} cm tussen rijen',
          ),
          if (_hasText(vegetable.sunRequirement))
            _InfoItem('Licht', vegetable.sunRequirement),
          if (_hasText(vegetable.water))
            _InfoItem('Water', vegetable.water),
          if (_hasText(vegetable.soilAndFood))
            _InfoItem('Bodem & voeding', vegetable.soilAndFood),
        ],
      ),
      _InfoGroup(
        title: 'Verzorging',
        icon: Icons.agriculture_outlined,
        items: [
          if (_hasText(vegetable.care))
            _InfoItem('Verzorging', vegetable.care),
          if (_hasText(vegetable.harvestTips))
            _InfoItem('Oogsttips', vegetable.harvestTips),
        ],
      ),
      _InfoGroup(
        title: 'Plagen & aandachtspunten',
        icon: Icons.bug_report_outlined,
        items: [
          if (_hasText(vegetable.commonIssues))
            _InfoItem('Let op', vegetable.commonIssues),
        ],
      ),
      if (_hasText(vegetable.summary))
        _InfoGroup(
          title: 'Volledige omschrijving',
          icon: Icons.description_outlined,
          items: [_InfoItem('Over de plant', vegetable.summary)],
        ),
    ];
    return groups.where((g) => g.items.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups();
    if (groups.isEmpty) return const SizedBox.shrink();

    return PlantDetailSectionCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < groups.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: Theme.of(context)
                    .colorScheme
                    .outlineVariant
                    .withValues(alpha: 0.35),
              ),
            _InfoGroupTile(
              group: groups[i],
              initiallyExpanded: false,
              seasonLines: groups[i].title == 'Zaaien & oogsten'
                  ? seasonAdvice?.accordionLines
                  : null,
              seasonEnded: seasonAdvice?.isSeasonEnded ?? false,
            ),
          ],
        ],
      ),
    );
  }
}

class _InfoGroup {
  const _InfoGroup({
    required this.title,
    required this.icon,
    required this.items,
  });

  final String title;
  final IconData icon;
  final List<_InfoItem> items;
}

class _InfoItem {
  const _InfoItem(this.title, this.body);
  final String title;
  final String body;
}

class _InfoGroupTile extends StatefulWidget {
  const _InfoGroupTile({
    required this.group,
    required this.initiallyExpanded,
    this.seasonLines,
    this.seasonEnded = false,
  });

  final _InfoGroup group;
  final bool initiallyExpanded;
  final List<String>? seasonLines;
  final bool seasonEnded;

  @override
  State<_InfoGroupTile> createState() => _InfoGroupTileState();
}

class _InfoGroupTileState extends State<_InfoGroupTile> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Theme(
      data: t.copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        initiallyExpanded: widget.initiallyExpanded,
        onExpansionChanged: (v) => setState(() => _expanded = v),
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
        leading: Icon(widget.group.icon, color: cs.primary, size: 22),
        title: Text(
          widget.group.title,
          style: t.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
        ),
        subtitle: _expanded
            ? null
            : Text(
                '${widget.group.items.length} punten',
                style: t.textTheme.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                ),
              ),
        children: [
          if (widget.seasonLines != null && widget.seasonLines!.isNotEmpty) ...[
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: cs.primaryContainer.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Seizoen nu',
                    style: t.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: widget.seasonEnded
                          ? cs.onSurfaceVariant
                          : cs.primary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  ...widget.seasonLines!.map(
                    (line) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        line,
                        style: t.textTheme.bodySmall?.copyWith(height: 1.35),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          for (final item in widget.group.items)
            PlantDetailFactRow(label: item.title, value: item.body),
        ],
      ),
    );
  }
}
