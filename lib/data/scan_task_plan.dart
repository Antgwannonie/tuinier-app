import 'package:flutter/material.dart';

import '../models/plant_ai_insight_report.dart';
import 'scan_report_modules.dart';

List<ScanTaskStep> resolveScanTaskSteps(ScanTaskItem task) {
  if (task.steps.isNotEmpty) return task.steps;
  return _fallbackSteps(task.title, task.icon);
}

List<ScanTaskStep> scanTaskStepsFromStrings(List<String> raw) {
  return raw
      .where((s) => s.trim().isNotEmpty)
      .map((s) => ScanTaskStep(title: s.trim()))
      .toList();
}

ScanTaskItem scanTaskFromAssessment(PlantScanAssessment assessment) {
  return ScanTaskItem(
    title: assessment.title,
    summary: assessment.visibleOnPhoto
        ? 'Zichtbaar op je scanfoto'
        : assessment.description,
    description: assessment.description,
    steps: scanTaskStepsFromStrings(assessment.steps),
    priority: AiPriority.medium,
    timeline: 'Vandaag',
    icon: _iconForTask(assessment.title),
  );
}

ScanTaskItem scanTaskFromRecommendedAction(AiRecommendedAction action) {
  return ScanTaskItem(
    title: action.title,
    summary: action.reasonSummary,
    description: action.description,
    steps: scanTaskStepsFromStrings(action.steps),
    priority: action.priority,
    timeline: _timelineForPriority(action.priority),
    icon: _iconForTask(action.title),
  );
}

ScanTaskItem scanTaskFromCoachTask(AiCoachTaskSuggestion task) {
  return ScanTaskItem(
    title: task.title,
    summary: task.body,
    steps: _fallbackSteps(task.title, _iconForKind(task.kind)),
    priority: AiPriority.medium,
    timeline: 'Deze week',
    icon: _iconForKind(task.kind),
  );
}

List<ScanTaskStep> _fallbackSteps(String title, IconData icon) {
  final t = title.toLowerCase();
  if (t.contains('water') || t.contains('giet')) {
    return const [
      ScanTaskStep(
        title: 'Controleer de grond',
        detail: 'Voel 2 cm onder het oppervlak — droog betekent water geven.',
      ),
      ScanTaskStep(
        title: 'Geef water aan de voet',
        detail: 'Giet rustig tot de grond vochtig is, niet nat.',
      ),
      ScanTaskStep(
        title: 'Check morgen opnieuw',
        detail: 'Kijk of de bladeren er frisser uitzien.',
      ),
    ];
  }
  if (t.contains('plaag') || t.contains('luis') || t.contains('insect')) {
    return const [
      ScanTaskStep(
        title: 'Inspecteer blad en stengel',
        detail: 'Kijk onder de bladeren en bij jonge scheuten.',
      ),
      ScanTaskStep(
        title: 'Verwijder zichtbare plagen',
        detail: 'Spuit af met water of verwijder met de hand.',
      ),
      ScanTaskStep(
        title: 'Herhaal over een paar dagen',
        detail: 'Controleer of het probleem kleiner wordt.',
      ),
    ];
  }
  if (t.contains('bemest') || t.contains('voed')) {
    return const [
      ScanTaskStep(title: 'Kies passende voeding voor dit gewas'),
      ScanTaskStep(title: 'Geef volgens de dosering op de verpakking'),
      ScanTaskStep(title: 'Giet daarna licht door zodat voeding de wortels bereikt'),
    ];
  }
  if (t.contains('oogst')) {
    return const [
      ScanTaskStep(title: 'Kies rijpe vruchten of bladeren op de foto'),
      ScanTaskStep(title: 'Oogst voorzichtig met schone schaar of hand'),
      ScanTaskStep(title: 'Laat kleine vruchten door groeien voor later'),
    ];
  }
  return [
    ScanTaskStep(title: 'Bereid de taak voor: $title'),
    ScanTaskStep(title: 'Voer de taak rustig uit op de plant'),
    ScanTaskStep(title: 'Controleer over een paar dagen het resultaat'),
  ];
}

String _timelineForPriority(AiPriority p) {
  switch (p) {
    case AiPriority.urgent:
    case AiPriority.high:
      return 'Vandaag';
    case AiPriority.medium:
      return 'Binnen 2 dagen';
    case AiPriority.low:
      return 'Deze week';
  }
}

IconData _iconForTask(String title) {
  final t = title.toLowerCase();
  if (t.contains('water') || t.contains('giet')) return Icons.water_drop_outlined;
  if (t.contains('snoei') || t.contains('knip')) return Icons.content_cut_outlined;
  if (t.contains('plaag') || t.contains('luis')) return Icons.bug_report_outlined;
  if (t.contains('bemest') || t.contains('voed')) return Icons.grass_outlined;
  if (t.contains('oogst')) return Icons.shopping_basket_outlined;
  return Icons.task_alt_outlined;
}

IconData _iconForKind(String kind) {
  switch (kind) {
    case 'water':
      return Icons.water_drop_outlined;
    case 'fertilize':
      return Icons.grass_outlined;
    case 'prune':
      return Icons.content_cut_outlined;
    case 'harvest':
      return Icons.shopping_basket_outlined;
    default:
      return Icons.visibility_outlined;
  }
}
