import '../models/vegetable.dart';
import 'plant_factory.dart';

/// Nuttige bloemen en planten voor moestuin: plagen weren en bestuiving (NL).
final List<Vegetable> kMoestuinCompanionPlants = _parseCompanionPlants(_companionData);

/// Emoji per id (afbeelding: assets/images/vegetables/<id>.png).
const Map<String, String> kMoestuinCompanionEmojis = {
  'afrikaantje': '🌼',
  'goudsbloem': '🌼',
  'oostindische_kers': '🌺',
  'komkommerkruid': '💙',
  'facelia': '💜',
  'korenbloem': '🌸',
  'cosmos': '🌸',
  'boekweit': '🌿',
  'witte_klaver': '🍀',
  'rode_klaver': '🍀',
  'duizendblad': '🌿',
  'zaadslurf': '🤍',
  'limnanthes': '🌼',
  'monarda': '🌺',
  'zonnehoed': '🌸',
  'verbena': '🌸',
  'wilde_marjolein': '🌿',
  'hysop': '🌿',
  'mosterd_geel': '🌼',
  'klaproos': '🌺',
  'bijenmengsel': '🐝',
  'lindebloesem': '🌳',
  'ui_bloei': '🌸',
  'look_bloei': '🌸',
  'dille_bloei': '🌼',
  'koriander_bloei': '🌼',
  'salie_bloei': '🌿',
  'tijm_bloei': '🌿',
  'basilicum_bloei': '🌿',
  'munt_bloei': '🍃',
  'calendula_officinalis': '🌼',
  'tagetes_patula': '🌼',
  'alyssum_sneeuw': '🤍',
  'zinnia': '🌸',
  'lupine_groenbemester': '🌺',
  'stiefmoedje': '💜',
  'ringelbloem': '🌼',
};

const String _companionData = '''
afrikaantje|Afrikaantje (tagetes)|Composietenfamilie|Moestuin-bloemen (nuttig)|Juli–oktober|Werkt tegen aaltjes en witte vlieg; plant tussen tomaten en kolen.
goudsbloem|Goudsbloem (calendula)|Composietenfamilie|Moestuin-bloemen (nuttig)|Juni–oktober|Trekt sluipwantsen en lieveheersbeestjes; nuttig bij bonen en sla.
oostindische_kers|Oost-Indische kers|Koolgewas|Moestuin-bloemen (nuttig)|Juli–oktober|Vangplant voor bladluis; beschermt kool, tomaten en komkommer.
komkommerkruid|Komkommerkruid (borago)|Boraginaceae|Moestuin-bloemen (nuttig)|Juni–september|Trekt bijen en zweefvliegen; klassieke begeleider van tomaten en courgette.
facelia|Facelia|Boraginaceae|Moestuin-bloemen (nuttig)|Juni–augustus|Uitstekende bijenplant en groenbemester; tussen rijen zaaien.
korenbloem|Korenbloem|Composietenfamilie|Moestuin-bloemen (nuttig)|Juni–augustus|Trekt bijen en nuttige insecten; rand langs moestuin.
cosmos|Cosmos|Composietenfamilie|Moestuin-bloemen (nuttig)|Juli–oktober|Langbloeiend; voedsel voor bijen, zweefvliegen en lieveheersbeestjes.
boekweit|Boekweit|Polygonaceae|Moestuin-bloemen (nuttig)|Juli–september|Snelle bijenplant en groenbemester; na oogst uitspitten.
witte_klaver|Witte klaver|Vlinderbloemenfamilie|Moestuin-bloemen (nuttig)|Mei–september|Vastlegt stikstof; trekt bijen en gaat goed tussen fruitbomen.
rode_klaver|Rode klaver|Vlinderbloemenfamilie|Moestuin-bloemen (nuttig)|Mei–september|Groenbemester en bijenplant; onder fruit of als tussenteelt.
duizendblad|Duizendblad|Composietenfamilie|Moestuin-bloemen (nuttig)|Juni–augustus|Trekt lieveheersbeestjes, parasietwespen en goudoogjes.
zaadslurf|Zaadslurf (alyssum)|Koolgewas|Moestuin-bloemen (nuttig)|Mei–oktober|Laag, geurt zoet; trekt zweefvliegen tegen bladluis.
limnanthes|Slakkenplantje (limnanthes)|Limnanthaceae|Moestuin-bloemen (nuttig)|Mei–juli|Bijenmagnet; vaak tussen aardbei en groenten gezaaid.
monarda|Monarda (bergamot)|Lipbloemenfamilie|Moestuin-bloemen (nuttig)|Juli–augustus|Trekt bijen en hommels; helpt bestuiving van pompoen en courgette.
zonnehoed|Purperzonnehoed|Composietenfamilie|Moestuin-bloemen (nuttig)|Juli–september|Trekt vlinders en bijen; randplant langs moestuin.
verbena|Verbena|Verbenaceae|Moestuin-bloemen (nuttig)|Juni–oktober|Langbloeiend; nuttig voor bijen en bestuiving in kas en buiten.
wilde_marjolein|Wilde marjolein|Lipbloemenfamilie|Moestuin-bloemen (nuttig)|Juni–augustus|Geur werkt afstotend op enkele insecten; trekt bestuivers.
hysop|Hysop|Lipbloemenfamilie|Moestuin-bloemen (nuttig)|Juni–augustus|Trekt bijen; traditioneel bij kool en druiven geplant.
mosterd_geel|Mosterd (groenbemester)|Koolgewas|Moestuin-bloemen (nuttig)|April–september|Vangt koolvlieg en verbetert bodem; niet na kool zaaien.
klaproos|Klaproos|Papaveraceae|Moestuin-bloemen (nuttig)|Juni–juli|Randbloem voor biodiversiteit en nuttige insecten.
bijenmengsel|Bijenmengsel (zaad)|Mengsel|Moestuin-bloemen (nuttig)|Juni–september|Strooien tussen rijen voor bestuiving van peulen en fruit.
lindebloesem|Winterlinde (jonge boom)|Lindeachtigen|Moestuin-bloemen (nuttig)|Juni|Hommel- en bijenboom; helpt bestuiving in de buurt.
ui_bloei|Bloeiende ui|Uiengewassen|Moestuin-bloemen (nuttig)|Juni–juli|Uiengeur helpt bij wortel en prei; laat bewust een deel doorbloeien.
look_bloei|Bloeiende knoflook|Uiengewassen|Moestuin-bloemen (nuttig)|Juni–juli|Lookfamilie werkt afschrikkend op enkele plagen bij tomaten en rozen.
dille_bloei|Bloeiende dille|Schermbloemenfamilie|Moestuin-bloemen (nuttig)|Juni–augustus|Trekt zweefvliegen en parasietwespen; ideaal bij kool en komkommer.
koriander_bloei|Bloeiende koriander|Schermbloemenfamilie|Moestuin-bloemen (nuttig)|Juni–augustus|Bloei trekt nuttige insecten; zaai door voor langere bloei.
salie_bloei|Bloeiende salie|Lipbloemenfamilie|Moestuin-bloemen (nuttig)|Juni–augustus|Afschrikkend op koolmot; nuttig bij kool, wortel en aardbei.
tijm_bloei|Bloeiende tijm|Lipbloemenfamilie|Moestuin-bloemen (nuttig)|Juni–augustus|Laag struikje; helpt tegen koolbladluis en trekt bestuivers.
basilicum_bloei|Bloeiende basilicum|Lipbloemenfamilie|Moestuin-bloemen (nuttig)|Juli–september|Versterkt tomaten en paprika; knip bloei bij keukengebruik.
munt_bloei|Bloeiende munt|Lipbloemenfamilie|Moestuin-bloemen (nuttig)|Juli–augustus|In pot houden; geur op mieren en kevers; trekt bijen.
calendula_officinalis|Goudsbloem officinalis|Composietenfamilie|Moestuin-bloemen (nuttig)|Juni–oktober|Eetbare bloem; trekt lieveheersbeestjes tegen bladluis.
tagetes_patula|Afrikaantje (lage tagetes)|Composietenfamilie|Moestuin-bloemen (nuttig)|Juni–oktober|Sterk bij tomaten, paprika en ui; werkt op wortelknobbelaaltjes.
alyssum_sneeuw|Sneeuwzaadslurf|Koolgewas|Moestuin-bloemen (nuttig)|Mei–oktober|Laag tapijt; zweefvliegen eten bladluis bij sla en aardbei.
zinnia|Zinnia|Composietenfamilie|Moestuin-bloemen (nuttig)|Juli–oktober|Langbloeiend; trekt bijen, vlinders en hommels langs de moestuin.
lupine_groenbemester|Lupine (groenbemester)|Vlinderbloemenfamilie|Moestuin-bloemen (nuttig)|Mei–juli|Groenbemester en bijenplant; na bloei omslaan of uitspitten.
stiefmoedje|Stiefmoedje (viooltje)|Viooltjesfamilie|Moestuin-bloemen (nuttig)|Maart–mei|Vroege bijenplant; geschikt als rand of in pot bij de moestuin.
ringelbloem|Ringelbloem|Composietenfamilie|Moestuin-bloemen (nuttig)|Juni–oktober|Trekt lieveheersbeestjes; in de moestuin ook bekend als goudsbloem (calendula).
''';

List<Vegetable> _parseCompanionPlants(String raw) {
  final plants = <Vegetable>[];
  for (final line in raw.trim().split('\n')) {
    if (line.trim().isEmpty) continue;
    final parts = line.split('|');
    if (parts.length < 6) continue;
    final id = parts[0].trim();
    final name = parts[1].trim();
    final family = parts[2].trim();
    final category = parts[3].trim();
    final harvest = parts[4].trim();
    final benefit = parts[5].trim();
    plants.add(
      nlPlant(
        id: id,
        nameNl: name,
        family: family,
        growthCategory: category,
        summary: benefit,
        harvest: harvest,
        sowingOutdoors: 'Maart–juni direct zaaien of voorzaaien in trays.',
        care: benefit,
        harvestTips:
            'Laat bloemen staan voor insecten; eetbare soorten kun je mee oogsten.',
        commonIssues:
            'Niet te veel bemesten (dan blad i.p.v. bloem); snoei uitgebloeide delen.',
        keywords: [
          id.replaceAll('_', ' '),
          name.toLowerCase(),
          'moestuin',
          'plagen',
          'bestuiving',
          'bijen',
          'nuttige bloemen',
          'gezelschapsplant',
          'companion plant',
        ],
        spacingCm: 25,
        rowSpacingCm: 30,
      ),
    );
  }
  return plants;
}

/// Alle ids voor het filter “Tegen plagen & bestuiving”.
Set<String> get kMoestuinCompanionPlantIds =>
    kMoestuinCompanionPlants.map((v) => v.id).toSet();
