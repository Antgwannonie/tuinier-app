import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const SRC = path.join(__dirname, 'generate_vegetable_overview.py');
const OUT = path.join(__dirname, 'vegetable_overview_all.json');

const REQUIRED_IDS = `
rode_biet rode_biet_cilindrisch gele_biet witte_biet chioggia_biet
sla ijsbergsla lollo_rossa krulsla lambsla eikenbladsla
spinazie baby_spinazie rucola andijvie postelein snijbiet tuinkers witlof veldsla
wortel paarse_wortel gele_wortel witte_wortel radijs pastinaak winterpeen mini_wortel schorseneer rammenas zwarte_radijs peterseliewortel
tomaat snoeptomaat cherrytomaat pruimtomaat vleestomaat trostomaat cocktailtomaat balkontomaat honingtomaat
rode_paprika gele_paprika oranje_paprika puntpaprika snack_paprika peper cayenne_peper chilipeper jalapeno habanero serrano_peper galapeno_peper thaise_peper poblano_peper padron_peper tabasco_peper peperoncini banana_peper
snackkomkommer komkommer cucamelon courgette courgette_geel patisson augurk pompoen reuzen_pompoen pompoen_hokkaido pompoen_butternut okra pepino galia_meloen honingmeloen
bosui ui prei winterprei zomerprei knoflook sjalot rode_ui winterui knoflook_hardnekkig scheve_ui
boerenkool broccoli bimi koolrabi wittekool rodekool bloemkool spruitkool paksoi koolraap savooiekool spitskool palmekool romanesco chinese_kool raapstelen raapkool rode_savooi bloemkool_paars spruitkool_rood paksoi_jong broccoli_rabe
aardappel vroege_aardappel vastkokende_aardappel kruimige_aardappel zoete_aardappel aardpeer
aubergine
mais maiskolf
rabarber asperge groene_asperge witte_asperge zuring
`.trim().split(/\s+/);

function normalize(d) {
  return {
    sow: d.sow ?? [],
    plant: d.plant ?? [],
    harvest: d.harvest ?? [],
    standplaats: d.standplaats,
    water: d.water,
    difficulty: d.difficulty,
    lifespan: d.lifespan,
    outdoor: d.outdoor,
    container: d.container,
    voeding: d.voeding,
    height: d.height,
    width: d.width,
    habit: d.habit,
    spacing: d.spacing,
    row: d.row,
    first: d.first,
    period: d.period,
    yield_level: d.yield_level,
    yield_detail: d.yield_detail,
    points: d.points,
    summary: d.summary,
    know: d.know,
  };
}

function parsePyList(text) {
  const items = [];
  for (const m of text.matchAll(/"((?:[^"\\]|\\.)*)"/g)) items.push(m[1]);
  return items;
}

function parsePyValue(raw) {
  let s = raw.trim().replace(/,\s*$/, '');
  if (s.startsWith('[')) {
    if (!s.endsWith(']')) {
      const lines = s.split('\n').map((l) => l.trim()).filter(Boolean);
      s = lines.join(' ');
    }
    if (s.includes('"')) return parsePyList(s);
    if (s === '[]') return [];
    return JSON.parse(s);
  }
  if (s.startsWith('"')) return JSON.parse(s);
  return s;
}

function extractDictBody(block, name) {
  const marker = `${name} = dict(`;
  const start = block.indexOf(marker);
  if (start < 0) return null;
  let i = start + marker.length;
  let depth = 1;
  let content = '';
  while (i < block.length && depth > 0) {
    const ch = block[i];
    if (ch === '(') depth += 1;
    else if (ch === ')') depth -= 1;
    if (depth > 0) content += ch;
    i += 1;
  }
  return content;
}

function parseDictContent(content) {
  const obj = {};
  const keyPositions = [];
  for (const m of content.matchAll(/([a-zA-Z_]\w*)\s*=/g)) {
    keyPositions.push({ key: m[1], valueStart: m.index + m[0].length, keyStart: m.index });
  }
  for (let idx = 0; idx < keyPositions.length; idx += 1) {
    const { key, valueStart } = keyPositions[idx];
    const end = idx + 1 < keyPositions.length ? keyPositions[idx + 1].keyStart : content.length;
    const raw = content.slice(valueStart, end).trim().replace(/,\s*$/, '');
    obj[key] = parsePyValue(raw);
  }
  return obj;
}

function loadBase(block, name) {
  const content = extractDictBody(block, name);
  if (!content) return null;
  return parseDictContent(content);
}

function extractEntryInners(block) {
  const inners = [];
  const marker = 'entries.append(entry(';
  let i = 0;
  while (i < block.length) {
    const start = block.indexOf(marker, i);
    if (start < 0) break;
    let j = start + marker.length;
    let depth = 1;
    while (j < block.length && depth > 0) {
      const ch = block[j];
      if (ch === '(') depth += 1;
      else if (ch === ')') depth -= 1;
      if (depth > 0) j += 1;
    }
    inners.push(block.slice(start + marker.length, j));
    i = j + 1;
  }
  return inners;
}

function parseEntryInner(inner, bases) {
  const idM = inner.match(/"([^"]+)"/);
  if (!idM) return null;
  const id = idM[1];

  const summaryM = inner.match(/summary="((?:[^"\\]|\\.)*)"/);
  const knowM = inner.match(/know="((?:[^"\\]|\\.)*)"/);
  if (!summaryM || !knowM) return null;

  let data = {};
  const spreadM = inner.match(/\*\*([a-zA-Z_]\w*)/);
  if (spreadM && bases[spreadM[1]]) data = { ...bases[spreadM[1]] };

  const overrideM = inner.match(/\*\*\{([^}]+)\}/);
  if (overrideM) {
    for (const kv of overrideM[1].matchAll(/"([^"]+)":\s*"((?:[^"\\]|\\.)*)"/g)) data[kv[1]] = kv[2];
    for (const kv of overrideM[1].matchAll(/"([^"]+)":\s*\[([^\]]*)\]/g)) data[kv[1]] = JSON.parse(`[${kv[2]}]`);
  }

  const fields = parseDictContent(inner.replace(/^[\s\S]*?"[^"]+",\s*/, ''));
  data = { ...data, ...fields };
  delete data.summary;
  delete data.know;

  data.summary = summaryM[1];
  data.know = knowM[1];
  return [id, normalize(data)];
}

const block = fs.readFileSync(SRC, 'utf8');
const dataBlock = block.slice(block.indexOf('# --- Bieten ---'), block.indexOf('# Write dart file'));

const baseNames = [
  'biet_base', 'sla_base', 'wortel_base', 'tomaat', 'paprika',
  'komkommer', 'courgette', 'pompoen', 'kool_common', 'aardappel',
];
const bases = {};
for (const name of baseNames) {
  const b = loadBase(dataBlock, name);
  if (b) bases[name] = b;
}
bases.peper = {
  ...bases.paprika,
  difficulty: 'Gemiddeld',
  yield_detail: 'Oogst groen of rijp rood; scherpte neemt toe bij rijpheid',
  points: ['Warmte nodig', 'Voorzaaien vroeg', 'Pot mogelijk', 'Handschoenen bij hete rassen'],
};

const plants = {};
for (const inner of extractEntryInners(dataBlock)) {
  const parsed = parseEntryInner(inner, bases);
  if (parsed) plants[parsed[0]] = parsed[1];
}

// Paprika loop
const paprika = bases.paprika;
for (const [pid, summary, know] of [
  ['rode_paprika', 'Rode paprika rijpt van groen naar rood en wordt zoeter. Warmte is doorslaggevend in NL.', 'Laat vruchten aan de plant narijpen voor volle kleur.'],
  ['gele_paprika', 'Gele paprika teel je zoals rode paprika: vroeg voorzaaien en warm uitplanten.', "Gele rassen kleuren vaak iets sneller dan dikke rode blokpaprika's."],
  ['oranje_paprika', "Oranje paprika vraagt dezelfde warme teelt als andere blokpaprika's.", 'Mooi voor snacken en salades door milde zoetheid.'],
  ['puntpaprika', 'Puntpaprika is vaak zoeter en wat vroeger dan blokpaprika. Ideaal voor grill en oven.', 'Dunner vruchtvlees droogt sneller in de oven.'],
  ['snack_paprika', "Snackpaprika's blijven klein en productief, ook in grote potten.", 'Oogst regelmatig om nieuwe zetting te stimuleren.'],
]) {
  let d = { ...paprika };
  if (pid.includes('snack')) Object.assign(d, { height: '40–70 cm', difficulty: 'Makkelijk', yield_level: 'Hoge opbrengst', yield_detail: "Veel kleine zoete paprika's" });
  if (pid.includes('punt')) d.yield_detail = 'Langwerpige zoete vruchten';
  plants[pid] = normalize({ ...d, summary, know });
}

// Peper loop
const peper = bases.peper;
for (const [pid, summary, know] of [
  ['peper', 'Peper (zoet/pittig afhankelijk van ras) vraagt warmte zoals paprika. Voorzaaien in februari–maart.', 'Start zachtjes met water bij jonge planten; te nat geeft groeistagnatie.'],
  ['cayenne_peper', 'Cayenne is een slanke hete peper. Warm telen en rijp rood oogsten voor drogen.', 'Gedroogde cayenne is sterker dan verse groene peulen.'],
  ['chilipeper', 'Chilipeper dekt veel hete rassen. Geef warmte, steun bij zware belading en oogst naar smaak.', 'Stress (droogte) kan scherpte verhogen.'],
  ['jalapeno', 'Jalapeño is middelheet en productief. Goed te doen in kas of warme bak.', "Rode rijpe jalapeño's zijn zoeter en vaak iets heter."],
  ['habanero', 'Habanero is zeer heet en warmteminnend. Alleen voor warme kas of warme zomer.', 'Draag handschoenen bij oogsten en snijden.'],
  ['serrano_peper', 'Serrano is slanker en vaak iets heter dan jalapeño. Zelfde warme teelt.', 'Oogst jong voor frisse hitte, rijper voor diepere smaak.'],
  ['galapeno_peper', 'Galapeño/jalapeño-achtige peper voor warme teelt in pot of kas.', 'Regelmatig oogsten houdt de plant productief.'],
  ['thaise_peper', 'Thaise peper is klein, scherp en productief bij voldoende warmte.', 'Plant blijft relatief compact; goed voor grote pot.'],
  ['poblano_peper', 'Poblano is grootvruchtig en mild-heet. Laat goed uitgroeien in warme omstandigheden.', 'Gedroogd heet deze peper vaak ancho.'],
  ['padron_peper', 'Padrón pepertjes grill je jong. De meeste zijn mild, enkele onverwacht heet.', 'Oogst klein (3–5 cm) voor de klassieke tapa.'],
  ['tabasco_peper', 'Tabasco-peper is klein en scherp; uitstekend voor saus. Warmte is essentieel.', 'Vruchten rijpen van groen via geel/oranje naar rood.'],
  ['peperoncini', 'Peperoncini is mildzuur en vaak ingelegd. Iets makkelijker dan zeer hete rassen.', 'Oogst lichtgeelgroen voor de bekende milde smaak.'],
  ['banana_peper', 'Banana peper is mild, zoetzuur en vroeg productief in warme zomer.', 'Geschikt om te vullen, grillen of in te maken.'],
]) {
  let d = { ...peper };
  if (pid === 'habanero') d.difficulty = 'Moeilijk';
  if (['padron_peper', 'peperoncini', 'banana_peper'].includes(pid)) {
    d.difficulty = 'Makkelijk';
    d.yield_level = 'Hoge opbrengst';
  }
  plants[pid] = normalize({ ...d, summary, know });
}

const ordered = {};
for (const id of REQUIRED_IDS) {
  if (plants[id]) ordered[id] = plants[id];
}
const missing = REQUIRED_IDS.filter((id) => !plants[id]);

fs.writeFileSync(OUT, JSON.stringify(ordered, null, 2) + '\n', 'utf8');
console.log(`Wrote ${Object.keys(ordered).length} plants -> ${OUT}`);
if (missing.length) console.log(`Missing (${missing.length}): ${missing.join(', ')}`);
