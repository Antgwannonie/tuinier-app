import 'package:flutter/material.dart';

import '../widgets/home_moestuin_actions.dart';
import 'home_action_plan.dart';

/// Bepaalt een passend, levendig icoon voor een stap in het stappenplan.
IconData homeActionStepIcon({
  required HomeActionStep step,
  required GardenHomeActionKind actionKind,
  required int index,
}) {
  if (step.icon != null) return step.icon!;

  final title = step.title.toLowerCase();
  final detail = (step.detail ?? '').toLowerCase();
  final text = '$title $detail';

  if (text.contains('licht') || text.contains('daglicht')) {
    return Icons.wb_sunny_rounded;
  }
  if (text.contains('beeld') || text.contains('zichtbaar')) {
    return Icons.center_focus_strong;
  }
  if (text.contains('upload') ||
      text.contains('scan') ||
      text.contains('foto')) {
    return Icons.photo_camera_rounded;
  }
  if (text.contains('rijpheid') || text.contains('rijp')) {
    return Icons.spa_rounded;
  }
  if (text.contains('oogstadvies') || text.contains('oogst deze')) {
    return Icons.agriculture_rounded;
  }
  if (text.contains('voorzichtig') || text.contains('pluk')) {
    return Icons.pan_tool;
  }
  if (text.contains('meer oogst')) {
    return Icons.refresh_rounded;
  }
  if (text.contains('herken') ||
      text.contains('plaag') ||
      text.contains('luis') ||
      text.contains('rups')) {
    return Icons.pest_control;
  }
  if (text.contains('aanpak') || text.contains('behandel')) {
    return Icons.medical_services;
  }
  if (text.contains('water') || text.contains('giet')) {
    return Icons.water_drop_rounded;
  }
  if (text.contains('onkruid')) {
    return Icons.grass_rounded;
  }
  if (text.contains('vorst') || text.contains('kou')) {
    return Icons.ac_unit;
  }
  if (text.contains('geplant') || text.contains('markeer')) {
    return Icons.flag_rounded;
  }
  if (text.contains('planten') || text.contains('zaai')) {
    return Icons.yard_rounded;
  }
  if (text.contains('kalender') || text.contains('controleer')) {
    return Icons.event_note;
  }
  if (text.contains('planning') || text.contains('advies')) {
    return Icons.lightbulb_rounded;
  }
  if (text.contains('situatie')) {
    return Icons.analytics;
  }
  if (text.contains('schimmel') || text.contains('ziekte')) {
    return Icons.coronavirus;
  }
  if (text.contains('voeding') || text.contains('bemest')) {
    return Icons.eco_rounded;
  }

  return switch (actionKind) {
    GardenHomeActionKind.harvest => Icons.agriculture_rounded,
    GardenHomeActionKind.firstPhoto ||
    GardenHomeActionKind.weeklyScan =>
      Icons.photo_camera_rounded,
    GardenHomeActionKind.planPlant => Icons.yard_rounded,
    GardenHomeActionKind.aiWarning => Icons.pest_control,
    GardenHomeActionKind.seasonWarning => Icons.warning_amber_rounded,
    GardenHomeActionKind.aiCoach => Icons.psychology,
    GardenHomeActionKind.calendarHarvest ||
    GardenHomeActionKind.calendarCountdown =>
      Icons.event_available_rounded,
  };
}
