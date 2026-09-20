import '../models/vegetable.dart';

import 'mushroom_guide_card_data.dart';
import 'mushroom_overview_data.dart';
import 'plant_guide_detail.dart';



class MushroomProblemCard {

  const MushroomProblemCard({

    required this.title,

    required this.description,

    required this.causes,

    required this.solutions,

    required this.assetPath,

  });



  final String title;

  final String description;

  final List<String> causes;

  final List<String> solutions;

  final String assetPath;

}



class QuickRecognitionItem {

  const QuickRecognitionItem({

    required this.label,

    required this.assetPath,

  });



  final String label;

  final String assetPath;

}



class MushroomProblemsGuide with MushroomGuideCardData {

  const MushroomProblemsGuide({

    required this.earlyRecognitionBody,

    required this.commonProblems,

    required this.quickRecognition,

    required this.checklistItems,

    required this.checklistTip,

    required this.discardSignals,

    required this.extraHelpBody,

    this.cardSummaries = const {},

    this.cardDetails = const {},

  });



  final String earlyRecognitionBody;

  final List<MushroomProblemCard> commonProblems;

  final List<QuickRecognitionItem> quickRecognition;

  final List<String> checklistItems;

  final String checklistTip;

  final List<String> discardSignals;

  final String extraHelpBody;

  @override
  final Map<String, String> cardSummaries;

  @override
  final Map<String, List<PlantGuideDetailBlock>> cardDetails;

}



const _asset = 'assets/images/mushroom_problems';



const _commonProblems = [

  MushroomProblemCard(

    title: 'Schimmelgroei',

    description:

        'Ongewenste schimmel (zoals Trichoderma) overwoekert het mycelium en kan de hele oogst vernietigen.',

    causes: [

      'Te hoge luchtvochtigheid zonder ventilatie',

      'Besmet substraat of spawn',

      'Onvoldoende hygiëne bij enten',

      'Te warme kweekruimte',

    ],

    solutions: [

      'Verwijder besmet deel direct',

      'Verbeter ventilatie en luchtuitwisseling',

      'Verlaag temperatuur en vochtigheid',

      'Werk altijd hygiënisch met schone handen',

    ],

    assetPath: '$_asset/problems_mold.png',

  ),

  MushroomProblemCard(

    title: 'Bacteriële besmetting',

    description:

        'Slijmerige, bruine of gele vlekken met vieze geur wijzen op bacteriële rot in het substraat.',

    causes: [

      'Te nat substraat (druipend)',

      'Slechte luchtcirculatie',

      'Onvoldoende sterilisation/pasteurisatie',

      'Condens op mycelium',

    ],

    solutions: [

      'Verwijder besmet substraat onmiddellijk',

      'Verminder watergift en vernevelen',

      'Verbeter ventilatie na vernevelen',

      'Houd substraat vochtig maar niet druipend',

    ],

    assetPath: '$_asset/problems_bacterial.png',

  ),

  MushroomProblemCard(

    title: 'Geen of weinig groei',

    description:

        'Mycelium groeit niet verder of er verschijnen geen pinheads na volledige kolonisatie.',

    causes: [

      'Onvolledige kolonisatie',

      'Te hoog CO₂-niveau',

      'Verkeerde temperatuur',

      'Onvoldoende licht of frisse lucht',

    ],

    solutions: [

      'Wacht tot substraat volledig wit is',

      'Geef frisse lucht (open growkit kort)',

      'Controleer temperatuur en pas aan',

      'Verhoog indirect licht en luchtvochtigheid',

    ],

    assetPath: '$_asset/problems_no_growth.png',

  ),

  MushroomProblemCard(

    title: 'Langzame groei',

    description:

        'Mycelium of pinheads groeien trager dan verwacht; vruchtlichamen blijven klein.',

    causes: [

      'Te lage temperatuur',

      'Te droog substraat',

      'Oude of zwakke spawn',

      'Onvoldoende voedingsstoffen in substraat',

    ],

    solutions: [

      'Controleer en verhoog temperatuur indien nodig',

      'Vernevel regelmatig maar kort',

      'Gebruik verse, kwalitatieve spawn',

      'Houd omstandigheden stabiel',

    ],

    assetPath: '$_asset/problems_slow_growth.png',

  ),

  MushroomProblemCard(

    title: 'Misvormde pinheads',

    description:

        'Lange dunne stelen, gekrulde hoeden of vervormde vruchtlichamen tijdens groei.',

    causes: [

      'Te hoog CO₂ (weinig frisse lucht)',

      'Te weinig indirect licht',

      'Uitdroging of tocht op jonge pinheads',

      'Temperatuurschommelingen',

    ],

    solutions: [

      'Ventileer kort maar regelmatig',

      'Geef 8–12 uur indirect daglicht',

      'Vermijd tocht op jonge vruchtlichamen',

      'Houd temperatuur en vochtigheid stabiel',

    ],

    assetPath: '$_asset/problems_deformed_pins.png',

  ),

];



const _quickRecognition = [

  QuickRecognitionItem(

    label: 'Groene schimmel',

    assetPath: '$_asset/problems_quick_green_mold.png',

  ),

  QuickRecognitionItem(

    label: 'Zwarte schimmel',

    assetPath: '$_asset/problems_quick_black_mold.png',

  ),

  QuickRecognitionItem(

    label: 'Gele vlekken',

    assetPath: '$_asset/problems_quick_yellow.png',

  ),

  QuickRecognitionItem(

    label: 'Plakkerig of nat',

    assetPath: '$_asset/problems_quick_wet.png',

  ),

  QuickRecognitionItem(

    label: 'Zwakke groei',

    assetPath: '$_asset/problems_quick_weak.png',

  ),

];



MushroomProblemsGuide problemsGuideForVegetable(Vegetable vegetable) {

  final overview = buildMushroomOverviewLayout(vegetable);

  final name = vegetable.nameNl.split('(').first.trim();

  final style = _problemsStyleFor(vegetable.id);



  final earlyBody = switch (style) {

    _ProblemsStyle.outdoor =>

      'Controleer je $name-bed dagelijks op kleur, geur en textuur. Buiten is besmetting lastiger te stoppen — handel snel bij de eerste signalen.',

    _ProblemsStyle.woodBlock =>

      'Inspecteer houtblokken wekelijks. Groene of zwarte plekken op $name-blokken verspreiden zich langzaam maar zijn moeilijk te genezen.',

    _ProblemsStyle.compost =>

      'Controleer composttrays dagelijks. Champignons zijn gevoelig voor bacteriën bij te nat substraat — let op geur en vocht.',

    _ProblemsStyle.indoorKit =>

      'Controleer je growkit dagelijks op kleur, geur en textuur. Vroeg ingrijpen voorkomt dat problemen het hele substraat besmetten.',

  };



  final checklistTip = switch (style) {

    _ProblemsStyle.outdoor =>

      'Buiten: verwijder besmet materiaal direct en bedek het bed opnieuw met schone mulch.',

    _ProblemsStyle.woodBlock =>

      'Houtblokken: kleine besmettingen kunnen soms worden weggesneden; grote besmetting = blok weggooien.',

    _ProblemsStyle.compost =>

      'Compost: houd casinglaag droog en ventileer goed om schimmel te voorkomen.',

    _ProblemsStyle.indoorKit =>

      'Tip: noteer problemen in een logboek — zo herken je patronen en voorkom je herhaling.',

  };



  final extraHelp = vegetable.commonIssues.isNotEmpty

      ? 'Specifiek voor $name: ${vegetable.commonIssues} ${overview.goodToKnow}'

      : 'Bij aanhoudende problemen: controleer hygiëne, ventilatie en vochtigheid opnieuw. ${overview.goodToKnow}';



  return MushroomProblemsGuide(

    earlyRecognitionBody: earlyBody,

    commonProblems: _commonProblems,

    quickRecognition: _quickRecognition,

    checklistItems: [

      'Controleer kleur van mycelium (wit = goed)',

      'Ruik aan substraat (muffig = probleem)',

      'Voel vochtigheid (vochtig, niet druipend)',

      'Let op groene, zwarte of gele vlekken',

      'Controleer temperatuur (${overview.temperature})',

      'Meet luchtvochtigheid (${overview.humidity})',

      'Ventileer regelmatig voor frisse lucht',

      'Werk hygiënisch met schone handen',

    ],

    checklistTip: checklistTip,

    discardSignals: const [

      'Groene schimmel over meer dan 30% van substraat',

      'Sterke rot- of vieze geur',

      'Slijmerige, bruine bacteriële vlekken',

      'Zwarte aanslag die snel groeit',

      'Meerdere mislukte flushes achter elkaar',

      'Substraat volledig verkleurd en stinkend',

    ],

    extraHelpBody: extraHelp,

    cardSummaries: mushroomCardSummaries(
      tab: 'problems',
      vegetable: vegetable,
      titles: const [
        'Problemen vroeg herkennen',
        'Veelvoorkomende problemen',
        'Problemen snel herkennen',
        'Algemene checklist bij problemen',
        'Wanneer een blok weggooien?',
        'Extra hulp nodig?',
      ],
    ),

    cardDetails: {
      'Problemen vroeg herkennen': mushroomDetailBlocks(fullBody: earlyBody),
      'Veelvoorkomende problemen': [
        for (final p in _commonProblems)
          PlantGuideDetailBlock(
            heading: p.title,
            body:
                '${p.description}\n\nOorzaken:\n${p.causes.map((c) => '• $c').join('\n')}\n\nOplossing:\n${p.solutions.map((s) => '• $s').join('\n')}',
          ),
      ],
      'Problemen snel herkennen': mushroomDetailBlocks(
        fullBody: _quickRecognition.map((q) => '• ${q.label}').join('\n'),
      ),
      'Algemene checklist bij problemen': mushroomDetailBlocks(
        fullBody:
            '${[
              'Controleer kleur van mycelium (wit = goed)',
              'Ruik aan substraat (muffig = probleem)',
              'Voel vochtigheid (vochtig, niet druipend)',
              'Let op groene, zwarte of gele vlekken',
              'Controleer temperatuur (${overview.temperature})',
              'Meet luchtvochtigheid (${overview.humidity})',
              'Ventileer regelmatig voor frisse lucht',
              'Werk hygiënisch met schone handen',
            ].map((i) => '• $i').join('\n')}\n\n$checklistTip',
      ),
      'Wanneer een blok weggooien?': mushroomDetailBlocks(
        fullBody: const [
          'Groene schimmel over meer dan 30% van substraat',
          'Sterke rot- of vieze geur',
          'Slijmerige, bruine bacteriële vlekken',
          'Zwarte aanslag die snel groeit',
          'Meerdere mislukte flushes achter elkaar',
          'Substraat volledig verkleurd en stinkend',
        ].map((s) => '• $s').join('\n'),
      ),
      'Extra hulp nodig?': mushroomDetailBlocks(fullBody: extraHelp),
    },

  );

}



enum _ProblemsStyle { indoorKit, woodBlock, compost, outdoor }



_ProblemsStyle _problemsStyleFor(String id) {

  switch (id) {

    case 'shiitake':

    case 'reishi':

    case 'maitake':

      return _ProblemsStyle.woodBlock;

    case 'kastanjechampignon':

    case 'portobello':

    case 'champignon_wit':

      return _ProblemsStyle.compost;

    case 'wijnrood_stropharia':

    case 'blauwe_ridderzwam':

    case 'morielzwam':

      return _ProblemsStyle.outdoor;

    default:

      return _ProblemsStyle.indoorKit;

  }

}

