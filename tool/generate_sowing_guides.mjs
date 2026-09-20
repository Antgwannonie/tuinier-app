/**
 * Genereert curated Zaaien-gidsen voor alle planten behalve bloemen/paddestoelen.
 * Bron: overzicht-maanden + teeltprofielen (NL-klimaat, gangbare moestuinkennis).
 */
import fs from 'fs';

const overview = JSON.parse(
  fs.readFileSync('tool/vegetable_overview_all.json', 'utf8'),
);
const targetIds = JSON.parse(
  fs.readFileSync('tool/sowing_target_ids.json', 'utf8'),
);

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
  if (!arr || !arr.length) return null;
  const s = [...arr].sort((a, b) => a - b);
  if (s.length === 1) return MONTHS[s[0]];
  return `${MONTHS[s[0]]} – ${MONTHS[s[s.length - 1]]}`;
}

function setLit(arr) {
  if (!arr || !arr.length) return 'null';
  return `{${[...new Set(arr)].sort((a, b) => a - b).join(', ')}}`;
}

function esc(s) {
  return String(s)
    .replace(/\\/g, '\\\\')
    .replace(/'/g, "\\'");
}

/** @typedef {{
 *  indoorSummary: string, outdoorSummary: string,
 *  depthSummary: string, germDaysSummary: string, germTempSummary: string,
 *  lightSummary: string, waterSummary: string,
 *  prickSummary: string, potSummary: string,
 *  indoorHow: string, outdoorHow: string,
 *  depth: object, germ: object, temp: object, light: object, water: object,
 *  prick: object, pot: object, indoorWhy: string, outdoorWhy: string,
 *  frost?: boolean, note?: string, noSeed?: boolean
 * }} Profile */

/** @type {Record<string, Profile>} */
const PROFILES = {
  tomaat: {
    indoorSummary: 'Februari – april voorzaaien op warmte.',
    outdoorSummary: 'Niet zaaien buiten; uitplanten na ijsheiligen.',
    indoorHow: 'Zaai in trays of potjes met zaaigrond, dek licht af, op 20–25 °C.',
    outdoorHow: 'Buiten zaaien loont zelden in NL; plant afgeharde planten uit.',
    indoorWhy:
      'Tomaat is warmteminnend. Binnen voorzaaien geeft sterke planten die na mid-mei vrucht kunnen zetten. Buiten kiemt en groeit het te traag.',
    outdoorWhy:
      'De Nederlandse lente is te koel voor betrouwbare kieming in de volle grond. Daarom voorzaaien en later uitplanten.',
    depthSummary: '0,5 – 1 cm diep.',
    germDaysSummary: '5 – 10 dagen bij 20–25 °C.',
    germTempSummary: 'Optimaal 20 – 25 °C (min. ±15 °C).',
    lightSummary: 'Donkerkiemer: licht bedekken; daarna veel licht.',
    waterSummary: 'Gelijkmatig vochtig; niet sopnat (kiemplantziekte).',
    prickSummary: 'Bij 1–2 echte blaadjes naar apart potje.',
    potSummary: 'Oppotten naar 8–12 cm pot tot uitplanten.',
    frost: true,
    depth: {
      why: 'Kleine zaden hebben weinig reserve. Te diep = zwakke of geen opkomst.',
      how: 'Zaai oppervlakkig (0,5–1 cm), druk licht aan en benevel. Dek af met een dun laagje grond of vermiculiet.',
      tip: 'Label ras en datum. Gebruik frisse zaaigrond zonder mestpiek.',
    },
    germ: {
      why: 'Warmte versnelt enzymen in het zaad. Kouder dan ±15 °C: trage of uitblijvende kieming.',
      how: 'Zet trays op een warmteplaat of warme vensterbank. Na opkomst meteen veel licht om langrekken te voorkomen.',
      tip: 'Oude zaden kiemen trager; bij twijfel kiemtest doen op keukenpapier.',
    },
    temp: {
      why: 'Tomaat komt uit warme klimaten. Koude bodem remt kieming en nodigt schimmels uit.',
      how: 'Houd 20–25 °C tot kieming. Daarna mag het iets koeler (16–20 °C) als er genoeg licht is.',
      tip: 'Kas of kweekkast helpt in februari–maart.',
    },
    light: {
      why: 'Het zaad kiemt onder een dunne afdeklaag (donker). De kiemplant heeft daarna direct veel licht nodig.',
      how: 'Na opkomst: zo licht mogelijk (zuidenraam of kweeklamp 12–16 u). Draai trays dagelijks.',
      tip: 'Langgerekte zaailingen = te weinig licht of te warm na kieming.',
    },
    water: {
      why: 'Vocht activeert het zaad; stilstaand water veroorzaakt omvalziekte.',
      how: 'Benevel of geef water van onderaf. Laat de bovenlaag niet kurkdroog worden, maar ook niet plassen.',
      tip: 'Goede drainage in trays is essentieel.',
    },
    prick: {
      why: 'Vroege ruimte voorkomt concurrentie en zwakke stengels.',
      how: 'Til voorzichtig uit bij 1–2 echte blaadjes. Plant iets dieper (tot net onder de zaadlobben) voor extra steunwortels.',
      tip: 'Niet aan de stengel trekken; pak het blaadje of een kluitje.',
    },
    pot: {
      why: 'Wortels hebben volume nodig vóór uitplanten in mei/juni.',
      how: 'Verpot naar grotere pot met potgrond wanneer wortels onderuit komen. Harden 7–10 dagen af vóór uitplanten.',
      tip: 'Pas uitplanten na ijsheiligen, op een zonnige, warme plek.',
    },
  },

  paprika: {
    indoorSummary: 'Februari – maart voorzaaien (heeft lange start nodig).',
    outdoorSummary: 'Niet zaaien buiten; uitplanten juni na warmte.',
    indoorHow: 'Zaai warm (22–28 °C), geduld: traagere start dan tomaat.',
    outdoorHow: 'Alleen via voorzaaien; vollegrondzaai is onbetrouwbaar in NL.',
    indoorWhy:
      'Paprika/peper heeft een lang seizoen en hoge kiemwarmte. Vroeg voorzaaien is nodig voor rijpe vruchten.',
    outdoorWhy:
      'Te koel voor kieming en vroege groei buiten. Werk met opgekweekte planten.',
    depthSummary: '0,5 – 1 cm diep.',
    germDaysSummary: '7 – 21 dagen (vaak trager dan tomaat).',
    germTempSummary: 'Optimaal 22 – 28 °C.',
    lightSummary: 'Licht bedekken; na opkomst veel licht.',
    waterSummary: 'Constant licht vochtig, warm houden.',
    prickSummary: 'Bij 2 echte blaadjes verspenen.',
    potSummary: 'Oppotten tot stevige plant vóór uitplanten.',
    frost: true,
    depth: {
      why: 'Zelfde principe als tomaat: oppervlakkig zaaien.',
      how: '0,5–1 cm diep in zaaigrond, licht aandrukken, afdekken met heldere kap tot kieming.',
      tip: 'Verse zaden kiemen betrouwbaarder; peperzaad verliest sneller kiemkracht.',
    },
    germ: {
      why: 'Hoge temperatuur is kritischer dan bij tomaat; onder 20 °C blijft kieming vaak uit.',
      how: 'Warmteplaat of broeikas. Verwacht tot 2–3 weken.',
      tip: 'Geduld: niet te vroeg herzaaien.',
    },
    temp: {
      why: 'Tropische/subtropische herkomst vraagt warmte.',
      how: '22–28 °C tot kieming; daarna 18–24 °C met veel licht.',
      tip: 'Koude nachten in huis vertragen alles — vermijd tochtige vensters.',
    },
    light: {
      why: 'Na opkomst snel veel licht voorkomt slapte.',
      how: 'Zuidenraam of LED-kweeklamp; plant draaien.',
      tip: 'Bij weinig licht later zaaien (maart) is beter dan zwakke planten.',
    },
    water: {
      why: 'Uitdroging stopt kieming; nat + koud = schimmel.',
      how: 'Benevel; kap eraf zodra zaden kiemen om schimmel te beperken.',
      tip: 'Gebruik lauw water.',
    },
    prick: {
      why: 'Paprika groeit eerst traag; ruimte helpt daarna sterk door.',
      how: 'Verspeen voorzichtig bij 2 echte blaadjes naar losse potjes.',
      tip: 'Niet te diep planten (anders dan tomaat).',
    },
    pot: {
      why: 'Sterke wortelkluit = betere uitplantgroei in juni.',
      how: 'Oppotten naar 9–12 cm. Afharden en pas uitplanten bij nachten >10–12 °C.',
      tip: 'In pot of kas vaak betrouwbaarder dan koude volle grond.',
    },
  },

  aubergine: {
    indoorSummary: 'Februari – maart warm voorzaaien.',
    outdoorSummary: 'Geen betrouwbare buitenkieming; uitplanten juni.',
    indoorHow: 'Zaai op 22–28 °C in zaaigrond, licht afdekken.',
    outdoorHow: 'Plant alleen afgeharde planten op de warmste plek.',
    indoorWhy: 'Nog warmteminnender dan tomaat; lange voorteelt is nodig.',
    outdoorWhy: 'NL-bodem blijft te lang te koud voor kieming.',
    depthSummary: '0,5 – 1 cm.',
    germDaysSummary: '7 – 14 dagen bij voldoende warmte.',
    germTempSummary: '22 – 28 °C.',
    lightSummary: 'Bedekken; daarna veel licht.',
    waterSummary: 'Warm en licht vochtig houden.',
    prickSummary: 'Bij 2 echte blaadjes verspenen.',
    potSummary: 'Oppotten tot stevige plant; late uitplant.',
    frost: true,
    depth: {
      why: 'Kleine zaden, oppervlakkig zaaien.',
      how: '0,5–1 cm, lichte aandrukking, warme kiemplek.',
      tip: 'Gebruik een heldere afdekplaat tot kieming.',
    },
    germ: {
      why: 'Warmte is doorslaggevend.',
      how: 'Houd constant warm; wisselende kou vertraagt sterk.',
      tip: 'Kweeklamp + warmteplaat is ideaal in februari.',
    },
    temp: {
      why: 'Subtropisch gewas.',
      how: '22–28 °C kiemen; groei bij voorkeur >18 °C.',
      tip: 'Kas of beschutte zuidmuur later bij uitplanten.',
    },
    light: {
      why: 'Voorkomt langgerekte zaailingen.',
      how: 'Direct na opkomst veel licht.',
      tip: 'Niet te warm bij weinig licht.',
    },
    water: {
      why: 'Vocht nodig, maar warm houden.',
      how: 'Benevel; vermijd koude natte trays.',
      tip: 'Laat nooit volledig uitdrogen.',
    },
    prick: {
      why: 'Ruimte voor dikke stengelontwikkeling.',
      how: 'Verspeen bij 2 echte blaadjes.',
      tip: 'Voorzichtig: wortels zijn gevoelig.',
    },
    pot: {
      why: 'Grote plant vóór uitplanten in juni.',
      how: 'Oppotten en afharden; uitplanten op warmste plek.',
      tip: 'Zwarte potten/kas helpen bodemwarmte.',
    },
  },

  komkommer: {
    indoorSummary: 'Half april – begin mei voorzaaien.',
    outdoorSummary: 'Mei – juni direct buiten of na ijsheiligen uitplanten.',
    indoorHow: 'Zaai per potje 1–2 zaden; niet te vroeg (snelle groeiers).',
    outdoorHow: 'Na voldoende bodemwarmte (±15 °C+) op beschutte plek.',
    indoorWhy:
      'Komkommer groeit hard. Te vroeg zaaien geeft te grote planten in kleine potten vóór het veilig is buiten.',
    outdoorWhy:
      'Buiten zaaien kan na koude nachten; bodem moet opgewarmd zijn.',
    depthSummary: '1 – 2 cm diep (afdekken).',
    germDaysSummary: '3 – 10 dagen bij 20–25 °C.',
    germTempSummary: 'Optimaal 20 – 25 °C (min. ±15 °C).',
    lightSummary: 'Donkerkiemer: zaden afdekken; daarna licht.',
    waterSummary: 'Vochtig en warm; niet laten uitdrogen.',
    prickSummary: 'Liever niet verspenen; zaai direct in potjes.',
    potSummary: 'Zaai in 8–10 cm pot; uitplanten met kluit.',
    frost: true,
    depth: {
      why: 'Komkommerzaad is middelgroot en wil bedekt kiemen (geen lichtkiemer).',
      how: '1–2 cm diep in vochtige zaaigrond. Niet bloot laten liggen.',
      tip: 'Eerdere app-tekst “niet bedekken” was onjuist; wél licht afdekken.',
    },
    germ: {
      why: 'Bij warmte kiemt komkommer razendsnel.',
      how: '20–25 °C; vaak binnen een week groen.',
      tip: 'Te koud: zaden rotten eerder dan ze kiemen.',
    },
    temp: {
      why: 'Warmteminnend cucurbitengewas.',
      how: 'Kiemen warm; groei het liefst >18 °C.',
      tip: 'Na ijsheiligen uitplanten of onder vlies.',
    },
    light: {
      why: 'Kieming onder grondlaag; zaailing wil daarna licht.',
      how: 'Afdekken tot kieming; daarna lichte plek.',
      tip: 'Niet tot lange ranken laten groeien in kleine pot.',
    },
    water: {
      why: 'Snelle kiemers verdrogen snel in droge trays.',
      how: 'Vochtig houden; goede drainage.',
      tip: 'Water bij voorkeur lauw.',
    },
    prick: {
      why: 'Komkommer heeft gevoelige wortels; verspenen remt vaak.',
      how: 'Zaai 1 zaad per potje zodat je niet hoeft te verspenen.',
      tip: 'Moet je toch verzetten: alleen met intacte kluit.',
    },
    pot: {
      why: 'Plant groeit snel de pot uit.',
      how: 'Gebruik meteen voldoende potvolume of plant snel uit na afharden.',
      tip: 'Latwerk klaarzetten bij uitplanten.',
    },
  },

  courgette: {
    indoorSummary: 'Half april – mei voorzaaien (niet te vroeg).',
    outdoorSummary: 'Mei – juni buiten zaaien of planten.',
    indoorHow: '1 zaad per pot, 2–3 cm diep, warm kiemen.',
    outdoorHow: 'Na ijsheiligen in warme, rijke grond.',
    indoorWhy: 'Voorsprong van 3–4 weken; te vroeg zaaien = potgebonden reuzen.',
    outdoorWhy: 'Kan direct buiten vanaf voldoende warmte.',
    depthSummary: '2 – 3 cm diep.',
    germDaysSummary: '5 – 10 dagen.',
    germTempSummary: '18 – 25 °C.',
    lightSummary: 'Afdekken (donkerkiemer); daarna licht.',
    waterSummary: 'Vochtig houden tot opkomst.',
    prickSummary: 'Niet verspenen; per pot zaaien.',
    potSummary: 'Direct in stevige pot; snel uitplanten.',
    frost: true,
    depth: {
      why: 'Grote zaden mogen dieper; vocht rondom het zaad is belangrijk.',
      how: '2–3 cm diep, plat op de zijkant leggen kan helpen.',
      tip: 'Week grote zaden eventueel 12 u voor snellere start.',
    },
    germ: {
      why: 'Warmte + vocht = snelle kieming.',
      how: '18–25 °C; controleer dagelijks vocht.',
      tip: 'Koude grond: wachten loont.',
    },
    temp: {
      why: 'Cucurbit, vorstgevoelig.',
      how: 'Warm kiemen; buiten pas na koude nachten.',
      tip: 'Vliesdoek helpt bij vroege uitplant.',
    },
    light: {
      why: 'Kieming onder grond; daarna zon/licht.',
      how: 'Afdekken; na opkomst lichte plek.',
      tip: 'Binnen niet te lang laten staan.',
    },
    water: {
      why: 'Grote zaden hebben constant vocht nodig om te zwellen.',
      how: 'Goed bevochtigen na zaaien; niet laten uitdrogen.',
      tip: 'Mulch later buiten helpt vochtvasthouden.',
    },
    prick: {
      why: 'Wortels houden niet van verstoring.',
      how: 'Zaai per pot; plant met kluit uit.',
      tip: 'Geen verspenen uit zaaitray indien mogelijk.',
    },
    pot: {
      why: 'Snelle groei.',
      how: 'Ruime pot of tijdig uitplanten op compostrijke plek.',
      tip: 'Geef ruimte: plant wordt breed.',
    },
  },

  pompoen: {
    indoorSummary: 'Eind april – mei voorzaaien.',
    outdoorSummary: 'Mei – juni buiten zaaien op warme grond.',
    indoorHow: '1–2 zaden per pot, 2–3 cm diep.',
    outdoorHow: 'Op rijke, warme plek; veel ruimte geven.',
    indoorWhy: 'Voorsprong helpt bij late pompoenen/wintertypes.',
    outdoorWhy: 'Direct zaaien kan zodra grond warm is.',
    depthSummary: '2 – 3 cm.',
    germDaysSummary: '5 – 12 dagen.',
    germTempSummary: '18 – 25 °C.',
    lightSummary: 'Afdekken; daarna licht.',
    waterSummary: 'Vochtig tot opkomst.',
    prickSummary: 'Niet verspenen; potzaai.',
    potSummary: 'Snel uitplanten; grote groeiers.',
    frost: true,
    depth: {
      why: 'Grote zaden, dieper zaaien.',
      how: '2–3 cm, vochtig houden.',
      tip: 'Pointy end kan iets schuin omhoog wijzen — optioneel.',
    },
    germ: {
      why: 'Warmte versnelt.',
      how: '18–25 °C.',
      tip: 'Bescherm tegen muizen/slakken buiten.',
    },
    temp: {
      why: 'Vorstgevoelig.',
      how: 'Na ijsheiligen buiten.',
      tip: 'Zwarte grond/compost warmt sneller op.',
    },
    light: {
      why: 'Donker onder grondlaag.',
      how: 'Afdekken, daarna zon.',
      tip: 'Rankers hebben latwerk of ruimte nodig.',
    },
    water: {
      why: 'Gelijkmatig vocht.',
      how: 'Na zaaien goed aangieten.',
      tip: 'Later diep water geven i.p.v. dagelijks spatten.',
    },
    prick: {
      why: 'Gevoelige wortels.',
      how: 'Potzaai, kluit uitplanten.',
      tip: 'Vermijd wortelbreuk.',
    },
    pot: {
      why: 'Explosieve groei.',
      how: 'Niet te lang in kleine pot houden.',
      tip: 'Plantgat met compost verrijken.',
    },
  },

  meloen: {
    indoorSummary: 'April – begin mei warm voorzaaien.',
    outdoorSummary: 'Alleen in warme kas/zomer; zelden direct buiten.',
    indoorHow: 'Warm (22–28 °C), per pot zaaien.',
    outdoorHow: 'Uitplanten in kas of zeer warme hoek na juni-start.',
    indoorWhy: 'Meloen eist meer warmte dan komkommer; voorteelt is standaard in NL.',
    outdoorWhy: 'Koude zomers maken vollegrondzaai riskant.',
    depthSummary: '1 – 2 cm.',
    germDaysSummary: '5 – 10 dagen bij warmte.',
    germTempSummary: '22 – 28 °C.',
    lightSummary: 'Afdekken; daarna veel licht.',
    waterSummary: 'Warm en vochtig kiemen.',
    prickSummary: 'Niet verspenen; potzaai.',
    potSummary: 'Uitplanten in kas/pot met warmte.',
    frost: true,
    depth: {
      why: 'Middelgroot zaad, bedekken.',
      how: '1–2 cm diep.',
      tip: 'Kas geeft de beste kans op zoete vruchten.',
    },
    germ: {
      why: 'Hoge temperatuur nodig.',
      how: 'Warmteplaat aanbevolen.',
      tip: 'Onder 18 °C vaak mislukking.',
    },
    temp: {
      why: 'Warmteminnend.',
      how: 'Kiemen 22–28 °C; teelt bij voorkeur kas.',
      tip: 'Nachtwarmte is belangrijk.',
    },
    light: {
      why: 'Sterke zaailingen voor kas.',
      how: 'Veel licht na opkomst.',
      tip: 'Niet laten oprekken.',
    },
    water: {
      why: 'Vocht + warmte.',
      how: 'Niet koud water; niet uitdrogen.',
      tip: 'Later water geven aan de voet, niet op blad.',
    },
    prick: {
      why: 'Gevoelige wortels.',
      how: 'Direct in pot zaaien.',
      tip: 'Kluit behouden bij uitplanten.',
    },
    pot: {
      why: 'Snelle start richting kas.',
      how: 'Tijdig uitplanten op warme plek.',
      tip: 'Bestuiving in kas soms handmatig helpen.',
    },
  },

  sla: {
    indoorSummary: 'Februari – augustus in etappes voorzaaien mogelijk.',
    outdoorSummary: 'Maart – september direct buiten (niet in hitte).',
    indoorHow: 'Oppervlakkig zaaien; koel kiemen (±10–18 °C).',
    outdoorHow: 'Rijtjes of breedwerpig; dun zaaien, later uitdunnen.',
    indoorWhy: 'Voorzaaien helpt vroege en late teelten; sla houdt niet van hitte.',
    outdoorWhy: 'Sla kiemt goed koel; zomerhitte remt kieming (thermokiemrust).',
    depthSummary: '0 – 0,5 cm (lichtkiemer / nauwelijks bedekken).',
    germDaysSummary: '4 – 10 dagen.',
    germTempSummary: 'Optimaal 10 – 18 °C (boven ±25 °C vaak slecht).',
    lightSummary: 'Lichtkiemer: niet of nauwelijks bedekken.',
    waterSummary: 'Oppervlakte vochtig houden (benevelen).',
    prickSummary: 'Bij 2–3 blaadjes verspenen of ter plaatse uitdunnen.',
    potSummary: 'Optioneel in modules; snel uitplanten.',
    frost: false,
    depth: {
      why: 'Sla heeft licht nodig om te kiemen; diep bedekken faalt vaak.',
      how: 'Zaai op het oppervlak of met een stofje zand/vermiculiet. Aandrukken is genoeg.',
      tip: 'In zomer: zaai in de schaduw/koelte of zaailingen voorkweken.',
    },
    germ: {
      why: 'Koelere temperaturen werken beter dan tropische warmte.',
      how: 'Niet op warme radiator zetten. 10–18 °C is ideaal.',
      tip: 'Bij hitte: zaden eventueel een nacht in de koelkast voorzaaien (stratificatie-achtige truc).',
    },
    temp: {
      why: 'Thermokiemrust boven ±25 °C.',
      how: 'Kiem koel; groei ook liever niet in volle middagzon in juli.',
      tip: 'Zomer: kies hittebestendige rassen of teel in halfschaduw.',
    },
    light: {
      why: 'Lichtkiemer.',
      how: 'Niet begraven; lichte plek na zaaien.',
      tip: 'Afdekvlies houdt vocht vast zonder licht volledig weg te nemen.',
    },
    water: {
      why: 'Oppervlakkige zaden drogen snel uit.',
      how: 'Benevel 1–2× daags tot opkomst; daarna gelijkmatig vochtig.',
      tip: 'Uitdroging = mislukte kieming.',
    },
    prick: {
      why: 'Dichte zaai geeft zwakke kropvorming.',
      how: 'Verspeen of dun uit op 20–30 cm (afhankelijk van type).',
      tip: 'Jonge uitgedunde plantjes kun je elders opnieuw zetten.',
    },
    pot: {
      why: 'Modules werken goed voor vroege teelt.',
      how: 'Uitplanten met kluit; niet te diep (hart boven grond).',
      tip: 'Successief zaaien elke 2–3 weken voor doorlopende oogst.',
    },
  },

  spinazie: {
    indoorSummary: 'Mogelijk, maar vaak niet nodig.',
    outdoorSummary: 'Maart – mei en augustus – september (vermijd hitte).',
    indoorHow: 'Alleen voor heel vroege teelt; koel houden.',
    outdoorHow: 'Direct in rijen; dun zaaien.',
    indoorWhy: 'Spinazie kiemt en groeit het best koel; binnen wordt het snel te warm.',
    outdoorWhy: 'Klassieke koeleseizoenteelt; zomerzaai schiet snel door.',
    depthSummary: '1 – 2 cm.',
    germDaysSummary: '5 – 12 dagen.',
    germTempSummary: '5 – 18 °C ideaal; boven 20 °C slechter.',
    lightSummary: 'Afdekken; geen typische lichtkiemer.',
    waterSummary: 'Vochtig tot opkomst.',
    prickSummary: 'Meestal uitdunnen i.p.v. verspenen.',
    potSummary: 'Zelden; vooral ter plaatse zaaien.',
    depth: {
      why: 'Middelgrote zaden, bedekken.',
      how: '1–2 cm diep in vochtige grond.',
      tip: 'Week zaden 8–12 u voor snellere kieming (optioneel).',
    },
    germ: {
      why: 'Houdt van koelte.',
      how: 'Niet op warme mat zetten.',
      tip: 'Herfstteelt is vaak makkelijker dan zomer.',
    },
    temp: {
      why: 'Hitte = slechte kieming en doorschieten.',
      how: 'Zaai in koele periodes.',
      tip: 'Zomer: kies slow-bolt rassen of wacht op nazomer.',
    },
    light: {
      why: 'Standaard afdekken.',
      how: '1–2 cm grond erover.',
      tip: 'Na opkomst volle tot lichte schaduw in warm weer.',
    },
    water: {
      why: 'Vochtige kiembedden.',
      how: 'Regelmatig vochtig houden.',
      tip: 'Droogte versnelt doorschieten later.',
    },
    prick: {
      why: 'Wortels houden niet van veel gesleep.',
      how: 'Dun uit op 5–10 cm.',
      tip: 'Baby leaf: dichter zaaien en jong oogsten.',
    },
    pot: {
      why: 'Meestal vollegrond of bak ter plaatse.',
      how: 'Potteelt kan in bakken; zaai direct.',
      tip: 'Diepe bak houdt vocht beter vast.',
    },
  },

  biet: {
    indoorSummary: 'Maart – april mogelijk in modules.',
    outdoorSummary: 'April – juli direct buiten.',
    indoorHow: 'Modules; “zaadkluwen” kan meerdere kiemplanten geven.',
    outdoorHow: 'Rijen zaaien; later uitdunnen.',
    indoorWhy: 'Voorteelt helpt vroege bieten; vaak volstaat buiten zaaien.',
    outdoorWhy: 'Bieten kiemen goed in open grond vanaf april.',
    depthSummary: '2 – 3 cm.',
    germDaysSummary: '7 – 14 dagen.',
    germTempSummary: '8 – 20 °C (optimaal ±15 °C).',
    lightSummary: 'Afdekken.',
    waterSummary: 'Vochtig houden; korstvorming vermijden.',
    prickSummary: 'Dunnen: per cluster 1 plant aanhouden.',
    potSummary: 'Modules uitplanten met kluit.',
    depth: {
      why: 'Kurkachtig zaadkluwen; iets dieper zaaien helpt vocht.',
      how: '2–3 cm. Week 1–2 u optioneel.',
      tip: 'Elk “zaad” is vaak een kluitje met meerdere embryo’s.',
    },
    germ: {
      why: 'Matige warmte volstaat.',
      how: 'Geduld tot 2 weken.',
      tip: 'Koude, natte grond vertraagt.',
    },
    temp: {
      why: 'Kiembereik breed, niet tropisch.',
      how: 'Vanaf ±8 °C bodem.',
      tip: 'Te vroeg in kou: spotziekte-risico bij sommige rassen.',
    },
    light: {
      why: 'Geen lichtkiemer.',
      how: 'Goed afdekken.',
      tip: 'Na opkomst volle zon.',
    },
    water: {
      why: 'Gelijkmatig vocht voorkomt harde korst.',
      how: 'Na zaaien aandrukken en vochtig houden.',
      tip: 'Uitdunnen na regen/makkelijke grond.',
    },
    prick: {
      why: 'Meerdere kiemplanten per kluit concurreren.',
      how: 'Laat de sterkste staan (5–10 cm).',
      tip: 'Uitgedunde jonge planten kun je soms verzetten.',
    },
    pot: {
      why: 'Modules verminderen schok.',
      how: 'Uitplanten zonder wortelkluit te breken.',
      tip: 'Niet te lang in kleine module laten.',
    },
  },

  wortel: {
    indoorSummary: 'Meestal niet: wortels houden niet van verplanten.',
    outdoorSummary: 'Maart – juni (en soms juli voor winterpeen).',
    indoorHow: 'Alleen in diepe wortelmodules als je toch voorkweekt.',
    outdoorHow: 'Direct in fijne, steenvrije grond; dun zaaien.',
    indoorWhy: 'Penwortel breekt snel; ter plaatse zaaien geeft mooiere wortels.',
    outdoorWhy: 'Klassieke directe teelt in losse grond.',
    depthSummary: '0,5 – 1 cm.',
    germDaysSummary: '10 – 21 dagen (traag).',
    germTempSummary: '7 – 20 °C.',
    lightSummary: 'Licht bedekken; kiembed vochtig houden.',
    waterSummary: 'Nooit laten uitdrogen in kiemperiode.',
    prickSummary: 'Niet verspenen; wel uitdunnen.',
    potSummary: 'Niet typisch; eventueel diepe bak ter plaatse.',
    depth: {
      why: 'Fijn zaad; te diep = slechte opkomst.',
      how: '0,5–1 cm, fijne grond, aandrukken.',
      tip: 'Meng met zand voor gelijkmatiger zaaien.',
    },
    germ: {
      why: 'Traag en gevoelig voor uitdroging.',
      how: 'Houd 2–3 weken vochtig; afdekvlies helpt.',
      tip: 'Radijs als “markeergewas” meezaaien toont de rij.',
    },
    temp: {
      why: 'Kiemt in koele lente.',
      how: 'Vanaf vroeg voorjaar mogelijk.',
      tip: 'Zomerhitte + droogte = slechte opkomst.',
    },
    light: {
      why: 'Niet echt lichtkiemer, wel oppervlakkig.',
      how: 'Dun afdekken.',
      tip: 'Geen dikke kluiten grond erop.',
    },
    water: {
      why: 'Kritische fase tot opkomst.',
      how: 'Dagelijks licht vochtig; geen harde korst.',
      tip: 'Beregen zacht of gebruik vlies.',
    },
    prick: {
      why: 'Verplanten misvormt de penwortel.',
      how: 'Dun uit op 3–5 cm (baby) of 5–8 cm.',
      tip: 'Uitdunnen als planten 3–5 cm hoog zijn.',
    },
    pot: {
      why: 'Alleen diepe bakken (≥30 cm) werken.',
      how: 'Zaai direct in de bak; geen verspenen.',
      tip: 'Kies korte/ronde rassen voor bakken.',
    },
  },

  radijs: {
    indoorSummary: 'Kan, maar buiten is sneller en makkelijker.',
    outdoorSummary: 'Maart – september in etappes.',
    indoorHow: 'Alleen voor vroege teelt in bak.',
    outdoorHow: 'Direct zaaien; oogst in 3–6 weken.',
    indoorWhy: 'Niet nodig voor snelle teelt.',
    outdoorWhy: 'Ideaal markeer- en tussengewas.',
    depthSummary: '1 cm.',
    germDaysSummary: '3 – 7 dagen.',
    germTempSummary: '8 – 20 °C.',
    lightSummary: 'Afdekken.',
    waterSummary: 'Vochtig voor milde, niet houtige knollen.',
    prickSummary: 'Uitdunnen op 2–5 cm.',
    potSummary: 'Prima in ondiepe bakken ter plaatse.',
    depth: {
      why: 'Klein zaad, ±1 cm.',
      how: 'Rij zaaien, aandrukken.',
      tip: 'Elke 1–2 weken opnieuw zaaien.',
    },
    germ: {
      why: 'Zeer snel.',
      how: 'Vaak binnen een week.',
      tip: 'Perfect om rijen van trage gewassen te markeren.',
    },
    temp: {
      why: 'Koel tot mild.',
      how: 'In hitte wordt radijs snel pithy/scherp.',
      tip: 'Zomer: halfschaduw of korte rassen.',
    },
    light: {
      why: 'Standaard bedekken.',
      how: '1 cm grond.',
      tip: 'Na opkomst volle zon (lente/herfst).',
    },
    water: {
      why: 'Droogte = houtig en scherp.',
      how: 'Gelijkmatig vochtig houden.',
      tip: 'Mulch helpt in warm weer.',
    },
    prick: {
      why: 'Dicht zaaien remt knolvorming.',
      how: 'Dun op 2–5 cm.',
      tip: 'Jonge blad is ook eetbaar.',
    },
    pot: {
      why: 'Ondiepe wortels.',
      how: 'Zaai direct in bak.',
      tip: 'Goede drainage.',
    },
  },

  kool: {
    indoorSummary: 'Februari – april (afhankelijk van type) voorzaaien.',
    outdoorSummary: 'April – juni; sommige types ook later voor winter.',
    indoorHow: 'In trays/modules; later verspenen.',
    outdoorHow: 'Zaai in zaaibed of plant uit na voorteelt.',
    indoorWhy: 'Voorteelt geeft sterke planten en vroegere oogst.',
    outdoorWhy: 'Kan ook in zaaibed; let op koolvlieg.',
    depthSummary: '0,5 – 1 cm.',
    germDaysSummary: '5 – 12 dagen.',
    germTempSummary: '10 – 20 °C.',
    lightSummary: 'Licht bedekken; daarna veel licht.',
    waterSummary: 'Vochtig, niet koud-nat laten staan.',
    prickSummary: 'Bij 2–3 echte blaadjes verspenen.',
    potSummary: 'Oppotten/modules tot uitplantgrootte (±5–8 weken).',
    depth: {
      why: 'Kleine zaden, oppervlakkig.',
      how: '0,5–1 cm.',
      tip: 'Gebruik fijn zaaigrond.',
    },
    germ: {
      why: 'Koel tot mild kiemt goed.',
      how: 'Niet te warm (±>25 °C) houden.',
      tip: 'Label rassen — veel koolsoorten lijken op elkaar als zaailing.',
    },
    temp: {
      why: 'Brede kiemrange.',
      how: '10–20 °C ideaal.',
      tip: 'Afharden voor uitplanten.',
    },
    light: {
      why: 'Voorkomt zwakke stengels.',
      how: 'Veel licht na opkomst.',
      tip: 'Kweeklamp in vroege lente helpt.',
    },
    water: {
      why: 'Gelijkmatig vocht.',
      how: 'Niet laten uitdrogen.',
      tip: 'Bij uitplanten goed aangieten.',
    },
    prick: {
      why: 'Ruimte voor stevige planten.',
      how: 'Verspeen naar modules bij 2–3 blaadjes.',
      tip: 'Plant iets dieper voor stevigheid.',
    },
    pot: {
      why: 'Uitplantklare planten (±15 cm).',
      how: 'Oppotten indien nodig; net tegen koolvlieg overwegen.',
      tip: 'Wissel teelt; geen kool op kool.',
    },
  },

  ui: {
    indoorSummary: 'Februari – maart voorzaaien of februari uienzaai.',
    outdoorSummary: 'Maart – april zaaien; of plantuien in voorjaar/herfst.',
    indoorHow: 'Dicht zaaien in trays, later verspenen/bundels.',
    outdoorHow: 'Rijen zaaien of plantuien zetten.',
    indoorWhy: 'Zaaiuien profiteren van lange voorteelt.',
    outdoorWhy: 'Plantuien zijn makkelijker voor beginners.',
    depthSummary: '1 – 1,5 cm (zaad); plantui punt omhoog.',
    germDaysSummary: '10 – 21 dagen (zaad).',
    germTempSummary: '10 – 18 °C.',
    lightSummary: 'Afdekken.',
    waterSummary: 'Vochtig tot opkomst; daarna niet nat.',
    prickSummary: 'In bosjes verspenen of uitdunnen.',
    potSummary: 'Modules mogelijk; uitplanten in bunches.',
    depth: {
      why: 'Klein zaad.',
      how: '1–1,5 cm. Plantui: tip net zichtbaar.',
      tip: 'Onderscheid zaaiui vs plantui in je planning.',
    },
    germ: {
      why: 'Traag.',
      how: 'Geduld tot 3 weken; vochtig houden.',
      tip: 'Markeer rijen goed.',
    },
    temp: {
      why: 'Koel kiemen.',
      how: 'Niet op hete mat.',
      tip: 'Te vroeg + extreme kou kan schieten beïnvloeden bij sommige types.',
    },
    light: {
      why: 'Standaard.',
      how: 'Afdekken, daarna licht.',
      tip: 'Dunne zaailingen niet laten oprekken.',
    },
    water: {
      why: 'Opkomstfase kritisch.',
      how: 'Vochtig; later droger voor bolvorming.',
      tip: 'Stop met water geven als loof knikt bij afrijping.',
    },
    prick: {
      why: 'Uien verdragen bunches.',
      how: 'Verspeen groepjes van 3–4.',
      tip: 'Of dun ter plaatse.',
    },
    pot: {
      why: 'Vooral voor zaaiuien.',
      how: 'Uitplanten op 10–15 cm.',
      tip: 'Onkruidvrij houden — uien concurreren slecht.',
    },
  },

  prei: {
    indoorSummary: 'Januari – april voorzaaien (vroege/late types).',
    outdoorSummary: 'April – mei zaaibed; later uitplanten.',
    indoorHow: 'Zaai in trays; later diep planten voor witte schacht.',
    outdoorHow: 'Zaaibed of modules; uitplanten in geultjes.',
    indoorWhy: 'Lange teelt; voorzaaien is standaard.',
    outdoorWhy: 'Zaaibed werkt goed; uitplanten maakt bleke schachten.',
    depthSummary: '1 cm.',
    germDaysSummary: '10 – 20 dagen.',
    germTempSummary: '10 – 18 °C.',
    lightSummary: 'Afdekken; daarna licht.',
    waterSummary: 'Vochtig houden.',
    prickSummary: 'Verspenen/uitplanten als potlooddik.',
    potSummary: 'Modules; diep uitplanten.',
    depth: {
      why: 'Klein zaad.',
      how: '±1 cm.',
      tip: 'Geduld bij kieming.',
    },
    germ: {
      why: 'Traag zoals ui.',
      how: 'Vochtig en koel-mild.',
      tip: 'Niet te dik zaaien.',
    },
    temp: {
      why: 'Koel kiemen.',
      how: '10–18 °C.',
      tip: 'Extreme hitte vermijden.',
    },
    light: {
      why: 'Na opkomst licht.',
      how: 'Afdekken tot kieming.',
      tip: 'Sterke zaailingen = dikkere prei.',
    },
    water: {
      why: 'Gelijkmatig.',
      how: 'Niet laten uitdrogen.',
      tip: 'Bij uitplanten geul water geven.',
    },
    prick: {
      why: 'Diep planten bleekt de schacht.',
      how: 'Plant diep in gaten/geul; aanzarden later.',
      tip: 'Wortels inkorten mag licht bij uitplanten.',
    },
    pot: {
      why: 'Modules vergemakkelijken uitplanten.',
      how: 'Uitplanten op 10–15 cm.',
      tip: 'Houd vochtig na uitplanten.',
    },
  },

  aardappel: {
    indoorSummary: 'Niet zaaien: pootgoed voorkiemen (maart).',
    outdoorSummary: 'Maart – mei poten (geen zaadteelt voor knollen).',
    indoorHow: 'Pootaardappelen voorkiemen op koele lichte plek.',
    outdoorHow: 'Poten in voren zodra grond bewerkbaar is.',
    indoorWhy: 'Consumententeelt gebruikt knollen (pootgoed), geen zaad.',
    outdoorWhy: 'Poten is de standaardmethode voor oogstknollen.',
    depthSummary: 'Pootdiepte 8 – 12 cm; aanaarden later.',
    germDaysSummary: 'Opkomst 2 – 4 weken na poten.',
    germTempSummary: 'Bodem bij voorkeur >6–8 °C.',
    lightSummary: 'Voorkiemen in licht; pootgoed niet in donker lang bewaren groen.',
    waterSummary: 'Niet sopnat poten; na opkomst gelijkmatig vocht.',
    prickSummary: 'N.v.t. (geen zaailingteelt).',
    potSummary: 'N.v.t.; eventueel potteelt met pootgoed.',
    noSeed: true,
    note: 'Geen zaadteelt voor eetknollen; gebruik gecertificeerd pootgoed.',
    depth: {
      why: 'Knol moet bedekt zijn om groen worden/te voorkomen en vocht te houden.',
      how: '8–12 cm diep; later aanaarden tot ruggen.',
      tip: 'Snijd grote poters eventueel met ogen; laat wond drogen.',
    },
    germ: {
      why: 'Opkomst hangt af van bodemwarmte.',
      how: 'Voorkiemen verkort tijd tot groen.',
      tip: 'Bescherm jonge loof tegen late vorst (aanaarden/vlies).',
    },
    temp: {
      why: 'Koude natte grond rot pootgoed.',
      how: 'Wacht tot grond bewerkbaar is.',
      tip: 'Vroege rassen eerder, late rassen iets later.',
    },
    light: {
      why: 'Voorkiemen in licht geeft stevige scheuten (niet lange witte).',
      how: 'Koel, licht, vorstvrij voorkiemen 3–6 weken.',
      tip: 'Donkere warme kast = slappe scheuten.',
    },
    water: {
      why: 'Rot vs droogtestress.',
      how: 'Niet poten in natte klei; na opkomst regelmatig vocht.',
      tip: 'Droogte tijdens knolzetting verlaagt oogst.',
    },
    prick: {
      why: 'Geen zaailingen.',
      how: 'Niet van toepassing.',
      tip: 'Wel opkomst checken en gaten bijpoten.',
    },
    pot: {
      why: 'Potteelt kan met pootgoed.',
      how: 'Diepe pot/zak, trapsgewijs aanaarden.',
      tip: 'Gebruik pootgoed, geen supermarktaardappel (ziekterisico).',
    },
  },

  mais: {
    indoorSummary: 'Eind april – mei voorzaaien in potten.',
    outdoorSummary: 'Mei buiten zaaien in blokken (niet enkele rij).',
    indoorHow: '1 zaad per pot, warm; snel uitplanten.',
    outdoorHow: 'In blok zaaien voor windbestuiving.',
    indoorWhy: 'Voorsprong helpt in korte zomers.',
    outdoorWhy: 'Mais is windbestuiver: blokvormige planting.',
    depthSummary: '3 – 5 cm.',
    germDaysSummary: '7 – 14 dagen.',
    germTempSummary: 'Bodem >10–12 °C, liever 15 °C+.',
    lightSummary: 'Afdekken.',
    waterSummary: 'Vochtig tot opkomst.',
    prickSummary: 'Niet verspenen; potzaai.',
    potSummary: 'Snel uitplanten; houdt niet van kleine pot lang.',
    frost: true,
    depth: {
      why: 'Groot zaad.',
      how: '3–5 cm diep.',
      tip: 'Vogels lusten zaden — net/vlies overwegen.',
    },
    germ: {
      why: 'Warmte nodig.',
      how: 'Wacht op warme grond of voorzaai.',
      tip: 'Koud + nat = rotting.',
    },
    temp: {
      why: 'Warmteminnend grasgewas.',
      how: 'Na ijsheiligen buiten.',
      tip: 'Zwarte plastic/mulch kan helpen.',
    },
    light: {
      why: 'Standaard.',
      how: 'Afdekken.',
      tip: 'Volle zon teelt.',
    },
    water: {
      why: 'Vocht bij kieming en bloei.',
      how: 'Na zaaien vochtig; later diep water.',
      tip: 'Droogte bij bloei = slechte kolfvulling.',
    },
    prick: {
      why: 'Gevoelig voor wortelstoring.',
      how: 'Potzaai / direct zaaien.',
      tip: 'Uitdunnen op 25–30 cm.',
    },
    pot: {
      why: 'Snelle groeier.',
      how: 'Niet lang in pot houden.',
      tip: 'Plant in blok van minstens 4×4 voor bestuiving.',
    },
  },

  boon: {
    indoorSummary: 'Eind april – mei (niet te vroeg; kou = rot).',
    outdoorSummary: 'Mei – juni buiten zaaien.',
    indoorHow: 'Potzaai kort vóór uitplanten.',
    outdoorHow: 'Direct zaaien in warme grond.',
    indoorWhy: 'Korte voorteelt kan; te vroeg zaaien mislukt vaak door kou.',
    outdoorWhy: 'Standaard: warm genoeg, dan buiten zaaien.',
    depthSummary: '3 – 5 cm.',
    germDaysSummary: '7 – 14 dagen.',
    germTempSummary: 'Bodem >12–15 °C.',
    lightSummary: 'Afdekken.',
    waterSummary: 'Vochtig; niet koud en nat.',
    prickSummary: 'Niet verspenen; pot of ter plaatse.',
    potSummary: 'Kort in pot, snel uitplanten.',
    frost: true,
    depth: {
      why: 'Grote zaden.',
      how: '3–5 cm.',
      tip: 'Niet in ijskoude natte grond.',
    },
    germ: {
      why: 'Warmte voorkomt rotting.',
      how: 'Wacht op warm weer.',
      tip: 'Week 1–2 u max; langer kan schadelijk zijn.',
    },
    temp: {
      why: 'Koude grond = wegrotten.',
      how: 'Na ijsheiligen.',
      tip: 'Staakbonen latwerk klaarzetten bij zaaien.',
    },
    light: {
      why: 'Standaard.',
      how: 'Afdekken.',
      tip: 'Volle zon.',
    },
    water: {
      why: 'Vocht voor zwelling.',
      how: 'Na zaaien aangieten; daarna matig.',
      tip: 'Te nat + koud = schimmel.',
    },
    prick: {
      why: 'Heeft hekel aan wortelstoring.',
      how: 'Direct of pot met kluit.',
      tip: 'Uitdunnen i.p.v. verspenen.',
    },
    pot: {
      why: 'Alleen korte voorteelt.',
      how: 'Uitplanten zodra veilig.',
      tip: 'Niet laten bloeien in te kleine pot.',
    },
  },

  erwt: {
    indoorSummary: 'Februari – maart mogelijk; vaak buiten vroeg.',
    outdoorSummary: 'Maart – april (en soms juli voor herfst).',
    indoorHow: 'Modules/potjes; snel uitplanten.',
    outdoorHow: 'Vroeg zaaien in koele grond kan wél.',
    indoorWhy: 'Optioneel voor voorsprong of vogelbescherming.',
    outdoorWhy: 'Erwten houden van koel weer; vroeg zaaien is normaal.',
    depthSummary: '3 – 5 cm.',
    germDaysSummary: '7 – 14 dagen.',
    germTempSummary: '5 – 15 °C werkt goed.',
    lightSummary: 'Afdekken.',
    waterSummary: 'Vochtig tot opkomst.',
    prickSummary: 'Liever niet; pot/ter plaatse.',
    potSummary: 'Kort; steun/net bij uitplanten.',
    depth: {
      why: 'Groot zaad.',
      how: '3–5 cm.',
      tip: 'Bescherm tegen vogels/muizen.',
    },
    germ: {
      why: 'Kiembereik koeler dan boon.',
      how: 'Vroege lente oké.',
      tip: 'Niet in bevroren grond.',
    },
    temp: {
      why: 'Koeleseizoen.',
      how: 'Zaai vroeg; hitte = slechte peulen.',
      tip: 'Schaduwdoek in late warmte.',
    },
    light: {
      why: 'Standaard.',
      how: 'Afdekken.',
      tip: 'Steun bij rankende types.',
    },
    water: {
      why: 'Vocht bij bloei belangrijk.',
      how: 'Kiemfase vochtig; daarna regelmatig.',
      tip: 'Mulch helpt.',
    },
    prick: {
      why: 'Wortelgevoelig.',
      how: 'Potzaai of direct.',
      tip: 'Uitdunnen op 5 cm.',
    },
    pot: {
      why: 'Korte voorteelt.',
      how: 'Snel uit, steun geven.',
      tip: 'Net/gaas tegen vogels.',
    },
  },

  kruid_zacht: {
    indoorSummary: 'Maart – mei voorzaaien (soortafhankelijk).',
    outdoorSummary: 'April – juni buiten na opwarming.',
    indoorHow: 'Fijn zaad oppervlakkig; lichtkiemer vaak.',
    outdoorHow: 'Dun zaaien op zonnige plek.',
    indoorWhy: 'Veel keukenkruiden starten beter gecontroleerd binnen.',
    outdoorWhy: 'Na vorst kan direct of uitgeplant.',
    depthSummary: '0 – 0,5 cm (vaak lichtkiemer).',
    germDaysSummary: '7 – 21 dagen.',
    germTempSummary: '15 – 22 °C.',
    lightSummary: 'Vaak lichtkiemer: niet bedekken.',
    waterSummary: 'Benevelen; fijn zaad droogt snel.',
    prickSummary: 'Bij 2–3 blaadjes voorzichtig verspenen.',
    potSummary: 'Oppotten in kruidenpotten.',
    depth: {
      why: 'Zeer fijn zaad.',
      how: 'Oppervlakkig, aandrukken.',
      tip: 'Basilicum e.d. echt niet begraven.',
    },
    germ: {
      why: 'Soortverschillen groot.',
      how: 'Geduld; warmte helpt tropische kruiden (basilicum).',
      tip: 'Peterselie is berucht traag (tot 3–4 weken).',
    },
    temp: {
      why: 'Hangt van soort: basilicum warm, peterselie koeler.',
      how: 'Check soort; basilicum ~20–25 °C.',
      tip: 'Niet alle kruiden op dezelfde mat zetten.',
    },
    light: {
      why: 'Veel fijnzadige kruiden zijn lichtkiemers.',
      how: 'Niet of nauwelijks bedekken.',
      tip: 'Na opkomst veel licht.',
    },
    water: {
      why: 'Oppervlaktezaad.',
      how: 'Benevel; kap helpt vocht.',
      tip: 'Kap eraf bij opkomst tegen schimmel.',
    },
    prick: {
      why: 'Dunne zaailingen.',
      how: 'Voorzichtig verspenen of uitdunnen.',
      tip: 'Sommige (dille) liever ter plaatse.',
    },
    pot: {
      why: 'Keukenkruiden groeien goed in pot.',
      how: 'Oppotten met verse potgrond.',
      tip: 'Drainagegat verplicht.',
    },
  },

  meerjarig: {
    indoorSummary: 'Voorjaar voorzaaien of delen/planten.',
    outdoorSummary: 'Voorjaar of najaar planten; zaaien soortafhankelijk.',
    indoorHow: 'Vaak traag; koudeperiode soms nodig.',
    outdoorHow: 'Plantgoed is betrouwbaarder dan zaad voor beginners.',
    indoorWhy: 'Meerjarigen starten traag uit zaad; plantgoed is praktischer.',
    outdoorWhy: 'Veel soorten worden als plant of via deling vermeerderd.',
    depthSummary: 'Afhankelijk van zaadgrootte (vaak 0,5 – 2 cm).',
    germDaysSummary: '2 – 6 weken (soms langer).',
    germTempSummary: 'Vaak 15 – 20 °C; sommige willen koudeperiode.',
    lightSummary: 'Soortafhankelijk; check of licht- of donkerkiemer.',
    waterSummary: 'Gelijkmatig vochtig; geduld.',
    prickSummary: 'Verspenen als hanteerbaar.',
    potSummary: 'Oppotten en eerste jaar beschermen.',
    note: 'Voor asperge/artisjok e.d. is plantgoed vaak beter dan zaad.',
    depth: {
      why: 'Verschilt per soort.',
      how: 'Vuistregel 2–3× zaaddikte.',
      tip: 'Koop plantgoed als zaadinfo ontbreekt.',
    },
    germ: {
      why: 'Meerjarigen investeren eerst in wortel.',
      how: 'Geduld; niet te vroeg weggooien.',
      tip: 'Sommige zaden hebben koude stratificatie nodig.',
    },
    temp: {
      why: 'Soortspecifiek.',
      how: 'Matig warm tenzij anders aangegeven.',
      tip: 'Asperge uit zaad duurt jaren tot oogst.',
    },
    light: {
      why: 'Soortspecifiek.',
      how: 'Bij twijfel oppervlakkig zaaien en vochtig houden.',
      tip: 'Noteer bron/ras.',
    },
    water: {
      why: 'Lange kiemtijd = lang vochtig houden zonder rot.',
      how: 'Luchtige grond, matig vochtig.',
      tip: 'Goede hygiene in trays.',
    },
    prick: {
      why: 'Zodra hanteerbaar.',
      how: 'Voorzichtig verspenen.',
      tip: 'Eerste winter soms vorstbescherming.',
    },
    pot: {
      why: 'Opkweek tot plantgrootte.',
      how: 'Oppotten en afharden.',
      tip: 'Plant op vaste plek met ruimte voor jaren.',
    },
  },

  fruit_zaad: {
    indoorSummary: 'Meestal niet via moestuinzaad; gebruik plantgoed.',
    outdoorSummary: 'Plant bomen/struiken in tipseizoen; zaaien is specialistisch.',
    indoorHow: 'Zaailingen uit pit zijn genetisch onvoorspelbaar en traag.',
    outdoorHow: 'Koop geënt plantgoed voor betrouwbare rassen.',
    indoorWhy:
      'Appel/peer e.d. uit zaad geven zelden de ouder-ras kwaliteit en kosten jaren.',
    outdoorWhy: 'Praktijk: plantgoed, niet pitteelt.',
    depthSummary: 'N.v.t. voor normale teelt (plantgoed).',
    germDaysSummary: 'N.v.t. / specialistisch (vaak stratificatie).',
    germTempSummary: 'N.v.t. voor standaard aanplant.',
    lightSummary: 'N.v.t.',
    waterSummary: 'Bij aanplant: goed water geven.',
    prickSummary: 'N.v.t.',
    potSummary: 'Containerplanten uitpotten en aanplanten.',
    noSeed: true,
    note: 'Geen betrouwbare moestuin-zaai-route; gebruik plantgoed. Exacte stratificatie per soort niet volledig uitgewerkt in deze gids.',
    depth: {
      why: 'Zaadteelt is geen standaardroute voor raszuivere vruchten.',
      how: 'Plant een gekocht boompje/struik op juiste diepte (enting boven grond).',
      tip: 'Pit teelt alleen voor experiment/onderstam.',
    },
    germ: {
      why: 'Veel pitten hebben koude stratificatie nodig.',
      how: 'Niet uitgewerkt per fruitsoort in deze app-gids.',
      tip: 'Zoek soortspecifieke stratificatie als je toch wilt experimenteren.',
    },
    temp: {
      why: 'Aanplant seizoensgebonden.',
      how: 'Plant in rustperiode of volgens kwekerijadvies.',
      tip: 'Niet in volle zomerhitte zonder waterplan.',
    },
    light: {
      why: 'Volle zon voor de meeste fruitsoorten.',
      how: 'Kies standplaats volgens soort.',
      tip: 'Zaailingen uit pit: jaren tot eerste vrucht.',
    },
    water: {
      why: 'Aanplantfase kritisch.',
      how: 'Eerste seizoenen regelmatig water.',
      tip: 'Mulch helpt.',
    },
    prick: {
      why: 'N.v.t.',
      how: 'Niet van toepassing.',
      tip: 'Snoeien/leiden wél relevant na aanplant.',
    },
    pot: {
      why: 'Containerteelt mogelijk bij kleine fruittypes.',
      how: 'Uitpotten zonder wortelkluit te slopen.',
      tip: 'Geënte rassen kopen.',
    },
  },

  aardbei: {
    indoorSummary: 'Zaaien kan in winter (traag); meestal plantgoed.',
    outdoorSummary: 'Plant in voorjaar of nazomer; uitlopers gebruiken.',
    indoorHow: 'Lichtkiemer, koel; zeer traag.',
    outdoorHow: 'Plant frigo/verse planten; of uitlopers afleggen.',
    indoorWhy: 'Zaadteelt is specialistisch en traag; plantgoed is standaard.',
    outdoorWhy: 'Uitlopers/planten geven sneller oogst.',
    depthSummary: 'Niet bedekken (lichtkiemer) bij zaad.',
    germDaysSummary: '2 – 6 weken (zaad).',
    germTempSummary: '15 – 20 °C; soms koudeperiode.',
    lightSummary: 'Lichtkiemer.',
    waterSummary: 'Benevelen.',
    prickSummary: 'Verspenen als hanteerbaar.',
    potSummary: 'Oppotten; hart niet begraven bij uitplanten.',
    note: 'Voor snelle oogst: koop plantgoed i.p.v. zaad.',
    depth: {
      why: 'Zeer fijn zaad, lichtkiemer.',
      how: 'Oppervlakkig zaaien.',
      tip: 'Plantgoed is praktischer.',
    },
    germ: {
      why: 'Traag en wisselvallig.',
      how: 'Geduld; vochtig en licht.',
      tip: 'Sommige zaden willen koude stratificatie.',
    },
    temp: {
      why: 'Matig.',
      how: '15–20 °C.',
      tip: 'Niet te warm na opkomst.',
    },
    light: {
      why: 'Lichtkiemer.',
      how: 'Niet bedekken.',
      tip: 'Na opkomst veel licht.',
    },
    water: {
      why: 'Fijn zaad.',
      how: 'Benevelen.',
      tip: 'Geen plasvorming.',
    },
    prick: {
      why: 'Kleine zaailingen.',
      how: 'Voorzichtig verspenen.',
      tip: 'Hart vrijhouden van grond.',
    },
    pot: {
      why: 'Opkweek tot plant.',
      how: 'Oppotten; uitplanten met hart boven grond.',
      tip: 'Uitlopers later voor vermeerdering.',
    },
  },

  knoflook: {
    indoorSummary: 'Niet zaaien: tenen poten.',
    outdoorSummary: 'Oktober – november (of vroeg voorjaar) tenen poten.',
    indoorHow: 'N.v.t.',
    outdoorHow: 'Tenen met punt omhoog, 3–5 cm diep, 10–15 cm uit elkaar.',
    indoorWhy: 'Knoflook wordt vegetatief vermeerderd via tenen.',
    outdoorWhy: 'Najaarspoten geeft sterkste bollen in NL.',
    depthSummary: 'Tenen 3 – 5 cm diep.',
    germDaysSummary: 'Opkomst na weken; wintergroei traag.',
    germTempSummary: 'Koude periode stimuleert bolvorming.',
    lightSummary: 'Volle zon teelt.',
    waterSummary: 'Niet te nat in winter; in voorjaar vochtig.',
    prickSummary: 'N.v.t.',
    potSummary: 'N.v.t. / bakken mogelijk met tenen.',
    noSeed: true,
    depth: {
      why: 'Teen moet bedekt zijn tegen vorst/uitdroging.',
      how: '3–5 cm, punt omhoog.',
      tip: 'Gebruik pootknoflook, geen behandelde supermarktknoflook.',
    },
    germ: {
      why: 'Wortels eerst, loof later.',
      how: 'Najaar poten; geduld.',
      tip: 'Mulch tegen vorst wisselingen.',
    },
    temp: {
      why: 'Koude winter helpt bolsplitsing.',
      how: 'Najaarspoten prefereert.',
      tip: 'Voorjaarspoten kan, vaak kleinere bollen.',
    },
    light: {
      why: 'Volle zon.',
      how: 'Zonnige plek kiezen.',
      tip: 'Goede drainage.',
    },
    water: {
      why: 'Rot in natte winterklei.',
      how: 'Doorlatende grond; voorjaar water bij droogte.',
      tip: 'Stop water vóór afrijping.',
    },
    prick: {
      why: 'N.v.t.',
      how: 'Niet van toepassing.',
      tip: 'Verwijder bloemstengels (scape) bij hardneck voor grotere bollen.',
    },
    pot: {
      why: 'Kan in diepe bak.',
      how: 'Tenen poten zoals buiten.',
      tip: 'Vorstvrije maar koude plek.',
    },
  },

  okra: {
    indoorSummary: 'April warm voorzaaien (kas/huis).',
    outdoorSummary: 'Juni uitplanten op warmste plek; zelden direct buiten.',
    indoorHow: 'Week zaden, zaai warm (24–30 °C) in potjes.',
    outdoorHow: 'Alleen na echte zomerwarmte; kas helpt sterk.',
    indoorWhy: 'Okra is tropisch en eist hoge kiem- en groeitemperaturen.',
    outdoorWhy: 'NL-zomer is vaak te kort/koel zonder kas of warme muur.',
    depthSummary: '1 – 2 cm.',
    germDaysSummary: '5 – 14 dagen bij hoge warmte.',
    germTempSummary: '24 – 30 °C.',
    lightSummary: 'Afdekken; daarna veel licht.',
    waterSummary: 'Warm en vochtig kiemen.',
    prickSummary: 'Potzaai; voorzichtig uitplanten.',
    potSummary: 'Snel naar warme standplaats/kas.',
    frost: true,
    note: 'In NL vooral kas/zuidmuur; oogst wisselvallig in koele zomers.',
    depth: { why: 'Middelgroot zaad.', how: '1–2 cm na weken.', tip: 'Harde schil: licht schuren of weeken.' },
    germ: { why: 'Hoge warmte verplicht.', how: 'Warmteplaat.', tip: 'Onder 20 °C vaak mislukking.' },
    temp: { why: 'Tropisch.', how: '24–30 °C kiemen.', tip: 'Kas sterk aanbevolen.' },
    light: { why: 'Sterke zaailingen.', how: 'Veel licht na opkomst.', tip: 'Niet laten oprekken.' },
    water: { why: 'Vocht + warmte.', how: 'Niet koud water.', tip: 'Goede drainage.' },
    prick: { why: 'Wortelgevoelig.', how: 'Potzaai.', tip: 'Kluit behouden.' },
    pot: { why: 'Warmte na uitplanten.', how: 'Kas/zuidmuur.', tip: 'Oogst peulen jong.' },
  },
  gember: {
    indoorSummary: 'Voorjaar: stukje wortelstok poten (geen zaad).',
    outdoorSummary: 'Alleen kas/pot binnenshuis in NL.',
    indoorHow: 'Poot een knolstuk met oog in potgrond, warm en licht vochtig.',
    outdoorHow: 'Niet winterhard; houd als kuipplant.',
    indoorWhy: 'Gember vermeerdert via rizoom, niet via moestuinzaad.',
    outdoorWhy: 'Te koud voor vollegrondsteelt in NL.',
    depthSummary: 'Rizoom licht bedekken (2–3 cm).',
    germDaysSummary: 'Opkomst 2 – 6 weken.',
    germTempSummary: '22 – 28 °C.',
    lightSummary: 'Lichte plek, geen felle middagzon eerst.',
    waterSummary: 'Licht vochtig; niet koud en nat.',
    prickSummary: 'N.v.t.',
    potSummary: 'Ruime pot; binnen of kas overwinteren.',
    noSeed: true,
    note: 'Geen zaadteelt — poot biologisch rizoom. Exacte rasseninfo beperkt.',
    depth: { why: 'Rizoom moet net bedekt.', how: '2–3 cm potgrond erover.', tip: 'Gebruik onbehandelde knol.' },
    germ: { why: 'Warmte wekt ogen.', how: 'Geduld tot scheuten.', tip: 'Plastic kap houdt vocht.' },
    temp: { why: 'Tropisch.', how: '>22 °C.', tip: 'Kou stopt groei.' },
    light: { why: 'Na opkomst licht.', how: 'Half Indirect tot licht.', tip: 'Verbranding vermijden.' },
    water: { why: 'Rot vs droogte.', how: 'Matig vochtig.', tip: 'Minder water in winter.' },
    prick: { why: 'N.v.t.', how: 'Niet van toepassing.', tip: 'Delen van rizoom kan later.' },
    pot: { why: 'Kuipteelt.', how: 'Ruime pot, goede drainage.', tip: 'Binnen halen vóór kou.' },
  },
  pepino: {
    indoorSummary: 'Voorjaar stekken of zaaien warm; vaak plantgoed.',
    outdoorSummary: 'Kas/kuip; niet winterhard.',
    indoorHow: 'Zaai warm of stek halfverhoute scheuten.',
    outdoorHow: 'Uitplanten in kas na vorst.',
    indoorWhy: 'Pepino is vorstgevoelig; opkweek binnen/kas.',
    outdoorWhy: 'Alleen beschutte warme teelt in NL.',
    depthSummary: '0,5 – 1 cm bij zaad.',
    germDaysSummary: '10 – 21 dagen.',
    germTempSummary: '20 – 25 °C.',
    lightSummary: 'Licht bedekken; daarna licht.',
    waterSummary: 'Vochtig, niet nat.',
    prickSummary: 'Verspenen bij 2 blaadjes.',
    potSummary: 'Kuipplant; afharden naar kas.',
    frost: true,
    note: 'In NL vooral kas/kuip; zaad minder gangbaar dan stek/plant.',
    depth: { why: 'Klein zaad.', how: '0,5–1 cm.', tip: 'Stekken is vaak makkelijker.' },
    germ: { why: 'Warmte.', how: '20–25 °C.', tip: 'Geduld.' },
    temp: { why: 'Vorstgevoelig.', how: 'Kas.', tip: 'Binnen overwinteren.' },
    light: { why: 'Na opkomst licht.', how: 'Lichte plek.', tip: 'Niet langrekken.' },
    water: { why: 'Gelijkmatig.', how: 'Niet uitdrogen.', tip: 'Drainage.' },
    prick: { why: 'Ruimte.', how: 'Verspenen voorzichtig.', tip: 'Of stek gebruiken.' },
    pot: { why: 'Kuipteelt.', how: 'Oppotten.', tip: 'Steunen bij vrucht.' },
  },
  kardoen: {
    indoorSummary: 'Maart – april voorzaaien.',
    outdoorSummary: 'Mei uitplanten; lijkt op artisjok-familie.',
    indoorHow: 'Zaai in potten; later uitplanten.',
    outdoorHow: 'Ruimte geven; bleken voor eetbare stengels.',
    indoorWhy: 'Lange teelt; voorzaaien helpt.',
    outdoorWhy: 'Uitplanten na vorst op voedselrijke grond.',
    depthSummary: '1 – 2 cm.',
    germDaysSummary: '10 – 20 dagen.',
    germTempSummary: '15 – 20 °C.',
    lightSummary: 'Afdekken.',
    waterSummary: 'Vochtig houden.',
    prickSummary: 'Potzaai of verspenen voorzichtig.',
    potSummary: 'Uitplanten met ruimte (grote plant).',
    frost: true,
    note: 'Minder gangbaar; bleektechniek bepaalt eetkwaliteit stengels.',
    depth: { why: 'Middelgroot zaad.', how: '1–2 cm.', tip: 'Verse zaden gebruiken.' },
    germ: { why: 'Matige warmte.', how: '15–20 °C.', tip: 'Geduld.' },
    temp: { why: 'Vorstgevoelig jong.', how: 'Na ijsheiligen uit.', tip: 'Mulch later.' },
    light: { why: 'Standaard.', how: 'Afdekken.', tip: 'Volle zon teelt.' },
    water: { why: 'Vocht voor opkomst.', how: 'Gelijkmatig.', tip: 'Later diep water.' },
    prick: { why: 'Penwortelachtig.', how: 'Liever potzaai.', tip: 'Kluit behouden.' },
    pot: { why: 'Grote eindplant.', how: 'Snel naar vaste plek.', tip: 'Bleken in najaar.' },
  },
  tauge: {
    indoorSummary: 'Niet tuinjaaien: kiemen op keukenpapier/kiemschaal.',
    outdoorSummary: 'N.v.t. voor taugé-productie.',
    indoorHow: 'Week mungbonen, spoel 2–3× daags tot kiemgroente.',
    outdoorHow: 'Niet van toepassing.',
    indoorWhy: 'Taugé is een kiemgroente, geen moestuinplantteelt.',
    outdoorWhy: 'Geen bedteelt voor taugé.',
    depthSummary: 'N.v.t. (kiemen zonder grond).',
    germDaysSummary: '3 – 6 dagen tot eetbare kiemen.',
    germTempSummary: '18 – 24 °C.',
    lightSummary: 'Donker kiemen voor witte taugé; licht maakt groener/bitterder.',
    waterSummary: 'Meermaals daags spoelen; goed uitlekken.',
    prickSummary: 'N.v.t.',
    potSummary: 'N.v.t.',
    noSeed: true,
    note: 'Keukenkieming, geen zaaibed. Gebruik kiemgeschikte zaden (voedselveilig).',
    depth: { why: 'Geen grondteelt.', how: 'Kiempot/papier.', tip: 'Geen tuinzaad met coating.' },
    germ: { why: 'Snelle keukenkiem.', how: 'Spoelen + uitlekken.', tip: 'Schimmel = te nat/warm stilstaand water.' },
    temp: { why: 'Kamertemperatuur.', how: '18–24 °C.', tip: 'Niet op radiator.' },
    light: { why: 'Donker voor klassieke witte taugé.', how: 'Kast/doek.', tip: 'Kort licht vóór oogst optioneel.' },
    water: { why: 'Hygiëne.', how: '2–3× spoelen/dag.', tip: 'Goed uitlekken.' },
    prick: { why: 'N.v.t.', how: 'Niet van toepassing.', tip: 'Oogst na 3–6 dagen.' },
    pot: { why: 'N.v.t.', how: 'Niet van toepassing.', tip: 'Koel bewaren na oogst.' },
  },
  algemeen: {
    indoorSummary: 'Voorzaaien in het vroege voorjaar volgens seizoen.',
    outdoorSummary: 'Buiten zaaien wanneer grond en vorst het toelaten.',
    indoorHow: 'Gebruik zaaigrond, labels en een lichte, warme plek.',
    outdoorHow: 'Zaai in losse grond; houd vochtig tot opkomst.',
    indoorWhy: 'Voorzaaien geeft voorsprong en bescherming tegen kou.',
    outdoorWhy: 'Direct zaaien is eenvoudig als het seizoen past.',
    depthSummary: 'Ongeveer 2–3× de zaaddikte.',
    germDaysSummary: 'Meestal 5 – 21 dagen.',
    germTempSummary: 'Meestal 15 – 22 °C.',
    lightSummary: 'Check of de soort licht- of donkerkiemer is.',
    waterSummary: 'Gelijkmatig vochtig, niet sopnat.',
    prickSummary: 'Bij 2 – 4 echte blaadjes.',
    potSummary: 'Verpot bij volle wortelkluit.',
    note: 'Algemeen profiel — soortspecifieke details beperkt beschikbaar.',
    depth: {
      why: 'Vuistregel voorkomt te diep zaaien.',
      how: '2–3× zaaddikte, aandrukken, vochtig houden.',
      tip: 'Bij twijfel eerder te ondiep dan te diep (behalve grote zaden).',
    },
    germ: {
      why: 'Temperatuur en vocht bepalen de snelheid.',
      how: 'Geduld tot 3 weken bij tragere soorten.',
      tip: 'Noteer zaaidatum.',
    },
    temp: {
      why: 'Te koud = traag/rot; te warm + weinig licht = langrek.',
      how: 'Hoeer warmte bij warmteminnende gewassen.',
      tip: 'Bodthermometer helpt buiten.',
    },
    light: {
      why: 'Lichtkiemers vs donkerkiemers.',
      how: 'Bij twijfel: heel licht afdekken en vochtig houden.',
      tip: 'Na opkomst altijd voldoende licht.',
    },
    water: {
      why: 'Kieming stopt bij droogte.',
      how: 'Benevel of van onderaf water geven.',
      tip: 'Ventileer afgedekte trays tegen schimmel.',
    },
    prick: {
      why: 'Ruimte = sterkere planten.',
      how: 'Verspeen voorzichtig met kluitje.',
      tip: 'Niet alle gewassen willen verspenen (wortel, komkommer).',
    },
    pot: {
      why: 'Voorkomt remming door te kleine pot.',
      how: 'Oppotten en afharden vóór buiten.',
      tip: 'IJsheiligen als vuistregel voor vorstgevoelige teelten.',
    },
  },
};

/** Map plant id → profile key */
function profileKeyFor(id) {
  const x = id.toLowerCase();
  if (x.includes('aardappel')) return 'aardappel';
  if (x.includes('knoflook') || x === 'sjalot' || x.includes('sjalot')) return 'knoflook';
  if (x.includes('mais') || x.includes('maïs') || x === 'suikermais') return 'mais';
  if (
    x.includes('mango') ||
    x.includes('avocado') ||
    x.includes('nectarine') ||
    x.includes('mirabel') ||
    x.includes('kriek') ||
    x.includes('mispel') ||
    x.includes('mandarijn') ||
    x.includes('citroenboom') ||
    x.includes('limoen') ||
    x.includes('walnoot') ||
    x.includes('hazelnoot') ||
    x.includes('kastanje') ||
    x.includes('kaki') ||
    x.includes('physalis')
  )
    return 'fruit_zaad';
  if (
    x.includes('haricot') ||
    x.includes('snijboon') ||
    x.includes('snijbonen') ||
    x.includes('pinda') ||
    x.includes('kapucijner')
  )
    return x.includes('kapucijner') ? 'erwt' : 'boon';
  if (
    x.includes('mizuna') ||
    x.includes('tatsoi') ||
    x.includes('komatsuna') ||
    x.includes('mosterd') ||
    x.includes('savooi')
  )
    return 'kool';
  if (x.includes('zuring') || x.includes('majoraan') || x.includes('kamille') || x.includes('estragon') || x.includes('kerrie') || x.includes('citroengras'))
    return 'kruid_zacht';
  if (x.includes('gember')) return 'gember';
  if (x.includes('okra')) return 'okra';
  if (x.includes('pepino')) return 'pepino';
  if (x.includes('kardoen')) return 'kardoen';
  if (x.includes('tauge')) return 'tauge';
  if (
    x.includes('tomaat') ||
    x.includes('tros') ||
    x.includes('cherry') ||
    x.includes('cocktail') ||
    x.includes('vlees') ||
    x.includes('pruim') ||
    x.includes('balkon') ||
    x.includes('snoeptomaat')
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
    x.includes('banana_peper')
  )
    return 'paprika';
  if (x.includes('aubergine')) return 'aubergine';
  if (
    x.includes('komkommer') ||
    x.includes('augurk') ||
    x.includes('cucamelon')
  )
    return 'komkommer';
  if (x.includes('courgette') || x.includes('patisson')) return 'courgette';
  if (x.includes('pompoen') || x.includes('hokkaido') || x.includes('butternut'))
    return 'pompoen';
  if (x.includes('meloen') || x.includes('watermeloen')) return 'meloen';
  if (
    x.includes('sla') ||
    x.includes('lollo') ||
    x.includes('eikenblad') ||
    x.includes('ijsberg') ||
    x.includes('kropsla')
  )
    return 'sla';
  if (
    x.includes('spinazie') ||
    x.includes('rucola') ||
    x.includes('tuinkers') ||
    x.includes('postelein') ||
    x.includes('waterkers') ||
    x.includes('veldsla') ||
    x.includes('tuinmelde') ||
    x.includes('andijvie') ||
    x.includes('snijbiet') ||
    x.includes('witlof')
  )
    return x.includes('andijvie') || x.includes('snijbiet') || x.includes('witlof')
      ? 'sla'
      : 'spinazie';
  if (x.includes('biet') || x.includes('chioggia')) return 'biet';
  if (
    x.includes('wortel') ||
    x.includes('peen') ||
    x.includes('pastinaak') ||
    x.includes('schorseneer') ||
    x.includes('peterseliewortel')
  )
    return x.includes('pastinaak') || x.includes('schorseneer')
      ? 'wortel'
      : 'wortel';
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
    x.includes('savooie')
  )
    return 'kool';
  if (x.includes('prei')) return 'prei';
  if (
    x.includes('ui') ||
    x.includes('bosui') ||
    x.includes('sint') ||
    x.includes('tree_onion')
  )
    return 'ui';
  if (
    x.includes('boon') ||
    x.includes('sperzie') ||
    x.includes('stokboon') ||
    x.includes('tuinboon') ||
    x.includes('sojaboon') ||
    x.includes('linzen') ||
    x.includes('kikkererwt')
  )
    return x.includes('tuinboon') ? 'erwt' : 'boon';
  if (x.includes('erwt') || x.includes('peul') || x.includes('sugar')) return 'erwt';
  if (x.includes('aardbei')) return 'aardbei';
  if (
    x.includes('appel') ||
    x.includes('peer') ||
    x.includes('pruim') ||
    x.includes('kers') ||
    x.includes('perzik') ||
    x.includes('abrikoos') ||
    x.includes('vijg') ||
    x.includes('druif') ||
    x.includes('kiwi') ||
    x.includes('duindoorn') ||
    x.includes('framboos') ||
    x.includes('braam') ||
    x.includes('bes') ||
    x.includes('blauwe') ||
    x.includes('cranberry')
  )
    return 'fruit_zaad';
  if (x.includes('aardpeer')) return 'meerjarig';
  if (
    x.includes('asperge') ||
    x.includes('artisjok') ||
    x.includes('rabarber') ||
    x.includes('meerjarig')
  )
    return 'meerjarig';
  if (
    x.includes('basilicum') ||
    x.includes('peterselie') ||
    x.includes('bieslook') ||
    x.includes('dille') ||
    x.includes('koriander') ||
    x.includes('munt') ||
    x.includes('tijm') ||
    x.includes('oregano') ||
    x.includes('salie') ||
    x.includes('rozemarijn') ||
    x.includes('dragon') ||
    x.includes('bonenkruid') ||
    x.includes('citroenmelisse') ||
    x.includes('kervel') ||
    x.includes('hysop') ||
    x.includes('lavas') ||
    x.includes('selderij') ||
    x.includes('venkel') ||
    x.includes('knol')
  )
    return x.includes('venkel') || x.includes('selderij') || x.includes('knol')
      ? 'kool'
      : 'kruid_zacht';
  // venkel/selderij better as specific - remap
  if (x.includes('venkel') || x.includes('selderij') || x.includes('knolraap'))
    return 'kool';
  return 'algemeen';
}

// Fix andijvie/snijbiet mapping - use sla-like cool crop with deeper notes
// Already partially handled

function blocks(sectionKey, p, name) {
  const d = p[sectionKey];
  return [
    { heading: 'Waarom dit advies?', body: d.why },
    { heading: 'Hoe doe je het?', body: d.how },
    { heading: 'Praktische tips', body: d.tip },
    {
      heading: 'Extra info',
      body: `Voor ${name}: combineer dit met de periode op de kaart en je lokale microklimaat (stad warmer, klei kouder). Twijfel je over jouw ras, check ook de zaaizak.`,
    },
  ];
}

function emitSection(title, summary, illustration, details, extra = {}) {
  const detailLit = details
    .map(
      (b) => `        SowingDetailBlock(
          heading: '${esc(b.heading)}',
          body: '${esc(b.body)}',
        )`,
    )
    .join(',\n');
  const when = extra.whenText
    ? `whenText: '${esc(extra.whenText)}',\n      `
    : '';
  const how = extra.howText
    ? `howText: '${esc(extra.howText)}',\n      `
    : '';
  const months =
    extra.sowMonths != null
      ? `sowMonths: ${setLit(extra.sowMonths)},\n      `
      : '';
  return `    PlantSowingGuideSection(
      title: '${title}',
      summary: '${esc(summary)}',
      ${when}${how}${months}illustration: PlantSowingIllustration.${illustration},
      details: [
${detailLit},
      ],
    )`;
}

function buildGuide(id, name) {
  let key = profileKeyFor(id);
  // refinements
  if (id.includes('venkel') || id.includes('selderij') || id.includes('knolselerij'))
    key = 'kool';
  if (id.includes('andijvie') || id.includes('snijbiet') || id.includes('bleekselderij_blad'))
    key = 'sla';
  if (id.includes('tuinboon')) key = 'erwt';

  const p = PROFILES[key] || PROFILES.algemeen;
  const ov = overview[id] || {};
  const sow = ov.sow || [];
  const plant = ov.plant || [];
  const indoorMonths = sow.length ? sow : null;
  const outdoorMonths = plant.length ? plant : sow.length ? sow : null;

  const indoorWhen = monthRange(indoorMonths) || p.indoorSummary;
  const outdoorWhen = monthRange(outdoorMonths) || p.outdoorSummary;

  const alerts = [];
  if (p.frost) {
    alerts.push(`    PlantSowingAlert(
      kind: PlantSowingAlertKind.frost,
      title: 'Vorstgevoelig',
      body: 'Jonge ${esc(name)}-planten verdragen geen vorst. Plant of zaai buiten pas na voldoende warmte (vaak na ijsheiligen).',
    )`);
  }
  if (p.note) {
    alerts.push(`    PlantSowingAlert(
      kind: PlantSowingAlertKind.info,
      title: 'Let op',
      body: '${esc(p.note)}',
    )`);
  }

  const sections = [
    emitSection(
      'Binnen zaaien',
      p.noSeed ? p.indoorSummary : `${indoorWhen}. ${p.indoorHow}`,
      'indoorTray',
      [
        { heading: 'Waarom dit advies?', body: p.indoorWhy },
        { heading: 'Hoe doe je het?', body: `${p.indoorHow} Periode (richtlijn NL): ${indoorWhen}.` },
        {
          heading: 'Praktische tips',
          body: p.noSeed
            ? p.note || 'Volg de vegetatieve methode in plaats van zaad.'
            : `Gebruik schone trays, verse zaaigrond en labels met ${name}. Zet na opkomst meteen lichter/koeler genoeg om langrekken te voorkomen.`,
        },
        {
          heading: 'Extra info',
          body: `De maanden komen uit de overzichtgegevens van ${name} waar beschikbaar. Microklimaat (kas, stad, klei) kan 1–3 weken schelen.`,
        },
      ],
      {
        whenText: indoorWhen,
        howText: p.indoorHow,
        sowMonths: indoorMonths,
      },
    ),
    emitSection(
      'Buiten zaaien',
      p.noSeed ? p.outdoorSummary : `${outdoorWhen}. ${p.outdoorHow}`,
      'outdoorSoil',
      [
        { heading: 'Waarom dit advies?', body: p.outdoorWhy },
        { heading: 'Hoe doe je het?', body: `${p.outdoorHow} Periode (richtlijn NL): ${outdoorWhen}.` },
        {
          heading: 'Praktische tips',
          body: 'Controleer bodemvocht en nachtvorst. Gebruik vliesdoek bij vroege teelten. Houd rijen vrij van onkruid tijdens kieming.',
        },
        {
          heading: 'Extra info',
          body: `Voor ${name} geldt: liever iets later zaaien in warme grond dan te vroeg in koude natte grond.`,
        },
      ],
      {
        whenText: outdoorWhen,
        howText: p.outdoorHow,
        sowMonths: outdoorMonths,
      },
    ),
    emitSection('Zaaidiepte', p.depthSummary, 'seedDepth', blocks('depth', p, name)),
    emitSection('Kiemduur', p.germDaysSummary, 'germinationTimeline', blocks('germ', p, name)),
    emitSection('Kiemtemperatuur', p.germTempSummary, 'temperatureRange', blocks('temp', p, name)),
    emitSection(
      'Licht tijdens kieming',
      p.lightSummary,
      'lightGermination',
      blocks('light', p, name),
    ),
    emitSection(
      'Water tijdens kieming',
      p.waterSummary,
      'waterGermination',
      blocks('water', p, name),
    ),
    emitSection('Verspenen', p.prickSummary, 'prickOut', blocks('prick', p, name)),
    emitSection('Oppotten', p.potSummary, 'potUp', blocks('pot', p, name)),
  ];

  return {
    key,
    note: p.note || null,
    noSeed: !!p.noSeed,
    dart: `  '${id}': PlantSowingGuide(
    sections: [
${sections.join(',\n')},
    ],
    alerts: [
${alerts.join(',\n')}
    ],
  )`,
  };
}

function prettyName(id) {
  return id
    .split('_')
    .map((w) => w.charAt(0).toUpperCase() + w.slice(1))
    .join(' ');
}

const entries = [];
const gaps = [];
const profileCounts = {};

for (const id of [...new Set(targetIds)]) {
  const name = prettyName(id);
  const built = buildGuide(id, name);
  entries.push(built.dart);
  profileCounts[built.key] = (profileCounts[built.key] || 0) + 1;
  if (built.key === 'algemeen') {
    gaps.push({
      id,
      profile: 'algemeen',
      reason:
        'Nog geen fijnmazig soortprofiel — algemene NL-richtlijnen. Lever bronnen aan voor okra/pepino/gember/tauge/kardoen e.d.',
    });
  } else if (built.noSeed || built.note) {
    gaps.push({
      id,
      profile: built.key,
      reason: built.note || 'Vegetatieve teelt / geen standaard zaadroute',
    });
  }
}

const out = `part of 'plant_sowing_guide.dart';

/// Gecureerde Zaaien-gidsen (samenvatting + detailblokken) voor groente/kruiden/peulvruchten/fruit
/// behalve bloemen en paddenstoelen. Gegenereerd via tool/generate_sowing_guides.mjs.
final Map<String, PlantSowingGuide> kPlantSowingGuides = {
${entries.join(',\n')},
};
`;

fs.writeFileSync('lib/data/plant_sowing_guide_entries.dart', out);
fs.writeFileSync(
  'tool/sowing_gaps_report.json',
  JSON.stringify({ count: gaps.length, profileCounts, gaps }, null, 2),
);
console.log(
  JSON.stringify(
    {
      written: entries.length,
      gaps: gaps.length,
      profileCounts,
    },
    null,
    2,
  ),
);