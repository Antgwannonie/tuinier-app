import 'dart:math' as math;
import 'dart:ui';

/// Compleet tuinplan met meerdere bakken.
class VisualGardenPlan {
  const VisualGardenPlan({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.beds = const [],
  });

  final String id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<VisualGardenBed> beds;

  VisualGardenPlan copyWith({
    String? name,
    DateTime? updatedAt,
    List<VisualGardenBed>? beds,
  }) {
    return VisualGardenPlan(
      id: id,
      name: name ?? this.name,
      createdAt: createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      beds: beds ?? this.beds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'beds': beds.map((b) => b.toJson()).toList(),
      };

  factory VisualGardenPlan.fromJson(Map<String, dynamic> json) {
    return VisualGardenPlan(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Mijn moestuin',
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      beds: (json['beds'] as List<dynamic>? ?? [])
          .map((e) => VisualGardenBed.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Eén teeltperiode binnen een fysieke bak (voorjaar / zomer / najaar, …).
class VisualCropPlan {
  const VisualCropPlan({
    required this.id,
    required this.name,
    required this.startDate,
    required this.endDate,
    this.placements = const [],
    this.seasonLabel,
  });

  final String id;
  final String name;
  final DateTime startDate;
  final DateTime endDate;
  final List<PlantPlacement> placements;

  /// Optioneel label zoals “Voorjaar”, “Zomer”.
  final String? seasonLabel;

  DateTime get startDateOnly =>
      DateTime(startDate.year, startDate.month, startDate.day);
  DateTime get endDateOnly =>
      DateTime(endDate.year, endDate.month, endDate.day);

  String get periodLabel {
    if (startDate.year == endDate.year &&
        startDate.month == endDate.month) {
      return '${_monthNl(startDate.month)} ${startDate.year}';
    }
    if (startDate.year == endDate.year) {
      return '${_monthNl(startDate.month)} – ${_monthNl(endDate.month)} ${endDate.year}';
    }
    return '${_monthNl(startDate.month)} ${startDate.year} – ${_monthNl(endDate.month)} ${endDate.year}';
  }

  /// Korte periode zoals in de mockup: "jul – sep 2026".
  String get periodLabelShort {
    final a = _monthShort(startDate.month);
    final b = _monthShort(endDate.month);
    if (startDate.year == endDate.year && startDate.month == endDate.month) {
      return '$a ${startDate.year}';
    }
    if (startDate.year == endDate.year) {
      return '$a – $b ${endDate.year}';
    }
    return '$a ${startDate.year} – $b ${endDate.year}';
  }

  Set<String> get plantIds => {for (final p in placements) p.plantId};

  VisualCropPlan copyWith({
    String? name,
    DateTime? startDate,
    DateTime? endDate,
    List<PlantPlacement>? placements,
    String? seasonLabel,
    bool clearSeasonLabel = false,
  }) {
    return VisualCropPlan(
      id: id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      placements: placements ?? this.placements,
      seasonLabel:
          clearSeasonLabel ? null : (seasonLabel ?? this.seasonLabel),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'startDate': startDateOnly.toIso8601String(),
        'endDate': endDateOnly.toIso8601String(),
        'seasonLabel': seasonLabel,
        'placements': placements.map((p) => p.toJson()).toList(),
      };

  factory VisualCropPlan.fromJson(Map<String, dynamic> json) {
    return VisualCropPlan(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Teeltplan',
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      seasonLabel: json['seasonLabel'] as String?,
      placements: (json['placements'] as List<dynamic>? ?? [])
          .map((e) => PlantPlacement.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  static String _monthNl(int m) {
    const names = [
      '',
      'januari',
      'februari',
      'maart',
      'april',
      'mei',
      'juni',
      'juli',
      'augustus',
      'september',
      'oktober',
      'november',
      'december',
    ];
    return names[m.clamp(1, 12)];
  }

  static String _monthShort(int m) {
    const names = [
      '',
      'jan',
      'feb',
      'mrt',
      'apr',
      'mei',
      'jun',
      'jul',
      'aug',
      'sep',
      'okt',
      'nov',
      'dec',
    ];
    return names[m.clamp(1, 12)];
  }

  /// Standaard seizoenslabel op basis van startdatum.
  static String seasonForMonth(int month) {
    if (month >= 3 && month <= 5) return 'Voorjaar';
    if (month >= 6 && month <= 8) return 'Zomer';
    if (month >= 9 && month <= 11) return 'Najaar';
    return 'Winter';
  }
}

/// Eén plantenbak als gesloten polygoon in echte cm-coördinaten.
class VisualGardenBed {
  const VisualGardenBed({
    required this.id,
    required this.name,
    required this.verticesCm,
    this.cropPlans = const [],
    this.activeCropPlanId,
    this.wallHeightCm = 20,
    this.borderColorValue = 0xFFB08968,
    this.fillColorValue = 0xFF4A3728,
  });

  final String id;
  final String name;

  /// Hoeken van de bak in cm (gesloten polygoon, eerste ≠ laatste).
  final List<Offset> verticesCm;

  /// Opeenvolgende teeltplannen voor deze fysieke bak.
  final List<VisualCropPlan> cropPlans;

  /// Welk teeltplan de editor/canvas toont.
  final String? activeCropPlanId;

  /// Wandhoogte van de bak (weergave / chips).
  final double wallHeightCm;

  /// ARGB-kleur van de bakrand (hout).
  final int borderColorValue;

  /// ARGB-kleur van de binnenkant (aarde).
  final int fillColorValue;

  Color get borderColor => Color(borderColorValue);
  Color get fillColor => Color(fillColorValue);

  int get cornerCount => verticesCm.length;

  VisualCropPlan? get activeCropPlan {
    if (cropPlans.isEmpty) return null;
    final id = activeCropPlanId;
    if (id != null) {
      for (final p in cropPlans) {
        if (p.id == id) return p;
      }
    }
    return cropPlans.first;
  }

  /// Placements van het actieve teeltplan (compat voor canvas/editor).
  List<PlantPlacement> get placements =>
      activeCropPlan?.placements ?? const [];

  List<VisualCropPlan> get cropPlansSorted {
    final list = [...cropPlans];
    list.sort((a, b) => a.startDateOnly.compareTo(b.startDateOnly));
    return list;
  }

  double get widthCm {
    if (verticesCm.isEmpty) return 100;
    var minX = verticesCm.first.dx;
    var maxX = verticesCm.first.dx;
    for (final v in verticesCm) {
      minX = math.min(minX, v.dx);
      maxX = math.max(maxX, v.dx);
    }
    return math.max(maxX - minX, 1);
  }

  double get heightCm {
    if (verticesCm.isEmpty) return 100;
    var minY = verticesCm.first.dy;
    var maxY = verticesCm.first.dy;
    for (final v in verticesCm) {
      minY = math.min(minY, v.dy);
      maxY = math.max(maxY, v.dy);
    }
    return math.max(maxY - minY, 1);
  }

  /// Zijdelengtes in cm (hoek i → hoek i+1).
  List<double> get edgeLengthsCm {
    if (verticesCm.length < 2) return const [];
    final out = <double>[];
    for (var i = 0; i < verticesCm.length; i++) {
      final a = verticesCm[i];
      final b = verticesCm[(i + 1) % verticesCm.length];
      out.add((b - a).distance);
    }
    return out;
  }

  double get areaM2 {
    if (verticesCm.length < 3) return 0;
    var sum = 0.0;
    for (var i = 0; i < verticesCm.length; i++) {
      final a = verticesCm[i];
      final b = verticesCm[(i + 1) % verticesCm.length];
      sum += a.dx * b.dy - b.dx * a.dy;
    }
    return sum.abs() / 2 / 10000;
  }

  String get dimensionsLabel {
    final edges = edgeLengthsCm;
    if (edges.isEmpty) return '—';
    if (edges.length <= 4) {
      return '${edges.map((e) => '${e.round()}').join(' × ')} cm';
    }
    return '${edges.length} zijden · ${widthCm.round()}×${heightCm.round()} cm';
  }

  VisualGardenBed copyWith({
    String? name,
    List<Offset>? verticesCm,
    List<VisualCropPlan>? cropPlans,
    String? activeCropPlanId,
    bool clearActiveCropPlanId = false,
    List<PlantPlacement>? placements,
    double? wallHeightCm,
    int? borderColorValue,
    int? fillColorValue,
  }) {
    var plans = cropPlans ?? this.cropPlans;
    var activeId = clearActiveCropPlanId
        ? null
        : (activeCropPlanId ?? this.activeCropPlanId);

    // Compat: placements schrijven naar actief teeltplan.
    if (placements != null) {
      final currentId = activeId ??
          (plans.isEmpty ? null : plans.first.id);
      if (currentId != null && plans.any((p) => p.id == currentId)) {
        plans = [
          for (final p in plans)
            if (p.id == currentId)
              p.copyWith(placements: placements)
            else
              p,
        ];
        activeId = currentId;
      } else if (placements.isNotEmpty) {
        final now = DateTime.now();
        final endMonth = now.month + 2 > 12 ? now.month + 2 - 12 : now.month + 2;
        final endYear = now.month + 2 > 12 ? now.year + 1 : now.year;
        final plan = VisualCropPlan(
          id: 'crop_${now.millisecondsSinceEpoch}',
          name: 'Teeltplan 1',
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(endYear, endMonth + 1, 0),
          seasonLabel: VisualCropPlan.seasonForMonth(now.month),
          placements: placements,
        );
        plans = [plan];
        activeId = plan.id;
      }
    }

    if (plans.isEmpty) {
      activeId = null;
    } else if (activeId == null || !plans.any((p) => p.id == activeId)) {
      activeId = plans.first.id;
    }

    return VisualGardenBed(
      id: id,
      name: name ?? this.name,
      verticesCm: verticesCm ?? this.verticesCm,
      cropPlans: plans,
      activeCropPlanId: activeId,
      wallHeightCm: wallHeightCm ?? this.wallHeightCm,
      borderColorValue: borderColorValue ?? this.borderColorValue,
      fillColorValue: fillColorValue ?? this.fillColorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'wallHeightCm': wallHeightCm,
        'borderColor': borderColorValue,
        'fillColor': fillColorValue,
        'activeCropPlanId': activeCropPlanId,
        'verticesCm': [
          for (final v in verticesCm) {'x': v.dx, 'y': v.dy},
        ],
        'cropPlans': cropPlans.map((p) => p.toJson()).toList(),
        // Legacy-veld voor oudere readers (actieve placements).
        'placements': placements.map((p) => p.toJson()).toList(),
      };

  factory VisualGardenBed.fromJson(Map<String, dynamic> json) {
    final border = (json['borderColor'] as num?)?.toInt() ?? 0xFFB08968;
    final fill = (json['fillColor'] as num?)?.toInt() ?? 0xFF4A3728;
    final wall = (json['wallHeightCm'] as num?)?.toDouble() ??
        (json['heightCm'] as num?)?.toDouble() ??
        20;

    List<Offset> verts;
    if (json['verticesCm'] is List && (json['verticesCm'] as List).isNotEmpty) {
      verts = (json['verticesCm'] as List)
          .map((e) {
            final m = e as Map<String, dynamic>;
            return Offset(
              (m['x'] as num).toDouble(),
              (m['y'] as num).toDouble(),
            );
          })
          .toList();
    } else {
      final w = (json['widthCm'] as num?)?.toDouble() ?? 100;
      final h = (json['heightCm'] as num?)?.toDouble() ?? 100;
      final shape = json['shape'] as String? ?? 'rectangle';
      if (shape == 'circle' || shape == 'oval') {
        verts = [
          for (var i = 0; i < 12; i++)
            Offset(
              w / 2 + (w / 2) * math.cos(i * math.pi * 2 / 12),
              h / 2 + (h / 2) * math.sin(i * math.pi * 2 / 12),
            ),
        ];
      } else {
        verts = [
          Offset.zero,
          Offset(w, 0),
          Offset(w, h),
          Offset(0, h),
        ];
      }
    }

    final legacyPlacements = (json['placements'] as List<dynamic>? ?? [])
        .map((e) => PlantPlacement.fromJson(e as Map<String, dynamic>))
        .toList();

    List<VisualCropPlan> plans;
    if (json['cropPlans'] is List && (json['cropPlans'] as List).isNotEmpty) {
      plans = (json['cropPlans'] as List)
          .map((e) => VisualCropPlan.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      // Migratie: oude bak zonder teeltplannen → één plan.
      final now = DateTime.now();
      plans = [
        VisualCropPlan(
          id: 'crop_migrated_${json['id'] ?? now.millisecondsSinceEpoch}',
          name: 'Teeltplan 1',
          startDate: DateTime(now.year, now.month, 1),
          endDate: DateTime(now.year, (now.month + 3 - 1) % 12 + 1, 28),
          seasonLabel: VisualCropPlan.seasonForMonth(now.month),
          placements: legacyPlacements,
        ),
      ];
    }

    final activeId = json['activeCropPlanId'] as String? ??
        (plans.isEmpty ? null : plans.first.id);

    return VisualGardenBed(
      id: json['id'] as String,
      name: json['name'] as String? ?? 'Plantenbak',
      verticesCm: verts,
      wallHeightCm: wall,
      borderColorValue: border,
      fillColorValue: fill,
      cropPlans: plans,
      activeCropPlanId: activeId,
    );
  }

  /// Lege bak-shell met zelfde vorm (voor nieuw teeltplan).
  static VisualGardenBed emptyShell({
    required String id,
    required String name,
    required List<Offset> verticesCm,
    double wallHeightCm = 20,
    int borderColorValue = 0xFFB08968,
    int fillColorValue = 0xFF4A3728,
    required VisualCropPlan firstPlan,
  }) {
    return VisualGardenBed(
      id: id,
      name: name,
      verticesCm: verticesCm,
      wallHeightCm: wallHeightCm,
      borderColorValue: borderColorValue,
      fillColorValue: fillColorValue,
      cropPlans: [firstPlan],
      activeCropPlanId: firstPlan.id,
    );
  }
}

/// Geplaatste plant in echte bak-coördinaten (cm, centrum van plantzone).
class PlantPlacement {
  const PlantPlacement({
    required this.id,
    required this.plantId,
    required this.xCm,
    required this.yCm,
    required this.spacingCm,
    this.createdAt,
  });

  final String id;
  final String plantId;

  /// Centrum X in cm vanaf linkerbovenhoek van de bak-bounding box.
  final double xCm;

  /// Centrum Y in cm vanaf linkerbovenhoek van de bak-bounding box.
  final double yCm;

  final double spacingCm;
  final DateTime? createdAt;

  PlantPlacement copyWith({
    double? xCm,
    double? yCm,
    double? spacingCm,
  }) {
    return PlantPlacement(
      id: id,
      plantId: plantId,
      xCm: xCm ?? this.xCm,
      yCm: yCm ?? this.yCm,
      spacingCm: spacingCm ?? this.spacingCm,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'plantId': plantId,
        'xCm': xCm,
        'yCm': yCm,
        'spacingCm': spacingCm,
        'createdAt': (createdAt ?? DateTime.now()).toIso8601String(),
      };

  factory PlantPlacement.fromJson(Map<String, dynamic> json) {
    return PlantPlacement(
      id: json['id'] as String,
      plantId: json['plantId'] as String,
      xCm: (json['xCm'] as num).toDouble(),
      yCm: (json['yCm'] as num).toDouble(),
      spacingCm: (json['spacingCm'] as num?)?.toDouble() ?? 25,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
    );
  }
}
