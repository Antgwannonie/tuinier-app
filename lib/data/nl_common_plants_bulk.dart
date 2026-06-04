import '../models/vegetable.dart';
import 'plant_factory.dart';

/// 100 extra gewassen die veel in Nederland worden geteeld (afbeeldingen: assets/images/vegetables/<id>.png).
final List<Vegetable> kNlCommonPlantsBulk = _parseBulkPlants(_bulkPlantData);

/// Emoji per id voor zoek- en kalenderweergave.
const Map<String, String> kNlCommonPlantEmojis = {
  'savooiekool': '🥬',
  'spitskool': '🥬',
  'palmekool': '🥬',
  'romanesco': '🥦',
  'chinese_kool': '🥬',
  'raapstelen': '🥬',
  'meiraap': '🟤',
  'schorseneer': '🥕',
  'knolselerij': '🥬',
  'knolvenkel': '🌿',
  'kapucijner': '🫛',
  'bruine_boon': '🫘',
  'tuinerwt': '🫛',
  'sojaboon': '🫛',
  'aardpeer': '🥔',
  'topinambur': '🥔',
  'zoete_aardappel': '🍠',
  'rammenas': '🥕',
  'zwarte_radijs': '🌱',
  'okra': '🫛',
  'pepino': '🥒',
  'chilipeper': '🌶️',
  'jalapeno': '🌶️',
  'habanero': '🌶️',
  'serrano_peper': '🌶️',
  'lollo_rossa': '🥬',
  'krulsla': '🥬',
  'lambsla': '🥬',
  'eikenbladsla': '🥬',
  'mizuna': '🥬',
  'tatsoi': '🥬',
  'komatsuna': '🥬',
  'mosterdgroen': '🥬',
  'raap': '🥬',
  'gele_biet': '🟡',
  'witte_biet': '⚪',
  'knolraap': '🟤',
  'stengelselderij': '🥬',
  'groene_asperge': '🌿',
  'witte_asperge': '🌿',
  'kardoen': '🌿',
  'rode_ui': '🧅',
  'winterui': '🧅',
  'lente_ui': '🧅',
  'tuinmelde': '🍃',
  'zuring': '🍃',
  'waterkers': '🥬',
  'tauge': '🌱',
  'cherrytomaat': '🍅',
  'pruimtomaat': '🍅',
  'vleestomaat': '🍅',
  'trostomaat': '🍅',
  'galia_meloen': '🍈',
  'honingmeloen': '🍈',
  'portobello': '🍄',
  'champignon_wit': '🍄',
  'morielzwam': '🍄',
  'lions_mane': '🍄',
  'enoki': '🍄',
  'shimeji': '🍄',
  'nectarine': '🍑',
  'mirabel': '🍑',
  'kriek': '🍒',
  'zure_kers': '🍒',
  'kweepeer': '🍐',
  'mispel': '🍎',
  'nashi_peer': '🍐',
  'mandarijn': '🍊',
  'citroenboom': '🍋',
  'limoen': '🍋',
  'granaatappel': '🍎',
  'kruisbess': '🫐',
  'aalbes': '🫐',
  'jostabes': '🫐',
  'vlierbes': '🫐',
  'duindoorn': '🫐',
  'veenbes': '🫐',
  'walnoot': '🥜',
  'hazelnoot': '🥜',
  'kastanje_boom': '🌰',
  'citroenmelisse': '🌿',
  'pepermunt': '🌿',
  'kamille': '🌼',
  'bonenkruid': '🌿',
  'anijs_kruid': '🌿',
  'estragon': '🌿',
  'kerrieblad': '🌿',
  'tuinkruid': '🌿',
  'gele_paprika': '🫑',
  'winterpeen': '🥕',
  'mini_wortel': '🥕',
  'raapkool': '🥬',
  'broccoli_rabe': '🥦',
  'rode_savooi': '🥬',
  'tuin_linzen': '🫛',
  'erwtensoep_erwt': '🫛',
  'snijboon_geel': '🫛',
  'winterpostelein': '🥬',
  'bleekselderij_blad': '🥬',
  'raapsteeltjes': '🥬',
  'scheve_ui': '🧅',
  'knoflook_hardnekkig': '🧄',
  'bloemkool_paars': '🥦',
  'spruitkool_rood': '🥬',
  'paksoi_jong': '🥬',
  'courgette_geel': '🥒',
  'patisson_geel': '🟡',
  'maiskolf': '🌽',
  'pompoen_hokkaido': '🎃',
  'pompoen_butternut': '🎃',
  'aardbei_everbearer': '🍓',
  'framboos_zomer': '🫐',
  'braam_zonder_doorn': '🫐',
  'rode_bes_grootvrucht': '🫐',
  'blauwe_regen_bes': '🫐',
};

const String _bulkPlantData = '''
savooiekool|Savooiekool|Koolgewas|Middelmatige groeiers|Oktober–maart
spitskool|Spitskool|Koolgewas|Middelmatige groeiers|Oktober–december
palmekool|Boerenkool (palm)|Koolgewas|Middelmatige groeiers|Oktober–maart
romanesco|Romanesco|Koolgewas|Middelmatige groeiers|September–november
chinese_kool|Chinese kool|Koolgewas|Middelmatige groeiers|September–november
raapstelen|Raapstelen|Koolgewas|Snelle groeiers|Mei–oktober
meiraap|Meiraap|Koolgewas|Middelmatige groeiers|Oktober–maart
schorseneer|Schorseneer|Composietenfamilie|Middelmatige groeiers|Oktober–maart
knolselerij|Knolselerij|Schermbloemenfamilie|Middelmatige groeiers|September–november
knolvenkel|Knolvenkel|Schermbloemenfamilie|Middelmatige groeiers|Oktober–november
kapucijner|Kapucijner|Peulgewas|Middelmatige groeiers|Juli–september
bruine_boon|Bruine tuinboon|Peulgewas|Middelmatige groeiers|Augustus–september
tuinerwt|Tuinerwt|Peulgewas|Snelle groeiers|Juni–augustus
sojaboon|Sojaboon (edamame)|Peulgewas|Lang producerende zomerplanten|Augustus–september
aardpeer|Aardpeer|Composietenfamilie|Meerjarig|Oktober–maart
topinambur|Topinambur|Composietenfamilie|Meerjarig|Oktober–maart
zoete_aardappel|Zoete aardappel|Windasfamilie|Lang producerende zomerplanten|September–oktober
rammenas|Rammenas (daikon)|Koolgewas|Snelle groeiers|September–november
zwarte_radijs|Zwarte radijs|Koolgewas|Snelle groeiers|Juli–oktober
okra|Okra|Malvaceae|Lang producerende zomerplanten|Juli–september
pepino|Pepino|Nachtschadefamilie|Lang producerende zomerplanten|Augustus–oktober
chilipeper|Chilipeper|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
jalapeno|Jalapeño|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
habanero|Habanero|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
serrano_peper|Serranopeper|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
lollo_rossa|Lollo rossa|Composietenfamilie|Snelle groeiers|Mei–oktober
krulsla|Krulsla|Composietenfamilie|Snelle groeiers|Mei–oktober
lambsla|Lambsla|Composietenfamilie|Snelle groeiers|Mei–oktober
eikenbladsla|Eikenbladsla|Composietenfamilie|Snelle groeiers|Mei–oktober
mizuna|Mizuna|Koolgewas|Snelle groeiers|Mei–oktober
tatsoi|Tatsoi|Koolgewas|Snelle groeiers|Mei–oktober
komatsuna|Komatsuna|Koolgewas|Snelle groeiers|Mei–oktober
mosterdgroen|Mosterdgroen|Koolgewas|Snelle groeiers|Mei–oktober
raap|Raap|Koolgewas|Middelmatige groeiers|Oktober–maart
gele_biet|Gele biet|Amarantenfamilie|Middelmatige groeiers|Juli–oktober
witte_biet|Witte biet|Amarantenfamilie|Middelmatige groeiers|Juli–oktober
knolraap|Knolraap|Koolgewas|Middelmatige groeiers|Oktober–maart
stengelselderij|Bleekselderij (stengel)|Schermbloemenfamilie|Middelmatige groeiers|Juli–oktober
groene_asperge|Groene asperge|Leliegewassen|Meerjarig|April–juni
witte_asperge|Witte asperge|Leliegewassen|Meerjarig|April–juni
kardoen|Kardoen|Composietenfamilie|Middelmatige groeiers|Oktober–november
rode_ui|Rode ui|Uiengewassen|Middelmatige groeiers|Juli–september
winterui|Winterui|Uiengewassen|Middelmatige groeiers|Juli–september
lente_ui|Lente-ui|Uiengewassen|Snelle groeiers|Mei–juli
tuinmelde|Tuinmelde|Amarantenfamilie|Snelle groeiers|Mei–oktober
zuring|Zuring|Polygonaceae|Meerjarig|Maart–november
waterkers|Waterkers|Brassicaceae|Snelle groeiers|Mei–oktober
tauge|Taugé (kiem)|Peulgewas|Snelle groeiers|Doorlopend binnen
cherrytomaat|Cherrytomaat|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
pruimtomaat|Pruimtomaat|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
vleestomaat|Vleestomaat|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
trostomaat|Trostomaat|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
galia_meloen|Galia-meloen|Komkommerfamilie|Lang producerende zomerplanten|Augustus–september
honingmeloen|Honingmeloen|Komkommerfamilie|Lang producerende zomerplanten|Augustus–september
portobello|Portobello|Paddestoelen|Paddestoel|Doorlopend binnen
champignon_wit|Witte champignon|Paddestoelen|Paddestoel|Doorlopend binnen
morielzwam|Morielzwam|Paddestoelen|Paddestoel|Maart–mei
lions_mane|Lion's mane|Paddestoelen|Paddestoel|Doorlopend binnen
enoki|Enoki|Paddestoelen|Paddestoel|Doorlopend binnen
shimeji|Shimeji|Paddestoelen|Paddestoel|Doorlopend binnen
nectarine|Nectarine|Rozenbloemenfamilie|Meerjarig fruit (boom)|Augustus
mirabel|Mirabel|Rozenbloemenfamilie|Meerjarig fruit (boom)|Augustus
kriek|Kriek|Rozenbloemenfamilie|Meerjarig fruit (boom)|Juli
zure_kers|Zure kers|Rozenbloemenfamilie|Meerjarig fruit (boom)|Juli
kweepeer|Kweepeer|Rozenbloemenfamilie|Meerjarig fruit (boom)|Oktober
mispel|Mispel|Rozenbloemenfamilie|Meerjarig fruit (boom)|November
nashi_peer|Nashipeer|Rozenbloemenfamilie|Meerjarig fruit (boom)|Oktober
mandarijn|Mandarijn (pot)|Citrusfamilie|Meerjarig fruit (boom)|November–januari
citroenboom|Citroen (pot)|Citrusfamilie|Meerjarig fruit (boom)|Doorlopend
limoen|Limoen (pot)|Citrusfamilie|Meerjarig fruit (boom)|Doorlopend
granaatappel|Granaatappel (pot)|Lythraceae|Meerjarig fruit (boom)|Oktober
kruisbess|Kruisbess|Saxifragefamilie|Meerjarig fruit (bes)|Juli
aalbes|Aalbes|Saxifragefamilie|Meerjarig fruit (bes)|Juli
jostabes|Jostabes|Saxifragefamilie|Meerjarig fruit (bes)|Juli
vlierbes|Vlierbes|Vlierfamilie|Meerjarig fruit (bes)|Augustus
duindoorn|Duindoorn|Duindoornfamilie|Meerjarig fruit (bes)|September
veenbes|Veenbes|Heidefamilie|Meerjarig fruit (bes)|Augustus
walnoot|Walnoot|Okkernootfamilie|Meerjarig fruit (boom)|Oktober
hazelnoot|Hazelnoot|Berkenfamilie|Meerjarig fruit (boom)|September
kastanje_boom|Esskastanje|Beukfamilie|Meerjarig fruit (boom)|Oktober
citroenmelisse|Citroenmelisse|Lipbloemenfamilie|Kruiden|Juni–september
pepermunt|Pepermunt|Lipbloemenfamilie|Kruiden|Mei–oktober
kamille|Kamille|Composietenfamilie|Kruiden|Juni–augustus
bonenkruid|Bonenkruid|Lipbloemenfamilie|Kruiden|Juni–september
anijs_kruid|Anijs|Schermbloemenfamilie|Kruiden|Augustus
estragon|Estragon|Composietenfamilie|Kruiden|Mei–oktober
kerrieblad|Kerrieplant|Komkommerfamilie|Kruiden|Juni–september
tuinkruid|Tuinkruid (marjolein)|Lipbloemenfamilie|Kruiden|Juni–september
gele_paprika|Gele paprika|Nachtschadefamilie|Lang producerende zomerplanten|Juli–oktober
winterpeen|Winterpeen|Schermbloemenfamilie|Middelmatige groeiers|Oktober–maart
mini_wortel|Miniwortel|Schermbloemenfamilie|Snelle groeiers|Juni–oktober
raapkool|Raapkool|Koolgewas|Middelmatige groeiers|Oktober–maart
broccoli_rabe|Broccoli rabe|Koolgewas|Snelle groeiers|Mei–oktober
rode_savooi|Rode savooikool|Koolgewas|Middelmatige groeiers|Oktober–maart
tuin_linzen|Tuinlinzen|Peulgewas|Middelmatige groeiers|Juli–augustus
erwtensoep_erwt|Droog erwt (soep)|Peulgewas|Middelmatige groeiers|Juli–augustus
snijboon_geel|Gele sperzieboon|Peulgewas|Snelle groeiers|Juli–september
winterpostelein|Winterpostelein|Portulacaceae|Snelle groeiers|Maart–november
bleekselderij_blad|Bleekselderij blad|Schermbloemenfamilie|Middelmatige groeiers|Juli–oktober
raapsteeltjes|Raapsteeltjes|Koolgewas|Snelle groeiers|Mei–oktober
scheve_ui|Gele ui (scheve)|Uiengewassen|Middelmatige groeiers|Juli–september
knoflook_hardnekkig|Hardnekkige knoflook|Uiengewassen|Middelmatige groeiers|Juli
bloemkool_paars|Paarse bloemkool|Koolgewas|Middelmatige groeiers|September–november
spruitkool_rood|Rode spruitkool|Koolgewas|Middelmatige groeiers|Oktober–februari
paksoi_jong|Jonge paksoi|Koolgewas|Snelle groeiers|Mei–oktober
courgette_geel|Gele courgette|Komkommerfamilie|Lang producerende zomerplanten|Juli–oktober
patisson_geel|Gele patisson|Komkommerfamilie|Lang producerende zomerplanten|Augustus–oktober
maiskolf|Maïskolf|Grasfamilie|Lang producerende zomerplanten|September
pompoen_hokkaido|Hokkaido-pompoen|Komkommerfamilie|Lang producerende zomerplanten|September–oktober
pompoen_butternut|Butternutpompoen|Komkommerfamilie|Lang producerende zomerplanten|September–oktober
aardbei_everbearer|Everbearing aardbei|Rozenbloemenfamilie|Meerjarig fruit (bes)|Mei–oktober
framboos_zomer|Zomerframboos|Rozenbloemenfamilie|Meerjarig fruit (bes)|Juli–augustus
braam_zonder_doorn|Doornloze braam|Rozenbloemenfamilie|Meerjarig fruit (bes)|Augustus
rode_bes_grootvrucht|Grootvrucht rode bes|Heidefamilie|Meerjarig fruit (bes)|Juli
blauwe_regen_bes|Blauwe regen (sier)|Fabaceae|Meerjarig|Juni–juli
''';

List<Vegetable> _parseBulkPlants(String raw) {
  final plants = <Vegetable>[];
  for (final line in raw.trim().split('\n')) {
    if (line.trim().isEmpty) continue;
    final parts = line.split('|');
    if (parts.length < 4) continue;
    final id = parts[0].trim();
    final name = parts[1].trim();
    final family = parts[2].trim();
    final category = parts[3].trim();
    final harvest = parts.length > 4 ? parts[4].trim() : 'Juni–oktober; zie teeltinfo.';
    plants.add(
      nlPlantBulk(
        id,
        name,
        family: family,
        growthCategory: category,
        harvest: harvest,
        keywords: [id.replaceAll('_', ' '), name.toLowerCase()],
      ),
    );
  }
  return plants;
}
