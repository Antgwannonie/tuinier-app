import '../models/vegetable.dart';
import 'crop_harvest_kind.dart';
import 'underground_crop.dart';

/// Gewassen waar je de oogst direct op de foto kunt zien (vruchten, peulen, bessen).
bool isVisibleFruitCrop(Vegetable vegetable) {
  if (isUndergroundCrop(vegetable)) return false;
  if (isMoestuinBloomCrop(vegetable)) return false;

  final id = vegetable.id.toLowerCase();
  if (_kVisibleFruitCropIds.contains(id)) return true;

  if (id.contains('tomaat') ||
      id.contains('komkommer') ||
      id.contains('courgette') ||
      id.contains('paprika') ||
      id.contains('peper') ||
      id.contains('aubergine') ||
      id.contains('meloen') ||
      id.contains('pompoen') ||
      id.contains('augurk') ||
      id.contains('physalis') ||
      id.contains('aardbei') ||
      id.contains('framboos') ||
      id.contains('bes') ||
      id.contains('cucamelon')) {
    return true;
  }

  final family = vegetable.family.toLowerCase();
  if (family.contains('nachtschade') ||
      family.contains('komkommer') ||
      family.contains('cucurbit') ||
      family.contains('pompoen') ||
      family.contains('meloen') ||
      family.contains('peulvrucht') ||
      family.contains('bessen')) {
    return true;
  }

  final text =
      '${vegetable.summary} ${vegetable.harvest} ${vegetable.harvestTips}'
          .toLowerCase();
  return text.contains('vrucht') ||
      text.contains('peul') ||
      text.contains('bes') ||
      text.contains('pluk');
}

const Set<String> _kVisibleFruitCropIds = {
  'courgette',
  'komkommer',
  'snackkomkommer',
  'cucamelon',
  'tomaat',
  'snoeptomaat',
  'rode_paprika',
  'peper',
  'aubergine',
  'pompoen',
  'flespompoen',
  'meloen',
  'watermeloen',
  'aardbei',
  'bonen_sperzie',
  'snijbonen',
  'doperwten',
  'sugarsnap',
  'physalis',
};

/// Referentiematen (supermarkt / keuken) voor de AI-prompt.
String visibleFruitSizeReferenceFor(Vegetable vegetable) {
  final id = vegetable.id.toLowerCase();
  final tips = vegetable.harvestTips.trim();
  final harvest = vegetable.harvest.trim();

  String specific;
  if (id.contains('courgette')) {
    specific =
        'Courgette supermarkt: ca. 15–25 cm lang, 3–5 cm diameter, glanzend donkergroen, '
        'stevig maar niet houtachtig. Te klein (<12 cm): nog laten groeien. '
        'Te groot (>30 cm of dik als fles): vaak minder smaak, wel nog eetbaar of beter voor soep.';
  } else if (id.contains('cucamelon') || id.contains('augurk') || id == 'snackkomkommer') {
    specific =
        'Mini-komkommer/augurk: supermarkt snackformaat ca. 2–4 cm, stevig en glanzend. '
        'Groter dan 5–6 cm: sneller bitter of zaadrijper.';
  } else if (id.contains('komkommer')) {
    specific =
        'Komkommer supermarkt: ca. 20–35 cm, uniform groen, stevig, geen gele uiteinden. '
        'Jonge vruchten (10–15 cm): nog laten groeien tenzij augurk-formaat gewenst.';
  } else if (id.contains('tomaat')) {
    specific =
        'Tomaat supermarkt: volle rijpe kleur (rood/geel/oranje), stevig maar licht meegeefend, '
        'geen harde groene schouders. Ondermaatse groene vruchten: nog laten rijpen. '
        'Gebarsten maar gekleurde vruchten: vaak rijp genoeg om te eten.';
  } else if (id.contains('paprika') || id.contains('peper')) {
    specific =
        'Paprika/peper supermarkt: volle kleur (rood/geel/oranje/groen afhankelijk van ras), '
        'glad en stevig, volle wanddikte. Klein en donkergroen: nog groeien. '
        'Chili: volle kleur en stevig; groen kan ook eetbaar maar milder.';
  } else if (id.contains('aubergine')) {
    specific =
        'Aubergine supermarkt: glanzende huid, 15–25 cm, stevig maar niet hard als hout. '
        'Te groot of dof/gelb: vaak bitter, liever jonger oogsten.';
  } else if (id.contains('pompoen') && !id.contains('fles')) {
    specific =
        'Pompoen: harde schil, diepe kleur, stengel droog; supermarkt Hokkaido ca. 15–25 cm doorsnee. '
        'Hele grote vruchten: rijp als stengel droog en klank hol bij tikken (moeilijk op foto).';
  } else if (id.contains('meloen') || id.contains('watermeloen')) {
    specific =
        'Meloen: rijp bij typische geur, lichte inspringing bij bloemkant, geen groene harde schil meer. '
        'Watermeloen: veldvlak dof, klank hol (foto alleen: kleur en matuur patroon op schil).';
  } else if (id.contains('aardbei') || id.contains('framboos') || id.contains('bes')) {
    specific =
        'Aardbei/bes supermarkt: volle rode kleur, geen witte schouders, stevig. '
        'Deels wit: nog 2–5 dagen. Te donker/zacht: direct eten of verwerken.';
  } else if (id.contains('boon') || id.contains('peul') || id.contains('erwt')) {
    specific =
        'Sperziebonen/snijbonen: peul ca. 10–18 cm, smal, geen zichtbare bonen erin (anders taai). '
        'Doperwten: peul gezwollen maar nog groen en glanzend.';
  } else {
    specific =
        'Vergelijk zichtbare vruchten met wat je in de supermarkt ziet: lengte, diameter, kleur en stevigheid. '
        'Gebruik blad, hand of bloem in beeld als schaalvergelijking.';
  }

  final extra = <String>[
    if (harvest.isNotEmpty) 'Teeltinfo oogst: $harvest',
    if (tips.isNotEmpty) 'Tuiniertip: $tips',
  ].join('\n');

  return '$specific\n$extra';
}

/// Promptblok voor zichtbare vruchten op de plantfoto.
String buildVisibleFruitHarvestPromptSection(Vegetable vegetable) {
  return '''

ZICHTBARE VRUCHTEN OP DE PLANT (${vegetable.nameNl}):
De oogst is ZICHTBAAR op deze foto. Beoordeel elke zichtbare vrucht of peul op GROOTTE en RIJPHEID.

${visibleFruitSizeReferenceFor(vegetable)}

VERPLICHTE BEOORDELING (als er vruchten/peulen/bessen zichtbaar zijn):
1. Schat de grootte per zichtbare vrucht in cm (lengte en/of diameter). Gebruik blad, hand, bloem of steel als referentie in beeld.
2. Vergelijk expliciet met supermarktformaat: "kleiner dan supermarkt", "ongeveer supermarktformaat", "groter dan supermarkt / te groot".
3. Beoordeel rijpheid: kleur, glans, stevigheid, geen harde groene zones (waar van toepassing).
4. ripenessNote in insight VERPLICHT (2-4 zinnen NL): geschatte maat + supermarktvergelijking + rijp of nog wachten.
5. fruitHarvestNote VERPLICHT (3-5 zinnen NL): wat je op de foto ziet, welke vruchten oogstbaar zijn, welke nog moeten groeien.
6. harvestReady in insight:
   - true als minstens één vrucht duidelijk supermarktformaat EN eetrijp lijkt (kleur + stevigheid).
   - false als alleen kleine/jonge vruchten zichtbaar zijn, of alles duidelijk onrijp.
7. phase:
   - "fruiting" = alleen kleine jonge vruchten net gevormd.
   - "almost_ripe" = vruchten bijna supermarktformaat of bijna volle kleur.
   - "ripe" = duidelijk eetrijp supermarktformaat op de foto.
8. daysUntilHarvest: 0 bij harvestReady=true; anders schat dagen tot supermarktformaat (bij kleine vruchten).
9. Wees niet te terughoudend: als een vrucht duidelijk volwassen en supermarktformaat is, zet harvestReady=true en phase="ripe".
10. Bij meerdere vruchten: vermeld in ripenessNote welke wel/niet geoogst kunnen worden.
11. coachTasks: mag kind "harvest" als er nu geoogst kan worden.

Als er GEEN vruchten zichtbaar zijn (alleen blad/bloei): fruitHarvestNote=null, beoordeel fase normaal.
''';
}
