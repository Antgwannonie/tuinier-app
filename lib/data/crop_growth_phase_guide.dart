import '../models/plant_ai_analysis.dart';

/// Teeltfase voor checklist en plantinfo (afgestemd op AI-fase).
enum CropCarePhase {
  zaadbed,
  zaailing,
  jongePlant,
  vegetatief,
  bloei,
  vruchtvorming,
  oogst,
}

extension CropCarePhaseLabel on CropCarePhase {
  String get labelNl => switch (this) {
        CropCarePhase.zaadbed => 'Zaadbed / nog geen plant',
        CropCarePhase.zaailing => 'Zaailing',
        CropCarePhase.jongePlant => 'Jonge plant',
        CropCarePhase.vegetatief => 'Vegetatieve groei',
        CropCarePhase.bloei => 'Bloei',
        CropCarePhase.vruchtvorming => 'Vruchtvorming',
        CropCarePhase.oogst => 'Oogst / rijp',
      };
}

/// Bepaalt teeltfase uit analyse (na scan) of schatting vóór scan.
CropCarePhase resolveCropCarePhase({
  PlantAiPhase? phase,
  String? growthPhaseDetail,
  bool plantingBedOnly = false,
  bool isFirstScan = false,
  int? daysSincePlanted,
}) {
  if (plantingBedOnly || (isFirstScan && phase == PlantAiPhase.seedling)) {
    return CropCarePhase.zaadbed;
  }

  final detail = growthPhaseDetail?.trim().toLowerCase() ?? '';
  if (detail == 'zaailing') return CropCarePhase.zaailing;
  if (detail == 'jonge_plant') return CropCarePhase.jongePlant;
  if (detail == 'vegetatief') return CropCarePhase.vegetatief;
  if (detail == 'bloei') return CropCarePhase.bloei;
  if (detail == 'vruchtvorming') return CropCarePhase.vruchtvorming;
  if (detail == 'oogst') return CropCarePhase.oogst;

  if (phase != null) {
    return switch (phase) {
      PlantAiPhase.seedling =>
        daysSincePlanted != null && daysSincePlanted > 21
            ? CropCarePhase.jongePlant
            : CropCarePhase.zaailing,
      PlantAiPhase.growing => CropCarePhase.vegetatief,
      PlantAiPhase.flowering => CropCarePhase.bloei,
      PlantAiPhase.fruiting => CropCarePhase.vruchtvorming,
      PlantAiPhase.almostRipe || PlantAiPhase.ripe => CropCarePhase.oogst,
    };
  }

  if (daysSincePlanted != null) {
    if (daysSincePlanted <= 7) return CropCarePhase.zaailing;
    if (daysSincePlanted <= 21) return CropCarePhase.jongePlant;
  }

  return CropCarePhase.vegetatief;
}

/// Koppeling top-level phase → growthPhaseDetail in insight.
String growthPhaseDetailForPhase(PlantAiPhase phase) => switch (phase) {
      PlantAiPhase.seedling => 'zaailing',
      PlantAiPhase.growing => 'vegetatief',
      PlantAiPhase.flowering => 'bloei',
      PlantAiPhase.fruiting => 'vruchtvorming',
      PlantAiPhase.almostRipe || PlantAiPhase.ripe => 'oogst',
    };

/// TaskIds die voor deze fase NIET relevant zijn (niet outputten als task/let_op).
Set<String> excludedTaskIdsForPhase(CropCarePhase phase) {
  return switch (phase) {
    CropCarePhase.zaadbed => {
        'oogsten_plukken',
        'uitgebloeide_bloemen',
        'dieven_verwijderen',
        'tomaat_onderste_blad',
        'uitdunnen',
        'snoeien_dood_blad',
        'bemesten',
        'bladluis',
        'rupsen',
        'meeldauw',
        'schimmel',
        'oogsten_plukken',
        'gezonde_groei',
      },
    CropCarePhase.zaailing => {
        'oogsten_plukken',
        'uitgebloeide_bloemen',
        'dieven_verwijderen',
        'tomaat_onderste_blad',
        'aardbei_runners',
      },
    CropCarePhase.jongePlant => {
        'oogsten_plukken',
        'uitgebloeide_bloemen',
      },
    CropCarePhase.vegetatief => {
        'oogsten_plukken',
      },
    CropCarePhase.bloei => {
        'oogsten_plukken',
        'uitdunnen',
      },
    CropCarePhase.vruchtvorming => const {},
    CropCarePhase.oogst => {
        'uitdunnen',
      },
  };
}

/// Fase-specifieke checklist-items (taskId + hint).
List<(String id, String label, String hint)> phaseSpecificChecklistItems(
  CropCarePhase phase,
) {
  return switch (phase) {
    CropCarePhase.zaadbed => const [
      (
        'zaadbed_vocht',
        'Vocht zaadbed',
        'Is de grond gelijkmatig vochtig zonder plas? Geen kiemplant zichtbaar is normaal.',
      ),
      (
        'zaadbed_bescherming',
        'Bescherming zaadbed',
        'Zijn zaadjes bedekt, niet weggespoeld, geen harde korst op de grond?',
      ),
      (
        'zaadbed_licht',
        'Licht en temperatuur',
        'Past de standplaats bij dit gewas (zaai-instructie)?',
      ),
    ],
    CropCarePhase.zaailing => const [
      (
        'zaailing_vocht',
        'Zaailing vochtig houden',
        'Dunne wortels drogen snel uit — droge topgrond zichtbaar?',
      ),
      (
        'zaailing_uitdunnen',
        'Uitdunnen zaailingen',
        'Staan zaailingen te dicht op elkaar?',
      ),
      (
        'zaailing_slakken',
        'Slakken bij zaailing',
        'Slakken vreten zaailingen snel weg — schade of glimspoor?',
      ),
      (
        'zaailing_licht',
        'Voldoende licht',
        'Lijken zaailingen uitgerekt, bleek of scheef naar het licht?',
      ),
    ],
    CropCarePhase.jongePlant => const [
      (
        'jonge_plant_aanpotten',
        'Ruimte voor wortels',
        'Past de pot/afstand bij de grootte (wortelruimte)?',
      ),
      (
        'jonge_plant_beschermen',
        'Bescherm jonge plant',
        'Nachtvorst, wind of snelle temperatuurwissel relevant?',
      ),
    ],
    CropCarePhase.vegetatief => const [
      (
        'vegetatief_groei',
        'Groei en blad',
        'Stevige stengel, fris blad, geen stilstand in groei?',
      ),
      (
        'vegetatief_steun',
        'Steun en structuur',
        'Moet de plant gebind of gesteund worden?',
      ),
    ],
    CropCarePhase.bloei => const [
      (
        'bloei_bestuiving',
        'Bestuiving',
        'Zijn er insecten of handbestuiving nodig bij dit gewas?',
      ),
      (
        'bloei_voeding',
        'Voeding tijdens bloei',
        'Past bemesting bij bloei (niet te veel stikstof)?',
      ),
    ],
    CropCarePhase.vruchtvorming => const [
      (
        'vrucht_zetting',
        'Vruchtzetting',
        'Zijn bloemen bevrucht en zetten vruchten aan?',
      ),
      (
        'vrucht_calciummtekort',
        'Bloedrot / vruchtfouten',
        'Bij tomaat: bruine bodem vrucht? Onregelmatig water?',
      ),
    ],
    CropCarePhase.oogst => const [
      (
        'oogst_rijpheid',
        'Oogstrijpheid',
        'Zijn vruchten/koppen op het juiste moment om te oogsten?',
      ),
      (
        'oogst_doorplukken',
        'Doorplukken na oogst',
        'Komt er nog meer oogst aan dit seizoen?',
      ),
    ],
  };
}

/// NL-richtlijnen voor de AI per fase.
String phaseGuidanceForAi(CropCarePhase phase) {
  return switch (phase) {
    CropCarePhase.zaadbed =>
      'ZAADBED: geen oogst-, snoei- of plaagtaken tenzij grond/zaadbed zichtbaar problematisch is. '
          'Focus op vocht, bescherming en geduld. positive: goed zaadbed. let_op: vorst, uitdroging.',
    CropCarePhase.zaailing =>
      'ZAAILING: geen oogstadvies. Focus op vocht, licht, uitdunnen, slakken. '
          'Bemesting licht of nog niet. let_op: uitrekken, slakken, droogte.',
    CropCarePhase.jongePlant =>
      'JONGE PLANT: nog geen oogst. Water, licht, eerste bladluis/slakken, uitdunnen. '
          'Nog geen zware snoei of dieven (tomaat pas later).',
    CropCarePhase.vegetatief =>
      'VEGETATIEVE GROEI: blad en stengel belangrijk. Water, voeding, ondersteunen, onkruid, '
          'eerste plagen. Nog geen oogst tenzij bladgewas.',
    CropCarePhase.bloei =>
      'BLOEI: focus op bloemen, bestuiving, uitgebloeide bloemen verwijderen. '
          'Andere voeding dan vegetatief. Geen oogst van vruchten die nog niet bestaan.',
    CropCarePhase.vruchtvorming =>
      'VRUCHTVORMING: vruchten laten groeien, water regelmatig, calcium bij tomaat, plagen op vruchten. '
          'Oogst pas als vruchten zichtbaar rijp worden.',
    CropCarePhase.oogst =>
      'OOGST: rijpheid op foto bepalen, oogsten/plukken, kwaliteit vruchten/koppen. '
          'Minder uitdunnen; let_op op doorplukken en bewaar.',
  };
}

/// Korte tips voor plantinfo-tab (na scan).
ScanPhaseTips phaseTipsForUi(CropCarePhase phase, String plantName) {
  return switch (phase) {
    CropCarePhase.zaadbed => ScanPhaseTips(
        title: 'Zaadbed-fase',
        summary:
            'Er is nog geen kiemplant zichtbaar of het zaadbed is net aangelegd. '
            'Houd de grond gelijkmatig vochtig en bescherm tegen uitdroging en vorst.',
        steps: const [
          'Houd de grond licht vochtig — niet nat en niet uitgedroogd',
          'Dek af bij nachtvorst indien nodig',
          'Scan opnieuw zodra de eerste kiemplant zichtbaar is',
        ],
      ),
    CropCarePhase.zaailing => ScanPhaseTips(
        title: 'Zaailing-fase',
        summary:
            '$plantName is nog klein en kwetsbaar. Zaailingen drogen snel uit en slakken zijn de grootste vijand.',
        steps: const [
          'Geef regelmatig water — kleine potjes drogen sneller',
          'Zorg voor veel licht om uitrekken te voorkomen',
          'Dun uit als meerdere zaailingen te dicht staan',
          'Controleer \'s avonds op slakken',
        ],
      ),
    CropCarePhase.jongePlant => ScanPhaseTips(
        title: 'Jonge plant',
        summary:
            '$plantName wortelt en groeit door. Nu is de basis voor een gezonde plant.',
        steps: const [
          'Water regelmatig, vooral bij warm weer',
          'Geef voldoende ruimte tussen planten',
          'Let op eerste tekenen van bladluis of slakken',
        ],
      ),
    CropCarePhase.vegetatief => ScanPhaseTips(
        title: 'Groei-fase',
        summary:
            '$plantName bouwt blad en stengel op. Goede verzorging nu zorgt voor meer oogst later.',
        steps: const [
          'Houd onkruid weg en geef water bij droogte',
          'Bemest volgens dit gewas als de groei aantrekt',
          'Bind of ondersteun hoge of klimmende planten',
        ],
      ),
    CropCarePhase.bloei => ScanPhaseTips(
        title: 'Bloei-fase',
        summary:
            'Bloemen zijn belangrijk voor vruchtzetting of sierwaarde. '
            'Verwijder uitgebloeide bloemen om nieuwe aan te moedigen.',
        steps: const [
          'Trek geen nuttige bloemen weg tenzij uitgebloeid',
          'Zorg voor bestuiving (insecten of zacht schudden)',
          'Geef iets minder stikstof, meer kalium indien van toepassing',
        ],
      ),
    CropCarePhase.vruchtvorming => ScanPhaseTips(
        title: 'Vruchtvorming',
        summary:
            'Vruchten of oogstdeel groeit nu. Regelmatig water voorkomt scheuren en misvorming.',
        steps: const [
          'Geef gelijkmatig water — wisselen droog/nat veroorzaakt problemen',
          'Ondersteun zware vruchten indien nodig',
          'Controleer op plagen bij jonge vruchten',
        ],
      ),
    CropCarePhase.oogst => ScanPhaseTips(
        title: 'Oogst-fase',
        summary:
            '$plantName is (bijna) oogstrijp. Oogst op het juiste moment voor de beste smaak.',
        steps: const [
          'Oogst regelmatig om nieuwe vruchten aan te moedigen',
          'Bewaar of verwerk snel na oogst',
          'Controleer of er nog aanplant voor een tweede ronde is',
        ],
      ),
  };
}

class ScanPhaseTips {
  const ScanPhaseTips({
    required this.title,
    required this.summary,
    required this.steps,
  });

  final String title;
  final String summary;
  final List<String> steps;
}

bool isTaskIdAllowedForPhase(String taskId, CropCarePhase phase) {
  return !excludedTaskIdsForPhase(phase).contains(taskId);
}
