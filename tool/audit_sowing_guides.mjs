import fs from 'fs';

const entries = fs.readFileSync('lib/data/plant_sowing_guide_entries.dart', 'utf8');
const overview = JSON.parse(fs.readFileSync('tool/vegetable_overview_all.json', 'utf8'));
const ids = [...entries.matchAll(/^  '([^']+)': PlantSowingGuide/gm)].map((m) => m[1]);

function sectionChunk(id) {
  const start = entries.indexOf(`'${id}': PlantSowingGuide`);
  if (start < 0) return null;
  const next = entries.indexOf(`': PlantSowingGuide`, start + 10);
  const end = next > 0 ? next : start + 8000;
  return entries.slice(start, end);
}

function summaries(id) {
  const chunk = sectionChunk(id);
  if (!chunk) return null;
  const out = [];
  const re = /title: '([^']+)',\s*summary: '([^']*)'/g;
  let m;
  while ((m = re.exec(chunk)) && out.length < 9) {
    out.push({ title: m[1], summary: m[2] });
  }
  return out;
}

const sample = [
  'tomaat',
  'komkommer',
  'courgette',
  'sla',
  'wortel',
  'radijs',
  'aardappel',
  'zoete_aardappel',
  'basilicum',
  'peterselie',
  'boerenkool',
  'broccoli',
  'ui',
  'prei',
  'knoflook',
  'erwt',
  'sperzieboon',
  'mais',
  'aardbei',
  'appel',
  'asperge',
  'spinazie',
  'biet',
  'aubergine',
  'paprika',
  'meloen',
  'tauge',
  'gember',
];

const report = [];
for (const id of sample) {
  report.push({ id, inOverview: !!overview[id], sections: summaries(id) });
}

// Automated red-flag checks across ALL entries
const flags = [];
for (const id of ids) {
  const secs = summaries(id) || [];
  const byTitle = Object.fromEntries(secs.map((s) => [s.title, s.summary.toLowerCase()]));
  const licht = byTitle['Licht tijdens kieming'] || '';
  const diepte = byTitle['Zaaidiepte'] || '';
  const binnen = byTitle['Binnen zaaien'] || '';
  const buiten = byTitle['Buiten zaaien'] || '';

  // Cucurbits should be covered / dark germinators, not "niet bedekken" as light germinator
  if (
    (id.includes('komkommer') ||
      id.includes('courgette') ||
      id.includes('pompoen') ||
      id.includes('meloen') ||
      id.includes('augurk')) &&
    (licht.includes('lichtkiemer') || diepte.includes('niet bedekken'))
  ) {
    flags.push({ id, issue: 'cucurbit marked as light germinator / not cover' });
  }

  // Lettuce should be light germinator / shallow
  if (
    (id.includes('sla') || id === 'lollo_rossa' || id.includes('eikenblad')) &&
    diepte.includes('2 – 3 cm') &&
    !diepte.includes('0')
  ) {
    flags.push({ id, issue: 'lettuce sown too deep' });
  }

  // Potato seed wording conflict
  if (id.includes('aardappel') && !id.includes('zoete') && binnen.includes('zaai') && !binnen.includes('poot')) {
    if (!binnen.includes('niet zaaien') && !binnen.includes('poot')) {
      flags.push({ id, issue: 'potato may still talk about sowing seed' });
    }
  }

  // Sweet potato should not be seed potato advice only
  if (id.includes('zoete_aardappel') && (diepte.includes('pootdiepte 8') || binnen.includes('pootaardappel'))) {
    flags.push({ id, issue: 'sweet potato using white potato seed-tuber profile' });
  }

  // Carrot transplant
  if (
    (id.includes('wortel') || id.includes('winterpeen') || id.includes('mini_wortel')) &&
    (byTitle['Verspenen'] || '').includes('2 – 4 echte') &&
    !(byTitle['Verspenen'] || '').includes('niet')
  ) {
    flags.push({ id, issue: 'carrot suggests normal pricking out' });
  }
}

fs.writeFileSync(
  'tool/sowing_audit_sample.json',
  JSON.stringify({ sample: report, flags, total: ids.length }, null, 2),
);
console.log(JSON.stringify({ total: ids.length, flagCount: flags.length, flags }, null, 2));
