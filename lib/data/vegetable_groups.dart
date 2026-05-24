import '../models/vegetable_group.dart';

/// Verzamelkopjes met alle soorten die in de app onder die familie vallen.
const List<VegetableGroup> kVegetableGroups = [
  VegetableGroup(
    id: 'bieten',
    nameNl: 'Bieten',
    vegetableIds: ['rode_biet'],
  ),
  VegetableGroup(
    id: 'sla_soorten',
    nameNl: 'Sla soorten',
    vegetableIds: ['sla', 'ijsbergsla'],
  ),
  VegetableGroup(
    id: 'bladgroenten',
    nameNl: 'Bladgroenten',
    vegetableIds: [
      'spinazie',
      'rucola',
      'andijvie',
      'postelein',
      'snijbiet',
      'tuinkers',
    ],
  ),
  VegetableGroup(
    id: 'wortelgroenten',
    nameNl: 'Wortelgroenten',
    vegetableIds: ['wortel', 'radijs', 'pastinaak'],
  ),
  VegetableGroup(
    id: 'tomaten',
    nameNl: 'Tomaten',
    vegetableIds: ['tomaat', 'snoeptomaat'],
  ),
  VegetableGroup(
    id: 'paprika_peper',
    nameNl: 'Paprika & peper',
    vegetableIds: ['paprika', 'peper'],
  ),
  VegetableGroup(
    id: 'komkommer_familie',
    nameNl: 'Komkommer & courgette',
    vegetableIds: [
      'snackkomkommer',
      'komkommer',
      'cucamelon',
      'courgette',
      'augurk',
      'pompoen',
    ],
  ),
  VegetableGroup(
    id: 'bonen',
    nameNl: 'Bonen & erwten',
    vegetableIds: [
      'bonen_sperzie',
      'snijbonen',
      'doperwt',
      'tuinboon',
      'sugarsnaps',
    ],
  ),
  VegetableGroup(
    id: 'uien',
    nameNl: 'Uien & look',
    vegetableIds: ['bosui', 'ui', 'prei', 'knoflook', 'sjalot', 'lente_ui'],
  ),
  VegetableGroup(
    id: 'kolen',
    nameNl: 'Koolgewassen',
    vegetableIds: [
      'boerenkool',
      'broccoli',
      'koolrabi',
      'raps_kool',
      'wittekool',
      'rodekool',
      'bloemkool',
      'spruitkool',
      'paksoi',
      'koolraap',
    ],
  ),
  VegetableGroup(
    id: 'aardappel',
    nameNl: 'Aardappel',
    vegetableIds: ['aardappel'],
  ),
  VegetableGroup(
    id: 'aubergine',
    nameNl: 'Aubergine',
    vegetableIds: ['aubergine'],
  ),
  VegetableGroup(
    id: 'aardbeien',
    nameNl: 'Aardbeien',
    vegetableIds: ['aardbei'],
  ),
  VegetableGroup(
    id: 'mais',
    nameNl: 'Mais',
    vegetableIds: ['mais'],
  ),
  VegetableGroup(
    id: 'meerjarig',
    nameNl: 'Meerjarig',
    vegetableIds: ['rabarber', 'asperge'],
  ),
];

VegetableGroup? vegetableGroupById(String id) {
  for (final g in kVegetableGroups) {
    if (g.id == id) return g;
  }
  return null;
}
