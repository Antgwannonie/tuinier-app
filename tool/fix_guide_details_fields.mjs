import fs from 'fs';

const jobs = [
  {
    file: 'lib/data/plant_water_guide.dart',
    anchor: 'final bool illustrationFirst;',
  },
  {
    file: 'lib/data/plant_nutrition_guide.dart',
    anchor: 'final bool recommended;',
  },
  {
    file: 'lib/data/plant_growth_guide.dart',
    anchor: 'final List<GrowthStimulateFactor>? stimulateFactors;',
  },
  {
    file: 'lib/data/plant_harvest_guide.dart',
    anchor: 'final List<HarvestOption>? edibleParts;',
  },
  {
    file: 'lib/data/plant_care_guide.dart',
    anchor: 'final List<CareIconOption>? iconOptions;',
  },
];

for (const { file, anchor } of jobs) {
  let s = fs.readFileSync(file, 'utf8');

  // Remove weird "\r," lines before this.details
  s = s.replace(/\r,\r?\n(\s*)this\.details/g, '\n$1this.details');
  s = s.replace(/,\r\n(\s*),\r\n(\s*)this\.details/g, ',\n$2this.details');

  if (!s.includes("import 'plant_guide_detail.dart';")) {
    const firstNl = s.indexOf('\n');
    s =
      s.slice(0, firstNl + 1) +
      "import 'plant_guide_detail.dart';\nimport 'plant_section_details.dart';\n" +
      s.slice(firstNl + 1);
  } else if (!s.includes("import 'plant_section_details.dart';")) {
    s = s.replace(
      "import 'plant_guide_detail.dart';\n",
      "import 'plant_guide_detail.dart';\nimport 'plant_section_details.dart';\n",
    );
  }

  if (!s.includes('final List<PlantGuideDetailBlock> details;')) {
    if (!s.includes(anchor)) {
      console.log('ANCHOR MISSING', file);
    } else {
      s = s.replace(
        anchor,
        `${anchor}
  final List<PlantGuideDetailBlock> details;

  bool get hasDetailPage =>
      title.isNotEmpty && details.isNotEmpty;`,
      );
    }
  }

  fs.writeFileSync(file, s);
  console.log(file, {
    field: s.includes('final List<PlantGuideDetailBlock> details;'),
    imports: s.includes('plant_section_details.dart'),
  });
}
