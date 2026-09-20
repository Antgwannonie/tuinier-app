import 'package:flutter/material.dart';

import '../models/add_plant_wizard_models.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import 'plant_start_flow.dart';
import 'planting_calendar.dart';
import 'planting_season_context.dart';
import 'planting_season_status.dart';
import 'planting_timing_advice.dart';

/// Eén keuze op wizard-stap 2, afgestemd op het plantseizoen.
class WizardStep2IntentOption {
  const WizardStep2IntentOption({
    required this.intent,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final PlantAddIntent intent;
  final String title;
  final String subtitle;
  final IconData icon;
}

/// Seizoenscontext voor stap 2 van de toevoeg-wizard.
class WizardStep2SeasonContext {
  const WizardStep2SeasonContext({
    required this.isPlantingSeasonNow,
    required this.seasonHeadline,
    required this.seasonDetail,
    required this.seasonLabel,
    required this.activeSeasons,
    required this.options,
    required this.status,
  });

  final bool isPlantingSeasonNow;
  final String seasonHeadline;
  final String seasonDetail;
  final String seasonLabel;
  final List<ActivePlantingSeasonLine> activeSeasons;
  final List<WizardStep2IntentOption> options;
  final PlantingSeasonStatus status;
}

WizardStep2SeasonContext buildWizardStep2SeasonContext({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final status = plantingSeasonStatusFor(
    vegetable.id,
    reference: reference,
    vegetable: vegetable,
  );
  final activeSeasons = activePlantingSeasonLinesFor(
    vegetable: vegetable,
    reference: reference,
  );
  final inSeason = activeSeasons.isNotEmpty;
  final action = _wizardPlantingActionLabel(status, vegetable, activeSeasons);
  final name = vegetable.nameNl;
  final cal = calendarLabelsFor(vegetable.id);

  final seasonHeadline = inSeason
      ? activeSeasons.length == 1
          ? 'Nu ${activeSeasons.first.title.toLowerCase()} voor $name'
          : 'Nu ${activeSeasons.length} seizoenen actief voor $name'
      : 'Nu geen zaai- of plantseizoen voor $name';

  final seasonLines = <String>[
    if (activeSeasons.isNotEmpty)
      ...activeSeasons.map((line) => '• ${line.title}: ${line.statusLine}'),
    if (!inSeason && status.label.trim().isNotEmpty) status.label.trim(),
    if (cal.plant != null && !inSeason) cal.plant!,
    if (!inSeason && cal.harvest != null) cal.harvest!,
  ];
  final seasonDetail = seasonLines.isNotEmpty
      ? seasonLines.join('\n')
      : (inSeason
          ? 'Dit is een goed moment om met $name aan de slag te gaan.'
          : 'Je kunt toch starten of wachten tot het seizoen begint.');

  final options = inSeason
      ? [
          WizardStep2IntentOption(
            intent: PlantAddIntent.startNow,
            title: '🌿 $name nu $action',
            subtitle: activeSeasons.length > 1
                ? 'Meerdere seizoenen zijn nu open. Kies wat bij jouw aanpak past.'
                : 'Het is het juiste seizoen. Start nu met zaaien of planten.',
            icon: Icons.grass_rounded,
          ),
          WizardStep2IntentOption(
            intent: PlantAddIntent.alreadyHave,
            title: PlantAddIntent.alreadyHave.title,
            subtitle:
                'De plant groeit al. Scan hem in de volgende stap zodat de AI meekijkt.',
            icon: PlantAddIntent.alreadyHave.icon,
          ),
        ]
      : [
          WizardStep2IntentOption(
            intent: PlantAddIntent.startNow,
            title: '🌿 Toch $action buiten het seizoen?',
            subtitle:
                'Start nu met AI-begeleiding, ook buiten het aanbevolen venster.',
            icon: Icons.grass_rounded,
          ),
          WizardStep2IntentOption(
            intent: PlantAddIntent.alreadyHave,
            title: PlantAddIntent.alreadyHave.title,
            subtitle:
                'Je hebt de plant al staan. Scan hem in de volgende stap zodat de AI meekijkt.',
            icon: PlantAddIntent.alreadyHave.icon,
          ),
          WizardStep2IntentOption(
            intent: PlantAddIntent.planForSeason,
            title: PlantAddIntent.planForSeason.title,
            subtitle:
                'Plan $name voor later. Je krijgt een melding zodra het zaaiseizoen begint.',
            icon: PlantAddIntent.planForSeason.icon,
          ),
        ];

  return WizardStep2SeasonContext(
    isPlantingSeasonNow: inSeason,
    seasonHeadline: seasonHeadline,
    seasonDetail: seasonDetail,
    seasonLabel: status.label.trim(),
    activeSeasons: activeSeasons,
    options: options,
    status: status,
  );
}

String _wizardPlantingActionLabel(
  PlantingSeasonStatus status,
  Vegetable vegetable,
  List<ActivePlantingSeasonLine> activeSeasons,
) {
  if (activeSeasons.length == 1) {
    return switch (activeSeasons.first.type) {
      GardenTaskType.preSow => 'voorzaaien',
      GardenTaskType.sowOutdoors => 'buiten zaaien',
      GardenTaskType.plantOutdoors => 'buiten planten',
      GardenTaskType.harvest => 'oogsten',
    };
  }
  if (activeSeasons.length > 1) {
    final verbs = activeSeasons
        .map((line) => switch (line.type) {
              GardenTaskType.preSow => 'voorzaaien',
              GardenTaskType.sowOutdoors => 'buiten zaaien',
              GardenTaskType.plantOutdoors => 'buiten planten',
              GardenTaskType.harvest => 'oogsten',
            })
        .toSet()
        .toList();
    if (verbs.length == 1) return verbs.first;
    return verbs.join(', ');
  }

  final fromType = switch (status.taskType) {
    GardenTaskType.preSow => 'voorzaaien',
    GardenTaskType.sowOutdoors => 'zaaien',
    GardenTaskType.plantOutdoors => 'planten',
    _ => null,
  };
  if (fromType != null) return fromType;

  final methods = availablePlantStartMethods(vegetable);
  final canSow = methods.contains(PlantStartMethod.sowOutdoors) ||
      methods.contains(PlantStartMethod.preSowIndoors);
  final canPlant = methods.contains(PlantStartMethod.plantOutdoors);
  if (canPlant && !canSow) return 'planten';
  if (canSow && !canPlant) return 'zaaien';
  return 'zaaien of planten';
}
