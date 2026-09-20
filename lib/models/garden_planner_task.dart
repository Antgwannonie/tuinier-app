/// Geplande tuintaak (handmatig in de Planner aangemaakt).
enum GardenPlannerTaskPriority {
  high,
  medium,
  low,
}

extension GardenPlannerTaskPriorityLabel on GardenPlannerTaskPriority {
  String get label {
    switch (this) {
      case GardenPlannerTaskPriority.high:
        return 'Hoge prioriteit';
      case GardenPlannerTaskPriority.medium:
        return 'Gemiddelde prioriteit';
      case GardenPlannerTaskPriority.low:
        return 'Lage prioriteit';
    }
  }
}

class GardenPlannerTask {
  const GardenPlannerTask({
    required this.id,
    required this.title,
    required this.dueDate,
    this.body = '',
    this.vegetableId,
    this.priority = GardenPlannerTaskPriority.medium,
    this.completed = false,
    this.createdAt,
  });

  final String id;
  final String title;
  final String body;
  final DateTime dueDate;

  /// null = algemene tuin (niet gekoppeld aan een plant).
  final String? vegetableId;
  final GardenPlannerTaskPriority priority;
  final bool completed;
  final DateTime? createdAt;

  bool get isGeneralGardenTask => vegetableId == null;

  DateTime get dueDateOnly =>
      DateTime(dueDate.year, dueDate.month, dueDate.day);

  GardenPlannerTask copyWith({
    String? id,
    String? title,
    String? body,
    DateTime? dueDate,
    String? vegetableId,
    bool clearVegetableId = false,
    GardenPlannerTaskPriority? priority,
    bool? completed,
    DateTime? createdAt,
  }) {
    return GardenPlannerTask(
      id: id ?? this.id,
      title: title ?? this.title,
      body: body ?? this.body,
      dueDate: dueDate ?? this.dueDate,
      vegetableId:
          clearVegetableId ? null : (vegetableId ?? this.vegetableId),
      priority: priority ?? this.priority,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'body': body,
        'dueDate': dueDateOnly.toIso8601String(),
        'vegetableId': vegetableId,
        'priority': priority.name,
        'completed': completed,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory GardenPlannerTask.fromJson(Map<String, dynamic> json) {
    final raw = DateTime.parse(json['dueDate'] as String);
    return GardenPlannerTask(
      id: json['id'] as String,
      title: json['title'] as String? ?? '',
      body: json['body'] as String? ?? '',
      dueDate: DateTime(raw.year, raw.month, raw.day),
      vegetableId: json['vegetableId'] as String?,
      priority: GardenPlannerTaskPriority.values.firstWhere(
        (p) => p.name == json['priority'],
        orElse: () => GardenPlannerTaskPriority.medium,
      ),
      completed: json['completed'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
