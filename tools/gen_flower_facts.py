#!/usr/bin/env python3
"""Generate flower_overview_facts_map.dart."""

OUT = r"C:\Users\frede\tuinier_app\lib\data\flower_overview_facts_map.dart"

BEE = "assets/images/bloom/bloom_pollinator_bee.png"
BUT = "assets/images/bloom/bloom_pollinator_butterfly.png"
PEST = "assets/images/combination/combo_pest_plants.png"
BEN = "assets/images/combination/combo_benefits.png"
HAR = "assets/images/harvest/harvest_basket.png"
SOIL = "assets/images/combination/combo_soil_improvers.png"


def why(r1, r2, r3, r4):
    out = ["    whyPlantReasons: ["]
    for asset, label in (r1, r2, r3, r4):
        out += [
            "      FlowerWhyPlantReason(",
            f"        imageAsset: '{asset}',",
            f"        label: '{label}',",
            "      ),",
        ]
    out.append("    ],")
    return "\n".join(out)


def cal(sow_label, sow, plant, bloom, seed="{9, 10}", plant_out=True):
    out = ["    calendarMoments: ["]
    out += [
        "      FlowerCalendarMoment(",
        "        timeline: PlantMonthTimeline(",
        f"          label: '{sow_label}',",
        f"          months: {sow},",
        "        ),",
        "        accentColor: Color(0xFF43A047),",
        "        imageAsset: 'assets/images/plant_info_tabs/tab_zaaien.png',",
        "      ),",
    ]
    if plant_out:
        out += [
            "      FlowerCalendarMoment(",
            f"        timeline: PlantMonthTimeline(label: 'Uitplanten', months: {plant}),",
            "        accentColor: Color(0xFF2E7D32),",
            "        imageAsset: 'assets/images/plant_info_tabs/tab_uitplanten.png',",
            "      ),",
        ]
    out += [
        "      FlowerCalendarMoment(",
        f"        timeline: PlantMonthTimeline(label: 'Bloei', months: {bloom}),",
        "        accentColor: Color(0xFF7B1FA2),",
        "        imageAsset: 'assets/images/plant_info_tabs/tab_bloei.png',",
        "      ),",
        "      FlowerCalendarMoment(",
        f"        timeline: PlantMonthTimeline(label: 'Zaadoogst', months: {seed}),",
        "        accentColor: Color(0xFFF57C00),",
        "        imageAsset: 'assets/images/harvest/harvest_seed_packet.png',",
        "      ),",
        "    ],",
    ]
    return "\n".join(out)


def colors(*hexes):
    cs = ",\n      ".join(f"Color({h})" for h in hexes)
    return f"    flowerColors: [\n      {cs},\n    ],"


def features(*items):
    fs = ",\n      ".join(f"'{x}'" for x in items)
    return f"    keyFeatures: [\n      {fs},\n    ],"


def poll(b, bf, bu, h):
    return (
        "    pollinatorRatings: FlowerPollinatorRatings(\n"
        f"      bees: {b},\n      butterflies: {bf},\n"
        f"      bumblebees: {bu},\n      hoverflies: {h},\n    ),"
    )


def entry(pid, body):
    return f"  '{pid}': _FlowerFacts(\n{body}\n  ),"


def build(s):
    c = s["cal"]
    sow_l, sow, plant, bloom = c[:4]
    seed = c[4] if len(c) > 4 else "{9, 10}"
    plant_out = s.get("plant_out", True)
    w1, w2, w3, w4 = s["why"]
    return entry(
        s["id"],
        f"""    standplaats: '{s.get("sp", "Volle zon")}',
    standplaatsSubtitle: '{s.get("sps", "6+ uur per dag")}',
    water: '{s.get("w", "Gemiddeld")}',
    waterSubtitle: '{s.get("ws", "Houd de grond gelijkmatig vochtig")}',
    difficulty: '{s.get("d", "Makkelijk")}',
    difficultySubtitle: '{s.get("ds", "Geschikt voor beginners")}',
    lifespan: '{s.get("life", "Eenjarig")}',
    lifespanSubtitle: '{s.get("ls", "Bloeit één seizoen, zaai opnieuw")}',
    summary:
        '{s["sum1"]} '
        '{s["sum2"]}',
{why(w1, w2, w3, w4)}
{poll(*s["poll"])}
    height: '{s["h"]}',
    width: '{s.get("wdt", "25–40 cm")}',
    bloomPeriod: '{s["bloom"]}',
    bloomDuration: '{s.get("dur", "Gemiddeld")}',
{cal(sow_l, sow, plant, bloom, seed, plant_out)}
{colors(*s["col"])}
    fragrance: '{s.get("frag", "Licht geurend of neutraal")}',
    winterHardy: {str(s.get("wh", False)).lower()},
    winterHardyDetail: '{s.get("whd", "Nee, bescherm of herplant")}',
    droughtResistant: {str(s.get("dr", False)).lower()},
    droughtResistantDetail: '{s.get("drd", "Nee, regelmatig water")}',
    suitableFor: {s.get("suit", "_suitableFull")},
{features(*s["feat"])}
    tip:
        '{s["tip"]}',""",
    )


SPECS = [
    dict(
        id="lavendel", sp="Volle zon", sps="6+ uur per dag", w="Weinig",
        ws="Geef pas water als de grond droog is", life="Vaste plant",
        ls="Winterhard en komt elk jaar terug",
        sum1="Geurende, winterharde vaste plant die bijen en vlinders aantrekt.",
        sum2="Bloeit rijkelijk van juni tot september en is ideaal voor borders, potten en droge plekken.",
        why=((BEE, "Trekt bijen en hommels in de zomer"), (PEST, "Geur helpt wolluis en mot te verminderen"),
             (BUT, "Vlinders bezoeken de bloemen regelmatig"), (HAR, "Mooi in pluktuin en droogbloemen")),
        poll=(5, 4, 4, 3), h="60–80 cm", wdt="40–60 cm", bloom="Juni–september", dur="Lang",
        cal=("Zaaien (binnen)", "{3, 4}", "{5, 6}", "{6, 7, 8, 9}", "{10, 11}"),
        col=("0xFF7B1FA2", "0xFF7986CB", "0xFFF48FB1", "0xFFF5F5F5"), frag="Heerlijk geurend",
        wh=True, whd="Ja, tot -20 °C", dr=True, drd="Ja, verdraagt droogte uitstekend",
        feat=("Winterhard en meerjarig", "Zeer aantrekkelijk voor bijen", "Heerlijke geur in de tuin",
              "Weinig water nodig", "Geschikt voor pot en border"),
        tip="Knip lavendel na de bloei licht terug om compact te houden en volgend jaar weer rijk te laten bloeien. Laat niet te ver in het oude hout snijden.",
    ),
    dict(
        id="zonnebloem", sps="6+ uur per dag; beschut tegen wind", ws="Regelmatig water in droge periodes",
        sum1="Imposante eenjarige zomerbloem die bijen en hommels massaal aantrekt.",
        sum2="Ideaal als windscherm en sier aan de zonnige rand van de moestuin, met eetbare zaden in het najaar.",
        why=((BEE, "Trekt bijen en hommels voor betere bestuiving"), (BEN, "Verhoogt biodiversiteit langs het bed"),
             (BUT, "Ook voedselbron voor vlinders"), (HAR, "Eetbare zaden en mooi in pluktuin")),
        poll=(5, 3, 5, 2), h="150–250 cm", wdt="40–60 cm", bloom="Juli–september", dur="Lang",
        cal=("Zaaien (binnen)", "{3, 4}", "{5, 6}", "{7, 8, 9}", "{9, 10}"),
        col=("0xFFFFC107", "0xFFFF9800", "0xFF8D6E63"), whd="Nee, eenjarig; zaai elk voorjaar opnieuw",
        drd="Nee, geef water bij langdurige droogte",
        feat=("Zeer aantrekkelijk voor bijen en hommels", "Kan dienen als windscherm", "Eetbare zaden in het najaar",
              "Makkelijk direct buiten te zaaien", "Hoge en opvallende zomerbloem"),
        tip="Plant aan de zonnige rand van het bed; geef hoge rassen een stevige stok en bescherm tegen harde wind.",
    ),
    dict(
        id="afrikaantje", sum1="Klassieke moestuinbegeleider met sterke geur die wortelknobbelaaltjes en witte vlieg helpt verminderen.",
        sum2="Plant tussen rijen of per hoek bij tomaat, paprika en kool voor een lang bloeiend effect.",
        why=((PEST, "Helpt wortelknobbelaaltjes en witte vlieg af te schrikken"), (SOIL, "Werkt op bodemplagen bij wortelgewassen"),
             (BEE, "Trekt bijen en nuttige insecten"), (BEN, "Verrijkt combinatieteelt in de moestuin")),
        poll=(3, 3, 2, 2), h="30–80 cm", bloom="Juni–oktober", dur="Lang",
        cal=("Zaaien (binnen)", "{3, 4, 5}", "{5, 6}", "{6, 7, 8, 9, 10}", "{10, 11}"),
        col=("0xFFFF9800", "0xFFE53935", "0xFFFFC107"), frag="Sterk geurend", whd="Nee, vorstgevoelig; eenjarig",
        suit="_suitableMoestuinRand",
        feat=("Helpt plagen in de buurt te verminderen", "Sterk geurende moestuinbegeleider", "Lang bloeiend tot de vorst",
              "Geschikt tussen smalle paden", "Makkelijk voor te zaaien"),
        tip="Plant lage en hoge varianten tussen tomaten en kool; lage tagetes past goed in smalle paden.",
    ),
    dict(
        id="goudsbloem", sum1="Eetbare eenjarige bloem die lieveheersbeestjes tegen bladluis aantrekt.",
        sum2="Bloeit lang door en verrijkt borders en moestuinranden met warme oranje en gele kleuren.",
        why=((PEST, "Trekt lieveheersbeestjes tegen bladluis"), (HAR, "Bloembladeren zijn eetbaar"),
             (BEE, "Trekt bijen en vlinders"), (BEN, "Verhoogt biodiversiteit in de tuin")),
        poll=(4, 4, 3, 4), h="30–50 cm", wdt="25–35 cm", bloom="Mei–oktober", dur="Lang",
        cal=("Zaaien", "{3, 4, 5, 6}", "{5, 6}", "{6, 7, 8, 9, 10}", "{10, 11}"),
        col=("0xFFFF9800", "0xFFFFC107", "0xFFE53935"),
        feat=("Eetbare bloembladeren", "Lang doorbloeiend", "Trekt lieveheersbeestjes", "Makkelijk door te zaaien", "Warme kleuren tot de vorst"),
        tip="Knip uitgebloeide bloemen weg voor doorbloei tot de eerste vorst.",
    ),
    dict(
        id="oostindische_kers", sum1="Eetbare vangplant die bladluis wegtrekt van kool en komkommer.",
        sum2="Plant iets verder van hoofdteelt; bloeit rijk en houdt onkruid tegen op kale plekken.",
        why=((PEST, "Trek bladluis weg van kool en komkommer"), (HAR, "Eetbare bloemen en blad"),
             (BEE, "Trekt bijen en nuttige insecten"), (BEN, "Dekkend tapijt op lege plekken")),
        poll=(3, 3, 2, 2), h="20–30 cm", wdt="30–50 cm", bloom="Juni–oktober", dur="Lang",
        cal=("Zaaien", "{5, 6}", "{6}", "{7, 8, 9, 10}", "{10, 11}"), plant_out=False,
        col=("0xFFFF9800", "0xFFE53935", "0xFFFFC107"),
        feat=("Eetbare bloemen en blad", "Vangplant voor bladluis", "Dekkend laag tapijt", "Lang bloeiend in de zomer", "Makkelijk direct te zaaien"),
        tip="Niet te dicht op jonge koolplanten; gebruik eerst als lokmiddel iets verder van de hoofdteelt.",
        suit="_suitableMoestuinRand",
    ),
    dict(
        id="komkommerkruid", sum1="Sterke bijenplant en klassieke buur van tomaten en courgette.",
        sum2="Verbeterde vruchtzetting door betere bestuiving; ook sierlijk met blauwe sterbloemen.",
        why=((BEE, "Sterke bijenplant voor betere bestuiving"), (BEN, "Verhoogt biodiversiteit in de moestuin"),
             (BUT, "Ook aantrekkelijk voor vlinders"), (HAR, "Eetbaar blad en bloemen")),
        poll=(5, 3, 3, 3), h="40–60 cm", bloom="Juni–september", dur="Lang",
        cal=("Zaaien (binnen)", "{4, 5}", "{5, 6}", "{6, 7, 8, 9}", "{9, 10}"),
        col=("0xFF42A5F5", "0xFF7B1FA2", "0xFFF5F5F5"), frag="Licht geurend",
        feat=("Zeer aantrekkelijk voor bijen", "Klassieke buur van tomaat", "Eetbaar blad en bloemen", "Helpt vruchtzetting", "Lang bloeiend"),
        tip="Zaai naast tomaten, courgette of komkommer; laat een deel doorbloeien voor bijen.",
    ),
    dict(
        id="facelia", sum1="Top bijenplant en snelle groenbemester voor lege plekken na vroege oogst.",
        sum2="Verbeterd bodemstructuur als je na bloei uitspit; paarse bloemen trekken massaal bestuivers.",
        why=((BEE, "Enorme bijenaantrek op paarse bloemen"), (SOIL, "Verbetert bodem als groenbemester"),
             (BUT, "Trekt ook vlinders en zweefvliegen"), (BEN, "Vult lege plekken snel op")),
        poll=(5, 3, 4, 5), h="40–70 cm", bloom="Juni–augustus", dur="Gemiddeld",
        cal=("Zaaien", "{4, 5, 6, 7, 8}", "{5, 6, 7}", "{6, 7, 8}", "{9, 10}"), plant_out=False,
        col=("0xFF7B1FA2", "0xFF42A5F5", "0xFFF5F5F5"),
        feat=("Zeer aantrekkelijk voor bijen", "Snelle groenbemester", "Ideaal na vroege oogst", "Trekt zweefvliegen", "Verbeterd bodemstructuur"),
        tip="Zaai in blokken op lege plek na radijs of sla; bijen komen massaal op de paarse bloemen.",
        suit="_suitableGreenManure",
    ),
    dict(
        id="korenbloem", sum1="Eenvoudige randbloem met blauwe bloemen die bijen en nuttige insecten aantrekt.",
        sum2="Makkelijk te zaaien langs paden en bij bonen of uien in de moestuin.",
        why=((BEE, "Trekt bijen en nuttige insecten"), (BUT, "Ook geliefd bij vlinders"),
             (BEN, "Verhoogt biodiversiteit op de rand"), (HAR, "Sierlijk in pluktuin en border")),
        poll=(4, 4, 3, 3), h="40–80 cm", bloom="Juni–augustus", dur="Gemiddeld",
        cal=("Zaaien", "{3, 4}", "{5, 6}", "{6, 7, 8}", "{9, 10}"),
        col=("0xFF42A5F5", "0xFF7B1FA2", "0xFFE53935"),
        feat=("Makkelijke randbloem", "Trekt bijen en vlinders", "Blauwe zomerbloemen", "Direct buiten te zaaien", "Past langs moestuinpaden"),
        tip="Zaai direct in volle grond langs de rand; dun uit voor stevige planten.",
    ),
    dict(
        id="cosmos", sum1="Lang bloeiende eenjarige met luchtige bloemen voor bijen en vlinders.",
        sum2="Ideaal op de rand van de moestuin; bloeit door tot de eerste vorst bij regelmatig deadheading.",
        why=((BEE, "Langdurige voedselbron voor bijen"), (BUT, "Zeer geliefd bij vlinders"),
             (BEN, "Verhoogt biodiversiteit op de rand"), (HAR, "Mooi in pluktuin en border")),
        poll=(4, 5, 3, 3), h="80–120 cm", wdt="30–45 cm", bloom="Juli–oktober", dur="Lang",
        cal=("Zaaien", "{5, 6}", "{6}", "{7, 8, 9, 10}", "{10, 11}"), plant_out=False,
        col=("0xFFF48FB1", "0xFFE53935", "0xFFF5F5F5"),
        feat=("Zeer aantrekkelijk voor vlinders", "Lang doorbloeiend", "Luchtige zomerbloemen", "Makkelijk direct te zaaien", "Ideaal op moestuinrand"),
        tip="Zaai direct buiten na de vorstperiode; dun uit voor luchtige, rijke bloei.",
    ),
    dict(
        id="boekweit", sum1="Snelle groenbemester en bijenplant die binnen enkele weken bloeit.",
        sum2="Ideaal op lege plekken tussen rijen; verbetert bodem en trekt zweefvliegen.",
        why=((BEE, "Snelle bijenbron na inzaai"), (SOIL, "Verbetert bodem als groenbemester"),
             (BUT, "Trekt nuttige insecten"), (BEN, "Vult lege plekken snel op")),
        poll=(4, 2, 3, 5), h="40–60 cm", bloom="Juli–september", dur="Kort",
        cal=("Zaaien", "{5, 6, 7, 8}", "{6, 7, 8}", "{7, 8, 9}", "{9, 10}"), plant_out=False,
        col=("0xFFF5F5F5", "0xFFFFC107"),
        feat=("Snelle groenbemester", "Trekt zweefvliegen", "Bloeit binnen enkele weken", "Verbeterd bodem", "Flexibel in te zaaien"),
        tip="Zaai als groenbemester op lege plek; bloeit snel en trekt massaal zweefvliegen.",
        suit="_suitableGreenManure",
    ),
    dict(
        id="witte_klaver", sp="Volle zon", sps="4–6 uur zon; ook licht halfschaduw", w="Gemiddeld",
        sum1="Laag groenbedekkend klaver dat stikstof vastlegt in de bodem.",
        sum2="Ideaal onder fruitbomen of als tijdelijke tussenteelt langs paden.",
        why=((SOIL, "Vangt stikstof en verbetert bodem"), (BEE, "Trekt bijen en hommels"),
             (BEN, "Laag tapijt onder fruit of struiken"), (PEST, "Dekkend tegen onkruid")),
        poll=(4, 2, 4, 3), h="15–25 cm", wdt="30–50 cm", bloom="Mei–september", dur="Lang",
        cal=("Zaaien", "{3, 4, 5, 6, 7, 8, 9}", "{5, 6, 7}", "{5, 6, 7, 8, 9}", "{9, 10}"), plant_out=False,
        col=("0xFFF5F5F5", "0xFFE8F5E9"), life="Meerjarig", ls="Komt terug als tapijt; zaai opnieuw indien nodig",
        wh=True, whd="Ja, winterhard als laag tapijt", dr=False,
        feat=("Vangt stikstof in de bodem", "Laag groenbedekkend tapijt", "Trekt bijen en hommels", "Ideaal onder fruit", "Tijdelijke tussenteelt"),
        tip="Vastlegt stikstof; goed als tussen-teelt of groenbedekker onder fruitbomen.",
        suit="_suitableGreenManure",
    ),
    dict(
        id="rode_klaver", sp="Volle zon", sps="4–6 uur zon per dag", sum1="Groenbemester met roodroze bloemen die stikstof vastlegt.",
        sum2="Zaai in voorjaar of na oogst; knip vóór je opnieuw zaait in het bed.",
        why=((SOIL, "Vangt stikstof en verbetert bodem"), (BEE, "Trekt bijen en hommels"),
             (BEN, "Tijdelijke tussenteelt tussen rijen"), (BUT, "Ook aantrekkelijk voor vlinders")),
        poll=(4, 3, 4, 3), h="20–40 cm", bloom="Mei–september", dur="Lang",
        cal=("Zaaien", "{3, 4, 5, 8, 9}", "{5, 6, 9}", "{5, 6, 7, 8, 9}", "{9, 10}"), plant_out=False,
        col=("0xFFE53935", "0xFFFF5252", "0xFFF48FB1"), life="Meerjarig", ls="Kan terugkomen; zaai opnieuw als tussenteelt",
        wh=True, whd="Ja, winterhard als groenbedekker",
        feat=("Vangt stikstof in de bodem", "Groenbemester met bijenbloei", "Tijdelijke tussenteelt", "Trekt hommels", "Makkelijk in te zaaien"),
        tip="Zaai als groenbemester; knip of spit onder vóór je opnieuw groenten zaait.",
        suit="_suitableGreenManure",
    ),
    dict(
        id="duizendblad", sum1="Kruidachtige vaste plant die parasietwespen en lieveheersbeestjes aantrekt.",
        sum2="Versterkt buurtplanten bij kool, tomaat en komkommer met witte bloemtuilen.",
        why=((PEST, "Trekt parasietwespen en lieveheersbeestjes"), (BEE, "Witte bloemen voor bijen"),
             (BEN, "Verhoogt biodiversiteit in de buurt"), (HAR, "Sierlijk en nuttig kruid")),
        poll=(3, 3, 3, 4), h="40–70 cm", bloom="Juni–augustus", dur="Lang", life="Vaste plant",
        ls="Winterhard en komt elk jaar terug", wh=True, whd="Ja, tot ca. -25 °C", dr=True, drd="Ja, verdraagt droge perioden goed",
        cal=("Zaaien", "{3, 4, 5}", "{5, 6}", "{6, 7, 8}", "{9, 10}"),
        col=("0xFFF5F5F5", "0xFFFFC107"),
        feat=("Winterhard en meerjarig", "Trekt nuttige insecten", "Witte bloemtuilen", "Versterkt buurtplanten", "Droogtolerant"),
        tip="Plant bij kool, tomaat of komkommer; laat een deel staan voor nuttige insecten.",
    ),
    dict(
        id="zaadslurf", sum1="Laag bloeitapijt met zoete geur dat zweefvliegen tegen bladluis aantrekt.",
        sum2="Ideaal tussen lage gewassen als sla, aardbei, kool en tomaat.",
        why=((PEST, "Trekt zweefvliegen die bladluis eten"), (BEE, "Zoete geur lokt bestuivers"),
             (BEN, "Laag tapijt op voorgrond van bed"), (HAR, "Dekkend en sierlijk")),
        poll=(3, 2, 2, 5), h="10–20 cm", wdt="20–40 cm", bloom="Juni–september", dur="Lang",
        cal=("Zaaien", "{5, 6}", "{6}", "{6, 7, 8, 9}", "{9, 10}"), plant_out=False,
        col=("0xFF42A5F5", "0xFFF5F5F5"), frag="Licht geurend",
        feat=("Trekt zweefvliegen tegen bladluis", "Laag bloeitapijt", "Zoete geur", "Ideaal tussen lage gewassen", "Lang bloeiend"),
        tip="Zaai tussen sla, aardbei of kool; zweefvliegen eten bladluis in de buurt.",
    ),
    dict(
        id="limnanthes", sum1="Het 'slakkenplantje': enorme bijenmagnet met fel gele bloemen.",
        sum2="Korte, rijke bloei in voorjaar en vroege zomer; ideaal bij aardbei, fruit en bonen.",
        why=((BEE, "Enorme bijenaantrek in het voorjaar"), (BEN, "Verbetert bestuiving in de buurt"),
             (BUT, "Ook nuttig voor andere bestuivers"), (HAR, "Fel geel en vrolijk tapijt")),
        poll=(5, 2, 3, 3), h="15–25 cm", bloom="Mei–juli", dur="Kort",
        cal=("Zaaien", "{4, 5}", "{5, 6}", "{5, 6, 7}", "{8, 9}"),
        col=("0xFFFFC107", "0xFFF5F5F5"),
        feat=("Zeer aantrekkelijk voor bijen", "Fel geel voorjaarsbloei", "Kort en krachtig effect", "Ideaal bij aardbei", "Makkelijk te zaaien"),
        tip="Zaai vroeg in het voorjaar; korte maar intense bijenbloei rond fruit en bonen.",
    ),
    dict(
        id="monarda", life="Vaste plant", ls="Winterhard en komt elk jaar terug",
        sum1="Vaste bloem met rode of paarse bloemen die hommels en bijen aantrekt.",
        sum2="Helpt bestuiving van pompoenfamilie; plant bij courgette, komkommer en fruit.",
        why=((BEE, "Trekt bijen en hommels"), (BUT, "Ook geliefd bij vlinders"),
             (BEN, "Helpt bestuiving pompoenfamilie"), (HAR, "Sierlijk en lang bloeiend")),
        poll=(5, 4, 4, 3), h="60–90 cm", bloom="Juni–augustus", dur="Lang",
        wh=True, whd="Ja, tot ca. -20 °C", cal=("Zaaien (binnen)", "{3, 4}", "{5, 6}", "{6, 7, 8}", "{9, 10}"),
        col=("0xFFE53935", "0xFF7B1FA2"),
        feat=("Winterhard en meerjarig", "Zeer aantrekkelijk voor bijen", "Helpt pompoenbestuiving", "Rode en paarse bloemen", "Lang bloeiend"),
        tip="Plant bij pompoen, courgette of komkommer voor betere vruchtzetting.",
    ),
    dict(
        id="zonnehoed", life="Vaste plant", ls="Winterhard en komt elk jaar terug",
        sum1="Vaste prairiebloem die vlinders en bijen aantrekt op de moestuinrand.",
        sum2="Decoratief en nuttig; bloeit lang in de zomer en herfst.",
        why=((BUT, "Trekt vlinders massaal"), (BEE, "Voedselbron voor bijen en hommels"),
             (BEN, "Verhoogt biodiversiteit op de rand"), (HAR, "Mooi in pluktuin")),
        poll=(4, 4, 4, 3), h="60–120 cm", bloom="Juli–september", dur="Lang",
        wh=True, whd="Ja, tot ca. -25 °C", dr=True, drd="Ja, verdraagt droge perioden",
        cal=("Zaaien (binnen)", "{2, 3}", "{5, 6}", "{7, 8, 9}", "{10, 11}"),
        col=("0xFFE53935", "0xFFFF9800", "0xFFF48FB1", "0xFFF5F5F5"),
        feat=("Winterhard en meerjarig", "Zeer aantrekkelijk voor vlinders", "Lang bloeiend", "Droogtolerant", "Ideaal op moestuinrand"),
        tip="Plant op een zonnige rand; laat uitgebloeide stengels staan voor vogels in het najaar.",
    ),
    dict(
        id="verbena", sum1="Lang bloeiende bijenbron, ook geschikt in pot bij terras-tuin.",
        sum2="Paarse bloemaren trekken bijen de hele zomer; in koude winters vorstgevoelig.",
        why=((BEE, "Langdurige bijenbron"), (BUT, "Ook aantrekkelijk voor vlinders"),
             (BEN, "Verhoogt biodiversiteit op rand"), (HAR, "Mooi in pot en border")),
        poll=(4, 4, 3, 3), h="60–120 cm", bloom="Juni–oktober", dur="Lang",
        wh=False, whd="Nee, vorstgevoelig; bescherm of herplant", cal=("Zaaien (binnen)", "{3, 4}", "{5, 6}", "{6, 7, 8, 9, 10}", "{10, 11}"),
        col=("0xFF7B1FA2", "0xFF42A5F5", "0xFFF5F5F5"),
        feat=("Lang doorbloeiend", "Trekt bijen de hele zomer", "Geschikt in pot", "Paarse bloemaren", "Ideaal op moestuinrand"),
        tip="Zaai voor binnen of koop jonge planten; bescherm in strenge winters of behandel als eenjarig.",
    ),
    dict(
        id="wilde_marjolein", life="Vaste plant", ls="Winterhard kruid dat terugkomt",
        sum1="Geurend kruid dat sommige insecten verstoort en bestuivers aantrekt.",
        sum2="Traditionele buur bij kool, boon en wortel in combinatieteelt.",
        why=((PEST, "Geur verstoort sommige insecten"), (BEE, "Trekt bijen in de zomer"),
             (BEN, "Versterkt combinatieteelt"), (HAR, "Eetbaar kruid en bloei")),
        poll=(3, 2, 2, 3), h="30–50 cm", bloom="Juni–augustus", dur="Gemiddeld",
        wh=True, whd="Ja, tot ca. -15 °C", dr=True, drd="Ja, verdraagt droge perioden",
        frag="Heerlijk geurend", cal=("Zaaien", "{4, 5}", "{5, 6}", "{6, 7, 8}", "{9, 10}"),
        col=("0xFFE8F5E9", "0xFFF5F5F5"),
        feat=("Winterhard kruid", "Geur verstoort insecten", "Trekt bestuivers", "Bij kool en wortel", "Droogtolerant"),
        tip="Plant bij kool, boon of wortel; laat een deel bloeien voor bijen.",
    ),
    dict(
        id="hysop", life="Vaste plant", ls="Winterhard en komt elk jaar terug",
        sum1="Traditioneel kruid bij kool en druif met blauwe bijenbloemen.",
        sum2="Helpt plagen verminderen en verrijkt de moestuin met geur en kleur.",
        why=((PEST, "Traditioneel bij kool en druif"), (BEE, "Blauwe bloemen voor bijen"),
             (BEN, "Versterkt combinatieteelt"), (HAR, "Eetbaar kruid en sier")),
        poll=(4, 3, 3, 2), h="40–60 cm", bloom="Juni–augustus", dur="Gemiddeld",
        wh=True, whd="Ja, tot ca. -20 °C", dr=True, drd="Ja, houdt van doorlatende grond",
        frag="Heerlijk geurend", cal=("Zaaien (binnen)", "{3, 4}", "{5, 6}", "{6, 7, 8}", "{9, 10}"),
        col=("0xFF42A5F5", "0xFF7B1FA2"),
        feat=("Winterhard en meerjarig", "Blauwe bijenbloemen", "Traditioneel bij kool", "Droogtolerant", "Aangename kruidengeur"),
        tip="Plant bij kool of langs druif; snoei na bloei licht terug.",
    ),
    dict(
        id="mosterd_geel", sum1="Groenbemester en vangplant voor koolvlieg op lege bedden.",
        sum2="Verbeterd bodem, maar spit 4 weken vóór koolteelt onder — niet direct ervoor zaaien.",
        why=((PEST, "Vangt koolvlieg op lege bedden"), (SOIL, "Verbetert bodem als groenbemester"),
             (BEE, "Gele bloemen voor bijen"), (BEN, "Vult lege plekken snel")),
        poll=(3, 2, 2, 4), h="40–80 cm", bloom="Juni–september", dur="Kort",
        cal=("Zaaien", "{4, 5, 6, 7, 8, 9}", "{5, 6, 7, 8}", "{6, 7, 8, 9}", "{9, 10}"), plant_out=False,
        col=("0xFFFFC107", "0xFFF5F5F5"),
        feat=("Vangt koolvlieg", "Snelle groenbemester", "Gele bloemen", "Vult lege bedden", "Verbeterd bodem"),
        tip="Niet direct vóór broccoli of spruitkool zaaien; spit 4 weken vóór koolteelt onder.",
        suit="_suitableGreenManure",
    ),
    dict(
        id="klaproos", sum1="Wilde randbloem die biodiversiteit verhoogt in een natuurlijke hoek.",
        sum2="Rustplek voor nuttige insecten; zaai in herfst of vroeg voorjaar.",
        why=((BEN, "Verhoogt biodiversiteit"), (BUT, "Rustplek voor nuttige insecten"),
             (BEE, "Trekt bijen op de rand"), (HAR, "Sierlijk in wilde hoek")),
        poll=(3, 3, 2, 3), h="50–80 cm", bloom="Juni–augustus", dur="Gemiddeld",
        cal=("Zaaien", "{3, 4, 9, 10}", "{4, 5}", "{6, 7, 8}", "{9, 10}"),
        col=("0xFFE53935", "0xFFFF5252", "0xFFF5F5F5"),
        feat=("Verhoogt biodiversiteit", "Rustplek voor insecten", "Makkelijk op rand", "Rode klaprozen", "Zaai herfst of voorjaar"),
        tip="Zaai op een rustige rand of wilde hoek; rooi niet te vroeg voor insecten.",
    ),
    dict(
        id="bijenmengsel", sum1="Gemengd zaad met bloemen die bijen en bestuivers door het seizoen voeden.",
        sum2="Strooi waar een plek leeg is tussen rijen, bij bonen, fruit of komkommer.",
        why=((BEE, "Voedt bijen door het hele seizoen"), (BEN, "Snelle mix voor bestuiving"),
             (BUT, "Ook vlinders en nuttige insecten"), (HAR, "Flexibel in te zaaien")),
        poll=(5, 4, 4, 4), h="30–80 cm", bloom="Juni–september", dur="Lang",
        cal=("Zaaien", "{5, 6, 7, 8}", "{6, 7, 8}", "{6, 7, 8, 9}", "{9, 10}"), plant_out=False,
        col=("0xFFFFC107", "0xFFFF9800", "0xFFE53935", "0xFF7B1FA2"),
        feat=("Zeer aantrekkelijk voor bijen", "Mix bloeit door het seizoen", "Flexibel in te zaaien", "Ideaal op lege plek", "Verbetert bestuiving"),
        tip="Strooi waar een plek leeg is; inzaaien tussen rijen of na vroege oogst.",
    ),
    dict(
        id="lindebloesem", sp="Volle zon", sps="Ruime standplaats; volwassen boom", w="Gemiddeld",
        ws="Jonge bomen regelmatig water", life="Vaste plant", ls="Meerjarige boom; bloeit elk jaar",
        sum1="Hommel- en bijenboom op lange termijn voor de hele tuin.",
        sum2="Alleen bij ruime tuin; in klein bed kies liever facelia of klaver in de moestuin.",
        why=((BEE, "Enorme hommel- en bijenboom"), (BEN, "Voedt bestuivers op grote schaal"),
             (BUT, "Ondersteunt biodiversiteit in de tuin"), (HAR, "Geurige juni-bloei")),
        poll=(5, 3, 5, 2), h="800–1500 cm", wdt="400–800 cm", bloom="Juni", dur="Kort",
        wh=True, whd="Ja, winterharde boom", dr=False,
        cal=("Planten", "{3, 4, 10, 11}", "{4, 5}", "{6}", "{10, 11}"), plant_out=True,
        col=("0xFFFFC107", "0xFFF5F5F5"),
        frag="Heerlijk geurend",
        feat=("Enorme bijen- en hommelboom", "Geurige junibloei", "Langetermijn investering", "Ondersteunt hele tuin", "Winterhard"),
        tip="Geen ideale keuze in klein moestuinbed; kies facelia of klaver voor direct effect.",
        suit="_suitableFull",
    ),
    dict(
        id="tagetes_patula", sum1="Lage tagetes met sterke begeleiding bij nachtschadegewassen.",
        sum2="Werkt op bodemplagen bij wortelgewassen; ideaal in smalle paden tussen groenten.",
        why=((PEST, "Sterke begeleider bij nachtschade"), (SOIL, "Werkt op bodemplagen"),
             (BEE, "Trekt bijen en nuttige insecten"), (BEN, "Compact in smalle paden")),
        poll=(3, 2, 2, 2), h="20–30 cm", wdt="20–25 cm", bloom="Juni–oktober", dur="Lang",
        cal=("Zaaien (binnen)", "{4, 5}", "{5, 6}", "{6, 7, 8, 9, 10}", "{10, 11}"),
        col=("0xFFFF9800", "0xFFE53935"), frag="Sterk geurend", whd="Nee, vorstgevoelig; eenjarig",
        feat=("Helpt plagen verminderen", "Lage variant voor smalle paden", "Lang bloeiend", "Bij tomaat en paprika", "Compact en kleurrijk"),
        tip="Lage variant ideaal in smalle paden tussen groenten; plant bij tomaat en aardappel.",
        suit="_suitableMoestuinRand",
    ),
    dict(
        id="alyssum_sneeuw", sum1="Laag wit bloeitapijt dat zweefvliegen tegen bladluis aantrekt.",
        sum2="Mooi op de voorgrond van bedden, randen en in potten.",
        why=((PEST, "Trekt zweefvliegen tegen bladluis"), (BEE, "Kleine bloemen voor bijen"),
             (BEN, "Laag op voorgrond van bed"), (HAR, "Wit tapijt in pot en border")),
        poll=(4, 3, 2, 4), h="10–15 cm", wdt="20–30 cm", bloom="Mei–september", dur="Lang",
        cal=("Zaaien", "{4, 5, 6}", "{5, 6}", "{5, 6, 7, 8, 9}", "{9, 10}"),
        col=("0xFFF5F5F5", "0xFFE1BEE7"),
        feat=("Trekt zweefvliegen", "Laag bodembedekkend", "Wit bloeitapijt", "Ideaal in potten", "Lang bloeiend"),
        tip="Laag bodembedekkend; ideaal aan randen, voorgrond van bedden en in potten.",
    ),
    dict(
        id="calendula_officinalis", sum1="Eetbare goudsbloem die bladluis verstoort en lieveheersbeestjes aantrekt.",
        sum2="Vrolijke rand langs paden; bloeit de hele zomer door bij regelmatig deadheading.",
        why=((PEST, "Vangt en verstoort bladluis"), (HAR, "Eetbare bloembladeren"),
             (BEE, "Trekt bijen en vlinders"), (BEN, "Vrolijke rand langs paden")),
        poll=(4, 4, 3, 4), h="30–50 cm", bloom="Mei–oktober", dur="Lang",
        cal=("Zaaien", "{3, 4, 5, 6}", "{5, 6}", "{6, 7, 8, 9, 10}", "{10, 11}"),
        col=("0xFFFF9800", "0xFFFFC107", "0xFFE53935"),
        feat=("Eetbare bloembladeren", "Trekt lieveheersbeestjes", "Lang doorbloeiend", "Vangt bladluis", "Warme kleuren"),
        tip="Knip uitgebloeide bloemen weg voor doorbloei; eetbare bloembladeren op salade.",
    ),
    dict(
        id="zinnia", sum1="Warmteminnende eenjarige met rijke kleuren voor bijen en vlinders.",
        sum2="Zaai pas na de IJsheiligen; houdt van een warme, zonnige plek in de moestuin.",
        why=((BUT, "Zeer geliefd bij vlinders"), (BEE, "Trekt bijen in de zomer"),
             (HAR, "Mooi in pluktuin"), (BEN, "Verrijkt moestuinrand met kleur")),
        poll=(4, 5, 3, 2), h="40–90 cm", bloom="Juli–oktober", dur="Lang",
        cal=("Zaaien (binnen)", "{4, 5}", "{5, 6}", "{7, 8, 9, 10}", "{10, 11}"),
        col=("0xFFE53935", "0xFFFF9800", "0xFFF48FB1"),
        feat=("Zeer aantrekkelijk voor vlinders", "Rijke zomerbloemen", "Lang doorbloeiend", "Warmteminnend", "Mooi in pluktuin"),
        tip="Zaai pas na de IJsheiligen; houdt van warme plekken en regelmatig deadheading.",
    ),
    dict(
        id="lupine_groenbemester", life="Eenjarig", ls="Bloeit één seizoen; spit onder voor bemesting",
        sum1="Peulgewas als groenbemester met rijke bloei voor hommels en bijen.",
        sum2="Werk onder vóór zaadzetting als je groenbemesting wilt, niet voor zaad.",
        why=((SOIL, "Verbetert bodem als groenbemester"), (BEE, "Trekt bijen en hommels"),
             (BEN, "Vastlegt stikstof via wortels"), (HAR, "Sierlijke lentebloei")),
        poll=(4, 4, 5, 2), h="60–100 cm", bloom="Mei–juli", dur="Gemiddeld",
        cal=("Zaaien", "{3, 4, 7, 8}", "{5, 6, 8}", "{5, 6, 7}", "{8, 9}"),
        col=("0xFF7B1FA2", "0xFF42A5F5", "0xFFF5F5F5"), wh=True, whd="Ja, winterhard zaad; eenjarige teelt",
        feat=("Groenbemester met stikstof", "Trekt hommels", "Sierlijke lentebloei", "Verbeterd bodem", "Spit onder vóór zaad"),
        tip="Werk onder vóór bloei als je groenbemesting wilt; niet laten zaaien in het bed.",
        suit="_suitableGreenManure",
    ),
    dict(
        id="stiefmoedje", sp="Halfschaduw", sps="3–6 uur zon; koeler weer", sum1="Koel-season bloem met gezichtjes; bloeit vroeg in voorjaar en herfst.",
        sum2="Ideaal in pot, border of onder hogere planten; winterhard biennial.",
        why=((BEE, "Vroege voedselbron voor bijen"), (BEN, "Kleur in voor- en najaar"),
             (HAR, "Mooi in pot en border"), (BUT, "Ook in koelere maanden actief")),
        poll=(3, 3, 2, 3), h="15–25 cm", wdt="20–30 cm", bloom="Maart–mei & september–november", dur="Lang",
        life="Tweejarig", ls="Bloeit vaak in het tweede jaar; kan terugkomen",
        wh=True, whd="Ja, winterhard tot ca. -15 °C",
        cal=("Zaaien (binnen)", "{6, 7, 8}", "{8, 9}", "{3, 4, 5, 9, 10, 11}", "{7, 8}"),
        col=("0xFF7B1FA2", "0xFF42A5F5", "0xFFFFC107", "0xFFF5F5F5"),
        feat=("Bloeit vroeg en laat in seizoen", "Winterhard biennial", "Geschikt in pot", "Koel-season kleur", "Compact en rijk"),
        tip="Zaai in zomer voor bloei volgend voorjaar; houdt van koelere, licht beschaduwde plekken.",
    ),
    dict(
        id="ringelbloem", sum1="Eetbare composietenbloem met oranje bloemhoofden langs de moestuinrand.",
        sum2="Trekt zweefvliegen en nuttige insecten; bloeit lang in de zomer.",
        why=((BEE, "Trekt bijen en nuttige insecten"), (HAR, "Eetbare bloembladeren"),
             (BEN, "Verrijkt moestuinrand"), (PEST, "Trekt zweefvliegen")),
        poll=(3, 3, 2, 4), h="50–80 cm", bloom="Juni–oktober", dur="Lang",
        cal=("Zaaien", "{4, 5, 6}", "{5, 6}", "{6, 7, 8, 9, 10}", "{10, 11}"),
        col=("0xFFFF9800", "0xFFFFC107", "0xFFE53935"),
        feat=("Eetbare bloembladeren", "Trekt zweefvliegen", "Lang bloeiend", "Oranje bloemhoofden", "Rand langs moestuin"),
        tip="Plant langs de rand; verwijder uitgebloeide bloemen voor langere bloei.",
    ),
    dict(
        id="ui_bloei", sum1="Laat bewust 2–3 uien doorbloeien voor bestuivers en combinatiewerking.",
        sum2="Uiengeur helpt wortel en prei; bolvormige bloem voor bijen.",
        why=((PEST, "Uiengeur helpt wortel en prei"), (BEE, "Bolvormige bloem voor bijen"),
             (BEN, "Gratis combinatiewerking uit eigen teelt"), (HAR, "Bewust deel laten staan")),
        poll=(4, 2, 3, 3), h="60–100 cm", bloom="Juni–juli", dur="Kort", life="Tweejarig",
        ls="Ui bloeit vaak in het tweede jaar",
        cal=("Zaaien", "{3, 4}", "{5, 6}", "{6, 7}", "{8, 9}"),
        col=("0xFFF5F5F5", "0xFFFFC107"), frag="Licht geurend",
        feat=("Uiengeur helpt buurtplanten", "Gratis uit eigen teelt", "Trekt bijen", "Bolvormige bloem", "Combinatie met wortel"),
        tip="Laat bewust 2–3 uien doorbloeien; oogst de rest voor keuken.",
        suit="_suitableMoestuinRand",
    ),
    dict(
        id="look_bloei", sum1="Laat knoflook of look doorbloeien voor afschrikkende geur rond buurtplanten.",
        sum2="Helpt diverse plagen verminderen bij tomaat, aardbei en fruit.",
        why=((PEST, "Afschrikkende geur op diverse plagen"), (BEE, "Bloei trekt bestuivers"),
             (BEN, "Gratis uit eigen teelt"), (HAR, "Sierlijk bolvormige bloem")),
        poll=(4, 2, 3, 2), h="60–100 cm", bloom="Juni–juli", dur="Kort", life="Meerjarig",
        ls="Look/knoflook bloeit in voorjaar",
        cal=("Planten", "{10, 11, 3}", "{3, 4}", "{6, 7}", "{8, 9}"),
        col=("0xFFF5F5F5", "0xFFE8F5E9"), frag="Sterk geurend", wh=True, whd="Ja, winterhard",
        feat=("Afschrikkende geur", "Gratis uit eigen teelt", "Trekt bestuivers", "Bij tomaat en fruit", "Bolvormige bloem"),
        tip="Laat een paar bolletjes doorbloeien; plant look in het najaar of vroege lente.",
        suit="_suitableMoestuinRand",
    ),
    dict(
        id="dille_bloei", sum1="Laat een deel dille doorbloeien voor zweefvliegen en parasietwespen.",
        sum2="Ideaal tussen kool, komkommer en tomaat voor natuurlijke plaagbeheersing.",
        why=((PEST, "Trekt zweefvliegen en parasietwespen"), (BEE, "Geel schermbloei voor bijen"),
             (BEN, "Ideaal tussen kool"), (HAR, "Eetbaar kruid en bloei")),
        poll=(4, 2, 2, 4), h="60–120 cm", bloom="Juni–augustus", dur="Gemiddeld",
        cal=("Zaaien", "{4, 5, 6, 7}", "{5, 6, 7}", "{6, 7, 8}", "{9, 10}"), plant_out=False,
        col=("0xFFFFC107", "0xFFF5F5F5"), frag="Heerlijk geurend",
        feat=("Trekt zweefvliegen", "Ideaal bij kool", "Eetbaar kruid", "Geel schermbloei", "Doorzaaien voor lang effect"),
        tip="Zaai elke paar weken door; laat een deel bloeien voor nuttige insecten.",
    ),
    dict(
        id="koriander_bloei", sum1="Laat koriander doorbloeien voor nuttige insecten en bestuivers.",
        sum2="Zaai elke 3 weken door voor lang effect; bloei trekt zweefvliegen.",
        why=((BEE, "Bloei trekt bijen en nuttige insecten"), (PEST, "Zweefvliegen tegen bladluis"),
             (BEN, "Doorzaaien voor lang effect"), (HAR, "Eetbaar kruid en zaad")),
        poll=(4, 2, 2, 4), h="30–60 cm", bloom="Juni–september", dur="Gemiddeld",
        cal=("Zaaien", "{4, 5, 6, 7, 8}", "{5, 6, 7, 8}", "{6, 7, 8, 9}", "{9, 10}"), plant_out=False,
        col=("0xFFF5F5F5", "0xFFE8F5E9"), frag="Heerlijk geurend",
        feat=("Trekt nuttige insecten", "Doorzaaien elke 3 weken", "Bij tomaat en komkommer", "Eetbaar zaad en blad", "Zweefvliegen tegen bladluis"),
        tip="Zaai regelmatig door; laat een deel schieten voor bijen en nuttige insecten.",
    ),
    dict(
        id="salie_bloei", life="Vaste plant", ls="Winterhard en komt elk jaar terug",
        sum1="Vaste salie in bloei helpt koolmot verminderen en trekt bestuivers.",
        sum2="Plant bij kool, wortel of aardbei; blauwe bloemen in het voorjaar.",
        why=((PEST, "Helpt koolmot verminderen"), (BEE, "Blauwe voorjaarsbloei voor bijen"),
             (BEN, "Versterkt combinatieteelt"), (HAR, "Eetbaar kruid en sier")),
        poll=(4, 3, 3, 2), h="40–60 cm", bloom="Mei–juni", dur="Kort",
        wh=True, whd="Ja, tot ca. -15 °C", dr=True, drd="Ja, verdraagt droge perioden",
        frag="Heerlijk geurend", cal=("Planten", "{3, 4, 9, 10}", "{4, 5, 10}", "{5, 6}", "{7, 8}"),
        col=("0xFF7B1FA2", "0xFF42A5F5"),
        feat=("Winterhard en meerjarig", "Helpt koolmot verminderen", "Blauwe voorjaarsbloei", "Bij koolgewassen", "Droogtolerant"),
        tip="Plant bij kool, wortel of aardbei; snoei na bloei licht terug.",
    ),
    dict(
        id="tijm_bloei", life="Vaste plant", ls="Winterhard en komt elk jaar terug",
        sum1="Laag droogtolerant kruid dat koolbladluis helpt verminderen.",
        sum2="Plant bij kool, aardbei of tussen tegels; bloeit rijk in het voorjaar.",
        why=((PEST, "Helpt koolbladluis verminderen"), (BEE, "Voorjaarsbloei voor bijen"),
             (BEN, "Laag en combinatievriendelijk"), (HAR, "Eetbaar kruid en sier")),
        poll=(4, 3, 3, 3), h="10–25 cm", wdt="20–30 cm", bloom="Mei–juli", dur="Gemiddeld",
        wh=True, whd="Ja, tot ca. -20 °C", dr=True, drd="Ja, verdraagt droogte uitstekend",
        w="Weinig", ws="Geef pas water als de grond droog is", frag="Heerlijk geurend",
        cal=("Planten", "{3, 4, 9}", "{4, 5}", "{5, 6, 7}", "{8, 9}"),
        col=("0xFFE8F5E9", "0xFFF5F5F5", "0xFFFFC107"),
        feat=("Winterhard en meerjarig", "Droogtolerant", "Helpt koolbladluis verminderen", "Laag en compact", "Heerlijke geur"),
        tip="Laag en droogtolerant; plant bij kool voor bladluiswerking.",
    ),
    dict(
        id="basilicum_bloei", sum1="Laat een deel basilicum doorbloeien voor bijen naast tomaat en paprika.",
        sum2="Versterkt combinatieteelt; knip rest voor keuken en laat enkele planten bloeien.",
        why=((PEST, "Versterkt tomaat en paprika"), (BEE, "Bloei trekt bestuivers"),
             (BEN, "Gratis uit eigen kruidenbed"), (HAR, "Eetbaar kruid en bloei")),
        poll=(4, 3, 2, 3), h="30–50 cm", bloom="Juli–september", dur="Gemiddeld",
        cal=("Zaaien (binnen)", "{4, 5}", "{5, 6}", "{7, 8, 9}", "{9, 10}"),
        col=("0xFFE8F5E9", "0xFFF5F5F5"), frag="Heerlijk geurend", wh=False, whd="Nee, vorstgevoelig",
        feat=("Versterkt tomaat en paprika", "Bloei trekt bestuivers", "Eetbaar kruid", "Warmteminnend", "Gratis uit eigen teelt"),
        tip="Laat een deel bloeien voor bijen; knip de rest regelmatig voor keuken.",
    ),
    dict(
        id="munt_bloei", life="Meerjarig", ls="Vorstgevoelig; altijd in pot houden",
        sum1="Geur op mieren en kevers; bloei trekt bijen in de zomer.",
        sum2="Altijd in pot plaatsen — wortels verspreiden zich anders snel.",
        why=((PEST, "Geur op mieren en kevers"), (BEE, "Zomerbloei voor bijen"),
             (BEN, "In pot goed te beheersen"), (HAR, "Eetbaar kruid en sier")),
        poll=(4, 2, 2, 3), h="30–60 cm", bloom="Juli–augustus", dur="Gemiddeld",
        wh=False, whd="Nee, wortels vorstgevoelig; pot binnen of beschermen", dr=False,
        frag="Heerlijk geurend", cal=("Planten", "{4, 5, 9}", "{5, 6}", "{7, 8}", "{9, 10}"),
        col=("0xFFE8F5E9", "0xFF7B1FA2", "0xFFF5F5F5"),
        feat=("Geur op mieren en kevers", "Altijd in pot", "Trekt bijen", "Eetbaar kruid", "Spreidt zich niet in bed"),
        tip="Altijd in pot plaatsen — wortels verspreiden zich snel in open grond.",
        suit="_suitablePotBee",
    ),
]

# Reorder to match user list (vegetable_groups order)
ORDER = [
    "zonnebloem", "afrikaantje", "goudsbloem", "oostindische_kers", "komkommerkruid",
    "facelia", "korenbloem", "cosmos", "boekweit", "witte_klaver", "rode_klaver",
    "duizendblad", "zaadslurf", "limnanthes", "monarda", "zonnehoed", "verbena",
    "wilde_marjolein", "hysop", "mosterd_geel", "klaproos", "bijenmengsel",
    "lindebloesem", "tagetes_patula", "alyssum_sneeuw", "calendula_officinalis",
    "zinnia", "lupine_groenbemester", "stiefmoedje", "ringelbloem", "lavendel",
    "ui_bloei", "look_bloei", "dille_bloei", "koriander_bloei", "salie_bloei",
    "tijm_bloei", "basilicum_bloei", "munt_bloei",
]

by_id = {s["id"]: s for s in SPECS}
entries = [build(by_id[pid]) for pid in ORDER]

with open(OUT, "w", encoding="utf-8") as f:
    f.write("part of 'flower_overview_data.dart';\n\n")
    f.write("const Map<String, _FlowerFacts> _kFlowerFacts = {\n")
    f.write(",\n".join(entries))
    f.write("\n};\n")

print(f"Wrote {len(entries)} entries")
