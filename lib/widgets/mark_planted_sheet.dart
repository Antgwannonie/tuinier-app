import 'package:flutter/material.dart';

import '../data/plant_pending_planting.dart';
import '../data/plant_start_flow.dart';
import '../data/planting_timing_advice.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import 'plant_setup_sheet_ui.dart';
import 'planting_guidance_sheet.dart';
import 'planting_timing_warning_card.dart';

class MarkPlantedResult {
  const MarkPlantedResult({
    required this.plantedAt,
    required this.location,
    required this.sunLevel,
    this.plantingDateUnknown = false,
    this.plantStartMethod,
    this.completeOutdoorPlanting = false,
  });

  final DateTime plantedAt;
  final GardenLocation location;
  final SunLevel sunLevel;
  final bool plantingDateUnknown;
  final PlantStartMethod? plantStartMethod;
  final bool completeOutdoorPlanting;
}

/// Plantgegevens uit het profiel (wizard-keuzes), zonder extra sheet.
MarkPlantedResult markPlantedResultFromProfile(GardenPlantProfile profile) {
  final outdoorCompletion = profileAwaitingOutdoorPlanting(profile);
  final method = profile.plantStartMethod ??
      (outdoorCompletion ? PlantStartMethod.plantOutdoors : null);
  return MarkPlantedResult(
    plantedAt: profile.plantedAt,
    location: outdoorCompletion ? GardenLocation.outdoor : profile.location,
    sunLevel: profile.sunLevel,
    plantingDateUnknown: profile.plantingDateUnknown,
    plantStartMethod: method,
    completeOutdoorPlanting: outdoorCompletion,
  );
}

Future<MarkPlantedResult?> showMarkPlantedSheet(
  BuildContext context, {
  required Vegetable vegetable,
  required int daysUntilFirstPhoto,
  GardenPlantProfile? existingProfile,
}) {
  if (shouldUsePlantingGuidanceSheet(existingProfile)) {
    return showModalBottomSheet<MarkPlantedResult>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(ctx).bottom,
        ),
        child: PlantingGuidanceSheet(
          vegetable: vegetable,
          profile: existingProfile!,
        ),
      ),
    );
  }

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
        existingProfile: existingProfile,
      ),
    ),
  );
}

class _MarkPlantedSheet extends StatefulWidget {
  const _MarkPlantedSheet({
    required this.vegetable,
    required this.daysUntilFirstPhoto,
    this.existingProfile,
  });

  final Vegetable vegetable;
  final int daysUntilFirstPhoto;
  final GardenPlantProfile? existingProfile;

  @override
  State<_MarkPlantedSheet> createState() => _MarkPlantedSheetState();
}

class _MarkPlantedSheetState extends State<_MarkPlantedSheet> {
  late DateTime _plantedAt;
  late GardenLocation _location;
  late SunLevel _sun;
  bool _plantingDateUnknown = false;
  late PlantStartMethod _method;

  bool get _outdoorCompletion =>
      widget.existingProfile != null &&
      profileAwaitingOutdoorPlanting(widget.existingProfile!);

  @override
  void initState() {
    super.initState();
    final profile = widget.existingProfile;
    _plantedAt = profile?.plantedAt ?? DateTime.now();
    _location = _outdoorCompletion
        ? GardenLocation.outdoor
        : (profile?.location ?? GardenLocation.outdoor);
    _sun = profile?.sunLevel ?? SunLevel.medium;
    _plantingDateUnknown = profile?.plantingDateUnknown ?? false;
    _method = _outdoorCompletion
        ? PlantStartMethod.plantOutdoors
        : (suggestedPlantStartMethod(vegetable: widget.vegetable) ??
            availablePlantStartMethods(widget.vegetable).firstOrNull ??
            PlantStartMethod.plantOutdoors);
  }

  PlantingTimingAssessment get _timingPreview => assessPlantingTiming(
        vegetable: widget.vegetable,
        profile: GardenPlantProfile(
          vegetableId: widget.vegetable.id,
          plantedAt: _plantedAt,
          location: _location,
          sunLevel: _sun,
          isPlanted: true,
          plantingDateUnknown: _plantingDateUnknown,
          plantStartMethod: _method,
          awaitingOutdoorPlanting:
              _method == PlantStartMethod.preSowIndoors && !_outdoorCompletion,
        ),
      );

  Future<void> _pickDate() async {
    final picked = await pickPlantSetupDate(context, initial: _plantedAt);
    if (picked != null) setState(() => _plantedAt = picked);
  }

  void _onMethodSelected(PlantStartMethod method) {
    setState(() {
      _method = method;
      if (method == PlantStartMethod.preSowIndoors &&
          _location == GardenLocation.outdoor) {
        _location = GardenLocation.windowsill;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final timing = _timingPreview;
    final showSeasonCard = timing.showOnInfoTab;
    final methods = availablePlantStartMethods(widget.vegetable);
    final dateLabel = _outdoorCompletion
        ? PlantStartMethod.plantOutdoors.dateFieldLabel
        : _method.dateFieldLabel;

    return PlantSetupSheetFrame(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PlantSetupSheetHeader(
              title: widget.vegetable.nameNl,
              badge: _outdoorCompletion
                  ? outdoorPlantingActionLabel
                  : 'Zaaien / planten',
              subtitle: _outdoorCompletion
                  ? 'Je hebt binnen voorgezaaid. Geef aan wanneer je buiten '
                      'hebt geplant.'
                  : 'Kies hoe je bent gestart. Daarna kun je scannen voor je '
                      'AI-samenvatting.',
            ),
            if (!_outdoorCompletion && methods.length > 1) ...[
              const SizedBox(height: 20),
              const PlantSetupSectionLabel('Hoe gestart?'),
              PlantSetupSurfaceCard(
                child: PlantSetupOptionChips<PlantStartMethod>(
                  options: methods,
                  labelFor: (m) => m.cardLabel,
                  selected: _method,
                  onSelected: _onMethodSelected,
                ),
              ),
            ],
            const SizedBox(height: 20),
            PlantSetupDateCard(
              dateLabel: dateLabel,
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
                  plantStartMethod: _method,
                  completeOutdoorPlanting: _outdoorCompletion,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull => isEmpty ? null : first;
}
