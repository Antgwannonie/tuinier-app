import 'package:flutter/material.dart';

import '../data/planting_timing_advice.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'plant_setup_sheet_ui.dart';
import 'planting_timing_warning_card.dart';

class AddPlantSetupResult {
  const AddPlantSetupResult({
    required this.plantedAt,
    required this.location,
    required this.sunLevel,
    this.isPlanted = true,
    this.plantingDateUnknown = false,
  });

  final DateTime plantedAt;
  final GardenLocation location;
  final SunLevel sunLevel;

  /// `false` = alleen op lijst, nog niet in de grond.
  final bool isPlanted;

  /// Geen seizoenswaarschuwing op ingevulde datum.
  final bool plantingDateUnknown;
}

/// Bij toevoegen: wanneer geplant, locatie en zon.
Future<AddPlantSetupResult?> showAddPlantSetupSheet(
  BuildContext context, {
  required Vegetable vegetable,
}) {
  return showModalBottomSheet<AddPlantSetupResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(ctx).bottom,
      ),
      child: _AddPlantSetupSheet(vegetable: vegetable),
    ),
  );
}

class _AddPlantSetupSheet extends StatefulWidget {
  const _AddPlantSetupSheet({required this.vegetable});

  final Vegetable vegetable;

  @override
  State<_AddPlantSetupSheet> createState() => _AddPlantSetupSheetState();
}

class _AddPlantSetupSheetState extends State<_AddPlantSetupSheet> {
  DateTime _plantedAt = DateTime.now();
  GardenLocation _location = GardenLocation.outdoor;
  SunLevel _sun = SunLevel.medium;
  bool _alreadyPlanted = true;
  bool _plantingDateUnknown = false;

  GardenPlantProfile get _previewProfile => GardenPlantProfile(
        vegetableId: widget.vegetable.id,
        plantedAt: _plantedAt,
        location: _location,
        sunLevel: _sun,
        isPlanted: _alreadyPlanted,
        plantingDateUnknown: _plantingDateUnknown,
      );

  PlantingTimingAssessment get _timingPreview => assessPlantingTiming(
        vegetable: widget.vegetable,
        profile: _previewProfile,
      );

  String get _dateLabel => _alreadyPlanted
      ? 'Gezaaid / geplant op'
      : 'Gepland voor';

  Future<void> _pickDate() async {
    final picked = await pickPlantSetupDate(context, initial: _plantedAt);
    if (picked != null) setState(() => _plantedAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final timing = _timingPreview;
    final showSeasonPreview =
        !_plantingDateUnknown && timing.showOnInfoTab;

    return PlantSetupSheetFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlantSetupSheetHeader(
              title: widget.vegetable.nameNl,
              badge: 'Toevoegen',
              subtitle:
                  'Datum en plek helpen groei en oogst beter inschatten.',
            ),
            const SizedBox(height: 16),
            PlantSetupPlantedSwitch(
              value: _alreadyPlanted,
              onChanged: (v) => setState(() => _alreadyPlanted = v),
            ),
            const SizedBox(height: 16),
            PlantSetupDateCard(
              dateLabel: _dateLabel,
              plantedAt: _plantedAt,
              dateUnknown: _plantingDateUnknown,
              onDateUnknownChanged: (v) =>
                  setState(() => _plantingDateUnknown = v),
              onPickDate: _pickDate,
            ),
            const SizedBox(height: 20),
            const PlantSetupSectionLabel('Locatie'),
            PlantSetupSurfaceCard(
              child: PlantSetupOptionChips<GardenLocation>(
                options: GardenLocation.values,
                labelFor: (l) => l.label,
                selected: _location,
                onSelected: (l) => setState(() => _location = l),
              ),
            ),
            const SizedBox(height: 16),
            const PlantSetupSectionLabel('Zon op deze plek'),
            PlantSetupSurfaceCard(
              child: PlantSetupOptionChips<SunLevel>(
                options: SunLevel.values,
                labelFor: (s) => s.label,
                selected: _sun,
                onSelected: (s) => setState(() => _sun = s),
              ),
            ),
            if (_plantingDateUnknown || showSeasonPreview) ...[
              const SizedBox(height: 16),
              PlantingTimingWarningCard(assessment: timing),
            ],
            const SizedBox(height: 24),
            PlantSetupConfirmButton(
              label: 'Toevoegen aan Mijn moestuin',
              onPressed: () => Navigator.pop(
                context,
                AddPlantSetupResult(
                  plantedAt: _plantedAt,
                  location: _location,
                  sunLevel: _sun,
                  isPlanted: _alreadyPlanted,
                  plantingDateUnknown: _plantingDateUnknown,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
