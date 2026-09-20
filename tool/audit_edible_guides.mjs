import fs from 'fs';

const sow = fs.readFileSync('lib/data/plant_sowing_guide_entries.dart', 'utf8');
const trans = fs.readFileSync('lib/data/plant_transplant_guide_entries.dart', 'utf8');

const sowIds = [...sow.matchAll(/^  '([^']+)': PlantSowingGuide/gm)].map((m) => m[1]);
const transIds = [...trans.matchAll(/^  '([^']+)': PlantTransplantGuide/gm)].map((m) => m[1]);

function chunkFor(file, id, marker) {
  const start = file.indexOf(`'${id}': ${marker}`);
  if (start < 0) return null;
  const next = file.indexOf(`': ${marker}`, start + 10);
  return file.slice(start, next > 0 ? next : start + 20000);
}

function auditCurated(file, ids, blockName, marker) {
  const thin = [];
  const noDetails = [];
  for (const id of ids) {
    const chunk = chunkFor(file, id, marker);
    if (!chunk) continue;
    const re = /title: '([^']+)',\s*\n\s*summary: '([^']*)'[\s\S]*?details: \[([\s\S]*?)\n\s*\]/g;
    let m;
    while ((m = re.exec(chunk))) {
      const title = m[1];
      const blocks = (m[3].match(new RegExp(blockName, 'g')) || []).length;
      if (blocks === 0) noDetails.push(`${id}::${title}`);
      else if (blocks < 2) thin.push(`${id}::${title} (${blocks})`);
    }
  }
  return { thin, noDetails };
}

const sowAudit = auditCurated(sow, sowIds, 'SowingDetailBlock', 'PlantSowingGuide');
const transAudit = auditCurated(trans, transIds, 'TransplantDetailBlock', 'PlantTransplantGuide');

console.log(JSON.stringify({
  sowingCuratedCount: sowIds.length,
  transplantCuratedCount: transIds.length,
  sowingNoDetails: sowAudit.noDetails.length,
  sowingThin: sowAudit.thin.length,
  transplantNoDetails: transAudit.noDetails.length,
  transplantThin: transAudit.thin.length,
  sampleSowingThin: sowAudit.thin.slice(0, 5),
  sampleTransplantThin: transAudit.thin.slice(0, 5),
}, null, 2));
