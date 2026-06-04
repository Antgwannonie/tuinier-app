import '../models/vegetable.dart';

/// Compacte helper voor atlas-groenten (zelfde stijl als bestaande data).
Vegetable nlPlant({
  required String id,
  required String nameNl,
  String? nameLatin,
  required String family,
  required String growthCategory,
  required String summary,
  String sowingIndoors = 'Kan binnen of in kas.',
  String? sowingOutdoors,
  String transplant = 'Meestal niet nodig of zie teeltinfo.',
  required String harvest,
  int spacingCm = 30,
  int rowSpacingCm = 40,
  String sunRequirement = 'Volle zon.',
  String water = 'Gelijkmatig vocht; niet lang uitdrogen.',
  String soilAndFood = 'Voedselrijke, goed doorlatende grond.',
  String care = 'Regelmatig controleren op plagen en voeding.',
  String harvestTips = 'Oogsten op het juiste moment voor beste smaak.',
  String commonIssues = 'Wisseltelte en goede drainage helpen.',
  List<String>? keywords,
  String? cropDuration,
}) {
  return Vegetable(
    id: id,
    nameNl: nameNl,
    nameLatin: nameLatin,
    family: family,
    growthCategory: growthCategory,
    summary: summary,
    sowingIndoors: sowingIndoors,
    sowingOutdoors: sowingOutdoors ?? 'Zie kalender in de app.',
    transplant: transplant,
    harvest: harvest,
    spacingCm: spacingCm,
    rowSpacingCm: rowSpacingCm,
    sunRequirement: sunRequirement,
    water: water,
    soilAndFood: soilAndFood,
    care: care,
    harvestTips: harvestTips,
    commonIssues: commonIssues,
    keywords: keywords ??
        [
          id.replaceAll('_', ' '),
          nameNl.toLowerCase(),
        ],
    cropDuration: cropDuration,
  );
}

/// Snelle atlas-entry voor bulklijsten (NL moestuin).
Vegetable nlPlantBulk(
  String id,
  String nameNl, {
  String? nameLatin,
  String family = 'Groentegewas',
  String growthCategory = 'Middelmatige groeiers',
  String? summary,
  String harvest = 'Juni–oktober; zie teeltinfo.',
  String? sowingOutdoors,
  List<String>? keywords,
  int spacingCm = 30,
  int rowSpacingCm = 40,
}) {
  return nlPlant(
    id: id,
    nameNl: nameNl,
    nameLatin: nameLatin,
    family: family,
    growthCategory: growthCategory,
    summary: summary ??
        'Veel geteeld in Nederlandse moestuinen; kies ras passend bij seizoen.',
    sowingOutdoors: sowingOutdoors,
    harvest: harvest,
    spacingCm: spacingCm,
    rowSpacingCm: rowSpacingCm,
    keywords: keywords,
  );
}
