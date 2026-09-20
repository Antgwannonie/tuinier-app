import 'dart:io';

import 'package:tuinier_app/data/vegetables_data.dart';
import 'package:tuinier_app/models/vegetable.dart';

final _latinPattern = RegExp(
  r'^[A-Z][a-z]+(?:\s×\s[A-Z][a-z]+|\s+[a-z]+(?:\s+var\.\s+[a-z]+)?)+$',
);
final _latinPatternLower = RegExp(r'^[a-z]+(?:\s+[a-z]+)+$');

bool looksLikeScientificName(String value) {
  final trimmed = value.trim();
  if (trimmed.isEmpty || trimmed.contains(RegExp(r'[0-9]'))) return false;
  if (RegExp(r'\b(bloemen|kruid|nuttig|bes|boon|plant)\b', caseSensitive: false)
      .hasMatch(trimmed)) {
    return false;
  }
  if (_latinPattern.hasMatch(trimmed)) return true;
  if (!_latinPatternLower.hasMatch(trimmed)) return false;
  final parts = trimmed.split(' ');
  return parts.length >= 2 && parts[1].isNotEmpty;
}

String titleCaseLatin(String value) {
  return value.split(' ').map((part) {
    if (part == '×') return part;
    if (part == 'var.') return part;
    if (part.isEmpty) return part;
    return '${part[0].toUpperCase()}${part.substring(1)}';
  }).join(' ');
}

String? latinFromKeywords(List<String> keywords) {
  for (final keyword in keywords) {
    final trimmed = keyword.trim();
    if (!looksLikeScientificName(trimmed)) continue;
    if (_latinPattern.hasMatch(trimmed)) return trimmed;
    if (_latinPatternLower.hasMatch(trimmed)) {
      return titleCaseLatin(trimmed);
    }
  }
  return null;
}

const _dutchToEnglish = <String, String>{
  'aardappel': 'Potato',
  'aardbei': 'Strawberry',
  'andijvie': 'Endive',
  'ananas': 'Pineapple',
  'appel': 'Apple',
  'artisjok': 'Artichoke',
  'asperge': 'Asparagus',
  'augurk': 'Gherkin',
  'aubergine': 'Aubergine',
  'avocado': 'Avocado',
  'banaan': 'Banana',
  'basilicum': 'Basil',
  'bieslook': 'Chives',
  'biet': 'Beetroot',
  'bloemkool': 'Cauliflower',
  'boerenkool': 'Kale',
  'bonen': 'Beans',
  'bonenstok': 'Pole beans',
  'bosbes': 'Blueberry',
  'braam': 'Blackberry',
  'broccoli': 'Broccoli',
  'cherry': 'Cherry',
  'chili': 'Chilli',
  'citroen': 'Lemon',
  'citroengras': 'Lemongrass',
  'courgette': 'Zucchini',
  'dille': 'Dill',
  'druif': 'Grape',
  'erwt': 'Pea',
  'erwten': 'Peas',
  'framboos': 'Raspberry',
  'gele': 'Yellow',
  'groene': 'Green',
  'rode': 'Red',
  'witte': 'White',
  'paarse': 'Purple',
  'zwarte': 'Black',
  'baby': 'Baby',
  'kers': 'Cherry',
  'knoflook': 'Garlic',
  'komkommer': 'Cucumber',
  'kool': 'Cabbage',
  'koolraap': 'Kohlrabi',
  'koriander': 'Coriander',
  'limoen': 'Lime',
  'mais': 'Sweet corn',
  'mango': 'Mango',
  'meloen': 'Melon',
  'munt': 'Mint',
  'okra': 'Okra',
  'oregano': 'Oregano',
  'paprika': 'Bell pepper',
  'pastinaak': 'Parsnip',
  'peer': 'Pear',
  'peper': 'Pepper',
  'perzik': 'Peach',
  'peterselie': 'Parsley',
  'pompoen': 'Pumpkin',
  'postelein': 'Purslane',
  'prei': 'Leek',
  'pruim': 'Plum',
  'radijs': 'Radish',
  'rucola': 'Rocket',
  'salie': 'Sage',
  'selderij': 'Celery',
  'sinaasappel': 'Orange',
  'sla': 'Lettuce',
  'sjalot': 'Shallot',
  'snijbiet': 'Swiss chard',
  'sojaboon': 'Soybean',
  'spinazie': 'Spinach',
  'spruitjes': 'Brussels sprouts',
  'tomaat': 'Tomato',
  'tuinboon': 'Broad bean',
  'ui': 'Onion',
  'venkel': 'Fennel',
  'watermeloen': 'Watermelon',
  'wortel': 'Carrot',
  'witlof': 'Chicory',
  'zoete': 'Sweet',
  'snack': 'Snack',
  'mini': 'Mini',
  'reuzen': 'Giant',
  'honing': 'Honey',
  'winter': 'Winter',
  'zomer': 'Summer',
  'peul': 'Pod',
  'peulen': 'Pods',
  'boon': 'Bean',
  'plant': 'Plant',
  'struik': 'Bush',
  'trost': 'Vine',
  'vlees': 'Beefsteak',
  'cocktail': 'Cocktail',
  'pruimtomaat': 'Plum tomato',
  'snoep': 'Snack',
  'ijsberg': 'Iceberg',
  'krul': 'Curly',
  'eikenblad': 'Oak leaf',
  'lollo': 'Lollo',
  'rammenas': 'Daikon radish',
  'schorseneer': 'Salsify',
  'paksoi': 'Pak choi',
  'mizuna': 'Mizuna',
  'tatsoi': 'Tatsoi',
  'chinese': 'Chinese',
  'spruitkool': 'Brussels sprouts',
  'spruit': 'Sprout',
  'bloem': 'Flower',
  'kruiden': 'Herbs',
  'fruit': 'Fruit',
  'gras': 'Grass',
  'rabarber': 'Rhubarb',
  'maitake': 'Maitake',
  'nameko': 'Nameko',
  'reishi': 'Reishi',
  'koningsoesterzwam': 'King oyster mushroom',
  'stropharia': 'Wine cap stropharia',
  'ridderzwam': 'Wood blewit',
  'paddestoel': 'Mushroom',
  'blauwe': 'Blue',
  'wijnrood': 'Wine-red',
};

String? englishFromId(String id) {
  final parts = id.split('_').where((p) => p.isNotEmpty).toList();
  if (parts.isEmpty) return null;
  final translated = <String>[];
  for (final part in parts) {
    final word = _dutchToEnglish[part];
    if (word != null) {
      translated.add(word);
    }
  }
  if (translated.isEmpty) return null;
  return translated.join(' ');
}

String? englishFromNameNl(String nameNl) {
  final base = nameNl.split('(').first.trim();
  final words = base.toLowerCase().split(RegExp(r'[\s\-]+'));
  final translated = <String>[];
  for (final word in words) {
    final clean = word.replaceAll(RegExp(r'[^a-z]'), '');
    if (clean.isEmpty) continue;
    final hit = _dutchToEnglish[clean];
    if (hit != null) translated.add(hit);
  }
  if (translated.isEmpty) return null;
  return translated.join(' ');
}

String categoryForFamily(String family) {
  final lower = family.trim().toLowerCase();
  if (lower.isEmpty) return 'Moestuinplant';

  final paren = family.indexOf('(');
  if (paren > 0) {
    return family.substring(0, paren).trim();
  }

  const containsMap = <String, String>{
    'vruchtgroente': 'Vruchtgroente',
    'komkommer': 'Vruchtgroente',
    'nachtschade': 'Vruchtgroente',
    'kool': 'Koolgewas',
    'kruisbloem': 'Koolgewas',
    'brassicaceae': 'Koolgewas',
    'bladgroente': 'Bladgroente',
    'blad- en wortel': 'Bladgroente',
    'peul': 'Peulgewas',
    'vlinderbloem': 'Peulgewas',
    'fabaceae': 'Peulgewas',
    'uien': 'Uiengewas',
    'look': 'Uiengewas',
    'allium': 'Uiengewas',
    'wortel': 'Wortelgewas',
    'schermbloem': 'Schermbloemigen',
    'kruid': 'Kruid',
    'lipbloem': 'Kruid',
    'boraginaceae': 'Kruid',
    'paddestoel': 'Paddestoel',
    'citrus': 'Fruit',
    'rozen': 'Fruit',
    'fruit': 'Fruit',
    'boom': 'Fruit',
    'bes': 'Fruit',
    'gras': 'Graangewas',
    'meerjarig': 'Meerjarige plant',
    'mengsel': 'Mengsel',
  };

  for (final entry in containsMap.entries) {
    if (lower.contains(entry.key)) return entry.value;
  }

  if (lower.endsWith('familie')) {
    return family
        .replaceAll('familie', '')
        .replaceAll('Familie', '')
        .trim()
        .isEmpty
        ? 'Moestuinplant'
        : family.trim();
  }

  return family.trim();
}

/// Handmatige Latijnse namen — voorkomt familie-lek (bijv. Cynara/Physalis).
const _latinOverrides = <String, String>{
  'aardappel': 'Solanum tuberosum',
  'aardbei': 'Fragaria × ananassa',
  'aardbei_everbearer': 'Fragaria × ananassa',
  'aardpeer': 'Helianthus tuberosus',
  'abrikoos': 'Prunus armeniaca',
  'afrikaantje': 'Tagetes erecta',
  'alyssum_sneeuw': 'Lobularia maritima',
  'andijvie': 'Cichorium endivia',
  'anijs_kruid': 'Pimpinella anisum',
  'appel': 'Malus domestica',
  'artisjok': 'Cynara cardunculus var. scolymus',
  'asperge': 'Asparagus officinalis',
  'aubergine': 'Solanum melongena',
  'augurk': 'Cucumis sativus',
  'avocado': 'Persea americana',
  'baby_spinazie': 'Spinacia oleracea',
  'balkontomaat': 'Solanum lycopersicum',
  'banana_peper': 'Capsicum annuum',
  'basilicum': 'Ocimum basilicum',
  'basilicum_bloei': 'Ocimum basilicum',
  'bieslook': 'Allium schoenoprasum',
  'bimi': 'Brassica oleracea',
  'blauwe_bes': 'Vaccinium corymbosum',
  'bleekselderij': 'Apium graveolens var. dulce',
  'bleekselderij_blad': 'Apium graveolens var. dulce',
  'bloemkool': 'Brassica oleracea var. botrytis',
  'bloemkool_paars': 'Brassica oleracea var. botrytis',
  'boerenkool': 'Brassica oleracea var. sabellica',
  'bonen_sperzie': 'Phaseolus vulgaris',
  'bonenkruid': 'Satureja hortensis',
  'bosui': 'Allium fistulosum',
  'braam': 'Rubus fruticosus',
  'broccoli': 'Brassica oleracea var. italica',
  'broccoli_rabe': 'Brassica rapa subsp. rapa',
  'bruine_boon': 'Phaseolus vulgaris',
  'calendula_officinalis': 'Calendula officinalis',
  'cayenne_peper': 'Capsicum annuum',
  'cherrytomaat': 'Solanum lycopersicum',
  'chilipeper': 'Capsicum annuum',
  'chinese_kool': 'Brassica rapa subsp. pekinensis',
  'chioggia_biet': 'Beta vulgaris',
  'citroengras': 'Cymbopogon citratus',
  'citroenmelisse': 'Melissa officinalis',
  'citroenboom': 'Citrus limon',
  'cocktailtomaat': 'Solanum lycopersicum',
  'cosmos': 'Cosmos bipinnatus',
  'courgette': 'Cucurbita pepo',
  'courgette_geel': 'Cucurbita pepo',
  'cucamelon': 'Melothria scabra',
  'dille': 'Anethum graveolens',
  'dille_bloei': 'Anethum graveolens',
  'doperwt': 'Pisum sativum',
  'dragon': 'Artemisia dracunculus',
  'druif': 'Vitis vinifera',
  'duizendblad': 'Achillea millefolium',
  'eikenbladsla': 'Lactuca sativa',
  'estragon': 'Artemisia dracunculus',
  'framboos': 'Rubus idaeus',
  'galapeno_peper': 'Capsicum annuum',
  'galia_meloen': 'Cucumis melo',
  'gele_biet': 'Beta vulgaris',
  'gele_paprika': 'Capsicum annuum',
  'gele_wortel': 'Daucus carota',
  'gember': 'Zingiber officinale',
  'goudsbloem': 'Calendula officinalis',
  'groene_asperge': 'Asparagus officinalis',
  'habanero': 'Capsicum chinense',
  'haricots_verts': 'Phaseolus vulgaris',
  'honingmeloen': 'Cucumis melo',
  'honingtomaat': 'Solanum lycopersicum',
  'hysop': 'Hyssopus officinalis',
  'ijsbergsla': 'Lactuca sativa var. capitata',
  'jalapeno': 'Capsicum annuum',
  'jostabes': 'Ribes × nidigrolaria',
  'kaki': 'Diospyros kaki',
  'kamille': 'Matricaria chamomilla',
  'kapucijner': 'Pisum sativum',
  'kardoen': 'Cynara cardunculus',
  'kerrieblad': 'Murraya koenigii',
  'kers': 'Prunus avium',
  'kervel': 'Anthriscus cerefolium',
  'kikkererwt': 'Cicer arietinum',
  'kiwi': 'Actinidia deliciosa',
  'knoflook': 'Allium sativum',
  'knolraap': 'Brassica rapa subsp. rapa',
  'knolselerij': 'Apium graveolens var. rapaceum',
  'knolvenkel': 'Foeniculum vulgare var. azoricum',
  'komatsuna': 'Brassica rapa var. perviridis',
  'komkommer': 'Cucumis sativus',
  'koolraap': 'Brassica napus var. napobrassica',
  'koolrabi': 'Brassica oleracea var. gongylodes',
  'korenbloem': 'Centaurea cyanus',
  'koriander': 'Coriandrum sativum',
  'koriander_bloei': 'Coriandrum sativum',
  'kriek': 'Prunus cerasus',
  'kruimige_aardappel': 'Solanum tuberosum',
  'krulsla': 'Lactuca sativa',
  'kweepeer': 'Cydonia oblonga',
  'lambsla': 'Valerianella locusta',
  'lavendel': 'Lavandula angustifolia',
  'lollo_rossa': 'Lactuca sativa',
  'look_bloei': 'Allium sativum',
  'lupine_groenbemester': 'Lupinus angustifolius',
  'mais': 'Zea mays',
  'maiskolf': 'Zea mays',
  'majoraan': 'Origanum majorana',
  'mango': 'Mangifera indica',
  'meiraap': 'Brassica rapa subsp. rapa',
  'meloen': 'Cucumis melo',
  'mini_wortel': 'Daucus carota',
  'mirabel': 'Prunus domestica subsp. syriaca',
  'mispel': 'Mespilus germanica',
  'mizuna': 'Brassica rapa var. nipposinica',
  'monarda': 'Monarda didyma',
  'mosterd_geel': 'Sinapis alba',
  'mosterdgroen': 'Brassica juncea',
  'munt': 'Mentha sp.',
  'munt_bloei': 'Mentha sp.',
  'nashi_peer': 'Pyrus pyrifolia',
  'nectarine': 'Prunus persica var. nucipersica',
  'oostindische_kers': 'Tropaeolum majus',
  'oranje_paprika': 'Capsicum annuum',
  'oregano': 'Origanum vulgare',
  'paarse_wortel': 'Daucus carota',
  'padron_peper': 'Capsicum annuum',
  'paksoi': 'Brassica rapa subsp. chinensis',
  'paksoi_jong': 'Brassica rapa subsp. chinensis',
  'palmekool': 'Brassica oleracea var. palmifolia',
  'pastinaak': 'Pastinaca sativa',
  'patisson': 'Cucurbita pepo var. ovifera',
  'patisson_geel': 'Cucurbita pepo var. ovifera',
  'peer': 'Pyrus communis',
  'peper': 'Capsicum annuum',
  'pepermunt': 'Mentha × piperita',
  'peperoncini': 'Capsicum annuum',
  'pepino': 'Solanum muricatum',
  'perzik': 'Prunus persica',
  'peterselie': 'Petroselinum crispum',
  'peterseliewortel': 'Petroselinum crispum var. tuberosum',
  'peultjes': 'Pisum sativum',
  'physalis': 'Physalis peruviana',
  'pinda': 'Arachis hypogaea',
  'poblano_peper': 'Capsicum annuum',
  'pompoen': 'Cucurbita maxima',
  'pompoen_butternut': 'Cucurbita moschata',
  'pompoen_hokkaido': 'Cucurbita maxima',
  'postelein': 'Portulaca oleracea',
  'prei': 'Allium porrum',
  'pruim': 'Prunus domestica',
  'pruimtomaat': 'Solanum lycopersicum',
  'puntpaprika': 'Capsicum annuum',
  'raap': 'Brassica rapa',
  'raapkool': 'Brassica rapa',
  'raapstelen': 'Brassica rapa',
  'rabarber': 'Rheum rhabarbarum',
  'radijs': 'Raphanus sativus',
  'rammenas': 'Raphanus sativus var. longipinnatus',
  'reuzen_pompoen': 'Cucurbita maxima',
  'ringelbloem': 'Calendula officinalis',
  'rode_bes': 'Ribes rubrum',
  'rode_biet': 'Beta vulgaris',
  'rode_biet_cilindrisch': 'Beta vulgaris',
  'rode_klaver': 'Trifolium pratense',
  'rode_paprika': 'Capsicum annuum',
  'rode_savooi': 'Brassica oleracea var. sabauda',
  'rode_ui': 'Allium cepa',
  'rodekool': 'Brassica oleracea var. capitata f. rubra',
  'romanesco': 'Brassica oleracea var. botrytis',
  'rozemarijn': 'Salvia rosmarinus',
  'rucola': 'Eruca vesicaria',
  'salie': 'Salvia officinalis',
  'salie_bloei': 'Salvia officinalis',
  'savooiekool': 'Brassica oleracea var. sabauda',
  'schorseneer': 'Scorzonera hispanica',
  'serrano_peper': 'Capsicum annuum',
  'sjalot': 'Allium cepa var. aggregatum',
  'sla': 'Lactuca sativa',
  'snack_paprika': 'Capsicum annuum',
  'snackkomkommer': 'Cucumis sativus',
  'snijbiet': 'Beta vulgaris subsp. vulgaris',
  'snijbonen': 'Phaseolus vulgaris',
  'snijboon_geel': 'Phaseolus vulgaris',
  'snoeptomaat': 'Solanum lycopersicum',
  'sojaboon': 'Glycine max',
  'spinazie': 'Spinacia oleracea',
  'spitskool': 'Brassica oleracea var. capitata',
  'spruitkool': 'Brassica oleracea var. gemmifera',
  'spruitkool_rood': 'Brassica oleracea var. gemmifera',
  'stengelselderij': 'Apium graveolens var. dulce',
  'sugarsnaps': 'Pisum sativum var. macrocarpon',
  'tabasco_peper': 'Capsicum frutescens',
  'tagetes_patula': 'Tagetes patula',
  'tatsoi': 'Brassica rapa subsp. narinosa',
  'tauge': 'Vigna radiata',
  'thaise_peper': 'Capsicum frutescens',
  'tijm': 'Thymus vulgaris',
  'tijm_bloei': 'Thymus vulgaris',
  'tomaat': 'Solanum lycopersicum',
  'trostomaat': 'Solanum lycopersicum',
  'tuin_linzen': 'Lens culinaris',
  'tuinboon': 'Vicia faba',
  'tuinerwt': 'Pisum sativum',
  'tuinkers': 'Lepidium sativum',
  'tuinkruid': 'Origanum majorana',
  'tuinmelde': 'Atriplex hortensis',
  'ui': 'Allium cepa',
  'ui_bloei': 'Allium cepa',
  'vastkokende_aardappel': 'Solanum tuberosum',
  'veenbes': 'Vaccinium macrocarpon',
  'veldsla': 'Valerianella locusta',
  'venkel': 'Foeniculum vulgare',
  'vijg': 'Ficus carica',
  'vleestomaat': 'Solanum lycopersicum',
  'vroege_aardappel': 'Solanum tuberosum',
  'watermeloen': 'Citrullus lanatus',
  'wilde_marjolein': 'Origanum vulgare',
  'winterpeen': 'Daucus carota',
  'winterprei': 'Allium porrum',
  'winterui': 'Allium fistulosum',
  'witlof': 'Cichorium intybus',
  'witte_asperge': 'Asparagus officinalis',
  'witte_biet': 'Beta vulgaris',
  'witte_boon': 'Phaseolus vulgaris',
  'witte_klaver': 'Trifolium repens',
  'witte_wortel': 'Daucus carota',
  'wittekool': 'Brassica oleracea var. capitata',
  'wortel': 'Daucus carota',
  'zaadslurf': 'Lobularia maritima',
  'zinnia': 'Zinnia elegans',
  'zoete_aardappel': 'Ipomoea batatas',
  'zomerprei': 'Allium porrum',
  'zonnebloem': 'Helianthus annuus',
  'zonnehoed': 'Echinacea purpurea',
  'zure_kers': 'Prunus cerasus',
  'zwarte_bes': 'Ribes nigrum',
  'zwarte_radijs': 'Raphanus sativus var. niger',
};

String? _latinFromKnownSibling(Vegetable v) {
  final id = v.id.toLowerCase();
  // Varianten van bekende basisgewassen → Latijn van de basissoort.
  const stems = <String, String>{
    'tomaat': 'Solanum lycopersicum',
    'paprika': 'Capsicum annuum',
    'peper': 'Capsicum annuum',
    'komkommer': 'Cucumis sativus',
    'courgette': 'Cucurbita pepo',
    'pompoen': 'Cucurbita maxima',
    'meloen': 'Cucumis melo',
    'sla': 'Lactuca sativa',
    'spinazie': 'Spinacia oleracea',
    'biet': 'Beta vulgaris',
    'wortel': 'Daucus carota',
    'peen': 'Daucus carota',
    'radijs': 'Raphanus sativus',
    'ui': 'Allium cepa',
    'prei': 'Allium porrum',
    'knoflook': 'Allium sativum',
    'boon': 'Phaseolus vulgaris',
    'erwt': 'Pisum sativum',
    'aardappel': 'Solanum tuberosum',
    'aardbei': 'Fragaria × ananassa',
    'selderij': 'Apium graveolens',
    'venkel': 'Foeniculum vulgare',
    'kool': 'Brassica oleracea',
    'asperge': 'Asparagus officinalis',
  };
  for (final entry in stems.entries) {
    if (id.contains(entry.key)) return entry.value;
  }
  return null;
}

String? resolveLatin(Vegetable v) {
  final override = _latinOverrides[v.id];
  if (override != null) return override;

  final direct = v.nameLatin?.trim();
  if (direct != null &&
      direct.isNotEmpty &&
      looksLikeScientificName(direct)) {
    return direct;
  }

  final fromKeywords = latinFromKeywords(v.keywords);
  if (fromKeywords != null) return fromKeywords;

  final fromStem = _latinFromKnownSibling(v);
  if (fromStem != null) return fromStem;

  // Alleen siblings met dezelfde id-prefix (varianten), nooit hele familie.
  final base = v.id.split('_').first;
  if (base.length >= 4) {
    for (final other in kVegetablesSeed) {
      if (other.id == v.id) continue;
      if (other.id != base && !other.id.startsWith('${base}_')) continue;
      final otherLatin = other.nameLatin?.trim();
      if (otherLatin != null && looksLikeScientificName(otherLatin)) {
        return otherLatin;
      }
      final otherOverride = _latinOverrides[other.id];
      if (otherOverride != null) return otherOverride;
    }
  }

  return null;
}

String? resolveEnglish(Vegetable v) {
  const overrides = <String, String>{
    'wijnrood_stropharia': 'Wine cap stropharia',
    'blauwe_ridderzwam': 'Wood blewit',
    'zomerpaddestoel': 'Pioppino',
    'koningsoesterzwam': 'King oyster mushroom',
  };
  final override = overrides[v.id];
  if (override != null) return override;
  return englishFromId(v.id) ??
      englishFromNameNl(v.nameNl) ??
      englishFromNameNl(v.nameNl.split('(').first);
}

void main() {
  final latinEntries = <String>[];
  final englishEntries = <String>[];
  final categoryEntries = <String>[];

  for (final v in kVegetablesSeed) {
    final latin = resolveLatin(v);
    final english = resolveEnglish(v) ?? v.nameNl;
    final category = categoryForFamily(v.family);

    if (latin != null && latin.isNotEmpty) {
      latinEntries.add("  '${v.id}': '${latin.replaceAll("'", "\\'")}',");
    }
    if (english.isNotEmpty) {
      englishEntries.add("  '${v.id}': '${english.replaceAll("'", "\\'")}',");
    }
    categoryEntries.add("  '${v.id}': '${category.replaceAll("'", "\\'")}',");
  }

  latinEntries.sort();
  englishEntries.sort();
  categoryEntries.sort();

  final buffer = StringBuffer('''
// GENERATED by tool/generate_display_names.dart — do not edit by hand.
import '../models/vegetable.dart';

const _latinById = <String, String>{
${latinEntries.join('\n')}
};

const _englishById = <String, String>{
${englishEntries.join('\n')}
};

const _categoryById = <String, String>{
${categoryEntries.join('\n')}
};

String? latinNameForVegetable(Vegetable vegetable) {
  final direct = vegetable.nameLatin?.trim();
  if (direct != null && direct.isNotEmpty) return direct;
  return _latinById[vegetable.id];
}

String? englishNameForVegetable(Vegetable vegetable) {
  return _englishById[vegetable.id];
}

String plantCategoryForVegetable(Vegetable vegetable) {
  return _categoryById[vegetable.id] ?? 'Moestuinplant';
}
''');

  File('lib/data/vegetable_display_names.dart')
      .writeAsStringSync(buffer.toString());
  stdout.writeln('wrote lib/data/vegetable_display_names.dart');
  stdout.writeln('latin=${latinEntries.length} english=${englishEntries.length}');
}
