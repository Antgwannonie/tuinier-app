/// JSON-schema voor uitgebreide plantanalyse (NL).
const String kPlantAiInsightJsonSchema = '''
  "insight": {
    "summary": "1-2 zinnen: korte samenvatting voor de tuinier",
    "healthScore": <int 0-100 algemene gezondheid>,
    "growthScore": <int 0-100 groei/kracht>,
    "harvestChancePercent": <int 0-100 VERPLICHT: kans dat oogst nog haalbaar is>,
    "harvestChanceNote": <NL 1-2 zinnen VERPLICHT: waarom dit % — zichtbare koppen/vruchten, volwassenheid, gezondheid>,
    "riskLevel": "low|medium|high",
    "priority": "low|medium|high|urgent",
    "problems": ["korte NL problemen die je ziet, max 6"],
    "pests": [
      {"id":"bladluis","labelNl":"Bladluis","detected":<bool>,"confidencePercent":<0-100>,"symptoms":<of null>,"action":<of null>},
      {"id":"witte_vlieg","labelNl":"Witte vlieg","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"spint","labelNl":"Spint","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"trips","labelNl":"Trips","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"rups","labelNl":"Rupsen","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"kever","labelNl":"Kevers","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"slak","labelNl":"Slakken","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>}
    ],
    "diseases": [
      {"id":"meeldauw","labelNl":"Meeldauw","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"valse_meeldauw","labelNl":"Valse meeldauw","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"roest","labelNl":"Roest","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"bladvlek","labelNl":"Bladvlekkenziekte","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>},
      {"id":"schimmel","labelNl":"Schimmelinfectie","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"action":<of null>}
    ],
    "waterStatus": "ok|too_dry|too_wet|wilting",
    "waterSymptoms": <NL of null>,
    "waterAdvice": <praktisch NL of null>,
    "nutrients": [
      {"id":"stikstof","labelNl":"Stikstoftekort","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"explanation":<of null>},
      {"id":"magnesium","labelNl":"Magnesiumtekort","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"explanation":<of null>},
      {"id":"kalium","labelNl":"Kaliumtekort","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"explanation":<of null>},
      {"id":"ijzer","labelNl":"IJzertekort","detected":<bool>,"confidencePercent":<int>,"symptoms":<of null>,"explanation":<of null>}
    ],
    "growthPhaseDetail": "zaailing|jonge_plant|vegetatief|bloei|vruchtvorming|oogst",
    "harvestReady": <bool>,
    "moreHarvestExpectedThisSeason": <bool|null: kan deze plant LATER DIT SEIZOEN nog meer oogst geven?>,
    "seasonHarvestComplete": <bool|null: is oogst voor DIT SEIZOEN volledig uitgeput?>,
    "harvestAlternativeTips": [<NL tips als er geen natuurlijke oogst meer komt maar alternatieven zijn, bv. blad oogsten, stekken, kas, max 4>],
    "plantLikelyDead": <bool|null: lijkt de plant dood of irreversibel beschadigd?>,
    "deadPlantCheckSteps": [<NL stappen om te controleren of de plant echt dood is, max 5>],
    "ripenessNote": <NL of null; bij zichtbare vruchten: geschatte cm + supermarktvergelijking + rijpheid>,
    "fruitSizeVsMarket": <"much_smaller"|"smaller"|"market_size"|"oversized"|"no_fruit_visible"|null>,
    "floweringStatus": "none|buds|blooming|faded",
    "floweringNote": <NL of null>,
    "growthScheduleStatus": "ahead|on_track|behind|unknown",
    "growthScheduleWeeksDelta": <int weken voor/achter; 0 als unknown>,
    "growthScheduleNote": <NL vergelijking met gemiddelde plant van dit gewas, bijv. 2 weken achter door schaduw>,
    "adjustedHarvestLabel": <NL datum/venster na correctie of null>,
    "pruningAdvice": <NL snoei: dode bladeren, uitdunnen, dieven bij tomaat, of null>,
    "weedsDetected": <bool>,
    "weedsNote": <NL of null>,
    "sunlightLevel": "veel|gemiddeld|weinig",
    "sunlightAdvice": <NL standplaats of null>,
    "recommendedActions": [
      {"title":"korte taak","description":"optioneel","reasonSummary":"koppeling aan wat je op de foto ziet","linkedObservationTitle":"exacte titel uit visualObservations","steps":["stap 1","stap 2"],"priority":"low|medium|high|urgent"}
    ],
    "coachTasks": [
      {"title":"bijv. Water geven","body":"optioneel","kind":"water|fertilize|prune|check|harvest"}
    ],
    "moduleConfidence": {
      "health": <0-100 zekerheid gezondheidsbeoordeling>,
      "growth": <0-100>,
      "growthPhase": <0-100>,
      "scanComparison": <0-100 of null zonder vorige scan>,
      "flowering": <0-100>,
      "fruits": <0-100>,
      "leaves": <0-100>,
      "pests": <0-100>,
      "diseases": <0-100>,
      "environment": <0-100>,
      "strengths": <0-100>,
      "attention": <0-100>,
      "pruning": <0-100>,
      "tasks": <0-100>,
      "harvestForecast": <0-100>,
      "season": <0-100>,
      "weekFocus": <0-100>,
      "outlook": <0-100>
    },
    "scanComparisonBullets": [<NL vergelijking met vorige scan, max 5, bv. "+5 nieuwe bladeren">],
    "leafAnalysisNote": <NL bladbeeld of null>,
    "strengths": [<NL positieve punten op foto, max 4>],
    "attentionPoints": [<NL waar tuinier op moet letten, max 5>],
    "environmentNote": <NL weer/standplaats invloed of null>,
    "weekFocus": <NL belangrijkste taak deze week of null>,
    "outlookBullets": [<NL verwachting komende weken, max 4>],
    "coachWeekPlan": [<NL genummerd weekplan, max 5>],
    "didYouKnow": <NL weetje specifiek over dit gewas of null>,
    "visualObservations": [
      {"title":"korte titel","description":"wat de AI precies op de foto ziet","scorePercent":<0-100 positiviteit voor gezondheid/oogst>,"kind":"leaf|flower|fruit|pest|slug|water|disease|damage|growth|other"}
    ],
    "scanAssessments": [
      {"taskId":"exact id uit checklist","kind":"task|let_op|positive","title":"korte titel","description":"1-2 zinnen NL","scorePercent":<0-100; verplicht bij positive, optioneel bij task/let_op>,"steps":["stap 1"],"visibleOnPhoto":<true als op foto zichtbaar>}
    ]
  }
''';

const String kPlantAiInsightInstructions = '''
STAP 3: alleen bij matchesSelectedCrop = true: vul ook het geneste object "insight" in.

=== CHECKLIST-SYSTEEM (scanAssessments — VERPLICHT, FASEBEWUST) ===
De app levert een FASEBEWUSTE checklist (zie prompt). Werkwijze:
1. Bepaal EERST groeifase op de foto: top-level "phase" + insight "growthPhaseDetail".
2. Loop ALLEEN de checklist-items van DIE fase langs.
3. Output scanAssessments alleen wat nu relevant is voor deze fase en dit gewas.

FASE-REGELS (strikt):
- Zaailing: GEEN oogst, geen dieven, geen uitgebloeide bloemen. Focus vocht, licht, slakken, uitdunnen.
- Zaadbed zonder plant: alleen zaadbed-vocht/bescherming; geen plaagtaken.
- Vegetatief: geen oogst (behalve bladgewas); wel voeding, steun, onkruid.
- Bloei: focus bloemen/bestuiving; geen oogst van nog niet gevormde vruchten.
- Vruchtvorming/oogst: oogst en rijpheid wel relevant; minder uitdunnen.
- growthPhaseDetail MOET logisch passen bij wat je op de foto ziet én bij top-level phase.

Drie soorten output (kind):
- "task": concrete actie nodig — zichtbaar op foto OF duidelijke actie (water geven, wieden, bestrijden).
- "let_op": plant-specifiek risico of tip die NIET op foto zichtbaar is, maar nu relevant (bv. koolrups-controle onder blad, vorst, typisch gewasrisico).
- "positive": gaat goed op foto — fris blad, gezonde groei, mooie bloei (geef goed gevoel).

Regels scanAssessments:
- Alleen items outputten die NU relevant zijn (niet alles forceren).
- Zelfde taskId NOOIT als task én let_op — kies task als actie nodig, anders let_op.
- positive: minstens 1 als er iets goed gaat op foto; scorePercent 75-100.
- task: steps met 1-3 concrete stappen; visibleOnPhoto=true als op foto zichtbaar.
- task + visibleOnPhoto=true: description VERPLICHT — beschrijf PRECIES wat je op de foto ziet (app toont dit als observatie-kop vóór de taak, bv. "Onkruid zichtbaar" + uitleg).
- Zonder zichtbaar bewijs op foto: visibleOnPhoto=false → dan let_op als het een risico is, geen task tenzij duidelijke actie nodig.
- let_op: visibleOnPhoto=false; geen steps nodig (wel description).
- Gebruik plant-specifieke kennis uit checklist (commonIssues, verzorging, fase).
- let_op en positive moeten ook fase-passend zijn (zaailing: let_op op uitrekken/slakken, niet op oogst).

ROUTING (app regelt dit — jij levert juiste kind):
- task → moestuin Taken + scan Taken-sectie
- task + visibleOnPhoto=true → ook observatie-kop in scan (wat je ziet op foto)
- let_op → moestuin Let op — NIET in scan-koppen
- positive → scan observatie-koppen (alleen positief) — NIET in moestuin taken/info

=== HOOFDREGEL: FOTO + CHECKLIST ===
Beoordeel op basis van DEZE foto én plant-specifieke checklist.
- Geen algemene teeltkennis zonder link naar dit gewas of deze foto.
- Geen plagen/ziektes als task of let_op zonder relevantie voor dit gewas of fase.
- Zie je gezond blad → positive assessment (gezonde_groei of eigen titel).
- Zie je bladluis → task bladluis (visibleOnPhoto=true).

OOGSTKANS (harvestChancePercent + harvestChanceNote — VERPLICHT):
- harvestChancePercent: jouw inschatting (0-100) of oogst NOG HAalbaar is, puur op basis van wat je op DEZE foto ziet.
- Kijk expliciet naar zichtbare oogstdeel (koppen, vruchten, peulen, knollen), volwassenheid/rijpheid, en algehele gezondheid van de plant.
- Dit is GEEN vaste schaal: kies een eerlijk percentage dat past bij wat je ziet (bv. 73%, 41%, 88%).
- Richtlijnen: 85-100 zeer waarschijnlijk haalbaar; 65-84 goede kans; 45-64 matig; 25-44 laag; 0-24 vrijwel niet meer haalbaar.
- Lage gezondheid, ernstige schade, te jonge plant, geen oogstdeel zichtbaar, of plant lijkt dood → lager %.
- harvestChanceNote: 1-2 zinnen NL waarom (wat je ziet aan koppen/vruchten, groei, gezondheid).
- De app toont dit als vaste "Oogstkans"-kaart — zet dit NOOIT als visualObservation of positive assessment.
- Gebruik ook daysUntilHarvest (top-level JSON) en ripenessNote/fruitHarvestNote waar van toepassing.

OOGSTKANS-KAART (altijd door de app, NIET in visualObservations/scanAssessments positive):
- De app toont automatisch één vaste kaart "Oogstkans" met harvestChancePercent en dagen tot oogst.

visualObservations (legacy/backup — mag leeg als scanAssessments compleet is):
- Optioneel: extra zichtbare details. De app gebruikt vooral scanAssessments kind=positive voor observatie-koppen.
- Geen negatieve observatie-koppen meer — problemen via scanAssessments kind=task.

recommendedActions (legacy — app vult uit scanAssessments kind=task):
- Mag leeg blijven; taken komen uit scanAssessments.

summary: max 2 zinnen; bevindingen van DEZE foto + fase + belangrijkste actie.
healthScore: gezondheid op foto. Plantscore in app = gemiddelde positive scanAssessments scorePercent.
growthScore: groei/kracht op foto (niet hetzelfde als harvestChancePercent).
growthPhaseDetail: VERPLICHT en fase-passend (zaailing|jonge_plant|vegetatief|bloei|vruchtvorming|oogst).

pests / diseases / nutrients:
- detected=true ALLEEN bij duidelijk zichtbaar op foto; anders false.
- Bij detected=true: ook scanAssessments task met zelfde taskId.

problems / attentionPoints / strengths:
- Optioneel; liever scanAssessments gebruiken.

waterStatus / waterSymptoms:
- Alleen invullen als droogte, natte grond of verwelking ZICHTBAAR is op foto.

leafAnalysisNote, floweringNote, ripenessNote, pruningAdvice:
- Alleen bij duidelijk zichtbaar op foto; anders null.

NIET invullen (leeg/null, moduleConfidence < 80):
- environmentNote (geen weer buiten foto)
- weekFocus, coachWeekPlan, didYouKnow, outlookBullets
- scanComparisonBullets zonder vorige scan

Overige regels:
- Wees conservatief: detected=true alleen bij duidelijke visuele signalen.
- coachTasks: leeg laten — scanAssessments heeft voorrang.
- Bij zichtbare vruchten: ripenessNote met geschatte grootte; harvestReady alleen bij duidelijk eetrijp.
- Bij ondergrondse gewassen op plantfoto: harvestReady=false; onzekerheid vermelden.
- Bij sier-moestuinbloemen: harvestReady=false.
- moduleConfidence: eerlijk; optionele modules < 80 als niet zichtbaar op foto.
- scanComparisonBullets: alleen met vorige scan.
''';
