/**
 * Genereert curated Uitplanten-gidsen voor alle planten behalve bloemen/paddenstoelen.
 */
import fs from 'fs';

const overview = JSON.parse(
  fs.readFileSync('tool/vegetable_overview_all.json', 'utf8'),
);
const targetIds = [
  ...new Set(JSON.parse(fs.readFileSync('tool/sowing_target_ids.json', 'utf8'))),
];

const MONTHS = [
  '',
  'januari',
  'februari',
  'maart',
  'april',
  'mei',
  'juni',
  'juli',
  'augustus',
  'september',
  'oktober',
  'november',
  'december',
];

function monthRange(arr) {
  if (!arr?.length) return null;
  const s = [...arr].sort((a, b) => a - b);
  if (s.length === 1) return MONTHS[s[0]];
  return `${MONTHS[s[0]]} – ${MONTHS[s[s.length - 1]]}`;
}

function setLit(arr) {
  if (!arr?.length) return 'null';
  return `{${[...new Set(arr)].sort((a, b) => a - b).join(', ')}}`;
}

function esc(s) {
  return String(s ?? '')
    .replace(/\\/g, '\\\\')
    .replace(/'/g, "\\'");
}

function parseCm(text) {
  if (!text) return null;
  const m = String(text).match(/(\d+)/);
  return m ? Number(m[1]) : null;
}

function prettyName(id) {
  return id
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

/** Transplant profile fields */
function P(o) {
  return o;
}

const PROFILES = {
  tomaat: P({
    frost: true,
    support: true,
    conditions: ['Geen nachtvorst (na ijsheiligen).', 'Bodem ≥ 12–15 °C.', 'Plant 15–25 cm hoog / 5–7 bladeren.'],
    harden: '7–10 dagen afharden; begin kort, eindig met vorstvrije nacht buiten.',
    depth: 'Iets dieper dan in de pot (tot net onder de zaadlobben/onderste blad).',
    depthWhy: 'Tomaat maakt steunwortels aan de stengel; dieper planten geeft stevigere planten.',
    soil: 'Rijke, goed doorlatende grond met compost; niet te stikstofrijk ten koste van bloei.',
    water: 'Direct aangieten; eerste 10 dagen regelmatig vochtig, daarna dieper minder vaak.',
    protect: ['nachtvorst', 'wind', 'slakken'],
    establish: '7–14 dagen',
    firstGrowth: '7–14 dagen nieuw blad',
    mistakes: ['Te vroeg bij kou', 'Niet afharden', 'Geen steun gezet', 'Te weinig water eerste week'],
    supportHow: 'Zet meteen een stok of tomatenkooi; bind losjes aan naarmate de plant groeit.',
  }),
  paprika: P({
    frost: true,
    support: true,
    conditions: ['Nachten bij voorkeur >10–12 °C.', 'Bodem warm.', 'Stevige plant met meerdere echte bladeren.'],
    harden: '7–10 dagen; paprika is gevoeliger voor kou dan tomaat.',
    depth: 'Op dezelfde diepte als in de pot.',
    depthWhy: 'Paprika maakt minder makkelijk steunwortels; niet te diep begraven.',
    soil: 'Voedzaam, warm, goed doorlatend; compost vooraf.',
    water: 'Aangieten; daarna gelijkmatig vochtig, niet koud water.',
    protect: ['nachtvorst', 'wind', 'felle zon'],
    establish: '10–14 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Uitplanten in koude grond', 'Geen afharden', 'Te natte koude potgrond'],
    supportHow: 'Kooi of stok bij grotere rassen; pepers kunnen omwaaien met zware vrucht.',
  }),
  aubergine: P({
    frost: true,
    support: true,
    conditions: ['Echte zomerwarmte; vaak pas juni.', 'Bodem warm.', 'Kas helpt sterk in NL.'],
    harden: 'Alleen bij warm weer; 5–7 dagen.',
    depth: 'Zelfde diepte als pot.',
    depthWhy: 'Voorkom stengelrot door te diep planten in koude grond.',
    soil: 'Rijk en warm; zwarte mulch kan helpen opwarmen.',
    water: 'Aangieten met lauw water; warmte belangrijker dan veel water.',
    protect: ['nachtvorst', 'wind'],
    establish: '10–21 dagen',
    firstGrowth: '2–3 weken',
    mistakes: ['Te vroeg', 'Koude grond', 'Geen kas/beschutting'],
    supportHow: 'Stok of kooi; vruchten worden zwaar.',
  }),
  komkommer: P({
    frost: true,
    support: true,
    conditions: ['Na ijsheiligen.', 'Bodem ≥ 15 °C.', '2–4 echte bladeren; niet overgroeid in pot.'],
    harden: '5–7 dagen; bescherm tegen koude wind.',
    depth: 'Zelfde diepte als pot; kluit intact houden.',
    depthWhy: 'Gevoelige wortels; verstoring remt aanslaan.',
    soil: 'Rijk, vochthoudend, compost; pH neutraal tot licht zuur.',
    water: 'Riant aangieten; daarna regelmatig vochtig houden.',
    protect: ['nachtvorst', 'slakken', 'wind'],
    establish: '5–10 dagen',
    firstGrowth: '5–10 dagen (snel)',
    mistakes: ['Wortelkluit breken', 'Te vroeg', 'Geen latwerk'],
    supportHow: 'Latwerk, net of touw meteen plaatsen voor klimrassen.',
  }),
  courgette: P({
    frost: true,
    support: false,
    conditions: ['Na ijsheiligen.', 'Warme grond.', 'Compacte plant, niet potgebonden.'],
    harden: '5–7 dagen.',
    depth: 'Zelfde diepte; ruim plantgat.',
    depthWhy: 'Brede wortels hebben losse grond nodig.',
    soil: 'Zeer voedselrijk; compost/mest goed verwerkt.',
    water: 'Goed aangieten; later diep water geven.',
    protect: ['nachtvorst', 'slakken'],
    establish: '5–10 dagen',
    firstGrowth: 'binnen 1 week vaak zichtbaar',
    mistakes: ['Te vroeg', 'Te arme grond', 'Te dicht op elkaar'],
    supportHow: 'Meestal geen steun; eventueel bij lange rankers.',
  }),
  pompoen: P({
    frost: true,
    support: false,
    conditions: ['Mei–juni na kou.', 'Warme, rijke grond.', 'Veel ruimte.'],
    harden: '5–7 dagen.',
    depth: 'Zelfde diepte; plantgat met compost.',
    depthWhy: 'Grote groeiers starten beter in losse, voedzame grond.',
    soil: 'Diep bewerkt, compostrijk.',
    water: 'Aangieten; mulch helpt later.',
    protect: ['nachtvorst', 'slakken'],
    establish: '7–14 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Te weinig ruimte', 'Koude grond', 'Wortelschade'],
    supportHow: 'Rankers kunnen geleid worden; bos-types niet nodig.',
  }),
  meloen: P({
    frost: true,
    support: true,
    conditions: ['Kas of zeer warme plek.', 'Juni vaak realistischer buiten.', 'Warmte belangrijker dan vroeg.'],
    harden: 'Alleen bij warm weer, kort.',
    depth: 'Zelfde diepte; kluit behouden.',
    depthWhy: 'Wortelstoring remt warmteminnende cucurbits.',
    soil: 'Warm, rijk, goed doorlatend; kasgrond of zwarte mulch.',
    water: 'Lauw aangieten; daarna vochtig maar warm houden.',
    protect: ['nachtvorst', 'koude wind'],
    establish: '10–14 dagen',
    firstGrowth: '1–3 weken',
    mistakes: ['Buiten te koud', 'Geen kas', 'Te nat + koud'],
    supportHow: 'Touw/latwerk in kas; bestuiving soms helpen.',
  }),
  sla: P({
    frost: false,
    support: false,
    conditions: ['Koel weer oké.', 'Vermijd hittegolven.', '4–6 bladeren bij uitplant.'],
    harden: '3–5 dagen; sla verdraagt koelte goed.',
    depth: 'Hart níet begraven; kluit gelijk met grond.',
    depthWhy: 'Bedolven hart rot makkelijk weg.',
    soil: 'Vochtig, luchtig, matig voedzaam.',
    water: 'Direct water; nooit laten uitdrogen.',
    protect: ['slakken', 'felle zon'],
    establish: '5–10 dagen',
    firstGrowth: 'binnen een week',
    mistakes: ['Hart begraven', 'Uitdrogen', 'Uitplanten in hitte'],
    supportHow: 'Geen steun nodig.',
  }),
  spinazie: P({
    frost: false,
    support: false,
    conditions: ['Liever koel seizoen.', 'Vaak ter plaatse gezaaid; uitplanten met kluit.'],
    harden: 'Kort of niet nodig bij stevige modules.',
    depth: 'Zelfde diepte; niet te diep.',
    depthWhy: 'Penwortelachtig; verstoring remt.',
    soil: 'Vochtig, stikstofarm tot matig, niet zuur verdicht.',
    water: 'Vochtig houden tot aanslaan.',
    protect: ['slakken', 'felle zon'],
    establish: '5–12 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Hitte', 'Uitdrogen', 'Wortelschade'],
    supportHow: 'Geen steun.',
  }),
  biet: P({
    frost: false,
    support: false,
    conditions: ['Vanaf april mogelijk.', 'Modules met kluit uitplanten.'],
    harden: '3–5 dagen.',
    depth: 'Zelfde diepte; niet dieper begraven.',
    depthWhy: 'Te diep geeft rare knolvorm.',
    soil: 'Los, steenvrij, niet vers bemest met verse stikstofpiek.',
    water: 'Aangieten; gelijkmatig vocht.',
    protect: ['slakken'],
    establish: '7–14 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Te diep', 'Verdichte grond', 'Uitdrogen'],
    supportHow: 'Geen steun.',
  }),
  wortel: P({
    frost: false,
    support: false,
    conditions: ['Bij voorkeur NIET verplanten.', 'Alleen diepe modules als het moet.'],
    harden: 'N.v.t. / minimaal bij modules.',
    depth: 'Zaai bij voorkeur ter plaatse; module: niet verstoren.',
    depthWhy: 'Penwortel breekt en vertakt bij verplanten.',
    soil: 'Diep los, steenvrij, geen verse mest.',
    water: 'Constant vochtig tot opkomst/aanslaan.',
    protect: ['slakken bij jonge plantjes'],
    establish: 'bij modules 1–2 weken',
    firstGrowth: 'traag',
    mistakes: ['Gewoon verspenen', 'Stenen in grond', 'Uitdrogen in kiemfase'],
    supportHow: 'Geen steun.',
    note: 'Wortel hoort ter plaatse gezaaid; uitplanten alleen met speciale diepe trays.',
  }),
  radijs: P({
    frost: false,
    support: false,
    conditions: ['Meestal ter plaatse zaaien.', 'Uitplanten zelden zinvol.'],
    harden: 'N.v.t.',
    depth: 'Ter plaatse 1 cm zaaien.',
    depthWhy: 'Snelle teelt; verplanten loont niet.',
    soil: 'Los, vochtig.',
    water: 'Gelijkmatig vochtig voor milde knollen.',
    protect: ['slakken'],
    establish: 'n.v.t. / dagen',
    firstGrowth: 'zeer snel',
    mistakes: ['Verplanten', 'Droogte', 'Te dicht laten staan'],
    supportHow: 'Geen steun.',
    note: 'Radijs zaai je vrijwel altijd ter plaatse.',
  }),
  kool: P({
    frost: false,
    support: false,
    conditions: ['Afhankelijk van type: voorjaar of zomer uitplanten.', 'Stevige plant ±10–15 cm.'],
    harden: '5–7 dagen.',
    depth: 'Iets dieper dan pot voor stevigheid.',
    depthWhy: 'Dieper zetten voorkomt omwaaien bij jonge kool.',
    soil: 'Voedzaam, vast genoeg, goede kalkstatus vaak gewenst.',
    water: 'Goed aangieten; net tegen koolvlieg overwegen.',
    protect: ['koolvlieg', 'rupsen', 'duiven'],
    establish: '7–14 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Geen net', 'Te droog', 'Te klein uitplanten'],
    supportHow: 'Meestal geen; grote spruitkool soms aanaarden.',
  }),
  ui: P({
    frost: false,
    support: false,
    conditions: ['Vroege lente voor plantui/zaaiui-plantjes.', 'Bosjes uitplanten mogelijk.'],
    harden: 'Kort bij zaailingen.',
    depth: 'Plantui: tip net zichtbaar; zaailingen niet te diep.',
    depthWhy: 'Te diep remt bolvorming.',
    soil: 'Los, niet vers bemest, onkruidvrij.',
    water: 'Aangieten; daarna niet te nat.',
    protect: ['vogels'],
    establish: '1–3 weken',
    firstGrowth: '1–3 weken',
    mistakes: ['Te diep', 'Onkruidconcurrentie', 'Natte grond'],
    supportHow: 'Geen steun.',
  }),
  prei: P({
    frost: false,
    support: false,
    conditions: ['Uitplanten als potlooddik.', 'Geultjes voor witte schacht.'],
    harden: '3–5 dagen.',
    depth: 'Diep in geul/gat planten; later aanzarden.',
    depthWhy: 'Diep planten bleekt de eetbare schacht.',
    soil: 'Diep bewerkt, voedzaam, vochthoudend.',
    water: 'Goed aangieten na uitplanten.',
    protect: ['uienvlieg / preimot netten'],
    establish: '2–3 weken',
    firstGrowth: '2–3 weken',
    mistakes: ['Te ondiep', 'Uitdrogen na uitplant', 'Geen ruimte'],
    supportHow: 'Geen steun; wel aanaarden.',
  }),
  knoflook: P({
    frost: false,
    support: false,
    conditions: ['Tenen poten in najaar of vroeg voorjaar.', 'Geen klassieke uitplantzaailing.'],
    harden: 'N.v.t.',
    depth: 'Tenen 3–5 cm, punt omhoog.',
    depthWhy: 'Vegetatieve teelt via teen.',
    soil: 'Doorlatend, niet te nat in winter.',
    water: 'Na poten vochtig; winter niet sopnat.',
    protect: ['vorst wisseling mulch'],
    establish: 'wortels in weken',
    firstGrowth: 'loof in voorjaar',
    mistakes: ['Supermarktknoflook', 'Natte klei', 'Te diep/te ondiep'],
    supportHow: 'Geen steun.',
    note: 'Knoflook/sjalot: tenen poten, geen uitplantzaailing.',
  }),
  aardappel: P({
    frost: false,
    support: false,
    conditions: ['Pootgoed poten als grond bewerkbaar is.', 'Geen zaailing-uitplant.'],
    harden: 'Voorkiemen i.p.v. afharden.',
    depth: '8–12 cm; later aanaarden.',
    depthWhy: 'Bedekking voorkomt groen worden en vorstschade aan kiemen.',
    soil: 'Los, niet vers gemest met verse stikstofpiek.',
    water: 'Niet poten in natte klei; na opkomst regelmatig vocht.',
    protect: ['late vorst op loof', 'coloradokever later'],
    establish: 'opkomst 2–4 weken',
    firstGrowth: 'loof na opkomst',
    mistakes: ['Supermarkt knollen', 'Nat poten', 'Niet aanaarden'],
    supportHow: 'Aanaarden = steun/bedekking.',
    note: 'Aardappel: pootgoed, geen klassieke uitplantzaailing. Zoete aardappel is anders (stekken).',
  }),
  mais: P({
    frost: true,
    support: false,
    conditions: ['Na ijsheiligen.', 'Blokvormig planten voor bestuiving.', 'Bodem warm.'],
    harden: 'Kort; mais groeit snel door.',
    depth: 'Zelfde diepte; stevig aandrukken.',
    depthWhy: 'Jonge mais waait makkelijk om.',
    soil: 'Voedzaam, warm.',
    water: 'Aangieten; later diep water bij droogte.',
    protect: ['vogels', 'nachtvorst'],
    establish: '7–14 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Enkele rij (slechte bestuiving)', 'Koude grond', 'Vogelschade'],
    supportHow: 'Meestal geen; aanaarden helpt standvastigheid.',
  }),
  boon: P({
    frost: true,
    support: true,
    conditions: ['Warme grond (>12–15 °C).', 'Na ijsheiligen.', 'Niet te vroeg.'],
    harden: 'Kort bij potzaailingen.',
    depth: 'Zelfde diepte; kluit behouden.',
    depthWhy: 'Bonen houden niet van wortelstoring.',
    soil: 'Niet vers bemest; matig rijk.',
    water: 'Aangieten; niet koud en nat.',
    protect: ['nachtvorst', 'slakken', 'vogels'],
    establish: '5–12 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Koude grond', 'Wortelschade', 'Geen steun bij stokboon'],
    supportHow: 'Stok/latwerk meteen bij stokbonen.',
  }),
  erwt: P({
    frost: false,
    support: true,
    conditions: ['Vroege teelt; koel weer oké.', 'Steun klaarzetten.'],
    harden: 'Minimaal.',
    depth: 'Zelfde diepte / ter plaatse vaak beter.',
    depthWhy: 'Wortelgevoelig.',
    soil: 'Los, niet te stikstofrijk.',
    water: 'Vochtig tot aanslaan; later bij bloei water.',
    protect: ['vogels', 'muizen'],
    establish: '7–14 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Geen net tegen vogels', 'Geen steun', 'Hitte'],
    supportHow: 'Net, gaas of twijgen bij het planten/zaaien.',
  }),
  kruid_zacht: P({
    frost: true,
    support: false,
    conditions: ['Na IJsheiligen (~half mei); geen nachtvorst.', 'Stevige mini-plant.'],
    harden: '5–7 dagen zorgvuldig afharden.',
    depth: 'Zelfde diepte; niet te diep.',
    depthWhy: 'Fijne stengels rotten makkelijk te diep.',
    soil: 'Luchtig, drainage in potten essentieel.',
    water: 'Aangieten; daarna niet sopnat.',
    protect: ['nachtvorst', 'slakken'],
    establish: '5–14 dagen',
    firstGrowth: '1–2 weken',
    mistakes: ['Te vroeg buiten', 'Te natte pot', 'Te weinig licht'],
    supportHow: 'Meestal geen.',
  }),
  kruid_hard: P({
    frost: false,
    support: false,
    conditions: ['Voorjaar of najaar planten.', 'Stevige plant of scheurlings.'],
    harden: 'Bij potplanten 3–5 dagen.',
    depth: 'Zelfde diepte als in pot; hart vrij houden.',
    depthWhy: 'Te diep planten remt uitlopers bij vaste kruiden.',
    soil: 'Doorlatend; mediterrane kruiden liever mager dan te rijk.',
    water: 'Aangieten; daarna matig — natte winters zijn riskanter dan vorst.',
    protect: ['slakken (jong)', 'natte klei zonder drainage'],
    establish: '1–3 weken',
    firstGrowth: '1–3 weken',
    mistakes: ['Te natte stand', 'Te rijke compostdump', 'Te diep planten'],
    supportHow: 'Meestal geen.',
    note: 'Vaste/winterharde kruiden (o.a. citroenmelisse, tijm, salie, oregano, munt in pot).',
  }),
  kruid_tropisch: P({
    frost: true,
    support: false,
    conditions: ['Pas na IJsheiligen; kas of beschutte warme plek.', 'Geen koude nachten.'],
    harden: 'Alleen bij mild weer; anders direct in kas/pot binnen.',
    depth: 'Zelfde diepte; goede drainage.',
    depthWhy: 'Wortelrot bij koude natte grond.',
    soil: 'Luchtig, warm, goed doorlatend.',
    water: 'Gelijkmatig vochtig, nooit koud en nat.',
    protect: ['kou', 'tocht', 'nachtvorst'],
    establish: '1–2 weken bij warmte',
    firstGrowth: '1–2 weken',
    mistakes: ['Koude buitenteelt', 'Te natte koude grond', 'Geen warmte'],
    supportHow: 'Meestal geen.',
    note: 'Tropische kruiden zoals citroengras: in NL vaak pot/kas.',
  }),
  meerjarig: P({
    frost: false,
    support: false,
    conditions: ['Voorjaar of najaar planten.', 'Plantgoed vaak beter dan zaailing.'],
    harden: 'Bij potplanten 5–7 dagen.',
    depth: 'Plant zoals in pot; enting/hart vrij houden waar van toepassing.',
    depthWhy: 'Vaste plek voor jaren; verkeerde diepte schaadt.',
    soil: 'Goed voorbereide vaste standplaats.',
    water: 'Eerste seizoen regelmatig water.',
    protect: ['droogte eerste jaar'],
    establish: '2–6 weken',
    firstGrowth: 'vaak traag eerste jaar',
    mistakes: ['Te kleine plantplaats', 'Uitdrogen eerste zomer', 'Te diep'],
    supportHow: 'Soortafhankelijk (aspergebed etc.).',
    note:
      'Plantgoed/kronen/scheurlingen. Asperge: jaar 1–2 niet oogsten. Rabarber: neuzen net boven grond. Artisjok: winterbescherming in NL.',
  }),
  fruit_boom: P({
    frost: false,
    support: true,
    conditions: [
      'Plantgoed: naakte wortel nov–mrt (niet bij vorst); container bij mild weer.',
      'Geen standaard zaailing-uitplant als je vrucht wilt.',
      'Check bestuiver-ras bij niet-zelfbestuivende rassen.',
    ],
    harden: 'Containerplanten kort wennen.',
    depth: 'Enting boven grond; potkluit gelijk met maaiveld.',
    depthWhy: 'Te diep planten van geënte bomen is een klassieke fout.',
    soil: 'Doorlatend, humusrijk, goede structuur.',
    water: 'Eerste 1–2 seizoenen regelmatig bij droogte; mulch (niet tegen stam).',
    protect: ['wildvraat', 'droogte'],
    establish: 'weken tot maanden',
    firstGrowth: 'voorjaarsscheuten',
    mistakes: ['Enting begraven', 'Geen waterplan', 'Verkeerde snoei jaar 1'],
    supportHow: 'Paal bij jonge bomen; bind losjes met boomband.',
    note:
      'Onderstam bepaalt boomgrootte. Pitfruit: wintersnoei. Steenfruit: snoei liever na oogst/late zomer.',
  }),
  fruit_klimmer: P({
    frost: false,
    support: true,
    conditions: [
      'Plantgoed: naakte wortel nov–mrt (niet bij vorst); container bij mild weer.',
      'Zonnige, beschutte standplaats.',
      'Stevig frame/draad klaarzetten vóór planten.',
    ],
    harden: 'Containerplanten kort wennen.',
    depth: 'Potkluit gelijk met maaiveld; bij druif iets dieper mag.',
    depthWhy: 'Klimplanten wortelen het best bij juiste diepte met steun erbij.',
    soil: 'Doorlatend, humusrijk, niet te nat.',
    water: 'Eerste 1–2 seizoenen regelmatig bij droogte; mulch rond de voet.',
    protect: ['wildvraat', 'droogte', 'wind'],
    establish: 'weken tot maanden',
    firstGrowth: 'scheuten in voorjaar',
    mistakes: ['Geen steun/draad bij planten', 'Geen waterplan', 'Verkeerde snoei jaar 1'],
    supportHow: 'Draad, gaas of latwerk meteen bij planten; leid jonge scheuten.',
    note: 'Druif/braam/framboos: leid ranken langs draad. Snoei verschilt per soort.',
  }),
  fruit_bes_zuur: P({
    frost: false,
    support: false,
    conditions: [
      'Plantgoed: container of naakte wortel in herfst/vroeg voorjaar.',
      'Zure bodem essentieel (pH 4,5–5,5).',
      'Geen kalk of gemengde borders met kalkminnende planten.',
    ],
    harden: 'Containerplanten kort wennen.',
    depth: 'Potkluit gelijk met maaiveld.',
    depthWhy: 'Oppervlakkig wortelstelsel; niet te diep begraven.',
    soil: 'Zuur (pH 4,5–5,5), veenrijk of rhododendronaarde; GEEN kalk.',
    water: 'Regelmatig water; bodem vochtig, nooit sopnat. Regenwater beter dan kraanwater.',
    protect: ['vogels', 'droogte'],
    establish: '1–2 seizoenen',
    firstGrowth: 'scheuten in voorjaar',
    mistakes: ['Te hoge pH (kalkgrond)', 'Kraanwater i.p.v. regenwater', 'Geen vogelnet bij oogst'],
    supportHow: 'Meestal geen steun nodig; eventueel beschermnet tegen vogels.',
    note: 'Blauwe bes, veenbes/cranberry: zure grond is essentieel. Gewone tuingrond is vaak te basisch.',
  }),
  fruit_bes: P({
    frost: false,
    support: false,
    conditions: [
      'Plantgoed: naakte wortel nov–mrt of container bij mild weer.',
      'Zonnige tot halfbeschaduwde plek.',
      'Goed doorlatende grond.',
    ],
    harden: 'Containerplanten kort wennen.',
    depth: 'Potkluit gelijk met maaiveld; kruis-/aalbes eventueel iets dieper.',
    depthWhy: 'Struiken wortelen het best op de oorspronkelijke diepte.',
    soil: 'Humusrijk, doorlatend, normale pH (6–7).',
    water: 'Eerste seizoen regelmatig bij droogte; mulch rond de voet.',
    protect: ['vogels', 'droogte'],
    establish: '2–6 weken',
    firstGrowth: 'scheuten in voorjaar',
    mistakes: ['Geen vogelnet bij oogst', 'Te droog eerste zomer', 'Geen snoei'],
    supportHow: 'Meestal geen steun nodig; vogelnet bij oogst.',
    note: 'Rode/zwarte/witte bes, kruisbes, jostabes: snoei jaarlijks oud hout weg.',
  }),
  aardbei: P({
    frost: false,
    support: false,
    conditions: ['Voorjaar of augustus planten.', 'Hart boven de grond.'],
    harden: 'Kort bij potplanten.',
    depth: 'Hart vrij; wortels gespreid.',
    depthWhy: 'Bedolven hart = rot; te hoog = uitdroging.',
    soil: 'Humusrijk, doorlatend; eventueel op ruggen.',
    water: 'Goed aangieten; mulch/stro later tegen rot.',
    protect: ['vogels', 'slakken'],
    establish: '1–3 weken',
    firstGrowth: '1–3 weken',
    mistakes: ['Hart begraven', 'Uitdrogen', 'Te diepe schaduw'],
    supportHow: 'Geen steun; wel net tegen vogels bij oogst.',
  }),
  okra: P({
    frost: true,
    support: true,
    conditions: ['Kas/zuidmuur.', 'Pas bij echte warmte.'],
    harden: 'Alleen warm.',
    depth: 'Zelfde diepte.',
    depthWhy: 'Warmte belangrijker dan diepte-truc.',
    soil: 'Warm, rijk.',
    water: 'Lauw aangieten.',
    protect: ['kou'],
    establish: '1–2 weken bij warmte',
    firstGrowth: '1–2 weken',
    mistakes: ['Te koud NL buiten', 'Geen kas'],
    supportHow: 'Stok bij langere planten.',
    note:
      'In NL vrijwel alleen kas/zuidmuur/warme kuip. Voorzaaien warm; peulen jong en vaak oogsten.',
  }),
  gember: P({
    frost: true,
    support: false,
    conditions: ['Kuip/kas; biologisch rizoom poten.', 'Geen zaailing.'],
    harden: 'N.v.t.',
    depth: 'Rizoom 2–3 cm bedekken, groeipunten omhoog.',
    depthWhy: 'Vegetatief via rizoomstukken.',
    soil: 'Luchtig, vochtig, warm, goede drainage.',
    water: 'Licht vochtig, niet koud nat.',
    protect: ['kou'],
    establish: '2–6 weken',
    firstGrowth: 'scheuten na weken',
    mistakes: ['Kou', 'Te nat', 'Behandelde knol'],
    supportHow: 'Geen.',
    note:
      'Poot rizoomstukken in kuip/kas; vorstvrij overwinteren. Oogst vaak na ±8–10 maanden.',
  }),
  tauge: P({
    frost: false,
    support: false,
    conditions: ['Keukenkieming, geen tuin-uitplant.'],
    harden: 'N.v.t.',
    depth: 'N.v.t.',
    depthWhy: 'Geen grondteelt.',
    soil: 'N.v.t.',
    water: 'Spoelen 2–3× daags; goed uitlekken.',
    protect: [],
    establish: '3–6 dagen tot oogst',
    firstGrowth: 'kieming in dagen',
    mistakes: ['Tuinzaad met coating', 'Te nat stilstaand water'],
    supportHow: 'N.v.t.',
    note:
      'Kiem mungbonen/kiemzaad in keuken (donker, spoelen). Geen tuinuitplant.',
  }),
  zoete_aardappel: P({
    frost: true,
    support: false,
    conditions: [
      'Bodem ≥18 °C; half mei–begin juni buiten (kas eerder).',
      'Gebruik gewortelde slips (stekken), geen pootknol zoals aardappel.',
      'Kas, zuidmuur of warme bak helpt in NL.',
    ],
    harden: 'Slips 3–5 dagen wennen aan buitenlucht bij warm weer.',
    depth:
      'Slips tot de onderste bladeren in de grond; ±40–50 cm tussen planten.',
    depthWhy:
      'Slips wortelen vanuit stengelknopen; voldoende diepte geeft meer knollen.',
    soil: 'Humusrijk, luchtig, warm; ruggen/bakken warmen sneller.',
    water: 'Goed aangieten; daarna regelmatig vochtig tot aanslaan.',
    protect: ['nachtvorst', 'koude wind'],
    establish: '1–3 weken',
    firstGrowth: '1–3 weken bij warmte',
    mistakes: ['Te koud uitplanten', 'Zaad i.p.v. slips', 'Te natte koude grond'],
    supportHow: 'Geen steun; ranken mogen geleiden.',
    note:
      'Jan–mrt slips maken van biologische knol; oogst sep–okt (±4–5 maanden); knollen eerst warm/droog curen.',
  }),
  algemeen: P({
    frost: false,
    support: false,
    conditions: ['Geen vorst.', 'Stevige plant met echte bladeren.', 'Bodem bewerkbaar.'],
    harden: '5–10 dagen geleidelijk wennen.',
    depth: 'Zelfde diepte als in de pot.',
    depthWhy: 'Voorkomt rot én uitdroging van de kluit.',
    soil: 'Losmaken, compost, onkruidvrij.',
    water: 'Direct aangieten; eerste week vochtig.',
    protect: ['nachtvorst', 'slakken', 'wind'],
    establish: '1–2 weken',
    firstGrowth: '7–14 dagen',
    mistakes: ['Te vroeg', 'Niet afharden', 'Te weinig water'],
    supportHow: 'Alleen bij klim-/hoge gewassen.',
    note: 'Algemeen teeltprofiel; check raslabel en lokale vorstdata.',
  }),
};

// Reuse sowing-like mapping (compact)
function profileKeyFor(id) {
  const x = id.toLowerCase();
  if (x.includes('zoete_aardappel')) return 'zoete_aardappel';
  if (x.includes('aardappel')) return 'aardappel';
  if (x.includes('knoflook') || x.includes('sjalot')) return 'knoflook';
  if (x.includes('mais')) return 'mais';
  if (
    x.includes('tomaat') ||
    x.includes('cherry') ||
    x.includes('cocktail') ||
    x === 'vlees' ||
    x.includes('pruimtomaat') ||
    x.includes('trostomaat') ||
    x.includes('snoeptomaat') ||
    x.includes('balkontomaat')
  )
    return 'tomaat';
  if (
    x.includes('paprika') ||
    x.includes('peper') ||
    x.includes('chili') ||
    x.includes('cayenne') ||
    x.includes('jalapeno') ||
    x.includes('galapeno') ||
    x.includes('habanero') ||
    x.includes('rawit') ||
    x.includes('banana_peper') ||
    x.includes('pepino')
  )
    return 'paprika';
  if (x.includes('aubergine')) return 'aubergine';
  if (x.includes('komkommer') || x.includes('augurk') || x.includes('cucamelon')) return 'komkommer';
  if (x.includes('courgette') || x.includes('patisson')) return 'courgette';
  if (x.includes('pompoen') || x.includes('hokkaido') || x.includes('butternut')) return 'pompoen';
  if (x.includes('meloen') || x.includes('watermeloen')) return 'meloen';
  if (
    x.includes('sla') ||
    x.includes('lollo') ||
    x.includes('eikenblad') ||
    x.includes('ijsberg') ||
    x.includes('andijvie') ||
    x.includes('snijbiet') ||
    x.includes('witlof')
  )
    return 'sla';
  if (
    x.includes('spinazie') ||
    x.includes('rucola') ||
    x.includes('tuinkers') ||
    x.includes('postelein') ||
    x.includes('waterkers') ||
    x.includes('veldsla') ||
    x.includes('tuinmelde')
  )
    return 'spinazie';
  if (x.includes('biet') || x.includes('chioggia')) return 'biet';
  if (
    x.includes('wortel') ||
    x.includes('peen') ||
    x.includes('pastinaak') ||
    x.includes('schorseneer') ||
    x.includes('peterseliewortel')
  )
    return 'wortel';
  if (x.includes('radijs') || x.includes('rammenas')) return 'radijs';
  if (
    x.includes('kool') ||
    x.includes('broccoli') ||
    x.includes('bloemkool') ||
    x.includes('boerenkool') ||
    x.includes('spruit') ||
    x.includes('paksoi') ||
    x.includes('chinese') ||
    x.includes('bimi') ||
    x.includes('romanesco') ||
    x.includes('raap') ||
    x.includes('koolrabi') ||
    x.includes('savooi') ||
    x.includes('mizuna') ||
    x.includes('tatsoi') ||
    x.includes('komatsuna') ||
    x.includes('mosterd') ||
    x.includes('venkel') ||
    x.includes('selderij') ||
    x.includes('knol')
  )
    return 'kool';
  if (x.includes('prei')) return 'prei';
  if (
    x === 'ui' ||
    x.endsWith('_ui') ||
    x.startsWith('ui_') ||
    x.includes('bosui') ||
    x.includes('winterui') ||
    x.includes('rode_ui') ||
    x.includes('scheve_ui')
  )
    return 'ui';
  if (
    x.includes('boon') ||
    x.includes('bonen') ||
    x.includes('sperzie') ||
    x.includes('haricot') ||
    x.includes('snijboon') ||
    x.includes('pinda') ||
    x.includes('linzen')
  )
    return 'boon';
  if (
    x.includes('erwt') ||
    x.includes('kapucijner') ||
    x.includes('tuinboon') ||
    x.includes('sugar') ||
    x.includes('peultjes') ||
    x.includes('peul')
  )
    return 'erwt';
  if (x.includes('aardbei')) return 'aardbei';
  if (x.includes('gember')) return 'gember';
  if (x.includes('okra')) return 'okra';
  if (x.includes('tauge')) return 'tauge';
  if (
    x.includes('asperge') ||
    x.includes('artisjok') ||
    x.includes('rabarber') ||
    x.includes('aardpeer') ||
    x.includes('kardoen')
  )
    return 'meerjarig';
  // Acid-soil berries
  if (
    x.includes('blauwe_bes') ||
    x.includes('blauwebes') ||
    x.includes('bosbes') ||
    x.includes('veenbes') ||
    x.includes('cranberry')
  )
    return 'fruit_bes_zuur';
  // Climbing fruit (need wire/trellis)
  if (
    x.includes('druif') ||
    x.includes('kiwi') ||
    x.includes('framboos') ||
    x.includes('braam')
  )
    return 'fruit_klimmer';
  // Bush berries (normal pH)
  if (
    x.includes('zwarte_bes') ||
    x.includes('rode_bes') ||
    x.includes('witte_bes') ||
    x.includes('aalbessen') ||
    x.includes('kruisbes') ||
    x.includes('josta') ||
    x.includes('vlier') ||
    x.endsWith('_bes') ||
    x.includes('duindoorn')
  )
    return 'fruit_bes';
  // Tree fruit and other fruit
  if (
    x.includes('appel') ||
    (x.includes('peer') && !x.includes('aardpeer')) ||
    x === 'pruim' ||
    x.startsWith('pruim_') ||
    x.includes('mirabel') ||
    x === 'kers' ||
    x.startsWith('kers_') ||
    x.includes('_kers') ||
    x.includes('kriek') ||
    x.includes('perzik') ||
    x.includes('nectarine') ||
    x.includes('abrikoos') ||
    x.includes('vijg') ||
    x.includes('mango') ||
    x.includes('avocado') ||
    x.includes('citroenboom') ||
    x.includes('limoen') ||
    x.includes('mandarijn') ||
    x.includes('walnoot') ||
    x.includes('hazelnoot') ||
    x.includes('kastanje') ||
    x.includes('kaki') ||
    x.includes('physalis') ||
    x.includes('mispel')
  )
    return 'fruit_boom';
  if (x.includes('citroengras') || x.includes('kerrieblad') || x.includes('kerrie_blad'))
    return 'kruid_tropisch';
  if (
    x.includes('citroenmelisse') ||
    x.includes('tijm') ||
    x.includes('oregano') ||
    x.includes('salie') ||
    x.includes('rozemarijn') ||
    x.includes('dragon') ||
    x.includes('estragon') ||
    x.includes('majoraan') ||
    x.includes('munt') ||
    x.includes('bieslook') ||
    x.includes('zuring') ||
    x.includes('hysop') ||
    x.includes('lavendel')
  )
    return 'kruid_hard';
  if (
    x.includes('basilicum') ||
    x.includes('peterselie') ||
    x.includes('dille') ||
    x.includes('koriander') ||
    x.includes('kamille') ||
    x.includes('kervel') ||
    x.includes('bonenkruid') ||
    x.includes('anijs') ||
    x.includes('tuinkruid') ||
    x.includes('_kruid') ||
    x.endsWith('kruid')
  )
    return 'kruid_zacht';
  return 'algemeen';
}

function details(blocks) {
  return blocks
    .filter((x) => x && x.b)
    .map(
      (x) => `            TransplantDetailBlock(
              heading: '${esc(x.h)}',
              body: '${esc(x.b)}',
            )`,
    )
    .join(',\n');
}

function D(h, b) {
  return { h, b };
}

function itemsLit(list, cross = false) {
  return list
    .map(
      (t) =>
        `              TransplantListItem('${esc(t)}'${cross ? ', marker: TransplantListMarker.cross' : ''})`,
    )
    .join(',\n');
}

function protectChips(protect) {
  const iconFor = {
    nachtvorst: 'frost',
    wind: 'wind',
    slakken: 'slug',
    'felle zon': 'strongSun',
    vogels: 'wind',
    kou: 'frost',
    'koude wind': 'wind',
  };
  const chips = [];
  for (const p of protect) {
    const icon = iconFor[p] || 'frost';
    const label =
      p === 'nachtvorst'
        ? 'Tegen nachtvorst'
        : p === 'wind' || p === 'koude wind'
          ? 'Tegen wind'
          : p === 'slakken'
            ? 'Tegen slakken'
            : p === 'felle zon'
              ? 'Tegen felle zon'
              : p === 'vogels'
                ? 'Tegen vogels'
                : `Tegen ${p}`;
    chips.push(
      `              TransplantIconChip(icon: TransplantChipIcon.${icon}, label: '${esc(label)}')`,
    );
  }
  if (!chips.length) {
    chips.push(
      `              TransplantIconChip(icon: TransplantChipIcon.frost, label: 'Tegen kou')`,
    );
  }
  return chips.join(',\n');
}

function locationChips(standplaats) {
  const s = (standplaats || '').toLowerCase();
  const chips = [];
  if (s.includes('zon'))
    chips.push(
      `              TransplantIconChip(icon: TransplantChipIcon.sun, label: 'Zon')`,
    );
  if (s.includes('half'))
    chips.push(
      `              TransplantIconChip(icon: TransplantChipIcon.partialSun, label: 'Halfschaduw')`,
    );
  chips.push(
    `              TransplantIconChip(icon: TransplantChipIcon.pot, label: 'Pot')`,
  );
  chips.push(
    `              TransplantIconChip(icon: TransplantChipIcon.greenhouse, label: 'Kas')`,
  );
  chips.push(
    `              TransplantIconChip(icon: TransplantChipIcon.openGround, label: 'Volle grond')`,
  );
  if (!chips.some((c) => c.includes("label: 'Zon'"))) {
    chips.unshift(
      `              TransplantIconChip(icon: TransplantChipIcon.sun, label: 'Zon')`,
    );
  }
  return chips.join(',\n');
}

const MISTAKES_SUMMARIES = {
  tomaat: 'Vermijd koude grond, schok door niet afharden en ontbrekende steun.',
  paprika: 'Vermijd koude grond, niet afharden en natte koude potgrond.',
  aubergine: 'Vermijd koude grond, te vroeg uitplanten en ontbrekende beschutting.',
  komkommer: 'Vermijd wortelschade, koude grond en ontbrekend latwerk.',
  courgette: 'Vermijd te vroeg planten, arme grond en te dichte stand.',
  pompoen: 'Vermijd te weinig ruimte, koude grond en wortelschade.',
  meloen: 'Vermijd koude buitenteelt, ontbrekende kas en te nat + koud.',
  sla: 'Vermijd begraven hart, uitdrogen en uitplanten in hitte.',
  spinazie: 'Vermijd hitte, uitdrogen en wortelschade.',
  biet: 'Vermijd te diep planten, verdichte grond en uitdrogen.',
  wortel: 'Vermijd verspenen, stenen in grond en droogte bij kieming.',
  radijs: 'Vermijd verplanten, droogte en te dicht laten staan.',
  kool: 'Vermijd ontbrekend insectennet, droogte en te klein uitplanten.',
  ui: 'Vermijd te diep planten, onkruidconcurrentie en natte grond.',
  prei: 'Vermijd te ondiep planten, uitdrogen en ruimtegebrek.',
  knoflook: 'Vermijd supermarktknoflook, natte klei en verkeerde diepte.',
  aardappel: 'Vermijd supermarktknollen, nat poten en niet aanaarden.',
  mais: 'Vermijd enkele rij, koude grond en vogelschade.',
  boon: 'Vermijd koude grond, wortelschade en ontbrekende steun.',
  erwt: 'Vermijd ontbrekend vogelnet, ontbrekende steun en hitte.',
  kruid_zacht: 'Vermijd te vroeg buiten, te natte pot en te weinig licht.',
  kruid_hard: 'Vermijd te natte stand, te rijke compost en te diep planten.',
  kruid_tropisch: 'Vermijd koude buitenteelt, natte koude grond en tocht.',
  meerjarig: 'Vermijd te kleine plantplaats, droogte en te diep planten.',
  fruit_boom: 'Vermijd enting begraven, geen waterplan en verkeerde snoei.',
  fruit_klimmer: 'Vermijd ontbrekende steun/draad, droogte en verkeerde snoei.',
  fruit_bes_zuur: 'Vermijd kalkgrond, kraanwater en ontbrekend vogelnet.',
  fruit_bes: 'Vermijd ontbrekend vogelnet, droogte en geen snoei.',
  aardbei: 'Vermijd begraven hart, uitdrogen en diepe schaduw.',
  okra: 'Vermijd koude buitenteelt in NL en ontbrekende kas.',
  gember: 'Vermijd kou, te natte grond en behandelde knol.',
  tauge: 'Vermijd tuinzaad met coating en stilstaand water.',
  zoete_aardappel: 'Vermijd koude grond, zaad i.p.v. slips en natte koude grond.',
  algemeen: 'Vermijd te vroeg planten, niet afharden en te weinig water.',
};

function buildGuide(id) {
  const name = prettyName(id);
  const key = profileKeyFor(id);
  const p = PROFILES[key] || PROFILES.algemeen;
  const ov = overview[id] || {};
  const plantMonths = ov.plant?.length ? ov.plant : ov.sow || [];
  const period = monthRange(plantMonths) || 'volgens seizoen';
  const spacing = parseCm(ov.spacing) || parseCm(ov.width) || 30;
  const row = parseCm(ov.row) || Math.max(spacing + 20, 40);
  const first = ov.first || 'Zie oogstkalender';
  const sun = ov.standplaats || 'Zon';
  const frostNote = p.frost
    ? 'Dit gewas is vorstgevoelig: wacht op ijsheiligen (rond mid-mei) of bescherm met kas/vlies.'
    : 'Lichte voorjaarsvorst is vaak minder kritiek, maar natte kou remt nog steeds de wortels.';

  const isFruit = key.startsWith('fruit_');
  const periodSummary =
    key === 'tauge' || isFruit || key === 'knoflook' || key === 'aardappel' || key === 'gember'
      ? `${period}. ${p.conditions[0]}`
      : `${period} (richtlijn NL).`;

  const dart = `  '${id}': PlantTransplantGuide(
    rows: [
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Uitplantperiode',
            summary: '${esc(periodSummary)}',
            months: ${setLit(plantMonths)},
            details: [
${details([
  D(
    'Wat betekent uitplantperiode?',
    `De uitplantperiode is het venster waarin ${name} van pot/tray naar definitieve plek mag. In Nederland bepalen vooral nachttemperatuur, bodemwarmte en vorstrisico dat venster — niet alleen de kalender.`,
  ),
  D(
    'Waarom dit advies?',
    `Te vroeg uitplanten geeft groeistilstand, gele bladeren of uitval. Te laat kan de oogst inkorten. Voor ${name} mik je op ${period}. ${frostNote}`,
  ),
  D(
    'Hoe doe je het?',
    `Plan uitplanten in ${period}. Check 3–5 nachten vooruit. ${p.conditions.join(' ')} Plant bij voorkeur op een bewolkte dag of laat op de middag, zodat de plant niet meteen in volle zon staat.`,
  ),
  D(
    'Seizoen & planning',
    `Plantmaanden uit het overzicht: ${period}. Oogstperiode ter referentie: ${ov.period || 'zie oogstkalender'}. Eerste oogst-richtlijn na start: ${first}.`,
  ),
  D(
    'Praktische tips',
    'Heb je een kas of tunnel, dan kun je vaak 1–2 weken eerder. Buiten: vliesdoek of cloche bij late kou. Noteer de uitplantdatum — handig voor watergift en oogstplanning.',
  ),
  p.note ? D('Let op voor dit gewas', p.note) : null,
])},
            ],
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.split,
        sections: [
          PlantTransplantSection(
            title: 'Uitplantvoorwaarden',
            summary: '${esc(p.conditions[0])}',
            items: [
${itemsLit(p.conditions)},
            ],
            details: [
${details([
  D(
    'Wat zijn uitplantvoorwaarden?',
    `Voorwaarden zijn de checklist vóór je ${name} de grond in zet: weer, bodem én plantkwaliteit. Ontbreekt één van de drie, dan aanslaan is onzeker.`,
  ),
  D(
    'Waarom dit advies?',
    `Koude of natte grond remt wortels. Een te kleine of potgebonden plant herstelt traag. Bij ${name}: ${p.conditions.join(' ')}`,
  ),
  D(
    'Hoe controleer je het?',
    'Voel de grond: koud en klef = wachten. Kijk naar de plant: stevige stengel, echte bladeren, geen gele onderste bladeren van stress. Kluit mag vochtig zijn, niet sopnat of kurkdroog.',
  ),
  D(
    'Wat heb je nodig?',
    'Plantgat iets ruimer dan de kluit, gieter of gieter-kannetje, eventueel compost, en (bij vorstgevoelige soorten) vlies of tunnel klaarliggen.',
  ),
  D(
    'Praktische tips',
    'Plant niet in de felle middagzon. Geef meteen water. Bij harde wind: tijdelijk beschutten. Verwijder het potje voorzichtig zodat de kluit heel blijft.',
  ),
])},
            ],
          ),
          const PlantTransplantSection(
            illustration: PlantTransplantIllustration.conditions,
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Afharden',
            summary: '${esc(p.harden)}',
            steps: const [
              'Dag 1–2: kort buiten',
              'Dag 3–5: langer buiten',
              'Dag 6–8: bijna hele dag',
              'Daarna: vorstvrij ook ’s nachts',
            ],
            illustration: PlantTransplantIllustration.hardening,
            details: [
${details([
  D(
    'Wat is afharden?',
    `Afharden is het geleidelijk wennen van ${name} aan buitenomstandigheden: UV, wind, drogere lucht en grotere temperatuurverschillen dan binnen of in de kas.`,
  ),
  D(
    'Waarom dit advies?',
    'Zonder afharden verbrandt blad, verwelkt de plant of stopt de groei dagen tot weken. Wind droogt potjes snel uit; UV beschadigt ‘zachte’ bladcellen die nooit buitenlicht hebben gezien.',
  ),
  D(
    'Hoe doe je het?',
    `${p.harden} Begin op een beschutte, halfbeschaduwde plek. Verhoog de tijd buiten stapsgewijs. Pas de laatste nacht(en) buiten laten staan als er geen vorst dreigt.`,
  ),
  D(
    'Stappenplan (richtlijn)',
    'Dag 1–2: 1–2 uur buiten. Dag 3–5: ochtend tot namiddag. Dag 6–8: bijna hele dag. Daarna: ook ’s nachts als het vorstvrij is. Bij slecht weer: een dag overslaan of korter.',
  ),
  D(
    'Praktische tips',
    `Houd potjes vochtig tijdens afharden — wind droogt snel. ${name} nooit op dag 1 in volle middagzon. Bij hagel of storm: binnen houden.`,
  ),
])},
            ],
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.columns3,
        sections: [
          PlantTransplantSection(
            title: 'Plantafstand',
            summary: '${spacing} cm tussen de planten.',
            illustration: PlantTransplantIllustration.plantSpacing,
            details: [
${details([
  D(
    'Wat is plantafstand?',
    `Plantafstand is de hart-op-hart afstand tussen ${name}-planten in de rij of in het plantvak. Te dicht = concurrentie en meer ziekte; te wijd = onbenutte ruimte.`,
  ),
  D(
    'Waarom dit advies?',
    `Ongeveer ${spacing} cm geeft ${name} wortelruimte, lucht rond het blad en makkelijker oogsten. Dichte stand houdt vocht langer vast op het blad (schimmelrisico).`,
  ),
  D(
    'Hoe meet je het?',
    `Meet van midden plant tot midden plant ±${spacing} cm. In bakken: volg dezelfde orde van grootte; bladgewassen verdraagt iets dichter, vruchtgewassen liever ruimer.`,
  ),
  D(
    'Bron & maat',
    ov.spacing
      ? `Uit het plantenoverzicht: ${ov.spacing}. Breedte-indicatie: ${ov.width || 'n.v.t.'}.`
      : `Richtlijn ±${spacing} cm (afgeleid van breedte/overzicht). Exacte rasafwijkingen kunnen voorkomen.`,
  ),
  D(
    'Praktische tips',
    'Markeer met stokjes of een meetlint. Bij zigzag- of blokplanting kun je iets efficiënter planten zonder de minimale afstand te onderschrijden.',
  ),
])},
            ],
          ),
          PlantTransplantSection(
            title: 'Rijafstand',
            summary: '${row} cm tussen de rijen.',
            illustration: PlantTransplantIllustration.rowSpacing,
            details: [
${details([
  D(
    'Wat is rijafstand?',
    'Rijafstand is de ruimte tussen evenwijdige rijen. Die ruimte is pad, luchtcirculatie én lichtinval voor de onderste bladeren.',
  ),
  D(
    'Waarom dit advies?',
    `Ongeveer ${row} cm tussen rijen past bij ${name}: je kunt wieden/oogsten zonder planten te vertrappen, en de lucht droogt sneller na regen.`,
  ),
  D(
    'Hoe doe je het?',
    `Zet rijen ±${row} cm uit elkaar. Bij vierkante-meter-teelt werk je met blokken i.p.v. lange rijen — houd dan wel de plantafstand aan.`,
  ),
  D(
    'Bron & maat',
    ov.row
      ? `Overzicht rijafstand: ${ov.row}.`
      : `Richtlijn ±${row} cm (vaak plantafstand + pad). Pas aan op bedbreedte.`,
  ),
  D(
    'Praktische tips',
    'Op smalle bedden: één of twee rijen. Op brede bedden: meerdere rijen met een duidelijk middenpad. Mulch tussen rijen remt onkruid.',
  ),
])},
            ],
          ),
          PlantTransplantSection(
            title: 'Plantdiepte',
            summary: '${esc(p.depth)}',
            illustration: PlantTransplantIllustration.plantingDepth,
            details: [
${details([
  D(
    'Wat is plantdiepte?',
    `Plantdiepte bepaalt hoe diep de kluit of stengel van ${name} in de grond komt. Te diep kan rot of trage groei geven; te ondiep droogt de kluit uit.`,
  ),
  D('Waarom dit advies?', p.depthWhy),
  D('Hoe doe je het?', `${p.depth} Vul aan met grond, druk licht aan zodat er geen luchtgaten rond de kluit blijven, en geef meteen water.`),
  D(
    'Wat zie je als het misgaat?',
    'Te diep: geel worden, rot aan de stengelbasis. Te ondiep: snelle slapte bij zon/wind, kluit die boven komt na water geven.',
  ),
  D(
    'Praktische tips',
    'Maak het gat iets dieper/breder dan de kluit, zet de plant waterpas, vul bij en giet aan. Bij soorten die dieper mogen (bijv. tomaat): vul stapsgewijs bij.',
  ),
])},
            ],
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Beste locaties',
            summary: '${esc(sun)}',
            chips: [
${locationChips(sun)},
            ],
            illustration: PlantTransplantIllustration.bestLocation,
            details: [
${details([
  D(
    'Wat zijn de beste locaties?',
    `De standplaats combineert licht, beschutting en grondtype. Voor ${name} is licht vaak de limiterende factor in NL-tuinen.`,
  ),
  D(
    'Waarom dit advies?',
    `Te weinig licht = slapte en trage groei. Te veel wind = uitdroging na uitplanten. Koude, natte laagtes remmen wortels. Standplaats uit overzicht: ${sun}.`,
  ),
  D(
    'Hoe kies je de plek?',
    `Zoek ${sun.toLowerCase().includes('half') ? 'halfschaduw of gefilterd licht' : 'een zonnige, warme plek'}. Outdoor-indicatie: ${ov.outdoor || 'buiten/kas volgens overzicht'}. Container: ${ov.container || 'pot of volle grond volgens overzicht'}.`,
  ),
  D(
    'Volle grond, pot of kas?',
    `Volle grond: stabielere vochtbuffer. Pot: sneller warm, sneller droog — kies voldoende volume. Kas/tunnel: warmer en eerder mogelijk, maar ventileer tegen schimmel.`,
  ),
  D(
    'Praktische tips',
    'Vermijd plekken waar water blijft staan. Houd rekening met schaduw van schuttingen later in het seizoen. Zet windgevoelige planten dicht bij een haag of muur (niet te dicht voor licht).',
  ),
])},
            ],
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Bodemvoorbereiding',
            summary: '${esc(p.soil)}',
            items: [
              TransplantListItem('Grond losmaken en egaliseren.'),
              TransplantListItem('Compost toevoegen naar behoefte.'),
              TransplantListItem('Onkruid en stenen verwijderen.'),
            ],
            illustration: PlantTransplantIllustration.soilPrep,
            details: [
${details([
  D(
    'Wat is bodemvoorbereiding?',
    `Voor het uitplanten van ${name} maak je de bovenlaag plantklaar: structuur, voeding, vocht en onkruidvrijheid.`,
  ),
  D('Waarom dit advies?', `Wortels moeten meteen de omliggende grond in kunnen. Verdichte of uitgehongerde grond = traag aanslaan. Advies voor dit type: ${p.soil}`),
  D(
    'Hoe doe je het?',
    `Maak 20–30 cm los (spade/vork), meng compost naar behoefte, verwijder wortelonkruid en grove stenen, egaliseer. Voeding volgens overzicht: ${ov.voeding || 'gemiddeld'} — pas bijmestmomenten daarop aan, niet meteen een zware stikstofgift op de uitplant-dag.`,
  ),
  D(
    'Wat heb je nodig?',
    'Spade of woelvork, compost of organische mest naar soort, gieter, eventueel mulch klaarleggen voor ná het aangieten.',
  ),
  D(
    'Praktische tips',
    'Werk niet in kletsnatte klei (structuurbreuk). In zandgrond: meer organische stof voor vochtvasthoudend vermogen. In pot: verse, luchtige potgrond met drainage.',
  ),
])},
            ],
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.columns2Compact,
        sections: [
          PlantTransplantSection(
            title: 'Water na uitplanten',
            summary: '${esc(p.water)}',
            items: [
              TransplantListItem('Direct goed water geven.'),
              TransplantListItem('Eerste week vochtig houden.'),
            ],
            illustration: PlantTransplantIllustration.waterAfter,
            illustrationSize: TransplantIllustrationSize.compact,
            details: [
${details([
  D(
    'Wat betekent water na uitplanten?',
    `Direct na het planten geef je water zodat grond en kluit contact maken. Daarna houd je de zone rond ${name} vochtig tot de wortels aanslaan.`,
  ),
  D(
    'Waarom dit advies?',
    'Haarwortels zijn kapot of gestrest door verplanten. Zonder vocht trekt blad water sneller weg dan wortels kunnen aanvullen → slapte of uitval.',
  ),
  D('Hoe doe je het?', `${p.water} Geef bij de voet (niet alleen over het blad). Laat de bovenlaag niet kurkdroog worden in week 1, maar vermijd een permanent sopnat gat.`),
  D(
    'Hoeveel & hoe vaak?',
    'Eerste dagen: check dagelijks met de vinger. Potten drogen sneller dan volle grond. Bij hitte: ’s ochtends of ’s avonds. Overzicht waterbehoefte later: ' +
      (ov.water || 'gemiddeld') +
      '.',
  ),
  D(
    'Praktische tips',
    'Mulch na het aangieten vermindert verdamping. Bij zware klei: kleinere gietbeurten vaker. Bij droog zand: dieper en iets vaker de eerste week.',
  ),
])},
            ],
          ),
          PlantTransplantSection(
            title: 'Ondersteuning',
            summary: '${esc(p.support ? p.supportHow : 'Meestal geen steun nodig.')}',
            illustration: PlantTransplantIllustration.support,
            illustrationSize: TransplantIllustrationSize.compact,
            details: [
${details([
  D(
    'Wat is ondersteuning?',
    `Steun (stok, kooi, latwerk, aanaarden) houdt ${name} recht, luchtig en minder vatbaar voor wind- of vruchtschade.`,
  ),
  D(
    'Waarom dit advies?',
    p.support
      ? `Zonder steun knakt of waait ${name} later om, of liggen vruchten/loof op de natte grond (rot). ${p.supportHow}`
      : `Voor ${name} is aparte steun meestal niet nodig. ${p.supportHow}`,
  ),
  D(
    'Hoe doe je het?',
    'Zet steun meteen bij uitplanten — later prikken beschadigt wortels. Bind losjes (niet wurgen). Laat ruimte voor stengeldikte.',
  ),
  D(
    'Materialen',
    'Bamboe, tonkinstok, tomatenkooi, gaas, touw of net. Kies iets dat de verwachte eindhoogte aankan (' +
      (ov.height || 'zie hoogte in overzicht') +
      ').',
  ),
  D(
    'Praktische tips',
    'Controleer bindingen na regen en wind. Bij klimmers: leid jonge ranken meteen de goede kant op.',
  ),
])},
            ],
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Bescherming na uitplanten',
            summary: 'Bescherm jonge planten de eerste dagen tot weken.',
            chips: [
${protectChips(p.protect)},
            ],
            illustration: PlantTransplantIllustration.protection,
            details: [
${details([
  D(
    'Wat is bescherming na uitplanten?',
    `Tijdelijke maatregelen tegen weer en vraat terwijl ${name} nog geen diep wortelstelsel heeft.`,
  ),
  D(
    'Waarom dit advies?',
    `De eerste week is het risico het hoogst. Focus bij dit gewas op: ${(p.protect || []).join(', ') || 'algemene weersbescherming'}.`,
  ),
  D(
    'Hoe doe je het?',
    'Nachtvorst: vliesdoek of tunnel ’s avonds, overdag luchten bij zon. Wind: tijdelijke scherm. Slakken: vallen/barrières/avondcontrole. Vogels: net of draad bij aantrekkelijke kiemplanten.',
  ),
  D(
    'Hoe lang?',
    'Meestal 1–3 weken, tot de plant zichtbaar doorgroeit. Bij aanhoudende kou langer beschermen. Verwijder doek overdag bij felle zon om ‘koken’ te voorkomen.',
  ),
  D(
    'Praktische tips',
    'Leg materiaal klaar vóór je plant. Check weerbericht. Bij dubbele stress (wind + droogte) is beschutting + water belangrijker dan mest.',
  ),
])},
            ],
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.columns3,
        sections: [
          PlantTransplantSection(
            title: 'Tijd tot aanslaan',
            summary: '${esc(p.establish)}',
            illustration: PlantTransplantIllustration.establish,
            illustrationSize: TransplantIllustrationSize.compact,
            details: [
${details([
  D(
    'Wat is aanslaan?',
    `Aanslaan betekent dat ${name} nieuwe wortels in de omliggende grond heeft gemaakt en zelfstandig water en voeding opneemt.`,
  ),
  D(
    'Waarom dit tijdsbeeld?',
    `Richtlijn: ${p.establish}. Koeler weer = trager; warm en vochtig (niet nat) = sneller. Potgebonden of beschadigde kluiten doen langer over aanslaan.`,
  ),
  D(
    'Hoe herken je het?',
    'Plant blijft stevig overdag, nieuw bladpuntje verschijnt, geen aanhoudende slapte na lichte zon. Trek voorzichtig: lichte weerstand = wortels pakken vast.',
  ),
  D(
    'Wat doe je in deze periode?',
    'Vochtig houden, niet opnieuw verplanten, geen zware mestgift, beschermen tegen extreme stress. Wieden voorzichtig rond de voet.',
  ),
  D(
    'Praktische tips',
    'Verwar slapte door droogte niet met ‘niet aangeslagen’: geef eerst water en kijk na een paar uur opnieuw.',
  ),
])},
            ],
          ),
          PlantTransplantSection(
            title: 'Tijd tot eerste groei',
            summary: '${esc(p.firstGrowth)}',
            illustration: PlantTransplantIllustration.growth,
            illustrationSize: TransplantIllustrationSize.compact,
            details: [
${details([
  D(
    'Wat is eerste groei?',
    `Zichtbaar nieuw blad of stengelverlenging nadat ${name} is aangeslagen. Wortelherstel komt meestal vóór bladgroei.`,
  ),
  D(
    'Waarom dit tijdsbeeld?',
    `Richtlijn: ${p.firstGrowth}. Geen groei in de eerste dagen is normaal. Wel problematisch: progressive geelheid, rot of totale slapte ondanks vocht.`,
  ),
  D(
    'Hoe stimuleer je gezonde groei?',
    'Licht, warmte binnen de soorttolerantie, gelijkmatig vocht. Geen zware stikstofmest direct na uitplanten — dat kan blad forceren terwijl wortels nog zwak zijn.',
  ),
  D(
    'Wat als groei uitblijft?',
    'Check kou, te natte grond, te diep geplant, wortelschade of te weinig licht. Soms helpt alleen geduld + mild weer.',
  ),
  D(
    'Praktische tips',
    'Fotografeer de plant bij uitplanten; na 10–14 dagen vergelijk je eerlijk of er nieuw blad is.',
  ),
])},
            ],
          ),
          PlantTransplantSection(
            title: 'Tijd tot eerste oogst',
            summary: '${esc(first)}',
            illustration: PlantTransplantIllustration.growth,
            illustrationSize: TransplantIllustrationSize.compact,
            details: [
${details([
  D(
    'Wat is tijd tot eerste oogst?',
    `De periode van uitplanten (of van teeltstart) tot de eerste bruikbare oogst van ${name}. Dit is een richtlijn, geen garantie.`,
  ),
  D(
    'Waarom dit cijfer?',
    `Overzicht: ${first}. Oogstperiode: ${ov.period || 'zie kalender'}. Ras, weer, voorzaaiduur en standplaats schuiven dit venster.`,
  ),
  D(
    'Hoe gebruik je dit in de planning?',
    'Tel terug vanaf wanneer je wilt oogsten. Combineer met de uitplantmaanden. Noteer je echte uitplantdatum in de app/tuinlog.',
  ),
  D(
    'Wat beïnvloedt de snelheid?',
    'Warmte versnelt de meeste vruchtgewassen; droogte of kou vertraagt. Te dicht planten kan oogst verkleinen. Habitus: ' +
      (ov.habit || 'zie overzicht') +
      '.',
  ),
  D(
    'Praktische tips',
    'Eerste oogst ≠ piekoogst. Bij bladgewassen kun je vaak eerder plukken (jonge bladeren) dan bij vruchtgewassen.',
  ),
])},
            ],
          ),
        ],
      ),
      PlantTransplantRow(
        kind: PlantTransplantRowKind.single,
        sections: [
          PlantTransplantSection(
            title: 'Veelgemaakte fouten',
            summary: '${esc(MISTAKES_SUMMARIES[key] || MISTAKES_SUMMARIES.algemeen)}',
            items: [
${itemsLit(p.mistakes, true)},
            ],
            illustration: PlantTransplantIllustration.mistakes,
            illustrationSize: TransplantIllustrationSize.large,
            details: [
${details([
  D(
    'Waarom deze fouten?',
    `De meeste mislukkingen bij ${name} gebeuren in de eerste 10 dagen: te vroeg, te droog, te diep, of een schok door niet afharden.`,
  ),
  D(
    'Vermijd vooral',
    p.mistakes.map((m) => `• ${m}`).join(' '),
  ),
  D(
    'Hoe herstel je een fout?',
    'Te droog: direct water + tijdelijke schaduw. Te vroeg/kou: vlies/tunnel of (in pot) tijdelijk terugzetten. Te diep: voorzichtig iets ophogen lukt zelden; voorkom herhaling. Niet afgehard: beschutten en geleidelijk wennen.',
  ),
  D(
    'Checklist vóór uitplanten',
    'Afgehard? Weer oké? Bodem klaar? Water bij de hand? Steun klaar (indien nodig)? Plantgat op juiste diepte?',
  ),
  D(
    'Praktische tips',
    'Liever een week later dan één nacht te vroeg bij vorst. Eén goede uitplantdag wint van drie matige.',
  ),
  p.note ? D('Extra bij dit gewas', p.note) : null,
])},
            ],
          ),
        ],
      ),
    ],
  )`;

  return { key, note: p.note || null, dart };
}

const entries = [];
const gaps = [];
const counts = {};

for (const id of targetIds) {
  const built = buildGuide(id);
  entries.push(built.dart);
  counts[built.key] = (counts[built.key] || 0) + 1;
  if (built.note) {
    gaps.push({ id, profile: built.key, reason: built.note });
  } else if (built.key === 'algemeen') {
    gaps.push({
      id,
      profile: 'algemeen',
      reason:
        'Algemeen uitplantprofiel — graag soortspecifieke bronnen voor verfijning.',
    });
  }
}

const out = `part of 'plant_transplant_guide.dart';

/// Gecureerde Uitplanten-gidsen (samenvatting + detail) voor groente e.d.
/// behalve bloemen en paddenstoelen. Gegenereerd via tool/generate_transplant_guides.mjs.
final Map<String, PlantTransplantGuide> kPlantTransplantGuides = {
${entries.join(',\n')},
};
`;

fs.writeFileSync('lib/data/plant_transplant_guide_entries.dart', out);
fs.writeFileSync(
  'tool/transplant_gaps_report.json',
  JSON.stringify({ count: gaps.length, counts, gaps }, null, 2),
);
console.log(JSON.stringify({ written: entries.length, gaps: gaps.length, counts }, null, 2));
