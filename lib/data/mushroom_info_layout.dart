/// Paddenstoel-specifieke info-tabs (los van planten-tabs).
enum MushroomInfoCategoryId {
  substraat,
  enten,
  kolonisatie,
  vruchtvorming,
  omgeving,
  water,
  groei,
  oogsten,
  flushes,
  bewaren,
  problemen,
  weetjes,
}

extension MushroomInfoCategoryIdMeta on MushroomInfoCategoryId {
  String get label => switch (this) {
        MushroomInfoCategoryId.substraat => 'Substraat',
        MushroomInfoCategoryId.enten => 'Enten',
        MushroomInfoCategoryId.kolonisatie => 'Kolonisatie',
        MushroomInfoCategoryId.vruchtvorming => 'Vruchtvorming',
        MushroomInfoCategoryId.omgeving => 'Omgeving',
        MushroomInfoCategoryId.water => 'Water',
        MushroomInfoCategoryId.groei => 'Groei',
        MushroomInfoCategoryId.oogsten => 'Oogsten',
        MushroomInfoCategoryId.flushes => 'Flushes',
        MushroomInfoCategoryId.bewaren => 'Bewaren',
        MushroomInfoCategoryId.problemen => 'Problemen',
        MushroomInfoCategoryId.weetjes => 'Weetjes',
      };

  String get emoji => switch (this) {
        MushroomInfoCategoryId.substraat => '🍄',
        MushroomInfoCategoryId.enten => '🧫',
        MushroomInfoCategoryId.kolonisatie => '🌱',
        MushroomInfoCategoryId.vruchtvorming => '🍄',
        MushroomInfoCategoryId.omgeving => '🌡️',
        MushroomInfoCategoryId.water => '💧',
        MushroomInfoCategoryId.groei => '📈',
        MushroomInfoCategoryId.oogsten => '🧺',
        MushroomInfoCategoryId.flushes => '🔄',
        MushroomInfoCategoryId.bewaren => '📦',
        MushroomInfoCategoryId.problemen => '⚠️',
        MushroomInfoCategoryId.weetjes => '💡',
      };
}

class MushroomInfoSection {
  const MushroomInfoSection({
    required this.title,
    required this.body,
    this.fullWidth,
    this.isWarning = false,
  });

  final String title;
  final String body;
  /// null = automatisch op basis van tekstlengte.
  final bool? fullWidth;
  final bool isWarning;

  bool get prefersFullWidth =>
      fullWidth ?? body.length > 140 || body.contains('\n');
}

class MushroomInfoGuide {
  const MushroomInfoGuide({required this.sections});

  final List<MushroomInfoSection> sections;

  bool get hasContent => sections.any((s) => s.body.trim().isNotEmpty);
}

class MushroomInfoCategoryContent {
  const MushroomInfoCategoryContent({
    required this.id,
    required this.guide,
  });

  final MushroomInfoCategoryId id;
  final MushroomInfoGuide guide;
}

List<MushroomInfoCategoryContent> allMushroomInfoCategories() {
  return MushroomInfoCategoryId.values
      .map(
        (id) => MushroomInfoCategoryContent(
          id: id,
          guide: const MushroomInfoGuide(sections: []),
        ),
      )
      .toList(growable: false);
}
