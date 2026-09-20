import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const jsonPath = path.join(__dirname, 'vegetable_overview_all.json');
const j = JSON.parse(fs.readFileSync(jsonPath, 'utf8'));

const set = (id, patch) => {
  if (!j[id]) throw new Error('missing ' + id);
  Object.assign(j[id], patch);
};

// —— Fruit trees / nuts ——
const fruit = {
  appel: {
    yield_detail: 'Na 2–4 jaar 10–30 kg per boom, afhankelijk van ras en snoei',
    points: ['Geënt plantgoed', 'Bestuiver-ras nodig', 'Wintersnoei', 'Oogst september–oktober'],
  },
  peer: {
    yield_detail: 'Na vestiging 15–40 kg per boom; bewaart beter dan appel',
    points: ['Bestuiver kiezen', 'Zonnige plek', 'Wintersnoei', 'Oogst najaar'],
  },
  kers: {
    yield_detail: 'Zoete kersen in juni–juli; netten tegen vogels nodig',
    points: ['Vroege bloei', 'Beschutting', 'Vogelnet', 'Zonnige plek'],
  },
  zure_kers: {
    yield_detail: 'Zure kersen voor jam/sap; vaak zelfbestuivend',
    points: ['Zelfbestuivend vaak', 'Jam en sap', 'Vroege zomer', 'Minder zoet'],
  },
  kriek: {
    yield_detail: 'Kleine zure kersen; ideaal voor likeur en confituur',
    points: ['Zure smaak', 'Vroege oogst', 'Jam/likeur', 'Meerjarig'],
  },
  pruim: {
    yield_detail: 'Zoete pruimen in augustus–september; rassen verschillen sterk',
    points: ['Ruime standplaats', 'Late zomer', 'Bestuiver checken', 'Snoei licht'],
  },
  mirabel: {
    yield_detail: 'Veel kleine gele pruimpjes; uitstekend voor jam',
    points: ['Kleine vruchten', 'Jam', 'Nazomer', 'Productief'],
  },
  perzik: {
    yield_detail: 'Beperkte oogst in NL; leiboom op zuidmuur werkt het best',
    points: ['Vroege bloei', 'Zuidmuur', 'Beschermen', 'Warm ras'],
  },
  nectarine: {
    yield_detail: 'Gladde perzikachtige vruchten; warme muur of kas nodig',
    points: ['Warmte', 'Gladde schil', 'Beschut', 'Vorstgevoelige bloesem'],
  },
  abrikoos: {
    yield_detail: 'Weinig betrouwbaar buiten; beste kans op warme muur',
    points: ['Vorstgevoelige bloesem', 'Warm en beschut', 'Kleine oogst', 'Kas helpt'],
  },
  vijg: {
    yield_detail: '1–2 kg per plant in warme zomer; winterbescherming nodig',
    points: ['Zuidmuur of kas', 'Winter beschermen', 'Droogte oké', 'Nazomer oogst'],
  },
  kweepeer: {
    yield_detail: 'Hard aromatisch fruit voor gelei; oogst oktober',
    points: ['Hard fruit', 'Gelei/jam', 'Najaar', 'Weinig snoei'],
  },
  mispel: {
    yield_detail: 'Kleine vruchten na vorst eetbaar; 1 boom volstaat vaak',
    points: ['Na vorst oogsten', 'Oud ras', 'Weinig zorg', 'Herfstfruit'],
  },
  nashi_peer: {
    yield_detail: 'Knapperige Aziatische peren; 5–15 kg na vestiging',
    points: ['Knapperige peer', 'Bestuiver checken', 'Herfst', 'Zonnig'],
  },
  kaki: {
    yield_detail: 'In NL vaak kozfruit; 5–20 vruchten per kuipplant mogelijk',
    points: ['Warmte nodig', 'Kuip of kas', 'Narijpen', 'Herfst'],
  },
  walnoot: {
    yield_detail: 'Na 6–10 jaar noten; één grote boom kan tientallen kg geven',
    points: ['Grote boom', 'Geduld', 'Oktober oogst', 'Diepe grond'],
  },
  hazelnoot: {
    yield_detail: 'Meerdere struiken voor bestuiving; 2–5 kg per struik',
    points: ['Meerdere rassen', 'Struikvorm', 'Herfstnoten', 'Windbestuiving'],
  },
  kastanje_boom: {
    yield_detail: 'Na jaren eetbare kastanjes; grote boom nodig',
    points: ['Grote tuin', 'Lange termijn', 'Oktober', 'Twee bomen beter'],
  },
  druif: {
    yield_detail: 'Na 2–3 jaar trossen; 5–15 kg per rank bij goede snoei',
    points: ['Wintersnoei', 'Zonnige muur', 'Nazomer', 'Ranken leiden'],
  },
  kiwi: {
    yield_detail: 'Mannelijke + vrouwelijke plant; 5–20 kg per vrouwelijke rank',
    points: ['Man én vrouw', 'Klimrek', 'Herfst', 'Beschut'],
  },
  citroenboom: {
    yield_detail: 'Enkele tot tientallen citroenen per kuipplant per jaar',
    points: ['Kuip/kas', 'Vorstvrij overwinteren', 'Zuur fruit', 'Jaarrond sier'],
  },
  limoen: {
    yield_detail: 'Kleine groene limoenen; beperkte oogst in kuip',
    points: ['Kuipplant', 'Warmte', 'Binnen overwinteren', 'Zure smaak'],
  },
  mandarijn: {
    yield_detail: 'Kleine zoete vruchten; typisch 10–40 stuks per kuip',
    points: ['Kuip/kas', 'Zoete kleine citrus', 'Overwinteren binnen', 'Zonnig'],
  },
  mango: {
    yield_detail: 'Vruchten zelden in NL; vooral sierlijke kuipplant',
    points: ['Kas/kuip', 'Tropisch', 'Zelden vrucht', 'Veel warmte'],
  },
  avocado: {
    yield_detail: 'Vruchten zeer zelden; vooral bladplant in kuip',
    points: ['Kuip/kas', 'Decoratief', 'Zelden vrucht', 'Vorstvrij'],
  },
  granaatappel: {
    yield_detail: 'Sierlijke bloei; vruchten alleen in zeer warme zomer/kas',
    points: ['Kuip', 'Oranje bloei', 'Warmte', 'Zelden rijp fruit'],
  },
};
for (const [id, p] of Object.entries(fruit)) set(id, p);

// —— Pepers ——
const pepe = {
  peper: {
    yield_detail: '5–15 peulen per plant; zoet of mild-heet afhankelijk van ras',
    points: ['Voorzaaien vroeg', 'Warmte', 'Kas helpt', 'Steun bij belading'],
  },
  cayenne_peper: {
    yield_detail: '20–40 slanke hete peulen; ideaal om te drogen',
    points: ['Heet', 'Drogen', 'Warmte', 'Rood rijp oogsten'],
  },
  chilipeper: {
    yield_detail: '10–30 hete peulen; scherpte stijgt bij volle rijpheid',
    points: ['Warmte', 'Steun', 'Handschoenen', 'Kas of warme muur'],
  },
  jalapeno: {
    yield_detail: '15–30 middelhete peulen; groen of rood oogsten',
    points: ['Middelheet', 'Productief', 'Kas/pot', 'Regelmatig plukken'],
  },
  habanero: {
    yield_detail: '10–20 zeer hete peulen; alleen in warme kas betrouwbaar',
    points: ['Zeer heet', 'Kas nodig', 'Handschoenen', 'Lang seizoen'],
  },
  serrano_peper: {
    yield_detail: '20–40 slanke peulen; iets heter dan jalapeño',
    points: ['Slank fruit', 'Heet', 'Warmte', 'Vaak oogsten'],
  },
  galapeno_peper: {
    yield_detail: '15–25 jalapeño-achtige peulen per plant',
    points: ['Warmte', 'Pot mogelijk', 'Productief', 'Groen of rood'],
  },
  thaise_peper: {
    yield_detail: '30–60 kleine scherpe peulen; compacte plant',
    points: ['Klein en scherp', 'Potgeschikt', 'Warmte', 'Productief'],
  },
  poblano_peper: {
    yield_detail: '8–15 grote milde peulen; gedroogd = ancho',
    points: ['Grote peul', 'Mild-heet', 'Warmte', 'Vullen/grillen'],
  },
  padron_peper: {
    yield_detail: '30–50 mini-pepers; oogst bij 3–5 cm voor milde tapa',
    points: ['Jong oogsten', 'Meestal mild', 'Grill', 'Productief'],
  },
  tabasco_peper: {
    yield_detail: '40–80 kleine peulen voor saus; rood laten rijpen',
    points: ['Sauspeper', 'Klein fruit', 'Warmte', 'Heet'],
  },
  peperoncini: {
    yield_detail: '15–25 milde peulen; klassiek om in te leggen',
    points: ['Mild', 'Inleggen', 'Warmte', 'Vroege oogst'],
  },
  banana_peper: {
    yield_detail: '10–20 milde zoetzure peulen; vroeg productief',
    points: ['Mild', 'Vroeg', 'Vullen/grillen', 'Warmte'],
  },
  rode_paprika: {
    yield_detail: '6–12 blokpaprika’s; rood rijp is zoeter',
    points: ['Lang voorzaaien', 'Kas helpt', 'Rood laten rijpen', 'Steun'],
  },
  gele_paprika: {
    yield_detail: '6–12 gele blokpaprika’s; vaak iets vroeger dan rood',
    points: ['Warmte', 'Geel rijp', 'Kas/balkon', 'Steun'],
  },
  oranje_paprika: {
    yield_detail: '6–10 oranje blokpaprika’s; mild zoet',
    points: ['Warmte', 'Oranje rijp', 'Kas helpt', 'Steun'],
  },
  puntpaprika: {
    yield_detail: '8–15 langwerpige zoete paprika’s; goed voor oven',
    points: ['Zoet', 'Vroeger dan blok', 'Warmte', 'Grillen'],
  },
  snack_paprika: {
    yield_detail: '20–40 mini-snackpaprika’s per plant',
    points: ['Klein fruit', 'Productief', 'Pot mogelijk', 'Vaak plukken'],
  },
};
for (const [id, p] of Object.entries(pepe)) set(id, p);

// —— Bonen & erwten ——
const beans = {
  bonen_sperzie: {
    yield_detail: '0,5–1,5 kg groene peulen per meter rij bij vaak plukken',
    points: ['Na ijsheiligen', 'Jong oogsten', 'Vaak plukken', 'Vorstgevoelig'],
  },
  haricots_verts: {
    yield_detail: 'Dunne peulen; 0,4–1 kg per meter bij regelmatig plukken',
    points: ['Dunne peul', 'Na vorst zaaien', 'Vaak oogsten', 'Warmte'],
  },
  snijbonen: {
    yield_detail: 'Brede peulen aan stok; 1–2 kg per plant bij goede groei',
    points: ['Stokken nodig', 'Na ijsheiligen', 'Brede peul', 'Klimmend'],
  },
  snijboon_geel: {
    yield_detail: 'Gele snijbonen; vergelijkbare oogst als groene stokboon',
    points: ['Gele peul', 'Stokken', 'Warmte', 'Vaak plukken'],
  },
  doperwt: {
    yield_detail: 'Vroege peulen; 0,3–0,8 kg doperwten per meter',
    points: ['Vroeg zaaien', 'Koel weer', 'Klimsteun', 'Voor warme juni'],
  },
  tuinerwt: {
    yield_detail: 'Klassieke groene erwten; 0,3–0,7 kg per meter rij',
    points: ['Vroege zaai', 'Steun', 'Koel', 'Peul openen'],
  },
  peultjes: {
    yield_detail: 'Platte peulen heel eten; 0,4–1 kg per meter',
    points: ['Vroeg', 'Hele peul', 'Steun', 'Jong plukken'],
  },
  sugarsnaps: {
    yield_detail: 'Dikke zoete peulen; 0,5–1 kg per meter bij vaak oogsten',
    points: ['Eetbare peul', 'Klimrek', 'Vroeg zaaien', 'Zoet'],
  },
  tuinboon: {
    yield_detail: 'Vroege peulen; 0,5–1 kg per meter, top na eerste zetting',
    points: ['Zeer vroeg', 'Toppen', 'Bladluis opletten', 'Koel weer'],
  },
  kapucijner: {
    yield_detail: 'Paarse bloemen + peulen; oogst jong of als droge boon',
    points: ['Sierlijk', 'Vroege teelt', 'Vers of droog', 'Toppen'],
  },
  bruine_boon: {
    yield_detail: 'Droge bruine bonen; 100–250 g gedroogd per m²',
    points: ['Droog oogsten', 'Vroeg zaaien', 'Drogen', 'Bewaren'],
  },
  witte_boon: {
    yield_detail: 'Droge witte bonen; 100–250 g gedroogd per m²',
    points: ['Droge boon', 'Vroege teelt', 'Goed drogen', 'Voorraad'],
  },
  kikkererwt: {
    yield_detail: 'Beperkt in NL; enkele peulen per plant in warme zomer',
    points: ['Warmte', 'Droog oogsten', 'Lange teelt', 'Moeilijk buiten'],
  },
  sojaboon: {
    yield_detail: 'Edamame: 0,3–0,8 kg groene peulen per m² bij warm weer',
    points: ['Warm zaaien', 'Groen oogsten', 'Korte peul', 'Kas helpt'],
  },
  tuin_linzen: {
    yield_detail: 'Kleine droge linzen; 50–150 g per m² na drogen',
    points: ['Vroege zaai', 'Droog oogsten', 'Lage plant', 'Arme grond oké'],
  },
  pinda: {
    yield_detail: 'Enkele peulen per plant in kas; buiten vaak teleurstellend',
    points: ['Kas/kuip', 'Lange warme teelt', 'Losse grond', 'Moeilijk in NL'],
  },
};
for (const [id, p] of Object.entries(beans)) set(id, p);

// —— Bessen ——
const berries = {
  framboos: {
    yield_detail: '1–2 kg per meter rij na vestiging (zomer- of herfsttype)',
    points: ['Zomer of herfst type', 'Steunlatten', 'Snoei passend', 'Meerjarig'],
  },
  braam: {
    yield_detail: '2–4 kg per plant bij goede snoei en steun',
    points: ['Late zomer', 'Stevige steun', 'Doornloos ras mogelijk', 'Snoei oud hout'],
  },
  blauwe_bes: {
    yield_detail: '1–3 kg per struik op zure grond (pH 4–5,5)',
    points: ['Zure grond', 'Net tegen vogels', 'Meerjarig', 'Pot met veengrond'],
  },
  rode_bes: {
    yield_detail: '2–4 kg per struik; goed voor gelei en sap',
    points: ['Koel klimaat oké', 'Snoei oud hout', 'Vogels', 'Zomer oogst'],
  },
  zwarte_bes: {
    yield_detail: '2–5 kg cassis per struik; sterk aromatisch',
    points: ['Sterke geur', 'Jam/sap', 'Snoei', 'Zonnig tot half'],
  },
  jostabes: {
    yield_detail: '2–4 kg grote bessen per struik; kruising bes × kruisbes',
    points: ['Grote bessen', 'Weinig doorns', 'Meerjarig', 'Zomer'],
  },
  vlierbes: {
    yield_detail: 'Bloesem in juni + bessen in nazomer voor siroop',
    points: ['Bloesem én bes', 'Siroop', 'Grote struik', 'Weinig zorg'],
  },
  duindoorn: {
    yield_detail: 'Oranje bessen rijk aan vitamine C; man + vrouw nodig',
    points: ['Man en vrouw', 'Zure bessen', 'Zandgrond oké', 'Herfst'],
  },
  veenbes: {
    yield_detail: 'Lage oogst in pot; 200–600 g per m² op zure natte grond',
    points: ['Zure grond', 'Vochtig', 'Laagblijvend', 'Pot mogelijk'],
  },
  physalis: {
    yield_detail: '20–60 zoete bessen in hulsjes per plant in kas',
    points: ['Warmte/kas', 'Papieren huls', 'Nazomer', 'Zoet fruit'],
  },
};
for (const [id, p] of Object.entries(berries)) set(id, p);

// —— Aziatisch blad ——
const asia = {
  mizuna: {
    yield_detail: 'Babyleaf in 25–40 dagen; meerdere snedes per zaaisel',
    points: ['Snel', 'Koel weer', 'Salade', 'Doorzaaien'],
  },
  tatsoi: {
    yield_detail: 'Rozetten van 15–25 cm; 1 krop of blad voor blad',
    points: ['Platte rozet', 'Koel', 'Najaar goed', 'Mild blad'],
  },
  komatsuna: {
    yield_detail: 'Snel blad; 30–50 dagen tot volle planten',
    points: ['Japanse mosterd', 'Snel', 'Koel', 'Wok/salade'],
  },
  mosterdgroen: {
    yield_detail: 'Pittig blad; oogst jong voor mildere smaak',
    points: ['Pittig', 'Snel', 'Koel seizoen', 'Doorzaaien'],
  },
};
for (const [id, p] of Object.entries(asia)) set(id, p);

// —— Bieten ——
set('witte_biet', {
  yield_detail: 'Milde witte knollen; 1 knol per plant na dunnen',
  points: ['Direct zaaien', 'Dunnen', 'Milde smaak', 'Zomer–najaar'],
});
set('rode_biet', {
  yield_detail: '1 rode knol per plant; 5–10 knollen per meter rij',
  points: ['Direct zaaien', 'Dunnen op tijd', 'Blad ook eetbaar', 'Beginnersvriendelijk'],
});

fs.writeFileSync(jsonPath, JSON.stringify(j, null, 2) + '\n');

// verify remaining yield_detail dups
const by = {};
for (const [id, o] of Object.entries(j)) {
  (by[o.yield_detail] ||= []).push(id);
}
const left = Object.entries(by).filter(([, ids]) => ids.length >= 2);
console.log('Remaining shared yield_detail groups:', left.length);
for (const [t, ids] of left.sort((a, b) => b[1].length - a[1].length).slice(0, 20)) {
  console.log(ids.length, ids.join(', '), '|', t.slice(0, 70));
}
