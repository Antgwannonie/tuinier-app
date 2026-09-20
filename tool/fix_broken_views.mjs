import fs from 'fs';

function ensureImport(s) {
  if (!s.includes('plant_guide_detail_screen.dart')) {
    s = s.replace(
      /import 'plant_detail_widgets\.dart';\n/,
      "import 'plant_detail_widgets.dart';\nimport 'plant_guide_detail_screen.dart';\n",
    );
  }
  return s;
}

function ensureWrapFn(s, wrapName, sectionType) {
  if (s.includes(`Widget ${wrapName}(`)) return s;
  const fn = `
Widget ${wrapName}(
  BuildContext context,
  ${sectionType} section,
  Widget child,
) {
  return PlantDetailCard(
    child: wrapGuideDetailCard(
      context: context,
      title: section.title,
      summary: section.summary ?? section.subtitle,
      details: section.details,
      child: child,
    ),
  );
}

`;
  // After last import
  const lastImport = s.lastIndexOf('import ');
  const nl = s.indexOf('\n', lastImport);
  return s.slice(0, nl + 1) + fn + s.slice(nl + 1);
}

function fixBuildColumns(s) {
  // Add context param to _buildColumns if missing
  s = s.replace(
    /Widget _buildColumns\(\s*List<(\w+)> sections,/g,
    'Widget _buildColumns(\n    BuildContext context,\n    List<$1> sections,',
  );
  s = s.replace(
    /return _buildColumns\(\s*row\.sections/g,
    'return _buildColumns(\n          context,\n          row.sections',
  );
  s = s.replace(
    /return _buildColumns\(\s*(\w+)/g,
    (m, a) => {
      if (a === 'context') return m;
      return `return _buildColumns(\n          context,\n          ${a}`;
    },
  );
  return s;
}

// BLOOM
{
  let s = fs.readFileSync(
    'lib/widgets/plant_encyclopedia/plant_bloom_guide_view.dart',
    'utf8',
  );
  s = ensureImport(s);
  s = ensureWrapFn(s, '_wrapBloomCard', 'PlantBloomSection');
  s = fixBuildColumns(s);
  fs.writeFileSync(
    'lib/widgets/plant_encyclopedia/plant_bloom_guide_view.dart',
    s,
  );
  console.log('bloom ok');
}

// NUTRITION
{
  let s = fs.readFileSync(
    'lib/widgets/plant_encyclopedia/plant_nutrition_guide_view.dart',
    'utf8',
  );
  s = ensureImport(s);
  s = ensureWrapFn(s, '_wrapNutritionCard', 'PlantNutritionSection');
  s = fixBuildColumns(s);
  fs.writeFileSync(
    'lib/widgets/plant_encyclopedia/plant_nutrition_guide_view.dart',
    s,
  );
  console.log('nutrition ok');
}

// CARE
{
  let s = fs.readFileSync(
    'lib/widgets/plant_encyclopedia/plant_care_guide_view.dart',
    'utf8',
  );
  s = ensureImport(s);
  s = ensureWrapFn(s, '_wrapCareCard', 'PlantCareSection');
  s = fixBuildColumns(s);
  // care may use sections in icon grid
  s = s.replace(
    /Widget _build\w+\(\s*List<PlantCareSection>/g,
    (m) => m.replace('(', '(BuildContext context, '),
  );
  fs.writeFileSync(
    'lib/widgets/plant_encyclopedia/plant_care_guide_view.dart',
    s,
  );
  console.log('care ok');
}

// HARVEST
{
  let s = fs.readFileSync(
    'lib/widgets/plant_encyclopedia/plant_harvest_guide_view.dart',
    'utf8',
  );
  s = ensureImport(s);
  s = ensureWrapFn(s, '_wrapHarvestCard', 'PlantHarvestSection');
  s = fixBuildColumns(s);
  fs.writeFileSync(
    'lib/widgets/plant_encyclopedia/plant_harvest_guide_view.dart',
    s,
  );
  console.log('harvest ok');
}

// GROWTH - more damage
{
  let s = fs.readFileSync(
    'lib/widgets/plant_encyclopedia/plant_growth_guide_view.dart',
    'utf8',
  );
  s = ensureImport(s);
  s = ensureWrapFn(s, '_wrapGrowthCard', 'PlantGrowthSection');
  s = fixBuildColumns(s);

  // Fix _buildSpeedAndSupport
  s = s.replace(
    /Widget _buildSpeedAndSupport\(List<PlantGrowthSection> sections\) \{[\s\S]*?\n  \}/,
    `Widget _buildSpeedAndSupport(
    BuildContext context,
    List<PlantGrowthSection> sections,
  ) {
    return Column(
      children: [
        _wrapGrowthCard(
          context,
          sections[0],
          _SpeedSection(section: sections[0]),
        ),
        const SizedBox(height: 12),
        _wrapGrowthCard(
          context,
          sections[1],
          _SupportSection(section: sections[1]),
        ),
      ],
    );
  }`,
  );

  s = s.replace(
    /return _buildSpeedAndSupport\(row\.sections\);/,
    'return _buildSpeedAndSupport(context, row.sections);',
  );

  s = s.replace(
    /Widget _buildStressAndAi\(\{[\s\S]*?\n  \}/,
    `Widget _buildStressAndAi({
    required BuildContext context,
    required PlantGrowthSection section,
    PlantGrowthAlert? alert,
  }) {
    final stressCard = _wrapGrowthCard(
      context,
      section,
      _ColumnSection(section: section),
    );
    final aiCard = alert != null
        ? _GrowthAiCard(alert: alert)
        : const SizedBox.shrink();

    return Column(
      children: [stressCard, const SizedBox(height: 12), aiCard],
    );
  }`,
  );

  s = s.replace(
    /return _buildStressAndAi\(\s*section: row\.sections\.first,\s*alert: row\.alert,\s*\);/,
    `return _buildStressAndAi(
          context: context,
          section: row.sections.first,
          alert: row.alert,
        );`,
  );

  fs.writeFileSync(
    'lib/widgets/plant_encyclopedia/plant_growth_guide_view.dart',
    s,
  );
  console.log('growth ok');
}
