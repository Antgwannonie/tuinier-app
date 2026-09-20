import 'package:flutter/material.dart';

import '../data/garden_profile_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import '../data/visual_garden_apply_bed.dart';
import '../models/tuin_space.dart';
import '../models/visual_garden_plan.dart';
import '../theme/tuinier_colors.dart';
import 'tuin_space_place_illustration.dart';

/// Bevestigt bak → nieuwe moestuin (naam + standplaats).
Future<VisualBedApplyResult?> showApplyVisualBedSheet({
  required BuildContext context,
  required VisualGardenBed bed,
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
}) {
  return showModalBottomSheet<VisualBedApplyResult>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => _ApplyVisualBedSheet(
      bed: bed,
      gardenStore: gardenStore,
      profileStore: profileStore,
      repository: repository,
    ),
  );
}

class _ApplyVisualBedSheet extends StatefulWidget {
  const _ApplyVisualBedSheet({
    required this.bed,
    required this.gardenStore,
    required this.profileStore,
    required this.repository,
  });

  final VisualGardenBed bed;
  final MyGardenStore gardenStore;
  final GardenProfileStore profileStore;
  final VegetableRepository repository;

  @override
  State<_ApplyVisualBedSheet> createState() => _ApplyVisualBedSheetState();
}

class _ApplyVisualBedSheetState extends State<_ApplyVisualBedSheet> {
  late final TextEditingController _nameController;
  TuinSpacePlace _place = TuinSpacePlace.outdoor;
  bool _saving = false;
  bool _addToAgenda = true;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.bed.name);
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  List<String> get _plantNames {
    final ids = widget.bed.placements.map((p) => p.plantId).toSet();
    final names = <String>[];
    for (final id in ids) {
      final name = widget.repository.byId(id)?.nameNl;
      if (name != null) names.add(name);
    }
    names.sort();
    return names;
  }

  Future<void> _submit() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      final result = await applyVisualBedToNewMoestuin(
        gardenStore: widget.gardenStore,
        profileStore: widget.profileStore,
        repository: widget.repository,
        bed: widget.bed,
        spaceName: _nameController.text,
        place: _place,
        addToAgenda: _addToAgenda,
      );
      if (!mounted) return;
      Navigator.of(context).pop(result);
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Kon de moestuin niet aanmaken. Probeer opnieuw.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final names = _plantNames;
    final count = names.length;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Selectie opslaan in moestuin',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Geef je nieuwe moestuin een naam. De planten worden gepland '
              'voor hun zaai-/plantperiode.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TuinierColors.textSecondary,
                    height: 1.35,
                  ),
            ),
            const SizedBox(height: 18),
            Text(
              'Naam van de moestuin',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'Bijv. ${widget.bed.name}',
                filled: true,
                fillColor: TuinierColors.card,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: TuinierColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(color: TuinierColors.border),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Standplaats',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: TuinSpacePlace.values.map((place) {
                final selected = _place == place;
                return FilterChip(
                  avatar: TuinSpacePlaceIllustration(place: place, size: 22),
                  label: Text(place.label),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: _saving
                      ? null
                      : (_) => setState(() => _place = place),
                  selectedColor: TuinierColors.primary.withValues(alpha: 0.14),
                  side: BorderSide(
                    color: selected
                        ? TuinierColors.primary
                        : TuinierColors.border,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Ook in planner-agenda zetten'),
              subtitle: const Text(
                'Krijg een melding wanneer je kunt beginnen met zaaien/planten',
              ),
              value: _addToAgenda,
              activeThumbColor: TuinierColors.primary,
              onChanged: _saving
                  ? null
                  : (v) => setState(() => _addToAgenda = v),
            ),
            const SizedBox(height: 8),
            Text(
              count == 1 ? '1 plantensoort' : '$count plantensoorten',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: 6),
            Text(
              names.isEmpty ? 'Geen planten in deze bak' : names.join(', '),
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: TuinierColors.textSecondary,
                  ),
            ),
            const SizedBox(height: 22),
            FilledButton(
              onPressed: _saving || names.isEmpty ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: TuinierColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Opslaan in mijn moestuin'),
            ),
          ],
        ),
      ),
    );
  }
}
