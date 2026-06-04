import '../models/garden_plant_profile.dart';
import '../models/plant_ai_analysis.dart';
import '../models/vegetable.dart';
import 'moestuin_companion_info.dart';
import 'vegetable_groups.dart';

/// Moestuinbloemen en nuttige randplanten (companion-groep).
bool isMoestuinBloomCrop(Vegetable vegetable) {
  if (vegetable.family.contains('Moestuin-bloemen')) return true;
  for (final group in kVegetableGroups) {
    if (group.id == 'moestuin_bloemen') {
      return group.vegetableIds.contains(vegetable.id);
    }
  }
  return false;
}

/// @deprecated Gebruik [isMoestuinBloomCrop] of [isOrnamentalOnlyMoestuinCrop].
bool isOrnamentalMoestuinCrop(Vegetable vegetable) => isMoestuinBloomCrop(vegetable);

/// Alleen bloei/insecten — niet bedoeld om te eten (cosmos, facelia, …).
bool isOrnamentalOnlyMoestuinCrop(Vegetable vegetable) =>
    isMoestuinBloomCrop(vegetable) && !isEdibleMoestuinBloomCrop(vegetable);

/// Bloemen of blad die je ook kunt eten (goudsbloem, oost-indische kers, kruiden in bloei, …).
bool isEdibleMoestuinBloomCrop(Vegetable vegetable) {
  if (!isMoestuinBloomCrop(vegetable)) return false;

  if (_kEdibleMoestuinBloomIds.contains(vegetable.id)) return true;

  final info = moestuinCompanionInfoForVegetable(vegetable);
  if (info != null) {
    final kind = info.plantKindLabel.toLowerCase();
    if (kind.contains('eetbaar') || kind.contains('bloem & blad')) {
      return true;
    }
    if (kind.contains('kruid') && !kind.contains('ui in bloei')) {
      return true;
    }
  }

  final text =
      '${vegetable.summary} ${vegetable.harvest} ${vegetable.harvestTips}'
          .toLowerCase();
  if (text.contains('eetbaar') ||
      text.contains('eetbare bloem') ||
      text.contains('mee oogsten')) {
    return true;
  }

  return false;
}

const Set<String> _kEdibleMoestuinBloomIds = {
  'goudsbloem',
  'calendula_officinalis',
  'oostindische_kers',
  'komkommerkruid',
  'monarda',
  'dille_bloei',
  'koriander_bloei',
  'basilicum_bloei',
  'munt_bloei',
  'salie_bloei',
  'tijm_bloei',
  'lavendel_bloei',
  'wilde_marjolein',
  'hysop',
};

/// Groente/kruid met klassieke oogst (geen moestuinbloem-logica).
bool isFoodHarvestableCrop(Vegetable vegetable) => !isMoestuinBloomCrop(vegetable);

/// UI-teksten voor afronden seizoen vs oogsten.
class CropHarvestUiCopy {
  const CropHarvestUiCopy({
    required this.sectionTitle,
    required this.sectionHintFallback,
    required this.buttonLabel,
    required this.dialogTitle,
    required this.dialogBody,
    required this.infoTitle,
    required this.infoBody,
    required this.snackBarDone,
  });

  final String sectionTitle;
  final String sectionHintFallback;
  final String buttonLabel;
  final String dialogTitle;
  final String dialogBody;
  final String infoTitle;
  final String infoBody;
  final String snackBarDone;
}

/// Twee keuzes bij eetbare moestuinbloemen in bloei.
class EdibleBloomHarvestUi {
  const EdibleBloomHarvestUi({
    required this.sectionTitle,
    required this.sectionHintFallback,
    required this.edibleChoiceNote,
    required this.foodHarvest,
    required this.seasonFinish,
  });

  final String sectionTitle;
  final String sectionHintFallback;

  /// Korte regel onder de titel: je mag eten óf laten uitbloeien.
  final String edibleChoiceNote;
  final CropHarvestUiCopy foodHarvest;
  final CropHarvestUiCopy seasonFinish;
}

String edibleBloomEatHint(Vegetable vegetable) {
  final info = moestuinCompanionInfoForVegetable(vegetable);
  if (info != null) {
    final kind = info.plantKindLabel.toLowerCase();
    if (kind.contains('eetbaar')) {
      return info.atAGlance;
    }
    if (kind.contains('kruid') || kind.contains('bloem & blad')) {
      return '${info.plantKindLabel}: knip wat je nodig hebt — '
          'of laat bloeien voor bijen en nuttige insecten.';
    }
  }
  return 'Bloemen of blad van ${vegetable.nameNl} kun je vaak eten; '
      'je hoeft de plant niet meteen uit je moestuin te halen.';
}

CropHarvestUiCopy harvestUiCopyFor(
  Vegetable vegetable, {
  required String plantNameNl,
  bool bloomConfirmed = false,
  bool forSeasonFinish = false,
}) {
  if (isEdibleMoestuinBloomCrop(vegetable) && forSeasonFinish) {
    return _seasonFinishCopyForEdibleBloom(vegetable, plantNameNl: plantNameNl);
  }
  if (isEdibleMoestuinBloomCrop(vegetable) && !forSeasonFinish) {
    return _foodHarvestCopyForEdibleBloom(vegetable, plantNameNl: plantNameNl);
  }
  if (isOrnamentalOnlyMoestuinCrop(vegetable)) {
    return _ornamentalOnlySeasonFinishCopy(
      plantNameNl: plantNameNl,
      bloomConfirmed: bloomConfirmed,
    );
  }
  return _standardFoodHarvestCopy(plantNameNl: plantNameNl);
}

EdibleBloomHarvestUi? edibleBloomHarvestUiFor(
  Vegetable vegetable, {
  required String plantNameNl,
}) {
  if (!isEdibleMoestuinBloomCrop(vegetable)) return null;
  return EdibleBloomHarvestUi(
    sectionTitle: 'In bloei — eetbaar of laten staan',
    sectionHintFallback:
        'Je $plantNameNl helpt insecten én kun je (deels) eten.',
    edibleChoiceNote:
        'Kies «Geoogst» als je bloemen of blad geplukt hebt en klaar bent. '
        'Kies «Seizoen afronden» om de plant uit je moestuin te halen zonder te eten — '
        'bijvoorbeeld om verder uit te laten bloeien tot het seizoen voorbij is.',
    foodHarvest: _foodHarvestCopyForEdibleBloom(
      vegetable,
      plantNameNl: plantNameNl,
    ),
    seasonFinish: _seasonFinishCopyForEdibleBloom(
      vegetable,
      plantNameNl: plantNameNl,
    ),
  );
}

CropHarvestUiCopy _ornamentalOnlySeasonFinishCopy({
  required String plantNameNl,
  required bool bloomConfirmed,
}) {
  return CropHarvestUiCopy(
    sectionTitle: bloomConfirmed ? 'Op haar mooist' : 'Prachtig in bloei',
    sectionHintFallback:
        'Je $plantNameNl doet het goed — laat bloeien voor bijen en nuttige insecten.',
    buttonLabel: 'Seizoen afronden',
    dialogTitle: 'Seizoen afronden?',
    dialogBody:
        'Weet je zeker dat je $plantNameNl uit je actieve moestuin wilt halen? '
        'De plant blijft in History; je oogst hier geen groente, je was klaar met dit seizoen.',
    infoTitle: 'Over bloemen in de moestuin',
    infoBody:
        'Cosmos, facelia en vergelijkbare bloemen eet je niet als maaltijd. '
        'Ze helpen bij bestuiving en nuttige insecten.\n\n'
        '• Laat ze bloeien zolang het kan — dat is juist het doel.\n'
        '• Knip af en toe uitgebloeide bloemen voor langere bloei.\n'
        '• Gebruik «Seizoen afronden» als de plant eruit gaat of het jaar klaar is.',
    snackBarDone: '$plantNameNl staat in History — tot volgend seizoen!',
  );
}

CropHarvestUiCopy _seasonFinishCopyForEdibleBloom(
  Vegetable vegetable, {
  required String plantNameNl,
}) {
  final eat = edibleBloomEatHint(vegetable);
  return CropHarvestUiCopy(
    sectionTitle: 'Laten uitbloeien of opruimen',
    sectionHintFallback:
        'Je hoeft niet te oogsten — je kunt de plant laten staan voor insecten.',
    buttonLabel: 'Seizoen afronden',
    dialogTitle: 'Seizoen afronden zonder te oogsten?',
    dialogBody:
        'Weet je zeker dat je $plantNameNl uit je actieve moestuin wilt halen '
        'zonder dat je alles geoogst hebt om te eten?\n\n'
        'De plant gaat naar History. Je koos ervoor om (verder) uit te laten bloeien, '
        'op te ruimen, of het seizoen af te ronden — terwijl insecten er nog van profiteren.\n\n'
        'Let op: $eat',
    infoTitle: 'Eten of laten bloeien?',
    infoBody:
        'Sommige moestuinbloemen en kruiden kun je én eten én laten staan voor insecten.\n\n'
        '• «Geoogst» — je hebt bloemen, blad of bloei geplukt om te eten en bent klaar met dit gewas.\n'
        '• «Seizoen afronden» — je haalt de plant uit je actieve moestuin zonder alles te eten; '
        'bijvoorbeeld omdat je wilt uitbloeien voor bijen of omdat het seizoen klaar is.\n\n'
        'Je kunt vaak nog even plukken vóór je afrondt — daarna blijft de geschiedenis in de app.',
    snackBarDone:
        '$plantNameNl staat in History — je liet het uitbloeien of rondde het seizoen af.',
  );
}

CropHarvestUiCopy _foodHarvestCopyForEdibleBloom(
  Vegetable vegetable, {
  required String plantNameNl,
}) {
  return CropHarvestUiCopy(
    sectionTitle: 'Klaar om te eten / te plukken',
    sectionHintFallback:
        'Pluk bloemen of blad voor op je bord — of laat staan met «Seizoen afronden».',
    buttonLabel: 'Geoogst',
    dialogTitle: 'Geoogst om te eten?',
    dialogBody:
        'Weet je zeker dat je van $plantNameNl geoogst hebt wat je wilde eten '
        '(bloemen, blad of bloei) en dit gewas uit je actieve moestuin wilt halen?\n\n'
        'De plant wordt opgeslagen in History. '
        'Wil je liever niet eten maar verder laten bloeien? Kies dan «Seizoen afronden».',
    infoTitle: 'Eten of laten bloeien?',
    infoBody:
        '${edibleBloomEatHint(vegetable)}\n\n'
        '• «Geoogst» — je plukte wat eetbaar is en bent klaar met dit gewas in de moestuin.\n'
        '• «Seizoen afronden» — je eet niet (meer) mee en haalt de plant weg terwijl hij nog kon uitbloeien.\n\n'
        'Beide keuzes archiveren de plant; scans blijven bewaard.',
    snackBarDone: '$plantNameNl staat in History — smakelijk!',
  );
}

CropHarvestUiCopy _standardFoodHarvestCopy({required String plantNameNl}) {
  return CropHarvestUiCopy(
    sectionTitle: 'Klaar om te oogsten',
    sectionHintFallback: 'Controleer of je alles geoogst hebt.',
    buttonLabel: 'Geoogst',
    dialogTitle: 'Geoogst?',
    dialogBody:
        'Weet je zeker dat je alles geoogst hebt van $plantNameNl? '
        'Deze plant wordt verwijderd uit je moestuin en opgeslagen in History.',
    infoTitle: 'Info over oogsten',
    infoBody:
        'Veel groenten kun je meerdere keren oogsten — niet alles hoeft in één keer weg.\n\n'
        '• Tomaten, komkommers, bonen: pluk regelmatig rijpe vruchten.\n'
        '• Sla, snijbiet: oogst buitenste bladeren.\n'
        '• Wortel, aardappel: controleer eerst met een proefoogst.\n\n'
        'Gebruik «Geoogst» als je klaar bent met dit gewas voor dit seizoen.',
    snackBarDone: '$plantNameNl staat nu in History.',
  );
}

String bloomHintFromProfile(GardenPlantProfile profile) {
  final a = profile.lastAnalysis;
  if (a == null) return '';
  if (a.bloomSeasonNote != null && a.bloomSeasonNote!.trim().isNotEmpty) {
    return a.bloomSeasonNote!.trim();
  }
  if (a.insight?.ripenessNote != null &&
      a.insight!.ripenessNote!.trim().isNotEmpty) {
    return a.insight!.ripenessNote!.trim();
  }
  return a.phaseLabel;
}

/// Toon actieblok voor moestuinbloemen in bloei.
bool showOrnamentalFinishSection(
  GardenPlantProfile profile,
  Vegetable vegetable,
) {
  if (!isMoestuinBloomCrop(vegetable)) return false;
  final a = profile.lastAnalysis;
  if (a == null || !a.matchesSelectedCrop) return false;
  if (a.phase == PlantAiPhase.flowering ||
      a.phase == PlantAiPhase.almostRipe ||
      a.phase == PlantAiPhase.fruiting) {
    return true;
  }
  final label = a.phaseLabel.toLowerCase();
  if (label.contains('bloei') || label.contains('bloem')) return true;
  if (a.bloomSeasonNote != null && a.bloomSeasonNote!.trim().isNotEmpty) {
    return true;
  }
  return false;
}

/// Eetbare bloem: ook tonen als AI oogst/eetbaar signaleert.
bool showEdibleBloomHarvestSection(
  GardenPlantProfile profile,
  Vegetable vegetable,
) {
  if (!isEdibleMoestuinBloomCrop(vegetable)) return false;
  if (showOrnamentalFinishSection(profile, vegetable)) return true;
  final a = profile.lastAnalysis;
  if (a == null || !a.matchesSelectedCrop) return false;
  if (a.insight?.harvestReady == true) return true;
  if (a.phase == PlantAiPhase.ripe) return true;
  return false;
}
