import 'package:flutter/material.dart';

import '../data/garden_notifications_sync.dart';
import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../widgets/add_plant_setup_sheet.dart';
import '../data/vegetable_groups.dart';
import '../data/vegetable_repository.dart';
import '../models/vegetable.dart';
import '../models/vegetable_group.dart';
import '../widgets/vegetable_thumbnail.dart';

class AddVegetableScreen extends StatefulWidget {
  const AddVegetableScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.profileStore,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;

  @override
  State<AddVegetableScreen> createState() => _AddVegetableScreenState();
}

class _AddVegetableScreenState extends State<AddVegetableScreen> {
  final TextEditingController _search = TextEditingController();
  String? _groupId;

  @override
  void initState() {
    super.initState();
    widget.gardenStore.addListener(_refresh);
  }

  @override
  void dispose() {
    widget.gardenStore.removeListener(_refresh);
    _search.dispose();
    super.dispose();
  }

  void _refresh() => setState(() {});

  VegetableGroup? get _group =>
      _groupId == null ? null : vegetableGroupById(_groupId!);

  List<Vegetable> get _available {
    Iterable<Vegetable> pool;
    final group = _group;
    if (group != null) {
      pool = widget.repository.inGroup(group);
    } else {
      pool = widget.repository.all;
    }

    final q = _search.text.trim();
    return pool
        .where((v) => !widget.gardenStore.contains(v.id))
        .where((v) => q.isEmpty || v.matchesQuery(q))
        .toList();
  }

  Future<void> _add(Vegetable v) async {
    final setup = await showAddPlantSetupSheet(
      context,
      vegetableName: v.nameNl,
    );
    if (setup == null || !mounted) return;

    await widget.gardenStore.add(v.id);
    await widget.profileStore.ensureProfile(
      v.id,
      plantedAt: setup.plantedAt,
      location: setup.location,
      sunLevel: setup.sunLevel,
      isPlanted: setup.isPlanted,
    );
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${v.nameNl} toegevoegd — planning op jouw situatie'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final list = _available;
    final group = _group;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Groente toevoegen'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              'Verzameling',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: const Text('Alle'),
                    selected: _groupId == null,
                    onSelected: (_) => setState(() => _groupId = null),
                  ),
                ),
                ...kVegetableGroups.map((g) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(g.nameNl),
                      selected: _groupId == g.id,
                      onSelected: (_) =>
                          setState(() => _groupId = _groupId == g.id ? null : g.id),
                    ),
                  );
                }),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Zoek binnen ${group?.nameNl ?? "alle groenten"}…',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                isDense: true,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              '${list.length} om toe te voegen',
              style: t.textTheme.labelLarge?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(
                        group != null
                            ? 'Geen groenten meer in ${group.nameNl} om toe te voegen, '
                                'of alles staat al in jouw lijst.'
                            : 'Alles staat al in jouw lijst of geen zoekresultaat.',
                        textAlign: TextAlign.center,
                        style: t.textTheme.bodyLarge,
                      ),
                    ),
                  )
                : ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final v = list[i];
                      return ListTile(
                        leading: VegetableThumbnail(vegetable: v),
                        title: Text(v.nameNl),
                        subtitle: Text(v.family),
                        trailing: IconButton(
                          icon: const Icon(Icons.add_circle),
                          color: t.colorScheme.primary,
                          tooltip: 'Toevoegen',
                          onPressed: () => _add(v),
                        ),
                        onTap: () => _add(v),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.check),
        label: const Text('Klaar'),
      ),
    );
  }
}
