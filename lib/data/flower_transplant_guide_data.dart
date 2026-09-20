import 'package:flutter/material.dart';

import '../models/vegetable.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'moestuin_companion_info.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';
import 'plant_guide_detail.dart';
import 'plant_transplant_guide.dart';

const _asset = 'assets/images/flower_transplant';

class FlowerTransplantGuide {
  FlowerTransplantGuide({
    required this.periodLabel,
    required this.periodMonths,
    required this.conditions,
    required this.conditionsImage,
    required this.hardeningSteps,
    required this.hardeningImage,
    required this.plantSpacing,
    required this.rowSpacing,
    required this.plantingDepth,
    required this.plantSpacingImage,
    required this.rowSpacingImage,
    required this.plantingDepthImage,
    required this.locations,
    required this.soilPrepItems,
    required this.soilPrepImage,
    required this.waterItems,
    required this.waterImage,
    required this.supportItems,
    required this.supportImage,
    required this.protectionItems,
    required this.protectionImage,
    required this.timeToEstablish,
    required this.timeToEstablishImage,
    required this.timeToGrowth,
    required this.timeToGrowthImage,
    required this.mistakes,
    required this.mistakesImage,
    this.vegetable,
  });

  final String periodLabel;
  final Set<int> periodMonths;
  final List<String> conditions;
  final String conditionsImage;
  final List<FlowerHardeningStep> hardeningSteps;
  final String hardeningImage;
  final String plantSpacing;
  final String rowSpacing;
  final String plantingDepth;
  final String plantSpacingImage;
  final String rowSpacingImage;
  final String plantingDepthImage;
  final List<FlowerLocationChip> locations;
  final List<String> soilPrepItems;
  final String soilPrepImage;
  final List<String> waterItems;
  final String waterImage;
  final List<String> supportItems;
  final String supportImage;
  final List<FlowerProtectionItem> protectionItems;
  final String protectionImage;
  final String timeToEstablish;
  final String timeToEstablishImage;
  final String timeToGrowth;
  final String timeToGrowthImage;
  final List<FlowerMistakeItem> mistakes;
  final String mistakesImage;
  final Vegetable? vegetable;

  /// Detailblokken per sectietitel (view-time helper).
  List<PlantGuideDetailBlock> detailsFor(String title) {
    final v = vegetable;
    if (v == null) return const [];
    return flowerSectionDetailsFor(
      tab: 'transplant',
      title: title,
      vegetable: v,
      profile: flowerGuideProfileFor(v.id),
    );
  }
}

class FlowerHardeningStep {
  FlowerHardeningStep({required this.label, required this.detail});

  final String label;
  final String detail;
}

class FlowerLocationChip {
  FlowerLocationChip({
    required this.label,
    required this.suitable,
    required this.icon,
  });

  final String label;
  final bool suitable;
  final IconData icon;
}

class FlowerProtectionItem {
  FlowerProtectionItem({
    required this.label,
    required this.icon,
  });

  final String label;
  final IconData icon;
}

class FlowerMistakeItem {
  FlowerMistakeItem({required this.title, required this.body});

  final String title;
  final String body;
}

final _lavendelTransplantGuide = FlowerTransplantGuide(
  periodLabel: 'April – mei, na de laatste nachtvorst.',
  periodMonths: {4, 5},
  conditions: const [
    'Geen nachtvorst.',
    'Bodemtemperatuur boven 10 °C.',
    'Plant heeft 4–6 echte bladeren.',
  ],
  conditionsImage: '$_asset/flower_transplant_conditions.png',
  hardeningSteps: [
    FlowerHardeningStep(label: 'Dag 1', detail: '2 uur buiten'),
    FlowerHardeningStep(label: 'Dag 2', detail: '4 uur buiten'),
    FlowerHardeningStep(label: 'Dag 3', detail: '6 uur buiten'),
    FlowerHardeningStep(label: 'Dag 7', detail: 'Hele dag buiten'),
  ],
  hardeningImage: '$_asset/flower_transplant_hardening.png',
  plantSpacing: '40 cm tussen de planten.',
  rowSpacing: '60 cm tussen de rijen.',
  plantingDepth: 'Op dezelfde diepte als in de pot.',
  plantSpacingImage: '$_asset/flower_transplant_plant_spacing.png',
  rowSpacingImage: '$_asset/flower_transplant_row_spacing.png',
  plantingDepthImage: '$_asset/flower_transplant_planting_depth.png',
  locations: [
    FlowerLocationChip(
      label: 'Zon',
      suitable: true,
      icon: Icons.wb_sunny_outlined,
    ),
    FlowerLocationChip(
      label: 'Halfschaduw',
      suitable: false,
      icon: Icons.wb_cloudy_outlined,
    ),
    FlowerLocationChip(
      label: 'Pot',
      suitable: true,
      icon: Icons.local_florist_outlined,
    ),
    FlowerLocationChip(
      label: 'Kas',
      suitable: false,
      icon: Icons.home_outlined,
    ),
    FlowerLocationChip(
      label: 'Volle grond',
      suitable: true,
      icon: Icons.grass_outlined,
    ),
  ],
  soilPrepItems: const [
    'Compost of organische mest toevoegen.',
    'Grond losmaken en egaliseren.',
    'Onkruid en stenen verwijderen.',
  ],
  soilPrepImage: '$_asset/flower_transplant_soil_prep.png',
  waterItems: const [
    'Direct goed water geven.',
    'Eerste week extra vochtig houden.',
  ],
  waterImage: '$_asset/flower_transplant_water.png',
  supportItems: const [
    'Lavendel heeft geen steun nodig.',
    'Zorg wel voor luchtige groei.',
  ],
  supportImage: '$_asset/flower_transplant_support.png',
  protectionItems: [
    FlowerProtectionItem(label: 'Tegen wind', icon: Icons.air),
    FlowerProtectionItem(label: 'Tegen slakken', icon: Icons.pest_control),
    FlowerProtectionItem(
      label: 'Tegen nachtvorst',
      icon: Icons.ac_unit_outlined,
    ),
    FlowerProtectionItem(
      label: 'Tegen felle zon',
      icon: Icons.wb_sunny_outlined,
    ),
  ],
  protectionImage: '$_asset/flower_transplant_protection.png',
  timeToEstablish: 'De plant heeft meestal 1–2 weken nodig om aan te slaan.',
  timeToEstablishImage: '$_asset/flower_transplant_establish.png',
  timeToGrowth: 'Nieuwe groei zichtbaar na 7–14 dagen.',
  timeToGrowthImage: '$_asset/flower_transplant_first_growth.png',
  mistakes: [
    FlowerMistakeItem(
      title: 'Te vroeg buiten zetten',
      body: 'Wacht tot er geen nachtvorst meer dreigt.',
    ),
    FlowerMistakeItem(
      title: 'Niet afharden',
      body: 'Laat jonge planten wennen aan buitenlucht en zon.',
    ),
    FlowerMistakeItem(
      title: 'Te diep planten',
      body: 'Zet op dezelfde diepte als in de pot.',
    ),
    FlowerMistakeItem(
      title: 'Te natte grond',
      body: 'Lavendel houdt van droge, goed doorlatende grond.',
    ),
    FlowerMistakeItem(
      title: 'Te dicht planten',
      body: 'Geef ruimte voor luchtcirculatie.',
    ),
  ],
  mistakesImage: '$_asset/flower_transplant_mistakes.png',
);

final Map<String, FlowerTransplantGuide> _kFlowerTransplantOverrides = {
  'lavendel': _lavendelTransplantGuide,
};

FlowerTransplantGuide flowerTransplantGuideForVegetable(Vegetable vegetable) {
  final exact = _kFlowerTransplantOverrides[vegetable.id];
  if (exact != null) {
    return FlowerTransplantGuide(
      periodLabel: exact.periodLabel,
      periodMonths: exact.periodMonths,
      conditions: exact.conditions,
      conditionsImage: exact.conditionsImage,
      hardeningSteps: exact.hardeningSteps,
      hardeningImage: exact.hardeningImage,
      plantSpacing: exact.plantSpacing,
      rowSpacing: exact.rowSpacing,
      plantingDepth: exact.plantingDepth,
      plantSpacingImage: exact.plantSpacingImage,
      rowSpacingImage: exact.rowSpacingImage,
      plantingDepthImage: exact.plantingDepthImage,
      locations: exact.locations,
      soilPrepItems: exact.soilPrepItems,
      soilPrepImage: exact.soilPrepImage,
      waterItems: exact.waterItems,
      waterImage: exact.waterImage,
      supportItems: exact.supportItems,
      supportImage: exact.supportImage,
      protectionItems: exact.protectionItems,
      protectionImage: exact.protectionImage,
      timeToEstablish: exact.timeToEstablish,
      timeToEstablishImage: exact.timeToEstablishImage,
      timeToGrowth: exact.timeToGrowth,
      timeToGrowthImage: exact.timeToGrowthImage,
      mistakes: exact.mistakes,
      mistakesImage: exact.mistakesImage,
      vegetable: vegetable,
    );
  }
  return _buildFlowerTransplantGuide(vegetable);
}

FlowerTransplantGuide _buildFlowerTransplantGuide(Vegetable vegetable) {
  final p = flowerGuideProfileFor(vegetable.id);
  final transplant = transplantGuideForVegetable(vegetable);
  final companion = moestuinCompanionInfoForVegetable(vegetable);
  final period = _rowSectionValue(transplant, 'Uitplantperiode');
  final plantMonths = p.transplantMonths.isNotEmpty
      ? p.transplantMonths
      : () {
          final activities = calendarActivitiesForVegetable(
            vegetable.id,
            vegetable: vegetable,
          );
          final months = <int>{};
          for (final a in activities) {
            if (a.type == GardenTaskType.plantOutdoors) {
              months.addAll(a.months);
            }
          }
          return months;
        }();

  final sun = p.sunNeed.toLowerCase();
  final prefersSun = sun.contains('zon') && !sun.contains('schaduw');
  final prefersPartial = sun.contains('half') || sun.contains('schaduw');
  final dryPreferring = p.droughtResistant ||
      p.waterNeed.toLowerCase().contains('weinig') ||
      p.waterNeed.toLowerCase().contains('droog');

  return FlowerTransplantGuide(
    periodLabel: period.isNotEmpty
        ? period
        : (companion?.whenToPlant.trim().isNotEmpty == true
            ? companion!.whenToPlant
            : 'Na de laatste nachtvorst uitplanten.'),
    periodMonths: plantMonths.isNotEmpty ? plantMonths : {4, 5, 6},
    conditions: [
      if (p.frostSensitive) 'Geen nachtvorst.' else 'Mild weer, geen harde vorst.',
      'Bodemtemperatuur boven 10 °C.',
      'Plant heeft 4–6 echte bladeren.',
    ],
    conditionsImage: '$_asset/flower_transplant_conditions.png',
    hardeningSteps: [
      FlowerHardeningStep(label: 'Dag 1', detail: '2 uur buiten'),
      FlowerHardeningStep(label: 'Dag 2', detail: '4 uur buiten'),
      FlowerHardeningStep(label: 'Dag 3', detail: '6 uur buiten'),
      FlowerHardeningStep(label: 'Dag 7', detail: 'Hele dag buiten'),
    ],
    hardeningImage: '$_asset/flower_transplant_hardening.png',
    plantSpacing: p.plantSpacing.isNotEmpty
        ? p.plantSpacing
        : (vegetable.spacingCm > 0
            ? '${vegetable.spacingCm} cm tussen de planten.'
            : 'Ruimte tussen de planten aanhouden.'),
    rowSpacing: p.rowSpacing.isNotEmpty
        ? p.rowSpacing
        : (vegetable.rowSpacingCm > 0
            ? '${vegetable.rowSpacingCm} cm tussen de rijen.'
            : 'Ruimte tussen de rijen aanhouden.'),
    plantingDepth: p.plantingDepth.isNotEmpty
        ? p.plantingDepth
        : 'Op dezelfde diepte als in de pot.',
    plantSpacingImage: '$_asset/flower_transplant_plant_spacing.png',
    rowSpacingImage: '$_asset/flower_transplant_row_spacing.png',
    plantingDepthImage: '$_asset/flower_transplant_planting_depth.png',
    locations: [
      FlowerLocationChip(
        label: 'Zon',
        suitable: prefersSun || !prefersPartial,
        icon: Icons.wb_sunny_outlined,
      ),
      FlowerLocationChip(
        label: 'Halfschaduw',
        suitable: prefersPartial,
        icon: Icons.wb_cloudy_outlined,
      ),
      FlowerLocationChip(
        label: 'Pot',
        suitable: true,
        icon: Icons.local_florist_outlined,
      ),
      FlowerLocationChip(
        label: 'Kas',
        suitable: false,
        icon: Icons.home_outlined,
      ),
      FlowerLocationChip(
        label: 'Volle grond',
        suitable: true,
        icon: Icons.grass_outlined,
      ),
    ],
    soilPrepItems: [
      p.compostAdvice.isNotEmpty
          ? p.compostAdvice
          : 'Compost of organische mest toevoegen.',
      'Grond losmaken en egaliseren.',
      'Onkruid en stenen verwijderen.',
    ],
    soilPrepImage: '$_asset/flower_transplant_soil_prep.png',
    waterItems: dryPreferring
        ? [
            p.waterHow.isNotEmpty
                ? p.waterHow
                : 'Matig water geven na uitplanten.',
            'Voorkom natte voeten.',
          ]
        : [
            p.waterHow.isNotEmpty
                ? p.waterHow
                : 'Direct goed water geven.',
            'Eerste week extra vochtig houden.',
          ],
    waterImage: '$_asset/flower_transplant_water.png',
    supportItems: [
      p.supportAdvice.isNotEmpty
          ? p.supportAdvice
          : 'Controleer of steun nodig is.',
      'Bind voorzichtig indien nodig.',
    ],
    supportImage: '$_asset/flower_transplant_support.png',
    protectionItems: [
      FlowerProtectionItem(label: 'Tegen wind', icon: Icons.air),
      FlowerProtectionItem(label: 'Tegen slakken', icon: Icons.pest_control),
      FlowerProtectionItem(
        label: 'Tegen nachtvorst',
        icon: Icons.ac_unit_outlined,
      ),
      FlowerProtectionItem(
        label: 'Tegen felle zon',
        icon: Icons.wb_sunny_outlined,
      ),
    ],
    protectionImage: '$_asset/flower_transplant_protection.png',
    timeToEstablish: 'De plant heeft meestal 1–2 weken nodig om aan te slaan.',
    timeToEstablishImage: '$_asset/flower_transplant_establish.png',
    timeToGrowth: 'Nieuwe groei zichtbaar na 7–14 dagen.',
    timeToGrowthImage: '$_asset/flower_transplant_first_growth.png',
    mistakes: [
      for (final m in (p.mistakes.isNotEmpty
          ? p.mistakes.take(5)
          : const [
              'Te vroeg buiten zetten — wacht tot er geen nachtvorst meer dreigt.',
              'Niet afharden — laat jonge planten wennen aan buitenlucht.',
              'Te diep planten — zet op dezelfde diepte als in de pot.',
              'Te dicht planten — geef ruimte voor luchtcirculatie.',
            ]))
        FlowerMistakeItem(
          title: m.contains('—') ? m.split('—').first.trim() : m,
          body: m.contains('—') ? m.split('—').skip(1).join('—').trim() : m,
        ),
    ],
    mistakesImage: '$_asset/flower_transplant_mistakes.png',
    vegetable: vegetable,
  );
}

String _rowSectionValue(PlantTransplantGuide guide, String title) {
  for (final row in guide.rows) {
    for (final section in row.sections) {
      if (section.title == title) {
        return section.summary?.trim() ?? '';
      }
    }
  }
  return '';
}
