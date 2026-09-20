import fs from 'fs';

const j = JSON.parse(fs.readFileSync('tool/vegetable_overview_all.json', 'utf8'));
const flower = fs.readFileSync('lib/data/flower_overview_facts_map.dart', 'utf8');
const mush = fs.readFileSync('lib/data/mushroom_overview_data.dart', 'utf8');

function groupBy(items, keyFn) {
  const m = new Map();
  for (const item of items) {
    const k = keyFn(item);
    if (!k) continue;
    if (!m.has(k)) m.set(k, []);
    m.get(k).push(item.id || item);
  }
  return [...m.entries()].filter(([, ids]) => ids.length > 1);
}

// —— Vegetables ——
const vegItems = Object.entries(j).map(([id, o]) => ({ id, ...o }));
const vegDupSummary = groupBy(vegItems, (o) => o.summary?.trim());
const vegDupKnow = groupBy(vegItems, (o) => o.know?.trim());
const vegDupDetail = groupBy(vegItems, (o) => o.yield_detail?.trim());
const vegDupFingerprint = groupBy(vegItems, (o) =>
  JSON.stringify({
    s: o.summary,
    k: o.know,
    p: o.points,
    st: o.standplaats,
    w: o.water,
    d: o.difficulty,
    l: o.lifespan,
    h: o.height,
    first: o.first,
  }),
);

// near-duplicates: same summary first 40 chars among different families
const near = groupBy(vegItems, (o) => (o.summary || '').slice(0, 55).trim());

console.log('=== VEG exact fingerprint dups ===');
for (const [fp, ids] of vegDupFingerprint) {
  console.log(ids.length, ids.join(', '));
}
console.log('\n=== VEG same summary ===');
for (const [s, ids] of vegDupSummary.sort((a, b) => b[1].length - a[1].length)) {
  console.log(ids.length, ids.join(', '));
  console.log(' ', s.slice(0, 100));
}
console.log('\n=== VEG same know (>=3) ===');
for (const [s, ids] of vegDupKnow.filter((x) => x[1].length >= 3)) {
  console.log(ids.length, ids.join(', '));
  console.log(' ', s.slice(0, 100));
}
console.log('\n=== VEG same yield_detail (>=4) ===');
for (const [s, ids] of vegDupDetail.filter((x) => x[1].length >= 4)) {
  console.log(ids.length, ids.join(', '));
  console.log(' ', s.slice(0, 100));
}
console.log('\n=== VEG near summary prefix (>=3) ===');
for (const [s, ids] of near.filter((x) => x[1].length >= 3)) {
  console.log(ids.length, ids.join(', '));
  console.log(' ', s);
}

// —— Flowers: extract summary + tip per id ——
const flowerIds = [...flower.matchAll(/'([a-z_]+)': _FlowerFacts\(/g)].map((m) => m[1]);
const flowerFacts = flowerIds.map((id, i) => {
  const start = flower.indexOf(`'${id}': _FlowerFacts(`);
  const next = flowerIds[i + 1];
  const end = next ? flower.indexOf(`'${next}': _FlowerFacts(`) : flower.length;
  const block = flower.slice(start, end);
  const summary =
    block.match(/summary:\s*'((?:\\'|[^'])*)'/)?.[1] ||
    block.match(/summary:\s*((?:'[^\n]*'\s*)+)/)?.[1];
  const tip = block.match(/tip:\s*'((?:\\'|[^'])*)'/)?.[1];
  const lifespan = block.match(/lifespan:\s*'([^']+)'/)?.[1];
  const height = block.match(/height:\s*'([^']+)'/)?.[1];
  return { id, summary: (summary || '').replace(/\s+/g, ' '), tip, lifespan, height };
});
const fDupSum = groupBy(flowerFacts, (o) => o.summary);
const fDupTip = groupBy(flowerFacts, (o) => o.tip);
console.log('\n=== FLOWER same summary ===');
for (const [s, ids] of fDupSum) {
  console.log(ids.length, ids.join(', '));
  console.log(' ', s.slice(0, 100));
}
console.log('\n=== FLOWER same tip ===');
for (const [s, ids] of fDupTip) {
  console.log(ids.length, ids.join(', '));
  console.log(' ', (s || '').slice(0, 100));
}

// —— Mushrooms ——
const mushIds = [...mush.matchAll(/'([a-z_]+)': _MushroomFacts\(/g)].map((m) => m[1]);
const mushFacts = mushIds.map((id, i) => {
  const start = mush.indexOf(`'${id}': _MushroomFacts(`);
  const next = mushIds[i + 1];
  const end = next ? mush.indexOf(`'${next}': _MushroomFacts(`) : mush.length;
  const block = mush.slice(start, end);
  const summary = block.match(/summary:\s*'((?:\\'|[^'])*)'/)?.[1] ||
    block.match(/summary:\s*((?:'[^\n]*'\s*\+?\s*)+)/)?.[1];
  const good = block.match(/goodToKnow:\s*'((?:\\'|[^'])*)'/)?.[1];
  return {
    id,
    summary: (summary || '').replace(/\s+/g, ' ').replace(/'\s*\+\s*'/g, ''),
    good,
  };
});
console.log('\n=== MUSH same summary ===');
for (const [s, ids] of groupBy(mushFacts, (o) => o.summary)) {
  console.log(ids.length, ids.join(', '));
}
console.log('\n=== MUSH same goodToKnow ===');
for (const [s, ids] of groupBy(mushFacts, (o) => o.good)) {
  console.log(ids.length, ids.join(', '));
  console.log(' ', (s || '').slice(0, 90));
}

console.log('\nCOUNTS', {
  veg: Object.keys(j).length,
  flower: flowerIds.length,
  mush: mushIds.length,
  vegExactDups: vegDupFingerprint.length,
  vegSummaryDups: vegDupSummary.length,
  flowerSummaryDups: fDupSum.length,
  flowerTipDups: fDupTip.length,
});
