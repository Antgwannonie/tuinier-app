import '../models/vegetable.dart';
import 'home_plant_display_text.dart';
import 'moestuin_companion_info.dart';
import 'plant_search_filters.dart';
import 'planting_season_status.dart';

/// Eén regel in de korte plantsamenvatting.
class PlantQuickSummaryPoint {
  const PlantQuickSummaryPoint({
    required this.icon,
    required this.label,
    required this.value,
  });

  final String icon;
  final String label;
  final String value;
}

/// Belangrijkste info om snel te beslissen: wel of niet in de moestuin?
class PlantQuickSummary {
  const PlantQuickSummary({
    required this.headline,
    required this.points,
    this.benefitTags = const [],
    this.isCompanion = false,
    this.seasonEnded = false,
    this.tip,
  });

  final String headline;
  final List<PlantQuickSummaryPoint> points;
  final List<String> benefitTags;
  final bool isCompanion;
  final bool seasonEnded;
  final String? tip;
}

PlantQuickSummary buildPlantQuickSummary({
  required Vegetable vegetable,
  required PlantingSeasonAdvice seasonAdvice,
}) {
  final companion = moestuinCompanionInfoForVegetable(vegetable);
  final isCompanion = companion != null;

  final headline = isCompanion
      ? shortTextForHomeCard(companion.atAGlance, maxLen: 100)
      : _headlineFromSummary(vegetable.summary);

  final points = <PlantQuickSummaryPoint>[];

  final typeLabel = _typeLabel(vegetable);
  if (typeLabel.isNotEmpty) {
    points.add(PlantQuickSummaryPoint(
      icon: '🌱',
      label: 'Soort',
      value: typeLabel,
    ));
  }

  if (seasonAdvice.shortLabel.trim().isNotEmpty) {
    points.add(PlantQuickSummaryPoint(
      icon: seasonAdvice.isSeasonEnded ? '⏸' : '📅',
      label: 'Nu in seizoen',
      value: seasonAdvice.shortLabel.trim(),
    ));
  }

  if (isCompanion) {
    if (companion.goodNearLabels.isNotEmpty) {
      points.add(PlantQuickSummaryPoint(
        icon: '📍',
        label: 'Past goed bij',
        value: companion.goodNearLabels.join(' · '),
      ));
    }
    points.add(PlantQuickSummaryPoint(
      icon: '⏱',
      label: 'Wanneer',
      value: companion.whenToPlant,
    ));
  } else {
    final sow = _compact(_bestSowText(vegetable), maxLen: 80);
    if (sow.isNotEmpty) {
      points.add(PlantQuickSummaryPoint(
        icon: '🌿',
        label: 'Zaaien / planten',
        value: sow,
      ));
    }

    final harvest = _compact(vegetable.harvest, maxLen: 72);
    if (harvest.isNotEmpty) {
      points.add(PlantQuickSummaryPoint(
        icon: '🧺',
        label: 'Oogst',
        value: harvest,
      ));
    }
  }

  final sun = _compact(vegetable.sunRequirement, maxLen: 48);
  if (sun.isNotEmpty) {
    points.add(PlantQuickSummaryPoint(
      icon: '☀️',
      label: 'Standplaats',
      value: sun,
    ));
  }

  if (!isCompanion) {
    points.add(PlantQuickSummaryPoint(
      icon: '💧',
      label: 'Water',
      value: classifyWater(vegetable.water).label,
    ));

    final duration = vegetable.cropDuration?.trim();
    if (duration != null && duration.isNotEmpty) {
      points.add(PlantQuickSummaryPoint(
        icon: '⏳',
        label: 'Groeitijd',
        value: duration,
      ));
    }
  }

  return PlantQuickSummary(
    headline: headline,
    points: points.take(6).toList(),
    benefitTags: isCompanion
        ? companion.benefits.map((b) => '${b.emoji} ${b.label}').toList()
        : const [],
    isCompanion: isCompanion,
    seasonEnded: seasonAdvice.isSeasonEnded,
    tip: isCompanion ? companion.tip : null,
  );
}

String _typeLabel(Vegetable vegetable) {
  final kind = browseKindForPlant(vegetable.id);
  if (kind != PlantBrowseKind.all && kind != PlantBrowseKind.other) {
    return kind.label;
  }
  final cat = vegetable.growthCategory?.trim();
  if (cat != null && cat.isNotEmpty) return cat;
  return vegetable.family;
}

String _headlineFromSummary(String summary) {
  final t = summary.trim();
  if (t.isEmpty) return 'Bekijk de teeltinfo hieronder voor zaaien, oogst en verzorging.';
  final dot = t.indexOf('.');
  if (dot > 0 && dot < 140) {
    return t.substring(0, dot + 1);
  }
  return _compact(t, maxLen: 140);
}

String _bestSowText(Vegetable vegetable) {
  final outdoor = vegetable.sowingOutdoors.trim();
  final indoor = vegetable.sowingIndoors.trim();
  if (outdoor.isNotEmpty &&
      outdoor != 'Zie kalender in de app.' &&
      !outdoor.toLowerCase().contains('zie teelt')) {
    return outdoor;
  }
  if (indoor.isNotEmpty &&
      !indoor.toLowerCase().contains('niet nodig') &&
      !indoor.toLowerCase().contains('meestal niet')) {
    return indoor;
  }
  return outdoor.isNotEmpty ? outdoor : indoor;
}

String _compact(String text, {int maxLen = 72}) {
  var t = text.trim().replaceAll(RegExp(r'\s+'), ' ');
  if (t.isEmpty || t == '—' || t == '-') return '';
  if (t.length <= maxLen) return t;
  return '${t.substring(0, maxLen - 1).trim()}…';
}
