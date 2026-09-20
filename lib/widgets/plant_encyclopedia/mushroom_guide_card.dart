import 'package:flutter/material.dart';

import '../../data/mushroom_guide_card_data.dart';
import '../../data/plant_guide_detail.dart';
import 'plant_detail_widgets.dart';
import 'plant_guide_detail_screen.dart';

export '../../data/mushroom_guide_card_data.dart' show mushroomDetailBlocks;

/// Tikbare paddenstoel-kaart: korte samenvatting op de kaart, volledige tekst via Meer info.
Widget wrapMushroomGuideCard({
  required BuildContext context,
  required String title,
  required String summary,
  required List<PlantGuideDetailBlock> details,
  required Widget child,
}) {
  return PlantDetailCard(
    child: wrapGuideDetailCard(
      context: context,
      title: title,
      summary: summary,
      details: details,
      child: child,
    ),
  );
}

/// Wrapper met [MushroomGuideCardData] uit de gids-factory.
Widget mushroomGuideCard({
  required BuildContext context,
  required MushroomGuideCardData guide,
  required String title,
  required Widget Function(String summary) child,
}) {
  final summary = guide.cardSummary(title);
  return wrapMushroomGuideCard(
    context: context,
    title: title,
    summary: summary,
    details: guide.cardDetail(title),
    child: child(summary),
  );
}
