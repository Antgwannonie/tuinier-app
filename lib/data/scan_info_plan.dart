import 'package:flutter/material.dart';

import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/vegetable.dart';
import 'crop_growth_phase_guide.dart';
import 'moestuin_task_catalog.dart';
import 'scan_assessment_sync.dart';
import 'scan_report_modules.dart';
import 'scan_task_plan.dart';

List<ScanInfoItem> buildScanInfoItems({
  required PlantAiInsightReport insight,
  Vegetable? vegetable,
  PlantAiPhase? phase,
}) {
  final items = <ScanInfoItem>[];
  final seenTopics = <String>{};
  final carePhase = resolveCropCarePhase(
    phase: phase,
    growthPhaseDetail: insight.growthPhaseDetail,
  );

  void addItem(ScanInfoItem item) {
    final key = item.taskId ?? item.title.toLowerCase();
    if (seenTopics.contains(key)) return;
    seenTopics.add(key);
    items.add(item);
  }

  if (vegetable != null) {
    final phaseTips = phaseTipsForUi(carePhase, vegetable.nameNl);
    addItem(
      ScanInfoItem(
        title: 'Jouw fase: ${phaseTips.title}',
        summary: phaseTips.summary,
        steps: scanTaskStepsFromStrings(phaseTips.steps),
        icon: Icons.timeline_outlined,
        taskId: 'fase_${carePhase.name}',
      ),
    );
  }

  for (final a in letOpAssessments(insight)) {
    if (!isTaskIdAllowedForPhase(a.taskId, carePhase)) continue;
    addItem(scanInfoFromAssessment(a));
  }

  for (final point in insight.attentionPoints) {
    final text = point.trim();
    if (text.isEmpty) continue;
    addItem(
      ScanInfoItem(
        title: _titleFromAttentionPoint(text),
        summary: text,
        steps: _fallbackInfoSteps(text),
        icon: Icons.visibility_outlined,
      ),
    );
  }

  if (vegetable != null) {
    final contextId = 'plant_context_${vegetable.id}';
    if (!seenTopics.contains(contextId)) {
      addItem(
        ScanInfoItem(
          title: 'Over ${vegetable.nameNl}',
          summary: vegetable.care.trim().isNotEmpty
              ? vegetable.care.trim()
              : vegetable.summary.trim(),
          steps: _vegetableCareSteps(vegetable),
          icon: Icons.local_florist_outlined,
          taskId: contextId,
        ),
      );
    }
  }

  return items;
}

ScanInfoItem scanInfoFromAssessment(PlantScanAssessment assessment) {
  return ScanInfoItem(
    title: assessment.title,
    summary: assessment.description,
    steps: _infoStepsFromAssessment(assessment),
    icon: _iconForInfoTaskId(assessment.taskId),
    taskId: assessment.taskId,
  );
}

List<ScanTaskStep> resolveScanInfoSteps(ScanInfoItem item) {
  if (item.steps.isNotEmpty) return item.steps;
  return _fallbackInfoSteps(item.summary);
}

List<ScanTaskStep> _infoStepsFromAssessment(PlantScanAssessment assessment) {
  if (assessment.steps.isNotEmpty) {
    return scanTaskStepsFromStrings(assessment.steps);
  }
  return _fallbackInfoStepsForTaskId(assessment.taskId, assessment.description);
}

String _titleFromAttentionPoint(String text) {
  final t = text.toLowerCase();
  if (t.contains('bladluis')) return 'Let op: bladluis';
  if (t.contains('slak')) return 'Let op: slakken';
  if (t.contains('rups')) return 'Let op: rupsen';
  if (t.contains('meeldauw')) return 'Let op: meeldauw';
  if (t.contains('water') || t.contains('droog')) return 'Let op: water';
  if (t.length > 48) return '${text.substring(0, 45).trim()}…';
  return text;
}

List<ScanTaskStep> _fallbackInfoSteps(String text) {
  final t = text.toLowerCase();
  if (t.contains('bladluis') || t.contains('luis')) {
    return const [
      ScanTaskStep(
        title: 'Controleer onder de bladeren',
        detail: 'Bladluis zit vaak aan jonge scheuten en onderkant blad.',
      ),
      ScanTaskStep(
        title: 'Verwijder met water of vingers',
        detail: 'Spuit af met water of veeg voorzichtig weg.',
      ),
      ScanTaskStep(
        title: 'Herhaal na een paar dagen',
        detail: 'Blijf controleren tot het niet terugkomt.',
      ),
    ];
  }
  return const [
    ScanTaskStep(
      title: 'Loop even naar je plant',
      detail: 'Kijk of je het signaal op de plant zelf kunt bevestigen.',
    ),
    ScanTaskStep(
      title: 'Pas de aanbevolen actie toe',
      detail: 'Volg de tips hierboven zodra je het probleem ziet.',
    ),
    ScanTaskStep(
      title: 'Scan opnieuw over een week',
      detail: 'Zo zie je of de situatie verbetert.',
    ),
  ];
}

List<ScanTaskStep> _fallbackInfoStepsForTaskId(String taskId, String description) {
  final key = semanticTopicKeyForTaskId(taskId);
  return switch (key) {
    'bladluis' => _fallbackInfoSteps('bladluis'),
    'slak' => const [
      ScanTaskStep(title: 'Zoek slakken bij schemering'),
      ScanTaskStep(title: 'Verwijder slakken en beschadigde bladeren'),
      ScanTaskStep(title: 'Bescherm jonge planten indien nodig'),
    ],
    'rups' => const [
      ScanTaskStep(title: 'Kijk onder bladeren op eitjes of rupsen'),
      ScanTaskStep(title: 'Verwijder rupsen voorzichtig met de hand'),
      ScanTaskStep(title: 'Controleer binnen een week opnieuw'),
    ],
    'meeldauw' => const [
      ScanTaskStep(title: 'Controleer blad en stengel op wit poeder'),
      ScanTaskStep(title: 'Verwijder zwaar aangetaste bladeren'),
      ScanTaskStep(title: 'Zorg voor goede luchtcirculatie rond de plant'),
    ],
    'water' => const [
      ScanTaskStep(title: 'Voel de grond 2 cm diep'),
      ScanTaskStep(title: 'Geef water aan de voet als het droog is'),
      ScanTaskStep(title: 'Controleer morgen opnieuw'),
    ],
    'onkruid' => const [
      ScanTaskStep(title: 'Wied voorzichtig rond de wortels'),
      ScanTaskStep(title: 'Laat een dun laagje mulch liggen indien mogelijk'),
      ScanTaskStep(title: 'Herhaal zodra nieuw onkruid verschijnt'),
    ],
    _ => _fallbackInfoSteps(description),
  };
}

List<ScanTaskStep> _vegetableCareSteps(Vegetable vegetable) {
  final steps = <ScanTaskStep>[];
  if (vegetable.water.trim().isNotEmpty) {
    steps.add(ScanTaskStep(title: 'Water', detail: vegetable.water.trim()));
  }
  if (vegetable.commonIssues.trim().isNotEmpty) {
    steps.add(
      ScanTaskStep(
        title: 'Typische aandachtspunten',
        detail: vegetable.commonIssues.trim(),
      ),
    );
  }
  if (vegetable.harvestTips.trim().isNotEmpty) {
    steps.add(
      ScanTaskStep(
        title: 'Oogsttip',
        detail: vegetable.harvestTips.trim(),
      ),
    );
  }
  if (steps.isEmpty) {
    steps.add(
      ScanTaskStep(
        title: 'Houd je plant in de gaten',
        detail: vegetable.summary.trim(),
      ),
    );
  }
  return steps;
}

IconData _iconForInfoTaskId(String taskId) {
  final key = semanticTopicKeyForTaskId(taskId);
  return switch (key) {
    'water' => Icons.water_drop_outlined,
    'onkruid' => Icons.grass_outlined,
    'bladluis' ||
    'witte_vlieg' ||
    'spint' ||
    'trips' ||
    'rups' ||
    'slak' =>
      Icons.bug_report_outlined,
    'meeldauw' || 'schimmel' => Icons.coronavirus_outlined,
    'snoei' => Icons.content_cut_outlined,
    'voeding' => Icons.compost_outlined,
    _ => Icons.lightbulb_outline,
  };
}
