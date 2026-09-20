import '../models/vegetable.dart';
import 'mushroom_card_summaries.dart';
import 'plant_guide_detail.dart';

/// Gedeelde kaart-data voor paddenstoel-gidsen (samenvatting + Meer info).
mixin MushroomGuideCardData {
  Map<String, String> get cardSummaries;
  Map<String, List<PlantGuideDetailBlock>> get cardDetails;

  String cardSummary(String title, {String? fallback}) {
    final s = cardSummaries[title];
    if (s != null && s.trim().isNotEmpty) return s;
    return fallback ?? '';
  }

  List<PlantGuideDetailBlock> cardDetail(String title) =>
      cardDetails[title] ?? const [];
}

List<PlantGuideDetailBlock> mushroomDetailBlocks({
  required String fullBody,
  String? tip,
  String? extra,
}) =>
    guideDetailBlocks(
      why: fullBody,
      how: tip ?? 'Volg de stappen en controleer dagelijks.',
      tip: tip ?? 'Pas aan op temperatuur, vocht en ventilatie.',
      extra: extra,
    );

Map<String, String> mushroomCardSummaries({
  required String tab,
  required Vegetable vegetable,
  required Iterable<String> titles,
}) =>
    {
      for (final t in titles)
        t: mushroomCardSummaryFor(tab: tab, title: t, vegetable: vegetable),
    };

Map<String, List<PlantGuideDetailBlock>> mushroomCardDetailsFromBodies(
  Map<String, String> bodies, {
  String? tip,
}) =>
    {
      for (final e in bodies.entries)
        e.key: mushroomDetailBlocks(fullBody: e.value, tip: tip),
    };
