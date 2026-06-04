import 'package:flutter/material.dart';

import '../data/planting_timing_advice.dart';
import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'plant_setup_sheet_ui.dart';
import 'planting_timing_warning_card.dart';

class MarkPlantedResult {
  const MarkPlantedResult({
    required this.plantedAt,
    required this.location,
    required this.sunLevel,
    this.plantingDateUnknown = false,
  });

  final DateTime plantedAt;
  final GardenLocation location;
  final SunLevel sunLevel;
  final bool plantingDateUnknown;
}

Future<MarkPlantedResult?> showMarkPlantedSheet(
  BuildContext context, {
  required Vegetable vegetable,
  required int daysUntilFirstPhoto,
}) {
  return showModalBottomSheet<MarkPlantedResult>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(ctx).bottom,
      ),
      child: _MarkPlantedSheet(
        vegetable: vegetable,
        daysUntilFirstPhoto: daysUntilFirstPhoto,
      ),
    ),
  );
}

class _MarkPlantedSheet extends StatefulWidget {
  const _MarkPlantedSheet({
    required this.vegetable,
    required this.daysUntilFirstPhoto,
  });

  final Vegetable vegetable;
  final int daysUntilFirstPhoto;

  @override
  State<_MarkPlantedSheet> createState() => _MarkPlantedSheetState();
}

class _MarkPlantedSheetState extends State<_MarkPlantedSheet> {
  DateTime _plantedAt = DateTime.now();
  GardenLocation _location = GardenLocation.outdoor;
  SunLevel _sun = SunLevel.medium;
  bool _plantingDateUnknown = false;

  PlantingTimingAssessment get _timingPreview => assessPlantingTiming(
        vegetable: widget.vegetable,
        profile: GardenPlantProfile(
          vegetableId: widget.vegetable.id,
          plantedAt: _plantedAt,
          location: _location,
          sunLevel: _sun,
          isPlanted: true,
          plantingDateUnknown: _plantingDateUnknown,
        ),
      );

  Future<void> _pickDate() async {
    final picked = await pickPlantSetupDate(context, initial: _plantedAt);
    if (picked != null) setState(() => _plantedAt = picked);
  }

  @override
  Widget build(BuildContext context) {
    final timing = _timingPreview;
    final showSeasonCard = timing.showOnInfoTab;
    final reminderDays = widget.daysUntilFirstPhoto;

    return PlantSetupSheetFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlantSetupSheetHeader(
              title: widget.vegetable.nameNl,
              badge: 'Geplant',
              subtitle:
                  'Scan meteen je eerste foto — ook zonder zichtbare kiem. '
                  'Na $reminderDays dagen volgt eventueel een herinnering.',
            ),
            const SizedBox(height: 20),
            PlantSetupDateCard(
              dateLabel: 'Gezaaid / geplant op',
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
            if (showSeasonCard) ...[
              const SizedBox(height: 16),
              PlantingTimingWarningCard(assessment: timing),
            ],
            const SizedBox(height: 24),
            PlantSetupConfirmButton(
              label: 'Bevestigen',
              onPressed: () => Navigator.pop(
                context,
                MarkPlantedResult(
                  plantedAt: _plantedAt,
                  location: _location,
                  sunLevel: _sun,
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
