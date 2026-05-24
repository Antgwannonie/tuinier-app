import 'package:flutter/material.dart';

import '../data/vegetable_groups.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../models/vegetable_group.dart';
import '../widgets/vegetable_thumbnail.dart';
import 'vegetable_detail_screen.dart';

class VegetableListScreen extends StatefulWidget {
  const VegetableListScreen({
    super.key,
    required this.repository,
    this.initialGroupId,
  });

  final VegetableRepository repository;

  /// Open direct op een verzameling (vanaf startpagina).
  final String? initialGroupId;

  @override
  State<VegetableListScreen> createState() => _VegetableListScreenState();
}

class _VegetableListScreenState extends State<VegetableListScreen> {
  final TextEditingController _search = TextEditingController();
  final ScrollController _listScroll = ScrollController();
  final ScrollController _groupScroll = ScrollController();

  late String? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _selectedGroupId = widget.initialGroupId;
  }

  VegetableGroup? get _activeGroup =>
      _selectedGroupId == null ? null : vegetableGroupById(_selectedGroupId!);

  List<Vegetable> get _plantsInActiveGroup {
    final group = _activeGroup;
    if (group == null) return const [];
    return widget.repository.inGroup(group);
  }

  List<Vegetable> get _visible {
    final pool = _activeGroup == null
        ? widget.repository.all
        : _plantsInActiveGroup;
    return pool.where((v) => v.matchesQuery(_search.text)).toList();
  }

  @override
  void dispose() {
    _search.dispose();
    _listScroll.dispose();
    _groupScroll.dispose();
    super.dispose();
  }

  void _selectGroup(String? groupId) {
    setState(() => _selectedGroupId = groupId);
    if (_listScroll.hasClients) _listScroll.jumpTo(0);
  }

  void _openDetail(Vegetable v) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => VegetableDetailScreen(vegetable: v),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final veggies = _visible;
    final t = Theme.of(context);
    final group = _activeGroup;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groentenatlas'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: Text(
              'Verzamelingen',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              controller: _groupScroll,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              itemCount: kVegetableGroups.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return FilterChip(
                    label: const Text('Alle'),
                    selected: _selectedGroupId == null,
                    onSelected: (_) => _selectGroup(null),
                  );
                }
                final g = kVegetableGroups[index - 1];
                final selected = _selectedGroupId == g.id;
                return FilterChip(
                  label: Text(g.nameNl),
                  selected: selected,
                  onSelected: (_) => _selectGroup(selected ? null : g.id),
                );
              },
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Zoek op naam of trefwoord…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
              textInputAction: TextInputAction.search,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              group == null
                  ? '${veggies.length} groente(n) in de atlas'
                  : '${veggies.length} soort(en) in ${group.nameNl}',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: veggies.isEmpty
                ? Center(
                    child: Text(
                      'Geen groenten gevonden',
                      style: t.textTheme.bodyLarge?.copyWith(
                        color: t.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  )
                : ListView.separated(
                    controller: _listScroll,
                    itemCount: veggies.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final v = veggies[i];
                      return ListTile(
                        leading: VegetableThumbnail(vegetable: v),
                        title: Text(v.nameNl),
                        subtitle: Text(
                          [
                            if (v.growthCategory != null) v.growthCategory!,
                            v.family,
                          ].join(' · '),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => _openDetail(v),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
