import '../models/vegetable.dart';
import 'flower_card_summaries.dart';
import 'flower_guide_profiles.dart';
import 'flower_section_details.dart';
import 'plant_guide_detail.dart';

const _asset = 'assets/images/flower_problems';

class FlowerProblemChip {
  const FlowerProblemChip({required this.label, required this.imageAsset});

  final String label;
  final String imageAsset;
}

class FlowerProblemSection {
  const FlowerProblemSection({
    required this.title,
    required this.body,
    required this.imageAsset,
    this.chips = const [],
    this.details = const [],
  });

  final String title;
  final String body;
  final String imageAsset;
  final List<FlowerProblemChip> chips;
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage => details.isNotEmpty;
}

class FlowerProblemsGuideData {
  const FlowerProblemsGuideData({
    required this.intro,
    required this.sections,
    required this.tip,
    required this.tipImage,
  });

  final String intro;
  final List<FlowerProblemSection> sections;
  final String tip;
  final String tipImage;
}

/// @Deprecated Prefer [flowerProblemsGuideForVegetable].
const flowerProblemsGuideData = FlowerProblemsGuideData(
  intro: 'Herken problemen op tijd en pak ze effectief aan.',
  sections: [],
  tip: 'Controleer je plant regelmatig en handel op tijd.',
  tipImage: '$_asset/flower_problems_tip.png',
);

String _chipSlug(String label) {
  return label
      .toLowerCase()
      .replaceAll('ë', 'e')
      .replaceAll('é', 'e')
      .replaceAll('&', '')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_|_$'), '');
}

FlowerProblemChip _chip(String label, {String? asset}) {
  final slug = _chipSlug(label);
  return FlowerProblemChip(
    label: label,
    imageAsset: asset ?? '$_asset/fp_chip_$slug.png',
  );
}

List<FlowerProblemChip> _chipsFrom(List<String> labels, List<FlowerProblemChip> fallback) {
  if (labels.isEmpty) return fallback;
  return [for (final l in labels.take(6)) _chip(l)];
}

List<PlantGuideDetailBlock> _pd(
  Vegetable v,
  FlowerGuideProfile p,
  String title,
) =>
    flowerSectionDetailsFor(
      tab: 'problems',
      title: title,
      vegetable: v,
      profile: p,
    );

FlowerProblemsGuideData flowerProblemsGuideForVegetable(Vegetable v) {
  final p = flowerGuideProfileFor(v.id);
  final name = v.nameNl.split('(').first.trim();
  final pestChips = _chipsFrom(
    p.pests,
    const [
      FlowerProblemChip(
        label: 'Bladluizen',
        imageAsset: '$_asset/fp_chip_aphids.png',
      ),
      FlowerProblemChip(
        label: 'Slakken',
        imageAsset: '$_asset/fp_chip_slugs.png',
      ),
      FlowerProblemChip(
        label: 'Spint',
        imageAsset: '$_asset/fp_chip_spider_mite.png',
      ),
      FlowerProblemChip(
        label: 'Rupsen',
        imageAsset: '$_asset/fp_chip_caterpillars.png',
      ),
    ],
  );
  final diseaseChips = _chipsFrom(
    p.diseases,
    const [
      FlowerProblemChip(
        label: 'Meeldauw',
        imageAsset: '$_asset/fp_chip_mildew.png',
      ),
      FlowerProblemChip(
        label: 'Botrytis',
        imageAsset: '$_asset/fp_chip_botrytis.png',
      ),
      FlowerProblemChip(
        label: 'Wortelrot',
        imageAsset: '$_asset/fp_chip_root_rot.png',
      ),
      FlowerProblemChip(
        label: 'Bladvlekken',
        imageAsset: '$_asset/fp_chip_leaf_spots.png',
      ),
    ],
  );
  final mistakeBody = p.mistakes.isNotEmpty
      ? 'Let vooral op: ${p.mistakes.take(3).join('; ')}.'
      : 'Voorkom stress door juiste standplaats, watergift en luchtcirculatie.';

  String sum(String title) => flowerCardSummaryFor(
        tab: 'problems',
        title: title,
        vegetable: v,
        profile: p,
      );

  final guide = FlowerProblemsGuideData(
    intro:
        'Herken problemen bij $name op tijd en pak ze effectief aan voor een '
        'gezonde plant.',
    sections: [
      FlowerProblemSection(
        title: 'Symptomen herkennen',
        body:
            'Geel blad, vlekken of slapte? Leer de signalen van $name lezen en grijp op tijd in.',
        imageAsset: '$_asset/flower_problems_symptoms.png',
        chips: const [
          FlowerProblemChip(
            label: 'Gele bladeren',
            imageAsset: '$_asset/fp_chip_yellow_leaves.png',
          ),
          FlowerProblemChip(
            label: 'Bruine bladeren',
            imageAsset: '$_asset/fp_chip_brown_leaves.png',
          ),
          FlowerProblemChip(
            label: 'Vlekken',
            imageAsset: '$_asset/fp_chip_spots.png',
          ),
          FlowerProblemChip(
            label: 'Verwelking',
            imageAsset: '$_asset/fp_chip_wilting.png',
          ),
        ],
        details: _pd(v, p, 'Symptomen herkennen'),
      ),
      FlowerProblemSection(
        title: 'Insecten & plagen',
        body: p.pests.isNotEmpty
            ? 'Bij $name komen vooral voor: ${p.pests.join(', ')}. '
                'Controleer regelmatig blad en stengels.'
            : 'Controleer $name regelmatig op bladluis, slakken en andere vreterij.',
        imageAsset: '$_asset/flower_problems_pests.png',
        chips: pestChips,
        details: _pd(v, p, 'Insecten & plagen'),
      ),
      FlowerProblemSection(
        title: 'Schimmels & ziekten',
        body: p.diseases.isNotEmpty
            ? 'Mogelijke ziekten bij $name: ${p.diseases.join(', ')}. '
                'Voorkom nat blad en zorg voor lucht.'
            : 'Nat blad en slechte lucht zijn de vijanden — houd $name droog en luchtig.',
        imageAsset: '$_asset/flower_problems_fungi.png',
        chips: diseaseChips,
        details: _pd(v, p, 'Schimmels & ziekten'),
      ),
      FlowerProblemSection(
        title: 'Voedingstekorten',
        body:
            'Geel of paars blad bij $name? Mogelijk mist de plant stikstof, fosfor of kalium.',
        imageAsset: '$_asset/flower_problems_nutrients.png',
        chips: const [
          FlowerProblemChip(
            label: 'Stikstof',
            imageAsset: '$_asset/fp_chip_nitrogen.png',
          ),
          FlowerProblemChip(
            label: 'Fosfor',
            imageAsset: '$_asset/fp_chip_phosphorus.png',
          ),
          FlowerProblemChip(
            label: 'Kalium',
            imageAsset: '$_asset/fp_chip_potassium.png',
          ),
          FlowerProblemChip(
            label: 'Magnesium',
            imageAsset: '$_asset/fp_chip_magnesium.png',
          ),
        ],
        details: _pd(v, p, 'Voedingstekorten'),
      ),
      FlowerProblemSection(
        title: 'Waterproblemen',
        body:
            'Te veel of te weinig water (${p.waterNeed}) kan problemen geven '
            'bij $name. Leer de signalen herkennen.',
        imageAsset: '$_asset/flower_problems_water.png',
        chips: const [
          FlowerProblemChip(
            label: 'Te veel water',
            imageAsset: '$_asset/fp_chip_too_much_water.png',
          ),
          FlowerProblemChip(
            label: 'Te weinig water',
            imageAsset: '$_asset/fp_chip_too_little_water.png',
          ),
          FlowerProblemChip(
            label: 'Slechte drainage',
            imageAsset: '$_asset/fp_chip_poor_drainage.png',
          ),
          FlowerProblemChip(
            label: 'Waterstress',
            imageAsset: '$_asset/fp_chip_water_stress.png',
          ),
        ],
        details: _pd(v, p, 'Waterproblemen'),
      ),
      FlowerProblemSection(
        title: 'Weerproblemen',
        body: p.frostSensitive
            ? '$name is vorstgevoelig — pas op voor IJsheiligen (half mei) en late nachtvorst. Natte winters, hittegolven en stormwind geven extra stress.'
            : '$name is redelijk winterhard, maar natte NL-winters, plotse hittegolven en zware stormwind kunnen alsnog schade geven.',
        imageAsset: '$_asset/flower_problems_weather.png',
        chips: const [
          FlowerProblemChip(
            label: 'IJsheiligen / late vorst',
            imageAsset: '$_asset/fp_chip_frost_damage.png',
          ),
          FlowerProblemChip(
            label: 'Natte winters',
            imageAsset: '$_asset/fp_chip_long_rain.png',
          ),
          FlowerProblemChip(
            label: 'Hittegolven',
            imageAsset: '$_asset/fp_chip_heat.png',
          ),
          FlowerProblemChip(
            label: 'Stormwind',
            imageAsset: '$_asset/fp_chip_wind_damage.png',
          ),
        ],
        details: _pd(v, p, 'Weerproblemen'),
      ),
      FlowerProblemSection(
        title: 'Groeiproblemen',
        body: mistakeBody,
        imageAsset: '$_asset/flower_problems_growth.png',
        chips: const [
          FlowerProblemChip(
            label: 'Langzame groei',
            imageAsset: '$_asset/fp_chip_slow_growth.png',
          ),
          FlowerProblemChip(
            label: 'Zwakke plant',
            imageAsset: '$_asset/fp_chip_weak_plant.png',
          ),
          FlowerProblemChip(
            label: 'Geen groei',
            imageAsset: '$_asset/fp_chip_no_growth.png',
          ),
          FlowerProblemChip(
            label: 'Misvormde plant',
            imageAsset: '$_asset/fp_chip_deformed_plant.png',
          ),
        ],
        details: _pd(v, p, 'Groeiproblemen'),
      ),
      FlowerProblemSection(
        title: 'Problemen in potten',
        body: p.potAdvice.isNotEmpty
            ? p.potAdvice
            : 'In pot heeft $name vaker water- en voedingstekort; zorg voor drainage.',
        imageAsset: '$_asset/flower_problems_pots.png',
        chips: const [
          FlowerProblemChip(
            label: 'Wortelgebonden',
            imageAsset: '$_asset/fp_chip_rootbound.png',
          ),
          FlowerProblemChip(
            label: 'Uitdroging',
            imageAsset: '$_asset/fp_chip_dehydration.png',
          ),
          FlowerProblemChip(
            label: 'Te kleine pot',
            imageAsset: '$_asset/fp_chip_small_pot.png',
          ),
        ],
        details: _pd(v, p, 'Problemen in potten'),
      ),
      FlowerProblemSection(
        title: 'Problemen voorkomen',
        body:
            'Voorkomen is beter dan genezen: geef $name ${p.sunNeed.toLowerCase()}, water naar behoefte (${p.waterNeed.toLowerCase()}) en voldoende lucht.',
        imageAsset: '$_asset/flower_problems_prevention.png',
        chips: const [
          FlowerProblemChip(
            label: 'Wisselen van plek',
            imageAsset: '$_asset/fp_chip_crop_rotation.png',
          ),
          FlowerProblemChip(
            label: 'Goede luchtcirculatie',
            imageAsset: '$_asset/fp_chip_air_circulation.png',
          ),
          FlowerProblemChip(
            label: 'Correct water geven',
            imageAsset: '$_asset/fp_chip_correct_watering.png',
          ),
          FlowerProblemChip(
            label: 'Gezonde bodem',
            imageAsset: '$_asset/fp_chip_healthy_soil.png',
          ),
        ],
        details: _pd(v, p, 'Problemen voorkomen'),
      ),
      FlowerProblemSection(
        title: 'Natuurlijke bestrijding',
        body:
            'Lieveheersbeestjes, gaasvliegen en slim combineren — bestrijdt plagen bij $name zonder gif.',
        imageAsset: '$_asset/flower_problems_biocontrol.png',
        chips: const [
          FlowerProblemChip(
            label: 'Lieveheersbeestjes',
            imageAsset: '$_asset/fp_chip_ladybugs.png',
          ),
          FlowerProblemChip(
            label: 'Gaasvliegen',
            imageAsset: '$_asset/fp_chip_lacewings.png',
          ),
          FlowerProblemChip(
            label: 'Biologische middelen',
            imageAsset: '$_asset/fp_chip_bio_agents.png',
          ),
          FlowerProblemChip(
            label: 'Companion planting',
            imageAsset: '$_asset/fp_chip_companion_planting.png',
          ),
        ],
        details: _pd(v, p, 'Natuurlijke bestrijding'),
      ),
      FlowerProblemSection(
        title: 'Eerste hulp voor planten',
        body:
            '$name hangt slap of verkleurt? Check meteen water, licht en de onderkant van het blad.',
        imageAsset: '$_asset/flower_problems_first_aid.png',
        chips: const [
          FlowerProblemChip(
            label: 'Plant hangt slap',
            imageAsset: '$_asset/fp_chip_drooping.png',
          ),
          FlowerProblemChip(
            label: 'Gele bladeren',
            imageAsset: '$_asset/fp_chip_yellow_leaves.png',
          ),
          FlowerProblemChip(
            label: 'Bruine vlekken',
            imageAsset: '$_asset/fp_chip_spots.png',
          ),
          FlowerProblemChip(
            label: 'Groei stopt',
            imageAsset: '$_asset/fp_chip_no_growth.png',
          ),
        ],
        details: _pd(v, p, 'Eerste hulp voor planten'),
      ),
    ],
    tip: p.tip.isNotEmpty
        ? p.tip
        : 'Controleer $name regelmatig en handel op tijd. Een gezonde plant '
            'is beter bestand tegen problemen!',
    tipImage: '$_asset/flower_problems_tip.png',
  );

  return FlowerProblemsGuideData(
    intro: guide.intro,
    sections: [
      for (final s in guide.sections)
        FlowerProblemSection(
          title: s.title,
          body: sum(s.title),
          imageAsset: s.imageAsset,
          chips: s.chips,
          details: s.details,
        ),
    ],
    tip: guide.tip,
    tipImage: guide.tipImage,
  );
}
