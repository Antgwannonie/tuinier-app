import 'package:flutter/material.dart';

import '../models/garden_plant_profile.dart';

class MarkPlantedResult {
  const MarkPlantedResult({
    required this.plantedAt,
    required this.location,
    required this.sunLevel,
  });

  final DateTime plantedAt;
  final GardenLocation location;
  final SunLevel sunLevel;
}

Future<MarkPlantedResult?> showMarkPlantedSheet(
  BuildContext context, {
  required String vegetableName,
  required int daysUntilFirstPhoto,
}) {
  return showModalBottomSheet<MarkPlantedResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _MarkPlantedSheet(
      vegetableName: vegetableName,
      daysUntilFirstPhoto: daysUntilFirstPhoto,
    ),
  );
}

class _MarkPlantedSheet extends StatefulWidget {
  const _MarkPlantedSheet({
    required this.vegetableName,
    required this.daysUntilFirstPhoto,
  });

  final String vegetableName;
  final int daysUntilFirstPhoto;

  @override
  State<_MarkPlantedSheet> createState() => _MarkPlantedSheetState();
}

class _MarkPlantedSheetState extends State<_MarkPlantedSheet> {
  DateTime _plantedAt = DateTime.now();
  GardenLocation _location = GardenLocation.outdoor;
  SunLevel _sun = SunLevel.medium;

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${widget.vegetableName} — geplant',
              style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Na ongeveer ${widget.daysUntilFirstPhoto} dagen krijg je een melding '
              'om je eerste foto te maken.',
              style: t.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _plantedAt,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _plantedAt = picked);
              },
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                'Geplant op ${_plantedAt.day}-${_plantedAt.month}-${_plantedAt.year}',
              ),
            ),
            const SizedBox(height: 12),
            Text('Locatie', style: t.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: GardenLocation.values.map((loc) {
                return ChoiceChip(
                  label: Text(loc.label),
                  selected: _location == loc,
                  onSelected: (_) => setState(() => _location = loc),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
            Text('Zon', style: t.textTheme.labelLarge),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: SunLevel.values.map((s) {
                return ChoiceChip(
                  label: Text(s.label),
                  selected: _sun == s,
                  onSelected: (_) => setState(() => _sun = s),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: () => Navigator.pop(
                context,
                MarkPlantedResult(
                  plantedAt: _plantedAt,
                  location: _location,
                  sunLevel: _sun,
                ),
              ),
              icon: const Icon(Icons.check),
              label: const Text('Bevestigen — staat in de grond'),
            ),
          ],
        ),
      ),
    );
  }
}
