/// Gedeelde detailblokken voor Plant Info-koppen (samenvatting → tik → detail).
class PlantGuideDetailBlock {
  const PlantGuideDetailBlock({
    required this.heading,
    required this.body,
  });

  final String heading;
  final String body;
}

List<PlantGuideDetailBlock> guideDetailBlocks({
  required String why,
  required String how,
  required String tip,
  String? extra,
  String? meaning,
}) {
  return [
    if (meaning != null && meaning.trim().isNotEmpty)
      PlantGuideDetailBlock(heading: 'Wat betekent dit?', body: meaning),
    PlantGuideDetailBlock(heading: 'Waarom dit advies?', body: why),
    PlantGuideDetailBlock(heading: 'Hoe doe je het?', body: how),
    PlantGuideDetailBlock(heading: 'Praktische tips', body: tip),
    if (extra != null && extra.trim().isNotEmpty)
      PlantGuideDetailBlock(heading: 'Extra info', body: extra),
  ];
}
