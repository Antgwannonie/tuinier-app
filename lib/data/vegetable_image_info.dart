/// Afbeelding / emoji per groente-id (offline emoji + optionele foto-URL).
class VegetableImageInfo {
  const VegetableImageInfo({
    required this.emoji,
    this.imageUrl,
    this.greenBackground = true,
  });

  final String emoji;
  final String? imageUrl;

  /// Groene (#E8F5E9) of witte achtergrond.
  final bool greenBackground;
}

const _defaultInfo = VegetableImageInfo(emoji: '🌱', greenBackground: true);

const Map<String, VegetableImageInfo> kVegetableImages = {
  'radijs': VegetableImageInfo(
    emoji: '🌱',
    greenBackground: true,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/2f/Raphanus_sativus.JPG/256px-Raphanus_sativus.JPG',
  ),
  'rucola': VegetableImageInfo(emoji: '🥬', greenBackground: false),
  'sla': VegetableImageInfo(
    emoji: '🥬',
    greenBackground: true,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/5d/Looseleaf_lettuce.jpg/256px-Looseleaf_lettuce.jpg',
  ),
  'spinazie': VegetableImageInfo(emoji: '🍃', greenBackground: false),
  'bosui': VegetableImageInfo(emoji: '🧅', greenBackground: true),
  'wortel': VegetableImageInfo(
    emoji: '🥕',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a2/Vegetable-Carrot-Bundle-wStems.jpg/256px-Vegetable-Carrot-Bundle-wStems.jpg',
  ),
  'rode_biet': VegetableImageInfo(
    emoji: '🟣',
    greenBackground: true,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Beetroot_jm26647.jpg/256px-Beetroot_jm26647.jpg',
  ),
  'bonen_sperzie': VegetableImageInfo(
    emoji: '🫛',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Green_beans.jpg/256px-Green_beans.jpg',
  ),
  'snijbonen': VegetableImageInfo(emoji: '🫛', greenBackground: true),
  'cucamelon': VegetableImageInfo(emoji: '🥒', greenBackground: false),
  'snackkomkommer': VegetableImageInfo(emoji: '🥒', greenBackground: true),
  'komkommer': VegetableImageInfo(
    emoji: '🥒',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/9/96/ARS_cucumber.jpg/256px-ARS_cucumber.jpg',
  ),
  'snoeptomaat': VegetableImageInfo(
    emoji: '🍅',
    greenBackground: true,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Bright_red_tomato_and_cross_section.jpg/256px-Bright_red_tomato_and_cross_section.jpg',
  ),
  'tomaat': VegetableImageInfo(
    emoji: '🍅',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/88/Bright_red_tomato_and_cross_section.jpg/256px-Bright_red_tomato_and_cross_section.jpg',
  ),
  'paprika': VegetableImageInfo(
    emoji: '🫑',
    greenBackground: true,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/8/85/Green-Yellow-Red-Pepper-2009.jpg/256px-Green-Yellow-Red-Pepper-2009.jpg',
  ),
  'peper': VegetableImageInfo(emoji: '🌶️', greenBackground: false),
  'aubergine': VegetableImageInfo(
    emoji: '🍆',
    greenBackground: true,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/21/Aubergine.jpg/256px-Aubergine.jpg',
  ),
  'aardbei': VegetableImageInfo(
    emoji: '🍓',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/2/29/PerfectStrawberry.jpg/256px-PerfectStrawberry.jpg',
  ),
  'ui': VegetableImageInfo(emoji: '🧅', greenBackground: true),
  'prei': VegetableImageInfo(emoji: '🧅', greenBackground: false),
  'courgette': VegetableImageInfo(
    emoji: '🥒',
    greenBackground: true,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Patisson_jaune_Blanc.jpg/256px-Patisson_jaune_Blanc.jpg',
  ),
  'doperwt': VegetableImageInfo(
    emoji: '🫛',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/1/11/Peas_in_pods_-_Studio.jpg/256px-Peas_in_pods_-_Studio.jpg',
  ),
  'boerenkool': VegetableImageInfo(emoji: '🥬', greenBackground: true),
  'broccoli': VegetableImageInfo(
    emoji: '🥦',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/0/03/Broccoli_%28brassica_oleracea%29_1.jpg/256px-Broccoli_%28brassica_oleracea%29_1.jpg',
  ),
  'koolrabi': VegetableImageInfo(emoji: '🥬', greenBackground: true),
  'pastinaak': VegetableImageInfo(emoji: '🥕', greenBackground: false),
  'raps_kool': VegetableImageInfo(emoji: '🥬', greenBackground: true),
  'aardappel': VegetableImageInfo(
    emoji: '🥔',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/a/ab/Patates.jpg/256px-Patates.jpg',
  ),
  'knoflook': VegetableImageInfo(emoji: '🧄', greenBackground: true),
  'rabarber': VegetableImageInfo(emoji: '🌿', greenBackground: false),
  'asperge': VegetableImageInfo(
    emoji: '🌿',
    greenBackground: true,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/4/44/Asparagus_officinalis_%28asparagus%29.jpg/256px-Asparagus_officinalis_%28asparagus%29.jpg',
  ),
  'mais': VegetableImageInfo(
    emoji: '🌽',
    greenBackground: false,
    imageUrl:
        'https://upload.wikimedia.org/wikipedia/commons/thumb/5/50/Cornucopia_of_corn.jpg/256px-Cornucopia_of_corn.jpg',
  ),
  'wittekool': VegetableImageInfo(emoji: '🥬', greenBackground: true),
  'rodekool': VegetableImageInfo(emoji: '🟣', greenBackground: false),
  'bloemkool': VegetableImageInfo(emoji: '🥦', greenBackground: true),
  'spruitkool': VegetableImageInfo(emoji: '🥬', greenBackground: false),
  'andijvie': VegetableImageInfo(emoji: '🥬', greenBackground: true),
  'paksoi': VegetableImageInfo(emoji: '🥬', greenBackground: false),
  'venkel': VegetableImageInfo(emoji: '🌿', greenBackground: true),
  'bleekselderij': VegetableImageInfo(emoji: '🥬', greenBackground: false),
  'postelein': VegetableImageInfo(emoji: '🍃', greenBackground: true),
  'tuinkers': VegetableImageInfo(emoji: '🌱', greenBackground: false),
  'tuinboon': VegetableImageInfo(emoji: '🫛', greenBackground: true),
  'sugarsnaps': VegetableImageInfo(emoji: '🫛', greenBackground: false),
  'sjalot': VegetableImageInfo(emoji: '🧅', greenBackground: true),
  'pompoen': VegetableImageInfo(emoji: '🎃', greenBackground: false),
  'ijsbergsla': VegetableImageInfo(emoji: '🥬', greenBackground: true),
  'koolraap': VegetableImageInfo(emoji: '🟤', greenBackground: false),
  'augurk': VegetableImageInfo(emoji: '🥒', greenBackground: true),
  'snijbiet': VegetableImageInfo(emoji: '🥬', greenBackground: false),
  'artisjok': VegetableImageInfo(emoji: '🌿', greenBackground: true),
  'lente_ui': VegetableImageInfo(emoji: '🧅', greenBackground: false),
};

VegetableImageInfo vegetableImageFor(String vegetableId) {
  return kVegetableImages[vegetableId] ?? _defaultInfo;
}
