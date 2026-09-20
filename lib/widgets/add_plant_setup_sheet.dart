import 'package:flutter/material.dart';

import '../data/ai_settings_store.dart';
import '../data/vegetable_repository.dart';
import '../models/add_plant_setup_result.dart';
import '../models/vegetable.dart';
import 'add_plant_wizard_screen.dart';

export '../models/add_plant_setup_result.dart';

/// Bij toevoegen: 6-stappen wizard (vanaf stap 2 als plant al gekozen is).
Future<AddPlantSetupResult?> showAddPlantSetupSheet(
  BuildContext context, {
  required Vegetable vegetable,
  required VegetableRepository repository,
  required AiSettingsStore aiSettings,
}) {
  return showAddPlantWizard(
    context,
    repository: repository,
    aiSettings: aiSettings,
    vegetable: vegetable,
  );
}
