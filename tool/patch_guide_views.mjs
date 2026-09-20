/**
 * Voegt wrapGuideDetailCard toe aan guide views.
 * Verwacht dat sections `.title`, `.summary`, `.details` hebben.
 */
import fs from 'fs';

const views = [
  {
    file: 'lib/widgets/plant_encyclopedia/plant_nutrition_guide_view.dart',
    sectionType: 'PlantNutritionSection',
    wrapName: '_wrapNutritionCard',
    guideImport: '../../data/plant_nutrition_guide.dart',
  },
  {
    file: 'lib/widgets/plant_encyclopedia/plant_growth_guide_view.dart',
    sectionType: 'PlantGrowthSection',
    wrapName: '_wrapGrowthCard',
    guideImport: '../../data/plant_growth_guide.dart',
  },
  {
    file: 'lib/widgets/plant_encyclopedia/plant_bloom_guide_view.dart',
    sectionType: 'PlantBloomSection',
    wrapName: '_wrapBloomCard',
    guideImport: '../../data/plant_bloom_guide.dart',
  },
  {
    file: 'lib/widgets/plant_encyclopedia/plant_harvest_guide_view.dart',
    sectionType: 'PlantHarvestSection',
    wrapName: '_wrapHarvestCard',
    guideImport: '../../data/plant_harvest_guide.dart',
  },
  {
    file: 'lib/widgets/plant_encyclopedia/plant_care_guide_view.dart',
    sectionType: 'PlantCareSection',
    wrapName: '_wrapCareCard',
    guideImport: '../../data/plant_care_guide.dart',
  },
];

for (const v of views) {
  let s = fs.readFileSync(v.file, 'utf8');
  if (s.includes(v.wrapName)) {
    console.log('skip', v.file);
    continue;
  }

  if (!s.includes('plant_guide_detail_screen.dart')) {
    s = s.replace(
      /import 'plant_detail_widgets\.dart';\n/,
      "import 'plant_detail_widgets.dart';\nimport 'plant_guide_detail_screen.dart';\n",
    );
  }

  const wrapFn = `
Widget ${v.wrapName}(
  BuildContext context,
  ${v.sectionType} section,
  Widget child,
) {
  return PlantDetailCard(
    child: wrapGuideDetailCard(
      context: context,
      title: section.title,
      summary: section.summary ?? section.subtitle,
      details: section.details,
      child: child,
    ),
  );
}
`;

  // Insert wrap function after imports / before first class
  s = s.replace(
    /(import .+;\n)\n(class )/,
    `$1\n${wrapFn}\n$2`,
  );

  // Replace PlantDetailCard( child: XXX(section: row.sections.first
  // with wrap — too fragile. Instead replace:
  // return PlantDetailCard(\n          child:
  // when followed soon by section: row.sections.first

  // Simpler: replace all `PlantDetailCard(` that wrap section content
  // with a comment instructing - actually do:
  s = s.replace(
    /return PlantDetailCard\(\s*child: /g,
    `return ${v.wrapName}(\n          context,\n          row.sections.first,\n          `,
  );

  // This breaks closing parens - PlantDetailCard( child: X ) becomes wrap(ctx, sec, X ) 
  // which needs one less closing for PlantDetailCard - the original `);` still closes wrap. OK if only one level.

  // Fix columns that use sections[i]:
  s = s.replace(
    /PlantDetailCard\(\s*child: /g,
    `${v.wrapName}(\n              context,\n              sections[i],\n              `,
  );

  fs.writeFileSync(v.file, s);
  console.log('patched', v.file);
}
