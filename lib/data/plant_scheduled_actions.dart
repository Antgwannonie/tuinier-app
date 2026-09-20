import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/plant_ai_insight_report.dart';
import '../models/plant_start_method.dart';
import '../models/vegetable.dart';
import 'crop_harvest_kind.dart';
import 'garden_countdown.dart';
import 'garden_plant_schedule.dart';
import 'garden_scan_prefs_store.dart';
import 'home_plant_display_text.dart';
import 'home_upcoming_items.dart';
import 'plant_age_warnings.dart';
import 'plant_health_warnings.dart';
import 'harvest_self_check.dart';
import 'home_action_completion.dart';
import 'moestuin_task_catalog.dart';
import 'plant_lifecycle.dart';
import 'plant_pending_planting.dart';
import 'plant_season_activation.dart';
import 'plant_start_flow.dart';
import 'planting_calendar.dart';
import 'planting_calendar_fallback.dart';
import 'planting_season_context.dart';
import 'planting_season_status.dart';
import 'scan_assessment_sync.dart';

/// Soort geplande actie voor één plant.
enum PlantScheduledActionKind {
  aiWarning,
  aiLetOp,
  seasonWarning,
  planPlant,
  firstScan,
  weeklyScan,
  harvest,
  aiCoach,
  aiRecommended,
  calendar,
}

/// AI-meldingen en observaties zonder directe taak (leren / opletten).
bool isPlantInfoScheduledActionKind(PlantScheduledActionKind kind) {
  return switch (kind) {
    PlantScheduledActionKind.aiWarning ||
    PlantScheduledActionKind.aiLetOp ||
    PlantScheduledActionKind.seasonWarning =>
      true,
    _ => false,
  };
}

bool isPlantTaskScheduledActionKind(PlantScheduledActionKind kind) {
  return !isPlantInfoScheduledActionKind(kind);
}

String formatTasksAndInfoCount({
  required int taskCount,
  required int infoCount,
}) {
  if (taskCount == 0 && infoCount == 0) return 'Geen items';
  if (taskCount > 0 && infoCount == 0) {
    return '$taskCount ${taskCount == 1 ? 'taak' : 'taken'}';
  }
  if (taskCount == 0 && infoCount > 0) {
    return '$infoCount info';
  }
  return '$taskCount · $infoCount info';
}

/// Eén actie met prioriteit en optionele aftelling.
class PlantScheduledAction {
  const PlantScheduledAction({
    required this.kind,
    required this.topic,
    required this.activeLabel,
    this.daysUntil,
    this.detailBody,
    this.warningNote,
  });

  final PlantScheduledActionKind kind;
  final String topic;
  final String activeLabel;

  /// `null` = direct (waarschuwingen). `0` = vandaag/now.
  final int? daysUntil;

  /// Volledige tekst/context voor dit ene actie-detail (niet afgekapt).
  final String? detailBody;

  /// Korte waarschuwing op de takenlijst (bijv. vroeg buiten planten).
  final String? warningNote;

  bool get isImmediate =>
      kind == PlantScheduledActionKind.aiWarning ||
      kind == PlantScheduledActionKind.seasonWarning;

  bool get isActiveNow =>
      isImmediate || daysUntil == null || daysUntil == 0;

  String get moestuinLabel {
    if (isActiveNow) return activeLabel;
    if (!activeLabel.startsWith('Nu:')) return activeLabel;
    final d = daysUntil!;
    if (d == 1) return 'Over 1 dag: $topic';
    return 'Over $d dagen: $topic';
  }
}

int comparePlantScheduledActions(
  PlantScheduledAction a,
  PlantScheduledAction b,
) {
  final tierA = _actionTier(a);
  final tierB = _actionTier(b);
  if (tierA != tierB) return tierA.compareTo(tierB);

  final daysA = a.daysUntil ?? 0;
  final daysB = b.daysUntil ?? 0;
  if (daysA != daysB) return daysA.compareTo(daysB);

  return a.topic.compareTo(b.topic);
}

PlantScheduledAction _planPlantAction({
  required String topic,
  required String activeLabel,
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  int? daysUntil,
  DateTime? reference,
}) {
  final warning = profile != null
      ? earlyOutdoorPlantingTaskWarning(
          vegetable: vegetable,
          profile: profile,
          reference: reference,
        )
      : null;

  return PlantScheduledAction(
    kind: PlantScheduledActionKind.planPlant,
    topic: topic,
    activeLabel: activeLabel,
    daysUntil: daysUntil,
    detailBody: warning,
    warningNote: warning,
  );
}

/// Of een kaartactie oogst suggereert (ook via seizoenstekst met “oogstperiode”).
bool moestuinScheduledActionImpliesHarvest(PlantScheduledAction action) {
  if (action.kind == PlantScheduledActionKind.harvest) return true;
  final text =
      '${action.topic} ${action.activeLabel} ${action.detailBody ?? ''}';
  return semanticTopicKeyForAction(text) == 'harvest';
}

bool shouldHideMoestuinHarvestAction(
  PlantScheduledAction action, {
  required GardenPlantProfile profile,
  required Vegetable vegetable,
}) {
  return moestuinScheduledActionImpliesHarvest(action) &&
      !canUseAiHarvestAssessment(profile, vegetable: vegetable);
}

int _actionTier(PlantScheduledAction action) {
  if (action.kind == PlantScheduledActionKind.aiWarning) return 0;
  if (action.kind == PlantScheduledActionKind.aiLetOp ||
      action.kind == PlantScheduledActionKind.seasonWarning) {
    return 1;
  }
  if (action.isActiveNow) return 2;
  return 3;
}

/// Alle geplande acties voor één plant, gesorteerd op urgentie.
List<PlantScheduledAction> collectPlantScheduledActions({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();
  final today = DateTime(ref.year, ref.month, ref.day);
  final m = month ?? ref.month;
  final out = <PlantScheduledAction>[];

  // Coaching klaar: geen Home-acties; AI-adviezen alleen in plant/scan-info.
  if (profile != null && !profile.isMoestuinActive) {
    return out;
  }

  if (profile != null) {
    final skipDatePhotoMismatchActions = profileHasDatePhotoMismatch(profile);
    final assessmentKeys = assessmentTopicKeys(profile.lastAnalysis?.insight);
    for (final warning in activeAiWarningsFor(profile)) {
      if (skipDatePhotoMismatchActions &&
          isPlantingDateMismatchWarning(warning)) {
        continue;
      }
      if (assessmentKeys.isNotEmpty) {
        final topic = semanticTopicKeyForAction(warning);
        if (topic != null && assessmentKeys.contains(topic)) continue;
      }
      if (shouldExcludeFromHomeActions(warning, profile: profile)) continue;
      out.add(
        PlantScheduledAction(
          kind: PlantScheduledActionKind.aiWarning,
          topic: _warningTopic(warning),
          activeLabel: _warningActiveLabel(warning),
          detailBody: warning,
        ),
      );
    }
    for (final warning in activeSeasonWarningsFor(
      profile: profile,
      vegetable: vegetable,
    )) {
      if (skipDatePhotoMismatchActions &&
          isPlantingDateMismatchWarning(warning)) {
        continue;
      }
      if (shouldExcludeFromHomeActions(warning, profile: profile)) continue;
      out.add(
        PlantScheduledAction(
          kind: PlantScheduledActionKind.seasonWarning,
          topic: _warningTopic(warning),
          activeLabel: shortTextForHomeCard(warning, maxLen: 48),
          detailBody: warning,
        ),
      );
    }
    if (profile.seasonBeyondCalendar) {
      out.add(
        PlantScheduledAction(
          kind: PlantScheduledActionKind.seasonWarning,
          topic: 'Laat oogst',
          activeLabel: shortTextForHomeCard(
            seasonBeyondCalendarNotice(profile),
            maxLen: 52,
          ),
          detailBody: seasonBeyondCalendarNotice(profile),
        ),
      );
    }
    if (profile.awaitingDeathConfirmation) {
      out.add(
        const PlantScheduledAction(
          kind: PlantScheduledActionKind.aiWarning,
          topic: 'Plantstatus',
          activeLabel: 'Controleer of de plant dood is',
        ),
      );
    }
  }

  final planted = profile?.isPlanted ?? false;

  if (!planted) {
    _addPlantingActions(
      out: out,
      vegetable: vegetable,
      profile: profile,
      month: m,
      reference: ref,
    );
  } else {
    final p = profile!;
    if (profileAwaitingOutdoorPlanting(p)) {
      _addAwaitingOutdoorPlantingActions(
        out: out,
        vegetable: vegetable,
        reference: ref,
      );
    }
    _addScanActions(
      out: out,
      profile: p,
      scanPrefs: scanPrefs,
      today: today,
    );
    _addAiCoachActions(out: out, profile: p);
    _addScanAssessmentLetOpActions(out: out, profile: p);
    _addHarvestActions(
      out: out,
      vegetable: vegetable,
      profile: p,
      reference: ref,
    );
    _addHarvestCountdownActions(
      out: out,
      vegetable: vegetable,
      profile: p,
      reference: ref,
    );
    _addPossibleHarvestHintAction(
      out: out,
      vegetable: vegetable,
      profile: p,
    );
  }

  _filterStaleCoachAndRecommended(out: out, profile: profile);
  _dedupeHarvestActions(out);
  _dedupeSemanticTopicActions(out);

  if (profile != null) {
    out.removeWhere(
      (action) => _isDismissedHomeAction(profile: profile, action: action),
    );
    out.removeWhere(
      (action) => shouldExcludeFromHomeActions(
        '${action.topic} ${action.activeLabel} ${action.detailBody ?? ''}',
        profile: profile,
      ),
    );
    out.removeWhere(
      (action) => shouldHideMoestuinHarvestAction(
        action,
        profile: profile,
        vegetable: vegetable,
      ),
    );
  }

  out.sort(comparePlantScheduledActions);
  return out;
}

PlantScheduledAction? primaryPlantScheduledAction({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  final actions = collectPlantScheduledActions(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    month: month,
    reference: reference,
  );
  if (actions.isEmpty) return null;
  return actions.first;
}

bool _isPlantDeathCheckAction(PlantScheduledAction action) {
  return action.kind == PlantScheduledActionKind.aiWarning &&
      action.topic == 'Plantstatus';
}

List<PlantScheduledAction> moestuinCardActions({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  return [
    for (final action in collectPlantScheduledActions(
      vegetable: vegetable,
      profile: profile,
      scanPrefs: scanPrefs,
      month: month,
      reference: reference,
    ))
      if (!_isPlantDeathCheckAction(action)) action,
  ];
}

/// Korte actie op de moestuin-kaart: binnen voorzaaien / buiten zaaien / buiten planten.
String moestuinPlantingActionLabel({
  required Vegetable vegetable,
  required int month,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();
  final suggested = suggestedPlantStartMethod(
    vegetable: vegetable,
    reference: ref,
  );
  if (suggested != null) return suggested.cardLabel;

  final acts = calendarActivitiesForVegetable(
    vegetable.id,
    vegetable: vegetable,
  )
      .where(
        (a) =>
            a.months.contains(month) &&
            (a.type == GardenTaskType.plantOutdoors ||
                a.type == GardenTaskType.sowOutdoors ||
                a.type == GardenTaskType.preSow),
      )
      .toList()
    ..sort((a, b) => a.type.sortOrder.compareTo(b.type.sortOrder));
  if (acts.isEmpty) return PlantStartMethod.plantOutdoors.cardLabel;
  return moestuinPlantingMethodLabel(acts.first.type);
}

String _plantingVerbShort(GardenTaskType type) =>
    moestuinPlantingMethodLabel(type);

/// Aftelling tot voorzaai-/buiten-zaai-seizoen voor nog niet gezaaide planten.
String moestuinUnplantedSeasonCountdownLabel({
  required Vegetable vegetable,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();
  final defaultTopic = moestuinInitialPlantingActionLabel(vegetable: vegetable);
  final sowSeason = plantingSeasonStatusForSowStart(
    vegetable.id,
    reference: ref,
    vegetable: vegetable,
  );

  String format(int days, String topic) {
    if (days == 1) return 'Over 1 dag: $topic';
    return 'Over $days dagen: $topic';
  }

  if (sowSeason.phase == PlantingSeasonPhase.activeNow ||
      sowSeason.phase == PlantingSeasonPhase.daysLeft) {
    return moestuinUnplantedSowActiveActionLabel(
      vegetable: vegetable,
      reference: ref,
    );
  }

  final days = sowSeason.phase == PlantingSeasonPhase.startsSoon
      ? sowSeason.days
      : daysUntilNextInitialPlantSeason(
          vegetable.id,
          reference: ref,
          vegetable: vegetable,
        );

  if (days != null && days > 0) {
    final topic = sowSeason.taskType != null
        ? moestuinPlantingMethodLabel(sowSeason.taskType!)
        : defaultTopic;
    return format(days, topic);
  }

  if (days == 0) {
    return 'Nu: $defaultTopic';
  }

  final fallbackDays = daysUntilNextInitialPlantSeason(
    vegetable.id,
    reference: ref,
    vegetable: vegetable,
  );
  if (fallbackDays != null && fallbackDays > 0) {
    return format(fallbackDays, defaultTopic);
  }

  return 'Volgend zaai-seizoen: $defaultTopic';
}

/// Actie op kaart wanneer zaai-/voorzaai-seizoen open is (stap 1).
String moestuinUnplantedSowActiveActionLabel({
  required Vegetable vegetable,
  DateTime? reference,
  GardenPlantProfile? profile,
}) {
  final ref = reference ?? DateTime.now();
  final status = plantingSeasonStatusForGrowApproach(
    vegetable: vegetable,
    growApproach: profile != null ? resolvePlantGrowApproach(profile) : null,
    plantStartMethod: profile?.plantStartMethod,
    reference: ref,
  );
  final topic = status.taskType != null
      ? moestuinPlantingMethodLabel(status.taskType!)
      : profile != null
          ? pendingPlantingTaskLabel(vegetable: vegetable, profile: profile)
          : moestuinInitialPlantingActionLabel(vegetable: vegetable);
  return _plantingSeasonMoestuinLabel(status: status, topic: topic);
}

String _plantingSeasonKindLabel(GardenTaskType? taskType) {
  return taskType == GardenTaskType.plantOutdoors
      ? 'plant seizoen'
      : 'zaai seizoen';
}

String _plantingSeasonMoestuinLabel({
  required PlantingSeasonStatus status,
  required String topic,
}) {
  final season = _plantingSeasonKindLabel(status.taskType);
  switch (status.phase) {
    case PlantingSeasonPhase.activeNow:
      return 'Nu: $topic';
    case PlantingSeasonPhase.daysLeft:
      final d = status.days ?? 0;
      return d == 1 ? 'Nog 1 dag in $season' : 'Nog $d dagen in $season';
    case PlantingSeasonPhase.startsSoon:
      final d = status.days ?? 0;
      return d == 1 ? 'Nog 1 dag tot $season' : 'Nog $d dagen tot $season';
    case PlantingSeasonPhase.seasonEnded:
      return 'Zaaiseizoen voorbij';
    case PlantingSeasonPhase.noCalendar:
      return topic;
  }
}

String _plantingActionTopic({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required PlantingSeasonStatus status,
}) {
  if (status.taskType != null) {
    return moestuinPlantingMethodLabel(status.taskType!);
  }
  if (profile != null && !profile.isPlanted) {
    return pendingPlantingTaskLabel(vegetable: vegetable, profile: profile);
  }
  return moestuinInitialPlantingActionLabel(vegetable: vegetable);
}

void _addPlantingActionFromSeason({
  required List<PlantScheduledAction> out,
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required PlantingSeasonStatus status,
  required DateTime reference,
}) {
  var current = status;
  var topic = _plantingActionTopic(
    vegetable: vegetable,
    profile: profile,
    status: current,
  );

  int? daysUntil = switch (current.phase) {
    PlantingSeasonPhase.activeNow || PlantingSeasonPhase.daysLeft => 0,
    PlantingSeasonPhase.startsSoon => current.days,
    PlantingSeasonPhase.seasonEnded ||
    PlantingSeasonPhase.noCalendar =>
      daysUntilNextInitialPlantSeason(
        vegetable.id,
        reference: reference,
        vegetable: vegetable,
      ),
  };

  if (current.phase == PlantingSeasonPhase.seasonEnded ||
      current.phase == PlantingSeasonPhase.noCalendar) {
    if (daysUntil == null || daysUntil <= 0) return;
    current = PlantingSeasonStatus(
      phase: PlantingSeasonPhase.startsSoon,
      label: '',
      days: daysUntil,
      taskType: current.taskType,
    );
  }

  if (daysUntil == null) return;

  final label = _plantingSeasonMoestuinLabel(status: current, topic: topic);

  if (daysUntil == 0) {
    out.add(
      _planPlantAction(
        topic: topic,
        activeLabel: label,
        vegetable: vegetable,
        profile: profile,
        daysUntil: 0,
        reference: reference,
      ),
    );
    return;
  }

  out.add(
    PlantScheduledAction(
      kind: PlantScheduledActionKind.calendar,
      topic: topic,
      activeLabel: label,
      daysUntil: daysUntil,
    ),
  );
}

/// Korte regel voor Actie: nog X dagen zaaien/planten in dit venster.
String moestuinPlantingSeasonActiveActionLabel({
  required Vegetable vegetable,
  int? month,
  DateTime? reference,
}) {
  final m = month ?? (reference ?? DateTime.now()).month;
  final verb = moestuinPlantingActionLabel(
    vegetable: vegetable,
    month: m,
  ).toLowerCase();
  final left = plantingSeasonDaysLeftInWindow(
    vegetable.id,
    reference: reference,
    vegetable: vegetable,
  );
  if (left != null && left > 0) {
    return left == 1 ? 'Nog 1 dag $verb' : 'Nog $left dagen $verb';
  }
  return 'Nu seizoen $verb';
}

/// Aftelling op Volgende actie: nog X dagen om te zaaien/planten.
String moestuinPlantingSeasonCountdownLabel({
  required Vegetable vegetable,
  int? month,
  DateTime? reference,
}) {
  final m = month ?? (reference ?? DateTime.now()).month;
  final topic = moestuinPlantingActionLabel(vegetable: vegetable, month: m);
  final left = plantingSeasonDaysLeftInWindow(
    vegetable.id,
    reference: reference,
    vegetable: vegetable,
  );
  if (left != null && left > 0) {
    return left == 1 ? 'Nog 1 dag: $topic' : 'Nog $left dagen: $topic';
  }
  if (left == 0) {
    return 'Laatste dag: $topic';
  }
  return moestuinPlantingSeasonActiveActionLabel(
    vegetable: vegetable,
    month: m,
    reference: reference,
  );
}

/// Alias — zie [moestuinPlantingSeasonActiveActionLabel].
String moestuinPlantingSeasonNowLabel({
  required Vegetable vegetable,
  int? month,
  DateTime? reference,
}) {
  return moestuinPlantingSeasonActiveActionLabel(
    vegetable: vegetable,
    month: month,
    reference: reference,
  );
}

void _addAwaitingOutdoorPlantingActions({
  required List<PlantScheduledAction> out,
  required Vegetable vegetable,
  required DateTime reference,
}) {
  const label = outdoorPlantingActionLabel;
  if (isOutdoorPlantingDueNow(vegetable: vegetable, reference: reference)) {
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.planPlant,
        topic: label,
        activeLabel: moestuinOutdoorPlantingActiveActionLabel(
          vegetable: vegetable,
          reference: reference,
        ),
        daysUntil: 0,
      ),
    );
    return;
  }
  final days = daysUntilOutdoorPlanting(
    vegetable: vegetable,
    reference: reference,
  );
  if (days != null && days > 0) {
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.calendar,
        topic: label,
        activeLabel: days == 1
            ? 'Nog 1 dag tot plant seizoen'
            : 'Nog $days dagen tot plant seizoen',
        daysUntil: days,
      ),
    );
  }
}

void _addPlantingActions({
  required List<PlantScheduledAction> out,
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required int month,
  required DateTime reference,
}) {
  if (profile != null &&
      isMoestuinOffSeasonWaiting(
        profile: profile,
        vegetable: vegetable,
        reference: reference,
      )) {
    return;
  }

  final status = plantingSeasonStatusForGrowApproach(
    vegetable: vegetable,
    growApproach: profile != null ? resolvePlantGrowApproach(profile) : null,
    plantStartMethod: profile?.plantStartMethod,
    reference: reference,
  );

  if (status.phase == PlantingSeasonPhase.noCalendar) return;

  _addPlantingActionFromSeason(
    out: out,
    vegetable: vegetable,
    profile: profile,
    status: status,
    reference: reference,
  );
}

void _addScanActions({
  required List<PlantScheduledAction> out,
  required GardenPlantProfile profile,
  required GardenScanPrefsStore scanPrefs,
  required DateTime today,
}) {
  if (hasPostPlantAiScan(profile)) {
    _addWeeklyScanActions(
      out: out,
      profile: profile,
      scanPrefs: scanPrefs,
      today: today,
    );
    return;
  }

  if (awaitingFirstPhotoScan(profile)) {
    final due = firstPhotoDueDate(
      profile,
      daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
    );
    final days = due.difference(today).inDays;
    final active = days <= 0 ||
        needsFirstPhoto(
          profile,
          daysUntilFirstPhoto: scanPrefs.daysUntilFirstPhoto,
        );
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.firstScan,
        topic: 'Eerste scan',
        activeLabel: kFirstScanCardLabel,
        daysUntil: active ? 0 : days,
      ),
    );
    return;
  }
}

void _addWeeklyScanActions({
  required List<PlantScheduledAction> out,
  required GardenPlantProfile profile,
  required GardenScanPrefsStore scanPrefs,
  required DateTime today,
}) {
  if (profile.lastAnalysis == null) return;

  final scannedToday = _scannedToday(profile, today);
  final due = profile.nextScanDue;
  if (due == null) {
    if (scannedToday && profile.isMoestuinActive) {
      out.add(
        PlantScheduledAction(
          kind: PlantScheduledActionKind.weeklyScan,
          topic: 'Scan',
          activeLabel: 'Wekelijkse foto',
          daysUntil: scanPrefs.weeklyScanIntervalDays,
        ),
      );
    } else if (!scannedToday && needsWeeklyScan(profile)) {
      out.add(
        const PlantScheduledAction(
          kind: PlantScheduledActionKind.weeklyScan,
          topic: 'Scan',
          activeLabel: 'Wekelijkse foto',
          daysUntil: 0,
        ),
      );
    }
    return;
  }

  final days = DateTime(due.year, due.month, due.day).difference(today).inDays;
  if (scannedToday) {
    if (days > 0) {
      out.add(
        PlantScheduledAction(
          kind: PlantScheduledActionKind.weeklyScan,
          topic: 'Scan',
          activeLabel: 'Wekelijkse foto',
          daysUntil: days,
        ),
      );
    }
    return;
  }

  if (needsWeeklyScan(profile) || days <= 0) {
    out.add(
      const PlantScheduledAction(
        kind: PlantScheduledActionKind.weeklyScan,
        topic: 'Scan',
        activeLabel: 'Wekelijkse foto',
        daysUntil: 0,
      ),
    );
  } else if (days > 0) {
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.weeklyScan,
        topic: 'Scan',
        activeLabel: 'Wekelijkse foto',
        daysUntil: days,
      ),
    );
  }
}

void _addScanAssessmentLetOpActions({
  required List<PlantScheduledAction> out,
  required GardenPlantProfile profile,
}) {
  final insight = profile.lastAnalysis?.insight;
  if (insight == null) return;

  for (final a in letOpAssessments(insight)) {
    final text = '${a.title} ${a.description}';
    if (shouldExcludeFromHomeActions(text, profile: profile)) continue;

    final topicKey = semanticTopicKeyForTaskId(a.taskId);
    final hasTask = out.any((existing) {
      if (!isPlantTaskScheduledActionKind(existing.kind)) return false;
      if (topicKey == null) return existing.topic == a.title;
      return semanticTopicKeyForAction(existing.topic) == topicKey;
    });
    if (hasTask) continue;

    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.aiLetOp,
        topic: a.title,
        activeLabel: a.title,
        detailBody: a.description,
      ),
    );
  }
}

void _addAiCoachActions({
  required List<PlantScheduledAction> out,
  required GardenPlantProfile profile,
}) {
  final insight = profile.lastAnalysis?.insight;
  if (insight == null) return;

  for (final task in insight.coachTasks) {
    final title = task.title.trim();
    if (title.isEmpty) continue;
    if (shouldExcludeFromHomeActions(
      '$title ${task.body ?? ''}',
      profile: profile,
    )) {
      continue;
    }
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.aiCoach,
        topic: title,
        activeLabel: title,
        daysUntil: 0,
        detailBody: task.body,
      ),
    );
  }

  final coachKeys = <String>{};
  for (final task in insight.coachTasks) {
    final title = task.title.trim();
    if (title.isEmpty) continue;
    final key = semanticTopicKeyForAction(title);
    if (key != null) coachKeys.add(key);
  }

  for (final rec in insight.recommendedActions) {
    final title = rec.title.trim();
    if (title.isEmpty) continue;
    if (shouldExcludeFromHomeActions(
      '$title ${rec.description ?? ''}',
      profile: profile,
    )) {
      continue;
    }
    if (coachKeys.contains(semanticTopicKeyForAction(title))) continue;
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.aiRecommended,
        topic: title,
        activeLabel: title,
        daysUntil: 0,
        detailBody: rec.description,
      ),
    );
  }
}

void _addHarvestActions({
  required List<PlantScheduledAction> out,
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required DateTime reference,
}) {
  if (!canUseAiHarvestAssessment(profile, vegetable: vegetable)) return;

  if (isEdibleMoestuinBloomCrop(vegetable) &&
      showEdibleBloomHarvestSection(profile, vegetable)) {
    out.add(
      const PlantScheduledAction(
        kind: PlantScheduledActionKind.harvest,
        topic: 'Oogsten',
        activeLabel: 'Eetbaar of seizoen afronden',
        daysUntil: 0,
      ),
    );
    return;
  }

  if (isOrnamentalOnlyMoestuinCrop(vegetable) &&
      showOrnamentalFinishSection(profile, vegetable)) {
    final bloom = shortTextForHomeCard(
      bloomHintFromProfile(profile),
      maxLen: 44,
    );
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.harvest,
        topic: 'Bloei',
        activeLabel: bloom.isNotEmpty ? bloom : 'In bloei',
        daysUntil: 0,
      ),
    );
    return;
  }

  if (isHomeHarvestActionDue(profile, vegetable: vegetable)) {
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.harvest,
        topic: 'Oogsten',
        activeLabel:
            profile.lastAnalysis?.harvestWindowLabel ?? 'Klaar om te oogsten',
        daysUntil: 0,
        detailBody: profile.lastAnalysis?.insight?.ripenessNote ??
            profile.lastAnalysis?.advice,
      ),
    );
  }
}

/// Toekomstige oogst — alleen na AI-scan met oogstschatting (geen kalender-fallback).
void _addHarvestCountdownActions({
  required List<PlantScheduledAction> out,
  required Vegetable vegetable,
  required GardenPlantProfile profile,
  required DateTime reference,
}) {
  if (!canUseAiHarvestAssessment(profile, vegetable: vegetable)) return;
  if (isHomeHarvestActionDue(profile, vegetable: vegetable)) return;

  final analysis = profile.lastAnalysis;
  if (analysis == null) return;

  final days = remainingHarvestDays(profile, reference: reference);
  if (days != null && days > 0) {
    out.add(
      PlantScheduledAction(
        kind: PlantScheduledActionKind.harvest,
        topic: 'Oogsten',
        activeLabel: analysis.harvestWindowLabel.trim().isNotEmpty
            ? analysis.harvestWindowLabel.trim()
            : 'Oogst verwacht',
        daysUntil: days,
      ),
    );
  }
}

/// “Mogelijk oogstbaar” op Actie als de AI dat suggereert maar nog geen harde oogstactie.
void _addPossibleHarvestHintAction({
  required List<PlantScheduledAction> out,
  required Vegetable vegetable,
  required GardenPlantProfile profile,
}) {
  if (isHomeHarvestActionDue(profile, vegetable: vegetable)) return;
  if (!isHarvestPossiblyReady(profile, vegetable)) return;
  if (out.any((a) => a.kind == PlantScheduledActionKind.harvest)) return;

  final days = remainingHarvestDays(profile);
  if (days != null && days > 0) return;

  out.add(
    const PlantScheduledAction(
      kind: PlantScheduledActionKind.harvest,
      topic: 'Oogsten',
      activeLabel: 'Mogelijk oogstbaar',
      daysUntil: 0,
    ),
  );
}

String _warningTopic(String warning) {
  final short = shortTextForHomeCard(warning, maxLen: 28);
  if (short.toLowerCase().startsWith('plaag')) return 'Plaag';
  if (short.toLowerCase().startsWith('ziekte')) return 'Ziekte';
  if (short.toLowerCase().startsWith('water')) return 'Water';
  if (short.toLowerCase().startsWith('onkr')) return 'Onkruid';
  return short;
}

String _warningActiveLabel(String warning) {
  return shortTextForHomeCard(warning, maxLen: 48);
}

bool _isDismissedHomeAction({
  required GardenPlantProfile profile,
  required PlantScheduledAction action,
}) {
  // Toekomstige aftellingen (scan over X dagen) blijven zichtbaar tot seizoen
  // afronden — ook na een scan vandaag.
  final days = action.daysUntil;
  if (days != null && days > 0) return false;

  return isHomeActionCompleted(
    profile: profile,
    kindName: action.kind.name,
    topic: action.topic,
    activeLabel: action.activeLabel,
    detailBody: action.detailBody,
  );
}

bool _scannedToday(GardenPlantProfile profile, DateTime today) {
  final last = profile.lastAnalysis;
  if (last == null) return false;
  final scanned = DateTime(
    last.scannedAt.year,
    last.scannedAt.month,
    last.scannedAt.day,
  );
  return scanned == today;
}

bool _isHarvestRelatedText(String text) {
  final t = text.toLowerCase();
  return t.contains('oogst') ||
      t.contains('pluk') ||
      t.contains('rijp') ||
      t.contains('harvest') ||
      t.contains('oogstbaar');
}

bool _isScanRelatedText(String text) {
  final t = text.toLowerCase();
  return t.contains('scan') ||
      t.contains('foto') ||
      t.contains('camera') ||
      t.contains('maak een foto');
}

bool _isCheckRelatedText(String text) {
  final t = text.toLowerCase();
  return t.contains('controleer') ||
      t.contains('check') ||
      t.contains('nakijken') ||
      t.contains('inspecteer');
}

bool _coachTaskStillRelevant({
  required GardenPlantProfile profile,
  required String title,
  String? body,
}) {
  final analysis = profile.lastAnalysis;
  final insight = analysis?.insight;
  final text = '$title ${body ?? ''}'.toLowerCase();

  if (analysis?.pestLikelyResolvedSincePrevious == true) {
    if (text.contains('plaag') ||
        text.contains('bladluis') ||
        text.contains('rups') ||
        _isCheckRelatedText(text)) {
      return false;
    }
  }

  if (insight != null &&
      insight.confirmedPests.isEmpty &&
      insight.confirmedDiseases.isEmpty &&
      insight.riskLevel == AiRiskLevel.low &&
      insight.priority.index <= AiPriority.medium.index) {
    if (_isCheckRelatedText(text) && !text.contains('oogst')) {
      return false;
    }
  }

  if (_isScanRelatedText(text) && _scannedToday(profile, DateTime.now())) {
    return false;
  }

  if (_isHarvestRelatedText(text) &&
      isHomeHarvestActionDue(profile, vegetable: null)) {
    return false;
  }

  return true;
}

void _filterStaleCoachAndRecommended({
  required List<PlantScheduledAction> out,
  required GardenPlantProfile? profile,
}) {
  if (profile == null) return;

  final hasActiveHarvest = out.any(
    (a) =>
        a.kind == PlantScheduledActionKind.harvest &&
        (a.daysUntil ?? 0) <= 0,
  );

  out.removeWhere((action) {
    if (action.kind != PlantScheduledActionKind.aiCoach &&
        action.kind != PlantScheduledActionKind.aiRecommended) {
      return false;
    }

    if (!_coachTaskStillRelevant(
      profile: profile,
      title: action.topic,
      body: action.detailBody ?? action.activeLabel,
    )) {
      return true;
    }

    if (hasActiveHarvest && _isHarvestRelatedText(action.topic)) {
      return true;
    }

    if (shouldExcludeFromHomeActions(
      '${action.topic} ${action.activeLabel} ${action.detailBody ?? ''}',
      profile: profile,
    )) {
      return true;
    }

    return false;
  });
}

void _dedupeHarvestActions(List<PlantScheduledAction> out) {
  final harvestIndexes = <int>[];
  for (var i = 0; i < out.length; i++) {
    if (out[i].kind == PlantScheduledActionKind.harvest) {
      harvestIndexes.add(i);
    }
  }
  if (harvestIndexes.length <= 1) return;

  var keep = harvestIndexes.first;
  for (final i in harvestIndexes) {
    final candidate = out[i];
    final current = out[keep];
    final cDays = candidate.daysUntil ?? 9999;
    final kDays = current.daysUntil ?? 9999;
    if (cDays < kDays) {
      keep = i;
      continue;
    }
    if (cDays == kDays && candidate.activeLabel.length > current.activeLabel.length) {
      keep = i;
    }
  }

  for (var i = harvestIndexes.length - 1; i >= 0; i--) {
    final idx = harvestIndexes[i];
    if (idx != keep) out.removeAt(idx);
  }
}

/// Eén actie per onderwerp (water, oogst, bladluis, …), geen dubbele meldingen.
void _dedupeSemanticTopicActions(List<PlantScheduledAction> out) {
  final groups = <String, List<int>>{};
  for (var i = 0; i < out.length; i++) {
    final key = semanticTopicKeyForAction(
      '${out[i].topic} ${out[i].activeLabel} ${out[i].detailBody ?? ''}',
    );
    if (key == null) continue;
    groups.putIfAbsent(key, () => []).add(i);
  }

  final remove = <int>{};
  for (final indices in groups.values) {
    if (indices.length <= 1) continue;
    final keep = _bestDuplicateIndex(out, indices);
    for (final i in indices) {
      if (i != keep) remove.add(i);
    }
  }

  final sorted = remove.toList()..sort((a, b) => b.compareTo(a));
  for (final i in sorted) {
    out.removeAt(i);
  }
}

int _bestDuplicateIndex(List<PlantScheduledAction> out, List<int> indices) {
  var best = indices.first;
  for (final i in indices) {
    if (_actionRichnessScore(out[i]) > _actionRichnessScore(out[best])) {
      best = i;
    }
  }
  return best;
}

int _actionRichnessScore(PlantScheduledAction action) {
  var score = 0;
  final body = action.detailBody?.trim();
  if (body != null && body.isNotEmpty) score += body.length.clamp(0, 40);
  score += switch (action.kind) {
    PlantScheduledActionKind.aiCoach => 30,
    PlantScheduledActionKind.aiWarning => 25,
    PlantScheduledActionKind.aiRecommended => 15,
    PlantScheduledActionKind.harvest => 20,
    _ => 0,
  };
  return score;
}

