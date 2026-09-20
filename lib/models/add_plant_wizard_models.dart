import 'package:flutter/material.dart';

import 'garden_plant_profile.dart';
import 'plant_ai_analysis.dart';
import 'plant_grow_approach.dart';
import 'plant_start_method.dart';

export 'plant_grow_approach.dart';

/// Stap 2: plantstatus bij toevoegen.
enum PlantAddIntent {
  alreadyHave,
  startNow,
  planForSeason,
}

extension PlantAddIntentLabels on PlantAddIntent {
  String get title => switch (this) {
        PlantAddIntent.alreadyHave => '🌱 Ik heb deze plant al',
        PlantAddIntent.startNow => '🌿 Nu beginnen met planten & zaaien',
        PlantAddIntent.planForSeason => '📅 Wachten op juiste seizoen',
      };

  String get subtitle => switch (this) {
        PlantAddIntent.alreadyHave =>
          'De plant groeit al en ik wil hem direct laten volgen door de AI.',
        PlantAddIntent.startNow =>
          'Start direct met kweken. Ook buiten het aanbevolen seizoen ontvang je passend AI-advies.',
        PlantAddIntent.planForSeason =>
          'Plan deze plant voor later en ontvang een melding zodra het juiste seizoen begint.',
      };

  IconData get icon => switch (this) {
        PlantAddIntent.alreadyHave => Icons.yard_rounded,
        PlantAddIntent.startNow => Icons.grass_rounded,
        PlantAddIntent.planForSeason => Icons.event_available_rounded,
      };

  bool get waitsForSeason => this == PlantAddIntent.planForSeason;
}

/// Stap 3 bij «ik heb deze plant al»: huidige groeifase.
enum PlantWizardCurrentPhase {
  seedling,
  growing,
  flowering,
  fruiting,
  almostRipe,
  ripe;

  static PlantWizardCurrentPhase? fromAiPhase(PlantAiPhase? phase) {
    if (phase == null) return null;
    return switch (phase) {
      PlantAiPhase.seedling => PlantWizardCurrentPhase.seedling,
      PlantAiPhase.growing => PlantWizardCurrentPhase.growing,
      PlantAiPhase.flowering => PlantWizardCurrentPhase.flowering,
      PlantAiPhase.fruiting => PlantWizardCurrentPhase.fruiting,
      PlantAiPhase.almostRipe => PlantWizardCurrentPhase.almostRipe,
      PlantAiPhase.ripe => PlantWizardCurrentPhase.ripe,
    };
  }
}

extension PlantWizardCurrentPhaseLabels on PlantWizardCurrentPhase {
  String get title => aiPhase.label;

  String get subtitle => switch (this) {
        PlantWizardCurrentPhase.seedling =>
          'Kiem of jonge plant, nog klein.',
        PlantWizardCurrentPhase.growing =>
          'Blad en stengel groeien; nog geen bloei of vruchten.',
        PlantWizardCurrentPhase.flowering =>
          'De plant bloeit of staat op bloei.',
        PlantWizardCurrentPhase.fruiting =>
          'Vruchten, knollen of peulen zijn aan het vormen.',
        PlantWizardCurrentPhase.almostRipe =>
          'Bijna klaar om te oogsten.',
        PlantWizardCurrentPhase.ripe =>
          'Klaar om te oogsten.',
      };

  IconData get icon => switch (this) {
        PlantWizardCurrentPhase.seedling => Icons.spa_rounded,
        PlantWizardCurrentPhase.growing => Icons.trending_up_rounded,
        PlantWizardCurrentPhase.flowering => Icons.local_florist_rounded,
        PlantWizardCurrentPhase.fruiting => Icons.eco_rounded,
        PlantWizardCurrentPhase.almostRipe => Icons.access_time_rounded,
        PlantWizardCurrentPhase.ripe => Icons.shopping_basket_rounded,
      };

  String get summaryLabel => aiPhase.label;

  PlantAiPhase get aiPhase => switch (this) {
        PlantWizardCurrentPhase.seedling => PlantAiPhase.seedling,
        PlantWizardCurrentPhase.growing => PlantAiPhase.growing,
        PlantWizardCurrentPhase.flowering => PlantAiPhase.flowering,
        PlantWizardCurrentPhase.fruiting => PlantAiPhase.fruiting,
        PlantWizardCurrentPhase.almostRipe => PlantAiPhase.almostRipe,
        PlantWizardCurrentPhase.ripe => PlantAiPhase.ripe,
      };
}

/// Stap 5: groeilocatie (mockup — mapped naar [GardenLocation]).
enum WizardGrowLocation {
  outdoor,
  greenhouse,
  shed,
  balcony,
  indoor,
  growLight,
}

extension WizardGrowLocationLabels on WizardGrowLocation {
  String get label => switch (this) {
        WizardGrowLocation.outdoor => 'Buiten',
        WizardGrowLocation.greenhouse => 'Kas / tunnel',
        WizardGrowLocation.shed => 'Schuur',
        WizardGrowLocation.balcony => 'Balkon',
        WizardGrowLocation.indoor => 'Binnen huis',
        WizardGrowLocation.growLight => 'Groeilamp',
      };

  IconData get icon => switch (this) {
        WizardGrowLocation.outdoor => Icons.wb_sunny_rounded,
        WizardGrowLocation.greenhouse => Icons.home_rounded,
        WizardGrowLocation.shed => Icons.garage_rounded,
        WizardGrowLocation.balcony => Icons.balcony_rounded,
        WizardGrowLocation.indoor => Icons.weekend_rounded,
        WizardGrowLocation.growLight => Icons.lightbulb_rounded,
      };

  GardenLocation get gardenLocation => switch (this) {
        WizardGrowLocation.outdoor || WizardGrowLocation.shed =>
          GardenLocation.outdoor,
        WizardGrowLocation.greenhouse => GardenLocation.greenhouse,
        WizardGrowLocation.balcony => GardenLocation.balcony,
        WizardGrowLocation.indoor || WizardGrowLocation.growLight =>
          GardenLocation.windowsill,
      };
}

/// Stap 6: zonuren op de groeiplek.
enum WizardSunHours {
  little,
  average,
  normal,
  enough,
  unknown,
}

extension WizardSunHoursLabels on WizardSunHours {
  String get label => switch (this) {
        WizardSunHours.little => 'Weinig · tot 4 uur',
        WizardSunHours.average => 'Gemiddeld · 4-6 uur',
        WizardSunHours.normal => 'Voldoende · 6-8 uur',
        WizardSunHours.enough => 'Genoeg · 8 uur en meer',
        WizardSunHours.unknown => 'Weet ik niet',
      };

  String get summaryLabel => switch (this) {
        WizardSunHours.little => 'Weinig zon · tot 4 uur',
        WizardSunHours.average => 'Gemiddeld · 4-6 uur zon',
        WizardSunHours.normal => 'Voldoende · 6-8 uur zon',
        WizardSunHours.enough => 'Genoeg zon · 8 uur en meer',
        WizardSunHours.unknown => 'Zon onbekend',
      };

  IconData get icon => switch (this) {
        WizardSunHours.little => Icons.bedtime,
        WizardSunHours.average => Icons.wb_cloudy,
        WizardSunHours.normal => Icons.filter_drama_rounded,
        WizardSunHours.enough => Icons.wb_sunny_rounded,
        WizardSunHours.unknown => Icons.help_rounded,
      };

  SunLevel get sunLevel => switch (this) {
        WizardSunHours.little => SunLevel.low,
        WizardSunHours.average || WizardSunHours.normal => SunLevel.medium,
        WizardSunHours.enough => SunLevel.high,
        WizardSunHours.unknown => SunLevel.medium,
      };

  /// Past bij gewassen die veel directe zon nodig hebben (8 uur of meer).
  bool get isAdequateForHighSunPlants => this == WizardSunHours.enough;

  /// Meeste directe zon — mogelijk te veel voor schaduwplanten.
  bool get isStrongSun => this == WizardSunHours.enough;
}

/// Snelle datumkeuze (stap 4).
enum WizardDateQuickPick {
  today,
  underWeek,
  oneToThreeWeeks,
  oneMonth,
  twoMonths,
  unknown,
}

extension WizardDateQuickPickLabels on WizardDateQuickPick {
  String labelFor({required bool alreadyPlanted}) => switch (this) {
        WizardDateQuickPick.today => 'Vandaag',
        WizardDateQuickPick.underWeek =>
          alreadyPlanted ? '± 1 week geleden' : '< 1 week',
        WizardDateQuickPick.oneToThreeWeeks =>
          alreadyPlanted ? '± 2 weken geleden' : '1-3 weken',
        WizardDateQuickPick.oneMonth =>
          alreadyPlanted ? '± 1 maand geleden' : '1 maand',
        WizardDateQuickPick.twoMonths =>
          alreadyPlanted ? '± 2 maanden geleden' : '2 maanden',
        WizardDateQuickPick.unknown => 'Weet ik niet',
      };

  String get label => labelFor(alreadyPlanted: false);
}

DateTime wizardDateForQuickPick(
  WizardDateQuickPick pick, {
  DateTime? reference,
  bool alreadyPlanted = false,
}) {
  final now = reference ?? DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  if (alreadyPlanted) {
    return switch (pick) {
      WizardDateQuickPick.today => today,
      WizardDateQuickPick.underWeek =>
        today.subtract(const Duration(days: 7)),
      WizardDateQuickPick.oneToThreeWeeks =>
        today.subtract(const Duration(days: 14)),
      WizardDateQuickPick.oneMonth =>
        today.subtract(const Duration(days: 30)),
      WizardDateQuickPick.twoMonths =>
        today.subtract(const Duration(days: 60)),
      WizardDateQuickPick.unknown => today,
    };
  }
  return switch (pick) {
    WizardDateQuickPick.today => today,
    WizardDateQuickPick.underWeek => today.add(const Duration(days: 7)),
    WizardDateQuickPick.oneToThreeWeeks => today.add(const Duration(days: 14)),
    WizardDateQuickPick.oneMonth => today.add(const Duration(days: 30)),
    WizardDateQuickPick.twoMonths => today.add(const Duration(days: 60)),
    WizardDateQuickPick.unknown => today,
  };
}

PlantStartMethod plantStartMethodForApproach({
  required PlantGrowApproach approach,
  required List<PlantStartMethod> available,
  PlantStartMethod? suggested,
}) {
  return switch (approach) {
    PlantGrowApproach.seed =>
      suggested ??
          (available.contains(PlantStartMethod.sowOutdoors)
              ? PlantStartMethod.sowOutdoors
              : available.contains(PlantStartMethod.preSowIndoors)
                  ? PlantStartMethod.preSowIndoors
                  : _firstAvailable(available) ?? PlantStartMethod.sowOutdoors),
    PlantGrowApproach.seedling || PlantGrowApproach.adult =>
      available.contains(PlantStartMethod.plantOutdoors)
          ? PlantStartMethod.plantOutdoors
          : _firstAvailable(available) ?? PlantStartMethod.plantOutdoors,
  };
}

PlantStartMethod? _firstAvailable(List<PlantStartMethod> available) {
  if (available.isEmpty) return null;
  return available.first;
}
