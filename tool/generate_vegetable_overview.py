# -*- coding: utf-8 -*-
"""Generate vegetable_overview_entries.dart with curated NL overview facts."""
from __future__ import annotations

from pathlib import Path

OUT = Path(__file__).resolve().parents[1] / "lib" / "data" / "vegetable_overview_entries.dart"


def s(months: list[int]) -> str:
    if not months:
        return "<int>{}"
    return "{" + ", ".join(str(m) for m in months) + "}"


def entry(
    id_: str,
    *,
    sow: list[int],
    plant: list[int] | None = None,
    harvest: list[int],
    standplaats: str,
    water: str,
    difficulty: str,
    lifespan: str,
    outdoor: str,
    container: str,
    voeding: str,
    height: str,
    width: str,
    habit: str,
    spacing: str,
    row: str,
    first: str,
    period: str,
    yield_level: str,
    yield_detail: str,
    points: list[str],
    summary: str,
    know: str,
) -> str:
    plant = plant or []
    pts = ",\n      ".join(f"'{p.replace(chr(39), chr(92)+chr(39))}'" for p in points)
    return f"""  '{id_}': VegetableOverviewFacts(
    sowMonths: {s(sow)},
    plantMonths: {s(plant)},
    harvestMonths: {s(harvest)},
    standplaats: '{standplaats}',
    water: '{water}',
    difficulty: '{difficulty}',
    lifespan: '{lifespan}',
    locatieOutdoor: '{outdoor}',
    locatieContainer: '{container}',
    voeding: '{voeding}',
    height: '{height}',
    width: '{width}',
    growthHabit: '{habit}',
    plantSpacing: '{spacing}',
    rowSpacing: '{row}',
    firstHarvest: '{first}',
    harvestPeriod: '{period}',
    opbrengstLevel: '{yield_level}',
    opbrengstDetail: '{yield_detail}',
    keyPoints: [
      {pts},
    ],
    summaryShort: '{summary.replace(chr(39), chr(92)+chr(39))}',
    didYouKnow: '{know.replace(chr(39), chr(92)+chr(39))}',
  ),"""


entries: list[str] = []

# --- Bieten ---
biet_base = dict(
    sow=[3, 4, 5, 6, 7],
    plant=[],
    harvest=[6, 7, 8, 9, 10],
    standplaats="Zon",
    water="Gemiddeld",
    difficulty="Makkelijk",
    lifespan="Eenjarig",
    outdoor="Buiten",
    container="Bed / Pot",
    voeding="Gemiddeld",
    height="30–50 cm",
    width="20–30 cm",
    habit="Bladrozet met knol",
    spacing="10–15 cm",
    row="25–30 cm",
    first="±55–80 dagen",
    period="juni – oktober",
    yield_level="Gemiddelde opbrengst",
    yield_detail="1 knol per plant; dunnen geeft grotere bieten",
    points=[
        "Direct buiten zaaien",
        "Dunnen op tijd",
        "Geschikt voor beginners",
        "Ook blad eetbaar",
    ],
)
entries.append(entry("rode_biet", **biet_base, summary="Klassieke rode biet voor de Nederlandse moestuin. Zaai in rijen vanaf maart en oogst knollen als ze stevig en goed gevuld zijn.", know="Jonge bladeren kun je meenemen als spinazie-achtige groente."))
entries.append(entry("rode_biet_cilindrisch", **{**biet_base, "yield_detail": "Cilindervormige knollen; handig voor plakjes", "habit": "Cilindervormige knol"}, summary="Cilindervormige rode biet die makkelijk in plakjes snijdt. Zelfde teelt als gewone rode biet.", know="Ideaal voor wecken en snijden door de egale vorm."))
entries.append(entry("gele_biet", **{**biet_base, "yield_detail": "Zoete gele knollen zonder rode verkleuring"}, summary="Gele biet is zoeter en kleurt niet af. Teelt en zaaikalender zijn gelijk aan rode biet.", know="Mooi in salades omdat het sap niet rood uitslaat."))
entries.append(entry("witte_biet", **biet_base, summary="Witte biet heeft een milde, zoete smaak. Zaai en oogst zoals rode biet in volle grond.", know="Minder bekend, maar zeer geschikt voor soepen en ovenschotels."))
entries.append(entry("chioggia_biet", **{**biet_base, "yield_detail": "Ringpatroon binnenin; jonge knollen oogsten"}, summary="Chioggia-biet met roze-witte ringen. Zaai in zonrijke grond en oogst jong voor het mooiste patroon.", know="Het ringpatroon vervaagt iets bij lang koken."))

# --- Sla ---
sla_base = dict(
    sow=[3, 4, 5, 6, 7, 8, 9],
    plant=[4, 5, 6, 7, 8],
    harvest=[4, 5, 6, 7, 8, 9, 10],
    standplaats="Halfschaduw",
    water="Hoog",
    difficulty="Makkelijk",
    lifespan="Eenjarig",
    outdoor="Buiten",
    container="Pot / Balkon",
    voeding="Gemiddeld",
    height="15–30 cm",
    width="20–30 cm",
    habit="Bladrozet of krop",
    spacing="20–30 cm",
    row="30 cm",
    first="±40–70 dagen",
    period="april – oktober",
    yield_level="Hoge opbrengst",
    yield_detail="Doorzaaien elke 2–3 weken voor continue oogst",
    points=[
        "Regelmatig water geven",
        "Geschikt voor potten",
        "Doorzaaien voor dooroogst",
        "Halfschaduw in de zomer",
    ],
)
entries.append(entry("sla", **sla_base, summary="Sla is een snelle bladgroente voor pot en bed. Zaai gefaseerd en houd de grond vochtig voor knapperige bladeren.", know="In warme zomers schiet sla snel door; kies dan hittebestendige rassen."))
entries.append(entry("ijsbergsla", **{**sla_base, "difficulty": "Gemiddeld", "first": "±70–90 dagen", "habit": "Stevige krop", "yield_detail": "1 stevige krop per plant"}, summary="IJsbergsla vormt een stevige krop en vraagt iets meer ruimte en tijd dan snijsla. Gelijkmatig vochtig houden.", know="Te veel warmte geeft losse kroppen; zaai voorjaar en najaar."))
entries.append(entry("lollo_rossa", **{**sla_base, "habit": "Krullende snijsla", "yield_detail": "Blad voor blad of hele krop oogsten"}, summary="Lollo Rossa is decoratieve krulsla met milde smaak. Ideaal voor snijden en doorzaaien.", know="Rode rassen kleuren sterker bij koel weer."))
entries.append(entry("krulsla", **{**sla_base, "habit": "Krullende bladeren"}, summary="Krulsla levert luchtige, gekrulde bladeren. Goed voor snijden en herhaalde oogst.", know="Oogst buitenste bladeren zodat het hart blijft doorgroeien."))
entries.append(entry("lambsla", **{**sla_base, "sow": [2, 3, 4, 8, 9, 10], "plant": [], "harvest": [3, 4, 5, 10, 11, 12], "standplaats": "Halfschaduw", "first": "±50–70 dagen", "period": "najaar – voorjaar", "habit": "Kleine rozetten", "spacing": "10–15 cm", "yield_detail": "Kleine rozetten; dicht zaaien mogelijk"}, summary="Lambsla (veldslachtig) is mild en winterhard. Zaai vooral in het najaar voor oogst in de koude maanden.", know="Verwar niet met veldsla; lambsla is een zachte botersla-variant."))
entries.append(entry("eikenbladsla", **{**sla_base, "habit": "Eikenbladvormige bladeren", "yield_detail": "Mooi als snijsla; rode en groene rassen"}, summary="Eikenbladsla heeft gelobde bladeren en een milde smaak. Geschikt als snij- of kropensla.", know="Rode eikenbladsla blijft langer knapperig in de koeling."))

# --- Bladgroenten ---
entries.append(entry(
    "spinazie",
    sow=[3, 4, 5, 8, 9], plant=[], harvest=[4, 5, 6, 9, 10, 11],
    standplaats="Halfschaduw", water="Hoog", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Pot / Balkon", voeding="Hoog",
    height="20–40 cm", width="15–25 cm", habit="Bladrozet", spacing="8–12 cm", row="25 cm",
    first="±35–50 dagen", period="april – juni en september – november",
    yield_level="Hoge opbrengst", yield_detail="Meerdere snedes mogelijk bij doorzaaien",
    points=["Snel te oogsten", "Doorzaaien in voor- en najaar", "Regelmatig water", "Geschikt voor beginners"],
    summary="Spinazie groeit snel in koele periodes. Zaai in voorjaar en najaar en houd vochtig voor zachte bladeren.",
    know="In de zomer schiet spinazie snel door; kies dan zomerse bladalternatieven.",
))
entries.append(entry(
    "baby_spinazie",
    sow=[3, 4, 5, 8, 9], plant=[], harvest=[4, 5, 6, 9, 10],
    standplaats="Halfschaduw", water="Hoog", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Pot / Balkon", voeding="Gemiddeld",
    height="10–20 cm", width="10–15 cm", habit="Jonge bladeren dicht gezaaid", spacing="3–5 cm", row="15 cm",
    first="±25–35 dagen", period="april – juni en september – oktober",
    yield_level="Hoge opbrengst", yield_detail="Oogst jong als babyleaf",
    points=["Zeer snel", "Ideaal voor potten", "Dicht zaaien", "Mild van smaak"],
    summary="Baby-spinazie oogst je jong als babyleaf. Dicht zaaien en vroeg plukken geeft malse saladebladeren.",
    know="Niet laten doorschieten: oogst zodra bladeren 8–12 cm zijn.",
))
entries.append(entry(
    "rucola",
    sow=[3, 4, 5, 6, 7, 8, 9], plant=[], harvest=[4, 5, 6, 7, 8, 9, 10],
    standplaats="Halfschaduw", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Pot / Balkon", voeding="Laag",
    height="15–30 cm", width="15–20 cm", habit="Snelle bladgroente", spacing="5–10 cm", row="20 cm",
    first="±25–40 dagen", period="april – oktober",
    yield_level="Hoge opbrengst", yield_detail="Herhaaldelijk snijden mogelijk",
    points=["Zeer snel", "Pittige smaak", "Geschikt voor potten", "Doorzaaien"],
    summary="Rucola is een snelle, pittige bladgroente. Zaai vaak klein beetje bij voor continue oogst.",
    know="Bij warm weer wordt de smaak scherper; halfschaduw helpt.",
))
entries.append(entry(
    "andijvie",
    sow=[5, 6, 7], plant=[6, 7, 8], harvest=[8, 9, 10, 11],
    standplaats="Zon", water="Hoog", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Hoog",
    height="30–40 cm", width="30–40 cm", habit="Brede bladrozet", spacing="30–35 cm", row="40 cm",
    first="±70–90 dagen", period="augustus – november",
    yield_level="Gemiddelde opbrengst", yield_detail="1 krop per plant; bleken voor mildere smaak",
    points=["Najaarsgewas", "Veel water nodig", "Ruimte geven", "Bleken voor mildere smaak"],
    summary="Andijvie is vooral een najaarsgewas. Zaai in zomer, geef ruimte en water, en oogst stevige kroppen.",
    know="Te vroeg zaaien in warm weer verhoogt kans op doorschieten.",
))
entries.append(entry(
    "postelein",
    sow=[5, 6, 7, 8], plant=[], harvest=[6, 7, 8, 9],
    standplaats="Zon", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Pot / Balkon", voeding="Laag",
    height="10–25 cm", width="15–25 cm", habit="Kruipend bladgewas", spacing="10 cm", row="20 cm",
    first="±30–45 dagen", period="juni – september",
    yield_level="Gemiddelde opbrengst", yield_detail="Snijden van jonge scheuten",
    points=["Zomerbladgroente", "Hittebestendig", "Geschikt voor potten", "Mild zuurachtig"],
    summary="Postelein groeit goed in de zomerhitte als spinazie-alternatief. Oogst jonge scheuten regelmatig.",
    know="Winterpostelein is een andere soort en groeit juist in de kou.",
))
entries.append(entry(
    "snijbiet",
    sow=[4, 5, 6, 7], plant=[5, 6], harvest=[6, 7, 8, 9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Hoog",
    height="40–60 cm", width="30–40 cm", habit="Brede bladstelen", spacing="25–30 cm", row="40 cm",
    first="±50–70 dagen", period="juni – oktober",
    yield_level="Hoge opbrengst", yield_detail="Blad voor blad oogsten tot in de herfst",
    points=["Dooroogst mogelijk", "Kleurrijke stelen", "Voedingsrijk", "Vorst tot lichte kou oké"],
    summary="Snijbiet geeft maandenlang blad en stelen. Zaai vanaf april en oogst steeds de buitenste bladeren.",
    know="Bij lichte vorst blijft snijbiet vaak langer staan dan sla.",
))
entries.append(entry(
    "tuinkers",
    sow=[3, 4, 5, 6, 7, 8, 9], plant=[], harvest=[3, 4, 5, 6, 7, 8, 9, 10],
    standplaats="Halfschaduw", water="Hoog", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Binnen / Kas", container="Pot / Balkon", voeding="Laag",
    height="5–15 cm", width="5–10 cm", habit="Zeer snelle kiemer", spacing="dicht", row="dicht",
    first="±7–14 dagen", period="bijna jaarrond binnen",
    yield_level="Hoge opbrengst", yield_detail="Oogst als microgroente of jong blad",
    points=["Supersnel", "Ideaal binnen", "Dicht zaaien", "Beginnersvriendelijk"],
    summary="Tuinkers is een van de snelste gewassen. Zaai dicht op vochtig keukenpapier of in potgrond en oogst jong.",
    know="Buiten schiet tuinkers snel door; voor kiemgroente is binnen ideaal.",
))
entries.append(entry(
    "witlof",
    sow=[5, 6], plant=[], harvest=[11, 12, 1, 2, 3],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Tweejarig",
    outdoor="Buiten", container="Volle grond", voeding="Gemiddeld",
    height="30–50 cm (loof)", width="20–30 cm", habit="Wortel + trekken in het donker", spacing="10–15 cm", row="30 cm",
    first="±150–200 dagen + trekken", period="winter (getrokken kroppen)",
    yield_level="Gemiddelde opbrengst", yield_detail="Eerst wortel telen, daarna kroppen trekken",
    points=["Twee stappen: wortel en trekken", "Donker trekken nodig", "Najaarswerk", "Meer ervaring vereist"],
    summary="Witlof vraagt twee fases: eerst wortels telen, daarna kroppen in het donker trekken. Uitdagend maar lonend.",
    know="Zonder duisternis worden de kroppen groen en bitter.",
))
entries.append(entry(
    "veldsla",
    sow=[8, 9, 10], plant=[], harvest=[10, 11, 12, 1, 2, 3],
    standplaats="Halfschaduw", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="5–15 cm", width="10–15 cm", habit="Kleine winterrozetten", spacing="5–10 cm", row="15 cm",
    first="±60–90 dagen", period="oktober – maart",
    yield_level="Gemiddelde opbrengst", yield_detail="Kleine rozetten; winteroogst",
    points=["Wintergewas", "Koudebestendig", "Laag bemesten", "Geschikt voor bakken"],
    summary="Veldsla is dé winterbladgroente. Zaai in nazomer/najaar voor oogst in de koude maanden.",
    know="Dekken met vliesdoek verhoogt de kwaliteit in strenge vorst.",
))

# --- Wortelgroenten ---
wortel_base = dict(
    sow=[3, 4, 5, 6, 7], plant=[], harvest=[6, 7, 8, 9, 10, 11],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Diepe bak", voeding="Laag",
    height="25–40 cm loof", width="5–10 cm", habit="Peen in losse grond", spacing="5–8 cm", row="25–30 cm",
    first="±70–100 dagen", period="juni – november",
    yield_level="Gemiddelde opbrengst", yield_detail="Dunnen voor rechte, stevige wortels",
    points=["Losse, steenvrije grond", "Niet te zwaar bemesten", "Regelmatig dunnen", "Gelijkmatig vochtig"],
)
entries.append(entry("wortel", **wortel_base, summary="Wortelen vragen losse, steenvrije grond. Zaai dun, houd gelijkmatig vochtig en oogst naar gewenste dikte.", know="Verse mest geeft vaak gespleten of vertakte wortels."))
entries.append(entry("paarse_wortel", **{**wortel_base, "yield_detail": "Paarse schil; vaak oranje kern"}, summary="Paarse wortel teel je zoals oranje peen. Losse grond en dunnen blijven essentieel.", know="De paarse kleur zit vooral in de schil en is rijk aan anthocyanen."))
entries.append(entry("gele_wortel", **wortel_base, summary="Gele wortel is zoeter en milder. Zelfde teeltwijze als klassieke peen.", know="Mooi in soepen omdat de kleur warm geel blijft."))
entries.append(entry("witte_wortel", **wortel_base, summary="Witte wortel heeft een milde smaak en groeit het best in losse grond zonder verse mest.", know="Historisch ras; vaak iets vroeger oogstbaar dan lange winterpeen."))
entries.append(entry(
    "radijs",
    sow=[3, 4, 5, 6, 7, 8, 9], plant=[], harvest=[4, 5, 6, 7, 8, 9, 10],
    standplaats="Zon", water="Hoog", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Pot / Balkon", voeding="Laag",
    height="10–20 cm", width="5–8 cm", habit="Snelle knolgewas", spacing="3–5 cm", row="15 cm",
    first="±25–35 dagen", period="april – oktober",
    yield_level="Hoge opbrengst", yield_detail="Doorzaaien elke 1–2 weken",
    points=["Zeer snel", "Beginnersvriendelijk", "Gelijkmatig water", "Geschikt voor potten"],
    summary="Radijs is ideaal voor beginners: snel, compact en makkelijk. Doorzaaien houdt de oogst gaande.",
    know="Te droog of te warm maakt radijs houtig en scherp.",
))
entries.append(entry(
    "pastinaak",
    sow=[3, 4], plant=[], harvest=[10, 11, 12, 1, 2],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Laag",
    height="40–60 cm loof", width="8–12 cm", habit="Lange witte wortel", spacing="10–15 cm", row="35 cm",
    first="±120–150 dagen", period="oktober – februari",
    yield_level="Gemiddelde opbrengst", yield_detail="Na vorst zoeter; langzaam kiemend",
    points=["Traag kiemen", "Winteroogst", "Diepe losse grond", "Vorst verbetert smaak"],
    summary="Pastinaak kiemt traag en groeit lang. Zaai vroeg en oogst na de eerste vorst voor zoetere smaak.",
    know="Zaad verliest snel kiemkracht; gebruik vers zaad.",
))
entries.append(entry(
    "winterpeen",
    sow=[4, 5, 6], plant=[], harvest=[9, 10, 11, 12],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Laag",
    height="30–45 cm loof", width="5–8 cm", habit="Lange bewaarwortel", spacing="6–8 cm", row="30 cm",
    first="±100–140 dagen", period="september – december",
    yield_level="Gemiddelde opbrengst", yield_detail="Geschikt om in te kuilen of koel te bewaren",
    points=["Bewaarpeen", "Diepe grond", "Niet te vroeg oogsten", "Losse grond"],
    summary="Winterpeen is bedoeld om te bewaren. Zaai niet te vroeg en laat wortels goed uitgroeien.",
    know="Na oogst loof inkorten maar niet de kop beschadigen voor betere bewaring.",
))
entries.append(entry(
    "mini_wortel",
    sow=[3, 4, 5, 6, 7, 8], plant=[], harvest=[5, 6, 7, 8, 9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Pot / Balkon", voeding="Laag",
    height="15–25 cm loof", width="2–4 cm", habit="Korte peen voor bakken", spacing="3–5 cm", row="15–20 cm",
    first="±50–70 dagen", period="mei – oktober",
    yield_level="Hoge opbrengst", yield_detail="Ideaal voor ondiepe bakken",
    points=["Geschikt voor potten", "Sneller dan lange peen", "Doorzaaien", "Losse potgrond"],
    summary="Mini-wortelen zijn perfect voor bakken en potten. Korter groeiseizoen dan lange peen.",
    know="Ook bij steenachtige grond minder kans op vertakte wortels.",
))
entries.append(entry(
    "schorseneer",
    sow=[3, 4], plant=[], harvest=[10, 11, 12],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Laag",
    height="80–120 cm loof", width="5–8 cm", habit="Lange zwarte wortel", spacing="10 cm", row="30 cm",
    first="±180–220 dagen", period="oktober – december",
    yield_level="Beperkte opbrengst", yield_detail="Lange teelt; voorzichtig oogsten",
    points=["Zeer lange teelt", "Diepe grond nodig", "Voorzichtig oogsten", "Meer ervaring"],
    summary="Schorseneer vraagt een heel seizoen en diepe, losse grond. Oogst voorzichtig om breuk te voorkomen.",
    know="Wordt ook winterasperge genoemd door de milde smaak na koken.",
))
entries.append(entry(
    "rammenas",
    sow=[6, 7, 8], plant=[], harvest=[9, 10, 11],
    standplaats="Zon", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="30–50 cm", width="8–12 cm", habit="Grote herfstradijs", spacing="15–20 cm", row="30 cm",
    first="±60–90 dagen", period="september – november",
    yield_level="Gemiddelde opbrengst", yield_detail="Grote knollen voor herfst en winter",
    points=["Najaarsgewas", "Pittige smaak", "Niet te vroeg zaaien", "Losse grond"],
    summary="Rammenas is een grote herfstradijs. Zaai in de zomer voor stevige knollen in het najaar.",
    know="Te vroeg zaaien geeft vaak doorschieten in plaats van knolvorming.",
))
entries.append(entry(
    "zwarte_radijs",
    sow=[6, 7, 8], plant=[], harvest=[9, 10, 11],
    standplaats="Zon", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="25–40 cm", width="8–10 cm", habit="Zwarte schil, witte binnenkant", spacing="12–15 cm", row="30 cm",
    first="±60–80 dagen", period="september – november",
    yield_level="Gemiddelde opbrengst", yield_detail="Bewaarbaar in koel en vochtig",
    points=["Najaarsgewas", "Scherpe smaak", "Goed bewaarbaar", "Losse grond"],
    summary="Zwarte radijs heeft een stevige schil en pittige smaak. Zaai in zomer voor najaarsoogst.",
    know="Schillen en kort weken kan de scherpte milderen.",
))
entries.append(entry(
    "peterseliewortel",
    sow=[3, 4], plant=[], harvest=[9, 10, 11],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Laag",
    height="30–50 cm loof", width="5–8 cm", habit="Wortel + peterselieachtig loof", spacing="10 cm", row="30 cm",
    first="±120–150 dagen", period="september – november",
    yield_level="Gemiddelde opbrengst", yield_detail="Zowel wortel als blad bruikbaar",
    points=["Lang groeiseizoen", "Blad ook eetbaar", "Losse grond", "Gelijkmatig vochtig"],
    summary="Peterseliewortel combineert een aromatische wortel met eetbaar loof. Zaai vroeg en geef het seizoen de tijd.",
    know="Lijkt op pastinaak maar is aromatischer en fijner van smaak.",
))

print(f"Part A entries: {len(entries)}")
# Continue in same script for remaining groups...

# --- Tomaten ---
tomaat = dict(
    sow=[2, 3, 4], plant=[5, 6], harvest=[7, 8, 9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten / Kas", container="Pot / Balkon", voeding="Hoog",
    height="120–200 cm", width="50–70 cm", habit="Opgaand, dieven en steunen", spacing="50–70 cm", row="70–90 cm",
    first="±70–90 dagen na uitplanten", period="juli – oktober",
    yield_level="Hoge opbrengst", yield_detail="Veel trossen bij goede verzorging en steun",
    points=["Voorzaaien warm", "Uitplanten na ijsheiligen", "Steun en dieven", "Regelmatig water onder bij de voet"],
)
entries.append(entry("tomaat", **tomaat, summary="Tomaat is een warmteminnend kas- of zonnig buitenras. Voorzaaien, steunen, dieven en regelmatig water geven leveren de meeste vruchten.", know="Ongelijke watergift geeft snel neusrot aan de vruchten."))
entries.append(entry("snoeptomaat", **{**tomaat, "height": "100–180 cm", "yield_detail": "Veel kleine zoete vruchten; ideaal tussendoor"}, summary="Snoeptomaat geeft veel kleine, zoete vruchten. Teelt als gewone tomaat met steun en warmte.", know="Vaak productiever per plant dan grote vleestomaten."))
entries.append(entry("cherrytomaat", **{**tomaat, "height": "120–200 cm", "difficulty": "Makkelijk", "yield_detail": "Zeer productief; klein fruit"}, summary="Cherrytomaat is productief en iets vergevingsgezinder. Perfect voor kas, serre of warme muur.", know="Laat trossen goed doorrijpen voor maximale zoetheid."))
entries.append(entry("pruimtomaat", **{**tomaat, "yield_detail": "Vlezige ovale vruchten; goed voor saus"}, summary="Pruimtomaat heeft vlezige, ovale vruchten die uitblinken in saus en drogen.", know="Minder sap dan ronde tomaten; ideaal voor concentraten."))
entries.append(entry("vleestomaat", **{**tomaat, "difficulty": "Gemiddeld", "first": "±80–100 dagen na uitplanten", "yield_detail": "Grote vruchten; iets lagere aantallen"}, summary="Vleestomaat geeft grote, vlezige vruchten. Geef stevige steun en gelijkmatig water.", know="Grote vruchten scheuren sneller bij wisselende vochtigheid."))
entries.append(entry("trostomaat", **{**tomaat, "yield_detail": "Oogst hele trossen tegelijk"}, summary="Trostomaat rijpt gelijkmatig aan de tros. Teelt verder als standaard tomaat.", know="Tros oogsten als de meeste vruchten kleuren."))
entries.append(entry("cocktailtomaat", **{**tomaat, "yield_detail": "Middelkleine vruchten; goede balans smaak/opbrengst"}, summary="Cocktailtomaat zit tussen cherry en trostomaat in. Warm, zonnig en steun zijn belangrijk.", know="Goede allrounder voor kas en warme balkonbak."))
entries.append(entry("balkontomaat", **{**tomaat, "height": "30–80 cm", "habit": "Compact, struikachtig", "spacing": "30–40 cm", "difficulty": "Makkelijk", "yield_detail": "Compact ras voor potten en bakken"}, summary="Balkontomaat blijft compact en is gemaakt voor potten. Kies een grote bak en zonnige plek.", know="Zelfs compacte rassen hebben minstens 10–20 liter potgrond nodig."))
entries.append(entry("honingtomaat", **{**tomaat, "yield_detail": "Extra zoete vruchten; warmte belangrijk"}, summary="Honingtomaat staat bekend om zoete smaak. Warmte, zon en gelijkmatig water zijn cruciaal.", know="Smaak piekt bij volle rijpheid aan de plant."))

# --- Paprika & peper ---
paprika = dict(
    sow=[2, 3], plant=[5, 6], harvest=[7, 8, 9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten / Kas", container="Pot / Balkon", voeding="Hoog",
    height="60–100 cm", width="40–50 cm", habit="Struikachtig, warmteminnend", spacing="40–50 cm", row="50–60 cm",
    first="±70–90 dagen na uitplanten", period="juli – oktober",
    yield_level="Gemiddelde opbrengst", yield_detail="Meer vruchten in kas of warme zomer",
    points=["Lang voorzaaien", "Veel warmte nodig", "Uitplanten na vorst", "Oogst groen of gekleurd"],
)
for pid, name, extra in [
    ("rode_paprika", "Rode paprika rijpt van groen naar rood en wordt zoeter. Warmte is doorslaggevend in NL.", "Laat vruchten aan de plant narijpen voor volle kleur."),
    ("gele_paprika", "Gele paprika teel je zoals rode paprika: vroeg voorzaaien en warm uitplanten.", "Gele rassen kleuren vaak iets sneller dan dikke rode blokpaprika's."),
    ("oranje_paprika", "Oranje paprika vraagt dezelfde warme teelt als andere blokpaprika's.", "Mooi voor snacken en salades door milde zoetheid."),
    ("puntpaprika", "Puntpaprika is vaak zoeter en wat vroeger dan blokpaprika. Ideaal voor grill en oven.", "Dunner vruchtvlees droogt sneller in de oven."),
    ("snack_paprika", "Snackpaprika's blijven klein en productief, ook in grote potten.", "Oogst regelmatig om nieuwe zetting te stimuleren."),
]:
    d = {**paprika}
    if "snack" in pid:
        d = {**d, "height": "40–70 cm", "difficulty": "Makkelijk", "yield_level": "Hoge opbrengst", "yield_detail": "Veel kleine zoete paprika's"}
    if "punt" in pid:
        d = {**d, "yield_detail": "Langwerpige zoete vruchten"}
    entries.append(entry(pid, **d, summary=name, know=extra))

peper = {**paprika, "difficulty": "Gemiddeld", "yield_detail": "Oogst groen of rijp rood; scherpte neemt toe bij rijpheid", "points": ["Warmte nodig", "Voorzaaien vroeg", "Pot mogelijk", "Handschoenen bij hete rassen"]}
pepers = [
    ("peper", "Peper (zoet/pittig afhankelijk van ras) vraagt warmte zoals paprika. Voorzaaien in februari–maart.", "Start zachtjes met water bij jonge planten; te nat geeft groeistagnatie."),
    ("cayenne_peper", "Cayenne is een slanke hete peper. Warm telen en rijp rood oogsten voor drogen.", "Gedroogde cayenne is sterker dan verse groene peulen."),
    ("chilipeper", "Chilipeper dekt veel hete rassen. Geef warmte, steun bij zware belading en oogst naar smaak.", "Stress (droogte) kan scherpte verhogen."),
    ("jalapeno", "Jalapeño is middelheet en productief. Goed te doen in kas of warme bak.", "Rode rijpe jalapeño's zijn zoeter en vaak iets heter."),
    ("habanero", "Habanero is zeer heet en warmteminnend. Alleen voor warme kas of warme zomer.", "Draag handschoenen bij oogsten en snijden."),
    ("serrano_peper", "Serrano is slanker en vaak iets heter dan jalapeño. Zelfde warme teelt.", "Oogst jong voor frisse hitte, rijper voor diepere smaak."),
    ("galapeno_peper", "Galapeño/jalapeño-achtige peper voor warme teelt in pot of kas.", "Regelmatig oogsten houdt de plant productief."),
    ("thaise_peper", "Thaise peper is klein, scherp en productief bij voldoende warmte.", "Plant blijft relatief compact; goed voor grote pot."),
    ("poblano_peper", "Poblano is grootvruchtig en mild-heet. Laat goed uitgroeien in warme omstandigheden.", "Gedroogd heet deze peper vaak ancho."),
    ("padron_peper", "Padrón pepertjes grill je jong. De meeste zijn mild, enkele onverwacht heet.", "Oogst klein (3–5 cm) voor de klassieke tapa."),
    ("tabasco_peper", "Tabasco-peper is klein en scherp; uitstekend voor saus. Warmte is essentieel.", "Vruchten rijpen van groen via geel/oranje naar rood."),
    ("peperoncini", "Peperoncini is mildzuur en vaak ingelegd. Iets makkelijker dan zeer hete rassen.", "Oogst lichtgeelgroen voor de bekende milde smaak."),
    ("banana_peper", "Banana peper is mild, zoetzuur en vroeg productief in warme zomer.", "Geschikt om te vullen, grillen of in te maken."),
]
for pid, summary, know in pepers:
    d = dict(peper)
    if pid in ("habanero",):
        d["difficulty"] = "Moeilijk"
    if pid in ("padron_peper", "peperoncini", "banana_peper", "snack_paprika"):
        d["difficulty"] = "Makkelijk"
        d["yield_level"] = "Hoge opbrengst"
    entries.append(entry(pid, **d, summary=summary, know=know))

# --- Komkommer familie ---
komkommer = dict(
    sow=[4, 5], plant=[5, 6], harvest=[7, 8, 9],
    standplaats="Zon", water="Hoog", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten / Kas", container="Bed / Pot", voeding="Hoog",
    height="150–250 cm (klimmend)", width="40–60 cm", habit="Klimmend of rankend", spacing="50–60 cm", row="100 cm",
    first="±55–70 dagen na uitplanten", period="juli – september",
    yield_level="Hoge opbrengst", yield_detail="10–20 komkommers per plant bij goede groei",
    points=["Veel water", "Warmte nodig", "Steun of latwerk", "Oogst jong en vaak"],
)
entries.append(entry("komkommer", **komkommer, summary="Komkommer groeit hard met warmte, water en steun. Oogst jong voor de beste kwaliteit en doorproductie.", know="Oudere vruchten remmen nieuwe zetting; pluk dus vaak."))
entries.append(entry("snackkomkommer", **{**komkommer, "height": "120–200 cm", "difficulty": "Makkelijk", "yield_detail": "Veel kleine snackvruchten"}, summary="Snackkomkommer blijft kleiner van vrucht en is productief op latwerk of in de kas.", know="Ideaal om dagelijks te plukken zonder grote vruchten te missen."))
entries.append(entry("augurk", **{**komkommer, "yield_detail": "Klein plukken voor inmaak", "first": "±50–65 dagen na uitplanten"}, summary="Augurk teel je als komkommer, maar oogst je veel kleiner voor inleggen.", know="Dagelijks plukken voorkomt te dikke, zaderige augurken."))
entries.append(entry(
    "cucamelon",
    sow=[4, 5], plant=[5, 6], harvest=[7, 8, 9],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten / Kas", container="Pot / Balkon", voeding="Gemiddeld",
    height="150–250 cm", width="30–50 cm", habit="Rankend met kleine vruchtjes", spacing="40 cm", row="80 cm",
    first="±70–90 dagen", period="juli – september",
    yield_level="Gemiddelde opbrengst", yield_detail="Veel mini-meloenkomkommertjes",
    points=["Latwerk nodig", "Warmte helpt", "Decoratief en eetbaar", "Pot mogelijk"],
    summary="Cucamelon lijkt op een mini-watermeloen maar smaakt naar komkommer met citrus. Klimplant voor warme plek.",
    know="In koude zomers blijft de opbrengst beperkt; kas helpt.",
))
courgette = dict(
    sow=[4, 5], plant=[5, 6], harvest=[7, 8, 9, 10],
    standplaats="Zon", water="Hoog", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Grote bak", voeding="Hoog",
    height="60–90 cm", width="80–120 cm", habit="Breed, bossig gewas", spacing="80–100 cm", row="100–120 cm",
    first="±50–65 dagen", period="juli – oktober",
    yield_level="Hoge opbrengst", yield_detail="Meerdere vruchten per week bij regelmatig plukken",
    points=["Veel ruimte", "Hoge opbrengst", "Vaak water en voeding", "Jong oogsten"],
)
entries.append(entry("courgette", **courgette, summary="Courgette is productief en makkelijk. Geef ruimte, water en voeding, en oogst jong voor doorproductie.", know="Eén of twee planten volstaan vaak voor een huishouden."))
entries.append(entry("courgette_geel", **{**courgette, "yield_detail": "Gele vruchten; zelfde teelt als groene courgette"}, summary="Gele courgette teel je precies als de groene. Oogst bij 15–20 cm voor de beste textuur.", know="Gele rassen zijn vaak iets zachter van smaak."))
entries.append(entry("patisson", **{**courgette, "habit": "Schijfvormige vruchten", "yield_detail": "Oogst jong; oudere vruchten worden hard"}, summary="Patisson is een schijfvormige pompoenachtige. Teelt als courgette, oogst jong.", know="Grote patissons zijn vooral decoratief en minder mals."))
pompoen = dict(
    sow=[4, 5], plant=[5, 6], harvest=[9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="40–60 cm", width="150–300 cm", habit="Breed rankend", spacing="100–150 cm", row="150–200 cm",
    first="±90–120 dagen", period="september – oktober",
    yield_level="Gemiddelde opbrengst", yield_detail="1–4 vruchten per plant afhankelijk van ras",
    points=["Veel ruimte", "Rijke grond", "Nazomer oogsten", "Harddop laten nazonnen"],
)
entries.append(entry("pompoen", **pompoen, summary="Pompoen vraagt ruimte, warmte en voeding. Laat vruchten goed uitrijpen en dop harden voor bewaring.", know="Onder de vrucht een tegel of stro voorkomt rot."))
entries.append(entry("reuzen_pompoen", **{**pompoen, "difficulty": "Moeilijk", "yield_detail": "Vaak 1 vrucht per plant maximaliseren", "width": "300–500 cm"}, summary="Reuzenpompoen is een ruimte- en voedingvreter. Beperk tot één vrucht voor maximale omvang.", know="Regelmatig draaien voorkomt platte kanten."))
entries.append(entry("pompoen_hokkaido", **{**pompoen, "yield_detail": "Compacte oranje vruchten; schil eetbaar", "difficulty": "Makkelijk"}, summary="Hokkaido is een betrouwbare bewaarpompoen. Schil is eetbaar en vruchten bewaren goed.", know="Oogst met steeltje eraan voor langere houdbaarheid."))
entries.append(entry("pompoen_butternut", **{**pompoen, "yield_detail": "Pechervormige zoete vruchten", "first": "±100–120 dagen"}, summary="Butternut vraagt een warm, lang seizoen. In NL vaak beter in kas of warme zomer.", know="Narijpen binnen op een warme plek verbetert zoetheid."))
entries.append(entry(
    "okra",
    sow=[3, 4], plant=[5, 6], harvest=[7, 8, 9],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Eenjarig",
    outdoor="Buiten / Kas", container="Grote pot", voeding="Gemiddeld",
    height="100–180 cm", width="40–60 cm", habit="Opgaand warmtegewas", spacing="40–50 cm", row="60 cm",
    first="±60–80 dagen na uitplanten", period="juli – september",
    yield_level="Beperkte opbrengst", yield_detail="Jonge peulen om de 1–2 dagen plukken",
    points=["Veel warmte", "Kas aanbevolen", "Vaak oogsten", "Uitdagend in NL"],
    summary="Okra is tropisch en lastig in koel weer. Alleen kansrijk in kas of zeer warme zomer.",
    know="Peulen worden snel vezelig; oogst bij 5–8 cm.",
))
entries.append(entry(
    "pepino",
    sow=[2, 3], plant=[5, 6], harvest=[8, 9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Eenjarig",
    outdoor="Buiten / Kas", container="Pot / Balkon", voeding="Gemiddeld",
    height="60–100 cm", width="40–60 cm", habit="Halfstruik, warmteminnend", spacing="50 cm", row="60 cm",
    first="±90–120 dagen", period="augustus – oktober",
    yield_level="Beperkte opbrengst", yield_detail="Meloenachtige vruchten in warme nazomer",
    points=["Kas of warme muur", "Lang seizoen", "Steun nuttig", "Vorstgevoelig"],
    summary="Pepino smaakt naar meloen-peer en vraagt veel warmte. In NL vooral kaswerk.",
    know="Oogst als de vrucht crèmegeel met paarse strepen kleurt.",
))
entries.append(entry(
    "galia_meloen",
    sow=[3, 4], plant=[5, 6], harvest=[8, 9],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Eenjarig",
    outdoor="Kas", container="Kas / grote bak", voeding="Hoog",
    height="rankend", width="80–150 cm", habit="Rankende meloen", spacing="60–80 cm", row="100 cm",
    first="±90–110 dagen", period="augustus – september",
    yield_level="Beperkte opbrengst", yield_detail="1–3 meloenen per plant in kas",
    points=["Kas sterk aanbevolen", "Warmte en zon", "Bestuiving helpen", "Geurend rijp oogsten"],
    summary="Galia-meloen lukt vooral onder glas. Geef warmte, ruimte en oogst op geur en kleur.",
    know="Rijpe Galia geurt sterk zoet; steeltje laat vaak makkelijk los.",
))
entries.append(entry(
    "honingmeloen",
    sow=[3, 4], plant=[5, 6], harvest=[8, 9],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Eenjarig",
    outdoor="Kas", container="Kas / grote bak", voeding="Hoog",
    height="rankend", width="80–150 cm", habit="Rankende zoete meloen", spacing="60–80 cm", row="100 cm",
    first="±100–120 dagen", period="augustus – september",
    yield_level="Beperkte opbrengst", yield_detail="Warm seizoen of kas nodig",
    points=["Kaswerk", "Lang warm seizoen", "Beperk vruchten", "Rijk bemesten"],
    summary="Honingmeloen vraagt een lang, warm seizoen. In Nederland vrijwel altijd kas.",
    know="Laat vruchten goed nazonnen; te vroeg oogsten geeft weinig smaak.",
))

# --- Uien & look ---
entries.append(entry(
    "ui",
    sow=[3, 4], plant=[3, 4], harvest=[7, 8, 9],
    standplaats="Zon", water="Laag", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="40–60 cm", width="8–12 cm", habit="Bolgewas uit zaaiui of zaad", spacing="8–10 cm", row="25–30 cm",
    first="±90–120 dagen", period="juli – september",
    yield_level="Gemiddelde opbrengst", yield_detail="Uien uit plantuitjes zijn het makkelijkst",
    points=["Zonnige plek", "Niet te nat", "Loof laten afsterven", "Drogen na oogst"],
    summary="Uien groeien het makkelijkst uit plantuitjes. Kies zon, niet te rijke grond, en droog na de oogst goed na.",
    know="Stop met water geven als het loof begint om te vallen.",
))
entries.append(entry(
    "rode_ui",
    sow=[3, 4], plant=[3, 4], harvest=[7, 8, 9],
    standplaats="Zon", water="Laag", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="40–60 cm", width="8–12 cm", habit="Rode bolui", spacing="8–10 cm", row="25–30 cm",
    first="±100–130 dagen", period="juli – september",
    yield_level="Gemiddelde opbrengst", yield_detail="Iets langere teelt dan lichte uien",
    points=["Zonrijk", "Matig vochtig", "Goed drogen", "Mooi voor rauw gebruik"],
    summary="Rode ui teel je als gewone ui, vaak iets langer tot volle kleur en bolgrootte.",
    know="Voor bewaring goed narijpen en drogen tot de rokken ritselen.",
))
entries.append(entry(
    "bosui",
    sow=[3, 4, 5, 6, 7, 8], plant=[4, 5, 6], harvest=[5, 6, 7, 8, 9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Pot / Balkon", voeding="Gemiddeld",
    height="30–50 cm", width="2–3 cm", habit="Dunne lente-ui", spacing="3–5 cm", row="15–20 cm",
    first="±50–70 dagen", period="mei – oktober",
    yield_level="Hoge opbrengst", yield_detail="Doorzaaien voor continue bosjes",
    points=["Doorzaaien", "Snel", "Potgeschikt", "Mild van smaak"],
    summary="Bosui is snel en makkelijk. Zaai gefaseerd voor een constante voorraad milde uistengels.",
    know="Je kunt ook het wit van een trekvaste bosui opnieuw in water zetten.",
))
entries.append(entry(
    "winterui",
    sow=[8, 9], plant=[9, 10], harvest=[5, 6],
    standplaats="Zon", water="Laag", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="40–60 cm", width="8–12 cm", habit="Overwinterende ui", spacing="10 cm", row="25 cm",
    first="±240–270 dagen", period="mei – juni",
    yield_level="Gemiddelde opbrengst", yield_detail="Vroege uien in het voorjaar",
    points=["Najaar planten", "Winterhard", "Vroege oogst", "Zonnige plek"],
    summary="Winterui plant je in het najaar voor een vroege oogst in mei–juni.",
    know="Geschikt als eerste verse ui van het seizoen, minder voor lange bewaring.",
))
entries.append(entry(
    "sjalot",
    sow=[], plant=[3, 4], harvest=[7, 8],
    standplaats="Zon", water="Laag", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="30–50 cm", width="10–15 cm", habit="Kloont tot tros bollen", spacing="15 cm", row="25 cm",
    first="±90–120 dagen", period="juli – augustus",
    yield_level="Gemiddelde opbrengst", yield_detail="Eén plantuitje geeft meerdere sjalotten",
    points=["Plantuitjes gebruiken", "Zonnig en droogachtig", "Goed drogen", "Fijne smaak"],
    summary="Sjalot plant je als uitjes in het voorjaar. Elke plant vormt een trosje bollen.",
    know="Bewaar pootgoed koel en droog; niet uit de koelkast direct de grond in.",
))
entries.append(entry(
    "scheve_ui",
    sow=[3, 4], plant=[3, 4], harvest=[7, 8],
    standplaats="Zon", water="Laag", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="30–50 cm", width="5–8 cm", habit="Lange, scheve stengelui", spacing="8 cm", row="25 cm",
    first="±80–100 dagen", period="juli – augustus",
    yield_level="Gemiddelde opbrengst", yield_detail="Milder dan ui; heel of gesneden gebruiken",
    points=["Mild van smaak", "Zonnige plek", "Niet te nat", "Ook als bosui-achtig"],
    summary="Scheve ui (of speciale stengelui-rassen) teel je luchtig en zonnig, vergelijkbaar met bos- of lente-ui.",
    know="Naam en ras kunnen per leverancier verschillen; teelt blijft ui-achtig.",
))
entries.append(entry(
    "prei",
    sow=[2, 3, 4], plant=[5, 6, 7], harvest=[9, 10, 11, 12, 1, 2],
    standplaats="Zon", water="Hoog", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="50–80 cm", width="3–5 cm", habit="Diep wit te maken door aanaarden", spacing="10–15 cm", row="30–40 cm",
    first="±120–150 dagen", period="september – februari",
    yield_level="Gemiddelde opbrengst", yield_detail="Lang wit gedeelte door aanaarden of diep planten",
    points=["Voorzaaien of kopen", "Aanaarden voor wit", "Vochtig houden", "Lange teelt"],
    summary="Prei vraagt tijd, voeding en vocht. Plant diep of aard aan voor een lang wit gedeelte.",
    know="Zomer- en winterprei hebben verschillende plant- en oogstmomenten.",
))
entries.append(entry(
    "winterprei",
    sow=[3, 4, 5], plant=[6, 7], harvest=[11, 12, 1, 2, 3],
    standplaats="Zon", water="Hoog", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="50–80 cm", width="3–5 cm", habit="Winterharde prei", spacing="12–15 cm", row="35 cm",
    first="±150–180 dagen", period="november – maart",
    yield_level="Gemiddelde opbrengst", yield_detail="Oogst verspreid door de winter",
    points=["Winteroogst", "Aanaarden", "Vorstbestendig ras kiezen", "Voedingsrijk"],
    summary="Winterprei blijft de winter over staan. Plant in zomer en oogst naar behoefte.",
    know="Bij strenge vorst helpt mulchen of vliesdoek.",
))
entries.append(entry(
    "zomerprei",
    sow=[1, 2, 3], plant=[4, 5, 6], harvest=[7, 8, 9],
    standplaats="Zon", water="Hoog", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="50–70 cm", width="3–5 cm", habit="Vroege prei", spacing="10–12 cm", row="30 cm",
    first="±100–130 dagen", period="juli – september",
    yield_level="Gemiddelde opbrengst", yield_detail="Dunnere schachten; eerder oogstbaar",
    points=["Vroeg voorzaaien", "Zomeroogst", "Vochtig houden", "Diep planten"],
    summary="Zomerprei zaai je vroeg voor oogst in de zomer. Minder winterhard dan winterprei.",
    know="Niet laten staan tot de winter; kwaliteit loopt terug.",
))
entries.append(entry(
    "knoflook",
    sow=[], plant=[10, 11, 2], harvest=[6, 7],
    standplaats="Zon", water="Laag", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="40–70 cm", width="10–15 cm", habit="Teen planten in najaar", spacing="12–15 cm", row="25–30 cm",
    first="±240–270 dagen", period="juni – juli",
    yield_level="Gemiddelde opbrengst", yield_detail="1 teen geeft 1 bol",
    points=["Najaar planten", "Zonnig en niet te nat", "Oogsten bij geel loof", "Drogen na oogst"],
    summary="Knoflook plant je bij voorkeur in oktober–november. Oogst in de zomer als het loof vergeelt.",
    know="Gebruik pootknoflook, geen supermarketbol met remmers.",
))
entries.append(entry(
    "knoflook_hardnekkig",
    sow=[], plant=[10, 11], harvest=[6, 7],
    standplaats="Zon", water="Laag", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Bed / Pot", voeding="Laag",
    height="60–90 cm", width="12–15 cm", habit="Hardneck met bloemstengel", spacing="15 cm", row="30 cm",
    first="±240–270 dagen", period="juni – juli",
    yield_level="Gemiddelde opbrengst", yield_detail="Scapes in voorjaar apart oogsten",
    points=["Najaar planten", "Scapes oogsten", "Iets minder lang houdbaar", "Sterke smaak"],
    summary="Hardneck-knoflook vormt een bloemstengel (scape). Plant in najaar en oogst scapes apart in het voorjaar.",
    know="Scapes zijn eetbaar en mild-knoflookachtig van smaak.",
))

# --- Kolen ---
kool_common = dict(
    standplaats="Zon", water="Hoog", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
)
entries.append(entry("boerenkool", **kool_common, sow=[5, 6, 7], plant=[6, 7, 8], harvest=[10, 11, 12, 1, 2, 3],
    height="60–100 cm", width="50–70 cm", habit="Opgaand bladkool", spacing="50–60 cm", row="60–70 cm",
    first="±90–120 dagen", period="oktober – maart", yield_level="Hoge opbrengst",
    yield_detail="Blad voor blad winteroogst",
    points=["Winteroogst", "Na vorst zoeter", "Veel voeding", "Netten tegen rupsen"],
    summary="Boerenkool is een wintersterke bladkool. Plant in zomer en oogst bladeren door de winter.",
    know="Vorst maakt boerenkool merkbaar zoeter."))
entries.append(entry("palmekool", **kool_common, sow=[4, 5, 6], plant=[5, 6, 7], harvest=[9, 10, 11, 12, 1],
    height="80–150 cm", width="50–70 cm", habit="Hoge palmachtige kool", spacing="60 cm", row="70 cm",
    first="±90–120 dagen", period="september – januari", yield_level="Hoge opbrengst",
    yield_detail="Jonge bladeren van onderaf oogsten",
    points=["Decoratief en eetbaar", "Winteroogst", "Ruimte geven", "Rupsengaas"],
    summary="Palmekool (cavolo nero) groeit hoog en smal. Oogst onderste bladeren eerst.",
    know="Jonge bladeren zijn malser; oudere bladeren langer garen."))
entries.append(entry("broccoli", **kool_common, sow=[3, 4, 5, 6], plant=[4, 5, 6, 7], harvest=[6, 7, 8, 9, 10],
    height="50–80 cm", width="50–60 cm", habit="Hoofd + zijscheuten", spacing="45–50 cm", row="60 cm",
    first="±70–100 dagen", period="juni – oktober", yield_level="Gemiddelde opbrengst",
    yield_detail="Eerst hoofd, daarna kleinere zijscheuten",
    points=["Oogst voor bloei", "Vochtig en voedingsrijk", "Rupsengaas", "Niet laten doorschieten"],
    summary="Broccoli oogst je vóór de gele bloei. Na het hoofd volgen vaak kleinere scheuten.",
    know="Geel worden betekent dat je te laat bent met oogsten."))
entries.append(entry("bimi", **kool_common, sow=[3, 4, 5, 6, 7], plant=[4, 5, 6, 7], harvest=[6, 7, 8, 9, 10],
    height="40–70 cm", width="40–50 cm", habit="Dunne broccoli-asperge stelen", spacing="40 cm", row="50 cm",
    first="±60–80 dagen", period="juni – oktober", yield_level="Hoge opbrengst",
    yield_detail="Herhaald oogsten van stelen met klein roosje",
    points=["Dooroogst", "Sneller dan broccoli", "Rupsengaas", "Vochtig houden"],
    summary="Bimi (broccolini) geeft dunne stelen met klein roosje. Regelmatig snijden houdt productie op gang.",
    know="Vaak milder en malser dan klassieke broccoli."))
entries.append(entry("broccoli_rabe", **kool_common, sow=[3, 4, 8, 9], plant=[], harvest=[5, 6, 10, 11],
    height="30–50 cm", width="30–40 cm", habit="Snel blad/scheutgewas", spacing="20–25 cm", row="30 cm",
    first="±40–60 dagen", period="voorjaar en najaar", yield_level="Gemiddelde opbrengst",
    yield_detail="Oogst jonge scheuten vóór volle bloei",
    points=["Snel", "Licht bitter", "Koele seizoenen", "Dicht zaaien mogelijk"],
    summary="Broccoli rabe (rapini) groeit snel in koele periodes. Oogst jonge scheuten voor ze volledig bloeien.",
    know="Meer verwant aan raapstelen dan aan dikke broccoli."))
entries.append(entry("bloemkool", **kool_common, sow=[3, 4, 5], plant=[4, 5, 6], harvest=[6, 7, 8, 9, 10],
    height="40–70 cm", width="50–60 cm", habit="Witte koolbloem", spacing="50–60 cm", row="60–70 cm",
    first="±80–110 dagen", period="juni – oktober", yield_level="Gemiddelde opbrengst",
    yield_detail="1 hoofd per plant; bladeren over hoofd vouwen tegen zon",
    points=["Gelijkmatig vochtig", "Niet laten verkleuren", "Voedingsrijk", "Rupsengaas"],
    summary="Bloemkool is veeleisend qua vocht en voeding. Bescherm het hoofd tegen fel zonlicht.",
    know="Droogtestress geeft snel losse of gele schermen."))
entries.append(entry("bloemkool_paars", **kool_common, sow=[3, 4, 5], plant=[4, 5, 6], harvest=[7, 8, 9, 10],
    height="40–70 cm", width="50–60 cm", habit="Paars scherm", spacing="50–60 cm", row="60–70 cm",
    first="±85–120 dagen", period="juli – oktober", yield_level="Gemiddelde opbrengst",
    yield_detail="Paarse kleur; wordt groener bij koken",
    points=["Zelfde teelt als bloemkool", "Kleurrijk", "Vochtig houden", "Rupsengaas"],
    summary="Paarse bloemkool teel je als witte bloemkool. De kleur is decoratief en verkleurt bij koken.",
    know="Kort stomen houdt meer kleur dan lang koken."))
entries.append(entry("romanesco", **kool_common, sow=[4, 5], plant=[5, 6], harvest=[8, 9, 10],
    height="40–70 cm", width="50–60 cm", habit="Spiraalvormig scherm", spacing="50–60 cm", row="60–70 cm",
    first="±90–120 dagen", period="augustus – oktober", yield_level="Gemiddelde opbrengst",
    yield_detail="1 geometrisch hoofd per plant",
    points=["Iets lastiger", "Gelijkmatige groei", "Voeding en water", "Rupsengaas"],
    summary="Romanesco vraagt rustige, gelijkmatige groei. Oogst het spiraalscherm vóór het los komt.",
    know="Groeistops door droogte geven snel misvormde schermen."))
entries.append(entry("wittekool", **kool_common, sow=[3, 4, 5], plant=[4, 5, 6], harvest=[8, 9, 10, 11],
    height="40–60 cm", width="50–70 cm", habit="Zware kropkool", spacing="50–60 cm", row="60–70 cm",
    first="±90–140 dagen", period="augustus – november", yield_level="Hoge opbrengst",
    yield_detail="Grote kroppen; goed bewaarbaar",
    points=["Veel ruimte", "Zware voeding", "Rupsengaas", "Bewaren mogelijk"],
    summary="Wittekool is een klassieke bewaarkool. Geef ruimte, voeding en bescherming tegen rupsen.",
    know="Stevig aanvoelen van de krop is een goed oogstsignaal."))
entries.append(entry("rodekool", **kool_common, sow=[3, 4, 5], plant=[4, 5, 6], harvest=[9, 10, 11],
    height="40–60 cm", width="50–70 cm", habit="Rode bewaarkool", spacing="50–60 cm", row="60–70 cm",
    first="±100–150 dagen", period="september – november", yield_level="Hoge opbrengst",
    yield_detail="Stevige kroppen; uitstekend bewaarbaar",
    points=["Lange teelt", "Voedingsrijk", "Rupsengaas", "Goede bewaarkool"],
    summary="Rodekool heeft een lang seizoen nodig. Teelt verder als wittekool met goede bemesting.",
    know="Bij zuren blijft de rode kleur mooi behouden."))
entries.append(entry("savooiekool", **kool_common, sow=[4, 5], plant=[5, 6, 7], harvest=[9, 10, 11, 12],
    height="40–60 cm", width="50–70 cm", habit="Gekrulde bewaarkool", spacing="50–60 cm", row="60–70 cm",
    first="±90–130 dagen", period="september – december", yield_level="Hoge opbrengst",
    yield_detail="Winterharde gekrulde kroppen",
    points=["Koudetolerant", "Rupsengaas", "Voedingrijk", "Najaarsoogst"],
    summary="Savooiekool verdraagt kou goed. Plant in voorzomer voor stevige najaarskroppen.",
    know="Gekrulde bladeren zijn malser dan gladde bewaarkool."))
entries.append(entry("rode_savooi", **kool_common, sow=[4, 5], plant=[5, 6, 7], harvest=[9, 10, 11, 12],
    height="40–60 cm", width="50–70 cm", habit="Rode gekrulde kool", spacing="50–60 cm", row="60–70 cm",
    first="±95–140 dagen", period="september – december", yield_level="Hoge opbrengst",
    yield_detail="Decoratieve rode savooiekroppen",
    points=["Koudetolerant", "Decoratief", "Rupsengaas", "Najaarsoogst"],
    summary="Rode savooi combineert koudetolerantie met opvallende kleur. Zelfde teelt als groene savooi.",
    know="Mooi voor winterse stamppot én als sierlijke oogst."))
entries.append(entry("spitskool", **kool_common, sow=[3, 4, 5, 6, 7], plant=[4, 5, 6, 7], harvest=[6, 7, 8, 9, 10],
    height="40–60 cm", width="40–50 cm", habit="Spitse, snellere kool", spacing="40–45 cm", row="50–60 cm",
    first="±60–90 dagen", period="juni – oktober", yield_level="Gemiddelde opbrengst",
    yield_detail="Vroeger en malser dan bewaarkool",
    points=["Sneller dan witte kool", "Mals blad", "Rupsengaas", "Niet lang bewaren"],
    summary="Spitskool is sneller en malser dan bewaarkool. Ideaal voor zomer- en vroege herfstoogst.",
    know="Minder geschikt voor lange bewaring dan wittekool."))
entries.append(entry("spruitkool", **kool_common, sow=[3, 4], plant=[5, 6], harvest=[10, 11, 12, 1, 2],
    height="70–100 cm", width="50–60 cm", habit="Hoge stengel met spruiten", spacing="50–60 cm", row="70 cm",
    first="±150–180 dagen", period="oktober – februari", yield_level="Hoge opbrengst",
    yield_detail="Van onderaf plukken na vorst zoeter",
    points=["Lange teelt", "Winteroogst", "Steun soms nodig", "Rupsengaas"],
    summary="Spruitkool heeft een lang seizoen. Plant in het voorjaar en oogst spruiten in de winter.",
    know="Na vorst smaken spruiten zoeter."))
entries.append(entry("spruitkool_rood", **kool_common, sow=[3, 4], plant=[5, 6], harvest=[10, 11, 12, 1, 2],
    height="70–100 cm", width="50–60 cm", habit="Rode spruiten", spacing="50–60 cm", row="70 cm",
    first="±150–180 dagen", period="oktober – februari", yield_level="Hoge opbrengst",
    yield_detail="Rode spruiten; zelfde lange teelt",
    points=["Lange teelt", "Decoratief", "Winteroogst", "Rupsengaas"],
    summary="Rode spruitkool teel je als groene spruitkool. De kleur blijft mooi na korte bereiding.",
    know="Iets lager productief soms, maar opvallend op het bord."))
entries.append(entry("koolrabi", **kool_common, sow=[3, 4, 5, 6, 7], plant=[4, 5, 6, 7], harvest=[5, 6, 7, 8, 9, 10],
    height="30–45 cm", width="25–35 cm", habit="Bovengrondse knol", spacing="25–30 cm", row="35 cm",
    first="±50–70 dagen", period="mei – oktober", yield_level="Gemiddelde opbrengst",
    yield_detail="Oogst bij tennisbalgrootte",
    points=["Snel", "Niet te groot laten worden", "Vochtig houden", "Rupsengaas"],
    summary="Koolrabi groeit snel. Oogst bij tennisbalgrootte voor malse knollen zonder houtige vezels.",
    know="Te grote knollen worden snel houtig."))
entries.append(entry("koolraap", **kool_common, sow=[5, 6, 7], plant=[], harvest=[9, 10, 11, 12],
    height="40–60 cm", width="30–40 cm", habit="Ondergrondse knol", spacing="30–40 cm", row="40 cm",
    first="±90–120 dagen", period="september – december", yield_level="Gemiddelde opbrengst",
    yield_detail="Grote bewaarknollen",
    points=["Najaarsgewas", "Losse grond", "Niet te vroeg zaaien", "Goed bewaarbaar"],
    summary="Koolraap is een stevige najaarsknol. Zaai in zomer voor oogst en bewaring in de herfst.",
    know="Te vroeg zaaien verhoogt kans op doorschieten."))
entries.append(entry("raapkool", **kool_common, sow=[7, 8], plant=[], harvest=[9, 10, 11],
    height="30–50 cm", width="25–35 cm", habit="Snelle herfstknol/blad", spacing="20–25 cm", row="30 cm",
    first="±50–70 dagen", period="september – november", yield_level="Gemiddelde opbrengst",
    yield_detail="Jonge knollen of blad oogsten",
    points=["Najaarsgewas", "Snel", "Koele teelt", "Niet te dik zaaien"],
    summary="Raapkool groeit snel in het najaar. Oogst jong voor milde smaak.",
    know="Jonge bladeren zijn ook eetbaar als raapstelen-achtige groente."))
entries.append(entry("raapstelen", **kool_common, sow=[3, 4, 8, 9], plant=[], harvest=[4, 5, 9, 10],
    height="20–35 cm", width="15–25 cm", habit="Snel bladgewas", spacing="5–10 cm", row="20 cm",
    first="±30–45 dagen", period="voorjaar en najaar", yield_level="Hoge opbrengst",
    yield_detail="Meerdere snedes van jong blad",
    points=["Zeer snel", "Koele seizoenen", "Doorzaaien", "Beginnersvriendelijk"],
    summary="Raapstelen zijn snelle bladgroenten voor voorjaar en najaar. Oogst jong en zaai opnieuw.",
    know="In de zomer schieten ze snel door naar bloei."))
entries.append(entry("paksoi", **kool_common, sow=[4, 5, 6, 7, 8], plant=[5, 6, 7, 8], harvest=[5, 6, 7, 8, 9, 10],
    height="30–45 cm", width="25–35 cm", habit="Steelige bladkool", spacing="25–30 cm", row="35 cm",
    first="±45–60 dagen", period="mei – oktober", yield_level="Hoge opbrengst",
    yield_detail="Hele krop of blad oogsten",
    points=["Snel", "Vochtig houden", "Rupsengaas", "Niet te warm laten doorschieten"],
    summary="Paksoi groeit snel en houdt van vocht. In hitte schiet ze makkelijk door.",
    know="Voor zomerteelt halfschaduw en voldoende water helpen."))
entries.append(entry("paksoi_jong", **kool_common, sow=[4, 5, 6, 7, 8, 9], plant=[], harvest=[5, 6, 7, 8, 9, 10],
    height="15–25 cm", width="10–20 cm", habit="Babyleaf / mini paksoi", spacing="8–12 cm", row="20 cm",
    first="±25–40 dagen", period="mei – oktober", yield_level="Hoge opbrengst",
    yield_detail="Oogst als mini-krop of babyleaf",
    points=["Supersnel", "Potgeschikt", "Doorzaaien", "Milder dan grote paksoi"],
    summary="Jonge paksoi oogst je als mini-krop. Dicht zaaien en vroeg plukken geeft malse planten.",
    know="Ideaal voor wok en salade binnen 4–6 weken."))
entries.append(entry("chinese_kool", **kool_common, sow=[6, 7, 8], plant=[7, 8], harvest=[9, 10, 11],
    height="30–45 cm", width="30–40 cm", habit="Langwerpige krop", spacing="30–35 cm", row="40 cm",
    first="±60–80 dagen", period="september – november", yield_level="Gemiddelde opbrengst",
    yield_detail="Najaarskroppen; voorjaar schiet snel door",
    points=["Bij voorkeur najaar", "Vochtig", "Rupsengaas", "Niet te vroeg zaaien"],
    summary="Chinese kool lukt het best als najaarsgewas. Voorjaarszaai schiet vaak door.",
    know="Korte daglengte in nazomer/herfst helpt kropvorming."))

# --- Aardappel ---
aardappel = dict(
    sow=[], plant=[3, 4, 5], harvest=[6, 7, 8, 9],
    standplaats="Zon", water="Gemiddeld", difficulty="Makkelijk", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Gemiddeld",
    height="40–70 cm", width="30–40 cm", habit="Aanaarden bij groei", spacing="30–35 cm", row="60–75 cm",
    first="±70–120 dagen", period="juni – september",
    yield_level="Hoge opbrengst", yield_detail="Meerdere knollen per plant; aanaarden voorkomt groen",
    points=["Pootgoed gebruiken", "Aanaarden", "Niet te nat bewaren", "Vorstvrij houden"],
)
entries.append(entry("aardappel", **aardappel, summary="Aardappelen plant je als pootgoed in het voorjaar. Aard aan en oogst na de bloei of wanneer het loof afsterft.", know="Groene knollen bevatten solanine; goed aanaarden voorkomt dit."))
entries.append(entry("vroege_aardappel", **{**aardappel, "plant": [3, 4], "harvest": [6, 7], "first": "±70–90 dagen", "period": "juni – juli", "yield_detail": "Vroege oogst; minder bewaarbaar"}, summary="Vroege aardappelen geef je een voorsprong onder vlies of in warme grond. Oogst jong als krieltjes of vastkokend.", know="Niet bedoeld voor lange bewaring."))
entries.append(entry("vastkokende_aardappel", **{**aardappel, "harvest": [8, 9], "yield_detail": "Blijft heel bij koken; goede bewaarknol"}, summary="Vastkokende rassen oogst je als het loof afsterft. Goed drogen en donker bewaren.", know="Ideaal voor salade en oven; minder kruimelig."))
entries.append(entry("kruimige_aardappel", **{**aardappel, "harvest": [8, 9], "yield_detail": "Kruimelig; goed voor puree en friet"}, summary="Kruimige aardappelen hebben een langer seizoen nodig en bewaren vaak goed.", know="Laat knollen narijpen met afstervend loof voor betere schil."))
entries.append(entry(
    "zoete_aardappel",
    sow=[], plant=[5, 6], harvest=[9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Eenjarig",
    outdoor="Buiten / Kas", container="Grote bak", voeding="Gemiddeld",
    height="rankend", width="100–200 cm", habit="Warmteminnende ranken", spacing="40–50 cm", row="80–100 cm",
    first="±100–140 dagen", period="september – oktober",
    yield_level="Beperkte opbrengst", yield_detail="Alleen in warme zomer of kas betrouwbaar",
    points=["Veel warmte", "Pas na ijsheiligen", "Lange teelt", "Voorzichtig oogsten"],
    summary="Zoete aardappel vraagt veel warmte. Plant stekken pas in juni en oogst voor de vorst.",
    know="Knollen narijpen warm en droog voor zoetere smaak.",
))
entries.append(entry(
    "aardpeer",
    sow=[], plant=[3, 4], harvest=[10, 11, 12, 1, 2],
    standplaats="Zon", water="Laag", difficulty="Makkelijk", lifespan="Meerjarig",
    outdoor="Buiten", container="Volle grond", voeding="Laag",
    height="200–300 cm", width="50–80 cm", habit="Hoge meerjarige knol", spacing="40–50 cm", row="60 cm",
    first="±150–180 dagen", period="oktober – februari",
    yield_level="Hoge opbrengst", yield_detail="Komt elk jaar terug; kan woekeren",
    points=["Meerjarig", "Kan woekeren", "Winteroogst", "Weinig zorg"],
    summary="Aardpeer is meerjarig en productief. Plant knollen in voorjaar en oogst in winter.",
    know="Laat geen knolresten achter als je verspreiding wilt beperken.",
))

# --- Aubergine ---
entries.append(entry(
    "aubergine",
    sow=[2, 3], plant=[5, 6], harvest=[7, 8, 9, 10],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Eenjarig",
    outdoor="Buiten / Kas", container="Pot / Balkon", voeding="Hoog",
    height="60–100 cm", width="40–50 cm", habit="Warmteminnende struik", spacing="45–50 cm", row="60 cm",
    first="±80–100 dagen na uitplanten", period="juli – oktober",
    yield_level="Gemiddelde opbrengst", yield_detail="Meer vruchten in kas; steun bij zware belading",
    points=["Kas sterk aanbevolen", "Lang voorzaaien", "Veel warmte", "Oogsten glanzend"],
    summary="Aubergine lukt in NL vooral in de kas. Voorzaaien vroeg en pas uitplanten bij echte warmte.",
    know="Doffe vruchten zijn vaak te oud; oogst bij glanzende schil.",
))

# --- Mais ---
entries.append(entry(
    "mais",
    sow=[5], plant=[5, 6], harvest=[8, 9],
    standplaats="Zon", water="Hoog", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="180–250 cm", width="30–40 cm", habit="Hoog, in blok zaaien", spacing="30–40 cm", row="60–70 cm",
    first="±90–110 dagen", period="augustus – september",
    yield_level="Gemiddelde opbrengst", yield_detail="Blokgewijs zaaien voor bestuiving",
    points=["In een blok zaaien", "Veel zon en voeding", "Windgevoelig", "Oogst melkerig"],
    summary="Suikermais zaai je in een blok voor goede bestuiving. Geef voeding, water en oogst bij melkerig stadium.",
    know="Rijen van één breedte bestuiven slecht; maak minstens een vierkant blok.",
))
entries.append(entry(
    "maiskolf",
    sow=[5], plant=[5, 6], harvest=[8, 9],
    standplaats="Zon", water="Hoog", difficulty="Gemiddeld", lifespan="Eenjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="180–250 cm", width="30–40 cm", habit="Suikermaiskolf", spacing="30–40 cm", row="60–70 cm",
    first="±90–110 dagen", period="augustus – september",
    yield_level="Gemiddelde opbrengst", yield_detail="1–2 kolven per plant gebruikelijk",
    points=["Blokgewijs planten", "Snel verwerken na oogst", "Veel water", "Warmte helpt"],
    summary="Maiskolven oogst je als de draden bruin zijn en korrels melkerig. Verwerk snel voor zoetheid.",
    know="Suikermais wordt snel zetmeelachtig na de oogst.",
))

# --- Meerjarig ---
entries.append(entry(
    "rabarber",
    sow=[], plant=[3, 4, 10, 11], harvest=[4, 5, 6],
    standplaats="Halfschaduw", water="Hoog", difficulty="Makkelijk", lifespan="Meerjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="60–100 cm", width="80–120 cm", habit="Grote bladplant met stelen", spacing="100 cm", row="100 cm",
    first="vanaf 2e jaar", period="april – juni",
    yield_level="Hoge opbrengst", yield_detail="Stelen trekken; blad is giftig",
    points=["Meerjarig", "Niet alle stelen oogsten", "Blad niet eten", "Rijke grond"],
    summary="Rabarber is meerjarig en vroeg in het voorjaar oogstbaar. Eet alleen de stelen, nooit het blad.",
    know="Stop met oogsten in de zomer zodat de plant kan herstellen.",
))
entries.append(entry(
    "asperge",
    sow=[], plant=[3, 4], harvest=[4, 5, 6],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Meerjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="100–150 cm loof", width="40–50 cm", habit="Meerjarige bedcultuur", spacing="30–40 cm", row="120–150 cm",
    first="vanaf 3e jaar", period="april – juni",
    yield_level="Hoge opbrengst", yield_detail="Jarenlange oogst na aanslag",
    points=["Meerjarig bed", "Geduld nodig", "Niet te vroeg oogsten", "Na juni laten groeien"],
    summary="Asperge vraagt een vast bed en geduld. Pas vanaf het derde jaar vol oogsten.",
    know="Na eind juni niet meer steken zodat wortels kunnen herstellen.",
))
entries.append(entry(
    "groene_asperge",
    sow=[], plant=[3, 4], harvest=[4, 5, 6],
    standplaats="Zon", water="Gemiddeld", difficulty="Gemiddeld", lifespan="Meerjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="100–150 cm loof", width="40–50 cm", habit="Bovengronds steken", spacing="30–40 cm", row="120 cm",
    first="vanaf 3e jaar", period="april – juni",
    yield_level="Hoge opbrengst", yield_detail="Groene stengels boven de grond oogsten",
    points=["Geen rug nodig", "Meerjarig", "Zonnige plek", "Geduld"],
    summary="Groene asperge steek je bovengronds en is iets makkelijker dan witte aspergeteelt.",
    know="Dagelijks oogsten in het seizoen houdt kwaliteit hoog.",
))
entries.append(entry(
    "witte_asperge",
    sow=[], plant=[3, 4], harvest=[4, 5, 6],
    standplaats="Zon", water="Gemiddeld", difficulty="Moeilijk", lifespan="Meerjarig",
    outdoor="Buiten", container="Volle grond", voeding="Hoog",
    height="rugteelt", width="40–50 cm", habit="Onder rug bleken", spacing="30–40 cm", row="150 cm",
    first="vanaf 3e jaar", period="april – juni",
    yield_level="Hoge opbrengst", yield_detail="Steken zodra kop de rug raakt",
    points=["Ruggen maken", "Meer werk", "Zandgrond helpt", "Meerjarig bed"],
    summary="Witte asperge wordt onder een grondrug gebleekt. Meer werk, klassieke teelt.",
    know="Steek vroeg op de dag voor de mooiste witte stengels.",
))
entries.append(entry(
    "zuring",
    sow=[3, 4, 8, 9], plant=[4, 5, 9], harvest=[4, 5, 6, 7, 8, 9],
    standplaats="Halfschaduw", water="Hoog", difficulty="Makkelijk", lifespan="Meerjarig",
    outdoor="Buiten", container="Pot / Balkon", voeding="Gemiddeld",
    height="30–60 cm", width="30–40 cm", habit="Meerjarig zuur blad", spacing="30 cm", row="30 cm",
    first="±40–60 dagen", period="april – september",
    yield_level="Gemiddelde opbrengst", yield_detail="Blad voor blad; kan jaren terugkomen",
    points=["Meerjarig", "Zure smaak", "Vochtig houden", "Pot remt woekeren"],
    summary="Zuring is meerjarig en geeft friszuur blad. Houd vochtig en oogst jonge bladeren.",
    know="In pot houden voorkomt dat zuring zich te sterk uitbreidt.",
))

# Write dart file
header = '''// GENERATED by tool/generate_vegetable_overview.py — curated NL vegetable overview facts.
// ignore_for_file: prefer_const_constructors

part of 'vegetable_overview_data.dart';

const Map<String, VegetableOverviewFacts> kVegetableOverviewFacts = {
'''
footer = '''
};
'''

OUT.write_text(header + "\n".join(entries) + footer, encoding="utf-8")
ids = [e.split("'")[1] for e in entries]
print(f"Wrote {len(entries)} entries -> {OUT}")
missing_check = sorted(set(ids))
print("IDs:", len(missing_check))
