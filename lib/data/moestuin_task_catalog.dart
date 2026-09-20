/// Universele moestuinchecklist — de app levert de items, de AI beoordeelt ze per scan.
class MoestuinTaskCatalogItem {
  const MoestuinTaskCatalogItem({
    required this.id,
    required this.labelNl,
    required this.aiHint,
    this.topicKey,
  });

  final String id;
  final String labelNl;
  final String aiHint;
  /// Sleutel voor deduplicatie tussen taken en let-op info.
  final String? topicKey;
}

/// Standaard taken die voor (bijna) elk gewas relevant kunnen zijn.
const List<MoestuinTaskCatalogItem> kUniversalMoestuinTasks = [
  MoestuinTaskCatalogItem(
    id: 'water_geven',
    labelNl: 'Water geven',
    topicKey: 'water',
    aiHint: 'Droge grond, hangende bladeren of te natte grond op foto?',
  ),
  MoestuinTaskCatalogItem(
    id: 'onkruid_wieden',
    labelNl: 'Onkruid wieden',
    topicKey: 'onkruid',
    aiHint: 'Concurrentie of onkruid zichtbaar rond de plant?',
  ),
  MoestuinTaskCatalogItem(
    id: 'snoeien_dood_blad',
    labelNl: 'Dode bladeren verwijderen',
    topicKey: 'snoei',
    aiHint: 'Gele, bruine of dode bladeren zichtbaar?',
  ),
  MoestuinTaskCatalogItem(
    id: 'uitdunnen',
    labelNl: 'Uitdunnen',
    topicKey: 'snoei',
    aiHint: 'Te dichte opstand, te veel scheuten naast elkaar?',
  ),
  MoestuinTaskCatalogItem(
    id: 'ondersteunen',
    labelNl: 'Ondersteunen / binden',
    aiHint: 'Hoge of klimmende plant die steun nodig heeft?',
  ),
  MoestuinTaskCatalogItem(
    id: 'mulchen',
    labelNl: 'Mulchen / bodem bedekken',
    aiHint: 'Kale grond zichtbaar die bedekt kan worden?',
  ),
  MoestuinTaskCatalogItem(
    id: 'bemesten',
    labelNl: 'Bemesten / voeden',
    topicKey: 'voeding',
    aiHint: 'Tekenen van voedingstekort op blad, of groei lijkt stil?',
  ),
  MoestuinTaskCatalogItem(
    id: 'bladluis',
    labelNl: 'Bladluis',
    topicKey: 'bladluis',
    aiHint: 'Kleine groene/zwarte insecten op scheuten of onder blad?',
  ),
  MoestuinTaskCatalogItem(
    id: 'slakken',
    labelNl: 'Slakken',
    topicKey: 'slak',
    aiHint: 'Gaten in blad, glimspoor of slak zichtbaar?',
  ),
  MoestuinTaskCatalogItem(
    id: 'rupsen',
    labelNl: 'Rupsen',
    topicKey: 'rups',
    aiHint: 'Rupsen, kaars of vraatsporen op blad?',
  ),
  MoestuinTaskCatalogItem(
    id: 'witte_vlieg',
    labelNl: 'Witte vlieg',
    topicKey: 'witte_vlieg',
    aiHint: 'Witte vliegjes rond plant of onder blad?',
  ),
  MoestuinTaskCatalogItem(
    id: 'spint',
    labelNl: 'Spint',
    topicKey: 'spint',
    aiHint: 'Fijne webjes of stipjes op blad?',
  ),
  MoestuinTaskCatalogItem(
    id: 'trips',
    labelNl: 'Trips',
    topicKey: 'trips',
    aiHint: 'Zilverige vlekken of kleine insecten in bloem/knop?',
  ),
  MoestuinTaskCatalogItem(
    id: 'meeldauw',
    labelNl: 'Meeldauw',
    topicKey: 'meeldauw',
    aiHint: 'Wit poeder op blad of stengel?',
  ),
  MoestuinTaskCatalogItem(
    id: 'schimmel',
    labelNl: 'Schimmel / vlekkenziekte',
    topicKey: 'schimmel',
    aiHint: 'Bruine vlekken, schimmelvlok of vergeling met vlekken?',
  ),
  MoestuinTaskCatalogItem(
    id: 'uitgebloeide_bloemen',
    labelNl: 'Uitgebloeide bloemen verwijderen',
    aiHint: 'Verwelkte bloemen die verwijderd kunnen worden?',
  ),
  MoestuinTaskCatalogItem(
    id: 'oogsten_plukken',
    labelNl: 'Oogsten / plukken',
    topicKey: 'harvest',
    aiHint: 'Rijpe vruchten, blad of bloemen klaar om te oogsten?',
  ),
  MoestuinTaskCatalogItem(
    id: 'standplaats_licht',
    labelNl: 'Standplaats / licht',
    aiHint: 'Plant lijkt uitgerekt, bleek of schaduwachtig op foto?',
  ),
  MoestuinTaskCatalogItem(
    id: 'gezonde_groei',
    labelNl: 'Gezonde groei',
    aiHint: 'Positief: fris blad, goede kleur, stevige groei zichtbaar?',
  ),
];

MoestuinTaskCatalogItem? catalogItemForTaskId(String taskId) {
  for (final item in kUniversalMoestuinTasks) {
    if (item.id == taskId) return item;
  }
  return null;
}

String? semanticTopicKeyForTaskId(String taskId) {
  final catalog = catalogItemForTaskId(taskId);
  if (catalog?.topicKey != null) return catalog!.topicKey;
  final id = taskId.toLowerCase();
  if (id.contains('water')) return 'water';
  if (id.contains('bladluis') || id.contains('luis')) return 'bladluis';
  if (id.contains('slak')) return 'slak';
  if (id.contains('rups')) return 'rups';
  if (id.contains('witte_vlieg')) return 'witte_vlieg';
  if (id.contains('spint')) return 'spint';
  if (id.contains('trips')) return 'trips';
  if (id.contains('meeldauw')) return 'meeldauw';
  if (id.contains('schimmel')) return 'schimmel';
  if (id.contains('onkruid')) return 'onkruid';
  if (id.contains('bemest') || id.contains('voed')) return 'voeding';
  if (id.contains('snoei') || id.contains('dood_blad') || id.contains('uitdunnen')) {
    return 'snoei';
  }
  if (id.contains('oogst') || id.contains('pluk')) return 'harvest';
  return null;
}
