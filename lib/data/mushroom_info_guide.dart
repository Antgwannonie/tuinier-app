import '../models/vegetable.dart';
import '../utils/plant_display_info.dart';
import 'mushroom_info_layout.dart';
import 'mushroom_overview_data.dart';

enum _MushroomGrowStyle { indoorKit, woodBlock, compostDark, outdoorBed }

_MushroomGrowStyle _growStyleFor(String id) {
  switch (id) {
    case 'shiitake':
    case 'reishi':
    case 'maitake':
      return _MushroomGrowStyle.woodBlock;
    case 'kastanjechampignon':
    case 'portobello':
    case 'champignon_wit':
      return _MushroomGrowStyle.compostDark;
    case 'wijnrood_stropharia':
    case 'blauwe_ridderzwam':
    case 'morielzwam':
      return _MushroomGrowStyle.outdoorBed;
    default:
      return _MushroomGrowStyle.indoorKit;
  }
}

bool _isOutdoor(_MushroomGrowStyle style) => style == _MushroomGrowStyle.outdoorBed;

MushroomInfoGuide mushroomInfoGuideFor(
  Vegetable vegetable,
  MushroomInfoCategoryId category,
) {
  final overview = buildMushroomOverviewLayout(vegetable);
  final style = _growStyleFor(vegetable.id);
  final name = vegetable.nameNl.split('(').first.trim();
  final latin = latinNameForVegetable(vegetable) ?? vegetable.nameLatin ?? '';

  return MushroomInfoGuide(
    sections: switch (category) {
      MushroomInfoCategoryId.substraat =>
        _substraatSections(overview, style, name),
      MushroomInfoCategoryId.enten =>
        _entenSections(overview, style, name, vegetable),
      MushroomInfoCategoryId.kolonisatie =>
        _kolonisatieSections(overview, style, name),
      MushroomInfoCategoryId.vruchtvorming =>
        _vruchtvormingSections(overview, style, name),
      MushroomInfoCategoryId.omgeving =>
        _omgevingSections(overview, style, name),
      MushroomInfoCategoryId.water =>
        _waterSections(overview, style, name, vegetable),
      MushroomInfoCategoryId.groei =>
        _groeiSections(overview, style, name, vegetable),
      MushroomInfoCategoryId.oogsten =>
        _oogstenSections(overview, style, name, vegetable),
      MushroomInfoCategoryId.flushes =>
        _flushesSections(overview, style, name),
      MushroomInfoCategoryId.bewaren =>
        _bewarenSections(overview, name),
      MushroomInfoCategoryId.problemen =>
        _problemenSections(overview, style, name, vegetable),
      MushroomInfoCategoryId.weetjes =>
        _weetjesSections(overview, name, latin, vegetable),
    },
  );
}

List<MushroomInfoCategoryContent> mushroomInfoCategoriesFor(Vegetable vegetable) {
  return MushroomInfoCategoryId.values
      .map(
        (id) => MushroomInfoCategoryContent(
          id: id,
          guide: mushroomInfoGuideFor(vegetable, id),
        ),
      )
      .toList(growable: false);
}

List<MushroomInfoSection> _substraatSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
) {
  final alt = switch (style) {
    _MushroomGrowStyle.woodBlock => 'Hardhoutblokken, eiken- of beukenhout.',
    _MushroomGrowStyle.compostDark =>
      'Gecomposteerde paardenmest met stro (casinglaag).',
    _MushroomGrowStyle.outdoorBed =>
      'Compost, mulch, houtsnippers of bladeren.',
    _MushroomGrowStyle.indoorKit =>
      'Stro, zaagsel, koffiedik of kant-en-klare growkit.',
  };

  final prep = switch (style) {
    _MushroomGrowStyle.woodBlock =>
      'Gebruik vers, schoon hardhout. Laat blokken niet uitdrogen vóór inoculatie.',
    _MushroomGrowStyle.compostDark =>
      'Compost moet goed doorgewerkt en vochtig zijn. Voeg casinglaag toe na kolonisatie.',
    _MushroomGrowStyle.outdoorBed =>
      'Maak een bed van 10–20 cm compost of mulch. Houd vochtig en bedek met stro.',
    _MushroomGrowStyle.indoorKit =>
      'Substraat gelijkmatig vochtig maken. Growkits zijn vaak al voorbehandeld.',
  };

  final steril = style == _MushroomGrowStyle.indoorKit ||
          style == _MushroomGrowStyle.compostDark
      ? 'Voor zelfbereid substraat: steriliseer in drukketel (121 °C, 60–90 min) of gebruik een growkit.'
      : 'Houtblokken worden vaak gesteriliseerd vóór inoculatie. Buitenbedden worden gepasteuriseerd door compostering.';

  final pasteur = _isOutdoor(style)
      ? 'Buitenbedden worden gepasteuriseerd door compostering en vochtig houden (60–70 °C gedurende dagen).'
      : 'Pasteuriseer stro of zaagsel 1–2 uur bij 65–80 °C als je geen growkit gebruikt.';

  return [
    MushroomInfoSection(
      title: 'Beste substraat',
      body: 'Voor $name: ${o.substrate}.',
    ),
    MushroomInfoSection(
      title: 'Alternatieve substraten',
      body: alt,
    ),
    MushroomInfoSection(
      title: 'Substraat voorbereiden',
      body: prep,
      fullWidth: true,
    ),
    MushroomInfoSection(title: 'Steriliseren', body: steril),
    MushroomInfoSection(title: 'Pasteuriseren', body: pasteur),
    MushroomInfoSection(
      title: 'Ideaal vochtgehalte',
      body:
          'Substraat moet vochtig aanvoelen maar niet druipen. Luchtvochtigheid ${o.humidity} tijdens kolonisatie en vruchtzetting.',
    ),
    const MushroomInfoSection(
      title: 'Veelgemaakte fouten',
      body:
          'Te nat substraat veroorzaakt bacteriële rot. Te droog substraat stopt myceliumgroei. Werk altijd hygiënisch.',
      isWarning: true,
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _entenSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
  Vegetable v,
) {
  final when = _isOutdoor(style)
      ? 'Voorjaar (maart–mei): wanneer het bed vochtig is en temperaturen stijgen.'
      : 'Het hele jaar binnen, zodra substraat is voorbereid of growkit is aangeschaft.';

  final how = switch (style) {
    _MushroomGrowStyle.woodBlock =>
      'Verdeel spawn gelijkmatig in inoculatiepunten in het houtblok. Bedek met tape of was.',
    _MushroomGrowStyle.compostDark =>
      'Meng spawn door de compost en bedek met een casinglaag na kolonisatie.',
    _MushroomGrowStyle.outdoorBed =>
      'Meng spawn door compost/mulch en bedek met een laag stro om vocht te behouden.',
    _MushroomGrowStyle.indoorKit =>
      'Volg de instructies op de growkit: snijd open, vernevel en plaats op een schone ondergrond.',
  };

  final amount = _isOutdoor(style)
      ? 'Gebruik 50–100 g spawn per m² bed, afhankelijk van spawnkwaliteit.'
      : 'Growkit: meegeleverde hoeveelheid. Zelf substraat: 5–10 % spawn van het substraatgewicht.';

  return [
    const MushroomInfoSection(
      title: 'Wat is enten',
      body:
          'Enten is het toevoegen van mycelium (spawn of broed) aan substraat, zodat het substraat wordt gekoloniseerd.',
      fullWidth: true,
    ),
    MushroomInfoSection(title: 'Wanneer enten', body: when),
    MushroomInfoSection(title: 'Hoe enten', body: how, fullWidth: true),
    MushroomInfoSection(title: 'Hoeveel broed gebruiken', body: amount),
    MushroomInfoSection(
      title: 'Entpunten',
      body: style == _MushroomGrowStyle.woodBlock
          ? 'Maak 4–8 inoculatiepunten per blok, gelijkmatig verdeeld.'
          : 'Verdeel spawn gelijkmatig door het substraat voor snelle kolonisatie.',
    ),
    const MushroomInfoSection(
      title: 'Hygiëne',
      body:
          'Desinfecteer handen, gereedschap en werkplek met alcohol. Vermijd tocht en stof tijdens enten.',
      fullWidth: true,
    ),
    MushroomInfoSection(
      title: 'Veelgemaakte fouten',
      body:
          'Besmet substraat door onvoldoende hygiëne. Te weinig spawn vertraagt kolonisatie. ${v.commonIssues}',
      isWarning: true,
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _kolonisatieSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
) {
  final light = style == _MushroomGrowStyle.compostDark
      ? 'Volledige duisternis — licht remt kolonisatie van champignons.'
      : _isOutdoor(style)
          ? 'Donker of indirect licht; mycelium groeit onder de mulchlaag.'
          : 'Donker of indirect licht tijdens kolonisatie.';

  final duration = o.stages.length > 1
      ? o.stages[1].duration
      : '7–14 dagen (growkit) tot weken (houtblok)';

  return [
    MushroomInfoSection(
      title: 'Ideale temperatuur',
      body: '${o.temperature} tijdens kolonisatie van $name.',
    ),
    MushroomInfoSection(
      title: 'Ideale luchtvochtigheid',
      body: '${o.humidity} — houd het substraat gelijkmatig vochtig.',
    ),
    MushroomInfoSection(title: 'Licht of donker', body: light),
    MushroomInfoSection(
      title: 'Ventilatie',
      body:
          '${o.ventilation}${o.ventilationSubtitle != null ? ' (${o.ventilationSubtitle})' : ''}. Te veel tocht droogt substraat uit.',
    ),
    MushroomInfoSection(title: 'Kolonisatieduur', body: duration),
    const MushroomInfoSection(
      title: 'Gezonde kolonisatie herkennen',
      body:
          'Wit, dicht mycelium dat het substraat gelijkmatig overgroeit. Geen groene, zwarte of vieze geuren.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Problemen herkennen',
      body:
          'Groene schimmel (Trichoderma), zwarte aanslag of rotgeur wijzen op besmetting. Gele of bruine vlekken kunnen bacteriën zijn.',
      isWarning: true,
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _vruchtvormingSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
) {
  final start = switch (style) {
    _MushroomGrowStyle.woodBlock =>
      'Na volledige kolonisatie: koel schok (5–10 °C lager) en verhoog luchtvochtigheid.',
    _MushroomGrowStyle.compostDark =>
      'Na casinglaag en volledige kolonisatie: verlaag temperatuur licht en verhoog frisse lucht.',
    _MushroomGrowStyle.outdoorBed =>
      'Na regenperiodes in late zomer/herfst; natuurlijke temperatuurdaling stimuleert vruchtzetting.',
    _MushroomGrowStyle.indoorKit =>
      'Snijd de growkit open, vernevel 2–3× per dag en geef frisse lucht (CO₂ afvoeren).',
  };

  return [
    MushroomInfoSection(
      title: 'Vruchtvorming starten',
      body: start,
      fullWidth: true,
    ),
    MushroomInfoSection(title: 'Temperatuur', body: o.temperature),
    MushroomInfoSection(title: 'Luchtvochtigheid', body: o.humidity),
    MushroomInfoSection(title: 'Lichtbehoefte', body: o.light),
    MushroomInfoSection(
      title: 'Ventilatie',
      body:
          'Frisse lucht is essentieel. ${o.ventilation} — te weinig ventilatie geeft lange, dunne vruchtlichamen.',
    ),
    const MushroomInfoSection(
      title: 'CO₂ niveau',
      body:
          'Laag CO₂ (< 1000 ppm) stimuleert vruchtzetting. Ventileer kort maar regelmatig in plaats van constante tocht.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Pinheads herkennen',
      body:
          'Kleine knobbeltjes (pinheads) zijn het begin van vruchtlichamen. Verschijnen 3–7 dagen na het openen van de kit of na een koelschok.',
    ),
    MushroomInfoSection(
      title: 'Optimale omstandigheden',
      body:
          'Stabiele ${o.humidity}, ${o.temperature} en regelmatig vernevelen. Vermijd directe tocht op jonge pinheads.',
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _omgevingSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
) {
  final indoor = _isOutdoor(style)
      ? 'Vooruitkweken in tray mogelijk, maar hoofdteelt is buiten.'
      : 'Ideale plek: ${o.location}${o.locationSubtitle != null ? ' (${o.locationSubtitle})' : ''}.';

  return [
    MushroomInfoSection(title: 'Temperatuur', body: o.temperature),
    MushroomInfoSection(title: 'Luchtvochtigheid', body: o.humidity),
    MushroomInfoSection(title: 'Licht', body: o.light),
    MushroomInfoSection(
      title: 'Ventilatie',
      body:
          '${o.ventilation}${o.ventilationSubtitle != null ? ' — ${o.ventilationSubtitle}' : ''}.',
    ),
    MushroomInfoSection(title: 'Binnen kweken', body: indoor, fullWidth: true),
    MushroomInfoSection(
      title: 'Buiten kweken',
      body: _isOutdoor(style)
          ? 'Geschikt voor $name: compost- of mulchbed in halfschaduw, beschut tegen wind.'
          : 'Niet aanbevolen voor $name in ons klimaat, behalve in beschutte kas.',
    ),
    MushroomInfoSection(
      title: 'Kas',
      body: _isOutdoor(style)
          ? 'Kas kan gebruikt worden voor bescherming en vochtigheid.'
          : 'Verwarmde kas met vochtigheidsregeling is ideaal voor vruchtzetting.',
    ),
    MushroomInfoSection(
      title: 'Kelder',
      body: style == _MushroomGrowStyle.compostDark || style == _MushroomGrowStyle.indoorKit
          ? 'Koele kelder (${o.temperature}) is uitstekend voor $name.'
          : 'Koele, vochtige kelder kan geschikt zijn bij stabiele temperatuur.',
    ),
    MushroomInfoSection(
      title: 'Schuur',
      body: 'Onverwarmde schuur werkt als temperatuur stabiel blijft en vocht niet wegvloeit.',
    ),
  ];
}

List<MushroomInfoSection> _waterSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
  Vegetable v,
) {
  return [
    MushroomInfoSection(
      title: 'Water geven',
      body: v.water.isNotEmpty ? v.water : 'Substraat gelijkmatig vochtig houden.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Vernevelen',
      body:
          'Gebruik een plantenspuit of vernevelaar. Vernevel 2–3× per dag tijdens vruchtzetting, niet op mycelium tijdens kolonisatie.',
    ),
    MushroomInfoSection(
      title: 'Hoe vaak sproeien',
      body: _isOutdoor(style)
          ? 'Buitenbed: controleer dagelijks, sproei bij droog weer.'
          : 'Binnen: 2–3× per dag vernevelen tijdens vruchtzetting; 1× per dag tijdens kolonisatie.',
    ),
    const MushroomInfoSection(
      title: 'Te nat herkennen',
      body:
          'Druipend substraat, condens op wanden, muffe geur of groene schimmel. Verminder water en verbeter ventilatie.',
      isWarning: true,
    ),
    const MushroomInfoSection(
      title: 'Te droog herkennen',
      body:
          'Substraat voelt droog aan, mycelium krimpelt of stopt met groeien. Verhoog vernevelen en dek af met folie.',
      isWarning: true,
    ),
    const MushroomInfoSection(
      title: 'Beste type water',
      body: 'Gebruik regenwater of gefilterd kraanwater op kamertemperatuur. Geen chloorrijk water.',
    ),
    MushroomInfoSection(
      title: 'Luchtvochtigheid verhogen',
      body:
          'Plaats een bak water in de kweekruimte, gebruik een humidifier of dek het substraat af met een vochtige doek (niet direct op mycelium). Doel: ${o.humidity}.',
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _groeiSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
  Vegetable v,
) {
  final phases = o.stages
      .map((s) => '${s.label}: ${s.duration}')
      .join(' → ');

  return [
    MushroomInfoSection(
      title: 'Groeifases',
      body: phases,
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Myceliumgroei',
      body:
          'Wit netwerk dat substraat koloniseert. Duurt dagen tot weken afhankelijk van substraat en temperatuur.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Pinheads',
      body: 'Miniatuur vruchtlichamen; verschijnen na koelschok of opening van de kit.',
    ),
    const MushroomInfoSection(
      title: 'Jonge vruchtlichamen',
      body: 'Groeiende hoeden en stelen; gevoelig voor uitdroging en tocht.',
    ),
    const MushroomInfoSection(
      title: 'Volgroeide paddenstoelen',
      body: 'Hoed volledig gevormd maar nog niet volledig uitgespreid — ideaal oogstmoment.',
    ),
    MushroomInfoSection(
      title: 'Groeisnelheid',
      body: 'Eerste oogst na ${o.timeToHarvest}. ${v.cropDuration ?? ''}'.trim(),
    ),
    MushroomInfoSection(
      title: 'Verwachte opbrengst',
      body: '${o.yield}. ${o.flushCount}.',
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _oogstenSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
  Vegetable v,
) {
  return [
    MushroomInfoSection(
      title: 'Oogstperiode',
      body: v.harvest.isNotEmpty ? v.harvest : 'Doorlopend bij gunstige omstandigheden.',
    ),
    MushroomInfoSection(
      title: 'Wanneer oogsten',
      body: v.harvestTips.isNotEmpty
          ? v.harvestTips
          : 'Oogst wanneer hoed nog gesloten of net openstaat.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Oogstrijp herkennen',
      body:
          'Hoed is volledig gevormd, rand nog naar beneden of net plat. Vóór sporen vrijkomen voor beste houdbaarheid.',
    ),
    MushroomInfoSection(
      title: 'Hoe oogsten',
      body: style == _MushroomGrowStyle.indoorKit
          ? 'Draai en knip bij de basis van de steel. Niet rukken — beschadigt volgende flush.'
          : 'Snij met schoon mes bij de basis. Verwijder resten van steel.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Oogsttechniek',
      body:
          'Gebruik een scherp, schoon mes. Oogst in de ochtend als luchtvochtigheid het hoogst is.',
    ),
    MushroomInfoSection(
      title: 'Opbrengst per flush',
      body: o.yield,
    ),
    const MushroomInfoSection(
      title: 'Oogstproblemen',
      body:
          'Te laat oogsten: sporenregen en mindere smaak. Te vroeg: kleinere opbrengst. Uitdroging na oogst vermindert kwaliteit.',
      isWarning: true,
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _flushesSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
) {
  return [
    const MushroomInfoSection(
      title: 'Wat is een flush',
      body:
          'Een flush is een oogstgolf: alle vruchtlichamen die in korte tijd uit hetzelfde substraat verschijnen.',
      fullWidth: true,
    ),
    MushroomInfoSection(
      title: 'Eerste flush',
      body: 'Grootste opbrengst, meestal ${o.timeToHarvest} na start vruchtzetting.',
    ),
    const MushroomInfoSection(
      title: 'Tweede flush',
      body:
          'Volgt 1–2 weken na eerste oogst. Vernevel en geef frisse lucht; opbrengst iets lager.',
    ),
    const MushroomInfoSection(
      title: 'Derde flush',
      body: 'Kleinere vruchtlichamen maar nog steeds eetbaar. Houd substraat vochtig.',
    ),
    MushroomInfoSection(
      title: 'Verdere flushes',
      body: o.flushCount,
      fullWidth: true,
    ),
    MushroomInfoSection(title: 'Opbrengst per flush', body: o.yield),
    MushroomInfoSection(
      title: 'Substraat hergebruiken',
      body: style == _MushroomGrowStyle.woodBlock
          ? 'Houtblokken geven meerdere flushes over maanden. Breek niet te vroeg open.'
          : 'Growkit: meestal 2–5 flushes mogelijk. Daarna voedingswaarde afgenomen.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Flush stimuleren',
      body:
          'Na oogst: verwijder resten, vernevel, wacht 5–10 dagen. Koelschok kan nieuwe flush triggeren.',
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _bewarenSections(
  MushroomOverviewLayout o,
  String name,
) {
  return [
    const MushroomInfoSection(
      title: 'Koelkast bewaren',
      body:
          'In papieren zak of luchtdoorlatende doos: 3–7 dagen bij 2–4 °C. Niet in gesloten plastic.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Invriezen',
      body:
          'Kook kort (blancheren) en vries in. Geschikt voor soepen en sauzen; textuur verandert.',
    ),
    const MushroomInfoSection(
      title: 'Drogen',
      body:
          'Snijd in plakjes en droog bij 40–50 °C tot knapperig. Bewaar luchtdicht; lang houdbaar.',
    ),
    const MushroomInfoSection(
      title: 'Houdbaarheid',
      body: 'Vers: enkele dagen. Gedroogd: maanden tot een jaar. Bewaar koel en droog.',
    ),
    MushroomInfoSection(
      title: 'Bewaartips',
      body:
          'Oogst $name vers en verwerk snel. ${o.edibility}${o.edibilitySubtitle != null ? ' — ${o.edibilitySubtitle}' : ''}.',
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _problemenSections(
  MushroomOverviewLayout o,
  _MushroomGrowStyle style,
  String name,
  Vegetable v,
) {
  return [
    const MushroomInfoSection(
      title: 'Besmettingen',
      body:
          'Voorkom door hygiëne, schone lucht en correct vochtigheidsniveau. Besmet substraat direct verwijderen.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Bacteriën',
      body: 'Slijmerige, vieze geur en bruine vlekken. Oorzaak: te nat substraat. Verwijder besmet deel.',
    ),
    const MushroomInfoSection(
      title: 'Schimmels',
      body: 'Ongewenste schimmels door slechte hygiëne of vervuilde spawn.',
    ),
    const MushroomInfoSection(
      title: 'Trichoderma',
      body:
          'Groene schimmel die mycelium overwoekert. Meest voorkomende contaminant bij te hoge vochtigheid en warmte.',
      isWarning: true,
    ),
    const MushroomInfoSection(
      title: 'Te nat',
      body: 'Druipend substraat, bacteriële rot. Ventileer en verminder water.',
      isWarning: true,
    ),
    const MushroomInfoSection(
      title: 'Te droog',
      body: 'Mycelium stopt, pinheads verdrogen. Verhoog vernevelen.',
      isWarning: true,
    ),
    const MushroomInfoSection(
      title: 'Geen vruchtvorming',
      body:
          'Oorzaken: te hoog CO₂, verkeerde temperatuur, onvoldoende licht of onvolledige kolonisatie. Geef frisse lucht en pas omstandigheden aan.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Misvormde paddenstoelen',
      body:
          'Lange, dunne stelen: te weinig licht of te hoog CO₂. Gekrulde hoeden: uitdroging.',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Symptomen herkennen',
      body:
          'Let op kleur (groen = Trichoderma), geur (rot = bacteriën) en textuur (slijmerig = besmetting).',
      fullWidth: true,
    ),
    MushroomInfoSection(
      title: 'Oplossingen',
      body: v.commonIssues.isNotEmpty
          ? v.commonIssues
          : 'Verbeter hygiëne, ventilatie en vochtigheid. ${o.goodToKnow}',
      fullWidth: true,
    ),
  ];
}

List<MushroomInfoSection> _weetjesSections(
  MushroomOverviewLayout o,
  String name,
  String latin,
  Vegetable v,
) {
  final medicinal = v.id == 'reishi'
      ? 'Reishi (Ganoderma lucidum) wordt al eeuwenlang gebruikt in de traditionele Chinese geneeskunde.'
      : 'Sommige paddenstoelen hebben medicinale eigenschappen; raadpleeg betrouwbare bronnen.';

  return [
    MushroomInfoSection(
      title: 'Oorsprong',
      body: latin.isNotEmpty
          ? '$name ($latin) komt van nature voor in gematigde en tropische klimaten.'
          : '$name komt van nature voor in diverse klimaten wereldwijd.',
    ),
    const MushroomInfoSection(
      title: 'Historie',
      body:
          'Paddenstoelen worden al duizenden jaren geteeld en gegeten, vooral in Azië. Moderne growkits maken kweken toegankelijk.',
      fullWidth: true,
    ),
    MushroomInfoSection(
      title: 'Familie',
      body: latin.isNotEmpty ? 'Wetenschappelijke naam: $latin.' : 'Familie: ${v.family}.',
    ),
    MushroomInfoSection(
      title: 'Bijzonderheden',
      body: o.summary,
      fullWidth: true,
    ),
    MushroomInfoSection(
      title: 'Gebruik in de keuken',
      body:
          '${o.edibility}${o.edibilitySubtitle != null ? '. ${o.edibilitySubtitle}' : ''}. ${v.summary}',
      fullWidth: true,
    ),
    const MushroomInfoSection(
      title: 'Gezondheidsvoordelen',
      body:
          'Paddenstoelen zijn rijk aan eiwitten, vezels en B-vitamines. Verschilt per soort.',
      fullWidth: true,
    ),
    MushroomInfoSection(
      title: 'Medicinale eigenschappen',
      body: medicinal,
      fullWidth: true,
    ),
    MushroomInfoSection(
      title: 'Leuk weetje',
      body: o.goodToKnow,
      fullWidth: true,
    ),
  ];
}
