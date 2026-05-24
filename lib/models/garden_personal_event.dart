/// Persoonlijke kalender-/melding-gebeurtenissen uit AI en plantstatus.
enum PersonalEventType {
  plantReminder,
  firstPhoto,
  weeklyScan,
  harvest,
}

extension PersonalEventTypeLabel on PersonalEventType {
  String get label {
    switch (this) {
      case PersonalEventType.plantReminder:
        return 'Tijd om te planten';
      case PersonalEventType.firstPhoto:
        return 'Eerste foto maken';
      case PersonalEventType.weeklyScan:
        return 'Voortgangsfoto';
      case PersonalEventType.harvest:
        return 'Oogst (AI)';
    }
  }

  String get emoji {
    switch (this) {
      case PersonalEventType.plantReminder:
        return '🌱';
      case PersonalEventType.firstPhoto:
        return '📷';
      case PersonalEventType.weeklyScan:
        return '🔄';
      case PersonalEventType.harvest:
        return '🧺';
    }
  }
}

class GardenPersonalEvent {
  const GardenPersonalEvent({
    required this.vegetableId,
    required this.date,
    required this.type,
    required this.title,
    this.subtitle,
  });

  final String vegetableId;
  final DateTime date;
  final PersonalEventType type;
  final String title;
  final String? subtitle;
}
