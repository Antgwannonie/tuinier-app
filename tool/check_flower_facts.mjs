import fs from 'fs';

const s = fs.readFileSync('lib/data/flower_overview_facts_map.dart', 'utf8');
const ids = [...s.matchAll(/'([a-z_]+)': _FlowerFacts\(/g)].map((m) => m[1]);
const req =
  'zonnebloem afrikaantje goudsbloem oostindische_kers komkommerkruid facelia korenbloem cosmos boekweit witte_klaver rode_klaver duizendblad zaadslurf limnanthes monarda zonnehoed verbena wilde_marjolein hysop mosterd_geel klaproos bijenmengsel lindebloesem tagetes_patula alyssum_sneeuw calendula_officinalis zinnia lupine_groenbemester stiefmoedje ringelbloem lavendel ui_bloei look_bloei dille_bloei koriander_bloei salie_bloei tijm_bloei basilicum_bloei munt_bloei'.split(
    /\s+/,
  );
const miss = req.filter((id) => !ids.includes(id));
const extra = ids.filter((id) => !req.includes(id));
const fields = [
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
const incomplete = [];
for (let i = 0; i < ids.length; i++) {
  const id = ids[i];
  const start = s.indexOf(`'${id}': _FlowerFacts(`);
  const nextId = ids[i + 1];
  const end = nextId ? s.indexOf(`'${nextId}': _FlowerFacts(`) : s.length;
  const block = s.slice(start, end);
  const missing = fields.filter((f) => !block.includes(f));
  if (missing.length) incomplete.push(`${id}: ${missing.join(', ')}`);
}
console.log({ count: ids.length, miss, extra, incomplete: incomplete.length });
if (incomplete.length) console.log(incomplete);
