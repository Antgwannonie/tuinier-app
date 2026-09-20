import fs from 'fs';

const veg = JSON.parse(
  fs.readFileSync('tool/vegetable_overview_all.json', 'utf8'),
);
const flowerSrc = fs.readFileSync(
  'lib/data/flower_overview_facts_map.dart',
  'utf8',
);
const mushSrc = fs.readFileSync(
  'lib/data/mushroom_overview_data.dart',
  'utf8',
);
const groupsSrc = fs.readFileSync('lib/data/vegetable_groups.dart', 'utf8');

function groupIds(id) {
  const re = new RegExp(
    `VegetableGroup\\(\\s*id:\\s*'${id}'[\\s\\S]*?vegetableIds:\\s*\\[([^\\]]+)\\]`,
  );
  const m = groupsSrc.match(re);
  if (!m) return [];
  return [...m[1].matchAll(/'([^']+)'/g)].map((x) => x[1]);
}

const groenteGroups = [
  'bieten',
  'sla_soorten',
  'bladgroenten',
  'wortelgroenten',
  'tomaten',
  'paprika_peper',
  'komkommer_familie',
  'uien',
  'kolen',
  'aardappel',
  'aubergine',
  'mais',
  'meerjarig',
];
const restGroups = [
  'kruiden',
  'bonen',
  'fruit_bomen',
  'aardbeien',
  'bessen',
  'meloenen',
  'aziatische_groenten',
];
const flowerIds = [
  ...new Set([
    ...groupIds('moestuin_bloemen'),
    ...groupIds('bloemen_zaden'),
  ]),
];
const mushIds = groupIds('paddestoelen');
const expectedVeg = [
  ...new Set([...groenteGroups, ...restGroups].flatMap(groupIds)),
].filter((id) => !flowerIds.includes(id) && !mushIds.includes(id));

const issues = [];
const warn = (msg) => issues.push({ level: 'warn', msg });
const err = (msg) => issues.push({ level: 'error', msg });

// —— Vegetable completeness ——
const vegFields = [
  'sow',
  'plant',
  'harvest',
  'standplaats',
  'water',
  'difficulty',
  'lifespan',
  'outdoor',
  'container',
  'voeding',
  'height',
  'width',
  'habit',
  'spacing',
  'row',
  'first',
  'period',
  'yield_level',
  'yield_detail',
  'points',
  'summary',
  'know',
];
const allowed = {
  standplaats: ['Zon', 'Halfschaduw', 'Schaduw'],
  water: ['Laag', 'Gemiddeld', 'Hoog'],
  difficulty: ['Makkelijk', 'Gemiddeld', 'Moeilijk'],
  lifespan: ['Eenjarig', 'Tweejarig', 'Meerjarig'],
  voeding: ['Laag', 'Gemiddeld', 'Hoog'],
  yield_level: [
    'Hoge opbrengst',
    'Gemiddelde opbrengst',
    'Beperkte opbrengst',
  ],
};

let vegMissing = 0;
for (const id of expectedVeg) {
  const o = veg[id];
  if (!o) {
    err(`GROENTE/REST mist entry: ${id}`);
    vegMissing++;
    continue;
  }
  for (const f of vegFields) {
    if (o[f] === undefined || o[f] === null || o[f] === '') {
      err(`${id}: leeg veld ${f}`);
    }
  }
  for (const [k, vals] of Object.entries(allowed)) {
    if (o[k] && !vals.includes(o[k])) {
      err(`${id}: ongeldige ${k}="${o[k]}"`);
    }
  }
  if (!Array.isArray(o.points) || o.points.length < 3) {
    err(`${id}: points < 3`);
  }
  if (!o.harvest?.length) err(`${id}: geen harvest-maanden`);
  if (!o.sow?.length && !o.plant?.length) {
    warn(`${id}: geen sow én geen plant maanden`);
  }
  for (const m of [...(o.sow || []), ...(o.plant || []), ...(o.harvest || [])]) {
    if (m < 1 || m > 12) err(`${id}: maand buiten 1–12: ${m}`);
  }
  // warm crops should not sow outdoors only in deep winter without plant
  if (
    ['tomaat', 'aubergine', 'komkommer', 'courgette', 'paprika'].some((x) =>
      id.includes(x),
    )
  ) {
    if ((o.plant || []).some((m) => m < 5) && !(o.outdoor || '').includes('Kas')) {
      warn(`${id}: uitplanten voor mei zonder kas-notatie`);
    }
  }
}

// known accuracy checks
const checks = [
  {
    id: 'radijs',
    test: (o) => o.first.includes('25') || o.first.includes('30') || o.first.includes('35'),
    msg: 'radijs moet snelle oogst (~25–35d) hebben',
  },
  {
    id: 'tomaat',
    test: (o) => (o.sow || []).every((m) => m <= 4) && (o.plant || []).every((m) => m >= 5),
    msg: 'tomaat: voorzaaien vroeg, uitplanten vanaf mei',
  },
  {
    id: 'knoflook',
    test: (o) => (o.plant || []).includes(10) || (o.plant || []).includes(11),
    msg: 'knoflook: najaar planten',
  },
  {
    id: 'asperge',
    test: (o) => o.lifespan === 'Meerjarig' && (o.first || '').includes('jaar'),
    msg: 'asperge: meerjarig, oogst vanaf later jaar',
  },
  {
    id: 'witlof',
    test: (o) => o.difficulty === 'Moeilijk' || o.lifespan === 'Tweejarig',
    msg: 'witlof: moeilijk/tweejarig',
  },
  {
    id: 'boerenkool',
    test: (o) => (o.harvest || []).some((m) => m >= 10 || m <= 3),
    msg: 'boerenkool: winteroogst',
  },
  {
    id: 'munt',
    test: (o) => o.lifespan === 'Meerjarig',
    msg: 'munt: meerjarig',
  },
  {
    id: 'basilicum',
    test: (o) => o.lifespan === 'Eenjarig' && o.standplaats === 'Zon',
    msg: 'basilicum: eenjarig + zon',
  },
  {
    id: 'appel',
    test: (o) => o.lifespan === 'Meerjarig',
    msg: 'appel: meerjarig',
  },
  {
    id: 'watermeloen',
    test: (o) => o.difficulty === 'Moeilijk' || (o.outdoor || '').toLowerCase().includes('kas'),
    msg: 'watermeloen: moeilijk/kas in NL',
  },
  {
    id: 'tuinboon',
    test: (o) => (o.sow || []).some((m) => m <= 4),
    msg: 'tuinboon: vroege zaai',
  },
  {
    id: 'aardbei',
    test: (o) => o.lifespan === 'Meerjarig',
    msg: 'aardbei: meerjarig',
  },
];
for (const c of checks) {
  const o = veg[c.id];
  if (!o) {
    err(`check mist plant ${c.id}`);
    continue;
  }
  if (!c.test(o)) err(`ACCURACY ${c.id}: ${c.msg}`);
}

// —— Flowers ——
const flowerMapIds = [
  ...flowerSrc.matchAll(/'([a-z_]+)': _FlowerFacts\(/g),
].map((m) => m[1]);
for (const id of flowerIds) {
  if (!flowerMapIds.includes(id)) err(`BLOEM mist facts: ${id}`);
}
for (const id of flowerMapIds) {
  if (!flowerIds.includes(id)) warn(`BLOEM extra facts (niet in groups): ${id}`);
}

const flowerFields = [
  'standplaats:',
  'water:',
  'difficulty:',
  'lifespan:',
  'summary:',
  'whyPlantReasons:',
  'pollinatorRatings:',
  'height:',
  'width:',
  'bloomPeriod:',
  'bloomDuration:',
  'calendarMoments:',
  'flowerColors:',
  'fragrance:',
  'winterHardy:',
  'droughtResistant:',
  'suitableFor:',
  'keyFeatures:',
  'tip:',
];
for (let i = 0; i < flowerMapIds.length; i++) {
  const id = flowerMapIds[i];
  const start = flowerSrc.indexOf(`'${id}': _FlowerFacts(`);
  const next = flowerMapIds[i + 1];
  const end = next
    ? flowerSrc.indexOf(`'${next}': _FlowerFacts(`)
    : flowerSrc.length;
  const block = flowerSrc.slice(start, end);
  for (const f of flowerFields) {
    if (!block.includes(f)) err(`BLOEM ${id}: mist ${f}`);
  }
  // pollinator 0-5
  const stars = [...block.matchAll(/(bees|butterflies|bumblebees|hoverflies):\s*(\d+)/g)];
  for (const [, name, n] of stars) {
    const v = Number(n);
    if (v < 0 || v > 5) err(`BLOEM ${id}: ${name}=${v} buiten 0–5`);
  }
  // months in calendar
  const months = [...block.matchAll(/months:\s*\{([^}]*)\}/g)].flatMap((m) =>
    m[1]
      .split(',')
      .map((x) => x.trim())
      .filter(Boolean)
      .map(Number),
  );
  for (const m of months) {
    if (m < 1 || m > 12) err(`BLOEM ${id}: maand ${m}`);
  }
}

// flower accuracy
const flowerChecks = [
  {
    id: 'lavendel',
    test: (b) =>
      b.includes("lifespan: 'Vaste plant'") &&
      b.includes('winterHardy: true') &&
      b.includes("water: 'Weinig'"),
    msg: 'lavendel: vaste plant, winterhard, weinig water',
  },
  {
    id: 'zonnebloem',
    test: (b) => b.includes("lifespan: 'Eenjarig'") && b.includes('150'),
    msg: 'zonnebloem: eenjarig en hoog',
  },
  {
    id: 'munt_bloei',
    test: (b) => b.includes('Pot') || b.includes('pot'),
    msg: 'munt: pot aanbevolen',
  },
  {
    id: 'facelia',
    test: (b) => b.includes("lifespan: 'Eenjarig'") && b.includes('bees: 5'),
    msg: 'facelia: eenjarig, top voor bijen',
  },
  {
    id: 'tagetes_patula',
    test: (b) =>
      b.includes("lifespan: 'Eenjarig'") &&
      (b.includes('Moestuin') || b.includes('plaag') || b.includes('nematode') || b.includes('tomaten') || b.includes('kool')),
    msg: 'tagetes: eenjarig + moestuin/plaag-nut',
  },
];
for (const c of flowerChecks) {
  const i = flowerSrc.indexOf(`'${c.id}': _FlowerFacts(`);
  if (i < 0) {
    err(`flower check mist ${c.id}`);
    continue;
  }
  const j = flowerSrc.indexOf("': _FlowerFacts(", i + 10);
  const block = flowerSrc.slice(i, j < 0 ? flowerSrc.length : j);
  if (!c.test(block)) err(`ACCURACY BLOEM ${c.id}: ${c.msg}`);
}

// —— Mushrooms ——
const mushMapIds = [
  ...mushSrc.matchAll(/'([a-z_]+)': _MushroomFacts\(/g),
].map((m) => m[1]);
for (const id of mushIds) {
  if (!mushMapIds.includes(id)) err(`PADDENSTOEL mist facts: ${id}`);
}
const mushFields = [
  'difficulty:',
  'location:',
  'temperature:',
  'humidity:',
  'timeToHarvest:',
  'yield:',
  'flushCount:',
  'substrate:',
  'light:',
  'ventilation:',
  'summary:',
  'stages:',
  'edibility:',
  'edibilityStars:',
  'beginnerSuitability:',
  'beginnerRecommended:',
  'goodToKnow:',
];
for (let i = 0; i < mushMapIds.length; i++) {
  const id = mushMapIds[i];
  const start = mushSrc.indexOf(`'${id}': _MushroomFacts(`);
  const next = mushMapIds[i + 1];
  const end = next
    ? mushSrc.indexOf(`'${next}': _MushroomFacts(`)
    : mushSrc.length;
  const block = mushSrc.slice(start, end);
  for (const f of mushFields) {
    if (!block.includes(f)) err(`PADDENSTOEL ${id}: mist ${f}`);
  }
  const stars = block.match(/edibilityStars:\s*(\d+)/);
  if (stars) {
    const n = Number(stars[1]);
    if (n < 1 || n > 5) err(`PADDENSTOEL ${id}: edibilityStars ${n}`);
  }
}

const mushChecks = [
  {
    id: 'oesterzwam',
    test: (b) => b.includes("difficulty: 'Makkelijk'") && b.includes('beginnerRecommended: true'),
    msg: 'oesterzwam makkelijk voor beginners',
  },
  {
    id: 'reishi',
    test: (b) =>
      b.includes("difficulty: 'Moeilijk'") &&
      b.includes('Medicinaal') &&
      b.includes('beginnerRecommended: false'),
    msg: 'reishi moeilijk/medicinaal',
  },
  {
    id: 'morielzwam',
    test: (b) =>
      b.includes("difficulty: 'Moeilijk'") &&
      b.includes('beginnerRecommended: false'),
    msg: 'moriel moeilijk',
  },
  {
    id: 'champignon_wit',
    test: (b) => b.includes('duisternis') || b.includes('Donker'),
    msg: 'champignon: donkere teelt',
  },
];
for (const c of mushChecks) {
  const i = mushSrc.indexOf(`'${c.id}': _MushroomFacts(`);
  const j = mushSrc.indexOf("': _MushroomFacts(", i + 10);
  const block = mushSrc.slice(i, j < 0 ? mushSrc.length : j);
  if (!c.test(block)) err(`ACCURACY PAD ${c.id}: ${c.msg}`);
}

// contradictions in veg: perennial but annual harvest wording ok; check tropicals
for (const id of ['mango', 'avocado', 'citroenboom', 'limoen', 'mandarijn']) {
  const o = veg[id];
  if (!o) continue;
  if (o.difficulty !== 'Moeilijk') warn(`${id}: verwacht Moeilijk in NL`);
  if (!(o.outdoor || '').toLowerCase().includes('kas') && !(o.outdoor || '').toLowerCase().includes('kuip')) {
    warn(`${id}: outdoor zou kas/kuip moeten zijn`);
  }
}

const errors = issues.filter((i) => i.level === 'error');
const warnings = issues.filter((i) => i.level === 'warn');
console.log(
  JSON.stringify(
    {
      vegExpected: expectedVeg.length,
      vegPresent: expectedVeg.filter((id) => veg[id]).length,
      vegJsonTotal: Object.keys(veg).length,
      flowersExpected: flowerIds.length,
      flowersPresent: flowerMapIds.length,
      mushroomsExpected: mushIds.length,
      mushroomsPresent: mushMapIds.length,
      errorCount: errors.length,
      warnCount: warnings.length,
      errors: errors.map((e) => e.msg),
      warnings: warnings.map((w) => w.msg),
    },
    null,
    2,
  ),
);
