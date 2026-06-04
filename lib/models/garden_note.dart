/// Bron van een tuin-notitie.
enum GardenNoteSource {
  user,
  ai,
}

extension GardenNoteSourceLabel on GardenNoteSource {
  String get label {
    switch (this) {
      case GardenNoteSource.user:
        return 'Jouw notitie';
      case GardenNoteSource.ai:
        return 'AI-scan';
    }
  }

  String get emoji {
    switch (this) {
      case GardenNoteSource.user:
        return '📝';
      case GardenNoteSource.ai:
        return '🤖';
    }
  }
}

/// Notitie gekoppeld aan een dag; optioneel aan één of meer groenten.
class GardenNote {
  const GardenNote({
    required this.id,
    required this.date,
    required this.title,
    required this.body,
    required this.source,
    this.vegetableIds = const [],
    this.scanPhotoPath,
    this.onCalendar = true,
    this.notify = false,
    this.createdAt,
  });

  final String id;
  final DateTime date;
  final String title;
  final String body;
  final GardenNoteSource source;

  /// Leeg = algemene tuintaak (niet gekoppeld aan een groente).
  final List<String> vegetableIds;

  final String? scanPhotoPath;
  final bool onCalendar;
  final bool notify;
  final DateTime? createdAt;

  /// Eerste gekoppelde groente (o.a. voor oudere code).
  String? get vegetableId =>
      vegetableIds.isEmpty ? null : vegetableIds.first;

  bool get isGeneralGardenTask => vegetableIds.isEmpty;

  DateTime get dateOnly => DateTime(date.year, date.month, date.day);

  GardenNote copyWith({
    String? id,
    DateTime? date,
    String? title,
    String? body,
    GardenNoteSource? source,
    List<String>? vegetableIds,
    String? scanPhotoPath,
    bool? onCalendar,
    bool? notify,
    DateTime? createdAt,
  }) {
    return GardenNote(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      body: body ?? this.body,
      source: source ?? this.source,
      vegetableIds: vegetableIds ?? this.vegetableIds,
      scanPhotoPath: scanPhotoPath ?? this.scanPhotoPath,
      onCalendar: onCalendar ?? this.onCalendar,
      notify: notify ?? this.notify,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'date': dateOnly.toIso8601String(),
        'title': title,
        'body': body,
        'source': source.name,
        'vegetableIds': vegetableIds,
        if (vegetableId != null) 'vegetableId': vegetableId,
        'scanPhotoPath': scanPhotoPath,
        'onCalendar': onCalendar,
        'notify': notify,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory GardenNote.fromJson(Map<String, dynamic> json) {
    final rawDate = DateTime.parse(json['date'] as String);
    return GardenNote(
      id: json['id'] as String,
      date: DateTime(rawDate.year, rawDate.month, rawDate.day),
      title: json['title'] as String,
      body: json['body'] as String,
      source: GardenNoteSource.values.byName(json['source'] as String),
      vegetableIds: _vegetableIdsFromJson(json),
      scanPhotoPath: json['scanPhotoPath'] as String?,
      onCalendar: json['onCalendar'] as bool? ?? true,
      notify: json['notify'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }

  static List<String> _vegetableIdsFromJson(Map<String, dynamic> json) {
    final raw = json['vegetableIds'];
    if (raw is List) {
      return raw.map((e) => e.toString()).where((id) => id.isNotEmpty).toList();
    }
    final single = json['vegetableId'] as String?;
    if (single != null && single.isNotEmpty) return [single];
    return const [];
  }
}
