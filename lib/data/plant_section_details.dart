import '../models/vegetable.dart';
import 'flower_section_details.dart';
import 'plant_crop_profiles.dart';
import 'plant_guide_detail.dart';
import 'plant_search_filters.dart';
import 'vegetable_overview_data.dart';

/// Bouwt uitgebreide detailteksten per kop, op basis van teeltprofiel + overzicht.
List<PlantGuideDetailBlock> sectionDetailsFor({
  required String tab,
  required String title,
  required Vegetable vegetable,
  CropProfile? profile,
  VegetableOverviewFacts? overview,
}) {
  if (isFlowerGuidePlant(vegetable.id)) {
    return flowerSectionDetailsFor(
      tab: tab,
      title: title,
      vegetable: vegetable,
    );
  }

  final p = profile ?? cropProfileFor(vegetable.id);
  final ov = overview ?? vegetableOverviewFactsFor(vegetable.id);
  final name = vegetable.nameNl;
  final t = title.trim().toLowerCase();
  final gap = (p.note != null && p.note!.trim().isNotEmpty)
      ? p.note
      : (p.specialNotes.trim().isNotEmpty ? p.specialNotes : null);

  List<PlantGuideDetailBlock> d({
    required String why,
    required String how,
    required String tip,
    String? meaning,
    String? extra,
  }) =>
      guideDetailBlocks(
        meaning: meaning,
        why: why,
        how: how,
        tip: tip,
        extra: extra ?? gap,
      );

  switch (tab) {
    case 'water':
      return _waterDetails(t, name, p, ov, vegetable, d);
    case 'nutrition':
      return _nutritionDetails(t, name, p, ov, vegetable, d);
    case 'growth':
      return _growthDetails(t, name, p, ov, vegetable, d);
    case 'bloom':
      return _bloomDetails(t, name, p, ov, vegetable, d);
    case 'harvest':
      return _harvestDetails(t, name, p, ov, vegetable, d);
    case 'care':
      return _careDetails(t, name, p, ov, vegetable, d);
    case 'weetjes':
      return _weetjesDetails(t, name, p, ov, vegetable, d);
    case 'combination':
      return _combinationDetails(t, name, p, ov, vegetable, d);
    case 'problems':
      return _problemsDetails(t, name, p, ov, vegetable, d);
    default:
      return d(
        meaning: 'Informatie over “$title” voor $name.',
        why: 'Deze kop helpt je $name beter te verzorgen.',
        how: vegetable.care.isNotEmpty ? vegetable.care : p.seasonCare,
        tip: 'Combineer met standplaats, water en voeding.',
      );
  }
}

typedef _D = List<PlantGuideDetailBlock> Function({
  required String why,
  required String how,
  required String tip,
  String? meaning,
  String? extra,
});

List<PlantGuideDetailBlock> _waterDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('behoefte')) {
    return d(
      meaning: 'Waterbehoefte is hoe dorstig $name gemiddeld is in de teelt.',
      why:
          'Te weinig water remt groei; te veel veroorzaakt rot. Richtlijn: ${p.waterNeed} (overzicht: ${ov?.water ?? v.water}).',
      how: p.waterHow,
      tip: 'Check met de vinger 2–3 cm diep. Potten drogen sneller dan volle grond.',
    );
  }
  if (t.contains('water geven') || t == 'water geven') {
    return d(
      meaning: 'Techniek en timing van water geven.',
      why: 'Verkeerd water geven (nat blad ’s avonds, oppervlakkig sproeien) veroorzaakt schimmel of zwakke wortels.',
      how: p.waterHow,
      tip: 'Liever ’s ochtends bij de voet. Mulch vermindert verdamping.',
    );
  }
  if (t.contains('kieming')) {
    return d(
      meaning: 'Vocht tijdens zaaien en kiemen.',
      why: 'Zaden hebben constant vocht nodig, maar stilstaand water geeft omvalziekte.',
      how: p.waterGermination,
      tip: 'Benevel of geef van onderaf; nooit laten uitdrogen in de kiemfase.',
    );
  }
  if (t.contains('groei') && !t.contains('probleem')) {
    return d(
      meaning: 'Water in de vegetatieve groeifase.',
      why: 'Jonge planten bouwen wortels en blad; droogte nu remt later oogst.',
      how: p.waterGrowth,
      tip: 'Dieper wateren stimuleert diepere wortels.',
    );
  }
  if (t.contains('bloei')) {
    return d(
      meaning: 'Water rond de bloei.',
      why: 'Droogtestress of kou + droogte geeft bloemval bij veel gewassen.',
      how: p.waterBloom,
      tip: 'Houd gelijkmatig vochtig; geen extreme schommelingen.',
    );
  }
  if (t.contains('vrucht') || t.contains('bladgroei') || t.contains('wortelverdikking') || t.contains('bolvulling') || t.contains('peulvorming') || t.contains('kolfvulling') || t.contains('volle groei') || t.contains('oogstperiode')) {
    return d(
      meaning: 'Water tijdens de late groeifase (${cropLateStageLabel(v.id).toLowerCase()}).',
      why: 'Schommelingen geven kwaliteitsverlies of groeistoringen.',
      how: cropLateStageWaterHow(v.id),
      tip: 'Gelijkmatig water + mulch; kas goed ventileren.',
    );
  }
  if (t.contains('droogte')) {
    return d(
      meaning: 'Hoe slecht $name tegen droogte kan.',
      why: 'Gevoeligheid: ${p.droughtSensitive}.',
      how: 'Bij hitte: extra water, mulch, eventueel schaduwdoek. ${p.protectHeat}',
      tip: p.tooLittleSigns,
    );
  }
  if (t.contains('natte')) {
    return d(
      meaning: 'Gevoeligheid voor natte, slecht doorlatende grond.',
      why: 'Gevoeligheid: ${p.wetSensitive}. Natte kou = wortelrot.',
      how: 'Verbeter drainage; verhoogde bakken; niet water geven bij kletsnatte grond.',
      tip: p.tooMuchSigns,
    );
  }
  if (t.contains('te weinig')) {
    return d(
      meaning: 'Signalen van droogte.',
      why: 'Vroeg herkennen voorkomt blijvende schade.',
      how: 'Herken: ${p.tooLittleSigns} Geef dan diep water en controleer de volgende dag opnieuw.',
      tip: 'Verwar warmte-slapte niet met chronische droogte: kijk naar de grond.',
    );
  }
  if (t.contains('te veel')) {
    return d(
      meaning: 'Signalen van overbewatering.',
      why: 'Wortels verstikken zonder zuurstof.',
      how: 'Herken: ${p.tooMuchSigns} Laat opdrogen, verbeter drainage, verwijder rotte delen.',
      tip: 'Potten: check of gaten open zijn; schotel niet vol laten staan.',
    );
  }
  if (t.contains('kwaliteit')) {
    return d(
      meaning: 'Welk water het beste is.',
      why: 'Koud kraanwater of chloor kan gevoelige kiemplanten remmen; hard water beïnvloedt pH.',
      how: 'Bij voorkeur regenwater of lauw, afgestaan water. Vermijd zout/zacht water met te veel natrium.',
      tip: 'In kas: temperatuur van het water dichter bij de bodemtemperatuur houden.',
    );
  }
  if (t.contains('pot')) {
    return d(
      meaning: 'Extra aandacht voor potteelt.',
      why: 'Potten drogen sneller en hebben beperkte buffer.',
      how: p.potCare,
      tip: 'Kies voldoende volume; giet tot het uit de bodem komt, daarna overtollig water weg.',
    );
  }
  if (t.contains('kas')) {
    return d(
      meaning: 'Water in kas of tunnel.',
      why: 'Kas droogt sneller overdag maar blijft vochtig in stilstaande lucht.',
      how: '${p.greenhouseCare} Water bij de voet; ventileer na het gieten.',
      tip: '’s Ochtends water geven zodat blad droog is voor de nacht.',
    );
  }
  return d(
    meaning: 'Wateradvies voor $name.',
    why: 'Waterbehoefte: ${p.waterNeed}.',
    how: p.waterHow,
    tip: v.water,
  );
}

List<PlantGuideDetailBlock> _nutritionDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('voedingsbehoefte') || t == 'voedingsbehoefte') {
    return d(
      meaning: 'Hoe “hongerig” $name is.',
      why:
          'Overzicht voeding: ${ov?.voeding ?? 'gemiddeld'}. Bodem: ${p.soilType}',
      how: p.fertiliserAdvice,
      tip: v.soilAndFood.isNotEmpty ? v.soilAndFood : p.compostAdvice,
    );
  }
  if (t.contains('bodem')) {
    return d(
      meaning: 'Welke grond $name het liefst heeft.',
      why: p.soilType,
      how: '${p.compostAdvice} pH-richtlijn: ${p.phRange}.',
      tip: 'Werk niet in kletsnatte klei; verbeter zand met compost.',
    );
  }
  if (t.contains('ph')) {
    return d(
      meaning: 'Zuurgraad van de bodem.',
      why: 'Buiten ${p.phRange} neemt $name voeding minder goed op.',
      how: 'Meet met een pH-set. Pas aan met compost, kalk (voorzichtig) of organisch materiaal.',
      tip: 'Plotse grote kalkgiften vermijden; liever geleidelijk.',
    );
  }
  if (t.contains('compost')) {
    return d(
      meaning: 'Rol van compost.',
      why: 'Compost verbetert structuur, leven en voeding buffer.',
      how: p.compostAdvice,
      tip: 'Gebruik rijpe compost; verse mest kan wortels verbranden.',
    );
  }
  if (t.contains('mest') || t.contains('beste')) {
    return d(
      meaning: 'Welke bemesting past.',
      why: p.fertiliserAdvice,
      how: 'Start met ${p.feedAtPlant} Daarna ${p.feedDuringGrowth}',
      tip: 'Volg het overzicht: ${ov?.voeding ?? v.soilAndFood}.',
    );
  }
  if (t.contains('belangrijkste') || t.contains('voedingsstoffen')) {
    return d(
      meaning: 'Hoofdvoedingsstoffen.',
      why: p.mainNutrients,
      how: 'Gebruik organische mest of compost die N-P-K in balans houdt voor dit gewas.',
      tip: 'Te veel N = blad ten koste van bloei/vrucht.',
    );
  }
  if (t.contains('bij planten') || t.contains('bemesten bij')) {
    return d(
      meaning: 'Bemesting bij het planten.',
      why: 'Jonge wortels hebben milde startvoeding, geen zoutpiek.',
      how: p.feedAtPlant,
      tip: 'Meng compost door het plantgat, niet tegen de stengel.',
    );
  }
  if (t.contains('tijdens groei')) {
    return d(
      meaning: 'Bijmesten in de groei.',
      why: 'Actieve groei verbruikt voeding.',
      how: p.feedDuringGrowth,
      tip: p.deficiencySigns,
    );
  }
  if (t.contains('bloei')) {
    return d(
      meaning: 'Voeding rond bloei.',
      why: 'Te veel stikstof remt bloei; kalium/fosfor helpen.',
      how: p.feedBloom,
      tip: p.bloomStimulate,
    );
  }
  if (t.contains('vrucht') || t.contains('bladgroei') || t.contains('wortelverdikking') || t.contains('bolvulling') || t.contains('peulvorming') || t.contains('kolfvulling') || t.contains('volle groei') || t.contains('oogstperiode')) {
    return d(
      meaning: 'Voeding in de late groeifase (${cropLateStageLabel(v.id).toLowerCase()}).',
      why: 'Kalium versterkt stevigheid en weerstand in deze fase.',
      how: cropLateStageFeedHow(v.id),
      tip: p.overfeedSigns,
    );
  }
  if (t.contains('tekort')) {
    return d(
      meaning: 'Signalen van tekorten.',
      why: p.deficiencySigns,
      how: 'Check water eerst (opname stopt bij droogte/nat). Daarna bijmest gericht.',
      tip: 'Gele onderste bladeren kunnen N-tekort of gewoon ouderdom zijn.',
    );
  }
  if (t.contains('overbemesting')) {
    return d(
      meaning: 'Te veel mest.',
      why: p.overfeedSigns,
      how: 'Stop bemesting, spoel potgrond licht, geef alleen water tot herstel.',
      tip: 'Liever te weinig dan te veel bij jonge planten.',
    );
  }
  if (t.contains('schema')) {
    final lateLabel = cropLateStageLabel(v.id);
    return d(
      meaning: 'Eenvoudig voedingsschema.',
      why: 'Timing voorkomt pieken en tekorten.',
      how:
          '1) Bij planten: ${p.feedAtPlant} 2) Groei: ${p.feedDuringGrowth} 3) Bloei: ${p.feedBloom} 4) $lateLabel: ${cropLateStageFeedHow(v.id)}',
      tip: 'Pas aan op ${ov?.voeding ?? 'gemiddelde'} behoefte.',
    );
  }
  return d(
    meaning: 'Voeding voor $name.',
    why: p.fertiliserAdvice,
    how: p.compostAdvice,
    tip: v.soilAndFood,
  );
}

List<PlantGuideDetailBlock> _growthDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('fase')) {
    return d(
      meaning: 'De groeifases van kiem tot oogst.',
      why: 'Elke fase vraagt ander water, steun en bescherming.',
      how:
          'Volg opkomst → jonge plant → groei → bloei/vrucht → oogst. Habitus: ${ov?.growthHabit ?? p.growthHabit}.',
      tip: p.healthySigns,
    );
  }
  if (t.contains('groeiduur') || t.contains('tijd tot oogst')) {
    return d(
      meaning: 'Hoe lang tot oogst.',
      why:
          'Richtlijn: ${ov?.firstHarvest ?? v.cropDuration ?? p.daysToFruitHint}. Periode: ${ov?.harvestPeriod ?? v.harvest}.',
      how: 'Noteer zaa-/uitplantdatum; weer en ras schuiven het venster.',
      tip: 'Eerste oogst ≠ piekoogst.',
    );
  }
  if (t.contains('hoogte')) {
    return d(
      meaning: 'Verwachte planthoogte.',
      why: 'Hoogte ${ov?.height ?? 'zie overzicht'} bepaalt steun en schaduw op buren.',
      how: 'Houd rekening met eindhoogte bij het kiezen van steun en plek.',
      tip: p.supportHow,
    );
  }
  if (t.contains('breedte')) {
    return d(
      meaning: 'Verwachte breedte.',
      why: 'Breedte ${ov?.width ?? 'zie overzicht'} bepaalt plantafstand.',
      how: 'Plantafstand ${ov?.plantSpacing ?? '${v.spacingCm} cm'}.',
      tip: 'Rankers geleiden spaart oppervlak.',
    );
  }
  if (t.contains('groeiwijze') || t.contains('habit')) {
    return d(
      meaning: 'Hoe de plant groeit.',
      why: ov?.growthHabit ?? p.growthHabit,
      how: p.supportHow,
      tip: p.growthSpeed,
    );
  }
  if (t.contains('snelheid')) {
    return d(
      meaning: 'Groeisnelheid.',
      why: 'Snelheid: ${p.growthSpeed}.',
      how: 'Warmte en vocht binnen de soorttolerantie versnellen; kou remt.',
      tip: p.stressSigns,
    );
  }
  if (t.contains('ondersteuning') || t.contains('opbinden')) {
    return d(
      meaning: 'Steun en opbinden.',
      why: 'Nodig: ${p.supportNeeded}. ${p.supportHow}',
      how: 'Zet steun vroeg; bind losjes bij.',
      tip: 'Later prikken beschadigt wortels.',
    );
  }
  if (t.contains('toppen')) {
    return d(
      meaning: 'Toppen van de plant.',
      why: p.pinchTop,
      how: 'Knip of knijp de top boven een bladpaar weg wanneer de soort dat vraagt.',
      tip: 'Niet toppen bij gewassen die daar niet van houden.',
    );
  }
  if (t.contains('dieven')) {
    return d(
      meaning: 'Dieven (okselscheuten) verwijderen.',
      why: p.removeSuckers,
      how: 'Verwijder kleine dieven vroeg bij soorten die dat vragen (bijv. stamtomaat).',
      tip: 'Niet bij alle rassen/soorten nodig.',
    );
  }
  if (t.contains('uitdun')) {
    return d(
      meaning: 'Uitdunnen van zaailingen.',
      why: p.thinSeedlings,
      how: 'Knip overtollige kiemplanten weg tot de juiste afstand; trekken kan buren meenemen.',
      tip: 'Doe dit vochtig weer of na water geven.',
    );
  }
  if (t.contains('stimuleren')) {
    return d(
      meaning: 'Groei stimuleren.',
      why: 'Licht, warmte, water en voeding in balans.',
      how: '${p.bloomStimulate} ${p.feedDuringGrowth}',
      tip: 'Geen mestgift op een gestreste droge plant.',
    );
  }
  if (t.contains('probleem')) {
    return d(
      meaning: 'Veelvoorkomende groeiproblemen.',
      why: p.growthProblems,
      how: 'Check water, kou, licht, plagen en voeding. Symptomen: ${p.problemSymptoms}',
      tip: p.stressSigns,
    );
  }
  if (t.contains('gezonde')) {
    return d(
      meaning: 'Tekenen van gezonde groei.',
      why: p.healthySigns,
      how: 'Vergelijk wekelijks: nieuwe bladeren, stevige stengel, goede kleur.',
      tip: 'Fotografeer bij uitplanten voor eerlijke vergelijking.',
    );
  }
  if (t.contains('stress')) {
    return d(
      meaning: 'Tekenen van groeistress.',
      why: p.stressSigns,
      how: 'Verwijder de stressor (droogte, wind, kou, te nat) vóór je bemest.',
      tip: p.protectHeat,
    );
  }
  return d(
    meaning: 'Groei van $name.',
    why: p.growthHabit,
    how: p.seasonCare,
    tip: ov?.growthHabit ?? v.care,
  );
}

List<PlantGuideDetailBlock> _bloomDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('periode') || t.contains('eerste bloei')) {
    return d(
      meaning: 'Wanneer $name bloeit.',
      why: p.bloomPeriodHint,
      how: 'Zorg voor genoeg licht/warmte. ${p.bloomStimulate}',
      tip: p.bloomProblems,
    );
  }
  if (t.contains('vruchtvorming') || t.contains('tijd tot') || t.contains('bloei en oogst')) {
    return d(
      meaning: 'Van bloei naar vrucht.',
      why: p.daysToFruitHint,
      how: p.hasSeparateSexFlowers
          ? 'Mannelijke en vrouwelijke bloemen: ${p.handPollinate}'
          : 'Bestuiving: ${p.selfPollinating ? 'vaak zelfbestuivend' : 'hulp van bestuivers'}.',
      tip: p.pollinators,
    );
  }
  if (t.contains('zelfbestuiver')) {
    return d(
      meaning: 'Of de plant zichzelf kan bestuiven.',
      why: p.selfPollinating
          ? '$name is (deels) zelfbestuivend, maar luchtbeweging/insecten helpen.'
          : '$name heeft bestuivers of handbestuiving nodig.',
      how: p.handPollinate,
      tip: p.pollinators,
    );
  }
  if (t.contains('mannelijk') || t.contains('vrouwelijk')) {
    return d(
      meaning: 'Gescheiden bloemen.',
      why: p.hasSeparateSexFlowers
          ? 'Deze familie heeft aparte mannelijke en vrouwelijke bloemen.'
          : 'Meestal gemengde of hermafrodiete bloemen.',
      how: p.handPollinate,
      tip: 'Vrouwelijke bloemen hebben vaak een mini-vruchtje onder de bloem.',
    );
  }
  if (t.contains('bestuiver')) {
    return d(
      meaning: 'Wie bestuift.',
      why: p.pollinators,
      how: 'Plant bloemen, vermijd insecticiden in bloei, open kasramen.',
      tip: p.handPollinate,
    );
  }
  if (t.contains('stimuleren')) {
    return d(
      meaning: 'Bloei stimuleren.',
      why: p.bloomStimulate,
      how: 'Voldoende licht, niet te veel stikstof, stabiel water.',
      tip: p.feedBloom,
    );
  }
  if (t.contains('verwijderen')) {
    return d(
      meaning: 'Bloemen weghalen.',
      why: p.removeFlowersAdvice,
      how: 'Verwijder zieke/uitgebloeide bloemen; bij bladgewassen soms knoppen.',
      tip: p.flowersEdible,
    );
  }
  if (t.contains('zelf') && t.contains('bestuiv')) {
    return d(
      meaning: 'Handbestuiving.',
      why: 'Handig in kas of bij weinig insecten.',
      how: p.handPollinate,
      tip: 'Doe het ’s ochtends bij droge bloemen.',
    );
  }
  if (t.contains('gezonde bloei')) {
    return d(
      meaning: 'Gezonde bloei herkennen.',
      why: p.bloomHealthy,
      how: 'Kijk naar verse bloemen en vruchtzetting na enkele dagen.',
      tip: p.bloomProblems,
    );
  }
  if (t.contains('probleem')) {
    return d(
      meaning: 'Problemen in de bloei.',
      why: p.bloomProblems,
      how: 'Check temperatuur, water, bestuiving en stikstofoverschot.',
      tip: p.protectHeat,
    );
  }
  if (t.contains('eetbaar')) {
    return d(
      meaning: 'Zijn de bloemen eetbaar?',
      why: p.flowersEdible,
      how: 'Alleen eten wat je zeker weet; bespuiting vermijden.',
      tip: 'Courgettebloemen zijn een bekende uitzondering.',
    );
  }
  return d(
    meaning: 'Bloei van $name.',
    why: p.bloomPeriodHint,
    how: p.bloomStimulate,
    tip: p.bloomProblems,
  );
}

List<PlantGuideDetailBlock> _harvestDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('periode')) {
    return d(
      meaning: 'Oogstperiode.',
      why:
          'Periode: ${ov?.harvestPeriod ?? v.harvest}. Eerste oogst: ${ov?.firstHarvest ?? p.daysToFruitHint}.',
      how: 'Oogst wanneer rijpheidskenmerken kloppen, niet alleen op de kalender.',
      tip: v.harvestTips,
    );
  }
  if (t.contains('tijd tot')) {
    return d(
      meaning: 'Tijd tot oogst.',
      why: ov?.firstHarvest ?? v.cropDuration ?? p.daysToFruitHint,
      how: 'Tel vanaf zaai/uitplant; weer en ras schuiven.',
      tip: 'Noteer je startdatum.',
    );
  }
  if (t.contains('frequentie')) {
    return d(
      meaning: 'Hoe vaak oogsten.',
      why: p.harvestFrequency,
      how: p.harvestHow,
      tip: 'Regelmatig oogsten stimuleert vaak nieuwe productie.',
    );
  }
  if (t.contains('rijp') || t.contains('herkennen')) {
    return d(
      meaning: 'Oogstrijp herkennen.',
      why: p.ripenessSigns,
      how: 'Gebruik kleur, grootte, stevigheid en geur; check rasinfo.',
      tip: v.harvestTips,
    );
  }
  if (t.contains('hoe oogst')) {
    return d(
      meaning: 'Oogsttechniek.',
      why: 'Juiste techniek voorkomt schade en ziekte.',
      how: p.harvestHow,
      tip: 'Oogst droog weer; schoon gereedschap.',
    );
  }
  if (t.contains('opbrengst')) {
    return d(
      meaning: 'Verwachte opbrengst.',
      why:
          '${ov?.opbrengstLevel ?? p.yieldHint}. ${ov?.opbrengstDetail ?? ''}',
      how: 'Goede standplaats, water en voeding verhogen de oogst.',
      tip: 'Dichte stand verlaagt vaak de opbrengst per plant.',
    );
  }
  if (t.contains('stimuleren')) {
    return d(
      meaning: 'Oogst stimuleren.',
      why: 'Regelmatig plukken en goede bestuiving helpen.',
      how: '${p.harvestFrequency} ${p.bloomStimulate}',
      tip: p.feedFruit,
    );
  }
  if (t.contains('doorgroeien')) {
    return d(
      meaning: 'Doorgroeien na oogst.',
      why: 'Sommige gewassen geven meerdere snedes of herhaalde oogst.',
      how: 'Laat groeipunten intact waar de soort dat vraagt; bemest licht na zware oogst.',
      tip: p.seasonCare,
    );
  }
  if (t.contains('bewaar')) {
    return d(
      meaning: 'Bewaren na oogst.',
      why: p.storeHow,
      how: p.storeHow,
      tip: 'Beschadigde vruchten eerst opeten.',
    );
  }
  if (t.contains('invries')) {
    return d(
      meaning: 'Invriezen.',
      why: p.freezeHow,
      how: p.freezeHow,
      tip: 'Blancheren waar nodig voor betere kwaliteit.',
    );
  }
  if (t.contains('drogen')) {
    return d(
      meaning: 'Drogen.',
      why: p.dryHow,
      how: p.dryHow,
      tip: 'Droog luchtig en uit de felle zon bij kruiden/zaden.',
    );
  }
  if (t.contains('zaden')) {
    return d(
      meaning: 'Zaden bewaren.',
      why: p.saveSeeds,
      how: 'Volledig rijp → drogen → koel/droog labelen.',
      tip: 'Hybriden (F1) geven niet altijd trouw nageslacht.',
    );
  }
  if (t.contains('perfecte') || t.contains('tekenen van')) {
    return d(
      meaning: 'Perfecte oogstmoment.',
      why: p.ripenessSigns,
      how: p.harvestHow,
      tip: v.harvestTips,
    );
  }
  if (t.contains('probleem')) {
    return d(
      meaning: 'Oogstproblemen.',
      why: p.harvestProblems,
      how: 'Pas timing, water en rassenkeuze aan; verwijder zieke delen.',
      tip: v.commonIssues,
    );
  }
  if (t.contains('eetbare')) {
    return d(
      meaning: 'Eetbare delen.',
      why: p.edibleParts,
      how: 'Gebruik alleen gezonde, onbespoten delen.',
      tip: p.kitchenUse,
    );
  }
  return d(
    meaning: 'Oogsten van $name.',
    why: ov?.harvestPeriod ?? v.harvest,
    how: p.harvestHow,
    tip: v.harvestTips,
  );
}

List<PlantGuideDetailBlock> _careDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('dagelijkse')) {
    return d(
      meaning: 'Dagelijkse check.',
      why: p.dailyCheck,
      how: 'Loop langs: slapte, hitte, vorst, openstaande kas.',
      tip: p.potCare,
    );
  }
  if (t.contains('wekelijkse')) {
    return d(
      meaning: 'Wekelijkse controle.',
      why: p.weeklyCheck,
      how: 'Onkruid, steun, bladonderkant op plagen, bemesting.',
      tip: p.mulch,
    );
  }
  if (t.contains('onderhoud')) {
    return d(
      meaning: 'Algemeen onderhoud.',
      why: p.seasonCare,
      how: v.care.isNotEmpty ? v.care : p.seasonCare,
      tip: p.weeklyCheck,
    );
  }
  if (t.contains('snoeien') || t.contains('toppen') || t.contains('dieven')) {
    return d(
      meaning: titleish(t),
      why: t.contains('dieven')
          ? p.removeSuckers
          : t.contains('top')
              ? p.pinchTop
              : p.prune,
      how: p.prune,
      tip: 'Snoei bij droog weer; schoon gereedschap.',
    );
  }
  if (t.contains('opbind') || t.contains('ondersteun')) {
    return d(
      meaning: 'Steun en opbinden.',
      why: '${p.supportNeeded}. ${p.supportHow}',
      how: p.supportHow,
      tip: 'Controleer bindingen na wind.',
    );
  }
  if (t.contains('mulch')) {
    return d(
      meaning: 'Mulchen.',
      why: p.mulch,
      how: 'Leg 3–5 cm mulch rond de plant, niet tegen de stengel.',
      tip: 'Bij aardbei: stro tegen rot.',
    );
  }
  if (t.contains('onkruid')) {
    return d(
      meaning: 'Onkruidbeheer.',
      why: p.weed,
      how: 'Wied ondiep; mulch helpt.',
      tip: 'Jonge onkruiden zijn makkelijker.',
    );
  }
  if (t.contains('hitte')) {
    return d(meaning: 'Hittebescherming.', why: p.protectHeat, how: p.protectHeat, tip: p.waterHow);
  }
  if (t.contains('kou') || t.contains('vorst')) {
    return d(meaning: 'Kou/vorstbescherming.', why: p.protectCold, how: p.protectCold, tip: p.winterCare);
  }
  if (t.contains('wind') || t.contains('regen') || t.contains('dieren')) {
    return d(
      meaning: 'Bescherming tegen weer/dieren.',
      why: 'Wind, slagregen en vraat beschadigen jonge planten.',
      how: 'Netten, vlies, steun en omheining naar behoefte.',
      tip: p.windSensitivity,
    );
  }
  if (t.contains('gezonde plant')) {
    return d(meaning: 'Gezonde plant.', why: p.healthySigns, how: p.dailyCheck, tip: p.stressSigns);
  }
  if (t.contains('waarschuwing')) {
    return d(meaning: 'Waarschuwingssignalen.', why: p.stressSigns, how: p.problemSymptoms, tip: v.commonIssues);
  }
  if (t.contains('seizoen')) {
    return d(meaning: 'Seizoensverzorging.', why: p.seasonCare, how: p.seasonCare, tip: ov?.lifespan ?? '');
  }
  if (t.contains('winter')) {
    return d(meaning: 'Winterbescherming.', why: p.winterCare, how: p.winterCare, tip: p.protectCold);
  }
  if (t.contains('pot')) {
    return d(meaning: 'Verzorging in pot.', why: p.potCare, how: p.potCare, tip: p.waterHow);
  }
  if (t.contains('kas')) {
    return d(meaning: 'Verzorging in kas.', why: p.greenhouseCare, how: p.greenhouseCare, tip: p.protectHeat);
  }
  return d(
    meaning: 'Verzorging van $name.',
    why: p.seasonCare,
    how: v.care.isNotEmpty ? v.care : p.weeklyCheck,
    tip: p.dailyCheck,
  );
}

String titleish(String t) {
  if (t.contains('dieven')) return 'Dieven verwijderen';
  if (t.contains('top')) return 'Toppen van de plant';
  if (t.contains('snoei')) return 'Snoeien';
  return 'Verzorging';
}

List<PlantGuideDetailBlock> _weetjesDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('oorsprong')) {
    return d(
      meaning: 'Waar $name vandaan komt en hoe het in Nederland terechtkwam.',
      why: p.origin,
      how: 'Cultuurplanten verspreidden zich via handelsroutes naar het gematigde NL-klimaat.',
      tip: p.funFact,
    );
  }
  if (t.contains('historie') || t.contains('geschiedenis')) {
    return d(
      meaning: 'De teeltgeschiedenis van $name.',
      why: p.origin,
      how: 'Rassenkeuze en teelt evolueerden met klimaat en keuken — in NL vooral na de 17e eeuw.',
      tip: p.specialNotes.isNotEmpty ? p.specialNotes : p.funFact,
    );
  }
  if (t.contains('naam')) {
    return d(
      meaning: 'Herkomst van de naam $name.',
      why: p.nameMeaning,
      how: 'Latijnse namen helpen familie en verwantschap te herkennen.',
      tip: v.nameLatin ?? '',
    );
  }
  if (t.contains('plantenfamilie')) {
    return d(
      meaning: 'Botanische plantenfamilie van $name.',
      why: p.plantFamilyHint,
      how:
          'Soorten uit dezelfde familie delen vaak plagen en voedingsbehoeften. Wissel families in je bedden.',
      tip:
          'In NL-klimaat voorkomt wisselteelt bodemziekten binnen dezelfde familie.',
      extra: 'Verwanten in de app staan als chips op deze kaart.',
    );
  }
  if (t.contains('familie')) {
    return d(
      meaning: 'Plantenfamilie van $name.',
      why: p.plantFamilyHint,
      how: 'Familie bepaalt wisselteelt, gedeelde plagen en voedingsbehoeften.',
      tip: 'In NL-klimaat is wisselteelt essentieel om bodemziekten te voorkomen binnen dezelfde familie.',
    );
  }
  if (t.contains('nuttig') || t.contains('dieren') || t.contains('bijen')) {
    return d(
      meaning: 'Nuttige dieren rond $name.',
      why:
          'Bestuivers en natuurlijke vijanden verhogen oogst en verminderen plagen zonder chemie.',
      how:
          'Laat bloeiende randen staan, vermijd breedwerkende middelen, en geef schuilplekken (hout, steenhopen).',
      tip:
          'Bijen en hommels bestuiven; lieveheersbeestjes eten bladluis. Vlinders signaleren een biodiversere tuin.',
      extra: p.pollinators,
    );
  }
  if (t.contains('wereld') || t.contains('productie')) {
    return d(
      meaning: 'Wereldteelt van $name.',
      why:
          'Grote productielanden bepalen aanbod in winkels; eigen teelt geeft verse smaak en rassenkeuze.',
      how:
          'In Nederland past $name vooral in moestuin, bak of kas — afhankelijk van warmtebehoefte.',
      tip: p.kasPreferred
          ? 'Kas of tunnel helpt in het NL-klimaat voor een betrouwbare oogst.'
          : 'Buiten teelt lukt vaak goed met de juiste standplaats en timing.',
      extra: p.origin,
    );
  }
  if (t.contains('bijzonder')) {
    return d(
      meaning: 'Bijzondere eigenschappen van $name.',
      why: p.specialNotes.isNotEmpty ? p.specialNotes : p.funFact,
      how: ov?.didYouKnow ?? p.funFact,
      tip: gapOr(p),
    );
  }
  if (t.contains('eetbare') || t.contains('eetbaar')) {
    return d(
      meaning: 'Welke delen van $name eetbaar zijn.',
      why: p.edibleParts,
      how: p.kitchenUse,
      tip: p.healthBenefits,
    );
  }
  if (t.contains('gezondheid') || t.contains('voordelen')) {
    return d(
      meaning: 'Gezondheidsvoordelen van $name.',
      why: p.healthBenefits,
      how: 'Varieer bereiding; verse oogst uit eigen tuin behoudt meer vitamines.',
      tip: p.kitchenUse,
    );
  }
  if (t.contains('keuken') || t.contains('gebruik') || t.contains('bereiding')) {
    return d(
      meaning: 'Keukengebruik van $name.',
      why: p.kitchenUse,
      how: 'Kort koken of rauw eten behoudt de meeste voedingsstoffen.',
      tip: p.storeHow,
    );
  }
  if (t.contains('rassen') || t.contains('variëteit') || t.contains('populair')) {
    return d(
      meaning: 'Populaire rassen van $name voor het NL-klimaat.',
      why: 'Kies rassen die bestand zijn tegen NL-weer: vochtigheid, wind en koel voorjaar.',
      how: 'Vroege rassen presteren beter in korte zomers; late rassen geven herfstoogst.',
      tip: p.specialNotes.isNotEmpty ? p.specialNotes : 'Vraag tuincentrum om bewezen lokale rassen.',
    );
  }
  if (t.contains('verrassend') || t.contains('toepassing')) {
    return d(
      meaning: 'Onverwachte toepassingen van $name.',
      why: p.funFact,
      how: p.kitchenUse,
      tip: p.specialNotes,
    );
  }
  if (t.contains('wist') || t.contains('feit') || t.contains('datje')) {
    return d(
      meaning: 'Wist-je-dat over $name.',
      why: ov?.didYouKnow ?? p.funFact,
      how: p.funFact,
      tip: gapOr(p),
    );
  }
  return d(
    meaning: 'Weetje over $name.',
    why: ov?.didYouKnow ?? p.funFact,
    how: p.origin,
    tip: p.kitchenUse,
  );
}

String gapOr(CropProfile p) => p.note ?? '';

List<PlantGuideDetailBlock> _combinationDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('goede buren') || (t.contains('goede') && !t.contains('voorganger'))) {
    return d(
      meaning: 'Planten die $name beschermen of versterken.',
      why: p.goodNeighbors.isNotEmpty
          ? 'Goede buren: ${p.goodNeighbors.join(', ')}.'
          : 'Kies buren met complementaire worteldiepte en voedingsbehoefte.',
      how: 'Wissel rijen met buren; in NL benut het vochtige seizoen om samen te starten.',
      tip: p.comboBenefits,
    );
  }
  if (t.contains('slechte')) {
    return d(
      meaning: 'Planten die je beter niet naast $name zet.',
      why: p.badNeighbors.isNotEmpty
          ? 'Vermijd: ${p.badNeighbors.join(', ')}.'
          : 'Houd dezelfde familie gescheiden.',
      how: 'Houd minstens 50 cm afstand of plaats in ander bed. NL-tuinen zijn compact — plan vooruit.',
      tip: p.comboMistakes,
    );
  }
  if (t.contains('plantfamilie') || t.contains('familie')) {
    return d(
      meaning: 'Familieverwantschap van $name.',
      why: p.plantFamilyHint,
      how: 'Gebruik familie voor wisselteelt; in het NL-klimaat bouwen bodemziekten snel op bij herhaalde teelt.',
      tip: v.family,
    );
  }
  if (t.contains('wissel')) {
    final isMeerjarig = p.key == CropProfileKey.fruitZaad || p.key == CropProfileKey.meerjarig;
    return d(
      meaning: isMeerjarig
          ? '$name is meerjarig — vaste plek met goede bodembedekking.'
          : 'Wisselteelt voorkomt bodemuitputting bij $name.',
      why: isMeerjarig
          ? 'Meerjarige planten hoeven niet te roteren; zorg voor mulch en bemesting.'
          : p.rotationYears.isNotEmpty ? p.rotationYears : 'Laat 3–4 jaar tussen dezelfde familie.',
      how: isMeerjarig
          ? 'Kies een definitieve plek met goede licht/drainage.'
          : 'Wissel families over bedden; in NL korte seizoenen benutten met groenbemester ertussen.',
      tip: p.comboMistakes,
    );
  }
  if (t.contains('voorganger')) {
    return d(
      meaning: 'Wat het beste vóór $name op deze plek stond.',
      why: p.predecessors.isNotEmpty ? p.predecessors.join(', ') : 'Peulvruchten of groenbemester.',
      how: 'Kies voorgangers die stikstof achterlaten of bodemziekte onderdrukken.',
      tip: p.nitrogenFixers.isNotEmpty ? p.nitrogenFixers.join(', ') : 'Klaver, erwten, bonen.',
    );
  }
  if (t.contains('opvolger')) {
    return d(
      meaning: 'Wat je na $name op dezelfde plek kunt telen.',
      why: p.successors.isNotEmpty ? p.successors.join(', ') : 'Bladgroente of wortelgewas.',
      how: 'Na zware eters: licht bladgewas of groenbemester vóór de winter (NL: zaai vóór oktober).',
      tip: p.soilImprovers.isNotEmpty ? p.soilImprovers.join(', ') : 'Compost, groenbemester.',
    );
  }
  if (t.contains('gezelschap') || t.contains('compan')) {
    return d(
      meaning: 'Gezelschapsplanten die $name ondersteunen.',
      why: p.companions.isNotEmpty ? p.companions.join(', ') : 'Afrikaantje, basilicum, goudsbloem.',
      how: 'Meng geuren en bloemen voor diversiteit; in NL-tuinen helpt dit ook bestuivers.',
      tip: p.comboBenefits,
    );
  }
  if (t.contains('plagen') || t.contains('pest')) {
    return d(
      meaning: 'Planten die plagen van $name op afstand houden.',
      why: p.pestPlants.isNotEmpty ? p.pestPlants.join(', ') : 'Ui, look, lavendel, afrikaantje.',
      how: 'Combineer met netten en hygiëne; geurplanten helpen maar zijn geen garantie.',
      tip: 'Veelvoorkomende plagen bij $name: ${p.commonPests.take(3).join(', ')}.',
    );
  }
  if (t.contains('bodemverbeteraar') || t.contains('bodem')) {
    return d(
      meaning: 'Planten die de bodem rond $name verbeteren.',
      why: p.soilImprovers.isNotEmpty ? p.soilImprovers.join(', ') : 'Compost en groenbemesters.',
      how: 'In NL-kleigrond helpen diepwortelaars met drainage; in zandgrond houden ze vocht vast.',
      tip: p.compostAdvice,
    );
  }
  if (t.contains('stikstof')) {
    return d(
      meaning: 'Stikstofbinders die $name ten goede komen.',
      why: p.nitrogenFixers.isNotEmpty ? p.nitrogenFixers.join(', ') : 'Erwten, bonen, klaver, lupine.',
      how: 'Zaai vlinderbloemigen voor of naast zware eters; in NL ideaal als nazomer-groenbemester.',
      tip: 'Niet meteen extra stikstofmest geven naast vlinderbloemigen.',
    );
  }
  if (t.contains('groene') || t.contains('bemester')) {
    return d(
      meaning: 'Groenbemesters voor een gezonde bodem.',
      why: 'Verbeteren structuur, onderdrukken onkruid en voeden bodemleven.',
      how: 'Zaai na oogst (NL: aug–sept); werk in vóór bloei/zaadrijpheid in het voorjaar.',
      tip: p.soilImprovers.isNotEmpty ? p.soilImprovers.join(', ') : 'Mosterd, phacelia, klaver.',
    );
  }
  if (t.contains('ruimte')) {
    return d(
      meaning: 'Ruimte besparen door slim combineren met $name.',
      why: 'Hoog + laag en snel + langzaam naast elkaar levert meer op.',
      how: 'Sla tussen kool; rankers omhoog; in kleine NL-tuinen is verticaal groeien essentieel.',
      tip: p.comboBenefits,
    );
  }
  if (t.contains('voordeel') || t.contains('combinatievoordelen')) {
    return d(
      meaning: 'Voordelen van goede combinaties met $name.',
      why: p.comboBenefits.isNotEmpty ? p.comboBenefits : 'Minder plagen, meer oogst, gezondere bodem.',
      how: 'Plan buren vooraf; in het NL-klimaat profiteren combinaties van beschut microklimaat.',
      tip: p.goodNeighbors.isNotEmpty ? p.goodNeighbors.join(', ') : '',
    );
  }
  if (t.contains('fout') || t.contains('veelgemaakte')) {
    return d(
      meaning: 'Fouten die je wilt vermijden bij $name.',
      why: p.comboMistakes.isNotEmpty ? p.comboMistakes : 'Zelfde familie op één plek; te dicht planten.',
      how: 'Vermijd ${p.badNeighbors.take(3).join(', ')} als directe buur.',
      tip: p.rotationYears.isNotEmpty ? p.rotationYears : 'Wissel elk jaar van bed.',
    );
  }
  return d(
    meaning: 'Combinatieteelt voor $name.',
    why: p.comboBenefits.isNotEmpty ? p.comboBenefits : 'Slim combineren verhoogt je oogst.',
    how: 'Goed: ${p.goodNeighbors.join(', ')}. Vermijd: ${p.badNeighbors.join(', ')}.',
    tip: p.comboMistakes,
  );
}

List<PlantGuideDetailBlock> _problemsDetails(
  String t,
  String name,
  CropProfile p,
  VegetableOverviewFacts? ov,
  Vegetable v,
  _D d,
) {
  if (t.contains('symptoom') || t.contains('herkennen')) {
    return d(
      meaning: 'Hoe herken je problemen bij $name.',
      why: p.problemSymptoms,
      how: 'Bekijk blad, stengel, wortelzone en weer van de week. In NL is vochtige lucht een risicofactor.',
      tip: v.commonIssues,
    );
  }
  if (t.contains('insect') || t.contains('plaag')) {
    return d(
      meaning: 'Insecten en plagen bij $name.',
      why: 'Veelvoorkomend: ${p.commonPests.join(', ')}.',
      how: 'Controleer onder blad; biologische bestrijding; insectennetten bij NL-nachtvlinders en koolvliegen.',
      tip: v.commonIssues,
    );
  }
  if (t.contains('schimmel') || t.contains('ziekte')) {
    return d(
      meaning: 'Schimmels en ziekten bij $name.',
      why: 'Veelvoorkomend: ${p.commonDiseases.join(', ')}.',
      how: 'Luchtcirculatie verhogen, droog blad in de avond, wisselteelt. NL-vocht bevordert meeldauw en Phytophthora.',
      tip: p.greenhouseCare,
    );
  }
  if (t.contains('voeding') || t.contains('tekort')) {
    return d(
      meaning: 'Voedingsproblemen bij $name.',
      why: p.deficiencySigns,
      how: 'Eerst water/pH checken, dan bijmesten. NL-regenval spoelt voeding sneller uit dan in droog klimaat.',
      tip: p.fertiliserAdvice,
    );
  }
  if (t.contains('water')) {
    return d(
      meaning: 'Waterproblemen bij $name.',
      why: '${p.tooLittleSigns} / ${p.tooMuchSigns}',
      how: '${p.waterHow} In NL: let op natte periodes in voor- en najaar.',
      tip: p.wetSensitive,
    );
  }
  if (t.contains('weer') || t.contains('klimaat')) {
    return d(
      meaning: 'Weer- en klimaatproblemen bij $name.',
      why: 'Hitte, kou, wind en hagel stressen $name. NL-late nachtvorst en koele zomers zijn veelvoorkomend.',
      how: '${p.protectHeat} ${p.protectCold}',
      tip: p.windSensitivity,
    );
  }
  if (t.contains('bestuiv')) {
    final fruits = cropFruitsForHarvest(v.id);
    return d(
      meaning: fruits ? 'Bestuivingsproblemen bij $name.' : 'Bestuiving is hier niet relevant voor oogst.',
      why: fruits ? p.bloomProblems : 'Bij dit gewas oogst je geen vruchten uit bloemen.',
      how: fruits
          ? '${p.handPollinate} In koele NL-voorjaren zijn bestuivers minder actief.'
          : 'Bestuiving speelt alleen een rol als je zaad wilt winnen.',
      tip: fruits ? p.pollinators : 'Laat de plant doorschieten als je zaad wilt oogsten.',
    );
  }
  if (t.contains('groei')) {
    return d(
      meaning: 'Groeiproblemen bij $name.',
      why: p.growthProblems,
      how: '${p.stressSigns} NL-koele nachten in mei/juni vertragen warmteminnende gewassen.',
      tip: p.healthySigns,
    );
  }
  if (t.contains('pot') || t.contains('bak')) {
    return d(
      meaning: 'Problemen bij potcultuur van $name.',
      why: 'Uitdroging, zoutopbouw, te kleine pot.',
      how: '${p.potCare} Potten in NL-wind drogen extra snel.',
      tip: p.tooMuchSigns,
    );
  }
  if (t.contains('kas') || t.contains('tunnel')) {
    return d(
      meaning: 'Problemen in kas bij $name.',
      why: 'Hitte, schimmel, plagen floreren in stilstaande lucht.',
      how: '${p.greenhouseCare} Open bij 25 °C+ en sluit bij nachtvorst.',
      tip: p.commonDiseases.join(', '),
    );
  }
  if (t.contains('dier') || t.contains('slak') || t.contains('vogel')) {
    return d(
      meaning: 'Dierenschade bij $name.',
      why: 'Slakken (NL-probleem #1), vogels en konijnen beschadigen jonge planten.',
      how: 'Netten, slakkenringen, biervalletjes, oogst tijdig.',
      tip: p.commonPests.join(', '),
    );
  }
  return d(
    meaning: 'Problemen bij $name.',
    why: p.problemSymptoms,
    how: 'Plagen: ${p.commonPests.join(', ')}. Ziekten: ${p.commonDiseases.join(', ')}.',
    tip: v.commonIssues.isNotEmpty ? v.commonIssues : gapOr(p),
  );
}
