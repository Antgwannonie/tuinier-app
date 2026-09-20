import '../models/vegetable.dart';
import '../utils/plant_display_info.dart';
import 'crop_card_summaries.dart';
import 'plant_crop_profiles.dart';
import 'vegetable_overview_data.dart';

enum PlantWeetjesIllustration {
  origin,
  history,
  family,
  edibleParts,
  funFact,
  healthShield,
  healthMuscle,
  healthHeart,
  healthDrop,
  kitchenSalad,
  kitchenSoup,
  kitchenSmoothie,
  kitchenTea,
  varietyCherry,
  varietyPlum,
  varietyBeefsteak,
  varietyYellow,
  varietyBlack,
  wildlifeBee,
  wildlifeButterfly,
  wildlifeLadybug,
  wildlifeBumblebee,
  medalGold,
  medalSilver,
  medalBronze,
  appInsect,
  appDecor,
  appCosmetic,
  appTea,
  appDye,
}

class WeetjesIconItem {
  const WeetjesIconItem({
    required this.label,
    required this.illustration,
    this.detail,
  });

  final String label;
  final PlantWeetjesIllustration illustration;
  final String? detail;
}

class PlantWeetjesGuide {
  const PlantWeetjesGuide({
    required this.origin,
    required this.history,
    required this.nameMeaning,
    required this.familyMembers,
    required this.vruchtFamilieMembers,
    required this.vruchtFamilieLabel,
    required this.specialFeatures,
    required this.ediblePartsSummary,
    required this.ediblePartLabels,
    required this.healthBenefits,
    required this.kitchenUses,
    required this.popularVarieties,
    required this.wildlife,
    required this.worldProduction,
    required this.surprisingUses,
    required this.funFact,
    this.cardSummaries = const {},
  });

  final String origin;
  final String history;
  final String nameMeaning;
  final String familyMembers;
  final List<String> vruchtFamilieMembers;
  final String? vruchtFamilieLabel;
  final List<String> specialFeatures;
  final String ediblePartsSummary;
  final List<String> ediblePartLabels;
  final List<WeetjesIconItem> healthBenefits;
  final List<WeetjesIconItem> kitchenUses;
  final List<WeetjesIconItem> popularVarieties;
  final List<WeetjesIconItem> wildlife;
  final List<WeetjesIconItem> worldProduction;
  final List<WeetjesIconItem> surprisingUses;
  final String funFact;

  /// Korte kaartteksten per sectietitel (detail-tab Weetjes).
  final Map<String, String> cardSummaries;

  String cardSummary(String title, {String? fallback}) {
    final s = cardSummaries[title];
    if (s != null && s.trim().isNotEmpty) return s;
    return fallback ?? '';
  }

  bool get hasContent =>
      origin.trim().isNotEmpty ||
      history.trim().isNotEmpty ||
      funFact.trim().isNotEmpty;
}

PlantWeetjesGuide weetjesGuideForVegetable(Vegetable vegetable) {
  final built = _buildWeetjesGuide(vegetable);
  String sum(String title) =>
      cropCardSummaryFor(tab: 'weetjes', title: title, vegetable: vegetable);
  return PlantWeetjesGuide(
    origin: built.origin,
    history: built.history,
    nameMeaning: built.nameMeaning,
    familyMembers: built.familyMembers,
    vruchtFamilieMembers: built.vruchtFamilieMembers,
    vruchtFamilieLabel: built.vruchtFamilieLabel,
    specialFeatures: built.specialFeatures,
    ediblePartsSummary: built.ediblePartsSummary,
    ediblePartLabels: built.ediblePartLabels,
    healthBenefits: built.healthBenefits,
    kitchenUses: built.kitchenUses,
    popularVarieties: built.popularVarieties,
    wildlife: built.wildlife,
    worldProduction: built.worldProduction,
    surprisingUses: built.surprisingUses,
    funFact: built.funFact,
    cardSummaries: {
      'Oorsprong': sum('Oorsprong'),
      'Historie': sum('Historie'),
      'Naam': sum('Naam'),
      'Familie': sum('Familie'),
      'Plantenfamilie': sum('Plantenfamilie'),
      'Bijzonderheden': sum('Bijzonderheden'),
      'Eetbare delen': sum('Eetbare delen'),
      'Gezondheidsvoordelen': sum('Gezondheidsvoordelen'),
      'Gebruik in de keuken': sum('Gebruik in de keuken'),
      'Populaire rassen': sum('Populaire rassen'),
      'Nuttige dieren': sum('Nuttige dieren'),
      'Wereldproductie': sum('Wereldproductie'),
      'Verrassende toepassingen': sum('Verrassende toepassingen'),
      'Wist-je-dat': sum('Wist-je-dat'),
    },
  );
}

PlantWeetjesGuide _buildWeetjesGuide(Vegetable v) {
  final id = v.id.toLowerCase();
  final isTomato = id.contains('tomaat');
  final isCucumber = id.contains('komkommer');
  final p = cropProfileFor(v.id);
  final ov = vegetableOverviewFactsFor(v.id);

  final origin = p.origin.trim().isNotEmpty && !p.origin.contains('Wereldwijd gecultiveerd')
      ? p.origin
      : _originFor(v, isTomato: isTomato, isCucumber: isCucumber);
  final history = _historyFor(v, isTomato: isTomato);
  final nameMeaning = p.nameMeaning.trim().isNotEmpty
      ? '${p.nameMeaning}${v.nameLatin != null ? ' (${v.nameLatin})' : ''}'
      : _nameMeaningFor(v);
  final familyMembers = p.plantFamilyHint.trim().isNotEmpty
      ? '${p.plantFamilyHint}. ${_familyTextFor(v)}'
      : _familyTextFor(v);
  final specialFeatures = [
    ..._specialFeaturesFor(v),
    if (p.specialNotes.trim().isNotEmpty) p.specialNotes,
    if (p.note != null) p.note!,
  ];
  final edibleLabels = _edibleLabelsFor(v);
  final health = _healthBenefitsFor(v, isTomato: isTomato);
  final kitchen = _kitchenUsesFor(v, isTomato: isTomato);
  final varieties = _varietiesFor(v, isTomato: isTomato);
  final wildlife = _wildlifeFor(v);
  final world = _worldProductionFor(v, isTomato: isTomato);
  final surprising = _surprisingUsesFor(v, isTomato: isTomato);
  final funFact = (ov?.didYouKnow ?? p.funFact).trim().isNotEmpty
      ? (ov?.didYouKnow ?? p.funFact)
      : _funFactFor(v, isTomato: isTomato, isCucumber: isCucumber);

  final vruchtFamilieLabel = botanicalFamilyLabel(v.family);
  final vruchtFamilieMembers = botanicalFamilyMemberNames(v);

  return PlantWeetjesGuide(
    origin: origin,
    history: history,
    nameMeaning: nameMeaning,
    familyMembers: familyMembers,
    vruchtFamilieMembers: vruchtFamilieMembers,
    vruchtFamilieLabel: vruchtFamilieLabel,
    specialFeatures: specialFeatures,
    ediblePartsSummary: p.edibleParts.isNotEmpty
        ? '${p.edibleParts}. ${_edibleSummaryFor(v)}'
        : _edibleSummaryFor(v),
    ediblePartLabels: edibleLabels,
    healthBenefits: health,
    kitchenUses: kitchen,
    popularVarieties: varieties,
    wildlife: wildlife,
    worldProduction: world,
    surprisingUses: surprising,
    funFact: funFact,
  );
}

String _originFor(
  Vegetable v, {
  required bool isTomato,
  required bool isCucumber,
}) {
  if (isTomato) {
    return 'De tomaat komt oorspronkelijk uit Midden- en Zuid-Amerika, '
        'waar inheemse volkeren het gewas al duizenden jaren telden.';
  }
  if (isCucumber) {
    return 'Komkommer is een van de oudste tuingewassen en werd al in '
        'Azië geteeld voordat het Europa bereikte.';
  }
  return '${v.nameNl} heeft een lange teeltgeschiedenis in verschillende '
      'klimaatzones; in Nederland past het goed in het gematigde seizoen.';
}

String _historyFor(Vegetable v, {required bool isTomato}) {
  if (isTomato) {
    return 'In Europa werd de tomaat eerst als sierplant gezien. Pas in de '
        '18e en 19e eeuw werd hij algemeen gegeten en geteeld als voedselgewas.';
  }
  return 'Door de eeuwen heen verspreidde ${v.nameNl.toLowerCase()} zich via '
      'handel en tuinbouw naar tuinen over de hele wereld.';
}

String _nameMeaningFor(Vegetable v) {
  if (v.nameLatin != null && v.nameLatin!.trim().isNotEmpty) {
    return '${v.nameNl} heet wetenschappelijk ${v.nameLatin}. '
        'De naam verwijst vaak naar vorm, kleur of herkomst van het gewas.';
  }
  return 'De Nederlandse naam ${v.nameNl} wordt in tuinboeken en op zaden '
      'meestal hetzelfde geschreven als in de volkstaal.';
}

String _familyTextFor(Vegetable v) {
  final fam = v.family.trim();
  if (fam.isEmpty) {
    return 'Verwant aan andere veelgekozen moestuinplanten in dezelfde '
        'plantenfamilie.';
  }
  return 'Hoort bij de familie $fam. Verwanten delen vaak dezelfde '
      'voedingsbehoefte en wisselteeltregels in de moestuin.';
}

List<String> _specialFeaturesFor(Vegetable v) {
  final items = <String>[
    if (v.growthCategory != null && v.growthCategory!.trim().isNotEmpty)
      v.growthCategory!,
    if (v.cropDuration != null && v.cropDuration!.trim().isNotEmpty)
      'Oogstperiode: ${v.cropDuration}',
    if (v.sunRequirement.trim().isNotEmpty) v.sunRequirement,
    if (v.water.trim().isNotEmpty) 'Water: ${v.water}',
  ];
  if (items.length < 4) {
    items.addAll([
      'Geschikt voor de Nederlandse moestuin',
      'Populair bij beginnende én ervaren tuiniers',
      'Veelzijdig in de keuken',
      'Goed te combineren met andere groenten',
    ].take(4 - items.length));
  }
  return items.take(4).toList();
}

String _edibleSummaryFor(Vegetable v) {
  final key = cropProfileKeyFor(v.id);
  switch (key) {
    case CropProfileKey.tomaat:
    case CropProfileKey.paprika:
    case CropProfileKey.aubergine:
    case CropProfileKey.komkommer:
    case CropProfileKey.courgette:
    case CropProfileKey.pompoen:
    case CropProfileKey.meloen:
    case CropProfileKey.okra:
      return 'De vruchten zijn het belangrijkste oogstdeel van ${v.nameNl.toLowerCase()}.';
    case CropProfileKey.sla:
    case CropProfileKey.spinazie:
      return 'Oogst de buitenste bladeren en laat het hart doorgroeien.';
    case CropProfileKey.wortel:
    case CropProfileKey.radijs:
    case CropProfileKey.biet:
      return 'De wortel is het eetbare hoofddeel; het blad is ook bruikbaar.';
    case CropProfileKey.kool:
      return 'Blad of bloemhoofd vormt de oogst; buitenblad is vaak ook eetbaar.';
    case CropProfileKey.ui:
    case CropProfileKey.prei:
    case CropProfileKey.knoflook:
      return 'De bol of schacht is het eetbare deel; het groen is ook bruikbaar.';
    case CropProfileKey.boon:
    case CropProfileKey.erwt:
      return 'Oogst peulen jong en mals; gedroogde zaden zijn lang houdbaar.';
    case CropProfileKey.kruidZacht:
      return 'Pluk bladeren en bloemtoppen voor de meeste smaak.';
    case CropProfileKey.aardappel:
    case CropProfileKey.zoeteAardappel:
      return 'Oogst de knollen; het bovengrondse loof is niet eetbaar.';
    case CropProfileKey.aardbei:
    case CropProfileKey.fruitZaad:
      return 'Vruchten zijn het hoofddoel; sommige bladeren zijn geschikt voor thee.';
    default:
      return 'Oogst wat eetbaar is en laat de rest groeien voor een gezonde plant.';
  }
}

List<String> _edibleLabelsFor(Vegetable v) {
  final key = cropProfileKeyFor(v.id);
  switch (key) {
    case CropProfileKey.tomaat:
    case CropProfileKey.paprika:
    case CropProfileKey.aubergine:
    case CropProfileKey.komkommer:
    case CropProfileKey.courgette:
    case CropProfileKey.pompoen:
    case CropProfileKey.meloen:
    case CropProfileKey.okra:
      return const ['Vrucht', 'Bloem', 'Blad', 'Zaad'];
    case CropProfileKey.sla:
    case CropProfileKey.spinazie:
      return const ['Blad', 'Stengel'];
    case CropProfileKey.wortel:
    case CropProfileKey.radijs:
    case CropProfileKey.biet:
      return const ['Wortel', 'Blad'];
    case CropProfileKey.kool:
      return const ['Blad', 'Bloem', 'Stengel'];
    case CropProfileKey.ui:
    case CropProfileKey.prei:
    case CropProfileKey.knoflook:
      return const ['Bol', 'Blad', 'Stengel'];
    case CropProfileKey.boon:
    case CropProfileKey.erwt:
      return const ['Peul', 'Zaad', 'Blad'];
    case CropProfileKey.kruidZacht:
      return const ['Blad', 'Bloem', 'Stengel'];
    case CropProfileKey.aardappel:
    case CropProfileKey.zoeteAardappel:
      return const ['Knol'];
    case CropProfileKey.aardbei:
      return const ['Vrucht', 'Blad'];
    case CropProfileKey.fruitZaad:
      return const ['Vrucht', 'Blad'];
    case CropProfileKey.mais:
      return const ['Kolf', 'Zaad'];
    case CropProfileKey.gember:
      return const ['Wortelstok'];
    case CropProfileKey.tauge:
      return const ['Kiem', 'Zaad'];
    case CropProfileKey.meerjarig:
      return const ['Stengel', 'Blad', 'Wortel'];
    case CropProfileKey.algemeen:
      return const ['Blad', 'Stengel', 'Wortel'];
  }
}

List<WeetjesIconItem> _healthBenefitsFor(Vegetable v, {required bool isTomato}) {
  if (isTomato) {
    return const [
      WeetjesIconItem(
        label: 'Immuunsysteem',
        illustration: PlantWeetjesIllustration.healthShield,
        detail: 'Rijk aan vitamine C en antioxidanten.',
      ),
      WeetjesIconItem(
        label: 'Spieren',
        illustration: PlantWeetjesIllustration.healthMuscle,
        detail: 'Bevat kalium en B-vitamines.',
      ),
      WeetjesIconItem(
        label: 'Hart',
        illustration: PlantWeetjesIllustration.healthHeart,
        detail: 'Lycopeen uit rijpe vruchten.',
      ),
      WeetjesIconItem(
        label: 'Hydratatie',
        illustration: PlantWeetjesIllustration.healthDrop,
        detail: 'Hoog watergehalte in de vrucht.',
      ),
    ];
  }
  final p = cropProfileFor(v.id);
  final healthHint = p.healthBenefits.trim();
  return [
    WeetjesIconItem(
      label: 'Vitamines',
      illustration: PlantWeetjesIllustration.healthShield,
      detail: healthHint.isNotEmpty ? healthHint : 'Verse oogst uit eigen tuin behoudt meer vitamines.',
    ),
    WeetjesIconItem(
      label: 'Energie',
      illustration: PlantWeetjesIllustration.healthMuscle,
      detail: 'Licht verteerbaar en voedzaam.',
    ),
    WeetjesIconItem(
      label: 'Hart',
      illustration: PlantWeetjesIllustration.healthHeart,
      detail: 'Onderdeel van een gevarieerd plantaardig dieet.',
    ),
    WeetjesIconItem(
      label: 'Hydratatie',
      illustration: PlantWeetjesIllustration.healthDrop,
      detail: 'Vers geoogst bevat extra vocht en mineralen.',
    ),
  ];
}

List<WeetjesIconItem> _kitchenUsesFor(Vegetable v, {required bool isTomato}) {
  if (isTomato) {
    return const [
      WeetjesIconItem(
        label: 'Salade',
        illustration: PlantWeetjesIllustration.kitchenSalad,
      ),
      WeetjesIconItem(
        label: 'Soep',
        illustration: PlantWeetjesIllustration.kitchenSoup,
      ),
      WeetjesIconItem(
        label: 'Smoothie',
        illustration: PlantWeetjesIllustration.kitchenSmoothie,
      ),
      WeetjesIconItem(
        label: 'Thee',
        illustration: PlantWeetjesIllustration.kitchenTea,
      ),
    ];
  }
  return [
    WeetjesIconItem(
      label: 'Rauw',
      illustration: PlantWeetjesIllustration.kitchenSalad,
    ),
    WeetjesIconItem(
      label: 'Gekookt',
      illustration: PlantWeetjesIllustration.kitchenSoup,
    ),
    WeetjesIconItem(
      label: 'Smoothie',
      illustration: PlantWeetjesIllustration.kitchenSmoothie,
    ),
    WeetjesIconItem(
      label: 'Thee',
      illustration: PlantWeetjesIllustration.kitchenTea,
    ),
  ];
}

List<WeetjesIconItem> _varietiesFor(Vegetable v, {required bool isTomato}) {
  if (isTomato) {
    return const [
      WeetjesIconItem(
        label: 'Cherry',
        illustration: PlantWeetjesIllustration.varietyCherry,
      ),
      WeetjesIconItem(
        label: 'Pruim',
        illustration: PlantWeetjesIllustration.varietyPlum,
      ),
      WeetjesIconItem(
        label: 'Vleestomaat',
        illustration: PlantWeetjesIllustration.varietyBeefsteak,
      ),
      WeetjesIconItem(
        label: 'Geel',
        illustration: PlantWeetjesIllustration.varietyYellow,
      ),
      WeetjesIconItem(
        label: 'Zwart',
        illustration: PlantWeetjesIllustration.varietyBlack,
      ),
    ];
  }
  return [
    WeetjesIconItem(
      label: 'Vroeg',
      illustration: PlantWeetjesIllustration.varietyCherry,
    ),
    WeetjesIconItem(
      label: 'Maincrop',
      illustration: PlantWeetjesIllustration.varietyPlum,
    ),
    WeetjesIconItem(
      label: 'Grootvrucht',
      illustration: PlantWeetjesIllustration.varietyBeefsteak,
    ),
    WeetjesIconItem(
      label: 'Geel',
      illustration: PlantWeetjesIllustration.varietyYellow,
    ),
    WeetjesIconItem(
      label: 'Special',
      illustration: PlantWeetjesIllustration.varietyBlack,
    ),
  ];
}

List<WeetjesIconItem> _wildlifeFor(Vegetable v) {
  return const [
    WeetjesIconItem(
      label: 'Bijen',
      illustration: PlantWeetjesIllustration.wildlifeBee,
      detail: 'Bestuiven bloemen en verhogen de oogst.',
    ),
    WeetjesIconItem(
      label: 'Vlinders',
      illustration: PlantWeetjesIllustration.wildlifeButterfly,
      detail: 'Signaleren biodiversiteit en bezoeken bloeiende randen.',
    ),
    WeetjesIconItem(
      label: 'Lieveheersbeestjes',
      illustration: PlantWeetjesIllustration.wildlifeLadybug,
      detail: 'Natuurlijke plaagbestrijders tegen bladluis.',
    ),
    WeetjesIconItem(
      label: 'Hommels',
      illustration: PlantWeetjesIllustration.wildlifeBumblebee,
      detail: 'Sterke bestuivers, ook bij koel NL-weer.',
    ),
  ];
}

List<WeetjesIconItem> _worldProductionFor(
  Vegetable v, {
  required bool isTomato,
}) {
  if (isTomato) {
    return const [
      WeetjesIconItem(
        label: 'China',
        illustration: PlantWeetjesIllustration.medalGold,
        detail: 'Grootste tomatenteelt ter wereld.',
      ),
      WeetjesIconItem(
        label: 'India',
        illustration: PlantWeetjesIllustration.medalSilver,
        detail: 'Belangrijke producent voor verse en verwerkte tomaat.',
      ),
      WeetjesIconItem(
        label: 'Turkije',
        illustration: PlantWeetjesIllustration.medalBronze,
        detail: 'Grote teelt voor export en lokale markt.',
      ),
    ];
  }
  return const [
    WeetjesIconItem(
      label: 'Wereld',
      illustration: PlantWeetjesIllustration.medalGold,
      detail: 'Wereldwijd geteeld in passende klimaten.',
    ),
    WeetjesIconItem(
      label: 'Europa',
      illustration: PlantWeetjesIllustration.medalSilver,
      detail: 'Belangrijke regio voor verse groente en kasproductie.',
    ),
    WeetjesIconItem(
      label: 'Nederland',
      illustration: PlantWeetjesIllustration.medalBronze,
      detail: 'Moestuin, bak en (voor warmteminners) kas of tunnel.',
    ),
  ];
}

List<WeetjesIconItem> _surprisingUsesFor(
  Vegetable v, {
  required bool isTomato,
}) {
  if (isTomato) {
    return const [
      WeetjesIconItem(
        label: 'Tegen insecten',
        illustration: PlantWeetjesIllustration.appInsect,
      ),
      WeetjesIconItem(
        label: 'Decoratie',
        illustration: PlantWeetjesIllustration.appDecor,
      ),
      WeetjesIconItem(
        label: 'Cosmetica',
        illustration: PlantWeetjesIllustration.appCosmetic,
      ),
      WeetjesIconItem(
        label: 'Thee',
        illustration: PlantWeetjesIllustration.appTea,
      ),
      WeetjesIconItem(
        label: 'Natuurlijke kleurstof',
        illustration: PlantWeetjesIllustration.appDye,
      ),
    ];
  }
  return const [
    WeetjesIconItem(
      label: 'Compost',
      illustration: PlantWeetjesIllustration.appInsect,
    ),
    WeetjesIconItem(
      label: 'Decoratie',
      illustration: PlantWeetjesIllustration.appDecor,
    ),
    WeetjesIconItem(
      label: 'Cosmetica',
      illustration: PlantWeetjesIllustration.appCosmetic,
    ),
    WeetjesIconItem(
      label: 'Thee',
      illustration: PlantWeetjesIllustration.appTea,
    ),
    WeetjesIconItem(
      label: 'Kleurstof',
      illustration: PlantWeetjesIllustration.appDye,
    ),
  ];
}

String _funFactFor(
  Vegetable v, {
  required bool isTomato,
  required bool isCucumber,
}) {
  if (v.summary.trim().isNotEmpty) {
    return v.summary;
  }
  if (isTomato) {
    return 'Wist je dat de tomaat botanisch een vrucht is, maar in de keuken '
        'als groente wordt gebruikt?';
  }
  if (isCucumber) {
    return 'Wist je dat komkommer voor meer dan 95% uit water bestaat?';
  }
  return 'Wist je dat verse ${v.nameNl.toLowerCase()} uit eigen tuin vaak '
      'meer smaak heeft dan winkelware?';
}
