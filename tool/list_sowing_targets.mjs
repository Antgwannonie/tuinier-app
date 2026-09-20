import fs from 'fs';

const groups = fs.readFileSync('lib/data/vegetable_groups.dart', 'utf8');

function groupIds(gid) {
  const r = new RegExp(
    `id:\\s*'${gid}'[\\s\\S]*?vegetableIds:\\s*\\[([\\s\\S]*?)\\]`,
  );
  const m = groups.match(r);
  if (!m) return [];
  return (m[1].match(/'([^']+)'/g) || []).map((s) => s.slice(1, -1));
}

const allIds = [];
for (const m of groups.matchAll(/vegetableIds:\s*\[([\s\S]*?)\]/g)) {
  for (const id of m[1].match(/'([^']+)'/g) || []) {
    allIds.push(id.slice(1, -1));
  }
}
const unique = [...new Set(allIds)];

const mushrooms = new Set(groupIds('paddestoelen'));
const flowers = new Set([
  ...groupIds('bloemen_zaden'),
  ...groupIds('moestuin_bloemen'),
]);

let companions = new Set();
try {
  const c = fs.readFileSync('lib/data/moestuin_companion_plants.dart', 'utf8');
  for (const id of c.match(/'([a-z0-9_]+)'/g) || []) {
    companions.add(id.slice(1, -1));
  }
} catch {
  /* ignore */
}

// Flower-guide plants = flowers + companions used as flower UI
const flowerGuide = new Set([...flowers, ...companions]);
const need = [...new Set(unique.filter((id) => !mushrooms.has(id) && !flowerGuide.has(id)))];

console.log(
  JSON.stringify(
    {
      totalUnique: unique.length,
      mushrooms: mushrooms.size,
      flowerGuide: flowerGuide.size,
      need: need.length,
      sample: need.slice(0, 50),
    },
    null,
    2,
  ),
);
fs.writeFileSync('tool/sowing_target_ids.json', JSON.stringify(need, null, 2));
