import '../models/vegetable.dart';
import 'crop_lifecycle_metadata.dart';

/// Gewas waar je met een truc meerdere keren kunt oogsten (niet alleen één keer).
class ExtendedHarvestGuide {
  const ExtendedHarvestGuide({
    required this.leadIn,
    required this.repeatedHarvest,
    required this.oneShotHarvest,
  });

  /// Korte intro bovenaan Oogst-info.
  final String leadIn;

  /// Truc voor doorlopend / herhaald oogsten.
  final String repeatedHarvest;

  /// Alles in één keer oogsten.
  final String oneShotHarvest;
}

bool _id(Vegetable v, String id) => v.id == id;

bool _idContains(Vegetable v, String part) => v.id.contains(part);

bool _isSla(Vegetable v) =>
    _idContains(v, 'sla') && !v.id.contains('slak') && !v.id.contains('slab');

bool _isLeafyCutAndComeAgain(Vegetable v) {
  if (_isSla(v)) return true;
  const ids = {
    'spinazie',
    'spinazie_winter',
    'rucola',
    'rucola_wild',
    'veldsla',
    'postelein',
    'paksoi',
    'tatsoi',
    'mizuna',
    'mesclun',
    'andijvie',
    'chinese_kool',
    'sla_snij',
  };
  if (ids.contains(v.id)) return true;
  return v.id.contains('spinazie') || v.id.contains('rucola');
}

bool _isKaleFamily(Vegetable v) {
  const ids = {
    'boerenkool',
    'palmkool',
    'spruitkool',
    'kool_raap',
    'koolgroen',
  };
  return ids.contains(v.id) || v.id.contains('boerenkool') || v.id.contains('palmkool');
}

bool _isHerbPinch(Vegetable v) {
  const ids = {
    'basilicum',
    'peterselie',
    'dille',
    'koriander',
    'munt',
    'tijm',
    'salie',
    'bieslook',
    'bieslook_bos',
    'oregano',
    'marjolein',
    'bonenkruid',
    'citroenmelisse',
  };
  if (ids.contains(v.id)) return true;
  final fam = v.family.toLowerCase();
  return fam.contains('kruid') && !v.id.contains('bloei');
}

ExtendedHarvestGuide? extendedHarvestGuideFor(Vegetable vegetable) {
  if (harvestPatternFor(vegetable) == CropHarvestPattern.continuous) {
    return null;
  }

  if (_isSla(vegetable)) {
    return ExtendedHarvestGuide(
      leadIn:
          'Bij sla hoef je niet te wachten op één groot moment. Met de juiste '
          'methode oogst je meerdere keren. Of je haalt alles in één keer weg.',
      repeatedHarvest:
          'Pluk of snij alleen de buitenste bladeren, laat het hart in het '
          'midden staan. De plant maakt steeds nieuwe bladeren aan, zo kun je '
          'wekenlang kleine porties oogsten.\n\n'
          'Tip: oogst in de ochtend als het koel is; geef na het plukken water '
          'bij droog weer.',
      oneShotHarvest:
          'Snij de hele rozet af net boven de grond als de krop vol en stevig '
          'is. Dat is één grote oogst. Daarna is de plant klaar voor dit seizoen.',
    );
  }

  if (_idContains(vegetable, 'spinazie')) {
    return ExtendedHarvestGuide(
      leadIn:
          'Spinazie kun je herhaald oogsten door alleen de buitenste bladeren '
          'te halen, of alles in één keer.',
      repeatedHarvest:
          'Knip of pluk de grootste buitenste bladeren, laat het hart staan. '
          'Bij koel weer en voldoende water schiet spinazie opnieuw uit.\n\n'
          'Oogst niet te laat. Bij warmte schiet spinazie snel door naar bloei.',
      oneShotHarvest:
          'Snij de hele plant af net boven de grond als je genoeg blad hebt. '
          'Dat is één oogst; de plant komt meestal niet meer terug.',
    );
  }

  if (_id(vegetable, 'sla_snij') ||
      vegetable.nameNl.toLowerCase().contains('snijsla')) {
    return ExtendedHarvestGuide(
      leadIn:
          'Snijsla groeit na het afknippen opnieuw uit, ideaal voor meerdere '
          'kleine oogsten.',
      repeatedHarvest:
          'Snij alle bladeren af op 2–3 cm boven de grond. Houd de wortel intact '
          'en geef water. Vaak krijg je na 2–3 weken een tweede (kleinere) oogst.',
      oneShotHarvest:
          'Wil je maar één keer oogsten? Snij dan alles af en ruim de plant op '
          'als hij niet meer mooi terugkomt.',
    );
  }

  if (_isLeafyCutAndComeAgain(vegetable) && !_isSla(vegetable)) {
    final name = vegetable.nameNl;
    return ExtendedHarvestGuide(
      leadIn:
          'Bij $name kun je meerdere keren oogsten door steeds de buitenste '
          'delen te halen, of alles in één keer.',
      repeatedHarvest:
          'Oogst de buitenste bladeren of blaadjes en laat het groeipunt in '
          'het midden staan. Zo blijft de plant produceren.\n\n'
          'Regelmatig klein oogsten is vaak lekkerder dan één keer alles '
          'tegelijk.',
      oneShotHarvest:
          'Snij de hele plant af net boven de grond als hij groot genoeg is. '
          'Daarna is dit seizoen voorbij voor deze plant.',
    );
  }

  if (_isKaleFamily(vegetable)) {
    return ExtendedHarvestGuide(
      leadIn:
          'Boerenkool en verwanten geven de hele winter blad, je hoeft niet '
          'alles in één keer te oogsten.',
      repeatedHarvest:
          'Pluk onderste bladeren eerst, laat de top groeien. De plant blijft '
          'omhoog produceren, zo oogst je maandenlang.\n\n'
          'Na lichte vorst smaakt het vaak zoeter.',
      oneShotHarvest:
          'Snij de hele plant af bij de stam als je alles tegelijk wilt '
          'verwerken of ruimte nodig hebt.',
    );
  }

  if (_id(vegetable, 'broccoli') || _idContains(vegetable, 'broccoli')) {
    return ExtendedHarvestGuide(
      leadIn:
          'Na de hoofdbloemkool kun je vaak nog wekenlang zijscheuten oogsten.',
      repeatedHarvest:
          'Oogst de hoofdbloem op tijd (nog compact, knoppen nog dicht). Laat '
          'de plant staan, er komen zijscheuten met kleinere roosjes.\n\n'
          'Pluk die zijscheuten regelmatig zodat de plant doorproduceert.',
      oneShotHarvest:
          'Alleen de hoofdbloem geoogst en geen zijscheuten meer? Dan is de '
          'plant klaar, rond het seizoen af.',
    );
  }

  if (_id(vegetable, 'prei') || _idContains(vegetable, 'prei')) {
    return ExtendedHarvestGuide(
      leadIn:
          'Prei kun je geleidelijk oogsten, niet alles hoeft tegelijk uit de '
          'grond.',
      repeatedHarvest:
          'Trek of snij één prei tegelijk uit de rij als je die nodig hebt. '
          'De rest blijft staan en groeit door tot vorst.\n\n'
          'Aarde rond de stengel houdt het witte deel langer mals.',
      oneShotHarvest:
          'Trek alle preien uit de grond vóór strenge vorst als je ze in één '
          'keer wilt bewaren of verwerken.',
    );
  }

  if (_isHerbPinch(vegetable)) {
    final name = vegetable.nameNl;
    return ExtendedHarvestGuide(
      leadIn:
          'Bij $name stimuleer je nieuwe groei door regelmatig te knippen, '
          'of je oogst de hele plant in één keer.',
      repeatedHarvest:
          'Knip steeds de bovenste scheuten of bladeren, net boven een bladpaar. '
          'De plant wordt bossiger en je kunt het hele seizoen blijven oogsten.\n\n'
          'Knip bloemen weg als je vooral blad wilt.',
      oneShotHarvest:
          'Snij de hele plant af of trek hem uit als je een grote voorraad '
          'wilt drogen of verwerken, daarna is hij klaar.',
    );
  }

  if (_idContains(vegetable, 'wortel') && !vegetable.id.contains('pastinaak')) {
    return ExtendedHarvestGuide(
      leadIn:
          'Wortels hoef je niet allemaal tegelijk te oogsten, je kunt '
          'dunneren en tussentijds al oogsten.',
      repeatedHarvest:
          'Trek elke tweede wortel uit als verdunning zodra het loof dicht '
          'staat. De overgebleven wortels worden groter.\n\n'
          'Zo heb je meerdere kleine oogsten in plaats van één grote.',
      oneShotHarvest:
          'Trek of spit alle wortels in één keer uit bij natte bodem als het '
          'oogstvenster of het weer dat vraagt.',
    );
  }

  if (_idContains(vegetable, 'radijs') && !vegetable.id.contains('zwarte')) {
    return ExtendedHarvestGuide(
      leadIn:
          'Radijs groeit snel, oogst jonge knollen regelmatig zodat er ruimte '
          'blijft voor nieuwe.',
      repeatedHarvest:
          'Pluk de grootste radijsjes uit de rij en laat kleinere staan. '
          'Zaai eventueel elke paar weken bij voor een constante oogst.\n\n'
          'Te lang laten staan = houtachtig en gaat door naar bloei.',
      oneShotHarvest:
          'Trek de hele rij in één keer als alles de gewenste grootte heeft.',
    );
  }

  if (_idContains(vegetable, 'biet') || _id(vegetable, 'rode_biet')) {
    return ExtendedHarvestGuide(
      leadIn:
          'Biet levert zowel jong blad als knollen, je kunt tussentijds al '
          'oogsten.',
      repeatedHarvest:
          'Pluk af en toe een paar buitenste bladeren voor in de salade (niet '
          'te veel, laat genoeg loof voor de knol).\n\n'
          'Later oogst je de knollen wanneer ze de gewenste grootte hebben.',
      oneShotHarvest:
          'Trek alle bieten uit de grond in één keer als de knollen groot '
          'genoeg zijn.',
    );
  }

  if (_id(vegetable, 'spruitkool') ||
      (_idContains(vegetable, 'spruit') && vegetable.id.contains('kool'))) {
    return ExtendedHarvestGuide(
      leadIn:
          'Spruitjes oogst je van onder naar boven, meerdere keren, niet '
          'alles tegelijk.',
      repeatedHarvest:
          'Pluk eerst de onderste, rijpe spruiten. De bovenste groeien door '
          'en worden later rijp.\n\n'
          'Zo verspreid je de oogst over weken.',
      oneShotHarvest:
          'Knip de hele koolstronk met alle spruiten tegelijk als je alles in '
          'één keer wilt invriezen of verwerken.',
    );
  }

  return null;
}

bool hasExtendedHarvestTricks(Vegetable vegetable) =>
    extendedHarvestGuideFor(vegetable) != null;

/// Korte regel op de moestuin-kaart (uitklapbare oogst-sectie).
String extendedHarvestExpandHint() {
  return 'Voor meer oogst zie Oogst-info, of oogst alles in één keer.\n\n'
      'Zolang er nog te oogsten valt: houd de plant actief bij in je moestuin.\n\n'
      'Klaar met oogsten? Rond het seizoen af. Dan stoppen we de plant voor '
      'dit seizoen. Tot volgend seizoen.';
}
