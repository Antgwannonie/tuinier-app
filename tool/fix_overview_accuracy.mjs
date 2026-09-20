import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const jsonPath = path.join(__dirname, 'vegetable_overview_all.json');
const j = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

const herb = (id, o) => {
  j[id] = {
    sow: o.sow ?? [],
    plant: o.plant ?? [],
    harvest: o.harvest,
    standplaats: o.standplaats,
    water: o.water,
    difficulty: o.difficulty ?? 'Makkelijk',
    lifespan: o.lifespan,
    outdoor: o.outdoor ?? 'Buiten',
    container: o.container ?? 'Pot / Bed',
    voeding: o.voeding ?? 'Laag',
    height: o.height,
    width: o.width,
    habit: o.habit,
    spacing: o.spacing,
    row: o.row ?? o.spacing,
    first: o.first,
    period: o.period,
    yield_level: o.yield_level ?? 'Gemiddelde opbrengst',
    yield_detail: o.yield_detail,
    points: o.points,
    summary: o.summary,
    know: o.know,
  };
};

// —— Accurate herbs ——
herb('basilicum', {
  sow: [3, 4],
  plant: [5, 6],
  harvest: [6, 7, 8, 9],
  standplaats: 'Zon',
  water: 'Gemiddeld',
  lifespan: 'Eenjarig',
  outdoor: 'Buiten / Pot',
  height: '20–40 cm',
  width: '20–30 cm',
  habit: 'Warmtegevoelig bladkruid',
  spacing: '20–25 cm',
  first: '±40–60 dagen na uitplanten',
  period: 'juni – september',
  yield_detail: 'Regelmatig toppen voor meer blad',
  points: ['Voorzaaien warm', 'Uitplanten na ijsheiligen', 'Niet laten bloeien voor blad', 'Vorstgevoelig'],
  summary:
    'Basilicum is een warmtegevoelig eenjarig keukenkruid. Zaai binnen in maart–april en plant pas na de ijsheiligen buiten of in een warme pot.',
  know: 'Onder 10 °C stopt de groei; haal potten bij kou naar binnen.',
});

herb('peterselie', {
  sow: [3, 4, 5, 6, 7],
  plant: [4, 5, 6],
  harvest: [5, 6, 7, 8, 9, 10, 11],
  standplaats: 'Halfschaduw',
  water: 'Gemiddeld',
  lifespan: 'Tweejarig',
  height: '20–40 cm',
  width: '20–30 cm',
  habit: 'Bladrozet; bloeit in jaar 2',
  spacing: '15–20 cm',
  first: '±60–90 dagen',
  period: 'mei – november',
  yield_detail: 'Doorzaaien houdt fris blad beschikbaar',
  points: ['Traag kiemen', 'Tweejarig', 'Halfschaduw oké', 'Regelmatig water'],
  summary:
    'Peterselie kiemt traag en is tweejarig: blad in jaar één, bloemstengel in jaar twee. Zaai vanaf maart en houd vochtig.',
  know: 'Week zaad een nacht in lauw water om kieming te versnellen.',
});

herb('dille', {
  sow: [3, 4, 5, 6, 7],
  plant: [],
  harvest: [5, 6, 7, 8, 9],
  standplaats: 'Zon',
  water: 'Laag',
  lifespan: 'Eenjarig',
  height: '60–120 cm',
  width: '20–30 cm',
  habit: 'Opgaand zaadkruid',
  spacing: '15–20 cm',
  first: '±40–60 dagen',
  period: 'mei – september',
  yield_detail: 'Blad jong, zaad later oogsten',
  points: ['Direct zaaien', 'Heeft diepe wortel', 'Trekt zweefvliegen', 'Doorzaaien'],
  summary:
    'Dille zaai je direct op vaste plek; verplanten lukt slecht. Oogst jong blad of laat uitgroeien voor zaadschermen.',
  know: 'Laat een paar planten uitbloeien: de schermen trekken nuttige insecten.',
});

herb('tijm', {
  sow: [3, 4],
  plant: [4, 5],
  harvest: [5, 6, 7, 8, 9, 10],
  standplaats: 'Zon',
  water: 'Laag',
  lifespan: 'Meerjarig',
  height: '10–25 cm',
  width: '20–40 cm',
  habit: 'Laag, houtig keukenkruid',
  spacing: '20–25 cm',
  first: 'vanaf 1e jaar',
  period: 'mei – oktober',
  yield_detail: 'Knip zachte scheuten; niet tot op oud hout',
  points: ['Droogtolerant', 'Scherpe drainage', 'Meerjarig', 'Zonnige plek'],
  summary:
    'Tijm is een droogtolerant, meerjarig kruid voor arme, doorlatende grond in volle zon.',
  know: 'Te natte wintergrond is funester dan vorst; plant op een verhoogde of zandige plek.',
});

herb('munt', {
  sow: [3, 4],
  plant: [4, 5, 9],
  harvest: [5, 6, 7, 8, 9, 10],
  standplaats: 'Halfschaduw',
  water: 'Hoog',
  lifespan: 'Meerjarig',
  outdoor: 'Buiten',
  container: 'Pot (aanbevolen)',
  height: '30–60 cm',
  width: '40–80 cm',
  habit: 'Kruipend, woekerend kruid',
  spacing: '30 cm',
  first: 'vanaf 1e jaar',
  period: 'mei – oktober',
  yield_level: 'Hoge opbrengst',
  yield_detail: 'Zeer productief; begrens wortels',
  points: ['Altijd in pot of bak', 'Vochtige grond', 'Winterhard', 'Woekert snel'],
  summary:
    'Munt is een winterhard, woekerend kruid dat van vochtige grond houdt. Plant altijd in pot of met wortelbarrière.',
  know: 'In open grond neemt munt snel het bed over; pot of emmer zonder bodemgat in de grond werkt goed.',
});

herb('pepermunt', {
  sow: [],
  plant: [4, 5, 9],
  harvest: [5, 6, 7, 8, 9, 10],
  standplaats: 'Halfschaduw',
  water: 'Hoog',
  lifespan: 'Meerjarig',
  container: 'Pot (aanbevolen)',
  height: '40–70 cm',
  width: '40–80 cm',
  habit: 'Kruipende pepermunt',
  spacing: '30 cm',
  first: 'vanaf 1e jaar',
  period: 'mei – oktober',
  yield_level: 'Hoge opbrengst',
  yield_detail: 'Sterke pepermuntgeur; begrens wortels',
  points: ['In pot houden', 'Vochtig houden', 'Winterhard', 'Sterke smaak'],
  summary:
    'Pepermunt is een sterke, winterharde muntsoort. Houd wortels begrensd en de grond vochtig.',
  know: 'Koop stekken of plantjes; pepermunt zaait meestal niet betrouwbaar uit zaad.',
});

herb('citroenmelisse', {
  sow: [3, 4],
  plant: [4, 5],
  harvest: [5, 6, 7, 8, 9],
  standplaats: 'Halfschaduw',
  water: 'Gemiddeld',
  lifespan: 'Meerjarig',
  height: '40–70 cm',
  width: '40–60 cm',
  habit: 'Bossig bladkruid',
  spacing: '30–40 cm',
  first: 'vanaf 1e jaar',
  period: 'mei – september',
  yield_detail: 'Knip vóór bloei voor mildste smaak',
  points: ['Citroengeur', 'Meerjarig', 'Zaait zich uit', 'Halfschaduw oké'],
  summary:
    'Citroenmelisse is meerjarig met frisse citroengeur. Knip regelmatig terug om woekeren en uitzaaien te beperken.',
  know: 'Verwijder bloemstengels als je geen zelfuitzaai wilt.',
});

herb('bieslook', {
  sow: [3, 4, 5],
  plant: [3, 4, 5, 9],
  harvest: [4, 5, 6, 7, 8, 9, 10],
  standplaats: 'Zon',
  water: 'Gemiddeld',
  lifespan: 'Meerjarig',
  height: '20–40 cm',
  width: '15–25 cm',
  habit: 'Polvormige ui-achtige grassprieten',
  spacing: '15–20 cm',
  first: 'vanaf 1e jaar',
  period: 'april – oktober',
  yield_level: 'Hoge opbrengst',
  yield_detail: 'Knip boven de bol; blijft terugkomen',
  points: ['Meerjarig', 'Makkelijk', 'Eetbare bloemen', 'Potgeschikt'],
  summary:
    'Bieslook is een makkelijk meerjarig kruid. Knip de blaadjes boven de basis en laat de plant in het voorjaar bloeien voor bijen.',
  know: 'Deel dichte pollen om de paar jaar voor frissere groei.',
});

herb('koriander', {
  sow: [3, 4, 5, 8, 9],
  plant: [],
  harvest: [4, 5, 6, 9, 10],
  standplaats: 'Halfschaduw',
  water: 'Gemiddeld',
  lifespan: 'Eenjarig',
  height: '30–60 cm',
  width: '15–25 cm',
  habit: 'Snel doorschietend bladkruid',
  spacing: '10–15 cm',
  first: '±30–45 dagen',
  period: 'april – juni en september – oktober',
  yield_detail: 'Doorzaaien; zomerhitte geeft snel zaad',
  points: ['Doorzaaien', 'Schiet snel door', 'Koel weer beter', 'Direct zaaien'],
  summary:
    'Koriander houdt van koel weer en schiet in de zomer snel door. Zaai vaak klein beetje bij voor blad of laat rijpen voor zaad.',
  know: 'In warme periodes halfschaduw kiezen voor langer blad.',
});

herb('salie', {
  sow: [3, 4],
  plant: [4, 5],
  harvest: [5, 6, 7, 8, 9, 10],
  standplaats: 'Zon',
  water: 'Laag',
  difficulty: 'Makkelijk',
  lifespan: 'Meerjarig',
  height: '40–60 cm',
  width: '40–60 cm',
  habit: 'Houtig keukenkruid',
  spacing: '35–40 cm',
  first: 'vanaf 1e jaar',
  period: 'mei – oktober',
  yield_detail: 'Knip zachte toppen; niet tot op oud hout',
  points: ['Meerjarig', 'Doorlatende grond', 'Zonrijk', 'Snoei na bloei'],
  summary:
    'Salie is een meerjarig, aromatisch kruid voor zonnige, droge plekken. Snoei na de bloei licht terug.',
  know: 'Oudere planten worden houtig; stek jonge scheuten om te verjongen.',
});

herb('oregano', {
  sow: [3, 4],
  plant: [4, 5],
  harvest: [6, 7, 8, 9],
  standplaats: 'Zon',
  water: 'Laag',
  lifespan: 'Meerjarig',
  height: '30–50 cm',
  width: '30–50 cm',
  habit: 'Bossig, geurend kruid',
  spacing: '25–30 cm',
  first: 'vanaf 1e jaar',
  period: 'juni – september',
  yield_detail: 'Smaak sterkst net vóór bloei',
  points: ['Droogtolerant', 'Meerjarig', 'Pizza-kruid', 'Zonrijk'],
  summary:
    'Oregano is een droogtolerant, meerjarig keukenkruid. Oogst net vóór de bloei voor de sterkste smaak.',
  know: 'Griekse oregano is sterker van smaak dan wilde marjolein.',
});

herb('rozemarijn', {
  sow: [2, 3],
  plant: [5, 6],
  harvest: [5, 6, 7, 8, 9, 10],
  standplaats: 'Zon',
  water: 'Laag',
  difficulty: 'Gemiddeld',
  lifespan: 'Meerjarig',
  outdoor: 'Buiten / Kuip',
  height: '50–100 cm',
  width: '40–60 cm',
  habit: 'Houtige mediterrane struik',
  spacing: '40–50 cm',
  first: 'vanaf 1e jaar',
  period: 'mei – oktober',
  yield_detail: 'Knip zachte scheuten; nooit tot kaal hout',
  points: ['Scherpe drainage', 'Beschutte plek', 'Kuip mogelijk', 'Natte winters riskant'],
  summary:
    'Rozemarijn is mediterraan en houdt van zon en droge voeten. In NL plant je het best na de vorst op een beschutte, doorlatende plek of in kuip.',
  know: 'Natte kleigrond in de winter doodt meer planten dan vorst alleen.',
});

herb('dragon', {
  sow: [],
  plant: [4, 5],
  harvest: [5, 6, 7, 8, 9],
  standplaats: 'Zon',
  water: 'Gemiddeld',
  lifespan: 'Meerjarig',
  height: '40–70 cm',
  width: '30–40 cm',
  habit: 'Franse dragon (stek)',
  spacing: '30 cm',
  first: 'vanaf 1e jaar',
  period: 'mei – september',
  yield_detail: 'Alleen Franse dragon stekken; Russische is grover',
  points: ['Stekken gebruiken', 'Meerjarig', 'Anijsachtige smaak', 'Beschutte plek'],
  summary:
    'Franse dragon vermeerder je via stekken, niet via zaad. Plant in zon en oogst jonge toppen.',
  know: 'Zaad van “dragon” is vaak Russische dragon met mindere smaak.',
});

herb('estragon', {
  sow: [],
  plant: [4, 5],
  harvest: [5, 6, 7, 8, 9],
  standplaats: 'Zon',
  water: 'Gemiddeld',
  lifespan: 'Meerjarig',
  height: '40–70 cm',
  width: '30–40 cm',
  habit: 'Synoniem voor dragon',
  spacing: '30 cm',
  first: 'vanaf 1e jaar',
  period: 'mei – september',
  yield_detail: 'Zelfde teelt als Franse dragon',
  points: ['Stekken', 'Meerjarig', 'Keukenkruid', 'Zonnige plek'],
  summary:
    'Estragon (dragon) is een meerjarig keukenkruid. Gebruik stekken van Franse dragon voor de beste smaak.',
  know: 'Deel pollen in het voorjaar om planten jong te houden.',
});

herb('majoraan', {
  sow: [3, 4],
  plant: [5, 6],
  harvest: [7, 8, 9],
  standplaats: 'Zon',
  water: 'Laag',
  lifespan: 'Eenjarig',
  height: '20–40 cm',
  width: '20–30 cm',
  habit: 'Zomerkruid (zoete marjolein)',
  spacing: '20 cm',
  first: '±60–80 dagen',
  period: 'juli – september',
  yield_detail: 'Oogst vóór bloei; vorstgevoelig',
  points: ['Voorzaaien', 'Na ijsheiligen buiten', 'Milder dan oregano', 'Eenjarig in NL'],
  summary:
    'Majoraan is in NL meestal eenjarig en vorstgevoelig. Voorzaaien en na mid-mei uitplanten geeft de beste oogst.',
  know: 'Oogst net vóór de bloei en droog takjes voor wintergebruik.',
});

herb('kervel', {
  sow: [3, 4, 8, 9],
  plant: [],
  harvest: [4, 5, 6, 9, 10],
  standplaats: 'Halfschaduw',
  water: 'Hoog',
  lifespan: 'Eenjarig',
  height: '30–50 cm',
  width: '15–25 cm',
  habit: 'Fijn bladkruid voor koel weer',
  spacing: '10–15 cm',
  first: '±40–50 dagen',
  period: 'april – juni en september – oktober',
  yield_detail: 'Doorzaaien in koel seizoen',
  points: ['Koel weer', 'Halfschaduw', 'Snel doorschieten in hitte', 'Direct zaaien'],
  summary:
    'Kervel groeit het best in koel voor- en najaar. In de zomerhitte schiet het snel door.',
  know: 'Zaai in de schaduw van hogere gewassen voor langer mals blad.',
});

herb('kamille', {
  sow: [3, 4, 5, 8],
  plant: [],
  harvest: [6, 7, 8, 9],
  standplaats: 'Zon',
  water: 'Laag',
  lifespan: 'Eenjarig',
  height: '30–50 cm',
  width: '20–30 cm',
  habit: 'Echte kamille voor thee',
  spacing: '15–20 cm',
  first: '±60–80 dagen',
  period: 'juni – september',
  yield_detail: 'Pluk open bloemen voor thee',
  points: ['Direct zaaien', 'Arme grond oké', 'Zelf uitzaaien', 'Theebloemen'],
  summary:
    'Echte kamille zaai je licht op zonnige, niet te rijke grond. Pluk open bloemen voor thee.',
  know: 'Zaai oppervlakkig; licht is nodig voor kieming.',
});

herb('bonenkruid', {
  sow: [4, 5],
  plant: [5, 6],
  harvest: [7, 8, 9],
  standplaats: 'Zon',
  water: 'Laag',
  lifespan: 'Eenjarig',
  height: '20–40 cm',
  width: '15–25 cm',
  habit: 'Zomerbonenkruid',
  spacing: '15–20 cm',
  first: '±50–70 dagen',
  period: 'juli – september',
  yield_detail: 'Klassiek bij bonen; droogbaar',
  points: ['Bij bonen zaaien', 'Droogtolerant', 'Eenjarig', 'Zonnig'],
  summary:
    'Zomerbonenkruid is een eenjarig, peperachtig kruid dat klassiek bij bonen wordt gezaaid.',
  know: 'Winterbonenkruid is meerjarig en houtiger; dit profiel is voor zomerbonenkruid.',
});

herb('anijs_kruid', {
  sow: [4, 5],
  plant: [],
  harvest: [8, 9],
  standplaats: 'Zon',
  water: 'Laag',
  difficulty: 'Gemiddeld',
  lifespan: 'Eenjarig',
  height: '40–60 cm',
  width: '20–30 cm',
  habit: 'Zaadkruid met schermen',
  spacing: '20 cm',
  first: '±100–120 dagen',
  period: 'augustus – september',
  yield_detail: 'Vooral zaad oogsten',
  points: ['Warmte nodig', 'Direct zaaien', 'Niet verplanten', 'Zaad drogen'],
  summary:
    'Anijs vraagt warmte en een lang seizoen. Zaai direct en oogst rijpe zaden in nazomer.',
  know: 'In koele zomers blijft de zaadopbrengst beperkt.',
});

herb('kerrieblad', {
  sow: [],
  plant: [5, 6],
  harvest: [6, 7, 8, 9],
  standplaats: 'Zon',
  water: 'Gemiddeld',
  difficulty: 'Moeilijk',
  lifespan: 'Meerjarig',
  outdoor: 'Kas / kuip',
  container: 'Kuip',
  height: '50–150 cm',
  width: '40–60 cm',
  habit: 'Tropische kuipplant',
  spacing: '40 cm',
  first: 'doorlopend blad',
  period: 'juni – september (kuip)',
  yield_detail: 'Vers blad; vorstvrij overwinteren',
  points: ['Niet winterhard', 'Kuip/kas', 'Binnen overwinteren', 'Vers blad gebruiken'],
  summary:
    'Echt kerrieblad (Murraya) is een tropische kuipplant. In NL alleen buiten in warme maanden; vorstvrij overwinteren.',
  know: 'Verwar niet met “kerrieplant” (Helichrysum), die alleen naar kerrie ruikt.',
});

herb('tuinkruid', {
  sow: [3, 4, 5],
  plant: [4, 5],
  harvest: [5, 6, 7, 8, 9],
  standplaats: 'Zon',
  water: 'Gemiddeld',
  lifespan: 'Eenjarig',
  height: '20–40 cm',
  width: '15–25 cm',
  habit: 'Gemengd of basis keukenkruid',
  spacing: '15–20 cm',
  first: '±40–60 dagen',
  period: 'mei – september',
  yield_detail: 'Afhankelijk van het gekozen ras/mengsel',
  points: ['Zonnige plek', 'Regelmatig oogsten', 'Pot of bed', 'Doorzaaien mogelijk'],
  summary:
    'Tuinkruid dekt aromatische keukenkruiden voor pot of bed. Kies zon, goede drainage en oogst regelmatig.',
  know: 'Controleer op de verpakking welk ras of mengsel je hebt voor precieze teelt.',
});

herb('gember', {
  sow: [],
  plant: [4, 5],
  harvest: [9, 10, 11],
  standplaats: 'Halfschaduw',
  water: 'Hoog',
  difficulty: 'Gemiddeld',
  lifespan: 'Eenjarig',
  outdoor: 'Kas / binnen',
  container: 'Grote pot',
  height: '60–100 cm',
  width: '30–40 cm',
  habit: 'Tropische wortelstok',
  spacing: '20–30 cm',
  first: '±6–8 maanden',
  period: 'september – november',
  yield_detail: 'Jonge gember of volle wortelstok',
  points: ['Warmte nodig', 'Vochtig houden', 'Pot/kas', 'Lange teelt'],
  summary:
    'Gember teel je uit een wortelstok in warme, vochtige omstandigheden. In NL vooral in kas of binnen.',
  know: 'Start met biologische gember; behandelde knollen kiemen slechter.',
});

herb('citroengras', {
  sow: [],
  plant: [5, 6],
  harvest: [7, 8, 9, 10],
  standplaats: 'Zon',
  water: 'Hoog',
  difficulty: 'Gemiddeld',
  lifespan: 'Meerjarig',
  outdoor: 'Kas / kuip',
  container: 'Kuip',
  height: '80–120 cm',
  width: '40–60 cm',
  habit: 'Tropisch polgras',
  spacing: '40 cm',
  first: '±3–4 maanden',
  period: 'juli – oktober',
  yield_detail: 'Stengels snijden; vorstvrij overwinteren',
  points: ['Niet winterhard', 'Veel water in groei', 'Kuip', 'Binnen overwinteren'],
  summary:
    'Citroengras is een tropische kuipplant. Buiten alleen in de warme maanden; ’s winters vorstvrij houden.',
  know: 'Wortel een verse stengel uit de winkel in water als startmateriaal.',
});

// —— Other veg fixes ——
j.zoete_aardappel.plant = [6];
j.zoete_aardappel.points = [
  'Veel warmte',
  'Pas in juni planten',
  'Lange teelt',
  'Voorzichtig oogsten',
];

j.pinda.outdoor = 'Kas / kuip';
j.pinda.container = 'Kas / grote bak';
j.pinda.summary =
  'Pinda vraagt een lang, warm seizoen. In NL vooral kansrijk in kas of op een zeer warme, beschutte plek.';

j.framboos.summary =
  'Framboos is meerjarig: zomerframboos draagt op tweejarige stokken, herfstframboos op eenjarige scheuten. Snoei passend bij het type.';

fs.writeFileSync(jsonPath, JSON.stringify(j, null, 2) + '\n');
console.log('JSON herbs + veg fixes written');
