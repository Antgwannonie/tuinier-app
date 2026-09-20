import 'dart:typed_data';

import '../models/add_plant_wizard_models.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_start_method.dart';

/// Eerste plantscan uit de toevoeg-wizard — wordt na toevoegen opgeslagen.
class WizardInitialScan {
  const WizardInitialScan({
    required this.analysis,
    required this.photoBytes,
    this.mimeType = 'image/jpeg',
  });

  final PlantAiAnalysis analysis;
  final Uint8List photoBytes;
  final String mimeType;
}

class AddPlantSetupResult {
  const AddPlantSetupResult({
    required this.vegetableId,
    required this.plantedAt,
    required this.location,
    required this.sunLevel,
    required this.intent,
    this.isPlanted = false,
    this.plantingDateUnknown = false,
    this.plantStartMethod,
    this.growApproach,
    this.currentPhase,
    this.initialScan,
  });

  final String vegetableId;
  final DateTime plantedAt;
  final GardenLocation location;
  final SunLevel sunLevel;
  final PlantAddIntent intent;
  final bool isPlanted;
  final bool plantingDateUnknown;
  final PlantStartMethod? plantStartMethod;
  final PlantGrowApproach? growApproach;
  final PlantWizardCurrentPhase? currentPhase;
  final WizardInitialScan? initialScan;

  PlantAiPhase? get reportedAiPhase =>
      initialScan != null ? null : currentPhase?.aiPhase;
}