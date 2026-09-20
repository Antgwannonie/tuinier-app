/**
 * Scan curated sowing/transplant guide entries for wrong plant names.
 * Flags when entry text for vegetable id X mentions another plant as subject.
 */
import fs from 'fs';
import path from 'path';

const root = path.resolve(import.meta.dirname, '..');

const ENTRY_FILES = [
  'lib/data/plant_sowing_guide_entries.dart',
  'lib/data/plant_transplant_guide_entries.dart',
];

const GENERIC_BUILDER_FILES = [
  'lib/data/plant_weetjes_guide.dart',
  'lib/data/crop_card_summaries.dart',
  'lib/data/plant_growth_guide.dart',
  'lib/data/plant_harvest_guide.dart',
  'lib/data/plant_care_guide.dart',
  'lib/data/plant_transplant_guide.dart',
  'lib/data/plant_section_details.dart',
];

function read(rel) {
  return fs.readFileSync(path.join(root, rel), 'utf8');
}

function parseEntryIds(content) {
  return [...content.matchAll(/^  '([^']+)': Plant/gm)].map((m) => m[1]);
}

function entryChunk(content, id) {
  const start = content.indexOf(`'${id}': Plant`);
  if (start < 0) return null;
  const next = content.indexOf(`': Plant`, start + 10);
  return content.slice(start, next > 0 ? next : start + 15000);
}

function extractStrings(chunk) {
  const texts = [];
  const re = /(?:summary|body|whenText|howText|title):\s*'((?:\\'|[^'])*)'/g;
  let m;
  while ((m = re.exec(chunk))) {
    texts.push(m[1].replace(/\\'/g, "'"));
  }
  return texts;
}

function idToDisplayName(id) {
  return id
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

function lineNumber(content, index) {
  return content.slice(0, index).split('\n').length;
}

/** Allow "bijv. tomaat" as generic example, not a leak. */
function isGenericExample(text, matchIndex, matched) {
  const before = text.slice(Math.max(0, matchIndex - 12), matchIndex).toLowerCase();
  if (/bijv\.?\s*$/.test(before)) return true;
  if (/bijvoorbeeld\s*$/.test(before)) return true;
  if (/zoals\s*$/.test(before)) return true;
  // companion lists: "tomaat, paprika" in flower data — skip in curated veg scan
  if (matched.length < 5) return false;
  return false;
}

function buildNameIndex(ids) {
  const byId = {};
  const aliases = {};
  for (const id of ids) {
    const display = idToDisplayName(id);
    byId[id] = display;
    aliases[id] = new Set([
      display.toLowerCase(),
      ...display.split(' ').map((w) => w.toLowerCase()),
    ]);
    if (id.includes('tomaat')) aliases[id].add('tomaat');
    if (id.includes('komkommer') && !id.includes('kruid')) aliases[id].add('komkommer');
    if (id.includes('courgette')) aliases[id].add('courgette');
    if (id.includes('paprika')) aliases[id].add('paprika');
    if (id.includes('aardappel') && !id.includes('zoete')) aliases[id].add('aardappel');
  }
  return { byId, aliases };
}

function scanCuratedEntries() {
  const leaks = [];
  for (const rel of ENTRY_FILES) {
    const content = read(rel);
    const ids = parseEntryIds(content);
    const { byId, aliases } = buildNameIndex(ids);

    for (const id of ids) {
      const chunk = entryChunk(content, id);
      if (!chunk) continue;
      const chunkStart = content.indexOf(chunk);
      const texts = extractStrings(chunk);
      const allowed = aliases[id];

      for (const text of texts) {
        const low = text.toLowerCase();
        for (const otherId of ids) {
          if (otherId === id) continue;
          const otherName = byId[otherId];
          const otherLow = otherName.toLowerCase();
          // Skip partial id overlap (snackkomkommer vs komkommer handled per-id names)
          if (id.includes(otherId) || otherId.includes(id)) continue;

          const idx = low.indexOf(otherLow);
          if (idx < 0) continue;
          if (isGenericExample(text, idx, otherLow)) continue;

          // Subject-style patterns (strong leak signal)
          const subjectPatterns = [
            new RegExp(`\\bvoor\\s+${escapeRegExp(otherLow)}\\b`, 'i'),
            new RegExp(`\\bjonge\\s+${escapeRegExp(otherLow)}`, 'i'),
            new RegExp(`\\blabels\\s+met\\s+${escapeRegExp(otherLow)}`, 'i'),
            new RegExp(`\\buitplanten\\s+van\\s+${escapeRegExp(otherLow)}`, 'i'),
            new RegExp(`\\b${escapeRegExp(otherLow)}[- ]planten\\b`, 'i'),
            new RegExp(`\\b${escapeRegExp(otherLow)}\\s+van\\s+pot`, 'i'),
            new RegExp(`\\bbij\\s+${escapeRegExp(otherLow)}\\s*:`, 'i'),
            new RegExp(`\\boverzichtgegevens\\s+van\\s+${escapeRegExp(otherLow)}`, 'i'),
          ];
          if (!subjectPatterns.some((p) => p.test(text))) continue;
          if ([...allowed].some((a) => otherLow.includes(a) || a.includes(otherLow.split(' ')[0])))
            continue;

          const absIdx = chunkStart + chunk.indexOf(text) + idx;
          leaks.push({
            severity: 'high',
            file: rel,
            line: lineNumber(content, absIdx),
            entryId: id,
            expectedName: byId[id],
            wrongPlantId: otherId,
            wrongPlantName: otherName,
            snippet: text.slice(0, 140),
          });
        }
      }
    }
  }
  return leaks;
}

function escapeRegExp(s) {
  return s.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
}

function scanGenericBuilders() {
  const issues = [];
  const patterns = [
    {
      re: /isCucumber\s*=\s*id\.contains\('komkommer'\)/,
      severity: 'high',
      note: 'Matches komkommerkruid — cucumber weetjes leak',
    },
    {
      re: /return 'Plant \$name op dezelfde diepte als in de pot \(tomaat iets dieper mag\)/,
      severity: 'medium',
      note: 'Tomato depth tip shown for all plants in cropCardSummaryFor transplant',
    },
    {
      re: /illustration: PlantHarvestIllustration\.ripeTomato/,
      severity: 'low',
      note: 'Tomato illustration used for all fruit harvest ripeness section',
    },
    {
      re: /illustration: PlantHarvestIllustration\.perfectTomato/,
      severity: 'low',
      note: 'Tomato illustration used for all plants perfect harvest section',
    },
    {
      re: /blob\.contains\('tomaat'\)/,
      severity: 'medium',
      note: 'Care/id blob treats any id/care mentioning tomaat as climbing/support',
    },
  ];

  for (const rel of GENERIC_BUILDER_FILES) {
    const content = read(rel);
    const lines = content.split('\n');
    for (const pat of patterns) {
      lines.forEach((line, i) => {
        if (pat.re.test(line)) {
          issues.push({
            severity: pat.severity,
            file: rel,
            line: i + 1,
            note: pat.note,
            snippet: line.trim().slice(0, 120),
          });
        }
      });
    }
  }
  return issues;
}

function scanSubstringFalsePositives() {
  /** ids where contains('komkommer') or contains('tomaat') misfires */
  const ids = Object.keys(JSON.parse(read('tool/vegetable_overview_all.json')));
  const misfires = [];
  for (const id of ids) {
    if (id.includes('komkommer') && id.includes('kruid')) {
      misfires.push({
        severity: 'high',
        entryId: id,
        note: "id.contains('komkommer') triggers cucumber branch in plant_weetjes_guide",
      });
    }
  }
  return misfires;
}

const curatedLeaks = scanCuratedEntries();
const builderIssues = scanGenericBuilders();
const substringMisfires = scanSubstringFalsePositives();

const report = {
  curatedLeaks,
  builderIssues,
  substringMisfires,
  summary: {
    curatedLeakCount: curatedLeaks.length,
    builderIssueCount: builderIssues.length,
    substringMisfireCount: substringMisfires.length,
  },
};

fs.writeFileSync(
  path.join(root, 'tool/plant_name_leak_audit.json'),
  JSON.stringify(report, null, 2),
);
console.log(JSON.stringify(report.summary, null, 2));
if (curatedLeaks.length) {
  console.log('\nCurated leaks (first 15):');
  console.log(JSON.stringify(curatedLeaks.slice(0, 15), null, 2));
}
if (builderIssues.length) {
  console.log('\nBuilder issues:');
  console.log(JSON.stringify(builderIssues, null, 2));
}
