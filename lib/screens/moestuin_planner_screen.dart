import 'package:flutter/material.dart';

import '../data/garden_history_store.dart';
import '../data/my_garden_store.dart';
import '../data/vegetable_repository.dart';
import 'moestuin_plan_wizard_screen.dart';

/// Compat-entry: opent de volledige moestuin-planwizard.
class MoestuinPlannerScreen extends StatelessWidget {
  const MoestuinPlannerScreen({
    super.key,
    required this.repository,
    required this.gardenStore,
    required this.historyStore,
  });

  final VegetableRepository repository;
  final MyGardenStore gardenStore;
  final GardenHistoryStore historyStore;

  @override
  Widget build(BuildContext context) {
    return MoestuinPlanWizardScreen(
      repository: repository,
      gardenStore: gardenStore,
      historyStore: historyStore,
    );
  }
}
