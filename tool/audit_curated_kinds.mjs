import fs from 'fs';

const groups = fs.readFileSync('lib/data/vegetable_groups.dart', 'utf8');
const sow = fs.readFileSync('lib/data/plant_sowing_guide_entries.dart', 'utf8');
const sowIds = [...sow.matchAll(/^  '([^']+)': PlantSowingGuide/gm)].map((m) => m[1]);

function idsInGroup(groupId) {
  const re = new RegExp(`id: '${groupId}'[\\s\\S]*?vegetableIds: \\[([\\s\\S]*?)\\],`, 'm');
  const m = groups.match(re);
  if (!m) return [];
  return [...m[1].matchAll(/'([^']+)'/g)].map((x) => x[1]);
}

const flowerIds = new Set([
  ...idsInGroup('moestuin_bloemen'),
  ...idsInGroup('bloemen_zaden'),
]);
const mushroomIds = new Set(idsInGroup('paddenstoelen'));

const curatedFlowers = sowIds.filter((id) => flowerIds.has(id));
const curatedMushrooms = sowIds.filter((id) => mushroomIds.has(id));
const curatedEdible = sowIds.filter((id) => !flowerIds.has(id) && !mushroomIds.has(id));

console.log(JSON.stringify({
  curatedTotal: sowIds.length,
  curatedEdible: curatedEdible.length,
  curatedFlowers: curatedFlowers.length,
  curatedMushrooms: curatedMushrooms.length,
  flowerInCuratedSample: curatedFlowers.slice(0, 5),
}, null, 2));
