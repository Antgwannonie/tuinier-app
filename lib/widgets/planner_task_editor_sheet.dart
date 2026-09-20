import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../models/garden_planner_task.dart';
import '../theme/tuinier_colors.dart';
import 'vegetable_thumbnail.dart';

Future<GardenPlannerTask?> showPlannerTaskEditor({
  required BuildContext context,
  required VegetableRepository repository,
  required MyGardenStore gardenStore,
  GardenPlannerTask? existing,
  DateTime? initialDate,
}) {
  return showModalBottomSheet<GardenPlannerTask>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    backgroundColor: Theme.of(context).colorScheme.surface,
    builder: (ctx) => _PlannerTaskEditorSheet(
      repository: repository,
      gardenStore: gardenStore,
      existing: existing,
      initialDate: initialDate,
    ),
  );
}

class _PlannerTaskEditorSheet extends StatefulWidget {
  const _PlannerTaskEditorSheet({
    required this.repository,
    required this.gardenStore,
    this.existing,
    this.initialDate,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenPlannerTask? existing;
  final DateTime? initialDate;

  @override
  State<_PlannerTaskEditorSheet> createState() =>
      _PlannerTaskEditorSheetState();
}

class _PlannerTaskEditorSheetState extends State<_PlannerTaskEditorSheet> {
  late final TextEditingController _titleCtrl;
  late final TextEditingController _bodyCtrl;
  late DateTime _dueDate;
  late GardenPlannerTaskPriority _priority;
  late bool _forPlant;
  String? _vegetableId;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _titleCtrl = TextEditingController(text: widget.existing?.title ?? '');
    _bodyCtrl = TextEditingController(text: widget.existing?.body ?? '');
    _dueDate = widget.existing?.dueDateOnly ??
        widget.initialDate ??
        DateTime(now.year, now.month, now.day);
    _priority = widget.existing?.priority ?? GardenPlannerTaskPriority.medium;
    _forPlant = widget.existing?.vegetableId != null;
    _vegetableId = widget.existing?.vegetableId;
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _bodyCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  void _save() {
    final title = _titleCtrl.text.trim();
    if (title.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Geef de taak een titel')),
      );
      return;
    }
    if (_forPlant && (_vegetableId == null || _vegetableId!.isEmpty)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Kies een plant of schakel over op algemene tuin')),
      );
      return;
    }

    final task = GardenPlannerTask(
      id: widget.existing?.id ??
          'task_${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(9999)}',
      title: title,
      body: _bodyCtrl.text.trim(),
      dueDate: _dueDate,
      vegetableId: _forPlant ? _vegetableId : null,
      priority: _priority,
      completed: widget.existing?.completed ?? false,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    Navigator.pop(context, task);
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);
    final gardenPlants = [
      for (final id in widget.gardenStore.ids)
        if (widget.repository.byId(id) case final v?) v,
    ];
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              widget.existing == null
                  ? 'Tuin taak plannen'
                  : 'Taak bewerken',
              style: t.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Plan iets voor een plant of voor je algemene tuin.',
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _titleCtrl,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Titel',
                hintText: 'Bijv. Tomaten water geven',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyCtrl,
              minLines: 2,
              maxLines: 4,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Details (optioneel)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.event_outlined),
              title: const Text('Datum'),
              subtitle: Text(
                '${_dueDate.day}-${_dueDate.month}-${_dueDate.year}',
              ),
              trailing: TextButton(
                onPressed: _pickDate,
                child: const Text('Kies'),
              ),
            ),
            const SizedBox(height: 8),
            Text('Prioriteit', style: t.textTheme.titleSmall),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              children: GardenPlannerTaskPriority.values.map((p) {
                final selected = _priority == p;
                return ChoiceChip(
                  label: Text(p.label),
                  selected: selected,
                  onSelected: (_) => setState(() => _priority = p),
                );
              }).toList(),
            ),
            const SizedBox(height: 14),
            Text('Voor wie?', style: t.textTheme.titleSmall),
            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Algemene tuin'),
              subtitle: const Text('Niet gekoppeld aan één plant'),
              value: false,
              groupValue: _forPlant,
              onChanged: (v) => setState(() {
                _forPlant = v ?? false;
                if (!_forPlant) _vegetableId = null;
              }),
            ),
            RadioListTile<bool>(
              contentPadding: EdgeInsets.zero,
              title: const Text('Bepaalde plant'),
              subtitle: Text(
                gardenPlants.isEmpty
                    ? 'Voeg eerst planten toe in Moestuin'
                    : 'Kies uit je moestuin',
              ),
              value: true,
              groupValue: _forPlant,
              onChanged: gardenPlants.isEmpty
                  ? null
                  : (v) => setState(() => _forPlant = v ?? true),
            ),
            if (_forPlant && gardenPlants.isNotEmpty) ...[
              const SizedBox(height: 8),
              SizedBox(
                height: 160,
                child: ListView.separated(
                  itemCount: gardenPlants.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 6),
                  itemBuilder: (context, i) {
                    final v = gardenPlants[i];
                    final selected = _vegetableId == v.id;
                    return ListTile(
                      selected: selected,
                      selectedTileColor:
                          TuinierColors.primary.withValues(alpha: 0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: selected
                              ? TuinierColors.primary
                              : TuinierColors.border,
                        ),
                      ),
                      leading: VegetableThumbnail(
                        vegetable: v,
                        size: 40,
                      ),
                      title: Text(v.nameNl),
                      trailing: selected
                          ? const Icon(Icons.check_circle,
                              color: TuinierColors.primary)
                          : null,
                      onTap: () => setState(() => _vegetableId = v.id),
                    );
                  },
                ),
              ),
            ],
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _save,
              style: FilledButton.styleFrom(
                backgroundColor: TuinierColors.primary,
                minimumSize: const Size.fromHeight(48),
              ),
              child: Text(
                widget.existing == null ? 'Taak opslaan' : 'Wijzigingen opslaan',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
