// ignore_for_file: avoid_print

import 'dart:io';

const _outPath = r'lib/data/flower_overview_facts_map.dart';
const _pyPath = 'gen_flower_facts.py';

const _bee = 'assets/images/bloom/bloom_pollinator_bee.png';
const _but = 'assets/images/bloom/bloom_pollinator_butterfly.png';
const _pest = 'assets/images/combination/combo_pest_plants.png';
const _ben = 'assets/images/combination/combo_benefits.png';
const _har = 'assets/images/harvest/harvest_basket.png';
const _soil = 'assets/images/combination/combo_soil_improvers.png';

const _assetByToken = {
  'BEE': _bee,
  'BUT': _but,
  'PEST': _pest,
  'BEN': _ben,
  'HAR': _har,
  'SOIL': _soil,
};

const _order = [
  'zonnebloem', 'afrikaantje', 'goudsbloem', 'oostindische_kers', 'komkommerkruid',
  'facelia', 'korenbloem', 'cosmos', 'boekweit', 'witte_klaver', 'rode_klaver',
  'duizendblad', 'zaadslurf', 'limnanthes', 'monarda', 'zonnehoed', 'verbena',
  'wilde_marjolein', 'hysop', 'mosterd_geel', 'klaproos', 'bijenmengsel',
  'lindebloesem', 'tagetes_patula', 'alyssum_sneeuw', 'calendula_officinalis',
  'zinnia', 'lupine_groenbemester', 'stiefmoedje', 'ringelbloem', 'lavendel',
  'ui_bloei', 'look_bloei', 'dille_bloei', 'koriander_bloei', 'salie_bloei',
  'tijm_bloei', 'basilicum_bloei', 'munt_bloei',
];

String _esc(String s) => s.replaceAll(r"\", r"\\").replaceAll("'", r"\'");

String? _quoted(String block, String key) {
  final re = RegExp('(?<![a-zA-Z_])${RegExp.escape(key)}="([^"]*)"');
  final m = re.firstMatch(block);
  return m?.group(1);
}

bool? _boolField(String block, String key) {
  final re = RegExp('$key: (true|false)', multiLine: true);
  final m = re.firstMatch(block);
  if (m == null) {
    final re2 = RegExp('$key=(True|False)');
    final m2 = re2.firstMatch(block);
    if (m2 == null) return null;
    return m2.group(1) == 'True';
  }
  return m.group(1) == 'true';
}

List<String> _tupleStrings(String block, String key) {
  final re = RegExp('$key=\\(([^)]*(?:\\([^)]*\\)[^)]*)*)\\)', dotAll: true);
  final m = re.firstMatch(block);
  if (m == null) return [];
  final inner = m.group(1)!;
  return RegExp(r'"([^"]*)"').allMatches(inner).map((x) => x.group(1)!).toList();
}

List<(String, String)> _whyPairs(String block) {
  final re = RegExp(r'why=\((.*)\),\s*poll=', dotAll: true);
  final m = re.firstMatch(block);
  if (m == null) return [];
  final out = <(String, String)>[];
  for (final pm in RegExp(r'\((\w+),\s*"([^"]*)"\)').allMatches(m.group(1)!)) {
    final token = pm.group(1)!;
    final label = pm.group(2)!;
    final asset = _assetByToken[token];
    if (asset == null) {
      throw StateError('Unknown why token $token');
    }
    out.add((asset, label));
  }
  return out;
}

List<int> _poll(String block) {
  final m = RegExp(r'poll=\((\d+),\s*(\d+),\s*(\d+),\s*(\d+)\)').firstMatch(block);
  if (m == null) throw StateError('poll missing');
  return [for (var i = 1; i <= 4; i++) int.parse(m.group(i)!)];
}

List<String> _cal(String block) {
  final m = RegExp(r'cal=\("([^"]*)",\s*"(\{[^"]*\})",\s*"(\{[^"]*\})",\s*"(\{[^"]*\})"(?:,\s*"(\{[^"]*\})")?\)', dotAll: true)
      .firstMatch(block);
  if (m == null) throw StateError('cal missing');
  return [
    m.group(1)!,
    m.group(2)!,
    m.group(3)!,
    m.group(4)!,
    if (m.group(5) != null) m.group(5)! else '{9, 10}',
  ];
}

Map<String, String> _parseDictBlock(String block) {
  final id = _quoted(block, 'id');
  if (id == null) throw StateError('id missing');
  final why = _whyPairs(block);
  if (why.length != 4) throw StateError('why must be 4 for $id');
  final poll = _poll(block);
  final cal = _cal(block);
  final cols = _tupleStrings(block, 'col');
  if (cols.isEmpty) {
    throw StateError('col missing for $id');
  }
  final feat = _tupleStrings(block, 'feat');
  final sum1 = _quoted(block, 'sum1');
  final sum2 = _quoted(block, 'sum2');
  final tip = _quoted(block, 'tip');
  if (sum1 == null || sum2 == null || tip == null) {
    throw StateError('summary/tip missing for $id');
  }

  String g(String key, String def) => _quoted(block, key) ?? def;

  return {
    'id': id,
    'sp': g('sp', 'Volle zon'),
    'sps': g('sps', '6+ uur per dag'),
    'w': g('w', 'Gemiddeld'),
    'ws': g('ws', 'Houd de grond gelijkmatig vochtig'),
    'd': g('d', 'Makkelijk'),
    'ds': g('ds', 'Geschikt voor beginners'),
    'life': g('life', 'Eenjarig'),
    'ls': g('ls', 'Bloeit één seizoen, zaai opnieuw'),
    'sum1': sum1,
    'sum2': sum2,
    'h': g('h', '40–60 cm'),
    'wdt': g('wdt', '25–40 cm'),
    'bloom': g('bloom', 'Juni–augustus'),
    'dur': g('dur', 'Gemiddeld'),
    'frag': g('frag', 'Licht geurend of neutraal'),
    'whd': g('whd', 'Nee, bescherm of herplant'),
    'drd': g('drd', 'Nee, regelmatig water'),
    'suit': g('suit', '_suitableFull'),
    'tip': tip,
    'wh': (_boolField(block, 'wh') ?? false).toString(),
    'dr': (_boolField(block, 'dr') ?? false).toString(),
    'plant_out': (_boolField(block, 'plant_out') ?? true).toString(),
    'why0a': why[0].$1,
    'why0l': why[0].$2,
    'why1a': why[1].$1,
    'why1l': why[1].$2,
    'why2a': why[2].$1,
    'why2l': why[2].$2,
    'why3a': why[3].$1,
    'why3l': why[3].$2,
    'poll0': poll[0].toString(),
    'poll1': poll[1].toString(),
    'poll2': poll[2].toString(),
    'poll3': poll[3].toString(),
    'cal0': cal[0],
    'cal1': cal[1],
    'cal2': cal[2],
    'cal3': cal[3],
    'cal4': cal[4],
    'cols': cols.join('|'),
    'feat': feat.join('|'),
  };
}

List<String> _loadSpecsFromPy(String pyText) {
  final start = pyText.indexOf('SPECS = [');
  final end = pyText.indexOf('# Reorder to match user list');
  if (start < 0 || end < 0) throw StateError('SPECS block not found in py');
  final chunk = pyText.substring(start, end);
  final blocks = chunk.split(RegExp(r'\n    dict\(\n')).skip(1);
  return blocks.map((b) => 'dict(\n$b').toList();
}

String _whyPlant(Map<String, String> s) {
  final b = StringBuffer('    whyPlantReasons: [\n');
  for (var i = 0; i < 4; i++) {
    b.writeln('      FlowerWhyPlantReason(');
    b.writeln("        imageAsset: '${s['why${i}a']}',");
    b.writeln("        label: '${_esc(s['why${i}l']!)}',");
    b.writeln('      ),');
  }
  b.writeln('    ],');
  return b.toString();
}

String _calendar(Map<String, String> s) {
  final plantOut = s['plant_out'] == 'true';
  final b = StringBuffer('    calendarMoments: [\n');
  b.writeln('      FlowerCalendarMoment(');
  b.writeln('        timeline: PlantMonthTimeline(');
  b.writeln("          label: '${_esc(s['cal0']!)}',");
  b.writeln('          months: ${s['cal1']},');
  b.writeln('        ),');
  b.writeln('        accentColor: Color(0xFF43A047),');
  b.writeln("        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',");
  b.writeln('      ),');
  if (plantOut) {
    b.writeln('      FlowerCalendarMoment(');
    b.writeln("        timeline: PlantMonthTimeline(label: 'Uitplanten', months: ${s['cal2']}),");
    b.writeln('        accentColor: Color(0xFF2E7D32),');
    b.writeln("        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',");
    b.writeln('      ),');
  }
  b.writeln('      FlowerCalendarMoment(');
  b.writeln("        timeline: PlantMonthTimeline(label: 'Bloei', months: ${s['cal3']}),");
  b.writeln('        accentColor: Color(0xFF7B1FA2),');
  b.writeln("        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',");
  b.writeln('      ),');
  b.writeln('      FlowerCalendarMoment(');
  b.writeln("        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: ${s['cal4']}),");
  b.writeln('        accentColor: Color(0xFFF57C00),');
  b.writeln("        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',");
  b.writeln('      ),');
  b.writeln('    ],');
  return b.toString();
}

String _buildEntry(Map<String, String> s) {
  final cols = s['cols']!.split('|').map((h) => '      Color($h),').join('\n');
  final feats = s['feat']!.split('|').map((f) => "      '${_esc(f)}',").join('\n');
  return '''  '${s['id']}': _FlowerFacts(
    standplaats: '${_esc(s['sp']!)}',
    standplaatsSubtitle: '${_esc(s['sps']!)}',
    water: '${_esc(s['w']!)}',
    waterSubtitle: '${_esc(s['ws']!)}',
    difficulty: '${_esc(s['d']!)}',
    difficultySubtitle: '${_esc(s['ds']!)}',
    lifespan: '${_esc(s['life']!)}',
    lifespanSubtitle: '${_esc(s['ls']!)}',
    summary:
        '${_esc(s['sum1']!)} '
        '${_esc(s['sum2']!)}',
${_whyPlant(s)}
    pollinatorRatings: FlowerPollinatorRatings(
      bees: ${s['poll0']},
      butterflies: ${s['poll1']},
      bumblebees: ${s['poll2']},
      hoverflies: ${s['poll3']},
    ),
    height: '${_esc(s['h']!)}',
    width: '${_esc(s['wdt']!)}',
    bloomPeriod: '${_esc(s['bloom']!)}',
    bloomDuration: '${_esc(s['dur']!)}',
${_calendar(s)}
    flowerColors: [
$cols
    ],
    fragrance: '${_esc(s['frag']!)}',
    winterHardy: ${s['wh']},
    winterHardyDetail: '${_esc(s['whd']!)}',
    droughtResistant: ${s['dr']},
    droughtResistantDetail: '${_esc(s['drd']!)}',
    suitableFor: ${s['suit']},
    keyFeatures: [
$feats
    ],
    tip:
        '${_esc(s['tip']!)}',
  ),''';
}

void main() {
  final scriptDir = File(Platform.script.toFilePath()).parent.path;
  final pyFile = File('$scriptDir/$_pyPath');
  if (!pyFile.existsSync()) {
    stderr.writeln('Missing ${pyFile.path}');
    exit(1);
  }
  var pyText = pyFile.readAsStringSync();
  pyText = pyText.replaceAll('\r\n', '\n');
  final byId = <String, Map<String, String>>{};
  for (final block in _loadSpecsFromPy(pyText)) {
    final parsed = _parseDictBlock(block);
    byId[parsed['id']!] = parsed;
  }

  final missing = _order.where((id) => !byId.containsKey(id)).toList();
  if (missing.isNotEmpty) {
    stderr.writeln('Missing specs: ${missing.join(', ')}');
    exit(1);
  }

  final entries = _order.map((id) => _buildEntry(byId[id]!)).join('\n');
  final root = Directory(scriptDir).parent.path;
  final outFile = File('$root/$_outPath');
  outFile.parent.createSync(recursive: true);
  outFile.writeAsStringSync(
    "part of 'flower_overview_data.dart';\n\n"
    'const Map<String, _FlowerFacts> _kFlowerFacts = {\n'
    '$entries\n'
    '};\n',
  );
  print('Wrote ${outFile.path} with ${_order.length} entries');
}