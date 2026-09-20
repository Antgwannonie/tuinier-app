import '../models/vegetable.dart';
import 'moestuin_companion_plants.dart';

/// Waarom deze plant in de moestuin nuttig is.
enum CompanionBenefitKind {
  pestControl,
  pollination,
  soilHealth,
  biodiversity,
}

extension CompanionBenefitKindLabel on CompanionBenefitKind {
  String get label {
    switch (this) {
      case CompanionBenefitKind.pestControl:
        return 'Tegen plagen';
      case CompanionBenefitKind.pollination:
        return 'Bestuiving';
      case CompanionBenefitKind.soilHealth:
        return 'Bodem';
      case CompanionBenefitKind.biodiversity:
        return 'Biodiversiteit';
    }
  }

  String get emoji {
    switch (this) {
      case CompanionBenefitKind.pestControl:
        return '🐞';
      case CompanionBenefitKind.pollination:
        return '🐝';
      case CompanionBenefitKind.soilHealth:
        return '🌱';
      case CompanionBenefitKind.biodiversity:
        return '🦋';
    }
  }
}

/// Korte info om in één oogopslag te beslissen: nu/hier planten?
class MoestuinCompanionInfo {
  const MoestuinCompanionInfo({
    required this.plantKindLabel,
    required this.benefits,
    required this.goodNearLabels,
    required this.whenToPlant,
    required this.atAGlance,
    this.tip,
  });

  /// bv. "Bloem", "Kruid (in bloei)", "Groenbemester"
  final String plantKindLabel;
  final List<CompanionBenefitKind> benefits;

  /// Gewassen waar je dit het beste naast zet (leesbare namen).
  final List<String> goodNearLabels;

  /// Wanneer zaaien/planten in NL.
  final String whenToPlant;

  /// 1–2 zinnen: hoofdreden + effect.
  final String atAGlance;

  /// Extra tip voor plaatsing of gebruik.
  final String? tip;
}

bool isMoestuinCompanionPlant(Vegetable vegetable) {
  return kMoestuinCompanionPlantIds.contains(vegetable.id) ||
      (vegetable.growthCategory?.toLowerCase().contains('moestuin-bloemen') ??
          false);
}

MoestuinCompanionInfo? moestuinCompanionInfoFor(String vegetableId) {
  return _kCompanionInfo[vegetableId];
}

/// Expliciete info of afgeleid van plantdata voor companion-gewassen.
MoestuinCompanionInfo? moestuinCompanionInfoForVegetable(Vegetable vegetable) {
  final explicit = _kCompanionInfo[vegetable.id];
  if (explicit != null) return explicit;
  if (!isMoestuinCompanionPlant(vegetable)) return null;

  final benefits = <CompanionBenefitKind>[];
  final text = '${vegetable.summary} ${vegetable.care}'.toLowerCase();
  if (text.contains('plaag') ||
      text.contains('bladluis') ||
      text.contains('vlieg') ||
      text.contains('aalt') ||
      text.contains('rups') ||
      text.contains('afschrik')) {
    benefits.add(CompanionBenefitKind.pestControl);
  }
  if (text.contains('bij') ||
      text.contains('hommel') ||
      text.contains('bestui') ||
      text.contains('zweefvlieg')) {
    benefits.add(CompanionBenefitKind.pollination);
  }
  if (text.contains('bodem') ||
      text.contains('groenbemest') ||
      text.contains('stikstof')) {
    benefits.add(CompanionBenefitKind.soilHealth);
  }
  if (benefits.isEmpty) {
    benefits.add(CompanionBenefitKind.biodiversity);
  }

  return MoestuinCompanionInfo(
    plantKindLabel: 'Nuttige moestuinplant',
    benefits: benefits,
    goodNearLabels: const ['Zie samenvatting hieronder'],
    whenToPlant: vegetable.sowingOutdoors,
    atAGlance: vegetable.summary,
    tip: vegetable.harvestTips.trim().isNotEmpty ? vegetable.harvestTips : null,
  );
}

const Map<String, MoestuinCompanionInfo> _kCompanionInfo = {
  'zonnebloem': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem (hoog)',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Maïs', 'Komkommer', 'Courgette', 'Rand van het bed'],
    whenToPlant: 'April–mei zaaien · bloei juli–september',
    atAGlance:
        'Trekt bijen en hommels; helpt bestuiving van peulgewassen en pompoenachtigen.',
    tip: 'Aan de zonnige rand van de moestuin; kan windscherm voor lage groenten.',
  ),
  'afrikaantje': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.soilHealth,
    ],
    goodNearLabels: ['Tomaat', 'Paprika', 'Ui', 'Kool'],
    whenToPlant: 'Maart–mei voorzaaien · bloei juni–oktober',
    atAGlance:
        'Kan wortelknobbelaaltjes remmen (sterkst bij dichte voorteelt op dezelfde plek); '
        'plant na IJsheiligen tussen rijen of als bed-voorteelt.',
    tip: 'Lage en hoge tagetes: beide nuttig; verwacht geen wonder van 2–3 losse plantjes.',
  ),
  'tagetes_patula': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem (laag)',
    benefits: [
      CompanionBenefitKind.pestControl,
    ],
    goodNearLabels: ['Tomaat', 'Paprika', 'Ui', 'Aardappel'],
    whenToPlant: 'Mei–juni uitplanten · bloei zomer',
    atAGlance:
        'Lage Tagetes patula; aaltjeswerking het sterkst bij dichtere inzet of voorteelt, '
        'plus nuttige insecten tussen nachtschade.',
  ),
  'goudsbloem': MoestuinCompanionInfo(
    plantKindLabel: 'Eetbare bloem',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Boon', 'Sla', 'Tomaat', 'Komkommer'],
    whenToPlant: 'Maart–juni doorzaaien · bloei juni–oktober',
    atAGlance:
        'Trekt lieveheersbeestjes tegen bladluis; bloembladeren zijn eetbaar.',
  ),
  'calendula_officinalis': MoestuinCompanionInfo(
    plantKindLabel: 'Eetbare bloem',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Sla', 'Boon', 'Tomaat'],
    whenToPlant: 'April–juni · bloei de hele zomer',
    atAGlance: 'Vangt en verstoort bladluis; vrolijke rand langs paden.',
  ),
  'oostindische_kers': MoestuinCompanionInfo(
    plantKindLabel: 'Eetbare bloem / vangplant',
    benefits: [CompanionBenefitKind.pestControl],
    goodNearLabels: ['Kool', 'Tomaat', 'Komkommer', 'Courgette'],
    whenToPlant: 'Mei–juni direct zaaien · bloei juli–oktober',
    atAGlance:
        'Trek bladluis weg van kool en komkommer; plant iets verder van hoofdteelt.',
    tip: 'Niet te dicht op jonge koolplanten, eerst als lokmiddel verderop.',
  ),
  'komkommerkruid': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem & blad',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Tomaat', 'Courgette', 'Komkommer', 'Aardbei'],
    whenToPlant: 'April–mei · bloei juni–september',
    atAGlance:
        'Sterke bijenplant; klassieke buur van tomaten en courgette voor betere vruchtzetting.',
  ),
  'facelia': MoestuinCompanionInfo(
    plantKindLabel: 'Groenbemester & bijenplant',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.soilHealth,
    ],
    goodNearLabels: ['Tussen rijen', 'Na vroege oogst', 'Fruit', 'Bonen'],
    whenToPlant: 'April–augustus inzaaien · bloei 6–8 weken later',
    atAGlance:
        'Top voor bijen; verbetert bodemstructuur als je na bloei uitspit.',
    tip: 'Ideaal om lege plek na radijs of sla op te vullen.',
  ),
  'korenbloem': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Rand moestuin', 'Bonen', 'Uien'],
    whenToPlant: 'Maart–april · bloei zomer',
    atAGlance: 'Eenvoudige randbloem; trekt bijen en nuttige insecten.',
  ),
  'cosmos': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Rand', 'Tomaten', 'Pompoen'],
    whenToPlant: 'Mei–juni · bloei juli tot vorst',
    atAGlance: 'Lang bloeiend; voedsel voor bijen en lieveheersbeestjes.',
  ),
  'boekweit': MoestuinCompanionInfo(
    plantKindLabel: 'Groenbemester',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.soilHealth,
    ],
    goodNearLabels: ['Lege plek', 'Tussen rijen', 'Voor herfstteelt'],
    whenToPlant: 'Mei–augustus · bloei binnen 6 weken',
    atAGlance: 'Snelle bijenplant; verbetert bodem als groenbemesting.',
  ),
  'witte_klaver': MoestuinCompanionInfo(
    plantKindLabel: 'Groenbemester',
    benefits: [
      CompanionBenefitKind.soilHealth,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Fruitbomen', 'Struiken', 'Rustige hoek'],
    whenToPlant: 'Maart–september inzaaien',
    atAGlance: 'Vangt stikstof; laag tapijt onder fruit of langs pad.',
  ),
  'rode_klaver': MoestuinCompanionInfo(
    plantKindLabel: 'Groenbemester',
    benefits: [
      CompanionBenefitKind.soilHealth,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Fruit', 'Tussen rijen (tijdelijk)'],
    whenToPlant: 'Voorjaar of na oogst',
    atAGlance: 'Groenbemester met bijenbloei; even snijden vóór je weer zaait.',
  ),
  'duizendblad': MoestuinCompanionInfo(
    plantKindLabel: 'Kruidachtige bloem',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Kool', 'Tomaat', 'Komkommer', 'Rand'],
    whenToPlant: 'Maart–mei · bloei zomer',
    atAGlance: 'Trekt parasietwespen en lieveheersbeestjes; versterkt buurtplanten.',
  ),
  'zaadslurf': MoestuinCompanionInfo(
    plantKindLabel: 'Laag bloeitapijt',
    benefits: [CompanionBenefitKind.pestControl],
    goodNearLabels: ['Sla', 'Aardbei', 'Kool', 'Tomaat'],
    whenToPlant: 'Mei–juni · bloei de hele zomer',
    atAGlance:
        'Zoete geur trekt zweefvliegen die bladluis eten, ideaal tussen lage gewassen.',
  ),
  'alyssum_sneeuw': MoestuinCompanionInfo(
    plantKindLabel: 'Laag bloeitapijt',
    benefits: [CompanionBenefitKind.pestControl],
    goodNearLabels: ['Sla', 'Aardbei', 'Kool'],
    whenToPlant: 'Mei–juni · laag houden',
    atAGlance: 'Zweefvliegen tegen bladluis; mooi op voorgrond van bed.',
  ),
  'limnanthes': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem (bijenmagnet)',
    benefits: [CompanionBenefitKind.pollination],
    goodNearLabels: ['Aardbei', 'Fruit', 'Bonen', 'Komkommer'],
    whenToPlant: 'April–mei · bloei mei–juli',
    atAGlance: '“Slakkenplantje”, enorme bijenaantrek; kort en fel geel.',
  ),
  'monarda': MoestuinCompanionInfo(
    plantKindLabel: 'Vaste bloem',
    benefits: [CompanionBenefitKind.pollination],
    goodNearLabels: ['Pompoen', 'Courgette', 'Komkommer', 'Fruit'],
    whenToPlant: 'Voorjaar planten · bloei zomer',
    atAGlance: 'Hommels en bijen; helpt bestuiving van pompoenfamilie.',
  ),
  'zonnehoed': MoestuinCompanionInfo(
    plantKindLabel: 'Vaste bloem',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Rand moestuin', 'Kruiden', 'Fruit'],
    whenToPlant: 'Plant of zaai · bloei zomer–herfst',
    atAGlance: 'Vlinders en bijen; decoratief en nuttig op de rand.',
  ),
  'verbena': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem',
    benefits: [CompanionBenefitKind.pollination],
    goodNearLabels: ['Kas', 'Tomaten', 'Rand'],
    whenToPlant: 'Mei–juni · lang bloeiend',
    atAGlance: 'Langdurige bijenbron; ook in pot bij terras-tuin.',
  ),
  'wilde_marjolein': MoestuinCompanionInfo(
    plantKindLabel: 'Kruid',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Kool', 'Boon', 'Wortel'],
    whenToPlant: 'Mei · bloei zomer',
    atAGlance: 'Geur verstoort sommige insecten; trekt ook bestuivers.',
  ),
  'hysop': MoestuinCompanionInfo(
    plantKindLabel: 'Kruid',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Kool', 'Druif', 'Sla'],
    whenToPlant: 'Voorjaar · vaste plant',
    atAGlance: 'Traditioneel bij kool en druif; blauwe bloemen voor bijen.',
  ),
  'mosterd_geel': MoestuinCompanionInfo(
    plantKindLabel: 'Groenbemester / vangplant',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.soilHealth,
    ],
    goodNearLabels: ['Vóór koolteelt', 'Leeg bed'],
    whenToPlant: 'April–september · niet vlak vóór kool zaaien',
    atAGlance: 'Vangt koolvlieg; verbetert bodem, wel 4 weken voor kool oogsten/uitspitten.',
    tip: 'Niet direct vóór broccoli of spruitkool zaaien (zelfde familie).',
  ),
  'klaproos': MoestuinCompanionInfo(
    plantKindLabel: 'Randbloem',
    benefits: [CompanionBenefitKind.biodiversity],
    goodNearLabels: ['Rand', 'Wilde hoek'],
    whenToPlant: 'Herfst of voorjaar zaaien',
    atAGlance: 'Verhoogt biodiversiteit; rustplek voor nuttige insecten.',
  ),
  'bijenmengsel': MoestuinCompanionInfo(
    plantKindLabel: 'Zaadmengsel',
    benefits: [CompanionBenefitKind.pollination],
    goodNearLabels: ['Tussen rijen', 'Bonen', 'Fruit', 'Komkommer'],
    whenToPlant: 'Mei–augustus strooien',
    atAGlance: 'Snelle mix voor bestuiving; inzaaien waar een plek leeg is.',
  ),
  'lindebloesem': MoestuinCompanionInfo(
    plantKindLabel: 'Boom (groot)',
    benefits: [CompanionBenefitKind.pollination],
    goodNearLabels: ['Hele tuin (hommels)', 'Fruit in de buurt'],
    whenToPlant: 'Jonge boom planten · bloei juni',
    atAGlance: 'Hommel- en bijenboom op lange termijn; alleen bij ruime tuin.',
    tip: 'Geen ideale keuze in klein bed, kies facelia of klaver in de moestuin zelf.',
  ),
  'ui_bloei': MoestuinCompanionInfo(
    plantKindLabel: 'Ui in bloei',
    benefits: [CompanionBenefitKind.pestControl],
    goodNearLabels: ['Wortel', 'Prei', 'Tomaat', 'Sla'],
    whenToPlant: 'Laat een deel van je ui doorbloeien',
    atAGlance: 'Uiengeur helpt wortel en prei; laat bewust 2–3 stuks bloeien.',
  ),
  'look_bloei': MoestuinCompanionInfo(
    plantKindLabel: 'Look in bloei',
    benefits: [CompanionBenefitKind.pestControl],
    goodNearLabels: ['Tomaat', 'Aardbei', 'Roos', 'Fruit'],
    whenToPlant: 'Laat knoflook/look doorbloeien',
    atAGlance: 'Afschrikkend op diverse plagen; sterke geur rond buurtplanten.',
  ),
  'dille_bloei': MoestuinCompanionInfo(
    plantKindLabel: 'Kruid in bloei',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Kool', 'Komkommer', 'Tomaat'],
    whenToPlant: 'Zaai door; laat deel bloeien',
    atAGlance: 'Zweefvliegen en parasietwespen, ideaal tussen kool.',
  ),
  'koriander_bloei': MoestuinCompanionInfo(
    plantKindLabel: 'Kruid in bloei',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.pestControl,
    ],
    goodNearLabels: ['Tomaat', 'Komkommer', 'Aardbei'],
    whenToPlant: 'Doorzaaien elke 3 weken',
    atAGlance: 'Bloei trekt nuttige insecten; zaai regelmatig door voor lang effect.',
  ),
  'lavendel': MoestuinCompanionInfo(
    plantKindLabel: 'Vaste kruid',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Pad', 'Aardbei', 'Rozen', 'Fruit'],
    whenToPlant: 'Voorjaar planten · zon',
    atAGlance: 'Geur op wolluis en mot; bijen in de zomer.',
  ),
  'zinnia': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem (snij)',
    benefits: [
      CompanionBenefitKind.pollination,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Tomaat', 'Komkommer', 'Rand van het bed'],
    whenToPlant: 'Mei zaaien/uitplanten · bloei juli–oktober',
    atAGlance:
        'Kleurrijke snijbloem die bijen en vlinders lokt tussen groenten.',
    tip: 'Deadhead voor langere bloei; laat eind zomer wat staan voor zaad.',
  ),
  'lupine_groenbemester': MoestuinCompanionInfo(
    plantKindLabel: 'Groenbemester',
    benefits: [
      CompanionBenefitKind.soilHealth,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Na vroege oogst', 'Braak liggend bed', 'Fruit'],
    whenToPlant: 'Voorjaar of nazomer inzaaien',
    atAGlance:
        'Stikstofbinder die de bodem verrijkt en bijen lokt tijdens de bloei.',
    tip: 'Werk onder vóór zaadvorming als je vooral bemesting wilt.',
  ),
  'stiefmoedje': MoestuinCompanionInfo(
    plantKindLabel: 'Bloem (rand)',
    benefits: [
      CompanionBenefitKind.biodiversity,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Pad', 'Potten', 'Rand moestuin'],
    whenToPlant: 'Voorjaar of najaar planten · koele bloei',
    atAGlance:
        'Vrolijke randplant die vroeg en laat in het seizoen kleur en insecten brengt.',
  ),
  'ringelbloem': MoestuinCompanionInfo(
    plantKindLabel: 'Eetbare bloem',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.biodiversity,
    ],
    goodNearLabels: ['Boon', 'Sla', 'Tomaat', 'Komkommer'],
    whenToPlant: 'Maart–juni doorzaaien · bloei juni–oktober',
    atAGlance:
        'Synoniem/variant van goudsbloem: lokt nuttige insecten; bloembladeren eetbaar.',
  ),
  'salie_bloei': MoestuinCompanionInfo(
    plantKindLabel: 'Kruid in bloei',
    benefits: [CompanionBenefitKind.pestControl],
    goodNearLabels: ['Kool', 'Wortel', 'Aardbei'],
    whenToPlant: 'Vaste plant · bloei voorjaar',
    atAGlance: 'Helpt koolmot verminderen; plant bij koolgewassen.',
  ),
  'tijm_bloei': MoestuinCompanionInfo(
    plantKindLabel: 'Kruid in bloei',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Kool', 'Aardbei', 'Pad tussen tegels'],
    whenToPlant: 'Vaste plant · zon en doorlatend',
    atAGlance: 'Laag en droogtolerant; tegen koolbladluis.',
  ),
  'basilicum_bloei': MoestuinCompanionInfo(
    plantKindLabel: 'Kruid in bloei',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Tomaat', 'Paprika', 'Komkommer'],
    whenToPlant: 'Mei–juni · knip voor keuken, laat deel bloeien',
    atAGlance: 'Versterkt tomaat en paprika; bloei trekt bestuivers.',
  ),
  'munt_bloei': MoestuinCompanionInfo(
    plantKindLabel: 'Kruid in bloei',
    benefits: [
      CompanionBenefitKind.pestControl,
      CompanionBenefitKind.pollination,
    ],
    goodNearLabels: ['Aardbei', 'Kool (op afstand)', 'In pot'],
    whenToPlant: 'Altijd in pot · anders verspreidt hij',
    atAGlance: 'Geur op mieren en kevers; bloei voor bijen.',
    tip: 'Altijd in pot plaatsen, wortels kunnen andere planten overwoekeren.',
  ),
};
