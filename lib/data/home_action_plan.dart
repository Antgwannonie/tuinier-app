import 'package:flutter/material.dart';

import '../models/add_plant_wizard_models.dart';
import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../widgets/home_moestuin_actions.dart';
import 'plant_pending_planting.dart';
import 'plant_scheduled_actions.dart';

/// Eén stap in het stappenplan bij een home-actie.
class HomeActionStep {
  const HomeActionStep({
    required this.title,
    this.detail,
    this.icon,
  });

  final String title;
  final String? detail;
  final IconData? icon;
}

/// Korte samenvatting + stappen voor één specifieke actie.
class HomeActionPlan {
  const HomeActionPlan({
    required this.headline,
    required this.summary,
    required this.steps,
  });

  final String headline;
  final String summary;
  final List<HomeActionStep> steps;
}

HomeActionPlan buildHomeActionPlan({
  required GardenHomeAction action,
  required GardenPlantProfile? profile,
}) {
  final veg = action.vegetable.nameNl;
  final scheduled = action.scheduled;
  final analysis = profile?.lastAnalysis;
  final insight = analysis?.insight;
  final focus = _actionFocusText(action);

  final headline = _headlineFor(action, veg, profile);
  final summary = _summaryFor(action, analysis, insight, focus);
  final steps = _stepsFor(action, profile, analysis, insight, focus);

  return HomeActionPlan(
    headline: headline,
    summary: summary,
    steps: steps.isNotEmpty
        ? steps
        : [HomeActionStep(title: focus, detail: summary)],
  );
}

String _actionFocusText(GardenHomeAction action) {
  final scheduled = action.scheduled;
  if (scheduled?.detailBody != null && scheduled!.detailBody!.trim().isNotEmpty) {
    return scheduled.detailBody!.trim();
  }
  if (scheduled != null) {
    return scheduled.activeLabel.trim();
  }
  return action.subtitle.trim();
}

String _headlineFor(
  GardenHomeAction action,
  String veg,
  GardenPlantProfile? profile,
) {
  final topic = action.scheduled?.topic ?? action.subtitle;
  return switch (action.kind) {
    GardenHomeActionKind.harvest => '$veg · Oogsten',
    GardenHomeActionKind.firstPhoto => '$veg · Eerste scan',
    GardenHomeActionKind.weeklyScan => '$veg · Scan',
    GardenHomeActionKind.aiWarning => '$veg · $topic',
    GardenHomeActionKind.seasonWarning => '$veg · $topic',
    GardenHomeActionKind.aiCoach => '$veg · $topic',
    GardenHomeActionKind.planPlant => () {
        final topic = action.scheduled?.topic;
        if (topic != null && topic.isNotEmpty) return '$veg · $topic';
        if (profile != null) {
          return '$veg · ${pendingPlantingTaskLabel(vegetable: action.vegetable, profile: profile)}';
        }
        return '$veg · Planten';
      }(),
    GardenHomeActionKind.calendarHarvest => '$veg · Oogstperiode',
    GardenHomeActionKind.calendarCountdown => '$veg · $topic',
  };
}

String _summaryFor(
  GardenHomeAction action,
  PlantAiAnalysis? analysis,
  PlantAiInsightReport? insight,
  String focus,
) {
  if (action.kind == GardenHomeActionKind.harvest) {
    final parts = <String>[
      if (insight?.ripenessNote != null) insight!.ripenessNote!,
      if (analysis?.harvestWindowLabel.isNotEmpty == true)
        'Venster: ${analysis!.harvestWindowLabel}',
    ];
    if (parts.isNotEmpty) return parts.join('\n\n');
    return focus;
  }

  if (action.kind == GardenHomeActionKind.aiWarning ||
      action.kind == GardenHomeActionKind.seasonWarning) {
    return focus;
  }

  if (action.kind == GardenHomeActionKind.aiCoach) {
    return focus;
  }

  if (action.kind == GardenHomeActionKind.firstPhoto ||
      action.kind == GardenHomeActionKind.weeklyScan) {
    return 'Maak een nieuwe foto zodat de AI de actuele stand van je plant '
        'kan beoordelen.';
  }

  return focus;
}

List<HomeActionStep> _stepsFor(
  GardenHomeAction action,
  GardenPlantProfile? profile,
  PlantAiAnalysis? analysis,
  PlantAiInsightReport? insight,
  String focus,
) {
  return switch (action.kind) {
    GardenHomeActionKind.harvest =>
      _harvestStepsForAction(insight, analysis, focus),
    GardenHomeActionKind.aiWarning =>
      _singleWarningSteps(insight, focus),
    GardenHomeActionKind.seasonWarning =>
      _seasonWarningSteps(focus),
    GardenHomeActionKind.firstPhoto ||
    GardenHomeActionKind.weeklyScan =>
      _scanSteps(analysis),
    GardenHomeActionKind.aiCoach =>
      _coachSteps(insight, action.scheduled, focus),
    GardenHomeActionKind.planPlant =>
      _plantingTaskSteps(action, profile),
    GardenHomeActionKind.calendarHarvest ||
    GardenHomeActionKind.calendarCountdown =>
      _calendarSteps(focus),
  };
}

List<HomeActionStep> _harvestStepsForAction(
  PlantAiInsightReport? insight,
  PlantAiAnalysis? analysis,
  String focus,
) {
  final steps = <HomeActionStep>[];
  final focusLower = focus.toLowerCase();

  if (analysis?.undergroundHarvestNote != null &&
      analysis!.undergroundHarvestNote!.trim().isNotEmpty) {
    steps.add(
      HomeActionStep(
        title: 'Oogstadvies',
        detail: analysis.undergroundHarvestNote,
      ),
    );
  }

  if (insight?.ripenessNote != null &&
      insight!.ripenessNote!.trim().isNotEmpty) {
    steps.add(
      HomeActionStep(title: 'Rijpheid', detail: insight.ripenessNote),
    );
  }

  final matchedCoach = _matchingCoachTask(insight, focusLower, harvestOnly: true);
  if (matchedCoach != null) {
    steps.add(
      HomeActionStep(title: matchedCoach.title, detail: matchedCoach.body),
    );
  }

  final matchedRec = _matchingRecommended(insight, focusLower, harvestOnly: true);
  if (matchedRec != null) {
    steps.add(
      HomeActionStep(
        title: matchedRec.title,
        detail: matchedRec.description,
      ),
    );
  }

  if (steps.isEmpty) {
    steps.add(
      HomeActionStep(
        title: 'Oogst deze plant',
        detail: focus,
      ),
    );
  }

  steps.add(
    const HomeActionStep(
      title: 'Oogst voorzichtig',
      detail: 'Verwijder alleen rijpe vruchten. Laat de plant staan als er '
          'later nog meer oogst mogelijk is.',
      icon: Icons.pan_tool,
    ),
  );

  if (insight?.moreHarvestExpectedThisSeason == true) {
    final tips = insight!.harvestAlternativeTips;
    steps.add(
      HomeActionStep(
        title: 'Meer oogst mogelijk',
        detail: tips.isNotEmpty
            ? 'Deze plant kan dit seizoen nog meer produceren:\n${tips.map((t) => '• $t').join('\n')}'
            : 'Deze plant kan dit seizoen nog meer produceren. '
                'Blijf scannen voor nieuwe oogstmomenten.',
        icon: Icons.refresh_rounded,
      ),
    );
  }

  return steps;
}

List<HomeActionStep> _singleWarningSteps(
  PlantAiInsightReport? insight,
  String focus,
) {
  final steps = <HomeActionStep>[];
  final lower = focus.toLowerCase();

  for (final pest in insight?.confirmedPests ?? const []) {
    if (!_textMatchesIssue(lower, pest.labelNl, 'plaag')) continue;
    steps.add(
      HomeActionStep(
        title: 'Herken ${pest.labelNl}',
        detail: pest.symptoms ?? focus,
      ),
    );
    if (pest.action != null && pest.action!.trim().isNotEmpty) {
      steps.add(
        HomeActionStep(title: 'Aanpak', detail: pest.action),
      );
    }
    return steps;
  }

  for (final disease in insight?.confirmedDiseases ?? const []) {
    if (!_textMatchesIssue(lower, disease.labelNl, 'ziekte')) continue;
    steps.add(
      HomeActionStep(
        title: 'Herken ${disease.labelNl}',
        detail: disease.symptoms ?? focus,
      ),
    );
    if (disease.action != null && disease.action!.trim().isNotEmpty) {
      steps.add(
        HomeActionStep(title: 'Aanpak', detail: disease.action),
      );
    }
    return steps;
  }

  for (final nutrient in insight?.confirmedNutrients ?? const []) {
    if (!lower.contains(nutrient.labelNl.toLowerCase()) &&
        !lower.contains('voeding')) {
      continue;
    }
    steps.add(
      HomeActionStep(
        title: nutrient.labelNl,
        detail: nutrient.explanation ?? nutrient.symptoms ?? focus,
      ),
    );
    return steps;
  }

  if (lower.contains('water') && insight?.waterAdvice != null) {
    return [
      HomeActionStep(
        title: insight!.waterStatus?.labelNl ?? 'Water',
        detail: [
          if (insight.waterSymptoms != null) insight.waterSymptoms!,
          insight.waterAdvice!,
        ].join('\n\n'),
      ),
    ];
  }

  if (lower.contains('onkruid')) {
    return [
      HomeActionStep(
        title: 'Onkruid verwijderen',
        detail: insight?.weedsNote ?? focus,
      ),
    ];
  }

  for (final problem in insight?.problems ?? const []) {
    if (!_textMatchesProblem(lower, problem)) continue;
    final rec = _matchingRecommended(insight, problem.toLowerCase());
    return [
      HomeActionStep(title: problem, detail: rec?.description),
      if (rec != null)
        HomeActionStep(title: 'Aanpak', detail: rec.description),
    ];
  }

  return [HomeActionStep(title: 'Taak', detail: focus)];
}

List<HomeActionStep> _seasonWarningSteps(String focus) {
  final lower = focus.toLowerCase();
  if (lower.contains('seizoen') && lower.contains('voorbij')) {
    return [
      HomeActionStep(
        title: 'Situatie',
        detail: focus,
        icon: Icons.analytics,
      ),
      const HomeActionStep(
        title: 'Blijf scannen',
        detail: 'Ook na het officiële seizoen kan oogst nog mogelijk zijn. '
            'De AI bepaalt wanneer je moet stoppen.',
        icon: Icons.photo_camera_rounded,
      ),
      const HomeActionStep(
        title: 'Let op vorst en nachtvorst',
        detail: 'Bescherm de plant bij kou als je nog wilt oogsten.',
        icon: Icons.ac_unit,
      ),
    ];
  }

  if (lower.contains('te laat')) {
    return [
      HomeActionStep(
        title: 'Situatie',
        detail: focus,
        icon: Icons.analytics,
      ),
      const HomeActionStep(
        title: 'Beoordeel realistisch',
        detail: 'Kijk of de plant nog genoeg groeitijd heeft dit seizoen.',
        icon: Icons.access_time_rounded,
      ),
    ];
  }

  return [
    HomeActionStep(
      title: 'Advies',
      detail: focus,
      icon: Icons.lightbulb_rounded,
    ),
    const HomeActionStep(
      title: 'Pas je planning aan',
      detail: 'Werk zaai-, plant- of oogstmoment bij op basis van dit advies.',
      icon: Icons.event_note,
    ),
  ];
}

List<HomeActionStep> _scanSteps(PlantAiAnalysis? analysis) {
  return [
    const HomeActionStep(
      title: 'Kies goed licht',
      detail: 'Fotografeer bij daglicht, niet tegen fel zonlicht in.',
      icon: Icons.wb_sunny_rounded,
    ),
    const HomeActionStep(
      title: 'Hele plant in beeld',
      detail: 'Zorg dat blad, stengel en eventuele vruchten zichtbaar zijn.',
      icon: Icons.center_focus_strong,
    ),
    if (analysis?.advice.isNotEmpty == true)
      HomeActionStep(
        title: 'Specifiek voor nu',
        detail: analysis!.advice,
        icon: Icons.lightbulb_rounded,
      ),
    const HomeActionStep(
      title: 'Upload de scan',
      detail: 'Na de scan worden alleen actuele taken getoond.',
      icon: Icons.photo_camera_rounded,
    ),
  ];
}

List<HomeActionStep> _coachSteps(
  PlantAiInsightReport? insight,
  PlantScheduledAction? scheduled,
  String focus,
) {
  final topic = scheduled?.topic ?? focus;
  final coach = _matchingCoachTask(insight, topic.toLowerCase());
  if (coach != null) {
    return _coachTaskToSteps(coach);
  }

  final rec = _matchingRecommended(insight, topic.toLowerCase());
  if (rec != null) {
    return [
      HomeActionStep(title: rec.title, detail: rec.description ?? focus),
    ];
  }

  return [HomeActionStep(title: topic, detail: focus)];
}

List<HomeActionStep> _plantingTaskSteps(
  GardenHomeAction action,
  GardenPlantProfile? profile,
) {
  if (profile == null) {
    return _plantSteps(action.subtitle);
  }
  final firstSteps = buildPlantingGuidanceSteps(
    vegetable: action.vegetable,
    profile: profile,
  );
  final steps = <HomeActionStep>[
    for (var i = 0; i < firstSteps.steps.length; i++)
      HomeActionStep(
        title: 'Stap ${i + 1}',
        detail: firstSteps.steps[i],
        icon: i == 0 ? Icons.yard_rounded : Icons.check_circle_outline,
      ),
  ];
  if (firstSteps.offSeason != null) {
    steps.add(
      HomeActionStep(
        title: 'Buiten het seizoen',
        detail: firstSteps.offSeason!.body,
        icon: Icons.info_outline,
      ),
    );
    for (final tip in firstSteps.offSeason!.extraTips) {
      steps.add(
        HomeActionStep(
          title: 'Tip',
          detail: tip,
          icon: Icons.lightbulb_outline,
        ),
      );
    }
  }
  return steps;
}

List<HomeActionStep> _plantSteps(String focus) {
  return [
    HomeActionStep(
      title: 'Nu planten',
      detail: focus,
      icon: Icons.yard_rounded,
    ),
    const HomeActionStep(
      title: 'Markeer als geplant',
      detail: 'Geef aan wanneer en waar je geplant hebt voor betere scans.',
      icon: Icons.flag_rounded,
    ),
    const HomeActionStep(
      title: 'Eerste scan',
      detail: 'Maak binnen een paar dagen je eerste foto van de plek of plant.',
      icon: Icons.photo_camera_rounded,
    ),
  ];
}

List<HomeActionStep> _calendarSteps(String focus) {
  return [
    HomeActionStep(
      title: 'Kalendertaak',
      detail: focus,
      icon: Icons.event_available_rounded,
    ),
    const HomeActionStep(
      title: 'Controleer je tuin',
      detail: 'Kijk of deze plant klaar is voor de geplande handeling.',
      icon: Icons.remove_red_eye,
    ),
  ];
}

AiCoachTaskSuggestion? _matchingCoachTask(
  PlantAiInsightReport? insight,
  String needle, {
  bool harvestOnly = false,
}) {
  AiCoachTaskSuggestion? best;
  for (final task in insight?.coachTasks ?? const []) {
    final title = task.title.toLowerCase();
    if (harvestOnly &&
        task.kind != 'harvest' &&
        !_isHarvestText(title)) {
      continue;
    }
    if (title == needle || title.contains(needle) || needle.contains(title)) {
      best = task;
      if (title == needle) return task;
    }
  }
  return best;
}

AiRecommendedAction? _matchingRecommended(
  PlantAiInsightReport? insight,
  String needle, {
  bool harvestOnly = false,
}) {
  for (final rec in insight?.recommendedActions ?? const []) {
    final title = rec.title.toLowerCase();
    if (harvestOnly && !_isHarvestText(title)) continue;
    if (title == needle || title.contains(needle) || needle.contains(title)) {
      return rec;
    }
  }
  return null;
}

List<HomeActionStep> _coachTaskToSteps(AiCoachTaskSuggestion coach) {
  final body = coach.body?.trim();
  if (body == null || body.isEmpty) {
    return [HomeActionStep(title: coach.title)];
  }

  final lines = body
      .split(RegExp(r'[\n\r]+|(?<=\.) '))
      .map((s) => s.trim())
      .where((s) => s.isNotEmpty)
      .toList();

  if (lines.length <= 1) {
    return [HomeActionStep(title: coach.title, detail: body)];
  }

  return [
    for (final line in lines) HomeActionStep(title: line),
  ];
}

bool _textMatchesIssue(String focusLower, String label, String category) {
  final labelLower = label.toLowerCase();
  return focusLower.contains(labelLower) ||
      focusLower.contains(category) && focusLower.contains(labelLower.split(' ').first);
}

bool _textMatchesProblem(String focusLower, String problem) {
  final p = problem.toLowerCase();
  return focusLower.contains(p) || p.contains(focusLower.split(' ').first);
}

bool _isHarvestText(String text) {
  final t = text.toLowerCase();
  return t.contains('oogst') ||
      t.contains('pluk') ||
      t.contains('rijp') ||
      t.contains('harvest');
}
