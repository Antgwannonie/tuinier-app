import 'package:flutter/material.dart';

import '../models/vegetable.dart';

/// Groepen met uitklapbare teeltinformatie per groente.
class VegetableInfoAccordion extends StatelessWidget {
  const VegetableInfoAccordion({
    super.key,
    required this.vegetable,
    this.initiallyExpandedGroupIndex = 0,
  });

  final Vegetable vegetable;
  final int initiallyExpandedGroupIndex;

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
            _InfoItem('Oogstperiode', vegetable.harvest),
          if (_hasText(vegetable.cropDuration))
            _InfoItem('Groeitijd (indicatie)', vegetable.cropDuration!),
        ],
      ),
      _InfoGroup(
        title: 'Afstand & omstandigheden',
        icon: Icons.wb_sunny_outlined,
        items: [
          _InfoItem(
            'Afstand (plant × rij)',
            '${vegetable.spacingCm} cm × ${vegetable.rowSpacingCm} cm tussen de rijen',
          ),
          if (_hasText(vegetable.sunRequirement))
            _InfoItem('Licht', vegetable.sunRequirement),
          if (_hasText(vegetable.water))
            _InfoItem('Water', vegetable.water),
          if (_hasText(vegetable.soilAndFood))
            _InfoItem('Bodem & bemesting', vegetable.soilAndFood),
        ],
      ),
      _InfoGroup(
        title: 'Verzorging & oogst',
        icon: Icons.agriculture_outlined,
        items: [
          if (_hasText(vegetable.care))
            _InfoItem('Verzorging', vegetable.care),
          if (_hasText(vegetable.harvestTips))
            _InfoItem('Oogsttips', vegetable.harvestTips),
        ],
      ),
      _InfoGroup(
        title: 'Ziektes & plagen',
        icon: Icons.bug_report_outlined,
        items: [
          if (_hasText(vegetable.commonIssues))
            _InfoItem('Waar op letten', vegetable.commonIssues),
        ],
      ),
    ];
    return groups.where((g) => g.items.isNotEmpty).toList();
  }

  @override
  Widget build(BuildContext context) {
    final groups = _groups();
    if (groups.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < groups.length; i++)
          _CollapsibleGroup(
            group: groups[i],
            initiallyExpanded: i == initiallyExpandedGroupIndex,
          ),
      ],
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

class _CollapsibleGroup extends StatefulWidget {
  const _CollapsibleGroup({
    required this.group,
    required this.initiallyExpanded,
  });

  final _InfoGroup group;
  final bool initiallyExpanded;

  @override
  State<_CollapsibleGroup> createState() => _CollapsibleGroupState();
}

class _CollapsibleGroupState extends State<_CollapsibleGroup> {
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

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: cs.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 8, 14),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: cs.primaryContainer,
                      child: Icon(
                        widget.group.icon,
                        size: 22,
                        color: cs.onPrimaryContainer,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.group.title,
                            style: t.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${widget.group.items.length} onderdeel(en)',
                            style: t.textTheme.labelMedium?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    AnimatedRotation(
                      turns: _expanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.expand_more,
                        color: cs.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _expanded
                  ? Column(
                      children: [
                        Divider(
                          height: 1,
                          color: cs.outlineVariant.withValues(alpha: 0.5),
                        ),
                        for (var i = 0; i < widget.group.items.length; i++) ...[
                          _InfoTile(item: widget.group.items[i]),
                          if (i < widget.group.items.length - 1)
                            Divider(
                              height: 1,
                              indent: 16,
                              endIndent: 16,
                              color: cs.outlineVariant.withValues(alpha: 0.35),
                            ),
                        ],
                        const SizedBox(height: 4),
                      ],
                    )
                  : const SizedBox(width: double.infinity, height: 0),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatefulWidget {
  const _InfoTile({required this.item});

  final _InfoItem item;

  @override
  State<_InfoTile> createState() => _InfoTileState();
}

class _InfoTileState extends State<_InfoTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final cs = t.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.item.title,
                    style: t.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: cs.primary,
                    ),
                  ),
                ),
                Icon(
                  _open ? Icons.remove_circle_outline : Icons.add_circle_outline,
                  size: 22,
                  color: cs.primary,
                ),
              ],
            ),
          ),
        ),
        AnimatedSize(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  child: Text(
                    widget.item.body,
                    style: t.textTheme.bodyLarge?.copyWith(height: 1.45),
                  ),
                )
              : const SizedBox(width: double.infinity, height: 0),
        ),
      ],
    );
  }
}
