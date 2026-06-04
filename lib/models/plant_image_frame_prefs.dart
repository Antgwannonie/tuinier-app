import 'package:flutter/painting.dart';

/// Hoe een plantfoto in de Zoeken-kaart / detail-balk wordt getoond.
enum PlantImageBoxFit { contain, cover, fill }

class PlantImageFramePrefs {
  const PlantImageFramePrefs({
    this.scale = 1.0,
    this.alignX = 0.0,
    this.alignY = 0.0,
    this.boxFit = PlantImageBoxFit.contain,
    this.backgroundArgb = 0xFF8EC8E8,
  });

  final double scale;
  final double alignX;
  final double alignY;
  final PlantImageBoxFit boxFit;
  final int backgroundArgb;

  static const defaults = PlantImageFramePrefs();

  PlantImageFramePrefs copyWith({
    double? scale,
    double? alignX,
    double? alignY,
    PlantImageBoxFit? boxFit,
    int? backgroundArgb,
  }) {
    return PlantImageFramePrefs(
      scale: scale ?? this.scale,
      alignX: alignX ?? this.alignX,
      alignY: alignY ?? this.alignY,
      boxFit: boxFit ?? this.boxFit,
      backgroundArgb: backgroundArgb ?? this.backgroundArgb,
    );
  }

  bool isNearDefaults({double epsilon = 0.001}) {
    return (scale - defaults.scale).abs() < epsilon &&
        alignX.abs() < epsilon &&
        alignY.abs() < epsilon &&
        boxFit == defaults.boxFit &&
        backgroundArgb == defaults.backgroundArgb;
  }

  Map<String, dynamic> toJson() => {
        'scale': scale,
        'alignX': alignX,
        'alignY': alignY,
        'fit': boxFit.name,
        'bg': backgroundArgb,
      };

  factory PlantImageFramePrefs.fromJson(Map<String, dynamic> json) {
    final fitName = json['fit'] as String? ?? 'contain';
    return PlantImageFramePrefs(
      scale: (json['scale'] as num?)?.toDouble() ?? 1.0,
      alignX: (json['alignX'] as num?)?.toDouble() ?? 0.0,
      alignY: (json['alignY'] as num?)?.toDouble() ?? 0.0,
      boxFit: PlantImageBoxFit.values.firstWhere(
        (f) => f.name == fitName,
        orElse: () => PlantImageBoxFit.contain,
      ),
      backgroundArgb: json['bg'] as int? ?? 0xFF8EC8E8,
    );
  }
}

BoxFit plantImageBoxFitToFlutter(PlantImageBoxFit fit) {
  switch (fit) {
    case PlantImageBoxFit.contain:
      return BoxFit.contain;
    case PlantImageBoxFit.cover:
      return BoxFit.cover;
    case PlantImageBoxFit.fill:
      return BoxFit.fill;
  }
}
