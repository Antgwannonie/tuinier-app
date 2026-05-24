import 'package:flutter/material.dart';

import '../models/garden_plant_profile.dart';

class AddPlantSetupResult {
  const AddPlantSetupResult({
    required this.plantedAt,
    required this.location,
    required this.sunLevel,
    this.isPlanted = true,
  });

  final DateTime plantedAt;
  final GardenLocation location;
  final SunLevel sunLevel;

  /// `false` = alleen op lijst, nog niet in de grond.
  final bool isPlanted;
}

/// Bij toevoegen: wanneer geplant, locatie en zon.
Future<AddPlantSetupResult?> showAddPlantSetupSheet(
  BuildContext context, {
  required String vegetableName,
}) {
  return showModalBottomSheet<AddPlantSetupResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => _AddPlantSetupSheet(vegetableName: vegetableName),
  );
}

class _AddPlantSetupSheet extends StatefulWidget {
  const _AddPlantSetupSheet({required this.vegetableName});

  final String vegetableName;

  @override
  State<_AddPlantSetupSheet> createState() => _AddPlantSetupSheetState();
}

class _AddPlantSetupSheetState extends State<_AddPlantSetupSheet> {
  DateTime _plantedAt = DateTime.now();
  GardenLocation _location = GardenLocation.outdoor;
  SunLevel _sun = SunLevel.medium;
  bool _alreadyPlanted = true;

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
              '${widget.vegetableName} toevoegen',
              style: t.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Zo schat de app jouw groei en oogst realistischer in.',
              style: t.textTheme.bodyMedium?.copyWith(
                color: t.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Staat al in de grond'),
              subtitle: const Text(
                'Uit = alleen plannen; je vinkt later “geplant” aan op Start.',
              ),
              value: _alreadyPlanted,
              onChanged: (v) => setState(() => _alreadyPlanted = v),
            ),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(
                _alreadyPlanted ? 'Geplant / gezaaid op' : 'Gepland voor',
              ),
              subtitle: Text(
                '${_plantedAt.day}-${_plantedAt.month}-${_plantedAt.year}',
              ),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _plantedAt,
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now(),
                );
                if (picked != null) setState(() => _plantedAt = picked);
              },
            ),
            Text('Locatie', style: t.textTheme.titleSmall),
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
            Text('Zon op deze plek', style: t.textTheme.titleSmall),
            Wrap(
              spacing: 8,
              children: SunLevel.values.map((sun) {
                return ChoiceChip(
                  label: Text(sun.label),
                  selected: _sun == sun,
                  onSelected: (_) => setState(() => _sun = sun),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => Navigator.pop(
                context,
                AddPlantSetupResult(
                  plantedAt: _plantedAt,
                  location: _location,
                  sunLevel: _sun,
                  isPlanted: _alreadyPlanted,
                ),
              ),
              child: const Text('Toevoegen aan Mijn moestuin'),
            ),
          ],
        ),
      ),
    );
  }
}
