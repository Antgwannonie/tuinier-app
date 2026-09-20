import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'crop_bloom_countdown.dart';
import 'crop_growth_phase_guide.dart';
import 'moestuin_task_catalog.dart';

/// Bouwt de fasebewuste checklist voor de AI-prompt.
String buildCropCareChecklistPrompt({
  required Vegetable vegetable,
  int? daysSincePlanted,
  String? phaseLabel,
  PlantAiPhase? previousPhase,
  bool isFirstScan = false,
}) {
  final estimatedPhase = resolveCropCarePhase(
    phase: previousPhase,
    daysSincePlanted: daysSincePlanted,
    isFirstScan: isFirstScan,
  );

  final lines = <String>[
    '=== FASEBEWUSTE CHECKLIST · ${vegetable.nameNl.toUpperCase()} ===',
    '',
    'STAP A (VERPLICHT vóór scanAssessments):',
    '1. Bepaal op de FOTO de groeifase: top-level "phase" + insight "growthPhaseDetail".',
    '2. Gebruik ALLEEN de checklist-sectie hieronder die bij JOUW vastgestelde fase hoort.',
    '3. Output GEEN taken/let_op/positive die bij een andere fase horen (geen oogst bij zaailing).',
    '',
    'Koppeling phase → growthPhaseDetail:',
    '- seedling → zaailing of jonge_plant (kiemplant zichtbaar?)',
    '- growing → vegetatief',
    '- flowering → bloei',
    '- fruiting → vruchtvorming',
    '- almost_ripe / ripe → oogst',
    '- Alleen grond/zaadbed zonder plant → phase seedling + growthPhaseDetail zaailing OF foto zaadbed',
    '',
    'Hint uit app (niet blind volgen): geschatte fase = ${estimatedPhase.labelNl}',
    if (phaseLabel?.trim().isNotEmpty == true)
      'Vorige scan fase: ${phaseLabel!.trim()}',
    if (daysSincePlanted != null) 'Dagen sinds zaai/plant: $daysSincePlanted',
    '',
    '--- Plant-specifiek (${vegetable.nameNl}) ---',
    '- gewas_familie: ${vegetable.family}',
    if (vegetable.cropDuration?.trim().isNotEmpty == true)
      '- teelttijd: ${vegetable.cropDuration}',
    if (vegetable.water.trim().isNotEmpty) '- water: ${vegetable.water}',
    if (vegetable.care.trim().isNotEmpty) '- verzorging: ${vegetable.care}',
    if (vegetable.soilAndFood.trim().isNotEmpty)
      '- bodem_voeding: ${vegetable.soilAndFood}',
    for (final issue in _parseCommonIssues(vegetable.commonIssues))
      '- ${_issueToTaskId(issue)}: $issue',
    for (final extra in _familySpecificItems(vegetable))
      '- ${extra.id}: ${extra.labelNl} — ${extra.aiHint}',
    if (cropUsesBloomCountdown(vegetable))
      '- bloei_fase: moestuinbloem — bloei centraal, geen oogst',
    '',
    '--- Checklist per fase (gebruik ALLEEN jouw fase) ---',
  ];

  for (final phase in CropCarePhase.values) {
    lines.add('');
    lines.add('>>> FASE: ${phase.labelNl} <<<');
    lines.add(phaseGuidanceForAi(phase));
    for (final (id, label, hint) in phaseSpecificChecklistItems(phase)) {
      lines.add('- $id: $label — $hint');
    }
    for (final item in kUniversalMoestuinTasks) {
      if (isTaskIdAllowedForPhase(item.id, phase)) {
        lines.add('- ${item.id}: ${item.labelNl} — ${item.aiHint}');
      }
    }
    for (final extra in _familySpecificItems(vegetable)) {
      if (isTaskIdAllowedForPhase(extra.id, phase)) {
        lines.add('- ${extra.id}: ${extra.labelNl} — ${extra.aiHint}');
      }
    }
  }

  lines.add('');
  lines.add(
    'scanAssessments: alleen items uit JOUW fase-sectie. '
    'kind=positive minstens 1 als iets goed gaat. '
    'Zelfde taskId nooit als task én let_op.',
  );

  return lines.join('\n');
}

List<String> _parseCommonIssues(String raw) {
  final text = raw.trim();
  if (text.isEmpty) return const [];
  return text
      .split(RegExp(r'[,;]|\ben\b'))
      .map((s) => s.trim())
      .where((s) => s.length > 2)
      .toList();
}

String _issueToTaskId(String issue) {
  final t = issue.toLowerCase();
  if (t.contains('bladluis') || t.contains('luis')) return 'bladluis';
  if (t.contains('koolrups') || t.contains('rups')) return 'rupsen';
  if (t.contains('slak')) return 'slakken';
  if (t.contains('witte vlieg')) return 'witte_vlieg';
  if (t.contains('spint')) return 'spint';
  if (t.contains('trips')) return 'trips';
  if (t.contains('meeldauw')) return 'meeldauw';
  if (t.contains('schimmel') || t.contains('vlek')) return 'schimmel';
  if (t.contains('water') || t.contains('droog')) return 'water_geven';
  return 'risico_${t.replaceAll(RegExp(r'[^a-z0-9]+'), '_').replaceAll(RegExp(r'_+'), '_').replaceAll(RegExp(r'^_|_$'), '')}';
}

List<MoestuinTaskCatalogItem> _familySpecificItems(Vegetable vegetable) {
  final family = vegetable.family.toLowerCase();
  final id = vegetable.id.toLowerCase();
  final out = <MoestuinTaskCatalogItem>[];

  if (family.contains('nachtschade') ||
      id.contains('tomaat') ||
      id.contains('paprika') ||
      id.contains('aubergine')) {
    out.add(
      const MoestuinTaskCatalogItem(
        id: 'dieven_verwijderen',
        labelNl: 'Dieven verwijderen',
        topicKey: 'snoei',
        aiHint: 'Zijscheuten in bladoks — pas relevant vanaf vegetatieve fase.',
      ),
    );
  }

  if (family.contains('kool') ||
      id.contains('broccoli') ||
      id.contains('spruit') ||
      id.contains('bloemkool')) {
    out.add(
      const MoestuinTaskCatalogItem(
        id: 'koolrups',
        labelNl: 'Koolrups controleren',
        topicKey: 'rups',
        aiHint: 'Gaten in blad, rupsen of eitjes onder blad.',
      ),
    );
  }

  if (family.contains('cucurbit') ||
      id.contains('komkommer') ||
      id.contains('courgette') ||
      id.contains('pompoen')) {
    out.add(
      const MoestuinTaskCatalogItem(
        id: 'cucurbit_meeldauw',
        labelNl: 'Meeldauw (cucurbit)',
        topicKey: 'meeldauw',
        aiHint: 'Wit poeder op blad.',
      ),
    );
  }

  if (id.contains('aardbei')) {
    out.add(
      const MoestuinTaskCatalogItem(
        id: 'aardbei_runners',
        labelNl: 'Uitlopers beheren',
        aiHint: 'Veel uitlopers of te dichte opstand.',
      ),
    );
  }

  if (id.contains('tomaat')) {
    out.add(
      const MoestuinTaskCatalogItem(
        id: 'tomaat_onderste_blad',
        labelNl: 'Onderste blad verwijderen',
        topicKey: 'snoei',
        aiHint: 'Onderste bladeren raken grond — vanaf jonge plant/vegetatief.',
      ),
    );
  }

  return out;
}
