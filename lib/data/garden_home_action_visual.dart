import 'package:flutter/material.dart';

import '../data/plant_health_warnings.dart';
import '../theme/tuinier_colors.dart';
import '../widgets/home_moestuin_actions.dart';
import '../models/garden_plant_profile.dart';

/// Ernst van een home-actie: rood / geel / groen.
enum GardenActionSeverity {
  danger,
  warning,
  success,
}

/// Icoon + kleur + korte kop voor één actie in “Acties voor jou”.
class GardenHomeActionVisual {
  const GardenHomeActionVisual({
    required this.severity,
    required this.icon,
    required this.label,
  });

  final GardenActionSeverity severity;
  final IconData icon;
  final String label;

  Color get color => switch (severity) {
        GardenActionSeverity.danger => TuinierColors.error,
        GardenActionSeverity.warning => TuinierColors.warning,
        GardenActionSeverity.success => TuinierColors.success,
      };
}

GardenHomeActionVisual gardenHomeActionVisual(
  GardenHomeAction action,
  GardenPlantProfile? profile,
) {
  if (action.isPlantInfo) {
    return _plantInfoListVisual(action, profile);
  }
  return _taskActionVisual(action, profile);
}

GardenHomeActionVisual _plantInfoListVisual(
  GardenHomeAction action,
  GardenPlantProfile? profile,
) {
  final veg = action.vegetable.nameNl;
  final topic = action.scheduled?.topic ??
      _topicFromSubtitle(action.subtitle);
  final severity = switch (action.kind) {
    GardenHomeActionKind.aiWarning => GardenActionSeverity.danger,
    GardenHomeActionKind.seasonWarning => GardenActionSeverity.warning,
    _ => GardenActionSeverity.success,
  };
  return GardenHomeActionVisual(
    severity: severity,
    icon: Icons.info_outline,
    label: _headline(veg, topic),
  );
}

GardenHomeActionVisual _taskActionVisual(
  GardenHomeAction action,
  GardenPlantProfile? profile,
) {
  final veg = action.vegetable.nameNl;
  final aiWarnings = activeAiWarningsFor(profile);
  final seasonWarnings = activeSeasonWarningsFor(
    profile: profile,
    vegetable: action.vegetable,
  );
  final highlight = plantWarningHighlightLevel(
    profile: profile,
    vegetable: action.vegetable,
  );

  if (action.kind == GardenHomeActionKind.aiWarning ||
      action.kind == GardenHomeActionKind.seasonWarning) {
    return GardenHomeActionVisual(
      severity: action.kind == GardenHomeActionKind.aiWarning
          ? GardenActionSeverity.danger
          : GardenActionSeverity.warning,
      icon: action.kind == GardenHomeActionKind.aiWarning
          ? _iconForWarningText(action.subtitle)
          : Icons.warning_amber_rounded,
      label: _headline(veg, _topicFromSubtitle(action.subtitle)),
    );
  }

  if (highlight == PlantWarningHighlightLevel.danger &&
      action.kind != GardenHomeActionKind.harvest &&
      action.kind != GardenHomeActionKind.calendarHarvest) {
    return GardenHomeActionVisual(
      severity: GardenActionSeverity.danger,
      icon: Icons.error_rounded,
      label: _headlineForKind(action, veg),
    );
  }

  if (seasonWarnings.isNotEmpty &&
      (action.kind == GardenHomeActionKind.weeklyScan ||
          action.kind == GardenHomeActionKind.firstPhoto)) {
    return GardenHomeActionVisual(
      severity: GardenActionSeverity.warning,
      icon: Icons.warning_amber_rounded,
      label: _headline(veg, _topicFromSeasonWarning(seasonWarnings.first)),
    );
  }

  return switch (action.kind) {
    GardenHomeActionKind.planPlant => GardenHomeActionVisual(
        severity: GardenActionSeverity.success,
        icon: Icons.yard_rounded,
        label: _headline(veg, _plantTopic(action.subtitle)),
      ),
    GardenHomeActionKind.firstPhoto => GardenHomeActionVisual(
        severity: GardenActionSeverity.warning,
        icon: Icons.photo_camera_rounded,
        label: _headline(veg, 'Eerste scan'),
      ),
    GardenHomeActionKind.weeklyScan => GardenHomeActionVisual(
        severity: GardenActionSeverity.warning,
        icon: Icons.photo_camera_rounded,
        label: _headline(veg, 'Scan'),
      ),
    GardenHomeActionKind.harvest => GardenHomeActionVisual(
        severity: GardenActionSeverity.success,
        icon: _harvestIcon(action.subtitle),
        label: _headline(veg, _harvestTopic(action.subtitle)),
      ),
    GardenHomeActionKind.calendarHarvest => GardenHomeActionVisual(
        severity: GardenActionSeverity.success,
        icon: Icons.event_available_rounded,
        label: _headline(veg, _calendarHarvestTopic(action.subtitle)),
      ),
    GardenHomeActionKind.aiWarning => GardenHomeActionVisual(
        severity: GardenActionSeverity.danger,
        icon: Icons.bug_report,
        label: _headline(veg, _topicFromSubtitle(action.subtitle)),
      ),
    GardenHomeActionKind.seasonWarning => GardenHomeActionVisual(
        severity: GardenActionSeverity.warning,
        icon: Icons.warning_amber_rounded,
        label: _headline(veg, _topicFromSubtitle(action.subtitle)),
      ),
    GardenHomeActionKind.aiCoach => GardenHomeActionVisual(
        severity: GardenActionSeverity.warning,
        icon: Icons.psychology,
        label: _headline(veg, _topicFromSubtitle(action.subtitle)),
      ),
    GardenHomeActionKind.calendarCountdown => GardenHomeActionVisual(
        severity: GardenActionSeverity.success,
        icon: Icons.event_note,
        label: _headline(veg, _topicFromSubtitle(action.subtitle)),
      ),
  };
}

String _topicFromSubtitle(String subtitle) {
  final lower = subtitle.toLowerCase();
  if (lower.startsWith('over ')) {
    final parts = subtitle.split(': ');
    if (parts.length >= 2) return parts.sublist(1).join(': ');
    return subtitle;
  }
  return subtitle;
}

/// Formaat: “Tomaat · Bladluis”, kort, scannable.
String _headline(String veg, String topic) => '$veg · $topic';

String _headlineForKind(GardenHomeAction action, String veg) {
  return switch (action.kind) {
    GardenHomeActionKind.firstPhoto => _headline(veg, 'Eerste scan'),
    GardenHomeActionKind.weeklyScan => _headline(veg, 'Scan'),
    GardenHomeActionKind.harvest => _headline(veg, _harvestTopic(action.subtitle)),
    GardenHomeActionKind.calendarHarvest =>
      _headline(veg, _calendarHarvestTopic(action.subtitle)),
    GardenHomeActionKind.planPlant => _headline(veg, _plantTopic(action.subtitle)),
    GardenHomeActionKind.aiWarning ||
    GardenHomeActionKind.seasonWarning ||
    GardenHomeActionKind.aiCoach ||
    GardenHomeActionKind.calendarCountdown =>
      _headline(veg, _topicFromSubtitle(action.subtitle)),
  };
}

String _plantTopic(String subtitle) {
  final sub = subtitle.toLowerCase();
  if (sub.contains('zaai')) return 'Zaaien';
  if (sub.contains('voorzaai')) return 'Voorzaaien';
  if (sub.contains('uitplant')) return 'Uitplanten';
  return 'Planten';
}

String _harvestTopic(String subtitle) {
  final sub = subtitle.toLowerCase();
  if (sub.contains('klaar') || sub.contains('oogst')) return 'Oogstbaar';
  if (sub.contains('bloei')) return 'Bloei';
  if (sub.contains('eetbaar')) return 'Eetbaar';
  return 'Oogst';
}

String _calendarHarvestTopic(String subtitle) {
  final match = RegExp(r'(\d{1,2})-(\d{1,2})').firstMatch(subtitle);
  if (match != null) {
    return 'Oogst ${match.group(1)}-${match.group(2)}';
  }
  return 'Oogstperiode';
}

String _topicFromWarning(String warning) {
  final t = warning.toLowerCase();
  if (t.contains('bladluis') || t.contains('luis')) return 'Bladluis';
  if (t.contains('rups')) return 'Rupsen';
  if (t.contains('slak')) return 'Slakken';
  if (t.contains('insect') || t.contains('plaag')) return 'Plaag';
  if (t.contains('schimmel')) return 'Schimmel';
  if (t.contains('ziek') || t.contains('rot') || t.contains('vlek')) {
    return 'Ziekte';
  }
  if (t.contains('water') || t.contains('droog') || t.contains('giet')) {
    return 'Water';
  }
  if (t.contains('tekort') ||
      t.contains('voeding') ||
      t.contains('stikstof') ||
      t.contains('kalium')) {
    return 'Voeding';
  }
  return _firstWords(warning, 2);
}

String _topicFromSeasonWarning(String warning) {
  final t = warning.toLowerCase();
  if (t.contains('te vroeg')) return 'Te vroeg';
  if (t.contains('te laat')) return 'Te laat';
  if (t.contains('vorst')) return 'Vorst';
  if (t.contains('zaai')) return 'Zaai tijd';
  if (t.contains('plant')) return 'Plant tijd';
  if (t.contains('oogst')) return 'Oogst timing';
  return _firstWords(warning, 2);
}

String _firstWords(String text, int count) {
  final words = text.trim().split(RegExp(r'\s+'));
  if (words.isEmpty) return 'Check';
  return words.take(count).join(' ');
}

IconData _harvestIcon(String subtitle) {
  final sub = subtitle.toLowerCase();
  if (sub.contains('bloei')) return Icons.local_florist_rounded;
  if (sub.contains('eetbaar')) return Icons.restaurant;
  return Icons.agriculture_rounded;
}

IconData _iconForWarningText(String warning) {
  final t = warning.toLowerCase();
  if (t.contains('bladluis') ||
      t.contains('insect') ||
      t.contains('luis') ||
      t.contains('plaag') ||
      t.contains('rups') ||
      t.contains('slak')) {
    return Icons.pest_control;
  }
  if (t.contains('water') || t.contains('droog') || t.contains('giet')) {
    return Icons.water_drop_rounded;
  }
  if (t.contains('ziek') ||
      t.contains('schimmel') ||
      t.contains('rot') ||
      t.contains('vlek')) {
    return Icons.coronavirus;
  }
  if (t.contains('voeding') ||
      t.contains('tekort') ||
      t.contains('stikstof') ||
      t.contains('kalium')) {
    return Icons.eco_rounded;
  }
  return Icons.error_rounded;
}
