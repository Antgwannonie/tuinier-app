import fs from 'fs';

// Parse flower/mushroom ids from dart source (simple grep patterns)
const filters = fs.readFileSync('lib/data/plant_search_filters.dart', 'utf8');
const mushroomMatch = filters.match(/final Set<String> kMushroomPlantIds = _plantIdsInGroups\(_kMushroomGroupIds\);/);
const flowerIds = new Set();
for (const m of filters.matchAll(/groups\.contains\('moestuin_bloemen'\)/g)) {}
// flower detection: isFlowerGuidePlant checks moestuin_bloemen, bloemen_zaden, companion

// Load all vegetable ids from catalog files via simple id: 'xxx' pattern in seed sources
const catalogFiles = [
  'lib/data/my_garden_plants.dart',
  'lib/data/extra_reference_vegetables.dart',
  'lib/data/new_atlas_vegetables.dart',
  'lib/data/expanded_fruit_and_plants.dart',
  'lib/data/nl_common_plants_bulk.dart',
  'lib/data/new_garden_varieties.dart',
  'lib/data/moestuin_companion_plants.dart',
];
const allIds = new Set();
for (const f of catalogFiles) {
  const text = fs.readFileSync(f, 'utf8');
  for (const m of text.matchAll(/\bid: '([^']+)'/g)) allIds.add(m[1]);
}

const sow = fs.readFileSync('lib/data/plant_sowing_guide_entries.dart', 'utf8');
const sowIds = new Set([...sow.matchAll(/^  '([^']+)': PlantSowingGuide/gm)].map((m) => m[1]));

// Flower ids from kFlowerPlantIds + companion - read group data
const flowerGroupIds = ['moestuin_bloemen', 'bloemen_zaden'];
const groupsText = fs.readFileSync('lib/data/plant_search_filters.dart', 'utf8');
// Extract vegetable ids in flower groups from kVegetableGroups - too complex; use isFlower heuristic from groups map
const groupsMap = fs.readFileSync('lib/data/vegetable_groups.dart', 'utf8');
const flowerPlantIds = new Set();
for (const gid of ['moestuin_bloemen', 'bloemen_zaden', 'companion_garden']) {
  const re = new RegExp(`id: '${gid}'[\\s\\S]*?vegetableIds: \\[([\\s\\S]*?)\\]`, 'm');
  const m = groupsMap.match(re);
  if (m) {
    for (const id of m[1].matchAll(/'([^']+)'/g)) flowerPlantIds.add(id[1]);
  }
}

const mushroomIds = new Set();
const mushRe = /_kMushroomGroupIds = \[([\s\S]*?)\];/;
const mushGroups = groupsText.match(mushRe)?.[1]?.matchAll(/'([^']+)'/g) || [];
for (const g of mushGroups) {
  const re = new RegExp(`id: '${g[1]}'[\\s\\S]*?vegetableIds: \\[([\\s\\S]*?)\\]`, 'm');
  const m = groupsMap.match(re);
  if (m) for (const id of m[1].matchAll(/'([^']+)'/g)) mushroomIds.add(id[1]);
}

const edible = [...allIds].filter((id) => !flowerPlantIds.has(id) && !mushroomIds.has(id));
const missingSowing = edible.filter((id) => !sowIds.has(id));

console.log(JSON.stringify({
  totalCatalogIds: allIds.size,
  edibleEstimate: edible.length,
  flowerEstimate: flowerPlantIds.size,
  mushroomEstimate: mushroomIds.size,
  curatedSowing: sowIds.size,
  edibleMissingSowingGuide: missingSowing.length,
  missingSowingSample: missingSowing.slice(0, 20),
}, null, 2));
