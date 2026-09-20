import fs from 'fs';

// Mirror of cropProfileKeyFor notes from Dart profiles
const notes = {
  aubergine: 'In NL buiten lastig zonder warme zomer; kas sterk aanbevolen.',
  meloen: 'In NL buiten onzeker; kas/zuidmuur realistischer.',
  wortel:
    'Wortel/pastinaak: bij voorkeur ter plaatse zaaien; uitplanten alleen met diepe modules.',
  radijs: 'Radijs zaai je vrijwel altijd ter plaatse; snelle teelt.',
  knoflook: 'Tenen poten; geen klassieke zaailing-uitplant.',
  aardappel:
    'Pootgoed; geen zaailing-uitplant. Zoete aardappel is apart (slips).',
  zoeteAardappel:
    'Slips/stekken. Exacte NL-oogst per ras wisselvallig — graag jouw bron voor verfijning.',
  meerjarig:
    'Meerjarigen: plantgoed/aanplant vaak relevanter dan zaailing. Soortspecifieke details beperkt.',
  fruitZaad:
    'Fruit: gebruik plantgoed. Exacte ras-/onderstam-/snoei-details niet volledig — geef bronnen door.',
  okra: 'In NL vooral kas/zuidmuur; oogst wisselvallig.',
  gember: 'Rizoom in kuip/kas; geen klassieke uitplantzaailing.',
  tauge: 'Keukenkiemgroente — geen tuin-standplaats/uitplant.',
  algemeen:
    'Algemeen profiel — soortspecifieke bronnen welkom voor verfijning.',
};

// Reuse key logic simplified via reading transplant gaps + sowing targets
const ids = JSON.parse(fs.readFileSync('tool/sowing_target_ids.json', 'utf8'));

function keyFor(id) {
  const x = id.toLowerCase();
  if (x.includes('zoete_aardappel')) return 'zoeteAardappel';
  if (x.includes('aardappel')) return 'aardappel';
  if (x.includes('knoflook') || x.includes('sjalot')) return 'knoflook';
  if (x.includes('aubergine')) return 'aubergine';
  if (x.includes('meloen') || x.includes('watermeloen')) return 'meloen';
  if (
    x.includes('wortel') ||
    x.includes('peen') ||
    x.includes('pastinaak') ||
    x.includes('schorseneer') ||
    x.includes('peterseliewortel')
  )
    return 'wortel';
  if (x.includes('radijs') || x.includes('rammenas')) return 'radijs';
  if (x.includes('okra')) return 'okra';
  if (x.includes('gember')) return 'gember';
  if (x.includes('tauge')) return 'tauge';
  if (
    x.includes('asperge') ||
    x.includes('artisjok') ||
    x.includes('rabarber') ||
    x.includes('aardpeer') ||
    x.includes('kardoen')
  )
    return 'meerjarig';
  if (
    x.includes('appel') ||
    x.includes('peer') ||
    x.includes('pruim') ||
    x.includes('kers') ||
    x.includes('perzik') ||
    x.includes('nectarine') ||
    x.includes('abrikoos') ||
    x.includes('vijg') ||
    x.includes('druif') ||
    x.includes('kiwi') ||
    x.includes('bes') ||
    x.includes('framboos') ||
    x.includes('braam') ||
    x.includes('mango') ||
    x.includes('avocado') ||
    x.includes('citroen') ||
    x.includes('limoen') ||
    x.includes('mandarijn') ||
    x.includes('walnoot') ||
    x.includes('hazelnoot') ||
    x.includes('kastanje') ||
    x.includes('kaki') ||
    x.includes('physalis') ||
    x.includes('mispel') ||
    x.includes('mirabel') ||
    x.includes('kriek') ||
    x.includes('duindoorn') ||
    x.includes('blauwe') ||
    x.includes('cranberry')
  )
    return 'fruitZaad';
  return null;
}

const gaps = [];
for (const id of ids) {
  const k = keyFor(id);
  if (k && notes[k]) gaps.push({ id, profile: k, reason: notes[k] });
}

const out = {
  generatedFor:
    'Standplaats/Water/Voeding/Groei/Bloei/Oogsten/Verzorging/Weetjes/Combinatie/Problemen (naast Zaaien/Uitplanten)',
  count: gaps.length,
  gaps,
  needsUserSources: [
    'fruit (ras/onderstam/snoei per soort)',
    'meerjarigen (asperge/rabarber/artisjok detail)',
    'zoete aardappel slips + NL-oogst',
    'exoten: okra, meloen, aubergine buiten NL',
    'weetjes: oorsprong/historie per zeldzame soort',
  ],
};

fs.writeFileSync(
  'tool/remaining_guides_gaps_report.json',
  JSON.stringify(out, null, 2),
);
console.log(JSON.stringify({ count: gaps.length, needs: out.needsUserSources }, null, 2));
