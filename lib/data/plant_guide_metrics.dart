import '../models/vegetable.dart';
import 'planting_season_status.dart';

bool _hasGuideText(String? value) {
  if (value == null) return false;
  final t = value.trim();
  return t.isNotEmpty && t != '—' && t != '-';
}

/// Aantal teelt-onderwerpen voor badge op plantengids-kaarten.
int plantGuideTopicCount(Vegetable vegetable) {
  var count = 0;
  for (final field in [
    vegetable.sowingIndoors,
    vegetable.sowingOutdoors,
    vegetable.transplant,
    vegetable.harvest,
    vegetable.cropDuration,
    vegetable.sunRequirement,
    vegetable.water,
    vegetable.soilAndFood,
    vegetable.care,
    vegetable.harvestTips,
    vegetable.commonIssues,
    vegetable.summary,
  ]) {
    if (_hasGuideText(field)) count++;
  }
  return count.clamp(3, 12);
}

String plantGuideTopicBadge(Vegetable vegetable) {
  final n = plantGuideTopicCount(vegetable);
  return '$n onderwerpen';
}

/// Seizoenslabel voor hoek-badge (bijv. «Nu zaaien»).
String? plantGuideSeasonBadge(Vegetable vegetable) {
  final season = plantingSeasonStatusFor(
    vegetable.id,
    vegetable: vegetable,
  );
  return switch (season.phase) {
    PlantingSeasonPhase.activeNow => 'Nu zaaien',
    PlantingSeasonPhase.daysLeft when season.days != null =>
      'Nog ${season.days} d',
    PlantingSeasonPhase.startsSoon when season.days != null =>
      'Over ${season.days} d',
    PlantingSeasonPhase.seasonEnded => 'Seizoen voorbij',
    PlantingSeasonPhase.noCalendar => null,
    _ => season.label.trim().isNotEmpty ? season.label : null,
  };
}
