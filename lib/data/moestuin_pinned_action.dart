import '../models/garden_plant_profile.dart';
import '../models/vegetable.dart';
import 'garden_plant_schedule.dart';
import 'garden_scan_prefs_store.dart';
import 'home_action_completion.dart';
import 'home_plant_display_text.dart';
import 'home_upcoming_items.dart';
import 'plant_lifecycle.dart';
import 'plant_pending_planting.dart';
import 'plant_scheduled_actions.dart';
import 'plant_season_activation.dart';
import 'plant_start_flow.dart';

/// Max. lengte voor “Actie” op de smalle plantkaart.
const moestuinCardActionMaxLen = 22;

String plantScheduledActionKey(PlantScheduledAction action) {
  return homeActionDismissKey(
    kindName: action.kind.name,
    topic: action.topic,
    activeLabel: action.activeLabel,
    detailBody: action.detailBody,
  );
}

PlantScheduledAction? plantScheduledActionByKey(
  List<PlantScheduledAction> actions,
  String key,
) {
  for (final action in actions) {
    if (plantScheduledActionKey(action) == key) return action;
  }
  return null;
}

/// Vastgezette actie op de kaart — wisselt na afvinken of urgentere scan.
PlantScheduledAction? pinnedMoestuinCardAction({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  final actions = moestuinCardActions(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    month: month,
    reference: reference,
  );
  if (actions.isEmpty) return null;

  final primary = _primaryImmediateAction(
    actions,
    profile: profile,
  )!;
  if (profile == null) return primary;

  final pinKey = profile.pinnedMoestuinActionKey;
  if (pinKey == null || pinKey.isEmpty) return primary;

  final pinned = plantScheduledActionByKey(actions, pinKey);
  if (pinned == null) return primary;

  if (shouldHideMoestuinHarvestAction(
    pinned,
    profile: profile,
    vegetable: vegetable,
  )) {
    return primary;
  }

  final pinAtScan = profile.pinnedMoestuinActionAtScanMs;
  final lastScanMs = profile.lastAnalysis?.scannedAt.millisecondsSinceEpoch;
  if (lastScanMs != null &&
      pinAtScan != null &&
      lastScanMs > pinAtScan &&
      comparePlantScheduledActions(primary, pinned) < 0) {
    return primary;
  }

  return pinned;
}

/// Werkt de pin bij na scan of afvinken in home.
GardenPlantProfile syncPinnedMoestuinAction({
  required GardenPlantProfile profile,
  required Vegetable vegetable,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  final actions = moestuinCardActions(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    month: month,
    reference: reference,
  );
  if (actions.isEmpty) {
    if (profile.pinnedMoestuinActionKey == null) return profile;
    return profile.copyWith(clearPinnedMoestuinAction: true);
  }

  final primary = _primaryImmediateAction(
    actions,
    profile: profile,
  )!;
  final pinKey = profile.pinnedMoestuinActionKey;
  final pinAtScan = profile.pinnedMoestuinActionAtScanMs;
  final lastScanMs =
      profile.lastAnalysis?.scannedAt.millisecondsSinceEpoch ??
      DateTime.now().millisecondsSinceEpoch;

  if (pinKey == null || pinKey.isEmpty) {
    return profile.copyWith(
      pinnedMoestuinActionKey: plantScheduledActionKey(primary),
      pinnedMoestuinActionAtScanMs: lastScanMs,
    );
  }

  final pinned = plantScheduledActionByKey(actions, pinKey);
  if (pinned == null) {
    return profile.copyWith(
      pinnedMoestuinActionKey: plantScheduledActionKey(primary),
      pinnedMoestuinActionAtScanMs: lastScanMs,
    );
  }

  if (shouldHideMoestuinHarvestAction(
    pinned,
    profile: profile,
    vegetable: vegetable,
  )) {
    return profile.copyWith(
      pinnedMoestuinActionKey: plantScheduledActionKey(primary),
      pinnedMoestuinActionAtScanMs: lastScanMs,
    );
  }

  if (lastScanMs > (pinAtScan ?? 0) &&
      comparePlantScheduledActions(primary, pinned) < 0) {
    return profile.copyWith(
      pinnedMoestuinActionKey: plantScheduledActionKey(primary),
      pinnedMoestuinActionAtScanMs: lastScanMs,
    );
  }

  return profile;
}

String _actionContext(PlantScheduledAction action) =>
    '${action.topic} ${action.activeLabel} ${action.detailBody ?? ''}';

/// Alle kaartacties: twee woorden, kort en duidelijk.
String moestuinCardActionShortLabel(PlantScheduledAction action) {
  switch (action.kind) {
    case PlantScheduledActionKind.aiWarning:
    case PlantScheduledActionKind.aiLetOp:
    case PlantScheduledActionKind.seasonWarning:
      if (semanticTopicKeyForAction(_actionContext(action)) == 'harvest') {
        return shortTextForHomeCard(
          action.activeLabel,
          maxLen: moestuinCardActionMaxLen,
        );
      }
      return _semanticActionLabel(
        _actionContext(action),
        fallback: _warningTopicLabel(action.topic),
      );
    case PlantScheduledActionKind.planPlant:
      return action.activeLabel;
    case PlantScheduledActionKind.firstScan:
      return 'Eerste scan';
    case PlantScheduledActionKind.weeklyScan:
      return action.isActiveNow ? 'Nieuwe scan' : 'Scan plannen';
    case PlantScheduledActionKind.harvest:
      if (action.topic == 'Bloei') return 'In bloei';
      if (_hasCountdownDays(action)) return 'Oogst verwacht';
      if (action.activeLabel.toLowerCase().contains('mogelijk')) {
        return 'Mogelijk oogst';
      }
      return 'Nu oogstbaar';
    case PlantScheduledActionKind.aiCoach:
    case PlantScheduledActionKind.aiRecommended:
      if (semanticTopicKeyForAction(_actionContext(action)) == 'harvest') {
        return shortTextForHomeCard(
          action.activeLabel,
          maxLen: moestuinCardActionMaxLen,
        );
      }
      return _semanticActionLabel(
        _actionContext(action),
        fallback: _twoWordLabel(action.topic, verb: 'opvolgen'),
      );
    case PlantScheduledActionKind.calendar:
      return _calendarTopicLabel(action.topic);
  }
}

String _warningTopicLabel(String topic) {
  return switch (topic) {
    'Water' => 'Water geven',
    'Onkruid' => 'Onkruid wieden',
    'Ziekte' => 'Ziekte aanpakken',
    'Plaag' => 'Plaag bestrijden',
    'Laat oogst' => 'Laat oogsten',
    'Plantstatus' => 'Plant controleren',
    _ => _twoWordLabel(topic, verb: 'aanpakken'),
  };
}

String _calendarTopicLabel(String topic) {
  return switch (topic) {
    'Voorzaaien' => 'Nu voorzaaien',
    'Zaaien buiten' => 'Buiten zaaien',
    'Planten' => 'Nu planten',
    'Oogsten' => 'Nu oogsten',
    'Scan' => 'Nieuwe scan',
    'Eerste scan' => 'Eerste scan',
    'Bloei' => 'In bloei',
    _ => _twoWordLabel(topic, verb: 'plannen'),
  };
}

String _twoWordLabel(String topic, {required String verb}) {
  final t = topic.trim();
  if (t.isEmpty) return 'Geen taak';
  final words = t.split(RegExp(r'\s+'));
  if (words.length >= 2) {
    return '${words[0]} ${words[1]}';
  }
  return '$t $verb';
}

String _semanticActionLabel(String text, {required String fallback}) {
  return switch (semanticTopicKeyForAction(text)) {
    'water' => 'Water geven',
    'harvest' => 'Nu oogstbaar',
    'bladluis' => 'Bladluis verwijderen',
    'rups' => 'Rups verwijderen',
    'slak' => 'Slak verwijderen',
    'witte_vlieg' => 'Vlieg bestrijden',
    'spint' => 'Spint bestrijden',
    'trips' => 'Trips bestrijden',
    'meeldauw' => 'Meeldauw bestrijden',
    'schimmel' => 'Schimmel bestrijden',
    'onkruid' => 'Onkruid wieden',
    'voeding' => 'Plant bemesten',
    'snoei' => 'Plant snoeien',
    'scan' => 'Nieuwe scan',
    _ => fallback,
  };
}

String moestuinCardActionDisplayText(PlantScheduledAction action) {
  return shortTextForHomeCard(
    moestuinCardActionShortLabel(action),
    maxLen: moestuinCardActionMaxLen,
  );
}

/// Tekst voor “Actie” op de plantkaart — vastgezet tot afvinken of urgentere scan.
String moestuinPrimaryActionLabel({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  if (profile != null && !profile.isMoestuinActive) {
    return 'Niet actief';
  }

  if (profile != null && profileAwaitingOutdoorPlanting(profile)) {
    if (isOutdoorPlantingDueNow(
      vegetable: vegetable,
      reference: reference,
    )) {
      return shortTextForHomeCard(
        moestuinOutdoorPlantingActiveActionLabel(
          vegetable: vegetable,
          reference: reference,
        ),
        maxLen: moestuinCardActionMaxLen,
      );
    }
  }

  if (profile != null && !profile.isPlanted) {
    if (isPlantingDueNow(
      vegetable: vegetable,
      profile: profile,
      reference: reference,
    )) {
      return shortTextForHomeCard(
        moestuinUnplantedSowActiveActionLabel(
          vegetable: vegetable,
          reference: reference,
          profile: profile,
        ),
        maxLen: moestuinCardActionMaxLen,
      );
    }
    return 'Geen taak';
  }

  final pinned = pinnedMoestuinCardAction(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    month: month,
    reference: reference,
  );
  if (pinned == null) return 'Geen taak';
  return moestuinCardActionDisplayText(pinned);
}

bool _isPlantingTopic(String topic) {
  final t = topic.toLowerCase();
  return t.contains('zaai') || t.contains('plant') || t.contains('voorzaai');
}

String? _preScanPlantingLabelFromActions(
  List<PlantScheduledAction> actions, {
  GardenPlantProfile? profile,
}) {
  if (profile != null && !hasPostPlantAiScan(profile)) {
    for (final action in actions) {
      if (action.kind == PlantScheduledActionKind.firstScan) {
        return kFirstScanCardLabel;
      }
    }
  }
  for (final action in actions) {
    if (action.kind == PlantScheduledActionKind.planPlant) {
      return action.topic;
    }
    if (action.kind == PlantScheduledActionKind.calendar &&
        _isPlantingTopic(action.topic)) {
      return action.topic;
    }
  }
  return null;
}

/// Groene badge vóór de eerste scan: alleen wat je moet doen, zonder dagen.
String moestuinPreScanGreenBadgeLabel({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  final ref = reference ?? DateTime.now();

  if (profile != null && profile.isPlanted && !hasPostPlantAiScan(profile)) {
    return kFirstScanCardLabel;
  }

  if (profile != null && profileAwaitingOutdoorPlanting(profile)) {
    return outdoorPlantingActionLabel;
  }

  if (profile != null && !profile.isPlanted) {
    final plantingLabel = _preScanPlantingLabelFromActions(
      moestuinCardActions(
        vegetable: vegetable,
        profile: profile,
        scanPrefs: scanPrefs,
        month: month,
        reference: ref,
      ),
      profile: profile,
    );
    if (plantingLabel != null) return plantingLabel;
    return pendingPlantingTaskLabel(vegetable: vegetable, profile: profile);
  }

  return moestuinInitialPlantingActionLabel(vegetable: vegetable);
}

/// Actie met aftelling (over X dagen).
bool _hasCountdownDays(PlantScheduledAction action) {
  final days = action.daysUntil;
  return days != null && days > 0;
}

PlantScheduledAction? _primaryImmediateAction(
  List<PlantScheduledAction> actions, {
  GardenPlantProfile? profile,
}) {
  if (profile != null && !hasPostPlantAiScan(profile)) {
    for (final action in actions) {
      if (action.kind == PlantScheduledActionKind.firstScan) {
        return action;
      }
    }
  }
  for (final action in actions) {
    if (action.isActiveNow) return action;
  }
  return actions.isNotEmpty ? actions.first : null;
}

/// Verandert bij app-start en elke keer dat je Mijn moestuin opent.
int moestuinCountdownRotationEpoch = 0;

/// Nieuwe volgorde voor roterende aftellingen op de plantkaart.
void bumpMoestuinCountdownRotation() {
  moestuinCountdownRotationEpoch++;
}

List<PlantScheduledAction> moestuinCountdownActions(
  List<PlantScheduledAction> actions,
) {
  return [
    for (final action in actions)
      if (_hasCountdownDays(action)) action,
  ];
}

PlantScheduledAction? _rotatedCountdownAction({
  required List<PlantScheduledAction> actions,
  required String vegetableId,
}) {
  final countdowns = moestuinCountdownActions(actions);
  if (countdowns.isEmpty) return null;
  final idx = (moestuinCountdownRotationEpoch + vegetableId.hashCode).abs() %
      countdowns.length;
  return countdowns[idx];
}

String moestuinVolgendeActieDisplayText(PlantScheduledAction action) {
  return action.moestuinLabel;
}

/// Tekst voor “Volgende actie” — roteert door aftellingen bij app-start / moestuin-tab.
String moestuinNextActionLabel({
  required Vegetable vegetable,
  required GardenPlantProfile? profile,
  required GardenScanPrefsStore scanPrefs,
  int? month,
  DateTime? reference,
}) {
  if (profile != null && !profile.isMoestuinActive) {
    return moestuinInactiveNextSeasonLabel(
      profile: profile,
      vegetable: vegetable,
      reference: reference,
    );
  }

  if (profile != null && profileAwaitingOutdoorPlanting(profile)) {
    if (isOutdoorPlantingDueNow(
      vegetable: vegetable,
      reference: reference,
    )) {
      final left = outdoorPlantingDaysLeftInWindow(
        vegetable: vegetable,
        reference: reference,
      );
      if (left != null && left > 0) {
        return left == 1
            ? 'Nog 1 dag: $outdoorPlantingActionLabel'
            : 'Nog $left dagen: $outdoorPlantingActionLabel';
      }
      return outdoorPlantingActionLabel;
    }
    final outdoorActions = moestuinCardActions(
      vegetable: vegetable,
      profile: profile,
      scanPrefs: scanPrefs,
      month: month,
      reference: reference,
    );
    final outdoorNext = _rotatedCountdownAction(
      actions: outdoorActions,
      vegetableId: vegetable.id,
    );
    if (outdoorNext != null) {
      return moestuinVolgendeActieDisplayText(outdoorNext);
    }
  }

  if (profile != null && !profile.isPlanted) {
    if (isPlantingDueNow(
      vegetable: vegetable,
      profile: profile,
      reference: reference,
    )) {
      return moestuinUnplantedSowActiveActionLabel(
        vegetable: vegetable,
        reference: reference,
        profile: profile,
      );
    }
    final actions = moestuinCardActions(
      vegetable: vegetable,
      profile: profile,
      scanPrefs: scanPrefs,
      month: month,
      reference: reference,
    );
    final next = _rotatedCountdownAction(
      actions: actions,
      vegetableId: vegetable.id,
    );
    if (next == null) {
      return moestuinUnplantedSeasonCountdownLabel(
        vegetable: vegetable,
        reference: reference,
      );
    }
    return moestuinVolgendeActieDisplayText(next);
  }

  final actions = moestuinCardActions(
    vegetable: vegetable,
    profile: profile,
    scanPrefs: scanPrefs,
    month: month,
    reference: reference,
  );
  if (actions.isEmpty) return 'Geen taak';

  final next = _rotatedCountdownAction(
    actions: actions,
    vegetableId: vegetable.id,
  );
  if (next == null) return 'Geen taak';
  return moestuinVolgendeActieDisplayText(next);
}
