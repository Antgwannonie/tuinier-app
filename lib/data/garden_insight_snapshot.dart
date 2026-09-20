import '../models/garden_plant_profile.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/vegetable.dart';
import 'garden_health_score.dart';
import 'garden_plant_schedule.dart';
import 'garden_profile_store.dart';
import 'garden_scan_prefs_store.dart';
import 'garden_weather_advice.dart';
import 'insect_scan_store.dart';
import 'my_garden_store.dart';
import 'plant_health_warnings.dart';
import 'plant_scan_history.dart';
import 'vegetable_repository.dart';
import 'weather_service.dart';
import '../widgets/home_moestuin_actions.dart';

enum InsightPriority { high, medium, low }

extension InsightPriorityLabel on InsightPriority {
  String get labelNl {
    switch (this) {
      case InsightPriority.high:
        return 'Hoog';
      case InsightPriority.medium:
        return 'Middel';
      case InsightPriority.low:
        return 'Laag';
    }
  }
}

class InsightProblem {
  const InsightProblem({
    required this.plantName,
    required this.title,
    required this.cause,
    required this.solution,
    required this.priority,
  });

  final String plantName;
  final String title;
  final String cause;
  final String solution;
  final InsightPriority priority;
}

class InsightTodayAction {
  const InsightTodayAction({
    required this.plantName,
    required this.action,
    this.detail,
    this.priority = InsightPriority.medium,
  });

  final String plantName;
  final String action;
  final String? detail;
  final InsightPriority priority;
}

class InsightGrowthItem {
  const InsightGrowthItem({
    required this.plantName,
    required this.status,
    this.detail,
  });

  final String plantName;
  final AiGrowthScheduleStatus status;
  final String? detail;
}

class InsightWaterItem {
  const InsightWaterItem({
    required this.plantName,
    required this.status,
    this.advice,
  });

  final String plantName;
  final AiWaterStatus status;
  final String? advice;
}

class InsightHarvestItem {
  const InsightHarvestItem({
    required this.plantName,
    required this.label,
    this.estimatedDate,
    this.readyNow = false,
  });

  final String plantName;
  final String label;
  final DateTime? estimatedDate;
  final bool readyNow;
}

class InsightNutrientIssue {
  const InsightNutrientIssue({
    required this.plantName,
    required this.label,
    required this.cause,
    required this.solution,
  });

  final String plantName;
  final String label;
  final String cause;
  final String solution;
}

class InsightRecentScan {
  const InsightRecentScan({
    required this.plantName,
    required this.scannedAt,
    required this.healthScore,
    required this.problems,
  });

  final String plantName;
  final DateTime scannedAt;
  final int? healthScore;
  final List<String> problems;
}

class InsightSeasonStats {
  const InsightSeasonStats({
    required this.scanCount,
    required this.plantCount,
    required this.speciesCount,
    required this.problemCount,
    required this.harvestReadyCount,
    required this.plantsWithScans,
  });

  final int scanCount;
  final int plantCount;
  final int speciesCount;
  final int problemCount;
  final int harvestReadyCount;
  final int plantsWithScans;
}

class InsightBiodiversity {
  const InsightBiodiversity({
    required this.score,
    required this.beneficialCount,
    required this.harmfulCount,
    required this.neutralCount,
    required this.recentNames,
    this.openHarmful = const [],
  });

  final int score;
  final int beneficialCount;
  final int harmfulCount;
  final int neutralCount;
  final List<String> recentNames;
  final List<InsightOpenHarmfulPest> openHarmful;
}

class InsightOpenHarmfulPest {
  const InsightOpenHarmfulPest({
    required this.id,
    required this.nameNl,
    required this.summary,
    required this.scannedAt,
  });

  final String id;
  final String nameNl;
  final String summary;
  final DateTime scannedAt;
}

class GardenInsightSnapshot {
  const GardenInsightSnapshot({
    required this.moestuinName,
    required this.health,
    required this.healthStatus,
    required this.waterScore,
    required this.growthScore,
    required this.coachSummary,
    required this.problems,
    required this.todayActions,
    required this.growthItems,
    required this.waterItems,
    required this.harvestWithin7,
    required this.harvestWithin30,
    required this.biodiversity,
    required this.nutrients,
    required this.recentScans,
    required this.seasonStats,
    this.weatherSummary,
    this.weatherTips = const [],
  });

  final String moestuinName;
  final GardenHealthScore health;
  final String healthStatus;
  final int waterScore;
  final int growthScore;
  final String coachSummary;
  final List<InsightProblem> problems;
  final List<InsightTodayAction> todayActions;
  final List<InsightGrowthItem> growthItems;
  final List<InsightWaterItem> waterItems;
  final List<InsightHarvestItem> harvestWithin7;
  final List<InsightHarvestItem> harvestWithin30;
  final InsightBiodiversity biodiversity;
  final List<InsightNutrientIssue> nutrients;
  final List<InsightRecentScan> recentScans;
  final InsightSeasonStats seasonStats;
  final String? weatherSummary;
  final List<GardenWeatherTip> weatherTips;
}

String healthStatusLabel(int total, {required int plantCount}) {
  if (plantCount == 0) return 'Nog leeg';
  if (total >= 90) return 'Uitstekend';
  if (total >= 75) return 'Goed';
  if (total >= 55) return 'Matig';
  return 'Slecht';
}

InsightPriority _priorityFromAi(AiPriority? p, AiRiskLevel? risk) {
  if (p == AiPriority.urgent || p == AiPriority.high) {
    return InsightPriority.high;
  }
  if (risk == AiRiskLevel.high) return InsightPriority.high;
  if (p == AiPriority.medium) return InsightPriority.medium;
  return InsightPriority.low;
}

InsightPriority _priorityFromHighlight(PlantWarningHighlightLevel level) {
  switch (level) {
    case PlantWarningHighlightLevel.danger:
      return InsightPriority.high;
    case PlantWarningHighlightLevel.warning:
      return InsightPriority.medium;
    case PlantWarningHighlightLevel.neutral:
    case PlantWarningHighlightLevel.none:
      return InsightPriority.low;
  }
}

int _computeWaterScore(Iterable<GardenPlantProfile?> profiles) {
  var withWater = 0;
  var ok = 0;
  for (final p in profiles) {
    final ws = p?.lastAnalysis?.insight?.waterStatus;
    if (ws == null) continue;
    withWater++;
    if (ws == AiWaterStatus.ok) ok++;
  }
  if (withWater == 0) return 78;
  return ((ok / withWater) * 100).round().clamp(40, 100);
}

int _computeGrowthScore(Iterable<GardenPlantProfile?> profiles) {
  var total = 0;
  var count = 0;
  for (final p in profiles) {
    final g = p?.lastAnalysis?.insight?.growthScore;
    if (g == null) continue;
    total += g;
    count++;
  }
  if (count == 0) return 75;
  return (total / count).round().clamp(40, 100);
}

DateTime? _estimatedHarvestDate(GardenPlantProfile profile) {
  if (profile.predictedHarvestAt != null) {
    return profile.predictedHarvestAt;
  }
  final days = profile.lastAnalysis?.daysUntilHarvest;
  if (days == null) return null;
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day).add(Duration(days: days));
}

String _formatHarvestLabel(DateTime? date, {required bool readyNow}) {
  if (readyNow) return 'Nu oogstbaar';
  if (date == null) return 'Datum onbekend';
  final diff = date.difference(DateTime.now()).inDays;
  if (diff <= 0) return 'Nu oogstbaar';
  if (diff == 1) return 'Morgen';
  return 'Over $diff dagen';
}

List<InsightProblem> _collectProblems({
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
}) {
  final out = <InsightProblem>[];
  final seen = <String>{};

  void add({
    required String plantName,
    required String title,
    required String cause,
    required String solution,
    required InsightPriority priority,
  }) {
    final key = '$plantName::$title';
    if (seen.contains(key)) return;
    seen.add(key);
    out.add(
      InsightProblem(
        plantName: plantName,
        title: title,
        cause: cause,
        solution: solution,
        priority: priority,
      ),
    );
  }

  for (final id in gardenStore.ids) {
    final profile = profileStore.profileFor(id);
    final veg = repository.byId(id);
    if (profile == null || veg == null) continue;
    final name = veg.nameNl;
    final insight = profile.lastAnalysis?.insight;

    if (insight != null) {
      final priority = _priorityFromAi(insight.priority, insight.riskLevel);
      for (final pest in insight.confirmedPests) {
        add(
          plantName: name,
          title: '${pest.labelNl} gevonden',
          cause: pest.symptoms ?? 'Zichtbaar op de laatste scan.',
          solution: pest.action ?? 'Controleer en behandel gericht.',
          priority: priority,
        );
      }
      for (final disease in insight.confirmedDiseases) {
        add(
          plantName: name,
          title: disease.labelNl,
          cause: disease.symptoms ?? 'AI signaleerde dit op de foto.',
          solution: disease.action ?? 'Verwijder aangetaste delen en ventileer.',
          priority: priority,
        );
      }
      if (insight.weedsDetected == true) {
        add(
          plantName: name,
          title: 'Onkruid rondom plant',
          cause: insight.weedsNote ?? 'Onkruid concurreert om water en voeding.',
          solution: 'Wied rondom de plant en mulch de bodem.',
          priority: InsightPriority.medium,
        );
      }
      if (insight.growthScheduleStatus == AiGrowthScheduleStatus.behind) {
        final weeks = insight.growthScheduleWeeksDelta;
        final cause = weeks != null && weeks > 0
            ? 'Geschat $weeks week${weeks == 1 ? '' : 'en'} achter op schema.'
            : (insight.growthScheduleNote ??
                'Plant groeit langzamer dan verwacht.');
        add(
          plantName: name,
          title: 'Groei loopt achter',
          cause: cause,
          solution: 'Controleer water, voeding en standplaats.',
          priority: InsightPriority.medium,
        );
      }
    }

    for (final warning in activeSeasonWarningsFor(
      profile: profile,
      vegetable: veg,
    )) {
      add(
        plantName: name,
        title: warning,
        cause: 'Seizoens-timing of plantdatum wijkt af.',
        solution: 'Pas planning of standplaats aan.',
        priority: InsightPriority.medium,
      );
    }

    for (final warning in activeAiWarningsFor(profile)) {
      add(
        plantName: name,
        title: warning,
        cause: 'Gesignaleerd door AI-scan.',
        solution: 'Open plantdetails voor advies.',
        priority: _priorityFromHighlight(
          plantWarningHighlightLevel(profile: profile, vegetable: veg),
        ),
      );
    }
  }

  int rank(InsightPriority p) => switch (p) {
        InsightPriority.high => 0,
        InsightPriority.medium => 1,
        InsightPriority.low => 2,
      };
  out.sort((a, b) => rank(a.priority).compareTo(rank(b.priority)));
  return out;
}

List<InsightTodayAction> _collectTodayActions({
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required GardenScanPrefsStore scanPrefs,
}) {
  final out = <InsightTodayAction>[];
  final month = DateTime.now().month;

  final homeActions = collectGardenHomeActions(
    repository: repository,
    gardenStore: gardenStore,
    profileStore: profileStore,
    scanPrefs: scanPrefs,
    month: month,
  );

  for (final action in homeActions) {
    final label = switch (action.kind) {
      GardenHomeActionKind.planPlant => 'Planten',
      GardenHomeActionKind.firstPhoto => 'Eerste scan',
      GardenHomeActionKind.weeklyScan => 'Weekscan',
      GardenHomeActionKind.harvest => 'Oogsten',
      GardenHomeActionKind.calendarHarvest => 'Oogsten',
      GardenHomeActionKind.aiWarning => 'Waarschuwing',
      GardenHomeActionKind.seasonWarning => 'Seizoen',
      GardenHomeActionKind.aiCoach => 'AI-advies',
      GardenHomeActionKind.calendarCountdown => 'Kalender',
    };
    final priority = action.kind == GardenHomeActionKind.harvest ||
            action.kind == GardenHomeActionKind.firstPhoto ||
            action.kind == GardenHomeActionKind.aiWarning
        ? InsightPriority.high
        : InsightPriority.medium;
    out.add(
      InsightTodayAction(
        plantName: action.vegetable.nameNl,
        action: label,
        detail: action.subtitle,
        priority: priority,
      ),
    );
  }

  for (final id in gardenStore.ids) {
    final profile = profileStore.profileFor(id);
    final veg = repository.byId(id);
    if (profile == null || veg == null) continue;
    final insight = profile.lastAnalysis?.insight;
    if (insight == null) continue;
    for (final rec in insight.recommendedActions.take(2)) {
      out.add(
        InsightTodayAction(
          plantName: veg.nameNl,
          action: rec.title,
          detail: rec.description,
          priority: _priorityFromAi(rec.priority, null),
        ),
      );
    }
  }

  return out.take(12).toList();
}

String _buildCoachSummary({
  required GardenHealthScore health,
  required String healthStatus,
  required List<InsightProblem> problems,
  required List<InsightTodayAction> actions,
  required List<InsightWaterItem> waterItems,
  required List<GardenWeatherTip> weatherTips,
  required int plantCount,
}) {
  if (plantCount == 0) {
    return 'Je moestuin is nog leeg. Voeg planten toe en maak je eerste scan '
        'om dit dashboard te vullen met AI-advies.';
  }

  final parts = <String>[];
  if (health.total >= 85) {
    parts.add('Je tuin staat er goed voor.');
  } else if (health.total >= 65) {
    parts.add('Je tuin doet het redelijk, met een paar aandachtspunten.');
  } else {
    parts.add('Je tuin heeft deze week extra aandacht nodig.');
  }

  final highProblems = problems.where((p) => p.priority == InsightPriority.high);
  if (highProblems.isNotEmpty) {
    final first = highProblems.first;
    parts.add(
      'Let op ${first.plantName.toLowerCase()}: ${first.title.toLowerCase()}.',
    );
  } else if (problems.isNotEmpty) {
    parts.add(
      'Houd ${problems.first.plantName.toLowerCase()} in de gaten '
      '(${problems.first.title.toLowerCase()}).',
    );
  } else {
    parts.add('De meeste planten groeien volgens verwachting.');
  }

  final dry = waterItems.where((w) => w.status == AiWaterStatus.tooDry);
  if (dry.isNotEmpty) {
    parts.add(
      'Geef ${dry.first.plantName.toLowerCase()} extra water door droogte.',
    );
  }

  final urgentWeather = weatherTips
      .where((t) => t.level == GardenWeatherLevel.alert)
      .toList();
  if (urgentWeather.isNotEmpty) {
    parts.add('Weer: ${urgentWeather.first.title.toLowerCase()}.');
  }

  if (actions.isNotEmpty && parts.length < 3) {
    parts.add(
      'Vandaag: ${actions.first.action.toLowerCase()} bij '
      '${actions.first.plantName.toLowerCase()}.',
    );
  }

  return parts.join(' ');
}

GardenInsightSnapshot buildGardenInsightSnapshot({
  required MyGardenStore gardenStore,
  required GardenProfileStore profileStore,
  required VegetableRepository repository,
  required InsectScanStore insectStore,
  required GardenScanPrefsStore scanPrefs,
  WeatherForecast? forecast,
}) {
  final spaceId = gardenStore.activeSpace?.id ?? '';
  final moestuinName = gardenStore.activeSpace?.name ?? 'Mijn moestuin';
  final health = computeGardenHealthScore(
    gardenStore: gardenStore,
    profileStore: profileStore,
    repository: repository,
    insectStore: insectStore,
  );

  final profiles = <GardenPlantProfile>[];
  for (final id in gardenStore.ids) {
    final p = profileStore.profileFor(id);
    if (p != null) profiles.add(p);
  }

  final waterScore = _computeWaterScore(profiles);
  final growthScore = _computeGrowthScore(profiles);
  final status = healthStatusLabel(health.total, plantCount: health.plantCount);

  final problems = _collectProblems(
    gardenStore: gardenStore,
    profileStore: profileStore,
    repository: repository,
  );

  final todayActions = _collectTodayActions(
    gardenStore: gardenStore,
    profileStore: profileStore,
    repository: repository,
    scanPrefs: scanPrefs,
  );

  final growthItems = <InsightGrowthItem>[];
  final waterItems = <InsightWaterItem>[];
  final nutrients = <InsightNutrientIssue>[];
  final harvest7 = <InsightHarvestItem>[];
  final harvest30 = <InsightHarvestItem>[];
  var scanCount = 0;
  var plantsWithScans = 0;
  var harvestReady = 0;
  final recentScans = <InsightRecentScan>[];

  for (final id in gardenStore.ids) {
    final profile = profileStore.profileFor(id);
    final veg = repository.byId(id);
    if (profile == null || veg == null) continue;
    final name = veg.nameNl;
    final insight = profile.lastAnalysis?.insight;
    final analysis = profile.lastAnalysis;

    scanCount += profile.scanHistory.length;
    if (analysis != null) plantsWithScans++;

    if (isReadyToHarvest(profile, vegetable: veg)) harvestReady++;

    if (insight?.growthScheduleStatus != null &&
        insight!.growthScheduleStatus != AiGrowthScheduleStatus.unknown) {
      String? detail = insight.growthScheduleNote;
      final weeks = insight.growthScheduleWeeksDelta;
      if (weeks != null && weeks > 0) {
        detail = switch (insight.growthScheduleStatus) {
          AiGrowthScheduleStatus.behind => '$weeks week${weeks == 1 ? '' : 'en'} achter',
          AiGrowthScheduleStatus.ahead => '$weeks week${weeks == 1 ? '' : 'en'} voor',
          _ => detail,
        };
      }
      growthItems.add(
        InsightGrowthItem(
          plantName: name,
          status: insight.growthScheduleStatus!,
          detail: detail,
        ),
      );
    }

    final ws = insight?.waterStatus;
    if (ws != null && ws != AiWaterStatus.ok) {
      waterItems.add(
        InsightWaterItem(
          plantName: name,
          status: ws,
          advice: insight?.waterAdvice,
        ),
      );
    }

    for (final n in insight?.confirmedNutrients ?? const []) {
      nutrients.add(
        InsightNutrientIssue(
          plantName: name,
          label: n.labelNl,
          cause: n.symptoms ?? 'Teken op blad of groei zichtbaar.',
          solution: n.explanation ?? 'Pas bemesting aan op dit tekort.',
        ),
      );
    }

    final est = _estimatedHarvestDate(profile);
    final ready = isReadyToHarvest(profile, vegetable: veg);
    if (ready || est != null) {
      final days = est?.difference(DateTime.now()).inDays;
      final item = InsightHarvestItem(
        plantName: name,
        label: _formatHarvestLabel(est, readyNow: ready),
        estimatedDate: est,
        readyNow: ready,
      );
      if (ready || (days != null && days <= 7)) {
        harvest7.add(item);
      } else if (days != null && days <= 30) {
        harvest30.add(item);
      }
    }

    for (final entry in plantScanEntries(profile)) {
      final scanInsight = entry.analysis.insight;
      recentScans.add(
        InsightRecentScan(
          plantName: name,
          scannedAt: entry.analysis.scannedAt,
          healthScore: scanInsight?.healthScore,
          problems: scanInsight != null
              ? [
                  ...scanInsight.confirmedPests.map((p) => p.labelNl),
                  ...scanInsight.confirmedDiseases.map((d) => d.labelNl),
                  ...scanInsight.problems,
                ]
              : entry.analysis.warnings,
        ),
      );
    }
  }

  recentScans.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));

  final insects = insectStore.activeEntriesForSpace(spaceId);
  final harmfulInsects =
      insects.where((e) => e.benefit == InsectBenefit.harmful).toList();
  final biodiversity = InsightBiodiversity(
    score: health.biodiversity,
    beneficialCount:
        insects.where((e) => e.benefit == InsectBenefit.beneficial).length,
    harmfulCount: harmfulInsects.length,
    neutralCount:
        insects.where((e) => e.benefit == InsectBenefit.neutral).length,
    recentNames: insects.take(8).map((e) => e.nameNl).toList(),
    openHarmful: harmfulInsects
        .map(
          (e) => InsightOpenHarmfulPest(
            id: e.id,
            nameNl: e.nameNl,
            summary: e.summary,
            scannedAt: e.scannedAt,
          ),
        )
        .toList(),
  );

  final weatherTips =
      forecast != null ? gardenTipsFromForecast(forecast) : const <GardenWeatherTip>[];

  return GardenInsightSnapshot(
    moestuinName: moestuinName,
    health: health,
    healthStatus: status,
    waterScore: waterScore,
    growthScore: growthScore,
    coachSummary: _buildCoachSummary(
      health: health,
      healthStatus: status,
      problems: problems,
      actions: todayActions,
      waterItems: waterItems,
      weatherTips: weatherTips,
      plantCount: health.plantCount,
    ),
    problems: problems,
    todayActions: todayActions,
    growthItems: growthItems,
    waterItems: waterItems,
    harvestWithin7: harvest7,
    harvestWithin30: harvest30,
    biodiversity: biodiversity,
    nutrients: nutrients,
    recentScans: recentScans.take(8).toList(),
    seasonStats: InsightSeasonStats(
      scanCount: scanCount,
      plantCount: health.plantCount,
      speciesCount: gardenStore.ids.length,
      problemCount: health.warningCount,
      harvestReadyCount: harvestReady,
      plantsWithScans: plantsWithScans,
    ),
    weatherSummary: forecast != null ? weatherSummaryNl(forecast) : null,
    weatherTips: weatherTips,
  );
}
