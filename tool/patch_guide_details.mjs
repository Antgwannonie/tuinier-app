/**
 * Voegt details-veld + sectionDetailsFor-wrapper toe aan plant guides.
 * Run: node tool/patch_guide_details.mjs
 */
import fs from 'fs';

const guides = [
  {
    file: 'lib/data/plant_water_guide.dart',
    section: 'PlantWaterSection',
    guide: 'PlantWaterGuide',
    forFn: 'waterGuideForVegetable',
    buildFn: '_buildWaterGuide',
    tab: 'water',
    row: 'PlantWaterRow',
    rowExtras: ['alert'],
  },
  {
    file: 'lib/data/plant_nutrition_guide.dart',
    section: 'PlantNutritionSection',
    guide: 'PlantNutritionGuide',
    forFn: 'nutritionGuideForVegetable',
    buildFn: '_buildNutritionGuide',
    tab: 'nutrition',
    row: 'PlantNutritionRow',
    rowExtras: [],
  },
  {
    file: 'lib/data/plant_growth_guide.dart',
    section: 'PlantGrowthSection',
    guide: 'PlantGrowthGuide',
    forFn: 'growthGuideForVegetable',
    buildFn: '_buildGrowthGuide',
    tab: 'growth',
    row: 'PlantGrowthRow',
    rowExtras: [],
  },
  {
    file: 'lib/data/plant_bloom_guide.dart',
    section: 'PlantBloomSection',
    guide: 'PlantBloomGuide',
    forFn: 'bloomGuideForVegetable',
    buildFn: '_buildBloomGuide',
    tab: 'bloom',
    row: 'PlantBloomRow',
    rowExtras: [],
  },
  {
    file: 'lib/data/plant_harvest_guide.dart',
    section: 'PlantHarvestSection',
    guide: 'PlantHarvestGuide',
    forFn: 'harvestGuideForVegetable',
    buildFn: '_buildHarvestGuide',
    tab: 'harvest',
    row: 'PlantHarvestRow',
    rowExtras: [],
  },
  {
    file: 'lib/data/plant_care_guide.dart',
    section: 'PlantCareSection',
    guide: 'PlantCareGuide',
    forFn: 'careGuideForVegetable',
    buildFn: '_buildCareGuide',
    tab: 'care',
    row: 'PlantCareRow',
    rowExtras: [],
  },
  {
    file: 'lib/data/plant_weetjes_guide.dart',
    section: 'PlantWeetjesSection',
    guide: 'PlantWeetjesGuide',
    forFn: 'weetjesGuideForVegetable',
    buildFn: '_buildWeetjesGuide',
    tab: 'weetjes',
    row: 'PlantWeetjesRow',
    rowExtras: [],
  },
];

function ensureImports(src) {
  if (!src.includes("import 'plant_section_details.dart';")) {
    const line = "import 'plant_guide_detail.dart';\nimport 'plant_section_details.dart';\n";
    if (src.includes("import 'plant_guide_detail.dart';")) {
      src = src.replace(
        "import 'plant_guide_detail.dart';\n",
        line,
      );
    } else {
      src = src.replace(/(import '[^']+';\n)/, `$1${line}`);
    }
  }
  return src;
}

function addDetailsToSection(src, sectionName) {
  if (src.includes('final List<PlantGuideDetailBlock> details;') &&
      src.includes('this.details = const []')) {
    return src;
  }

  // Insert constructor param
  const ctorRe = new RegExp(
    `(const ${sectionName}\\(\\{)([\\s\\S]*?)(\\n  \\}\\);)`,
  );
  src = src.replace(ctorRe, (full, start, body, end) => {
    if (body.includes('this.details')) return full;
    const trimmed = body.replace(/\s+$/, '');
    const needsComma = /(?:this\.[\w]+|required this\.[\w]+)\s*$/.test(
      trimmed.trim().split('\n').pop().replace(/,$/, '') + ',',
    );
    // always add comma before details
    return `${start}${body.replace(/\n\s*$/, '')},\n    this.details = const [],${end}`;
  });

  // Insert field + getter before class closing — find section class body end
  const classStart = src.indexOf(`class ${sectionName} `);
  if (classStart < 0) return src;
  // Find matching closing brace of class: after constructor and fields, before next top-level enum/class
  const afterClass = src.slice(classStart);
  const nextTop = afterClass.search(/\n\}\n\n(enum |class |typedef )/);
  if (nextTop < 0) {
    console.warn('class end not found', sectionName);
    return src;
  }
  const classChunk = afterClass.slice(0, nextTop);
  if (classChunk.includes('final List<PlantGuideDetailBlock> details;')) {
    return src;
  }
  const insertion = `\n  final List<PlantGuideDetailBlock> details;\n\n  bool get hasDetailPage =>\n      title.isNotEmpty && details.isNotEmpty;`;
  const newChunk = classChunk + insertion;
  src = src.slice(0, classStart) + newChunk + afterClass.slice(nextTop);
  return src;
}

function wrapForFunction(src, cfg) {
  if (src.includes(`sectionDetailsFor(tab: '${cfg.tab}'`)) {
    console.log('already wrapped', cfg.forFn);
    return src;
  }

  // Extract this.field names from section constructor
  const ctor = src.match(
    new RegExp(`const ${cfg.section}\\(\\{([\\s\\S]*?)\\n  \\}\\);`),
  );
  if (!ctor) {
    console.warn('ctor missing', cfg.section);
    return src;
  }
  const params = [...ctor[1].matchAll(/this\.(\w+)/g)].map((m) => m[1]);
  const copyParams = params.filter((p) => p !== 'details');

  const copyLines = copyParams
    .map((p) => `                ${p}: s.${p},`)
    .join('\n');

  // Detect row constructor optional named params beyond kind/sections
  const rowCtor = src.match(
    new RegExp(`const ${cfg.row}\\(\\{([\\s\\S]*?)\\n  \\}\\);`),
  );
  const rowParams = rowCtor
    ? [...rowCtor[1].matchAll(/(?:required )?this\.(\w+)/g)].map((m) => m[1])
    : ['kind', 'sections'];
  const rowExtraLines = rowParams
    .filter((p) => p !== 'kind' && p !== 'sections')
    .map((p) => `          ${p}: row.${p},`)
    .join('\n');

  const wrapper = `${cfg.forFn}(Vegetable vegetable) {
  final built = ${cfg.buildFn}(vegetable);
  return ${cfg.guide}(
    rows: [
      for (final row in built.rows)
        ${cfg.row}(
          kind: row.kind,
${rowExtraLines ? `${rowExtraLines}\n` : ''}          sections: [
            for (final s in row.sections)
              ${cfg.section}(
${copyLines}
                details: s.title.isEmpty
                    ? const <PlantGuideDetailBlock>[]
                    : sectionDetailsFor(
                        tab: '${cfg.tab}',
                        title: s.title,
                        vegetable: vegetable,
                      ),
              ),
          ],
        ),
    ],
  );
}`;

  const forRe = new RegExp(
    `${cfg.forFn}\\(Vegetable vegetable\\) \\{[\\s\\S]*?return ${cfg.buildFn}\\(vegetable\\);\\s*\\}`,
  );
  if (!forRe.test(src)) {
    console.warn('forFn not matched', cfg.forFn);
    return src;
  }
  return src.replace(forRe, wrapper);
}

for (const cfg of guides) {
  let src = fs.readFileSync(cfg.file, 'utf8');
  src = ensureImports(src);
  src = addDetailsToSection(src, cfg.section);
  src = wrapForFunction(src, cfg);
  fs.writeFileSync(cfg.file, src);
  console.log('OK', cfg.file);
}
